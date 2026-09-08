# FQS Data Dictionary

*Reference for every custom field and custom metadata record that ships in the FQS unmanaged package. Standard fields are listed where FQS-specific notes apply (behavior, allowed values, automation dependencies). For help-text overlays on standard fields, see [docs/manual-help-text-setup.md](manual-help-text-setup.md).*

**Column key**
| Column | Meaning |
|---|---|
| API Name | Salesforce field API name |
| Label | Field label as it appears in the UI |
| Type | Field data type |
| Req | `Y` = required, `—` = optional |
| Notes | FQS-specific behavior, automation dependencies, or constraints |

---

## Table of contents

**Custom fields by object**
- [Account](#account)
- [Campaign](#campaign)
- [DonorGiftSummary](#donorgiftsummary)
- [GiftCommitment](#giftcommitment)
- [GiftCommitmentSchedule](#giftcommitmentschedule)
- [GiftDefaultDesignation](#giftdefaultdesignation)
- [GiftDefaultSoftCredit](#giftdefaultsoftcredit)
- [GiftDesignation](#giftdesignation)
- [GiftEntry](#giftentry)
- [GiftRefund](#giftrefund)
- [GiftSoftCredit](#giftsoftcredit)
- [GiftTransaction](#gifttransaction)
- [GiftTransactionDesignation](#gifttransactiondesignation)
- [GiftTribute](#gifttribute)
- [Opportunity](#opportunity)
- [OutreachSourceCode](#outreachsourcecode)
- [OutreachSummary](#outreachsummary)
- [PaymentInstrument](#paymentinstrument)

**Custom metadata types**
- [FQS_Campaign_Template__mdt](#fqs_campaign_template__mdt) — fields + records
- [FQS_Donor_Tier__mdt](#fqs_donor_tier__mdt) — fields + records

---

## Account

FQS adds 5 fields to Account, all related to the employer matching gift feature.

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. Pattern: `FQS-<OBJ>-<idx>`. Not used in production flows. |
| `FQS_Is_Match_Intermediary__c` | Is Match Intermediary | Checkbox | — | Marks the Account as a matching-gift pass-through (Benevity, YourCause, Bright Funds, CyberGrants). When the donor's Account has this flag, the Guided Gift Entry launcher prompts for the true corporate Account and creates the match GC against that Account. Mutually exclusive with `FQS_Matching_Gift_Program__c`. |
| `FQS_Match_Annual_Individual_Maximum__c` | Match Annual Individual Maximum | Currency | — | Per-employee annual cap on match dollars for this employer. The Guided Gift Entry match flow sums matched amounts already recorded this calendar year and excludes candidates that would push the employee over this cap. Blank = no cap. |
| `FQS_Match_Ratio__c` | Match Ratio | Number | — | Multiplier applied to the employee's `OriginalAmount` when sizing the expected corporate match. `2.00` = 2:1 (company matches double); `1.00` = 1:1 (default if blank); `0.50` = 0.5:1. |
| `FQS_Matching_Gift_Program__c` | Matching Gift Program | Checkbox | — | Marks this Account as running an employer match program. Drives Account-lookup filtering in the Guided Gift Entry match flow. Mutually exclusive with `FQS_Is_Match_Intermediary__c`. |

---

## Campaign

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `FQS_Campaign_Category__c` | Campaign Category | Picklist | — | Fundraising purpose (Annual Fund, Major Gift, Grant, Event, etc.). Drives list-view segmentation and GE launchers' `MessageChannel` / `Platform` defaults when creating the first Outreach Source Code. |
| `FQS_Child_Campaign_Count__c` | Child Campaign Count | Number | — | **Flow-maintained** (not a rollup summary). Updated by `FQS_Campaign_Child_Count_Update` (AfterSave) and `FQS_Campaign_Child_Count_Delete` (BeforeDelete). If the count stops updating, verify both flows are Active. |
| `FQS_Create_First_Outreach_Source_Code__c` | Create First Outreach Source Code | Checkbox | — | Flip trigger for the placeholder OSC auto-created on Tactical campaigns (depth ≥ 3). Set to `true` by `FQS_CampaignHierarchyBuilder` after Ask inserts, or manually to trigger the flow. Idempotent — the flow no-ops if a placeholder already exists (`External_Id__c = 'FQS-OSC-{CampaignId15}-DEFAULT'`). |
| `FQS_Enable_Auto_Members__c` | Enable Automatic Campaign Members | Checkbox | — | Gates the CampaignMember lifecycle flows. Defaulted to `true` on insert for Tactical-level campaigns by `FQS_Campaign_Auto_Members_Default`. The GT and GC record-triggered flows check this field before creating or advancing CampaignMember rows. |
| `FQS_Hierarchy_Depth__c` | Hierarchy Depth | Number (formula) | — | Cross-object `ISBLANK(Parent[.Parent…].ParentId)` depth formula. Depth 1 = Portfolio/Rollup; 2 = Operational; ≥ 3 = Tactical. Clamped at 5. Use in list-view filters to isolate leaf-level vs. parent campaigns. |
| `FQS_Short_Name__c` | Short Name | Text(255) | — | URL-safe, lowercase identifier for UTM campaign codes and OSC source tracking. Lowercase alphanumeric + hyphens recommended (e.g. `fy26-yearend-email`). Not enforced as unique. |
| `FQS_Ultimate_Parent_Campaign__c` | Ultimate Parent Campaign | Text (formula) | — | Walks `Parent.Parent.Parent.Parent.Parent.Name` → `Name`. Returns the level-5 ancestor name for hierarchies deeper than 5. Text, not an Id. |

---

## DonorGiftSummary

DonorGiftSummary (DGS) is a Fundraising Cloud platform object. FQS adds 13 custom fields across two families: **donor grouping** (tier formulas derived from FQS_Donor_Tier__mdt) and **legacy-migration** (carry-over totals from prior CRM or spreadsheet imports).

**Standard fields with FQS behavior notes**

| API Name | Notes |
|---|---|
| `BestGiftYear` | Platform-written 4-digit year string. Not fiscal-year-aware. |
| `BookedPledges` | Platform SUM of `GiftCommitment.ExpectedTotalCmtAmount` across pledge-category GCs in Active / Failing / Paused status. |
| `CompositeRfmScore` | Platform-written RFM score. Segmentation banding conventions are platform-defined. |
| `CurrentYearSoftCreditsAmount` | Platform-written. Feeds `FQS_Annual_Donor_Level*` when a tier's `Credit_Type__c = 'Hard + Soft Credits'`. |
| `FrequencyScore` | F in RFM. Platform-written. |
| `GiftsThisYearAmount` | Calendar-year windowed rollup. Feeds `FQS_Annual_Donor_Level*` formula fields. |
| `GivingLevel` | Unrestricted picklist, platform-written (15 levels). Distinct from FQS donor grouping fields which are org-branded and CMDT-driven. |
| `MonetaryScore` | M in RFM. Platform-written. |
| `RecencyScore` | R in RFM. Platform-written. |
| `TotalBookableRevenue` | Platform-written. `TotalGiftsAmount` + unpaid portion of open pledges. |
| `TotalPaidRcrInstallments` | Platform-written. Excludes pledge installments; recurring commitments only. |
| `TotalPaidRcrInstlAmt` | Subset of `TotalGiftsAmount` filtered to `ScheduleType = 'Recurring'` strictly (Custom-schedule payments excluded). |

**FQS custom fields**

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External Id | Text(255) | — | Stable key for upserting legacy/migrated giving totals. Format should match the parent Account's `External_Id__c`. Not set on NPC-engine-created records. |
| `FQS_Annual_Donor_Level__c` | Annual Donor Tier | Text (formula) | — | Returns `Entry`, `Mid`, `Major`, or blank based on `GiftsThisYearAmount` (+ `CurrentYearSoftCreditsAmount` if the tier's `Credit_Type__c = 'Hard + Soft Credits'`) vs. `Annual_Min_Amount__c` thresholds in `FQS_Donor_Tier__mdt`. Recalculates retroactively when thresholds change — no redeploy required. |
| `FQS_Annual_Donor_Level_Name__c` | Annual Donor Tier Name | Text (formula) | — | Same logic as `FQS_Annual_Donor_Level__c` but returns the tier's `Branded_Name__c` value (e.g. "Partner") rather than the generic key. Use in donor-facing displays. |
| `FQS_Is_Entry_Annual_Donor__c` | Is Entry Annual Donor | Checkbox (formula) | — | Boolean: `true` when annual giving lands in the Entry band. |
| `FQS_Is_Mid_Annual_Donor__c` | Is Mid Annual Donor | Checkbox (formula) | — | Boolean: `true` when annual giving lands in the Mid band. |
| `FQS_Is_Major_Annual_Donor__c` | Is Major Annual Donor | Checkbox (formula) | — | Boolean: `true` when annual giving lands in the Major band. |
| `FQS_Is_Entry_Lifetime_Donor__c` | Is Entry Lifetime Donor | Checkbox (formula) | — | Boolean: lifetime giving (`TotalGiftsAmount + FQS_Legacy_Total_Gifts_Amount__c`) in the Entry band. |
| `FQS_Is_Mid_Lifetime_Donor__c` | Is Mid Lifetime Donor | Checkbox (formula) | — | Boolean: lifetime giving in the Mid band. |
| `FQS_Is_Major_Lifetime_Donor__c` | Is Major Lifetime Donor | Checkbox (formula) | — | Boolean: lifetime giving in the Major band. |
| `FQS_Lifetime_Donor_Level__c` | Lifetime Donor Tier | Text (formula) | — | Returns `Entry`, `Mid`, `Major`, or blank based on `TotalGiftsAmount + FQS_Legacy_Total_Gifts_Amount__c` vs. `Lifetime_Min_Amount__c` thresholds. Soft credits added when `Credit_Type__c = 'Hard + Soft Credits'`. |
| `FQS_Lifetime_Donor_Level_Name__c` | Lifetime Donor Tier Name | Text (formula) | — | Branded-name variant of `FQS_Lifetime_Donor_Level__c`. |
| `FQS_Legacy_First_Gift_Date__c` | Legacy First Gift Date | Date | — | Earliest known gift date from a legacy/external system. Populated once during import; NPC engine does not overwrite. Formulas use `MIN(FirstGiftDate, FQS_Legacy_First_Gift_Date__c)` for true-tenure calculations. |
| `FQS_Legacy_Gift_Count__c` | Legacy Gift Count | Number | — | Gift count from a legacy/external system. Added to the standard `GiftCount` rollup in FQS reports for true lifetime frequency. |
| `FQS_Legacy_Soft_Credit_Total__c` | Legacy Soft Credit Total | Currency | — | Soft-credit total from a legacy/external system. Added to `TotalSoftCreditsAmount` in donor-grouping formula logic when `Credit_Type__c = 'Hard + Soft Credits'`. |
| `FQS_Legacy_Total_Gifts_Amount__c` | Legacy Total Gifts Amount | Currency | — | Hard-credit giving total from a legacy/external system. Added to `TotalGiftsAmount` in lifetime donor-level formulas. |

---

## GiftCommitment

Includes both FQS custom fields and standard fields where FQS behavior applies.

**Standard fields with FQS behavior notes**

| API Name | Notes |
|---|---|
| `CampaignId` | Lookup to Campaign. Required for CampaignMember lifecycle flows to fire. |
| `CurrentGiftCmtScheduleId` | Platform-managed. Populated when a schedule's `StartDate` arrives, **not** at insert. Do not back-fill — overriding this breaks reports that filter on non-null to identify actively giving commitments. See [[gc-current-schedule-activation]]. |
| `FormalCommitmentType` | Restricted picklist: `Verbal`, `Written`. |
| `FulfillmentType` | Restricted picklist: **`Unconditional`**, **`Conditional`**. Maintained by the FQS fulfillment flows (`FQS_GC_Fulfillment_On_Change`, `FQS_GC_Fulfillment_From_GDD`). Default: `Unconditional`. |
| `RecurrenceType` | Restricted picklist: `Fixed Length`, `Open Ended`. Set by the launcher / seed; not derived by the platform. Default: `Open Ended`. |
| `ScheduleType` | Restricted picklist. Set by the launcher based on the gift shape chosen. |

**FQS custom fields**

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `FQS_Gift_Commitment_Category__c` | Gift Commitment Category | Picklist | — | Set by the Guided Gift Entry launcher based on the branch chosen (Pledged Gift, Recurring Gift, Grant Payout, etc.). Child GTs inherit the mapped category via `FQS_Auto_Category_Gift_Transaction` when their own category is blank and `GiftCommitmentId` is set. |
| `FQS_Is_Entry_Commitment__c` | Is Entry Commitment | Checkbox (formula) | — | `true` when `ExpectedTotalCmtAmount` lands in the Entry lifetime band. Recalculates retroactively when `FQS_Donor_Tier__mdt` thresholds change. |
| `FQS_Is_Mid_Commitment__c` | Is Mid Commitment | Checkbox (formula) | — | `true` when `ExpectedTotalCmtAmount` lands in the Mid lifetime band. |
| `FQS_Is_Major_Commitment__c` | Is Major Commitment | Checkbox (formula) | — | `true` when `ExpectedTotalCmtAmount` lands in the Major lifetime band. |
| `FQS_Match_Eligible__c` | Match Eligible | Checkbox | Y | When `true`, a corporate matching gift is expected against this commitment. The Pledge Payment leaf reads this flag to default the employer-match question to Yes. |
| `FQS_Restriction_Release_Date__c` | Restriction Release Date | Date | — | Date the gift restriction is expected to release. Convention for multi-year grants: one year past the final installment date. Drives `FulfillmentType` via `FQS_GC_Fulfillment_On_Change` — clearing this date can flip a Conditional back to Unconditional. |
| `FQS_Skip_Naming__c` | Skip FQS Auto Naming | Checkbox | Y | When `true`, `FQS_Auto_Name_Gift_Commitment` skips this record. Use for imports or integration writes carrying an authoritative external Name. |
| `FQS_Summary__c` | Summary | Text (formula) | — | Human-readable schedule summary assembled from platform-managed fields. Returns "Schedule starts in the future." when `ScheduleType` is set but `CurrentGiftCmtScheduleId` is null (pre-activation). |

---

## GiftCommitmentSchedule

Standard fields only (FQS adds one custom field).

**Standard fields with FQS behavior notes**

| API Name | Notes |
|---|---|
| `CommitmentUpdateReason` | Populated by schedule edit / pause / resume flows. Reporting-only. |
| `GiftCommitmentStatus` | Read-only mirror of the parent GC Status. Values: Draft, Active, Lapsed, Failing, Paused, Closed. |
| `PaymentMethod` | Method installment payments are collected. Values include Credit Card, ACH, Check, Cash, PayPal, Venmo, Cryptocurrency, Stock, Asset, In-Kind, Unknown. |
| `TransactionAmount` | Per-installment amount. Required. |
| `TransactionDay` | Restricted picklist: `'1'`–`'28'` and `'LastDay'`. Values 29–31 rejected. Required for Monthly / Yearly periods. Set to `DAY(StartDate)` on seed to avoid monthly-drift to day 1. See [[fundfirst-custom-schedule-shape]]. |
| `TransactionPeriod` | Restricted picklist: Daily, Weekly, Monthly, Yearly, Custom. `Custom` disables engine fanout — each installment must be inserted independently. Required. |
| `Type` | Restricted picklist: `CreateTransactions` (normal), `PauseTransactions` (suspended). Default: `CreateTransactions`. |

**FQS custom fields**

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. **Not unique at the platform level** — managed schedule-cloning actions copy `External_Id__c` via sObject clone; uniqueness is instead enforced by the seed's own naming convention. See [[gcs-external-id-nonunique]]. |

---

## GiftDefaultDesignation

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `FQS_Parent_Type__c` | Parent Type | Text (formula) | — | Reads key prefix of `ParentRecordId`: returns "Gift Commitment" (6gc), "Opportunity" (006), "Campaign" (701), or blank. |
| `FQS_Restriction_Type__c` | Restriction Type | Text (formula) | — | Mirrors `GiftDesignation.FQS_Restriction_Type__c`. Read-only. |
| `GiftDesignationId` | *(standard)* | Lookup | Y | Lookup filter restricts picker to `IsActive = True` designations. Filter is Optional (not Required) so users can see retired designations for back-dated corrections or integration edge cases. |

---

## GiftDefaultSoftCredit

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `FQS_Parent_Type__c` | Parent Type | Text (formula) | — | Reads key prefix of `ParentRecordId`: "Gift Commitment" (6gc), "Opportunity" (006), or blank. |

---

## GiftDesignation

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `FQS_Restriction_Type__c` | Restriction Type | Picklist | — | Restriction category for this designation (Without Donor Restriction, Purpose, Permanent, Earned Revenue). Mirrored as read-only formulas onto GiftTransactionDesignation and GiftDefaultDesignation. Time restrictions are NOT represented here — use `FQS_Restriction_Release_Date__c` on the commitment or transaction. |
| `IsActive` | *(standard)* | Checkbox | Y | An active GD cannot be deleted by the platform. Teardown pattern: un-default → deactivate → delete. Deactivation does NOT affect existing historical GTD rows. |
| `IsDefault` | *(standard)* | Checkbox | — | **Load-bearing.** The managed `processGiftCommitment` action aborts without an active default GD. FQS seed flags `FQS-GD-GENERAL-OPERATING` on install. Platform enforces uniqueness across active records — promote a successor before retiring the current default. See [[fqs-orgwide-default-designation]]. |

---

## GiftEntry

GiftEntry (GE) is the staging object for the Gift Entry Batch experience. FQS adds **12 staging-mirror fields** — each mirrors a corresponding field on GiftCommitment or GiftTransaction so the `FieldMappingConfig` can route the value to the right destination object on commit.

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `FQS_Donor_Tax_Date__c` | Donor Tax Date | Date | — | → `GiftTransaction.FQS_Donor_Tax_Date__c`. The date the gift left the donor's control for tax purposes (postmark, authorization, delivery). Optional — leave blank when no meaningful gap from Transaction Date. |
| `FQS_Fair_Market_Value_Amount__c` | Fair Market Value Amount | Currency | — | → `GiftTransaction.FQS_Fair_Market_Value_Amount__c`. Staging value for in-kind FMV. |
| `FQS_GC_Match_Eligible__c` | GC Match Eligible | Checkbox | Y | → `GiftCommitment.FQS_Match_Eligible__c`. The `GC_` prefix disambiguates from a future GT-level match flag. When `true`, a corporate matching gift is expected against the commitment. |
| `FQS_GC_Restriction_Release_Date__c` | Restriction Release Date (GC) | Date | — | → `GiftCommitment.FQS_Restriction_Release_Date__c`. Separate staging column needed because Salesforce enforces one GE source field → one destination field per FieldMappingConfig. |
| `FQS_GC_Skip_Naming__c` | Skip FQS Auto Naming (GC) | Checkbox | Y | → `GiftCommitment.FQS_Skip_Naming__c`. Separate from `FQS_GT_Skip_Naming__c` for same FieldMappingConfig reason. |
| `FQS_GT_Restriction_Release_Date__c` | Restriction Release Date (GT) | Date | — | → `GiftTransaction.FQS_Restriction_Release_Date__c`. |
| `FQS_GT_Skip_Naming__c` | Skip FQS Auto Naming (GT) | Checkbox | Y | → `GiftTransaction.FQS_Skip_Naming__c`. |
| `FQS_Gift_Transaction_Category__c` | Gift Transaction Category | Picklist | — | → `GiftTransaction.FQS_Gift_Transaction_Category__c`. Shares the `FQS_Gift_Transaction_Category` GlobalValueSet with the canonical GT field so staging and destination values are always in sync. |
| `FQS_Match_Status__c` | Match Status | Picklist | — | → `GiftTransaction.FQS_Match_Status__c`. Shares the `FQS_Match_Status` GlobalValueSet. |
| `FQS_Stewardship_Date__c` | Stewardship Date | Date | — | → `GiftTransaction.FQS_Stewardship_Date__c`. Manual override for stewardship performed outside the automated flow. |
| `FQS_Stewardship_Status__c` | Stewardship Status | Picklist | — | → `GiftTransaction.FQS_Stewardship_Status__c`. Shares the `FQS_Stewardship_Status` GlobalValueSet. |
| `FQS_Tax_Receipt_Date__c` | Tax Receipt Date | Date | — | → `GiftTransaction.FQS_Tax_Receipt_Date__c`. Rare on Gift Entry — used for retroactive entries where the tax receipt is already issued. |

> **Deploy note**: FieldMappingConfig for these fields requires mdapi-format deploy at v67 due to a `ConversionError: Missing processType` bug in the source-format deploy path. See [[fieldmappingconfig-metadata-type]].

---

## GiftRefund

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |

---

## GiftSoftCredit

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `Role` | *(standard)* | Picklist | Y | FundFirst ships 8 values. FQS relies on the **In-Kind Recognition** value to auto-generate self-recognition soft credits on In-Kind gifts (`FQS_In_Kind__c = true`). If missing post-install, restore via Setup. Unique index on `(GiftTransactionId, RecipientId)` — two GSCs on the same GT cannot share a recipient. See [[giftsoftcredit-unique-gt-recipient]]. |

---

## GiftTransaction

The most field-rich object in FQS. Includes both standard fields with FQS-specific behavior and 18 custom fields.

**Standard fields with FQS behavior notes**

| API Name | Notes |
|---|---|
| `AcknowledgementDate` | Date the donor was thanked. Written by `FQS_Gift_Acknowledgement` flow when acknowledgement is delivered. Distinct from `FQS_Donor_Tax_Date__c` (tax-control date) and `FQS_Tax_Receipt_Date__c` (year-end receipt date). |
| `AcknowledgementStatus` | Written by `FQS_Gift_Acknowledgement`. `To Be Sent` (default) queues for the daily run; `Sent` stamps `AcknowledgementDate`. Clearing back to `To Be Sent` re-queues on next run. |
| `CampaignId` | OSC.CampaignId must equal GT.CampaignId — platform enforces this. Recommended pattern: set `CampaignId` from `OutreachSourceCode.CampaignId`, not the other way around. |
| `CurrentAmount` | **Not writable via API/Apex.** To reduce, insert a `GiftRefund` child. |
| `GiftType` | Restricted picklist: `Individual`, `Organizational`. Not derived from `DonorId` — set explicitly. Default: `Individual`. |
| `Name` | Auto-populated by `FQS_Auto_Name_Gift_Transaction`. Skipped when `FQS_Skip_Naming__c = true`. |
| `NonTaxDeductibleAmount` | Quid-pro-quo tracking. `TaxDeductionAmount = CurrentAmount − NonTaxDeductibleAmount`. Not auto-computed. |
| `OriginalAmount` | Includes donor cover, excludes gateway/processor fees. Required. Treat as immutable after posting — reductions flow through `GiftRefund`. |
| `OutreachSourceCodeId` | Must reference an OSC on the same Campaign as the GT. Mismatched = platform error. |
| `PaymentMethod` | Required. Drives conditional visibility (`CheckDate` for checks; `FQS_Fair_Market_Value_Amount__c` for `In-Kind`). On pledge/recurring payments, inherits from the parent schedule. |
| `Status` | Platform fanout from schedule sets `Status = 'Expected'` — see [[gt-expected-status-default]]. FQS launcher defaults to `Paid` for retroactive entry — see [[gt-status-default-paid]]. |
| `TaxDeductionAmount` | Manual. Blank = "assume full deduction" for receipting. For in-kind gifts, the deductible amount is the donor's responsibility. |
| `TaxReceiptStatus` | `Sent` stamps `FQS_Tax_Receipt_Date__c`. Year-end receipting is out of scope for FQS automation. |
| `TransactionDate` | For pledge payments: this is the *payment* date, not the pledge date (`GiftCommitment.EffectiveStartDate`). |
| `TransactionDueDate` | Required on insert even for Paid gifts. For outright gifts, set equal to `TransactionDate`. For installments, match the parent GCS row. |

**FQS custom fields**

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `FQS_Amount_Formatted__c` | Amount (Formatted) | Text (formula) | — | `CurrentAmount` formatted as `$1,250.00`. Used in FQS email templates — standard Currency merge fields render locale-dependent raw numbers in plain-text email. |
| `FQS_Donor_Tax_Date__c` | Donor Tax Date | Date | — | Date the gift left the donor's control for tax purposes. Renamed from `FQS_Donor_Tax_Acknowledgement_Date__c` (2026-08-02) to avoid confusion with the standard `AcknowledgementDate`. |
| `FQS_Fair_Market_Value_Amount__c` | Fair Market Value Amount | Currency | — | FMV for in-kind gifts. Convention: `OriginalAmount = 0`, FMV recorded here. Blank on non-in-kind gifts. |
| `FQS_Gift_Transaction_Category__c` | Gift Transaction Category | Picklist | — | Set by the launcher or inherited from the parent GC category via `FQS_Auto_Category_Gift_Transaction`. Category `Other` excludes the transaction from acknowledgement and stewardship flows. |
| `FQS_In_Kind__c` | In-Kind | Checkbox | Y | **Load-bearing routing flag.** Drives: `OriginalAmount = 0` / FMV convention, auto-generated `GiftSoftCredit` with `Role = 'In-Kind Recognition'`, record-page conditional visibility, seed-data classification. Retained as a boolean instead of relying on `PaymentMethod = 'In-Kind'` because `PaymentMethod` carries no single deterministic non-cash signal across Stock, Asset, and In-Kind values. See [[fqs-inkind-flag-load-bearing]]. |
| `FQS_Is_Entry_Gift__c` | Is Entry Gift | Checkbox (formula) | — | `true` when the gift's `CurrentAmount` lands in the Entry one-time band, or (installment inheritance) the parent GC's `ExpectedTotalCmtAmount` lands in the Entry lifetime band, and neither dimension puts it in Mid or Major. The three `FQS_Is_*_Gift__c` fields are mutually exclusive. |
| `FQS_Is_Mid_Gift__c` | Is Mid Gift | Checkbox (formula) | — | `true` when the gift is exactly in the Mid band. |
| `FQS_Is_Major_Gift__c` | Is Major Gift | Checkbox (formula) | — | `true` when the gift meets or exceeds the Major band threshold. Unbounded top band. |
| `FQS_Match_Status__c` | Match Status | Picklist | — | Lifecycle of the corporate matching-gift request. Values: Eligible → Request Confirmed → Received → Declined, N/A. `Received` is terminal success and pairs with `MatchingEmployerTransactionId` being populated. |
| `FQS_Restriction_Release_Date__c` | Restriction Release Date | Date | — | Date the gift restriction is expected to release. On a payment against a commitment, defaults from the parent GC but is independently writable. |
| `FQS_Skip_Naming__c` | Skip FQS Auto Naming | Checkbox | Y | When `true`, `FQS_Auto_Name_Gift_Transaction` skips this record. |
| `FQS_Stewardship_Date__c` | Stewardship Date | Date | — | Date the stewardship touch was delivered. Written by `FQS_Stewardship_Response`. Manual override allowed for non-automated stewardship touches. |
| `FQS_Stewardship_Status__c` | Stewardship Status | Picklist | — | Values: To Be Sent, Sent, Don't Send. Inline picklist (conversion to GVS blocked by platform). Written by `FQS_Stewardship_Response`. |
| `FQS_Tax_Receipt_Date__c` | Tax Receipt Date | Date | — | Date the year-end tax receipt was issued. Manual — year-end receipting is out of FQS automation scope. |
| `FQS_TaxDeduction_Amount_Formatted__c` | Tax Deduction Amount (Formatted) | Text (formula) | — | Formatted deductible portion (`CurrentAmount − NonTaxDeductibleAmount`) as `$150.00`. Used by the FQS Gift Acknowledgement (Partial Deduction) email template. |
| `FQS_Transaction_Date_LongForm__c` | Transaction Date (Long Form) | Text (formula) | — | `TransactionDate` formatted as `August 14, 2026`. Used in FQS email templates where locale-dependent short dates are unsuitable for tax-facing copy. |

---

## GiftTransactionDesignation

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `FQS_Restriction_Type__c` | Restriction Type | Text (formula) | — | Mirrors `GiftDesignation.FQS_Restriction_Type__c`. Read-only. |
| `GiftDesignationId` | *(standard)* | Lookup | Y | Lookup filter restricts picker to `IsActive = True` designations. Filter is Optional (not Required) — override allowed for back-dated corrections and integration edge cases. |

---

## GiftTribute

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `HonoreeContactId` | *(standard)* | Lookup | — | FQS adds a lookup filter restricting selection to `IsPersonAccount = True`. |
| `TributeType` | *(standard)* | Picklist | — | Unrestricted picklist. Standard values: Honor, Memorial. |

---

## Opportunity

FQS uses Opportunity as the pipeline-tracking record for major gifts and grants before they become Gift Commitments. The Guided Gift Entry Opportunity launcher bridges the two objects on close-won.

**Standard fields with FQS behavior notes**

| API Name | Notes |
|---|---|
| `Amount` | On close-won, the FQS launcher writes this into the resulting `GiftCommitment.ExpectedTotalCmtAmount` or `GiftTransaction.OriginalAmount`. |
| `CloseDate` | On close-won, written into `GiftCommitment.EffectiveStartDate` or `GiftTransaction.TransactionDate`. |
| `ExpectedRevenue` | Platform-computed; not writable. FQS reports use unweighted `Amount` for pipeline totals. |
| `Probability` | Stage → Probability mapping managed at the platform level. Manual override is per-record only. |

**FQS custom fields**

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `FQS_Grant_Deadline__c` | Grant Deadline | Date | — | Distinct from `CloseDate` (anticipated award decision). Populated on Grant-type Opportunities during LOI / Proposal stages. |
| `FQS_Grant_Report_Due__c` | Grant Report Due | Date | — | Post-award grant reporting deadline. Drives grant-stewardship reminders. |
| `FQS_Skip_Naming__c` | Skip FQS Auto Naming | Checkbox | Y | When `true`, `FQS_Auto_Name_Opportunity` skips this record. |
| `FQS_Solicitation_Date__c` | Solicitation Date | Date | — | Date of formal solicitation. Used in time-to-close reports (`CloseDate − FQS_Solicitation_Date__c`). |

---

## OutreachSourceCode

| API Name | Notes |
|---|---|
| `AudienceCount` | Integer. Read by `OutreachSummary.ResponseRate` = CEIL(`DonorCount / AudienceCount × 100`). Null = null Response Rate. |
| `MessageChannel` | Restricted picklist: Email, SMS, Direct Mail, Social Organic, Social Paid, Digital Paid, Organic Web, Physical, Share Partner, Telemarketing. Drives `FQS_Message_Channel_Segment__c`. |
| `MessageChannelPlatform` | Free text (255). Distinct from `FQS_Platform__c` picklist. |
| `SourceCode` | Managed by OSC Generation in Setup. |
| `Status` | Unrestricted picklist: Active, Inactive, Archived. Reporting-only in FQS. |
| `UsageType` | Restricted picklist. `Fundraising` is the only platform-shipped value. When `Fundraising`, `CampaignId` is required. |

**FQS custom fields**

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |
| `FQS_Message_Channel_Segment__c` | Message Channel Segment | Text (formula) | — | Groups `MessageChannel` into segments: Organic, Paid Digital, Owned or Acquired Lists. Not writable. |
| `FQS_Platform__c` | Platform | Picklist | — | Standardized platform picklist (vs. free-text `MessageChannelPlatform`). Contributes to channel-level attribution. |

---

## OutreachSummary

OutreachSummary is a platform-computed rollup object. FQS adds no custom fields; the notes below document key behaviors for FQS reporting.

| API Name | Notes |
|---|---|
| `AttributedAmount` | Platform-set. Credits recurring pledges by earned-to-date value, not paid installments — distinct from `TotalGiftTransactionAmount`. |
| `ResponseRate` | Platform-set. Reads `AudienceCount` from the related OSC(s). Null `AudienceCount` = null Response Rate. |
| `TotalOnetimeGiftAmount` | Platform-set. Filters to `GiftTransaction.GiftCommitmentId = null` strictly — Custom-schedule payments excluded. |

---

## PaymentInstrument

| API Name | Label | Type | Req | Notes |
|---|---|---|---|---|
| `External_Id__c` | External ID | Text(255) | — | Seed/teardown idempotency key. |

---

## FQS_Campaign_Template__mdt

Custom metadata type consumed by the `FQS_CampaignHierarchyBuilder` Apex class and the `FQS_Campaign_Hierarchy_Setup` Screen Flow. Each record defines a named campaign template that the setup wizard can place into a Campaign hierarchy.

### Fields

| API Name | Label | Type | Notes |
|---|---|---|---|
| `Template_Key__c` | Template Key | Text | **Stable slug — do not change after deploy.** Programmatic identifier used by Apex and Flow to look up templates and resolve parent-child links. Must be unique across all records. |
| `Level__c` | Level | Picklist | Which hierarchy tier this template creates: `Rollup` (top-level anchor), `Strategy` (mid-tier coordinated set), `Ask` (individual solicitation). |
| `Suggested_Name__c` | Suggested Name | Text | Default `Campaign.Name`. Supports `{yearLabel}` (e.g. FY26) and `{yearShort}` (e.g. 26) placeholder tokens expanded by Apex at insert. |
| `Applicable_Models__c` | Applicable Models | Text | Semicolon-separated models this template appears in: `Seasonal`, `GivingPrograms`, `Strategy`. Apex/Flow use substring matching (`LIKE '%model%'`) — avoid values that are substrings of one another. |
| `Default_In_Model__c` | Default In Model | Text | Subset of `Applicable_Models__c`. Templates listed here are pre-checked as defaults in the setup wizard for that model. |
| `Function_Group__c` | Function Group | Picklist | Fundraising function for grouping in the setup wizard picker: Acquisition, Retention, Solicitation, Events, Foundation, PlannedGiving. |
| `Date_Rule__c` | Date Rule | Picklist | Token consumed by `FQS_CampaignHierarchyBuilder` to compute `StartDate` / `EndDate` from the fiscal year window (e.g. `mar-may`, `oct-dec`, `evergreen`, `full-window`). |
| `Parent_Template_Key__c` | Parent Template Key | Text | `Template_Key__c` of this record's parent template. Blank for top-level Rollup records. Some templates have model-specific parent overrides in the Apex builder's `MODEL_PARENT_OVERRIDES` map. |
| `Display_Label__c` | Display Label | Text | Label shown in the setup wizard tactical picker: "Suggested Name (under Parent Name)". Not used for `Campaign.Name`. |
| `Sort_Order__c` | Sort Order | Number | Ascending display order within a setup wizard section. |
| `Notes__c` | Notes | LongTextArea | Author notes for metadata maintainers. Not surfaced in the setup wizard UI. |

### Records (53 total — by function group)

**Rollup templates** (6) — top-level organizing anchors for the GivingPrograms model

| Developer Name | Label | Function Group | Models |
|---|---|---|---|
| `Prg_Annual_Giving` | Annual Giving | Solicitation | GivingPrograms |
| `Prg_Events` | Events | Events | GivingPrograms |
| `Prg_Foundation_Giving` | Foundation Giving | Foundation | GivingPrograms |
| `Prg_Major_Gifts` | Major Gifts | Solicitation | GivingPrograms |
| `Prg_Online_Giving` | Online Giving | Acquisition | GivingPrograms |
| `Prg_Planned_Giving` | Planned Giving | PlannedGiving | GivingPrograms |

**Strategy templates** (12) — mid-tier coordinated campaign sets

| Developer Name | Label | Function Group | Models |
|---|---|---|---|
| `Str_Annual_Celebration` | Annual Celebration | Events | Seasonal |
| `Str_Foundation_Giving` | Foundation Giving | Foundation | Seasonal, Strategy |
| `Str_Lapsed_Reactivation` | Lapsed Donor Reactivation | Retention | Strategy |
| `Str_Mid_Level_Cultivation` | Mid-Level Donor Cultivation | Solicitation | Strategy |
| `Str_Monthly_Sustainer` | Monthly Sustainer Drive | Retention | Seasonal |
| `Str_New_Donor_Acquisition` | New Donor Acquisition | Acquisition | Strategy |
| `Str_Retention_Stewardship` | Retention and Stewardship | Retention | Strategy |
| `Str_Spring_Appeal` | Spring Appeal | Solicitation | Seasonal |
| `Str_Year_Cohort` | Year Cohort | Solicitation | GivingPrograms |
| `Str_Year_End_Push` | Year-End Push | Solicitation | Seasonal |

**Ask templates** (35) — individual solicitation tactics

| Developer Name | Label | Function Group | Parent | Date Rule |
|---|---|---|---|---|
| `Acq_Digital_Ads` | New Donor Digital Ads | Acquisition | New Donor Acquisition | full-window |
| `Acq_P2p_Drive` | Peer-to-Peer Fundraising Drive | Acquisition | Online Giving | mar-may |
| `Acq_Peer_Referral` | New Donor Peer Referral Drive | Acquisition | New Donor Acquisition | jan-mar |
| `Acq_Welcome_Series` | New Donor Welcome Series Email | Acquisition | New Donor Acquisition | evergreen |
| `Evt_Celebration_Invite` | Annual Celebration Invitation and RSVP | Events | Annual Celebration | sep-nov |
| `Evt_Celebration_Savedate` | Annual Celebration Save-the-Date Email | Events | Annual Celebration | jul-aug |
| `Evt_Celebration_Sponsor` | Annual Celebration Sponsorship Packet | Events | Annual Celebration | sep-nov |
| `Evt_Donor_Reception` | Donor Appreciation Reception | Events | Events | may-jun |
| `Evt_Open_House` | Community Open House | Events | Events | feb |
| `Fnd_Community_Proposal` | Community Foundation Proposal | Foundation | Foundation Giving | aug-oct |
| `Fnd_Corporate_Proposal` | Corporate Foundation Proposal | Foundation | Foundation Giving | jan-mar |
| `Fnd_Corporate_Sponsorship` | Corporate Sponsorship Solicitations | Foundation | Foundation Giving (GivingPrograms) | jul-aug |
| `Fnd_Daf_Outreach` | Donor-Advised Fund Outreach | Foundation | Foundation Giving (GivingPrograms) | oct-dec |
| `Fnd_Family_Proposals` | Family Foundation Proposals | Foundation | Foundation Giving (GivingPrograms) | full-window |
| `Pg_Bequest_Society` | Bequest Society Recognition Notes | PlannedGiving | Planned Giving | may-jun |
| `Pg_Estate_Webinar` | Estate Planning Webinar Invitation | PlannedGiving | Planned Giving | sep-nov |
| `Pg_Legacy_Outreach` | Legacy Circle Outreach | PlannedGiving | Planned Giving | mirrors-parent |
| `Ret_Anniversary_Notes` | Recurring Donor Anniversary Notes | Retention | Retention & Stewardship | evergreen |
| `Ret_Impact_Report` | Impact Report Mailing | Retention | Retention & Stewardship | sep-nov |
| `Ret_Lapsed_Last_Chance` | Lapsed Last-Chance Email | Retention | Lapsed Reactivation | may-jun |
| `Ret_Lapsed_Phone` | Lapsed Personal Phone Call | Retention | Lapsed Reactivation | q2 |
| `Ret_Lapsed_Winback` | Lapsed Winback Postcard | Retention | Lapsed Reactivation | q1 |
| `Ret_Second_Gift` | Second-Gift Follow-Up | Retention | Retention & Stewardship | evergreen |
| `Sol_Dec_Reminder_Sms` | Year-End December Reminder SMS | Solicitation | Year-End Push | dec-28-31 |
| `Sol_Discovery_Visits` | Prospect Discovery Visits | Solicitation | Major Gifts | jul-dec |
| `Sol_Giving_Tuesday` | Year-End Giving Tuesday Email | Solicitation | Year-End Push | dec-2-send |
| `Sol_Mid_Level_Letter` | Mid-Level Personal Update Letter | Solicitation | Mid-Level Cultivation | oct-plus-apr |
| `Sol_Mid_Level_Site_Visit` | Mid-Level Site Visit Invitations | Solicitation | Mid-Level Cultivation | mirrors-parent |
| `Sol_Monthly_Sustainer_Lp` | Sustainer Recruitment Landing Page | Solicitation | Monthly Sustainer Drive | mirrors-parent |
| `Sol_Portfolio_Solicitation` | Portfolio Solicitations | Solicitation | Major Gifts | mirrors-parent |
| `Sol_Spring_Dm` | Spring Appeal Direct Mail | Solicitation | Spring Appeal | mar-may |
| `Sol_Spring_Email` | Spring Appeal Email | Solicitation | Spring Appeal | mar-may |
| `Sol_Sustainer_Recruitment` | Monthly Sustainer Recruitment | Solicitation | Online Giving | mirrors-parent |
| `Sol_Yearend_Dm` | Year-End Direct Mail Appeal | Solicitation | Year-End Push | nov-dec |
| `Sol_Sustainer_Recruitment` | Monthly Sustainer Recruitment | Solicitation | Online Giving | mirrors-parent |

---

## FQS_Donor_Tier__mdt

Custom metadata type that drives all FQS donor grouping logic — donor tier thresholds, tier labels, stewardship routing, and credit type. Configure via **Setup → Custom Metadata Types → FQS Donor Tier** or via the **FQS Setup Tier Thresholds** and **FQS Setup Stewardship Response Settings** screen flows. Changes take effect retroactively across all DGS, GiftCommitment, and GiftTransaction formula fields — no redeploy or batch job required.

### Fields

| API Name | Label | Type | Notes |
|---|---|---|---|
| `Tier_Key__c` | Tier Key | Picklist | Generic tier key: `Entry`, `Mid`, `Major`. Must match the record's DeveloperName for formula evaluation consistency. |
| `Branded_Name__c` | Branded Name | Text(255) | Org-specific display name (e.g. "Friend", "Partner", "Champion"). Changing this value automatically updates `FQS_*_Donor_Level_Name__c` on all DGS records. |
| `One_Time_Min_Amount__c` | One-Time Minimum Amount | Number | Minimum single-transaction amount (inclusive) to qualify for this tier. Used in `FQS_Is_*_Gift__c` formula fields on GiftTransaction. |
| `Annual_Min_Amount__c` | Annual Minimum Amount | Number | Minimum annual giving total (inclusive) to qualify for this tier. Used in `FQS_Annual_Donor_Level__c` formula on DGS. |
| `Lifetime_Min_Amount__c` | Lifetime Minimum Amount | Number | Minimum lifetime giving total (inclusive) to qualify for this tier. Used in `FQS_Lifetime_Donor_Level__c` formula on DGS and the three `FQS_Is_*_Commitment__c` formulas on GiftCommitment. |
| `Sort_Order__c` | Sort Order | Number | Display-only. Formula evaluation uses minimum-amount comparisons, not this sort order. |
| `FQS_Auto_Stewardship__c` | Auto Stewardship | Picklist | Controls stewardship routing in `FQS_Stewardship_Response`. Values: `Include All` (auto-email), `Exclude Lifetime` (auto-email unless lifetime Major donor), `Exclude All` (always create Task). Governs the stewardship follow-up ~14 days after acknowledgement — **not** the acknowledgement itself. |
| `Credit_Type__c` | Credit Type | Picklist | Determines whether soft credits count toward tier qualification. `Hard Credits Only`: only the donor's own gifts. `Hard + Soft Credits`: also includes `TotalSoftCreditsAmount` / `CurrentYearSoftCreditsAmount`. Configurable per tier. Default: `Hard Credits Only`. |

### Seeded records

| Developer Name | Branded Name | One-Time Min | Annual Min | Lifetime Min | Auto Stewardship | Credit Type |
|---|---|---|---|---|---|---|
| `Entry` | Friend | $1 | $100 | $500 | Include All | Hard Credits Only |
| `Mid` | Partner | $250 | $3,000 | $15,000 | Exclude Lifetime | Hard Credits Only |
| `Major` | Champion | $500 | $5,000 | $25,000 | Exclude All | Hard Credits Only |
