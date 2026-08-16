# FQS Guided Gift Entry — Category × Field Crosswalk

Source flow: [FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml)

Purpose: for each leaf of the monolith launcher, enumerate what the user is asked on-screen vs. what the flow assigns pre-DML. Used to drive gift-entry grid template design so the templates match the semantics the guided flow enforces.

## Category → Leaf map

| Category | Leaf | Primary target | Detail screen |
|---|---|---|---|
| Monetary | Outright | GiftTransaction | Details_SinglePayment |
| Monetary | PledgePayment | GiftTransaction (Update or Insert against existing GC/GCS) | Pick_Commitment → SinglePayment |
| Monetary | Recurring | GiftCommitment + open-ended GCS + first GT | Details_Recurring |
| Future | Simple (single-payment Pledge / Grant) | GiftCommitment + 1 GCS (+ optional past-date GT) | Details_Pledge |
| Future | Scheduled (Regular or Custom Pledge / Grant) | GiftCommitment + 1 GCS OR N GCS rows | Details_Scheduled |
| Special | InKind | GiftTransaction + auto GSC self-credit | SinglePayment |
| Special | EarnedIncome | GiftTransaction | SinglePayment |
| Special | EventRegistration | GiftTransaction | SinglePayment |

Cell key: **screen** = user input on that leaf · **default:X** = hardcoded pre-DML Assignment · **formula:F** = formula/merge · **platform** = platform-derived · blank = untouched.

## GiftTransaction — fields by leaf

| Field | Outright | PledgePayment | Recurring (first GT) | Simple past-date GT | Scheduled Custom past-date GT | InKind | EarnedIncome | EventReg |
|---|---|---|---|---|---|---|---|---|
| DonorId | default:`recordId` | default:`recordId` | default:`recordId` | default:`recordId` | default:`recordId` | default:`recordId` | default:`recordId` | default:`recordId` |
| GiftCommitmentId |  | `rsv_GC_Selected.Id` | `rsv_GC.Id` | `rsv_GC.Id` | `rsv_GC.Id` |  |  |  |
| GiftCommitmentScheduleId |  |  |  | `rsv_GCS.Id` | `rsv_GCS_CustomLoopItem.Id` |  |  |  |
| FQS_Gift_Transaction_Category__c | `Outright Gift` | `Pledge Payment` | `Recurring Gift Payment` | formula (`Pledge Payment`/`Grant Payout`) | formula | `Outright Gift` | `Other` | `Other` |
| FQS_In_Kind__c | false | false | false | false | false | **true** | false | false |
| Status | `Paid` | `Paid` | `Paid` | `Unpaid` | `Expected` | `Paid` | `Paid` | `Paid` |
| TaxReceiptStatus | `To Be Sent` | `To Be Sent` | `To Be Sent` | `To Be Sent` | `To Be Sent` | `To Be Sent` | `Don't Send` | `Send` |
| PaymentMethod | screen (default Cash) | screen (from GCS) | screen (required) | screen default | screen default | **`In-Kind`** | screen | screen |
| OriginalAmount | screen | screen (preserved on Update) | screen | screen | `rsv_GCS_CustomLoopItem.TransactionAmount` | **`0`** | screen | screen |
| NonTaxDeductibleAmount |  |  |  |  |  | 0 |  | `SinglePayment_num_EventRegBenefit` |
| FQS_Fair_Market_Value_Amount__c |  |  |  |  |  | screen FMV |  |  |
| TransactionDate | screen (TODAY) | screen | `Recurring_dt_Start` | `Pledge_dt_ExpectedEnd` | `rsv_GCS_CustomLoopItem.StartDate` | screen | screen | screen |
| TransactionDueDate | =`SinglePayment_dt_Gift` | preserved on Update; new-payment = `SinglePayment_dt_Gift` | =`Recurring_dt_Start` | =`Pledge_dt_ExpectedEnd` | =`rsv_GCS_CustomLoopItem.StartDate` | =`SinglePayment_dt_Gift` | =`SinglePayment_dt_Gift` | =`SinglePayment_dt_Gift` |
| FQS_Donor_Tax_Date__c | screen | screen |  |  |  |  | screen | screen |
| FQS_Restriction_Release_Date__c | screen |  |  |  |  |  |  |  |
| Description |  |  |  |  |  | screen (InKind only) |  |  |
| CampaignId | resolver | inherited from GC |  |  |  | resolver (opt) | resolver (opt) | resolver (required) |
| Name | formula | formula | left null (auto-name flow) | left null | formula | formula | formula | formula |
| GiftType | Assign `Individual` / `Organizational` from IsPersonAccount | Assign `Individual` / `Organizational` from IsPersonAccount | platform | formula:`formulaCustomGiftType` | formula:`formulaCustomGiftType` | Assign `Individual` / `Organizational` from IsPersonAccount | Assign `Individual` / `Organizational` from IsPersonAccount | Assign `Individual` / `Organizational` from IsPersonAccount |

## GiftCommitment — fields by leaf (Recurring / Simple / Scheduled)

| Field | Recurring | Simple | Scheduled |
|---|---|---|---|
| DonorId | `recordId` | `recordId` | `recordId` |
| FQS_Gift_Commitment_Category__c | **`Recurring Gift`** (hardcoded) | screen (Pledged Gift / Grant Payout) | screen |
| Status | `Active` | `Active` | `Active` |
| FulfillmentType | `Unconditional` | (unset) | (unset) |
| FormalCommitmentType | **`Verbal`** (hardcoded) | screen | screen |
| RecurrenceType | **`OpenEnded`** | `FixedLength` | `FixedLength` |
| ExpectedTotalCmtAmount | (unset — open-ended) | screen | screen |
| ExpectedEndDate |  | screen | (comes from GCS.EndDate) |
| EffectiveStartDate | screen | screen | screen |
| IsAssetTransferExpected | false | false | false |
| FQS_Match_Eligible__c | formula | formula | formula |
| CampaignId | resolver | resolver | resolver |
| ScheduleType | **intentionally not set** — platform back-fills from GCS | same | same |
| Name | formula | formula | formula |

## GiftCommitmentSchedule — fields by leaf

| Field | Recurring | Simple | Scheduled Regular | Scheduled Custom (per row) |
|---|---|---|---|---|
| GiftCommitmentId | `rsv_GC.Id` | `rsv_GC.Id` | `rsv_GC.Id` | `rsv_GC.Id` |
| Type | `CreateTransactions` | `CreateTransactions` | `CreateTransactions` | `CreateTransactions` |
| TransactionPeriod | screen (Weekly/Monthly/Yearly) | **`Yearly`** | screen | **`Yearly`** |
| TransactionInterval | screen (1–8) | **`1`** | screen | **`1`** |
| TransactionAmount | screen | `Pledge_num_Amount` | formula (Total ÷ Count) | RepeaterItem `field_Custom_Amount` |
| StartDate | `Recurring_dt_Start` | `Pledge_dt_ExpectedEnd` | screen | RepeaterItem `field_Custom_Date` |
| EndDate | null (open-ended) | formula (clamps to TODAY if past) | formula (Start + Period × (N−1)) | formula |
| TransactionDay | formula (`DAY(StartDate)`, `'LastDay'` if 29–31) | formula | formula | formula |
| PaymentMethod | screen | screen | screen | screen |

## Shared post-DML writes

- **GiftTransactionDesignation** — always 100%, GiftDesignationId from resolver output; splits into N rows when parent GC has multiple GDDs.
- **GiftDefaultDesignation** — Parent=GC, 100% allocation, one per resolver designation. GC leaves only.
- **GiftSoftCredit (InKind self-recognition)** — auto-fires on every InKind gift with FMV>0: Recipient=donor, Role=`In-Kind Recognition`, PartialAmount=FMV.
- **GiftSoftCredit (manual)** — only when user picks Yes on the SinglePayment screen (Outright/PledgePayment/EventReg/EarnedIncome). Full=`OriginalAmount`, Partial=`PartialPercent`.
- **GiftDefaultSoftCredit** — Recurring/Simple/Scheduled only when `NeedsSoftCredits=Yes`.

## Category-specific quirks

- **InKind** — only leaf that forces `PaymentMethod='In-Kind'`, `FQS_In_Kind__c=true`, `OriginalAmount=0`, and auto-creates the FMV self-credit. Shows `Description`.
- **EventRegistration** — only leaf that populates `NonTaxDeductibleAmount` (the benefit portion); TaxReceiptStatus=`Send` (immediate).
- **EarnedIncome** — TaxReceiptStatus=`Don't Send`; Category=`Other`.
- **Outright** — only leaf showing `FQS_Restriction_Release_Date__c`.
- **PledgePayment** — Update path stamps `Id=rsv_GT_Selected.Id`, Status=`Paid`; Campaign inherited read-only from parent GC; preserves OriginalAmount even on mismatch.
- **Recurring** — hardcodes `Category=Recurring Gift`, `FormalCommitmentType=Verbal`, `RecurrenceType=OpenEnded`, `FulfillmentType=Unconditional`; no subcategory picker.
- **Simple** — emits a past-date compensating GT (`Status='Unpaid'`) when `ExpectedEnd<TODAY`; clamps GCS EndDate to TODAY.
- **Scheduled Custom** — Repeater produces N Yearly-N=1 GCS rows; past-dated rows get hand-authored `Status='Expected'` GTs (because `processGiftCommitment` only fans out from the current schedule).
- **Confirm_PastPayments** — post-DML datatable that bulk-flips selected Expected GTs to `Paid` — orthogonal to leaf.

## Cross-reference

- [GT Status default = Paid](../../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/gt-status-default-paid.md)
- [GT Status picklist values](../../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/gt-status-picklist-values.md)
- [FQS In-Kind flag load-bearing](../../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/fqs-inkind-flag-load-bearing.md)
- [GT Expected status default](../../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/gt-expected-status-default.md)
- [Monolith preselect + effective-var pattern](../../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/monolith-preselect-effective-var-pattern.md)

---

# Applying the crosswalk to Gift Entry Grid templates

The FQS package ships four `giftEntryGridTemplate` files, each aligned to a GGE leaf. In-Kind is intentionally out of scope. Below: what each template already covers, gaps against the guided flow, and specific column-additions / `defaultValue` proposals.

## Principles

- **No companion trigger flows.** Every default the flow sets should be reproducible from the template itself using `defaultValue` on the column (visible or `isColumnHidden: true`). We already do this for `FQS_Gift_Transaction_Category__c` and `FQS_Match_Status__c` — extend the same pattern to `Status`, `TaxReceiptStatus`, `PaymentMethod`, etc.
- **Picklist defaults ride on the template.** For any picklist field the flow hardcodes (`Status`, `TaxReceiptStatus`, `PaymentMethod` where applicable), add the column with `defaultValue: <value>` and either leave it visible for override or hide it with `isColumnHidden: true` when the value should be locked.
- **One template per leaf shape.** Pledge Payments in particular fans out into multiple templates so each variant has its own defaults.

## What the grid can and can't reach

Columns can default fields on `GiftEntry` that either (a) exist natively (donor, address, payment, GC modal, `Status`, `TaxReceiptStatus`, `PaymentMethod`, `NonTaxDeductibleAmount` where the sObject exposes them) or (b) are FQS custom fields mapped to their target via `FieldMappingConfig`:

| GiftEntry source | Destination | Notes |
|---|---|---|
| `FQS_Gift_Transaction_Category__c` | GT.`FQS_Gift_Transaction_Category__c` | picklist — defaultable |
| `FQS_Donor_Tax_Date__c` | GT.`FQS_Donor_Tax_Date__c` | date |
| `FQS_GT_Restriction_Release_Date__c` | GT.`FQS_Restriction_Release_Date__c` | date |
| `FQS_GC_Restriction_Release_Date__c` | GC.`FQS_Restriction_Release_Date__c` | date, only fires when GC created |
| `FQS_Stewardship_Status__c` / `FQS_Stewardship_Date__c` | GT.* |  |
| `FQS_Tax_Receipt_Date__c` | GT.`FQS_Tax_Receipt_Date__c` |  |
| `FQS_GC_Match_Eligible__c` | GC.`FQS_Match_Eligible__c` | checkbox |
| `FQS_Fair_Market_Value_Amount__c` | GT.`FQS_Fair_Market_Value_Amount__c` | currency |
| `FQS_Match_Status__c` | GT.`FQS_Match_Status__c` | picklist |
| `FQS_GC_Skip_Naming__c` / `FQS_GT_Skip_Naming__c` | GC/GT `FQS_Skip_Naming__c` |  |

`GC.FQS_Gift_Commitment_Category__c` is not currently mapped — see backlog item below.

---

## Template 1 · [FQS_Individual_Outright_Gifts](../force-app/main/default/giftEntryGridTemplates/FQS_Individual_Outright_Gifts.giftEntryGridTemplate) — targets **Outright leaf**

**Present:** Donor, GiftReceivedDate, GiftAmount, PaymentMethod (+ modal), PaymentIdentifier, Designations, Campaign, `FQS_Gift_Transaction_Category__c = Outright Gift`, `FQS_Match_Status__c = N/A`, `FQS_Donor_Tax_Date__c`.

**Gaps vs. flow:**
1. Add **`FQS_GT_Restriction_Release_Date__c`** column — Outright is the only leaf that surfaces this in the flow.
2. Add a **SoftCredits component** column — flow's SinglePayment screen offers Yes/No soft credit.
3. Add **hidden `Status` column, `defaultValue: Paid`** — matches flow's default.
4. Add **hidden `TaxReceiptStatus` column, `defaultValue: To Be Sent`** — matches flow's default.
5. `PaymentMethod` already visible; add `defaultValue: Cash` to match the flow.

**Suggested additions:**
```yaml
 -
  columnId: SoftCredits
  columnType: Component
  columnField:
    sourceField: RecipientId
    isFieldRequired: false
    isFieldHidden: false
  columnComponent:
    componentNameDisplay: runtime_industries_frops/giftEntryGridColumnDisplay
    componentNameEdit: runtime_industries_frops/giftEntryGridLookup
  columnModal:
    modalTitleLabel: $Label.GiftEntryGrid.SoftCreditsModalTitle
    modalComponent:
      componentName: runtime_industries_frops/giftEntryGridSoftCredit
    isModalReadOnly: false
  columnWidth: 240
  columnLabel: $Label.GiftEntryGrid.SoftCreditsLookup
 -
  columnId: FQS_GT_RestrictionReleaseDate
  columnType: Field
  columnField:
    sourceField: FQS_GT_Restriction_Release_Date__c
    isFieldRequired: false
    isFieldHidden: false
  columnWidth: 180
  columnLabel: Restriction Release Date
 -
  columnId: Status
  columnType: Field
  columnField:
    sourceField: Status
    isFieldRequired: false
    isFieldHidden: false
    defaultValue: Paid
  isColumnHidden: true
 -
  columnId: TaxReceiptStatus
  columnType: Field
  columnField:
    sourceField: TaxReceiptStatus
    isFieldRequired: false
    isFieldHidden: false
    defaultValue: To Be Sent
  isColumnHidden: true
```

Update existing `PaymentMethod` column to add `defaultValue: Cash`.

---

## Template 2 · [FQS_Pledge_Payments](../force-app/main/default/giftEntryGridTemplates/FQS_Pledge_Payments.giftEntryGridTemplate) — targets **PledgePayment leaf**

**Present:** Commitments (with GCS modal fields), Donor, GiftReceivedDate, GiftAmount, PaymentMethod, PaymentIdentifier, Campaign, Designations, `FQS_Gift_Transaction_Category__c = Pledge Payment`, `FQS_Match_Status__c = N/A`, `FQS_GT_Restriction_Release_Date__c`.

**Gaps vs. flow:**
1. Add `FQS_Donor_Tax_Date__c` column — flow shows this on all Monetary leaves.
2. Add SoftCredits component column — flow allows soft credit on PledgePayment screen.
3. `FQS_Gift_Transaction_Category__c` should be hidden with `defaultValue: Pledge Payment` — user shouldn't change it row-by-row.
4. Add hidden `Status` column, `defaultValue: Paid`.
5. Add hidden `TaxReceiptStatus` column, `defaultValue: To Be Sent`.
6. Add Campaign `fieldReadOnlyRule` gating on `GiftCommitmentId != null` — flow inherits from GC.

`PaymentMethod` stays as a visible per-row selector (no separate template per payment method) — batches routinely mix cash / check / card / ACH.

**Suggested additions:**
```yaml
 -
  columnId: FQS_DonorTaxDate
  columnType: Field
  columnField:
    sourceField: FQS_Donor_Tax_Date__c
    isFieldRequired: false
    isFieldHidden: false
  columnWidth: 160
  columnLabel: Donor Tax Date
 -
  columnId: SoftCredits
  columnType: Component
  columnField:
    sourceField: RecipientId
    isFieldRequired: false
    isFieldHidden: false
  columnComponent:
    componentNameDisplay: runtime_industries_frops/giftEntryGridColumnDisplay
    componentNameEdit: runtime_industries_frops/giftEntryGridLookup
  columnModal:
    modalTitleLabel: $Label.GiftEntryGrid.SoftCreditsModalTitle
    modalComponent:
      componentName: runtime_industries_frops/giftEntryGridSoftCredit
    isModalReadOnly: false
  columnWidth: 240
  columnLabel: $Label.GiftEntryGrid.SoftCreditsLookup
 -
  columnId: Status
  columnType: Field
  columnField:
    sourceField: Status
    defaultValue: Paid
  isColumnHidden: true
 -
  columnId: TaxReceiptStatus
  columnType: Field
  columnField:
    sourceField: TaxReceiptStatus
    defaultValue: To Be Sent
  isColumnHidden: true
```

Change existing `FQS_Category` column to `isColumnHidden: true` (keep the `defaultValue: Pledge Payment`).

Update existing `Campaign` column with the read-only rule:
```yaml
  columnField:
    sourceField: CampaignId
    ...
    fieldReadOnlyRule:
     -
      field: GiftCommitmentId
      values:
       - null
      operator: NOT_EQUALS
      multipleRulesEvaluationOperator: AND
```

---

## Template 3 · [FQS_Single_Payment_Pledges](../force-app/main/default/giftEntryGridTemplates/FQS_Single_Payment_Pledges.giftEntryGridTemplate) — targets **Simple Future leaf**

**Present:** Donor, GiftReceivedDate, Commitments, GiftAmount, PaymentMethod, OutreachSourceCode, Campaign, Designations, SoftCredits, `FQS_Gift_Transaction_Category__c = Pledge Payment`, `FQS_GC_Match_Eligible__c`, `FQS_Match_Status__c = N/A`, `FQS_GC_Restriction_Release_Date__c`.

**Gaps vs. flow:**
1. Add `FQS_Donor_Tax_Date__c` column.
2. Add `FQS_GT_Restriction_Release_Date__c` column (for the compensating past-date GT).
3. Add hidden `Status` column with `defaultValue: Paid` (past-date compensating GT + `Confirm_PastPayments` marks paid; template rows entered are treated as already-received).
4. Add hidden `TaxReceiptStatus` column with `defaultValue: To Be Sent`.

**Suggested additions:**
```yaml
 -
  columnId: FQS_DonorTaxDate
  columnType: Field
  columnField:
    sourceField: FQS_Donor_Tax_Date__c
    isFieldRequired: false
    isFieldHidden: false
  columnWidth: 160
 -
  columnId: FQS_GT_RestrictionReleaseDate
  columnType: Field
  columnField:
    sourceField: FQS_GT_Restriction_Release_Date__c
    isFieldRequired: false
    isFieldHidden: false
  columnWidth: 180
  columnLabel: Restriction Release Date (Payment)
 -
  columnId: Status
  columnType: Field
  columnField:
    sourceField: Status
    defaultValue: Paid
  isColumnHidden: true
 -
  columnId: TaxReceiptStatus
  columnType: Field
  columnField:
    sourceField: TaxReceiptStatus
    defaultValue: To Be Sent
  isColumnHidden: true
```

---

## Template 4 · [FQS_Event_Registrations](../force-app/main/default/giftEntryGridTemplates/FQS_Event_Registrations.giftEntryGridTemplate) — targets **EventRegistration leaf**

**Present:** Donor, GiftReceivedDate, Commitments (odd fit — remove or hide), GiftAmount, PaymentMethod, OutreachSourceCode, Campaign, Designations, SoftCredits, `FQS_Gift_Transaction_Category__c = Other`, `FQS_Fair_Market_Value_Amount__c`.

**Gaps vs. flow:**
1. Add `NonTaxDeductibleAmount` column (benefit portion of the ticket — flow's headline field for EventReg). If `GiftEntry` exposes it natively in v67 (typically yes), add as a standard column.
2. Change Campaign `isFieldRequired: false` → `true` — flow makes it required.
3. Add hidden `Status` column, `defaultValue: Paid`.
4. Add hidden `TaxReceiptStatus` column, `defaultValue: Send` (immediate for events).
5. Hide the Commitments column (`isColumnHidden: true`) — event registrations don't tie to a GC.
6. Add `FQS_Donor_Tax_Date__c` column.
7. Category defaults to `Other` today, matching the flow. Add a dedicated picklist value `Event Registration` and switch this template's `defaultValue` to it — see backlog.

**Suggested edits:**
```yaml
 -
  columnId: Campaign
  columnField:
    sourceField: CampaignId
    isFieldRequired: true          # was false — make required
 -
  columnId: NonTaxDeductibleAmount
  columnType: Field
  columnField:
    sourceField: NonTaxDeductibleAmount
    isFieldRequired: false
    isFieldHidden: false
  columnWidth: 180
  columnLabel: Non-Deductible (Benefit)
 -
  columnId: FQS_DonorTaxDate
  columnType: Field
  columnField:
    sourceField: FQS_Donor_Tax_Date__c
    isFieldRequired: false
    isFieldHidden: false
  columnWidth: 160
 -
  columnId: Status
  columnType: Field
  columnField:
    sourceField: Status
    defaultValue: Paid
  isColumnHidden: true
 -
  columnId: TaxReceiptStatus
  columnType: Field
  columnField:
    sourceField: TaxReceiptStatus
    defaultValue: Send
  isColumnHidden: true
```

Hide the existing Commitments column: set `isColumnHidden: true` on its definition.

---

## Summary — proposed edits by template

| Template | Add / show columns | Hidden defaults | Change requirement / behavior |
|---|---|---|---|
| Outright Gifts | SoftCredits, `FQS_GT_Restriction_Release_Date__c` | `Status=Paid`, `TaxReceiptStatus=To Be Sent`. PaymentMethod visible with `defaultValue: Cash`. | — |
| Pledge Payments | `FQS_Donor_Tax_Date__c`, SoftCredits | `FQS_Gift_Transaction_Category__c=Pledge Payment` (hide existing column), `Status=Paid`, `TaxReceiptStatus=To Be Sent` | Campaign read-only when GC picked |
| Single Payment Pledges | `FQS_Donor_Tax_Date__c`, `FQS_GT_Restriction_Release_Date__c` | `Status=Paid`, `TaxReceiptStatus=To Be Sent` | — |
| Event Registrations | `NonTaxDeductibleAmount`, `FQS_Donor_Tax_Date__c` | `Status=Paid`, `TaxReceiptStatus=Send`. Hide Commitments column. | Campaign=required |

---

## Backlog

- **Auto-name refactor** — the flow currently sets `Name` via formula on nearly every leaf (`formulaGiftTransactionName_OneTime`, `formulaGiftTransactionName_Recurring`, `formulaScheduledCommitmentName`, `formulaRecurringCommitmentName`, `formulaCustomGTName`, etc.). Replace all of these with a null/placeholder assignment and let `FQS_Auto_Name_Gift_Transaction` / `FQS_Auto_Name_Gift_Commitment` own naming end-to-end. Single source of truth for naming logic, and the same behavior for grid-entered records (which don't run the guided flow's formulas today).
- **Add `FQS_Gift_Commitment_Category__c` to `FieldMappingConfig`** — so future templates can pre-select `Pledged Gift` / `Grant Payout` / `Recurring Gift` from the grid; today the grid cannot influence GC category.
- **Add `Event Registration` and `Earned Income` picklist values** on `FQS_Gift_Transaction_Category__c` — flow currently overloads `Other`, which harms reporting. Add values, migrate the flow's Assignments, then default the Event Registrations template to the specific value.

