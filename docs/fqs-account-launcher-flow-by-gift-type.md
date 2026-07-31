# FQS Single-Donor Gift Entry — Data Model Reference by Gift Type

**Audience:** Salesforce admins, developers, and implementation partners who need to record fundraising activity against a single donor Account — whether by hand, in Data Loader, via Apex, or from a custom flow / LWC. Describes the records and fields to create for each gift type, and the platform-managed fields to leave alone.

**Scope:** One donor at a time. For batch entry, refunds, adjustments, or Grant-Payment category transactions, see the platform's Gift Entry Manager and the underlying [`GiftRefund`](../force-app/main/default/objects/GiftRefund/) object.

## Overview

The FQS data model supports five single-donor gift-entry scenarios:

| Type | Primary record | Also creates | Category value |
|---|---|---|---|
| Outright Gift | `GiftTransaction` | Optional `GiftTransactionDesignation`, `GiftSoftCredit` | [`FQS_Gift_Transaction_Category__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Gift_Transaction_Category__c.field-meta.xml) = `Outright Gift` |
| In-Kind Gift | `GiftTransaction` | Optional `GiftTransactionDesignation`, `GiftSoftCredit` | `FQS_Gift_Transaction_Category__c` = `Outright Gift` (with [`FQS_In_Kind__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_In_Kind__c.field-meta.xml) = `true`) |
| Earned Income / Event Registration | `GiftTransaction` | Optional `GiftTransactionDesignation`, `GiftSoftCredit` | `FQS_Gift_Transaction_Category__c` = `Other` |
| Pledge Payment | `GiftTransaction` (against existing `GiftCommitment`) | Optional `GiftTransactionDesignation`, `GiftSoftCredit` | `FQS_Gift_Transaction_Category__c` = `Pledge Payment` |
| New Pledge | `GiftCommitment` | Optional `GiftDefaultDesignation` (and a `GiftCommitmentSchedule` — see notes) | [`FQS_Gift_Commitment_Category__c`](../force-app/main/default/objects/GiftCommitment/fields/FQS_Gift_Commitment_Category__c.field-meta.xml) = `Pledged Gift` |

**How to read the field tables below:**
- **Required** — must be populated on insert.
- **Recommended** — not required by the platform, but omitting causes reporting or automation drift.
- **Auto-derive** — set based on other fields; guidance in the notes.
- **Do NOT set** — platform-managed, formula, or auto-populated on insert; writing causes errors or is silently discarded.

## Amounts & dates cheat sheet — `GiftTransaction`

These four fields drive rollups, tax receipts, and payment-cycle timing. They behave the same way across every transaction category, so the per-type tables below just reference this cheat sheet.

| Field | Write on insert? | What it holds | Source of truth |
|---|---|---|---|
| [`OriginalAmount`](../force-app/main/default/objects/GiftTransaction/fields/OriginalAmount.field-meta.xml) | **Yes — required.** | The full gift amount as originally committed. Never mutate later — record a `GiftRefund` for adjustments. | You. |
| [`CurrentAmount`](../force-app/main/default/objects/GiftTransaction/fields/CurrentAmount.field-meta.xml) | **No — platform-managed.** Writing returns `INVALID_FIELD_FOR_INSERT_UPDATE`. | `OriginalAmount` minus posted `GiftRefund` and adjustment amounts. Equals `OriginalAmount` at insert time. | Platform, derived from `OriginalAmount` and `GiftRefund` children. |
| `TaxDeductionAmount` | Optional — set explicitly when the receiptable portion differs from `OriginalAmount` (In-Kind FMV, Fee-for-Service with a partial charitable portion, event tickets with a benefit value). | The tax-deductible / receiptable portion of the gift. | You (or leave null to accept platform default). |
| `NonTaxDeductibleAmount` | **No — platform-managed.** Writes are silently discarded. | Auto-calculated from `TaxDeductionAmount` and `CurrentAmount` (roughly: `CurrentAmount − TaxDeductionAmount`). | Platform. |
| `TransactionDate` | **Yes — required.** | The date the donor made the gift. | You. |
| [`TransactionDueDate`](../force-app/main/default/objects/GiftTransaction/fields/TransactionDueDate.field-meta.xml) | **Yes — required** on every insert, even for `Status = Paid`. Omitting returns `REQUIRED_FIELD_MISSING`. | The date the gift is expected to be received. | You. For `Status = Paid`, set equal to `TransactionDate`. For `Status ≠ Paid`, use the expected receipt date (e.g. `TransactionDate + 30`). |
| `CheckDate` | Optional. | Date printed on the check, when `PaymentMethod = Check`. | You. |
| `AcknowledgementDate` | Optional. | Date the thank-you / acknowledgement was sent. Populated by the acknowledgement flow, not by gift entry. | Downstream automation. |

**Rule of thumb for amounts:**
- **Cash-equivalent gift (Outright / Pledge Payment):** `OriginalAmount = full gift`, `NonTaxDeductibleAmount = 0`. Platform sets `CurrentAmount = OriginalAmount` and derives `TaxDeductionAmount = full gift`.
- **Fee-for-Service (no charitable portion):** `OriginalAmount = full payment`, `NonTaxDeductibleAmount = full payment`. Platform derives `TaxDeductionAmount = 0`.
- **In-Kind:** `OriginalAmount = 0`, `NonTaxDeductibleAmount = 0`, and FMV recorded in a dedicated custom field. See [In-Kind Gift](#in-kind-gift) below.

## Common prerequisites

Applies to every gift type below.

- The donor `Account` must exist. `Account.IsPersonAccount` determines `GiftTransaction.GiftType` (Individual vs Organizational).
- If you plan to attach a `GiftDesignation`, at least one active row must exist in the org with the appropriate [`FQS_Restriction_Type__c`](../force-app/main/default/objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml). An `IsActive = true AND IsDefault = true` designation should exist to support unrestricted gifts.
- If you plan to attach a `Campaign` and want the Account's household Contacts to see it later in campaign pickers, a `CampaignMember` must link a household Contact to that Campaign.

## Outright Gift

**When to use:** One-time cash / check / card gift with no preceding pledge.

**Records to create (in order):**

1. `GiftTransaction`
2. `GiftTransactionDesignation` (optional — recommended; enables designation-based reporting)
3. `GiftSoftCredit` (optional — one per additional recognized donor)

### `GiftTransaction` fields

| Field | Required? | Value / Guidance |
|---|---|---|
| `DonorId` | Required | Donor `Account.Id`. |
| [`FQS_Gift_Transaction_Category__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Gift_Transaction_Category__c.field-meta.xml) | Required | `Outright Gift` |
| [`FQS_In_Kind__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_In_Kind__c.field-meta.xml) | Recommended | `false` |
| `Status` | Required | For real gifts entered manually, use `Pending` and let payment reconciliation transition to `Paid`. Direct-writing `Paid` bypasses payment posting — acceptable for seed/test data only. See [`Status`](../force-app/main/default/objects/GiftTransaction/fields/Status.field-meta.xml). |
| **`OriginalAmount`** | Required | Full gift amount, e.g. `100.00` for a $100 check. See [Amounts & dates cheat sheet](#amounts--dates-cheat-sheet--gifttransaction). |
| **`CurrentAmount`** | Do NOT set | Platform sets `CurrentAmount = OriginalAmount` on insert. Writing returns `INVALID_FIELD_FOR_INSERT_UPDATE`. |
| **`TaxDeductionAmount`** | Recommended | For a cash-equivalent gift, equals `OriginalAmount` (or leave null and accept the platform default). Set to a smaller value only if part of the gift was a benefit to the donor (e.g. event ticket portion). |
| **`NonTaxDeductibleAmount`** | Do NOT set | Auto-calculated from `TaxDeductionAmount` and `CurrentAmount`. |
| **`TransactionDate`** | Required | Date the donor made the gift, e.g. today's date for a walk-in check. |
| **`TransactionDueDate`** | Required | For a one-time gift with `Status = Paid`, set equal to `TransactionDate`. For `Status = Pending`, use the expected receipt date (e.g. `TransactionDate + 30`). See [`TransactionDueDate`](../force-app/main/default/objects/GiftTransaction/fields/TransactionDueDate.field-meta.xml). |
| **`CheckDate`** | Optional | Date printed on the check (populate only when `PaymentMethod = Check`). |
| `GiftType` | Required | `Individual` if `Account.IsPersonAccount = true`, else `Organizational`. |
| `PaymentMethod` | Required | e.g. `Credit Card`, `ACH`, `Check`, `PayPal`. |
| `PaymentIdentifier` | Recommended for `Check` / `ACH` | Check number or ACH reference. |
| `CampaignId` | Recommended | For attribution and rollups. |
| `TaxReceiptStatus` | Recommended | `To Be Sent` |
| `OutreachSourceCodeId` | Optional | If set, `OutreachSourceCode.CampaignId` must equal this record's `CampaignId`. See [`OutreachSourceCodeId`](../force-app/main/default/objects/GiftTransaction/fields/OutreachSourceCodeId.field-meta.xml). |

### `GiftTransactionDesignation` fields (optional but recommended)

| Field | Value |
|---|---|
| `GiftTransactionId` | Id of the `GiftTransaction` created above. |
| `GiftDesignationId` | Id of an `IsActive = true` `GiftDesignation`. Default to the org's `IsDefault = true` designation for unrestricted gifts. |
| `Percent` | `100` (single-designation allocation). |
| `Amount` | `GiftTransaction.OriginalAmount`. |
| [`FQS_Restriction_Type__c`](../force-app/main/default/objects/GiftTransactionDesignation/fields/FQS_Restriction_Type__c.field-meta.xml) | Do NOT set — read-only formula mirroring `GiftDesignation.FQS_Restriction_Type__c`. |

## In-Kind Gift

**When to use:** Non-cash outright gift (donated goods, services, stock at fair market value).

**Records to create:**

1. `GiftTransaction` — with zero cash amounts and the FMV stored on a dedicated custom field.
2. `GiftSoftCredit` (self-recognition) — soft-credits the donor for the FMV so recognition rollups reflect the in-kind value without inflating hard-credit totals.
3. `GiftTransactionDesignation` — optional.

### Design rationale

Hard-credit totals ([`GiftTransaction.OriginalAmount`](../force-app/main/default/objects/GiftTransaction/fields/OriginalAmount.field-meta.xml), rolled up as `DonorGiftSummary.TotalGiftsAmount`) should reflect the actual cash the donor gave the organization. In-kind gifts:

- Are not cash flow and should not inflate cash-flow reporting or the donor's hard-credit total.
- Have a fair market value that the **donor** ultimately determines for their own tax deduction — the charity records what was received and its estimated FMV, but the IRS-reportable deduction is the donor's responsibility. Storing this value in the same field as cash gifts commingles two different accounting concepts.

The convention below keeps hard credits cash-only, surfaces FMV in a dedicated field for tax-receipt and FMV-specific reporting, and uses NPC's soft-credit rollups (`DonorGiftSummary.TotalSoftCreditsAmount`, `TotalHardSoftCreditsAmount`) to give the donor recognition credit for the in-kind value.

### `GiftTransaction` fields — differences from Outright

| Field | Value |
|---|---|
| [`FQS_In_Kind__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_In_Kind__c.field-meta.xml) | `true` |
| `PaymentMethod` | `In-Kind` |
| `Description` | Recommended — describe the donated item / service (e.g. "Auction items: silent auction baskets", "Legal services: pro bono review — 12 hrs"). |
| [`FQS_Gift_Transaction_Category__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Gift_Transaction_Category__c.field-meta.xml) | Still `Outright Gift` — In-Kind is a flag on the outright category, not a separate category. |
| `TaxReceiptStatus` | `To Be Sent` |
| **`OriginalAmount`** | `0.00` — in-kind is not cash. |
| **`CurrentAmount`** | Do NOT set — platform sets to `0.00`. |
| **`NonTaxDeductibleAmount`** | `0.00`. |
| **`TaxDeductionAmount`** | Do NOT set — platform derives to `0.00`. The donor determines the deductible amount from the FMV on their own return; the charity does not record a tax-deduction figure on the gift. |
| **`FQS_InKind_Fair_Market_Value__c`** *(new custom field — see "Data-model additions" below)* | Estimated fair market value of the donated item / service, e.g. `2500.00`. Used for tax receipts (as an "estimated FMV" line, not an IRS-reportable deduction) and FMV-specific reporting. |

### `GiftSoftCredit` fields (self-recognition — always create for in-kind)

| Field | Value |
|---|---|
| `GiftTransactionId` | Id of the in-kind `GiftTransaction`. |
| `RecipientId` | Same as the donor's `Account.Id` — this is a **self soft-credit** for recognition purposes. |
| `PartialAmount` | FMV (same value as `FQS_InKind_Fair_Market_Value__c`). |
| `SoftCreditAmount` | FMV. |
| `Role` | `In-Kind Recognition` — a dedicated value distinct from `Soft Credit` so third-party soft-credit reports (household spouse credits, matching-employer credits) can filter this pattern out easily. |

### Data-model additions required to adopt this convention

1. Add `FQS_InKind_Fair_Market_Value__c` (Currency 18,2) to `GiftTransaction`. Inline help: *"Estimated fair market value of the donated goods or services. Used for tax receipts and reporting. The donor is responsible for determining the actual tax-deductible value on their own return."*
2. Add `In-Kind Recognition` as an allowed value on `GiftSoftCredit.Role` (or document the string convention if `Role` is free-text).
3. Update tax-receipt / acknowledgement logic to render `FQS_InKind_Fair_Market_Value__c` as an **estimated FMV** line when `FQS_In_Kind__c = true`, not as a deductible amount.
4. Retrofit existing in-kind data in the org (including seed data — [FQSSeedGenerator.cls:595-664](../force-app/main/default/classes/FQSSeedGenerator.cls#L595-L664) currently records FMV in `OriginalAmount`). Migration steps: for each existing `GiftTransaction` with `FQS_In_Kind__c = true`, copy `OriginalAmount` → `FQS_InKind_Fair_Market_Value__c`, insert a matching self `GiftSoftCredit`, then set `OriginalAmount = 0` (this will cascade `CurrentAmount = 0` via the platform rollup).

**No changes needed to existing donor-tier or DonorGiftSummary formulas.** In-kind gifts drop out of `TotalGiftsAmount` (hard credit — cash only) and appear in `TotalSoftCreditsAmount` / `TotalHardSoftCreditsAmount` (recognition — cash + in-kind). Reports that want the full donor value use `TotalHardSoftCreditsAmount`; reports that want cash flow use `TotalGiftsAmount`.

### Reporting implications

- **Third-party soft-credit reports** (household, matching gift, solicitor) — filter out `GiftSoftCredit.Role = 'In-Kind Recognition'` to exclude self-credits.
- **`GiftTransaction`-level tier formulas** ([`FQS_Is_Entry_Gift__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Is_Entry_Gift__c.field-meta.xml), [`FQS_Is_Mid_Gift__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Is_Mid_Gift__c.field-meta.xml), [`FQS_Is_Major_Gift__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Is_Major_Gift__c.field-meta.xml)) — in-kind rows return `false` for all tiers because they compare against `CurrentAmount = 0`. If per-transaction tier tagging is needed for in-kind (e.g. a related list highlighting a major in-kind gift), extend the formulas to fall back to `FQS_InKind_Fair_Market_Value__c` when `FQS_In_Kind__c = true`. Donor-level tiers on `DonorGiftSummary` are unaffected — they roll up via `TotalHardSoftCreditsAmount`.

All other fields follow the Outright pattern (dates, receipt status, campaign, etc.).

## Fee-for-Service

**When to use:** Payment for goods or services rendered (event ticket, publication, membership benefit) with zero charitable / tax-deductible portion.

**Records to create:** same as Outright — `GiftTransaction` plus optional `GiftTransactionDesignation` and `GiftSoftCredit`.

### `GiftTransaction` fields — differences from Outright

| Field | Value |
|---|---|
| [`FQS_Gift_Transaction_Category__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Gift_Transaction_Category__c.field-meta.xml) | `Other` |
| [`FQS_In_Kind__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_In_Kind__c.field-meta.xml) | `false` |
| `TaxReceiptStatus` | `Don't Send` (there is no charitable portion to receipt). |
| **`OriginalAmount`** | Full payment amount, e.g. `250.00` for a $250 event ticket. |
| **`CurrentAmount`** | Do NOT set — platform sets equal to `OriginalAmount`. |
| **`TaxDeductionAmount`** | `0.00` — Fee-for-Service is by definition non-charitable. |
| **`NonTaxDeductibleAmount`** | Do NOT set — platform derives, will equal `CurrentAmount`. |
| **`TransactionDate`** | Date the donor paid. |
| **`TransactionDueDate`** | Same rule as Outright — equal to `TransactionDate` for `Status = Paid`. |

All other fields follow the Outright pattern.

## Pledge Payment

**When to use:** Payment against a `GiftCommitment` the donor already has.

**Prerequisite:** an active `GiftCommitment` exists on the donor with `Status IN (Active, Failing, Lapsed, Paused)` and [`FQS_Gift_Commitment_Category__c`](../force-app/main/default/objects/GiftCommitment/fields/FQS_Gift_Commitment_Category__c.field-meta.xml) `IN (Pledged Gift, Recurring Gift)`.

**Records to create (in order):**

1. `GiftTransaction`
2. `GiftTransactionDesignation` (optional)
3. `GiftSoftCredit` (optional)

### `GiftTransaction` fields

| Field | Required? | Value / Guidance |
|---|---|---|
| `DonorId` | Required | Donor `Account.Id`. |
| `GiftCommitmentId` | Required | Id of the parent `GiftCommitment`. |
| [`FQS_Gift_Transaction_Category__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Gift_Transaction_Category__c.field-meta.xml) | Required | `Pledge Payment` |
| [`FQS_Recurring__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Recurring__c.field-meta.xml) | Auto-derive | `true` when the parent commitment's `FQS_Gift_Commitment_Category__c = Recurring Gift`, else `false`. |
| `Status` | Required | Same rules as Outright — prefer `Pending` for entry, let reconciliation transition to `Paid`. |
| **`OriginalAmount`** | Required | Per-installment amount for this payment. Prefill from the parent `GiftCommitmentSchedule.TransactionAmount` when a schedule exists — that's the amount the schedule expects. E.g. `500.00` for a $2,000 pledge paid quarterly. |
| **`CurrentAmount`** | Do NOT set | Platform sets equal to `OriginalAmount`. |
| **`TaxDeductionAmount`** | Recommended | Equal to `OriginalAmount` for a cash-equivalent installment. |
| **`NonTaxDeductibleAmount`** | Do NOT set | Platform-derived. |
| **`TransactionDate`** | Required | Date the donor made the payment. |
| **`TransactionDueDate`** | Required | Match the parent `GiftCommitmentSchedule` installment's due date if one exists; otherwise use `TransactionDate` for `Status = Paid` or the expected receipt date for `Status = Pending`. |
| `CampaignId` | Recommended | Default to the parent commitment's `CampaignId` if not overridden. |
| `PaymentMethod` | Required | e.g. `Credit Card`, `ACH`, `Check`. |
| `TaxReceiptStatus` | Recommended | `To Be Sent` |
| `GiftType` | Auto-derive | Same rule as Outright. |

### `GiftTransactionDesignation` — designation rules for Pledge Payments

The parent commitment's `FulfillmentType` drives whether/what designation to record on the payment:

- **Unconditional commitment** — no designation needs to be recorded on the payment; the commitment's `GiftDefaultDesignation` (if any) is the source of truth.
- **Conditional commitment** — record a `GiftTransactionDesignation` pointing at an `IsActive = true` `GiftDesignation` whose [`FQS_Restriction_Type__c`](../force-app/main/default/objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml) matches the commitment's existing `GiftDefaultDesignation.FQS_Restriction_Type__c`. Mismatched restrictions violate the pledge's intent.

Field values are the same as the Outright case: `Percent = 100`, `Amount = OriginalAmount`.

## New Pledge (Pledged Gift Commitment)

**When to use:** Recording a donor's commitment to give at a future date, without recording an inline payment.

**Records to create (in order):**

1. `GiftCommitment`
2. `GiftCommitmentSchedule` (one or more child rows — see "Platform contracts" for why this must follow, not precede, the commitment insert)
3. `GiftDefaultDesignation` (optional — one row per allocated designation)

### `GiftCommitment` fields

| Field | Required? | Value / Guidance |
|---|---|---|
| `DonorId` | Required | Donor `Account.Id`. |
| `Name` | Required | Donor-facing pledge name. Object has a formula default: *Donor + " - " + TransactionAmount + " " + TransactionPeriod*. |
| [`FQS_Gift_Commitment_Category__c`](../force-app/main/default/objects/GiftCommitment/fields/FQS_Gift_Commitment_Category__c.field-meta.xml) | Required | `Pledged Gift` (or `Recurring Gift` for a monthly/quarterly recurring). |
| `Status` | Required | `Active` for a new pledge. |
| **`ExpectedTotalCmtAmount`** | Required | Total amount the donor has committed to give over the life of the pledge, e.g. `12000.00` for a $12,000 five-year pledge. Drives donor-tier commitment formulas ([`FQS_Is_Entry_Commitment__c`](../force-app/main/default/objects/GiftCommitment/fields/FQS_Is_Entry_Commitment__c.field-meta.xml) etc.). |
| **`CurrentCommitmentAmount`** | Do NOT set | System-calculated rollup — sum of paid installment `GiftTransaction.CurrentAmount` values. |
| **`OutstandingCommitmentAmount`** | Do NOT set | System-calculated rollup — `ExpectedTotalCmtAmount − CurrentCommitmentAmount`. |
| **`EffectiveStartDate`** | Required | Date the pledge started / was made. |
| **`ExpectedEndDate`** | Recommended for `FixedLength` | Anticipated final-payment date, e.g. `EffectiveStartDate + 5 years`. Leave null for `OpenEnded` recurring commitments. |
| `FulfillmentType` | Required | `Unconditional` (default unrestricted use) or `Conditional` (donor restricted the funds). |
| `FormalCommitmentType` | Required | `Written` or `Verbal`. |
| `RecurrenceType` | Recommended | `FixedLength` for pledges with a defined end date; `OpenEnded` for open-ended recurring commitments. |
| `CampaignId` | Recommended | For pledge attribution. |
| `ScheduleType` | Do NOT set | Auto-managed. See "Platform contracts" — setting it on insert breaks any downstream Custom `GiftCommitmentSchedule` insert. |

### `GiftCommitmentSchedule` fields (create AFTER the commitment)

Insert one schedule child for the installment cadence. NPC populates `GiftCommitment.ScheduleType` from the first schedule inserted.

| Field | Value / Guidance |
|---|---|
| `GiftCommitmentId` | Id of the commitment created above. |
| `ScheduleType` | `Recurring` for a regular cadence (monthly/quarterly); `Custom` for a manually defined payment schedule. |
| `Type` | `CreateTransactions` — NPC auto-generates `GiftTransaction` installment rows on the cadence. Use `PauseTransactions` when installments are recorded manually or via an external system, to prevent NPC from generating duplicates. |
| `TransactionAmount` | Per-installment amount, e.g. `500.00` for a $12,000 pledge paid quarterly over 6 years (`ExpectedTotalCmtAmount / 24`). This is the amount NPC uses to prefill each auto-generated installment `GiftTransaction.OriginalAmount`. |
| `TransactionPeriod` | `Monthly`, `Quarterly`, `Yearly`, `Weekly`, `Daily`, or `Custom`. |
| `TransactionDay` | Day of month (1–30 or `LastDay`) or day of week when installments post. |
| `StartDate` | First installment date (usually equals `GiftCommitment.EffectiveStartDate`). |
| `EndDate` | Required for `FixedLength` commitments — usually equals `GiftCommitment.ExpectedEndDate`. |
| `PaymentMethod` | Expected payment method for auto-generated installments. |

Reference guidance for the four common pledge shapes:

| Pledge shape | `GiftCommitment.RecurrenceType` | `GiftCommitmentSchedule.Type` | Notes |
|---|---|---|---|
| Monthly / Quarterly, open-ended (recurring donor) | `OpenEnded` | `CreateTransactions` | No `EndDate` on the schedule. |
| Monthly / Quarterly, with an end date | `FixedLength` | `CreateTransactions` | Set `EndDate` on the schedule. |
| One-time payment recorded together with the pledge (backdated pledge + payment) | `FixedLength` | `PauseTransactions` | Prevents NPC from auto-generating a duplicate installment; record the actual payment as a separate `GiftTransaction` pointing at this commitment. |
| Specific set of custom payment dates | `FixedLength` | `Custom` | Insert one `GiftCommitmentSchedule` per scheduled payment date, or use one `Custom` schedule with the specific dates. |

### `GiftDefaultDesignation` fields (optional — allocates the pledge to a designation)

| Field | Value |
|---|---|
| `ParentRecordId` | Id of the `GiftCommitment`. |
| `GiftDesignationId` | Id of the target `GiftDesignation`. For Unconditional commitments, use the org's `IsActive = true AND IsDefault = true` designation. For Conditional, use a designation whose `FQS_Restriction_Type__c` matches the donor's restriction. |
| `AllocatedPercentage` | `100` for a single-designation allocation. Split across multiple rows for split allocations (must sum to 100). |
| [`FQS_Restriction_Type__c`](../force-app/main/default/objects/GiftDefaultDesignation/fields/FQS_Restriction_Type__c.field-meta.xml) | Do NOT set — read-only formula mirroring the parent `GiftDesignation`. |
| [`FQS_Parent_Type__c`](../force-app/main/default/objects/GiftDefaultDesignation/fields/FQS_Parent_Type__c.field-meta.xml) | Do NOT set — formula returning `GiftCommitment`, `Opportunity`, or `Campaign` from `ParentRecordId`. |

**Note:** if `FulfillmentType = Unconditional` and no explicit designation allocation is needed, skip the `GiftDefaultDesignation` entirely — Unconditional means "no restriction; use org default."

## Optional add-ons

Applicable to gift-transaction paths (Outright, In-Kind, Fee-for-Service, Pledge Payment). Not applicable to the New Pledge path — soft credits attach to `GiftTransaction`, not `GiftCommitment`.

### Soft Credits — `GiftSoftCredit`

Recognize a related Account for a gift they didn't legally give (household member, matching employer, solicitor, tribute honoree) — or recognize the donor themselves for the FMV of an in-kind gift (see [In-Kind Gift](#in-kind-gift)).

**Related-Account discovery pattern:** walk `Account → AccountContactRelation` and `Account → Contacts → ContactContactRelation` to find eligible soft-credit recipient Accounts.

| Field | Value |
|---|---|
| `GiftTransactionId` | Id of the `GiftTransaction`. |
| `RecipientId` | `Account.Id` of the soft-credit recipient. For in-kind self-recognition, same as `GiftTransaction.DonorId`. |
| `Role` | `Soft Credit` (or a more specific role like `Solicitor`, `Household Member`, `Matched Donor`, `Honoree`, `In-Kind Recognition`). |
| `PartialAmount` | Full credit: equal to `GiftTransaction.OriginalAmount`. Partial credit: leave null and populate `PartialPercent`. **In-Kind Recognition:** equal to `FQS_InKind_Fair_Market_Value__c` on the parent transaction. |
| `SoftCreditAmount` | Full credit: equal to `OriginalAmount`. **In-Kind Recognition:** equal to FMV. |
| `PartialPercent` | Partial credit only: `0 < value ≤ 100`. |

### Designations — `GiftTransactionDesignation` (transactions) / `GiftDefaultDesignation` (commitments)

**Restriction Type ([`GiftDesignation.FQS_Restriction_Type__c`](../force-app/main/default/objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml))** — FASB ASU 2016-14 net-asset classes:

- **Without Donor Restriction** — usable for any program at any time.
- **With Donor Restriction — Purpose** — must be spent on a specific program or use.
- **With Donor Restriction — Time** — released only after a specified date or event.
- **With Donor Restriction — Permanent** — principal held indefinitely (endowment); only earnings are spendable.

**When to allocate:**
- Transaction paths → create a `GiftTransactionDesignation` for each allocation. For unrestricted gifts, point at the `IsDefault = true` designation. Sum of `Percent` across children should equal 100 (or `Amount` across children should equal `OriginalAmount`).
- New Pledge → create a `GiftDefaultDesignation` on the commitment; NPC uses it as the template for future installments' allocations.

**Campaign-provided defaults:** if the selected `Campaign` has a `GiftDefaultDesignation` child pointing at a specific `GiftDesignation`, you can honor that default automatically instead of prompting for a designation.

### Campaigns

Attach a `Campaign` for attribution by setting `CampaignId` on the `GiftTransaction` or `GiftCommitment`.

- To keep the household on the campaign for future filtering, also ensure a `CampaignMember` exists linking one of the donor's Contacts to the Campaign. `CampaignMember` requires a `ContactId`, so Org donors without associated Contacts cannot be tracked as members directly.
- If both `CampaignId` and `OutreachSourceCodeId` are populated on a `GiftTransaction`, `OutreachSourceCode.CampaignId` must equal `GiftTransaction.CampaignId`. Recommended pattern: pick the OSC first, then set `CampaignId` from the OSC's parent Campaign. See [`OutreachSourceCodeId`](../force-app/main/default/objects/GiftTransaction/fields/OutreachSourceCodeId.field-meta.xml).

### Tributes — `GiftTribute`

Honor or Memorial recognition for a `GiftTransaction`. Create one `GiftTribute` child per tribute. `TributeType` = `Honor` (celebrating a living recipient) or `Memorial` (in memory of someone who has passed). This is a post-create step; not automated by the single-donor entry path.

## Platform contracts

Hard rules that produce misleading errors or silent data loss when violated. Full reference: [docs/npc-automation-notes.md](./npc-automation-notes.md).

| Rule | What happens if you violate it |
|---|---|
| `GiftTransaction.TransactionDueDate` is required on every insert, even for `Status = Paid`. | `REQUIRED_FIELD_MISSING` on insert. |
| `GiftTransaction.CurrentAmount` is not writable. | `INVALID_FIELD_FOR_INSERT_UPDATE`. Set `OriginalAmount` instead; use `GiftRefund` for adjustments. |
| `GiftTransaction.NonTaxDeductibleAmount` is auto-calculated. | Writes are silently discarded. |
| `GiftTransaction.OutreachSourceCodeId` must belong to the same Campaign as `GiftTransaction.CampaignId`. | *"Select an Outreach Source Code that's part of this Campaign."* |
| Direct-writing `GiftTransaction.Status = 'Paid'` bypasses payment posting. | Works for seed/test but produces gifts that never went through payment reconciliation. Use `Pending` for production entry. |
| `GiftCommitment.ScheduleType` is auto-managed — do NOT set on insert. | Silently overridden to `Recurring`; a subsequent `Custom` `GiftCommitmentSchedule` insert fails with *"You can only create a custom schedule when the commitment schedule type is Custom."* Insert the commitment with no `ScheduleType`, then insert schedule child(ren). |
| `GiftCommitment.CurrentCommitmentAmount` and `OutstandingCommitmentAmount` are not writable. | Values silently discarded. |
| `GiftDefaultDesignation.FQS_Restriction_Type__c` and `GiftTransactionDesignation.FQS_Restriction_Type__c` are read-only formulas. | Writes are silently discarded or error, depending on context. |
| `GiftDesignation` cannot be deleted while `IsActive = true`. | *"You can't delete an active designation."* Deactivate first, then delete. |
| Person Account record type requires explicit profile access. | *"RecordType ID {id} is not available for user"* — assign the `PersonAccount` RT via Profile → Record Type Settings. |

## What's out of scope for single-donor entry

- **Batch entry / multi-gift ingest** — use the platform's Gift Entry Manager, Data Loader, or a bulk Apex path.
- **Refunds / adjustments** — insert a [`GiftRefund`](../force-app/main/default/objects/GiftRefund/) child, do not mutate `CurrentAmount` on the original `GiftTransaction`.
- **Grant Payment category** — [`FQS_Gift_Transaction_Category__c`](../force-app/main/default/objects/GiftTransaction/fields/FQS_Gift_Transaction_Category__c.field-meta.xml) supports `Grant Payment`, but that flow uses `Opportunity` (Grant record type) + `GiftCommitment` (`CommitmentType = 'Grant'`) as the source of truth. See [docs/npc-automation-notes.md § Opportunity](./npc-automation-notes.md).
- **Fee decomposition** — `GatewayTransactionFee`, `ProcessorTransactionFee`, `DonorCoverAmount` are populated by payment-processor integrations, not by manual entry paths.
- **Standalone `GiftTribute` entry** — tributes always attach to a `GiftTransaction`. There is no standalone tribute entry point in FQS.
