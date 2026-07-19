# FQS Gift Entry Single Launcher — Account (Consolidated Plan)

> **2026-07-18 — Consolidation:** This plan absorbed `fqs-gift-entry-account-launcher-plan.md` (the R1–R5 redesign + decisions table + soft-credit subflow spec). Both files described the same flow. The launcher plan is deleted; its content lives in the **Launcher redesign appendix** at the bottom of this file.

## Purpose

The seed generator ([FQSSeedGenerator.cls](../force-app/main/default/classes/FQSSeedGenerator.cls)) is an empirical contract with the platform: wherever it *always* does something, that pattern was almost certainly discovered because omitting it either (a) failed a validation, (b) failed a required-field save, or (c) produced downstream data that was silently wrong.

Comparing the seed to [FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml) reveals several places where the flow diverges from that contract. This plan captures the divergences, ranks them, and proposes fixes.

---

## Reviewer decisions (2026-07-16)

Feedback captured verbatim from reviewer; items are labeled **Confirmed / Redesigned / Deferred / Corrected**. Remaining open questions at end of document.

### Confirmed

- **P.1** — Default `Status` picker to `Pending`. Update the field description/help text to state that direct-writing `Paid` bypasses payment posting and should be avoided for production entry; payment reconciliation is the intended path to `Paid`.
- **1.2** — Add `ExpectedEndDate` as a screen input on the Pledge details screen (option a). Applies to pledge structures that have a defined end.
- **1.3** — Add schedule inputs to the Pledge screen; conditional logic driven by the four pledge structures (see Redesigned P.4 below).
- **1.4** — Hoist the default `GiftDesignation` lookup earlier in the flow so both the Transaction and Pledge branches share one query instead of two.
- **2.2** — When the user does NOT select `Status = Paid`, prompt for `TransactionDueDate` explicitly on the details screen.
- **4.3** — Unconditional means "no restriction — use org default." Flow should NOT create a `GiftDefaultDesignation` on Unconditional pledges (aligns with seed §12.2).
- **V.3** — Surface a warning on the Success screen when no default `GiftDesignation` exists (rather than fail-fast).
- **V.4** — Require Campaign selection on all Campaign pickers (Transaction and Pledge branches).
- **5.5** — Reword `Screen_Success` — remove "return here to record another" claim; describe closing the dialog and relaunching the action.
- **5.6** — Reword `Err_Create` message so it doesn't tell the user to "review and try again" when they cannot go back; describe closing and relaunching.
- **5.10** — Keep friendly language AND include the jargon in parentheses, e.g. *"family, spouse, or business relationships (Account-Contact and Contact-Contact relationships)"*.
- **5.11** — Change `Screen_Pick_Restriction` default off `Purpose`; prefer leaving it undefaulted so the picker forces a conscious choice.
- **P.8** — Person Account save-failure handling: any error on Person Account insert/update routes to an error screen (no special profile-access remediation required in the flow). Add PA-related fault paths to the existing single-error-screen pattern.
- **V.9** — Conditional Pledge Payment lookup escape: validate `Get_Looked_Up_Designation.FQS_Restriction_Type__c == var_RestrictionType` and re-prompt on mismatch (do NOT disable the lookup escape).

### Redesigned — pledge structure branch (P.4 + P.10 + 1.3)

The Fulfillment question stays. After Fulfillment, add a **pledge structure** picker with four options; downstream defaults, screen inputs, and record creates all branch off this pick.

| # | Pledge structure | RecurrenceType | Additional inputs | GiftCommitmentSchedule child(ren) | Also creates GiftTransaction? |
|---|---|---|---|---|---|
| 1 | Monthly or Quarterly, **open-ended** | `OpenEnded` | Period (Monthly/Quarterly), StartDate | 1 row, `Type=CreateTransactions`, no `EndDate` | No |
| 2 | Monthly or Quarterly, **with clear end date** | `FixedLength` | Period, StartDate, `ExpectedEndDate` | 1 row, `Type=CreateTransactions`, `EndDate = ExpectedEndDate` | No |
| 3 | **One-time payment on the pledge** — pledge and payment recorded together (pledge wasn't entered when actually made) | `FixedLength` | StartDate (original pledge date) | 1 row for the full amount, **`Type=PauseTransactions`** | **No** — this is the pledge branch; the payment is recorded separately via the Pledge Payment path against the new commitment |
| 4 | **Specific set of payment dates** | `FixedLength` | (none — user is redirected) | **None created inline.** Launcher directs the user to set up the schedule on the new `GiftCommitment` after save. A future version will drop them into the `Create Gift Commitment Schedule` screen flow. | No |

**Platform rules that apply (P.4 contract):**
- Do NOT set `GiftCommitment.ScheduleType` on insert — insert commitment first, then schedule child(ren); platform back-fills.
- Scenarios 1 and 2: `GiftCommitmentSchedule.Type = CreateTransactions` — NPC auto-generates installment gifts on the schedule cadence; users record payments as they arrive via the launcher's Pledge Payment path.
- Scenario 3: `GiftCommitmentSchedule.Type = PauseTransactions` — prevents NPC from auto-generating a duplicate installment that would conflict with the payment the user records manually against this commitment.
- Scenario 4: no schedule row is inserted by the launcher. `GiftCommitment.ScheduleType` will remain null until the user adds a schedule via the record page (or via the future `Create Gift Commitment Schedule` sub-flow). Success screen must clearly instruct the user to complete this step.

### Deferred

- **P.3 / 2.5** — Outreach Source Code support deferred. Campaign is the priority attribution field.
- **2.4** — Fee decomposition (`GatewayTransactionFee`, `ProcessorTransactionFee`, `DonorCoverAmount`) not modeled by the flow.
- **3.1** — CampaignMember creation handled by a separate flow, not this launcher.
- **3.2** — Org donor Campaign picker UX left as-is for now; may be revisited if Accounts-on-Campaigns is enabled.
- **5.13 (Name defaults)** — Handled by existing formula defaults on the objects:
  - `GiftCommitment.Name` = *Donor + " - " + TransactionAmount + " " + Transaction Period*
  - `GiftTransaction.Name` (recurring) = *Donor + " " + OriginalAmount + " " + TransactionDueDate*
  - `GiftTransaction.Name` (one-time) = *Donor + " " + OriginalAmount + " " + TransactionDate*
  
  Other 5.13 fields resolved via smart defaults, not new screen inputs: `TransactionDate` → default `Today()`; `EffectiveStartDate` → default `Today()`; `PaymentMethod` picker stays as-is.

### Corrected (my prior findings were partly wrong)

- **4.2** — `NonTaxDeductibleAmount` is auto-calculated from `TaxDeductibleAmount` and `CurrentAmount`. **Fix:** remove the `NonTaxDeductibleAmount = 0` assignments from Outright / In-Kind / Pledge Payment blocks; the platform derives it.
- **4.4** — `CurrentAmount` is auto-populated by the platform from `OriginalAmount` on insert (system rollup — see P.5). **Fix:** update `Assign_Fanout_Amount` and `var_GiftAmount` descriptions to state that the flow only sets `OriginalAmount`; the platform derives `CurrentAmount`. No code change; description-only.
- **5.4** — The referenced "New Gift Entry action" does exist elsewhere; it's just not surfaced on this record page. No copy change required.

---

## Findings, ranked by blast radius

### Tier 0 — Platform contracts (from field metadata + `docs/npc-automation-notes.md`)

#### P.0 Lookup-escape fields don't render as record pickers (discovered 2026-07-18)

- **Symptom (Outright test, 2026-07-18):** on `Screen_Pick_Campaign` and `Screen_Pick_Designation`, checking the "None of the below match, let me search" checkbox reveals only the "Search for any Campaign here:" DisplayText — the actual lookup input is invisible. No error, just nothing to type in.
- **Root cause:** the intended lookup field is authored as `<fieldType>ObjectProvided</fieldType>` with `objectFieldReference=rsv_LookupCampaign.Id` (see [Screen_Pick_Campaign lookup field](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2757-L2780)). Screen Flow refuses to render `Id` (a system field) as an editable ObjectProvided input, so the field renders empty.
- **Fix:** switch each lookup-escape field to a native `<fieldType>Lookup</fieldType>` field with an `<objectType>` and an optional `<recordFilter>` (e.g., `IsActive = true`). Applies to all four picker screens: `Screen_Pick_Campaign`, `Screen_Pick_Campaign_Pledge`, `Screen_Pick_Designation`, `Screen_Pick_Commitment`, `Screen_Pick_SoftCredit`. Confirm the exact v66 syntax before landing.
- **Decision 2026-07-18 (P.1):** Default `Status = 'Pending'`, allow user to override on the details screen. Do NOT rely on platform-managed reconciliation (FQS ships no such automation today) — Pending-forever would be worse than the current Paid-hardcode. Override lets the user record known-paid gifts in one screen.
- **Decision 2026-07-18 (V.10):** Fix at flow level (add `IsActive = true` to `Get_Looked_Up_Designation`). Field-level org-wide lookup filters are out of scope for this plan; spin up `fqs-lookup-filters-plan.md` if Justin wants Data Loader / list-view guards too. Field-level MUST include the "IsActive OR Id = current" escape so historical data corrections don't get blocked.
- **Decision 2026-07-18 (1.1–1.4):** Paused. Justin considering pledge-structure design options before implementation.
- **Implementation 2026-07-18 (deploy `0AfWB00000DTXfR0AX`):** P.0 fix landed for all 5 picker screens (`Screen_Pick_Campaign`, `Screen_Pick_Campaign_Pledge`, `Screen_Pick_Commitment`, `Screen_Pick_Designation`, `Screen_Pick_SoftCredit`) — swapped `ObjectProvided`-bound-to-`.Id` for `flowruntime:lookup` component instances (`lkpCampaign`, `lkpCampaignPledge`, `lkpCommitment`, `lkpDesignation`, `lkpSoftCreditAccount`) with `objectApiName`+`fieldApiName` pointing at the real target lookup field (`GiftTransaction.CampaignId`, `GiftCommitment.CampaignId`, `GiftTransaction.GiftCommitmentId`, `GiftTransactionDesignation.GiftDesignationId`, `GiftSoftCredit.RecipientId`). Downstream references switched from `rsv_LookupX.Id` → `<screenFieldName>.recordId` (screen-field name only — NO screen-name prefix; that pattern is invalid, confirmed against SMQS `SearchExistingHouseholds.recordId` at [SMQS_Screen_Manage_Household.flow-meta.xml:2570](../../PSA-Stakeholder-Management-Quick-Start-DEV-1/force-app/main/default/flows/SMQS_Screen_Manage_Household.flow-meta.xml#L2570)). Four orphaned `rsv_LookupX` record variables deleted. **Field-level filter honored:** Justin's field-level lookup filter on `GiftTransactionDesignation.GiftDesignationId` is now picked up automatically because the lookup input is bound to the real lookup field, not to a text-cast Id.
- **Implementation 2026-07-18 (same deploy):** P.1 fix landed — Status default flipped from `'Paid'` → `'Pending'` on all four `Assign_Defaults_*` blocks (Outright, InKind, FeeForService, PledgePayment). Screen still surfaces the Status picker so the user can override to `Paid` when recording a known-paid gift.
- **Bug fix 2026-07-18 (same deploy) — Get_Active_Commitments filter:** the `<operator>In</operator>` filter with a comma-separated `<stringValue>` (SOQL-style) does NOT work in Flow — Flow's `In` expects a text-collection element reference. Empirically confirmed via a failed Sofia Garcia PledgePayment test where her one Active/Pledged Gift commitment did not appear. Fix: rewrote the filter as `1 AND (2 OR 3 OR 4 OR 5) AND (6 OR 7)` with each status/category as its own `EqualTo` clause. **Pattern warning:** grep other flows for `<operator>In</operator>` with a comma-separated `<stringValue>` sibling — every hit is broken the same way.

### Follow-up items surfaced during 2026-07-18 PledgePayment tests (flagged, NOT implemented)

- **Prefill payment method + transaction date from existing schedule.** When the user picks a `GiftCommitment` on the PledgePayment path, an existing `GiftCommitmentSchedule` (or, when NPC auto-generated one, an existing `GiftTransaction` on that commitment) already carries the intended `PaymentMethod` and cadence date. The flow currently defaults `TransactionDate = TODAY()` and `PaymentMethod = Cash` regardless. Better: prefill from `GiftCommitmentSchedule` (or the already-scheduled GT) when the picked commitment has one. Reduces per-payment clicks; matches how these gifts are usually recorded. **Priority:** medium — nothing is broken today, but the flow is more manual than it should be. Add a `Get_Commitment_Schedule` lookup and a `Decide_Prefill_From_Schedule` gate that only pre-seeds if the schedule row exists.
- **GiftTransaction naming is crude compared to seed.** Runtime-created GTs from this flow show a Name that doesn't match the naming convention the seed uses (`GT.Name` from seed = donor + amount + date, in a specific format). This is covered under `fqs-record-naming-flows-plan` — the three record-naming flows will fix it globally. **Priority:** low — cosmetic, addressed by an existing plan. Do not fix inside this launcher; that's what the record-naming flows are for.



Field `<description>`, `<inlineHelpText>`, and the referenced [docs/npc-automation-notes.md](../docs/npc-automation-notes.md) surface **hard platform rules** — behaviors that produce misleading errors or silent data loss when violated. The flow needs to honor these regardless of what the seed does.

#### P.1 `GiftTransaction.Status` — hardcoded `'Paid'` bypasses payment posting

- **Field description:** *"Direct-writing Status = 'Paid' on insert works for seed and test data but bypasses normal payment posting — do not use for production ingest."* ([GT.Status field-meta](../force-app/main/default/objects/GiftTransaction/fields/Status.field-meta.xml))
- **Flow:** all four `Assign_Defaults_*` blocks hardcode `Status = 'Paid'`. This is **exactly the pattern the field docs say not to use for production ingest.** The launcher is a user-facing production entry point, not a seed script.
- **Fix (elevates 2.1 to Tier 0):** the Status picker isn't just a "seed parity" polish — it's a platform-contract violation. User needs to pick `Pending` on newly-recorded gifts and let payment reconciliation move them to `Paid`.

#### P.2 `GiftTransaction.TransactionDueDate` — REQUIRED on insert

- **Field description:** *"Required on insert even for gifts in Paid status."* ([GT.TransactionDueDate field-meta](../force-app/main/default/objects/GiftTransaction/fields/TransactionDueDate.field-meta.xml))
- **Flow:** currently sets it in `Assign_Fanout_Amount`. Good — but if you ever remove that line (or if the fanout is bypassed by a future branch), insert fails with `REQUIRED_FIELD_MISSING`. Worth calling out so nobody deletes it.

#### P.3 `GiftTransaction.OutreachSourceCodeId` must match `CampaignId`

- **Field description (⚠):** *"When populated, the OSC's parent Campaign must equal this transaction's CampaignId — mismatched values fail with 'Select an Outreach Source Code that's part of this Campaign.' Recommended pattern in automation: pick the OSC first, then set CampaignId from OutreachSourceCode.CampaignId."* ([GT.OutreachSourceCodeId](../force-app/main/default/objects/GiftTransaction/fields/OutreachSourceCodeId.field-meta.xml))
- **Flow:** doesn't set OSC at all (item 2.5 above). If we implement 2.5, we **must** derive `CampaignId` from `OutreachSourceCode.CampaignId`, not the other way around — or add a Decision that validates match before insert.

#### P.4 `GiftCommitment.ScheduleType` — auto-managed, must NOT be set on insert

- **Field description (⚠):** *"Auto-managed. Do not set on insert — the system silently overrides to Recurring, producing the misleading error 'You can only create a custom schedule when the commitment schedule type is Custom' when a Custom GiftCommitmentSchedule is then attached. Correct pattern: insert GiftCommitment with no ScheduleType, then insert one or more GiftCommitmentSchedule children."* ([GC.ScheduleType](../force-app/main/default/objects/GiftCommitment/fields/ScheduleType.field-meta.xml))
- **Flow:** doesn't set it. ✓ Good — but this rule is why **items 1.1 and 1.3 have to be paired**. The flow must NOT set `ScheduleType` on `rsv_GiftCommitment`, and MUST create a `GiftCommitmentSchedule` child immediately after `Create_Pledge` so the platform's auto-set fires cleanly. This constrains the fix for 1.3.

#### P.5 `GiftTransaction.CurrentAmount` — not writable

- **Field description:** *"System-managed. Not writable via API or Apex — attempting to set returns INVALID_FIELD_FOR_INSERT_UPDATE."* ([GT.CurrentAmount](../force-app/main/default/objects/GiftTransaction/fields/CurrentAmount.field-meta.xml))
- **Flow:** the stale description on [Assign_Fanout_Amount](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L413-L415) claims we're setting `CurrentAmount`. **Good news:** we're not, because it would fail on save. **The stale comment (item 4.4) is worse than cosmetic — it invites a future maintainer to "fix" the missing assignment and break every insert.** Remove the stale reference urgently.

#### P.6 `GiftDefaultDesignation.FQS_Restriction_Type__c` is a **formula field, read-only**

- **Field description:** *"Formula: mirrors the Restriction Type from the related Gift Designation. Read-only."* ([GDD.FQS_Restriction_Type__c](../force-app/main/default/objects/GiftDefaultDesignation/fields/FQS_Restriction_Type__c.field-meta.xml))
- **Flow:** [Assign_Build_Default_Designation](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L640-L645) writes `rsv_GiftDefaultDesignation.FQS_Restriction_Type__c = var_RestrictionType` — writing to a read-only formula. **This should be failing on insert** (or the assignment is silently discarded), which explains why item V.8 seemed inconsistent — the whole assignment line is a no-op.
- **Fix:** delete that assignment. The GDD's `FQS_Restriction_Type__c` automatically mirrors the linked GiftDesignation, so the flow doesn't need to (and can't) set it. This actually **resolves V.8** — the formula does the right thing; the flow's misguided override is either silently ignored or throwing an error we haven't hit.
- **Seed parity note:** the seed doesn't set this field on GDD ([FQSSeedGenerator.cls:361-365](../force-app/main/default/classes/FQSSeedGenerator.cls#L361-L365)). ✓ Seed is right; flow is wrong.

#### P.7 `GiftTransactionDesignation.FQS_Restriction_Type__c` also read-only

- **Field description:** *"Formula: mirrors the Restriction Type from the related Gift Designation. Read-only."*
- **Flow:** doesn't touch it. ✓ Good. Just noting for completeness.

#### P.8 `Account` PersonAccount record type requires profile access

- **Doc §Account:** *"Even in orgs where Person Accounts are enabled, admins need the PersonAccount record type assigned via Setup → Profiles → [profile] → Record Type Settings → Account. Without it, Apex or API insert fails with 'RecordType ID {id} is not available for user'."*
- **Flow:** does not create Person Accounts, so not directly affected. But: the flow *reads* `Account.IsPersonAccount` at [Get_Account line 1470](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1470-L1486) to drive GiftType routing. On a profile without PA access, `IsPersonAccount` may still resolve — but any downstream logic that assumes household/Contact walks succeed against PA data will break. Worth verifying the launcher's target profile has PA RT access before shipping.

#### P.9 `GiftDesignation` cannot be deleted while active — implications for the flow's picker

- **Doc §GiftDesignation:** *"Cannot be deleted while IsActive = true. Deactivation does not affect existing GiftTransactionDesignation rows."*
- **Flow implication:** when the picker shows `IsActive = true` designations, the user is choosing from a set that will remain stable historically. Good — no fix needed. But confirms V.10 above: **lookup escape must also filter `IsActive = true`**, otherwise a user can attach a currently-inactive designation to a new gift, which is the exact scenario the deactivation rule is meant to prevent for new gifts.

#### P.10 `GiftCommitmentSchedule.Type` default has automation side effects

- **Doc §GiftCommitmentSchedule:** *"Type defaults to CreateTransactions. This causes NPC's scheduled Apex to auto-generate GiftTransaction rows for each unpaid installment on the schedule's cadence."*
- **Flow implication for item 1.3 (missing schedule create):** when we add the schedule, **omitting `Type`** means NPC will auto-generate installment gifts for the pledge. Might be what we want; might not. If the user is entering a pledge that will be paid manually, we probably want `Type = 'PauseTransactions'`. Business decision.
- **Seed parity:** seed doesn't set `Type` on schedules ([FQSSeedGenerator.cls:385-394](../force-app/main/default/classes/FQSSeedGenerator.cls#L385-L394)) — meaning every seeded pledge has NPC quietly generating installments in the background. Explains a lot about seed-org gift counts.

---

### Tier 1 — May fail on save or break downstream automation

#### 1.1 `GiftCommitment.RecurrenceType` never set on Pledge create

- **Seed:** every commitment gets `RecurrenceType = 'OpenEnded'` (Recurring) or `'FixedLength'` (Pledged / Grant). See [FQSSeedGenerator.cls:305, 319, 337](../force-app/main/default/classes/FQSSeedGenerator.cls#L305).
- **Flow:** [Assign_Pledge_Defaults](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L522-L552) omits it entirely.
- **Reveal:** the seed always sets it — likely because the platform requires it, or a downstream automation pattern-matches on it. Pledge inserts may fail, or schedule-generator behavior may silently misfire.
- **Fix:** set `rsv_GiftCommitment.RecurrenceType = 'FixedLength'` in `Assign_Pledge_Defaults` (the launcher only creates Pledged Gifts, which the seed always marks FixedLength).

#### 1.2 `ExpectedEndDate` never set on Pledge create

- **Seed:** every FixedLength commitment has `ExpectedEndDate` set to `StartDate.addYears(1..5)` — see [FQSSeedGenerator.cls:324, 342](../force-app/main/default/classes/FQSSeedGenerator.cls#L324).
- **Flow:** never sets it.
- **Reveal:** likely required for FixedLength commitments, or required by any "pledge fulfillment progress" rollup.
- **Fix:** either (a) add an `ExpectedEndDate` input to `Screen_Pledge_Details`, or (b) derive from `EffectiveStartDate + n years` with a sensible default. Prefer (a) — the tester should be able to model multi-year pledges.

#### 1.3 No `GiftCommitmentSchedule` created alongside the Pledge

- **Seed:** unconditionally creates a schedule for every commitment — [FQSSeedGenerator.cls:370-396](../force-app/main/default/classes/FQSSeedGenerator.cls#L370-L396). Includes `TransactionAmount`, `TransactionPeriod`, `StartDate`, `PaymentMethod`, and (for FixedLength) `EndDate`.
- **Flow:** never creates a schedule.
- **Reveal:** the launcher already *reads* the schedule at payment time (`Get_Commitment_Schedule` prefills the amount from `TransactionAmount`) — meaning any launcher-created pledge that later has a payment recorded against it will get no schedule prefill.
- **Impact:** schedule-driven rollups, "next expected payment" fields, and platform-driven reminders will be broken for launcher-created pledges.
- **Fix:** after `Create_Pledge`, create a corresponding `GiftCommitmentSchedule` with `TransactionAmount = ExpectedTotalCmtAmount / years`, `TransactionPeriod = 'Yearly'` (or add a picklist to `Screen_Pledge_Details`), `StartDate = EffectiveStartDate`, `EndDate = ExpectedEndDate`, `PaymentMethod = ?` (probably needs a screen input).

#### 1.4 No `GiftTransactionDesignation` fallback when user skips designation

- **Seed:** creates a GTD for every gift at 100% ([FQSSeedGenerator.cls:758-771](../force-app/main/default/classes/FQSSeedGenerator.cls#L758-L771)).
- **Flow:** [Decide_Create_Designation](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1195-L1213) creates a GTD **only** when the user picks a designation. The picker is optional (`isRequired` is not set; the user can skip).
- **Impact:** gifts entered without a designation won't roll up to any designation summary. All designation-based reporting misses launcher gifts.
- **Fix:** if no designation is picked, fall back to the default `GiftDesignation` (already loaded on the Pledge branch via `Get_Default_Designation`; add the same lookup to the Transaction branch). If a default doesn't exist, either force the user to pick (make designation required) or accept a null GTD.

---

### Tier 2 — Silent data drift / reporting inaccuracy

#### 2.1 `GiftTransaction.Status` is hardcoded to `'Paid'`

- **Seed:** distributes 90% Paid / 5% Pending / 3% Failed / 2% Unpaid — [FQSSeedGenerator.cls:546-550](../force-app/main/default/classes/FQSSeedGenerator.cls#L546-L550).
- **Flow:** all four default blocks hardcode `Status = 'Paid'`; no status picker on `Screen_Gift_Details`.
- **Impact:** the launcher cannot model a bounced check, pending ACH, unpaid pledge payment, or failed transaction. Testers see seed variety the launcher cannot reproduce.
- **Fix:** add a `Status` picklist to `Screen_Gift_Details` (default `Paid`, use a dynamic choice set from GiftTransaction.Status — same pattern as `pcs_PaymentMethod` at [line 1339](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1339)). Remove the hardcoded `Status = 'Paid'` from the four `Assign_Defaults_*` blocks.

#### 2.2 `TransactionDueDate` will lie once Status ≠ Paid

- **Seed:** `TransactionDueDate = isPaid ? txnDate : txnDate.addDays(30)` — [FQSSeedGenerator.cls:604](../force-app/main/default/classes/FQSSeedGenerator.cls#L604).
- **Flow:** [Assign_Fanout_Amount](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L424-L428) always sets `TransactionDueDate = TransactionDate`. Correct only because Status is hardcoded Paid.
- **Fix:** couple with 2.1 — when Status ≠ Paid, set `TransactionDueDate = TransactionDate + 30 days`.

#### 2.3 `FQS_Recurring__c` not set on Pledge Payments against a Recurring commitment

- **Seed:** sets `FQS_Recurring__c = true` when the parent commitment category is `Recurring Gift` — [FQSSeedGenerator.cls:615-617](../force-app/main/default/classes/FQSSeedGenerator.cls#L615-L617).
- **Flow:** [Assign_Defaults_PledgePayment](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L317-L357) never sets it, regardless of the commitment's category.
- **Impact:** any "recurring vs one-time" reporting split will misclassify launcher-created payments made against recurring commitments.
- **Fix:** add a decision after `Assign_Defaults_PledgePayment` — if `rsv_SelectedCommitment.FQS_Gift_Commitment_Category__c == 'Recurring Gift'`, set `rsv_GiftTransaction.FQS_Recurring__c = true`.

#### 2.4 No fee decomposition — `GatewayTransactionFee`, `ProcessorTransactionFee`, `DonorCoverAmount`

- **Seed:** every gift gets a full fee breakdown via `computeFees` — [FQSSeedGenerator.cls:139-159](../force-app/main/default/classes/FQSSeedGenerator.cls#L139-L159). Rates keyed on payment method (Credit Card 2.2% + $0.30, ACH 0.8%, PayPal 2.9% + $0.49, Check/In-Kind 0%).
- **Flow:** none of these fields are set.
- **Impact:** any "Net Amount" or "Donor Covered Fees" report silently under-reports for launcher-created gifts.
- **Fix:** two options —
  - **(a)** Replicate the fee model in the flow (formula fields, or a small invocable Apex action that mirrors `computeFees`).
  - **(b)** Expose the fee fields on the screen so the user can enter them.
  - Recommend (a) — user entering fees is unrealistic; the seed's model is already the source of truth.

#### 2.5 No `OutreachSourceCodeId` on created gifts

- **Seed:** assigns an OSC per gift, FY-scoped to match the campaign — [FQSSeedGenerator.cls:566-584](../force-app/main/default/classes/FQSSeedGenerator.cls#L566-L584).
- **Flow:** never sets `OutreachSourceCodeId`.
- **Impact:** depends on downstream logic. Seed comment [line 184-186](../force-app/main/default/classes/FQSSeedGenerator.cls#L184-L186) says OSCs are optional for the ack flow, but the ack flow's *routing* logic may still expect an OSC-driven path.
- **Fix (deferred pending investigation):** either (a) add an OSC picker to the flow (probably too much friction for a "single gift" launcher), or (b) auto-assign an OSC based on the picked Campaign — if any OSC exists whose `CampaignId` matches, use it. Cost is one extra Get + Decide; reward is parity.

#### 2.6 `TaxReceiptStatus` — flow hardcodes it, seed omits it

- **Flow:** sets `'To Be Sent'` for Outright / In-Kind / Pledge Payment; `"Don't Send"` for Fee-for-Service.
- **Seed:** never sets `TaxReceiptStatus`.
- **Impact:** direction of drift is reversed vs. every other finding — here the *seed* is the problem, and any downstream automation keyed on `TaxReceiptStatus` will behave differently against seed data.
- **Fix:** apply the flow's defaults to the seed generator when constructing `GiftTransaction` rows.

---

### Tier 3 — UX degradation / picker coverage

#### 3.1 No `CampaignMember` created when user picks a Campaign via the lookup escape hatch

- **Seed §12.1:** [FQSSeedGenerator.cls:670-714](../force-app/main/default/classes/FQSSeedGenerator.cls#L670-L714) explicitly creates a `CampaignMember` for every donor+campaign pair because the flow's own campaign picker ([Get_CampaignMembers line 1510](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1510-L1526)) filters campaigns via `CampaignMember`. Seed comment: "Without this, the picker is empty on every donor."
- **Flow:** does not create a `CampaignMember` when the user picks a Campaign via lookup escape hatch.
- **Impact:** a user who repeatedly uses lookup to attribute to Campaign X will never see Campaign X in the datatable — they're perpetually forced to the lookup. Self-perpetuating UX degradation.
- **Fix:** after a successful GT create, if the Campaign was picked via lookup (not from the datatable), create a `CampaignMember` for the Account's primary Contact + selected Campaign. Swallow the DUPLICATE_VALUE error (see seed pattern at [line 705-714](../force-app/main/default/classes/FQSSeedGenerator.cls#L705-L714)).

#### 3.2 Org-donor Campaign picker is always empty (no Person Contact)

- **Seed:** only creates CampaignMembers for Person Accounts because CampaignMember needs a `ContactId` and Org donors don't have a primary Contact on the Account itself — [line 675-681](../force-app/main/default/classes/FQSSeedGenerator.cls#L675-L681).
- **Flow:** `Get_Account_Contacts` on an Org Account returns any Contacts under the Account, but if the Org has no Contacts, the picker is empty.
- **Impact:** the datatable UX is materially worse for Org donors. They'll be forced to lookup escape hatch every time.
- **Fix:** either (a) accept the limitation and skip the datatable for Org donors (route straight to lookup), or (b) extend the picker to also match campaigns tied to the Account directly. This is a design decision, not a bug.

#### 3.3 `GiftCommitment.Status` picker allows more states than are ever written

- **Filter:** `Get_Active_Commitments` allows `Active, Failing, Lapsed, Paused` ([line 1571-1575](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1571-L1575)).
- **Seed & Flow:** both only ever write `Active`.
- **Reveal:** `Failing/Lapsed/Paused` are transition states driven by rollup automation, not user-authored. Not a bug — but the seed's lack of variety means those picker branches are untested.
- **Fix (optional):** add a small probability knob to the seed to sprinkle a few `Lapsed`/`Paused` commitments so the picker filter is exercised.

---

### Tier 4 — Data-shape mismatches & cosmetics

#### 4.1 Seed can produce category combinations the flow refuses

- **Flow:** In-Kind is its own ask type; `FQS_In_Kind__c = true` only when `pkAskType == 'InKind'`, and category is always `Outright Gift`.
- **Seed:** rolls `PROB_INKIND` on every category — a Pledge Payment or Grant Payment can be flipped In-Kind ([FQSSeedGenerator.cls:621-622](../force-app/main/default/classes/FQSSeedGenerator.cls#L621-L622)).
- **Occurrence:** 0.05%.
- **Fix:** constrain the seed roll to `cat == 'Outright Gift'` only.

#### 4.2 `NonTaxDeductibleAmount = 0` inconsistency

- **Flow:** sets `NonTaxDeductibleAmount = 0` on Outright, In-Kind, and Pledge Payment — but not Fee-for-Service (where it arguably matters most).
- **Seed:** never sets it.
- **Fix:** decide whether the field is required. If yes, set `= 0` on all four flow paths and mirror in the seed. If no, remove from the flow.

#### 4.3 `GiftDefaultDesignation` created on every launcher pledge; seed skips Unconditional

- **Seed §12.2:** [line 349-368](../force-app/main/default/classes/FQSSeedGenerator.cls#L349-L368) inserts a GDD only on Conditional (non-grant) commitments.
- **Flow:** creates a GDD on every pledge that has a selected designation, regardless of Conditional / Unconditional.
- **Question:** for Unconditional pledges, is a GDD wanted (attributes future payments to a specific designation) or unwanted (Unconditional means "no restriction — use org default")? This is a business rule to confirm.
- **Fix (pending decision):** align to whichever direction the business intent goes.

#### 4.4 Stale `CurrentAmount` comment in flow

- [Assign_Fanout_Amount description](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L413-L415) says "Fan the single Amount input out to OriginalAmount and **CurrentAmount**" but only `OriginalAmount` is assigned. Same stale reference on `var_GiftAmount` variable description ([line 2747](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2747)).
- **Fix:** update both descriptions to match, or add the `CurrentAmount` assignment if it was dropped by mistake.

---

### Tier 4.5 — Validation gaps surfaced by descriptions

Element descriptions in the flow read like validation assertions, but the flow doesn't enforce most of them. Each item below quotes the description, then contrasts with the actual runtime behavior.

#### V.1 `Decide_Has_Commitment` — "must be selected", but lookup path admits null

- **Description ([line 835](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L835)):** *"A commitment must be selected for the Pledge Payment path. If none, send the user back to the picker."*
- **Reality:** the re-prompt handles the table-selection case. The lookup path queries `Get_Looked_Up_Commitment` with a potentially null `rsv_LookupCommitment.Id`, writes null onto `rsv_SelectedCommitment`, and *then* re-prompts. Works, but with a redundant SOQL and no explicit user-facing warning.
- **Fix:** null-check before the lookup query, or make the lookup screen-level required with `isRequired=true`.

#### V.2 `var_SoftCreditPercent` — "0-100" claim not enforced

- **Description ([line 2756](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2756)):** *"Soft credit percent (0-100). Only used when var_SoftCreditType = 'Partial'."*
- **Reality:** `numSoftCreditPercent` on `Screen_SoftCredit_Amount` ([line 2260-2274](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2260-L2274)) is `isRequired=false` with no min/max. Negative, > 100, or blank are all accepted. `Assign_SoftCredit_Partial` writes the raw value straight to `PartialPercent`. Nonsense soft credits or platform-side validation errors on save.
- **Fix:** `isRequired=true` when `pkSoftCreditType == 'Partial'`, plus a screen validation formula: `numSoftCreditPercent > 0 AND numSoftCreditPercent <= 100`.

#### V.3 `Get_Default_Designation` — silent-fallback described but not surfaced

- **Description ([line 1793](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1793)):** *"If absent (null), rsv_SelectedDesignation stays null and no GiftDefaultDesignation is created for this pledge."*
- **Reality:** an org without a `IsActive=true AND IsDefault=true` GiftDesignation silently creates an Unconditional pledge with no GDD. Any restriction-based rollup misses this pledge and no one notices until reporting.
- **Fix:** either surface a warning on the Success screen ("no default designation configured — this pledge has no designation assigned"), or fail-fast on load if the launcher requires a default and none exists.

#### V.4 `Assign_Pledge_Campaign` — "CampaignId stays null" contradicts seed contract

- **Description ([line 608](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L608)):** *"If none selected, CampaignId stays null."*
- **Reality:** the seed sets `CampaignId` on every commitment ([FQSSeedGenerator.cls:309, 325, 343](../force-app/main/default/classes/FQSSeedGenerator.cls#L309)) — the seed treats it as effectively required for data quality. Flow allows null. Divergence.
- **Fix:** enforce Campaign selection in the flow (make `Screen_Pick_Campaign_Pledge` required), or accept nulls and drop the seed's always-set behavior. Preference: enforce.

#### V.5 `Decide_Fulfillment` — "(may be null)" is a warning sign

- **Description ([line 1278](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1278)):** *"Unconditional → auto-select default designation (may be null)."*
- Same pattern as V.3 — the parenthetical acknowledges a failure mode the flow doesn't guard.

#### V.6 `rsv_GTDesignation` — description implies always-created

- **Description ([line 2719](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2719)):** *"Record variable for the GiftTransactionDesignation created after a GiftTransaction insert."*
- **Reality:** created only when the user picks a designation (already flagged as **1.4** above). Description misleads maintainers into thinking every transaction gets a GTD.
- **Fix:** either fix the flow (see 1.4 — add default fallback) or update the description to reflect the conditional.

#### V.7 `rsv_GiftDefaultDesignation` — same over-promise

- **Description ([line 2728](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2728)):** *"Record variable for the GiftDefaultDesignation created after a new GiftCommitment (Pledge) insert."*
- **Reality:** only when a designation is selected AND the pledge branch reaches `Decide_Create_Default_Designation` with a non-null designation.

#### V.8 `var_RestrictionType` — GDD restriction type may lie for lookup-escape picks

- **Description ([line 2765](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2765)):** *"Screen-scoped restriction picklist value chosen on Screen_Pick_Restriction. Used only to filter the designation picker; not stored on GiftCommitment."*
- **Reality:** it's stored on `GiftDefaultDesignation.FQS_Restriction_Type__c` via `Assign_Build_Default_Designation`. If the user picks restriction "Purpose", then lookup-escapes to a Time-restricted GiftDesignation, the resulting GDD says "Purpose" while the linked GD says "Time" — data inconsistency the flow never checks.
- **Fix:** derive `GDD.FQS_Restriction_Type__c` from `rsv_SelectedDesignation.FQS_Restriction_Type__c` (the actual picked designation), not from the screen picklist `var_RestrictionType`.

#### V.9 `Decide_Restriction_Path` — lookup escape can violate Conditional filter

- **Description ([line 918](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L918)):** *"For Pledge Payment Conditional → filter designations by the commitment's existing GiftDefaultDesignation restriction."*
- **Reality:** the datatable filter is correct. The lookup-escape path (`Get_Looked_Up_Designation`) bypasses the filter — user can pick any designation regardless of restriction. Resulting GTD has a designation whose restriction differs from the parent commitment's default → business-rule violation, silently created.
- **Fix:** on Conditional Pledge Payment, either disable the lookup escape entirely, or validate `Get_Looked_Up_Designation.FQS_Restriction_Type__c == var_RestrictionType` before assigning; re-prompt on mismatch.

#### V.10 `Get_Filtered_Designations` — `IsActive` filter absent on lookup path

- **Reality:** [Get_Filtered_Designations line 1711](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1711) filters to `IsActive=true`. But `Get_Looked_Up_Designation` at [line 1735-1751](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1735-L1751) filters only by `Id` — no active check.
- **Reveal:** a user can lookup-pick an inactive designation, bypassing the active-only rule.
- **Fix:** add `IsActive=true` to the lookup's filter and re-prompt on empty match. Same pattern applies to `Get_Looked_Up_Campaign` (any `IsActive`/status filter?) and any other lookup-escape used to bypass a table's active filter.

---

### Tier 5 — Help text, descriptions, and choice labels

These are surfaced directly to users on screens (help text, choice labels, success/error text) or to future maintainers (element descriptions). Corrections here are cheap and improve trust in the launcher.

#### 5.1 Typo — "proceeding pledge"

- [Choice_Outright line 651](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L651): "A gift that had no **proceeding** pledge." → should be **preceding**. User-facing on `Screen_Choose_Type`.

#### 5.2 Main flow description is inaccurate about scope

- [Root flow description line 1338](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1338): claims "Every DML has a fault path to a single error screen so the user always sees why nothing was saved." True for saves — but silent on the fact that `Status` is hardcoded, that `Grant Payment` category is unsupported (only Outright, In-Kind, Fee-for-Service, Pledge Payment, Pledge), and that `TransactionDueDate` is always `TransactionDate`. Bring the description in sync with what the flow actually does.

#### 5.3 Dev tags leak into element descriptions

- Nine descriptions reference `R1`, `R2`, `R3`, `R5` (grep hits at [lines 148, 760, 897, 1001, 1045, 1390, 1646, 1671, 2283, 2800](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L760)). These are refactor-story tags meaningful only to the original author. In the Flow Builder inspector they're noise. **Fix:** either strip them, or replace with concise "what this does" prose.

#### 5.4 `Screen_Choose_Type` cross-reference to a non-existent action

- Footer text says: *"This action will create a single gift, to enter multiple gifts or payments use the **New Gift Entry action**."* No such linked action is created in the repo. Either build it, remove the reference, or reword to "batch entry via Data Loader" / similar.

#### 5.5 Success screen promises navigation the flow doesn't provide

- `Screen_Success` says: *"Open the new record from the related list on this Account, or **return here to record another**."* There is no "return here" — the flow ends. User has to relaunch the quick action.
- Also uses the HTML entity `&#10003;` for the checkmark; direct Unicode (`✓`) renders more reliably.
- **Fix:** either add a `Finish → Go To Screen_Choose_Type` behavior (Salesforce doesn't natively support "restart flow" but a Local Action can do it), or reword to "close this dialog and relaunch the New Gift action to record another."

#### 5.6 `Err_Create` says "review the details and try again" — but user can't

- `Err_Create` has `allowBack=false`. The user cannot go back to fix and retry. Wording is misleading.
- **Fix:** either enable `allowBack=true` for Err_Create (allowing the user to correct and re-save — but note the transaction is already rolled back so partial state might confuse), or reword to "Close this dialog and relaunch the action to try again."

#### 5.7 Empty-state warnings are missing across every picker

The seed goes to great lengths to *ensure* pickers have data. When the seed hasn't run (or the org is new), pickers are empty and users get no guidance:

| Screen | Filter | Empty-state condition | Missing warning |
|---|---|---|---|
| `Screen_Pick_Commitment` | Status in Active/Failing/Lapsed/Paused | Donor has no active pledges | "This donor has no active pledges — record an Outright Gift instead, or check the box above to search." |
| `Screen_Pick_Campaign` | Requires CampaignMember linking donor's Contacts | Fresh org, or Org donor with no Contacts | "No campaigns found for this donor. Use lookup above, or skip." |
| `Screen_Pick_Designation` | `IsActive AND FQS_Restriction_Type__c = X` | No designations exist for the chosen restriction type | "No designations match this restriction. Use lookup above, or continue without a designation." |
| `Screen_Pick_SoftCredit` | Subflow output | Donor has no ACR/CCR relations | "No related accounts found. Use lookup above to add a soft credit, or continue without one." |

**Fix:** add a `DisplayText` field to each screen with a `visibilityRule` that fires when the source collection `IsEmpty`. Precedent already exists in the flow (visibility rules on lookup vs datatable).

#### 5.8 Misleading help text — "optional" and "automatic"

- [Screen_Pick_Designation help](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2057): says designation is "optional" on all paths. On the Pledge Conditional branch the tester really should pick one (the whole point of the Restriction picker is to route here). Consider making designation required on the Pledge branch, or clarify the help text.
- [Choice_Fulfillment_Unconditional line 695](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L695): claims "the default unrestricted designation applies automatically." True only if a `GiftDesignation` with `IsActive=true AND IsDefault=true` exists. On a fresh org this is often absent → the Pledge is created without any GiftDefaultDesignation. Help text overstates guarantees.
- [Choice_Fulfillment_Conditional line 700](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L700): says "choose which restriction **below**" — but the restriction picker is on the *next screen*, not "below". Reword to "on the next screen."

#### 5.9 Filter criteria not surfaced to the user

Users don't see why lists are shaped the way they are:

- **Commitment picker** filters to a specific Status set — a user who knows Commitment X exists but it's `Completed` will be confused. Add: *"Showing only active-status commitments."*
- **Campaign picker** filters via `CampaignMember` — add: *"Showing only campaigns this donor is a member of."*
- **Designation picker** filters by restriction — the help text does say "filtered by restriction type: X" ([line 2057](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2057)), which is good. Consistent pattern; apply it elsewhere.

#### 5.10 Soft-credit help text uses jargon

- [SoftCreditHelp line 2151](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2151): "Related Accounts are drawn from Account-Contact and Contact-Contact relations." → few end users know what ACR / CCR are. Prefer "family, spouse, or business relationships."
- Field label on `pkNeedsSoftCredits` on `Screen_Gift_Details` reads *"Add soft credits (recognize another donor for this gift)?"* — some testers may confuse "soft credit" with "matching gift." A one-line tooltip clarifying the difference would help.

#### 5.11 `Screen_Pick_Restriction` default is arbitrary

- Defaults to `Choice_Restriction_Purpose` ([line 2538](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2538)). Why not `Without Donor Restriction` (the most common case for Conditional pledges that turn out to have no meaningful restriction)? Or leave it undefaulted and make the picker force a conscious choice. Small UX polish.

#### 5.12 Datatable columns don't show what the tester needs to disambiguate

- **Commitment picker** columns ([line 1910](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L1910)): Name, Category, Status, Fulfillment, ExpectedTotal, StartDate. Missing: `Campaign` (the picker knows this matters — Pledge Payment picks up campaign from the commitment as a fallback), `ExpectedEndDate` (helps distinguish two pledges that are otherwise identical).
- **Campaign picker** columns ([line 2004](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2004)): Name, Type, Status, StartDate, EndDate. Missing: `FQS_Campaign_Category__c` — the tester picking among asks vs cultivations vs stewardships needs this.
- **Designation picker** columns ([line 2098](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2098)): Name, Description, Restriction, IsDefault. Fine.
- **Soft-Credit picker** columns ([line 2192](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml#L2192)): Name, Type. Missing: some hint of the *relationship* (Spouse? Household? Business?) that made this Account appear.

#### 5.13 Silent required-field risks on `ObjectProvided` bindings

The following are bound via `ObjectProvided` (no explicit `isRequired`), meaning the user can leave them blank and downstream saves may fail with cryptic platform errors:

- `rsv_GiftTransaction.TransactionDate` — required on `GiftTransaction`
- `rsv_GiftTransaction.PaymentMethod` — required unless InKind
- `rsv_GiftCommitment.Name` — required on `GiftCommitment`
- `rsv_GiftCommitment.EffectiveStartDate` — required on `GiftCommitment`

**Fix:** either make these `InputField` with `isRequired=true`, or add explicit `Screen`-level validation formulas that surface a friendly error before submit.

---

## Suggested implementation order

Each row is independently mergeable. Recommend batching by tier so review scope stays tight.

Status legend: **[DO]** in scope, **[DEFERRED]** intentionally out of scope for now (documented above), **[SKIP]** superseded / no code change.

| Order | Item | Tier | Status | Notes |
|---|---|---|---|---|
| P.1 | Status picker (default `Pending`) + field description update — supersedes 2.1 | 0 | **[DO]** | 45 min |
| P.5 | Remove stale `CurrentAmount` references | 0 | **[DO]** | 5 min — reword to "OriginalAmount only; platform derives CurrentAmount" |
| P.6 | Delete assignment to read-only `GDD.FQS_Restriction_Type__c` (resolves V.8) | 0 | **[DO]** | 2 min |
| P.4 | Do NOT set `GiftCommitment.ScheduleType`; call out in element description | 0 | **[DO]** | 5 min — see redesigned pledge-structure branch |
| P.10 | `GiftCommitmentSchedule.Type` per pledge structure — see redesigned table above | 0 | **[DO]** | included in 1.3 rework |
| P.3 | OSC → CampaignId derivation | 0 | **[DEFERRED]** | tied to 2.5 |
| P.8 | Route Person Account save errors to the shared error screen (no ops profile check needed in flow) | 0 | **[DO]** | 10 min — add fault paths |
| 1 | 1.1 `RecurrenceType` — set from pledge-structure pick | 1 | **[DO]** | 5 min (rolled into 1.3 redesign) |
| 2 | 1.2 `ExpectedEndDate` screen input (option a) | 1 | **[DO]** | 30 min — only shown for Scenarios 2 and 4 |
| 3 | 1.3 `GiftCommitmentSchedule` — four pledge structures | 1 | **[DO]** | 1.5 hr — pledge-structure picker + conditional screen inputs; Scenarios 1/2 create schedule with `Type=CreateTransactions`; Scenario 3 creates schedule with `Type=PauseTransactions`; Scenario 4 creates no schedule and directs user to record page (Success screen instruction) |
| 4 | 1.4 GTD fallback — hoist default-designation lookup earlier so both branches share | 1 | **[DO]** | 20 min |
| 5 | 2.1 + 2.2 Status picker + conditional `TransactionDueDate` prompt when Status ≠ Paid | 2 | **[DO]** | 45 min |
| 6 | 2.3 `FQS_Recurring__c` on Pledge Payments against Recurring commitments | 2 | **[DO]** | 15 min |
| 7 | 2.4 Fee decomposition | 2 | **[DEFERRED]** | flow ignores fees |
| 8 | 2.5 `OutreachSourceCodeId` | 2 | **[DEFERRED]** | Campaign is the priority; OSC support deferred |
| 9 | 2.6 `TaxReceiptStatus` in seed | 2 | **[DO]** | 15 min |
| 10 | 3.1 CampaignMember on lookup pick | 3 | **[DEFERRED]** | separate flow will handle |
| 11 | 3.2 Org donor picker UX | 3 | **[DEFERRED]** | possibly enable Accounts-on-Campaigns later |
| 12 | 3.3 Lapsed/Paused seed variety | 3 | **[DO]** | 15 min |
| 13 | 4.1 Seed In-Kind constraint | 4 | **[DO]** | 5 min |
| 14 | 4.2 `NonTaxDeductibleAmount` — remove flow assignments (auto-calculated) | 4 | **[DO]** | 5 min |
| 15 | 4.3 GDD on Unconditional — remove GDD create for Unconditional pledges | 4 | **[DO]** | 10 min |
| 16 | 4.4 `CurrentAmount` description accuracy | 4 | **[DO]** | 5 min — description-only |
| 16a | V.1 Commitment lookup null-check | 4.5 | **[DO]** | 10 min |
| 16b | V.2 Soft credit percent 0–100 enforcement | 4.5 | **[DO]** | 10 min |
| 16c | V.3 Default-designation absence — surface warning on Success screen | 4.5 | **[DO]** | 15 min |
| 16d | V.4 Require Campaign selection on both branches | 4.5 | **[DO]** | 5 min |
| 16e | V.6 / V.7 Fix description accuracy (post-1.4) | 4.5 | **[DO]** | 5 min |
| 16f | V.8 GDD restriction derived from picked designation | 4.5 | **[SKIP]** | resolved by P.6 (deleting the read-only write) |
| 16g | V.9 Conditional Pledge Payment — validate lookup pick's restriction matches, re-prompt on mismatch | 4.5 | **[DO]** | 20 min |
| 16h | V.10 Active-only filter on lookup paths | 4.5 | **[DO]** | 10 min |
| 17 | 5.1 "proceeding" typo | 5 | **[DO]** | 1 min |
| 18 | 5.2 Root flow description accuracy | 5 | **[DO]** | 10 min |
| 19 | 5.3 Strip R1/R2/R3/R5 dev tags | 5 | **[DO]** | 15 min |
| 20 | 5.4 Screen_Choose_Type footer cross-ref | 5 | **[SKIP]** | action exists elsewhere; copy stays |
| 21 | 5.5 Success screen — remove "return here" claim; reword | 5 | **[DO]** | 15 min |
| 22 | 5.6 `Err_Create` reword | 5 | **[DO]** | 10 min |
| 23 | 5.7 Empty-state warnings on remaining pickers | 5 | **[DO]** | 20 min (Campaign-picker warning moot given V.4 requirement, but Commitment/Designation/SoftCredit still need it) |
| 24 | 5.8 Fulfillment / designation help-text accuracy | 5 | **[DO]** | 10 min |
| 25 | 5.9 Surface filter criteria in help text | 5 | **[DO]** | 15 min |
| 26 | 5.10 Soft-credit — friendly language + jargon in parens | 5 | **[DO]** | 5 min |
| 27 | 5.11 Restriction picker default — leave undefaulted | 5 | **[DO]** | 2 min |
| 28 | 5.12 Datatable column additions | 5 | **[DO]** | 20 min |
| 29 | 5.13 Object name defaults + smart defaults (no new required inputs) | 5 | **[DO]** | 15 min — apply formula defaults for GC.Name / GT.Name; smart defaults for TransactionDate / EffectiveStartDate |

## Open questions for reviewer

All questions resolved as of 2026-07-16. See the **Reviewer decisions** section and the redesigned pledge-structure table for the answers.


---

## Launcher redesign appendix (merged 2026-07-18 from fqs-gift-entry-account-launcher-plan.md)

The section below preserves the R1–R5 redesign, decisions table, soft-credit subflow spec, and datatable-picker pattern from the deleted launcher plan. Any conflict between this appendix and the Reviewer Decisions / Tier tables above is resolved in favor of the Tier tables — this appendix is the *design memo* that shaped the current flow; the Tier tables are the *implementation punch-list*.



**Flow:** [force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml)
**Status in repo:** untracked (never committed) — pulled fresh from FundFirst this session.

---

## What changed in your working copy

1. **Pledge Payment added as a 5th ask type** — `Choice_PledgePayment` present, but `Decide_Ask_Type` has no rule for it, so it currently falls through to the default connector (Outright behavior).
2. **Record-variable scaffolding started** — `rsv_GiftTransaction` (SObject / GiftTransaction) declared. `Screen_Gift_Details` has `ObjectProvided` fields for `.GiftCommitmentId / .PaymentMethod / .PaymentIdentifier / .TransactionDate / .TransactionDueDate`.
3. **Duplicate inputs left in place** — screen-scoped duplicates (`numGiftAmount`, `numGiftAmount2`, `dtGiftTransactionDate`, `txtGiftPaymentMethod`, `txtGiftPaymentMethod2`, `txtGiftPaymentInstrument`, `txt_Description_InKind`) remain alongside the record-provided ones.
4. **`Create_Gift_Transaction` not yet re-wired** — still uses per-field `inputAssignments` referencing screen-scoped vars; values entered via `ObjectProvided` fields are discarded on save.

---

## Decisions (locked)

| # | Decision | Value |
|---|---|---|
| 1 | Campaign datatable filter | All Campaigns where any Contact whose `AccountId = recordId` is a `CampaignMember` |
| 2 | OSC sync when Campaign selected | Leave `OutreachSourceCodeId` blank |
| 3 | Designation slots on this flow | One slot, 100% split — creates a single `GiftTransactionDesignation` |
| 4 | In-Kind description target | Reuse **`GiftTransaction.Description`** (standard textarea, 255 chars) |
| 5 | `FQS_Gift_Transaction_Category__c = 'Pledge Payment'` | Already in picklist — no field change needed |
| 6 | Pledge Payment prefill | See §Pledge Payment sub-flow below — schedule-aware |
| 7 | Pledge branch also gets Campaign + Designation pickers | Yes, both |
| 8 | Create nodes | Use `<inputReference>` with the record variable (drop per-field `inputAssignments`) |
| 9 | Soft credits | Datatable of unique Accounts derived from ACRs (`AccountContactRelation` where `ContactId` is on this Account's household) and CCRs (`ContactContactRelation` reachable from those Contacts). One recipient at a time, with Full or Partial (%) credit. |
| 10 | Datatable "search outside the list" | Every datatable screen has an escape hatch: a lookup control for the underlying object below the table. Selecting via lookup bypasses the filter and stores the same record variable as the table selection. |
| 11 | In-Kind Payment Method | Defaulted by the flow (`In-Kind`) and **not shown** on the screen. Same principle applied to all optional fields where a single value is obviously correct. |
| 12 | GiftType | Auto-derived from `Account.IsPersonAccount` in Assignment. **Not shown on screen.** |
| 13 | In-Kind Amount handling | `OriginalAmount = 0`. Fair market value goes on `TaxDeductionAmount`. All-or-nothing tax treatment (no partial-benefit split). |
| 14 | Pledge restriction control | Use the native `GiftCommitment.FulfillmentType` (`Unconditional` / `Conditional`) — no new custom field. `Unconditional` → auto-assign the default designation (`GiftDesignation.IsDefault = true`). `Conditional` → user picks Restriction Type first, then filtered Designation picker. |

## Simplification principles (apply throughout)

The goal is the simplest possible screen at every step. Concrete rules that fall out:

- **Hide anything with an obvious default.** In-Kind Payment Method is defaulted to `In-Kind` in the Assignment node and not rendered.
- **`OriginalAmount` and `CurrentAmount` collapse to one field on the screen.** The user enters one Amount; both `OriginalAmount` and `CurrentAmount` on `rsv_GiftTransaction` get that value via Assignment.
- **`TransactionDueDate` is hidden** on the transaction screen — defaulted to `TransactionDate` in Assignment. (User doesn't need to think about "due" vs. "transaction" on a payment being recorded right now.)
- **Picker screens skip cleanly.** If the datatable has zero rows AND the user didn't use the lookup escape, no picker screen is shown at all (guarded by a Decide element).
- **Optional pickers advertise as optional.** Campaign, Designation, and Soft Credit screens all have a visible "Skip" / "None" path that requires no input.

---

## Target design

### Variables

- `rsv_GiftTransaction` *(exists)* — extend to carry `CampaignId`, `OriginalAmount`, `CurrentAmount`, `GiftCommitmentScheduleId`, `Description`, plus the fields already bound.
- `rsv_GiftCommitment` *(new)* — SObject/GiftCommitment. Used on the Pledge (commitment-creation) branch.
- `rsv_SelectedCommitment` *(new)* — SObject/GiftCommitment. Holds the row picked from the Pledge Payment datatable.
- `rsv_SelectedSchedule` *(new)* — SObject/GiftCommitmentSchedule. Holds the nearest unpaid schedule row for the selected commitment, if one exists.
- `rsv_SelectedCampaign` *(new)* — SObject/Campaign.
- `rsv_SelectedDesignation` *(new)* — SObject/GiftDesignation.
- `rsv_SelectedSoftCreditAccount` *(new)* — SObject/Account. Recipient of the soft credit.
- `var_IsSatisfyingScheduledPayment` *(new)* — Boolean. True when the user confirms this payment satisfies an existing scheduled installment.
- `var_SoftCreditType` *(new)* — String, `'Full' | 'Partial' | 'None'`. Drives the soft-credit create node.
- `var_SoftCreditPercent` *(new)* — Number, 0–100. Only used when `var_SoftCreditType = 'Partial'`.
- `var_GiftAmount` *(new)* — Currency. Single Amount input; assigned to both `rsv_GiftTransaction.OriginalAmount` and `rsv_GiftTransaction.CurrentAmount`.

### Flow paths after redesign

```
Start
 → Get_Account
 → Screen_Choose_Type (Outright | In-Kind | Fee-for-Service | Pledge Payment | Pledge)
 → Decide_Ask_Type
    ├── Outright ─────────────────┐
    ├── In-Kind  ─────────────────┤
    ├── Fee-for-Service ──────────┤
    │                             │
    │                             ▼
    │                          Screen_Pick_Campaign (datatable + lookup escape, optional skip)
    │                             │
    │                             ▼
    │                          Screen_Pick_Designation (datatable + lookup escape, optional skip)
    │                             │
    │                             ▼
    │                          Screen_Pick_SoftCredit (datatable + lookup escape, optional skip)
    │                             │
    │                             ▼
    │                          Screen_SoftCredit_Amount (visible only if soft-credit account chosen — Full / Partial(%))
    │                             │
    │                             ▼
    │                          Assign_Transaction_Defaults (category, in-kind flag, In-Kind PaymentMethod, single Amount → Original + Current)
    │                             │
    │                             ▼
    │                          Screen_Gift_Details (de-duped, minimal)
    │                             │
    │                             ▼
    │                          Create_Gift_Transaction (inputReference=rsv_GiftTransaction)
    │                             │
    │                             ▼
    │                          Create_GiftTransactionDesignation (if designation picked)
    │                             │
    │                             ▼
    │                          Create_GiftSoftCredit (if soft-credit account picked)
    │                             │
    │                             ▼
    │                          Screen_Success
    │
    ├── Pledge Payment ────────►  Screen_Pick_Commitment (datatable — active commitments for this donor)
    │                             │
    │                             ▼
    │                          Get_Next_Unpaid_Schedule (SOQL: next GiftCommitmentSchedule for selected commitment)
    │                             │
    │                             ▼
    │                          Decide_HasUnpaidSchedule
    │                             ├── Yes → Screen_Confirm_Satisfies_Schedule (radio: satisfies existing / extra payment)
    │                             │           │
    │                             │           ├── Satisfies → Assign schedule Id + prefill amount/date → Screen_Gift_Details
    │                             │           └── Extra    → Screen_Gift_Details (no prefill, no schedule link)
    │                             └── No → Screen_Gift_Details (no prefill, no schedule link)
    │
    │                             ▼
    │                          Screen_Pick_Campaign → Screen_Pick_Designation → Screen_Pick_SoftCredit → Screen_SoftCredit_Amount → Assign_Transaction_Defaults (category='Pledge Payment')
    │                             │
    │                             ▼
    │                          Create_Gift_Transaction (inputReference=rsv_GiftTransaction, includes GiftCommitmentId + optional GiftCommitmentScheduleId)
    │                             │
    │                             ▼
    │                          Create_GiftTransactionDesignation (if designation picked)
    │                             │
    │                             ▼
    │                          Create_GiftSoftCredit (if soft-credit account picked)
    │                             │
    │                             ▼
    │                          Screen_Success
    │
    └── Pledge (new commitment) ► Screen_Pledge_Details (incl. FulfillmentType radio)
                                  → Screen_Pick_Campaign
                                  → Decide_Fulfillment
                                     ├── Unconditional → Get_Default_Designation (LIMIT 1; may return null)
                                     │                    → Assign_Default_Designation (null-safe)
                                     └── Conditional   → Screen_Pick_Restriction (4-value radio)
                                                          → Screen_Pick_Designation (filtered by chosen restriction; may be skipped)
                                  → Create_Pledge (inputReference=rsv_GiftCommitment)
                                  → Decide_HasDesignation
                                     ├── Has → Create_GiftDefaultDesignation
                                     └── None → skip
                                  → Screen_Success
                                  (Soft credits attach to GiftTransaction, not GiftCommitment — the Pledge branch creates no transaction, so no soft-credit picker here.)
```

### Datatable pickers — general pattern

All datatable screens use the same layout so behavior is consistent:

1. **Header** — one-line context ("Optional — pick a Campaign for this gift" etc.).
2. **`flowruntime_lwc:datatable`** — filtered / pre-scoped rows, single-row selection.
3. **Lookup escape hatch** — a standard `<inputField>` of type `Lookup` scoped to the same object, sitting directly under the table. Label: *"Not in the list? Search…"*. When populated, this takes precedence over the table selection.
4. **Skip / Continue footer** — user can leave both empty to skip; a downstream Decide element checks whether either produced a value.

An Assignment element after each picker resolves the final selection:
```
IF Lookup populated → rsv_Selected<X> = <lookup value>
ELSE IF Table populated → rsv_Selected<X> = <table row>
ELSE → rsv_Selected<X> stays null (skip)
```

### Datatable pickers — specifics

All use `flowruntime_lwc:datatable`. Each collects a single-row selection into an SObject variable.

**Screen_Pick_Commitment** (Pledge Payment only)
- Source: SOQL `GiftCommitment` where `DonorId = recordId` AND `Status IN ('Active','Failing','Lapsed','Paused')` AND `FQS_Gift_Commitment_Category__c IN ('Pledged Gift','Recurring Gift')`
- Columns: Name, Category, Status, Expected Total, Balance, EffectiveStartDate
- Selection → `rsv_SelectedCommitment`
- Assignment after selection: `rsv_GiftTransaction.GiftCommitmentId = rsv_SelectedCommitment.Id`

**Screen_Pick_Campaign** (all transaction paths + Pledge path)
- Source: SOQL `Campaign` where `IsActive = true` AND `Id IN (SELECT CampaignId FROM CampaignMember WHERE ContactId IN (SELECT Id FROM Contact WHERE AccountId = :recordId))`
- Columns: Name, StartDate, EndDate, Status, Type
- Optional skip button ("No campaign attribution")
- Selection → `rsv_SelectedCampaign`
- Assignment: `rsv_GiftTransaction.CampaignId` (or `rsv_GiftCommitment.CampaignId` for pledge branch)

**Screen_Pick_Designation** (all paths)
- Source: SOQL `GiftDesignation` where `IsActive = true` AND `FQS_Restriction_Type__c` matches the ask's restriction scope (see §Restriction handling below)
- Columns: Name, Description, Restriction Type
- Optional skip button ("No designation — use default")
- Lookup escape scoped to GiftDesignation (also restriction-filtered — see §Restriction handling)
- Selection → `rsv_SelectedDesignation`
- No direct field assignment; drives a post-create `Create_GiftTransactionDesignation` or `Create_GiftDefaultDesignation`

**Screen_Pick_SoftCredit** (all GiftTransaction paths — not the Pledge/commitment-only path)
- Source: SOQL Account where `Id IN (`
    `SELECT AccountId FROM AccountContactRelation WHERE ContactId IN (SELECT Id FROM Contact WHERE AccountId = :recordId) AND IsActive = true`
    `) OR Id IN (`
    `SELECT AccountId FROM Contact WHERE Id IN (SELECT RelatedContactId FROM ContactContactRelation WHERE ContactId IN (SELECT Id FROM Contact WHERE AccountId = :recordId) AND IsActive = true)`
    `)`
- Excludes the source Account itself (`Id != :recordId`).
- Deduplicated in the flow via Loop→AddOnlyIfNotAlreadyIn pattern (SOQL `IN` subqueries may return duplicates if a related Contact spans multiple relations).
- Columns: Name, Type, Owner
- Optional skip button ("No soft credit")
- Lookup escape scoped to Account (unfiltered — user can pick any Account)
- Selection → `rsv_SelectedSoftCreditAccount`

### Restriction handling — driven by `GiftCommitment.FulfillmentType`

No new custom field. We piggyback on the native `GiftCommitment.FulfillmentType` picklist (`Unconditional | Conditional`).

**Pledge (new commitment) branch:**
1. `Screen_Pledge_Details` gains a `FulfillmentType` radio (`Unconditional` / `Conditional`) bound to `rsv_GiftCommitment.FulfillmentType`. Defaults to `Unconditional`.
2. Decide branch after the screen:
   - **Unconditional** → `Get_Default_Designation` (SOQL: `GiftDesignation` where `IsDefault = true` AND `IsActive = true`, LIMIT 1). If found, Assignment sets `rsv_SelectedDesignation` to it. If not found, `rsv_SelectedDesignation` stays null and no `GiftDefaultDesignation` is created for the commitment. **No fault; no prompt.**
   - **Conditional** → show `Screen_Pick_Restriction` (radio, four values: `Without Donor Restriction`, `With Donor Restriction - Purpose`, `With Donor Restriction - Time`, `With Donor Restriction - Permanent`) → then `Screen_Pick_Designation` filtered by that restriction value.
3. The restriction picklist value picked on `Screen_Pick_Restriction` is used only to filter the designation datatable — it is **not** stored on `rsv_GiftCommitment`. The chosen designation is on `GiftDefaultDesignation.GiftDesignationId`; that designation's own `FQS_Restriction_Type__c` becomes the source of truth going forward.
4. `Create_GiftDefaultDesignation` is guarded by a Decide element — if `rsv_SelectedDesignation` is null, skip creating the default-designation record entirely.

**Pledge Payment branch (recording a payment on an existing commitment):**
1. After `Screen_Pick_Commitment`, inspect `rsv_SelectedCommitment.FulfillmentType`.
   - **Unconditional** → skip the Designation picker for this payment; carry the commitment's existing default designation via `GiftDefaultDesignation` (already linked at the commitment level, so no `GiftTransactionDesignation` is required on the transaction). If the commitment has no `GiftDefaultDesignation` on file, no `GiftTransactionDesignation` is created for this payment.
   - **Conditional** → `Get_Commitment_Default_Designations` (SOQL: `GiftDefaultDesignation` where `GiftCommitmentId = rsv_SelectedCommitment.Id`, LIMIT 1). If found, use that designation's `FQS_Restriction_Type__c` to filter a `Screen_Pick_Designation`, and selection creates a `GiftTransactionDesignation` at 100%. If not found, skip the Designation picker for this payment and no `GiftTransactionDesignation` is created. **No fault; no prompt.**
2. No `Screen_Pick_Restriction` on this branch — the commitment already defined its restriction posture.

**Outright / In-Kind / Fee-for-Service branches (no pledge context):**
- Designation picker stays filtered to `FQS_Restriction_Type__c = 'Without Donor Restriction'` (unconditional). A one-off gift with no pledge context is treated as unconditional by default.
- The "search outside the list" lookup escape hatch on the picker is also filtered to unrestricted designations for consistency.

### Screen_SoftCredit_Amount

Only shown when `rsv_SelectedSoftCreditAccount` is populated.
- Radio: **Full credit** (100% — `PartialPercent = null`, `SoftCreditAmount = OriginalAmount`) / **Partial credit** (user enters percent).
- If Partial, an `<inputField>` for `var_SoftCreditPercent` (0–100 required, no more than 100).
- Assignment after screen sets `var_SoftCreditType` and pre-computes `PartialAmount = OriginalAmount * (SoftCreditPercent / 100)`.

`Create_GiftSoftCredit` writes:
```
GiftTransactionId = Create_Gift_Transaction.Id
RecipientId       = rsv_SelectedSoftCreditAccount.Id
Role              = 'Soft Credit'
PartialAmount     = (Full → OriginalAmount, Partial → OriginalAmount × Percent / 100)
PartialPercent    = (Full → null,           Partial → var_SoftCreditPercent)
SoftCreditAmount  = same as PartialAmount
```

### Pledge Payment schedule-satisfies sub-flow

After `Screen_Pick_Commitment`:

1. **`Get_Next_Unpaid_Schedule`** — SOQL `GiftCommitmentSchedule` where `GiftCommitmentId = rsv_SelectedCommitment.Id` AND `Status IN ('Scheduled','Pending','Overdue')`, ORDER BY `ScheduledDate ASC`, LIMIT 1 → `rsv_SelectedSchedule`.
2. **`Decide_HasUnpaidSchedule`** — is `rsv_SelectedSchedule.Id` populated?
   - **Yes** → `Screen_Confirm_Satisfies_Schedule` shows the next scheduled row (date + expected amount) and asks: *"Does this payment cover that scheduled installment (updates the schedule), or is it an extra payment (leaves the schedule alone)?"* — radio to `var_IsSatisfyingScheduledPayment`.
     - If satisfying → `Assign_Prefill_From_Schedule` sets `rsv_GiftTransaction.OriginalAmount / CurrentAmount = rsv_SelectedSchedule.ExpectedAmount`, `.TransactionDate = TODAY`, `.GiftCommitmentScheduleId = rsv_SelectedSchedule.Id`.
     - If extra → skip prefill; leave `GiftCommitmentScheduleId` null.
   - **No** → straight to `Screen_Gift_Details`, no prefill.

*(Actual API name for `GiftCommitmentSchedule.Status` and `.ExpectedAmount` needs confirmation against FundFirst before wiring — I'll check via describe when implementing.)*

### De-duplicated & simplified `Screen_Gift_Details`

**Remove entirely:**
- `numGiftAmount` (number)
- `numGiftAmount2` (currency)
- `dtGiftTransactionDate`
- `txtGiftPaymentMethod`
- `txtGiftPaymentMethod2`
- `txtGiftPaymentInstrument`
- `txt_Description_InKind` (replaced by ObjectProvided binding to `.Description`)

**Keep on screen (all `ObjectProvided` bound to `rsv_GiftTransaction` unless noted):**
- **Read-only context** (`DisplayText` — no input): commitment name (Pledge Payment only), campaign name, designation name — pulled from `rsv_Selected*` variables. So users see what got picked without another click.
- **Amount** — single `<inputField>` for `var_GiftAmount` (currency, required). Assignment fans it out to both `rsv_GiftTransaction.OriginalAmount` and `.CurrentAmount`.
- **Transaction Date** — required, defaults to today. Bound to `rsv_GiftTransaction.TransactionDate`.
- **Payment Method** — bound to `rsv_GiftTransaction.PaymentMethod`, hidden when `pkAskType = 'InKind'` (Assignment pre-sets it to `In-Kind` and the field never renders).
- **Payment Identifier** — bound to `rsv_GiftTransaction.PaymentIdentifier`, visible only when Payment Method is Check / Money Order / Wire (per §Per-type defaults below).
- **Description** — bound to `rsv_GiftTransaction.Description`, LargeTextArea, visible only when `pkAskType = 'InKind'` (label "Description of In-Kind Gift").

**Hidden entirely (set by Assignment, never rendered):**
- `TransactionDueDate` — defaulted to `TransactionDate`.
- `FQS_Gift_Transaction_Category__c`, `FQS_In_Kind__c`, `GiftCommitmentId`, `GiftCommitmentScheduleId`, `CampaignId`, `PaymentMethod` (for In-Kind), and any other type-specific defaults — see §Per-type defaults below.

### Per-type defaults (answers "what else should be defaulted?")

Defaulting rules per ask type — set in the Assignment nodes before `Screen_Gift_Details`, so the user only fills out what's genuinely their decision.

**Universal (all types):**
| Field | Default | Rationale |
|---|---|---|
| `TransactionDate` | `TODAY` | Recording live; user can adjust if backdating. |
| `TransactionDueDate` | `= TransactionDate` | For non-pledge transactions, "due" and "transaction" collapse. Never shown. |
| `Status` | `Paid` for Outright / In-Kind / Fee-for-Service / Pledge Payment. (Pledge branch creates a GiftCommitment, not a transaction.) | User just recorded a payment ⇒ Paid. |
| `GiftType` | `Individual` when `Get_Account.IsPersonAccount = true`; `Organizational` otherwise. Auto-derived in Assignment, **not shown on screen.** | No user decision needed. |
| `DonorId` | `recordId` | Already the case. |
| `AcknowledgementStatus` | `To Be Sent` (keep native default). | Consistent with FQS conventions. |
| `TaxReceiptStatus` | `To Be Sent` for Outright / In-Kind / Pledge Payment; `Don't Send` for Fee-for-Service. | Fee/Payment isn't tax-deductible. |
| `NonTaxDeductibleAmount` | `0` for Outright / Pledge Payment / In-Kind; `= OriginalAmount` for Fee-for-Service. | Fee/Payment is 100% non-deductible. In-Kind uses `TaxDeductionAmount` for FMV instead. |

**Outright Gift (`pkAskType = 'Outright'`):**
- `FQS_Gift_Transaction_Category__c = 'Outright Gift'`
- `FQS_In_Kind__c = false`
- No other overrides.

**In-Kind (`pkAskType = 'InKind'`):**
- `FQS_Gift_Transaction_Category__c = 'Outright Gift'` (per FQS convention)
- `FQS_In_Kind__c = true`
- `PaymentMethod = 'In-Kind'` — hidden on screen
- `PaymentIdentifier = null` — hidden on screen
- **On-screen field:** the same `Amount` input the other types use — for In-Kind the label context ("Recording a **InKind**...") makes clear this is the Fair Market Value.
- `NonTaxDeductibleAmount = 0` — all-or-nothing: the entire amount is tax-deductible. `TaxDeductionAmount` is a **calculated** field on the platform and computes to `OriginalAmount − NonTaxDeductibleAmount`, so putting FMV on `OriginalAmount` with `NonTaxDeductibleAmount = 0` yields `TaxDeductionAmount = FMV` automatically.
- `CurrentAmount` is also a **calculated** field — never written.
- `Description` stays on-screen (In-Kind description).

*Platform reality: `GiftTransaction.CurrentAmount` and `GiftTransaction.TaxDeductionAmount` are both calculated fields and cannot be written directly. The original plan of "OriginalAmount = 0, FMV on TaxDeductionAmount" wasn't possible; the implementation stores FMV on OriginalAmount and lets the calculated fields resolve. Currency fields also cannot be exposed via `ObjectProvided` bindings in v66, so `Amount` and Pledge `ExpectedTotalCmtAmount` are plain InputFields with Assignment fanout.*

**Fee-for-Service (`pkAskType = 'FeeForService'`):**
- `FQS_Gift_Transaction_Category__c = 'Fee/Payment'`
- `FQS_In_Kind__c = false`
- `NonTaxDeductibleAmount = OriginalAmount` (see universal table)
- `TaxReceiptStatus = 'Don't Send'`

**Pledge Payment (`pkAskType = 'PledgePayment'`):**
- `FQS_Gift_Transaction_Category__c = 'Pledge Payment'`
- `FQS_In_Kind__c = false`
- `GiftCommitmentId = rsv_SelectedCommitment.Id` (from picker)
- `GiftCommitmentScheduleId = rsv_SelectedSchedule.Id` if `var_IsSatisfyingScheduledPayment = true`, else `null`
- `CampaignId` — default to `rsv_SelectedCommitment.CampaignId` if the user didn't pick one on the Campaign screen (commitment-level attribution wins over blank).

**Pledge / new commitment (`pkAskType = 'Pledge'`):**
- `FQS_Gift_Commitment_Category__c = 'Pledged Gift'`
- `Status = 'Active'` (GiftCommitment picklist)
- `FulfillmentType` stays on screen as a user choice (`Unconditional` / `Conditional`, defaults `Unconditional`) — drives designation-picker behavior (see §Restriction handling).
- `FormalCommitmentType` stays on screen as a user choice (Written / Verbal).
- `EffectiveStartDate` stays on screen (defaults to today).

### Create nodes → `<inputReference>` pattern

**`Create_Gift_Transaction`** becomes:
```xml
<recordCreates>
    <name>Create_Gift_Transaction</name>
    <label>Create Gift Transaction</label>
    <inputReference>rsv_GiftTransaction</inputReference>
    <connector><targetReference>Decide_Create_Designation</targetReference></connector>
    <faultConnector><isGoTo>true</isGoTo><targetReference>Err_Create</targetReference></faultConnector>
</recordCreates>
```

Same shape for `Create_Pledge` using `rsv_GiftCommitment`.

Post-create designation nodes (`Create_GiftTransactionDesignation`, `Create_GiftDefaultDesignation`) build their record variable from `rsv_SelectedDesignation.Id` + the parent Id (from `Create_Gift_Transaction.Id` / `Create_Pledge.Id`) + 100% allocation.

---

## Files to touch

Just one: `force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml`.

No new custom fields required.

---

## Execution steps

1. Confirm this plan is right (this message).
2. Verify `GiftCommitmentSchedule` field API names for Status / ExpectedAmount via describe.
3. Rewrite the flow XML with:
   - New rule for `IsPledgePayment` in `Decide_Ask_Type`
   - `Screen_Pick_Commitment`, `Get_Next_Unpaid_Schedule`, `Decide_HasUnpaidSchedule`, `Screen_Confirm_Satisfies_Schedule`, `Assign_Prefill_From_Schedule`
   - `Screen_Pick_Campaign`, `Screen_Pick_Designation` on both transaction and pledge branches
   - New variables (`rsv_GiftCommitment`, `rsv_SelectedCommitment`, `rsv_SelectedSchedule`, `rsv_SelectedCampaign`, `rsv_SelectedDesignation`, `var_IsSatisfyingScheduledPayment`)
   - De-dupe `Screen_Gift_Details`
   - Convert both create nodes to `<inputReference>`
   - Add `Create_GiftTransactionDesignation` / `Create_GiftDefaultDesignation` post-create nodes with 100% allocation
4. Dry-run: `sf project deploy start --dry-run --source-dir force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml -o FundFirst`
5. Full deploy on success.
6. Manual walkthrough of all 5 branches in FundFirst.

---

## Open items to verify at implementation time

- `GiftCommitmentSchedule` field API names: `Status` picklist values (Scheduled? Pending? Overdue?) and the "expected amount" field name.
- Whether `flowruntime_lwc:datatable` in v66 supports the columns/filters we need, or if we need `dataTableSObjectColumns` variant.
- Whether the Contact→CampaignMember subquery works via SOQL in a `<recordLookups>` filter, or whether we need a Get Records → collection → filter pattern.

---

## Redesign — 2026-07-15 user notes

Feedback from the first deployed pass surfaced five structural issues. All five apply to Outright / In-Kind / Fee-for-Service / Pledge Payment (the "transaction" branches). The Pledge (commitment-creation) branch inherits the same subflow refactor for consistency, but keeps its existing Campaign/Restriction/Designation logic.

### R1. Gift Details screen moves to the front (of the transaction branches)

**Was:** Ask Type → Commitment picker (Pledge Payment only) → Campaign picker → Designation picker → Soft Credit picker → optional SC amount → Gift Details → Create.

**Now:** Ask Type → **Gift Details** → Commitment picker (Pledge Payment only) → Campaign picker → Designation picker (**conditionally**, see R3) → Soft Credit flow (**conditionally**, see R2 + R5) → Create.

The user enters the concrete gift facts first (Amount, TransactionDate, PaymentMethod, PaymentIdentifier, Description, and the soft-credit-yes/no toggle from R2), then makes the categorical/relational choices. Screens after Gift Details are all "route based on data" — never a required input on their own if defaults exist.

### R2. Soft credits become a routing question on the Gift Details screen

Add a `Yes/No` radio field `pkNeedsSoftCredits` **on the Gift Details screen**: "Add soft credits (recognize another donor for this gift)?" Default = No.

The screen already has room — it's the natural place to ask because the answer changes what happens next, and it lets us skip the soft-credit chain entirely in the common case.

- `pkNeedsSoftCredits = No` → skip Soft Credit picker AND skip the entire soft-credit lookup chain (see R5).
- `pkNeedsSoftCredits = Yes` → run the soft-credit lookup subflow (R5), show the Soft Credit Account picker, show the Full/Partial amount screen.

Drop the standalone `Screen_Pick_SoftCredit` recipient-question — the toggle on Gift Details replaces it. `Screen_Pick_SoftCredit` becomes the *Account picker* screen only (rendered only when the toggle is Yes).

### R3. Campaign default designation short-circuits the Designation picker

**Native shape:** `GiftDefaultDesignation` is polymorphic — its `ParentRecordId` accepts `Campaign`, `GiftCommitment`, and `Opportunity`. **No new custom field needed** — we already use this pattern for pledge default designations. Just query for children of the selected Campaign.

After the Campaign picker resolves `rsv_SelectedCampaign`, insert a new step:

1. `Get_Campaign_Default_Designations` (recordLookup) — `SELECT Id, DesignationId, AllocatedPercentage FROM GiftDefaultDesignation WHERE ParentRecordId = rsv_SelectedCampaign.Id AND DesignationId != null` (assigned as record, keep first only — single-slot flow).
2. `Decide_Campaign_Has_Default_Designation` — if the record was returned:
   - `Get_Campaign_Default_Designation_Detail` — fetch the `GiftDesignation` row → assign to `rsv_SelectedDesignation`. Skip `Screen_Pick_Designation` entirely.
   - Otherwise → proceed to `Screen_Pick_Designation` as today.

**No-Campaign path:** if the user skipped Campaign (allowed), fall through to Designation picker unchanged. The Campaign-provides-default short-circuit only fires when a Campaign is selected AND has at least one `GiftDefaultDesignation` child with a non-null `DesignationId`.

Analogous change applied to the **Pledge (commitment-creation) branch's Unconditional path**: it already queries `GiftDefaultDesignation` on the org's default `GiftDesignation` — no change needed there, but the Conditional path could optionally look at the Campaign's default before forcing Restriction selection. **Deferred** until the transaction-branch redesign is validated, to keep this pass tight.

### R4. Datatable escape-hatch becomes a checkbox toggle (fixes the `dtX.firstSelectedRow` reference error)

**Root cause of the error:** every datatable screen has an Assignment node after it that reads `dt<X>.firstSelectedRow`. Even when the user selects via the Lookup below the datatable (leaving the table with zero selections), the Assignment still fires and Flow rejects the unresolved reference. Guarding it behind a visibilityRule on the Assignment isn't possible — Assignments are unconditional. Guarding the reference itself with a Decide doesn't help — the reference is validated at flow-parse time.

**Fix:** on every picker screen, add a `chkUse<Object>Lookup` checkbox above the datatable: "None of the below <objects> match. Let me search for another existing <object>." Default = unchecked.

- Datatable is rendered only when the checkbox is **unchecked** (`visibilityRule` on the datatable field).
- Lookup is rendered only when the checkbox is **checked** (`visibilityRule` on the Lookup field).
- The follow-on Assignment is replaced by a `Decide_Use_<X>_Lookup` that branches:
  - checkbox unchecked → Assign `rsv_Selected<X> = dt<X>.firstSelectedRow` (safe: the datatable was rendered, so the reference resolves).
  - checkbox checked → Assign `rsv_Selected<X> = <lookupVar>` (via a Get Records on the lookup Id).

Applied to all four pickers: Commitment (Pledge Payment only), Campaign, Designation, Soft-Credit Account.

**Bonus:** the checkbox provides an unambiguous signal that the datatable is intentionally being bypassed, so validation can require *either* a table selection *or* a lookup value (not both, not neither) via a Decide re-prompt.

### R5. Soft-credit lookup chain moves to a subflow, called only when needed

The initial cascade on the current flow does — in order — Get_Account, Get_Account_Contacts, Loop_Collect_Contact_Ids, Get_CampaignMembers, Loop_Collect_Campaign_Ids, Get_Member_Campaigns, Get_Related_ACRs, Loop_Collect_ACR_Accounts, Get_Related_CCRs, Loop_Collect_CCR_Related_Contact_Ids, Get_CCR_Related_Contacts, Loop_Collect_CCR_Account_Ids, Get_SoftCredit_Accounts, then Screen_Choose_Type.

**Split:** the Contact + CampaignMember + Member Campaigns chain STAYS in the parent flow — the Campaign picker always needs it. The ACR + CCR + SoftCredit-Accounts chain (starting at `Get_Related_ACRs`) moves into a new subflow.

**New subflow:** `FQS_Gift_Entry_Soft_Credit_Reach` (invocable screen flow, no screens — just lookups + assignments returning a collection).

- **Inputs:** `recordId` (Account Id), `col_AccountContactIds` (String collection — the parent already computed this).
- **Outputs:** `col_SoftCreditAccountIds` (String collection of Account Ids), `outCollection_SoftCreditAccounts` (Account SObject collection for the datatable).
- **Body:** the 7 elements from `Get_Related_ACRs` through `Get_SoftCredit_Accounts`, verbatim.

**Parent flow call:** wrapped in a Decide that only invokes the subflow when the user opted in on Gift Details (`pkNeedsSoftCredits = Yes`). Skipping this saves ~7 SOQL calls on the common non-soft-credit case.

**Note:** the subflow is invoked *after* Gift Details, before the Soft Credit Account picker. Not at the top of the flow. This is the whole point — cost is paid only when needed.

### Screen order after redesign (transaction branches)

```
Start
 → Get_Account
 → Get_Account_Contacts
 → Loop_Collect_Contact_Ids
 → Get_CampaignMembers
 → Loop_Collect_Campaign_Ids
 → Get_Member_Campaigns
 → Screen_Choose_Type                       (ask type radio)
 → Decide_Ask_Type
      ├─ Pledge Payment → Screen_Pick_Commitment (with checkbox R4)
      │                   → Get_Commitment_Schedule
      │                   → Screen_Gift_Details
      └─ everything else → Screen_Gift_Details (new position — R1)
                                (Amount, Date, PaymentMethod, PaymentIdentifier, Description, chkNeedsSoftCredits — R2)
 → Screen_Pick_Campaign                     (checkbox R4)
 → Get_Campaign_Default_Designations        (new — R3)
 → Decide_Campaign_Has_Default_Designation
      ├─ Yes → Get_Campaign_Default_Designation_Detail → Assign_Designation_From_Campaign
      └─ No  → Screen_Pick_Designation      (checkbox R4)
 → Decide_Needs_Soft_Credits                (from chkNeedsSoftCredits on Gift Details)
      ├─ Yes → SUBFLOW: FQS_Gift_Entry_Soft_Credit_Reach
      │       → Screen_Pick_SoftCredit_Account (checkbox R4)
      │       → Screen_SoftCredit_Amount
      │       → Assignments...
      └─ No  → skip all three
 → Assign_Apply_Type_Defaults
 → Assign_Common_GiftType_And_Campaign
 → Assign_Fanout_Amount
 → Create_Gift_Transaction
 → Decide_Create_Designation → Create_GTDesignation
 → Decide_Create_SoftCredit  → Assign_Build_SoftCredit → Create_GiftSoftCredit
 → Screen_Success
```

Pledge (commitment-creation) branch keeps its existing shape but gets R4 (checkbox) applied to the Restriction and Designation pickers, and R5 (soft-credit subflow) if we later add soft credits to pledges — currently the Pledge branch doesn't offer soft credits, and this redesign doesn't change that.

### Impact on Section R1 — "screen order" combined with the checkbox pattern

Because Gift Details is now first, the checkbox on the Campaign picker means: if the user checks it and picks via Lookup, the follow-on `Get_Campaign_Default_Designations` still runs against `rsv_SelectedCampaign.Id` (whatever source), so R3's default-designation short-circuit works for both table selection and lookup selection.

### New / modified elements summary

| Kind | Name | Purpose |
|---|---|---|
| Screen field (add) | `chkUseCommitmentLookup`, `chkUseCampaignLookup`, `chkUseDesignationLookup`, `chkUseSoftCreditLookup` | R4 datatable / lookup toggle on each picker |
| Screen field (add) | `pkNeedsSoftCredits` (radio Yes/No) on Gift Details | R2 soft-credit routing |
| Decide (add) | `Decide_Use_Commitment_Lookup`, `Decide_Use_Campaign_Lookup`, `Decide_Use_Designation_Lookup`, `Decide_Use_SoftCredit_Lookup` | R4 route to correct source before Assign |
| Decide (add) | `Decide_Campaign_Has_Default_Designation` | R3 short-circuit Designation picker |
| Decide (add) | `Decide_Needs_Soft_Credits` | R2 skip subflow + SC screens when No |
| Record Lookup (add) | `Get_Campaign_Default_Designations` | R3 read child GiftDefaultDesignation |
| Record Lookup (add) | `Get_Campaign_Default_Designation_Detail` | R3 fetch GiftDesignation row for prefill |
| Subflow call (add) | `Sub_Soft_Credit_Reach` (invokes `FQS_Gift_Entry_Soft_Credit_Reach`) | R5 conditional invocation |
| New file | `force-app/main/default/flows/FQS_Gift_Entry_Soft_Credit_Reach.flow-meta.xml` | R5 subflow |
| Delete/repurpose | `Assign_Resolve_Commitment`, `Assign_Resolve_Campaign`, `Assign_Resolve_Designation`, `Assign_Resolve_SoftCredit` | R4 refactor — replaced by dual-path Decide + branch-specific Assign |
| Move | `Get_Related_ACRs`, `Loop_Collect_ACR_Accounts`, `Get_Related_CCRs`, `Loop_Collect_CCR_Related_Contact_Ids`, `Get_CCR_Related_Contacts`, `Loop_Collect_CCR_Account_Ids`, `Get_SoftCredit_Accounts` | R5 parent → subflow |
| Reorder | `Screen_Gift_Details` moves to position 2 of the transaction path | R1 |

### Verification checkpoints

- Deploy dry-run passes.
- Non-soft-credit flow (Outright, `pkNeedsSoftCredits = No`) never invokes the soft-credit subflow (verify via flow debug: no SOQL for ACRs/CCRs).
- Soft-credit flow (`pkNeedsSoftCredits = Yes`) invokes subflow once and surfaces same Accounts the current flow does.
- Campaign default-designation short-circuit skips Designation picker when a Campaign with a `GiftDefaultDesignation` child is selected, but still lets user see Designation picker when they skip Campaign.
- Checkbox-toggle Lookup path works on all 4 pickers without the `firstSelectedRow` reference error.
- Full deploy on FundFirst succeeds.
- Manual walkthrough: (a) Outright, no SC, no default desig → sees Campaign + Designation; (b) Outright, no SC, Campaign has default desig → skips Designation; (c) Outright with SC → subflow invoked, SC screens shown; (d) Pledge Payment with commitment lookup escape checkbox → resolves without `firstSelectedRow` error.
