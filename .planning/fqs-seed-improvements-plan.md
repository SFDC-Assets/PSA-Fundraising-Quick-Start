# FQS Seed Script Improvements — Execution Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Purpose of seed scripts:** Testing & development (primary), demos (secondary)
**Target org:** `FundFirst` (Nonprofit Cloud — Fundraising)

---

## User-confirmed design decisions

1. **Campaign hierarchy: Three-level** (Master → Categories → Leaf)
   - Master: `FQS Master Fundraising`
   - Categories: `FQS Annual Giving`, `FQS Events`, `FQS Major Gifts`, `FQS Grants`, `FQS Corporate & Community`
   - Leaves: keep the 12 existing leaf campaigns, parent them under the correct category
   - Wire up via `Campaign.ParentId`
2. **Corporate matching scenarios: all four** (see §4)
3. **External IDs: single `External_Id__c`** per seeded object — Text(64), External ID, Unique, Case-Sensitive
4. **Amounts: round to nearest $5**, then a subset carry realistic credit-card / processing fees so `OriginalAmount` becomes uneven when fees are applied
5. **Corporate employer accounts**: dedicated pool of ~15 accounts (naming: `FQS-CORP-01` etc.), separate from donor pyramid
6. **Bundle earlier bug fixes** into the same rewrite:
   - Pledge schedule denominator (divide by pledge years, not always 12)
   - `PaymentInstrument.ExpiryYear` uses `System.today().year()` base
   - `TransactionDueDate` = `TransactionDate + 30d` for non-Paid gifts
   - Stage ↔ CloseDate coupling on Opportunity

---

## 1. Metadata: External ID fields (13 files)

For each object below, create `force-app/main/default/objects/<Object>/fields/External_Id__c.field-meta.xml` with this content (adjust `<label>` if needed):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>External_Id__c</fullName>
    <caseSensitive>true</caseSensitive>
    <description>External identifier used by FQS seed scripts for idempotent upserts and teardown. Pattern: FQS-<OBJ>-<idx>[-<subidx>].</description>
    <externalId>true</externalId>
    <label>FQS External ID</label>
    <length>64</length>
    <required>false</required>
    <trackHistory>false</trackHistory>
    <type>Text</type>
    <unique>true</unique>
</CustomField>
```

**Objects that need this field:**

| # | Object |
|---|---|
| 1 | Account |
| 2 | Campaign |
| 3 | GiftDesignation |
| 4 | OutreachSourceCode |
| 5 | GiftCommitment |
| 6 | GiftCommitmentSchedule |
| 7 | GiftTransaction |
| 8 | GiftTransactionDesignation |
| 9 | GiftRefund |
| 10 | GiftSoftCredit |
| 11 | GiftTribute |
| 12 | PaymentInstrument |
| 13 | Opportunity |

**Naming convention for External ID values:**

| Object | Pattern | Example |
|---|---|---|
| Campaign (Master) | `FQS-CMP-MASTER` | `FQS-CMP-MASTER` |
| Campaign (Category) | `FQS-CMP-CAT-<slug>` | `FQS-CMP-CAT-ANNUAL` |
| Campaign (Leaf) | `FQS-CMP-<slug>` | `FQS-CMP-ANNUAL-2026` |
| GiftDesignation | `FQS-GD-<slug>` | `FQS-GD-GENERAL-OPERATING` |
| OutreachSourceCode | `FQS-OSC-<source-code>` | `FQS-OSC-EM-AA-Q1` |
| Account (Donor) | `FQS-ACC-<globalIdx>` | `FQS-ACC-42` |
| Account (Corporate Employer) | `FQS-ACC-CORP-<idx>` | `FQS-ACC-CORP-07` |
| GiftCommitment | `FQS-GC-<globalIdx>-<kind>` | `FQS-GC-42-pledged` |
| GiftCommitmentSchedule | `FQS-GCS-<globalIdx>-<kind>` | `FQS-GCS-42-pledged` |
| PaymentInstrument | `FQS-PI-<globalIdx>` | `FQS-PI-42` |
| Opportunity | `FQS-OPP-<globalIdx>` | `FQS-OPP-42` |
| GiftTransaction (donor) | `FQS-GT-<globalIdx>-<g>` | `FQS-GT-42-3` |
| GiftTransaction (corporate match) | `FQS-GT-CORP-<matchIdx>` | `FQS-GT-CORP-108` |
| GiftTransactionDesignation | `FQS-GTD-<gt-external-id>-<didx>` | `FQS-GTD-FQS-GT-42-3-0` |
| GiftRefund | `FQS-GR-<gt-external-id>` | `FQS-GR-FQS-GT-42-3` |
| GiftSoftCredit | `FQS-GSC-<gt-external-id>-<recipIdx>` | `FQS-GSC-FQS-GT-42-3-17` |
| GiftTribute | `FQS-GTR-<gt-external-id>` | `FQS-GTR-FQS-GT-42-3` |

**Deployment note:** After creating fields, deploy them first (`sf project deploy start --source-dir force-app/main/default/objects` with a targeted metadata filter) before running the rewritten seed scripts, since the scripts will reference the new field.

---

## 2. Rewrite `scripts/apex/seed/fqs-seed-foundation.apex`

### Section A — Campaign hierarchy (replaces existing campaign block)

Build in this order:
1. **Master parent** — one record: `FQS Master Fundraising`, `External_Id__c = FQS-CMP-MASTER`
2. **Category tier** (5 records, ParentId = Master.Id):
   - `FQS Annual Giving` → `FQS-CMP-CAT-ANNUAL` → holds `FQS_Campaign_Category__c = 'Annual Giving'`
   - `FQS Events` → `FQS-CMP-CAT-EVENTS` → `'Events'`
   - `FQS Major Gifts` → `FQS-CMP-CAT-MAJOR` → `'Major Gifts'`
   - `FQS Grants` → `FQS-CMP-CAT-GRANTS` → `'Grants'`
   - `FQS Corporate & Community` → `FQS-CMP-CAT-CORPCOMM` → `'Corporate Match'` (or leave category null)
3. **Leaf tier** (existing 12 + one new `FQS Planned Giving Legacy` for symmetry with Major Gifts category), each with `ParentId` set to its matching category:

| Leaf Campaign Name | External ID | Category (ParentId) |
|---|---|---|
| FQS Annual Fund 2026 | FQS-CMP-ANNUAL-2026 | FQS Annual Giving |
| FQS Annual Fund 2025 | FQS-CMP-ANNUAL-2025 | FQS Annual Giving |
| FQS Annual Fund 2024 | FQS-CMP-ANNUAL-2024 | FQS Annual Giving |
| FQS Spring Gala 2026 | FQS-CMP-GALA-2026 | FQS Events |
| FQS Fall Auction 2025 | FQS-CMP-AUCTION-2025 | FQS Events |
| FQS Major Gifts Initiative | FQS-CMP-MG-INIT | FQS Major Gifts |
| FQS Legacy Circle | FQS-CMP-LEGACY | FQS Major Gifts |
| FQS Foundation Grants 2026 | FQS-CMP-GRANTS-2026 | FQS Grants |
| FQS Corporate Matching Program | FQS-CMP-CORP-MATCH | FQS Corporate & Community |
| FQS In-Kind Donations Drive | FQS-CMP-INKIND | FQS Corporate & Community |
| FQS Capital Campaign 2026 | FQS-CMP-CAPITAL-2026 | FQS Corporate & Community |
| FQS General Fundraising | FQS-CMP-GENERAL | FQS Corporate & Community |

**Idempotency:** replace `Name`-based existence check with SOQL against `External_Id__c IN :expectedExtIds`. Use `Database.upsert(campaigns, Campaign.External_Id__c)` — cleaner than the current select-then-insert pattern.

### Section B — GiftDesignations (10 records) — add External IDs

Same 10 designations as today. Add `External_Id__c` per row:

| Name | External ID |
|---|---|
| FQS General Operating Fund | FQS-GD-GENERAL-OPERATING |
| FQS Community Programs | FQS-GD-COMMUNITY-PROGRAMS |
| FQS Education Initiative | FQS-GD-EDUCATION |
| FQS Youth Services | FQS-GD-YOUTH |
| FQS Emergency Relief Fund | FQS-GD-EMERGENCY |
| FQS 2026 Building Fund | FQS-GD-BUILDING-2026 |
| FQS 2027 Expansion Fund | FQS-GD-EXPANSION-2027 |
| FQS Endowment - Scholarships | FQS-GD-END-SCHOLAR |
| FQS Endowment - Operations | FQS-GD-END-OPS |
| FQS Named Legacy Endowment | FQS-GD-END-LEGACY |

Use `Database.upsert(...)` keyed on `External_Id__c`.

### Section C — OutreachSourceCodes (18 records) — add External IDs

External ID = `FQS-OSC-<SourceCode>` (SourceCode is already unique).

**Round-robin campaign assignment:** currently assigns leaf campaigns. Keep that, but preferentially match OSCs to their thematic leaf when obvious:
- `EM-GR-01` (Grant Solicit) → `FQS Foundation Grants 2026`
- `EM-YE-01` (Year End) → `FQS Annual Fund 2026`
- `DM-FALL-01` → `FQS Fall Auction 2025`

Otherwise round-robin.

Use `Database.upsert(...)` keyed on `External_Id__c`.

### Section D — Corporate Employer Accounts (NEW, 15 records)

New block at the end of foundation script — creates a fixed pool of employer accounts used for corporate matching gifts.

```apex
List<Map<String, String>> employers = new List<Map<String, String>>{
    {'name': 'TechCorp Global',       'domain': 'techcorp.demo',       'industry': 'Technology'},
    {'name': 'Meridian Bank',         'domain': 'meridianbank.demo',   'industry': 'Banking'},
    {'name': 'BlueSky Insurance',     'domain': 'bluesky.demo',        'industry': 'Insurance'},
    {'name': 'Northwind Energy',      'domain': 'northwind.demo',      'industry': 'Energy'},
    {'name': 'Cascade Manufacturing', 'domain': 'cascade.demo',        'industry': 'Manufacturing'},
    {'name': 'Vertex Analytics',      'domain': 'vertex.demo',         'industry': 'Technology'},
    {'name': 'Halcyon Health Systems','domain': 'halcyon.demo',        'industry': 'Healthcare'},
    {'name': 'Ironclad Legal',        'domain': 'ironclad.demo',       'industry': 'Legal Services'},
    {'name': 'Green Meadow Foods',    'domain': 'greenmeadow.demo',    'industry': 'Food & Beverage'},
    {'name': 'Aurora Media Group',    'domain': 'aurora.demo',         'industry': 'Media'},
    {'name': 'Summit Consulting',     'domain': 'summit.demo',         'industry': 'Professional Services'},
    {'name': 'Beacon Retail',         'domain': 'beacon.demo',         'industry': 'Retail'},
    {'name': 'Foundry Partners',      'domain': 'foundry.demo',        'industry': 'Financial Services'},
    {'name': 'Waypoint Logistics',    'domain': 'waypoint.demo',       'industry': 'Transportation'},
    {'name': 'Copperline Utilities',  'domain': 'copperline.demo',     'industry': 'Utilities'}
};
```

Each account:
- `Name` = employer name + ` FQS-CORP`
- `External_Id__c` = `FQS-ACC-CORP-01` through `FQS-ACC-CORP-15`
- `Type = 'Corporate Employer'` (verify picklist; fall back to `'Corporate'`)
- `Industry` from map
- `BillingCity/State` — synthetic realistic (Chicago/IL, Seattle/WA, etc.)
- `Website` = `https://<domain>`
- `Phone` = 555-01XX range
- `Description` = `'FQS Seed — corporate employer for matching gifts'`

Use `Database.upsert(...)`.

---

## 3. Rewrite the donor generator body

The generator is the ~280-line block currently duplicated across `fqs-seed-small.apex`, `fqs-seed-medium.apex`, and `fqs-seed-chunk.apex`. Rewrite once and paste into all three (keep the "Keep this in sync" comment convention for now — factoring into an Apex class is a separate future improvement).

### Section A — Config knobs (new, top-of-file)

Move all magic numbers to a config block at the top so devs can flip for fixture-mode testing:

```apex
Integer DONOR_COUNT = 10;
Integer BATCH_OFFSET = 0;

// --- Distribution knobs ---
Integer PYRAMID_ENTRY_PCT   = 70;   // Entry-level donor share
Integer PYRAMID_MID_PCT     = 25;   // Mid-level donor share (Major = remainder)
Integer PROB_INDIV_PCT      = 75;   // Individual vs Org for Entry/Mid
Integer PROB_MAJOR_ORG_PCT  = 40;   // Extra Org tilt for Major donors
Decimal PROB_RECURRING      = 0.35;
Decimal PROB_PLEDGED_MIDPLUS = 0.40;
Decimal PROB_GRANT_MAJORORG = 0.60;
Decimal PROB_LAPSED         = 0.15;
Decimal PROB_SOFT_CREDIT    = 0.15;
Decimal PROB_TRIBUTE        = 0.10;
Decimal PROB_REFUND         = 0.03;
Decimal PROB_INKIND         = 0.03;
Decimal PROB_EMPLOYER_MATCH_ELIGIBLE = 0.30;  // NEW — % of Individual donors who work at a seeded FQS-CORP employer
Integer GIFT_HISTORY_YEARS  = 3;

// --- Matching gift mix (of employer-match-eligible gifts) ---
Decimal MATCH_MIX_PLEDGE_MATCHED   = 0.30;  // employee gift is a pledge payment + corp match posted
Decimal MATCH_MIX_OUTRIGHT_MATCHED = 0.40;  // employee outright + corp match posted
Decimal MATCH_MIX_PENDING          = 0.15;  // employee flagged Matched, corp side not yet posted
Decimal MATCH_MIX_UNMATCHED        = 0.15;  // employer exists but employee never submitted; corp side absent
```

### Section B — Round-to-$5 helper + fee model

```apex
// Round a decimal to the nearest $5. Base amounts always end in ...0 or ...5.
Decimal roundTo5(Decimal amount) {
    return ((amount / 5).round(System.RoundingMode.HALF_UP)) * 5;
}

// Apply realistic credit-card / processing fees. Returns final OriginalAmount +
// separately-populated GatewayTransactionFee + ProcessorTransactionFee + DonorCoverAmount.
// The GT.OriginalAmount is what the donor actually gave; fees are deducted upstream,
// but DonorCoverAmount is the donor optionally covering fees (which un-rounds the total).
class GiftAmount {
    Decimal originalAmount;         // rounded to $5
    Decimal gatewayFee;             // 2.2% + $0.30 for CC, 0.8% for ACH, 0 for Check
    Decimal processorFee;           // 0.5% flat processor overhead
    Decimal donorCoverAmount;       // some % of donors "cover the fee" — this makes OriginalAmount NOT round to $5
    Decimal netAmount;              // what actually lands in the org's account
}

GiftAmount computeFees(Decimal baseAmountRoundedTo5, String paymentMethod, Boolean donorCoversFees) {
    GiftAmount ga = new GiftAmount();
    Decimal gatewayPct;
    Decimal gatewayFlat;
    if (paymentMethod == 'Credit Card') { gatewayPct = 0.022; gatewayFlat = 0.30; }
    else if (paymentMethod == 'ACH')    { gatewayPct = 0.008; gatewayFlat = 0.00; }
    else if (paymentMethod == 'PayPal') { gatewayPct = 0.029; gatewayFlat = 0.49; }
    else                                { gatewayPct = 0.000; gatewayFlat = 0.00; } // Check
    ga.gatewayFee   = (baseAmountRoundedTo5 * gatewayPct + gatewayFlat).setScale(2);
    ga.processorFee = (baseAmountRoundedTo5 * 0.005).setScale(2);
    if (donorCoversFees) {
        // Donor tacks the fees onto the total — OriginalAmount becomes uneven
        ga.donorCoverAmount = (ga.gatewayFee + ga.processorFee).setScale(2);
        ga.originalAmount   = (baseAmountRoundedTo5 + ga.donorCoverAmount).setScale(2);
    } else {
        ga.donorCoverAmount = 0;
        ga.originalAmount   = baseAmountRoundedTo5;
    }
    ga.netAmount = (ga.originalAmount - ga.gatewayFee - ga.processorFee).setScale(2);
    return ga;
}
```

**Apply everywhere a gift/pledge/schedule amount is generated:**
- Wrap `randRange(...)` results with `roundTo5(...)` — all commitment amounts, all gift base amounts
- For each gift, roll a `randBool(..., 0.35)` for "donor covers fees" (~35% of gifts)
- Set `GT.OriginalAmount = ga.originalAmount`, `GT.GatewayTransactionFee = ga.gatewayFee`, `GT.ProcessorTransactionFee = ga.processorFee`, `GT.DonorCoverAmount = ga.donorCoverAmount`
- Check-payment gifts always round to $5 exactly (no fees)

### Section C — Corporate matching-gift generation (NEW block, runs after main gift loop)

Runs after `newGifts` is inserted. Iterates the newly-created gifts and builds corporate-side matching transactions per the four scenarios.

**Eligibility gate:** individual donors (GiftType='Individual') where PRNG rolls `randBool(globalIdx, 600, PROB_EMPLOYER_MATCH_ELIGIBLE)` are "employed at a seeded corporate employer". Assign each such donor to one of the 15 corporate employers deterministically: `empIdx = Math.mod(prng(globalIdx, 601), 15)`.

**Per employer-eligible donor**, iterate their outright + pledge-payment gifts, and for each:

```apex
Integer scenarioRoll = Math.mod(prng(globalIdx, 602 + g), 100);
if (scenarioRoll < 30 && cat == 'Pledge Payment') {
    // Scenario 1: matched to a pledge payment
    // Employee gift: set FQS_Matched__c = true
    // Corp gift: insert new GT with:
    //   DonorId          = corporate employer Account.Id
    //   MatchingEmployerTransactionId = employee GT.Id
    //   OriginalAmount   = 50% or 100% of employee gift, rounded to $5
    //   TransactionDate  = employee GT.TransactionDate + randInt(15, 45) days
    //   PaymentMethod    = 'Check' (corporate matches typically ACH/Check)
    //   Status           = 'Paid'
    //   GiftType         = 'Organizational'
    //   CampaignId       = FQS Corporate Matching Program (leaf)
    //   FQS_Gift_Transaction_Category__c = 'Outright Gift'
    //   External_Id__c = FQS-GT-CORP-<runningIdx>
} else if (scenarioRoll < 70 && cat == 'Outright Gift') {
    // Scenario 2: matched to outright — same shape, different category
} else if (scenarioRoll < 85) {
    // Scenario 3: pending — flag employee gift Matched=true but don't create corp GT yet
    // FQS_Matched__c = true, MatchingEmployerTransactionId stays null
} else {
    // Scenario 4: unmatched but eligible — employee's employer is a seeded corp,
    // but neither Matched flag nor corp GT is created.
    // Optionally: set an Account-level FQS_Employer_Account__c lookup on the employee
    //             so reports can find "eligible but unclaimed" via that path.
    // Simpler alternative: skip — the seeded corp accounts already exist and can be
    // queried alongside employee giving history for "eligible but unclaimed" testing.
}
```

**Data-shape target for a 100-donor seed** (roughly):
- ~40 Individual donors flagged employer-match-eligible
- Of their ~120 gifts, ~30 scenario 1+2 corporate match GTs created
- ~10 scenario 3 pending (Matched=true, no corp GT)
- Remainder: employer exists in FQS-CORP pool but no linkage on the employee gift

### Section D — Bundled bug fixes

**Fix 1: Pledge schedule denominator**

Replace:
```apex
Decimal schedAmt = (kind == 'recurring') ? gc.ExpectedTotalCmtAmount
                                         : (gc.ExpectedTotalCmtAmount / 12).setScale(2);
```

With:
```apex
Decimal schedAmt;
if (kind == 'recurring') {
    // Recurring schedule amount = single-period amount (monthly)
    schedAmt = gc.ExpectedTotalCmtAmount;
} else {
    // Pledged/Grant: divide total by number of years the pledge covers
    Integer pledgeYears = (gc.ExpectedEndDate != null && gc.EffectiveStartDate != null)
        ? Math.max(1, gc.ExpectedEndDate.year() - gc.EffectiveStartDate.year())
        : 1;
    schedAmt = (gc.ExpectedTotalCmtAmount / pledgeYears).setScale(2);
    // Round to nearest $5
    schedAmt = roundTo5(schedAmt);
}
```

**Fix 2: `PaymentInstrument.ExpiryYear` base year**

Replace:
```apex
pi.ExpiryYear = String.valueOf(2026 + randInt(globalIdx, 64, 0, 5));
```

With:
```apex
pi.ExpiryYear = String.valueOf(System.today().year() + randInt(globalIdx, 64, 0, 5));
```

**Fix 3: `TransactionDueDate` for non-Paid gifts**

Replace:
```apex
TransactionDate=txnDate, TransactionDueDate=txnDate,
```

With:
```apex
TransactionDate = txnDate,
TransactionDueDate = (status == 'Paid') ? txnDate : txnDate.addDays(30),
```

**Fix 4: Opportunity Stage ↔ CloseDate coupling**

Replace independent stage + closeDate randomization with:
```apex
String stage = isGrant ? grantStages[Math.mod(prng(globalIdx, 51), grantStages.size())]
                       : majorStages[Math.mod(prng(globalIdx, 51), majorStages.size())];
Boolean isTerminalStage = (stage == 'Awarded' || stage == 'Closed Won' || stage == 'Closed Lost');
Integer daysOffset = isTerminalStage
    ? randInt(globalIdx, 53, -180, -1)     // closed in past
    : randInt(globalIdx, 53, 7, 365);      // open in future
Date closeDate = Date.today().addDays(daysOffset);
```

---

## 4. Rewrite `scripts/apex/seed/fqs-seed-teardown.apex`

Replace every `WHERE ...Name LIKE '%FQS #%'` (or `LIKE 'FQS %'`) clause with `WHERE External_Id__c LIKE 'FQS-%'`. Every seeded object now has this field, so deletion becomes:

```apex
// New teardown pattern
delete [SELECT Id FROM GiftRefund              WHERE External_Id__c LIKE 'FQS-GR-%'   LIMIT 50000];
delete [SELECT Id FROM GiftTransactionDesignation WHERE External_Id__c LIKE 'FQS-GTD-%' LIMIT 50000];
delete [SELECT Id FROM GiftSoftCredit          WHERE External_Id__c LIKE 'FQS-GSC-%'  LIMIT 50000];
delete [SELECT Id FROM GiftTribute             WHERE External_Id__c LIKE 'FQS-GTR-%'  LIMIT 50000];
delete [SELECT Id FROM GiftTransaction         WHERE External_Id__c LIKE 'FQS-GT-%'   LIMIT 50000];  // catches both FQS-GT-<idx>-<g> and FQS-GT-CORP-<idx>
delete [SELECT Id FROM GiftCommitmentSchedule  WHERE External_Id__c LIKE 'FQS-GCS-%'  LIMIT 50000];
delete [SELECT Id FROM GiftCommitment          WHERE External_Id__c LIKE 'FQS-GC-%'   LIMIT 50000];
delete [SELECT Id FROM Opportunity             WHERE External_Id__c LIKE 'FQS-OPP-%'  LIMIT 50000];
delete [SELECT Id FROM PaymentInstrument       WHERE External_Id__c LIKE 'FQS-PI-%'   LIMIT 50000];
delete [SELECT Id FROM DonorGiftSummary        WHERE Donor.External_Id__c LIKE 'FQS-ACC-%' LIMIT 50000];
delete [SELECT Id FROM Account                 WHERE External_Id__c LIKE 'FQS-ACC-%'  LIMIT 50000];  // catches donor AND FQS-ACC-CORP-
delete [SELECT Id FROM OutreachSourceCode      WHERE External_Id__c LIKE 'FQS-OSC-%'  LIMIT 50000];
// GiftDesignation still needs IsActive=false before delete
List<GiftDesignation> gds = [SELECT Id, IsActive FROM GiftDesignation WHERE External_Id__c LIKE 'FQS-GD-%' LIMIT 50000];
// deactivate + delete...
delete [SELECT Id FROM Campaign                WHERE External_Id__c LIKE 'FQS-CMP-%'  LIMIT 50000];
```

**Deletion order note:** Campaigns must delete last, but within Campaigns, leaves must be deleted before categories, before Master (`ParentId` FK). Handle by:
1. First pass: `delete [... WHERE External_Id__c LIKE 'FQS-CMP-%' AND ParentId != null]` (deletes leaves + categories)
2. Second pass: `delete [... WHERE External_Id__c = 'FQS-CMP-MASTER']`

OR: build a dependency-ordered list and delete leaves → categories → master in three explicit chunks.

---

## 5. README update (`scripts/apex/seed/README.md`)

Add sections:
- **Prerequisites**: after "Enable via Setup → Profiles → Record Type Settings", add "Deploy the `External_Id__c` fields first: `sf project deploy start --source-dir force-app/main/default/objects`"
- **Campaign hierarchy**: brief note that seed produces a 3-level tree, with a visualization
- **Corporate matching**: note the 15 FQS-CORP employers + the 4-scenario mix
- **Amount conventions**: "All base amounts round to nearest $5; ~35% of gifts have DonorCoverAmount which produces uneven OriginalAmount totals for realistic gateway reconciliation testing."
- **Query for eligible-but-unclaimed matches**:
    ```sql
    SELECT Id, Donor.Name, OriginalAmount
    FROM GiftTransaction
    WHERE GiftType = 'Individual'
      AND External_Id__c LIKE 'FQS-GT-%'
      AND External_Id__c NOT LIKE 'FQS-GT-CORP-%'
      AND FQS_Matched__c = false
      AND Id IN (SELECT MatchingEmployerTransactionId FROM GiftTransaction WHERE MatchingEmployerTransactionId != null)
    ```

---

## 6. Deployment / testing sequence

1. **Deploy metadata** (new fields):
   ```bash
   sf project deploy start --source-dir force-app/main/default/objects --target-org FundFirst
   ```
2. **Teardown any old FQS data** (using the OLD name-based teardown, one last time):
   ```bash
   sf apex run -f scripts/apex/seed/fqs-seed-teardown.apex --target-org FundFirst
   ```
   — Actually: since the new teardown uses External IDs which won't exist on old records, keep the old Name-based teardown alongside the new one temporarily, OR run `SELECT Id FROM Account WHERE Name LIKE '%FQS #%'` and delete manually before switching.
3. **Deploy the rewritten seed scripts + new teardown**: standard `sf apex run -f` per README.
4. **Verify counts** with the queries in the README.
5. **Optional**: write `fqs-seed-verify.apex` as a follow-up (not part of this plan).

---

## 7. Files modified/created

**Created (13):**
- `force-app/main/default/objects/Account/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/Campaign/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftDesignation/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/OutreachSourceCode/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftCommitment/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftCommitmentSchedule/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftTransaction/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftTransactionDesignation/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftRefund/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftSoftCredit/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftTribute/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/PaymentInstrument/fields/External_Id__c.field-meta.xml`
- `force-app/main/default/objects/Opportunity/fields/External_Id__c.field-meta.xml`

**Modified (5):**
- `scripts/apex/seed/fqs-seed-foundation.apex` — full rewrite for hierarchy + corp employers + upsert
- `scripts/apex/seed/fqs-seed-teardown.apex` — switch to External ID markers
- `scripts/apex/seed/fqs-seed-small.apex` — new generator body
- `scripts/apex/seed/fqs-seed-medium.apex` — new generator body (identical to small)
- `scripts/apex/seed/fqs-seed-chunk.apex` — new generator body (identical to small)
- `scripts/apex/seed/README.md` — document new behaviors

---

## 8. Out of scope (deferred)

- Extract generator to a proper Apex class (`FQSSeedGenerator.cls`) — big DX win, but a separate architectural change
- `fqs-seed-verify.apex` post-seed assertion script — mentioned in prior review, tracked separately
- `--dry-run` / `--resume-from` flags on `fqs-seed-large.sh`
- Multi-designation split gifts, partial soft credits, non-Active commitment status variance — coverage additions from prior review, tracked separately
- Add `Description`, address, phone, email, etc. to Account records — demo-visibility improvements, deprioritized per user memory

---

## 9. Assumptions to verify before execution

1. **`Campaign.FQS_Campaign_Category__c` picklist** currently expects values like `'Annual Giving'`, `'Events'`, etc. Verify the category tier campaigns don't fail validation with those values.
2. **`Account.Type` picklist** — verify `'Corporate Employer'` is a valid value; if not, fall back to `'Corporate'`.
3. **`GiftTransaction.MatchingEmployerTransactionId`** is a self-lookup (already confirmed from the field-meta). Ensure it accepts an Account-owned GT as the reference (i.e., the corp-side match points back to the employee GT, not the other way — verify direction with the FQS layout).
4. **`GiftTransaction.GatewayTransactionFee`, `ProcessorTransactionFee`, `DonorCoverAmount`** — confirmed present (from earlier ls output).
5. **Deployment order**: fields must land in the org before any Apex references them. This is standard, just calling it out.

---

## 10. Follow-up work found during execution (2026-07-07)

Items that surfaced while running the plan end-to-end on FundFirst. Each is testable and self-contained.

### 10.1 Rewrite teardown to loop under the 10K DML/tx cap
**Problem:** `fqs-seed-teardown.apex` uses `LIMIT 50000` per query but batches everything into one transaction. With ~89K FQS records in the org, it hits `System.LimitException: Too many DML rows: 10001` and fails without deleting anything.
**Fix:** Adopt the incremental pattern used in `/tmp/fqs-teardown-loop.apex` during the recovery run — cap each pass at 9,000 rows, then re-run until 0. Simplest packaging: a single Apex script that self-caps, plus a shell wrapper that loops until debug output reports 0 deletes.
**Priority:** high — the current teardown will silently fail on any large seeded org.

### 10.2 Chunk CPU-time budget failures at 300 donors
**Problem:** Roughly 1 chunk in 10 fails with `Apex CPU time limit exceeded` (10s cap). The chunk generator does per-gift fee-model math + corp-match scenario roll + designation assignment inside a tight loop; certain PRNG-determined mixes push CPU over.
**Fix options (ordered):**
  1. Precompute a small fee lookup keyed by `(paymentMethod, coversFees, baseBucket)` instead of calling `computeFees()` per gift.
  2. Drop chunk size to 250 donors (16% CPU headroom).
  3. Precompute `pickOne(...)` / `randInt(...)` results into arrays before the gift loop rather than re-invoking PRNG per gift.
**Priority:** medium — resumable, deterministic, so failed chunks can be reproduced and re-tried once fixed.

### 10.3 Extract generator to a proper Apex class (bumped from §8)
**Problem:** All three seed files are at 31.5K bytes after aggressive comment stripping. The anonymous-Apex hard cap is 32K. Any new feature (extra field population, a soft-credit variant, etc.) breaks all three files.
**Fix:** Create `FQSSeedGenerator.cls` with the shared body as a static method. Anonymous scripts shrink to ~20 lines: config knobs + `FQSSeedGenerator.seed(DONOR_COUNT, BATCH_OFFSET)`. Removes the "keep in sync across 3 files" burden entirely.
**Priority:** medium-high — deferred in §8, but now urgent because we're one feature away from a hard limit.
**Update (2026-07-09):** Confirmed urgent — adding the in-kind floor + item catalog + Description population forced stripping section-marker comments (`// ============ ACCOUNTS ============` etc.) to fit under 32K chars. The next feature (any field, any new category) will not fit. Extracting to `FQSSeedGenerator.cls` also restores commented section markers for readability.

### 10.4 Storage-aware chunk-count guidance in README
**Problem:** README currently says "large — takes ~15 min" without noting storage. On a Developer sandbox capped at 200 MB, 26 chunks (7,800 donors) fills storage and the remaining 8 chunks hit `STORAGE_LIMIT_EXCEEDED`.
**Fix:** Add a "Storage math" section to `scripts/apex/seed/README.md` — approximate MB per 1,000 donors (empirically ~25 MB based on this run), a table of donor count → estimated MB, and a recommendation to check `sf org list limits --target-org <org> | grep DataStorageMB` before large runs.
**Priority:** low — documentation, not code.

### 10.5 Recycle bin retention warning
**Problem:** After teardown + `Database.emptyRecycleBin()`, storage still counts deleted records for hours-to-days on Developer sandboxes (15-day archive retention). Running teardown then immediately re-seeding hits `STORAGE_LIMIT_EXCEEDED` even though live counts are zero.
**Fix:** Note in README that `DataStorageMB` may lag behind live record counts after mass deletion, and to expect a "second wipe" if seeding immediately after teardown.
**Priority:** low — documentation, discovered during recovery.

### 10.6 sf CLI path-caching bug workaround
**Problem:** During the FLS permset deploy, `sf project deploy start --source-dir <path>` cached a stale `/tmp/fqs-fls-deploy/...` reference in the CLI's in-memory source resolver and rejected all subsequent source-dir deploys with `UnsafeFilepathError`. Renaming the file didn't clear it; grepping `~/.sf`, `~/Library/Caches/sf`, and the project turned up nothing.
**Workaround (confirmed working):** Use MDAPI form: `sf project deploy start --metadata-dir <mdapi-format-dir>` with an explicit `package.xml`. Bypasses source resolution entirely.
**Fix:** File a bug on `salesforcecli/plugin-deploy-retrieve` with a repro. Not FQS code — capture it here so we don't rediscover it.
**Priority:** low — one-off workaround already documented.

### 10.7 (nice-to-have) `fqs-seed-verify.apex` post-seed assertion script
Bumped from §8 unchanged. Would assert counts, mix ratios, corp-match cardinality, and stage↔closeDate coupling after each run. Small script, high value for CI once seed scripts are used in test pipelines.

---

## 11. Campaign hierarchy expansion — aligning seed with the setup-flow framing (2026-07-10)

**Why this section exists:** the setup flow in [`.planning/fqs-campaign-hierarchy-setup-plan.md`](fqs-campaign-hierarchy-setup-plan.md) formalizes a three-level model — **rollup / strategy / ask** — and adds three organizing patterns (Seasonal, Giving Programs, Strategy) plus Foundation Giving as a first-class branch in every model. The current seed's campaign block predates that framing: it produces a `Master → 5 categories → 12 mixed rows` tree where the level-3 rows mix strategies (`FQS Annual Fund 2026`) and asks (`FQS In-Kind Donations Drive`) indiscriminately, and there's no dedicated Foundation Giving branch.

This section rewrites Section 2A of the foundation script so the seed:

1. **Exercises the same three-level shape** the setup flow produces (rollup / strategy / ask).
2. **Includes Foundation Giving** as a real branch under both `Annual` and `Grants` category buckets — the setup flow says it belongs everywhere, and reporting tests need at least one grant-style ask.
3. **Spans multiple fiscal years** so year-over-year reports and mid-year-backfill test cases have real data to hit.
4. **Uses the "asks" vocabulary** at level 3 — `Description` field prefixed `Ask:` — so anyone browsing the seeded org sees the mental model reinforced in the UI.
5. **Distributes gifts realistically across all three levels** — the existing seed's round-robin OSC-to-campaign assignment lands OSCs on the *category* tier which is wrong. All OSCs and all `GT.CampaignId` values should land on **level-3 ask campaigns only**, mirroring the "response data lives at level 3" rule from the setup flow.

### 11.1 New campaign taxonomy (replaces the current 1 + 5 + 12 spec)

The seed produces **1 rollup + 4 strategy campaigns + 15 ask campaigns spanning three fiscal years** (FY24, FY25, FY26) — 20 campaigns total. Naming uses the setup flow's terminology exactly.

**Level 1 — rollup (1 record):**

| Ext ID | Name | Category | Notes |
|---|---|---|---|
| `FQS-CMP-ROLLUP-FY26` | `FQS FY26 Fundraising` | `Fundraising Top Level Campaign` | Modeled on the Seasonal pattern; StartDate = FY26 start, EndDate = FY26 end (derived from `Organization.FiscalYearStartMonth` at seed time). |

*(Rationale: Seasonal is the most common starting model in FQS discovery calls, and one rollup makes the tree readable. The setup flow itself supports switching to Giving Programs; this seed intentionally does not create both to avoid an inconsistent shape.)*

**Level 2 — strategies (4 records, ParentId = the rollup):**

| Ext ID | Name | Category | Date rule |
|---|---|---|---|
| `FQS-CMP-STRAT-ANNUAL-FY26` | `FQS Annual Giving FY26` | `Annual Giving` | full FY26 window |
| `FQS-CMP-STRAT-EVENTS-FY26` | `FQS Events FY26` | `Events` | full FY26 window |
| `FQS-CMP-STRAT-MAJOR-FY26` | `FQS Major & Planned Giving FY26` | `Major Gifts` | full FY26 window |
| `FQS-CMP-STRAT-FOUND-FY26` | `FQS Foundation Giving FY26` | `Grants` | full FY26 window |

**Level 3 — asks (15 records — 5 for FY26, 5 for FY25, 5 for FY24 for YoY):**

Naming pattern: `FQS {Ask Description} {FY}`. Description on each: `Ask: <one-line summary of what went out>`.

| Ext ID | Name | ParentId (Strategy) | Date window | Category | Ask kind |
|---|---|---|---|---|---|
| `FQS-CMP-ASK-SPRING-EM-FY26` | `FQS Spring Appeal Email FY26` | `STRAT-ANNUAL-FY26` | Mar–May FY26 | `Annual Giving` | email drop |
| `FQS-CMP-ASK-SPRING-DM-FY26` | `FQS Spring Appeal Direct Mail FY26` | `STRAT-ANNUAL-FY26` | Mar–May FY26 | `Annual Giving` | mailing |
| `FQS-CMP-ASK-YEAREND-EM-FY26` | `FQS Year-End Email FY26` | `STRAT-ANNUAL-FY26` | Nov–Dec (FY26 = Nov 2025 – Dec 2025 for Jul FY start) | `Annual Giving` | email drop |
| `FQS-CMP-ASK-CELEB-INV-FY26` | `FQS Annual Celebration Invitation FY26` | `STRAT-EVENTS-FY26` | Sep–Nov FY26 | `Events` | invitation + RSVP |
| `FQS-CMP-ASK-DONOREVT-FY26` | `FQS Donor Appreciation Reception FY26` | `STRAT-EVENTS-FY26` | May–Jun FY26 | `Events` | sponsorship + invitation packet |
| `FQS-CMP-ASK-PORTFOLIO-FY26` | `FQS Major Gifts Portfolio FY26` | `STRAT-MAJOR-FY26` | full FY26 | `Major Gifts` | 1:1 solicitation meetings |
| `FQS-CMP-ASK-LEGACY-FY26` | `FQS Legacy Circle Outreach FY26` | `STRAT-MAJOR-FY26` | full FY26 | `Planned Giving` | planned-giving letters |
| `FQS-CMP-ASK-FOUND-COMM-FY26` | `FQS Community Foundation Proposal FY26` | `STRAT-FOUND-FY26` | Aug–Oct FY26 | `Grants` | grant proposal |
| `FQS-CMP-ASK-FOUND-CORPFDN-FY26` | `FQS Corporate Foundation Proposal FY26` | `STRAT-FOUND-FY26` | Jan–Mar FY26 | `Grants` | grant proposal |
| `FQS-CMP-ASK-SPRING-EM-FY25` | `FQS Spring Appeal Email FY25` | *(FY25 rollup — see below)* | Mar–May FY25 | `Annual Giving` | email drop |
| `FQS-CMP-ASK-YEAREND-EM-FY25` | `FQS Year-End Email FY25` | FY25 rollup | Nov–Dec CY24 | `Annual Giving` | email drop |
| `FQS-CMP-ASK-CELEB-INV-FY25` | `FQS Annual Celebration Invitation FY25` | FY25 rollup | Sep–Nov FY25 | `Events` | invitation |
| `FQS-CMP-ASK-FOUND-COMM-FY25` | `FQS Community Foundation Proposal FY25` | FY25 rollup | Aug–Oct FY25 | `Grants` | grant proposal |
| `FQS-CMP-ASK-YEAREND-EM-FY24` | `FQS Year-End Email FY24` | FY24 rollup | Nov–Dec CY23 | `Annual Giving` | email drop |
| `FQS-CMP-ASK-FOUND-COMM-FY24` | `FQS Community Foundation Proposal FY24` | FY24 rollup | Aug–Oct FY24 | `Grants` | grant proposal |

To keep FY25/FY24 asks parented correctly, the seed also creates **abbreviated prior-year rollups + strategies** — but only the branches an ask needs, so we don't over-inflate the tree:

**Prior-year rollups (2 records):**

| Ext ID | Name | Category |
|---|---|---|
| `FQS-CMP-ROLLUP-FY25` | `FQS FY25 Fundraising` | `Fundraising Top Level Campaign` |
| `FQS-CMP-ROLLUP-FY24` | `FQS FY24 Fundraising` | `Fundraising Top Level Campaign` |

**Prior-year strategies (5 records, only ones needed for the FY25/FY24 asks above):**

| Ext ID | Name | ParentId |
|---|---|---|
| `FQS-CMP-STRAT-ANNUAL-FY25` | `FQS Annual Giving FY25` | `ROLLUP-FY25` |
| `FQS-CMP-STRAT-EVENTS-FY25` | `FQS Events FY25` | `ROLLUP-FY25` |
| `FQS-CMP-STRAT-FOUND-FY25` | `FQS Foundation Giving FY25` | `ROLLUP-FY25` |
| `FQS-CMP-STRAT-ANNUAL-FY24` | `FQS Annual Giving FY24` | `ROLLUP-FY24` |
| `FQS-CMP-STRAT-FOUND-FY24` | `FQS Foundation Giving FY24` | `ROLLUP-FY24` |

**Total tree: 3 rollups + 9 strategies + 15 asks = 27 campaigns.** Up from the current 18 (1 + 5 + 12), so ~50% growth in metadata volume — negligible for storage.

### 11.2 Date derivation (matches the setup-flow year-basis rules)

Seed script reads `Organization.FiscalYearStartMonth` at run time, exactly like the setup flow. The FY26 window is the year containing `System.today()`; FY25 = FY26 minus 12 months; FY24 = FY26 minus 24 months.

```apex
Integer fyStartMonth = [SELECT FiscalYearStartMonth FROM Organization LIMIT 1].FiscalYearStartMonth;
Date today = System.today();
Date fy26Start = (today.month() >= fyStartMonth)
    ? Date.newInstance(today.year(),     fyStartMonth, 1)
    : Date.newInstance(today.year() - 1, fyStartMonth, 1);
Date fy26End   = fy26Start.addMonths(12).addDays(-1);
Date fy25Start = fy26Start.addMonths(-12);  Date fy25End = fy26End.addMonths(-12);
Date fy24Start = fy26Start.addMonths(-24);  Date fy24End = fy26End.addMonths(-24);
```

Each ask's `StartDate` / `EndDate` is derived from a **date-rule token** on the row spec — same mechanism as the setup flow's Screen 2 templates:

| Token | Meaning |
|---|---|
| `full-window` | strategy's full FY window |
| `mar-may` | March 1 → May 31 of the FY |
| `sep-nov` | September 1 → November 30 of the FY |
| `nov-dec` | November 1 → December 31 of the calendar year that contains FY-month 11 |
| `may-jun` | May 1 → June 30 of the FY |
| `aug-oct` | August 1 → October 31 of the FY |
| `jan-mar` | January 1 → March 31 of the calendar year inside the FY |

If the org's FY starts January, all these windows collapse into the same calendar year — the setup flow's `varYearBasis = Calendar` behavior is inherited automatically.

### 11.3 Gift assignment: OSCs and GifTransactions attach at level 3 only

**Change from current behavior:** the existing OSC round-robin lands OSCs on the mixed 12-row "leaf" set, which under the new taxonomy would spread them across strategies AND asks. Restrict:

- **`OutreachSourceCode.CampaignId`** — round-robin across the **15 ask campaigns** (level 3 only). Thematic pins updated:
   - `EM-YE-01` → `FQS-CMP-ASK-YEAREND-EM-FY26`
   - `DM-FALL-01` → `FQS-CMP-ASK-CELEB-INV-FY26`
   - `EM-GR-01` (Grant Solicit) → `FQS-CMP-ASK-FOUND-COMM-FY26`
   - `SMS-TX-01` → `FQS-CMP-ASK-YEAREND-EM-FY26`
- **`GiftTransaction.CampaignId`** — assigned from the ask pool as well, but weighted so historical gifts (from `GIFT_HISTORY_YEARS = 3` in the config knobs) land on the correct fiscal year's asks:
   - Gifts with `TransactionDate` in FY26 window → assign randomly across the 9 FY26 asks
   - Gifts in FY25 window → assign across the 4 FY25 asks
   - Gifts in FY24 window → assign across the 2 FY24 asks
   - This ties YoY reporting to real data at the strategy and rollup levels through the ParentId chain.
- **Corporate matching gifts** — retain the `FQS-CMP-ASK-YEAREND-EM-FY26` pin (was formerly `FQS-CMP-CORP-MATCH` leaf) since year-end drives typically produce the most corporate matches. If a matched employee gift is in FY25/FY24, its corp-side match gets the same-year year-end ask.

### 11.4 Retiring old external IDs — one-shot rename

The current seed's 12 leaf ext IDs (`FQS-CMP-ANNUAL-2026`, `FQS-CMP-GALA-2026` — retiring the "gala" naming here too, `FQS-CMP-MG-INIT`, etc.) don't map cleanly to the new taxonomy — some are strategies, some are asks, and the names bury the level. Rather than migrate in place:

1. Teardown script deletes anything matching `FQS-CMP-%` — which under Section 4's existing behavior sweeps the old leaves alongside the new records.
2. New seed inserts the new taxonomy on the next run.
3. No renames or upserts-with-old-keys — the delete+recreate on next teardown/seed cycle is intentional and simpler than a migration path.

Callout in the README for existing testers: **"If you seeded before 2026-07-10, run teardown then re-seed to get the new campaign structure. Old test-org data on the previous ext IDs is orphaned and safe to leave — teardown will collect it."**

### 11.5 Test coverage additions for the new structure

Two new assertions to add to the deferred `fqs-seed-verify.apex` (§10.7) — capture here so they aren't forgotten:

1. `assertAsksAreAllLevel3` — every campaign with ext ID matching `FQS-CMP-ASK-%` has a non-null `ParentId` pointing at a `FQS-CMP-STRAT-%` campaign, which itself has `ParentId` = a `FQS-CMP-ROLLUP-%` campaign. No ask is directly under a rollup.
2. `assertNoOscOnStrategyOrRollup` — every `OutreachSourceCode` with `External_Id__c LIKE 'FQS-OSC-%'` has `CampaignId` in the ask set (level 3), not in strategies or rollups. Locks in the "response data lives at level 3" rule.

### 11.6 File impact

Only Section 2A of `scripts/apex/seed/fqs-seed-foundation.apex` changes — the campaign block. All other sections (designations, OSCs, corporate employers, gift generation) remain but reference the new campaign ext IDs where they cross-link. The header comment updates:

```apex
// Produces:
//   - 3 rollup campaigns (FY24/FY25/FY26) + 9 strategy campaigns + 15 ask campaigns (3-level hierarchy per FQS setup-flow spec)
//   - 10 GiftDesignations
//   - 18 OutreachSourceCodes (pinned to thematic FY26 asks; remainder round-robin across all asks)
//   - 15 Corporate Employer Accounts (FQS-ACC-CORP-01..15) for matching-gift scenarios
```

Line count in the Apex file grows by ~40 lines for the expanded spec. Given §10.3's warning about the 32K anonymous-Apex cap, this is another nudge toward extracting the whole generator into `FQSSeedGenerator.cls` — but the campaign block itself is small enough to land inline without triggering the cap.

---

## 12. Coverage gaps blocking the Account-launcher flow (2026-07-15)

**Why this section exists:** the rewrite of `FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml` (see `.planning/fqs-gift-entry-account-launcher-plan.md`) added three filtered datatable pickers and a soft-credit datatable. Querying the current FundFirst seed revealed that **three branches of the flow have zero data to select against**, so testers can only exercise them via the native lookup escape-hatch (which defeats the point of the filtered datatables). Close each gap so every branch of the account launcher has at least one real row to pick.

### 12.1 CampaignMembers are absent — Campaign picker is always empty

**Observed state:** `SELECT COUNT() FROM CampaignMember` returns 0 in FundFirst after a full seed. The account-launcher Campaign picker filters to campaigns whose members include one of the Account's Contacts. With no CampaignMembers, that datatable is empty for every donor, on every ask type. The only way to attach a Campaign becomes the native Lookup below the table.

**Fix:** during the gift-generation loop (all three seed sizes + chunk), after each donor's Contact is created and gifts are assigned to level-3 ask campaigns, also insert `CampaignMember` rows linking the donor's primary Contact to each Campaign that donor gave to. Deterministic, one row per (Contact, Campaign) pair.

Rough shape inside the donor loop:

```apex
Set<Id> giftCampaignIds = new Set<Id>();
for (GiftTransaction gt : donorGifts) if (gt.CampaignId != null) giftCampaignIds.add(gt.CampaignId);
for (Id campId : giftCampaignIds) {
    cmembers.add(new CampaignMember(
        ContactId = primaryContact.Id,
        CampaignId = campId,
        Status = 'Responded'
    ));
}
```

For Organization donors (no primary Contact on the Account itself), walk the ACR — attach any active ACR Contact as the CampaignMember. A single ACR Contact per Org account is enough to make the datatable non-empty on the launcher.

**Data-shape target:** ~2–4 CampaignMember rows per donor Account on average, spread across FY26/FY25/FY24 asks matching that donor's gift history. Testers hitting the launcher on any seeded donor will see a non-empty Campaign picker.

### 12.2 All GiftCommitments are `FulfillmentType = Unconditional` — Conditional branch untested

**Observed state:** `SELECT FulfillmentType, COUNT(Id) FROM GiftCommitment WHERE Status = 'Active' GROUP BY FulfillmentType` returns `Unconditional: 7, Conditional: 0`. The account launcher's Pledge Payment → Conditional path (which shows the Restriction picker → filtered Designation picker) never fires; every Pledge Payment auto-picks the org's default Unrestricted designation and skips straight through. Same for creating a *new* Pledge with `FulfillmentType = Conditional` — the Restriction picker path exists in the flow but has no realistic data to compare against.

**Fix:** in `fqs-seed-foundation.apex` or the donor generator, mark **~30% of seeded GiftCommitments as `FulfillmentType = 'Conditional'`**, and for each Conditional commitment insert a `GiftDefaultDesignation` row that points at one of the restricted designations already seeded (`With Donor Restriction - Purpose`, `- Time`, or `- Permanent`). This gives the launcher's Pledge Payment path real Conditional commitments to route through the Restriction picker on.

Rough shape:

```apex
Boolean isConditional = randBool(globalIdx, 700, 0.30);
gc.FulfillmentType = isConditional ? 'Conditional' : 'Unconditional';
// ... insert gc ...
if (isConditional) {
    List<GiftDesignation> restrictedPool = [SELECT Id, FQS_Restriction_Type__c FROM GiftDesignation
                                            WHERE External_Id__c LIKE 'FQS-GD-%'
                                            AND FQS_Restriction_Type__c LIKE 'With Donor Restriction%'];
    GiftDesignation pick = restrictedPool[Math.mod(prng(globalIdx, 701), restrictedPool.size())];
    gdds.add(new GiftDefaultDesignation(
        ParentRecordId = gc.Id,
        DesignationId = pick.Id,
        AllocatedPercentage = 100
    ));
}
```

Note the field is `AllocatedPercentage`, not `Percent` — the account-launcher plan calls out that platform naming.

**Data-shape target:** ~30% Conditional commitments across the whole seed, each with a `GiftDefaultDesignation` pointing at a specific-restriction designation. Distribution across the three restriction subtypes (Purpose / Time / Permanent) — round-robin across the six restricted seed designations.

### 12.3 No `ContactContactRelation` rows — cross-household soft credit unreachable

**Observed state:** `SELECT COUNT() FROM ContactContactRelation WHERE IsActive = true` returns 0. The account launcher's soft-credit datatable pools two sources — Accounts reachable via active ACRs (household members, employers), and Accounts reachable via active CCRs (personal relationships like spouses across households). With no CCRs, the soft-credit table falls back to ACR-only reach, which for Person Accounts is often just the primary household. Testers can't exercise cross-household soft-credit selection.

**Fix:** insert a small number of `ContactContactRelation` rows during donor seeding — target ~10% of Person Account donors receive one active CCR to another seeded Person Account's primary Contact. Pick pairs deterministically so the same seed always produces the same reachability graph.

Rough shape (runs once, after all donor Accounts + Contacts exist):

```apex
List<Contact> paContacts = [SELECT Id FROM Contact
                            WHERE Account.External_Id__c LIKE 'FQS-ACC-%'
                            AND Account.IsPersonAccount = true];
Integer pairCount = paContacts.size() / 10;  // 10% get a CCR
List<ContactContactRelation> ccrs = new List<ContactContactRelation>();
for (Integer i = 0; i < pairCount; i++) {
    Contact c1 = paContacts[i * 2];
    Contact c2 = paContacts[i * 2 + 1];
    if (c1.Id == c2.Id) continue;
    ccrs.add(new ContactContactRelation(
        ContactId = c1.Id,
        RelatedContactId = c2.Id,
        IsActive = true,
        Relationship = 'Spouse'   // verify picklist value; fallback: 'Family'
    ));
}
insert ccrs;
```

Optionally seed a few Contact↔Contact rows where the two Contacts live on **different Household accounts** — that's the case that actually exercises the "walk CCR to a different Account" branch of the launcher's soft-credit query chain.

**Data-shape target:** ~5–10 active CCR rows in a 100-donor seed, at least 3 of which span two different household Accounts. Enough for the soft-credit datatable to show multiple candidate Accounts on any Person Account donor with a CCR.

### 12.4 Verify additions (bumped into deferred `fqs-seed-verify.apex`, §10.7)

Three new assertions to capture here so they aren't lost:

1. `assertEveryDonorHasCampaignMembers` — every donor Account with at least one gift has at least one `CampaignMember` row linking its primary Contact (or first active ACR Contact for Orgs) to a Campaign in that donor's gift history.
2. `assertConditionalCommitmentMix` — 20–40% of active GiftCommitments have `FulfillmentType = 'Conditional'`, and every Conditional commitment has at least one `GiftDefaultDesignation` pointing at a restricted `GiftDesignation`.
3. `assertCrossHouseholdCCRExists` — at least one active `ContactContactRelation` exists where `Contact.AccountId != RelatedContact.AccountId` (proves the cross-household soft-credit path is reachable).

### 12.5 File impact

- `scripts/apex/seed/fqs-seed-foundation.apex` — CCR block (new, small — ~15 lines).
- Donor generator body (`fqs-seed-small.apex` / `fqs-seed-medium.apex` / `fqs-seed-chunk.apex`, or the extracted `FQSSeedGenerator.cls` per §10.3) — CampaignMember insertion inside the donor loop (~10 lines), Conditional commitment + GiftDefaultDesignation logic (~15 lines).
- README — add to §5 update: "Every seeded donor gets CampaignMember rows for each Campaign they gave to. ~30% of commitments are Conditional with restricted default designations. A subset of Person Account donors have cross-household CCRs seeded for soft-credit reach testing."

Given §10.3's 32K-char anonymous-Apex ceiling is already tight, these three additions push hard toward extracting the generator to `FQSSeedGenerator.cls` **before** adding this coverage — otherwise the three files won't fit.

---

## 13. Coverage gaps from seed↔flow audit (2026-07-18)

Second-pass audit against every untracked FQS flow that reads GiftTransaction / GiftCommitment / Account / Campaign / OutreachSourceCode. Two actionable gaps confirmed; `Campaign.Type` gap intentionally ignored per Justin.

**Status (2026-07-19):** 13.1 + 13.2 implemented in `FQSSeedGenerator.cls` (deploy `0AfWB00000DTfuj0AD`). See tracker Findings entry for verification detail — smoke seed at offset 9000 confirmed 70/10/10/10 recurring-status split and 13/25 gifts with partial `NonTaxDeductibleAmount`. Key discovery: `GiftTransaction.TaxDeductionAmount` is `calculated:true` in-org — not directly writeable — so §13.2 is implemented by populating `NonTaxDeductibleAmount` (writeable) and letting the platform derive `TaxDeductionAmount = CurrentAmount - NonTaxDeductibleAmount`. Effect on the flow's `Route_Email_Template` decision is identical.

### 13.1 GiftCommitment.Status — seed only emits `Active`

**Flow:** `FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml` — `Get_Active_Commitments` filter accepts `Status IN ('Active', 'Failing', 'Lapsed', 'Paused')`.

**Current seed behavior:** Every generated `GiftCommitment` is inserted with `Status = 'Active'`. Three of the four allowed statuses receive zero seeded coverage → the launcher's non-Active branches (Failing / Lapsed / Paused) cannot be exercised in first-pass UI testing without hand-editing records.

**Change:** In the donor generator (post §10.3, this will live in `FQSSeedGenerator.cls`), after choosing base attributes for each commitment, apply a status distribution:

- **~70% `Active`** — happy path, existing coverage.
- **~10% `Failing`** — payment retry in progress (e.g., card declined last attempt).
- **~10% `Lapsed`** — expired without renewal.
- **~10% `Paused`** — donor-initiated pause.

Only apply the distribution to recurring commitments (`FQS_Gift_Commitment_Category__c = 'Recurring Gift'`); pledges (`Pledged Gift`) and grants (`Grant Payout`) stay `Active` unless there's a domain reason to distribute them. Verify allowed values by picklist description before shipping — Salesforce's active values may be a strict subset.

**Verify:** New `fqs-seed-verify.apex` assertion — `assertGiftCommitmentStatusBreadth`: every non-`Active` status has at least one seeded row across all donor tiers.

### 13.2 GiftTransaction.TaxDeductionAmount — never populated

**Flow:** `FQS_Gift_Acknowledgement.flow-meta.xml` — `Route_Email_Template` decision routes to a *partial-deduction* email template when `TaxDeductionAmount < CurrentAmount`. Seed never populates the field → every seeded gift falls through to the full-deduction default, and the partial-deduction branch is never test-covered.

**Change:** In `FQSSeedGenerator.cls`'s gift-transaction generation:

- **Default (most gifts):** `TaxDeductionAmount = OriginalAmount` (full deduction — cash gift, standard case).
- **Fee-carrying subset:** for the ~20% subset that already carries realistic fees per §1 decision #4, set `TaxDeductionAmount = OriginalAmount - GatewayTransactionFee - ProcessorTransactionFee` (partial deduction — the donor's deductible portion excludes the pass-through fees).
- **Benefit-inclusion subset (~10% of Event-category gifts):** set `TaxDeductionAmount = OriginalAmount * 0.85` (partial deduction — the classic "gala ticket includes dinner" pattern; donor's deductible amount excludes the fair market value of goods received).
- **In-kind subset:** for `FQS_In_Kind__c = true` gifts, leave `TaxDeductionAmount` null or match `OriginalAmount` — depends on how the flow treats null. Verify against the `IsNull` behavior in `Route_Email_Template` before choosing; default to matching `OriginalAmount` if the flow doesn't handle null.

The three distributions above give the flow at least one gift per template branch. Percentages are approximate — the goal is coverage, not statistical realism.

**Verify:** New `fqs-seed-verify.apex` assertion — `assertTaxDeductionCoversAllBranches`: at least one gift with `TaxDeductionAmount = CurrentAmount` (full), at least one with `TaxDeductionAmount < CurrentAmount` (partial), and no rows with `TaxDeductionAmount > CurrentAmount`.

### 13.3 File impact

- `FQSSeedGenerator.cls` — extend commitment loop with status distribution (~15 lines); extend gift-transaction generation with tax-deduction logic (~10 lines).
- `fqs-seed-verify.apex` (per §10.7, when authored) — 2 new assertion methods.
- No new SFDX metadata required — both fields already exist on their respective standard objects.

### 13.4 Explicit non-goals

- **`Campaign.Type` blank in Launcher_Account datatable** — audit surfaced this, Justin explicitly ignored (2026-07-18). Datatable column stays blank; do not touch the seed for this.
- **`AcknowledgementStatus` null** — intentional. Flow filter accepts `IsNull OR = 'To Be Sent'`, so null is the correct trigger state. No change.
