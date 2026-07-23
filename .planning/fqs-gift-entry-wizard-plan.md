# FQS Gift Entry Single Launcher — Category-Wizard Redesign

**Status:** Plan, awaiting implementation
**Created:** 2026-07-19
**Supersedes (for entry-point structure):** the four flat paths at the top of [FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml) and Section R1 of [fqs-account-launcher-flow-parity-plan.md](./fqs-account-launcher-flow-parity-plan.md)
**Does not supersede:** the field-parity contract, per-type default rules, soft-credit subflow, and datatable pickers in [fqs-account-launcher-flow-parity-plan.md](./fqs-account-launcher-flow-parity-plan.md) — those carry over unchanged and are the source of truth for downstream screens.
**Related:** [fqs-corporate-match-plan.md](./fqs-corporate-match-plan.md) owns the match algorithm; this plan only describes the inline "was this matched?" branch inside the wizard.
**Reference:** [docs/npc-automation-notes.md](../docs/npc-automation-notes.md) — every platform contract cited below is documented there.

---

## Motivation

The current launcher offers four flat paths (Outright / Pledge / Recurring / Grant). In review, several of the paths are edge cases the org must support, not user-facing choices. Grouping by user intent restructures the entry into two lightweight questions that read like an interview, not a schema picker.

Additional gap: matching-gift status is not captured today, and the pledge-payment path does not distinguish between recording a new payment vs. posting an already-scheduled Expected transaction.

---

## Screen 1 — Broad Category

**Question:** "What are you recording today?"

- [ ] **A Monetary Payment** — money is changing hands right now
- [ ] **A Future Commitment** — a formal promise of future funding; no money today
- [ ] **A Special / Non-Cash Transaction** — In-Kind or Fee for Service

Stored in `var_Category` (Text).

## Screen 2 — Specific Action

Choice list rendered conditionally based on `var_Category`. Stored in `var_Leaf`.

**If Monetary Payment:**
- [ ] **Outright Gift** — one-time donation, no preceding pledge
- [ ] **Pledge Payment** — payment toward an existing active pledge
- [ ] **Recurring Gift** — open-ended, ongoing schedule

**If Future Commitment:**
- [ ] **Simple Pledge / Grant** — full amount, single future date
- [ ] **Scheduled Pledge / Grant** — multiple installments

**If Special / Non-Cash:**
- [ ] **In-Kind Gift** — non-cash goods/services, not resold for cash
- [ ] **Fee for Service** — 100% non-deductible payment for direct material benefit

---

## Leaf-to-record mapping

| Leaf | Records created | `GC.FQS_Gift_Commitment_Category__c` | GCS? | Notes |
|---|---|---|---|---|
| Outright Gift | GT only | — | No | No parent commitment |
| Pledge Payment | GT insert **or** GT update (see §Pledge Payment logic) | — | No | Reuses parent GC |
| Recurring Gift | GC + first GT | `Recurring Gift` | Yes (1 row, `Recurring` / `OpenEnded`) | First GT posted; engine stamps future ones |
| Simple Pledge/Grant | GC only | `Pledged Gift` or `Grant Payout` (user choice) | **No** | Set `ExpectedTotalCmtAmount`, `NextTransactionDate`, `NextTransactionAmount` directly on GC |
| Scheduled Pledge/Grant — regular | GC + 1 GCS | `Pledged Gift` or `Grant Payout` | Yes (1 row, `Recurring` / `FixedLength`) | Engine expands into N Expected GTs |
| Scheduled Pledge/Grant — custom | GC + N GCS | `Pledged Gift` or `Grant Payout` | Yes (N rows, `Custom`) | Inline data-table for date/amount rows |
| In-Kind Gift | GT only | — | No | `PaymentMethod = 'In-Kind'`, `FQS_InKind_Fair_Market_Value__c` prompted |
| Fee for Service | GT only | — | No | `NonTaxDeductibleAmount = OriginalAmount` (`TaxDeductionAmount` derives to 0) |

Pledge/Grant choice inside Screen 2 → `FQS_Gift_Commitment_Category__c`:
- Pledged Gift and Grant Payout both flow through Simple/Scheduled leaves; the user picks the sub-category on the details screen (`var_CommitmentSubcategory`).

---

## Platform contracts baked into the wiring

All cited from [docs/npc-automation-notes.md](../docs/npc-automation-notes.md).

1. **`GiftCommitment.ScheduleType` — never set on insert.** Insert GC with no `ScheduleType`; insert GCS child(ren); platform back-fills. Setting on GC silently overrides to `Recurring` and later Custom GCS insert fails with a misleading error.
2. **`GiftTransaction.CurrentAmount` — not writable.** Set `OriginalAmount` on insert; system derives `CurrentAmount = OriginalAmount − refunds/adjustments`.
3. **`GiftTransaction.TransactionDueDate` — required on every insert.**
   - Outright, In-Kind, Fee for Service, Pledge Payment (fresh insert branch), Recurring first payment: `TransactionDueDate = TransactionDate`.
   - Pledge Payment (update-existing-Expected branch): do not touch; already stamped by GCS.
4. **`GiftTransaction.TaxDeductionAmount` — calculated in FundFirst.** Cannot be set directly. Drive via `NonTaxDeductibleAmount`. Fee for Service sets `NonTaxDeductibleAmount = OriginalAmount`. Event-benefit reductions set `NonTaxDeductibleAmount = <benefit fair market value>`.
5. **`GiftCommitment` computed rollups** (`CurrentCommitmentAmount`, `OutstandingCommitmentAmount`, `TotalPaidTransactionAmount`, `TotCommitmentScheduleAmt`) — silently ignored on write. Never set from the flow.
6. **`GiftCommitmentSchedule.Type = 'CreateTransactions'`** — every GCS row this launcher inserts uses `CreateTransactions`. `PauseTransactions` is only relevant when a donor pauses an existing schedule (not this launcher's job) — with one exception preserved from the parity plan: [scenario 3 in the parity plan appendix](./fqs-account-launcher-flow-parity-plan.md) records a pledge together with the first payment and uses `PauseTransactions` to prevent duplicate engine-generated GTs. Verify this scenario still applies under the new wizard structure before implementation.
7. **`Account` — Person Account record type requires profile access.** Fault path routes to the single error screen (already handled in current launcher).
8. **`GiftDesignation` deletion** — irrelevant for the launcher (never deletes); noted for seed teardown context only.
9. **`OutreachSourceCode` / `Campaign` coupling** — **deferred**, per Justin's 2026-07-19 note. No OSC picker in the launcher for now.
10. **`GiftTransaction.Status = 'Paid'`** — launcher writes `Paid` for all monetary-payment leaves (Outright / Pledge Payment / Recurring first payment / In-Kind / Fee for Service). The user is asserting "money in hand," which is the correct end state for manual entry. The doc's warning about bypassing payment reconciliation applies to integration ingest, not manual launcher entry.

---

## Matching-gift branch (payments only)

**Scope:** Shown on Monetary Payment leaves (Outright, Pledge Payment, Recurring first payment, In-Kind, Fee for Service). Also shown on commitment leaves so the commitment record carries an indication of match-eligibility forward — see below.

### Decision matrix

| Leaf | Show match question? | If yes → | Both GTs' `GiftCommitmentId` |
|---|---|---|---|
| Outright Gift | Yes | Prompt for employer Account; insert second GT paired via `MatchingEmployerTransactionId` | Both null (no wrapping GC) |
| Pledge Payment | Yes | Same as Outright; **both GTs get `GiftCommitmentId = <picked GC>`** so rollups reflect the match | Both = picked GC |
| Recurring Gift | Yes | Employer GT paired to donor's first GT via `MatchingEmployerTransactionId`; **both GTs get `GiftCommitmentId = <new GC>`**; recurring-match commitment prompt suppressed (handled by Find Match action if needed) | Both = new GC |
| Simple/Scheduled Pledge/Grant | Yes | Sets flag on donor GC only (see below); no employer records inserted at commitment time | — |
| In-Kind | No | (In-Kind gifts don't have a monetary match) | — |
| Fee for Service | No | (100% non-deductible; not match-eligible) | — |

### Rule (Justin, 2026-07-19)

- **Employer GT is never wrapped in its own GC.** Pairing to the donor GT is via native `GiftTransaction.MatchingEmployerTransactionId`.
- **When the donor GT is on a commitment, the employer GT parents to the same commitment.** This lets `TotalPaidTransactionAmount` / `CurrentCommitmentAmount` reflect the full match; `DonorId` (hard credit) and `GiftSoftCredit` rows manage account-level attribution correctly. Applies to Pledge Payment and Recurring Gift leaves. Outright Gift + match leaves both GTs orphan.
- **No new field on GC to track "employer will match."** For commitment leaves, the match-eligibility indication rides on the donor's GC via `FQS_Match_Eligible__c` (see below) — no employer record inserted at commitment time. When the payment against the commitment arrives, the launcher's Pledge Payment leaf sees the flag and defaults the match question to Yes.
- **Match may push paid amount past the pledge total.** Warn but do not auto-update `ExpectedTotalCmtAmount`; user handles the upgrade decision on the GC record.

### Small metadata add

Add `FQS_Match_Eligible__c` (Checkbox, default `false`) on `GiftCommitment`. Populated by the wizard on the four commitment leaves. Read by the Pledge Payment leaf to default the match question. Not rolled up anywhere.

### Employer picker

- Lookup source: `AccountContactRelation` where `ContactId = <donor Contact>` **and** `Account.RecordType.DeveloperName = 'Organization'`.
- Presentation: datatable of matching ACRs; user selects one.
- Escape hatch: "Employer not listed" checkbox → surfaces an Account lookup filtered to `RecordType.DeveloperName = 'Organization'` and non-household (verified via `Account.PartyRelationshipGroup` if a PRG lookup is exposed; parity with corporate-match-plan §5).
- If Employer chosen and no ACR exists yet → insert an ACR inline (parity with corporate-match-plan §5) so future gifts see the relationship.

### Amount

Match amount = user-entered (default: same as donor amount). Employer GT fields:
- `OriginalAmount = <matched amount>`
- `DonorId = <employer Account Id>`
- `MatchingEmployerTransactionId = <donor GT Id>` (set after donor GT insert returns the Id)
- `GiftCommitmentId = <donor GT's GiftCommitmentId>` (only if donor GT is on a commitment — Pledge Payment or Recurring Gift leaf; otherwise leave null)
- `Status = 'Paid'`
- `TransactionDate = <donor GT TransactionDate>`
- `TransactionDueDate = <donor GT TransactionDate>`

### Soft credits (inline, per 2026-07-19 decision)

Two `GiftSoftCredit` rows inserted alongside the employer GT:
- On donor GT — `Amount = <matched amount>`, `Role = 'Matched Donor'`, party = corporate Account.
- On employer GT — `Amount = <matched amount>`, `Role = 'Matched Donor'`, party = donor Person Account.

Legal donor (the `DonorId` on each GT) is never soft-credited to its own transaction — parity with [corporate-match-plan §Core rules](./fqs-corporate-match-plan.md).

---

## Pledge Payment logic (Monetary Payment → Pledge Payment)

**Difference from the current launcher:** a pledge payment may be an *update* on an existing scheduled/Expected GT, not always a fresh insert.

### Flow

1. User picks parent `GiftCommitment` (lookup, filtered to active commitments for this donor).
2. Query on entry: `SELECT Id, TransactionDate, TransactionDueDate, OriginalAmount, Status FROM GiftTransaction WHERE GiftCommitmentId = :gc AND Status IN ('Unpaid', 'Pending', 'Failed') ORDER BY TransactionDueDate ASC`.
3. **If ≥1 row returned** (scheduled or recurring commitment; NPC engine stamped Expected GTs):
   - Present the rows in a datatable.
   - Default-select the earliest.
   - Show two toggles:
     - "Post this existing scheduled payment" (default; updates the selected row)
     - "Record a new one-off payment" (inserts fresh, existing rows untouched)
4. **If 0 rows returned** (Simple Pledge/Grant, or fully-posted schedule):
   - Skip the datatable; go directly to fresh-insert path.

### Update-existing path

- Update selected GT: `Status = 'Paid'`, `TransactionDate = <today>`, `PaymentMethod = <entered>`, fee fields (`GatewayTransactionFee`, `ProcessorTransactionFee`, `DonorCoverAmount`), `NonTaxDeductibleAmount` if applicable.
- **Do not touch `OriginalAmount`.** If `<entered amount>` ≠ `OriginalAmount`, show a warning screen:
  > "Amount entered (`$<entered>`) differs from the scheduled amount (`$<original>`). This payment will post as-entered without changing the schedule. If this reflects a permanent change to the commitment, manage it on the Gift Commitment record."
  Continue button proceeds; no `OriginalAmount` write.
- **Do not touch `CurrentAmount`** — not writable; system rollup handles it.

### Fresh-insert path

- Insert new GT under `GiftCommitmentId = <gc>`, `Status = 'Paid'`, `OriginalAmount = <entered>`, `TransactionDate = <today>`, `TransactionDueDate = <today>`, `PaymentMethod`, fee fields.

---

## Simple Pledge/Grant leaf — GC only, no GCS

Set on GC directly (no schedule engine stamping):
- `ExpectedTotalCmtAmount = <entered pledged amount>`
- `NextTransactionDate = <entered fulfillment date>`
- `NextTransactionAmount = <entered pledged amount>`
- `RecurrenceType = 'FixedLength'`
- `FormalCommitmentType = <entered>` (Verbal / Written)
- `FulfillmentType = <entered>` (Unconditional / Conditional)
- `FQS_Gift_Commitment_Category__c = 'Pledged Gift'` or `'Grant Payout'` (from `var_CommitmentSubcategory`)
- `IsAssetTransferExpected` (required — inferred from Category or explicit prompt)
- `DonorId`, `Name` (formula default), `OwnerId`
- `FQS_Match_Eligible__c` (from match question above)

`GC.ScheduleType` stays null. Pipeline reports that need "expected future income" should filter on `NextTransactionDate != null` or `ExpectedTotalCmtAmount > 0`, **not** on `ScheduleType`. Add this note to the Simple leaf's Success screen and to the seed generator's docstring.

When the payment arrives, Pledge Payment leaf's "0 rows returned" branch handles it.

---

## Scheduled Pledge/Grant — Regular

GC insert (no `ScheduleType`) — same fields as Simple except `NextTransactionDate` / `NextTransactionAmount` are optional (engine will populate).

Then one GCS row:
- `GiftCommitmentId = <parent Id>`
- `TransactionPeriod` — from user (Monthly / Quarterly / Weekly / Yearly)
- `TransactionInterval` — from user (default 1)
- `TransactionAmount` — from user
- `StartDate` — from user
- `EndDate` — from user (required for FixedLength; blank for OpenEnded recurring, but Recurring Gift leaf handles that)
- `TransactionDay` — from user or inferred from StartDate (optional)
- `Type = 'CreateTransactions'`

**Verified 2026-07-19 via describe:** FundFirst's GiftCommitmentSchedule does NOT expose a `ScheduleType` field despite the platform-contract doc. Recurrence semantics ride entirely on `TransactionPeriod` + `TransactionInterval` + start/end + `Type`. Parent `GC.ScheduleType` back-fills from the child GCS shape (still platform-managed; never set explicitly). See [[fundfirst-gcs-no-scheduletype]].

Set `GC.RecurrenceType = 'FixedLength'` on the parent.

---

## Scheduled Pledge/Grant — Custom

GC insert as above.

Then inline data-table screen: user enters N rows of `Date | Amount | (optional) PaymentMethod`. Each row → one GCS with:
- `TransactionPeriod = 'Custom'`
- `StartDate = <row date>`
- `TransactionAmount = <row amount>`
- `Type = 'CreateTransactions'`
- `PaymentMethod` if entered

**No `ScheduleType` on GCS in FundFirst** — the Custom-ness of the schedule lives in `TransactionPeriod = 'Custom'`, not in a separate ScheduleType field. See [[fundfirst-gcs-no-scheduletype]].

Set `GC.RecurrenceType = 'FixedLength'`.

Validation: sum of `TransactionAmount` should equal (or reconcile with) `GC.ExpectedTotalCmtAmount`. If mismatch, warn: *"Sum of scheduled amounts (`$X`) does not match total pledge (`$Y`). Continue anyway?"*

---

## Recurring Gift — GC + first GT + 1 GCS

GC:
- `RecurrenceType = 'OpenEnded'`
- `FormalCommitmentType`, `FulfillmentType`, `DonorId`, `Name`, `IsAssetTransferExpected`
- `FQS_Gift_Commitment_Category__c = 'Recurring Gift'`
- `FQS_Match_Eligible__c` (from match question)
- `NextTransactionDate` / `NextTransactionAmount` optional — engine handles

GCS:
- `TransactionPeriod`, `TransactionInterval`, `TransactionAmount`, `StartDate`
- **No `EndDate`** (open-ended)
- `Type = 'CreateTransactions'`

**No `ScheduleType` on GCS in FundFirst** — see [[fundfirst-gcs-no-scheduletype]]. Open-endedness rides on `GC.RecurrenceType = 'OpenEnded'` + a blank `EndDate` on GCS.

First GT (posted for today):
- `GiftCommitmentId = <parent>`, `Status = 'Paid'`, `OriginalAmount`, `TransactionDate = today`, `TransactionDueDate = today`, `PaymentMethod`, fees, `NonTaxDeductibleAmount` if event benefit.

Match branch (if Yes) fires on the first GT the way Outright would.

---

## In-Kind Gift — GT only

- `PaymentMethod = 'In-Kind'` (native picklist value on GT — verified via describe)
- `FQS_InKind_Fair_Market_Value__c` — prompted
- `OriginalAmount = <FMV entered>`
- `NonTaxDeductibleAmount` — prompted (many in-kind gifts have a benefit component; leave blank for full deduction)
- `Status = 'Paid'`, `TransactionDate = today`, `TransactionDueDate = today`

No match question.

---

## Fee for Service — GT only

- `PaymentMethod` — from user (Check / Credit Card / etc.)
- `OriginalAmount = <entered>`
- `NonTaxDeductibleAmount = OriginalAmount` (100% non-deductible → derived `TaxDeductionAmount = 0`)
- `Status = 'Paid'`, `TransactionDate = today`, `TransactionDueDate = today`

No match question.

---

## Screen ordering (proposed)

1. **Screen_Category** — Monetary / Future / Special
2. **Screen_Leaf** — the 8 leaves, filtered by Screen_Category
3. **Screen_Donor** — donor lookup (Person Account default; Organization allowed for grant leaves)
4. **Screen_Commitment_Picker** — Pledge Payment leaf only; lookup filtered to active GCs for donor
5. **Screen_Existing_GTs** — Pledge Payment leaf only, if ≥1 open GT; datatable of scheduled/Expected GTs
6. **Screen_Details** — amounts, dates, fees, payment method, campaign, designation. Contents branch on leaf.
7. **Screen_Schedule_Regular** — Scheduled Pledge/Grant (regular) + Recurring: period/interval/amount/start/end
8. **Screen_Schedule_Custom** — Scheduled Pledge/Grant (custom): inline datatable of rows
9. **Screen_Match** — Monetary leaves + Commitment leaves: "Was this matched?" → employer picker
10. **Screen_Soft_Credit** — routing question (parity plan R2)
11. **Screen_Warning_Amount_Mismatch** — Pledge Payment update branch, if entered ≠ scheduled
12. **Screen_Success** — with links to created records and any warnings (no default designation, `ScheduleType` null on Simple, etc.)
13. **Err_Create** — single error screen for all fault paths (parity plan 5.6)

---

## Files to touch

- [force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml) — main rewrite
- [force-app/main/default/objects/GiftCommitment/fields/](../force-app/main/default/objects/GiftCommitment/fields/) — add `FQS_Match_Eligible__c.field-meta.xml`
- [force-app/main/default/permissionsets/FQS_Custom_Fields.permissionset-meta.xml](../force-app/main/default/permissionsets/FQS_Custom_Fields.permissionset-meta.xml) — grant edit on `FQS_Match_Eligible__c`
- [force-app/main/default/objects/GiftCommitment/fields/FQS_Match_Eligible__c.field-meta.xml](../force-app/main/default/objects/GiftCommitment/fields/FQS_Match_Eligible__c.field-meta.xml) — new
- [force-app/main/default/flexipages/FQS_GiftCommitment_Record_Page.flexipage-meta.xml](../force-app/main/default/flexipages/FQS_GiftCommitment_Record_Page.flexipage-meta.xml) — surface `FQS_Match_Eligible__c` on record page (optional; nice-to-have for admins)
- [force-app/main/default/classes/FQSSeedGenerator.cls](../force-app/main/default/classes/FQSSeedGenerator.cls) — populate `FQS_Match_Eligible__c` on some seeded commitments so the wizard's Pledge Payment default has real data to demo against

---

## Execution steps

1. **Metadata prep**
   - Add `FQS_Match_Eligible__c` field + permission set entry.
   - Deploy; verify field is queryable and creatable.
   - Update seed generator to populate the flag on ~20% of commitments (parity with existing `FQS_Matched__c` distribution on transactions).
2. **Screen 1 + 2 flow scaffold**
   - Insert Screen_Category + Screen_Leaf at the top of the flow.
   - Set `var_Category` and `var_Leaf`.
   - Route to existing branches to prove the wizard doesn't break current paths. Test each of the 4 existing leaves is still reachable.
3. **Restructure branches under the leaves**
   - Rename current Outright / Pledge / Recurring / Grant branches to match the 8-leaf model.
   - Split Grant leaf between Simple and Scheduled Pledge/Grant using the sub-category picker.
   - Move Simple Pledge to a GC-only path (no GCS insert).
4. **Add In-Kind and Fee for Service leaves**
   - Both are GT-only with tuned defaults; simplest branches.
5. **Pledge Payment update-vs-insert logic**
   - Add Screen_Existing_GTs + query.
   - Add update path with amount-mismatch warning.
6. **Matching-gift branch**
   - Add Screen_Match on Monetary + Commitment leaves.
   - Wire employer picker (ACR datatable + Account fallback lookup).
   - Post-donor-GT-insert: insert employer GT with `MatchingEmployerTransactionId`.
   - Cross-reference corporate-match-plan for soft-credit decision.
7. **Success screen updates**
   - Emit warnings for: no default designation, `ScheduleType` null on Simple, amount mismatch on Pledge Payment update.
   - Link to created records (donor GT, employer GT, GC, GCS).
8. **Regression check**
   - Every path in [fqs-account-launcher-flow-parity-plan.md](./fqs-account-launcher-flow-parity-plan.md) §Redesigned pledge structure branch must still be reachable through the new wizard.
   - Every field-parity contract from that plan's Tier 0/1 findings must still hold.
9. **Manual QA matrix**
   - Row per leaf × (match=Y/N) × (has designation default / no default) × (donor is Person Account / Organization for grant leaves).
   - Verify records created match the mapping table above.
10. **Commit** — Justin gates.

---

## Decisions locked (2026-07-19)

1. **Soft credits — inserted inline in launcher.** The pair is already in the flow's context and adding two inserts is cheap. Two `GiftSoftCredit` rows per matched pair:
   - Donor GT ← corporate Account, `Role = 'Matched Donor'`
   - Employer GT ← donor Person Account, `Role = 'Matched Donor'`
2. **Employer picker fallback — inline ACR create.** If the donor's employer isn't in their `AccountContactRelation` list, the launcher shows an Account lookup (filtered to `RecordType.DeveloperName = 'Organization'` and non-household) and inserts an `AccountContactRelation` inline when the user picks one. Parity with corporate-match-plan §5.
3. **Scenario 3 (pledge + payment same-run with `Type = PauseTransactions`) — dropped.** The two-step workflow (create commitment → relaunch → Pledge Payment leaf handles the 0-existing-GTs case) is acceptable. Removes a special GCS-insert path from the wizard.
4. **Corporate match on a pledge — both GTs parent to the same GC.** This is a departure from strict orphan-and-pair.
   - **Outright Gift + match:** both GTs orphan (donor GT has no `GiftCommitmentId`, employer GT has no `GiftCommitmentId`, `MatchingEmployerTransactionId` links them).
   - **Pledge Payment + match:** donor GT and employer GT both get `GiftCommitmentId = <picked GC>`. Both roll up to the same commitment so `TotalPaidTransactionAmount` / `CurrentCommitmentAmount` reflect the match; hard credit (`DonorId`) and soft credits handle account-level attribution.
   - **Recurring Gift + match:** donor GT and employer GT both get `GiftCommitmentId = <new GC>`. First payment is matched; the "recurring match commitment?" prompt from corporate-match-plan §7 is **suppressed** on this leaf (donor has a `GiftCommitmentId` now). Find Match action handles recurring-match escalation post-launch if the corporate wants it.
   - **Upgrade / satisfy semantics.** When the match payment plus prior paid transactions exceeds `ExpectedTotalCmtAmount`, warn on the Success screen: *"This match brings paid amount to `$X`, exceeding the commitment total of `$Y`. Manage the commitment on the Gift Commitment record if this is an upgrade."* Do not auto-update `ExpectedTotalCmtAmount` — the user manages that decision on the record.

---

## State at handoff (2026-07-19)

The launcher flow has ongoing work-in-progress that predates the wizard rewrite. The implementation agent must preserve it, not clobber it.

- **Preserve:** `Transform_Campaign_Ids_Into_Text_Strings` element's `<elementReference>` must resolve to `Get_CampaignMembers[$EachItem].CampaignId` (fixed 2026-07-19, deploy `0AfWB00000DTY0P0AX`). Previously it was self-referential (`Get_Member_Campaigns[$EachItem].Id`) and silently returned an empty text collection — no error, downstream Campaign picker returned 0 rows. See [[flow-transform-self-reference-gotcha]].
- **Finish, don't rebuild:** partial schedule-prefill scaffolding exists — `Get_Commitment_Schedule`, `Decide_Prefill_From_Schedule`, `Assign_Prefill_From_Schedule`. Today it only prefills `var_GiftAmount`; the follow-on `Assign_Gift_Details_Defaults` unconditionally stomps `TransactionDate` and `PaymentMethod`. To finish (inside Phase E's update-existing-GT branch): (1) extend `Assign_Prefill_From_Schedule` to prefill `var_PaymentMethod` from the schedule row, (2) gate `Assign_Gift_Details_Defaults` on `IsNull(var_TransactionDate)` and `IsNull(var_PaymentMethod)` so the prefill isn't stomped.
- **Untested legacy paths — skip pre-rewrite testing:** two paths (Pledge new-commitment, Soft-credit Yes) were left untested on the current flat structure. The wizard rewrite reshapes both — Pledge new-commitment becomes Simple/Scheduled Pledge/Grant leaves; Soft-credit Yes routes through the redesigned R2 question + new match branch. Do not spend cycles testing the pre-rewrite versions. They are exercised in Phase G's regression matrix.
- **Fee-designation plan coordination:** [fqs-fee-designation-plan.md](./fqs-fee-designation-plan.md) will add a fifth `FQS_Restriction_Type__c` picklist value `Earned Revenue` and wire the launcher's Fee for Service branch to auto-filter designation picker on it. Ship order is not determined. The wizard's Fee for Service leaf must conditionally add the filter only if the picklist value exists in the org — check via `sf sobject describe` at implementation time. Absent value → no filter, safe no-op.
- **Record-naming coordination:** [fqs-record-naming-flows-plan.md](./fqs-record-naming-flows-plan.md) will overwrite Names via `RecordAfterSave` flows once shipped. After that plan lands and is verified on runtime records, strip the launcher's four `rsv_*.Name = formula*` assignments and three name formula elements as a separate commit (not in scope for this wizard rewrite).
- **Prefill IsNull gate policy:** apply the same `IsNull()`-gate pattern anywhere a downstream assignment could stomp a prefill. Do not route around defaults by duplicating branches.

## Notes for future sessions

- Field descriptions on `GiftCommitment.ScheduleType`, `GiftTransaction.CurrentAmount`, and `GiftTransaction.TaxDeductionAmount` already carry "do not set on insert" / "calculated" language — don't duplicate that guidance in this launcher's inline help; link to the record's field help instead.
- The wizard's Screen 1 category labels and Step 2 leaf labels are user-facing marketing text — expect churn in wording during UAT. The XML `<label>` and `<choiceText>` are the touchpoints; leave the underlying variable names (`var_Category`, `var_Leaf`) stable across label edits.
- If the parity plan and this plan disagree, this plan wins on **entry-point structure and match wiring only**. The parity plan wins on everything else (field-parity contract, per-type defaults, soft-credit routing UX, datatable pickers).
- **IsBlank on picklist fields:** Flow formulas cannot call `ISNULL()` or `ISBLANK()` on a picklist field directly (`field integrity exception: The formula expression is invalid: Field <x> is a picklist field. Picklist fields are only supported in certain functions.`). Wrap with `TEXT()` first — `ISBLANK(TEXT({!rsv_GiftTransaction.PaymentMethod}))`. Encountered while implementing the Phase E IsNull-gate on `formulaDefault_PaymentMethod`.
- **Assign_Gift_Details_Defaults now runs formulas, not literals.** After Phase E's IsNull-gate, `Assign_Gift_Details_Defaults` writes `formulaDefault_TransactionDate` (returns TransactionDate if non-null else TODAY) and `formulaDefault_PaymentMethod` (returns PaymentMethod if non-blank else 'Cash') to `rsv_GiftTransaction`. If a future phase needs to add a third default (e.g., prefilled `NonTaxDeductibleAmount` from schedule), add a matching `formulaDefault_<field>` element and follow the same pattern — do NOT bypass it by writing a literal directly, or you re-introduce the stomp bug on the update-existing-GT path.
- **Seed generator salt tracking (Phase H).** `FQSSeedGenerator` picks new PRNG salts by convention: each commitment build (recurring / pledged / grant) has a cluster (20s / 30s / 40s). Match-eligible added at salts 27 / 37 / 47 (next unused past each cluster). If Phase F needs additional per-commitment randomization (e.g., corp-match probability variance), continue the pattern (28 / 38 / 48). Do not reuse salts across independent decisions — reused salts correlate outputs deterministically, which distorts test coverage.
