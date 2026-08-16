# FQS Object Help Text — GC / GCS / GT

**Scope:** Manual pass for GiftCommitment (GC), GiftCommitmentSchedule (GCS), GiftTransaction (GT). Once these three land, the pattern becomes the `sf-help-text-author` skill.

**Sources:**
- On-flexipage field lists from the three FQS record-page flexipages
- Current field metadata under `force-app/main/default/objects/{GiftCommitment,GiftCommitmentSchedule,GiftTransaction}/fields/`
- `docs/nonprofit-cloud-developer-guide-v67.md` (Chapter 3 — Fundraising)

---

## Rules of the pass

- **Not every field earns help text.** Skip when the API name is a complete sentence, no automation writes it on a hidden trigger, no sibling-field interaction, and the value type is unambiguous.
- **Keep help text** when *any* of these are true: sibling-field interaction, non-obvious writer or trigger, domain-standard name with surprising values, calendar / fiscal / timezone / activation-timing ambiguity, or edit-safety concerns.
- **Restricted picklists:** enumerate legal values in `<description>` (admins see them in Object Manager). Do NOT enumerate them in `<inlineHelpText>` — end users see the values in the dropdown already. Help text names the *meaning* and *when to pick*.
- **Standard-field labels are not renamed.** FQS owns labels only on custom `__c` fields.
- **Voice:** user-set = task-oriented. System-set = "Set automatically." + writer + edit-safety.

## Fields deliberately skipped (not misses)

- **Self-descriptive rollups on GC:** `TotalPaidTransactionAmount`, `TransactionPaymentCount`, `LastPaidTransactionDate`.
- **Self-descriptive booleans on GT:** `IsFullyRefunded`, `IsPartiallyRefunded`, `IsWrittenOff`, `IsPaid`.
- **User-entered scalars with no automation:** `GT.CheckDate`.
- **Platform-labeled:** `GC.OwnerId`, `GT.OwnerId`.
- **Audit fields:** `CreatedById`, `CreatedDate`, `LastModifiedById`, `LastModifiedDate`.
- **Gateway plumbing not written by FQS in the starter and not surfaced on the flexipage:** `GT.LastGatewayProcessedDate`, `GT.LastGatewayResponseCode`, `GT.LastGatewayErrorMessage`, `GT.GatewayReference`, `GT.ProcessorReference`, `GCS.ProcessorReference`. Dev-guide entries are adequate on their own — surface these only when a real gateway integration lands.
- **Off-flexipage integration fields:** `GT.GatewayTransactionFee`, `GT.ProcessorTransactionFee`, `GCS.PaymentInstrumentId`, `GT.PaymentInstrumentId`, `GT.PartyPhilanthropicRsrchPrflId`. Defer until the corresponding capability ships.

## README post-install steps required

- `GC.CampaignId` lookup filter (leaf-level campaigns only)
- `GT.CampaignId` lookup filter (leaf-level campaigns only)

Unmanaged packages don't carry lookup filters — README must document them.

---

## 1. GiftCommitment (GC)

### GC.CampaignId — standard (📄 README lookup filter)
- **Help:** The campaign this commitment is attributed to. Only leaf-level campaigns are selectable — top-level campaigns and category branches are filtered out by design.
- **Description:** Lookup filter restricts to leaf-level campaigns. Roll-ups to parent campaigns happen automatically through Salesforce hierarchy features.

### GC.CurrentGiftCmtScheduleId — standard, platform-managed
- **Help:** Set automatically. The gift commitment schedule currently in force. The platform populates this when a schedule's Start Date is today or earlier. Records with a future Start Date leave this field blank until activation.
- **Description:** Platform-managed lookup. Populated by the Fundraising engine when a schedule's `StartDate` arrives (past-or-today), not at insert time. Do not back-fill in flows or Apex — that overrides the platform's active-vs-pending semantics and breaks reports that filter on `CurrentGiftCmtScheduleId != null` to identify actively giving commitments. See [[gc-current-schedule-activation]].

### GC.DonorId — standard
- **Help:** The person, household, or organization giving this commitment.
- **Description:** Polymorphic lookup — Account (Business, Household, or Person Account). Required. Use Person Account for named individuals; Household for couples / families giving jointly; Organization for corporate, foundation, or entity commitments.

### GC.EffectiveStartDate — standard
- **Help:** The date this commitment begins — usually the date the pledge, grant, or recurring gift was made. Payments before this date won't roll up as "current period" totals.
- **Description:** Anchors period rollups on `TotalCurrentMonth/Quarter/Year`. For back-dated pledges, set to the original commitment date, not today.

### GC.ExpectedEndDate — standard
- **Help:** The date this commitment is expected to be fully paid. For open-ended recurring gifts, leave blank. For fixed-length pledges and grants, set to the date of the final installment.
- **Description:** Fixed-length commitments should have this populated to drive lapse reporting; open-ended recurring gifts leave it blank. Not enforced by the platform — a fixed-length schedule with a null ExpectedEndDate won't error, just under-report.

### GC.ExpectedTotalCmtAmount — standard-extended
- **Help:** The total amount the donor has pledged, granted, or committed to give across the full life of this commitment.

### GC.TotCommitmentScheduleAmt — standard, rollup
- **Help:** Set automatically. Sum of the expected amount across every schedule attached to this commitment. Usually matches Expected Total Commitment Amount; a mismatch means a schedule was extended, shortened, or replaced.
- **Description:** Rollup maintained by the Fundraising engine. Not writable. Reconcile against `ExpectedTotalCmtAmount` when investigating pledge-balance discrepancies.

### GC.NextTransactionAmount / GC.NextTransactionDate — standard, system
- **Help:** Set automatically. The amount / date of the next expected payment on the active schedule. Blank until the schedule activates (Start Date is today or earlier).
- **Description:** System-maintained by the NPC engine from the active `GiftCommitmentSchedule`. Not writable. Blank until `CurrentGiftCmtScheduleId` is populated — see the activation-timing notes on that field.

### GC.EffectiveTransactionPeriod / GC.EffectiveTransactionInterval — standard, system
- **Help:** Set automatically. The cadence and interval of the schedule currently in force — for example, Interval `2` with Period `Monthly` means every 2 months.
- **Description:** System-maintained. Mirrors `TransactionPeriod` / `TransactionInterval` from the active schedule (`CurrentGiftCmtScheduleId`). Blank until activation.

### GC.WrittenOffAmount — standard, system
- **Help:** Set automatically. Total dollars written off across this commitment's gift transactions.
- **Description:** System-maintained. Not writable. Written-off amounts are excluded from Total Paid Transaction Amount.

### GC.TotalCurrentMonth / Quarter / Year / NextYear — standard, system
- **Help:** Set automatically. Total dollars paid against this commitment in the current calendar month / quarter / year (or the next calendar year for the projection field).
- **Description:** System-maintained. Not writable. Not fiscal-calendar-aware. ⚠ Verify calendar-vs-fiscal semantics against a seeded org before final copy — dev-guide doesn't specify.

### GC.Status — standard, restricted picklist
- **Help:** Where this commitment sits in its lifecycle — Active while donors are paying, Closed when fully paid, Paused / Failing / Lapsed for interruptions. Draft is for records not yet ready to receive payments.
- **Description:** Restricted picklist. Legal values: **Draft** (set up but not yet accepting payments — default), **Active** (accepting payments; schedule generating installments), **Failing** (recent payment attempts failed), **Lapsed** (donor stopped paying, past expected end), **Paused** (installment generation suspended — see child `GiftCommitmentSchedule.Type='PauseTransactions'`), **Closed** (fully paid or explicitly ended). Reports typically filter on `Status IN ('Active','Failing','Paused')` for the in-flight pipeline.

### GC.ScheduleType — standard-extended, platform-managed picklist
- **Help:** Leave blank for standard recurring gifts and pledges — the platform will fill this in from the schedule you attach. Set to *Custom* only when the schedule has irregular installment amounts or spacing (typical for grants).
- **Description:** Restricted picklist. Legal values: **Recurring** (platform fans out installments from `TransactionPeriod` + `TransactionInterval` + `TransactionDay`), **Custom** (irregular installments — each `GiftTransaction` must be inserted by hand). Platform-managed on Flow inserts (silently overrides to `Recurring` unless left blank). Apex can set `Custom` on insert explicitly. See [[fundfirst-custom-schedule-shape]].

### GC.RecurrenceType — standard-extended, restricted picklist
- **Help:** Choose *Fixed Length* for pledges, grants, and scheduled gifts with a defined end date. Choose *Open Ended* for recurring gifts with no end date — the donor gives on a regular cadence until they cancel.
- **Description:** Restricted picklist. Legal values: **Fixed Length**, **Open Ended**. Set explicitly by the launcher / seed generator; the platform does not derive this from the child schedule. Default: `Open Ended`.

### GC.FormalCommitmentType — standard-extended, restricted picklist
- **Help:** Choose *Written* if the commitment is documented in a signed pledge form, MOU, grant agreement, or similar artifact. Choose *Verbal* for commitments made in conversation without written documentation.
- **Description:** Restricted picklist. Legal values: **Verbal**, **Written**. Reporting-only in FQS — no automation branches on this field. Default: `Verbal`.

### GC.FulfillmentType — standard-extended, restricted picklist
- **Help:** Choose *Unconditional* when the committed funds are usable as soon as they arrive. Choose *Conditional* when the gift is contingent on specific milestones being met — typical for grants with reporting or programmatic conditions.
- **Description:** Restricted picklist. Legal values: **Unconditional**, **Conditional**. Reporting-only in FQS. Default: `Unconditional`.

### GC.LastNextGenCmtProcDtTm / LastNextGenCmtProcError — standard, system
- **Help:** Set automatically. The date/time (and, on the error field, the message) from the last run of the NextGen commitment processing job. Blank message means the last run succeeded.
- **Description:** Written by the platform's NextGen commitment processing job (API 67.0+). Not writable. If this stops updating on active commitments, investigate the scheduled job in Setup → Apex Jobs.

### GC.Name — standard, FQS auto-named
- **Help:** Set automatically by the FQS naming flow. Format: donor + gift type + primary campaign. To keep a specific Name from being overwritten — e.g., a name imported from another system — check *Skip Naming*.
- **Description:** Written by the `FQS_Auto_Name_Gift_Commitment` flow on insert and on relevant updates. Skipped when `FQS_Skip_Naming__c = TRUE`. Not enforced as unique.

### GC.OpportunityId — standard
- **Help:** The Opportunity representing this pledge or grant in your pipeline. Optional — most FQS orgs use Gift Commitment as the primary pledge record and skip Opportunity.
- **Description:** Populated when the FQS launcher's Opportunity path is taken. Blank Opportunity is the default for recurring-gift and outright-gift shapes.

### GC.Description — standard (free text)
- **Help:** Free-text notes about this commitment — background, contact history, contingencies, or anything a fundraiser landing on this record should know. Not used by any automation.

### GC custom fields

- **GC.FQS_Gift_Commitment_Category__c** — restricted picklist, custom, `Gift Commitment Category`
  - **Help:** Classifies the type of commitment this record represents. Choose *Pledged Gift* for a one-time promise paid over time, *Recurring Gift* for an ongoing donation cadence, *Grant Payout* for foundation or institutional grant disbursements.
  - **Description:** Restricted picklist. Legal values: **Pledged Gift**, **Recurring Gift**, **Grant Payout**. Set by the FQS Gift Entry launcher based on the branch chosen. Not written by platform automation.

- **GC.FQS_Is_Entry_Commitment__c / FQS_Is_Mid_Commitment__c / FQS_Is_Major_Commitment__c** — formula, custom
  - **Help:** Set automatically. Checked when this commitment's total expected amount falls in the corresponding donor grouping. Your administrator controls the threshold through the FQS Setup flow.
  - **Description:** Boolean formula reading the FQS Donor Grouping CMDT thresholds. Configure via Setup → Custom Metadata Types or the FQS Setup flow → Configure Donor Groupings.

- **GC.FQS_Match_Eligible__c** — boolean, custom, `Match Eligible`
  - **Help:** Set to true if a corporate matching gift is expected against this commitment. The Gift Entry launcher reads this to default the match question on payments recorded against this commitment.

- **GC.FQS_Restriction_Release_Date__c** — date, custom, `Restriction Release Date`
  - **Help:** The date restricted funds from this commitment become available for their designated purpose or for general use. Leave blank for gifts with no time restriction.
  - **Description:** Convention: one year past the final installment date for multi-year and custom-schedule grants. Populated automatically by FQSSeedGenerator on grant-multiyear and grant-custom shapes; manually editable for real gifts.

- **GC.FQS_Summary__c** — formula, custom, `Summary`
  - **Help:** Set automatically. A one-sentence plain-English summary of this commitment's schedule — cadence, amount, and start. Updates as the underlying schedule changes.
  - **Description:** Assembled from platform-managed schedule fields with a failsafe for pre-activation commitments — when `ScheduleType` is set but `CurrentGiftCmtScheduleId` is null, returns "Schedule starts in the future."

- **GC.External_Id__c** — text, custom (off-flexipage), `External ID`
  - **Help:** External identifier used by FQS seed scripts for idempotent upserts and teardown. Not required for real gifts.
  - **Description:** Pattern used by seed scripts: `FQS-<OBJ>-<idx>[-<subidx>]`. Not unique at the platform level.

- **GC.FQS_Skip_Naming__c** — boolean, custom (off-flexipage), `Skip Auto-Naming`
  - **Help:** Check to prevent the FQS auto-naming flow from overwriting the Name on this Gift Commitment. Use for imports or integrations where the record already carries an authoritative external Name.

---

## 2. GiftCommitmentSchedule (GCS)

### GCS.GiftCommitmentId — standard
- **Help:** The parent commitment this schedule belongs to. Required — every schedule must belong to a commitment.
- **Description:** A commitment can have multiple schedules over time (pause/resume/edit), but only one is active at a time (see parent's `CurrentGiftCmtScheduleId`).

### GCS.CampaignId — standard
- **Help:** The campaign this schedule's payments are attributed to. Typically matches the parent commitment's campaign. Gift transactions fanned out from this schedule inherit this campaign.
- **Description:** Read by the NPC engine on installment fan-out — each generated `GiftTransaction.CampaignId` inherits this value. Change here does not retro-update already-created installments.

### GCS.StartDate — standard
- **Help:** The date this schedule becomes active. Payments won't post before this date, and the parent commitment's "next payment" fields stay blank until it arrives.
- **Description:** Required. Also drives `GC.CurrentGiftCmtScheduleId` activation — the parent GC's active-schedule lookup populates when StartDate ≤ today. See [[gc-current-schedule-activation]].

### GCS.EndDate — standard
- **Help:** The date this schedule stops generating payments. For open-ended recurring schedules, leave blank. For fixed-length schedules, set to the final installment date.
- **Description:** Combined with `StartDate`, `TransactionPeriod`, and `TransactionInterval` to fan out Expected `GiftTransaction` rows.

### GCS.TransactionAmount — standard
- **Help:** The amount paid per installment. For example, a $2,000 pledge paid four times a year has a transaction amount of $500.
- **Description:** Per-installment amount. Combined with `TransactionPeriod` + `TransactionInterval` to fan out Expected `GiftTransaction` rows. Required.

### GCS.TotalScheduleAmount — standard
- **Help:** The total dollars expected across every installment on this schedule (Transaction Amount × number of installments).
- **Description:** For fixed-length schedules, equal to `TransactionAmount × installment count`. For open-ended recurring gifts, blank or projected.

### GCS.TransactionPeriod — standard, restricted picklist
- **Help:** Choose the cadence for this schedule's installments. For grants and pledges with irregular payment amounts or spacing, choose *Custom* — you'll enter each installment as its own gift transaction.
- **Description:** Restricted picklist. Legal values: **Daily**, **Weekly**, **Monthly**, **Yearly** (platform fans out Expected `GiftTransaction` rows), **Custom** (disables engine fanout — each installment inserted independently). `Custom` requires parent `GiftCommitment.ScheduleType='Custom'` and this row's `Type='CreateTransactions'`. Required. See [[fundfirst-custom-schedule-shape]].

### GCS.TransactionInterval — standard
- **Help:** How many periods between payments. Combined with Transaction Period — for example, Period=Monthly + Interval=2 means every 2 months; Period=Weekly + Interval=1 means every week.
- **Description:** Required for `Recurring` schedules. Ignored on `Custom` schedules.

### GCS.TransactionDay — standard, restricted picklist
- **Help:** The day of the month payments post on. For payments due at the end of the month, choose *LastDay* — this handles February and other short months automatically. Days 29, 30, and 31 aren't selectable; use LastDay instead.
- **Description:** Restricted picklist. Legal values: **'1'..'28'** and **'LastDay'**. Values 29–31 are rejected with `INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`. Required when `TransactionPeriod = 'Monthly'` or `'Yearly'`. Set to `DAY(StartDate)` on seed to avoid monthly-drift to day 1.

### GCS.Type — standard, restricted picklist
- **Help:** Choose *Create Transactions* for a schedule that generates gift transactions as installments come due. Choose *Pause Transactions* to suspend installment generation temporarily — the schedule stays attached but stops producing new gifts.
- **Description:** Restricted picklist. Legal values: **CreateTransactions** (normal), **PauseTransactions** (suspended without deleting the schedule). Used by the managed `frops_flow__PauseResumeSchedule` action to pause / resume without deleting schedule history. Default: `CreateTransactions`.

### GCS.PaymentMethod — standard, restricted picklist
- **Help:** The payment channel used to collect installments on this schedule. Cascades to each installment gift transaction.
- **Description:** Restricted picklist. Legal values: **Cash**, **Check**, **Credit Card**, **ACH**, **PayPal**, **Venmo**, **Cryptocurrency**, **Stock**, **Asset**, **In-Kind**, **Unknown**. Cascades to fanned-out `GiftTransaction.PaymentMethod`. Change here does not retro-update installments already created.

### GCS.CommitmentUpdateReason — standard, restricted picklist
- **Help:** The reason this schedule or commitment was last changed. Use *Payment Method Declined* when the last payment couldn't be processed. Use *Financial Hardship* when the donor requested the change because of their financial circumstances.
- **Description:** Restricted picklist. Legal values: **Payment Method Declined**, **Financial Hardship**. Populated by the schedule edit / pause / resume flows; manual override allowed. Reporting-only.

### GCS.GiftCommitmentStatus — standard, system mirror
- **Help:** Set automatically. Mirrors the parent commitment's Status so schedule-level reports don't need to cross-join back to the commitment.
- **Description:** Restricted picklist mirror of `GC.Status`. Read-only on the schedule; edit at the parent commitment level.

### GCS.GiftCommitmentSchdBefEditId — standard, system
- **Help:** Set automatically. Points to the previous version of this schedule when an admin used the Pause / Resume / Edit Schedule action.
- **Description:** Written by the managed `frops_flow__PauseResumeSchedule` and edit flows. Useful for reconstructing schedule change history.

### GCS.OutreachSourceCodeId — standard
- **Help:** The appeal, event, or channel that generated this schedule. Cascades to each installment gift transaction.
- **Description:** Cascades to fanned-out `GiftTransaction.OutreachSourceCodeId`. Change here does not retro-update installments. When populated, must be a child of the schedule's Campaign.

### GCS.Name — standard, autonumber
- **Help:** Set automatically. Auto-numbered by the platform.

### GCS custom fields

- **GCS.External_Id__c** — text, custom (off-flexipage), `External ID`
  - **Help:** External identifier used by FQS seed scripts for idempotent upserts and teardown. Not required for real gifts.
  - **Description:** Pattern: `FQS-<OBJ>-<idx>[-<subidx>]`. Not unique at the platform level — see [[gcs-external-id-nonunique]] for why managed-package schedule-cloning flows require this.

---

## 3. GiftTransaction (GT)

### GT.CampaignId — standard (📄 README lookup filter)
- **Help:** The campaign this gift is attributed to. Only leaf-level campaigns are selectable — the lookup filter blocks top-level and category-branch campaigns by design.
- **Description:** Lookup filter restricts to leaf-level campaigns. On pledge / recurring payments, inherits from the parent `GiftCommitmentSchedule`. Reports roll to parent campaigns via hierarchy.

### GT.DonorId — standard
- **Help:** The person, household, or organization who gave this gift.
- **Description:** Polymorphic lookup — Account (Business / Household / Person). Required. For pledge payments, usually inherits from the parent commitment's donor.

### GT.GiftCommitmentId / GiftCommitmentScheduleId — standard
- **Help:** The pledge/grant/recurring commitment (and specific installment) this payment is applied against. Blank for outright one-time gifts.
- **Description:** Populated on Pledge Payment, Recurring Payment, and Grant Payment launcher branches. Used by the NPC engine to reconcile Expected vs Paid installments. See [[processgiftcommitment-multi-gcs-fanout]].

### GT.OriginalAmount — standard
- **Help:** The full gift amount as originally recorded. For refunds or adjustments, don't change this — record a Gift Refund instead.
- **Description:** Includes donor cover, excludes gateway/processor fees. Required. Once posted, treat as immutable — reductions flow through GiftRefund children so `CurrentAmount` recalculates.

### GT.CurrentAmount — standard, system
- **Help:** Set automatically. The gift amount remaining after any refunds or adjustments. Equals the Original Amount unless a Gift Refund has been posted.
- **Description:** Not writable via API or Apex — attempting to set returns `INVALID_FIELD_FOR_INSERT_UPDATE`. To reduce, insert a GiftRefund child instead of mutating this field.

### GT.RefundedAmount — standard, system
- **Help:** Set automatically. Total dollars refunded on this gift across all Gift Refund records.
- **Description:** Rollup of child `GiftRefund` records. Not writable.

### GT.DonorCoverAmount — standard
- **Help:** The extra amount the donor chose to add to cover processing fees. Included in the Original Amount total.
- **Description:** Donor-elected fee coverage. Reporting-only in the FQS starter. Not automatically applied to `NonTaxDeductibleAmount`.

### GT.TotalTransactionFee — standard, system
- **Help:** Set automatically. Total gateway + processor fees deducted from this transaction.
- **Description:** Sum of `GatewayTransactionFee` + `ProcessorTransactionFee` (off-flexipage). Blank for check/cash gifts.

### GT.TaxDeductionAmount — standard
- **Help:** The portion of this gift the donor can claim as a tax deduction. For most cash gifts, equal to the Original Amount. For in-kind gifts or gifts with benefits received, enter the deductible portion here.
- **Description:** Manual field. Blank means "assume full deduction" for receipting purposes. For in-kind gifts, work with `FQS_Fair_Market_Value_Amount__c` — legal deduction determination is the donor's responsibility.

### GT.NonTaxDeductibleAmount — standard
- **Help:** The portion of this gift the donor cannot deduct — e.g., the fair-market value of event tickets, dinners, or benefits received in exchange for the gift.
- **Description:** Quid-pro-quo tracking. When populated, `TaxDeductionAmount` should equal `OriginalAmount − NonTaxDeductibleAmount`. Not auto-computed.

### GT.TransactionDate — standard
- **Help:** The date the donor made this gift — check date, credit-card charge date, or the date the wire hit. Required when Status is Paid or Fully Refunded.
- **Description:** For pledge payments, this is the *payment* date, not the pledge date (which lives on the parent commitment's `EffectiveStartDate`). Distinct from `FQS_Processed_Date__c` (when the org entered the gift).

### GT.TransactionDueDate — standard
- **Help:** The date this gift was expected. For a one-time gift you're recording now, set the same date as Transaction Date. For a pledge or recurring payment, this matches the installment's scheduled due date.
- **Description:** Required on insert even for gifts in Paid status. For outright gifts, set equal to `TransactionDate`. For pledge payments, match the parent `GiftCommitmentSchedule` installment row.

### GT.Status — standard, restricted picklist
- **Help:** Where this gift is in its collection lifecycle. Choose *Paid* when the money is in hand, *Pending* for gifts you've recorded but not yet received, *Failed* if the payment attempt failed. Written-Off marks a receivable your org has given up collecting.
- **Description:** Restricted picklist. Legal values: **Unpaid** (default), **Pending**, **Paid**, **Failed**, **Canceled**, **Fully Refunded**, **Written-Off**. Platform fan-out from schedule sets `Status='Expected'` — see [[gt-expected-status-default]]. FQS Gift Entry launcher defaults to `Paid` for retroactive data entry — see [[gt-status-default-paid]]. Direct-writing `Paid` on insert bypasses normal payment posting; use for seed/test only.

### GT.AcknowledgementStatus — standard, restricted picklist
- **Help:** Where the thank-you for this gift is in its lifecycle. Set to *Don't Send* to suppress the automated acknowledgement — useful for anonymous donations or when acknowledgement was handled outside Salesforce.
- **Description:** Restricted picklist. Legal values: **To Be Sent** (default; queued for the daily FQS Gift Acknowledgement flow), **Sent** (stamps `AcknowledgementDate`), **Don't Send**. Written by the `FQS_Gift_Acknowledgement` flow. Clearing back to `To Be Sent` re-queues on next daily run.

### GT.AcknowledgementDate — standard
- **Help:** The date the donor was thanked for this gift. Set automatically by the FQS Gift Acknowledgement flow when the thank-you email is sent; enter manually if the acknowledgement was sent outside Salesforce.
- **Description:** Written by the `FQS_Gift_Acknowledgement` flow when `AcknowledgementStatus` flips to `Sent`. Manual override allowed.

### GT.TaxReceiptStatus — standard, restricted picklist
- **Help:** Where the tax receipt for this gift is in its lifecycle. Set to *Don't Send* for gifts that shouldn't receive a receipt — for example, non-deductible payments like event tickets billed at fair market value.
- **Description:** Restricted picklist. Legal values: **To Be Sent** (default), **Sent** (stamps `FQS_Tax_Receipt_Date__c`), **Don't Send**. Available from API 62.0+. Year-end receipting is out of scope for FQS automation — status is manually set today.

### GT.GiftType — standard, restricted picklist
- **Help:** Whether this is an individual donor's gift or an organizational gift. Individual covers person and household donors; Organizational covers business and foundation donors.
- **Description:** Restricted picklist. Legal values: **Individual**, **Organizational**. Set explicitly on insert; not derived from `DonorId`. Default: `Individual`. Drives the Matching Employer Transactions related list visibility (shown only when `Individual` AND `FQS_Matched__c = TRUE`).

### GT.PaymentMethod — standard, restricted picklist
- **Help:** The payment channel used for this gift.
- **Description:** Restricted picklist. Legal values: **Cash**, **Check**, **Credit Card**, **ACH**, **PayPal**, **Venmo**, **Cryptocurrency**, **Stock**, **Asset**, **In-Kind**, **Unknown**. Required. Drives visibility of downstream fields (`CheckDate` for check gifts; `FQS_Fair_Market_Value_Amount__c` for `In-Kind`). On pledge / recurring payments, inherits from the parent schedule.

### GT.PaymentIdentifier — standard
- **Help:** The reference number for the payment channel — check number, wire confirmation number, or merchant order number. Useful for reconciliation.
- **Description:** Free-text. Common patterns: check number for checks, transaction ID for card / ACH, wire confirmation for wire transfers, order number for gateway transactions.

### GT.OutreachSourceCodeId — standard
- **Help:** The appeal, event, or channel that generated this gift. Must belong to the Campaign selected on this record.
- **Description:** When populated, the OSC's parent Campaign must equal this transaction's CampaignId — mismatched values fail with "Select an Outreach Source Code that's part of this Campaign."

### GT.MatchingEmployerTransactionId — standard
- **Help:** Points to the matching gift transaction from the donor's employer. Populate when you record an employer match for this gift.
- **Description:** Self-referential lookup — points to another `GiftTransaction` (the employer's matching gift). Drives the Matching Employer Transactions related list when `FQS_Matched__c = TRUE`.

### GT.Name — standard, FQS auto-named
- **Help:** Set automatically by the FQS naming flow. Format: donor + amount + date + gift kind. To keep a specific Name from being overwritten — e.g., a name imported from another system — check *Skip Naming*.
- **Description:** Written by the `FQS_Auto_Name_Gift_Transaction` flow on insert and on relevant updates. Skipped when `FQS_Skip_Naming__c = TRUE`.

### GT.Description — standard (free text)
- **Help:** Free-text notes about this gift — payment context, reconciliation notes, or anything a fundraiser landing on this record should know. Not used by any automation.

### GT custom fields

- **GT.FQS_Gift_Transaction_Category__c** — restricted picklist, custom, `Gift Transaction Category`
  - **Help:** Classifies what kind of transaction this record represents. *Outright Gift* is a one-time gift not tied to a commitment; *Pledge Payment*, *Recurring Gift Payment*, and *Grant Payment* are installments against a commitment; *Other* covers earned income, event registrations, and service fees.
  - **Description:** Restricted picklist. Legal values: **Outright Gift**, **Pledge Payment**, **Recurring Gift Payment**, **Grant Payment**, **Other**. Set by the FQS Gift Entry launcher. `Other` excludes the transaction from acknowledgement and stewardship flows.

- **GT.FQS_Is_Entry_Gift__c / FQS_Is_Mid_Gift__c / FQS_Is_Major_Gift__c** — formula, custom
  - **Help:** Set automatically. Checked when this gift's amount qualifies for the corresponding donor grouping — either by its own amount, or (for installments) by inheriting from the parent commitment's band.
  - **Description:** Boolean formula. `TRUE` when the gift lands in the tier by its own `CurrentAmount` or via the parent GC. Drives stewardship-flow routing — see `docs/gift-stewardship-flow.md`.

- **GT.FQS_In_Kind__c** — boolean, custom, `In-Kind`
  - **Help:** Check when this gift is a non-cash contribution — goods, services, or property. In-kind gifts use `OriginalAmount = 0` (they don't count toward cash rollups) and record the estimated value on `Fair Market Value Amount`. Salesforce automation routes off this flag: the in-kind self-recognition soft credit, receipt handling, and reporting all key on it. Distinct from `PaymentMethod` (which may be In-Kind, Stock, or Asset for various non-cash channels) — this flag is the authoritative "treat as non-cash" signal.
  - **Description:** Deterministic gate — TRUE marks this transaction as non-cash. Load-bearing routing key across the Gift Entry launcher and Apex: drives the `OriginalAmount=0` / FMV-on-`FQS_Fair_Market_Value_Amount__c` convention, the auto-generated `GiftSoftCredit` with `Role='In-Kind Recognition'` pointing at the donor, record-page conditional visibility, and seed-data classification. Retained as a boolean instead of collapsed onto `PaymentMethod='In-Kind'` because PaymentMethod is a shared picklist (Stock, Asset, In-Kind, etc.) that carries no single deterministic "treat this as non-cash" signal — Stock and Asset gifts can be cash-equivalent or non-cash depending on liquidation, and users have latitude to key values inconsistently. This boolean is the org's authoritative in-kind flag.

- **GT.FQS_Fair_Market_Value_Amount__c** — currency, custom, `Fair Market Value Amount`
  - **Help:** Estimated fair market value of the donated goods or services. Used for the tax receipt and reporting only — the donor determines the actual tax-deductible value on their own return.
  - **Description:** For in-kind gifts the FQS convention is: `OriginalAmount = 0`, this field carries the estimate. Blank on non-in-kind gifts.

- **GT.FQS_Matched__c** — boolean, custom, `Matched`
  - **Help:** Check this box when this gift has been matched by the donor's employer or a third party. When checked (and the gift is from an individual), the Matching Employer Transactions related list appears on the record page.
  - **Description:** Pairs with `MatchingEmployerTransactionId` — this flag marks the donor's original gift; the lookup points to the employer's matching gift.

- **GT.FQS_Processed_Date__c** — date, custom, `Processed Date`
  - **Help:** Date the org keyed this gift into Salesforce. Defaults to today. Different from the Gift Date, which is when the donor originally sent the gift.
  - **Description:** Set by the FQS Gift Entry Single Launcher; defaults to today. Used for cash-flow and reconciliation reporting.

- **GT.FQS_Restriction_Release_Date__c** — date, custom, `Restriction Release Date`
  - **Help:** The date restricted funds from this payment become available for their designated purpose or for general use. Leave blank for gifts with no time restriction.
  - **Description:** Convention: one year past this transaction's date. On a payment against a commitment, defaults from the parent commitment but is independently writable. See [[seed-release-date-followup]].

- **GT.FQS_Stewardship_Status__c** — restricted picklist, custom, `Stewardship Status`
  - **Help:** Where the follow-up stewardship touch for this gift is in its lifecycle. Set to *Don't Send* to suppress automated stewardship — for example, when the donor has requested no further contact.
  - **Description:** Restricted picklist. Legal values: **To Be Sent**, **Sent** (stamps `FQS_Stewardship_Date__c`), **Don't Send**. Default: blank ("not yet queued"). Written by the `FQS_Stewardship_Response` flow. See `docs/gift-stewardship-flow.md`.

- **GT.FQS_Stewardship_Date__c** — date, custom, `Stewardship Date`
  - **Help:** Date the follow-up stewardship email or task was delivered. Set automatically by the flow, or manually if stewardship occurred outside Salesforce.
  - **Description:** Written by the `FQS_Stewardship_Response` flow when `FQS_Stewardship_Status__c` flips to `Sent`.

- **GT.FQS_Tax_Receipt_Date__c** — date, custom, `Tax Receipt Date`
  - **Help:** Date this gift's tax receipt was issued to the donor. Enter manually or via a bulk update after your annual tax-receipt run.
  - **Description:** Manual field — year-end tax receipting is out of scope for FQS automation. Distinct from `AcknowledgementDate` (per-gift thank-you) and `FQS_Stewardship_Date__c` (relationship touch).

- **GT.FQS_Recurring__c** — boolean, custom (off-flexipage), `Recurring`
  - **Help:** Set automatically. Marks this transaction as an installment against a recurring gift commitment.
  - **Description:** Set by the launcher when the branch is Recurring Gift Payment; distinct from `FQS_Gift_Transaction_Category__c` for reporting convenience.

- **GT.External_Id__c** — text, custom (off-flexipage), `External ID`
  - **Help:** External identifier used by FQS seed scripts for idempotent upserts and teardown. Not required for real gifts.
  - **Description:** Pattern: `FQS-<OBJ>-<idx>[-<subidx>]`. Not unique at the platform level.

- **GT.FQS_Skip_Naming__c** — boolean, custom, `Skip Auto-Naming`
  - **Help:** Check to prevent the FQS auto-naming flow from overwriting the Name on this Gift Transaction. Use for imports or integrations where the record already carries an authoritative external Name.

---

## Open follow-ups

- Calendar vs. fiscal semantics on `GC.TotalCurrentMonth/Quarter/Year/NextYear` — verify against a seeded org before final copy.
- `GT.GenerationalCohort` off-flexipage — surface only if generational segmentation is in use; deferred with the wealth-screening capability.

## Next steps

1. Emit metadata edits — add `<inlineHelpText>` and `<description>` in each field's `.field-meta.xml`. Create files for standard fields not yet customized.
2. Emit README post-install steps for the two 📄 lookup filters on `CampaignId`.
3. Extract `sf-help-text-author` skill and fan out to remaining Key + Supporting + Background objects.
