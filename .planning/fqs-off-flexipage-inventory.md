# FQS — Off-Flexipage Field Inventory

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst` sandbox (default)
**Companion to:** `.planning/fqs-object-help-text-plan.md` and `.planning/fqs-object-help-text-gc-gcs-gt.md`
**Purpose:** For each in-scope FQS object, list fields that exist on the object but are NOT surfaced on the FQS flexipage(s). Off-flexipage fields generally skip help-text authoring unless a specific reason justifies surfacing them.

---

## Method

Per object:

1. Locate the FQS flexipage(s) in `force-app/main/default/flexipages/` (filenames prefixed `FQS_`).
2. Extract field API names referenced on the flexipage (`<fieldItem><name>Record.<Field></name>`, `<fieldInstance>`, visibility filters).
3. Combine `.field-meta.xml` under `force-app/main/default/objects/<Object>/fields/` (custom + FQS-customized standard) with `sf sobject describe --sobject <Object> --target-org FundFirst` for the full field list.
4. Diff: full list MINUS on-flexipage = off-flexipage.
5. Bucket off-flexipage fields into **audit/platform**, **integration/plumbing**, and **candidate to surface**.

---

## Summary

- **Total objects surveyed:** 22
- **Objects with FQS-owned flexipage(s):** 17
- **Objects on platform default (no FQS flexipage):** 5 — ActionPlan, CampaignMember, GiftEntry, GiftBatch, FundraisingConfig
- **Objects with real gaps (candidates to surface):** 8 — Account, GiftCommitment, GiftTransaction, Campaign (layout-driven), Opportunity, OutreachSourceCode, DonorGiftSummary, GiftTransactionDesignation (plus GiftDefaultDesignation, GiftDefaultSoftCredit — single-field gaps)
- **Objects with essentially no gap:** GiftDesignation, GiftRefund, GiftTribute, GiftCmtChangeAttrLog, GiftCommitmentSchedule, OutreachSummary
- **Objects not present in org / describe failed:** 0 (note: `GiftCommitmentChangeAttributionLog` from the plan resolves to API name `GiftCmtChangeAttrLog` in v67)

**Global caveats:**

- `force:highlightsPanel` (Account, Campaign) and `record_flexipage:dynamicHighlights` (all others) render fields from a compact layout / dynamic highlights config, not from `Record.<field>` refs in flexipage XML. Counts below are a floor — actual surfaced fields are a superset.
- `force:detailPanel` on `FQS_Campaign_Record_Page` renders the entire assigned Campaign **page layout** in the Details tab. Only `FQS_Campaign_Category__c` is a direct XML ref (used for related-list visibility). Everything else on Campaign is layout-driven.
- Compound address fields (`BillingAddress`, `PersonMailingAddress`) cover their Street/City/State/Postal/Country/Latitude/Longitude/GeocodeAccuracy subfields.
- `External_Id__c` appears off-flexipage on every object where it exists — deliberate accelerator convention. Skip help-text for `External_Id__c` unless documenting the external-ID contract in one place.
- `Id` off-flexipage everywhere — treat as audit/platform, not a gap.

---

## Tier: Key

### Account

- **FQS flexipages:** `FQS_Account_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 21 refs (Person Account + Business Account variants; `force:highlightsPanel` compact layout; `flexipage:tab` visibility keyed on `IsPersonAccount`)
- **Off-flexipage — audit/platform (8):** `CreatedDate`, `IsDeleted`, `LastActivityDate`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `MasterRecordId`, `SystemModstamp`
- **Off-flexipage — integration/plumbing:** `AccountSource`, `Jigsaw`, `JigsawCompanyId`, `PersonContactId`, `PersonIndividualId`, `PhotoUrl`, `SicDesc`, `SourceSystemIdentifier`
- **Off-flexipage — compound-covered (via `BillingAddress` / `PersonMailingAddress` refs):** Billing + PersonMailing subfields (Street/City/State/Postal/Country/Latitude/Longitude/GeocodeAccuracy)
- **Off-flexipage — candidates to surface:**
  - `FQS_Matching_Gift_Program__c`, `FQS_Is_Match_Intermediary__c`, `FQS_Match_Ratio__c`, `FQS_Match_Annual_Individual_Maximum__c` — **whole matching-gift capability off-page**
  - `Type`, `ParentId` (household / hierarchy)
  - `ShippingAddress`, `PersonOtherAddress` compounds (Billing + PersonMailing surfaced; other two are not)
  - `Industry`, `AnnualRevenue`, `NumberOfEmployees` (organization-side)
- **Notes:** Confirm compact-layout coverage before treating Name/FirstName/LastName as gaps (highlights strip). `PersonMaritalStatus` is on the flexipage on a variant — ignore false positive.

### GiftCommitment

- **FQS flexipages:** `FQS_GiftCommitment_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 42 refs — highest-density flexipage in the accelerator
- **Off-flexipage — audit/platform (4):** `IsDeleted`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — integration/plumbing:** none
- **Off-flexipage — candidates to surface:**
  - `FQS_Skip_Naming__c` — accelerator-owned naming-skip flag
  - Planned-giving / non-cash: `GiftVehicle`, `GiftVehicleType`, `ExpectedAssetTransferDate`, `ExpectedAssetMaturityDate`, `IsAssetTransferExpected`, `TotalAssetPresentValue`, `TotExpcAssetTransferVal`, `TotExpcAssetMaturityVal` — legitimate deferral if starter is cash-only; flag as "deferred, not missed"
  - `PartyPhilanthropicRsrchPrflId`, `External_Id__c`
- Decision:
  - `External_Id__c`, FQS_Skip_Naming__c, as system fields.

### GiftCommitmentSchedule

- **FQS flexipages:** `FQS_GiftCommitmentSchedule_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 23 refs
- **Off-flexipage — audit/platform (4):** `IsDeleted`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** `GenerationalCohort` only
- **Notes:** `CampaignName` / `GiftCommitmentName` are display-name projections of already-surfaced FK IDs — do not surface.
- Decision: None

### GiftTransaction

- **FQS flexipages:** `FQS_GiftTransaction_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 52 refs
- **Off-flexipage — audit/platform (4):** `IsDeleted`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — integration/plumbing:** `GatewayTransactionFee`, `ProcessorTransactionFee` (component fees; `TotalTransactionFee` is surfaced — omission is by design)
- **Off-flexipage — candidates to surface:**
  - `FQS_In_Kind__c`, `FQS_Recurring__c` — accelerator-owned classifier flags
  - `IsPaid` (admin will want it visible when scanning a transaction)
  - `GenerationalCohort`, `PartyPhilanthropicRsrchPrflId`
- Decision: None

### GiftTransactionDesignation

- **FQS flexipages:** `FQS_GiftTransactionDesignation_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 12 refs
- **Off-flexipage — audit/platform (4):** `IsDeleted`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** `FQS_Restriction_Type__c`
- **Notes:** Mirrors the same field being off the `GiftDefaultDesignation` page.
- Decision: FQS_Restriction_Type__c

### GiftDesignation

- **FQS flexipages:** `FQS_GiftDesignation_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 23 refs
- **Off-flexipage — audit/platform (4):** `IsDeleted`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** none material — `External_Id__c` only
- **Notes:** No gap.

### Campaign

- **FQS flexipages:** `FQS_Campaign_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 1 direct XML ref (`FQS_Campaign_Category__c`, visibility filter only) + full page layout via `force:detailPanel` + compact layout via `force:highlightsPanel`
- **Off-flexipage — audit/platform (11):** `CreatedById`, `CreatedDate`, `IsDeleted`, `LastActivityDate`, `LastModifiedById`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `OwnerId`, `RecordTypeId`, `SystemModstamp`
- **Off-flexipage — candidates (layout-driven, not flexipage-driven):** every business field including `Name`, `Status`, `Type`, `StartDate`, `EndDate`, `IsActive`, `ParentId`, `Description`, `ExpectedRevenue`, `ExpectedResponse`, `BudgetedCost`, `ActualCost`, `NumberSent`, `NumberOf*` rollups, `AmountAllOpportunities`, `AmountWonOpportunities`, `Hierarchy*` rollups, `CampaignMemberRecordTypeId`, **`FQS_Short_Name__c`, `FQS_Child_Campaign_Count__c`, `FQS_Ultimate_Parent_Campaign__c`**, `External_Id__c`
- **Notes:** **Cannot diff cleanly** — Campaign is the only FQS record page using `force:detailPanel`. Whichever Campaign page layout is assigned to the running user's profile decides visibility. Follow-up: (a) audit the shipped Campaign page layout to confirm the three FQS `_c` hierarchy fields are on it, (b) note that `inlineHelpText` / `description` on the field metadata surfaces regardless of flexipage.

### Opportunity

- **FQS flexipages:** `FQS_Opportunity_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 17 refs
- **Off-flexipage — audit/platform (8):** `CreatedDate`, `IsDeleted`, `LastActivityDate`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `RecordTypeId`, `SystemModstamp`
- **Off-flexipage — integration/plumbing:** `Pricebook2Id`, `ContractId` (product/contract linkage — not in FQS starter fundraising model)
- **Off-flexipage — candidates to surface:**
  - `FQS_Skip_Naming__c`
  - `Type` (Grant/Major/etc. distinction for fundraising)
  - `ContactId` (primary contact — worth surfacing for grants/major gifts)
  - Fiscal / stage-change / activity derivatives: `ForecastCategory`, `ForecastCategoryName`, `IsClosed`, `IsWon`, `Fiscal`, `FiscalQuarter`, `FiscalYear`, `HasOpenActivity`, `HasOpportunityLineItem`, `HasOverdueTask`, `LastActivityInDays`, `LastStageChangeDate`, `LastStageChangeInDays`, `AgeInDays` — often intentionally hidden (computed from `StageName`)

---

## Tier: Supporting

### ActionPlan

- **FQS flexipages:** none — platform default
- **Notes:** All business fields technically "candidates" but ActionPlan is Salesforce Industries-managed. Only object-`description` and field-`inlineHelpText` are FQS-authorable levers; there's no flexipage to diff.

### GiftDefaultDesignation

- **FQS flexipages:** `FQS_GiftDefaultDesignation_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 10 refs
- **Off-flexipage — audit/platform (4):** `IsDeleted`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** `FQS_Restriction_Type__c`
- Decsion: Add FQS_Restriction_Type__c

### GiftDefaultSoftCredit

- **FQS flexipages:** `FQS_GiftDefaultSoftCredit_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 8 refs
- **Off-flexipage — audit/platform (7):** `CreatedDate`, `IsDeleted`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `OwnerId`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** `FQS_Parent_Type__c`
- **Notes:** `CreatedById` and `LastModifiedById` ARE on the flexipage — accelerator uses this object as an audit surface.
- Decsion: CreatedById`and`LastModifiedById`

### GiftRefund

- **FQS flexipages:** `FQS_GiftRefund_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 15 refs
- **Off-flexipage — audit/platform (4):** `IsDeleted`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** none material (`External_Id__c` only)
- Decision: Add External_ID__c

### GiftSoftCredit

- **FQS flexipages:** `FQS_GiftSoftCredit_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 11 refs
- **Off-flexipage — audit/platform (4):** `IsDeleted`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — integration/plumbing:** `PartyPhilanthropicRsrchPrflId`
- **Off-flexipage — candidates to surface:** `GenerationalCohort`
- Decision: None

### GiftTribute

- **FQS flexipages:** `FQS_GiftTribute_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 19 refs
- **Off-flexipage — audit/platform (5):** `IsDeleted`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** none material

### OutreachSourceCode

- **FQS flexipages:** `FQS_OutreachSourceCode_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 18 refs
- **Off-flexipage — audit/platform (6):** `CreatedDate`, `IsDeleted`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — integration/plumbing:** `SourceCodeBaseUrl` (URL scaffold; computed `SourceCodeUrl` is surfaced)
- **Off-flexipage — candidates to surface:** `FQS_Message_Channel_Segment__c`, `FQS_Platform__c`
- Decsion: FQS_Message_Channel_Segment__c`, `FQS_Platform__c`, SourceCodeBaseUrl`, LastModifiedDate, CreatedDate

### CampaignMember

- **FQS flexipages:** none — platform default
- **Notes:** Field help-text authoring runs against platform default; object-`description` is the FQS lever.

---

## Tier: Background

### GiftEntry

- **FQS flexipages:** none — platform default
- **Notes:** Edited via the Gift Entry wizard, not directly. **Deferred to `.planning/fqs-gift-entry-help-text-plan.md`** (per object-help-text plan scope).

### GiftBatch

- **FQS flexipages:** none — platform default
- **Notes:** Background-object framing: help text should point admins at the Gift Entry wizard rather than encourage direct edits.

### GiftCmtChangeAttrLog

- **FQS flexipages:** `FQS_GiftCmtChangeAttrLog_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 11 refs
- **Off-flexipage — audit/platform (6):** `CreatedDate`, `IsDeleted`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** none — system-write log; read-only framing applies.
- **Notes:** API name is `GiftCmtChangeAttrLog` in v67 (plan document uses long form `GiftCommitmentChangeAttributionLog`).

### FundraisingConfig

- **FQS flexipages:** none — surfaces via Setup / Custom Metadata UI, not a Lightning record page
- **Notes:** Object-`description` and per-field `inlineHelpText` are the only levers; nothing to diff.

### DonorGiftSummary

- **FQS flexipages:** `FQS_DonorGiftSummary_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 58 refs — widest-surfaced page in the accelerator
- **Off-flexipage — audit/platform (6):** `CreatedDate`, `IsDeleted`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — integration/plumbing:** `FQS_Legacy_First_Gift_Date__c`, `FQS_Legacy_Gift_Count__c`, `FQS_Legacy_Total_Gifts_Amount__c`, `FQS_Legacy_Soft_Credit_Total__c` — legacy-migration snapshot fields; intentional hide post-migration
- **Off-flexipage — candidates to surface:**
  - `LastTwoYearSoftCreditCount` — soft-credit parity to a surfaced gift-side field (`LastTwoYearGiftCount`)
  - Not: `FQS_Annual_Donor_Level__c` / `FQS_Lifetime_Donor_Level__c` raw picklists — the `_Name__c` sibling variants ARE surfaced; hiding raw is deliberate

### OutreachSummary

- **FQS flexipages:** `FQS_OutreachSummary_Record_Page.flexipage-meta.xml`
- **Fields on flexipage(s):** 18 refs
- **Off-flexipage — audit/platform (6):** `CreatedDate`, `IsDeleted`, `LastModifiedDate`, `LastReferencedDate`, `LastViewedDate`, `SystemModstamp`
- **Off-flexipage — candidates to surface:** none — background-object framing applies.

---

## Cross-cutting findings

### 1. Accelerator-owned `FQS_*` fields off their own flexipages (real gaps)

Before authoring help text on these objects, decide per field: **surface on the flexipage, or explicitly justify hiding**.


| Object                     | Field                                    | Notes                                   |
| -------------------------- | ---------------------------------------- | --------------------------------------- |
| Account                    | `FQS_Matching_Gift_Program__c`           | Whole matching-gift capability off-page |
| Account                    | `FQS_Is_Match_Intermediary__c`           | "                                       |
| Account                    | `FQS_Match_Ratio__c`                     | "                                       |
| Account                    | `FQS_Match_Annual_Individual_Maximum__c` | "                                       |
| GiftCommitment             | `FQS_Skip_Naming__c`                     | Naming-skip flag                        |
| GiftTransaction            | `FQS_In_Kind__c`                         | Classifier flag                         |
| GiftTransaction            | `FQS_Recurring__c`                       | Classifier flag                         |
| GiftTransactionDesignation | `FQS_Restriction_Type__c`                | Mirrors GDD gap                         |
| GiftDefaultDesignation     | `FQS_Restriction_Type__c`                | Mirrors GTD gap                         |
| GiftDefaultSoftCredit      | `FQS_Parent_Type__c`                     |                                         |
| Opportunity                | `FQS_Skip_Naming__c`                     | Naming-skip flag                        |
| OutreachSourceCode         | `FQS_Message_Channel_Segment__c`         |                                         |
| OutreachSourceCode         | `FQS_Platform__c`                        |                                         |
| Campaign (layout-driven)   | `FQS_Short_Name__c`                      | Layout audit needed                     |
| Campaign (layout-driven)   | `FQS_Child_Campaign_Count__c`            | "                                       |
| Campaign (layout-driven)   | `FQS_Ultimate_Parent_Campaign__c`        | "                                       |

### 2. Standard-field candidates worth considering

- **Account:** `Type`, `ParentId`, `ShippingAddress` + `PersonOtherAddress` compounds
- **GiftCommitment:** 8 `GiftVehicle*` / `*Asset*` fields (planned-giving) — likely intentional deferral; mark as "deferred, not missed"
- **GiftTransaction:** `IsPaid`
- **Opportunity:** `Type`, `ContactId`
- **DonorGiftSummary:** `LastTwoYearSoftCreditCount`

### 3. Conventions confirmed across the accelerator

- **Object-level help text (`description` on sObject metadata) is safe for all 22 objects** — layout-agnostic, surfaces in Object Manager.
- **Field-level `inlineHelpText` only needs authoring for fields the admin will see** — off-flexipage lists scope that.
- **`External_Id__c` hidden by convention** on every object where it exists — do not surface, do not author help text unless documenting the external-ID contract in one place.
- **Campaign is the only object where the flexipage doesn't drive field visibility** — recommend a separate page-layout audit before authoring Campaign field help text.

---

## Next steps

1. **Reconcile the 16 `FQS_*` gaps in the table above** — for each, either add to the appropriate flexipage or justify hiding in the help-text doc for that object.
2. **Audit the shipped Campaign page layout** to confirm which fields are actually visible (particularly the 3 FQS hierarchy fields).
3. **Fold recovered gaps into `.planning/fqs-object-help-text-plan.md`** so per-object authoring picks up the newly-surfaced fields.
4. **Fan out `sf-help-text-author` to the remaining Key/Supporting/Background objects** using off-flexipage lists to scope the field inventory.
