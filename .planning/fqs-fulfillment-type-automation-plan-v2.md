# FQS Fulfillment Type Automation — v2

**Status:** Active build 2026-08-14. Supersedes archived v1 (which was never actually shipped despite the archive README claim).

## Problem

`GiftCommitment.FulfillmentType` (Unconditional / Conditional) drives the record page's "Designations" tab visibility and reporting categorization, but today nothing keeps it in sync with the GC's actual restriction posture. Values are set by launcher hard-codes (donor-recurring always writes Unconditional, grants seed Conditional) and never re-evaluated when the underlying signals change.

## Rule

```
GC.FulfillmentType = 'Conditional'  IF:
    ANY child GDD (ParentRecordId = GC.Id) has FQS_Restriction_Type != 'Without Donor Restriction'
    OR
    GC.FQS_Restriction_Release_Date__c is populated

ELSE 'Unconditional'
```

Only `Without Donor Restriction` GDs → Unconditional. `Earned Revenue`, `With Donor Restriction - Purpose`, and `With Donor Restriction - Permanent` all force Conditional — once any restriction is attached (even a revenue-recognition earmark), the commitment is conditional.

Release date: presence of any release date (past or future) forces Conditional. The commitment flips to Unconditional only when the date is cleared or the restricted designations are removed — no scheduled crossing job is needed.

## Automation surfaces

| # | Flow | Trigger | Job |
|---|---|---|---|
| 1 | `FQS_Recalculate_GC_FulfillmentType` (autolaunched subflow) | Input: `giftCommitmentId` | Query GC + child GDDs, compute rule, write GC only if value changed |
| 2 | `FQS_GC_Fulfillment_On_Change` (record-triggered on GC, AfterSave) | Insert OR `FQS_Restriction_Release_Date__c` changes | Calls subflow with `$Record.Id` |
| 3 | `FQS_GC_Fulfillment_From_GDD` (record-triggered on GDD, AfterSave, Create+Update) | GDD insert / restriction-type change / parent GC change | If `ParentRecordId` is a GC (key prefix `6gc`), calls subflow with `ParentRecordId` |
| 4 | `FQS_GC_Fulfillment_From_GDD_Delete` (record-triggered on GDD, BeforeDelete) | GDD delete | Same subflow call for the parent GC |

## Deliberately out of scope

- **No fan-out from GD.FQS_Restriction_Type__c changes.** Restriction type is set at GD creation and almost never changes post-hoc. Building a Loop-over-GDDs from GD adds bulk-DML risk and complexity that doesn't pay for itself. Manual admin flip or next-day daily catches the rare change.
- **No launcher rewires.** Existing launchers write `Unconditional` on donor-recurring — that's still correct at insert time (no GDDs, no release date). Surface 2 recomputes after the launcher-created GDDs land (they insert same transaction as the GC in Guided Gift Entry; the GDD trigger fires after them).

## Precedent risks

- `[[gdd-parent-polymorphic]]` — GDD.ParentRecordId is polymorphic (Campaign / GC / Opp). Filter with `BEGINS(TEXT($Record.ParentRecordId), "6gc")` in the GDD flow entry criteria to skip Campaign/Opp GDDs.
- `[[flow-recordbeforedelete-filterformula-silent-skip]]` — no non-trivial filterFormula on GDD BeforeDelete; do the parent-type check with a Decision element inside the flow, not on `<start>`.
- `[[flow-in-operator-gotcha]]` — restriction-type match uses OR chain of `EqualTo`, not `In` with comma-separated stringValue.
- Idempotency — subflow reads current FulfillmentType and skips DML if unchanged, to avoid recursive re-triggering when Surface 2 fires after subflow writes GC.

## Deploy sequence

1. Subflow `FQS_Recalculate_GC_FulfillmentType` — no dependencies.
2. Surface 2 (`FQS_GC_Fulfillment_On_Change`) — depends on subflow.
3. Surface 3 (`FQS_GC_Fulfillment_From_GDD`) — depends on subflow.
4. Surface 4 (`FQS_GC_Fulfillment_From_GDD_Delete`) — depends on subflow.

## UAT

After all five deploy:
1. **Insert path** — create a GC with a purpose-restricted GDD via Guided Gift Entry Pledge leaf; expected: FulfillmentType flips to Conditional after commit fires.
2. **Release-date-only path** — new GC with `FQS_Restriction_Release_Date__c = TODAY+30`, no restricted GDDs; expected: Conditional.
3. **Release-date flip** — edit release date to `TODAY-1`; expected: Unconditional on next save.
4. **Add GDD** — start with Unconditional GC (Earned Revenue GDD), add a Permanent-restriction GDD; expected: Conditional after GDD insert.
5. **Remove GDD** — Conditional GC with only one restricted GDD; delete that GDD; expected: Unconditional on next save.
6. **Clear release date** — Conditional GC whose only restriction is `FQS_Restriction_Release_Date__c`; blank the date; expected: Unconditional on next save.
