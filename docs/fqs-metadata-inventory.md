# FQS Metadata Inventory

Canonical inventory for the Fundraising Quick Start (FQS) unmanaged package — shipping status and full by-type index.

For the feature-oriented view ("what ships to power feature X?") see [fqs-feature-inventory.md](fqs-feature-inventory.md).

`Referenced by` (§II only) uses a bounded search (`\b<api-name>\b`) across `force-app/main/default/`. When a category has ≤ 2 named consumers, the names appear; when it has more, the cell shows the count (e.g., `flow x5`).

**Scope.** Everything under `force-app/main/default/` that is not in `.forceignore`, plus a call-out for the `.deferred/` and `.forceignore`'d items so this doc stays complete. Two features are deferred from v1.0 scope: `FQS_Manage_Gift_Commitment_Actions` and the `FQS_Match*` corporate-matching-gift Apex trio (parked under `.deferred/v1.1-match-feature/`). `FQSSeedGenerator.cls` is a dev-only seed script and `.forceignore`d. See §I.3 for the full excluded list.

## Table of contents

### §I. Shipping status

- [I.1 Legend](#i1-legend) — the four shipping states
- [I.2 What's in the package](#i2-whats-in-the-package)
- [I.3 What's in the repo but NOT in the package](#i3-whats-in-the-repo-but-not-in-the-package)

### §I. By type

1. [Custom fields on standard and Fundraising Cloud objects](#ii1-custom-fields-on-standard-and-fundraising-cloud-objects)
2. [Custom metadata types](#ii2-custom-metadata-types)
3. [Flows](#ii3-flows)
4. [FlexiPages](#ii4-flexipages)
5. [Apps, tabs, quick actions](#ii5-apps-tabs-quick-actions)
6. [Apex classes](#ii6-apex-classes)
7. [Permission sets](#ii7-permission-sets)
8. [Reports, dashboards, report types](#ii8-reports-dashboards-report-types)
9. [Global value sets, standard value sets, custom permissions](#ii9-global-value-sets-standard-value-sets-custom-permissions)
10. [Supporting metadata](#ii10-supporting-metadata)
11. [Aggregated unreferenced findings](#ii11-aggregated-unreferenced-findings)

## §I. Shipping status

FQS ships as an **unmanaged package** built from `manifest/package.xml`. Not everything in the repo is in the package — some files are dev-only, deferred to a later release, or blocked by a platform quirk that forces an alternate install path. This section is the authoritative "what actually gets deployed" view.

### I.1 Legend

Every §II.1–§II.10 row falls into one of four shipping states. Where it matters, the state is called out inline (e.g., "*not in package — deferred to v1.1*"). Anything not marked is **shipped**.

| State | Meaning | Where the file lives |
|---|---|---|
| **shipped** | Included in `manifest/package.xml`; installs automatically with the unmanaged package. | `force-app/main/default/` |
| **shipped — manual step** | In the source tree and referenced by README, but the platform rejects the source-format deploy so admins install it via Setup UI or Tooling API after the package lands. | `force-app/main/default/` + a documented manual step |
| **deferred** | In the repo but excluded from deploys via `.forceignore`; parked for a future release. | `.deferred/v1.1-match-feature/` |
| **dev-only** | Excluded from deploys via `.forceignore`; supports development, testing, or seeding. Never installed in a customer org. | mixed |

### I.2 What's in the package

Counted from `manifest/package.xml` (`<version>66.0</version>`) — 30 metadata types:

| Type | Count | Examples |
|---|---:|---|
| `ActionPlanTemplate` | 2 | `FQS_Moves_Management`, `FQS_Stewardship` |
| `ApexClass` | 4 | `FQS_CampaignHierarchyBuilder` (+ test), `FQS_CustomMetadataSaver` (+ test) |
| `BusinessProcess` | 2 | `Opportunity.FQS Grant Process`, `Opportunity.FQS_Major_Gift_Process` |
| `CompactLayout` | 3 | Account, Campaign, PersonAccount |
| `CustomApplication` | 1 | `FQS_Console` |
| `CustomField` | 175 | FQS_*__c fields (~90) + FQS help-text overlays on standard fields (70) |
| `CustomMetadata` | 53 | 50 `FQS_Campaign_Template` rows + 3 `FQS_Donor_Tier` rows |
| `CustomObject` | 7 | Two custom (`FQS_Campaign_Template__mdt`, `FQS_Donor_Tier__mdt`) + five standard objects FQS extends |
| `CustomPermission` | 2 | `FQS_Bypass_Automation`, `FQS_Skip_Record_Naming` |
| `Dashboard` + `DashboardFolder` | 1 + 1 | `FQS_Donor_Tiers` in `FQSDashboards` |
| `DuplicateRule` | 3 | Account (Organization + Person) + Contact warn-not-block rules |
| `EmailTemplate` + `EmailFolder` | 3 + 1 | Two acknowledgement + one stewardship template in `FQS_Templates` |
| `FlexiPage` | 21 | 20 record pages + 1 home page + 1 utility bar |
| `Flow` | 35 | 14 screen flows + 15 record-triggered + 2 scheduled + 2 auto-launched + 2 setup flows |
| `FundraisingConfig` | 1 | Org-wide `FundraisingConfig` |
| `GiftEntryGridTemplate` | 4 | Individual, Pledge Payments, Single-Payment Pledges, Event Registrations |
| `GlobalValueSet` | 3 | `FQS_Gift_Transaction_Category`, `FQS_Match_Status`, `FQS_Stewardship_Status` |
| `Group` | 1 | `FQS_Fundraisers` public group |
| `Layout` | 9 | Minimal Classic layouts for record-type + business-process assignments |
| `ListView` | 68 | Segmentation across 16 objects |
| `MatchingRule` | 3 | Account × 2 (Organization fuzzy, External Id exact), Contact × 1 |
| `PathAssistant` | 4 | Campaign, GiftCommitment, GiftRefund, GiftTransaction |
| `PermissionSet` | 7 | See §II.7 |
| `QuickAction` | 6 | Account, Campaign, GiftCommitment, GiftTransaction, Opportunity |
| `Queue` | 4 | Executive Fundraising, Gift Processing, Major Donor, Stewardship |
| `RecordType` | 3 | `Campaign.FQS_Fundraising`, `Opportunity.Grant`, `Opportunity.Major_Gift` |
| `Report` + `ReportFolder` | 11 + 2 | Donor-tier / stewardship reports + record-page embedded reports |
| `ReportType` | 5 | Campaign, GiftDesignation, DGS, GC, GT deluxe types |
| `StandardValueSet` | 2 | `GiftBatchScreenTempName`, `OpportunityStage` (overrides Salesforce-shipped picklists) |
| `UiFormatSpecificationSet` | 1 | `Value_Matches_Expected` on GiftBatch |

**Not counted in the 30 above** — the `FQS_Rollup_DPE_Read` permission set (shipped 2026-08-19) is in the repo but has not been added to `manifest/package.xml` yet. Add before v1.0 release; see [`.planning/fqs-release-readiness.md`](../.planning/fqs-release-readiness.md).

### I.3 What's in the repo but NOT in the package

| Item | State | Reason | Install path |
|---|---|---|---|
| `.deferred/v1.1-match-feature/classes/FQS_MatchCandidate.cls` | deferred | Corporate matching-gift service parked for v1.1. | Ships in a future release. |
| `.deferred/v1.1-match-feature/classes/FQS_MatchCandidateService.cls` | deferred | " | " |
| `.deferred/v1.1-match-feature/classes/FQS_MatchCommitService.cls` | deferred | " | " |
| `.deferred/v1.1-match-feature/classes/FQS_MatchServices_Test.cls` | deferred | Coverage for the three Match classes. | " |
| `.deferred/v1.1-match-feature/flows/FQS_Manage_Gift_Commitment_Actions.flow-meta.xml` | deferred | State-aware router flow over Fund Cloud's managed subflows; deferred pending §II.5 open question resolution. See [fqs-flow-overview.md §FQS Coordinate Gift Commitment Processing](fqs-flow-overview.md). | " |
| `force-app/main/default/classes/FQSSeedGenerator.cls` | dev-only | Seed-data generator used for testing / dev only. `.forceignore`d. | Never ships. |
| `force-app/main/default/fieldMappingConfigs/FieldMappingConfig.fieldMappingConfig-meta.xml` | shipped — manual step | Source-format deploy fails at v66/67 with `ConversionError: Missing processType on FieldMappingConfigItem`. `**/fieldMappingConfigs/**` is `.forceignore`d. Canonical file is retained as source of truth. | Setup UI — see README §IV.8. (Tooling API path archived in `docs/archive/fqs-fieldmappingconfig-install.md`.) |
| Standard help-text fields (README §Standard Field Help-Text Overlays) | shipped — manual step | Six standard Fundraising fields whose FQS-authored inline help was rejected by the platform. | Setup UI paste — see [docs/manual-help-text-setup.md](manual-help-text-setup.md). |
| `.forceignore` overrides listed in `.forceignore` | excluded | 100+ standard object fields, standard list views, and standard web links that FQS does not customize but that `sf project retrieve start` would otherwise pull in. | Never ships. |



## §II. By type

This is the machine-verifiable inventory. Every FQS-owned metadata item shipped in the repo appears in one of §II.1–§II.10, grouped by kind. §II.11 aggregates the `⚠ unreferenced` cells surfaced by the bounded-name search — some are dead code, some are user-assigned in-org (permsets, path assistants, action plan templates) and expected to lack cross-references. §II.1 is an API-name list only — see [fqs-data-dictionary.md](fqs-data-dictionary.md) for field details.

### II.1 Custom fields on standard and Fundraising Cloud objects
### II.1 Custom fields on standard and Fundraising Cloud objects

See [fqs-data-dictionary.md](fqs-data-dictionary.md) for labels, types, required flags, and field-level notes.

**FQS-prefix custom fields (`FQS_*__c`):**

`Account`: `FQS_Is_Match_Intermediary__c`, `FQS_Match_Annual_Individual_Maximum__c`, `FQS_Match_Ratio__c`, `FQS_Matching_Gift_Program__c`

`Campaign`: `FQS_Campaign_Category__c`, `FQS_Child_Campaign_Count__c`, `FQS_Create_First_Outreach_Source_Code__c`, `FQS_Enable_Auto_Members__c`, `FQS_Hierarchy_Depth__c`, `FQS_Short_Name__c`, `FQS_Ultimate_Parent_Campaign__c`

`DonorGiftSummary`: `FQS_Annual_Donor_Level_Name__c`, `FQS_Annual_Donor_Level__c`, `FQS_Is_Entry_Annual_Donor__c`, `FQS_Is_Entry_Lifetime_Donor__c`, `FQS_Is_Major_Annual_Donor__c`, `FQS_Is_Major_Lifetime_Donor__c`, `FQS_Is_Mid_Annual_Donor__c`, `FQS_Is_Mid_Lifetime_Donor__c`, `FQS_Legacy_First_Gift_Date__c`, `FQS_Legacy_Gift_Count__c`, `FQS_Legacy_Soft_Credit_Total__c`, `FQS_Legacy_Total_Gifts_Amount__c`, `FQS_Lifetime_Donor_Level_Name__c`, `FQS_Lifetime_Donor_Level__c`

`GiftCommitment`: `FQS_Gift_Commitment_Category__c`, `FQS_Is_Entry_Commitment__c`, `FQS_Is_Major_Commitment__c`, `FQS_Is_Mid_Commitment__c`, `FQS_Match_Eligible__c`, `FQS_Restriction_Release_Date__c`, `FQS_Skip_Naming__c`, `FQS_Summary__c`

`GiftDefaultDesignation`: `FQS_Parent_Type__c`, `FQS_Restriction_Type__c`

`GiftDefaultSoftCredit`: `FQS_Parent_Type__c`

`GiftDesignation`: `FQS_Restriction_Type__c`

`GiftEntry`: `FQS_Donor_Tax_Date__c`, `FQS_Fair_Market_Value_Amount__c`, `FQS_GC_Match_Eligible__c`, `FQS_GC_Restriction_Release_Date__c`, `FQS_GC_Skip_Naming__c`, `FQS_GT_Restriction_Release_Date__c`, `FQS_GT_Skip_Naming__c`, `FQS_Gift_Transaction_Category__c`, `FQS_Match_Status__c`, `FQS_Stewardship_Date__c`, `FQS_Stewardship_Status__c`, `FQS_Tax_Receipt_Date__c`

`GiftTransaction`: `FQS_Amount_Formatted__c`, `FQS_Donor_Tax_Date__c`, `FQS_Fair_Market_Value_Amount__c`, `FQS_Gift_Transaction_Category__c`, `FQS_In_Kind__c`, `FQS_Is_Entry_Gift__c`, `FQS_Is_Major_Gift__c`, `FQS_Is_Mid_Gift__c`, `FQS_Match_Status__c`, `FQS_Recurring__c`, `FQS_Restriction_Release_Date__c`, `FQS_Skip_Naming__c`, `FQS_Stewardship_Date__c`, `FQS_Stewardship_Status__c`, `FQS_TaxDeduction_Amount_Formatted__c`, `FQS_Tax_Receipt_Date__c`, `FQS_Transaction_Date_LongForm__c`

`GiftTransactionDesignation`: `FQS_Restriction_Type__c`

`Opportunity`: `FQS_Grant_Deadline__c`, `FQS_Grant_Report_Due__c`, `FQS_Skip_Naming__c`, `FQS_Solicitation_Date__c`

`OutreachSourceCode`: `FQS_Message_Channel_Segment__c`, `FQS_Platform__c`

`External_Id__c` on: `Account`, `Campaign`, `DonorGiftSummary`, `GiftCommitment`, `GiftCommitmentSchedule`, `GiftDesignation`, `GiftRefund`, `GiftSoftCredit`, `GiftTransaction`, `GiftTransactionDesignation`, `GiftTribute`, `Opportunity`, `OutreachSourceCode`, `PaymentInstrument` — seed-script upsert key + FundraisingConfig donor matching.

**FQS-owned help-text overlays on standard / Fundraising Cloud fields** (file exists in repo; field is Salesforce-shipped):

`DonorGiftSummary`: `BestGiftYear`, `BookedPledges`, `CompositeRfmScore`, `CurrentYearSoftCreditsAmount`, `FrequencyScore`, `GiftsThisYearAmount`, `GivingLevel`, `MonetaryScore`, `RecencyScore`, `TotalBookableRevenue`, `TotalPaidRcrInstallments`, `TotalPaidRcrInstlAmt`

`GiftCommitment`: `CampaignId`, `CurrentGiftCmtScheduleId`, `ExpectedTotalCmtAmount`, `FormalCommitmentType`, `FulfillmentType`, `RecurrenceType`, `ScheduleType`

`GiftCommitmentSchedule`: `CommitmentUpdateReason`, `GiftCommitmentStatus`, `PaymentMethod`, `TransactionAmount`, `TransactionDay`, `TransactionPeriod`, `Type`

`GiftDefaultDesignation`: `GiftDesignationId`

`GiftDesignation`: `IsActive`, `IsDefault`

`GiftSoftCredit`: `Role`

`GiftTransaction`: `AcknowledgementDate`, `AcknowledgementStatus`, `CampaignId`, `CurrentAmount`, `GiftType`, `Name`, `NonTaxDeductibleAmount`, `OriginalAmount`, `OutreachSourceCodeId`, `PaymentIdentifier`, `PaymentMethod`, `Status`, `TaxDeductionAmount`, `TaxReceiptStatus`, `TransactionDate`, `TransactionDueDate`

`GiftTransactionDesignation`: `GiftDesignationId`

`GiftTribute`: `HonoreeContactId`, `TributeType`

`Opportunity`: `Amount`, `CloseDate`, `ExpectedRevenue`, `Probability`

`OutreachSourceCode`: `AudienceCount`, `MessageChannel`, `MessageChannelPlatform`, `MessageChannelPlatformAccount`, `SourceCode`, `SourceCodeUrl`, `Status`, `UsageType`

`OutreachSummary`: `AttributedAmount`, `DonorCount`, `GiftCount`, `OnetimeDonorCount`, `RecurringDonorCount`, `ResponseRate`, `TotalGiftTransactionAmount`, `TotalOnetimeGiftAmount`, `TotalRecurringGiftAmount`


### II.2 Custom metadata types

Three FQS-owned custom metadata types. All are Setup-editable through the FQS Setup screens on the Home page.


#### `FQS_Campaign_Hierarchy_Setup__mdt`

State-of-record for the last Campaign Hierarchy Setup run — chosen model, top-level Campaign id, per-model created-Ids JSON, last ask-creation choice, and last-run timestamp. Read/written by `FQS_CampaignHierarchyBuilder`.

| Field | Type |
|---|---|
| `All_Created_Top_Level_Ids_JSON__c` | LongTextArea |
| `Chosen_Model__c` | Picklist |
| `Last_Ask_Creation_Choice__c` | Checkbox |
| `Last_Run_At__c` | DateTime |
| `Last_Top_Level_Id__c` | Text |

#### `FQS_Campaign_Template__mdt`

Blueprint rows for the Campaign Hierarchy Setup catalog. Each row is one campaign template (display label, suggested name, sort order, function group, hierarchy level, date-rule, applicable fundraising models, default-in-model flag, parent template key). `FQS_CampaignHierarchyBuilder` reads this catalog to construct the campaign hierarchy for the chosen fundraising model.

| Field | Type |
|---|---|
| `Applicable_Models__c` | Text |
| `Date_Rule__c` | Picklist |
| `Default_In_Model__c` | Text |
| `Display_Label__c` | Text |
| `Function_Group__c` | Picklist |
| `Level__c` | Picklist |
| `Notes__c` | LongTextArea |
| `Parent_Template_Key__c` | Text |
| `Sort_Order__c` | Number |
| `Suggested_Name__c` | Text |
| `Template_Key__c` | Text |

**Records (53):** seven strategic-level rollup templates (`Str_*`); ten program templates (`Prg_*`); and 36 tactical templates spanning acquisition (`Acq_*`), solicitation (`Sol_*`), retention (`Ret_*`), foundation (`Fnd_*`), planned giving (`Pg_*`), event (`Evt_*`), and advocacy (`Adv_*`) shapes.

#### `FQS_Donor_Tier__mdt`

Editable tier thresholds and branded-name overrides for the three donor bands (`Entry` → "Friend", `Mid` → "Partner", `Major` → "Champion"). Governs every `FQS_Is_*_Donor__c` / `FQS_Is_*_Gift__c` / `FQS_Is_*_Commitment__c` boolean formula. Edited via `FQS_Setup_Tier_Thresholds` + `FQS_Setup_Stewardship_Response_Settings` flows.

| Field | Type |
|---|---|
| `Annual_Min_Amount__c` | Number |
| `Branded_Name__c` | Text |
| `Credit_Type__c` | Picklist |
| `FQS_Auto_Stewardship__c` | Picklist |
| `Lifetime_Min_Amount__c` | Number |
| `One_Time_Min_Amount__c` | Number |
| `Sort_Order__c` | Number |
| `Tier_Key__c` | Picklist |

**Records (3):** `Entry` (Friend), `Mid` (Partner), `Major` (Champion). Threshold values are the seed defaults — orgs edit them in-place via the FQS Setup screen.


### II.3 Flows

Organized by trigger family. `Runs on` shows the object + record-trigger type for automation flows; `Purpose` is the first sentence of the flow's shipped description.


#### Screen flows (user-facing)

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Acknowledgement_Stewardship_Tax_Guide` | Flow | Read-only informational Screen Flow that paginates the acknowledgement / stewardship / tax-receipting decision guide (docs/acknowledgement-stewardship-tax-receipting.md) into a wal | flexipage: FQS_Home_Page_Default |
| `FQS_Campaign_Hierarchy_Setup` | `FQS_Campaign_Template__mdt` | Runs after each per-year Build_Hierarchy call inside Loop_Year_Builds. | flexipage: FQS_Home_Page_Default; permset: FQS_Custom_Fields; class: FQS_CampaignHierarchyBuilder; object: FQ… |
| `FQS_Create_Gift_Batch` | `GiftBatch` | Home-page launcher that creates a new GiftBatch from three inputs: template (radio with fuller descriptions than the raw picklist labels), estimated value, and estimated gift count | flexipage: FQS_Home_Page_Default; flow: FQS_Acknowledgement_Stewardship_Tax_Guide |
| `FQS_Guided_Gift_Entry_Account` | `Account` | Synchronously invokes the platform&apos;s processGiftCommitment standard action on the just-created GC after the N Yearly N=1 GCSs land via Create_GCS_Custom. | flexipage: Fundraising_Quick_Start_UtilityBar1; flow x4; quickAction: Account.FQS_Guided_Gift_Entry |
| `FQS_Guided_Gift_Entry_GiftCommitment` | Flow | Bare-bones passthrough. | flow: FQS_Guided_Gift_Entry_Account, FQS_Guided_Gift_Entry_HomePage; quickAction: GiftCommitment.FQS_Pledge_P… |
| `FQS_Guided_Gift_Entry_HomePage` | Flow | Universal entry point for the FQS Guided Gift Entry suite. | flexipage: FQS_Home_Page_Default |
| `FQS_Guided_Gift_Entry_Opportunity` | `Opportunity` | Opportunity-surface purposeful launcher for the FQS Guided Gift Entry suite. | quickAction: Opportunity.FQS_Setup_Commitment |
| `FQS_Guided_Gift_Entry_Subflow_Campaign_Designation_Resolver` | `GiftDefaultDesignation` | Resolves the Campaign and GiftDesignation for a gift, then returns to the caller monolith. | flow: FQS_Guided_Gift_Entry_Account |
| `FQS_Guided_Gift_Entry_Subflow_Employer_Match` | `AccountContactRelation` | Phase G2. | flow: FQS_Guided_Gift_Entry_Account |
| `FQS_Refund_Gift` | `GiftRefund` | Screen flow launched from the Gift Transaction record page via the FQS Refund Gift quick action. | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Refund_Gift_From_Donor; quickAction: GiftTransaction.FQ… |
| `FQS_Refund_Gift_From_Donor` | `GiftRefund` | Copies the datatable&apos;s first-selected-row Id into the pickedGtId variable so downstream Get_GT can filter on it. | quickAction: Account.FQS_Refund_Donor_Gift |
| `FQS_Setup_Stewardship_Response_Settings` | `FQS_Donor_Tier__mdt` | FQS Setup Flow — stewardship response routing only. | flexipage: FQS_Home_Page_Default; flow: FQS_Setup_Tier_Thresholds |
| `FQS_Setup_Tier_Thresholds` | `FQS_Donor_Tier__mdt` | FQS Setup Flow — donor tier thresholds only. | flexipage: FQS_Home_Page_Default; flow: FQS_Setup_Stewardship_Response_Settings |
| `FQS_Suggest_Designations` | `GiftDesignation` | Setup-time Screen Flow that seeds a starter Gift Designation catalog. | flexipage: FQS_Home_Page_Default; flow: FQS_Guided_Gift_Entry_Account |

#### Record-triggered — before save

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Auto_Category_Gift_Transaction` | `GiftCommitment` · Create | Assigns the derived FQS_Gift_Transaction_Category__c back onto the in-flight GT. | flow: FQS_Guided_Gift_Entry_Account; field: FQS_Gift_Commitment_Category__c, FQS_Gift_Transaction_Category__c |
| `FQS_Auto_Name_Gift_Commitment` | `Account` · CreateAndUpdate | Assigns the computed Name back onto the in-flight record. | ⚠ unreferenced |
| `FQS_Auto_Name_Gift_Transaction` | `Account` · CreateAndUpdate | Assigns the computed Name back onto the in-flight record. | flow: FQS_Guided_Gift_Entry_Account; field: Name |
| `FQS_Auto_Name_Opportunity` | `Account` · CreateAndUpdate | Assigns the computed Name back onto the in-flight record. | ⚠ unreferenced |

#### Record-triggered — after save

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Campaign_Auto_Members_Default` | `Campaign` · Create | Fundraising Quick Start: on Campaign insert, defaults FQS_Enable_Auto_Members__c to TRUE for Tactical-level campaigns (Hierarchy Depth &gt;= 3). | field: FQS_Enable_Auto_Members__c |
| `FQS_Campaign_Child_Count_Update` | `Campaign` · CreateAndUpdate | Resets varNewParentCount to 0, then sets it to the count of direct children found under the new parent. | flow: FQS_Campaign_Member_Status_On_Gift_Transaction; permset: FQS_Custom_Fields; field: FQS_Child_Campaign_C… |
| `FQS_Campaign_Create_First_OSC` | `OutreachSourceCode` · CreateAndUpdate | Fundraising Quick Start: when FQS_Create_First_Outreach_Source_Code__c flips to true on a Tactical-level Campaign (FQS_Hierarchy_Depth__c &gt;= 3) — either by admin action or by FQ | class: FQS_CampaignHierarchyBuilder; field: FQS_Create_First_Outreach_Source_Code__c |
| `FQS_Campaign_Member_Status_Ladder` | `CampaignMemberStatus` · Create | Gates ladder seeding to Tactical-level campaigns only. | class: FQSSeedGenerator |
| `FQS_Campaign_Member_Status_On_Commitment` | `Account` · CreateAndUpdate | Fundraising Quick Start: keeps CampaignMember.Status in sync with the donor's GiftCommitment lifecycle. | flow: FQS_Campaign_Member_Status_Ladder, FQS_Campaign_Member_Status_On_Commitment_Delete; field: FQS_Enable_A… |
| `FQS_Campaign_Member_Status_On_Gift_Transaction` | `Account` · CreateAndUpdate | Fundraising Quick Start: keeps CampaignMember.Status in sync with the donor's GiftTransaction lifecycle. | flow x3 |
| `FQS_GC_Fulfillment_From_GDD` | `GiftDefaultDesignation` · CreateAndUpdate | Fundraising Quick Start: fires synchronously when a GiftDefaultDesignation whose parent is a GiftCommitment is inserted, or when an existing GDD has its ParentRecordId or GiftDesig | ⚠ unreferenced |
| `FQS_GC_Fulfillment_On_Change` | `GiftCommitment` · CreateAndUpdate | Fundraising Quick Start: fires synchronously on GC insert and on any update where FQS_Restriction_Release_Date__c changes, then delegates to FQS_Recalculate_GC_FulfillmentType. | ⚠ unreferenced |

#### Record-triggered — before delete

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Campaign_Child_Count_Delete` | `Campaign` · Delete | Resets varParentCount to 0, then sets it to the size of the sibling collection. | permset: FQS_Custom_Fields; field: FQS_Child_Campaign_Count__c |
| `FQS_Campaign_Member_Status_On_Commitment_Delete` | `Account` · Delete | Fundraising Quick Start: on GiftCommitment hard-delete, reverts the donor's CampaignMember on the same campaign to the starting ladder rung (Solicited baseline / Registered event) | ⚠ unreferenced |
| `FQS_Campaign_Member_Status_On_Gift_Transaction_Delete` | `Account` · Delete | Fundraising Quick Start: on GiftTransaction hard-delete, reverts the donor's CampaignMember on the same campaign to the starting ladder rung (Solicited baseline / Registered event) | ⚠ unreferenced |
| `FQS_GC_Fulfillment_From_GDD_Delete` | `GiftDefaultDesignation` · Delete | Two gates in one decision. | ⚠ unreferenced |

#### Scheduled flows

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Automatic_Rollup_Updates` | AutoLaunchedFlow | Scheduled flow that runs the Manage Fundraising Definitions invocable action daily to refresh Fundraising rollup summaries (Donor Gift Summary, Outreach Summary, Gift Designation). | ⚠ unreferenced |
| `FQS_Coordinate_Gift_Commitment_Processing` | AutoLaunchedFlow | Calls an action to get the currently enabled version of the gift commitment processing engine. | flow: FQS_Guided_Gift_Entry_Account |
| `FQS_Gift_Acknowledgement` | `Account` | Sends the FQS Gift Acknowledgement template (full deduction) to the donor&apos;s PersonContact using the emailSimple v3 template-aware action. | email: FQS_Gift_Acknowledgement, FQS_Gift_Acknowledgement_Partial; field: AcknowledgementStatus, FQS_Auto_Ste… |
| `FQS_Stewardship_Response` | `Task` | Sends the FQS Stewardship Response (Standard) email template to the donor&apos;s PersonContact using the emailSimple v3 template-aware action. | flow: FQS_Gift_Acknowledgement; email: FQS_Gift_Acknowledgement, FQS_Stewardship_Response_Standard; field: FQ… |

#### Auto-launched subflows

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Guided_Gift_Entry_Subflow_Soft_Credit_Reach` | `Contact` | Seed the candidate-Id accumulator with the ACR-reach Account Ids produced by Transform_ACR_Account_Ids. | flow: FQS_Guided_Gift_Entry_Account |
| `FQS_Recalculate_GC_FulfillmentType` | `GiftCommitment` | Sets varHasRestrictedGD to TRUE and jumps straight to Decide_Fulfillment_Value (skipping remaining loop iterations). | flow x3 |


### II.4 FlexiPages


#### II.4.1 Record pages

Each page is overridden onto its Sobject via `<actionOverrides>` on `FQS_Console`.

| API name | Sobject | Referenced by |
|---|---|---|

#### II.4.2 Home page and utility bar

| API name | Type | Referenced by |
|---|---|---|
| `FQS_Account_Record_Page` | Facet | app: FQS_Console |
| `FQS_Campaign_Record_Page` | Region | object: Campaign; app: FQS_Console |
| `FQS_DonorGiftSummary_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftBatch_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftCmtChangeAttrLog_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftCommitmentSchedule_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftCommitment_Record_Page` | Facet | app: FQS_Console, standard__FundraisingOperationsConsole |
| `FQS_GiftDefaultDesignation_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftDefaultSoftCredit_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftDesignation_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftRefund_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftSoftCredit_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftTransactionDesignation_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftTransaction_Record_Page` | Facet | app: FQS_Console |
| `FQS_GiftTribute_Record_Page` | Facet | app: FQS_Console |
| `FQS_Home_Page_Default` | HomePage | flow: FQS_Create_Gift_Batch, FQS_Guided_Gift_Entry_HomePage; app: FQS_Console |
| `FQS_Opportunity_Record_Page` | Facet | app: FQS_Console |
| `FQS_OutreachSourceCode_Record_Page` | Facet | app: FQS_Console |
| `FQS_OutreachSummary_Record_Page` | Facet | app: FQS_Console |
| `FQS_PaymentInstrument_Record_Page` | Facet | app: FQS_Console |
| `Fundraising_Quick_Start_UtilityBar1` | UtilityBar | app: FQS_Console |


### II.5 Apps, tabs, quick actions

#### II.5.1 Apps

| API name | Nav | Purpose |
|---|---|---|
| `FQS_Console` | Console | Fundraising Quick Start console app — 14 tabs; every FQS record page overrides its Sobject's View action into this app. Utility bar `Fundraising_Quick_Start_UtilityBar1`. |
| `standard__FundraisingOperationsConsole` | Console | Salesforce-shipped Fundraising Operations Console — FQS ships one override so `GiftCommitment` renders `FQS_GiftCommitment_Record_Page`. |

**FQS_Console tabs (14):** `standard-home`, `standard-Account`, `standard-GiftCommitment`, `standard-GiftTransaction`, `standard-Campaign`, `standard-Opportunity`, `standard-GiftDesignation`, `standard-GiftBatch`, `standard-Task`, `standard-ActionPlanTemplate`, `standard-IndustriesCsvDataimport`, `standard-Dashboard`, `standard-report`, `standard-EmailTemplate`.

#### II.5.2 Quick actions

| API name | Purpose | Referenced by |
|---|---|---|
| `Account.FQS_Guided_Gift_Entry` | Launches the Guided Gift Entry monolith with the current Account pre-selected as donor. | flexipage: FQS_Account_Record_Page; flow: FQS_Guided_Gift_Entry_HomePage |
| `Account.FQS_Refund_Donor_Gift` | Launches the Refund Gift From Donor picker so an admin can refund a specific gift from the donor's Account page. | flexipage: FQS_Account_Record_Page |
| `Campaign.Hierarchy_Metrics` | Standard 'Hierarchy Metrics' action retained on Campaign for hierarchy dollar rollups. | flexipage: FQS_Campaign_Record_Page |
| `FQS_New_Grant` | Global quick action to create a Grant Opportunity with the Grant record type pre-selected. | ⚠ unreferenced |
| `FQS_New_Major_Gift` | Global quick action to create a Major Gift Opportunity with the Major Gift record type pre-selected. | ⚠ unreferenced |
| `GiftCommitment.FQS_Pledge_Payment` | Records a pledge payment against the current Gift Commitment via the Guided Gift Entry monolith. | flexipage: FQS_GiftCommitment_Record_Page |
| `GiftTransaction.FQS_Refund_Gift` | Launches the single-gift Refund flow from the Gift Transaction record page. | flexipage: FQS_GiftTransaction_Record_Page |
| `Opportunity.FQS_Setup_Commitment` | Converts an Opportunity into a Gift Commitment via the Guided Gift Entry monolith. | flexipage: FQS_Opportunity_Record_Page; flow: FQS_Guided_Gift_Entry_Opportunity |


### II.6 Apex classes

Unmanaged code under `force-app/main/default/classes/`. `FQSSeedGenerator.cls` is `.forceignore`d and does not ship.

| API name | Role | Purpose | Referenced by |
|---|---|---|---|
| `FQS_CampaignHierarchyBuilder` | Service (invocable) | Builds the multi-model campaign hierarchy from `FQS_Campaign_Template__mdt` rows. Called from `FQS_Campaign_Hierarchy_Setup` flow; writes state back to `FQS_Campaign_Hierarchy_Setup__mdt.Default`. | flow: FQS_Campaign_Create_First_OSC, FQS_Campaign_Hierarchy_Setup; permset: FQS_Custom_Fields; clas… |
| `FQS_CampaignHierarchyBuilder_Test` | Test | Coverage for `FQS_CampaignHierarchyBuilder`. | ⚠ unreferenced |
| `FQS_CustomMetadataSaver` | Service (invocable) | Enqueues an async Metadata API deploy for FQS-owned custom metadata records. Used by the two Setup screen flows so admins can edit `FQS_Donor_Tier__mdt` rows in-flow. | flow: FQS_Setup_Stewardship_Response_Settings, FQS_Setup_Tier_Thresholds; permset: FQS_Custom_Field… |
| `FQS_CustomMetadataSaver_Test` | Test | Coverage for `FQS_CustomMetadataSaver`. | ⚠ unreferenced |
| `FQS_MatchCandidate` | DTO | Simple DTO returned by `FQS_MatchCandidateService.findCandidates()` describing a suggested matching-gift employer relationship. | class: FQS_MatchCandidateService, FQS_MatchServices_Test |
| `FQS_MatchCandidateService` | Service (invocable) | Given a donor Account id, returns match-eligible employer ACRs. Consumed by the Guided Gift Entry employer-match subflow. | permset: FQS_Custom_Fields; class: FQS_MatchCandidate, FQS_MatchServices_Test |
| `FQS_MatchCommitService` | Service (invocable) | Creates the employer-side matching gift commitment when a donor pledge fires the match subflow (ACR resolution, ratio, annual-cap enforcement). | permset: FQS_Custom_Fields; class: FQS_MatchServices_Test |
| `FQS_MatchServices_Test` | Test | Coverage for `FQS_MatchCandidate` / `FQS_MatchCandidateService` / `FQS_MatchCommitService`. | ⚠ unreferenced |


### II.7 Permission sets

| API name | Grants | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Bypass_Automation` | 1 custom perm | Bypass permset for migration/data-loader users. Grants `FQS_Bypass_Automation` custom permission so the three GC-fulfillment RT flows short-circuit. Post-migration run `scripts/apex/fqs-recalc-gc-fulfillmenttype.apex`. | flow x3 |
| `FQS_Campaign_Fields` | 20 field perms | Read/edit FLS on all permissionable standard Campaign fields. | ⚠ unreferenced |
| `FQS_Custom_Fields` | 87 field perms · 1 RT · 4 class accesses | Umbrella permset: FLS on every FQS custom field across Gift objects, plus `Campaign.FQS_Fundraising` record type and the four FQS_Match / FQS_CampaignHierarchyBuilder / FQS_CustomMetadataSaver Apex classes. | ⚠ unreferenced |
| `FQS_Email_Template_Builder_Permission` | Setup entitlement | "Access drag-and-drop content builder" toggle so admins can edit the three FQS email templates in Email Content Builder. | ⚠ unreferenced |
| `FQS_Naming_Opt_Out` | 3 field perms · 1 custom perm | Bypass permset for integration users. Grants `FQS_Skip_Record_Naming` + edit FLS on `FQS_Skip_Naming__c` so the three auto-name flows leave the Name alone. | flow: FQS_Auto_Name_Opportunity |
| `FQS_Person_Account_Fields` | 16 field perms · 2 RTs | Read access to standard PersonAccount fields when Person Accounts are enabled. | class: FQS_MatchServices_Test |
| `FQS_Record_Type_Access` | 3 RT visibilities | Grants `Opportunity.Major_Gift`, `Opportunity.Grant`, `Campaign.FQS_Fundraising` visibility on top of standard profiles. | ⚠ unreferenced |


### II.8 Reports, dashboards, report types

#### II.8.1 Report types

| API name | Base | Purpose | Referenced by |
|---|---|---|---|
| `Campaign_Deluxe` | Campaign→CampaignChildren→GiftTransaction | Cross-level Campaign type used by the record-page reports so grandchild GTs roll up to top-level Campaigns. | report: Campaign_Record_Page_Report_Level1_pWX, Campaign_Record_Page_Report_Level2_zMR |
| `Campaigns_and_Gift_Transactions` | Campaign→GiftTransaction | Baseline Campaign-with-Gift-Transactions type. | report: Campaign_Record_Page_Report_nLT |
| `GiftDesignation_Deluxe` | GiftDesignation→GTD→GiftTransaction | Lets Designation record-page reports show underlying GTs grouped by parent status. | report: GiftDesignation_Record_Page_Report_qKR |
| `fqs_Donor_Gift_Summary_Deluxe` | DonorGiftSummary→Account | Exposes the FQS donor-tier boolean formula fields on DGS. | report x3 |
| `fqs_Gift_Commitments_Deluxe` | GiftCommitment | Surfaces FQS commitment-tier booleans + category. | report: FQS_Major_Commitments_Active |
| `fqs_Gift_Transactions_Deluxe` | GiftTransaction→Campaign | Surfaces FQS gift-tier booleans, category, stewardship status, campaign-hierarchy fields. | report: FQS_Campaign_Performance_By_Depth, FQS_Major_Gifts_This_Year, FQS_Stewardship_Pipeline |

#### II.8.2 Reports

| API name | Folder | Report type | Purpose |
|---|---|---|---|
| `FQS_Campaign_Performance_By_Depth` | FQSDonorTierReports | fqs_Gift_Transactions_Deluxe__c | Total paid-gift dollars grouped by Campaign hierarchy depth (1 rollup to 5 leaf). |
| `FQS_Major_Annual_Donors_This_FY` | FQSDonorTierReports | fqs_Donor_Gift_Summary_Deluxe__c | Donors whose current-fiscal-year giving qualifies for the Major tier. |
| `FQS_Major_Commitments_Active` | FQSDonorTierReports | fqs_Gift_Commitments_Deluxe__c | Active Gift Commitments whose Expected Total Commitment Amount qualifies for the Major tier. |
| `FQS_Major_Gifts_This_Year` | FQSDonorTierReports | fqs_Gift_Transactions_Deluxe__c | Gift Transactions qualifying for the Major tier this year, including installment payments against Major-tier commitments. |
| `FQS_Major_Lifetime_Donors` | FQSDonorTierReports | fqs_Donor_Gift_Summary_Deluxe__c | Donors whose total lifetime giving qualifies for the Major tier. |
| `FQS_Mid_to_Major_Upgrade_Pipeline` | FQSDonorTierReports | fqs_Donor_Gift_Summary_Deluxe__c | Donors who are Mid-tier annual donors but have not yet reached the Major annual threshold. |
| `FQS_Stewardship_Pipeline` | FQSDonorTierReports | fqs_Gift_Transactions_Deluxe__c | Stewardship pipeline health — matrix of Paid contribution GTs (last 6 months) grouped by FQS_Stewardship_Status__c x Category. |
| `Campaign_Record_Page_Report_Level1_pWX` | FQSRecordPageReports | Campaign_Deluxe__c | Roll-up of Gift Transactions from grandchild Campaigns for use on a top-level (Level 1) Campaign record page. |
| `Campaign_Record_Page_Report_Level2_zMR` | FQSRecordPageReports | Campaign_Deluxe__c | Roll-up of Gift Transactions from direct-child Campaigns for use on a mid-level (Level 2) parent Campaign record page. |
| `Campaign_Record_Page_Report_nLT` | FQSRecordPageReports | Campaigns_and_Gift_Transactions__c | Created to provide a report out by campaign hierarchy to enable comparisons to budget and project revenue. |
| `GiftDesignation_Record_Page_Report_qKR` | FQSRecordPageReports | GiftDesignation_Deluxe__c | Sum of Gift Transaction Designation Amount, grouped by parent Gift Transaction Status. |

#### II.8.3 Dashboards + report folders

| API name | Folder | Purpose |
|---|---|---|
| `FQS_Donor_Tiers` | FQSDashboards | FQS Donor Tiers — donor-tier dashboard surfaced from FQS Home. |

**Report folders:** `FQSDonorTierReports` (7 donor-tier + stewardship reports), `FQSRecordPageReports` (4 record-page embedded reports).



### II.9 Global value sets, standard value sets, custom permissions

#### II.9.1 Global value sets

| API name | Purpose | Referenced by |
|---|---|---|
| `FQS_Gift_Transaction_Category` | Classifies gift transaction kind (Outright Gift / Pledge Payment / Recurring Gift Payment / Grant Payment / Other). Shared between `GiftTransaction.FQS_Gift_Transaction_Category__c` and `GiftEntry.FQS_Gift_Transaction_Category__c`. | field: FQS_Gift_Transaction_Category__c |
| `FQS_Match_Status` | Corporate matching-gift lifecycle (Eligible / Request Confirmed / Received / Declined / N/A). Shared between `GiftTransaction.FQS_Match_Status__c` and `GiftEntry.FQS_Match_Status__c`. | field: FQS_Match_Status__c |
| `FQS_Stewardship_Status` | Post-acknowledgement stewardship touch state (To Be Sent / Sent / Don't Send). Shared between `GiftTransaction.FQS_Stewardship_Status__c` and `GiftEntry.FQS_Stewardship_Status__c`. | field: FQS_Stewardship_Status__c |

#### II.9.2 Standard value sets (overrides)

FQS overrides of Salesforce-shipped picklists — ensures the FQS values ship in the package even for fresh orgs.

- `GiftBatchScreenTempName`
- `GiftCommitmentStatus`
- `GiftRefundReason`
- `GiftSoftCreditRole`
- `OpportunityStage`
- `OpportunityType`

#### II.9.3 Custom permissions

| API name | Purpose | Referenced by |
|---|---|---|
| `FQS_Bypass_Automation` | Bypass token. When held by the running user, the three GC-fulfillment RT flows short-circuit their recalc paths. Granted via `FQS_Bypass_Automation` permset. | flow x3; permset: FQS_Bypass_Automation |
| `FQS_Skip_Record_Naming` | Bypass token. When held by the running user, the three auto-name flows skip Name rewrites so integration users preserve upstream-owned Names. Granted via `FQS_Naming_Opt_Out` permset. | flow x3; permset: FQS_Naming_Opt_Out |


### II.10 Supporting metadata

List views (76), layouts, record types, business processes, path assistants, queues + group, action plan templates, gift-entry grid templates, email templates, duplicate/matching rules, compact layouts, the UI format-spec set, FundraisingConfig, and the Gift Entry field-mapping record.


#### II.10.1 List views

| Object | List views |
|---|---|
| `Campaign` (8) | `FQS_Active_Campaigns`, `FQS_All_Fundraising_Campaigns`, `FQS_Annual_Giving_Campaigns`, `FQS_Event_Campaigns`, `FQS_Grants_Campaigns`, `FQS_Major_Gifts_Campaigns`, `FQS_My_Fundraising_Campaigns`, `FQS_Top_Level_Campaigns` |
| `DonorGiftSummary` (3) | `FQS_Current_Year_Givers`, `FQS_Major_Donors`, `FQS_Recurring_Donors` |
| `GiftCmtChangeAttrLog` (3) | `FQS_Downgrades`, `FQS_Paused_Commitments`, `FQS_Upgrades` |
| `GiftCommitment` (5) | `FQS_Grant_Payouts`, `FQS_Lapsed_Recurring`, `FQS_Past_Due_Installments`, `FQS_Pledged_Gifts`, `FQS_Recurring_Gifts` |
| `GiftCommitmentSchedule` (2) | `FQS_Active_Schedules`, `FQS_Completed_Schedules` |
| `GiftDefaultSoftCredit` (4) | `FQS_Gift_Commitment_Defaults`, `FQS_Household_Member_Defaults`, `FQS_Matched_Donor_Defaults`, `FQS_Opportunity_Defaults` |
| `GiftDesignation` (5) | `All_GiftDesignations`, `FQS_Active_Designations`, `FQS_Inactive_Designations`, `FQS_With_Donor_Restriction`, `FQS_Without_Donor_Restriction` |
| `GiftRefund` (3) | `FQS_Completed_Refunds`, `FQS_Failed_Refunds`, `FQS_Initiated_Refunds` |
| `GiftSoftCredit` (4) | `FQS_Honoree_Credits`, `FQS_Matched_Donor_Credits`, `FQS_Soft_Credits`, `FQS_Solicitor_Credits` |
| `GiftTransaction` (11) | `All_GiftTransactions`, `FQS_Failed_Canceled_7d`, `FQS_Grant_Payments`, `FQS_Outright_Gifts`, `FQS_Pledge_Payments`, `FQS_Recurring_Gift_Payments`, `FQS_To_Be_Acknowledged`, `FQS_To_Be_Stewarded`, `FQS_Transaction_Category_Other`, `In_Kind_Gifts`, `To_Be_Stewarded` |
| `GiftTribute` (2) | `FQS_Honor_Tributes`, `FQS_Memorial_Tributes` |
| `Opportunity` (13) | `AllOpportunities`, `ClosingNextMonth`, `ClosingThisMonth`, `Default_Opportunity_Pipeline`, `FQS_Awarded_Grants`, `FQS_Grants`, `FQS_Major_Gifts`, `FQS_Major_Gifts_Closing_30`, `FQS_Major_Gifts_Stale`, `FQS_Pledged_Major_Gifts`, `MyOpportunities`, `NewThisWeek`, `Won` |
| `OutreachSourceCode` (4) | `FQS_Active_Outreach_Codes`, `FQS_Digital_Codes`, `FQS_Direct_Mail_Codes`, `FQS_Email_Codes` |
| `OutreachSummary` (3) | `FQS_Active_Outreach`, `FQS_No_Response`, `FQS_Recurring_Outreach` |
| `PaymentInstrument` (3) | `FQS_Bank_Debit_Instruments`, `FQS_Credit_Card_Instruments`, `FQS_Digital_Wallet_Instruments` |
| `Task` (4) | `FQS_Executive_Fundraising_Tasks_Task`, `FQS_Gift_Acknowledgements_Task`, `FQS_Major_Donor_Research_Task`, `FQS_Stewardship_Response_Task` |

#### II.10.2 Record types

- `Campaign.FQS_Fundraising`
- `Opportunity.Grant`
- `Opportunity.Major_Gift`

#### II.10.3 Compact layouts

- `Account.FQS_Account_Compact_Layout`
- `Campaign.FQS_Campaign_Compact_Layout`
- `PersonAccount.FQS_Person_Account_Compact_Layout`

#### II.10.4 Business processes

- `Opportunity.FQS Grant Process`
- `Opportunity.FQS_Major_Gift_Process`

#### II.10.5 Page layouts

FQS ships Lightning flexipages for the primary UX and a minimal set of classic layouts (mainly to satisfy record-type/business-process assignments). Per memory `fqs-classic-layouts-out-of-scope`, comprehensive Classic coverage is intentionally out of scope.

**Layouts (11):** `Account-Account Layout`, `Account-FQS Account Layout`, `Campaign-FQS Campaign Layout`, `FQS_Campaign_Template__mdt-FQS Campaign Template Layout`, `FQS_Donor_Tier__mdt-FQS Donor Tier Layout`, `GiftCommitment-Gift Commitment Layout`, `GiftDesignation-Gift Designation Layout`, `GiftTransaction-Gift Transaction Layout`, `Opportunity-FQS Opportunity Layout`, `PersonAccount-FQS Person Account Layout`, `PersonAccount-Person Account Layout`.

#### II.10.6 Path assistants

| API name | Object | Purpose |
|---|---|---|
| `FQS_Campaign_Status` | Campaign | Guided path over Campaign Status for the FQS_Fundraising record type. |
| `FQS_GiftCommitment_Status` | GiftCommitment | Guided path over GiftCommitment Status covering the pledge/recurring lifecycle. |
| `FQS_GiftRefund_Status` | GiftRefund | Guided path over GiftRefund Status. |
| `FQS_GiftTransaction_Status` | GiftTransaction | Guided path over GiftTransaction Status. |

#### II.10.7 Queues + Group

| API name | Type | Purpose |
|---|---|---|
| `FQS_Executive_Fundraising_Tasks` | Queue | Used to assign tasks needed to be done by an executive. Allows FQS some flexibility in shipping Action Plans, but also could help organizati |
| `FQS_Gift_Processing_Tasks` | Queue | Used for acknowledgements, tax receipting, and gift entry tasks created by the Moves Management and Stewardship Action Plans. |
| `FQS_Major_Donor_Tasks` | Queue | Used to assign tasks related to research and proposal creation for the Moves Management Action Plan. |
| `FQS_Stewardship_Tasks` | Queue | Used for cultivation tasks by the Stewardship action plan. |
| `FQS_Fundraisers` | Public group | Group used to assign FQS permsets and route Task ownership. |

#### II.10.8 Action plan templates

| API name | Target | Purpose |
|---|---|---|
| `Moves_Management_65c3e74a_90d4_11f1_9ffa_750d1a89e526` | Account | Moves Management — standard task ladder walking a major gift from Identification through Solicitation. Routes to `FQS_Major_Donor_Tasks` + `FQS_Executive_Fundraising_Tasks` queues. |
| `Stewardship_38e8d861_90da_11f1_b64a_f1bc2df97554` | Account | Stewardship — cultivation tasks routed to `FQS_Stewardship_Tasks` queue after a Major-tier gift is booked. |

#### II.10.9 Gift entry grid templates

- `FQS_Event_Registrations`
- `FQS_Individual_Outright_Gifts`
- `FQS_Pledge_Payments`
- `FQS_Single_Payment_Pledges`

#### II.10.10 Email templates

| API name | Subject | Purpose |
|---|---|---|
| `FQS_Gift_Acknowledgement` | Thank you for your gift! | Full-tax-deductible acknowledgement — sent by `FQS_Gift_Acknowledgement` scheduled flow. |
| `FQS_Gift_Acknowledgement_Partial` | Thank you for your gift! | Partial-tax-deductible variant — used when NonTaxDeductibleAmount > 0. |
| `FQS_Stewardship_Response_Standard` | Thanks again — plus a small update | Post-acknowledgement stewardship touch — sent by `FQS_Stewardship_Response` scheduled flow ~14 days after acknowledgement. |

**Email folder:** `FQS_Templates` — public folder holding the three templates above.

#### II.10.11 Duplicate + matching rules

- `Account.FQS_Account_Organization_Dupe`
- `Account.FQS_Account_Person_Dupe`
- `Contact.FQS_Contact_Dupe`
- `Account.matchingRule`
- `Contact.matchingRule`

#### II.10.12 UI format spec, Fundraising Config, Field Mapping Config

- `Value_Matches_Expected`
- `FundraisingConfig`
- `FieldMappingConfig`


### II.11 Aggregated unreferenced findings

Every `⚠ unreferenced` cell from §II.1–§II.10, consolidated. "Unreferenced" means no other file in `force-app/main/default/` names the item via a `\b<api-name>\b` match. That is a signal, not a verdict: some items (permsets, top-level apps, path assistants, action-plan templates) are user-assigned or admin-configured in-org rather than cross-referenced in metadata. Use this list as input for A3's dead-code purge; do not delete without a targeted check.

| Kind | API name | Section |
|---|---|---|
| flow | `FQS_Auto_Name_Gift_Commitment` | §II.3 |
| flow | `FQS_Auto_Name_Opportunity` | §II.3 |
| flow | `FQS_GC_Fulfillment_From_GDD` | §II.3 |
| flow | `FQS_GC_Fulfillment_On_Change` | §II.3 |
| flow | `FQS_Campaign_Member_Status_On_Commitment_Delete` | §II.3 |
| flow | `FQS_Campaign_Member_Status_On_Gift_Transaction_Delete` | §II.3 |
| flow | `FQS_GC_Fulfillment_From_GDD_Delete` | §II.3 |
| flow | `FQS_Automatic_Rollup_Updates` | §II.3 |
| quickAction | `FQS_New_Grant` | §II.5.2 |
| quickAction | `FQS_New_Major_Gift` | §II.5.2 |
| class | `FQS_CampaignHierarchyBuilder_Test` | §II.6 |
| class | `FQS_CustomMetadataSaver_Test` | §II.6 |
| class | `FQS_MatchServices_Test` | §II.6 |
| permset | `FQS_Campaign_Fields` | §II.7 (permsets are user-assigned in-org — expected) |
| permset | `FQS_Custom_Fields` | §II.7 (permsets are user-assigned in-org — expected) |
| permset | `FQS_Email_Template_Builder_Permission` | §II.7 (permsets are user-assigned in-org — expected) |
| permset | `FQS_Record_Type_Access` | §II.7 (permsets are user-assigned in-org — expected) |
| path | `FQS_Campaign_Status` | §II.10.6 (paths are org-config, not cross-referenced — expected) |
| path | `FQS_GiftCommitment_Status` | §II.10.6 (paths are org-config, not cross-referenced — expected) |
| path | `FQS_GiftRefund_Status` | §II.10.6 (paths are org-config, not cross-referenced — expected) |
| path | `FQS_GiftTransaction_Status` | §II.10.6 (paths are org-config, not cross-referenced — expected) |

