# FQS Record Naming Flows — Execution Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst`
**Handoff context:** This plan was drafted after finalizing naming conventions in the FQS seed generator (`FQSSeedGenerator.cls`). The seed produces the desired shape of Name on GC/GT/Opportunity; this plan ports that same shape to runtime record-triggered flows so **real user-created records** get the same treatment.

---

## Goal

Auto-maintain human-readable `Name` values on newly created `GiftCommitment`, `GiftTransaction`, and `Opportunity` records so list-view scanning stays consistent whether the record originated from the seed, the account launcher, or a user typing directly into the UI.

**Naming patterns to reproduce** (finalized during the seed conversation — see `force-app/main/default/classes/FQSSeedGenerator.cls`):

| Object / Kind | Pattern | Example |
|---|---|---|
| **GC — Recurring** (`RecurrenceType = 'OpenEnded'`) | `<Donor> - $<ExpectedTotalCmtAmount> Monthly` | `Amy Hill FQS #1 - $240 Monthly` |
| **GC — Pledged/Grant** (`RecurrenceType = 'FixedLength'`) | `<Donor> - $<ExpectedTotalCmtAmount> over N years` (N = `ExpectedEndDate.year() − EffectiveStartDate.year()`, min 1) | `James Wang FQS #2 - $9795 over 2 years` |
| **GT — Pledge Payment** (`FQS_Gift_Transaction_Category__c = 'Pledge Payment'`) | `<Donor> - $<OriginalAmount> due <TransactionDueDate>` | `Amy Hill FQS #1 - $240 due 2026-02-13` |
| **GT — One-time** (Outright / Grant Payment / Fee) | `<Donor> - $<OriginalAmount> on <TransactionDate>` | `Nathan White FQS #0 - $455 on 2026-01-03` |
| **GT — Corporate Match** (has non-null `MatchingEmployerTransactionId`) | `<Employer Donor> match - $<OriginalAmount> on <TransactionDate>` | `TechCorp Global FQS-CORP match - $500 on 2026-04-15` |
| **Opportunity** (all) | `<Account.Name> - $<Amount> close <CloseDate>` | `Marcus Allen FQS #6 - $725 close 2026-10-05` |

**Amount formatting rules** (see `FQSSeedGenerator.fmtAmt`):
- Integer if amount is whole (`$240`), 2-decimal if not (`$180.03`) — this reproduces cents when donor covered gateway fees.
- No thousands separators (deliberate — matches what the seed emits).

**Date formatting rules:**
- ISO `YYYY-MM-DD` throughout. Sortable in list views, unambiguous, matches Salesforce's `String.valueOf(Date)` output.

**Donor label rules** (see `FQSSeedGenerator.donorLabel`):
- `Account.Name` if set (Business Account, Household, Corp Employer)
- Else `FirstName + ' ' + LastName` (Person Account — Name field is a formula there)
- **CRITICAL:** the runtime flows need to look up the donor `Account` and, if Person Account, derive from `FirstName`/`LastName`. Referencing `Account.Name` directly on a Person Account returns the formula-composed value, which usually works too, but be aware that some orgs customize the PA Name formula.

---

## Opt-out surface (both required)

The concern driving opt-out design: **third-party fundraising tools** (e.g., Classy, iATS, Blackbaud connectors) may write GC/GT/Opportunity records whose Name field is meaningful *to that integration*. Overwriting those names would break their reconciliation logic.

**Two independent opt-outs — both need to be honored:**

### 1. User opt-out (Custom Permission)
- **Custom Permission API name:** `FQS_Skip_Record_Naming` (label: "FQS: Skip Record Naming")
- Assign via permission set (recommend adding to an existing PS or a new `FQS_Naming_Opt_Out` PS). Any user with this permission active bypasses the flow entirely for records they create/edit.
- Flow guard: `NOT($Permission.FQS_Skip_Record_Naming)` — if the running user has it, exit before touching `Name`.
- Rationale: integration users (e.g., an "iATS Integration" system user) get the permission; the flow does not rewrite records they created.

### 2. Record opt-out (checkbox per object)
- Field API name (same on all three objects): `FQS_Skip_Naming__c` — Checkbox, Default `false`, Description: "When true, FQS record-naming flows leave Name alone. Set by integrations that manage Name themselves."
- Add to: `GiftCommitment`, `GiftTransaction`, `Opportunity`.
- Flow guard: `!$Record.FQS_Skip_Naming__c` — record-level bypass.
- Rationale: a per-record escape hatch for one-off records or when an integration sets the flag on its writes.

Both guards must pass for the flow to proceed. This lets:
- **User has permission** → all their records skip.
- **Record has flag set** → that specific record skips, regardless of who created it.
- **Neither** → naming applies.

---

## Flow specifications

Three record-triggered flows — one per object. Each is `RecordAfterSave` on Create AND Update (Update needed so name stays fresh if `Amount` / dates change; opt-outs still respected). Same skeleton for all three:

```
Start (RecordAfterSave, Create + Update)
  ↓
Decision: Skip?
  Rule "Yes_Skip":
    ($Permission.FQS_Skip_Record_Naming = true)
    OR ($Record.FQS_Skip_Naming__c = true)
    → END
  Default:
    → Get_Donor_Account
  ↓
Get_Donor_Account (SOQL)
  From: GT.DonorId / GC.DonorId / Opp.AccountId
  Fields: Id, Name, FirstName, LastName, IsPersonAccount
  ↓
Assignment: Build donorLabel
  IF IsPersonAccount → FirstName + ' ' + LastName
  ELSE → Name
  ↓
Decision: Which pattern?
  (Only present in the GT flow — see below)
  ↓
Assignment: Compose newName
  ↓
Decision: Did Name change?
  IF $Record.Name = newName → END (no-op, avoids infinite update loop)
  ELSE → Update Record
  ↓
Update Record: Name = newName
```

**Per-flow specifics:**

### `FQS_Name_Gift_Commitment` (object: `GiftCommitment`)
- Pattern branches:
  - `RecurrenceType = 'OpenEnded'` → `<donor> - $<ExpectedTotalCmtAmount> Monthly`
  - `RecurrenceType = 'FixedLength'` (default for anything else) → `<donor> - $<ExpectedTotalCmtAmount> over N years`
- Compute N: `MAX(1, YEAR(ExpectedEndDate) - YEAR(EffectiveStartDate))`. If `ExpectedEndDate` is null, fall back to `over 1 year`.
- Amount formatter: use a subflow / formula that returns integer form if `MOD(amount, 1) = 0`, else `TEXT(amount)` with 2-decimal formatting.

### `FQS_Name_Gift_Transaction` (object: `GiftTransaction`)
- Pattern branches:
  - `MatchingEmployerTransactionId != null` → corp match variant: `<donor> match - $<OriginalAmount> on <TransactionDate>`
  - `FQS_Gift_Transaction_Category__c = 'Pledge Payment'` → `<donor> - $<OriginalAmount> due <TransactionDueDate>`
  - Everything else (Outright, Grant Payment, Fee/Payment, In-Kind, corp intermediary) → `<donor> - $<OriginalAmount> on <TransactionDate>`
- Donor lookup uses `$Record.DonorId`. For corp match rows, DonorId is the employer Account — the donor-label rule still applies (Name field, since corp accounts aren't Person Accounts).

### `FQS_Name_Opportunity` (object: `Opportunity`)
- Single pattern: `<account label> - $<Amount> close <CloseDate>`
- Donor lookup: `$Record.AccountId`.

---

## Amount formatting in flow

Apex has `fmtAmt()` (integer vs 2-decimal); Flow doesn't have a clean equivalent. Two options:

**Option A (recommended): shared invocable Apex method.**
```apex
public class FQSNameFormatter {
    @InvocableMethod(label='FQS Format Amount' description='$1234 for whole, $1234.56 otherwise')
    public static List<String> format(List<Decimal> amounts) {
        List<String> out = new List<String>();
        for (Decimal a : amounts) {
            if (a == null) { out.add('$0'); continue; }
            out.add((a == a.round()) ? '$' + a.longValue() : '$' + a.setScale(2));
        }
        return out;
    }
}
```
This keeps the seed's `fmtAmt` behavior identical to the flows' output. Bonus: if the format ever changes, one place to update.

**Option B: Flow formula.**
```
IF(MOD(originalAmount, 1) = 0,
   '$' + TEXT(FLOOR(originalAmount)),
   '$' + TEXT(originalAmount))
```
Simpler, no Apex, but Flow's `TEXT(Number)` may produce trailing zeros (`180.30` not `180.3`). Test on the target org before choosing.

Consider extracting `FQSSeedGenerator.fmtAmt` into `FQSNameFormatter` and having both the seed generator and the invocable call the same static method — single source of truth.

---

## Date formatting in flow

Salesforce Flow: `TEXT(dateField)` returns `YYYY-MM-DD` already, so no conversion needed. The seed uses `String.valueOf(Date)` which produces the same format.

---

## Ordering & recursion safety

- **RecordAfterSave** required because `Name` write is the flow's purpose; RecordBeforeSave doesn't allow you to write to the triggering record's fields via `Update Record`. Use `Update Record` element referencing `$Record.Id`.
- **Infinite-loop guard:** flow only writes if new name differs from current name. Salesforce still counts the recursive update in the governor budget — verify with a bulk 200-record insert that the flow doesn't tip DML limits.
- **Order-of-execution:** these flows should run *after* other business logic that sets `Amount`, `TransactionDate`, `DonorId`, etc. RecordAfterSave (Flow Builder equivalent) fires after workflows and before entity-level rollup summaries — that's the right window.

---

## Metadata files to create

Under `force-app/main/default/`:

**Custom permission** (1 file):
- `customPermissions/FQS_Skip_Record_Naming.customPermission-meta.xml`

**Custom fields** (3 files — same shape, different objects):
- `objects/GiftCommitment/fields/FQS_Skip_Naming__c.field-meta.xml`
- `objects/GiftTransaction/fields/FQS_Skip_Naming__c.field-meta.xml`
- `objects/Opportunity/fields/FQS_Skip_Naming__c.field-meta.xml`

Recommended field XML:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>FQS_Skip_Naming__c</fullName>
    <defaultValue>false</defaultValue>
    <description>When true, FQS record-naming flows leave Name alone. Set by integrations that manage Name themselves.</description>
    <externalId>false</externalId>
    <inlineHelpText>Check to prevent FQS from auto-updating this record's Name. Third-party fundraising integrations should set this to preserve their own naming.</inlineHelpText>
    <label>FQS: Skip Naming</label>
    <trackHistory>false</trackHistory>
    <trackTrending>false</trackTrending>
    <type>Checkbox</type>
</CustomField>
```

**Invocable Apex (optional but recommended — Option A above):**
- `classes/FQSNameFormatter.cls` + `.cls-meta.xml`

**Flows** (3 files):
- `flows/FQS_Name_Gift_Commitment.flow-meta.xml`
- `flows/FQS_Name_Gift_Transaction.flow-meta.xml`
- `flows/FQS_Name_Opportunity.flow-meta.xml`

**Permission set** — grant the custom permission to relevant integration users:
- Either add to an existing PS (e.g., an integration-user PS) or create `permissionsets/FQS_Naming_Opt_Out.permissionset-meta.xml` with only that custom permission enabled. Document in README who should assign it.

---

## Refactor opportunity (nice-to-have, defer if scoping tight)

Extract the naming logic into `FQSNameFormatter.cls` as reusable static methods:
```apex
public static String gcName(GiftCommitment gc, String donorLabel) { ... }
public static String gtName(GiftTransaction gt, String donorLabel) { ... }
public static String oppName(Opportunity opp, String accountLabel) { ... }
public static String donorLabel(Account a) { ... }
public static String fmtAmt(Decimal amt) { ... }
```
Then:
- `FQSSeedGenerator` calls these instead of duplicating the concat.
- Each flow calls an `@InvocableMethod` that returns the composed name.
- Single source of truth for the naming rules; seed output and flow output can never drift.

This is optional but strongly recommended — otherwise a future naming tweak requires editing both the seed generator and three flows.

---

## Testing

1. **Deploy** field + custom permission + Apex + flows.
2. **Seed** small dataset. Verify seed's names haven't changed (they should be identical whether or not the flow runs — flow output must match seed output).
3. **UI test:**
   - Create a GT via the account launcher → confirm Name is auto-populated.
   - Create a GT with `FQS_Skip_Naming__c = true` → confirm Name is left alone.
   - Assign `FQS_Skip_Record_Naming` custom permission to a test user → create a record as that user → confirm skip.
4. **Update test:** edit an existing GT's `OriginalAmount` → confirm Name refreshes.
5. **Integration simulation:** insert a GT via anonymous Apex with `FQS_Skip_Naming__c = true` and `Name = 'iATS-9999'` → confirm Name stays `iATS-9999`.
6. **Bulk test:** insert 200 GTs at once → confirm flow doesn't tip DML limits and every Name is set.

---

## Anchor references (for the implementing agent)

- Seed generator naming logic: `force-app/main/default/classes/FQSSeedGenerator.cls`
  - `donorLabel(Account)` — line ~76
  - `fmtAmt(Decimal)` — line ~84
  - GC recurring Name — line ~326
  - GC pledged Name — line ~343
  - GC grant Name — line ~364
  - Opportunity Name — line ~449
  - GT Name (one-time / pledge payment branch) — line ~628 (search for `gtDateLabel`)
  - GT corp match Name — line ~792
- Existing record-triggered flow to use as a shape reference (Auto-save, Update, with decision + assignment + update-record pattern):
  - `force-app/main/default/flows/FQS_Campaign_Member_Status_On_Gift.flow-meta.xml`
  - `force-app/main/default/flows/FQS_Automatic_Rollup_Updates.flow-meta.xml`
- README to update once flows land: `scripts/apex/seed/README.md` (mention that naming flows are the runtime counterpart to the seed's built-in naming; no action required for seeded records since seed writes correct names directly).

---

## Out of scope

- Backfill of existing records with wrong names (write a one-off Apex script if needed after flows land — should be small; run outside of this task).
- Renaming when donor changes (e.g., someone edits `Account.Name` and the flow re-derives every GT/GC/Opp attached). Deferred — the flows only fire on the child record's create/update, not on parent Account edits. Add later if requested.
- List-view configuration changes (Name is the anchor column already; no config changes needed).

---

## Explicitly excluded from scope

**Campaign records are NOT covered by these auto-naming flows.** The three objects in scope are `GiftCommitment`, `GiftTransaction`, and `Opportunity` — nothing else.

**Rationale (write-once conflict):** `FQS_CampaignHierarchyBuilder.expandName` composes final Campaign names at insert time (placeholders resolved against the computed fiscal-year window — e.g. `Spring Appeal {yearLabel}` → `Spring Appeal FY26`). An AfterSave record-triggered flow on Campaign would overwrite that Apex-composed name with a different pattern shortly after insert, defeating the deliberate hierarchy-shaped naming and confusing downstream `FQS_Ultimate_Parent_Campaign__c` / `FQS_Hierarchy_Depth__c` reporting that already renders those labels on record pages and dashboards.

If a Campaign-side naming convention is ever needed, the correct home is inside `FQS_CampaignHierarchyBuilder` (extend `expandName` or add a helper) — not a separate flow racing the Apex insert. Reopening this decision requires updating both this plan and `.planning/fqs-campaign-hierarchy-setup-plan.md` together.
