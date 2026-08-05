# FQS — Gift Entry Field Help Text & Admin Description Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst` sandbox (default)
**Goal:** Add `inlineHelpText` (end-user tooltip) and `description` (admin-only Setup text) to every field on the standard `GiftEntry` object, so admins and gift-entry users understand what each field means, which downstream object/field it feeds on processing, and any input rules.

**Sources of truth:**

1. The Salesforce Fundraising developer docs (`GiftEntry` object reference) for every official field description, allowed picklist values, defaulting behavior, and API version.
2. The provided source→target mapping table (Fundraising Quick Start Implementation Guide, pages 57–63) for what each Gift Entry field writes to on save.

Descriptions and help text on the field metadata are self-contained — they do NOT reference other repo files (Setup-viewable text stands on its own).

---

## Context

`GiftEntry` is a standard Salesforce Fundraising staging object. Records are drafted inside a Gift Batch. On processing, most Gift Entry fields are **copied** to their target object/field (Account, PersonAccount, PaymentInstrument, GiftTransaction, GiftCommitment, GiftCommitmentSchedule, GiftTransactionDesignation, GiftDefaultDesignation, GiftDefaultSoftCredit, GiftSoftCredit).

The Gift Entry object ships with **no in-app help text** on any field. Gift-entry staff are left guessing what "Effective Start Date" vs. "Expected End Date" means, why there are three Gift Designation slots, and what a "Soft Credit Information" long-text field is for. This plan closes that gap for both audiences below.

**Two audiences, two field-meta elements:**

| Element | Audience | Where it shows | Style |
|---|---|---|---|
| `inlineHelpText` | End users (gift-entry staff) | Tooltip on the field in Gift Entry / Gift Batch UI | Plain-language, ≤255 chars, tells them what to type and (when useful) what it becomes on save |
| `description` | Admins only | Setup → Object Manager → GiftEntry → Fields | Grounded in the official developer-doc description; names the target object/field on save; notes any constraints |

**Standard-field caveat:** Every GiftEntry field is standard (no `__c`). Salesforce permits `inlineHelpText` and `description` overrides on standard fields via field-meta.xml. If any specific field is locked by the managed package the deploy will fail gracefully with a per-field error — no data risk. Validate before merging.

---

## Files to create

**Directory (does not exist yet):** `force-app/main/default/objects/GiftEntry/fields/`

**File count target:** 49 field-meta.xml files — one per field on the source mapping table, plus a small set of system/staging fields (see Group 9). The exact count depends on the decisions in the open questions.

Each file follows this shape:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>FieldApiName</fullName>
    <description>Admin-facing description — anchors on the developer-doc description and names the target on save.</description>
    <inlineHelpText>End-user tooltip — plain-language guidance.</inlineHelpText>
</CustomField>
```

No `<type>` element for standard-field overrides.

---

## Field grouping

The 49 fields fall into 9 logical clusters. Help text is drafted per group so tone stays consistent within a group and users see coherent guidance when they scan the layout.

1. **Donor identity** (7): `DonorId`, `OrganizationName`, `Salutation`, `FirstName`, `LastName`, `Email`, `IsSetAsDefault`
2. **Address & phone** (7): `Street`, `City`, `State`, `PostalCode`, `Country`, `HomePhone`, `MobilePhone`
3. **Gift financial core** (5): `GiftAmount`, `GiftType`, `GiftReceivedDate`, `DonorCoverAmount`, `TotalTransactionFeeAmount`
4. **Payment instrument** (6): `PaymentMethod`, `PaymentIdentifier`, `Last4`, `ExpiryMonth`, `ExpiryYear`, `CheckDate`
5. **Attribution** (2): `CampaignId`, `OutreachSourceCodeId`
6. **Designations** (10): `GiftDesignation1Id`, `GiftDesignation1Amount`, `GiftDesignation1Percent`, `GiftDesignation2Id`, `GiftDesignation2Amount`, `GiftDesignation2Percent`, `GiftDesignation3Id`, `GiftDesignation3Amount`, `GiftDesignation3Percent`, `GiftDesignationInformation`
7. **Recurring / commitment schedule** (8): `GiftCommitmentId`, `GiftTransactionId`, `IsNewRecurringGift`, `EffectiveStartDate`, `ExpectedEndDate`, `TransactionDay`, `TransactionInterval`, `TransactionPeriod`
8. **Soft credit** (1): `SoftCreditInformation`
9. **System / staging** (10): `Name`, `OwnerId`, `CreatedById`, `CreatedDate`, `LastModifiedById`, `LastModifiedDate`, `GiftBatchId`, `GiftProcessingStatus`, `GiftProcessingResult`, `LastProcessedDateTime`

---

## Field-by-field drafts

Format:
> **Field label** — `ApiName`
> **Target on save:** what it becomes when the batch is processed
> **Help text (≤255 chars):** end-user tooltip
> **Admin description:** Setup-only text (rooted in the developer doc)

---

### Group 1 — Donor identity

**1. Donor** — `DonorId`
- **Target on save:** `GiftTransaction.DonorId`, `GiftCommitment.DonorId`, and `PaymentInstrument.AccountId`.
- **Help text:** The donor giving this gift. For an individual, pick a Person Account (household). For an organization, pick a business Account. Used to attribute the gift, the payment instrument, and any recurring commitment.
- **Admin description:** The person, household, or organization account associated with the gift. Lookup to Account. Copied to `GiftTransaction.DonorId`, `GiftCommitment.DonorId`, and `PaymentInstrument.AccountId` when the gift entry is processed. If left blank and OrganizationName or LastName is populated, Gift Entry may create a new Account of the corresponding type.

**2. Organization Name** — `OrganizationName`
- **Target on save:** `Account.Name` when a new organization Account is auto-created.
- **Help text:** Legal name of the giving organization. Leave blank for individual gifts. If you enter this and no Donor is selected, Gift Entry can create a new organization Account with this name.
- **Admin description:** The name of the donating organization associated with the gift entry. Copied to `Account.Name` when Gift Entry auto-creates an organization Account. Ignored when DonorId already points to an existing Account.

**3. Salutation** — `Salutation`
- **Target on save:** `PersonAccount.Salutation` when a new Person Account is auto-created.
- **Help text:** Honorific used in front of the donor's name in greetings (Dr., Mr., Mrs., Ms., Mx., Prof.).
- **Admin description:** Specifies the honorific abbreviation, word, or phrase to be used in front of the donor's name in greetings. Restricted picklist: Dr., Mr., Mrs., Ms., Mx., Prof. Copied to `PersonAccount.Salutation` when Gift Entry auto-creates a Person Account.

**4. First Name** — `FirstName`
- **Target on save:** `PersonAccount.FirstName`
- **Help text:** Donor's first name. Enter this along with Last Name if you want Gift Entry to create a new Person Account for the donor.
- **Admin description:** The first name of the donor. Copied to `PersonAccount.FirstName` when Gift Entry auto-creates a Person Account. Ignored when DonorId already resolves to an existing Person Account.

**5. Last Name** — `LastName`
- **Target on save:** `PersonAccount.LastName`
- **Help text:** Donor's last name. Required to create a new Person Account. Ignored when Donor is already selected.
- **Admin description:** The last name of the donor. Copied to `PersonAccount.LastName` when Gift Entry auto-creates a Person Account. Required by Salesforce for any new Person Account.

**6. Email** — `Email`
- **Target on save:** `PersonAccount.PersonEmail`
- **Help text:** Donor's email address. Used for receipts and acknowledgements.
- **Admin description:** The email of the donor. Copied to `PersonAccount.PersonEmail` on Person Account create/update per NPC Gift Entry behavior. Standard Email format validation applies.

**7. Set As Default** — `IsSetAsDefault`
- **Target on save:** N/A — this is a Gift Entry batch-authoring convenience flag; it is not copied to any downstream object.
- **Help text:** Check to use the values on this gift entry as the default values for other new gift entries in the same batch. Speeds up data entry when many gifts in the batch share the same donor, amount, or designation.
- **Admin description:** Indicates whether the values in this gift entry are used as default values in other gift entries of the gift batch (true) or not (false). Default value: false. Batch-authoring flag only — not copied to any downstream object on processing.

---

### Group 2 — Address & phone

**8. Street** — `Street`
- **Target on save:** `Account.BillingStreet` / `PersonAccount.PersonMailingStreet`
- **Help text:** Street address for the donor. Written to the billing address on a business Account or the mailing address on a Person Account.
- **Admin description:** The street details from the donor's address. Dual-target on Account create: `Account.BillingStreet` for Organization record types; `PersonAccount.PersonMailingStreet` for Household.

**9. City** — `City`
- **Target on save:** `Account.BillingCity` / `PersonAccount.PersonMailingCity`
- **Help text:** City for the donor's billing (organization) or mailing (individual) address.
- **Admin description:** The city where the donor resides. Dual-target: `Account.BillingCity` (Organization) / `PersonAccount.PersonMailingCity` (Household).

**10. State/Province** — `State`
- **Target on save:** `Account.BillingState` / `PersonAccount.PersonMailingState`
- **Help text:** State or province. If your org has State/Country picklists enabled, enter the state code (e.g., "CA") to match.
- **Admin description:** The name of the state or province where the donor resides. Dual-target: `Account.BillingState` (Organization) / `PersonAccount.PersonMailingState` (Household). Note: the source mapping table has a typo "BilingState" — actual API name is `BillingState`.

**11. Postal Code** — `PostalCode`
- **Target on save:** `Account.BillingPostalCode` / `PersonAccount.PersonMailingPostalCode`
- **Help text:** Postal or ZIP code for the donor's address.
- **Admin description:** The postal code from the donor's address. Dual-target: `Account.BillingPostalCode` (Organization) / `PersonAccount.PersonMailingPostalCode` (Household).

**12. Country** — `Country`
- **Target on save:** `Account.BillingCountry` / `PersonAccount.PersonMailingCountry`
- **Help text:** Country for the donor's address. Use the two-letter code (e.g., "US") if State/Country picklists are enabled.
- **Admin description:** The country where the donor resides. Dual-target: `Account.BillingCountry` (Organization) / `PersonAccount.PersonMailingCountry` (Household).

**13. Home Phone** — `HomePhone`
- **Target on save:** `PersonAccount.PersonHomePhone`
- **Help text:** Donor's home phone number. Leave blank for organizations.
- **Admin description:** The home phone number of the donor. Copied to `PersonAccount.PersonHomePhone` on Person Account create/update. No corresponding target field on business Accounts.

**14. Mobile Phone** — `MobilePhone`
- **Target on save:** `PersonAccount.PersonMobilePhone` (individuals) / `Account.Phone` (organizations)
- **Help text:** Mobile phone for individuals, or main phone for organizations. Written to whichever Account type is created.
- **Admin description:** The mobile number of the donor. Dual-target based on Account record type: `Account.Phone` (Organization) / `PersonAccount.PersonMobilePhone` (Household). Uncommon in that it maps to different-name target fields on the two Account types.

---

### Group 3 — Gift financial core

**15. Gift Amount** — `GiftAmount`
- **Target on save:** `GiftTransaction.OriginalAmount` for one-time and pledge-payment gifts; `GiftCommitmentSchedule.TransactionAmount` when a recurring commitment is created.
- **Help text:** The full gift amount. For a recurring gift, this is the per-installment amount, not the annual total. For a pledge payment, this is the payment amount, not the pledge total.
- **Admin description:** The amount of the gift. Dual-target based on gift context: `GiftTransaction.OriginalAmount` for a one-time or pledge-payment transaction; `GiftCommitmentSchedule.TransactionAmount` when a new recurring commitment schedule is created.

**16. Gift Type** — `GiftType`
- **Target on save:** `GiftTransaction.GiftType`
- **Help text:** Whether the gift is from an Individual or an Organization. Defaults to Individual.
- **Admin description:** Specifies the type of gift that's associated with the gift entry. Restricted picklist: Individual, Organizational. Default value: Individual. Copied to `GiftTransaction.GiftType` on processing.

**17. Gift Received Date** — `GiftReceivedDate`
- **Target on save:** `GiftTransaction.TransactionDate`
- **Help text:** The date the gift was received. For checks, use the postmark or deposit date per your policy. For credit-card gifts, use the transaction settlement date.
- **Admin description:** The date when the gift is received. Copied to `GiftTransaction.TransactionDate` on processing.

**18. Donor Cover Amount** — `DonorCoverAmount`
- **Target on save:** `GiftTransaction.DonorCoverAmount`
- **Help text:** The extra fee amount the donor paid on top of the gift to cover processing costs.
- **Admin description:** The fee amount that a donor pays in addition to the gift amount. Copied to `GiftTransaction.DonorCoverAmount` on processing.

**19. Total Transaction Fee Amount** — `TotalTransactionFeeAmount`
- **Target on save:** `GiftTransaction.DonorCoverAmount` *(per the source mapping table)*
- **Help text:** Total fees charged by the payment processor (application fees, processing fees, etc.).
- **Admin description:** The total transaction fees charged by the payment processor for the gift, for example application fees and processing fees. Per the source mapping table this Gift Entry field writes to `GiftTransaction.DonorCoverAmount` — the same target as the DonorCoverAmount field. **Open question — see below** for whether both should remain on FundFirst layouts.

---

### Group 4 — Payment instrument

**20. Payment Method** — `PaymentMethod`
- **Target on save:** `GiftTransaction.PaymentMethod`
- **Help text:** How the donor paid — Credit Card, ACH, Check, Cash, etc. Drives which other fields you need to fill in (Last 4 / Expiry for cards, Check Date for checks).
- **Admin description:** Specifies the payment method used for this gift. Picklist. Values: ACH, Asset, Cash, Check, Credit Card, Cryptocurrency, In-Kind, PayPal, Stock, Unknown, Venmo. Copied to `GiftTransaction.PaymentMethod` on processing.

**21. Payment Identifier** — `PaymentIdentifier`
- **Target on save:** `GiftTransaction.PaymentIdentifier`
- **Help text:** External reference for the payment — check number, wire reference, merchant order number, or any locally-meaningful identifier for reconciliation.
- **Admin description:** The identifier of the payment method for the gift, such as check number, transaction order number, or merchant order number. Copied to `GiftTransaction.PaymentIdentifier` on processing. Distinct from `GiftTransaction.GatewayReference` (gateway-assigned transaction ID).

**22. Last 4** — `Last4`
- **Target on save:** `PaymentInstrument.Last4`
- **Help text:** Last four digits of the credit card or bank account. Never enter the full number — Payment Card Industry (PCI) rules only allow the last 4 to be stored.
- **Admin description:** The last 4 digits of the credit card or bank account. Available from API version 60.0 and later. Copied to `PaymentInstrument.Last4` when a Payment Instrument is created.

**23. Expiry Month** — `ExpiryMonth`
- **Target on save:** `PaymentInstrument.ExpiryMonth`
- **Help text:** Credit card expiration month (01–12). Required for card payments.
- **Admin description:** The month of the credit card expiration date. Available from API version 60.0 and later. Copied to `PaymentInstrument.ExpiryMonth`.

**24. Expiry Year** — `ExpiryYear`
- **Target on save:** `PaymentInstrument.ExpiryYear`
- **Help text:** Credit card expiration year (four digits, e.g., 2027). Required for card payments.
- **Admin description:** The year of the credit card expiration date. Available from API version 60.0 and later. Copied to `PaymentInstrument.ExpiryYear`.

**25. Check Date** — `CheckDate`
- **Target on save:** `GiftTransaction.CheckDate`
- **Help text:** The date printed on the check. Used for donor-intent reporting when it differs from the date the check was received.
- **Admin description:** The date on the check that is used as the payment method for the gift. Copied to `GiftTransaction.CheckDate` on processing. Only meaningful when PaymentMethod = Check.

---

### Group 5 — Attribution

**26. Campaign** — `CampaignId`
- **Target on save:** `GiftTransaction.CampaignId` (one-time / pledge payment), `GiftCommitment.CampaignId` (new commitment), or `GiftCommitmentSchedule.CampaignId` (schedule).
- **Help text:** The campaign this gift belongs to. If you also set Outreach Source Code, the source code's parent Campaign must match this campaign.
- **Admin description:** The campaign that's associated with the gift entry. Lookup to Campaign. Copied on processing to `GiftTransaction.CampaignId`, `GiftCommitment.CampaignId`, or `GiftCommitmentSchedule.CampaignId` depending on gift context. When both CampaignId and OutreachSourceCodeId are set, the OSC's parent Campaign must equal this value; recommended pattern is to set the OSC first and let Campaign follow.

**27. Outreach Source Code** — `OutreachSourceCodeId`
- **Target on save:** `GiftTransaction.OutreachSourceCodeId` / `GiftCommitmentSchedule.OutreachSourceCodeId`
- **Help text:** The appeal, event, or channel that generated this gift. Must belong to the Campaign selected on this record.
- **Admin description:** The outreach source code that's associated with the campaign for the gift entry record. Lookup to OutreachSourceCode. Copied to `GiftTransaction.OutreachSourceCodeId` (or `GiftCommitmentSchedule.OutreachSourceCodeId` for recurring). NPC enforces Campaign parity between OSC and gift on save.

---

### Group 6 — Designations

Designations 1/2/3 share the same shape. Help text is templated so slots 2 and 3 differ only by slot number and optionality wording.

**28. Gift Designation 1** — `GiftDesignation1Id`
- **Target on save:** `GiftTransactionDesignation.GiftDesignationId` for a transaction; `GiftDefaultDesignation.GiftDesignationId` for a commitment/opportunity/campaign default.
- **Help text:** The fund or program this gift supports. If the gift is split across multiple funds, use slots 1–3 and either the Amount or Percent field for each.
- **Admin description:** The name of the designation 1 to which the gift amount is to be allocated. Lookup to GiftDesignation. Copied to `GiftTransactionDesignation.GiftDesignationId` on transaction processing, or to `GiftDefaultDesignation.GiftDesignationId` when the gift is a commitment/opportunity/campaign default.

**29. Gift Designation 1 – Amount** — `GiftDesignation1Amount`
- **Target on save:** `GiftTransactionDesignation.Amount`
- **Help text:** Fixed dollar amount going to Designation 1. Use either Amount or Percent — not both.
- **Admin description:** The amount to be allocated to designation 1. Copied to `GiftTransactionDesignation.Amount` on processing.

**30. Gift Designation 1 – Percent** — `GiftDesignation1Percent`
- **Target on save:** `GiftTransactionDesignation.Percent` (transaction) / `GiftDefaultDesignation.AllocatedPercentage` (default)
- **Help text:** Percentage of the gift going to Designation 1. Percents across all filled slots must total 100. Use either Amount or Percent — not both.
- **Admin description:** The percentage of gift amount to be allocated to designation 1 if the direct amount isn't being allocated. Copied to `GiftTransactionDesignation.Percent` (target type Percent(15,3)) for transactions or `GiftDefaultDesignation.AllocatedPercentage` (target type Percent(3,0)) for defaults. Gift Entry input is Percent(3,0).

**31–33. Gift Designation 2** — `GiftDesignation2Id`, `GiftDesignation2Amount`, `GiftDesignation2Percent`
- Same targets and rules as Designation 1. Help text says "Designation 2" in place of "Designation 1"; adds "Leave blank if this gift only uses Designation 1."
- **Admin description (Id):** The name of the designation 2 to which the gift amount is to be allocated.
- **Admin description (Amount):** The amount to be allocated to designation 2.
- **Admin description (Percent):** The percentage of gift amount to be allocated to designation 2 if the direct amount isn't being allocated.

**34–36. Gift Designation 3** — `GiftDesignation3Id`, `GiftDesignation3Amount`, `GiftDesignation3Percent`
- Same shape. Help text says "Designation 3"; adds "For gifts with more than 3 designations, use Gift Designation Information to record the additional splits."
- **Admin description (Id):** The name of the designation 3 to which the gift amount is to be allocated.
- **Admin description (Amount):** The amount to be allocated to designation 3.
- **Admin description (Percent):** The percentage of gift amount to be allocated to designation 3 if the direct amount isn't being allocated.

**37. Gift Designation Information** — `GiftDesignationInformation`
- **Target on save:** parsed on processing into additional `GiftTransactionDesignation` / `GiftDefaultDesignation` rows.
- **Help text:** Free-form notes for designation splits beyond the three built-in slots. Format: one designation per line, e.g., `Scholarship Fund: $500` or `Building Fund: 25%`.
- **Admin description:** Details about the gift designation such as the designation name, amount, or percentage of the gift that's allocated to the designation. Long Text Area(32768). Available in API version 66.0 and later. Per the source mapping table, this field feeds `GiftTransactionDesignation.GiftDesignationId`, `.Amount`, and `.Percent` (and their `GiftDefaultDesignation` equivalents) on processing.

---

### Group 7 — Recurring / commitment schedule

**38. Gift Commitment** — `GiftCommitmentId`
- **Target on save:** links this gift to an existing `GiftCommitment`. On processing, propagates to `GiftTransaction.GiftCommitmentId`, `GiftCommitmentSchedule.GiftCommitmentId`, and to `GiftDefaultDesignation.ParentRecordId` / `GiftDefaultSoftCredit.ParentRecordId` where those are being seeded.
- **Help text:** The pledge or recurring commitment this gift pays down. Leave blank for one-time gifts. For a pledge payment, pick the existing commitment.
- **Admin description:** The gift commitment that's associated with the gift entry. Lookup to GiftCommitment. Ties the new GiftTransaction to the existing commitment on processing and propagates to any Default Designation / Default Soft Credit records being seeded.

**39. Gift Transaction** — `GiftTransactionId`
- **Target on save:** links to an existing `GiftTransaction`; also propagates to `GiftTransactionDesignation.GiftTransactionId` and `GiftSoftCredit.GiftTransactionId`.
- **Help text:** Only used when adding designations or soft credits to an existing gift transaction. Leave blank for new gifts.
- **Admin description:** The gift transaction that's associated with the gift entry. Lookup to GiftTransaction. Populated when Gift Entry is being used to append related records (designation splits, soft credits) to an existing GiftTransaction rather than to create a new transaction.

**40. New Recurring Gift** — `IsNewRecurringGift`
- **Target on save:** staging flag; on processing, causes creation of a new `GiftCommitment` + `GiftCommitmentSchedule` chain rather than a one-time `GiftTransaction`.
- **Help text:** Check to start a new recurring gift series. Requires Effective Start Date, Transaction Period, and Transaction Day. Leave unchecked for one-time gifts or payments on an existing recurring commitment.
- **Admin description:** Indicates whether the gift is a new recurring gift commitment (true) or not (false). Default value: false. Available in API version 61.0 and later. When true, Gift Entry processing creates a GiftCommitment, a GiftCommitmentSchedule, and the first GiftTransaction; when false, only a GiftTransaction is created (optionally under the GiftCommitmentId parent).

**41. Effective Start Date** — `EffectiveStartDate`
- **Target on save:** `GiftCommitmentSchedule.StartDate`
- **Help text:** The date the recurring series starts. First installment is created on or after this date, per the Transaction Day and Period. Required when New Recurring Gift is checked.
- **Admin description:** The date from when the commitment is in effect. Available in API version 61.0 and later. Copied to `GiftCommitmentSchedule.StartDate` on processing.

**42. Expected End Date** — `ExpectedEndDate`
- **Target on save:** `GiftCommitmentSchedule.EndDate`
- **Help text:** For a fixed-length recurring gift, when the series ends. Leave blank for open-ended monthly donors.
- **Admin description:** The date when the total amount of the commitment is expected to be paid. Available in API version 61.0 and later. Copied to `GiftCommitmentSchedule.EndDate` on processing. A blank value corresponds to an open-ended recurrence; a set value corresponds to a fixed-length recurrence.

**43. Transaction Day** — `TransactionDay`
- **Target on save:** `GiftCommitmentSchedule.TransactionDay`
- **Help text:** The day each installment is created. For monthly gifts, pick a day 1–28 to avoid skipped months (February). Choose Last Day for end-of-month gifts.
- **Admin description:** Specifies the day of the month to create gift transactions in the future for a monthly transaction period. Restricted picklist: 1–30 and LastDay. Default value: 1. Available in API version 61.0 and later. If 29 or 30 is chosen, the gift transaction is created on the last day for months that don't have that many days. Copied to `GiftCommitmentSchedule.TransactionDay`.

**44. Transaction Interval** — `TransactionInterval`
- **Target on save:** `GiftCommitmentSchedule.EffectiveTransactionInterval`
- **Help text:** How many periods between installments. Interval 1 with Period Monthly = every month; Interval 3 with Period Monthly = every three months (quarterly).
- **Admin description:** The interval of running the gift commitment schedule. The transaction period and interval together define how often the schedule runs — for example, transaction period Monthly and transaction interval 3 means the schedule runs every three months. Available in API version 61.0 and later. Copied to `GiftCommitmentSchedule.EffectiveTransactionInterval`.

**45. Transaction Period** — `TransactionPeriod`
- **Target on save:** `GiftCommitmentSchedule.EffectiveTransactionPeriod`
- **Help text:** The unit of time for recurring installments — Monthly, Weekly, Yearly, etc. Combined with Transaction Interval to define cadence.
- **Admin description:** The period for which the gift commitment schedule is run. Restricted picklist: Custom, Daily, Monthly, Weekly, Yearly. Default value: Monthly. Available in API version 61.0 and later. Source is Picklist on Gift Entry; target `GiftCommitmentSchedule.EffectiveTransactionPeriod` is Text(255). Same enumerated values apply.

---

### Group 8 — Soft credit

**46. Soft Credit Information** — `SoftCreditInformation`
- **Target on save:** parsed on processing into `GiftDefaultSoftCredit.PartialAmount`, `.PartialPercent`, `.RecipientId`, `.Role` (for commitments) or the corresponding fields on `GiftSoftCredit` (for transactions).
- **Help text:** Free-form notes to soft-credit other people or organizations for this gift. Format: one recipient per line, e.g., `Alex Smith: Solicitor, 50%` or `Delta Foundation: Matched Donor, $500`.
- **Admin description:** The information about the soft credit, such as the name of the soft creditor, role, and amount or percentage of soft credit allocated to the soft creditor. Long Text Area(32768). Per the source mapping table, this field feeds four soft-credit target fields (RecipientId, Role, PartialAmount, PartialPercent) on either `GiftSoftCredit` (transaction) or `GiftDefaultSoftCredit` (commitment/opportunity default) on processing.

---

### Group 9 — System / staging (target-less on save)

**47. Name** — `Name`
- **Help text:** Auto-generated gift entry number. Read-only.
- **Admin description:** The name of the gift entry record. Auto number. Uniquely identifies the gift entry within a batch.

**48. Owner Name** — `OwnerId`
- **Help text:** The user or queue that owns this gift entry within the batch.
- **Admin description:** ID of the owner of this object. Polymorphic lookup to User or Group. Ownership does not transfer to the GiftTransaction created on processing (GiftTransaction ownership follows NPC's own assignment rules).

**49. Created By** — `CreatedById`
- **Help text:** User who created this gift entry.
- **Admin description:** System field. User who created this gift entry record.

**50. Created Date** — `CreatedDate`
- **Help text:** When this gift entry was drafted.
- **Admin description:** System field. Distinct from `GiftReceivedDate` (donor-intent date) and `LastProcessedDateTime` (processing timestamp).

**51. Last Modified By** — `LastModifiedById`
- **Help text:** User who last edited this gift entry.
- **Admin description:** System field.

**52. Last Modified Date** — `LastModifiedDate`
- **Help text:** When this gift entry was last edited.
- **Admin description:** System field.

**53. Gift Batch** — `GiftBatchId`
- **Help text:** The batch this gift entry belongs to. All gift entries in a batch are processed together.
- **Admin description:** The parent gift batch that's associated with the gift entry. Lookup to GiftBatch. Processing status and results roll up at the batch level.

**54. Gift Processing Status** — `GiftProcessingStatus`
- **Help text:** Where this gift entry is in processing. Set automatically by the batch — do not edit manually.
- **Admin description:** Specifies the processing status of the gift entry. Restricted picklist: Failure, New, Success. Default value: New. Managed by the NPC gift-processing engine.

**55. Gift Processing Result** — `GiftProcessingResult`
- **Help text:** Error or success message from the last processing attempt. If Status is Failure, this describes why.
- **Admin description:** The processing result of the gift entry record. Populated by the NPC gift-processing engine.

**56. Last Processed Date Time** — `LastProcessedDateTime`
- **Help text:** When the most recent processing attempt ran on this entry.
- **Admin description:** The date and time when the gift entry was last processed. Populated by the NPC gift-processing engine.

---

## Execution steps

1. Create directory `force-app/main/default/objects/GiftEntry/fields/`.
2. Write the field-meta.xml files per the drafts above.
3. Dry-run deploy against FundFirst:
   `sf project deploy start --dry-run --source-dir force-app/main/default/objects/GiftEntry/fields`
4. If any field errors as "cannot set help text on this field" (managed lock), note it in this plan and skip that file.
5. Full deploy on confirmation.
6. Manually verify a sample of tooltips in the FundFirst UI: Fundraising app → Gift Entry tab → New Gift Entry → hover the info icon on `DonorId`, `GiftAmount`, `GiftDesignation1Id`, `IsNewRecurringGift`, and `IsSetAsDefault` to confirm the text renders as drafted.

---

## Open questions for approval

1. **`DonorCoverAmount` vs. `TotalTransactionFeeAmount`:** The source mapping table shows both fields writing to `GiftTransaction.DonorCoverAmount`. Is this intentional (last-write-wins on save), or should we omit `TotalTransactionFeeAmount` from FundFirst gift-entry layouts to avoid double-entry confusion? Currently drafted with a soft flag; happy to hard-flag the collision in help text instead.

2. **Persona check on tone:** Drafts assume gift-entry staff have general Salesforce familiarity but no NPC-model depth (so "Person Account" is spelled out but "GiftCommitmentSchedule" is not). If your gift-entry users are less technical, I can do a plain-language re-drafting pass (fewer "target field" references, more "when you save, this fills in…"). Admin descriptions stay technical either way.

3. **Length ceiling:** All drafts are ≤255 chars. A few (Designation 1 Id, Gift Commitment, Gift Amount) are near 200. If you want a hard-shortened variant (≤150 chars per help text field), say so and I'll trim.

4. **Coverage of system fields (Group 9):** Ten system/staging fields have drafts. If you'd rather leave them at Salesforce default (no help text), I'll drop those 10 files from the deploy — the source mapping table treats them as target-less anyway.

5. **Order of merge with existing plans:** Two related plans are currently open (`fqs-outreach-summary-help-text-plan.md`, `fqs-gift-acknowledgement-plan.md`). Do you want this plan ordered ahead of or behind those, or merged into a single "help text sweep" PR?
