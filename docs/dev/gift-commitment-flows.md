# FQS Gift Commitment Flows — Admin Guide

## Overview

The FQS Gift Commitment surface consists of one hand-authored router flow (**FQS Manage Gift Commitment Actions**) that presents a state-aware set of cards on the Gift Commitment record page, and then hands off to Fundraising Cloud's packaged managed subflows (namespace `frops_flow`). This document captures how the router works, what state each card is offered in, and the platform quirks discovered while wiring the two managed subflows that take an `action` input variable.

## The router flow

**Flow:** `FQS_Manage_Gift_Commitment_Actions` (Screen Flow, launched from a Gift Commitment quick action)

**Path:** `Get_GC` → `Get_Live_Create_Schedules` → `Get_Active_Pause` → `Decision_State` → one of six state-scoped screens → `Assign_SelectedAction_*` → `Decision_Action` → correct subflow → `Process`

Each state routes to its own screen with a hand-authored `<choices>` block, so the card list is defined inline in the flow XML — no Custom Metadata indirection.

### State detection

The flow computes a single string context code via formula `frmContext`. Evaluation order is load-bearing — earlier branches short-circuit.

| Priority | Condition | Context code |
|---|---|---|
| 1 | `GC.Status = Closed` | `CLOSED` |
| 2 | Live `PauseTransactions` GCS on this commitment **OR** `GC.Status = Paused` | `RECURRING_PAUSED` |
| 3 | `GC.CurrentGiftCmtScheduleId` blank **AND** no live `CreateTransactions` GCS | `NO_SCHEDULE_YET` |
| 4 | No live `CreateTransactions` GCS (but `CurrentGiftCmtScheduleId` is populated) | `ONE_TIME_OR_SETTLED` |
| 5 | `FQS_Gift_Commitment_Category__c = Recurring Gift` | `RECURRING_ACTIVE` |
| 6 | (default — Pledged Gift or Grant Payout with a live schedule) | `OPEN_INSTALLMENT_PLEDGE` |

**Pause detection.** `Get_Active_Pause` queries for a sibling `GiftCommitmentSchedule` where `Type = PauseTransactions` and `(EndDate = null OR EndDate >= today)`. This matches indefinite pauses (the common case) and bounded pauses whose window still covers today. It deliberately ignores future-scheduled pauses; admins rarely produce that shape.

The formula checks both `GC.Status = Paused` and the sibling row because different Fund Cloud versions differ on whether the managed Pause subflow flips `GC.Status` — keeping both signals is defensively correct.

**Live-schedule detection.** `Get_Live_Create_Schedules` queries for a sibling `GiftCommitmentSchedule` where `Type = CreateTransactions`, `StartDate <= today`, and `(EndDate = null OR EndDate >= today)`. Presence-only (`getFirstRecordOnly=true`). The formula only reads `.Id`, so no field-hasn't-been-set error can fire.

This second query is what distinguishes `RECURRING_ACTIVE` / `OPEN_INSTALLMENT_PLEDGE` (live row present) from `ONE_TIME_OR_SETTLED` (a schedule reference exists but its window has passed — single-installment gifts, fully-paid pledges) from `NO_SCHEDULE_YET` (no reference AND no live row — freshly-created commitment, or custom-shape pledge with only Expected `GiftTransaction` rows).

### Card × state matrix

| Card | Subflow (frops_flow) | `action` input | States shown in |
|---|---|---|---|
| Create or update schedule | `ManageGiftCmtSchedule` | — | `NO_SCHEDULE_YET` |
| Pause schedule | `PauseResumeSchedule` | `Pause` | `RECURRING_ACTIVE` |
| Resume schedule | `PauseResumeSchedule` | `Resume` | `RECURRING_PAUSED` |
| Upgrade or downgrade amount | `UpdateRecurringSchedule` | `UpgradeDowngrade` | `RECURRING_ACTIVE`, `RECURRING_PAUSED`, `OPEN_INSTALLMENT_PLEDGE` |
| Update payment method | `UpdateRecurringSchedule` | `UpdatePaymentMethod` | `RECURRING_ACTIVE`, `RECURRING_PAUSED`, `OPEN_INSTALLMENT_PLEDGE` |
| Update dates | `UpdateRecurringSchedule` | `UpdateDates` | `RECURRING_ACTIVE`, `RECURRING_PAUSED`, `OPEN_INSTALLMENT_PLEDGE` |
| Manage designations | `ManageGiftDesignations` | — | all states except `CLOSED` |
| Close commitment | `CloseGiftCommitment` | — | all states except `CLOSED` |

`CLOSED` commitments land on `Screen_Closed` and no cards are offered.

**Semantic notes on the state matrix:**
- `OPEN_INSTALLMENT_PLEDGE` intentionally omits Pause/Resume — a fixed-length pledge on a ladder has no drumbeat to interrupt. If a use case for pausing a pledge emerges, both cards can be added to `Screen_Choose_Open_Installment_Pledge` — the managed subflow accepts either shape.
- `ONE_TIME_OR_SETTLED` and `NO_SCHEDULE_YET` both offer only Manage Designations + Close (plus Create Schedule for `NO_SCHEDULE_YET`) — none of the schedule-mutation cards operate meaningfully on a commitment with no live schedule row.

### Open item — `NO_SCHEDULE_YET` is currently a mixed bucket

Two structurally-different shapes route to `NO_SCHEDULE_YET` today:

1. **Fresh commitment with no schedule and no GTs** — the intended target of this state. "Create or update schedule" is the correct action.
2. **Custom-installment pledge** — a `GC` with N hand-rolled Expected `GiftTransaction` rows and no `GCS` (FundFirst rejects `TransactionPeriod=Custom` at row insert, so this is the only viable shape). "Create or update schedule" on this shape would generate a duplicating GCS on top of the existing GTs.

Deferred until the "custom pledges should always carry a GCS" design lands (owner: wizard C.2 + seed generator). Once custom pledges carry a schedule, these records naturally migrate out of `NO_SCHEDULE_YET` and the ambiguity dissolves. Tracked in `.planning/fqs-release-readiness.md` Phase 1 findings, 2026-07-24.

---

## What each managed subflow actually does to the data

### Pause (`frops_flow__PauseResumeSchedule`, `action=Pause`)

Given a monthly-recurring commitment with **one** existing `CreateTransactions` GCS running open-ended:

1. The **existing** `CreateTransactions` GCS is modified — its `EndDate` is set to just before the pause window opens.
2. A **new** `PauseTransactions` GCS is inserted spanning the pause window (`StartDate` → `EndDate`).
3. A **new** `CreateTransactions` GCS is inserted running from just after the pause window ends, open-ended.

So a schedule that had one row before Pause has three rows after: original (bounded) + pause window + resume tail.

`GC.Status` behavior after Pause **varies by Fund Cloud version.** Testing on the current FundFirst build shows Pause flipping `GC.Status` to `Paused`; earlier tests on the same code path (John Williams FQS #7, older Fund Cloud version) left `Status = Active`. The router flow keeps both detection paths — sibling PauseTransactions row **and** `GC.Status = Paused` — so it detects a pause regardless of which behavior the org exhibits.

`GC.CurrentGiftCmtScheduleId` continues pointing at the **original** bounded `CreateTransactions` row — not at the pause row and not at the resume-tail row. `GC.NextTransactionDate` advances to the first date after the pause window ends.

### Resume (`frops_flow__PauseResumeSchedule`, `action=Resume`)

Ends the pause window early by **truncating** the pause row and **inserting** a bridging `CreateTransactions` row. It does not modify or delete the original resume-tail row.

Given the three rows in the diagram above (Original bounded + Pause + Resume tail), running Resume with a new resume date of today+X produces:

1. The original bounded `CreateTransactions` row is untouched (still ends where Pause put it).
2. The `PauseTransactions` row's `EndDate` is **truncated** to just before the requested resume date.
3. A **new** bridging `CreateTransactions` row is inserted covering the gap from the requested resume date to just before the resume-tail row's original start.
4. The resume-tail `CreateTransactions` row is untouched.

So a schedule that had 3 rows after Pause has **4 rows** after Resume. Every Pause/Resume cycle grows the row count.

`GC.CurrentGiftCmtScheduleId` continues pointing at the original bounded row until the pause window actually elapses. `GC.NextTransactionDate` recomputes from the new resume date.

**Real-world sequence observed on John Williams FQS #7** ($45 Monthly, original schedule 2024-04-23 open-ended, `CurrentGiftCmtScheduleId` = the original):

| Step | Row 1 (original) | Row 2 (pause) | Row 3 (resume tail) | Row 4 (bridge) |
|---|---|---|---|---|
| Before | 2024-04-23 → null | — | — | — |
| After Pause (window 7/31–9/25) | 2024-04-23 → 2026-07-30 | Pause 2026-07-31 → 2026-09-25 | Create 2026-09-26 → null | — |
| After Resume (new date 8/14) | 2024-04-23 → 2026-07-30 | Pause 2026-07-31 → **2026-08-13** | Create 2026-09-26 → null | **Create 2026-08-14 → 2026-09-25** |

`NextTransactionDate` moved from `2026-10-23` (after Pause) to `2026-08-23` (after Resume) — the first monthly tx date after the new resume date.

### Upgrade / Downgrade, Update Payment Method, Update Dates (`frops_flow__UpdateRecurringSchedule`)

Same subflow, three distinct entry points selected by the `action` input.

**Update Dates** (verified 2026-07-24 on Marcus Allen FQS #6): modifies the selected `CreateTransactions` GCS in place — sets `StartDate` and/or `EndDate` to the values entered on the datatable screen. No successor row inserted for a same-schedule date change.

**Upgrade / Downgrade** and **Update Payment Method** follow the same in-place update pattern for straightforward edits, though a successor-row shape is expected when the change type demands it. Expect the count of GCS rows on the commitment to grow with each material change — audit trail is the whole schedule history, not just the current row.

### Manage Designations (`frops_flow__ManageGiftDesignations`)

Adjusts split-fund allocations on the commitment. Does not touch the schedule shape.

**Prerequisite:** the org must have exactly one `GiftDesignation` with `IsDefault = true`. Otherwise the trailing `frops_flow__ProcessGiftCommitment` step (which runs after Manage Designations on every router path) aborts with:

> The org wide default designation is not yet configured or is inactive.

The FQS foundation seed guarantees this by flagging `FQS-GD-GENERAL-OPERATING` as `IsDefault = true` after the GD upsert. Teardown clears the flag before deactivating GDs, so a teardown → foundation cycle needs the foundation step to fire in order to restore the flag. See memory files [[fqs-orgwide-default-designation]] and [[fqs-teardown-gd-default]].

### Close (`frops_flow__CloseGiftCommitment`)

**Documented behavior:** sets `GC.Status = Closed`.

**Observed behavior 2026-07-24** on Marcus Allen FQS #6: the managed Close action ran without error, cancelled the pending `GiftTransaction` (new GT row inserted with `Status = Canceled`), but `GC.Status` remained `Active`. Behavior is inside the managed subflow — the router flow's contribution ended when Close was invoked. If Close is not flipping `GC.Status` reliably, that's a Fund Cloud managed-package issue to escalate; the router's routing is correct.

---

## Platform quirks and gotchas

These are the ones already burned into memory files under `.claude/projects/…/memory/`. Cross-referenced here so admins working on this flow surface see them in one place.

### GCS custom External Ids must be non-unique

The managed schedule-cloning flows insert successor GCS rows via `sObject.clone()`, which copies every custom field value from the source — including any field marked `unique=true`. The insert then fails with `duplicate value found: <FieldName> duplicates value on record with id: <sourceGcsId>`.

**Rule:** on `GiftCommitmentSchedule`, keep custom External Id fields as `unique=false`. Rely on the seed's naming convention (`FQS-GCS-<RUN_STAMP>-<globalIdx>-<kind>`) to guarantee non-collision. When flipping `unique=true` → `unique=false` on a Text field, also remove `<caseSensitive>true</caseSensitive>` — the platform emits `CaseSensitive can only be set for fields with unique also set` otherwise.

See memory: [[gcs-external-id-nonunique]].

### `GC.CurrentGiftCmtScheduleId` during a pause is stale-but-stable

While a pause is in effect (and even after Resume has inserted its bridging row, until the pause window actually elapses and the next transaction fires), `GC.CurrentGiftCmtScheduleId` continues pointing at the **original `CreateTransactions` row that was current when Pause fired** — even though that row's `EndDate` is now in the past.

The platform does **not** advance `CurrentGiftCmtScheduleId` to:
- the `PauseTransactions` row during the pause window,
- the bridging `CreateTransactions` row inserted by Resume,
- or the resume-tail `CreateTransactions` row waiting after the pause,

until the pause window elapses and the next scheduled transaction actually fires.

**Consequence for consumers:** never treat the record `GC.CurrentGiftCmtScheduleId` points at as authoritative for "what's the commitment doing right now." Its `EndDate` may be years in the past. If you need "the currently effective schedule row," query GCS directly by GC ID + `StartDate <= TODAY AND (EndDate is null OR EndDate >= TODAY)`. The router flow does exactly this via `Get_Live_Create_Schedules` and `Get_Active_Pause`.

### `GC.CurrentGiftCmtScheduleId` populates on activation, not insert

The platform batches an activation job that stamps `GC.CurrentGiftCmtScheduleId` when a schedule's `StartDate` is on or before today. If the seed inserts a schedule with a future start, that field stays null until the batch runs. Don't back-fill it from Flow; it hides the "not yet active" state.

The FQS seed generator explicitly back-fills this field on every seeded GC where the schedule's StartDate has already passed, so the router flow classifies seeded records correctly on first launch.

See memory: [[gc-current-schedule-activation]].

### `GCS.ScheduleType` does not exist in FundFirst

Despite what some Fund Cloud plan docs suggest, `GiftCommitmentSchedule.ScheduleType` is not a field on FundFirst. Recurrence rides on `TransactionPeriod` + `TransactionInterval` + `StartDate` / `EndDate` + `Type`. `GC.ScheduleType` (on the parent, not the schedule) is a platform-managed back-fill.

See memory: [[fundfirst-gcs-no-scheduletype]].

### Custom-period schedules can't be a single row

Attempting to insert one `GCS` with `TransactionPeriod = Custom` rejects: *"only a recurring gift commitment schedule."* A "Custom" pledge is modeled as a `GC` plus N `Expected` `GiftTransaction` rows — no schedule row at all. The router flow treats these commitments as `NO_SCHEDULE_YET`; see the open-item note above.

See memory: [[fundfirst-custom-schedule-shape]].

### Org-wide default `GiftDesignation` is required

The managed `frops_flow__ProcessGiftCommitment` step (which runs after every action the router dispatches to, except CLOSED's dead-end screen) requires exactly one `GiftDesignation` with `IsDefault = true`. Missing → the whole transaction rolls back with *"The org wide default designation is not yet configured or is inactive."* The FQS foundation seed flags `FQS-GD-GENERAL-OPERATING` as default.

See memory: [[fqs-orgwide-default-designation]].

---

## Testing checklist

Fastest coverage matrix from a seeded FQS org:

| State | Recipe | Cards expected |
|---|---|---|
| `NO_SCHEDULE_YET` | Any Active GC with `CurrentGiftCmtScheduleId = null` and no live CreateTransactions GCS (Brightpath grant / pledge from the medium seed both qualify) | Create Schedule · Manage Designations · Close (3) |
| `RECURRING_ACTIVE` | Any seeded Recurring Gift with a live monthly schedule (Marcus Allen FQS #6, Amy Hill FQS #1, most of the seed) | Pause · Upgrade/Downgrade · Update Payment · Update Dates · Manage Designations · Close (6) |
| `OPEN_INSTALLMENT_PLEDGE` | Any seeded Pledged Gift or Grant Payout with a live yearly schedule (James Wang FQS #2, Sofia Garcia FQS #12) | Upgrade/Downgrade · Update Payment · Update Dates · Manage Designations · Close (5) |
| `RECURRING_PAUSED` | Run the router's Pause card on a `RECURRING_ACTIVE` commitment, then re-open | Resume · Upgrade/Downgrade · Update Payment · Update Dates · Manage Designations · Close (6) |
| `ONE_TIME_OR_SETTLED` | Any GC whose only `CreateTransactions` GCS has EndDate before today. Not naturally in the current seed; can be produced by running Update Dates on a monthly recurring and setting EndDate = today | Manage Designations · Close (2) |
| `CLOSED` | Run the router's Close card, or set `Status = Closed` directly | Dead-end "Commitment is closed" screen — no picker |

For each real card, click Next and confirm the correct managed subflow's first screen title matches what you'd expect (Pause vs Resume, Upgrade/Downgrade vs Update Dates vs Update Payment).

---

## When to add a new action

1. Add a new `<choices>` block near the top of the flow XML with a unique `name`, the display text as `<choiceText>`, `<dataType>String</dataType>`, and an UPPER_SNAKE_CASE token as the `<value><stringValue>`.
2. Add a `<choiceReferences>` line to each `Screen_Choose_*` element the new card should appear on.
3. Add a matching `<rules>` block to `Decision_Action`, comparing `SelectedAction` `EqualTo` the new token, connected to a new `<subflows>` element.
4. Add the `<subflows>` element invoking the target managed flow with the required inputs; connect its output to `Process`.
5. Deploy.

Adding a card to a state is a one-line `<choiceReferences>` edit on that state's screen. Adding a card to multiple states is one line per state. Removing a card from a state is the reverse. No metadata deploy needed; the flow XML is the source of truth for the card × state matrix.

---

## Known limitations / TODO

- Radios instead of cards on state-scoped screens. Migrating to `flowruntime:visualPicker` requires a Flow Builder round-trip (the visualPicker `ComponentChoice` shape can't be hand-authored — same class of source-authoring limitation as `flowruntime:datatable`). Not currently scheduled.
- `NO_SCHEDULE_YET` mixed-bucket gap (see open item above) — deferred until custom-installment pledges carry a `GiftCommitmentSchedule` row.
- `Close` action's flip of `GC.Status = Closed` was inconsistent in 2026-07-24 testing (GT was correctly canceled but `Status` remained `Active`). Managed-package behavior, escalate to Fund Cloud if reproducible.
