# FQS Metadata Inventory

Canonical inventory for the Fundraising Quick Start (FQS) unmanaged package — one row per shipped metadata item, grouped by kind. Every row gives the fully-qualified API name, its metadata type, a plain-English purpose (user- or admin-visible behavior — not internals), and where applicable a compact `Referenced by` cell showing the classes of metadata that consume the item. `⚠ unreferenced` cells mean nothing in the FQS source tree names the item; every such finding is aggregated in §11 for A3's dead-code purge.

`Referenced by` uses a bounded search (`\b<api-name>\b`) across `force-app/main/default/`. When a category has ≤ 2 named consumers, the names appear; when it has more, the cell shows the count (e.g., `flow x5`). Purpose text is the shipped field label or help text — not authored for this doc.

**Scope.** Everything under `force-app/main/default/` that is not in `.forceignore`. Two features are deferred from v1.0 scope and excluded intentionally: the flow `FQS_Manage_Gift_Commitment_Actions` and the `FQS_Find_Matching_Gift` feature. `FQSSeedGenerator.cls` is a dev-only seed script and `.forceignore`d.

## Table of contents

1. [Custom fields on standard and Fundraising Cloud objects](#1-custom-fields-on-standard-and-fundraising-cloud-objects)
2. [Custom metadata types](#2-custom-metadata-types)
3. [Flows](#3-flows)
4. [FlexiPages](#4-flexipages)
5. [Apps, tabs, quick actions](#5-apps-tabs-quick-actions)
6. [Apex classes](#6-apex-classes)
7. [Permission sets](#7-permission-sets)
8. [Reports, dashboards, report types](#8-reports-dashboards-report-types)
9. [Global value sets, standard value sets, custom permissions](#9-global-value-sets-standard-value-sets-custom-permissions)
10. [Supporting metadata](#10-supporting-metadata)
11. [Aggregated unreferenced findings](#11-aggregated-unreferenced-findings)



## 1. Custom fields on standard and Fundraising Cloud objects

Two subsections. §1.1 lists FQS-prefix custom fields (`FQS_*__c`) — net-new fields FQS creates on Salesforce-shipped or Fundraising-Cloud objects — with full `Referenced by` cells. §1.2 lists FQS-owned help-text overlays on standard fields, compressed to one row per field (the file exists in the repo only because FQS ships an inline-help/description override; the field itself is Salesforce-shipped).

**About `External_Id__c`.** FQS adds this text field to 14 objects for seed-script idempotency (`FQS-<OBJ>-<idx>[-<subidx>]`) and to satisfy the FundraisingConfig `donorExternalIdField=External_Id__c` setting on Account. The field pattern is identical everywhere; it appears once here.


### 1.1 FQS-prefix custom fields


#### `Account`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `Account.FQS_Is_Match_Intermediary__c` | Checkbox | Is Match Intermediary — Check when this Account is a matching-gift intermediary (Benevity, YourCause, Bright Funds, CyberGrants, etc.) rather than a true corporate donor. | flexipage: FQS_Account_Record_Page; flow: FQS_Guided_Gift_Entry_Subflow_Employer_Match; permset: FQS_Custom_F… |
| `Account.FQS_Match_Annual_Individual_Maximum__c` | Currency | Match Annual Individual Maximum — Maximum dollar amount this employer will match per individual per calendar year. Leave blank if the employer has no per-donor cap. | flexipage: FQS_Account_Record_Page; flow: FQS_Guided_Gift_Entry_Subflow_Employer_Match; permset: FQS_Custom_F… |
| `Account.FQS_Match_Ratio__c` | Number | Match Ratio — The dollar ratio this employer matches at. Enter 1.00 for 1:1 matching (default), 2.00 for 2:1, 0.50 for half-match, etc. Leave blank to use 1.00. | flexipage: FQS_Account_Record_Page; flow: FQS_Guided_Gift_Entry_Subflow_Employer_Match; permset: FQS_Custom_F… |
| `Account.FQS_Matching_Gift_Program__c` | Checkbox | Matching Gift Program — Check when this business Account offers an employer matching gift program. Do not check for matching-gift intermediaries such as Benevity or YourCause — use | flexipage: FQS_Account_Record_Page; flow: FQS_Guided_Gift_Entry_Subflow_Employer_Match; permset: FQS_Custom_F… |

#### `Campaign`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `Campaign.FQS_Campaign_Category__c` | Picklist | Campaign Category — Classifies the fundraising purpose of this campaign. Drives list-view segmentation on the Campaigns tab and controls related-list visibility on the Campaign rec | flexipage: FQS_Campaign_Record_Page; flow x7; permset: FQS_Custom_Fields; class x3; layout: Campaign-FQS Camp… |
| `Campaign.FQS_Child_Campaign_Count__c` | Number | Child Campaign Count — Set automatically. Count of direct child campaigns (immediate children only — grand-children are counted by their own parent). | flow: FQS_Campaign_Child_Count_Delete, FQS_Campaign_Child_Count_Update; permset: FQS_Custom_Fields; layout: C… |
| `Campaign.FQS_Create_First_Outreach_Source_Code__c` | Checkbox | Create First Outreach Source Code — Indicates the "Create First OSC" placeholder has been auto-provisioned. Set automatically by hierarchy builder; can be checked manually to (re)c | flow: FQS_Campaign_Create_First_OSC; permset: FQS_Custom_Fields; class: FQS_CampaignHierarchyBuilder; layout:… |
| `Campaign.FQS_Enable_Auto_Members__c` | Checkbox | Enable Automatic Campaign Members — When checked, gifts and commitments on this campaign automatically create or advance a Campaign Member row for the donor. Only applies to Tactic | flow x6; permset: FQS_Custom_Fields; class: FQS_CampaignHierarchyBuilder; layout: Campaign-FQS Campaign Layout |
| `Campaign.FQS_Hierarchy_Depth__c` | Number | Hierarchy Depth — Set automatically. Depth of this campaign in the hierarchy — 1 for top-level campaigns with no parent, 2 for direct children, up to 5 for the deepest supported ne | flexipage: FQS_Campaign_Record_Page; flow x8; permset: FQS_Custom_Fields; class: FQS_CampaignHierarchyBuilder… |
| `Campaign.FQS_Short_Name__c` | Text | Short Name — Equivalent to `utm_campaign` in web analytics. Used as the campaign segment when naming Outreach Source Codes. Also use this value directly as `utm_campaign` on any UR | flexipage: FQS_OutreachSourceCode_Record_Page; permset: FQS_Custom_Fields; class: FQS_CampaignHierarchyBuilde… |
| `Campaign.FQS_Ultimate_Parent_Campaign__c` | Text | Ultimate Parent Campaign — Set automatically. The name of the topmost campaign in this hierarchy branch (walks up to 5 levels of parents). Returns this campaign&apos;s own name whe | flow: FQS_Campaign_Hierarchy_Setup; permset: FQS_Custom_Fields; class: FQS_CampaignHierarchyBuilder; layout: … |

#### `DonorGiftSummary`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `DonorGiftSummary.FQS_Annual_Donor_Level_Name__c` | Text | Annual Donor Tier Name — Set automatically. The branded donor grouping name (e.g., Friend, Partner, Champion) for this donor based on current-year giving. Blank means the donor is | flexipage: FQS_Account_Record_Page, FQS_DonorGiftSummary_Record_Page; permset: FQS_Custom_Fields; report: FQS… |
| `DonorGiftSummary.FQS_Annual_Donor_Level__c` | Text | Annual Donor Tier — Automatically calculated. Shows which annual donor tier this donor belongs to (Entry, Mid, or Major) based on their giving in the current year. Blank means the | flexipage: FQS_Account_Record_Page; permset: FQS_Custom_Fields; reportType: fqs_Donor_Gift_Summary_Deluxe; li… |
| `DonorGiftSummary.FQS_Is_Entry_Annual_Donor__c` | Checkbox | Is Entry Annual Donor — Set automatically. Checked when this donor&apos;s current-year giving qualifies at the Entry annual tier. | flexipage: FQS_DonorGiftSummary_Record_Page; permset: FQS_Custom_Fields; reportType: fqs_Donor_Gift_Summary_D… |
| `DonorGiftSummary.FQS_Is_Entry_Lifetime_Donor__c` | Checkbox | Is Entry Lifetime Donor — Set automatically. Checked when this donor&apos;s lifetime giving qualifies at the Entry lifetime tier. | flexipage: FQS_DonorGiftSummary_Record_Page; permset: FQS_Custom_Fields; reportType: fqs_Donor_Gift_Summary_D… |
| `DonorGiftSummary.FQS_Is_Major_Annual_Donor__c` | Checkbox | Is Major Annual Donor — Set automatically. Checked when this donor&apos;s current-year giving qualifies at the Major annual tier. | flexipage: FQS_DonorGiftSummary_Record_Page; permset: FQS_Custom_Fields; report: FQS_Major_Annual_Donors_This… |
| `DonorGiftSummary.FQS_Is_Major_Lifetime_Donor__c` | Checkbox | Is Major Lifetime Donor — Set automatically. Checked when this donor&apos;s lifetime giving qualifies at the Major lifetime tier. | flexipage: FQS_DonorGiftSummary_Record_Page; flow: FQS_Stewardship_Response; permset: FQS_Custom_Fields; repo… |
| `DonorGiftSummary.FQS_Is_Mid_Annual_Donor__c` | Checkbox | Is Mid Annual Donor — Set automatically. Checked when this donor&apos;s current-year giving qualifies at the Mid annual tier. | flexipage: FQS_DonorGiftSummary_Record_Page; permset: FQS_Custom_Fields; report: FQS_Mid_to_Major_Upgrade_Pip… |
| `DonorGiftSummary.FQS_Is_Mid_Lifetime_Donor__c` | Checkbox | Is Mid Lifetime Donor — Set automatically. Checked when this donor&apos;s lifetime giving qualifies at the Mid lifetime tier. | flexipage: FQS_DonorGiftSummary_Record_Page; permset: FQS_Custom_Fields; reportType: fqs_Donor_Gift_Summary_D… |
| `DonorGiftSummary.FQS_Legacy_First_Gift_Date__c` | Date | Legacy First Gift Date — Earliest gift date from a legacy or external system. Preserved across NPC rollups so migrated donors keep their full historical tenure. | permset: FQS_Custom_Fields |
| `DonorGiftSummary.FQS_Legacy_Gift_Count__c` | Number | Legacy Gift Count — Count of hard-credit gifts from a legacy or external system. Adds to the standard GiftCount rollup for reporting. | permset: FQS_Custom_Fields |
| `DonorGiftSummary.FQS_Legacy_Soft_Credit_Total__c` | Currency | Legacy Soft Credit Total — Total soft-credit giving from a legacy or external system. Adds to the standard TotalSoftCreditsAmount rollup when the donor grouping tier is configured | permset: FQS_Custom_Fields; field: FQS_Lifetime_Donor_Level_Name__c, FQS_Lifetime_Donor_Level__c |
| `DonorGiftSummary.FQS_Legacy_Total_Gifts_Amount__c` | Currency | Legacy Total Gifts Amount — Total hard-credit giving from a legacy or external system. Adds to the standard TotalGiftsAmount rollup for donor-grouping calculations. | permset: FQS_Custom_Fields; field: FQS_Lifetime_Donor_Level_Name__c, FQS_Lifetime_Donor_Level__c |
| `DonorGiftSummary.FQS_Lifetime_Donor_Level_Name__c` | Text | Lifetime Donor Tier Name — Set automatically. The branded lifetime donor grouping name for this donor based on total giving to date. Your administrator controls both the thresholds | flexipage: FQS_Account_Record_Page, FQS_DonorGiftSummary_Record_Page; flow: FQS_Stewardship_Response; permset… |
| `DonorGiftSummary.FQS_Lifetime_Donor_Level__c` | Text | Lifetime Donor Tier — Automatically calculated. Shows which lifetime donor tier this donor belongs to (Entry, Mid, or Major) based on their total lifetime giving. Blank means the d | flexipage: FQS_Account_Record_Page; permset: FQS_Custom_Fields; reportType: fqs_Donor_Gift_Summary_Deluxe; li… |

#### `GiftCommitment`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `GiftCommitment.FQS_Gift_Commitment_Category__c` | Picklist | Gift Commitment Category — Classifies the type of commitment this record represents. Choose *Pledged Gift* for a one-time promise paid over time, *Recurring Gift* for an ongoing do | flexipage: FQS_Account_Record_Page, FQS_GiftCommitment_Record_Page; flow x5; permset: FQS_Custom_Fields; clas… |
| `GiftCommitment.FQS_Is_Entry_Commitment__c` | Checkbox | Is Entry Commitment — Set automatically. Checked when this commitment's total expected amount falls in the corresponding donor grouping. Your administrator controls the threshold t | flexipage: FQS_GiftCommitment_Record_Page; permset: FQS_Custom_Fields; reportType: fqs_Gift_Commitments_Delux… |
| `GiftCommitment.FQS_Is_Major_Commitment__c` | Checkbox | Is Major Commitment — Set automatically. Checked when this commitment's total expected amount falls in the corresponding donor grouping. Your administrator controls the threshold t | flexipage: FQS_GiftCommitment_Record_Page; permset: FQS_Custom_Fields; report: FQS_Major_Commitments_Active; … |
| `GiftCommitment.FQS_Is_Mid_Commitment__c` | Checkbox | Is Mid Commitment — Set automatically. Checked when this commitment's total expected amount falls in the corresponding donor grouping. Your administrator controls the threshold thr | flexipage: FQS_GiftCommitment_Record_Page; permset: FQS_Custom_Fields; reportType: fqs_Gift_Commitments_Delux… |
| `GiftCommitment.FQS_Match_Eligible__c` | Checkbox | Match Eligible — Set to true if a corporate matching gift is expected against this commitment. The Gift Entry launcher reads this to default the match question on payments recorded | flexipage: FQS_GiftCommitment_Record_Page; flow: FQS_Guided_Gift_Entry_Account, FQS_Guided_Gift_Entry_Subflow… |
| `GiftCommitment.FQS_Restriction_Release_Date__c` | Date | Restriction Release Date — The date restricted funds from this commitment become available for their designated purpose or for general use. Leave blank for gifts with no time restr | flexipage: FQS_GiftCommitment_Record_Page, FQS_GiftTransaction_Record_Page; flow x4; permset: FQS_Custom_Fiel… |
| `GiftCommitment.FQS_Skip_Naming__c` | Checkbox | Skip FQS Auto Naming — Check to prevent the FQS auto-naming flow from overwriting the Name on this Gift Commitment. Use for imports or integrations where the record already carries | flexipage: FQS_GiftCommitment_Record_Page, FQS_GiftTransaction_Record_Page; flow x3; permset: FQS_Custom_Fiel… |
| `GiftCommitment.FQS_Summary__c` | Text | Summary — Set automatically. A one-sentence plain-English summary of this commitment's schedule — cadence, amount, and start. Updates as the underlying schedule changes. | flexipage: FQS_GiftCommitment_Record_Page; permset: FQS_Custom_Fields |

#### `GiftDefaultDesignation`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `GiftDefaultDesignation.FQS_Parent_Type__c` | Text | Parent Type — Formula on ParentRecordId&apos;s key prefix. Returns &quot;Gift Commitment&quot; (6gc), &quot;Opportunity&quot; (006), &quot;Campaign&quot; (701), or blank if unset. | flexipage x4; permset: FQS_Custom_Fields; listView: FQS_Gift_Commitment_Defaults, FQS_Opportunity_Defaults; f… |
| `GiftDefaultDesignation.FQS_Restriction_Type__c` | Text | Restriction Type — FASB/GAAP restriction classification inherited from the parent Gift Designation. | flexipage x5; flow x5; permset: FQS_Custom_Fields; class: FQSSeedGenerator; reportType: GiftDesignation_Delux… |

#### `GiftDefaultSoftCredit`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `GiftDefaultSoftCredit.FQS_Parent_Type__c` | Text | Parent Type — Formula, text. Reads the 3-character key prefix of ParentRecordId (6gc → Gift Commitment, 006 → Opportunity, else blank). Recommend adding to Facet-fqs-gdsc-d-s1-left | flexipage x4; permset: FQS_Custom_Fields; listView: FQS_Gift_Commitment_Defaults, FQS_Opportunity_Defaults; f… |

#### `GiftDesignation`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `GiftDesignation.FQS_Restriction_Type__c` | Picklist | Restriction Type — How the donor restricted the funds. Without Donor Restriction: usable for any program (incl. board-designated). Purpose: must be spent on a specific use. Permane | flexipage x5; flow x5; permset: FQS_Custom_Fields; class: FQSSeedGenerator; reportType: GiftDesignation_Delux… |

#### `GiftEntry`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `GiftEntry.FQS_Donor_Tax_Date__c` | Date | Donor Tax Date — The date the donor is credited for tax purposes — postmark for mailed checks, charge date for cards, delivery date for stock. Leave blank if your org treats the Tr | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Guided_Gift_Entry_Account; permset: FQS_Custom_Fields; … |
| `GiftEntry.FQS_Fair_Market_Value_Amount__c` | Currency | Fair Market Value Amount — Estimated fair market value of the donated goods or services. Used for the tax receipt and reporting only — the donor determines the actual tax-deductibl | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Guided_Gift_Entry_Account; permset: FQS_Custom_Fields; … |
| `GiftEntry.FQS_GC_Match_Eligible__c` | Checkbox | GC Match Eligible — Check if a corporate matching gift is expected against the Gift Commitment being created. Populates the Match Eligible flag on the commitment, not on each indiv | permset: FQS_Custom_Fields; gridTemplate x4; fieldMapping: FieldMappingConfig |
| `GiftEntry.FQS_GC_Restriction_Release_Date__c` | Date | Restriction Release Date (GC) — The date restricted funds on this commitment become available for either general use or for their designated purpose. Populates onto the Gift Commit | permset: FQS_Custom_Fields; gridTemplate x4; field: FQS_GT_Restriction_Release_Date__c; fieldMapping: FieldMa… |
| `GiftEntry.FQS_GC_Skip_Naming__c` | Checkbox | Skip FQS Auto Naming (GC) — Check to prevent the FQS auto-naming flow from overwriting the Name on the resulting Gift Commitment. | permset: FQS_Custom_Fields; gridTemplate x4; field: FQS_GT_Skip_Naming__c; fieldMapping: FieldMappingConfig |
| `GiftEntry.FQS_GT_Restriction_Release_Date__c` | Date | Restriction Release Date (GT) — The date restricted funds from this payment become available for either general use or for their designated purpose. Populates onto the Gift Transac | permset: FQS_Custom_Fields; gridTemplate x4; field: FQS_GC_Restriction_Release_Date__c; fieldMapping: FieldMa… |
| `GiftEntry.FQS_GT_Skip_Naming__c` | Checkbox | Skip FQS Auto Naming (GT) — Check to prevent the FQS auto-naming flow from overwriting the Name on the resulting Gift Transaction. | permset: FQS_Custom_Fields; gridTemplate x4; field: FQS_GC_Skip_Naming__c; fieldMapping: FieldMappingConfig |
| `GiftEntry.FQS_Gift_Transaction_Category__c` | Picklist | Gift Transaction Category — Category that classifies this transaction: Outright Gift, Pledge Payment, Recurring Gift Payment, Grant Payment, or Other. | flexipage x3; flow x7; permset: FQS_Custom_Fields; class: FQSSeedGenerator; report: FQS_Stewardship_Pipeline;… |
| `GiftEntry.FQS_Match_Status__c` | Picklist | Match Status — Where this gift stands in the corporate matching lifecycle. Leave blank or set to N/A if no match is expected. Set to Received once the matching-employer transaction | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Guided_Gift_Entry_Subflow_Employer_Match; permset: FQS_… |
| `GiftEntry.FQS_Stewardship_Date__c` | Date | Stewardship Date — Date the stewardship follow-up occurred — only fill in if stewardship happened outside Salesforce. The automated stewardship flow otherwise writes this on delive | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Stewardship_Response; permset: FQS_Custom_Fields; class… |
| `GiftEntry.FQS_Stewardship_Status__c` | Picklist | Stewardship Status — Status of the follow-up stewardship touch. Set to "Don't Send" to suppress automated stewardship. Distinct from Acknowledgement Status, which tracks the initia | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Stewardship_Response; permset: FQS_Custom_Fields; class… |
| `GiftEntry.FQS_Tax_Receipt_Date__c` | Date | Tax Receipt Date — Date this gift's tax receipt was issued to the donor. Usually filled in by an annual bulk update — enter here only if the receipt was issued before entering the | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Gift_Acknowledgement; permset: FQS_Custom_Fields; class… |

#### `GiftTransaction`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `GiftTransaction.FQS_Amount_Formatted__c` | Text | Amount (Formatted) — Formatted currency string used by the FQS email templates. Derived from Current Amount. | permset: FQS_Custom_Fields; email x3 |
| `GiftTransaction.FQS_Donor_Tax_Date__c` | Date | Donor Tax Date — The date the donor is credited for tax purposes — postmark for mailed checks, charge date for cards, delivery date for stock. Leave blank if your org treats the Tr | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Guided_Gift_Entry_Account; permset: FQS_Custom_Fields; … |
| `GiftTransaction.FQS_Fair_Market_Value_Amount__c` | Currency | Fair Market Value Amount — Estimated fair market value of the donated goods or services. Used for the tax receipt and reporting only — the donor determines the actual tax-deductibl | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Guided_Gift_Entry_Account; permset: FQS_Custom_Fields; … |
| `GiftTransaction.FQS_Gift_Transaction_Category__c` | Picklist | Gift Transaction Category — Classifies what kind of transaction this record represents. *Outright Gift* is a one-time gift not tied to a commitment; *Pledge Payment*, *Recurring Gi | flexipage x3; flow x7; permset: FQS_Custom_Fields; class: FQSSeedGenerator; report: FQS_Stewardship_Pipeline;… |
| `GiftTransaction.FQS_In_Kind__c` | Checkbox | In-Kind — Check when this gift is a non-cash contribution — goods, services, or property. In-kind gifts set OriginalAmount = 0 and record the estimated value on Fair Market Value A | flexipage: FQS_GiftTransaction_Record_Page; flow x3; permset: FQS_Custom_Fields; class: FQSSeedGenerator; rep… |
| `GiftTransaction.FQS_Is_Entry_Gift__c` | Checkbox | Is Entry Gift — Automatically calculated. The field is checked when this gift's amount qualifies for the Entry donor tier, or when it is an installment payment against an Entry-tie | flexipage: FQS_GiftTransaction_Record_Page; permset: FQS_Custom_Fields; reportType x3; field: One_Time_Min_Am… |
| `GiftTransaction.FQS_Is_Major_Gift__c` | Checkbox | Is Major Gift — Automatically calculated. The field is checked when this gift's amount qualifies for the Major donor tier, or when it is an installment payment against a Major-tier | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Stewardship_Response; permset: FQS_Custom_Fields; repor… |
| `GiftTransaction.FQS_Is_Mid_Gift__c` | Checkbox | Is Mid Gift — Automatically calculated. The field is checked when this gift's amount qualifies for the Mid donor tier, or when it is an installment payment against a Mid-tier commi | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Stewardship_Response; permset: FQS_Custom_Fields; repor… |
| `GiftTransaction.FQS_Match_Status__c` | Picklist | Match Status — Where this gift stands in the corporate matching lifecycle. Leave blank or set to N/A if no match is expected. Set to Received once the matching-employer transaction | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Guided_Gift_Entry_Subflow_Employer_Match; permset: FQS_… |
| `GiftTransaction.FQS_Recurring__c` | Checkbox | Recurring — Indicates this transaction is part of a recurring giving series linked to a Gift Commitment. | permset: FQS_Custom_Fields; class: FQSSeedGenerator; reportType x3 |
| `GiftTransaction.FQS_Restriction_Release_Date__c` | Date | Restriction Release Date — The date restricted funds from this payment become available for their designated purpose or for general use. Leave blank for gifts with no time restrict | flexipage: FQS_GiftCommitment_Record_Page, FQS_GiftTransaction_Record_Page; flow x4; permset: FQS_Custom_Fiel… |
| `GiftTransaction.FQS_Skip_Naming__c` | Checkbox | Skip FQS Auto Naming — Check to prevent the FQS auto-naming flow from overwriting the Name on this Gift Transaction. Use for imports or integrations where the record already carrie | flexipage: FQS_GiftCommitment_Record_Page, FQS_GiftTransaction_Record_Page; flow x3; permset: FQS_Custom_Fiel… |
| `GiftTransaction.FQS_Stewardship_Date__c` | Date | Stewardship Date — Date the follow-up stewardship email or task was delivered. Set automatically by the flow, or manually if stewardship occurred outside Salesforce. | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Stewardship_Response; permset: FQS_Custom_Fields; class… |
| `GiftTransaction.FQS_Stewardship_Status__c` | Picklist | Stewardship Status — Status of the follow-up stewardship touch (email or task) for this gift. Set to "Don't Send" to suppress automated stewardship. Distinct from Acknowledgement S | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Stewardship_Response; permset: FQS_Custom_Fields; class… |
| `GiftTransaction.FQS_TaxDeduction_Amount_Formatted__c` | Text | Tax Deduction Amount (Formatted) — Formatted currency string used by the FQS Partial Deduction email template. Derived from Tax Deduction Amount. | permset: FQS_Custom_Fields; email: FQS_Gift_Acknowledgement_Partial |
| `GiftTransaction.FQS_Tax_Receipt_Date__c` | Date | Tax Receipt Date — Date this gift's tax receipt was issued to the donor. Enter manually or via a bulk update after your annual tax-receipt run. | flexipage: FQS_GiftTransaction_Record_Page; flow: FQS_Gift_Acknowledgement; permset: FQS_Custom_Fields; class… |
| `GiftTransaction.FQS_Transaction_Date_LongForm__c` | Text | Transaction Date (Long Form) — Long-form date used by the FQS email templates. Derived from Transaction Date. | permset: FQS_Custom_Fields; email: FQS_Gift_Acknowledgement, FQS_Gift_Acknowledgement_Partial |

#### `GiftTransactionDesignation`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `GiftTransactionDesignation.FQS_Restriction_Type__c` | Text | Restriction Type — FASB/GAAP restriction classification inherited from the parent Gift Designation. | flexipage x5; flow x5; permset: FQS_Custom_Fields; class: FQSSeedGenerator; reportType: GiftDesignation_Delux… |

#### `Opportunity`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `Opportunity.FQS_Grant_Deadline__c` | Date | Grant Deadline — The deadline to submit this grant application or report to the funder. | flexipage: FQS_Opportunity_Record_Page; permset: FQS_Custom_Fields; class: FQSSeedGenerator; reportType: fqs_… |
| `Opportunity.FQS_Grant_Report_Due__c` | Date | Grant Report Due — When the grant report (progress or final) must be submitted to the funder after the award. | flexipage: FQS_Opportunity_Record_Page; permset: FQS_Custom_Fields; reportType: fqs_Gift_Commitments_Deluxe |
| `Opportunity.FQS_Skip_Naming__c` | Checkbox | Skip FQS Auto Naming — Check to prevent the FQS auto-naming flow from overwriting the Name on this Opportunity. Use for imports or integrations where the record already carries an | flexipage: FQS_GiftCommitment_Record_Page, FQS_GiftTransaction_Record_Page; flow x3; permset: FQS_Custom_Fiel… |
| `Opportunity.FQS_Solicitation_Date__c` | Date | Solicitation Date — The date on which the formal ask was presented to the donor. Used for pipeline tracking and time-to-close analysis. | flexipage: FQS_Opportunity_Record_Page; permset: FQS_Custom_Fields; class: FQSSeedGenerator; reportType: fqs_… |

#### `OutreachSourceCode`

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `OutreachSourceCode.FQS_Message_Channel_Segment__c` | Text | Message Channel Segment — Set automatically. Rolls up Message Channel into three planning buckets — Organic, Paid Digital, or Owned or Acquired Lists — used by list views and chann | flexipage: FQS_OutreachSourceCode_Record_Page; permset: FQS_Custom_Fields; layout: Campaign-FQS Campaign Layo… |
| `OutreachSourceCode.FQS_Platform__c` | Picklist | Platform — The specific platform or sender for this source code — equivalent to utm_source in web analytics. | flexipage: FQS_Campaign_Record_Page, FQS_OutreachSourceCode_Record_Page; flow: FQS_Campaign_Create_First_OSC;… |

### 1.2 FQS-owned help-text overlays on standard / Fundraising Cloud fields

*Each row is a standard field where FQS ships help text, description, or picklist-value overrides. Purpose is the shipped inline help. Standard fields are consumed by the shipped record pages and reports; not cross-referenced here.*


#### `DonorGiftSummary`

| API name | Purpose |
|---|---|
| `DonorGiftSummary.BestGiftYear` | Set automatically. The calendar year during which this donor gave the most. |
| `DonorGiftSummary.BookedPledges` | Set automatically. The Expected Total Commitment Amount across all of this donor&apos;s open pledges (not yet fully paid). |
| `DonorGiftSummary.CompositeRfmScore` | Set automatically. Composite RFM score combining recency, frequency, and monetary components — used for donor segmentation. |
| `DonorGiftSummary.CurrentYearSoftCreditsAmount` | Set automatically. Dollar total of soft credits attributed to this donor in the current calendar year. |
| `DonorGiftSummary.FrequencyScore` | Set automatically. RFM frequency component (1–5). Higher = more frequent giving. |
| `DonorGiftSummary.GiftsThisYearAmount` | Set automatically. Dollar total of this donor&apos;s Paid gifts in the current calendar year. |
| `DonorGiftSummary.GivingLevel` | Set automatically. The dollar band that classifies this donor&apos;s giving — one of the platform-defined levels from Under $100 through $25,000,000+. |
| `DonorGiftSummary.MonetaryScore` | Set automatically. RFM monetary component (1–5). Higher = larger lifetime giving. |
| `DonorGiftSummary.RecencyScore` | Set automatically. RFM recency component (1–5). Higher = more recently giving. |
| `DonorGiftSummary.TotalBookableRevenue` | Set automatically. Sum of paid gifts plus outstanding pledge balances — the total revenue &quot;booked&quot; from this donor. |
| `DonorGiftSummary.TotalPaidRcrInstallments` | Set automatically. Lifetime count of Paid recurring-gift installments from this donor. |
| `DonorGiftSummary.TotalPaidRcrInstlAmt` | Set automatically. Lifetime dollar total of paid transactions against gift commitments whose Schedule Type is &quot;Recurring&quot;. |

#### `GiftCommitment`

| API name | Purpose |
|---|---|
| `GiftCommitment.CampaignId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftCommitment.CurrentGiftCmtScheduleId` | Set automatically. The gift commitment schedule currently in force. The platform populates this when a schedule&apos;s Start Date is today or earlier. Records with a future Start Date leave this field |
| `GiftCommitment.ExpectedTotalCmtAmount` | The total amount the donor has pledged for this commitment. |
| `GiftCommitment.FormalCommitmentType` | Allowed values: Verbal, Written. |
| `GiftCommitment.FulfillmentType` | Choose *Unconditional* when the committed funds are usable as soon as they arrive. Choose *Conditional* when the gift is contingent on specific milestones being met — typical for grants with reporting |
| `GiftCommitment.RecurrenceType` | Choose *Fixed Length* for pledges, grants, and scheduled gifts with a defined end date. Choose *Open Ended* for recurring gifts with no end date — the donor gives on a regular cadence until they cance |
| `GiftCommitment.ScheduleType` | Leave blank for standard recurring gifts and pledges — the platform will fill this in from the schedule you attach. Set to *Custom* only when the schedule has irregular installment amounts or spacing |

#### `GiftCommitmentSchedule`

| API name | Purpose |
|---|---|
| `GiftCommitmentSchedule.CommitmentUpdateReason` | Populated by the schedule edit / pause / resume flows; manual override allowed. Reporting-only. |
| `GiftCommitmentSchedule.GiftCommitmentStatus` | Read-only mirror of the parent Gift Commitment Status field. Allowed values: Draft (commitment not yet active), Active (installments being processed), Lapsed (past due with no recent payment), Failing |
| `GiftCommitmentSchedule.PaymentMethod` | Method by which installment payments are collected. Allowed values: Credit Card, ACH, Check, Cash, PayPal, Venmo, Cryptocurrency, Stock, Asset, In-Kind, Unknown. |
| `GiftCommitmentSchedule.TransactionAmount` | Enter the amount paid per transaction. For example, if the pledge is $2,000 and its paid quarterly (four times a year) then the amount should be $500. |
| `GiftCommitmentSchedule.TransactionDay` | The day of the month payments post on. For payments due at the end of the month, choose *LastDay* — this handles February and other short months automatically. Days 29, 30, and 31 aren&apos;t selectab |
| `GiftCommitmentSchedule.TransactionPeriod` | Choose the cadence for this schedule&apos;s installments. For grants and pledges with irregular payment amounts or spacing, choose *Custom* — you&apos;ll enter each installment as its own gift transac |
| `GiftCommitmentSchedule.Type` | Choose *Create Transactions* for a schedule that generates gift transactions as installments come due. Choose *Pause Transactions* to suspend installment generation temporarily — the schedule stays at |

#### `GiftDefaultDesignation`

| API name | Purpose |
|---|---|
| `GiftDefaultDesignation.GiftDesignationId` | By default this picker only shows active Gift Designations. If you need to attach this record to a retired designation (for example, to correct a back-dated commitment or to match an inbound integrati |

#### `GiftDesignation`

| API name | Purpose |
|---|---|
| `GiftDesignation.AverageTransactionAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.CurrentYearTransactionCount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.CurrentYearTrxnAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.Description` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.FirstPaidTransactionDate` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.HighestTransactionAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.IsActive` | Uncheck to retire this designation. Retired designations stay on historical gifts but won't appear when adding new gifts. |
| `GiftDesignation.IsDefault` | Check exactly ONE active designation as the org-wide default — usually the general operating fund. Gifts that arrive without an explicit designation split fall through to this bucket. |
| `GiftDesignation.LastPaidTransactionDate` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.LastTwoYearTrxnAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.LastTwoYearTrxnCount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.LastYearTransactionCount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.LastYearTrxnAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.LowestTransactionAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.Name` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.OwnerId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.TotalTransactionAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftDesignation.TotalTransactionCount` | (no help/description — FQS owns picklist values or field-level flags only) |

#### `GiftSoftCredit`

| API name | Purpose |
|---|---|
| `GiftSoftCredit.Role` | Why this party gets credit for a gift they didn't legally give — e.g., Solicitor moved the donor, Household Member is the donor's partner or family, Matched Donor is the matching employer, Honoree is |

#### `GiftTransaction`

| API name | Purpose |
|---|---|
| `GiftTransaction.AcknowledgementDate` | When this donor was thanked for the gift. Usually set automatically by the FQS Gift Acknowledgement flow when the thank-you goes out. Not the tax receipt date and not the donor tax date. |
| `GiftTransaction.AcknowledgementStatus` | Written by the `FQS_Gift_Acknowledgement` flow. `To Be Sent` (default) queues the gift for the daily run; `Sent` stamps `AcknowledgementDate`. Clearing back to `To Be Sent` re-queues on next daily run |
| `GiftTransaction.CampaignId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.CheckDate` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.CurrentAmount` | Set automatically. The gift amount remaining after any refunds or adjustments. Equals the Original Amount unless a Gift Refund has been posted. |
| `GiftTransaction.Description` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.DonorCoverAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.DonorId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.GatewayReference` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.GatewayTransactionFee` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.GenerationalCohort` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.GiftCommitmentId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.GiftCommitmentScheduleId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.GiftType` | Restricted picklist. Legal values: **Individual**, **Organizational**. Set explicitly on insert; not derived from `DonorId`. Default: `Individual`. Drives the Matching Employer Transactions related li |
| `GiftTransaction.IsFullyRefunded` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.IsPaid` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.IsPartiallyRefunded` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.IsWrittenOff` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.LastGatewayErrorMessage` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.LastGatewayProcessedDate` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.LastGatewayResponseCode` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.MatchingEmployerTransactionId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.Name` | Set automatically by the FQS naming flow. Format: donor + amount + date + gift kind. To keep a specific Name from being overwritten — e.g., a name imported from another system — check *Skip Naming*. |
| `GiftTransaction.NonTaxDeductibleAmount` | The portion of this gift the donor cannot deduct — e.g., the fair-market value of event tickets, dinners, or benefits received in exchange for the gift. |
| `GiftTransaction.OriginalAmount` | The full gift amount as originally recorded. For refunds or adjustments, don't change this — record a Gift Refund instead. |
| `GiftTransaction.OutreachSourceCodeId` | The appeal, event, or channel that generated this gift. Must belong to the Campaign selected on this record. |
| `GiftTransaction.OwnerId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.PartyPhilanthropicRsrchPrflId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.PaymentIdentifier` | The reference number for the payment channel — check number, wire confirmation number, or merchant order number. Useful for reconciliation. |
| `GiftTransaction.PaymentInstrumentId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.PaymentMethod` | Required. Drives visibility of downstream fields (`CheckDate` for check gifts; `FQS_Fair_Market_Value_Amount__c` for `In-Kind`). On pledge / recurring payments, inherits from the parent schedule. |
| `GiftTransaction.ProcessorReference` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.ProcessorTransactionFee` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.RefundedAmount` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.Status` | Where this gift is in the payment cycle. Choose Pending for gifts you've recorded financially but not yet received, Paid once the payment is in hand. |
| `GiftTransaction.TaxDeductionAmount` | Automatically calculated as Current Amount minus Non-Tax Deductible Amount. For In-Kind gifts, the deductible portion is instead tracked on Fair Market Value Amount, since the donor determines the FMV |
| `GiftTransaction.TaxReceiptStatus` | `Sent` stamps `FQS_Tax_Receipt_Date__c`. Available from API 62.0+. Year-end receipting is out of scope for FQS automation — status is manually set today. |
| `GiftTransaction.TotalTransactionFee` | (no help/description — FQS owns picklist values or field-level flags only) |
| `GiftTransaction.TransactionDate` | The date the donor made this gift — check date, credit-card charge date, or the date the wire hit. Required when Status is Paid or Fully Refunded. |
| `GiftTransaction.TransactionDueDate` | The date this gift was expected. For a one-time gift you're recording now, set the same date as Transaction Date. For a pledge or recurring payment, this matches the installment's scheduled due date. |

#### `GiftTransactionDesignation`

| API name | Purpose |
|---|---|
| `GiftTransactionDesignation.GiftDesignationId` | By default this picker only shows active Gift Designations. If you need to attach this record to a retired designation (for example, to correct a back-dated gift or to match an inbound integration), u |

#### `GiftTribute`

| API name | Purpose |
|---|---|
| `GiftTribute.HonoreeContactId` | The Person Account the tribute is for. Use this when the honoree already exists in FundFirst as a Person Account; fall back to Honoree Name for one-off honorees who don't need their own record. |
| `GiftTribute.TributeType` | Pick whether this tribute is In Honor Of (living recipient) or In Memory Of (deceased). |

#### `Opportunity`

| API name | Purpose |
|---|---|
| `Opportunity.AccountId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.Amount` | The dollar value the donor is expected to give if this Opportunity closes-won. For grants, the request amount; for major gifts, the ask amount. |
| `Opportunity.CampaignId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.CloseDate` | The date this Opportunity is expected to close — award decision date for grants, expected commitment date for major gifts. |
| `Opportunity.ContractId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.Description` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.ExpectedRevenue` | Set automatically. `Amount × Probability`. Used by pipeline forecasts to weight open Opportunities. |
| `Opportunity.IqScore` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.IsPrivate` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.LeadSource` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.Name` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.NextStep` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.OwnerId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.Pricebook2Id` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.Probability` | Likelihood this Opportunity closes-won, as a percentage. Defaults from the selected Stage — override only when you have Opportunity-specific intelligence. |
| `Opportunity.SourceId` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.StageName` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.TotalOpportunityQuantity` | (no help/description — FQS owns picklist values or field-level flags only) |
| `Opportunity.Type` | (no help/description — FQS owns picklist values or field-level flags only) |

#### `OutreachSourceCode`

| API name | Purpose |
|---|---|
| `OutreachSourceCode.AudienceCount` | How many people this outreach was sent to — email list size, print quantity, ad-reach estimate. Required for Response Rate on the child Outreach Summary to compute. |
| `OutreachSourceCode.MessageChannel` | Equivalent to utm_medium in web analytics. |
| `OutreachSourceCode.MessageChannelPlatform` | Free text (255). Distinct from the FQS-authored FQS_Platform__c picklist. |
| `OutreachSourceCode.MessageChannelPlatformAccount` | The specific sender account on the platform — e.g., the email-sending domain, the ad account ID, or the social handle used for this tactic. Useful for reconciling gift attribution against platform-sid |
| `OutreachSourceCode.SourceCode` | Managed by Outreach Source Code Generation in Setup. The Code Formula populates this field with the parent Campaign&apos;s Short Name followed by a random uniqueness suffix. |
| `OutreachSourceCode.SourceCodeUrl` | The full attributed landing URL for this outreach tactic — combines the campaign&apos;s short name (utm_campaign), Message Channel (utm_medium), Platform (utm_source), and Source Code (utm_content). C |
| `OutreachSourceCode.Status` | Unrestricted picklist — FundFirst ships Active, Inactive, Archived. Reporting-only in FQS. |
| `OutreachSourceCode.UsageType` | Restricted picklist. Legal values: Fundraising (only value shipped by NPC today). When UsageType = &apos;Fundraising&apos;, CampaignId is required or insert/update fails. |

#### `OutreachSummary`

| API name | Purpose |
|---|---|
| `OutreachSummary.AttributedAmount` | Total revenue credited to this campaign or outreach source code. Combines one-time cash gifts with the earned-to-date value of recurring pledges originated by this outreach. |
| `OutreachSummary.DonorCount` | Number of unique donors who made a paid gift attributed to this campaign or outreach source code. A donor who gave multiple times is counted once. |
| `OutreachSummary.GiftCount` | Total number of paid gift transactions attributed to this campaign or outreach source code. One donor may contribute multiple gifts, each counted separately. |
| `OutreachSummary.OnetimeDonorCount` | Number of unique donors whose paid gifts were one-time (not connected to a recurring gift commitment). |
| `OutreachSummary.RecurringDonorCount` | Number of unique donors who made at least one paid recurring installment attributed to this campaign or outreach source code. |
| `OutreachSummary.ResponseRate` | Percentage of the outreach audience who made at least one paid gift. Calculated as CEIL(DonorCount / AudienceCount × 100). |
| `OutreachSummary.TotalGiftTransactionAmount` | Sum of all paid gift transaction amounts attributed to this campaign or outreach source code, across one-time and recurring gift types. |
| `OutreachSummary.TotalOnetimeGiftAmount` | Sum of paid gift transactions that do not have any gift commitment associated with them. |
| `OutreachSummary.TotalRecurringGiftAmount` | Sum of paid gift transactions associated with a gift commitment whose Schedule Type is &quot;Recurring&quot;. |

**`External_Id__c` on:** `Account`, `Campaign`, `DonorGiftSummary`, `GiftCommitment`, `GiftCommitmentSchedule`, `GiftDesignation`, `GiftRefund`, `GiftSoftCredit`, `GiftTransaction`, `GiftTransactionDesignation`, `GiftTribute`, `Opportunity`, `OutreachSourceCode`, `PaymentInstrument` — seed-script upsert key + FundraisingConfig donor matching. Pattern identical across objects.



## 2. Custom metadata types

Three FQS-owned custom metadata types. All are Setup-editable through the FQS Setup screens on the Home page.


### `FQS_Campaign_Hierarchy_Setup__mdt`

State-of-record for the last Campaign Hierarchy Setup run — chosen model, top-level Campaign id, per-model created-Ids JSON, last ask-creation choice, and last-run timestamp. Read/written by `FQS_CampaignHierarchyBuilder`.

| Field | Type | Purpose |
|---|---|---|
| `All_Created_Top_Level_Ids_JSON__c` | LongTextArea | All Created Top Level IDs (JSON) — Stores the Salesforce IDs of all top-level Campaigns created when the setup flow last ran. For Giving Programs runs, this is a JSON array of all |
| `Chosen_Model__c` | Picklist | Chosen Model — The campaign hierarchy model the admin chose the last time the setup flow ran successfully. |
| `Last_Ask_Creation_Choice__c` | Checkbox | Last Ask Creation Choice — Records whether the admin chose to create individual ask campaigns (level 3) during the last setup run. |
| `Last_Run_At__c` | DateTime | Last Run At — The date and time when the campaign hierarchy setup flow last ran successfully. |
| `Last_Top_Level_Id__c` | Text | Last Top Level Campaign ID — The 18-character Salesforce ID of the main top-level Campaign created when the setup flow last ran. Navigate to this Campaign to see the full hierarchy |

### `FQS_Campaign_Template__mdt`

Blueprint rows for the Campaign Hierarchy Setup catalog. Each row is one campaign template (display label, suggested name, sort order, function group, hierarchy level, date-rule, applicable fundraising models, default-in-model flag, parent template key). `FQS_CampaignHierarchyBuilder` reads this catalog to construct the campaign hierarchy for the chosen fundraising model.

| Field | Type | Purpose |
|---|---|---|
| `Applicable_Models__c` | Text | Applicable Models — Semicolon-separated list of models for which this template applies. Valid values: Seasonal, GivingPrograms, Strategy. Example: "Seasonal;Strategy". The Apex bui |
| `Date_Rule__c` | Picklist | Date Rule — Controls how start and end dates are assigned when the campaign is created. Apex expands the token using the org's fiscal year window (topStart/topEnd) detected at flow |
| `Default_In_Model__c` | Text | Default In Model — Semicolon-separated list of models where this template is a pre-seeded default. Leave blank to make this template available only via the library picker. Valid va |
| `Display_Label__c` | Text | Display Label — The label shown in the campaign-setup flow's Tactical picker. Leave blank on Rollup/Strategy templates and templates that don't need parent disambiguation. |
| `Function_Group__c` | Picklist | Function Group — Controls which section this template appears in when the admin browses the campaign template library. Choose the primary fundraising function this ask or strategy |
| `Level__c` | Picklist | Level — Rollup creates a top-level Campaign (year rollup or evergreen program top). Strategy creates a mid-tier Campaign. Ask creates a leaf-level Campaign linked to a strategy. |
| `Notes__c` | LongTextArea | Notes — Internal notes about this campaign template. Not shown to admins using the setup flow. |
| `Parent_Template_Key__c` | Text | Parent Template Key — Must match the Template_Key__c of an existing parent template. Apex uses this at build time to assign Campaign.ParentId. Leave blank for top-level (rollup) te |
| `Sort_Order__c` | Number | Sort Order — Controls the order templates appear in the setup flow. Lower numbers appear first within each level and function group. |
| `Suggested_Name__c` | Text | Suggested Name — Template placeholders {yearLabel} and {yearShort} are replaced with the detected fiscal or calendar year before the Campaign is created. Example: Spring Appeal {ye |
| `Template_Key__c` | Text | Template Key — A stable unique identifier for this template used by the Apex builder. Do not change this value after deployment — doing so will break parent-child links in the buil |

**Records (53):** seven strategic-level rollup templates (`Str_*`); ten program templates (`Prg_*`); and 36 tactical templates spanning acquisition (`Acq_*`), solicitation (`Sol_*`), retention (`Ret_*`), foundation (`Fnd_*`), planned giving (`Pg_*`), event (`Evt_*`), and advocacy (`Adv_*`) shapes.

### `FQS_Donor_Tier__mdt`

Editable tier thresholds and branded-name overrides for the three donor bands (`Entry` → "Friend", `Mid` → "Partner", `Major` → "Champion"). Governs every `FQS_Is_*_Donor__c` / `FQS_Is_*_Gift__c` / `FQS_Is_*_Commitment__c` boolean formula. Edited via `FQS_Setup_Tier_Thresholds` + `FQS_Setup_Stewardship_Response_Settings` flows.

| Field | Type | Purpose |
|---|---|---|
| `Annual_Min_Amount__c` | Number | Annual Minimum Amount — The minimum fiscal-year giving total for a donor to qualify for this donor tier annually. Your administrator controls this threshold. Updating it automatica |
| `Branded_Name__c` | Text | Donor Tier — The organization's specific naming structure for public donor recognition. Changing this value here automatically updates FQS_*_Donor_Level_Name__c on all Donor Gift S |
| `Credit_Type__c` | Picklist | Credit Type — Choose whether this donor tier counts hard credits only, or hard + soft credits combined. Configured per tier — a Major tier can count soft credits (spouses, foundati |
| `FQS_Auto_Stewardship__c` | Picklist | Auto Stewardship — Determines whether a gift in this donor tier triggers an automatic stewardship email (Include All), a personal-touch task (Exclude All), or a lifetime-escalating |
| `Lifetime_Min_Amount__c` | Number | Lifetime Minimum Amount — The minimum lifetime giving total for a donor to qualify for this donor tier. Your administrator controls this threshold. Updating it automatically recalc |
| `One_Time_Min_Amount__c` | Number | One-Time Minimum Amount — The minimum gift amount for a single transaction to qualify for this donor tier. Your administrator controls this threshold. Updating it automatically rec |
| `Sort_Order__c` | Number | Sort Order — Controls the display order of donor tiers in Setup and reports. Lower numbers appear first. This field is for presentation only — the FQS_*_Donor_Level__c formula eval |
| `Tier_Key__c` | Picklist | Tier Key — The generic donor tier. The FQS_*_Donor_Level__c formula fields on Donor Gift Summary return this value and it is used for list views and reports. A single custom metada |

**Records (3):** `Entry` (Friend), `Mid` (Partner), `Major` (Champion). Threshold values are the seed defaults — orgs edit them in-place via the FQS Setup screen.


## 3. Flows

Organized by trigger family. `Runs on` shows the object + record-trigger type for automation flows; `Purpose` is the first sentence of the flow's shipped description.


### Screen flows (user-facing)

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

### Record-triggered — before save

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Auto_Category_Gift_Transaction` | `GiftCommitment` · Create | Assigns the derived FQS_Gift_Transaction_Category__c back onto the in-flight GT. | flow: FQS_Guided_Gift_Entry_Account; field: FQS_Gift_Commitment_Category__c, FQS_Gift_Transaction_Category__c |
| `FQS_Auto_Name_Gift_Commitment` | `Account` · CreateAndUpdate | Assigns the computed Name back onto the in-flight record. | ⚠ unreferenced |
| `FQS_Auto_Name_Gift_Transaction` | `Account` · CreateAndUpdate | Assigns the computed Name back onto the in-flight record. | flow: FQS_Guided_Gift_Entry_Account; field: Name |
| `FQS_Auto_Name_Opportunity` | `Account` · CreateAndUpdate | Assigns the computed Name back onto the in-flight record. | ⚠ unreferenced |

### Record-triggered — after save

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

### Record-triggered — before delete

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Campaign_Child_Count_Delete` | `Campaign` · Delete | Resets varParentCount to 0, then sets it to the size of the sibling collection. | permset: FQS_Custom_Fields; field: FQS_Child_Campaign_Count__c |
| `FQS_Campaign_Member_Status_On_Commitment_Delete` | `Account` · Delete | Fundraising Quick Start: on GiftCommitment hard-delete, reverts the donor's CampaignMember on the same campaign to the starting ladder rung (Solicited baseline / Registered event) | ⚠ unreferenced |
| `FQS_Campaign_Member_Status_On_Gift_Transaction_Delete` | `Account` · Delete | Fundraising Quick Start: on GiftTransaction hard-delete, reverts the donor's CampaignMember on the same campaign to the starting ladder rung (Solicited baseline / Registered event) | ⚠ unreferenced |
| `FQS_GC_Fulfillment_From_GDD_Delete` | `GiftDefaultDesignation` · Delete | Two gates in one decision. | ⚠ unreferenced |

### Scheduled flows

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Automatic_Rollup_Updates` | AutoLaunchedFlow | Scheduled flow that runs the Manage Fundraising Definitions invocable action daily to refresh Fundraising rollup summaries (Donor Gift Summary, Outreach Summary, Gift Designation). | ⚠ unreferenced |
| `FQS_Coordinate_Gift_Commitment_Processing` | AutoLaunchedFlow | Calls an action to get the currently enabled version of the gift commitment processing engine. | flow: FQS_Guided_Gift_Entry_Account |
| `FQS_Gift_Acknowledgement` | `Account` | Sends the FQS Gift Acknowledgement template (full deduction) to the donor&apos;s PersonContact using the emailSimple v3 template-aware action. | email: FQS_Gift_Acknowledgement, FQS_Gift_Acknowledgement_Partial; field: AcknowledgementStatus, FQS_Auto_Ste… |
| `FQS_Stewardship_Response` | `Task` | Sends the FQS Stewardship Response (Standard) email template to the donor&apos;s PersonContact using the emailSimple v3 template-aware action. | flow: FQS_Gift_Acknowledgement; email: FQS_Gift_Acknowledgement, FQS_Stewardship_Response_Standard; field: FQ… |

### Auto-launched subflows

| API name | Runs on | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Guided_Gift_Entry_Subflow_Soft_Credit_Reach` | `Contact` | Seed the candidate-Id accumulator with the ACR-reach Account Ids produced by Transform_ACR_Account_Ids. | flow: FQS_Guided_Gift_Entry_Account |
| `FQS_Recalculate_GC_FulfillmentType` | `GiftCommitment` | Sets varHasRestrictedGD to TRUE and jumps straight to Decide_Fulfillment_Value (skipping remaining loop iterations). | flow x3 |


## 4. FlexiPages


### 4.1 Record pages

Each page is overridden onto its Sobject via `<actionOverrides>` on `FQS_Console`.

| API name | Sobject | Referenced by |
|---|---|---|

### 4.2 Home page and utility bar

| API name | Type | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Account_Record_Page` | Facet | FQS Account Record Page | app: FQS_Console |
| `FQS_Campaign_Record_Page` | Region | FQS Campaign Record Page | object: Campaign; app: FQS_Console |
| `FQS_DonorGiftSummary_Record_Page` | Facet | FQS DonorGiftSummary Record Page | app: FQS_Console |
| `FQS_GiftBatch_Record_Page` | Facet | FQS Gift Batch Record Page | app: FQS_Console |
| `FQS_GiftCmtChangeAttrLog_Record_Page` | Facet | FQS_GiftCmtChangeAttrLog_Record_Page | app: FQS_Console |
| `FQS_GiftCommitmentSchedule_Record_Page` | Facet | FQS_GiftCommitmentSchedule_Record_Page | app: FQS_Console |
| `FQS_GiftCommitment_Record_Page` | Facet | FQS Gift Commitment Record Page | app: FQS_Console, standard__FundraisingOperationsConsole |
| `FQS_GiftDefaultDesignation_Record_Page` | Facet | FQS_GiftDefaultDesignation_Record_Page | app: FQS_Console |
| `FQS_GiftDefaultSoftCredit_Record_Page` | Facet | FQS_GiftDefaultSoftCredit_Record_Page | app: FQS_Console |
| `FQS_GiftDesignation_Record_Page` | Facet | FQS Gift Designation Record Page | app: FQS_Console |
| `FQS_GiftRefund_Record_Page` | Facet | FQS_GiftRefund_Record_Page | app: FQS_Console |
| `FQS_GiftSoftCredit_Record_Page` | Facet | FQS_GiftSoftCredit_Record_Page | app: FQS_Console |
| `FQS_GiftTransactionDesignation_Record_Page` | Facet | FQS_GiftTransactionDesignation_Record_Page | app: FQS_Console |
| `FQS_GiftTransaction_Record_Page` | Facet | FQS Gift Transaction Record Page | app: FQS_Console |
| `FQS_GiftTribute_Record_Page` | Facet | FQS_GiftTribute_Record_Page | app: FQS_Console |
| `FQS_Home_Page_Default` | HomePage | FQS Home Page — sidebar accordions embed the seven Home-launchable flows plus donor-tier dashboard + quick-report tiles. | flow: FQS_Create_Gift_Batch, FQS_Guided_Gift_Entry_HomePage; app: FQS_Console |
| `FQS_Opportunity_Record_Page` | Facet | FQS Opportunity Record Page | app: FQS_Console |
| `FQS_OutreachSourceCode_Record_Page` | Facet | FQS OutreachSourceCode Record Page | app: FQS_Console |
| `FQS_OutreachSummary_Record_Page` | Facet | FQS_OutreachSummary_Record_Page | app: FQS_Console |
| `FQS_PaymentInstrument_Record_Page` | Facet | FQS_PaymentInstrument_Record_Page | app: FQS_Console |
| `Fundraising_Quick_Start_UtilityBar1` | UtilityBar | Utility bar — pins `FQS_Guided_Gift_Entry_Account` as a persistent flow-runtime tab. | app: FQS_Console |


## 5. Apps, tabs, quick actions

### 5.1 Apps

| API name | Nav | Purpose |
|---|---|---|
| `FQS_Console` | Console | Fundraising Quick Start console app — 14 tabs; every FQS record page overrides its Sobject's View action into this app. Utility bar `Fundraising_Quick_Start_UtilityBar1`. |
| `standard__FundraisingOperationsConsole` | Console | Salesforce-shipped Fundraising Operations Console — FQS ships one override so `GiftCommitment` renders `FQS_GiftCommitment_Record_Page`. |

**FQS_Console tabs (14):** `standard-home`, `standard-Account`, `standard-GiftCommitment`, `standard-GiftTransaction`, `standard-Campaign`, `standard-Opportunity`, `standard-GiftDesignation`, `standard-GiftBatch`, `standard-Task`, `standard-ActionPlanTemplate`, `standard-IndustriesCsvDataimport`, `standard-Dashboard`, `standard-report`, `standard-EmailTemplate`.

### 5.2 Quick actions

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


## 6. Apex classes

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


## 7. Permission sets

| API name | Grants | Purpose | Referenced by |
|---|---|---|---|
| `FQS_Bypass_Automation` | 1 custom perm | Bypass permset for migration/data-loader users. Grants `FQS_Bypass_Automation` custom permission so the three GC-fulfillment RT flows short-circuit. Post-migration run `scripts/apex/fqs-recalc-gc-fulfillmenttype.apex`. | flow x3 |
| `FQS_Campaign_Fields` | 20 field perms | Read/edit FLS on all permissionable standard Campaign fields. | ⚠ unreferenced |
| `FQS_Custom_Fields` | 87 field perms · 1 RT · 4 class accesses | Umbrella permset: FLS on every FQS custom field across Gift objects, plus `Campaign.FQS_Fundraising` record type and the four FQS_Match / FQS_CampaignHierarchyBuilder / FQS_CustomMetadataSaver Apex classes. | ⚠ unreferenced |
| `FQS_Email_Template_Builder_Permission` | Setup entitlement | "Access drag-and-drop content builder" toggle so admins can edit the three FQS email templates in Email Content Builder. | ⚠ unreferenced |
| `FQS_Naming_Opt_Out` | 3 field perms · 1 custom perm | Bypass permset for integration users. Grants `FQS_Skip_Record_Naming` + edit FLS on `FQS_Skip_Naming__c` so the three auto-name flows leave the Name alone. | flow: FQS_Auto_Name_Opportunity |
| `FQS_Person_Account_Fields` | 16 field perms · 2 RTs | Read access to standard PersonAccount fields when Person Accounts are enabled. | class: FQS_MatchServices_Test |
| `FQS_Record_Type_Access` | 3 RT visibilities | Grants `Opportunity.Major_Gift`, `Opportunity.Grant`, `Campaign.FQS_Fundraising` visibility on top of standard profiles. | ⚠ unreferenced |


## 8. Reports, dashboards, report types

### 8.1 Report types

| API name | Base | Purpose | Referenced by |
|---|---|---|---|
| `Campaign_Deluxe` | Campaign→CampaignChildren→GiftTransaction | Cross-level Campaign type used by the record-page reports so grandchild GTs roll up to top-level Campaigns. | report: Campaign_Record_Page_Report_Level1_pWX, Campaign_Record_Page_Report_Level2_zMR |
| `Campaigns_and_Gift_Transactions` | Campaign→GiftTransaction | Baseline Campaign-with-Gift-Transactions type. | report: Campaign_Record_Page_Report_nLT |
| `GiftDesignation_Deluxe` | GiftDesignation→GTD→GiftTransaction | Lets Designation record-page reports show underlying GTs grouped by parent status. | report: GiftDesignation_Record_Page_Report_qKR |
| `fqs_Donor_Gift_Summary_Deluxe` | DonorGiftSummary→Account | Exposes the FQS donor-tier boolean formula fields on DGS. | report x3 |
| `fqs_Gift_Commitments_Deluxe` | GiftCommitment | Surfaces FQS commitment-tier booleans + category. | report: FQS_Major_Commitments_Active |
| `fqs_Gift_Transactions_Deluxe` | GiftTransaction→Campaign | Surfaces FQS gift-tier booleans, category, stewardship status, campaign-hierarchy fields. | report: FQS_Campaign_Performance_By_Depth, FQS_Major_Gifts_This_Year, FQS_Stewardship_Pipeline |

### 8.2 Reports

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

### 8.3 Dashboards + report folders

| API name | Folder | Purpose |
|---|---|---|
| `FQS_Donor_Tiers` | FQSDashboards | FQS Donor Tiers — donor-tier dashboard surfaced from FQS Home. |

**Report folders:** `FQSDonorTierReports` (7 donor-tier + stewardship reports), `FQSRecordPageReports` (4 record-page embedded reports).



## 9. Global value sets, standard value sets, custom permissions

### 9.1 Global value sets

| API name | Purpose | Referenced by |
|---|---|---|
| `FQS_Gift_Transaction_Category` | Classifies gift transaction kind (Outright Gift / Pledge Payment / Recurring Gift Payment / Grant Payment / Other). Shared between `GiftTransaction.FQS_Gift_Transaction_Category__c` and `GiftEntry.FQS_Gift_Transaction_Category__c`. | field: FQS_Gift_Transaction_Category__c |
| `FQS_Match_Status` | Corporate matching-gift lifecycle (Eligible / Request Confirmed / Received / Declined / N/A). Shared between `GiftTransaction.FQS_Match_Status__c` and `GiftEntry.FQS_Match_Status__c`. | field: FQS_Match_Status__c |
| `FQS_Stewardship_Status` | Post-acknowledgement stewardship touch state (To Be Sent / Sent / Don't Send). Shared between `GiftTransaction.FQS_Stewardship_Status__c` and `GiftEntry.FQS_Stewardship_Status__c`. | field: FQS_Stewardship_Status__c |

### 9.2 Standard value sets (overrides)

FQS overrides of Salesforce-shipped picklists — ensures the FQS values ship in the package even for fresh orgs.

| API name | Purpose |
|---|---|
| `GiftBatchScreenTempName` | Gift Entry batch template picklist — carries the four FQS-shipped grid templates. |
| `GiftCommitmentStatus` | Gift Commitment status values used by the four FQS list views + path assistant. |
| `GiftRefundReason` | Gift Refund reason picklist used by refund quick-action screen flows. |
| `GiftSoftCreditRole` | Soft credit role values (Household Member, Matched Donor, Solicitor, Honoree). |
| `OpportunityStage` | FQS Opportunity stage picklist — six active stages per record type (Major Gift + Grant sales processes). Non-FQS standard stages `isActive=false`. |
| `OpportunityType` | FQS Opportunity type picklist values. |

### 9.3 Custom permissions

| API name | Purpose | Referenced by |
|---|---|---|
| `FQS_Bypass_Automation` | Bypass token. When held by the running user, the three GC-fulfillment RT flows short-circuit their recalc paths. Granted via `FQS_Bypass_Automation` permset. | flow x3; permset: FQS_Bypass_Automation |
| `FQS_Skip_Record_Naming` | Bypass token. When held by the running user, the three auto-name flows skip Name rewrites so integration users preserve upstream-owned Names. Granted via `FQS_Naming_Opt_Out` permset. | flow x3; permset: FQS_Naming_Opt_Out |


## 10. Supporting metadata

List views (76), layouts, record types, business processes, path assistants, queues + group, action plan templates, gift-entry grid templates, email templates, duplicate/matching rules, compact layouts, the UI format-spec set, FundraisingConfig, and the Gift Entry field-mapping record.


### 10.1 List views

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

### 10.2 Record types

| API name | Purpose |
|---|---|
| `Campaign.FQS_Fundraising` | Marks a Campaign as FQS-managed; drives path assistant + record-page selection. |
| `Opportunity.Grant` | Grant Opportunity flavor — paired with `FQS Grant Process` business process. |
| `Opportunity.Major_Gift` | Major-gift Opportunity flavor — paired with `FQS_Major_Gift_Process` business process. |

### 10.3 Compact layouts

| API name | Purpose |
|---|---|
| `Account.FQS_Account_Compact_Layout` | Compact display for Organization Accounts — Name, Type, Website, Phone, Owner. |
| `Campaign.FQS_Campaign_Compact_Layout` | Compact display for Fundraising Campaigns — Name, Category, Short Name, Status, Owner. |
| `PersonAccount.FQS_Person_Account_Compact_Layout` | Compact display for Person Accounts — donor-focused fields. |

### 10.4 Business processes

| API name | Purpose |
|---|---|
| `Opportunity.FQS Grant Process` | Sales process 'FQS Grant Process' — subsets `OpportunityStage` for the paired record type. |
| `Opportunity.FQS_Major_Gift_Process` | Sales process 'FQS_Major_Gift_Process' — subsets `OpportunityStage` for the paired record type. |

### 10.5 Page layouts

FQS ships Lightning flexipages for the primary UX and a minimal set of classic layouts (mainly to satisfy record-type/business-process assignments). Per memory `fqs-classic-layouts-out-of-scope`, comprehensive Classic coverage is intentionally out of scope.

**Layouts (11):** `Account-Account Layout`, `Account-FQS Account Layout`, `Campaign-FQS Campaign Layout`, `FQS_Campaign_Template__mdt-FQS Campaign Template Layout`, `FQS_Donor_Tier__mdt-FQS Donor Tier Layout`, `GiftCommitment-Gift Commitment Layout`, `GiftDesignation-Gift Designation Layout`, `GiftTransaction-Gift Transaction Layout`, `Opportunity-FQS Opportunity Layout`, `PersonAccount-FQS Person Account Layout`, `PersonAccount-Person Account Layout`.

### 10.6 Path assistants

| API name | Object | Purpose |
|---|---|---|
| `FQS_Campaign_Status` | Campaign | Guided path over Campaign Status for the FQS_Fundraising record type. |
| `FQS_GiftCommitment_Status` | GiftCommitment | Guided path over GiftCommitment Status covering the pledge/recurring lifecycle. |
| `FQS_GiftRefund_Status` | GiftRefund | Guided path over GiftRefund Status. |
| `FQS_GiftTransaction_Status` | GiftTransaction | Guided path over GiftTransaction Status. |

### 10.7 Queues + Group

| API name | Type | Purpose |
|---|---|---|
| `FQS_Executive_Fundraising_Tasks` | Queue | Used to assign tasks needed to be done by an executive. Allows FQS some flexibility in shipping Action Plans, but also could help organizati |
| `FQS_Gift_Processing_Tasks` | Queue | Used for acknowledgements, tax receipting, and gift entry tasks created by the Moves Management and Stewardship Action Plans. |
| `FQS_Major_Donor_Tasks` | Queue | Used to assign tasks related to research and proposal creation for the Moves Management Action Plan. |
| `FQS_Stewardship_Tasks` | Queue | Used for cultivation tasks by the Stewardship action plan. |
| `FQS_Fundraisers` | Public group | Group used to assign FQS permsets and route Task ownership. |

### 10.8 Action plan templates

| API name | Target | Purpose |
|---|---|---|
| `Moves_Management_65c3e74a_90d4_11f1_9ffa_750d1a89e526` | Account | Moves Management — standard task ladder walking a major gift from Identification through Solicitation. Routes to `FQS_Major_Donor_Tasks` + `FQS_Executive_Fundraising_Tasks` queues. |
| `Stewardship_38e8d861_90da_11f1_b64a_f1bc2df97554` | Account | Stewardship — cultivation tasks routed to `FQS_Stewardship_Tasks` queue after a Major-tier gift is booked. |

### 10.9 Gift entry grid templates

| API name | Purpose |
|---|---|
| `FQS_Event_Registrations` | Batch template for event-registration gift entry (Event category, tribute row). |
| `FQS_Individual_Outright_Gifts` | Default outright-gift batch template (cash / check / credit / in-kind). |
| `FQS_Pledge_Payments` | Batch template for entering pledge installment payments (parent GC/GCS pre-linked). |
| `FQS_Single_Payment_Pledges` | Batch template for single-payment pledges (one GC + one GT in one submission). |

### 10.10 Email templates

| API name | Subject | Purpose |
|---|---|---|
| `FQS_Gift_Acknowledgement` | Thank you for your gift! | Full-tax-deductible acknowledgement — sent by `FQS_Gift_Acknowledgement` scheduled flow. |
| `FQS_Gift_Acknowledgement_Partial` | Thank you for your gift! | Partial-tax-deductible variant — used when NonTaxDeductibleAmount > 0. |
| `FQS_Stewardship_Response_Standard` | Thanks again — plus a small update | Post-acknowledgement stewardship touch — sent by `FQS_Stewardship_Response` scheduled flow ~14 days after acknowledgement. |

**Email folder:** `FQS_Templates` — public folder holding the three templates above.

### 10.11 Duplicate + matching rules

| API name | Purpose |
|---|---|
| `Account.FQS_Account_Organization_Dupe` | Warning-level DR on Organization Accounts. Pairs with `FQS_Account_Organization_Match`. |
| `Account.FQS_Account_Person_Dupe` | Warning-level DR on PersonAccounts keyed on `External_Id__c`. Pairs with `FQS_Account_External_Id_Match`. |
| `Contact.FQS_Contact_Dupe` | Warning-level Contact DR keyed on name+email. Pairs with `FQS_Contact_Individual_Match`. |
| `Account.matchingRule` | Two matching rules: `FQS_Account_Organization_Match` (Organization name+billing city fuzzy), `FQS_Account_External_Id_Match` (`External_Id__c` exact). |
| `Contact.matchingRule` | One matching rule: `FQS_Contact_Individual_Match` (name+email fuzzy). |

### 10.12 UI format spec, Fundraising Config, Field Mapping Config

| API name | Purpose |
|---|---|
| `Value_Matches_Expected` | UI format spec on Gift Batch record page — green-highlights lines where actual value matches expected. |
| `FundraisingConfig` | Org-wide Fundraising Cloud settings — donor matching via Duplicate Management Rules on `External_Id__c`, `installmentExtDayCount=1`, `lapsedUnpaidTrxnCount=3`, household soft-credit auto-create disabled, `outreachSourceCodeGenFmla={Campaign.FQS_Short_Name__c}`, UTM source = `OutreachSourceCode.FQS_Platform__c`. |
| `FieldMappingConfig` | Gift Entry field mappings that flow `GiftEntry.FQS_*` staging fields into the matching `GiftTransaction.FQS_*` canonical fields. Deployed via mdapi format only. |


## 11. Aggregated unreferenced findings

Every `⚠ unreferenced` cell from §1–§10, consolidated. "Unreferenced" means no other file in `force-app/main/default/` names the item via a `\b<api-name>\b` match. That is a signal, not a verdict: some items (permsets, top-level apps, path assistants, action-plan templates) are user-assigned or admin-configured in-org rather than cross-referenced in metadata. Use this list as input for A3's dead-code purge; do not delete without a targeted check.

| Kind | API name | Section |
|---|---|---|
| flow | `FQS_Auto_Name_Gift_Commitment` | §3 |
| flow | `FQS_Auto_Name_Opportunity` | §3 |
| flow | `FQS_GC_Fulfillment_From_GDD` | §3 |
| flow | `FQS_GC_Fulfillment_On_Change` | §3 |
| flow | `FQS_Campaign_Member_Status_On_Commitment_Delete` | §3 |
| flow | `FQS_Campaign_Member_Status_On_Gift_Transaction_Delete` | §3 |
| flow | `FQS_GC_Fulfillment_From_GDD_Delete` | §3 |
| flow | `FQS_Automatic_Rollup_Updates` | §3 |
| quickAction | `FQS_New_Grant` | §5.2 |
| quickAction | `FQS_New_Major_Gift` | §5.2 |
| class | `FQS_CampaignHierarchyBuilder_Test` | §6 |
| class | `FQS_CustomMetadataSaver_Test` | §6 |
| class | `FQS_MatchServices_Test` | §6 |
| permset | `FQS_Campaign_Fields` | §7 (permsets are user-assigned in-org — expected) |
| permset | `FQS_Custom_Fields` | §7 (permsets are user-assigned in-org — expected) |
| permset | `FQS_Email_Template_Builder_Permission` | §7 (permsets are user-assigned in-org — expected) |
| permset | `FQS_Record_Type_Access` | §7 (permsets are user-assigned in-org — expected) |
| path | `FQS_Campaign_Status` | §10.6 (paths are org-config, not cross-referenced — expected) |
| path | `FQS_GiftCommitment_Status` | §10.6 (paths are org-config, not cross-referenced — expected) |
| path | `FQS_GiftRefund_Status` | §10.6 (paths are org-config, not cross-referenced — expected) |
| path | `FQS_GiftTransaction_Status` | §10.6 (paths are org-config, not cross-referenced — expected) |
