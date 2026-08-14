# NPC Standard Field — Help Text & Description Recommendations

**Purpose:** Proposed `<inlineHelpText>` (end-user tooltip) and `<description>` (admin/dev metadata) overrides for standard Nonprofit Cloud (NPC) fields used in the FQS Quick Start.

**Audience split:**
- **Help Text** = Gift Officer / Development Officer during manual data entry. Short, plain-language, task-oriented.
- **Description** = Admin in Setup or developer reading the metadata XML. Captures auto-management behavior, cross-object validations, and other gotchas.

---

## Help Text (end-user tooltips)

### GiftTransaction

| Field | Proposed Help Text |
|---|---|
| `TransactionDueDate` | The date this gift is expected. For a one-time gift being recorded now, use the same date as Transaction Date. |
| `OriginalAmount` | The full gift amount as originally committed. For refunds or adjustments, don't change this — record a Gift Refund instead. |
| `CurrentAmount` | The remaining amount after any refunds or adjustments. Updates automatically. |
| `OutreachSourceCode` | The appeal, event, or channel that generated this gift. Must belong to the Campaign selected on this record. |
| `Status` | Where this gift is in the payment cycle. Choose Pending for gifts you've recorded financially but not yet received, Paid once the payment is in hand. |

### GiftCommitment

| Field | Proposed Help Text |
|---|---|
| `CommitmentType` | Recurring for ongoing gifts (monthly sustainer, quarterly pledge). Pledge for a total dollar commitment paid over time. Grant for foundation awards. |

### GiftCommitmentSchedule

| Field | Proposed Help Text |
|---|---|
| `InstallmentFrequency` | How often the donor pays toward this commitment. Choose Monthly, Quarterly, Annually, or Custom for irregular schedules. |

### GiftDesignation

| Field | Proposed Help Text |
|---|---|
| `RestrictionType` | Unrestricted funds can be used for any purpose at any time. Temporarily Restricted funds must be used for the purpose the donor specified until the restriction is met. Permanently Restricted funds (endowments) hold the principal indefinitely. |
| `IsActive` | Uncheck to retire this designation. Retired designations stay on historical gifts but won't appear when adding new gifts. |

### GiftSoftCredit

| Field | Proposed Help Text |
|---|---|
| `Role` | Why this person or organization gets credit for a gift they didn't legally give — e.g., "Solicitor", "Spouse", "Household Member", "Matching Employer". |

### GiftTribute

| Field | Proposed Help Text |
|---|---|
| `TributeType` | Select 'In Honor Of' for living recipients (birthdays, milestones) or 'In Memory Of' when the gift memorializes someone who has passed. |

### Opportunity

Record type distinctions belong on the RecordType metadata itself (`<description>` element in the `.recordType-meta.xml`), not on the `RecordTypeId` field help text. See the Grant and Major_Gift record type files under `force-app/main/default/objects/Opportunity/recordTypes/` — those descriptions have been updated for an admin-writing-automation audience.

---

## Description (admin / developer metadata)

These belong in the field's `<description>` — they surface in Setup and in the metadata XML but don't clutter the end-user tooltip.

### GiftCommitment

**`ScheduleType`**
> Auto-managed. Do not set on insert — the system silently overrides your value to `Recurring`, which produces the misleading error "You can only create a custom schedule when the commitment schedule type is Custom." To build a custom-schedule commitment: insert the GiftCommitment with no ScheduleType, then insert one or more GiftCommitmentSchedule children — ScheduleType is populated from the first schedule inserted.

**`CurrentCommitmentAmount`** / **`OutstandingCommitmentAmount`**
> System-calculated rollup from related GiftTransactions and GiftCommitmentSchedule rows. Not writable via API or Apex — attempting to set is silently ignored.

### GiftTransaction

**`CurrentAmount`**
> System-managed. Equals `OriginalAmount` minus posted GiftRefunds and adjustments. Not writable — attempting to set returns `INVALID_FIELD_FOR_INSERT_UPDATE`. Set `OriginalAmount` instead.

**`TransactionDueDate`**
> Required on insert even for gifts already in `Paid` status. For outright gifts, set equal to `TransactionDate`. For pledge payments, this should match the parent GiftCommitmentSchedule row.

**`OutreachSourceCodeId`** (paired with **`CampaignId`**)
> When populated, the referenced OSC must belong to `CampaignId`, or insert fails with "Select an Outreach Source Code that's part of this Campaign." Recommended API pattern: pick the OSC first, then set `CampaignId` from `OutreachSourceCode.CampaignId`.

**`Status`**
> Not all statuses are reachable by direct write. `Paid` requires an associated payment or manual reconciliation flow. Setting `Status = 'Paid'` on insert works for seed/test data but bypasses normal payment posting — do not use for production ingest.

### OutreachSourceCode

**`UsageType`**
> When set to `Fundraising`, `CampaignId` is required (validation: "Choose a campaign when the Usage Type is Fundraising."). For non-fundraising usages, CampaignId is optional. Cannot switch a saved OSC from `Fundraising` to another usage without first clearing its GiftTransaction references.

### GiftDesignation

**`IsActive`**
> An active GiftDesignation cannot be deleted. To remove one: set `IsActive = false`, `update`, then `delete` — teardown scripts should always do this two-step. Deactivation does not affect existing GiftTransactionDesignation rows that reference it.

### GiftCommitmentSchedule

**`Type`**
> Defaults to `CreateTransactions` on insert if omitted. `CreateTransactions` causes NPC's scheduled Apex to auto-generate GiftTransactions for each unpaid installment. Override only for scenarios where transactions are posted by an external system.

**`ScheduleType`** (on the schedule, not the commitment)
> Determines how the parent GiftCommitment.ScheduleType is populated. Insert this child first — parent.ScheduleType propagates from here.

### Account (Person Account context)

**`RecordTypeId`**
> The `PersonAccount` record type requires profile-level Record Type Settings access even for admins in orgs where Person Accounts are enabled. If Apex inserts fail with "RecordType ID … is not available for user", enable it via **Setup → Profiles → [profile] → Record Type Settings** before retrying.

### Opportunity

**`RecordTypeId`** (Grant, Major_Gift)
> NPC ships `Grant` and `Major_Gift` record types that are not assigned to standard profiles by default. Assign via **Setup → Profiles → [profile] → Record Type Settings** before insert or DML fails with "RecordType ID … is not available for user".

### DonorGiftSummary (object-level)

> Auto-created and maintained by NPC triggers on GiftTransaction/GiftCommitment insert. Manual deletion is often blocked by platform-managed sharing rules. Do not include in teardown scripts as a required step — wrap deletes in try/catch.

---

## Meta-observations for the NPC docs team

Two patterns keep repeating across NPC's shipped help text and are worth surfacing as feedback:

1. **Auto-managed fields with terse help text.** "Set automatically when …" tells you it's auto-set but doesn't tell you what happens if you write it anyway. In every case documented above, writing produced a misleading downstream error rather than a clean rejection. Help/description text should say **"Do not set on insert"** explicitly.

2. **Cross-object validations phrased as if the wrong field is at fault.** The OSC/Campaign rule blames the GiftTransaction insert when the real fix is on OutreachSourceCode's parent Campaign. Documenting the rule on both sides of a cross-object validation reduces the debugging surface.

---

## Delivery options for FQS

Given the audience split — end-user tooltips for Gift Officers vs. automation-authoring notes for admins — ship each section differently:

### Help Text (end-user tooltips)
Ship as `<inlineHelpText>` metadata overrides on the standard-field `.field-meta.xml` files under `force-app/main/default/objects/<Object>/fields/`. This surfaces the tooltip in every place the field appears (record page, list view inline edit, related-list quick create). Source-controlled and survives NPC package upgrades.

### Description (admin / automation-authoring notes)
The audience for the Description content is an admin writing a flow, validation rule, or Apex trigger — someone who will hit the auto-management and cross-object validation edge cases. Two viable homes:

1. **Selective `<description>` overrides** on the ~3 fields where the automation gotcha is the primary thing the admin needs to know: `GiftCommitment.ScheduleType`, `OutreachSourceCode.UsageType`, `GiftDesignation.IsActive`. These show in Setup > Object Manager > Field, which is where the admin lands when authoring automation.
2. **`docs/npc-automation-notes.md`** — a searchable reference for the remaining items. Easier to grep, safer against NPC metadata churn, and lets us include cross-cutting notes (e.g., PersonAccount RT profile access) that don't map cleanly to one field.

Recommendation: field-level `<description>` overrides for the three above; everything else moves to `docs/npc-automation-notes.md`. Do NOT bulk-override `<description>` across all listed fields — the metadata bloat and package-upgrade fragility aren't worth it.

### RecordType descriptions
Update the `<description>` element directly on each `.recordType-meta.xml` file — done for `Grant` and `Major_Gift` as part of this doc.

---

## Open questions for review

- Do we want to also cover the FQS custom fields (`FQS_Recurring__c`, `FQS_In_Kind__c`, `FQS_Matched__c`, `FQS_Gift_Transaction_Category__c`, `FQS_Gift_Commitment_Category__c`, `FQS_Campaign_Category__c`, `FQS_Restriction_Type__c`) in the same doc, or split them out?
- Any fields on this list where the current NPC-shipped help text is already good and we shouldn't override?
- Confirm the three fields nominated for `<description>` overrides (`GiftCommitment.ScheduleType`, `OutreachSourceCode.UsageType`, `GiftDesignation.IsActive`), or adjust the shortlist.
