# FQS Launcher — Pledge with First Payment Plan

**Status:** Planned. Not built.
**Owner:** Justin (solo).
**Origin:** Erin feedback 2026-07-30, item 1: *"Sometimes a pledge will be entered in with the first payment. We can support that but it requires us to update the category and follow-up question slightly."*
**Related:** [[fqs-launcher-copy-audit]], [[fqs-designations-plan]], [[fqs-designation-hierarchy-plan]], [[fqs-fulfillment-type-automation-plan]], [[fundfirst-custom-schedule-shape]].

---

## Problem statement

Today the launcher's two "future commitment" leaves — Single Payment Pledge / Grant and Scheduled Pledge / Grant — only create a `GiftCommitment` (and for Scheduled, a `GiftCommitmentSchedule` + Expected GTs). No first-payment `GiftTransaction` is stamped. The user has to follow up separately (via the Pledge Payment leaf on the same or another day) to record the first payment.

Real-world scenario: donor drops off a check with a signed pledge card — money in hand AND future commitment on paper, in one interaction. Currently the user must run the launcher twice: once as a Simple Payment Pledge to create the GC, once as a Pledge Payment to record the cash.

**The Recurring leaf already handles this pattern** — `Decide_Recurring_First_Payment_Or_Success` (line 4655) branches after the schedule activates: if `pkLeafMonetary = Recurring`, run `Assign_Recurring_First_Payment_Defaults` → `Create_Recurring_First_Payment_GT` → shared match chain. Otherwise skip to Screen_Success. Our new Pledge-with-first-payment path can reuse this same branching pattern, keyed on a new user opt-in prompt.

---

## Core design

### New user prompt

Add a Yes/No radio on `Screen_Pledge_Details` and `Screen_Scheduled_Details`:

**Field name:** `pkPledgeIncludesFirstPayment` (Simple) / `pkScheduledIncludesFirstPayment` (Scheduled)
**Label:** "Is the donor making the first payment now?"
**Help:** "Yes if the donor is handing you a check (or the money already cleared) along with signing the pledge. We'll record the pledge and a paid Gift Transaction for the first payment. No if the pledge stands alone and the first payment is expected later."
**Default:** No
**Required:** Yes

### Visibility / dependent fields

If Yes → surface a follow-up sub-panel on the same screen (visibility-gated) collecting:

- `numFirstPaymentAmount` (Currency, required) — how much of the pledge is the first payment (defaults to the pledge total for Simple; defaults to the per-installment amount for Scheduled Regular; free-form for Scheduled Custom).
- `dtFirstPaymentDate` (Date, required, default TODAY) — when the money changed hands.
- `dtFirstPaymentProcessedDate` (Date, optional, default TODAY) — for FQS_Processed_Date__c parity with the main Gift Details screen.
- `pkFirstPaymentMethod` (String, required, default Check) — reuses `Choice_Payment_*` records.

### Downstream wiring

After GC (and for Scheduled, GCS + Expected GT fanout) is created, gate on the new opt-in:

```
Decide_Pledge_First_Payment_Or_Success
  rule: pkPledgeIncludesFirstPayment=Yes OR pkScheduledIncludesFirstPayment=Yes
    -> Assign_Pledge_First_Payment_Defaults
    -> Create_Pledge_First_Payment_GT
    -> Decide_Insert_Employer_GT_Insert (existing shared match chain)
  default -> Screen_Success (unchanged terminal)
```

**Where to inject this decision.** The Recurring first-payment decision (`Decide_Recurring_First_Payment_Or_Success` line 4655) currently fires only when `pkLeafMonetary = Recurring`, and its default connector goes to `Decide_Needs_Commitment_SoftCredit` (GDSC opt-in gate, which itself terminates at Screen_Success). To add Pledge-first-payment, either:

- **(A) Extend the existing decision** to add a second rule for `pkPledgeIncludesFirstPayment=Yes OR pkScheduledIncludesFirstPayment=Yes`, routing to a new `Assign_Pledge_First_Payment_Defaults`. This keeps one gate; downstream branches per rule.
- **(B) Add a new decision** downstream of Decide_Recurring_First_Payment_Or_Success's default (before Decide_Needs_Commitment_SoftCredit). Cleaner separation; slightly more nodes.

**Recommendation: (A)** — the two features are exactly parallel (both post a first payment against a just-created commitment via a shared match chain), so they belong in the same gate for cognitive load.

### First-payment GT field mapping

Mirror `Assign_Recurring_First_Payment_Defaults` (line 2010) with these adjustments:

| Field | Simple | Scheduled | Notes |
|---|---|---|---|
| `DonorId` | `recordId` | `recordId` | Person or Org Account being launched from |
| `GiftCommitmentId` | `rsv_GiftCommitment.Id` | `rsv_GiftCommitment.Id` | GC just created |
| `OriginalAmount` | `numFirstPaymentAmount` | `numFirstPaymentAmount` | user-entered |
| `Status` | `Paid` | `Paid` | retroactive-entry convention |
| `TransactionDate` | `dtFirstPaymentDate` | `dtFirstPaymentDate` | user-entered |
| `TransactionDueDate` | `dtFirstPaymentDate` | `dtFirstPaymentDate` | mirror for FQS |
| `FQS_Processed_Date__c` | `dtFirstPaymentProcessedDate` | `dtFirstPaymentProcessedDate` | user-entered |
| `PaymentMethod` | `pkFirstPaymentMethod` | `pkFirstPaymentMethod` | user-entered |
| `GiftType` | `Individual` if IsPersonAccount, else `Organizational` | same | mirror existing pattern |
| `FQS_Gift_Transaction_Category__c` | `Pledge Payment` | `Pledge Payment` | first payment IS a pledge payment against the commitment |
| `TaxReceiptStatus` | `Send` | `Send` | default for received-money paths |
| `FQS_Matched__c` | `false` | `false` | match still opt-in via existing chain |

### Scheduled Custom edge case

Scheduled Custom Schedule (per-row date + amount): the first-payment amount must equal the first Custom installment row's amount, and dtFirstPaymentDate can arbitrarily differ from the first row's date (donor paid early / late / on-time).

**Decision needed:** does the first-payment GT create in addition to the first Custom Expected GT, or does it replace the first Expected GT? Both answers exist in real-world usage:

- **Replace** (recommendation): if the user opts into first-payment, the first Custom installment row is dropped from the col_CustomGTs collection before insert, so the Custom fanout produces N-1 Expected GTs; the launcher creates 1 Paid GT (this feature) to fill the slot. Reason: doubles avoided.
- **Add** (alternative): the Paid GT is a bonus record; the first Custom row still gets an Expected GT. User would see 2 GTs for the first installment date — awkward but symmetric with Recurring (where the platform fanout creates an Expected GT for TransactionDay of month 1 AND we insert a separate Paid GT for the same date).

Recurring's existing behavior IS Add — the platform-fanned Expected GT lives alongside the first-payment Paid GT. So parity with Recurring says **Add**. But Recurring's schedule is OpenEnded and the platform can only fan out a bounded window; on Scheduled FixedLength Custom, all N Expected GTs get inserted at once and doubling shows up immediately.

**Punting for detailed answer** — this needs a call from Justin.

### Scheduled Regular edge case

Scheduled Regular (same amount every period, N payments): first payment amount defaults to `numScheduledTotal / numScheduledPaymentCount`. Same replace-vs-add question. Recommendation: mirror Recurring's Add semantics for symmetry.

### Existing pkCommitmentSubcategory

Erin: *"...it requires us to update the category and follow-up question slightly."* The `pkCommitmentSubcategory` on Screen_Pledge_Details (Pledged Gift vs Grant Payout) doesn't need to change — the pledge is still a Pledged Gift or Grant Payout regardless of whether a first payment accompanies it. What Erin likely means: the follow-up question (the Yes/No prompt we're adding here) is the "slight" schema change. No other subcategory tweaks needed.

**Confirming assumption:** Erin was NOT asking us to add a "Combined pledge + first payment" as a THIRD subcategory option — just to acknowledge the possibility via the follow-up. Green-light before code.

---

## Terminal chain re-entry

Once `Create_Pledge_First_Payment_GT` lands, the flow re-enters the same shared chain that Recurring first-payment already uses:

```
Create_Pledge_First_Payment_GT
  -> Decide_Insert_Employer_GT_Insert (match?)
    Yes -> employer GT chain -> ACR + soft credits -> Decide_Create_InKind_SelfCredit
    No  -> Decide_Create_InKind_SelfCredit (skipped: not In-Kind)
  -> Decide_Create_SoftCredit (per-GT GSC opt-in)
  -> Decide_Fanout_GDSC_To_GSC (Item C fanout guard)
  -> Screen_Success
```

All of this reuses existing nodes. Only new nodes are the Assign_Pledge_First_Payment_Defaults + Create_Pledge_First_Payment_GT (mirroring the Recurring twins).

---

## Impact on FulfillmentType automation

Once [[fqs-fulfillment-type-automation-plan]] lands, this feature's Paid first-payment GT does NOT affect `GC.FulfillmentType` — the field is derived only from GDDs on the GC, not from child GTs. So no coupling.

---

## Screen preview / success text

Update `formulaSuccessSummary` (line 5432) to add first-payment context on the Simple/Scheduled branches. Something like:
"Recorded a $500 Single Payment Pledge/Grant. First payment of $500 received on Jul 30, 2026."

Or a separate DisplayText line on Screen_Success guarded on `pkPledgeIncludesFirstPayment=Yes OR pkScheduledIncludesFirstPayment=Yes`. Recommendation: separate DisplayText — easier to visibility-gate than to CASE-nest into an already-long formula.

---

## Test plan

1. **Simple Pledge, No first payment** → GC only, no GT. Same as today.
2. **Simple Pledge, Yes first payment, cash** → GC + 1 Paid GT (Category = Pledge Payment, matches numFirstPaymentAmount).
3. **Simple Pledge, Yes first payment + match** → GC + donor GT (Paid) + employer GT (Pending or Paid per pkMatchReceived).
4. **Scheduled Regular, Yes first payment, 4 installments** → GC + GCS + 4 Expected GTs + 1 Paid first-payment GT (5 total GTs; parity with Recurring semantics).
5. **Scheduled Custom, Yes first payment, 3 rows** → GC + GCS + 3 Expected GTs + 1 Paid first-payment GT (4 total). (Or 3 total if we go with Replace semantics.)
6. **Simple Pledge, Yes first payment, restricted designation** → GC.FulfillmentType lands (via automation) as Conditional; first-payment GT gets a GTD mirroring the GC's GDD.
7. **Simple Pledge, Yes first payment, GDSC opt-in** → GC.GDDs + GDD → GSC fanout on the first-payment GT via Item C (should Just Work since the GT is created before Decide_Fanout_GDSC_To_GSC).

---

## Open questions

1. **Add vs Replace semantics on Scheduled** — needs Justin's call. Recommendation: Add (mirror Recurring).
2. **Match-received prompt on the new path** — `pkMatchReceived` (new, this session) is scoped to the shared match-employer chain; will it be visible + wired correctly if the user opts into first-payment on the Simple/Scheduled leaf? Verifying trace before code lands.
3. **First-payment amount validation** — should we cap `numFirstPaymentAmount` at `numPledgeAmount` (Simple) / `numScheduledTotal` (Scheduled)? Or allow overpayment? Recommendation: no cap for v1 — let the user enter whatever; a real-world edge case is donor pays more than the pledge amount at inception, and blocking it forces a support ticket.
4. **Custom Repeater interaction** — Scheduled Custom uses a Repeater for the per-row inputs. Adding a first-payment sub-panel BELOW the Repeater is layout-wise fine, but the visibility-gated show/hide on a Repeater screen needs testing. Likely fine per [[flow-screen-authoring-gotchas]] but call it out.

---

## Rollout

1. **Confirm answers to open questions** (above) with Justin.
2. **Build the choices + screen fields + assignments + decision extension** in one commit.
3. **Deploy + test** the 7 scenarios above.
4. **Update [[fqs-release-readiness.md]]** — new §Gate row: "Pledge-with-first-payment feature UAT green" required for release.
5. **Update admin README** — new post-install note that Simple/Scheduled leaves now support optional first-payment.

---

## Non-goals

- **Retroactive backfill** — existing GCs without first-payment GTs stay as-is. The feature is opt-in on the launcher and only affects new commitments.
- **Multi-payment at inception** — the launcher records ONE first payment. If the donor hands you 2 checks up front, run the launcher twice or use Pledge Payment leaf for the second.
- **Editing an existing pledge to add a first payment retroactively** — out of scope; use Pledge Payment leaf.
