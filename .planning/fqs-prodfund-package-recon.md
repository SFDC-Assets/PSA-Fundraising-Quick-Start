# ProdFund Package Manager vs. repo manifest — reconciliation walkthrough

**Generated:** 2026-08-18 (post-Phase 5, pre-destructive)
**Repo manifest:** `manifest/package.xml` — 451 members / 33 types (post-cleanup)
**ProdFund package:** "Fundraising Quick Start" (Id `033a5000000sfB3AAI`) — 339 members / 19 types

**Source of truth going forward:** the repo. The ProdFund unmanaged package needs to be brought into alignment with `manifest/package.xml`.

**How to apply each section:** Setup → Installed Packages → **Fundraising Quick Start** → *Add Components* / click *Remove* on each row. Salesforce doesn't offer bulk actions in Package Manager, so each component is a UI click.

**Note on folder-qualified names:** Dashboard/Report/EmailTemplate references normalize to their leaf names for comparison — a repo entry `FQS_Donor_Tiers` and a ProdFund entry `FQSDashboards/FQS_Donor_Tiers` are the same dashboard.

**Note on components blocked by Package Manager:** several types below cannot be added via *Add Components* in the unmanaged-package UI (FundraisingConfig, StandardValueSet) or currently don't appear in the picker on this org (Queue, Group, EmailFolder). Those must be recreated by the installing admin as post-install steps — README §III / §IV documents them. They stay listed here so the reconciliation record is complete.

**Second-pass expectation:** several REMOVE rows (Donor Grouping CMDT + fields, FQS_MatchCandidate* Apex) will disappear on their own after Phase 7 destructive deletes fire against ProdFund. Re-run this diff after Phase 7 to shrink Section B.

---

## Summary

| Action | Count |
|--------|------:|
| **ADD to ProdFund package** (in repo, not in package) — total | **144** |
| — of which addable via Package Manager UI | **65** |
| — of which post-install-only (not addable to package) | **79** |
| **REMOVE from ProdFund package** (in package, not in repo) | **31** |

---

## Section A — ADD to ProdFund package (144)

For each entry: Setup → Package Manager → Fundraising Quick Start → **Add Components** → filter to the correct Component Type → check the box → **Add To Package**.

**⚠️ Post-install-only categories** (below sections marked `[POST-INSTALL]` are not addable to an unmanaged package via *Add Components*; they must be recreated by the installing admin per README post-install steps): FundraisingConfig, StandardValueSet, Queue, Group, EmailFolder, **and CustomField overlays on standard objects** (Package Manager rejects standard-object field additions in unmanaged packages). **79 members total.**

### ActionPlanTemplate — 2

- `FQS_Moves_Management`
- `FQS_Stewardship`

### ApexClass — 2

- `FQS_CampaignHierarchyBuilder_Test`
- `FQS_CustomMetadataSaver_Test`

### CompactLayout — 2

- `Account.FQS_Account_Compact_Layout`
- `PersonAccount.FQS_Person_Account_Compact_Layout`

### CustomField — 70  [POST-INSTALL]

Package Manager on this org rejects standard-object CustomField overlays (`DonorGiftSummary.*`, `GiftCommitment.*`, `GiftTransaction.*`, `Opportunity.*`, `OutreachSourceCode.*`, etc.) as addable components — the picker won't accept them. These deploy fine when the package is installed (they're in `manifest/package.xml` and `force-app/`), but they can't be catalogued in the Package Manager component list. Left in this section for reconciliation-record completeness.


- `DonorGiftSummary.BestGiftYear`
- `DonorGiftSummary.BookedPledges`
- `DonorGiftSummary.CompositeRfmScore`
- `DonorGiftSummary.CurrentYearSoftCreditsAmount`
- `DonorGiftSummary.FrequencyScore`
- `DonorGiftSummary.GiftsThisYearAmount`
- `DonorGiftSummary.GivingLevel`
- `DonorGiftSummary.MonetaryScore`
- `DonorGiftSummary.RecencyScore`
- `DonorGiftSummary.TotalBookableRevenue`
- `DonorGiftSummary.TotalPaidRcrInstallments`
- `DonorGiftSummary.TotalPaidRcrInstlAmt`
- `GiftCommitment.CampaignId`
- `GiftCommitment.CurrentGiftCmtScheduleId`
- `GiftCommitment.ExpectedTotalCmtAmount`
- `GiftCommitment.FormalCommitmentType`
- `GiftCommitment.FulfillmentType`
- `GiftCommitment.RecurrenceType`
- `GiftCommitment.ScheduleType`
- `GiftCommitmentSchedule.CommitmentUpdateReason`
- `GiftCommitmentSchedule.GiftCommitmentStatus`
- `GiftCommitmentSchedule.PaymentMethod`
- `GiftCommitmentSchedule.TransactionAmount`
- `GiftCommitmentSchedule.TransactionDay`
- `GiftCommitmentSchedule.TransactionPeriod`
- `GiftCommitmentSchedule.Type`
- `GiftDefaultDesignation.GiftDesignationId`
- `GiftDesignation.IsActive`
- `GiftDesignation.IsDefault`
- `GiftSoftCredit.Role`
- `GiftTransaction.AcknowledgementDate`
- `GiftTransaction.AcknowledgementStatus`
- `GiftTransaction.CampaignId`
- `GiftTransaction.CurrentAmount`
- `GiftTransaction.GiftType`
- `GiftTransaction.Name`
- `GiftTransaction.NonTaxDeductibleAmount`
- `GiftTransaction.OriginalAmount`
- `GiftTransaction.OutreachSourceCodeId`
- `GiftTransaction.PaymentIdentifier`
- `GiftTransaction.PaymentMethod`
- `GiftTransaction.Status`
- `GiftTransaction.TaxDeductionAmount`
- `GiftTransaction.TaxReceiptStatus`
- `GiftTransaction.TransactionDate`
- `GiftTransaction.TransactionDueDate`
- `GiftTransactionDesignation.GiftDesignationId`
- `GiftTribute.HonoreeContactId`
- `GiftTribute.TributeType`
- `Opportunity.Amount`
- `Opportunity.CloseDate`
- `Opportunity.ExpectedRevenue`
- `Opportunity.Probability`
- `OutreachSourceCode.AudienceCount`
- `OutreachSourceCode.MessageChannel`
- `OutreachSourceCode.MessageChannelPlatform`
- `OutreachSourceCode.MessageChannelPlatformAccount`
- `OutreachSourceCode.SourceCode`
- `OutreachSourceCode.SourceCodeUrl`
- `OutreachSourceCode.Status`
- `OutreachSourceCode.UsageType`
- `OutreachSummary.AttributedAmount`
- `OutreachSummary.DonorCount`
- `OutreachSummary.GiftCount`
- `OutreachSummary.OnetimeDonorCount`
- `OutreachSummary.RecurringDonorCount`
- `OutreachSummary.ResponseRate`
- `OutreachSummary.TotalGiftTransactionAmount`
- `OutreachSummary.TotalOnetimeGiftAmount`
- `OutreachSummary.TotalRecurringGiftAmount`

### CustomMetadata — 28

- `FQS_Campaign_Template.Prg_Planned_Giving`
- `FQS_Campaign_Template.Ret_Anniversary_Notes`
- `FQS_Campaign_Template.Ret_Impact_Report`
- `FQS_Campaign_Template.Ret_Lapsed_Last_Chance`
- `FQS_Campaign_Template.Ret_Lapsed_Phone`
- `FQS_Campaign_Template.Ret_Lapsed_Winback`
- `FQS_Campaign_Template.Ret_Second_Gift`
- `FQS_Campaign_Template.Sol_Dec_Reminder_Sms`
- `FQS_Campaign_Template.Sol_Discovery_Visits`
- `FQS_Campaign_Template.Sol_Giving_Tuesday`
- `FQS_Campaign_Template.Sol_Mid_Level_Letter`
- `FQS_Campaign_Template.Sol_Mid_Level_Site_Visit`
- `FQS_Campaign_Template.Sol_Monthly_Sustainer_Lp`
- `FQS_Campaign_Template.Sol_Portfolio_Solicitation`
- `FQS_Campaign_Template.Sol_Spring_Dm`
- `FQS_Campaign_Template.Sol_Spring_Email`
- `FQS_Campaign_Template.Sol_Sustainer_Recruitment`
- `FQS_Campaign_Template.Sol_Yearend_Dm`
- `FQS_Campaign_Template.Str_Annual_Celebration`
- `FQS_Campaign_Template.Str_Foundation_Giving`
- `FQS_Campaign_Template.Str_Lapsed_Reactivation`
- `FQS_Campaign_Template.Str_Mid_Level_Cultivation`
- `FQS_Campaign_Template.Str_Monthly_Sustainer`
- `FQS_Campaign_Template.Str_New_Donor_Acquisition`
- `FQS_Campaign_Template.Str_Retention_Stewardship`
- `FQS_Campaign_Template.Str_Spring_Appeal`
- `FQS_Campaign_Template.Str_Year_Cohort`
- `FQS_Campaign_Template.Str_Year_End_Push`

### CustomObject — 5

- `Campaign`
- `DonorGiftSummary`
- `GiftCommitment`
- `GiftDefaultDesignation`
- `GiftDesignation`

### DashboardFolder — 1

- `FQSDashboards`

### DuplicateRule — 3

- `Account.FQS_Account_Organization_Dupe`
- `Account.FQS_Account_Person_Dupe`
- `Contact.FQS_Contact_Dupe`

### EmailFolder — 1  [POST-INSTALL]

Package Manager cannot add EmailFolders to unmanaged packages on this org. Installing admin recreates the folder as a post-install step; EmailTemplate members inside it deploy on their own.

- `FQS_Templates`

### FundraisingConfig — 1  [POST-INSTALL]

Package Manager rejects `FundraisingConfig` as an addable component type. Installing admin configures Fundraising Configuration via Setup UI as a post-install step (README §III).

- `FundraisingConfig`

### Group — 1  [POST-INSTALL]

Package Manager cannot add public Groups to unmanaged packages on this org. Installing admin creates the Group manually as a post-install step.

- `FQS_Fundraisers`

### Layout — 3

- `GiftCommitment-Gift Commitment Layout`
- `GiftDesignation-Gift Designation Layout`
- `GiftTransaction-Gift Transaction Layout`

### ListView — 10

- `Campaign.FQS_Top_Level_Campaigns`
- `GiftCommitment.FQS_Recurring_Gifts`
- `GiftDesignation.FQS_With_Donor_Restriction`
- `GiftDesignation.FQS_Without_Donor_Restriction`
- `GiftTransaction.FQS_Recurring_Gift_Payments`
- `GiftTransaction.FQS_Transaction_Category_Other`
- `Task.FQS_Executive_Fundraising_Tasks_Task`
- `Task.FQS_Gift_Acknowledgements_Task`
- `Task.FQS_Major_Donor_Research_Task`
- `Task.FQS_Stewardship_Response_Task`

### MatchingRule — 3

- `Account.FQS_Account_External_Id_Match`
- `Account.FQS_Account_Organization_Match`
- `Contact.FQS_Contact_Individual_Match`

### PathAssistant — 4

- `FQS_Campaign_Status`
- `FQS_GiftCommitment_Status`
- `FQS_GiftRefund_Status`
- `FQS_GiftTransaction_Status`

### QuickAction — 0

_All QuickAction dangling members (`FQS_New_Grant`, `FQS_New_Major_Gift`) were removed from `manifest/package.xml` in the pre-recon cleanup — they are neither in the repo nor targeted for reintroduction. This section is retained as a marker for the next reconciliation pass._

### Queue — 4  [POST-INSTALL]

Package Manager cannot add Queues to unmanaged packages on this org. Installing admin creates the Queues manually as post-install steps.

- `FQS_Executive_Fundraising_Tasks`
- `FQS_Gift_Processing_Tasks`
- `FQS_Major_Donor_Tasks`
- `FQS_Stewardship_Tasks`

### ReportFolder — 2

- `FQSDonorTierReports`
- `FQSRecordPageReports`

### StandardValueSet — 2  [POST-INSTALL]

Package Manager rejects StandardValueSet as an addable component type. Installing admin adds the picklist values to `GiftBatchScreenTempName` + `OpportunityStage` via Setup UI as post-install steps (README §III).

- `GiftBatchScreenTempName`
- `OpportunityStage`

---

## Section B — REMOVE from ProdFund package (31)

For each entry: Setup → Package Manager → Fundraising Quick Start → find the row in the Components table → click **Remove**.

### ActionPlanTemplate — 2

- `Moves_Management_65c3e74a_90d4_11f1_9ffa_750d1a89e526`
- `Stewardship_38e8d861_90da_11f1_b64a_f1bc2df97554`

### ApexClass — 3

- `FQS_MatchCandidate`
- `FQS_MatchCandidateService`
- `FQS_MatchCommitService`

### CustomField — 5

- `FQS_Donor_Grouping__mdt.Branded_Name__c`
- `FQS_Donor_Grouping__mdt.Grouping_Key__c`
- `FQS_Donor_Grouping__mdt.Min_Amount__c`
- `FQS_Donor_Grouping__mdt.Sort_Order__c`
- `OutreachSourceCode.FQS_Channel_Segment__c`

### CustomMetadata — 3

- `FQS_Donor_Grouping.Entry`
- `FQS_Donor_Grouping.Major`
- `FQS_Donor_Grouping.Mid`

### CustomObject — 1

- `FQS_Donor_Grouping__mdt`

### Dashboard — 1

- `FQSDashboards`

### EmailTemplate — 1

- `FQS_Templates`

### Flow — 1

- `FQS_Manage_Gift_Commitment_Actions`

### Layout — 1

- `FQS_Donor_Grouping__mdt-FQS Donor Grouping Layout`

### ListView — 3

- `DonorGiftSummary.All_DonorGiftSummaries`
- `GiftTransaction.In_Kind_Gifts`
- `Opportunity.MyOpportunities`

### RecordType — 2

- `Account.Organization`
- `PersonAccount.PersonAccount`

### Report — 2

- `FQSDonorTierReports`
- `FQSRecordPageReports`

### WebLink — 6

- `Account.GoogleMaps`
- `Account.GoogleNews`
- `Account.GoogleSearch`
- `Account.HooversProfile`
- `Campaign.ViewAllCampaignMembers`
- `Campaign.ViewCampaignInfluenceReport`

