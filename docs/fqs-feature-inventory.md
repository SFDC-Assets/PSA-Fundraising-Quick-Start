# FQS Feature Inventory

The "why does FQS ship this?" view. Every component is regrouped under the user-visible capability it supports. A component may appear under more than one feature when it plays a shared role (e.g., `External_Id__c` supports data-import idempotency across every extended object). Deferred (`.deferred/v1.1-match-feature/`) items are called out inline with the feature they belong to.

For the full row-by-row metadata inventory (API names, Referenced by, shipping status) see [fqs-metadata-inventory.md](fqs-metadata-inventory.md).

## Table of contents

1. [Gift Transactions & Gift Commitments guardrails](#i1-gift-transactions--gift-commitments-guardrails)
2. [Grants, Major Gifts & Moves Management](#i2-grants-major-gifts--moves-management)
3. [Restrictions & Suggested Designations](#i3-restrictions--suggested-designations)
4. [Campaign hierarchy & templates](#i4-campaign-hierarchy--templates)
5. [Campaign Members lifecycle](#i5-campaign-members-lifecycle)
6. [Outreach Source Codes & Outreach Summaries](#i6-outreach-source-codes--outreach-summaries)
7. [Gift Batches & Gift Entry templates](#i7-gift-batches--gift-entry-templates)
8. [Guided Gift Entry](#i8-guided-gift-entry)
9. [Donor Gift Summary & Donor Tiers](#i9-donor-gift-summary--donor-tiers)
10. [Acknowledgement, Stewardship & Tax Receipting toolbox](#i10-acknowledgement-stewardship--tax-receipting-toolbox)
11. [Soft Credits & Tributes](#i11-soft-credits--tributes)
12. [Gift Refunds](#i12-gift-refunds)
13. [Data integrity, migration & data import guardrails](#i13-data-integrity-migration--data-import-guardrails)
14. [Standard field help-text overlays](#i14-standard-field-help-text-overlays)
15. [Foundation: app shell, permsets, home page, utility bar](#i15-foundation-app-shell-permsets-home-page-utility-bar)

---

### I.1 Gift Transactions & Gift Commitments guardrails

Data-quality automation on the two central Fundraising objects. Sensible category defaults, in-kind + matched-gift flags, auto-naming, and safe-recalc paths for the Fund Cloud `FulfillmentType` on Gift Commitment so downstream reporting stays consistent as pledges, recurring gifts, and grants evolve. Includes bypass tokens for migration and integration users.

- **Custom fields (GT)** — `FQS_Gift_Transaction_Category__c`, `FQS_In_Kind__c`, `FQS_Matched__c`, `FQS_Match_Status__c`, `FQS_Recurring__c`, `FQS_Is_Entry_Gift__c`, `FQS_Is_Mid_Gift__c`, `FQS_Is_Major_Gift__c`, `FQS_Amount_Formatted__c`, `FQS_TaxDeduction_Amount_Formatted__c`, `FQS_Transaction_Date_LongForm__c`, `FQS_Fair_Market_Value_Amount__c`, `FQS_Skip_Naming__c`
- **Custom fields (GC)** — `FQS_Gift_Commitment_Category__c`, `FQS_Is_Entry_Commitment__c`, `FQS_Is_Mid_Commitment__c`, `FQS_Is_Major_Commitment__c`, `FQS_Match_Eligible__c`, `FQS_Skip_Naming__c`, `FQS_Summary__c`
- **GlobalValueSets** — `FQS_Gift_Transaction_Category`, `FQS_Match_Status`
- **Flows** — `FQS_Auto_Category_Gift_Transaction`, `FQS_Auto_Name_Gift_Transaction`, `FQS_Auto_Name_Gift_Commitment`, `FQS_Auto_Name_Opportunity`, `FQS_GC_Fulfillment_On_Change`, `FQS_GC_Fulfillment_From_GDD`, `FQS_GC_Fulfillment_From_GDD_Delete`, `FQS_Recalculate_GC_FulfillmentType`
- **List views (GT, 9)** — `FQS_Outright_Gifts`, `FQS_Pledge_Payments`, `FQS_Recurring_Gift_Payments`, `FQS_Grant_Payments`, `FQS_In_Kind_Gifts`, `FQS_Failed_Canceled_7d`, `FQS_To_Be_Acknowledged`, `FQS_To_Be_Stewarded`, `FQS_Transaction_Category_Other`
- **List views (GC, 5)** — `FQS_Pledged_Gifts`, `FQS_Recurring_Gifts`, `FQS_Past_Due_Installments`, `FQS_Lapsed_Recurring`, `FQS_Grant_Payouts`
- **List views (GiftCmtChangeAttrLog)** — `FQS_Downgrades`, `FQS_Paused_Commitments`, `FQS_Upgrades`
- **Path assistants** — `FQS_GiftTransaction_Status`, `FQS_GiftCommitment_Status`
- **CustomPermissions** — `FQS_Bypass_Automation` + `FQS_Skip_Record_Naming` (bypass tokens for migration/integration users)
- **PermissionSets** — `FQS_Bypass_Automation`, `FQS_Naming_Opt_Out`
- **ReportTypes** — `fqs_Gift_Transactions_Deluxe`, `fqs_Gift_Commitments_Deluxe`
- **Reports** — `FQS_Major_Gifts_This_Year`, `FQS_Major_Commitments_Active`
- **FlexiPages** — `FQS_GiftTransaction_Record_Page`, `FQS_GiftCommitment_Record_Page`, `FQS_GiftCommitmentSchedule_Record_Page`, `FQS_GiftCmtChangeAttrLog_Record_Page`
- **Deferred (v1.1)** — `FQS_Manage_Gift_Commitment_Actions` (state-aware router over Fund Cloud's managed subflows)
- **Deep-dive docs** — [fqs-flow-overview.md](fqs-flow-overview.md)

### I.2 Grants, Major Gifts & Moves Management

Opportunity-driven grants pipeline and major-gift solicitation flow. Ships two record types + two business processes with their own stages, plus a Moves Management action plan template that lays out the standard Identification→Solicitation task ladder for major-gift work.

- **RecordTypes** — `Opportunity.Grant`, `Opportunity.Major_Gift`
- **BusinessProcesses** — `Opportunity.FQS Grant Process`, `Opportunity.FQS_Major_Gift_Process`
- **StandardValueSet overrides** — `OpportunityStage`, `OpportunityType`
- **Custom fields** — `Opportunity.FQS_Grant_Deadline__c`, `FQS_Grant_Report_Due__c`, `FQS_Solicitation_Date__c`, `FQS_Skip_Naming__c`
- **List views** — `Opportunity.FQS_Awarded_Grants`, `FQS_Grants`, `FQS_Major_Gifts`, `FQS_Major_Gifts_Closing_30`, `FQS_Major_Gifts_Stale`, `FQS_Pledged_Major_Gifts`
- **Quick actions** — `FQS_New_Grant` (global), `FQS_New_Major_Gift` (global)
- **PermissionSet** — `FQS_Record_Type_Access` (RT visibility for Major Gift + Grant + FQS_Fundraising)
- **ActionPlanTemplate** — `Moves_Management_*` (major-gift task ladder — Identification → Qualification → Cultivation → Solicitation)
- **Queues** — `FQS_Executive_Fundraising_Tasks`, `FQS_Major_Donor_Tasks`
- **List views (Task)** — `Task.FQS_Executive_Fundraising_Tasks_Task`, `FQS_Major_Donor_Research_Task`
- **FlexiPage** — `FQS_Opportunity_Record_Page`

### I.3 Restrictions & Suggested Designations

Restricted-vs-unrestricted revenue classification (FASB ASU 2016-14 net-asset classes) applied consistently across Gift Designation, Gift Default Designation, Gift Transaction Designation, and the parent Gift Transaction / Gift Commitment. Includes a Suggested Designations setup screen that seeds a starter catalog of common designations for new orgs, plus the release-date pattern that lets restricted funds automatically time-release.

- **Custom fields** — `GiftDesignation.FQS_Restriction_Type__c`; `GiftDefaultDesignation.FQS_Parent_Type__c`, `FQS_Restriction_Type__c`; `GiftTransactionDesignation.FQS_Restriction_Type__c`
- **FQS help-text overlays** — `GiftDesignation.IsActive`, `GiftDesignation.IsDefault`, `GiftDefaultDesignation.GiftDesignationId`, `GiftTransactionDesignation.GiftDesignationId`
- **Restriction release date** — `GiftCommitment.FQS_Restriction_Release_Date__c`, `GiftTransaction.FQS_Restriction_Release_Date__c` (drive scheduled release of temporarily-restricted funds; consumed by `FQS_Recalculate_GC_FulfillmentType`)
- **Flows** — `FQS_Suggest_Designations` (setup-time starter-catalog seeder)
- **List views** — `GiftDesignation.FQS_Active_Designations`, `FQS_Inactive_Designations`, `FQS_With_Donor_Restriction`, `FQS_Without_Donor_Restriction`
- **ReportType** — `GiftDesignation_Deluxe`
- **Report** — `GiftDesignation_Record_Page_Report_qKR`
- **FlexiPages** — `FQS_GiftDesignation_Record_Page`, `FQS_GiftDefaultDesignation_Record_Page`, `FQS_GiftTransactionDesignation_Record_Page`

### I.4 Campaign hierarchy & templates

Multi-year, multi-level fundraising campaign structure. Admins pick from 51 templates; the hierarchy builder generates the Campaigns, wires parent/child relationships, and pre-populates status, category, dates, and short-name. Hierarchy depth drives which record-page report shows on which level.

- **Apex** — `FQS_CampaignHierarchyBuilder` (+ test)
- **CustomMetadataType** — `FQS_Campaign_Template__mdt` (51 rows shipped)
- **Flows** — `FQS_Campaign_Hierarchy_Setup`, `FQS_Campaign_Auto_Members_Default`, `FQS_Campaign_Child_Count_Update`, `FQS_Campaign_Child_Count_Delete`, `FQS_Campaign_Create_First_OSC`
- **Custom fields** — `Campaign.FQS_Campaign_Category__c`, `FQS_Child_Campaign_Count__c`, `FQS_Create_First_Outreach_Source_Code__c`, `FQS_Enable_Auto_Members__c`, `FQS_Hierarchy_Depth__c`, `FQS_Short_Name__c`, `FQS_Ultimate_Parent_Campaign__c`
- **RecordType + BusinessProcess** — `Campaign.FQS_Fundraising` + `FQS_Campaign_Status` path
- **List views (8)** — `Campaign.FQS_Active_Campaigns`, `FQS_All_Fundraising_Campaigns`, `FQS_Annual_Giving_Campaigns`, `FQS_Event_Campaigns`, `FQS_Grants_Campaigns`, `FQS_Major_Gifts_Campaigns`, `FQS_My_Fundraising_Campaigns`, `FQS_Top_Level_Campaigns`
- **Quick action** — `Campaign.Hierarchy_Metrics`
- **Reports** — `Campaign_Record_Page_Report_Level1_pWX`, `Campaign_Record_Page_Report_Level2_zMR`, `Campaign_Record_Page_Report_nLT`, `FQS_Campaign_Performance_By_Depth`
- **ReportTypes** — `Campaign_Deluxe`, `Campaigns_and_Gift_Transactions`
- **FlexiPage** — `FQS_Campaign_Record_Page`

### I.5 Campaign Members lifecycle

Keeps `CampaignMember.Status` in sync with donor GC/GT activity so campaign reports reflect actual engagement rather than cold prospect lists. Per-Campaign kill switch (`FQS_Enable_Auto_Members__c`) so admins can disable automation on campaigns that manage membership manually.

- **Flows** — `FQS_Campaign_Member_Status_Ladder`, `FQS_Campaign_Member_Status_On_Commitment`, `FQS_Campaign_Member_Status_On_Commitment_Delete`, `FQS_Campaign_Member_Status_On_Gift_Transaction`, `FQS_Campaign_Member_Status_On_Gift_Transaction_Delete`
- **Custom field** — `Campaign.FQS_Enable_Auto_Members__c` (per-Campaign kill switch)

### I.6 Outreach Source Codes & Outreach Summaries

Appeal / channel / creative attribution model — ties actual GTs back to the outreach that generated them, so response-rate and revenue-per-outreach reporting works without hand-parsing UTM strings. Includes automatic source-code generation formula and a UTM-mapped platform picklist.

- **Custom fields** — `OutreachSourceCode.FQS_Message_Channel_Segment__c`, `FQS_Platform__c`; `Campaign.FQS_Short_Name__c` (`utm_campaign` equivalent)
- **FQS help-text overlays** — 8 on `OutreachSourceCode` (`AudienceCount`, `MessageChannel`, `MessageChannelPlatform`, `MessageChannelPlatformAccount`, `SourceCode`, `SourceCodeUrl`, `Status`, `UsageType`); 9 on `OutreachSummary` (`AttributedAmount`, `DonorCount`, `GiftCount`, etc.)
- **List views** — `OutreachSourceCode.FQS_Active_Outreach_Codes`, `FQS_Digital_Codes`, `FQS_Direct_Mail_Codes`, `FQS_Email_Codes`; `OutreachSummary.FQS_Active_Outreach`, `FQS_No_Response`, `FQS_Recurring_Outreach`
- **FlexiPages** — `FQS_OutreachSourceCode_Record_Page`, `FQS_OutreachSummary_Record_Page`
- **FundraisingConfig** — sets `outreachSourceCodeGenFmla={Campaign.FQS_Short_Name__c}` and UTM source = `OutreachSourceCode.FQS_Platform__c`

### I.7 Gift Batches & Gift Entry templates

Batch-entry surface for high-volume gift processing. Four grid templates cover the most common batch shapes (individual outright gifts, pledge installments, single-payment pledges, event registrations). Ships a FieldMappingConfig record so `GiftEntry.FQS_*` staging fields flow into the matching canonical `GiftTransaction.FQS_*` fields.

- **Flows** — `FQS_Create_Gift_Batch` (home-page launcher)
- **GiftEntryGridTemplates** — `FQS_Individual_Outright_Gifts`, `FQS_Pledge_Payments`, `FQS_Single_Payment_Pledges`, `FQS_Event_Registrations`
- **StandardValueSet override** — `GiftBatchScreenTempName` (carries the four templates as picklist values)
- **UI format spec** — `Value_Matches_Expected` (green-highlights matched actual-vs-expected lines)
- **Custom fields (GiftEntry, 12)** — `FQS_Gift_Transaction_Category__c`, `FQS_Match_Status__c`, `FQS_Stewardship_Status__c`, `FQS_Donor_Tax_Date__c`, `FQS_Fair_Market_Value_Amount__c`, `FQS_GC_Match_Eligible__c`, `FQS_GC_Restriction_Release_Date__c`, `FQS_GC_Skip_Naming__c`, `FQS_GT_Restriction_Release_Date__c`, `FQS_GT_Skip_Naming__c`, `FQS_Stewardship_Date__c`, `FQS_Tax_Receipt_Date__c`
- **FieldMappingConfig** — `FieldMappingConfig` (maps `GiftEntry.FQS_*` → `GiftTransaction.FQS_*`) — *shipped, manual step*
- **FlexiPage** — `FQS_GiftBatch_Record_Page`

### I.8 Guided Gift Entry

Purposeful launcher and subflows that walk a fundraiser or gift-entry user through a single gift end-to-end: donor selection → commitment shape → transaction → designation split → soft credit → optional employer match. Three surfaces (Account, Opportunity, Home Page) all funnel into the same monolith with pre-selection context.

- **Flows** — `FQS_Guided_Gift_Entry_HomePage` (universal entry), `FQS_Guided_Gift_Entry_Account`, `FQS_Guided_Gift_Entry_Opportunity`, `FQS_Guided_Gift_Entry_GiftCommitment`, `FQS_Guided_Gift_Entry_Subflow_Campaign_Designation_Resolver`, `FQS_Guided_Gift_Entry_Subflow_Soft_Credit_Reach`, `FQS_Guided_Gift_Entry_Subflow_Employer_Match`, `FQS_Coordinate_Gift_Commitment_Processing`
- **Quick actions** — `Account.FQS_Guided_Gift_Entry`, `GiftCommitment.FQS_Pledge_Payment`, `Opportunity.FQS_Setup_Commitment`
- **FlexiPages** — `FQS_Home_Page_Default` (surfaces the home-page launcher), `Fundraising_Quick_Start_UtilityBar1`
- **Account fields (Match)** — `Account.FQS_Matching_Gift_Program__c`, `FQS_Match_Ratio__c`, `FQS_Match_Annual_Individual_Maximum__c` (read by the employer-match subflow)
- **Deferred (v1.1)** — `FQS_MatchCandidateService` + `FQS_MatchCommitService` + `FQS_MatchCandidate` (Apex-backed candidate finder + committer intended to replace the in-flow employer-match logic)
- **Deep-dive docs** — [dev/fqs-common-gift-entry-scenario-data-requirements.md](dev/fqs-common-gift-entry-scenario-data-requirements.md), [archive/corporate-matching-gift-flow.md](archive/corporate-matching-gift-flow.md)

### I.9 Donor Gift Summary & Donor Tiers

Two things live here. **Donor Gift Summary** surfaces the standard Fund Cloud rollup fields with FQS-owned help text (RFM scores, best-year, booked pledges, giving-level bands, recurring installment totals) and a curated record page. **Donor Tiers** classifies donors into Entry / Mid / Major on both annual and lifetime dimensions using admin-editable thresholds, computed retroactively when thresholds change, with a Setup screen flow that edits the `FQS_Donor_Tier__mdt` rows without opening the CMDT UI.

- **CustomMetadataType** — `FQS_Donor_Tier__mdt` (3 rows: Entry, Mid, Major)
- **Flows** — `FQS_Setup_Tier_Thresholds`, `FQS_Setup_Stewardship_Response_Settings` (both edit CMDT via `FQS_CustomMetadataSaver`), `FQS_Automatic_Rollup_Updates` (scheduled — runs Manage Fundraising Definitions daily so DGS + Outreach Summary + Gift Designation rollups refresh)
- **Apex** — `FQS_CustomMetadataSaver` (+ test)
- **Custom fields (DGS, 14)** — `FQS_Annual_Donor_Level__c`, `FQS_Annual_Donor_Level_Name__c`, `FQS_Lifetime_Donor_Level__c`, `FQS_Lifetime_Donor_Level_Name__c`, `FQS_Is_Entry_Annual_Donor__c`, `FQS_Is_Mid_Annual_Donor__c`, `FQS_Is_Major_Annual_Donor__c`, `FQS_Is_Entry_Lifetime_Donor__c`, `FQS_Is_Mid_Lifetime_Donor__c`, `FQS_Is_Major_Lifetime_Donor__c`, `FQS_Legacy_First_Gift_Date__c`, `FQS_Legacy_Gift_Count__c`, `FQS_Legacy_Soft_Credit_Total__c`, `FQS_Legacy_Total_Gifts_Amount__c`
- **FQS help-text overlays (DGS, 12)** — `RecencyScore`, `FrequencyScore`, `MonetaryScore`, `CompositeRfmScore`, `BestGiftYear`, `BookedPledges`, `CurrentYearSoftCreditsAmount`, `GiftsThisYearAmount`, `GivingLevel`, `TotalBookableRevenue`, `TotalPaidRcrInstallments`, `TotalPaidRcrInstlAmt`
- **PermissionSet** — `FQS_Rollup_DPE_Read` (grants the Analytics Cloud Integration User read access on 37 standard fields the three shipped Fundraising DPE definitions reference)
- **List views** — `DonorGiftSummary.FQS_Current_Year_Givers`, `FQS_Major_Donors`, `FQS_Recurring_Donors`
- **Reports** — `FQS_Major_Annual_Donors_This_FY`, `FQS_Major_Lifetime_Donors`, `FQS_Mid_to_Major_Upgrade_Pipeline`
- **ReportType** — `fqs_Donor_Gift_Summary_Deluxe`
- **Dashboard** — `FQS_Donor_Tiers`
- **FlexiPage** — `FQS_DonorGiftSummary_Record_Page`
- **Deep-dive docs** — [dev/dpe/](dev/dpe/)

### I.10 Acknowledgement, Stewardship & Tax Receipting toolbox

A **toolbox**, not a complete end-to-end process. FQS provides the primitives — status fields, per-tier auto-stewardship toggles, sample email templates, ready-to-run scheduled flows, action-plan template, task queues — so an org can compose its own acknowledgement + stewardship + tax-receipting cadence. The pieces work standalone or together: use the acknowledgement scheduled flow but skip stewardship, or drop the shipped templates and wire your own.

- **Flows** — `FQS_Gift_Acknowledgement` (scheduled, template-aware), `FQS_Stewardship_Response` (scheduled, ~14 days after acknowledgement), `FQS_Acknowledgement_Stewardship_Tax_Guide` (home-page decision guide walking admins through the design choices)
- **Custom fields (GT)** — `FQS_Stewardship_Status__c`, `FQS_Stewardship_Date__c`, `FQS_Tax_Receipt_Date__c`, `FQS_Donor_Tax_Date__c`
- **FQS help-text overlays** — `GiftTransaction.AcknowledgementStatus`, `AcknowledgementDate`, `TaxReceiptStatus`, `TaxDeductionAmount`, `NonTaxDeductibleAmount`
- **GlobalValueSet** — `FQS_Stewardship_Status` (To Be Sent / Sent / Don't Send)
- **Per-tier toggle** — `FQS_Donor_Tier__mdt.FQS_Auto_Stewardship__c` (admin decides per tier whether stewardship auto-fires)
- **EmailTemplates** — `FQS_Gift_Acknowledgement` (full-tax), `FQS_Gift_Acknowledgement_Partial` (used when NonTaxDeductibleAmount > 0), `FQS_Stewardship_Response_Standard`
- **EmailFolder** — `FQS_Templates`
- **PermissionSet** — `FQS_Email_Template_Builder_Permission` (Setup entitlement for editing templates in Email Content Builder)
- **ActionPlanTemplate** — `Stewardship_*` (task ladder for post-Major-gift stewardship — routes to the Stewardship Tasks queue)
- **List views** — `GiftTransaction.FQS_To_Be_Acknowledged`, `FQS_To_Be_Stewarded`; `Task.FQS_Gift_Acknowledgements_Task`, `FQS_Stewardship_Response_Task`
- **Queues** — `FQS_Gift_Processing_Tasks`, `FQS_Stewardship_Tasks`
- **Report** — `FQS_Stewardship_Pipeline`
- **Deep-dive docs** — [dev/acknowledgement-stewardship-tax-receipting.md](dev/acknowledgement-stewardship-tax-receipting.md), [fqs-flow-overview.md](fqs-flow-overview.md)

### I.11 Soft Credits & Tributes

Recognition credit alongside hard credit without double-counting revenue, plus in-honor-of / in-memory-of tribute support.

- **Custom fields** — `GiftDefaultSoftCredit.FQS_Parent_Type__c`; `GiftSoftCredit.External_Id__c`; `GiftTribute.External_Id__c`
- **FQS help-text overlays** — `GiftSoftCredit.Role`; `GiftTribute.HonoreeContactId` (FQS-added Person-Account lookup filter), `TributeType`
- **StandardValueSet override** — `GiftSoftCreditRole` (Household Member, Matched Donor, Solicitor, Honoree)
- **List views** — `GiftSoftCredit.FQS_All_Soft_Credits`, `FQS_Honoree_Credits`, `FQS_Matched_Donor_Credits`, `FQS_Soft_Credits`, `FQS_Solicitor_Credits`; `GiftDefaultSoftCredit.FQS_Gift_Commitment_Defaults`, `FQS_Household_Member_Defaults`, `FQS_Matched_Donor_Defaults`, `FQS_Opportunity_Defaults`; `GiftTribute.FQS_Honor_Tributes`, `FQS_Memorial_Tributes`
- **FlexiPages** — `FQS_GiftSoftCredit_Record_Page`, `FQS_GiftDefaultSoftCredit_Record_Page`, `FQS_GiftTribute_Record_Page`

### I.12 Gift Refunds

Dedicated refund path that preserves historical gift totals — refunds get entered as GiftRefund records against a GT rather than by editing the GT amount. Two launch surfaces (from the GT record page and from the donor's Account page).

- **Flows** — `FQS_Refund_Gift`, `FQS_Refund_Gift_From_Donor`
- **Quick actions** — `GiftTransaction.FQS_Refund_Gift`, `Account.FQS_Refund_Donor_Gift`
- **StandardValueSet override** — `GiftRefundReason`
- **Path assistant** — `FQS_GiftRefund_Status`
- **List views** — `GiftRefund.FQS_Completed_Refunds`, `FQS_Failed_Refunds`, `FQS_Initiated_Refunds`
- **FlexiPage** — `FQS_GiftRefund_Record_Page`

### I.13 Data integrity, migration & data import guardrails

Duplicate + matching rules that surface likely duplicates without blocking user work, plus the `External_Id__c` upsert-key convention that keeps seed scripts, ETL pipelines, and downstream migrations idempotent. Everything an org needs to run bulk data imports (Data Loader, dataloader.io, Talend, Workbench, custom Apex) against a fresh FQS install and land clean records the second time you run the same file.

- **Custom fields** — `External_Id__c` on 15 objects (Account, Campaign, DonorGiftSummary, GiftCommitment, GiftCommitmentSchedule, GiftDesignation, GiftEntry *(implied via mapping)*, GiftRefund, GiftSoftCredit, GiftTransaction, GiftTransactionDesignation, GiftTribute, Opportunity, OutreachSourceCode, PaymentInstrument)
- **DuplicateRules** — `Account.FQS_Account_Organization_Dupe`, `Account.FQS_Account_Person_Dupe`, `Contact.FQS_Contact_Dupe` (all warn-not-block)
- **MatchingRules** — `Account.FQS_Account_Organization_Match` (name + billing city fuzzy), `Account.FQS_Account_External_Id_Match` (exact), `Contact.FQS_Contact_Individual_Match` (name + email fuzzy)
- **Custom field (Account)** — `FQS_Is_Match_Intermediary__c` (flags Benevity / YourCause / Bright Funds so they don't get treated as corporate donors during import)
- **CustomPermissions + PermissionSets (integration/migration users)** — `FQS_Bypass_Automation` (short-circuits GC-fulfillment RT flows during bulk load), `FQS_Skip_Record_Naming` (auto-name flows skip Name rewrites so upstream-owned Names survive import); paired permsets `FQS_Bypass_Automation` and `FQS_Naming_Opt_Out`
- **FundraisingConfig** — `donorExternalIdField=External_Id__c` (aligns Fund Cloud donor matching with the FQS import convention)

### I.14 Standard field help-text overlays

FQS ships inline help text, descriptions, and picklist-value tweaks on 70 Salesforce-shipped standard fields across the Fundraising object model. The goal is admin + user clarity — the standard help is often thin ("The status.") or missing entirely; FQS fills the gap with prose that describes *when* to use the field, *what* the values mean, and *how* it interacts with other fields.

Six overlays are blocked from source-format deploy by a platform quirk and ship as **manual paste** steps documented in [docs/manual-help-text-setup.md](manual-help-text-setup.md). Everything else deploys with the package.

Where the overlay is doing more than description — driving automation, feeding a report, or reshaping picklist behavior — the field also appears under its feature above. This feature is the catalog of overlays *as a set*.

- **Objects with overlays** (see [fqs-metadata-inventory.md §III.1.2](fqs-metadata-inventory.md#iii12-fqs-owned-help-text-overlays-on-standard--fundraising-cloud-fields) for the row-by-row list)
  - `DonorGiftSummary` (12) — RFM scores, best-year, booked pledges, giving-level bands, recurring installment totals
  - `GiftCommitment` (8) — CampaignId (+ lookup filter), CurrentGiftCmtScheduleId, ExpectedTotalCmtAmount, FormalCommitmentType, FulfillmentType, RecurrenceType, ScheduleType, `FQS_Restriction_Release_Date__c` companion notes
  - `GiftCommitmentSchedule` (7) — CommitmentUpdateReason, GiftCommitmentStatus, PaymentMethod, TransactionAmount, TransactionDay (LastDay note), TransactionPeriod (Custom callout), Type
  - `GiftDefaultDesignation`, `GiftTransactionDesignation` — GiftDesignationId (retired-designation guidance)
  - `GiftDesignation` — IsActive, IsDefault
  - `GiftSoftCredit` — Role (5-role rationale)
  - `GiftTransaction` (16) — AcknowledgementDate, AcknowledgementStatus, CampaignId (+ lookup filter), CurrentAmount, GiftType, Name, NonTaxDeductibleAmount, OriginalAmount, OutreachSourceCodeId, PaymentIdentifier, PaymentMethod, Status, TaxDeductionAmount, TaxReceiptStatus, TransactionDate, TransactionDueDate
  - `GiftTribute` — HonoreeContactId, TributeType
  - `Opportunity` (4) — Amount, CloseDate, ExpectedRevenue, Probability
  - `OutreachSourceCode` (8) — AudienceCount, MessageChannel, MessageChannelPlatform, MessageChannelPlatformAccount, SourceCode, SourceCodeUrl, Status, UsageType
  - `OutreachSummary` (9) — AttributedAmount, DonorCount, GiftCount, OnetimeDonorCount, RecurringDonorCount, ResponseRate, TotalGiftTransactionAmount, TotalOnetimeGiftAmount, TotalRecurringGiftAmount

**Install path**
- Automatic — every overlay in `force-app/main/default/objects/<Sobject>/fields/<Field>.field-meta.xml` deploys with the package.
- Manual — [docs/manual-help-text-setup.md](manual-help-text-setup.md) lists the six fields whose overlays are blocked at deploy and must be pasted into Setup after install.

### I.15 Foundation: app shell, permsets, home page, utility bar

Cross-cutting shell components that host the features above. Not a user-facing capability on their own — but every feature depends on the FQS_Console tab strip, one or more permission sets granting FLS, and the utility-bar launcher shortcuts.

- **CustomApplication** — `FQS_Console` (14 tabs: home, Account, GC, GT, Campaign, Opportunity, GD, GB, Task, ActionPlanTemplate, Csv Data Import, Dashboard, Report, EmailTemplate)
- **FlexiPage** — `FQS_Home_Page_Default`, `Fundraising_Quick_Start_UtilityBar1`
- **CompactLayouts** — Account, Campaign, PersonAccount
- **PermissionSets** — `FQS_Custom_Fields` (umbrella FLS grant), `FQS_Campaign_Fields`, `FQS_Person_Account_Fields`, `FQS_Record_Type_Access`, `FQS_Bypass_Automation`, `FQS_Naming_Opt_Out`, `FQS_Email_Template_Builder_Permission`, `FQS_Rollup_DPE_Read`
- **Group** — `FQS_Fundraisers` (public group for permset assignment + task routing)
- **Layouts (9)** — minimal Classic layouts satisfying record-type + business-process assignments (per `fqs-classic-layouts-out-of-scope` memory, comprehensive Classic coverage is intentionally out of scope)
