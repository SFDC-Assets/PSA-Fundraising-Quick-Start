# FQS Session Handoff Context

## Project Identity
- **PROJECT_NAME**: Fundraising Quick Start
- **PREFIX**: FQS
- **Org alias**: FundFirst (`justinsgilmore-snmm@force.com.fundfirst`)
- **Project path**: `~/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
- **sourceApiVersion**: 66.0 (already bumped in sfdx-project.json)
- **Skill file**: `~/Desktop/sf-psa-metadata-gen-DRAFT/SKILL.md`

---

## GiftCommitment — Completed This Session

### What deployed successfully
- `FQS_Gift_Commitment_Category__c` — restricted picklist (Pledged Gift, Recurring Gift, Grant Payout)
- `GiftCommitment.object-meta.xml` — searchLayouts patch
- Field patches — descriptions + help text on `FulfillmentType`, `RecurrenceType`, `ScheduleType`, `FormalCommitmentType`, `ExpectedTotalCmtAmount`
- List views: `FQS_Pledged_Gifts`, `FQS_Recurring_Gifts`, `FQS_Grant_Payouts` (all filtered on `FQS_Gift_Commitment_Category__c`)
- `FQS_GiftCommitment_Status` — PathAssistant (Status field, 6 steps)
- Quick actions: `FQS_New_Pledged_Gift`, `FQS_New_Recurring_Gift`, `FQS_New_Grant_Payout`
- `FQS_Custom_Fields` — permission set
- `FQS_GiftCommitment_Record_Page` — FlexiPage

### Segmentation Map
```
Segmentation map for GiftCommitment:
  Discriminator: FQS_Gift_Commitment_Category__c
  Kinds:
    - Pledged Gift   — when FQS_Gift_Commitment_Category__c = "Pledged Gift"
    - Recurring Gift — when FQS_Gift_Commitment_Category__c = "Recurring Gift"
    - Grant Payout   — when FQS_Gift_Commitment_Category__c = "Grant Payout"
  Mechanism: Custom restricted picklist field
```

### Relationship Priority List
```
Priority relationships for GiftCommitment:
  Tab 1: GiftTransactions (GiftTransaction) — top priority
  Tab 2: GiftCommitmentSchedules (GiftCommitmentSchedule) — second
  Tab 3 (grouped): GiftDefaultDesignationParentRecords (GiftDefaultDesignation)
                   GiftDefaultSoftCreditParentRecords (GiftDefaultSoftCredit)
                   GiftTributes (GiftTribute)
  Deprioritized / hidden: PartyPhilanthropicRsrchPrflId (lookup — not used)
  Layout intent: 3 tabs on the Lightning page (Detail tab + 3 custom related list tabs)
```

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `Status`, `FQS_Gift_Commitment_Category__c`, `ExpectedTotalCmtAmount`, `DonorId`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 4 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `detailTab_GiftCommitment` (active/landing) | `detailTabContent` | 7× `flexipage:fieldSection` blocks (see Detail Tab sections below) |
| `fqs_tab_GiftTransactions` | `relatedTabContent` | `force:relatedListSingleContainer` → `GiftTransactions` |
| `fqs_tab_Schedules` | `Facet-fqs-gcschedules` | `force:relatedListSingleContainer` → `GiftCommitmentSchedules` |
| `fqs_tab_GivingDetails` | `Facet-fqs-givingdetails` | 3× `force:relatedListSingleContainer`: `GiftDefaultDesignationParentRecords`, `GiftDefaultSoftCreditParentRecords`, `GiftTributes` |

**Detail Tab sections** (7 `flexipage:fieldSection` blocks, each using left/right column Facets):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Commitment Type | FulfillmentType, RecurrenceType, ScheduleType | FormalCommitmentType, GiftVehicle, GiftVehicleType |
| S2 Dates & Schedule | EffectiveStartDate, ExpectedEndDate, EffectiveTransactionInterval, EffectiveTransactionPeriod | NextTransactionDate (ro), NextTransactionAmount (ro), LastPaidTransactionDate (ro), CampaignId |
| S3 Related Records | OpportunityId, CurrentGiftCmtScheduleId (ro) | OwnerId |
| S4 Giving Totals | TotalPaidTransactionAmount (ro), TotCommitmentScheduleAmt (ro), WrittenOffAmount (ro), TransactionPaymentCount (ro) | TotalCurrentYear (ro), TotalCurrentQuarter (ro), TotalCurrentMonth (ro), TotalNextYear (ro) |
| S5 Asset Transfer | IsAssetTransferExpected, ExpectedAssetTransferDate, TotExpcAssetTransferVal (ro) | ExpectedAssetMaturityDate, TotExpcAssetMaturityVal (ro), TotalAssetPresentValue (ro) |
| S6 Description | Description (single column) | — |
| S7 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Field section Facet naming convention** (use for all FQS objects):
- Left column fields Facet: `Facet-fqs-d-s{N}-left`
- Right column fields Facet: `Facet-fqs-d-s{N}-right`
- Columns wrapper Facet: `Facet-fqs-d-s{N}-cols`
- Section identifier: `fqs_d_fieldSection_s{N}`
- Column identifiers: `fqs_d_col_s{N}_left`, `fqs_d_col_s{N}_right`
- Field identifiers: `fqs_d_fi_{FieldApiName}`

**Sidebar**: `flexipage:accordion` with 5 sections:
- Activity (`runtime_industries_frops:activitiesSection` + `runtime_sales_activities:activityPanel`)
- Upcoming Installments (`runtime_industries_frops:upcomingInstallments`)
- Failed Payments (`runtime_industries_frops:failedPayments`)
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Detail Tab pattern — use `flexipage:fieldSection` (NOT `force:detailPanel` or `force_record_detail:dynamicRecordDetail`)**:
- Each section: declare left-fields Facet, right-fields Facet, columns Facet (two `flexipage:column` items), then `flexipage:fieldSection` referencing the columns Facet
- Single-column section: declare one fields Facet, one `flexipage:column`, columns Facet, `flexipage:fieldSection`
- Field read-only override: add `<valueProvider><type>INPUT_FIELD_WRITE_MODE</type><value>READ</value></valueProvider>` inside the fieldInstance

**Key constraints learned:**
- Parent managed page validates that `relatedTabContent` is consumed — wire it to first custom tab
- `sidebartabs` / `activityTabContent` Facets can be omitted entirely when replacing sidebar with accordion (parent does not enforce them if not declared)
- Every declared Facet region must be referenced as a `body` somewhere or deploy fails
- Sidebar accordion pattern: declare one Facet per section, a Facet of `flexipage:accordionSection` items pointing at those Facets, then `flexipage:accordion` with `accordionSections` pointing at the sections Facet — wired to the `sidebar` Region with `mode:Replace`
- **Standard sidebar accordion sections for every FQS object** (in order): Activity (`runtime_industries_frops:activitiesSection` + `runtime_sales_activities:activityPanel`), Upcoming Installments (`runtime_industries_frops:upcomingInstallments`), Failed Payments (`runtime_industries_frops:failedPayments`), Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`), Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`) — omit Files/FieldHistory only if field history is not enabled on the object

File: `force-app/main/default/flexipages/FQS_GiftCommitment_Record_Page.flexipage-meta.xml`

---

## GiftTransaction — COMPLETE (deployed)

### What deployed successfully
- `FQS_Gift_Transaction_Category__c` — restricted picklist (Outright Gift, Pledge Payment, Recurring Gift Payment, Grant Payment, Other)
- `FQS_Is_Matched__c` — Checkbox
- `FQS_Is_In_Kind__c` — Checkbox
- `FQS_Is_Recurring__c` — Checkbox
- `GiftType.field-meta.xml` — standard field patch (description added: Allowed values: Individual, Organizational)
- `GiftTransaction.object-meta.xml` — searchLayouts patch (no excludeButtons — not supported on NPC objects)
- List views: `FQS_Outright_Gifts`, `FQS_Pledge_Payments`, `FQS_Recurring_Gift_Payments`, `FQS_Grant_Payments`, `FQS_Transaction_Category_Other`
- Quick actions: `FQS_New_Outright_Gift`, `FQS_New_Pledge_Payment`, `FQS_New_Grant_Payment`, `FQS_New_Fee_Payment`
  ⚠ Quick actions appear via the **page layout's Mobile & Lightning Actions** section — not via FlexiPage actionNames (custom quick actions cannot be validated by dynamicHighlights)
- `FQS_GiftTransaction_Status` — PathAssistant (Status field, 7 steps, non-linear: Unpaid, Pending, Paid, Failed, Fully Refunded, Written-Off, Canceled)
- `FQS_Custom_Fields` — permission set updated (4 new FQS GiftTransaction field entries)
- `FQS_GiftTransaction_Record_Page` — FlexiPage (deployed)

### Segmentation Map
```
Segmentation map for GiftTransaction:
  Discriminator: FQS_Gift_Transaction_Category__c
  Kinds:
    - Outright Gift          — standalone gift, no parent GiftCommitment required
    - Pledge Payment         — fulfills a pledge commitment (closed, recurring or custom schedules)
    - Recurring Gift Payment — fulfills a recurring commitment (open-ended)
    - Grant Payment          — fulfills a grant payout commitment
    - Other                  — earned income, event registrations, service fees, or other non-gift transactions
  Mechanism: Custom restricted picklist field
```

### Relationship Priority List
```
Priority relationships for GiftTransaction:
  Tab 1 (relatedTabContent): GiftTransactionDesignationRelation — where the money goes
  Tab 2: GiftSoftCredits (grouped with GiftTributes) — who gets credit + tributes
  Tab 3: GiftRefunds (grouped with MatchingEmployerTransactions) — refunds + employer match
  Conditional: MatchingEmployerTransactions — shown only when FQS_Is_Matched__c = true AND GiftType = Individual (visibilityRule on component)
  Deprioritized: GiftTransactionEntry, ActivityHistories, etc.
  Layout intent: Detail tab (active/landing) + 3 related list tabs
```

### FlexiPage detail tab sections
| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Transaction Type | FQS_Gift_Transaction_Category__c, GiftType, FQS_Is_Recurring__c | PaymentMethod, FQS_Is_In_Kind__c, FQS_Is_Matched__c |
| S2 Dates & Amounts | TransactionDate, TransactionDueDate, OriginalAmount | CurrentAmount (ro), RefundedAmount (ro), TotalTransactionFee (ro) |
| S3 Related Records | DonorId (req), GiftCommitmentId, GiftCommitmentScheduleId | CampaignId, OutreachSourceCodeId, OwnerId (ro) |
| S4 Acknowledgment & Tax | AcknowledgementStatus, AcknowledgementDate, TaxReceiptStatus | TaxDeductionAmount (ro), NonTaxDeductibleAmount |
| S5 Gateway & Payment | PaymentIdentifier, GatewayReference, LastGatewayProcessedDate (ro) | LastGatewayErrorMessage, LastGatewayResponseCode, ProcessorReference |
| S6 Description | Description (single column) | — |
| S7 System Information | CreatedDate (ro), LastModifiedDate (ro) | CreatedById (ro), LastModifiedById (ro) |

### Deploy fixes applied (record for skill learning)
- `excludeButtons` is NOT supported in `searchLayouts` on NPC standard objects — same constraint as `lookupDialogs`/`lookupFilterFields`. Remove from any future NPC object patch.
- Lookup field references in list view `<columns>` must use the relationship label (e.g. `Donor`, `GiftCommitment`) not the field API name (`DonorId`, `GiftCommitmentId`).
- FlexiPage `visibilityRule` structure: use multiple `<criteria>` elements (each with `leftValue`, `operator`, `rightValue`), NOT `<criteria><criteriaItems>` nesting. Operator is `EQUAL` (not `EqualTo` or `==`).
- `flexipage:tab` uses `<name>title</name>` for the tab label — NOT `<name>label</name>`. `label` is only valid on `flexipage:tabset`.
- `record_flexipage:dynamicHighlights` `actionNames` cannot reference custom user-defined quick actions — validation fails even after they deploy. Only standard/managed action names work. Custom quick actions appear via the page layout's Mobile & Lightning Actions section.
- `flexipage__default_rec_L` parent declares `activityTabContent` — do NOT re-declare it in the child page. Reference it as a `body` value (e.g., in a sidebartabs tab). Re-declaring = "Facet activityTabContent has already been declared by another component" error.
- For `flexipage__default_rec_L` sidebar: keep `activityTabContent` + `sidebartabs` pattern from the shell. Add extra tabs (Files, Field History) to `sidebartabs` by replacing that Facet and referencing new custom Facets for each.

---

## Confirmed NPC Org Conventions (use for all subsequent objects)

### FlexiPage
- Namespace: `xmlns="http://soap.sforce.com/2006/04/metadata"`
- Element: `<itemInstances><componentInstance>` (NOT `<componentInstances>`)
- Each `<componentInstance>` needs a unique `<identifier>`
- Template: `<template><name>flexipage:recordHomeTemplateDesktop</name></template>`
- NPC standard objects have a managed `<parentFlexiPage>` — retrieve it by creating a shell page in App Builder first, then retrieve to get the correct `parentFlexiPage` value and required region names
- All sidebar/activity regions from the parent template must be included or deploy fails
- **Always create a shell page in App Builder, retrieve it, then build on top of it** — do not write FlexiPage XML from scratch for NPC standard objects
- **All four FQS flexipages already exist locally** (`FQS_GiftCommitment_Record_Page`, `FQS_GiftTransaction_Record_Page`, `FQS_GiftDesignation_Record_Page`, `FQS_GiftCommitmentSchedule_Record_Page`) — skip the shell/retrieve step entirely for these objects. Edit the local file directly.
- The parent managed page requires `relatedTabContent` to be referenced by at least one tab — wire it to your first custom related tab; additional custom tabs use new named Facets (`Facet-<prefix>-*`)
- `force:relatedListSingleContainer` requires `relatedListApiName` + `parentFieldApiName` (`ObjectType.Id`) — `relatedListName` is invalid and will fail deploy
- Custom Facets declared in `<flexiPageRegions>` must be consumed (referenced as `body`) by a tab or the deploy fails with "Facet X is not used anywhere"
- GiftTransaction FlexiPage Facet prefix: `Facet-fqs-gt-*` / identifier prefix: `fqs_gt_*`
- **`flexipage__default_rec_L` sidebar pattern**: Shell declares `activityTabContent` (owned by parent — do NOT re-declare) and `sidebartabs` (a `flexipage:tab` pointing to `activityTabContent`). To add Files/Field History: declare new Facets for each, then replace `sidebartabs` with expanded tab list (Activity → `activityTabContent`, Files → new Facet, Field History → new Facet). Replace `sidebar` Region with tabset → `sidebartabs` (same as shell).
- **`flexipage:tab` custom label**: use `<name>title</name>` NOT `<name>label</name>`
- **`visibilityRule` on components**: multiple `<criteria>` elements under `<visibilityRule>`, each with `<leftValue>{!Record.Field__c}</leftValue>`, `<operator>EQUAL</operator>`, `<rightValue>value</rightValue>`. For AND: add `<booleanFilter>1 AND 2</booleanFilter>`.
- **`dynamicHighlights` actionNames**: standard/managed names only (e.g. `Edit`, `Delete`, `ChangeOwnerOne`). Custom quick action names fail validation. Surface custom quick actions via page layout Mobile & Lightning Actions instead.
- **App assignment (REQUIRED after FlexiPage deploy)**: `availableForApps` is NOT a valid FlexiPage XML element. App assignment lives in the `CustomApplication` XML as `<actionOverrides>` — two entries per object (Large + Small form factor). After deploying a new FQS FlexiPage, add these blocks to `Fundraising_Quick_Start.app-meta.xml` and redeploy the app:
  ```xml
  <actionOverrides>
      <actionName>View</actionName>
      <comment>Action override created by Lightning App Builder during activation.</comment>
      <content>FQS_[Object]_Record_Page</content>
      <formFactor>Large</formFactor>
      <skipRecordTypeSelect>false</skipRecordTypeSelect>
      <type>Flexipage</type>
      <pageOrSobjectType>[ObjectApiName]</pageOrSobjectType>
  </actionOverrides>
  <actionOverrides>
      <actionName>View</actionName>
      <comment>Action override created by Lightning App Builder during activation.</comment>
      <content>FQS_[Object]_Record_Page</content>
      <formFactor>Small</formFactor>
      <skipRecordTypeSelect>false</skipRecordTypeSelect>
      <type>Flexipage</type>
      <pageOrSobjectType>[ObjectApiName]</pageOrSobjectType>
  </actionOverrides>
  ```
  `<actionOverrides>` blocks go before `<brand>` in the app XML (alphabetical order). Deploy: `sf project deploy start --metadata "CustomApplication:Fundraising_Quick_Start" --target-org FundFirst`.

### PathAssistant
- Requires `<recordTypeName>__MASTER__</recordTypeName>` even with no record types
- `<isDefault>` element is invalid — omit it
- Path Settings must be enabled in Setup before deploying

### Quick Actions
- All quick action files live in `force-app/main/default/quickActions/` — even object-scoped ones
- Object scope is set by `<targetObject>`, not file path
- `Create` type requires `<quickActionLayout>` block — no bare `<layout>` element
- Default to object-scoped (with `<targetObject>`); ask user if global is intended
- After deploy: add to page layout's Mobile & Lightning Actions section to surface on record

### searchLayouts (NPC standard objects)
- Only `<customTabListAdditionalFields>` and `<searchResultsAdditionalFields>` are safe
- `<lookupDialogs>` and `<lookupFilterFields>` cause parse errors on NPC standard objects
- Rollup summary and formula fields cannot be used as columns
- GiftTransaction already had `<lookupDialogsAdditionalFields>` and `<lookupPhoneDialogsAdditionalFields>` in source — these were left as-is (retrieved fields, not FQS additions); only `<excludeButtons>` were added

### List Views
- Use `<columns>Name</columns>` (mixed case) — `NAME` fails on NPC standard objects
- Check existing list views in org before generating an "All" view: `sf data query --query "SELECT DeveloperName FROM ListView WHERE SobjectType = '[Object]'" --target-org FundFirst`
- Filters on new custom fields will show no results until records have data populated
- GiftTransaction already had `All_GiftTransactions` and `My_RecentGiftTransactions` — FQS views add 4 kind-filtered views, no duplicate "All" view needed

### FlexiPage — Confirmed Standard Patterns (use for all FQS objects going forward)

**Related lists on main tabs:** `lst:dynamicRelatedList` with `ADVGRID`, `relatedListLabel`, `relatedListFieldAliases`, `actionNames`, `sortFieldAlias: __DEFAULT__`, `sortFieldOrder: Default`. Confirmed working on GiftDesignation (GiftTransDesignation, GiftDesignationDefaults).
- `relatedListApiName` = relationship name from Object Manager > Relationships (not child object name)
- `relatedListFieldAliases` = field API names on the CHILD object; lookup fields use the relationship label not the field API name (e.g. `GiftTransaction` not `GiftTransactionId`)
- `actionNames: [New]` is the safe default; standard global actions always resolve
- Fallback to `force:relatedListSingleContainer` only when `lst:dynamicRelatedList` fails with `Invalid field alias` or `Invalid related list`

**Sidebar:** `flexipage:accordion` with three labeled `flexipage:accordionSection` items: `Tasks, Emails, and Events` (`runtime_sales_activities:activityPanel`), `Files` (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar: true`), `Field History` (`force:relatedListSingleContainer` → `Histories`, `showActionBar: false`). `defaultSectionName` = `accordionSection1`. Confirmed working on GiftDesignation.
- Each content area = its own Facet; one Facet holds all three `flexipage:accordionSection` items; `flexipage:accordion` references that sections Facet
- Section `name` values must be unique; `accordionSection1/2/3` works when hand-authored (App Builder generates UUIDs)
- Fallback: tabset sidebar using `sidebartabs`/`activityTabContent` pattern (used in early GiftTransaction, before accordion confirmed)

**List view filter conventions (confirmed on GiftDesignation):**
- Boolean filters use `0`/`1` not `True`/`False`
- `includes` operator not supported — use multiple `equals` filter items with `<booleanFilter>1 OR 2 OR 3</booleanFilter>`

### Namespaces
- FlexiPage: `http://soap.sforce.com/2006/04/metadata`
- All other metadata (fields, flows, list views, etc.): `urn:metadata.tooling.soap.sforce.com`
- Standard field patches (e.g. GiftType.field-meta.xml): use `http://soap.sforce.com/2006/04/metadata` (same as retrieved)

---

## GiftDesignation — Complete

### What deployed successfully
- `FQS_Restriction_Type__c` — restricted picklist (Without Donor Restriction, With Donor Restriction - Purpose, With Donor Restriction - Time, With Donor Restriction - Permanent)
- `GiftDesignation.object-meta.xml` — searchLayouts patch (added `FQS_Restriction_Type__c` as first column in customTabListAdditionalFields and searchResultsAdditionalFields)
- List views: `FQS_Active_Designations`, `FQS_Inactive_Designations`, `FQS_Without_Donor_Restriction`, `FQS_With_Donor_Restriction`
- `FQS_Custom_Fields` — permission set updated (1 new GiftDesignation field entry)
- `FQS_GiftDesignation_Record_Page` — FlexiPage

### Segmentation Map
```
Segmentation map for GiftDesignation:
  Discriminator: FQS_Restriction_Type__c
  Kinds:
    - Without Donor Restriction — when FQS_Restriction_Type__c = "Without Donor Restriction"
    - With Donor Restriction (Purpose) — when FQS_Restriction_Type__c = "With Donor Restriction - Purpose"
    - With Donor Restriction (Time) — when FQS_Restriction_Type__c = "With Donor Restriction - Time"
    - With Donor Restriction (Permanent) — when FQS_Restriction_Type__c = "With Donor Restriction - Permanent"
  Mechanism: Custom restricted picklist field
  Note: no kind-specific visibility rules on FlexiPage (all sections apply to all kinds)
```

### Relationship Priority List
```
Priority relationships for GiftDesignation:
  Tab 1 (relatedTabContent): GiftTransDesignation (GiftTransactionDesignation) — transactions assigned to this designation
  Tab 2: GiftDesignationDefaults (GiftDefaultDesignation) — commitment defaults pointing here
  Deprioritized / excluded: GiftEntryDesignation1/2/3 (GiftEntry) — not surfaced per user decision
  Sidebar: AttachedContentDocuments (Files), Histories (Field History)
  Layout intent: Detail tab (active/landing) + 2 related list tabs + sidebartabs sidebar
```

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `FQS_Restriction_Type__c`, `IsActive`, `IsDefault`, `TotalTransactionAmount`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 3 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_gd_tab_detail` (active/landing) | `detailTabContent` | 5× `flexipage:fieldSection` blocks |
| `fqs_gd_tab_Transactions` | `relatedTabContent` | `force:relatedListSingleContainer` → `GiftTransDesignation` |
| `fqs_gd_tab_Defaults` | `Facet-fqs-gd-defaults` | `force:relatedListSingleContainer` → `GiftDesignationDefaults` |

**Detail Tab sections** (5 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Designation Details | FQS_Restriction_Type__c, IsActive, IsDefault | OwnerId |
| S2 Giving Totals | TotalTransactionAmount (ro), TotalTransactionCount (ro), AverageTransactionAmount (ro), HighestTransactionAmount (ro) | LowestTransactionAmount (ro), LastPaidTransactionDate (ro), FirstPaidTransactionDate (ro) |
| S3 Annual Totals | CurrentYearTrxnAmount (ro), LastYearTrxnAmount (ro), LastTwoYearTrxnAmount (ro) | CurrentYearTransactionCount (ro), LastYearTransactionCount (ro), LastTwoYearTrxnCount (ro) |
| S4 Description | Description (single column) | — |
| S5 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: sidebartabs pattern (same as GiftTransaction) — Activity (activityTabContent), Files, Field History

**parentFlexiPage**: `flexipage__default_rec_L` — confirmed same as GiftTransaction (no NPC managed parent exists for GiftDesignation)

**Facet/identifier prefix**: `Facet-fqs-gd-*` / `fqs_gd_*`

File: `force-app/main/default/flexipages/FQS_GiftDesignation_Record_Page.flexipage-meta.xml`

### Deployment order
```
Group 1 — deploy first:
  □ GiftDesignation.FQS_Restriction_Type__c field
  □ GiftDesignation.object-meta.xml (searchLayouts patch)

Group 2 — after Group 1:
  □ List views (4 FQS_* views)

Group 3 — after Group 1:
  □ FQS_Custom_Fields permission set (1 new field entry)
  □ FQS_GiftDesignation_Record_Page FlexiPage
```

### Key Org Findings
- `enableFeeds: false` on GiftDesignation — Histories related list will deploy but may be empty if field tracking not enabled
- No NPC managed parent FlexiPage for GiftDesignation — uses `flexipage__default_rec_L` (same as GiftTransaction)
- Existing org list views `All_GiftDesignations` and `My_RecentGiftDesignations` preserved — FQS adds 4 filtered views
- Boolean list view filters on NPC standard objects require `0`/`1` not `True`/`False` — fixed on deploy
- `includes` operator rejected on GiftDesignation picklist list view filters — fixed by using three `equals` filter items with `<booleanFilter>1 OR 2 OR 3</booleanFilter>`

---

## GiftCommitmentSchedule — Complete

### What deployed successfully
- `GiftCommitmentSchedule.object-meta.xml` — searchLayouts patch (GiftCommitment, TransactionPeriod, TransactionAmount, StartDate, EndDate)
- Field patches with descriptions: `Type`, `TransactionPeriod`, `TransactionDay`, `PaymentMethod`, `CommitmentUpdateReason`, `GiftCommitmentStatus` (GenerationalCohort skipped)
- List views: `FQS_Active_Schedules` (EndDate >= TODAY), `FQS_Completed_Schedules` (EndDate < TODAY)
- `FQS_GiftCommitmentSchedule_Record_Page` — FlexiPage

### Segmentation Map
```
Segmentation map for GiftCommitmentSchedule:
  Discriminator: EndDate (date field)
  Kinds:
    - Active Schedules   — EndDate >= TODAY
    - Completed Schedules — EndDate < TODAY
  Mechanism: List view date filters (no custom field needed)
```

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `GiftCommitmentId`, `Type`, `TransactionPeriod`, `TransactionAmount`, `StartDate`, `EndDate`
- Actions: `Clone`, `ChangeOwnerOne`, `Delete`

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_gcs_tab_detail` (active/landing) | `detailTabContent` | 4× `flexipage:fieldSection` blocks |
| `fqs_gcs_tab_transactions` | `relatedTabContent` | `lst:dynamicRelatedList` → `GiftTransactionsSchedule` |

**Detail Tab sections** (4 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Schedule Definition | Type (req), TransactionPeriod (req), TransactionInterval, TransactionDay | TransactionAmount (req), TotalScheduleAmount (ro), StartDate (req), EndDate |
| S2 Payment | PaymentMethod, PaymentInstrumentId | ProcessorReference, CommitmentUpdateReason |
| S3 Related Records | GiftCommitmentId (req), CampaignId, OutreachSourceCodeId | GiftCommitmentSchdBefEditId (ro) |
| S4 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Transactions tab**: `lst:dynamicRelatedList` — `GiftTransactionsSchedule`, fields: Name, TransactionDate, OriginalAmount, CurrentAmount, Status, PaymentMethod

**Sidebar**: `flexipage:accordion` with 3 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-gcs-*` / `fqs_gcs_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_GiftCommitmentSchedule_Record_Page.flexipage-meta.xml`

### Key Org Findings
- `GiftCommitmentSchedule` is a Master-Detail child of GiftCommitment — **no OwnerId field** (omit from all future Master-Detail child pages)
- Child relationship name for GiftTransaction → GiftCommitmentSchedule is `GiftTransactionsSchedule` (not `GiftTransactions`)
- Master-Detail lookup fields (`GiftCommitmentId`) cannot be used in `searchLayouts` by field API name — use the relationship label (`GiftCommitment`) instead; same rule applies to list view `<columns>`
- Shell page retrieval conflict: deploy FlexiPage with `--ignore-conflicts` when shell was retrieved before overwriting
- `activityTabContent` / `sidebartabs` Facets declared in shell must NOT be re-declared when replacing sidebar with accordion — simply omit them; the accordion `sidebar` Region replace is sufficient
- `Edit` action name fails validation on `record_flexipage:dynamicHighlights` for GiftCommitmentSchedule — use `Clone`, `ChangeOwnerOne`, `Delete`
- `enableFeeds: false` on GiftCommitmentSchedule — Field History list deploys but may show no tracked changes

### Deployment order used
```
Group 1 — deployed together:
  ✓ GiftCommitmentSchedule.object-meta.xml (searchLayouts)
  ✓ Field patches (6 picklist fields with descriptions)
  ✓ List views (FQS_Active_Schedules, FQS_Completed_Schedules)

Group 2 — after Group 1:
  ✓ FQS_GiftCommitmentSchedule_Record_Page FlexiPage (--ignore-conflicts)
```

---

## GiftSoftCredit — Complete

### What deployed successfully
- `GiftSoftCredit.object-meta.xml` — searchLayouts patch (Role, Recipient, GiftTransaction, SoftCreditAmount)
- List views: `FQS_Soft_Credits`, `FQS_Matched_Donor_Credits`, `FQS_Solicitor_Credits`, `FQS_Honoree_Credits` (all filtered on standard `Role` picklist — no custom FQS_ category field needed)
- `FQS_GiftSoftCredit_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — GiftSoftCredit Large + Small actionOverrides added

### Segmentation Map
```
Segmentation map for GiftSoftCredit:
  Discriminator: Role (standard picklist)
  Kinds:
    - Soft Credit        — Role = "Soft Credit" (default)
    - Matched Donor      — Role = "Matched Donor"
    - Solicitor          — Role = "Solicitor"
    - Honoree            — Role = "Honoree"
    - (others: Household Member, Influencer, Third Party Donor, Other — not segmented in FQS views)
  Mechanism: Standard Role picklist — no custom FQS_ field added
```

### Key Org Findings
- GiftSoftCredit has no OwnerId — lookup/detail child of GiftTransaction (REQ); no OwnerId on page or highlights
- `feedEnabled = false` — Field History deploys but may be empty if tracking not enabled
- No child records to surface on related list tabs — `relatedTabContent` wired to Activity tab (`runtime_sales_activities:activityPanel`)
- 2-tab layout: Detail (active, `detailTabContent`) + Activity (`relatedTabContent`)
- Sidebar accordion has only 2 sections: Files + Field History (Activity is on main tab, not repeated in sidebar)
- `Edit` action validated successfully on `record_flexipage:dynamicHighlights` for GiftSoftCredit (unlike GiftCommitmentSchedule where Edit fails — test per object)
- No PathAssistant (no Status field), no quick actions (records created from GiftTransaction related list)
- No `FQS_Custom_Fields` permission set update needed (no custom fields added)

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `Role`, `RecipientId`, `GiftTransactionId`, `SoftCreditAmount`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_gsc_tab_detail` (active/landing) | `detailTabContent` | 3× `flexipage:fieldSection` blocks |
| `fqs_gsc_tab_activity` | `relatedTabContent` | `runtime_sales_activities:activityPanel` |

**Detail Tab sections** (3 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Soft Credit | Role (req), RecipientId | GiftTransactionId (req), SoftCreditAmount (ro) |
| S2 Amount Allocation | PartialAmount, PartialPercent | GenerationalCohort |
| S3 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 2 sections:
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-gsc-*` / `fqs_gsc_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_GiftSoftCredit_Record_Page.flexipage-meta.xml`

### Deployment order used
```
Group 1 — deployed together:
  ✓ GiftSoftCredit.object-meta.xml (searchLayouts)
  ✓ List views (FQS_Soft_Credits, FQS_Matched_Donor_Credits, FQS_Solicitor_Credits, FQS_Honoree_Credits)

Group 2 — after Group 1:
  ✓ FQS_GiftSoftCredit_Record_Page FlexiPage (--ignore-conflicts)
  ✓ Fundraising_Quick_Start CustomApplication (GiftSoftCredit actionOverrides)
```

---

## DonorGiftSummary — Complete

### What deployed successfully
- `FQS_Donor_Grouping__mdt` — Custom Metadata Type (3 fields: `Min_Amount__c` Number(18,2), `Sort_Order__c` Number, `Branded_Name__c` Text)
- CMT records: `Entry` (Friend, $0, sort 10), `Mid` (Partner, $1,000, sort 20), `Major` (Champion, $25,000, sort 30)
- `DonorGiftSummary.FQS_Donor_Level__c` (label: Donor Grouping) — formula Text: returns "Entry"/"Mid"/"Major" from `FQS_Donor_Grouping__mdt` thresholds (drives list view filters)
- `DonorGiftSummary.FQS_Donor_Level_Name__c` (label: Donor Grouping Name) — formula Text: returns branded name from `FQS_Donor_Grouping__mdt.Branded_Name__c` (use in reports/dashboards)
- Note: API names `FQS_Donor_Level__c` / `FQS_Donor_Level_Name__c` retained (cannot rename deployed fields); labels updated to "Donor Grouping" / "Donor Grouping Name"
- `DonorGiftSummary.object-meta.xml` — searchLayouts patch (Donor, TotalGiftsAmount, GiftCount, LastGiftDate, FQS_Donor_Level__c)
- List views: `FQS_Major_Donors` (FQS_Donor_Level__c = Major), `FQS_Recurring_Donors` (TotalPaidRcrInstallments > 0), `FQS_Current_Year_Givers` (GiftsThisYearAmount > 0)
- `FQS_Custom_Fields` — permission set updated (2 new formula fields, editable:false/readable:true)
- `FQS_DonorGiftSummary_Record_Page` — FlexiPage (deployed + activated by user in App Builder)

### Key Org Findings
- `DonorGiftSummary` is Master-Detail child of Account (`DonorId`) — no OwnerId field
- `hasFeed: false` — no Chatter; `Histories` related list deploys but field tracking may not be enabled
- `parentFlexiPage: flexipage__default_rec_L` — same as GiftCommitmentSchedule and GiftDesignation
- CMT Currency type NOT supported on Custom Metadata fields — use Number(18,2) instead; formula comparison against Currency fields works correctly
- Page was activated by user in App Builder — app override already set; no need to patch `Fundraising_Quick_Start.app-meta.xml`
- `fieldInstance` elements in a Facet each require their own `<itemInstances>` wrapper — cannot stack multiple `<fieldInstance>` inside one `<itemInstances>` block

### Segmentation Map
```
Segmentation map for DonorGiftSummary:
  Discriminator: FQS_Donor_Level__c (formula, Text)
  Kinds:
    - Entry  — TotalGiftsAmount < $1,000    → Branded: Friend
    - Mid    — TotalGiftsAmount >= $1,000   → Branded: Partner
    - Major  — TotalGiftsAmount >= $25,000  → Branded: Champion
  Mechanism: CMT-driven formula field; thresholds configurable via Setup > Custom Metadata > FQS Donor Level
```

### FlexiPage — COMPLETE (deployed + activated)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name` (readonly)
- Secondary fields Facet: `DonorId`, `TotalGiftsAmount`, `GiftCount`, `LastGiftDate`, `GivingLevel`
- Actions: `Clone`, `Delete`

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_dgs_tab_detail` (active) | `detailTabContent` | 7× `flexipage:fieldSection` blocks |
| `fqs_dgs_tab_related` | `relatedTabContent` | `force:relatedListContainer` (satisfies parent constraint) |

**Detail Tab sections** (7 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Giving Overview | TotalGiftsAmount (ro), GiftCount (ro), AverageGiftAmount (ro), BookedPledges (ro) | HighestGiftAmount (ro), LowestGiftAmount (ro), GivingLevel, TotalBookableRevenue (ro), FQS_Donor_Level_Name__c (ro) |
| S2 Gift Dates | LastGiftDate (ro), LastGiftAmount (ro), DaysSinceLastGift (ro), SecondGiftDate (ro) | FirstGiftDate (ro), FirstGiftAmount (ro), FirstGiftCampaignId (ro) |
| S3 Yearly Gift Totals | GiftsThisYearAmount (ro), CurrentYearGiftCount (ro), GiftsLastYearAmount (ro), LastYearGiftCount (ro) | GiftsTwoYearsAgoAmount (ro), LastTwoYearGiftCount (ro), BestGiftYear (ro), HighestGiftYearAmount (ro) |
| S4 Hard and Soft Credits | TotalHardSoftCreditsAmount (ro), TotalSoftCreditsAmount (ro), SoftCreditCount (ro), CurrentYearSoftCreditsAmount (ro), CurrentYearSoftCreditCount (ro), FirstSoftCreditAmount (ro), FirstSoftCreditDate (ro) | TotalHardSoftCredits (ro), HighestSoftCreditAmount (ro), HighestSoftCreditDate (ro), LastYearSoftCreditsAmount (ro), LastYearSoftCreditCount (ro), LastSoftCreditAmount (ro), LastSoftCreditDate (ro) |
| S5 Recurring Giving | FirstRecurringStartDate (ro), CurrentRecurringStartDate (ro), LastRecurringPaymentDate (ro) | TotalPaidRcrInstallments (ro), TotalPaidRcrInstlAmt (ro) |
| S6 RFM Scoring | RecencyScore (ro), FrequencyScore (ro), MonetaryScore (ro) | CompositeRfmScore (ro) |
| S7 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 3 sections — Tasks/Emails/Events (`runtime_sales_activities:activityPanel`), Files (`AttachedContentDocuments`), Field History (`Histories`)

**Facet/identifier prefix**: `Facet-fqs-dgs-*` / `fqs_dgs_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_DonorGiftSummary_Record_Page.flexipage-meta.xml`

---

## GiftDefaultSoftCredit — Complete

### What deployed successfully
- `GiftDefaultSoftCredit.object-meta.xml` — searchLayouts patch (Role, Recipient, ParentRecord, PartialPercent)
- List views: `FQS_Matched_Donor_Defaults` (Role = Matched Donor), `FQS_Household_Member_Defaults` (Role = Household Member)
- `FQS_GiftDefaultSoftCredit_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — actionOverrides added (Large + Small, GiftDefaultSoftCredit)

### Object Field Summary
```
Standard fields (all org-provided — no custom fields added):
  Role            — picklist [REQ]: Household Member, Influencer, Solicitor, Matched Donor,
                    Soft Credit, Honoree, Third Party Donor, Other
  RecipientId     — lookup -> Account
  ParentRecordId  — lookup -> GiftCommitment, Opportunity
  PartialPercent  — percent
  PartialAmount   — currency
  OwnerId         — lookup -> Group, User (has OwnerId — NOT Master-Detail)
  Name            — auto [RO]
```

### Key Org Findings
- `RecipientId` and `ParentRecordId` must use relationship labels (`Recipient`, `ParentRecord`) in both searchLayouts and list view `<columns>` — same NPC rule as other lookup fields
- `OwnerId` causes "couldn't retrieve or load the information on the field: Record.OwnerId" FlexiPage validation failure on GiftDefaultSoftCredit — omit from `flexipage:fieldSection` blocks; OwnerId remains accessible via standard detail. Record has OwnerId (not Master-Detail) but the FlexiPage validator rejects it
- No child relationships surfaced in FQS layout (GiftDefaultSoftCredit is a leaf record — no FQS children)
- Files surfaced in the main tab (relatedTabContent → AttachedContentDocuments) rather than sidebar, since the object is leaf-level with no other related tabs needed

### Segmentation Map
```
Segmentation map for GiftDefaultSoftCredit:
  Discriminator: Role (standard picklist)
  Kinds:
    - Matched Donor    — Role = "Matched Donor"
    - Household Member — Role = "Household Member"
  Mechanism: List view Role filters (no custom FQS_ field needed — Role is a native standard field)
```

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `Role`, `RecipientId`, `ParentRecordId`, `PartialPercent`, `PartialAmount`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_gdsc_tab_detail` (active/landing) | `detailTabContent` | 3× `flexipage:fieldSection` blocks |
| `fqs_gdsc_tab_files` | `relatedTabContent` | `force:relatedListSingleContainer` → `AttachedContentDocuments` |

**Detail Tab sections** (3 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Soft Credit Details | Role (req), RecipientId, ParentRecordId | — (single column — OwnerId omitted per FlexiPage constraint) |
| S2 Credit Allocation | PartialPercent | PartialAmount |
| S3 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 2 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-gdsc-*` / `fqs_gdsc_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_GiftDefaultSoftCredit_Record_Page.flexipage-meta.xml`

### Deployment order used
```
Group 1 — deployed together:
  ✓ GiftDefaultSoftCredit.object-meta.xml (searchLayouts)
  ✓ FQS_Matched_Donor_Defaults list view
  ✓ FQS_Household_Member_Defaults list view

Group 2:
  ✓ FQS_GiftDefaultSoftCredit_Record_Page FlexiPage (--ignore-conflicts)

Group 3:
  ✓ Fundraising_Quick_Start CustomApplication (actionOverrides)
```

---

## GiftTransactionDesignation — Complete

### What deployed successfully
- `GiftTransactionDesignation.object-meta.xml` — searchLayouts patch (GiftTransaction, GiftDesignation, Amount, Percent)
- `FQS_GiftTransactionDesignation_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — GiftTransactionDesignation Large + Small actionOverrides added

### Object Field Summary
```
Standard fields (all org-provided — no custom fields added):
  Name              — auto-number [RO]
  GiftTransactionId — Master-Detail(GiftTransaction) [REQ]
  GiftDesignationId — Lookup(GiftDesignation)
  Amount            — currency
  Percent           — percent(15,3)
  OwnerId           — Lookup(User,Group) — has OwnerId but omitted from FlexiPage field sections
  CreatedById       — lookup [RO]
  LastModifiedById  — lookup [RO]
```

### Segmentation Map
```
Segmentation map for GiftTransactionDesignation:
  Discriminator: N/A — junction object only
  Kinds: none — no FQS_ category field added; no list views needed
  Mechanism: N/A
```

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name` (readonly — auto-number)
- Secondary fields Facet: `GiftTransactionId`, `GiftDesignationId`, `Amount`, `Percent`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 2 tabs**:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_gtd_tab_detail` (active/landing) | `detailTabContent` | 2× `flexipage:fieldSection` blocks |
| `fqs_gtd_tab_files` | `relatedTabContent` | `force:relatedListSingleContainer` → `AttachedContentDocuments` |

**Detail Tab sections** (2 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Allocation | GiftTransactionId (req), GiftDesignationId | Amount, Percent |
| S2 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 3 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-gtd-*` / `fqs_gtd_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_GiftTransactionDesignation_Record_Page.flexipage-meta.xml`

### Deployment order used
```
Group 1:
  ✓ GiftTransactionDesignation.object-meta.xml (searchLayouts)

Group 2:
  ✓ FQS_GiftTransactionDesignation_Record_Page FlexiPage (--ignore-conflicts)

Group 3:
  ✓ Fundraising_Quick_Start CustomApplication (actionOverrides)
```

### Key Org Findings
- No custom fields needed — pure junction (GiftTransaction × GiftDesignation) with Amount + Percent as allocation payload
- No list views needed per project decision
- `Edit` action validated successfully on `record_flexipage:dynamicHighlights`
- No PathAssistant, no quick actions (records created from GiftTransaction related list)
- No `FQS_Custom_Fields` permission set update needed (no custom fields added)

---

## GiftTribute — Complete

### What deployed successfully
- `GiftTribute.object-meta.xml` — searchLayouts patch (TributeType, HonoreeName, GiftTransaction, GiftCommitment, NotificationStatus)
- List views: `FQS_Honor_Tributes` (TributeType = Honor), `FQS_Memorial_Tributes` (TributeType = Memorial)
- `FQS_GiftTribute_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — GiftTribute Large + Small actionOverrides added

### Segmentation Map
```
Segmentation map for GiftTribute:
  Discriminator: TributeType (standard picklist)
  Kinds:
    - Honor    — TributeType = "Honor"
    - Memorial — TributeType = "Memorial"
  Mechanism: List view TributeType filters (no custom FQS_ field needed — TributeType is a native standard field)
```

### Object Field Summary
```
Standard fields (all org-provided — no custom fields added):
  TributeType             — picklist: Honor, Memorial
  HonoreeName             — Text(255)
  HonoreeContactId        — lookup -> Account
  HonoreeInformation      — Long Text Area(32000)
  NotificationChannel     — picklist: Mail, Email
  NotificationStatus      — picklist: To Be Sent, Sent, Don't Send
  NotificationContactId   — lookup -> Account
  NotificationContactName — Text(255)
  NotificationEmail       — Email
  NotificationDate        — Date
  NotificationInfo        — Long Text Area(32000)
  NotificationMessage     — Long Text Area(32000)
  GiftCommitmentId        — lookup -> GiftCommitment [REQ by NPC]
  GiftTransactionId       — lookup -> GiftTransaction [REQ by NPC]
  OwnerId                 — lookup -> Group, User (has OwnerId — NOT Master-Detail)
  Name                    — auto [RO]
```

### Key Org Findings
- GiftTribute has `Feeds` / `GiftTributeFeed` child — Chatter feed enabled; Field History tracking may be enabled
- Has OwnerId (not Master-Detail) — `ChangeOwnerOne` valid in highlights actions
- `Edit` action validated on `record_flexipage:dynamicHighlights` (consistent with GiftSoftCredit)
- No child relationships surfaced in FQS layout (GiftTribute is a leaf record)
- 2-tab layout: Detail (active, `detailTabContent`) + Activity (`relatedTabContent`)
- Sidebar accordion has 3 sections: Tasks/Emails/Events, Files, Field History
- Facet/identifier prefix `fqs_gt2_*` used (avoids collision with GiftTransaction's `fqs_gt_*` prefix)

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `TributeType`, `HonoreeName`, `GiftTransactionId`, `GiftCommitmentId`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_gt2_tab_detail` (active/landing) | `detailTabContent` | 3× `flexipage:fieldSection` blocks |
| `fqs_gt2_tab_activity` | `relatedTabContent` | `runtime_sales_activities:activityPanel` |

**Detail Tab sections** (3 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Tribute | TributeType, HonoreeName, HonoreeContactId, HonoreeInformation | GiftTransactionId (req), GiftCommitmentId (req) |
| S2 Notification | NotificationChannel, NotificationStatus, NotificationContactId, NotificationEmail, NotificationDate | NotificationContactName, NotificationInfo, NotificationMessage |
| S3 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 3 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-gt2-*` / `fqs_gt2_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_GiftTribute_Record_Page.flexipage-meta.xml`

### Deployment order used
```
Group 1 — deployed together:
  ✓ GiftTribute.object-meta.xml (searchLayouts)
  ✓ FQS_Honor_Tributes list view
  ✓ FQS_Memorial_Tributes list view

Group 2:
  ✓ FQS_GiftTribute_Record_Page FlexiPage (--ignore-conflicts)

Group 3:
  ✓ Fundraising_Quick_Start CustomApplication (actionOverrides)
```

---

## GiftCmtChangeAttrLog — Complete

### What deployed successfully
- `GiftCmtChangeAttrLog.object-meta.xml` — searchLayouts patch (GiftCommitment, ChangeType, ChangeStatus, EffectiveDate, ChangePerDayAmount)
- List views: `FQS_Upgrades` (ChangeStatus = Upgrade), `FQS_Downgrades` (ChangeStatus = Downgrade), `FQS_Paused_Commitments` (ChangeStatus = Pause)
- `FQS_GiftCmtChangeAttrLog_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — GiftCmtChangeAttrLog Large + Small actionOverrides added
  ⚠ CustomApplication deploy failed on first attempt because `FQS_GiftTransactionDesignation_Record_Page` was referenced in the app XML but didn't exist in org — resolved by deploying that FlexiPage alongside the app in the same batch.

### Segmentation Map
```
Segmentation map for GiftCmtChangeAttrLog:
  Discriminator: ChangeStatus (standard picklist)
  Kinds:
    - Upgrade   — ChangeStatus = "Upgrade"
    - Downgrade — ChangeStatus = "Downgrade"
    - Paused    — ChangeStatus = "Pause"
  Mechanism: List view ChangeStatus filters (no custom FQS_ field needed — audit log, programmatically created by NPC)
```

### Key Org Findings
- `GiftCmtChangeAttrLog` has OwnerId (not Master-Detail) — but ChangeType, ChangeStatus, ChangePerDayAmount, EffectiveDate are set by NPC automation; marked readonly in FlexiPage field sections
- `feedEnabled: false` — Histories related list deploys but field tracking may be empty
- No FQS-specific child relationships — only standard ActivityHistories, AttachedContentDocuments, Histories
- No PathAssistant (ChangeStatus is a logged outcome, not a workflow stage); no quick actions (records created programmatically)

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `GiftCommitmentId`, `ChangeType`, `ChangeStatus`, `EffectiveDate`, `ChangePerDayAmount`
- Actions: `Edit`, `Delete`

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_gcal_tab_detail` (active/landing) | `detailTabContent` | 3× `flexipage:fieldSection` blocks |
| `fqs_gcal_tab_activity` | `relatedTabContent` | `runtime_sales_activities:activityPanel` |

**Detail Tab sections** (3 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Change Details | ChangeType (ro), ChangeStatus (ro), EffectiveDate (ro) | ChangePerDayAmount (ro), CampaignId, OutreachSourceCodeId |
| S2 Related Records | GiftCommitmentId (req) | GiftCommitmentScheduleId |
| S3 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 2 sections:
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-gcal-*` / `fqs_gcal_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_GiftCmtChangeAttrLog_Record_Page.flexipage-meta.xml`

### Deployment order used
```
Group 1 — deployed together:
  ✓ GiftCmtChangeAttrLog.object-meta.xml (searchLayouts)
  ✓ List views (FQS_Upgrades, FQS_Downgrades, FQS_Paused_Commitments)

Group 2:
  ✓ FQS_GiftCmtChangeAttrLog_Record_Page FlexiPage (--ignore-conflicts)

Group 3:
  ✓ FQS_GiftTransactionDesignation_Record_Page FlexiPage (unblocked pre-existing app ref)
  ✓ Fundraising_Quick_Start CustomApplication (GiftCmtChangeAttrLog actionOverrides)
```

---

## GiftRefund — Complete

### What deployed successfully
- `GiftRefund.object-meta.xml` — searchLayouts patch (GiftTransaction, Amount, Status, Date, Reason)
- List views: `FQS_Initiated_Refunds` (Status = Initiated), `FQS_Completed_Refunds` (Status = Completed), `FQS_Failed_Refunds` (Status = Failed, with LastGatewayErrorMessage column)
- `FQS_GiftRefund_Status` — PathAssistant (Status field, 3 steps: Initiated → Completed / Failed)
- `FQS_GiftRefund_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — GiftRefund Large + Small actionOverrides added

### Object Field Summary
```
Standard fields (all org-provided — no custom fields added):
  Name                    — auto [RO]
  GiftTransactionId       — lookup -> GiftTransaction [REQ]
  Amount                  — currency
  Date                    — date
  Status                  — picklist: Initiated, Completed, Failed
  Reason                  — picklist: Donor Request, Incorrect Amount
  GatewayTransactionFee   — currency
  ProcessorTransactionFee — currency
  LastGatewayProcessedDate — datetime [RO]
  LastGatewayErrorMessage  — string
  LastGatewayResponseCode  — string
  CreatedById / LastModifiedById — reference [RO]
  Note: NO OwnerId field (EntityParticle returned 0 rows — confirmed leaf record)
  Note: NO PaymentIdentifier / ProcessorReference on GiftRefund (unlike GiftTransaction)
```

### Segmentation Map
```
Segmentation map for GiftRefund:
  Discriminator: Status (standard picklist)
  Kinds:
    - Initiated — Status = "Initiated"
    - Completed — Status = "Completed"
    - Failed    — Status = "Failed"
  Mechanism: Standard Status picklist — no custom FQS_ field added
```

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name` (readonly — auto-number)
- Secondary fields Facet: `Status`, `GiftTransactionId`, `Amount`, `Date`
- Actions: `Edit`, `Clone`, `Delete`
  ⚠ `ChangeOwnerOne` fails validation on GiftRefund (no OwnerId) — use `Clone` instead

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_gr_tab_detail` (active/landing) | `detailTabContent` | 3× `flexipage:fieldSection` blocks |
| `fqs_gr_tab_activity` | `relatedTabContent` | `runtime_sales_activities:activityPanel` |

**Detail Tab sections** (3 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Refund Details | GiftTransactionId (req), Amount, Date | Status, Reason |
| S2 Gateway & Fees | GatewayTransactionFee, ProcessorTransactionFee | LastGatewayProcessedDate (ro), LastGatewayResponseCode, LastGatewayErrorMessage |
| S3 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 2 sections:
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-gr-*` / `fqs_gr_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_GiftRefund_Record_Page.flexipage-meta.xml`

### Deployment order used
```
Group 1 — deployed together:
  ✓ GiftRefund.object-meta.xml (searchLayouts)
  ✓ List views (FQS_Initiated_Refunds, FQS_Completed_Refunds, FQS_Failed_Refunds)
  ✓ FQS_GiftRefund_Status PathAssistant

Group 2:
  ✓ FQS_GiftRefund_Record_Page FlexiPage (--ignore-conflicts)
  Fix: ChangeOwnerOne → Clone (ChangeOwnerOne invalid on objects without OwnerId)

Group 3:
  ✓ Fundraising_Quick_Start CustomApplication (GiftRefund actionOverrides)
```

### Key Org Findings
- No OwnerId on GiftRefund — `ChangeOwnerOne` fails validation; use `Edit` + `Clone` + `Delete`
- No child relationships to surface on related list tabs (leaf record — child of GiftTransaction)
- `relatedTabContent` wired to Activity panel (`runtime_sales_activities:activityPanel`)
- No custom FQS_ fields needed — standard Status + Reason picklists sufficient
- `Edit` action validated successfully (test per object — fails on some NPC objects)

---

## PaymentInstrument — Complete

### What deployed successfully
- `PaymentInstrument.object-meta.xml` — searchLayouts patch (Type, Account, Last4, CardBrand, GatewayName)
- List views: `FQS_Credit_Card_Instruments` (Type = Credit Card), `FQS_Bank_Debit_Instruments` (Type IN ACH/SEPA/BACS/BECS, multi-equals OR), `FQS_Digital_Wallet_Instruments` (Type IN PayPal/Venmo, multi-equals OR)
- `FQS_PaymentInstrument_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — PaymentInstrument Large + Small actionOverrides added

### Segmentation Map
```
Segmentation map for PaymentInstrument:
  Discriminator: Type (standard picklist)
  Kinds:
    - Credit Card    — Type = "Credit Card"
    - Bank Debit     — Type IN (ACH, SEPA Direct Debit, BACS Debit, BECS Debit)
    - Digital Wallet — Type IN (PayPal, Venmo)
    - (iDEAL, Bancontact exist but not segmented in FQS views)
  Mechanism: Standard Type picklist — no custom FQS_ field added
```

### Object Field Summary
```
Standard fields (all org-provided — no custom fields added):
  Name                    — auto [REQ]
  Type                    — picklist: Credit Card, ACH, SEPA Direct Debit, iDEAL,
                            Bancontact, BACS Debit, BECS Debit, PayPal, Venmo
  AccountId               — lookup -> Account (rel: Account)
  AccountHolderName       — text
  BankAccountHolderType   — text (free-form, no picklist values)
  BankAccountNumber       — text
  BankAccountType         — text (free-form, no picklist values)
  BankCode                — text
  BankName                — text
  CardBrand               — text
  DigitalWalletProvider   — picklist: PayPal, Venmo
  ExpiryMonth             — text
  ExpiryYear              — text
  GatewayName             — text
  GatewayReference        — text
  Last4                   — text
  PaymentProcessorName    — text
  ProcessorReference      — text
  OwnerId                 — lookup -> Group, User [REQ]
  CreatedById             — lookup -> User [REQ] RO
  LastModifiedById        — lookup -> User [REQ] RO
```

### Key Child Relationships (fundraising-relevant)
- `TransactionPaymentInstruments` (GiftTransaction, field: PaymentInstrumentId)
- `SchedulePaymentInstruments` (GiftCommitmentSchedule, field: PaymentInstrumentId)

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `Type`, `AccountId`, `Last4`, `CardBrand`, `GatewayName`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 3 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_pi_tab_detail` (active/landing) | `detailTabContent` | 6× `flexipage:fieldSection` blocks |
| `fqs_pi_tab_transactions` | `relatedTabContent` | `lst:dynamicRelatedList` → `TransactionPaymentInstruments` |
| `fqs_pi_tab_schedules` | `Facet-fqs-pi-schedules` | `lst:dynamicRelatedList` → `SchedulePaymentInstruments` |

**Detail Tab sections** (6 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Instrument Type | Type, CardBrand, Last4 | ExpiryMonth, ExpiryYear |
| S2 Bank Details | BankName, BankAccountType, BankAccountHolderType, BankAccountNumber | BankCode |
| S3 Digital Wallet | DigitalWalletProvider, AccountHolderName | — (single column) |
| S4 Gateway & Processor | GatewayName, GatewayReference, PaymentProcessorName | ProcessorReference |
| S5 Account | AccountId, OwnerId | — (single column) |
| S6 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Transactions tab** (`relatedTabContent`): `lst:dynamicRelatedList` — `TransactionPaymentInstruments`, fields: Name, TransactionDate, OriginalAmount, CurrentAmount, Status, Donor
**Schedules tab**: `lst:dynamicRelatedList` — `SchedulePaymentInstruments`, fields: Name, GiftCommitment, Type, TransactionAmount, StartDate, EndDate

**Sidebar**: `flexipage:accordion` with 3 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-pi-*` / `fqs_pi_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_PaymentInstrument_Record_Page.flexipage-meta.xml`

### Key Org Findings
- `AccountId` must use relationship label `Account` (not `AccountId`) in searchLayouts and list view columns — same NPC rule
- `BankAccountHolderType` and `BankAccountType` are STRING type (free-form, no picklist values)
- Multi-value list view filters use multiple `equals` items with `<booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>`
- `Edit` action validated successfully on `record_flexipage:dynamicHighlights` for PaymentInstrument
- No PathAssistant, no quick actions, no custom FQS_ fields added
- `GiftCommitment` is the relationship label for GiftCommitmentSchedule.GiftCommitmentId in relatedListFieldAliases
- `Donor` is the relationship label for GiftTransaction.DonorId in relatedListFieldAliases

### Deployment order used
```
Group 1 — deployed together:
  ✓ PaymentInstrument.object-meta.xml (searchLayouts)
  ✓ FQS_Credit_Card_Instruments list view
  ✓ FQS_Bank_Debit_Instruments list view
  ✓ FQS_Digital_Wallet_Instruments list view

Group 2:
  ✓ FQS_PaymentInstrument_Record_Page FlexiPage (--ignore-conflicts)
  ✓ Fundraising_Quick_Start CustomApplication (actionOverrides)
```

---

## OutreachSummary — Complete

### What deployed successfully
- `OutreachSummary.object-meta.xml` — searchLayouts patch (Campaign, OutreachSourceCode, TotalGiftTransactionAmount, GiftCount, DonorCount — note: TotalGiftTransactionAmount is in searchLayouts but NOT in list view columns; currency rollup fields are rejected as list view columns)
- List views: `FQS_Active_Outreach` (GiftCount > 0), `FQS_Recurring_Outreach` (RecurringDonorCount > 0), `FQS_No_Response` (GiftCount = 0)
  ⚠ Currency rollup fields (TotalGiftTransactionAmount, TotalRecurringGiftAmount) failed as list view columns — "Could not resolve list view column" error. Replaced with int fields (GiftCount, DonorCount, RecurringDonorCount, ResponseRate). Same rule applies to any future OutreachSummary-like aggregate object.
- `FQS_OutreachSummary_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — OutreachSummary Large + Small actionOverrides added

### Segmentation Map
```
Segmentation map for OutreachSummary:
  Discriminator: N/A — analytics/aggregate object, no category picklist
  Kinds: none — segmentation is by list view filters (active vs. recurring vs. no-response)
  Mechanism: N/A
```

### Object Field Summary
```
Standard fields (all org-provided — no custom fields added):
  Name                           — string [RO] (system-set)
  OwnerId                        — lookup -> Group, User (has OwnerId — NOT Master-Detail)
  CampaignId                     — lookup -> Campaign
  OutreachSourceCodeId           — lookup -> OutreachSourceCode
  TotalGiftTransactionAmount     — currency [editable but NPC-managed aggregate]
  TotalOnetimeGiftAmount         — currency [editable but NPC-managed aggregate]
  TotalRecurringGiftAmount       — currency [editable but NPC-managed aggregate]
  GiftCount                      — int [editable but NPC-managed aggregate]
  DonorCount                     — int [editable but NPC-managed aggregate]
  OnetimeDonorCount              — int [editable but NPC-managed aggregate]
  RecurringDonorCount            — int [editable but NPC-managed aggregate]
  AverageGiftAmount              — currency [REQ] RO (API-confirmed not updateable)
  AverageOnetimeGiftAmount       — currency [REQ] RO
  AverageRecurringGiftAmount     — currency [REQ] RO
  ResponseRate                   — percent
  AttributedAmount               — currency
  CreatedById / LastModifiedById — reference RO
```

### Key Org Findings
- `hasFeed: false` — Histories deploys but field tracking may be empty
- Has OwnerId (not Master-Detail) — `Edit`, `Delete`, `ChangeOwnerOne` valid in highlights
- `Edit` action validated successfully on `record_flexipage:dynamicHighlights`
- Currency aggregate fields (TotalGiftTransactionAmount, TotalOnetimeGiftAmount, TotalRecurringGiftAmount) are NOT usable as list view columns — "Could not resolve list view column" error at deploy time
- No PathAssistant (no Status field), no quick actions (records created by NPC automation)
- No `FQS_Custom_Fields` permission set update needed (no custom fields added)
- No child relationships to surface on related list tabs (leaf record)
- 2-tab layout: Detail (active, `detailTabContent`) + Activity (`relatedTabContent`)

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name` (readonly — system-set)
- Secondary fields Facet: `CampaignId`, `OutreachSourceCodeId`, `TotalGiftTransactionAmount`, `GiftCount`, `DonorCount`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_os_tab_detail` (active/landing) | `detailTabContent` | 4× `flexipage:fieldSection` blocks |
| `fqs_os_tab_activity` | `relatedTabContent` | `runtime_sales_activities:activityPanel` |

**Detail Tab sections** (4 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Outreach Links | CampaignId, OutreachSourceCodeId | OwnerId (ro) |
| S2 Gift Totals | TotalGiftTransactionAmount (ro), TotalOnetimeGiftAmount (ro), TotalRecurringGiftAmount (ro) | GiftCount (ro), DonorCount (ro), OnetimeDonorCount (ro), RecurringDonorCount (ro) |
| S3 Averages & Response | AverageGiftAmount (ro), AverageOnetimeGiftAmount (ro), AverageRecurringGiftAmount (ro) | ResponseRate (ro), AttributedAmount (ro) |
| S4 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 3 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-os-*` / `fqs_os_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_OutreachSummary_Record_Page.flexipage-meta.xml`

### Deployment order used
```
Group 1 — deployed together:
  ✓ OutreachSummary.object-meta.xml (searchLayouts)
  ✓ List views (FQS_Active_Outreach, FQS_Recurring_Outreach, FQS_No_Response)
  Fix: currency aggregate fields → replaced with int/percent fields in list view columns

Group 2:
  ✓ FQS_OutreachSummary_Record_Page FlexiPage (--ignore-conflicts)
  ✓ Fundraising_Quick_Start CustomApplication (OutreachSummary actionOverrides)
```

---

## OutreachSourceCode — Complete

### What deployed successfully
- `OutreachSourceCode.FQS_Channel_Segment__c` — formula Text: "Organic" / "Paid Digital" / "Owned or Acquired Lists" (blank when MessageChannel not set)
- `OutreachSourceCode.MessageChannel.field-meta.xml` — description patch (restricted picklist, 10 values)
- `OutreachSourceCode.UsageType.field-meta.xml` — description patch (restricted picklist, single value: Fundraising)
- `OutreachSourceCode.object-meta.xml` — searchLayouts patch (SourceCode, Status, MessageChannel, Campaign, AudienceCount)
- List views: `FQS_Active_Outreach_Codes` (Status = Active), `FQS_Email_Codes` (MessageChannel = Email), `FQS_Direct_Mail_Codes` (MessageChannel = Direct Mail), `FQS_Digital_Codes` (MessageChannel = Digital Paid OR Social Paid)
- `FQS_Custom_Fields` — permission set updated (FQS_Channel_Segment__c, editable:false/readable:true)
- `FQS_OutreachSourceCode_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — OutreachSourceCode Large + Small actionOverrides added
  ⚠ Opportunity actionOverrides are currently ABSENT from deployed app XML — `FQS_Opportunity_Record_Page` has a pre-existing `ForecastCategory` FlexiPage validation error. Needs separate fix session before Opportunity override is live.

### Segmentation Map
```
Segmentation map for OutreachSourceCode:
  Discriminator 1: FQS_Channel_Segment__c (formula Text)
  Kinds:
    - Organic                 — MessageChannel IN (Organic Web, Physical, Social Organic, Share Partner)
    - Paid Digital            — MessageChannel IN (Digital Paid, Social Paid)
    - Owned or Acquired Lists — MessageChannel IN (Email, Direct Mail, SMS, Telemarketing)
  Discriminator 2: Status (standard picklist, unrestricted)
  Kinds: Active, Inactive, Archived
  Mechanism: Formula field for channel segment; list view Status filter for lifecycle
```

### Object Field Summary
```
Standard fields (all org-provided except FQS_Channel_Segment__c):
  Name                          — string [REQ]
  SourceCode                    — string [REQ] — the tracking code itself
  Status                        — picklist (unrestricted): Active, Inactive, Archived
  UsageType                     — picklist (RESTRICTED): Fundraising
  MessageChannel                — picklist (RESTRICTED): Email, SMS, Direct Mail, Social Organic,
                                   Social Paid, Digital Paid, Organic Web, Physical, Share Partner,
                                   Telemarketing
  CampaignId                    — lookup -> Campaign
  AudienceCount                 — integer
  AudienceInformation           — textarea
  MessageChannelPlatform        — string
  MessageChannelPlatformAccount — string
  MessageContentTitle           — string
  MessageContent                — string
  SentDate                      — datetime
  SourceCodeUrl                 — url (usable in FlexiPage)
  SourceCodeBaseUrl             — url (FlexiPage validator REJECTS — omit from all future flexipages)
  Description                   — textarea
  OwnerId                       — lookup -> Group, User [REQ]
  FQS_Channel_Segment__c        — formula Text (Organic / Paid Digital / Owned or Acquired Lists)
```

### Child Relationships
```
Fundraising-relevant child relationships:
  GiftTransactions      (GiftTransaction, OutreachSourceCodeId)       — FlexiPage surfaceable ✓
  OutreachSourceCodes   (GiftCommitmentSchedule, OutreachSourceCodeId) — FlexiPage validator REJECTS
                                                                          (both lst:dynamicRelatedList
                                                                          and force:relatedListSingleContainer)
  OutreachSummaries     (OutreachSummary, OutreachSourceCodeId)        — FlexiPage validator REJECTS
  GiftEntryOutreachSourceCode (GiftEntry)                              — deprioritized
```

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Primary field Facet: `Record.Name`
- Secondary fields Facet: `SourceCode`, `Status`, `MessageChannel`, `CampaignId`, `AudienceCount`
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 2 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_osc_tab_detail` (active/landing) | `detailTabContent` | 5× `flexipage:fieldSection` blocks |
| `fqs_osc_tab_transactions` | `relatedTabContent` | `lst:dynamicRelatedList` → `GiftTransactions` |

**Detail Tab sections** (5 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Outreach Details | SourceCode (req), Status, UsageType | CampaignId, OwnerId |
| S2 Channel | MessageChannel, MessageChannelPlatform, MessageChannelPlatformAccount | SentDate, SourceCodeUrl |
| S3 Audience & Content | AudienceCount, AudienceInformation | MessageContentTitle, MessageContent |
| S4 Description | Description (single column) | — |
| S5 System Information | CreatedById (ro) | LastModifiedById (ro) |

**Sidebar**: `flexipage:accordion` with 3 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
- Field History (`force:relatedListSingleContainer` → `Histories`, `showActionBar:false`)

**Facet/identifier prefix**: `Facet-fqs-osc-*` / `fqs_osc_*`
**parentFlexiPage**: `flexipage__default_rec_L`

File: `force-app/main/default/flexipages/FQS_OutreachSourceCode_Record_Page.flexipage-meta.xml`

### Key Org Findings
- `OutreachSourceCode` does NOT support PathAssistant — "bad value for restricted picklist field" error at deploy time; omit for this object
- `OutreachSummaries` and `OutreachSourceCodes` child relationships cannot be surfaced via FlexiPage — both `lst:dynamicRelatedList` AND `force:relatedListSingleContainer` fail with "Could not find related list"; only `GiftTransactions` resolves on this entity
- `SourceCodeBaseUrl` URL field is rejected by the FlexiPage field validator — omit from all flexipages
- `detailTabContent` and `relatedTabContent` Facets require `<mode>Replace</mode>` (same rule as all FQS objects — now re-confirmed)
- PermissionSet deploying a new custom field must be split into two groups: fields first, perm set after (linter strips forward references before the field lands)
- Opportunity FlexiPage (`FQS_Opportunity_Record_Page`) has pre-existing `ForecastCategory` validation error — its app XML actionOverrides are absent from deployed app; needs dedicated fix session

### Deployment order used
```
Group 1a — deployed together (fields first):
  ✓ OutreachSourceCode.object-meta.xml (searchLayouts)
  ✓ OutreachSourceCode.FQS_Channel_Segment__c (formula field)
  ✓ OutreachSourceCode.MessageChannel (description patch)
  ✓ OutreachSourceCode.UsageType (description patch)
  ✓ List views (FQS_Active_Outreach_Codes, FQS_Email_Codes, FQS_Direct_Mail_Codes, FQS_Digital_Codes)

Group 1b — after Group 1a:
  ✓ FQS_Custom_Fields permission set (FQS_Channel_Segment__c)

Group 2:
  ✓ FQS_OutreachSourceCode_Record_Page FlexiPage (--ignore-conflicts)

Group 3:
  ✓ Fundraising_Quick_Start CustomApplication (OutreachSourceCode actionOverrides)
  ⚠ Opportunity actionOverrides removed to unblock — restore after ForecastCategory fix
```

---

## Campaign — Complete

### What deployed successfully
- `FQS_Campaign_Category__c` — restricted picklist (8 values: Fundraising Top Level Campaign, Annual Giving, Events, Corporate Match, In-Kind, Major Gifts, Planned Giving, Grants)
- `Campaign.FQS_Fundraising.recordType-meta.xml` — Fundraising record type (active, all 8 category values listed)
- `Campaign.object-meta.xml` — searchLayouts patch (FQS_Campaign_Category__c only — standard fields fail)
- List views (8 FQS_* views): `FQS_All_Fundraising_Campaigns`, `FQS_My_Fundraising_Campaigns`, `FQS_Active_Campaigns`, `FQS_Top_Level_Campaigns`, `FQS_Annual_Giving_Campaigns`, `FQS_Event_Campaigns`, `FQS_Major_Gifts_Campaigns`, `FQS_Grants_Campaigns`
- `FQS_Campaign_Status` — PathAssistant (Status field, recordTypeName: FQS_Fundraising)
- `FQS_Custom_Fields` — permission set updated (FQS_Campaign_Category__c field + Campaign.FQS_Fundraising RT visibility — no `<default>` element)
- `FQS_Campaign_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — Campaign Large + Small actionOverrides added
- 8 global quick actions (`FQS_New_*_Campaign`) — created then deleted (approach abandoned; standard New button is sufficient)

### Segmentation Map
```
Segmentation map for Campaign:
  Discriminator: FQS_Campaign_Category__c (restricted picklist, custom field)
  Kinds:
    - Fundraising Top Level Campaign — parent org-level campaign
    - Annual Giving                  — annual fund campaigns
    - Events                         — event-based fundraising
    - Corporate Match                — employer matching campaigns
    - In-Kind                        — non-cash/goods donations
    - Major Gifts                    — major donor campaigns
    - Planned Giving                 — legacy/bequest campaigns
    - Grants                         — grant-funded campaigns
  Mechanism: Custom restricted picklist field + Fundraising record type
  Note: Campaign is a standard CRM object (not NPC) — purpose outside fundraising remains available via Type field
```

### Key Campaign-Specific Org Findings (CRM standard object — differs from NPC)
- `parentFlexiPage`: `runtime_sales_campaign__Campaign_rec_L_s` — NOT `flexipage__default_rec_L` (managed Campaign template)
- Template: `flexipage:recordHomeWithSubheaderTemplateDesktop` — requires a `subheader` Region (declare empty if unused)
- **`fieldInstance` elements are NOT supported on Campaign FlexiPage** — "You can't add fields to a page of type Record Page" deploy error. Use `force:highlightsPanel` (reads compact layout) + `force:detailPanel` (reads page layout) instead
- **`lst:dynamicRelatedList` on Campaign requires `parentFieldApiName: Campaign.Id`** — missing = "missing required property [parentFieldApiName]" deploy error
- **Campaign list view columns use `CAMPAIGN.*` uppercase prefix** (e.g. `CAMPAIGN.NAME`, `CAMPAIGN.STATUS`, `CAMPAIGN.START_DATE`) — NOT mixed-case API names like NPC objects. Discovery: retrieve existing `AllActiveCampaigns` list view to see the format
- **Campaign `searchLayouts` only accepts custom fields** — standard fields (Status, StartDate, EndDate, IsActive) fail with "field not found"
- **Campaign RecordType in PermissionSet**: no `<default>` element (only `<recordType>` and `<visible>`) — same constraint as all perm set RT blocks
- **PathAssistant for Campaign**: use `<recordTypeName>FQS_Fundraising</recordTypeName>` (not `__MASTER__`) since there is a real record type
- **Campaign list view RecordType.Name filter**: NOT a valid filter field — remove from all list views
- **Global quick actions for Campaign** (type=Create): `<defaultFieldValues>` is NOT supported; `<targetField>` is required for object-scoped Create actions but only available for parent-child relationships. Workaround was global quick actions (no object prefix) — ultimately abandoned, standard New button is sufficient for this use case
- `force:relatedListContainer` used for Sub-Campaigns (ChildCampaigns) and Outreach Source Codes (standard CRM children); `lst:dynamicRelatedList` with `parentFieldApiName: Campaign.Id` for GiftCommitments and GiftTransactions (NPC children)

### FlexiPage — COMPLETE (deployed)

**Header**: `force:highlightsPanel` (reads from Campaign compact layout)

**Detail Tab**: `force:detailPanel` (reads from Campaign page layout)
- ⚠ Field section content is controlled by the Campaign page layout assigned to FQS Fundraising RT — add `FQS_Campaign_Category__c` to that layout

**Main — 5 tabs** in `maintabs`:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_cam_tab_detail` (active/landing) | `detailTabContent` | `force:detailPanel` |
| `fqs_cam_tab_commitments` | `relatedTabContent` | `lst:dynamicRelatedList` → `GiftCommitments` |
| `fqs_cam_tab_transactions` | `Facet-fqs-cam-transactions` | `lst:dynamicRelatedList` → `GiftTransactions` |
| `fqs_cam_tab_subcampaigns` | `Facet-fqs-cam-subcampaigns` | `force:relatedListContainer` → ChildCampaigns |
| `fqs_cam_tab_outreach` | `Facet-fqs-cam-outreach` | `force:relatedListContainer` → OutreachSourceCodes |

**Sidebar**: `flexipage:accordion` with 3 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Files (`force:relatedListContainer`)
- Field History (`force:relatedListContainer`)

**Facet/identifier prefix**: `Facet-fqs-cam-*` / `fqs_cam_*`
**parentFlexiPage**: `runtime_sales_campaign__Campaign_rec_L_s`

File: `force-app/main/default/flexipages/FQS_Campaign_Record_Page.flexipage-meta.xml`

### Post-Deploy Steps (manual)
1. **Activate page in App Builder** — assign `FQS_Campaign_Record_Page` to the FQS Fundraising record type
2. **Campaign page layout** — add `FQS_Campaign_Category__c` to the Campaign page layout assigned to FQS Fundraising RT (detail panel reads from layout)
3. Quick actions: standard New button is sufficient; 8 global quick actions were created and then deleted in this session

### Deployment order used
```
Group 1 — deployed together:
  ✓ Campaign.FQS_Campaign_Category__c field
  ✓ Campaign.object-meta.xml (searchLayouts — custom field only)
  ✓ Campaign.FQS_Fundraising record type
  ✓ List views (8 FQS_* views)

Group 2 — deployed together:
  ✓ FQS_Campaign_Status PathAssistant
  ✓ 8 global quick actions (FQS_New_*_Campaign) — later deleted
  ✓ FQS_Custom_Fields permission set (Category field + RT visibility)

Group 3:
  ✓ FQS_Campaign_Record_Page FlexiPage (--ignore-conflicts)
  Fixes: replaced fieldInstance/dynamicHighlights with force:highlightsPanel + force:detailPanel;
         added parentFieldApiName: Campaign.Id to lst:dynamicRelatedList components

Group 4:
  ✓ Fundraising_Quick_Start CustomApplication (Campaign actionOverrides)

Quick action cleanup:
  ✓ sf project delete source — all 8 FQS_New_*_Campaign quick actions removed from org + local repo
```

---

## Opportunity — Complete

### What deployed successfully
- `StandardValueSet:OpportunityStage` — 10 nonprofit stages added: Identification (Pipeline, 10%), Cultivation (Pipeline, 25%), LOI Submitted (Pipeline, 35%), Proposal Submitted (Pipeline, 55%), Under Review (BestCase, 75%), Awarded (Closed, 100%, won=true), Declined (Omitted, 0%), Solicitation (Pipeline, 50%), Verbal Commitment (BestCase, 85%), Pledged (Closed, 100%, won=true)
- `BusinessProcess:Opportunity.FQS_Opportunity_Process` — embedded in `Opportunity.object-meta.xml` (12 stage values; no `<default>` children — not supported on Opportunity)
- `RecordType:Opportunity.Grant` — stages: Identification (default), Cultivation, LOI Submitted, Proposal Submitted, Under Review, Awarded, Declined
- `RecordType:Opportunity.Major_Gift` — stages: Identification (default), Cultivation, Solicitation, Verbal Commitment, Pledged, Closed Won, Closed Lost
- `CustomField:Opportunity.FQS_Grant_Deadline__c` — Date, "Application and/or Report Deadline"
- `CustomField:Opportunity.FQS_Grant_Report_Due__c` — Date, "Post-Award Grant Report Due"
- `CustomField:Opportunity.FQS_Solicitation_Date__c` — Date, "Formal Ask Date"
- List views (4): `FQS_Grants` (stage not equal to Closed Won/Closed Lost/Pledged/Awarded), `FQS_Major_Gifts` (stage not equal to LOI Submitted/Proposal Submitted/Under Review/Awarded/Declined), `FQS_Awarded_Grants` (stage = Awarded), `FQS_Pledged_Major_Gifts` (stage = Pledged)
- `QuickAction:FQS_New_Grant` — Create, targetObject: Opportunity, 2-column layout (Name/AccountId/Amount/Deadline | Stage/CloseDate/CampaignId/Description)
- `QuickAction:FQS_New_Major_Gift` — Create, targetObject: Opportunity, 2-column layout (Name/AccountId/Amount/SolicitationDate | Stage/CloseDate/CampaignId/Description)
- `FQS_Custom_Fields` — permission set updated (3 new Opportunity field entries)
- `FQS_Opportunity_Record_Page` — FlexiPage (deployed)
- `Fundraising_Quick_Start.app-meta.xml` — Opportunity Large + Small actionOverrides added (deployed)

### Segmentation Map
```
Segmentation map for Opportunity:
  Discriminator: RecordType (Grant / Major_Gift)
  Kinds:
    - Grant      — Grant record type, stage values: Identification, Cultivation, LOI Submitted,
                   Proposal Submitted, Under Review, Awarded, Declined
    - Major Gift — Major_Gift record type, stage values: Identification, Cultivation, Solicitation,
                   Verbal Commitment, Pledged, Closed Won, Closed Lost
  Mechanism: Standard Salesforce Record Types + OpportunityStage StandardValueSet + BusinessProcess
  Note: Opportunity is a standard CRM object, not NPC — no parentFlexiPage (sobjectType required instead)
```

### Object Field Summary
```
Standard + custom fields on FlexiPage:
  Name                    — string [REQ]
  AccountId               — lookup -> Account [REQ]
  StageName               — picklist [REQ]
  CloseDate               — date [REQ]
  Amount                  — currency
  CampaignId              — lookup -> Campaign
  OwnerId                 — lookup -> User/Group
  ExpectedRevenue         — currency
  Probability             — percent
  NextStep                — string
  LeadSource              — picklist
  Description             — textarea
  FQS_Grant_Deadline__c   — date (Grant only)
  FQS_Grant_Report_Due__c — date (Grant only)
  FQS_Solicitation_Date__c — date (Major Gift only)
  CreatedById / LastModifiedById — reference [RO]

Fields NOT available in this org (removed during deploy):
  RecordTypeId          — not displayable as a FlexiPage field
  LastStageChangeDate   — Sales Cloud only
  ForecastCategory      — Sales Cloud only
```

### Relationship Priority List
```
Priority relationships for Opportunity:
  Tab 2: GiftCommitments (GiftCommitment) — opportunities linked to gift commitments
  Tab 3 (Giving Details):
    OpportunityContactRoles — contact roles on the opportunity (force:relatedListSingleContainer)
    GiftDefaultDesignationParentRecords (GiftDefaultDesignation) — designation defaults
    GiftDefaultSoftCreditParentRecords (GiftDefaultSoftCredit) — soft credit defaults
  Sidebar: Tasks/Emails/Events (activityPanel), Files (AttachedContentDocuments)
  No Field History accordion section (Opportunity Histories not enabled in this org)
```

### FlexiPage — COMPLETE (deployed)

**Header**: `record_flexipage:dynamicHighlights` with:
- Actions: `Edit`, `Delete`, `ChangeOwnerOne`

**Main — 3 tabs**:

| Tab identifier | body Facet | Contents |
|---|---|---|
| `fqs_opp_tab_detail` (active/landing) | `detailTabContent` | 6× `flexipage:fieldSection` blocks |
| `fqs_opp_tab_commitments` | `relatedTabContent` | `lst:dynamicRelatedList` → `GiftCommitments` |
| `fqs_opp_tab_givingDetails` | `Facet-fqs-opp-givingDetails` | `force:relatedListSingleContainer` × 3 |

**Detail Tab sections** (6 `flexipage:fieldSection` blocks):

| Section | Left column fields | Right column fields |
|---|---|---|
| S1 Opportunity Information | Name, AccountId, Amount | StageName (req), CloseDate (req), CampaignId, OwnerId |
| S2 Grant Details | FQS_Grant_Deadline__c, FQS_Grant_Report_Due__c | ExpectedRevenue, Type |
| S3 Major Gift Details | FQS_Solicitation_Date__c, LeadSource | ExpectedRevenue, Type |
| S4 Dates & Pipeline | CloseDate, NextStep | Probability |
| S5 Description | Description (single column) | — |
| S6 System Information | CreatedById (ro) | LastModifiedById (ro) |

Note: S2 and S3 both always show (RecordType visibility rules are not deployable on standard Opportunity FlexiPage — `{!Record.RecordType.DeveloperName}` path syntax rejected by validator).

**GiftCommitments tab** (`relatedTabContent`): `lst:dynamicRelatedList`, fields: Name, Status, FulfillmentType, ExpectedTotalCmtAmount, EffectiveStartDate (DonorId removed — not a valid column when viewed from Opportunity)

**Giving Details tab**:
- `force:relatedListSingleContainer` → `OpportunityContactRoles` (switched from lst:dynamicRelatedList — not Dynamic Related List Enabled)
- `force:relatedListSingleContainer` → `GiftDefaultDesignationParentRecords`
- `force:relatedListSingleContainer` → `GiftDefaultSoftCreditParentRecords`

**Sidebar**: `flexipage:accordion` with 2 sections:
- Tasks, Emails, and Events (`runtime_sales_activities:activityPanel`)
- Files (`force:relatedListSingleContainer` → `AttachedContentDocuments`, `showActionBar:true`)
(Field History omitted — `Histories` related list not available on Opportunity in this org)

**Facet/identifier prefix**: `Facet-fqs-opp-*` / `fqs_opp_*`
**sobjectType**: `Opportunity` (NO parentFlexiPage — standard CRM object)

File: `force-app/main/default/flexipages/FQS_Opportunity_Record_Page.flexipage-meta.xml`

### Key Opportunity-Specific Org Findings

- **Standard Opportunity FlexiPage has no parentFlexiPage** — requires `<sobjectType>Opportunity</sobjectType>`, no `<parentFlexiPage>`, and no `<mode>` elements on any Region (mode is only valid when a parent exists). This differs from NPC objects and Campaign.
- **BusinessProcess on Opportunity**: `<businessProcesses>` block embedded in `Opportunity.object-meta.xml` must NOT have `<default>` child elements inside `<values>` — "Cannot specify a default on: Opportunity" deploy error. Also exists as standalone `businessProcesses/FQS_Opportunity_Process.businessProcess-meta.xml` — include `--metadata "BusinessProcess:Opportunity.FQS_Opportunity_Process"` explicitly in any deploy that triggers Opportunity components.
- **RecordType list view filters not deployable** — `RecordTypeId` rejected as a list view filter field via Metadata API for Opportunity. Stage-based filters achieve equivalent segmentation (Grant stages and Major Gift stages are mutually exclusive).
- **`{!Record.RecordType.DeveloperName}` rejected** in FlexiPage visibility rules — "Field RecordType does not exist" deploy error. The relationship traversal path is not supported by the FlexiPage validator on standard objects. Remove visibility rules entirely; rely on record-type-specific stage values to distinguish context.
- **`RecordTypeId` not displayable as a FlexiPage fieldInstance** — "couldn't retrieve or load the information on the field: Record.RecordTypeId" deploy error. Cannot surface the record type label as a field on the page.
- **`LastStageChangeDate` and `ForecastCategory` not available** in this org — Sales Cloud / high-edition fields. Remove from any Opportunity FlexiPage before deploy.
- **`OpportunityContactRoles` is NOT Dynamic Related List Enabled** — `lst:dynamicRelatedList` fails with "Related list [OpportunityContactRoles] is not Dynamic Related List Enabled". Must use `force:relatedListSingleContainer` instead.
- **`DonorId` not a valid column in `GiftCommitments` related list** when viewed from Opportunity — remove from `relatedListFieldAliases`.
- **QuickAction `<targetRecordType>` causes deploy failure** — "no RecordType named Grant found" even when Grant RT exists. Omit `<targetRecordType>` from all Opportunity quick actions.
- **Quick action file structure**: object-scoped Create quick actions use `<quickActionLayout>` with `<quickActionLayoutColumns>` (NOT bare `<layout>` or `<actionLayout>` elements). File lives in `force-app/main/default/quickActions/` (not in objects/ subdirectory).
- **BusinessProcess deploy dependency chain**: StandardValueSet → fields + record types + business process → list views → quick actions → FlexiPage → app. Deploying list views without the StandardValueSet causes "Picklist value: X not found" errors.
- **Pre-existing FQS FlexiPage bugs fixed this session** (blocking app deploy):
  - `FQS_Campaign_Record_Page`: `hideSlackAction` is invalid on `force:highlightsPanel`; `FQS_Gift_Transaction_Category__c` column removed from `GiftTransactions` related list (field not yet deployed)
  - `FQS_GiftTransaction_Record_Page`: `MatchingEmployerTransactions` related list not available; removed component
  - `FQS_GiftDesignation_Record_Page`: `FQS_Restriction_Type__c` field not in org — deployed separately
  - `FQS_GiftDefaultDesignation_Record_Page`: `FQS_Parent_Type__c` field not in org — deployed separately
  - `DonorGiftSummary.FQS_Donor_Level__c` / `FQS_Donor_Level_Name__c`: depended on `FQS_Donor_Grouping__mdt` CMT records not yet deployed — deployed `Entry`, `Mid`, `Major` records first
  - Several other FQS custom fields across GiftTransaction, GiftCommitment, OutreachSourceCode not yet deployed — deployed all in this session before deploying the app

### Deployment order used
```
Group 1a — StandardValueSet (required first):
  ✓ StandardValueSet:OpportunityStage (10 nonprofit stages added)

Group 1b — object bundle (after StandardValueSet):
  ✓ CustomField:Opportunity.FQS_Grant_Deadline__c
  ✓ CustomField:Opportunity.FQS_Grant_Report_Due__c
  ✓ CustomField:Opportunity.FQS_Solicitation_Date__c
  ✓ RecordType:Opportunity.Grant
  ✓ RecordType:Opportunity.Major_Gift
  ✓ BusinessProcess:Opportunity.FQS_Opportunity_Process

Group 2 — list views + quick actions + perm set:
  ✓ ListView:Opportunity.FQS_Grants
  ✓ ListView:Opportunity.FQS_Major_Gifts
  ✓ ListView:Opportunity.FQS_Awarded_Grants
  ✓ ListView:Opportunity.FQS_Pledged_Major_Gifts
  ✓ QuickAction:FQS_New_Grant (corrected layout structure)
  ✓ QuickAction:FQS_New_Major_Gift
  ✓ FQS_Custom_Fields permission set (after deploying all dependent fields + CMT + RT)

Group 3 — FlexiPage + app:
  ✓ FlexiPage:FQS_Opportunity_Record_Page
  ✓ FlexiPage:Fundraising_Quick_Start_UtilityBar
  ✓ All other FQS FlexiPages (pre-existing bugs fixed)
  ✓ CustomApplication:Fundraising_Quick_Start (Opportunity actionOverrides)
```

---

## Seed Data Scripts — Complete

Scripts at `scripts/apex/seed/` — three datasets (10 / 100 / 10,000 donors) with full cascade.
See `scripts/apex/seed/README.md` for full details.

### Key NPC + Salesforce Constraints Learned
- **Account.Description and Campaign.Description are NOT filterable** — use Name-based markers (e.g. `Name LIKE '%FQS #%'`) for teardown queries, not Description.
- **Person Account RT and Opportunity RTs (Grant, Major_Gift) require profile access** — must be granted via Setup → Profiles → Record Type Settings before any seed script that uses them will run.
- **`GiftCommitment.ScheduleType` is auto-managed by NPC** — do NOT set it on insert. Field help text: "Set automatically when a gift commitment schedule is created." Setting `ScheduleType='Custom'` on insert is silently overridden to `Recurring` and then schedule inserts fail with a misleading error: "You can only create a custom schedule when the commitment schedule type is Custom." Omit ScheduleType from all commitment inserts.
- **`GiftTransaction.CurrentAmount` is not writable** — omit from inserts (system-managed).
- **`GiftTransaction.TransactionDueDate` is required** — often overlooked because `TransactionDate` is set; both are required. Default to same value as `TransactionDate` for paid gifts.
- **`OutreachSourceCode.CampaignId` must match `GiftTransaction.CampaignId`** — NPC validation: "Select an Outreach Source Code that's part of this Campaign." Best approach: pick the OSC first, then use its `CampaignId` for the transaction (build an `oscToCampaign` map after loading OSCs).
- **`OutreachSourceCode` with `UsageType='Fundraising'` requires a Campaign** — validation blocks insert without one. Foundation seed script must insert Campaigns first, then round-robin OSCs across them.
- **`GiftDesignation` cannot be deleted while `IsActive=true`** — teardown must deactivate first, then delete in the same transaction.
- **Custom field naming**: `FQS_In_Kind__c`, `FQS_Matched__c`, `FQS_Recurring__c` (NO `Is_` prefix) on GiftTransaction — session notes had them as `FQS_Is_In_Kind__c` etc. which is incorrect.
- **Apex Integer overflow**: multipliers like `2654435761` exceed 32-bit Integer max. Use smaller multipliers (`2654`, `4361`, `1103515245`) with `& 2147483647` masking.
- **Apex Integer has no `.mod()` method** — use `Math.mod(a, b)` (static). `r.mod(10000)` fails; `Math.mod(r, 10000)` works.
- **Anonymous Apex DML limit**: 10,000 rows per transaction. At ~25 rows per donor cascade, max chunk size is ~300 donors. Larger datasets require shell-orchestrated multi-transaction runs.

### Files delivered
```
scripts/apex/seed/
  README.md                      # usage + verified counts
  fqs-seed-teardown.apex         # idempotent cleanup (deactivates GD before delete)
  fqs-seed-foundation.apex       # 12 Campaigns, 10 Designations, 18 OSCs
  fqs-seed-small.apex            # 10 donors, ~120 records
  fqs-seed-medium.apex           # 100 donors, ~975 records
  fqs-seed-chunk.apex            # template for large seeder
  fqs-seed-large.sh              # 34-chunk runner, ~10k donors, ~110k records total
```

### Verified counts (100-donor run, 2026-07-06 in FundFirst)
```
Accounts: 100 (79 Individual / 21 Business)
GiftCommitments: 45
GiftCommitmentSchedules: 45
Opportunities: 7
PaymentInstruments: 100
GiftTransactions: 299 (88% Paid / 7% Pending / 3% Failed / 2% Unpaid)
GiftTransactionDesignations: 299
GiftSoftCredits: 43
GiftTributes: 25
GiftRefunds: 12
TOTAL: 975 records — 2.8s CPU (well under 10s limit)
```

---

## Next Object
Pick up Phase 0 intake for the next object. Begin at §0.2 — project identity is already known (FQS / Fundraising Quick Start). Skip to §0.2.
