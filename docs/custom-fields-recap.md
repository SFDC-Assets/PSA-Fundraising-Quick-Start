# FQS Custom Fields Recap

Object-by-object recap of the custom fields (`__c`) added by the Fundraising Quick Start project, across the standard objects and custom metadata types it extends.

> **NOTE (2026-08-02):** The GiftTransaction, GiftCommitment, GiftEntry sections and totals in this doc lag reality — several fields (stewardship, tax dates, match lifecycle, GiftEntry staging mirrors, and more) have been added over multiple sessions without back-filling the summary tables. Treat the field-by-field help text / admin description tables further down as authoritative for the fields they cover, and the object folders under `force-app/main/default/objects/` as the true source of truth. A full recap rewrite is a separate cleanup pass.

---

## Standard objects (extended with FQS fields)

### Account (1)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), unique, external ID | Seed-script upsert key. |

### Campaign (2)
| API Name | Type | Notes |
|---|---|---|
| `FQS_Campaign_Category__c` | restricted Picklist | Values: Fundraising Top Level Campaign, Annual Giving, Events, Corporate Match, In-Kind, Major Gifts, Planned Giving, Grants. Drives list-view segmentation. |
| `External_Id__c` | Text(64), external ID | |

### Opportunity (4) — grants pipeline
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |
| `FQS_Grant_Deadline__c` | Date | Application/report submission deadline (distinct from `CloseDate` = award decision). |
| `FQS_Grant_Report_Due__c` | Date | Post-award report due date. |
| `FQS_Solicitation_Date__c` | Date | Major-gift formal-ask date. |

---

## Fundraising standard objects (Nonprofit Cloud)

### GiftTransaction (8)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |
| `FQS_Gift_Transaction_Category__c` | restricted Picklist | Values: Outright Gift, Pledge Payment, Recurring Gift Payment, Grant Payment, Other. |
| `FQS_In_Kind__c` | Checkbox | Non-cash gift flag. |
| `FQS_Matched__c` | Checkbox | Employer/third-party match indicator; drives conditional related list. |
| `FQS_Recurring__c` | Checkbox | Recurring-series membership. |
| `FQS_Is_Entry_Gift__c` | Checkbox formula | TRUE when `CurrentAmount` ≥ `Entry.One_Time_Min_Amount__c` OR parent `GiftCommitment.ExpectedTotalCmtAmount` ≥ `Entry.Lifetime_Min_Amount__c` (installment inheritance). |
| `FQS_Is_Mid_Gift__c` | Checkbox formula | Same shape at the Mid tier. |
| `FQS_Is_Major_Gift__c` | Checkbox formula | Same shape at the Major tier. |

### GiftCommitment (5)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |
| `FQS_Gift_Commitment_Category__c` | restricted Picklist | Values: Pledged Gift, Recurring Gift, Grant Payout. |
| `FQS_Is_Entry_Commitment__c` | Checkbox formula | `ExpectedTotalCmtAmount` ≥ `Entry.Lifetime_Min_Amount__c`. |
| `FQS_Is_Mid_Commitment__c` | Checkbox formula | Same shape at the Mid tier. |
| `FQS_Is_Major_Commitment__c` | Checkbox formula | Same shape at the Major tier. |

### GiftCommitmentSchedule (1)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |

### GiftDesignation (2)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |
| `FQS_Restriction_Type__c` | restricted Picklist | FASB ASU 2016-14 net-asset classes: Without Donor Restriction; With Donor Restriction — Purpose / Time / Permanent. |

### GiftDefaultDesignation (2)
| API Name | Type | Notes |
|---|---|---|
| `FQS_Parent_Type__c` | Text formula | Returns `GiftCommitment` / `Opportunity` / `Campaign` from the polymorphic `ParentRecordId` prefix. |
| `FQS_Restriction_Type__c` | Text formula | Mirrors `GiftDesignation.FQS_Restriction_Type__c`. |

### GiftTransactionDesignation (2)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |
| `FQS_Restriction_Type__c` | Text formula | Mirrors `GiftDesignation.FQS_Restriction_Type__c`. |

### GiftRefund (1)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |

### GiftSoftCredit (1)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |

### GiftTribute (1)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |

### DonorGiftSummary (10) — all formula fields; recalc retroactively when CMDT thresholds change
| API Name | Type | Notes |
|---|---|---|
| `FQS_Annual_Donor_Level__c` | Text formula | Returns `Entry` / `Mid` / `Major` / `""` from `GiftsThisYearAmount` vs. `Annual_Min_Amount__c`. |
| `FQS_Annual_Donor_Level_Name__c` | Text formula | Same tiers, returning branded names. |
| `FQS_Lifetime_Donor_Level__c` | Text formula | Same shape, evaluated against `Lifetime_Min_Amount__c`. |
| `FQS_Lifetime_Donor_Level_Name__c` | Text formula | Branded lifetime version. |
| `FQS_Is_Entry_Annual_Donor__c` | Checkbox formula | vs. `Entry.Annual_Min_Amount__c`. |
| `FQS_Is_Mid_Annual_Donor__c` | Checkbox formula | vs. `Mid.Annual_Min_Amount__c`. |
| `FQS_Is_Major_Annual_Donor__c` | Checkbox formula | vs. `Major.Annual_Min_Amount__c`. |
| `FQS_Is_Entry_Lifetime_Donor__c` | Checkbox formula | vs. `Entry.Lifetime_Min_Amount__c`. |
| `FQS_Is_Mid_Lifetime_Donor__c` | Checkbox formula | vs. `Mid.Lifetime_Min_Amount__c`. |
| `FQS_Is_Major_Lifetime_Donor__c` | Checkbox formula | vs. `Major.Lifetime_Min_Amount__c`. |

### OutreachSourceCode (2)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |
| `FQS_Message_Channel_Segment__c` | Text formula | Groups `MessageChannel` picklist into Organic / Paid Digital / Owned or Acquired Lists. |

### PaymentInstrument (1)
| API Name | Type | Notes |
|---|---|---|
| `External_Id__c` | Text(64), external ID | |

---

## Custom metadata type

### FQS_Donor_Grouping__mdt (6) — admin-tunable thresholds referenced by every donor-tier formula
| API Name | Type | Notes |
|---|---|---|
| `Grouping_Key__c` | restricted Picklist | Values: Entry, Mid, Major. |
| `Branded_Name__c` | Text(255) | Donor-facing tier name. |
| `Sort_Order__c` | Number(3,0) | Display-order only; does not affect formula evaluation. |
| `Annual_Min_Amount__c` | Number(18,2) | Fiscal-year threshold. |
| `Lifetime_Min_Amount__c` | Number(18,2) | Lifetime threshold (also used by commitment formulas + installment inheritance). |
| `One_Time_Min_Amount__c` | Number(18,2) | Single-transaction threshold. |

---

## Summary counts

| Object | Count |
|---|---:|
| GiftTransaction | 8 |
| DonorGiftSummary | 10 |
| FQS_Donor_Grouping__mdt | 6 |
| GiftCommitment | 5 |
| Opportunity | 4 |
| Campaign, GiftDefaultDesignation, GiftDesignation, GiftTransactionDesignation, OutreachSourceCode | 2 each |
| Account, GiftCommitmentSchedule, GiftRefund, GiftSoftCredit, GiftTribute, PaymentInstrument | 1 each |
| **Total** | **48** |

---

## Help Text (`inlineHelpText`)

Every field that ships with in-app help text — the tooltip a user sees next to the field on a record page. Covers custom (`__c`) fields *and* the standard-field overrides where this project sets or replaces the OOTB help text.

### Opportunity

| API Name | Kind | Help Text |
|---|---|---|
| `FQS_Grant_Deadline__c` | Custom | The deadline to submit this grant application or report to the funder. |
| `FQS_Grant_Report_Due__c` | Custom | When the grant report (progress or final) must be submitted to the funder after the award. |
| `FQS_Solicitation_Date__c` | Custom | The date on which the formal ask was presented to the donor. Used for pipeline tracking and time-to-close analysis. |

### GiftTransaction

| API Name | Kind | Help Text |
|---|---|---|
| `FQS_Donor_Tax_Date__c` | Custom | The date the donor is credited for tax purposes — postmark for mailed checks, charge date for cards, delivery date for stock. Leave blank if your org treats the Transaction Date as the tax date (fine for most orgs). |
| `FQS_Is_Entry_Gift__c` | Custom | Automatically calculated. Marked TRUE when this gift's amount qualifies for the Entry giving tier, or when it is an installment payment against an Entry-tier commitment. Your administrator controls the threshold amounts. |
| `FQS_Is_Major_Gift__c` | Custom | Automatically calculated. Marked TRUE when this gift's amount qualifies for the Major giving tier, or when it is an installment payment against a Major-tier commitment. Your administrator controls the threshold amounts. |
| `FQS_Is_Mid_Gift__c` | Custom | Automatically calculated. Marked TRUE when this gift's amount qualifies for the Mid giving tier, or when it is an installment payment against a Mid-tier commitment. Your administrator controls the threshold amounts. |
| `FQS_Match_Status__c` | Custom | Where this gift stands in the corporate matching lifecycle. Leave blank or N/A if no match is expected. Complements the boolean Matched field, which only flips true once the matching transaction is linked. |
| `FQS_Stewardship_Status__c` | Custom | Status of the follow-up stewardship touch (email or task) for this gift. Set to "Don't Send" to suppress automated stewardship. Distinct from Acknowledgement Status, which tracks the initial thank-you. |
| `CurrentAmount` | Standard (override) | The remaining amount after any refunds or adjustments. Updates automatically. |
| `OriginalAmount` | Standard (override) | The full gift amount as originally committed. For refunds or adjustments, don't change this — record a Gift Refund instead. |
| `OutreachSourceCodeId` | Standard (override) | The appeal, event, or channel that generated this gift. Must belong to the Campaign selected on this record. |
| `Status` | Standard (override) | Where this gift is in the payment cycle. Choose Pending for gifts you've recorded financially but not yet received, Paid once the payment is in hand. |
| `TransactionDueDate` | Standard (override) | The date this gift is expected. For a one-time gift being recorded now, use the same date as Transaction Date. |

### GiftCommitment

| API Name | Kind | Help Text |
|---|---|---|
| `FQS_Is_Entry_Commitment__c` | Custom | Automatically calculated. Marked TRUE when this commitment's total expected amount qualifies for the Entry giving tier. Your administrator controls the threshold amount. |
| `FQS_Is_Major_Commitment__c` | Custom | Automatically calculated. Marked TRUE when this commitment's total expected amount qualifies for the Major giving tier. Your administrator controls the threshold amount. |
| `FQS_Is_Mid_Commitment__c` | Custom | Automatically calculated. Marked TRUE when this commitment's total expected amount qualifies for the Mid giving tier. Your administrator controls the threshold amount. |
| `ExpectedTotalCmtAmount` | Standard (override) | The total amount the donor has pledged for this commitment. |
| `FulfillmentType` | Standard (override) | Indicates whether the committed funds can be used immediately (Unconditional) or only after specific conditions are met (Conditional). |
| `RecurrenceType` | Standard (override) | Open Ended: a recurring gift with no defined end date — typical for monthly donors. Fixed Length: a recurring gift with a clear start and end date. |
| `ScheduleType` | Standard (override) | Set automatically when a gift commitment schedule is created. Recurring = a regular cadence; Custom = a manually defined payment schedule. |

### GiftCommitmentSchedule

| API Name | Kind | Help Text |
|---|---|---|
| `TransactionAmount` | Standard (override) | Enter the amount paid per transaction. For example, if the pledge is $2,000 and its paid quarterly (four times a year) then the amount should be $500. |

### GiftDesignation

| API Name | Kind | Help Text |
|---|---|---|
| `FQS_Restriction_Type__c` | Custom | How the donor restricted the use of this designation's funds. Without Donor Restriction: usable for any program at any time. With Donor Restriction - Purpose: must be spent on a specific program or use. With Donor Restriction - Time: released only after a specified date or event. With Donor Restriction - Permanent: principal held indefinitely (endowment); only earnings are spendable. |
| `IsActive` | Standard (override) | Uncheck to retire this designation. Retired designations stay on historical gifts but won't appear when adding new gifts. |
| `IsDefault` | Standard (override) | Indicates whether the unrestricted gift amount is to be allocated to this designation as default (true) or not (false). |

### GiftDefaultDesignation

| API Name | Kind | Help Text |
|---|---|---|
| `FQS_Restriction_Type__c` | Custom | FASB/GAAP restriction classification inherited from the parent Gift Designation. |

### GiftEntry — Gift Entry launcher staging

Every field on this object is a staging mirror for a downstream GiftCommitment / GiftTransaction column. Values are written to their target field on commit.

| API Name | Kind | Help Text |
|---|---|---|
| `FQS_Donor_Tax_Date__c` | Custom | The date the donor is credited for tax purposes — postmark for mailed checks, charge date for cards, delivery date for stock. Leave blank if your org treats the Transaction Date as the tax date. |
| `FQS_Fair_Market_Value_Amount__c` | Custom | Estimated fair market value of the donated goods or services. Used for the tax receipt and reporting only — the donor determines the actual tax-deductible value on their own return. |
| `FQS_GC_Match_Eligible__c` | Custom | Check if a corporate matching gift is expected against the Gift Commitment being created. Populates the Match Eligible flag on the commitment, not on each individual transaction. |
| `FQS_Gift_Transaction_Category__c` | Custom | Category that classifies this transaction: Outright Gift, Pledge Payment, Recurring Gift Payment, Grant Payment, or Other. |
| `FQS_Match_Status__c` | Custom | Where this gift stands in the corporate matching lifecycle. Leave blank or N/A if no match is expected. Complements the boolean Matched field on the transaction, which only flips true once the matching transaction is linked. |
| `FQS_GC_Restriction_Release_Date__c` | Custom | The date restricted funds on the Gift Commitment become available for either general use or for their designated purpose. Populates onto the Gift Commitment on commit. |
| `FQS_GT_Restriction_Release_Date__c` | Custom | The date restricted funds from this payment become available for either general use or for their designated purpose. Populates onto the Gift Transaction on commit. |
| `FQS_GC_Skip_Naming__c` | Custom | Check to prevent the FQS auto-naming flow from overwriting the Name on the resulting Gift Commitment. |
| `FQS_GT_Skip_Naming__c` | Custom | Check to prevent the FQS auto-naming flow from overwriting the Name on the resulting Gift Transaction. |
| `FQS_Stewardship_Date__c` | Custom | Date the stewardship follow-up occurred — only fill in if stewardship happened outside Salesforce. The automated stewardship flow otherwise writes this on delivery. |
| `FQS_Stewardship_Status__c` | Custom | Status of the follow-up stewardship touch. Set to "Don't Send" to suppress automated stewardship. Distinct from Acknowledgement Status, which tracks the initial thank-you. |
| `FQS_Tax_Receipt_Date__c` | Custom | Date this gift's tax receipt was issued to the donor. Usually filled in by an annual bulk update — enter here only if the receipt was issued before entering the gift into Salesforce. |

### GiftTransactionDesignation

| API Name | Kind | Help Text |
|---|---|---|
| `FQS_Restriction_Type__c` | Custom | FASB/GAAP restriction classification inherited from the parent Gift Designation. |

### GiftSoftCredit

| API Name | Kind | Help Text |
|---|---|---|
| `Role` | Standard (override) | Why this person or organization gets credit for a gift they didn't legally give — e.g., Solicitor (moved the donor), Household Member (partner or family), Matched Donor (matching employer), Honoree (tribute gift recipient). |

### GiftTribute

| API Name | Kind | Help Text |
|---|---|---|
| `TributeType` | Standard (override) | Honor for a gift celebrating a living recipient (birthday, milestone, achievement). Memorial for a gift given in memory of someone who has passed. |

### DonorGiftSummary

| API Name | Kind | Help Text |
|---|---|---|
| `FQS_Annual_Donor_Level_Name__c` | Custom | Automatically calculated. Shows the branded giving tier name for this donor based on their current-year giving (e.g., Friend, Partner, Champion). Blank means the donor is below the Entry annual threshold. Your administrator controls both the threshold amounts and tier names. |
| `FQS_Annual_Donor_Level__c` | Custom | Automatically calculated. Shows which annual giving tier this donor belongs to (Entry, Mid, or Major) based on their giving in the current year. Blank means the donor is below the Entry annual threshold. Your administrator controls the threshold amounts. |
| `FQS_Is_Entry_Annual_Donor__c` | Custom | Automatically calculated. Marked TRUE when this donor's current-year giving qualifies for the Entry giving tier. Your administrator controls the threshold amount. |
| `FQS_Is_Entry_Lifetime_Donor__c` | Custom | Automatically calculated. Marked TRUE when this donor's total lifetime giving qualifies for the Entry giving tier. Your administrator controls the threshold amount. |
| `FQS_Is_Major_Annual_Donor__c` | Custom | Automatically calculated. Marked TRUE when this donor's current-year giving qualifies for the Major giving tier. Your administrator controls the threshold amount. |
| `FQS_Is_Major_Lifetime_Donor__c` | Custom | Automatically calculated. Marked TRUE when this donor's total lifetime giving qualifies for the Major giving tier. Your administrator controls the threshold amount. |
| `FQS_Is_Mid_Annual_Donor__c` | Custom | Automatically calculated. Marked TRUE when this donor's current-year giving qualifies for the Mid giving tier. Your administrator controls the threshold amount. |
| `FQS_Is_Mid_Lifetime_Donor__c` | Custom | Automatically calculated. Marked TRUE when this donor's total lifetime giving qualifies for the Mid giving tier. Your administrator controls the threshold amount. |
| `FQS_Lifetime_Donor_Level_Name__c` | Custom | Automatically calculated. Shows the branded giving tier name for this donor based on their total lifetime giving (e.g., Friend, Partner, Champion). Blank means the donor is below the Entry threshold. Your administrator controls both the threshold amounts and tier names. |
| `FQS_Lifetime_Donor_Level__c` | Custom | Automatically calculated. Shows which lifetime giving tier this donor belongs to (Entry, Mid, or Major) based on their total lifetime giving. Blank means the donor is below the Entry threshold. Your administrator controls the threshold amounts. Use the Lifetime Donor Grouping Name field for reports and communications. |

### FQS_Donor_Grouping__mdt

| API Name | Kind | Help Text |
|---|---|---|
| `Annual_Min_Amount__c` | Custom | The minimum fiscal-year giving total for a donor to qualify for this tier annually. Your administrator controls this threshold. Updating it automatically recalculates the annual giving tier across all Donor Gift Summary records. |
| `Branded_Name__c` | Custom | The branded name of the Grouping Key shown to staff and donors in reports, dashboards, and the Donor Gift Summary record page. Changing this value here automatically updates FQS_Donor_Level_Name__c on all Donor Gift Summary records. Example values: Friend, Partner, Champion or Entry, Rising, Summit. |
| `Grouping_Key__c` | Custom | The internal identifier for this grouping tier. The FQS_Donor_Level__c formula field on Donor Gift Summary returns this value and is used for list views and reports. A single custom metadata type is recommended for each of these picklist values. |
| `Lifetime_Min_Amount__c` | Custom | The minimum lifetime giving total for a donor to qualify for this tier. Your administrator controls this threshold. Updating it automatically recalculates the lifetime giving tier across all Donor Gift Summary, Gift Commitment, and related records. |
| `One_Time_Min_Amount__c` | Custom | The minimum gift amount for a single transaction to qualify for this tier. Your administrator controls this threshold. Updating it automatically recalculates the giving tier across all Gift Transactions. |
| `Sort_Order__c` | Custom | Controls the display order of grouping tiers in Setup and reports. Lower numbers appear first. This field is for presentation only — the FQS_Donor_Level__c formula evaluates tiers by comparing Minimum Amount values from highest to lowest, not by Sort Order. |

## Admin Descriptions (`description`)

Every field that ships with an admin-facing description — visible only to admins in Setup, used to document intent, formula behavior, sync-with-NPC caveats, and known override behaviors. Not shown to end users.

### Account

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |

### Campaign

| API Name | Kind | Admin Description |
|---|---|---|
| `FQS_Campaign_Category__c` | Custom | Fundraising Quick Start: identifies the fundraising purpose of the campaign. Drives list view segmentation and page layout context. |
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |

### Opportunity

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |
| `FQS_Grant_Deadline__c` | Custom | Date by which the grant application or report is due to the funder. Separate from CloseDate, which tracks the anticipated award decision date. |
| `FQS_Grant_Report_Due__c` | Custom | Date the post-award grant progress or final report is due to the funder. |
| `FQS_Solicitation_Date__c` | Custom | Date the major gift ask was formally made to the donor. |

### GiftTransaction

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |
| `FQS_Donor_Tax_Date__c` | Custom | The date the gift is treated as having left the donor's control for tax-receipt purposes. Varies by payment channel and local law — postmark for mailed checks, charge-authorization date for credit-card gifts, delivery date for stock or in-kind gifts. Distinct from Transaction Date (Transaction Completion Date), which is when the gift is fully in the org's hands. Optional for most orgs. Renamed from FQS_Donor_Tax_Acknowledgement_Date__c on 2026-08-02 to avoid confusion with the standard AcknowledgementDate (thank-you date). |
| `FQS_Gift_Transaction_Category__c` | Custom | Classifies the transaction kind. Values sourced from the FQS_Gift_Transaction_Category GlobalValueSet (shared with GiftEntry.FQS_Gift_Transaction_Category__c staging mirror). Allowed values: Outright Gift, Pledge Payment, Recurring Gift Payment, Grant Payment, Other. |
| `FQS_Match_Status__c` | Custom | Tracks the lifecycle of a corporate matching-gift request against this transaction. Values sourced from the FQS_Match_Status GlobalValueSet (shared with GiftEntry.FQS_Match_Status__c staging mirror). Distinct from FQS_Matched__c (boolean, flips true when MatchingEmployerTransactionId is linked): Match Status covers the whole workflow — Eligible, Request Confirmed, Received, Declined, N/A. |
| `FQS_Stewardship_Status__c` | Custom | Tracks whether a post-acknowledgement stewardship touch has been delivered for this gift. Values sourced from the FQS_Stewardship_Status GlobalValueSet (shared with GiftEntry.FQS_Stewardship_Status__c staging mirror). Written by the FQS_Stewardship_Response flow. Allowed values: To Be Sent, Sent, Don't Send. |
| `FQS_In_Kind__c` | Custom | Indicates this transaction is an in-kind (non-cash) gift such as goods, services, or property. |
| `FQS_Is_Entry_Gift__c` | Custom | Boolean formula that returns TRUE when CurrentAmount meets or exceeds the Entry.One_Time_Min_Amount__c value in FQS_Donor_Grouping custom metadata, OR when the parent GiftCommitment.ExpectedTotalCmtAmount meets or exceeds Entry.Lifetime_Min_Amount__c (installment inheritance — a payment against a large commitment inherits the commitment's tier). Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values recalculates this field across all Gift Transaction records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Major_Gift__c` | Custom | Boolean formula that returns TRUE when CurrentAmount meets or exceeds the Major.One_Time_Min_Amount__c value in FQS_Donor_Grouping custom metadata, OR when the parent GiftCommitment.ExpectedTotalCmtAmount meets or exceeds Major.Lifetime_Min_Amount__c (installment inheritance — a payment against a large commitment inherits the commitment's tier). Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values recalculates this field across all Gift Transaction records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Mid_Gift__c` | Custom | Boolean formula that returns TRUE when CurrentAmount meets or exceeds the Mid.One_Time_Min_Amount__c value in FQS_Donor_Grouping custom metadata, OR when the parent GiftCommitment.ExpectedTotalCmtAmount meets or exceeds Mid.Lifetime_Min_Amount__c (installment inheritance — a payment against a large commitment inherits the commitment's tier). Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values recalculates this field across all Gift Transaction records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Matched__c` | Custom | Indicates this transaction has an employer or third-party match. When true and GiftType is Individual, the Matching Employer Transactions related list is shown on the record page. |
| `FQS_Recurring__c` | Custom | Indicates this transaction is part of a recurring giving series linked to a Gift Commitment. |
| `CurrentAmount` | Standard (override) | System-managed. Equals OriginalAmount minus posted GiftRefund and adjustment amounts. Not writable via API or Apex — attempting to set returns INVALID_FIELD_FOR_INSERT_UPDATE. To reduce an amount, insert a GiftRefund child instead of mutating CurrentAmount. See docs/dev/npc-automation-notes.md. |
| `GiftType` | Standard (override) | Allowed values: Individual, Organizational. |
| `OutreachSourceCodeId` | Standard (override) | The Outreach Source Code (appeal, channel, or event) that generated this gift. When populated, the OSC's parent Campaign must equal this transaction's CampaignId — mismatched values fail with "Select an Outreach Source Code that's part of this Campaign." Recommended pattern in automation: pick the OSC first, then set CampaignId from OutreachSourceCode.CampaignId. See docs/dev/npc-automation-notes.md. |
| `Status` | Standard (override) | Not all statuses are reachable by direct write. Paid on a real gift typically requires an associated payment or NPC reconciliation flow. Direct-writing Status = 'Paid' on insert works for seed and test data but bypasses normal payment posting — do not use for production ingest. See docs/dev/npc-automation-notes.md. |
| `TransactionDueDate` | Standard (override) | Required on insert even for gifts in Paid status. For outright gifts, set equal to TransactionDate. For pledge payments, match the parent GiftCommitmentSchedule row. Grant payouts: expected payout date from the schedule. See docs/dev/npc-automation-notes.md. |

### GiftCommitment

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |
| `FQS_Gift_Commitment_Category__c` | Custom | Categorizes the gift commitment by its fundraising type. Allowed values: Pledged Gift, Recurring Gift, Grant Payout. |
| `FQS_Is_Entry_Commitment__c` | Custom | Boolean formula that returns TRUE when ExpectedTotalCmtAmount meets or exceeds the Entry.Lifetime_Min_Amount__c value in FQS_Donor_Grouping custom metadata. GiftCommitment has no CurrentAmount field, so ExpectedTotalCmtAmount (total pledged value) is used as the commitment's amount basis. Lifetime thresholds are used because a commitment represents a total pledge, not a single transaction. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values recalculates this field across all Gift Commitment records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Major_Commitment__c` | Custom | Boolean formula that returns TRUE when ExpectedTotalCmtAmount meets or exceeds the Major.Lifetime_Min_Amount__c value in FQS_Donor_Grouping custom metadata. GiftCommitment has no CurrentAmount field, so ExpectedTotalCmtAmount (total pledged value) is used as the commitment's amount basis. Lifetime thresholds are used because a commitment represents a total pledge, not a single transaction. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values recalculates this field across all Gift Commitment records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Mid_Commitment__c` | Custom | Boolean formula that returns TRUE when ExpectedTotalCmtAmount meets or exceeds the Mid.Lifetime_Min_Amount__c value in FQS_Donor_Grouping custom metadata. GiftCommitment has no CurrentAmount field, so ExpectedTotalCmtAmount (total pledged value) is used as the commitment's amount basis. Lifetime thresholds are used because a commitment represents a total pledge, not a single transaction. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values recalculates this field across all Gift Commitment records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FormalCommitmentType` | Standard (override) | Allowed values: Verbal, Written. |
| `FulfillmentType` | Standard (override) | Allowed values: Unconditional, Conditional. |
| `RecurrenceType` | Standard (override) | Allowed values: OpenEnded, FixedLength. |
| `ScheduleType` | Standard (override) | Auto-managed. Do not set on insert — the system silently overrides to Recurring, producing the misleading error "You can only create a custom schedule when the commitment schedule type is Custom" when a Custom GiftCommitmentSchedule is then attached. Correct pattern: insert GiftCommitment with no ScheduleType, then insert one or more GiftCommitmentSchedule children; ScheduleType is populated from the first schedule. See docs/dev/npc-automation-notes.md. Allowed values: Recurring, Custom. |

### GiftCommitmentSchedule

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |
| `CommitmentUpdateReason` | Standard (override) | Reason the schedule or commitment was last modified. Allowed values: Payment Method Declined (payment could not be processed), Financial Hardship (donor requested change due to financial circumstances). |
| `GiftCommitmentStatus` | Standard (override) | Read-only mirror of the parent Gift Commitment Status field. Allowed values: Draft (commitment not yet active), Active (installments being processed), Lapsed (past due with no recent payment), Failing (payment processing errors), Paused (installments temporarily suspended), Closed (commitment fulfilled or cancelled). |
| `PaymentMethod` | Standard (override) | Method by which installment payments are collected. Allowed values: Credit Card, ACH, Check, Cash, PayPal, Venmo, Cryptocurrency, Stock, Asset, In-Kind, Unknown. |
| `TransactionDay` | Standard (override) | Day of the month or week on which each installment transaction is created. Allowed values: 1–30 (day of month), LastDay (last day of the month). Used in conjunction with TransactionPeriod and TransactionInterval. |
| `TransactionPeriod` | Standard (override) | Frequency unit for recurring installments. Allowed values: Monthly (one installment per month), Weekly (one per week), Daily (one per day), Yearly (one per year), Custom (interval defined by TransactionInterval and TransactionDay). |
| `Type` | Standard (override) | Indicates whether this schedule is actively creating gift transactions or is paused. Allowed values: CreateTransactions (schedule is generating installments on each transaction date), PauseTransactions (schedule exists but installment generation is suspended). |

### GiftDesignation

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |
| `FQS_Restriction_Type__c` | Custom | Aligned to FASB ASU 2016-14 net asset classifications. Allowed values: Without Donor Restriction, With Donor Restriction - Purpose, With Donor Restriction - Time, With Donor Restriction - Permanent. |
| `IsActive` | Standard (override) | Controls whether the designation is available on new gifts. An active GiftDesignation cannot be deleted — attempting to delete raises "You can't delete an active designation." Correct teardown pattern: set IsActive = false, update, then delete. Deactivation does not affect existing GiftTransactionDesignation rows that reference the designation; historical allocations remain intact. See docs/dev/npc-automation-notes.md. |

### GiftDefaultDesignation

| API Name | Kind | Admin Description |
|---|---|---|
| `FQS_Parent_Type__c` | Custom | Formula: returns the type of the polymorphic ParentRecordId (GiftCommitment, Opportunity, Campaign, or blank if unset). |
| `FQS_Restriction_Type__c` | Custom | Formula: mirrors the Restriction Type from the related Gift Designation. Read-only. |

### GiftEntry — Gift Entry launcher staging

Every field on this object is a staging mirror for a downstream GiftCommitment / GiftTransaction column. Values are written to their target field on commit. See `docs/gift-entry-field-mapping.md` for the full mapping.

| API Name | Kind | Admin Description |
|---|---|---|
| `FQS_Donor_Tax_Date__c` | Custom | Staging mirror of GiftTransaction.FQS_Donor_Tax_Date__c. Captured on the Gift Entry launcher when the donor's tax-credit date differs from the Transaction Date. Written to GiftTransaction.FQS_Donor_Tax_Date__c on commit. |
| `FQS_Fair_Market_Value_Amount__c` | Custom | Staging mirror of GiftTransaction.FQS_Fair_Market_Value_Amount__c. Captured on the Gift Entry launcher for in-kind gifts. Written to GiftTransaction.FQS_Fair_Market_Value_Amount__c on commit. |
| `FQS_GC_Match_Eligible__c` | Custom | Staging mirror of GiftCommitment.FQS_Match_Eligible__c. Written to the parent Gift Commitment (not the resulting Gift Transaction) on commit. The GC_ prefix disambiguates the mirror from any future FQS_Match_Eligible__c on the GT and makes the routing intent explicit. |
| `FQS_Gift_Transaction_Category__c` | Custom | Staging mirror of GiftTransaction.FQS_Gift_Transaction_Category__c. Both fields source their picklist values from the FQS_Gift_Transaction_Category GlobalValueSet so the launcher staging value always matches what lands on the transaction. |
| `FQS_Match_Status__c` | Custom | Staging mirror of GiftTransaction.FQS_Match_Status__c. Both fields source their picklist values from the FQS_Match_Status GlobalValueSet so the launcher staging value always matches what lands on the transaction. |
| `FQS_GC_Restriction_Release_Date__c` | Custom | Staging mirror routed to GiftCommitment.FQS_Restriction_Release_Date__c on commit. Paired with FQS_GT_Restriction_Release_Date__c on the transaction side — Salesforce enforces one GiftEntry source field to one destination field per FieldMappingConfig, so GC and GT need separate staging columns. |
| `FQS_GT_Restriction_Release_Date__c` | Custom | Staging mirror routed to GiftTransaction.FQS_Restriction_Release_Date__c on commit. Paired with FQS_GC_Restriction_Release_Date__c on the commitment side. |
| `FQS_GC_Skip_Naming__c` | Custom | Staging mirror routed to GiftCommitment.FQS_Skip_Naming__c on commit. Paired with FQS_GT_Skip_Naming__c on the transaction side. When TRUE, the FQS Auto Name Gift Commitment flow skips the resulting GC and leaves Name as-is. |
| `FQS_GT_Skip_Naming__c` | Custom | Staging mirror routed to GiftTransaction.FQS_Skip_Naming__c on commit. Paired with FQS_GC_Skip_Naming__c on the commitment side. When TRUE, the FQS Auto Name Gift Transaction flow skips the resulting GT and leaves Name as-is. |
| `FQS_Stewardship_Date__c` | Custom | Staging mirror of GiftTransaction.FQS_Stewardship_Date__c. Carries a manual override date when stewardship was performed outside the automated flow. Blank on most entries — the automated FQS_Stewardship_Response flow writes the field post-commit when the stewardship touch is delivered. |
| `FQS_Stewardship_Status__c` | Custom | Staging mirror of GiftTransaction.FQS_Stewardship_Status__c. Both fields source their picklist values from the FQS_Stewardship_Status GlobalValueSet so the launcher staging value always matches what lands on the transaction. |
| `FQS_Tax_Receipt_Date__c` | Custom | Staging mirror of GiftTransaction.FQS_Tax_Receipt_Date__c. Rare on Gift Entry — year-end tax receipting is out of scope for FQS automation and typically handled by bulk update. Kept for the edge case where a gift is entered retroactively with its tax receipt already issued. |

### GiftTransactionDesignation

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |
| `FQS_Restriction_Type__c` | Custom | Formula: mirrors the Restriction Type from the related Gift Designation. Read-only. |

### GiftRefund

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |

### GiftSoftCredit

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |

### GiftTribute

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |

### DonorGiftSummary

| API Name | Kind | Admin Description |
|---|---|---|
| `FQS_Annual_Donor_Level_Name__c` | Custom | Boolean formula that returns the branded tier name (e.g., Friend, Partner, Champion) based on GiftsThisYearAmount against the Annual_Min_Amount__c thresholds in FQS_Donor_Grouping custom metadata. Note: GiftsThisYearAmount is a calendar-year rollup from NPC; if your org uses a non-calendar fiscal year, validate whether this aligns with your reporting expectations. Returns blank when GiftsThisYearAmount is below the Entry annual threshold. Thresholds and branded names are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values or branded names recalculates this field retroactively — no redeployment or batch job required. |
| `FQS_Annual_Donor_Level__c` | Custom | Boolean formula that returns the internal grouping tier key (Entry, Mid, Major, or blank for sub-Entry) based on GiftsThisYearAmount against the Annual_Min_Amount__c thresholds in FQS_Donor_Grouping custom metadata. Note: GiftsThisYearAmount is a calendar-year rollup from NPC; if your org uses a non-calendar fiscal year, validate whether this aligns with your reporting expectations. Returns blank when GiftsThisYearAmount is below the Entry annual threshold. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. |
| `FQS_Is_Entry_Annual_Donor__c` | Custom | Boolean formula that returns TRUE when GiftsThisYearAmount meets or exceeds the Entry.Annual_Min_Amount__c value in FQS_Donor_Grouping custom metadata. Note: GiftsThisYearAmount is a calendar-year rollup from NPC. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values in Setup or via the configurator flow recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Entry_Lifetime_Donor__c` | Custom | Boolean formula that returns TRUE when TotalGiftsAmount meets or exceeds the Entry.Lifetime_Min_Amount__c value in FQS_Donor_Grouping custom metadata. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values in Setup or via the configurator flow recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Major_Annual_Donor__c` | Custom | Boolean formula that returns TRUE when GiftsThisYearAmount meets or exceeds the Major.Annual_Min_Amount__c value in FQS_Donor_Grouping custom metadata. Note: GiftsThisYearAmount is a calendar-year rollup from NPC. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values in Setup or via the configurator flow recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Major_Lifetime_Donor__c` | Custom | Boolean formula that returns TRUE when TotalGiftsAmount meets or exceeds the Major.Lifetime_Min_Amount__c value in FQS_Donor_Grouping custom metadata. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values in Setup or via the configurator flow recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Mid_Annual_Donor__c` | Custom | Boolean formula that returns TRUE when GiftsThisYearAmount meets or exceeds the Mid.Annual_Min_Amount__c value in FQS_Donor_Grouping custom metadata. Note: GiftsThisYearAmount is a calendar-year rollup from NPC. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values in Setup or via the configurator flow recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Is_Mid_Lifetime_Donor__c` | Custom | Boolean formula that returns TRUE when TotalGiftsAmount meets or exceeds the Mid.Lifetime_Min_Amount__c value in FQS_Donor_Grouping custom metadata. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values in Setup or via the configurator flow recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately. |
| `FQS_Lifetime_Donor_Level_Name__c` | Custom | Boolean formula that returns the branded tier name (e.g., Friend, Partner, Champion) based on TotalGiftsAmount against the Lifetime_Min_Amount__c thresholds in FQS_Donor_Grouping custom metadata. Returns blank when TotalGiftsAmount is below the Entry lifetime threshold. Thresholds and branded names are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values or branded names recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards will reflect new values immediately. |
| `FQS_Lifetime_Donor_Level__c` | Custom | Boolean formula that returns the internal grouping tier key (Entry, Mid, Major, or blank for sub-Entry) based on TotalGiftsAmount against the Lifetime_Min_Amount__c thresholds in FQS_Donor_Grouping custom metadata. Returns blank when TotalGiftsAmount is below the Entry lifetime threshold. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values recalculates this field across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards will reflect new values immediately. Use FQS_Lifetime_Donor_Level_Name__c for donor-facing displays. |

### OutreachSourceCode

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |
| `FQS_Message_Channel_Segment__c` | Custom | Calculated channel segment grouping derived from Message Channel.  Organic: Organic Web, Physical, Social Organic, Share Partner.  Paid Digital: Digital Paid, Social Paid.  Owned or Acquired Lists: Email, Direct Mail, SMS, Telemarketing.  Blank when Message Channel is not set. |
| `MessageChannel` | Standard (override) | The outreach channel used for this source code. Restricted to NPC-supported channels. Select the channel that best matches the medium used to reach donors. Drives the Channel Segment field used for list view filtering and reporting.  Organic Web, Physical, Social Organic, Share Partner, Digital Paid, Social Paid, Email, Direct Mail, SMS, Telemarketing. |
| `UsageType` | Standard (override) | The purpose for which this source code is used. When set to Fundraising, CampaignId is required — insert or update fails with "Choose a campaign when the Usage Type is Fundraising." For non-Fundraising usages CampaignId is optional. Do not flip an existing OSC from Fundraising to another usage without first clearing dependent GiftTransaction references. Restricted to supported NPC usage types; currently only Fundraising is available. See docs/dev/npc-automation-notes.md. |

### PaymentInstrument

| API Name | Kind | Admin Description |
|---|---|---|
| `External_Id__c` | Custom | External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>]. |

### FQS_Donor_Grouping__mdt

| API Name | Kind | Admin Description |
|---|---|---|
| `Annual_Min_Amount__c` | Custom | Minimum fiscal-year giving total (inclusive) required to qualify for this grouping tier on an annual basis. Referenced by the DonorGiftSummary boolean formula fields FQS_Is_Entry_Annual_Donor__c, FQS_Is_Mid_Annual_Donor__c, and FQS_Is_Major_Annual_Donor__c. Changing this value in Setup → Custom Metadata Types → FQS Donor Grouping (or via the FQS Donor Grouping Configurator screen flow) recalculates those boolean fields across all Donor Gift Summary records retroactively — no redeployment or batch job required. Reports and dashboards using these fields will reflect the new values immediately. |
| `Branded_Name__c` | Custom | The donor-facing display name for this grouping tier. Referenced by the DonorGiftSummary formula field FQS_Donor_Level_Name__c. Change this value to rebrand tier names (e.g., "Friend" to "Community Member") across all Donor Gift Summary records without redeployment. |
| `Grouping_Key__c` | Custom | Internal key for this donor grouping. Referenced by the DonorGiftSummary formula field FQS_Donor_Level__c to classify donors. Must match the DeveloperName of this record so the formula evaluation is consistent. Allowed values: Entry, Mid, Major. |
| `Lifetime_Min_Amount__c` | Custom | Minimum lifetime giving total (inclusive) required to qualify for this grouping tier. Referenced by the DonorGiftSummary formula fields FQS_Lifetime_Donor_Level__c, FQS_Lifetime_Donor_Level_Name__c, FQS_Is_Entry_Lifetime_Donor__c, FQS_Is_Mid_Lifetime_Donor__c, FQS_Is_Major_Lifetime_Donor__c, and the GiftCommitment boolean fields FQS_Is_Entry_Commitment__c, FQS_Is_Mid_Commitment__c, FQS_Is_Major_Commitment__c. Also used in GiftTransaction installment-inheritance formulas. Changing this value in Setup → Custom Metadata Types → FQS Donor Grouping (or via the FQS Donor Grouping Configurator screen flow) recalculates all of the above fields retroactively — no redeployment or batch job required. Reports and dashboards will reflect the new values immediately. |
| `One_Time_Min_Amount__c` | Custom | Minimum single-transaction amount (inclusive) required to qualify for this grouping tier based on a one-time gift. Referenced by the GiftTransaction boolean formula fields FQS_Is_Entry_Gift__c, FQS_Is_Mid_Gift__c, and FQS_Is_Major_Gift__c. Changing this value in Setup → Custom Metadata Types → FQS Donor Grouping (or via the FQS Donor Grouping Configurator screen flow) recalculates those boolean fields across all Gift Transaction records retroactively — no redeployment or batch job required. Reports and dashboards using these fields will reflect the new values immediately. |
| `Sort_Order__c` | Custom | Ascending sort order for display purposes. The DonorGiftSummary formula fields FQS_Donor_Level__c and FQS_Donor_Level_Name__c evaluate groupings by comparing Minimum Amount values directly — Sort Order does not affect formula evaluation order. |

