# FQS Gift Commitment Router Flow — Refactor Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target flow:** `force-app/main/default/flows/FQS_Manage_Gift_Commitment_Actions.flow-meta.xml`
**Target org:** `FundFirst`

---

## Motivation

The router flow shipped 2026-07-24 works end-to-end for all 8 action paths against a live Active GC. Testing surfaced two design gaps and one over-engineering signal that this refactor addresses together:

### Gap 1 — "Recurring vs Custom" detection is a field-value heuristic that misses one-time gifts

Today's state formula distinguishes states by `GCS.TransactionPeriod = 'Custom'` vs. anything else. In FundFirst this is doubly wrong:

- **`CUSTOM_PLEDGE` is dead code.** FundFirst rejects `insert GCS(TransactionPeriod='Custom')` at the row level (`"only a recurring gift commitment schedule"` — see memory `fundfirst-custom-schedule-shape`). Custom pledges land as `GC + N Expected GT` rows with **no GCS row**, so they detect as `NO_SCHEDULE`, never as `CUSTOM_PLEDGE`.
- **One-time gifts detect as `RECURRING_ACTIVE`.** A $75K one-time grant is seeded as `RecurrenceType=FixedLength` + a single Yearly GCS. The router sees a schedule with `TransactionPeriod != 'Custom'` and offers Pause / Upgrade-Downgrade / Update Payment / Update Dates — actions that are nonsensical for a paid, done gift. Same for single-installment pledges.

### Gap 2 — `CurrentGiftCmtScheduleId` presence and live-schedule presence are conflated

`CurrentGiftCmtScheduleId` can point at a stale row (e.g., after Pause, per memory `gc-current-schedule-activation`). "Does a live active schedule row exist right now?" is a different question than "Does the lookup resolve?" Both matter to the state matrix and today's flow only checks the first.

### Signal 3 — CMDT `FQS_GC_Action__mdt` is over-engineered

The 8 CMDT records + dynamic choice set filter buys three real behaviors: Pause ↔ Resume swap, hide detail-edits on schedule-less states, dead-end CLOSED. All three can be expressed with `<decisions>` in the flow itself. In a solo-maintained project like FQS, CMDT indirection costs more legibility than it saves in editability.

---

## User-confirmed design decisions

1. **New state matrix keys off `FQS_Gift_Commitment_Category__c`** (semantic bucket already set by the seed) and **live-schedule existence** (a fresh SOQL query), not `GCS.TransactionPeriod`.
2. **One-time gifts and fully-paid pledges get their own state** (`ONE_TIME_OR_SETTLED`) with only two safe cards: Manage Designations + Close.
3. **Drop the CMDT.** Move card lists into per-state hand-authored Screen elements with static `<choices>` blocks.
4. **CMDT delete is a separate step** after the flow refactor is validated in the org. Flow-level refactor deploys first, non-destructive; CMDT + custom metadata records get destructive-changes deploy once we're confident.
5. **Keep the two independent pause-detection branches** (live PauseTransactions GCS OR `Status = Paused`) — memory `gc-current-schedule-activation` documents that different Fund Cloud versions behave differently on which one flips.

---

## New state matrix

| State | Trigger (evaluated top-down) | Cards offered |
|---|---|---|
| `CLOSED` | `GC.Status = 'Closed'` | (none — dead-end screen) |
| `RECURRING_PAUSED` | live `PauseTransactions` GCS row exists **OR** `GC.Status = 'Paused'` | Resume, Upgrade/Downgrade, Update Payment, Update Dates, Manage Designations, Close |
| `NO_SCHEDULE_YET` | no live `CreateTransactions` GCS row **AND** `GC.CurrentGiftCmtScheduleId` is blank | Create Schedule, Manage Designations, Close |
| `RECURRING_ACTIVE` | live `CreateTransactions` GCS row exists **AND** `FQS_Gift_Commitment_Category__c = 'Recurring Gift'` | Pause, Upgrade/Downgrade, Update Payment, Update Dates, Manage Designations, Close |
| `OPEN_INSTALLMENT_PLEDGE` | live `CreateTransactions` GCS row exists **AND** `FQS_Gift_Commitment_Category__c ∈ {'Pledged Gift', 'Grant Payout'}` | Upgrade/Downgrade, Update Payment, Update Dates, Manage Designations, Close |
| `ONE_TIME_OR_SETTLED` | `GC.CurrentGiftCmtScheduleId` resolves **AND** no live `CreateTransactions` GCS (all EndDates in past, or single-installment already past) | Manage Designations, Close |

### Why "live create schedule" is a separate query

Today's `Get_Current_Schedule` follows `CurrentGiftCmtScheduleId`. That row may have an `EndDate` in the past (managed Pause truncates it; single-installment schedules end after their one due date). A populated `CurrentGiftCmtScheduleId` does NOT mean "there is a live schedule right now."

The new signal is:

```
Get_Live_Create_Schedules:
  GiftCommitmentId = {!recordId}
  Type = 'CreateTransactions'
  EndDate = null OR EndDate >= TODAY
  StartDate <= TODAY  ← ensures we don't count future-scheduled rows as "live now"
```

If this returns rows, the commitment has an actively-firing or ready-to-fire schedule. If it returns zero rows AND the `CurrentGiftCmtScheduleId` lookup resolved, the commitment is `ONE_TIME_OR_SETTLED`.

---

## Structural changes to the flow

### Additions

- **New Get_Records: `Get_Live_Create_Schedules`** as described above.
- **New field on existing `Get_GC`:** add `FQS_Gift_Commitment_Category__c` to the stored field list.
- **New per-state Screen elements** (one radio field each, static `<choices>`):
  - `Screen_Choose_Recurring_Active` — 6 choices
  - `Screen_Choose_Recurring_Paused` — 6 choices
  - `Screen_Choose_No_Schedule` — 3 choices
  - `Screen_Choose_Open_Installment_Pledge` — 5 choices
  - `Screen_Choose_One_Time_Or_Settled` — 2 choices
  - `Screen_Closed` — existing, unchanged
- **Reshaped `Decision_State`** — 6 outcomes routing to the 6 screens above, based on the new `frmContext` formula.

### Removals

- Delete formula `dcsGCActions` (dynamic choice set on `FQS_GC_Action__mdt`)
- Delete single-screen `Screen_Choose_Action`
- (Later step) Delete `force-app/main/default/objects/FQS_GC_Action__mdt/` and all `customMetadata/FQS_GC_Action.*.md-meta.xml` files

### Unchanged

- All 8 `<subflows>` invocation nodes (Pause, Resume, UpgradeDowngrade, UpdatePaymentMethod, UpdateDates, ManageDesignations, CloseGiftCommitment, ManageGiftCmtSchedule)
- The trailing `Process` subflow (`frops_flow__ProcessGiftCommitment`)
- `Decision_Action` — still 8 outcomes on `ChooseAction` string values, unchanged
- `Get_Active_Pause` — keep the OR(EndDate is null, EndDate >= today) filter
- `Get_Current_Schedule` — still useful as a truth check that `CurrentGiftCmtScheduleId` resolves

---

## Formula rewrite

`frmContext` becomes:

```
IF(ISPICKVAL({!Get_GC.Status}, "Closed"),
   "CLOSED",
IF(OR(NOT(ISBLANK({!Get_Active_Pause.Id})), ISPICKVAL({!Get_GC.Status}, "Paused")),
   "RECURRING_PAUSED",
IF(AND(ISBLANK({!Get_GC.CurrentGiftCmtScheduleId}), ISBLANK({!Get_Live_Create_Schedules.Id})),
   "NO_SCHEDULE_YET",
IF(ISBLANK({!Get_Live_Create_Schedules.Id}),
   "ONE_TIME_OR_SETTLED",
IF(TEXT({!Get_GC.FQS_Gift_Commitment_Category__c}) = "Recurring Gift",
   "RECURRING_ACTIVE",
   "OPEN_INSTALLMENT_PLEDGE")))))
```

Load-bearing order:
1. Closed short-circuits before anything else.
2. Paused (via either signal) short-circuits before schedule-shape checks so a paused recurring stays labeled paused.
3. `NO_SCHEDULE_YET` requires BOTH signals absent (`CurrentGiftCmtScheduleId` blank AND no live create row). Belt-and-suspenders because a stale lookup pointing at a deleted or expired schedule would otherwise fool us.
4. `ONE_TIME_OR_SETTLED` is the mirror image: `CurrentGiftCmtScheduleId` is populated (line 3 didn't fire) but no live create row. This is the new state that catches single-installment gifts.
5. Category disambiguates `RECURRING_ACTIVE` vs `OPEN_INSTALLMENT_PLEDGE`.

---

## Test plan

Fresh medium seed provides coverage for every branch:

| State | Fastest recipe | Sample record from current seed |
|---|---|---|
| `CLOSED` | Run Close card on any GC, refresh; router should route to dead-end | (Amy Hill after tonight's Close test) |
| `RECURRING_PAUSED` | Run Pause card on an Active recurring GC, refresh | Fresh Active recurring — run Pause then re-launch |
| `NO_SCHEDULE_YET` | Any Custom-shape pledge (GC + Expected GTs, no GCS). Seed does not produce this today, but any Active GC with `CurrentGiftCmtScheduleId = null` also hits this branch. | 2 GCs in current seed have null CurrentGiftCmtScheduleId (future-start schedules) |
| `RECURRING_ACTIVE` | Any active recurring monthly | e.g., a $240 Monthly seed row |
| `OPEN_INSTALLMENT_PLEDGE` | Multi-year pledged or multi-year grant with unpaid installments remaining | 7 pledged Active GCs seeded |
| `ONE_TIME_OR_SETTLED` | Grant-onetime seed (single Yearly GCS, EndDate ~60d after Start, now past) OR any GC whose only Create schedule has past EndDate | 1 grant-onetime GC — likely past its EndDate; verify |

For each state, click Next through the first card offered, confirm the correct managed subflow fires, and confirm no state gets Pause offered to a one-time gift or Resume offered to a non-paused gift.

---

## Deploy sequence

1. **Retrieve current flow** to ensure clean base
2. **Deploy refactored flow** as new version, activate — non-destructive
3. **Test all 6 states** against representative records
4. **Destructive-changes deploy** to remove:
   - `CustomObject: FQS_GC_Action__mdt`
   - 8 × `CustomMetadata: FQS_GC_Action.<Name>`
   - Also cleans up permission-set references if any (verify)
5. **Local file cleanup** — delete the object dir + custom-metadata files after destructive deploy confirms
6. **Update `docs/gift-commitment-flows.md`** with the new state matrix, card × state table, and delete the "CMDT-driven action library" section
7. **Update `.planning/fqs-release-readiness.md`** with the new shipped rows

---

## Related memory + docs

- `fundfirst-custom-schedule-shape` — why `TransactionPeriod=Custom` never appears in FundFirst
- `gc-current-schedule-activation` — why `CurrentGiftCmtScheduleId` can be stale
- `fqs-orgwide-default-designation` — Manage Designations rollback (already fixed, unrelated to this refactor)
- `docs/gift-commitment-flows.md` — admin guide; will be updated after refactor lands
