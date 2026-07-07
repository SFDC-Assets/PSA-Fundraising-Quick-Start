# NPC Automation Notes

**Audience:** Admins and developers authoring flows, validation rules, Apex triggers, or bulk data operations against Nonprofit Cloud (NPC) objects in the FQS Quick Start.

**Not for:** End users doing manual data entry. For that audience, see the `<inlineHelpText>` on each field.

**Scope:** Cross-object validations, silently auto-managed fields, deletion rules, profile-access requirements, and other NPC behaviors that produce misleading errors when you don't know they're there.

---

## How to use this doc

- Search by object name when you're about to write automation against it.
- Every entry documents an observed behavior, not a hypothetical one — either from the FQS seed-data build, an NPC doc, or the field metadata inline help.
- When an entry has a ⚠ marker, the behavior has burned a developer already. Read the whole entry before writing the automation.

---

## GiftCommitment

### ⚠ `ScheduleType` is auto-managed on insert

Setting `ScheduleType` explicitly on `GiftCommitment` insert (e.g., `ScheduleType = 'Custom'`) is silently overridden to `Recurring`. Any downstream logic that then tries to attach a Custom `GiftCommitmentSchedule` fails with:

> "You can only create a custom schedule when the commitment schedule type is Custom."

The error blames the schedule insert, but the root cause is the commitment insert.

**Correct pattern:**
1. Insert the `GiftCommitment` with NO `ScheduleType` value.
2. Insert one or more `GiftCommitmentSchedule` rows as children.
3. `GiftCommitment.ScheduleType` is populated automatically from the first schedule inserted.

**Where this bites:** anywhere you're mass-loading commitments — Apex seed scripts, Data Loader imports, integration middleware. The Salesforce UI flow builds the schedule first, so it never trips this.

Source: `GiftCommitment.ScheduleType` `<inlineHelpText>` in the shipped field metadata (`"Set automatically when a gift commitment schedule is created."`) — but the help text does not tell you what happens if you set it anyway.

### `CurrentCommitmentAmount` / `OutstandingCommitmentAmount` are not writable

Both are system-calculated rollups from related `GiftTransaction` and `GiftCommitmentSchedule` rows. Attempting to set either in Apex or via the API is silently ignored — no error is raised, but the value is discarded and the rollup recalculates from scratch.

**Implication for automation:** never store computed commitment amounts on `GiftCommitment` from a flow or trigger. Push them onto the underlying transactions/schedules and let the rollup fire.

---

## GiftTransaction

### `CurrentAmount` is not writable

System-managed. Equals `OriginalAmount` minus posted `GiftRefund` and adjustment amounts. Attempting to set it in Apex or the API returns:

> `INVALID_FIELD_FOR_INSERT_UPDATE: Unable to create/update fields: CurrentAmount`

**Correct pattern:** set `OriginalAmount` on insert. For refunds/adjustments, insert a `GiftRefund` child rather than mutating `CurrentAmount` directly.

### `TransactionDueDate` is required on insert

Even for gifts already in `Paid` status. Omitting it returns a `REQUIRED_FIELD_MISSING` error.

**Correct pattern:**
- Outright gifts: `TransactionDueDate = TransactionDate`.
- Pledge payments: match the parent `GiftCommitmentSchedule` row's due date.
- Grant payouts: `TransactionDueDate` = expected payout date from the schedule.

### ⚠ `OutreachSourceCodeId` must belong to the same `CampaignId`

If both fields are populated, the OSC's parent Campaign must equal the `CampaignId` on the transaction, or insert fails with:

> "Select an Outreach Source Code that's part of this Campaign."

The error surfaces on `GiftTransaction`, but the fix may be to reassign the OSC to the intended Campaign (or vice versa).

**Correct pattern for bulk creates:**
1. Pick the OSC first based on your business logic (channel, appeal, source).
2. Read `OutreachSourceCode.CampaignId` from the OSC.
3. Set `GiftTransaction.CampaignId` to that value.

**Where this bites:** any flow or Apex that picks Campaign and OSC independently. Screen flows with lookup filters usually avoid it because the OSC picker filters by selected Campaign — but bare API calls have no such guard.

### `Status` transitions are constrained

Not every value in the picklist is reachable by direct write. In particular, `Paid` on a real gift typically requires an associated payment reconciliation or NPC flow. Direct-writing `Status = 'Paid'` on insert works for seed and test data but bypasses normal payment posting — do not use this pattern in production ingest.

---

## OutreachSourceCode

### ⚠ `UsageType = 'Fundraising'` requires `CampaignId`

Validation rule fires on insert or update:

> "Choose a campaign when the Usage Type is Fundraising."

For non-Fundraising usages (e.g., `Marketing`, `Outreach`), `CampaignId` is optional.

**Implication for automation:** any automation that creates OSCs (from an inbound integration, a batch appeal seeder, etc.) must select or create the Campaign first. Cannot flip an existing OSC from `Fundraising` to another usage without first clearing all `GiftTransaction` references that depend on it.

---

## GiftDesignation

### ⚠ Cannot be deleted while `IsActive = true`

Attempting to delete an active `GiftDesignation` raises:

> "You can't delete an active designation."

**Correct teardown pattern:**
```apex
List<GiftDesignation> gds = [SELECT Id, IsActive FROM GiftDesignation WHERE Name LIKE 'FQS %'];
for (GiftDesignation gd : gds) { if (gd.IsActive) gd.IsActive = false; }
update gds;
delete gds;
```

Deactivation does not affect existing `GiftTransactionDesignation` rows that reference the designation. Historical allocations remain intact — only new gifts can no longer select the retired designation from the picker.

---

## GiftCommitmentSchedule

### `Type` defaults to `CreateTransactions`

Omitting the field on insert produces the same result as `Type = 'CreateTransactions'`. This causes NPC's scheduled Apex to auto-generate `GiftTransaction` rows for each unpaid installment on the schedule's cadence.

**Override only when:** transactions for this commitment are posted by an external system (integration, hand-loaded imports) and you need NPC to leave the schedule alone.

### `ScheduleType` on the schedule propagates to the parent commitment

Set `ScheduleType` on the *schedule*, not the *commitment*. The commitment's `ScheduleType` is populated from the first inserted schedule's value. See `GiftCommitment.ScheduleType` above for the failure mode when this is inverted.

---

## Account (Person Account context)

### `PersonAccount` record type requires explicit profile access

Even in orgs where Person Accounts are enabled, admins need the `PersonAccount` record type assigned via **Setup → Profiles → [profile] → Record Type Settings → Account**.

Without it, Apex or API insert fails with:

> "RecordType ID {id} is not available for user"

The error text points at the record type, but the fix is at the profile level, not the record type level.

**Implication for automation:** flows and Apex that create Person Accounts must run as a user whose profile has the RT assigned, or use `System.runAs`/`without sharing` context deliberately. Assignment is deployment metadata (`.profile-meta.xml`) — capture it in source control if the profile is not managed elsewhere.

---

## Opportunity

### `Grant` and `Major_Gift` record types require explicit profile access

FQS ships both record types (see [Grant.recordType-meta.xml](../force-app/main/default/objects/Opportunity/recordTypes/Grant.recordType-meta.xml) and [Major_Gift.recordType-meta.xml](../force-app/main/default/objects/Opportunity/recordTypes/Major_Gift.recordType-meta.xml)), but neither is assigned to standard profiles by default. Assign via **Setup → Profiles → [profile] → Record Type Settings → Opportunity** before writing automation that instantiates them.

Failure mode is identical to the Person Account case above.

**Stage-based automation signals:**
- **Grant → Awarded**: create the corresponding `GiftCommitment` (`CommitmentType = 'Grant'`). Do NOT create on `Proposal Submitted` — declines at `Under Review` are common.
- **Major Gift → Closed Won**: create the `GiftCommitment` (`CommitmentType = 'Pledge'` or `'Recurring'`). `Pledged` is a soft indicator only and may still revert to `Cultivation` — treat as verbal intent, not a booked commitment.

---

## DonorGiftSummary

### Trigger-managed; do not include in required teardown paths

Auto-created and maintained by NPC triggers on `GiftTransaction`/`GiftCommitment` insert. Manual deletion is often blocked by platform-managed sharing rules and will raise on some orgs but not others.

**Correct pattern in teardown scripts:**
```apex
try { delete dgss; }
catch (Exception e) { System.debug('DonorGiftSummary delete skipped: ' + e.getMessage()); }
```

Deleting the underlying Account cascades the summary anyway, so the try/catch is a belt-and-braces measure for interim cleanups.

---

## Cross-cutting: teardown ordering

If you're wiping FQS-seeded data, deletion order matters — leaf children first, roots last:

1. `GiftRefund`
2. `GiftTransactionDesignation`
3. `GiftSoftCredit`
4. `GiftTribute`
5. `GiftTransaction`
6. `GiftCommitmentSchedule`
7. `GiftCommitment`
8. `Opportunity`
9. `PaymentInstrument`
10. `DonorGiftSummary` (try/catch)
11. `Account` (donors)
12. `OutreachSourceCode`
13. `GiftDesignation` (deactivate first — see above)
14. `Campaign`

The working implementation is [scripts/apex/seed/fqs-seed-teardown.apex](../scripts/apex/seed/fqs-seed-teardown.apex) and is idempotent.

---

## Cross-cutting: filterability gotchas on standard fields

Not all Description fields are indexed/filterable in SOQL:

| Object | Field | Filterable? |
|---|---|---|
| `Account` | `Description` | No |
| `Campaign` | `Description` | No |
| `Opportunity` | `Description` | Yes |

**Implication:** if you're tagging seeded/test records for later cleanup, use `Name` (which is filterable) rather than `Description`. FQS uses the marker convention `'FQS #<index>'` in the Account `Name` field for donors and `'FQS <label>'` for foundation records (Campaign, GiftDesignation, OutreachSourceCode).

---

## Two recurring NPC documentation patterns worth flagging upstream

1. **Auto-managed fields with terse help text.** "Set automatically when …" tells you the field is auto-set but does not tell you what happens if you write it anyway. In every case documented above, writing produced a misleading downstream error rather than a clean rejection. NPC help/description text should say **"Do not set on insert"** explicitly.
2. **Cross-object validations phrased as if the wrong field is at fault.** The OSC/Campaign rule blames the `GiftTransaction` insert when the fix may live on `OutreachSourceCode.CampaignId`. Documenting the rule on both sides of a cross-object validation reduces the debugging surface.

---

## See also

- [scripts/apex/seed/README.md](../scripts/apex/seed/README.md) — FQS seed-data scripts (the harness that surfaced most of these).
- [docs/npc-help-text-recommendations.md](./npc-help-text-recommendations.md) — the end-user-facing tooltip counterpart to this doc.
- [.claude/fqs-session-context.md](../.claude/fqs-session-context.md) — session context for AI-assisted work.
