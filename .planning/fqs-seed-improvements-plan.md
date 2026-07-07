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
3. **External IDs: single `FQS_External_Id__c`** per seeded object — Text(64), External ID, Unique, Case-Sensitive
4. **Amounts: round to nearest $5**, then a subset carry realistic credit-card / processing fees so `OriginalAmount` becomes uneven when fees are applied
5. **Corporate employer accounts**: dedicated pool of ~15 accounts (naming: `FQS-CORP-01` etc.), separate from donor pyramid
6. **Bundle earlier bug fixes** into the same rewrite:
   - Pledge schedule denominator (divide by pledge years, not always 12)
   - `PaymentInstrument.ExpiryYear` uses `System.today().year()` base
   - `TransactionDueDate` = `TransactionDate + 30d` for non-Paid gifts
   - Stage ↔ CloseDate coupling on Opportunity

---

## 1. Metadata: External ID fields (13 files)

For each object below, create `force-app/main/default/objects/<Object>/fields/FQS_External_Id__c.field-meta.xml` with this content (adjust `<label>` if needed):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>FQS_External_Id__c</fullName>
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
1. **Master parent** — one record: `FQS Master Fundraising`, `FQS_External_Id__c = FQS-CMP-MASTER`
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

**Idempotency:** replace `Name`-based existence check with SOQL against `FQS_External_Id__c IN :expectedExtIds`. Use `Database.upsert(campaigns, Campaign.FQS_External_Id__c)` — cleaner than the current select-then-insert pattern.

### Section B — GiftDesignations (10 records) — add External IDs

Same 10 designations as today. Add `FQS_External_Id__c` per row:

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

Use `Database.upsert(...)` keyed on `FQS_External_Id__c`.

### Section C — OutreachSourceCodes (18 records) — add External IDs

External ID = `FQS-OSC-<SourceCode>` (SourceCode is already unique).

**Round-robin campaign assignment:** currently assigns leaf campaigns. Keep that, but preferentially match OSCs to their thematic leaf when obvious:
- `EM-GR-01` (Grant Solicit) → `FQS Foundation Grants 2026`
- `EM-YE-01` (Year End) → `FQS Annual Fund 2026`
- `DM-FALL-01` → `FQS Fall Auction 2025`

Otherwise round-robin.

Use `Database.upsert(...)` keyed on `FQS_External_Id__c`.

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
- `FQS_External_Id__c` = `FQS-ACC-CORP-01` through `FQS-ACC-CORP-15`
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
    //   FQS_External_Id__c = FQS-GT-CORP-<runningIdx>
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

Replace every `WHERE ...Name LIKE '%FQS #%'` (or `LIKE 'FQS %'`) clause with `WHERE FQS_External_Id__c LIKE 'FQS-%'`. Every seeded object now has this field, so deletion becomes:

```apex
// New teardown pattern
delete [SELECT Id FROM GiftRefund              WHERE FQS_External_Id__c LIKE 'FQS-GR-%'   LIMIT 50000];
delete [SELECT Id FROM GiftTransactionDesignation WHERE FQS_External_Id__c LIKE 'FQS-GTD-%' LIMIT 50000];
delete [SELECT Id FROM GiftSoftCredit          WHERE FQS_External_Id__c LIKE 'FQS-GSC-%'  LIMIT 50000];
delete [SELECT Id FROM GiftTribute             WHERE FQS_External_Id__c LIKE 'FQS-GTR-%'  LIMIT 50000];
delete [SELECT Id FROM GiftTransaction         WHERE FQS_External_Id__c LIKE 'FQS-GT-%'   LIMIT 50000];  // catches both FQS-GT-<idx>-<g> and FQS-GT-CORP-<idx>
delete [SELECT Id FROM GiftCommitmentSchedule  WHERE FQS_External_Id__c LIKE 'FQS-GCS-%'  LIMIT 50000];
delete [SELECT Id FROM GiftCommitment          WHERE FQS_External_Id__c LIKE 'FQS-GC-%'   LIMIT 50000];
delete [SELECT Id FROM Opportunity             WHERE FQS_External_Id__c LIKE 'FQS-OPP-%'  LIMIT 50000];
delete [SELECT Id FROM PaymentInstrument       WHERE FQS_External_Id__c LIKE 'FQS-PI-%'   LIMIT 50000];
delete [SELECT Id FROM DonorGiftSummary        WHERE Donor.FQS_External_Id__c LIKE 'FQS-ACC-%' LIMIT 50000];
delete [SELECT Id FROM Account                 WHERE FQS_External_Id__c LIKE 'FQS-ACC-%'  LIMIT 50000];  // catches donor AND FQS-ACC-CORP-
delete [SELECT Id FROM OutreachSourceCode      WHERE FQS_External_Id__c LIKE 'FQS-OSC-%'  LIMIT 50000];
// GiftDesignation still needs IsActive=false before delete
List<GiftDesignation> gds = [SELECT Id, IsActive FROM GiftDesignation WHERE FQS_External_Id__c LIKE 'FQS-GD-%' LIMIT 50000];
// deactivate + delete...
delete [SELECT Id FROM Campaign                WHERE FQS_External_Id__c LIKE 'FQS-CMP-%'  LIMIT 50000];
```

**Deletion order note:** Campaigns must delete last, but within Campaigns, leaves must be deleted before categories, before Master (`ParentId` FK). Handle by:
1. First pass: `delete [... WHERE FQS_External_Id__c LIKE 'FQS-CMP-%' AND ParentId != null]` (deletes leaves + categories)
2. Second pass: `delete [... WHERE FQS_External_Id__c = 'FQS-CMP-MASTER']`

OR: build a dependency-ordered list and delete leaves → categories → master in three explicit chunks.

---

## 5. README update (`scripts/apex/seed/README.md`)

Add sections:
- **Prerequisites**: after "Enable via Setup → Profiles → Record Type Settings", add "Deploy the `FQS_External_Id__c` fields first: `sf project deploy start --source-dir force-app/main/default/objects`"
- **Campaign hierarchy**: brief note that seed produces a 3-level tree, with a visualization
- **Corporate matching**: note the 15 FQS-CORP employers + the 4-scenario mix
- **Amount conventions**: "All base amounts round to nearest $5; ~35% of gifts have DonorCoverAmount which produces uneven OriginalAmount totals for realistic gateway reconciliation testing."
- **Query for eligible-but-unclaimed matches**:
    ```sql
    SELECT Id, Donor.Name, OriginalAmount
    FROM GiftTransaction
    WHERE GiftType = 'Individual'
      AND FQS_External_Id__c LIKE 'FQS-GT-%'
      AND FQS_External_Id__c NOT LIKE 'FQS-GT-CORP-%'
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
- `force-app/main/default/objects/Account/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/Campaign/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftDesignation/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/OutreachSourceCode/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftCommitment/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftCommitmentSchedule/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftTransaction/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftTransactionDesignation/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftRefund/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftSoftCredit/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/GiftTribute/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/PaymentInstrument/fields/FQS_External_Id__c.field-meta.xml`
- `force-app/main/default/objects/Opportunity/fields/FQS_External_Id__c.field-meta.xml`

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
