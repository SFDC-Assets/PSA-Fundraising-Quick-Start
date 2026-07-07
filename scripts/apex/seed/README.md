# FQS Seed Data Scripts

Generates test donor datasets in FundFirst with realistic mix and cascade.
Primary purpose is **testing and development**; demo polish is secondary.

## Files

| File | Purpose |
|---|---|
| `fqs-seed-teardown.apex` | Removes all records where `FQS_External_Id__c LIKE 'FQS-%'` (safe, idempotent) |
| `fqs-seed-foundation.apex` | 3-level Campaign hierarchy + 10 Designations + 18 OSCs + 15 corporate employers |
| `fqs-seed-small.apex` | 10 donors + full cascade (~200 records) |
| `fqs-seed-medium.apex` | 100 donors + full cascade (~3,000 records) |
| `fqs-seed-chunk.apex` | Template used by the large seeder — one 300-donor chunk |
| `fqs-seed-large.sh` | Shell wrapper that runs 34 chunks for the 10k dataset |

## Prerequisites (one-time org setup)

1. The running user must have profile-level access to:
   - `Account.PersonAccount` record type
   - `Opportunity.Grant` record type
   - `Opportunity.Major_Gift` record type

   Enable via **Setup → Profiles → your profile → Record Type Settings**.

2. **Deploy the `FQS_External_Id__c` fields first**:
   ```bash
   sf project deploy start --source-dir force-app/main/default/objects --target-org FundFirst
   ```
   The seed scripts write to `FQS_External_Id__c` on every seeded object; they will
   error if the field is missing. Objects that carry the field: Account, Campaign,
   GiftDesignation, OutreachSourceCode, GiftCommitment, GiftCommitmentSchedule,
   GiftTransaction, GiftTransactionDesignation, GiftRefund, GiftSoftCredit,
   GiftTribute, PaymentInstrument, Opportunity.

## Mix (all three datasets)

- **Donor levels**: 70% Entry ($25–$999) / 25% Mid ($1K–$25K) / 5% Major ($25K–$50K)
- **Donor type**: 75% Individual / 25% Org (Major skews toward Org)
- **History**: 3 years of gifts
- **Recurring**: 35% of donors have an active recurring `GiftCommitment`
- **Pledged**: 40% of Mid+Major have a pledged `GiftCommitment`
- **Grant payouts**: ~30% of Major Org donors
- **Gift categories**: 30% Outright / 50% Pledge Payment / 15% Grant Payment / 5% Fee
- **Opportunities**: All Major donors + 20% of Mid (Grant RT for Orgs, Major_Gift RT for Individuals)
- **Edge cases**: 15% lapsed donors, 15% soft credits, 10% tributes, 3% refunds
- **Employer matching**: 30% of Individual donors are eligible; per-gift scenario mix below

All distribution knobs are exposed as `Integer` / `Decimal` constants at the top of
the generator body — flip them for fixture-mode testing (`PROB_LAPSED = 1.0` for
"all lapsed", etc.).

## Campaign hierarchy

The foundation script produces a 3-tier tree:

```
FQS Master Fundraising  (FQS-CMP-MASTER)
├── FQS Annual Giving
│   ├── FQS Annual Fund 2026 / 2025 / 2024
├── FQS Events
│   ├── FQS Spring Gala 2026, FQS Fall Auction 2025
├── FQS Major Gifts
│   ├── FQS Major Gifts Initiative, FQS Legacy Circle
├── FQS Grants
│   ├── FQS Foundation Grants 2026
└── FQS Corporate & Community
    ├── FQS Corporate Matching Program
    ├── FQS In-Kind Donations Drive
    ├── FQS Capital Campaign 2026
    └── FQS General Fundraising
```

Gifts and Opportunities are only assigned to **leaf** campaigns.

## Corporate matching

The foundation script creates 15 corporate employer accounts (`FQS-ACC-CORP-01`
through `FQS-ACC-CORP-15`), separate from the donor pyramid. About 30% of
Individual donors are randomly "employed" at one of them. For each such donor's
outright + pledge-payment gifts, one of four scenarios is rolled:

| Scenario | Probability | Employee-side | Corp-side |
|---|---|---|---|
| 1. Pledge-matched | 30% × pledge gifts | `FQS_Matched__c = true` | New GT: `DonorId` = employer, `MatchingEmployerTransactionId` = employee GT, `PaymentMethod = Check`, `Status = Paid` |
| 2. Outright-matched | 40% × outright gifts | Same flag pattern | Same shape as scenario 1 |
| 3. Pending (submitted, not yet posted) | 15% | `FQS_Matched__c = true` | No corp GT yet |
| 4. Unmatched but eligible | 15% | (no flag) | (no corp GT) — the employer exists in the pool but the employee never submitted |

Corp-side match amounts are 50% or 100% of the employee gift, rounded to $5.

## Amount conventions

- All base gift/commitment amounts round to nearest $5 (`roundTo5(...)`).
- About 35% of gifts have `DonorCoverAmount > 0` — the donor covers the gateway/processor
  fee, which makes `GT.OriginalAmount` uneven (e.g. `$107.30` instead of `$105.00`).
  This produces realistic gateway reconciliation test data.
- Fee model:
  | Payment method | Gateway fee | Processor fee |
  |---|---|---|
  | Credit Card | 2.2% + $0.30 | 0.5% |
  | ACH | 0.8% | 0.5% |
  | PayPal | 2.9% + $0.49 | 0.5% |
  | Check | 0 | 0 |
- Check gifts always land on a $5 boundary (no fees).

## Marker convention

Every seeded record carries `FQS_External_Id__c` starting with `FQS-`. Teardown
filters on that prefix, so it's precise and safe. External-ID patterns:

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
| GiftTransaction (donor) | `FQS-GT-<globalIdx>-<g>` | `FQS-GT-42-3` |
| GiftTransaction (corp match) | `FQS-GT-CORP-<globalIdx>-<g>` | `FQS-GT-CORP-42-3` |

## Run order

### Reseed (wipe + regenerate)

```bash
# 1. Clean up prior FQS test data (idempotent — safe to run anytime)
sf apex run -f scripts/apex/seed/fqs-seed-teardown.apex --target-org FundFirst

# 2. Seed foundation records
sf apex run -f scripts/apex/seed/fqs-seed-foundation.apex --target-org FundFirst

# 3. Pick a size:
sf apex run -f scripts/apex/seed/fqs-seed-small.apex --target-org FundFirst
# OR
sf apex run -f scripts/apex/seed/fqs-seed-medium.apex --target-org FundFirst
# OR (large — takes ~15 min)
./scripts/apex/seed/fqs-seed-large.sh
```

### Verify

```bash
sf data query --target-org FundFirst --query \
  "SELECT COUNT() FROM Account WHERE FQS_External_Id__c LIKE 'FQS-ACC-%'"

sf data query --target-org FundFirst --query \
  "SELECT COUNT() FROM GiftTransaction WHERE FQS_External_Id__c LIKE 'FQS-GT-%'"

# Corporate matches specifically:
sf data query --target-org FundFirst --query \
  "SELECT COUNT() FROM GiftTransaction WHERE FQS_External_Id__c LIKE 'FQS-GT-CORP-%'"

# Eligible-but-unclaimed matches (scenario 4 + pending scenario 3):
sf data query --target-org FundFirst --query \
  "SELECT Id, DonorId, OriginalAmount, FQS_Matched__c
   FROM GiftTransaction
   WHERE FQS_External_Id__c LIKE 'FQS-GT-%'
     AND FQS_External_Id__c NOT LIKE 'FQS-GT-CORP-%'
     AND GiftType = 'Individual'
     AND Id NOT IN (SELECT MatchingEmployerTransactionId FROM GiftTransaction WHERE MatchingEmployerTransactionId != null)"
```

## Governor-limit notes

- Anonymous Apex is capped at 10,000 DML rows per transaction.
- Each donor generates ~25 rows (Account + ~1 commitment + ~1 schedule + ~6 gifts +
  ~6 GTDs + ~1 opp + ~1 PI + soft credits/tributes/refunds + optional corp match GT).
- **Max single-transaction donors: ~300**. That's why the large dataset uses a shell loop.
- `fqs-seed-small.apex` (10 donors) and `fqs-seed-medium.apex` (100 donors) both fit
  in a single transaction.

## Determinism

Random values are seeded from `donor_index + salt` — the same offset always
produces the same donor. This means:
- Re-running the small dataset produces identical donors (until teardown clears them)
- The large dataset's chunk 0 always produces donors 0-299 the same way
- Upserts (foundation + accounts) are keyed on `FQS_External_Id__c`, so partial
  reruns are safe — records with matching IDs get updated in place.

If you want variety, change `BATCH_OFFSET` at the top of the seed scripts.
