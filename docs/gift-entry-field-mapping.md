# Gift Entry Field Mapping

`GiftEntry` is the FundFirst **staging object** for Gift Entry (single-launcher, batch, or Guided flows). It denormalizes fields that ultimately land on multiple downstream records — `GiftTransaction`, `GiftCommitment`, `GiftCommitmentSchedule`, `Account`/`PersonAccount`, `PaymentInstrument`, `GiftTransactionDesignation`, `GiftDefaultDesignation`, `GiftSoftCredit`, `GiftDefaultSoftCredit` — so the launcher UI can capture everything on one row before the platform fans it out.

Field parity between `GiftEntry` and its downstream targets is what makes the "commit" step work. When FQS adds a custom field to `GiftTransaction` or `GiftCommitment` and expects the Gift Entry flows to populate it (explicitly on the screen, or defaulted in the background), that custom field needs a **mirror** on `GiftEntry` so the staging row can carry the value.

---

## Standard Default Mappings (Salesforce-provided)

Source: FundFirst Nonprofit Cloud Developer Guide, "Gift Entry Default Mappings" appendix (`docs/nonprofit-cloud-developer-guide-v67.md`).

The table below lists every standard `GiftEntry` field and where it flows on commit.

| Gift Entry Field Label       | Gift Entry API Name          | Gift Entry Data Type   | Target Object              | Target Field                 | Target Data Type            |
| ---------------------------- | ---------------------------- | ---------------------- | -------------------------- | ---------------------------- | --------------------------- |
| Campaign                     | `CampaignId`                 | Lookup(Campaign)       | GiftTransaction            | `CampaignId`                 | Lookup(Campaign)            |
| Campaign                     | `CampaignId`                 | Lookup(Campaign)       | GiftCommitment             | `CampaignId`                 | Lookup(Campaign)            |
| Campaign                     | `CampaignId`                 | Lookup(Campaign)       | GiftCommitmentSchedule     | `CampaignId`                 | Lookup(Campaign)            |
| Check Date                   | `CheckDate`                  | Date                   | GiftTransaction            | `CheckDate`                  | Date                        |
| City                         | `City`                       | Text(40)               | Account                    | `BillingCity`                | Text(40)                    |
| City                         | `City`                       | Text(40)               | PersonAccount              | `PersonMailingCity`          | Text(40)                    |
| Country                      | `Country`                    | Text(80)               | Account                    | `BillingCountry`             | Text(80)                    |
| Country                      | `Country`                    | Text(80)               | PersonAccount              | `PersonMailingCountry`       | Text(80)                    |
| Created By                   | `CreatedById`                | Lookup(User)           | —                          | —                            | —                           |
| Created Date                 | `CreatedDate`                | Date/Time              | —                          | —                            | —                           |
| Donor                        | `DonorId`                    | Lookup(Account)        | Account                    | `DonorId`                    | Lookup(Account)             |
| Donor                        | `DonorId`                    | Lookup(Account)        | GiftCommitment             | `DonorId`                    | Lookup(Account)             |
| Donor                        | `DonorId`                    | Lookup(Account)        | GiftTransaction            | `DonorId`                    | Lookup(Account)             |
| Donor                        | `DonorId`                    | Lookup(Account)        | PaymentInstrument          | `AccountId`                  | Lookup(Account)             |
| Donor Cover Amount           | `DonorCoverAmount`           | Currency(16, 2)        | GiftTransaction            | `DonorCoverAmount`           | Currency(16, 2)             |
| Effective Start Date         | `EffectiveStartDate`         | Date                   | GiftCommitmentSchedule     | `StartDate`                  | Date                        |
| Email                        | `Email`                      | Email                  | PersonAccount              | `PersonEmail`                | Email                       |
| Expected End Date            | `ExpectedEndDate`            | Date                   | GiftCommitmentSchedule     | `EndDate`                    | Date                        |
| Expiry Month                 | `ExpiryMonth`                | Text(25)               | PaymentInstrument          | `ExpiryMonth`                | Text(25)                    |
| Expiry Year                  | `ExpiryYear`                 | Text(4)                | PaymentInstrument          | `ExpiryYear`                 | Text(4)                     |
| First Name                   | `FirstName`                  | Text(40)               | PersonAccount              | `FirstName`                  | Text(40)                    |
| Gift Amount                  | `GiftAmount`                 | Currency(16, 2)        | GiftTransaction            | `OriginalAmount`             | Currency(16, 2)             |
| Gift Amount                  | `GiftAmount`                 | Currency(16, 2)        | GiftCommitmentSchedule     | `TransactionAmount`          | Currency(16, 2)             |
| Gift Batch                   | `GiftBatchId`                | Lookup(Gift Batch)     | —                          | —                            | —                           |
| Gift Commitment              | `GiftCommitmentId`           | Lookup(GiftCommitment) | GiftCommitment             | `Id`                         | ID                          |
| Gift Commitment              | `GiftCommitmentId`           | Lookup(GiftCommitment) | GiftTransaction            | `GiftCommitmentId`           | Lookup(GiftCommitment)      |
| Gift Commitment              | `GiftCommitmentId`           | Lookup(GiftCommitment) | GiftDefaultDesignation     | `ParentRecordId`             | (Polymorphic)               |
| Gift Commitment              | `GiftCommitmentId`           | Lookup(GiftCommitment) | GiftCommitmentSchedule     | `GiftCommitmentId`           | Lookup(GiftCommitment)      |
| Gift Commitment              | `GiftCommitmentId`           | Lookup(GiftCommitment) | GiftDefaultSoftCredit      | `ParentRecordId`             | Lookup(Opportunity, GC)     |
| Gift Designation 1           | `GiftDesignation1Id`         | Lookup(GiftDesignation)| GiftTransactionDesignation | `GiftDesignationId`          | Lookup(GiftDesignation)     |
| Gift Designation 1           | `GiftDesignation1Id`         | Lookup(GiftDesignation)| GiftDefaultDesignation     | `GiftDesignationId`          | Lookup(GiftDesignation)     |
| Gift Designation 1 - Amount  | `GiftDesignation1Amount`     | Currency(16, 2)        | GiftTransactionDesignation | `Amount`                     | Currency(16, 2)             |
| Gift Designation 1 - Percent | `GiftDesignation1Percent`    | Percent(3, 0)          | GiftTransactionDesignation | `Percent`                    | Percent(15, 3)              |
| Gift Designation 1 - Percent | `GiftDesignation1Percent`    | Percent(3, 0)          | GiftDefaultDesignation     | `AllocatedPercentage`        | Percent(3, 0)               |
| Gift Designation 2           | `GiftDesignation2Id`         | Lookup(GiftDesignation)| GiftTransactionDesignation | `GiftDesignationId`          | Lookup(GiftDesignation)     |
| Gift Designation 2           | `GiftDesignation2Id`         | Lookup(GiftDesignation)| GiftDefaultDesignation     | `GiftDesignationId`          | Lookup(GiftDesignation)     |
| Gift Designation 2 - Amount  | `GiftDesignation2Amount`     | Currency(16, 2)        | GiftTransactionDesignation | `Amount`                     | Currency(16, 2)             |
| Gift Designation 2 - Percent | `GiftDesignation2Percent`    | Percent(3, 0)          | GiftTransactionDesignation | `Percent`                    | Percent(15, 3)              |
| Gift Designation 2 - Percent | `GiftDesignation2Percent`    | Percent(3, 0)          | GiftDefaultDesignation     | `AllocatedPercentage`        | Percent(3, 0)               |
| Gift Designation 3           | `GiftDesignation3Id`         | Lookup(GiftDesignation)| GiftTransactionDesignation | `GiftDesignationId`          | Lookup(GiftDesignation)     |
| Gift Designation 3           | `GiftDesignation3Id`         | Lookup(GiftDesignation)| GiftDefaultDesignation     | `GiftDesignationId`          | Lookup(GiftDesignation)     |
| Gift Designation 3 - Amount  | `GiftDesignation3Amount`     | Currency(16, 2)        | GiftTransactionDesignation | `Amount`                     | Currency(16, 2)             |
| Gift Designation 3 - Percent | `GiftDesignation3Percent`    | Percent(3, 0)          | GiftTransactionDesignation | `Percent`                    | Percent(15, 3)              |
| Gift Designation 3 - Percent | `GiftDesignation3Percent`    | Percent(3, 0)          | GiftDefaultDesignation     | `AllocatedPercentage`        | Percent(3, 0)               |
| Gift Designation Information | `GiftDesignationInformation` | Long Text Area(32768)  | GiftTransactionDesignation | `GiftDesignationId`          | Lookup(GiftDesignation)     |
| Gift Designation Information | `GiftDesignationInformation` | Long Text Area(32768)  | GiftDefaultDesignation     | `GiftDesignationId`          | Lookup(GiftDesignation)     |
| Gift Designation Information | `GiftDesignationInformation` | Long Text Area(32768)  | GiftTransactionDesignation | `Amount`                     | Currency(16, 2)             |
| Gift Designation Information | `GiftDesignationInformation` | Long Text Area(32768)  | GiftTransactionDesignation | `Percent`                    | Percent(15, 3)              |
| Gift Designation Information | `GiftDesignationInformation` | Long Text Area(32768)  | GiftDefaultDesignation     | `AllocatedPercentage`        | Percent(3, 0)               |
| Gift Processing Result       | `GiftProcessingResult`       | Text(255)              | —                          | —                            | —                           |
| Gift Processing Status       | `GiftProcessingStatus`       | Picklist               | —                          | —                            | —                           |
| Gift Received Date           | `GiftReceivedDate`           | Date                   | GiftTransaction            | `TransactionDate`            | Date                        |
| Gift Transaction             | `GiftTransactionId`          | Lookup(GiftTransaction)| GiftTransaction            | `Id`                         | ID                          |
| Gift Transaction             | `GiftTransactionId`          | Lookup(GiftTransaction)| GiftTransactionDesignation | `GiftTransactionId`          | Lookup(GiftTransaction)     |
| Gift Transaction             | `GiftTransactionId`          | Lookup(GiftTransaction)| GiftSoftCredit             | `GiftTransactionId`          | Lookup(GiftTransaction)     |
| Gift Type                    | `GiftType`                   | Picklist               | GiftTransaction            | `GiftType`                   | Picklist                    |
| Home Phone                   | `HomePhone`                  | Phone                  | PersonAccount              | `PersonHomePhone`            | Phone                       |
| Last 4                       | `Last4`                      | Text(4)                | PaymentInstrument          | `Last4`                      | Text(4)                     |
| Last Modified By             | `LastModifiedById`           | Lookup(User)           | —                          | —                            | —                           |
| Last Modified Date           | `LastModifiedDate`           | Date/Time              | —                          | —                            | —                           |
| Last Name                    | `LastName`                   | Text(80)               | PersonAccount              | `PersonLastName`             | Text(80)                    |
| Last Processed Date Time     | `LastProcessedDateTime`      | Date/Time              | —                          | —                            | —                           |
| Mobile Phone                 | `MobilePhone`                | Phone                  | Account                    | `Phone`                      | Phone                       |
| Mobile Phone                 | `MobilePhone`                | Phone                  | PersonAccount              | `PersonMobilePhone`          | Phone                       |
| Name                         | `Name`                       | Auto Number            | —                          | —                            | —                           |
| New Recurring Gift           | `IsNewRecurringGift`         | Checkbox               | —                          | —                            | —                           |
| Organization Name            | `OrganizationName`           | Text(255)              | Account                    | `Name`                       | Text(255)                   |
| Outreach Source Code         | `OutreachSourceCodeId`       | Lookup(OutreachSourceCode) | GiftTransaction        | `OutreachSourceCodeId`       | Lookup(OutreachSourceCode)  |
| Outreach Source Code         | `OutreachSourceCodeId`       | Lookup(OutreachSourceCode) | GiftCommitmentSchedule | `OutreachSourceCodeId`       | Lookup(OutreachSourceCode)  |
| Owner Name                   | `OwnerId`                    | Lookup(User, Group)    | —                          | —                            | —                           |
| Payment Identifier           | `PaymentIdentifier`          | Text(255)              | GiftTransaction            | `PaymentIdentifier`          | Text(255)                   |
| Payment Method               | `PaymentMethod`              | Picklist               | GiftTransaction            | `PaymentMethod`              | Picklist                    |
| Postal Code                  | `PostalCode`                 | Text(20)               | Account                    | `BillingPostalCode`          | Text(20)                    |
| Postal Code                  | `PostalCode`                 | Text(20)               | PersonAccount              | `PersonMailingPostalCode`    | Text(20)                    |
| Salutation                   | `Salutation`                 | Picklist               | PersonAccount              | `Salutation`                 | Picklist                    |
| Set As Default               | `IsSetAsDefault`             | Checkbox               | —                          | —                            | —                           |
| Soft Credit Information      | `SoftCreditInformation`      | Long Text Area(32768)  | GiftDefaultSoftCredit      | `PartialAmount`              | Currency(16, 2)             |
| Soft Credit Information      | `SoftCreditInformation`      | Long Text Area(32768)  | GiftDefaultSoftCredit      | `PartialPercent`             | Percent(3, 0)               |
| Soft Credit Information      | `SoftCreditInformation`      | Long Text Area(32768)  | GiftDefaultSoftCredit      | `RecipientId`                | Lookup(Account)             |
| Soft Credit Information      | `SoftCreditInformation`      | Long Text Area(32768)  | GiftDefaultSoftCredit      | `Role`                       | Picklist                    |
| Soft Credit Information      | `SoftCreditInformation`      | Long Text Area(32768)  | GiftSoftCredit             | `PartialAmount`              | Currency(16, 2)             |
| Soft Credit Information      | `SoftCreditInformation`      | Long Text Area(32768)  | GiftSoftCredit             | `PartialPercent`             | Percent(3, 0)               |
| Soft Credit Information      | `SoftCreditInformation`      | Long Text Area(32768)  | GiftSoftCredit             | `RecipientId`                | Lookup(Account)             |
| Soft Credit Information      | `SoftCreditInformation`      | Long Text Area(32768)  | GiftSoftCredit             | `Role`                       | Picklist                    |
| State/Province               | `State`                      | Text(80)               | Account                    | `BillingState`               | Text(80)                    |
| State/Province               | `State`                      | Text(80)               | PersonAccount              | `PersonMailingState`         | Text(80)                    |
| Street                       | `Street`                     | Text(255)              | Account                    | `BillingStreet`              | Text(255)                   |
| Street                       | `Street`                     | Text(255)              | PersonAccount              | `PersonMailingStreet`        | Text(255)                   |
| Total Transaction Fee Amount | `TotalTransactionFeeAmount`  | Currency(16, 2)        | GiftTransaction            | `DonorCoverAmount`           | Currency(16, 2)             |
| Transaction Day              | `TransactionDay`             | Picklist               | GiftCommitmentSchedule     | `TransactionDay`             | Picklist                    |
| Transaction Interval         | `TransactionInterval`        | Number(9, 0)           | GiftCommitmentSchedule     | `EffectiveTransactionInterval` | Number(9, 0)              |
| Transaction Period           | `TransactionPeriod`          | Picklist               | GiftCommitmentSchedule     | `EffectiveTransactionPeriod` | Text(255)                   |

**Reading notes:**

- **One-to-many rows.** `CampaignId`, `DonorId`, `GiftCommitmentId`, `GiftDesignationNId`, and `SoftCreditInformation` each fan out to 3+ downstream fields — one Gift Entry column, many target inserts.
- **`Gift Received Date` → `TransactionDate`.** The Gift Entry field label is "Gift Received Date" but the value lands on `GiftTransaction.TransactionDate` (the "when did this gift happen" canonical anchor per [[fqs-two-date-model]] — see `docs/gift-acknowledgement-flow.md` and Phase A of `.planning/fqs-process-date-refactor-plan.md`).
- **`GiftDesignationInformation` mapping is odd.** Long-text-area value maps to *both* the lookup (`GiftDesignationId`) *and* the amount/percent columns — Salesforce parses the freetext internally. Don't try to mirror this in custom code; use `GiftDesignation1..3` if amounts/percents matter.
- **`TotalTransactionFeeAmount` → `DonorCoverAmount` (not a fee field).** The label reads "fee" but the mapping is to `DonorCoverAmount` — this is a Salesforce doc quirk, not a typo. If FQS ever needs a real fee-mirror path we'd need a custom field with its own explicit flow write.
- **Fields with no target** (`GiftProcessingResult`, `GiftProcessingStatus`, `GiftBatchId`, `IsNewRecurringGift`, `IsSetAsDefault`, `Name`, `LastProcessedDateTime`, audit fields) stay on the staging row — the platform reads them for orchestration, doesn't propagate.

---

## FQS Custom Mirror Fields (deployed 2026-08-02)

**Status:** 10 GiftEntry mirror fields + `FieldMappingConfig` records deployed to FundFirst 2026-08-02. GiftEntry fields authored under `force-app/main/default/objects/GiftEntry/fields/`; picklist values sourced from three GlobalValueSets under `force-app/main/default/globalValueSets/` (`FQS_Gift_Transaction_Category`, `FQS_Stewardship_Status`, `FQS_Match_Status`). Salesforce field mappings live in `force-app/main/default/fieldMappingConfigs/FieldMappingConfig.fieldMappingConfig` — see [[fieldmappingconfig-metadata-type]] memory for deploy gotchas.

FQS ships 14 writable custom fields on `GiftCommitment` and `GiftTransaction` (formulas excluded — those derive post-commit and don't need staging). Every one of those either appears explicitly on a Gift Entry screen (user chooses/types the value) or gets defaulted in the background before commit. To keep the launcher on a single staging row, `GiftEntry` needs a mirror for each.

Proposed additions:

| GiftEntry API Name (proposed)                       | GiftEntry Data Type | Target Object   | Target Field                            | Notes                                                                 |
| --------------------------------------------------- | ------------------- | --------------- | --------------------------------------- | --------------------------------------------------------------------- |
| `FQS_Gift_Commitment_Category__c`                   | Picklist            | GiftCommitment  | `FQS_Gift_Commitment_Category__c`       | Same picklist values as the target field.                             |
| `FQS_Match_Eligible__c`                             | Checkbox            | GiftCommitment  | `FQS_Match_Eligible__c`                 | Default per campaign template.                                        |
| `FQS_Restriction_Release_Date__c` (GC)              | Date                | GiftCommitment  | `FQS_Restriction_Release_Date__c`       | Multi-year grant scenarios only.                                      |
| `FQS_Skip_Naming__c` (GC)                           | Checkbox            | GiftCommitment  | `FQS_Skip_Naming__c`                    | Advanced/hidden by default on the launcher.                           |
| `FQS_Gift_Transaction_Category__c`                  | Picklist            | GiftTransaction | `FQS_Gift_Transaction_Category__c`      | Same picklist values as target.                                       |
| `FQS_Donor_Tax_Date__c`                             | Date                | GiftTransaction | `FQS_Donor_Tax_Date__c`                 | Payment-type-aware default (see FQSSeedGenerator for logic). Renamed from FQS_Donor_Tax_Acknowledgement_Date__c on 2026-08-02. |
| `FQS_Fair_Market_Value_Amount__c`                   | Currency(16, 2)     | GiftTransaction | `FQS_Fair_Market_Value_Amount__c`       | Required only when `GiftType = In-Kind` (validation lives on GT).     |
| `FQS_In_Kind__c`                                    | Checkbox            | GiftTransaction | `FQS_In_Kind__c`                        | Set by Payment Method routing (In-Kind auto-checks).                  |
| `FQS_Matched__c`                                    | Checkbox            | GiftTransaction | `FQS_Matched__c`                        | Default false; flips true when matching-employer flow lands.          |
| `FQS_Recurring__c`                                  | Checkbox            | GiftTransaction | `FQS_Recurring__c`                      | Mirrors `IsNewRecurringGift` at commit; kept separate for clarity.    |
| `FQS_Restriction_Release_Date__c` (GT)              | Date                | GiftTransaction | `FQS_Restriction_Release_Date__c`       | Same shape as GC-side; drop into per-installment GTs.                 |
| `FQS_Skip_Naming__c` (GT)                           | Checkbox            | GiftTransaction | `FQS_Skip_Naming__c`                    | Advanced/hidden.                                                      |
| `FQS_Stewardship_Date__c`                           | Date                | GiftTransaction | `FQS_Stewardship_Date__c`               | Reserved for post-commit stewardship flow — carry through if entered. |
| `FQS_Stewardship_Status__c`                         | Picklist            | GiftTransaction | `FQS_Stewardship_Status__c`             | Same picklist values as target.                                       |
| `FQS_Tax_Receipt_Date__c`                           | Date                | GiftTransaction | `FQS_Tax_Receipt_Date__c`               | Distinct from `AcknowledgementDate` (thank-you) — see two-date model. |

**Fields deliberately NOT mirrored:**

- All `FQS_Is_*` formula checkboxes (`FQS_Is_Entry_Gift/Commitment__c`, `FQS_Is_Major_*`, `FQS_Is_Mid_*`) — derived from `OriginalAmount` / `ExpectedTotalCmtAmount` at row level; no staging needed.
- `FQS_Summary__c` — formula, derived from other GC fields.
- `FQS_Processed_Date__c` — deprecated as of Phase A of the process-date refactor (2026-08-02). Not carried forward. See `.planning/fqs-process-date-refactor-plan.md`.

**Design notes:**

- **Picklist alignment.** Any FQS custom picklist mirrored on GiftEntry MUST use the exact same values (case-sensitive) as the target field, or the commit fans out with a null value and no error. When we add these, retrieve the target field's `<valueSet>` and copy verbatim.
- **`FQS_Restriction_Release_Date__c` + `FQS_Skip_Naming__c` dual-target constraint.** These fields exist on both GC and GT. **Salesforce enforces one `sourceFieldId` → one `destinationFieldId` at the `FieldMappingConfig` level** — a single GiftEntry mirror can't fan out to both GC and GT. Current shape: mapped to GT-side only (the row created per Gift Entry commit). GC-side back-fill remains a follow-up — options are (a) split each into `FQS_GT_*` + `FQS_GC_*` GiftEntry mirrors, or (b) post-commit RecordAfterSave flow that copies GT→GC when the parent commitment is being created in the same submission. Same constraint applies to any future FQS field that lives on both GC and GT — see [[fieldmappingconfig-metadata-type]].
- **Naming convention.** All mirrors keep the `FQS_` prefix and match the target API name exactly where possible — makes the mapping self-documenting and grep-friendly.
- **Permset.** Every added mirror needs a corresponding `<fieldPermissions>` block in `FQS_Custom_Fields.permissionset-meta.xml` on the `GiftEntry` object.
- **Post-install README.** No standard-field edits here (all custom), so no README post-install steps needed for these — but the deploy sequence still matters if any picklist inherits its value set from the target field via a GlobalValueSet.

---

## When to Update This Doc

- A new custom field lands on `GiftCommitment` or `GiftTransaction` that the launcher writes → add a mirror row.
- The Gift Entry flow authoring reveals a defaulted-in-background value we forgot to stage → add a mirror row.
- Salesforce publishes a new standard `GiftEntry` field in a future release → add to the Standard Default Mappings table with the upstream provenance noted.

Related:

- Standard field surface enumeration: `sf sobject describe --sobject GiftEntry`
- Downstream target definitions: `force-app/main/default/objects/GiftCommitment/fields/`, `force-app/main/default/objects/GiftTransaction/fields/`
- Two-date refactor context: `.planning/fqs-process-date-refactor-plan.md`
- Flow authoring context: `docs/fqs-account-launcher-flow-by-gift-type.md`, `docs/gift-commitment-flows.md`
