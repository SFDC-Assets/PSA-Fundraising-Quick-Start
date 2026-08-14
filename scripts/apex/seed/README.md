# FQS Seed Data Scripts

Generates test donor datasets in FundFirst with realistic mix and cascade.
Primary purpose is **testing and development**; demo polish is secondary.

## Files

| File | Purpose |
|---|---|
| `fqs-seed-teardown.apex` | Removes all records where `External_Id__c LIKE 'FQS-%'` (safe, idempotent). Each invocation self-caps at ~9K DML rows; use the wrapper below on orgs with >9K FQS records. |
| `fqs-seed-teardown-loop.sh` | Shell wrapper that re-runs `fqs-seed-teardown.apex` until a pass reports 0 deletes. Use this for any org with tens of thousands of seeded records. |
| `fqs-seed-foundation.apex` | Rollup/strategy/ask Campaign hierarchy (3 rollups + 9 strategies + 15 asks across FY24/25/26, depth capped at 3) + 14 Designations (mirroring `FQS_Suggest_Designations` catalog) + one OSC per ask campaign + 15 corporate employers + 5 role-typed PartyRoleRelations (Spouse, Parent-Child, Sibling, Friend, Neighbor) |
| `fqs-seed-small.apex` | Thin invoker — 10 donors via `FQSSeedGenerator.seedChunk` |
| `fqs-seed-medium.apex` | Thin invoker — 100 donors via `FQSSeedGenerator.seedChunk` |
| `fqs-seed-chunk.apex` | Thin invoker — 300 donors per call (used by the large seeder) |
| `fqs-seed-large.sh` | Shell wrapper that runs 34 chunks for the 10k dataset |
| `fqs-seed-matching-gift-scenarios.apex` | Optional post-seed enhancer — layers ACRs, aligned commitments/campaigns, and intermediary launch-point GTs so the Find Matching Gift flow has data on every scoring path |
| `force-app/main/default/classes/FQSSeedGenerator.cls` | Deployable Apex class that holds all donor-generation logic. Invoked by the four thin scripts above. Keeps the anonymous Apex payloads far under the 32K cap and centralizes PRNG + amount-band math. |

## Prerequisites (one-time org setup)

1. The running user must have profile-level access to:
   - `Account.PersonAccount` record type
   - `Opportunity.Grant` record type
   - `Opportunity.Major_Gift` record type

   Enable via **Setup → Profiles → your profile → Record Type Settings**.

2. **Deploy the `External_Id__c` fields, the `FQS_Donor_Grouping__mdt` records, and `FQSSeedGenerator.cls`**:
   ```bash
   sf project deploy start --source-dir force-app/main/default/objects --target-org FundFirst
   sf project deploy start --source-dir force-app/main/default/customMetadata --target-org FundFirst
   sf project deploy start --source-dir force-app/main/default/classes/FQSSeedGenerator.cls --target-org FundFirst
   ```
   The seed scripts write to `External_Id__c` on every seeded object; they will
   error if the field is missing. Objects that carry the field: Account, Campaign,
   GiftDesignation, OutreachSourceCode, GiftCommitment, GiftCommitmentSchedule,
   GiftTransaction, GiftTransactionDesignation, GiftRefund, GiftSoftCredit,
   GiftTribute, PaymentInstrument, Opportunity.

   The generator queries `FQS_Donor_Grouping__mdt` at run time to derive the per-level
   amount bands (see the Mix section). All three records (Entry / Mid / Major) must
   exist in the target org.

## Mix (all three datasets)

- **Donor levels**: 70% Entry / 25% Mid / 5% Major
- **Amount bands (per-gift base amount, CMT-derived at run time)**:
  - Entry: `max($25, Entry.One_Time_Min_Amount__c)` up to `Mid.One_Time_Min_Amount__c − $5`
  - Mid:   `Mid.One_Time_Min_Amount__c` up to `Major.One_Time_Min_Amount__c − $5`
  - Major: `Major.One_Time_Min_Amount__c` up to `Major.One_Time_Min_Amount__c × 2`
  - With current CMT values that resolves to: **Entry $25–$495 · Mid $500–$4,995 · Major $5,000–$10,000**
  - **Hard clamps** (see `FQSSeedGenerator.ENTRY_MIN_FLOOR` / `MAJOR_MAX_RATIO`): Entry floor never drops below $25 even if the CMT is set to zero; Major upper is capped at 2× the threshold so we don't emit noise-inducing 6-figure outliers.
- **Recurring commitment amount**: derived from `Annual_Min_Amount__c ÷ 12` per level so a donor's annualized recurring giving lands squarely inside their grouping band.
- **Donor type**: 75% Individual / 25% Org (Major skews toward Org)
- **History**: 3 years of gifts
- **Recurring**: 35% of donors have an active recurring `GiftCommitment` (Monthly `GCS.TransactionPeriod`, no signing offset — first payment coincides with `EffectiveStartDate`)
- **Pledged**: 40% of Mid+Major have a pledged `GiftCommitment` (Yearly `GCS`, timing mix 40% past-only / 40% midflight / 20% future-only, `EffectiveStartDate` = firstPmt − 30..180d signing offset)
- **Grant payouts**: ~30% of Major Org donors, with three-way shape mix:
  - **70% one-time** — single installment, brief admin window
  - **25% multi-year** — yearly ladder over 2-3 years, per-installment `FQS_Restriction_Release_Date__c` +1yr
  - **5% Custom** — irregular installments (3-5 rows), irregular spacing (60-540d gaps), irregular amounts summing to `ExpectedTotalCmtAmount`. `GC.ScheduleType='Custom'`, `GCS.TransactionPeriod='Custom'`, `Type='CreateTransactions'`; `TransactionInterval` + `TransactionDay` omitted at insert (platform defaults both to `1` post-save).
- **Gift categories**: 30% Outright / 50% Pledge Payment / 15% Grant Payment / 5% Fee
- **Opportunities**: All Major donors + 20% of Mid (Grant RT for Orgs, Major_Gift RT for Individuals)
- **Edge cases**: 15% lapsed donors, 15% soft credits, 10% tributes, 3% refunds
- **Employer matching**: 30% of Individual donors are eligible; per-gift scenario mix below

All distribution knobs are `public static` fields on `FQSSeedGenerator`. Anonymous
scripts override them BEFORE calling `seedChunk(...)`:

```apex
FQSSeedGenerator.PROB_LAPSED = 1.0;             // all-lapsed fixture run
FQSSeedGenerator.PYRAMID_ENTRY_PCT = 0;         // no Entry donors
FQSSeedGenerator.PYRAMID_MID_PCT = 0;           // pure Major fixture
FQSSeedGenerator.seedChunk(10, 0);
```

If you change `FQS_Donor_Grouping__mdt` One_Time / Annual thresholds and want the
generator to pick them up, no code change is required — the next run queries the
current values and adjusts the bands automatically.

## Campaign hierarchy (rollup / strategy / ask)

The foundation script produces a 3-tier tree matching the FQS setup-flow spec.
Each tier serves a distinct role in reporting:

- **Rollup (level 1)** — top-of-tree; totals for a whole fiscal year.
- **Strategy (level 2)** — how the year's giving was organized (Annual, Events, Major/Planned, Foundation).
- **Ask (level 3)** — the specific solicitation that produced a response. **All OSCs and gifts land here.**

Three fiscal years are seeded (FY24 / FY25 / FY26) so year-over-year reports have real data.
FY windows are derived from `Organization.FiscalYearStartMonth` at seed time.

```
FQS FY26 Fundraising  (FQS-CMP-ROLLUP-FY26)
├── FQS Annual Giving FY26           (strategy)
│   ├── FQS Spring Appeal Email FY26        ← ask
│   ├── FQS Spring Appeal Direct Mail FY26  ← ask
│   └── FQS Year-End Email FY26             ← ask
├── FQS Events FY26                  (strategy)
│   ├── FQS Annual Celebration Invitation FY26   ← ask
│   └── FQS Donor Appreciation Reception FY26    ← ask
├── FQS Major & Planned Giving FY26  (strategy)
│   ├── FQS Major Gifts Portfolio FY26          ← ask
│   └── FQS Legacy Circle Outreach FY26         ← ask
└── FQS Foundation Giving FY26       (strategy)
    ├── FQS Community Foundation Proposal FY26  ← ask
    └── FQS Corporate Foundation Proposal FY26  ← ask

FQS FY25 Fundraising  (FQS-CMP-ROLLUP-FY25)  — abbreviated: only branches that back FY25 asks
├── FQS Annual Giving FY25  → 2 asks (Spring, Year-End)
├── FQS Events FY25         → 1 ask (Celebration)
└── FQS Foundation Giving FY25 → 1 ask (Community Foundation)

FQS FY24 Fundraising  (FQS-CMP-ROLLUP-FY24)  — abbreviated: 2 asks total
├── FQS Annual Giving FY24  → 1 ask (Year-End)
└── FQS Foundation Giving FY24 → 1 ask (Community Foundation)
```

**Total:** 3 rollups + 9 strategies + 15 asks = 27 campaigns.

**Gift/campaign assignment rules:**
- Gifts assign to asks **strictly by `TransactionDate` FY window** — a gift with a
  FY25 date lands on a FY25 ask, never a FY26 ask. Rollup + strategy totals accrue
  correctly via `ParentId`.
- OSCs cross-check: each gift picks an OSC whose CampaignId sits in the same FY.
- Corporate matches target the **year-end email ask in the same FY** as the employee gift.

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

### Employer configuration (foundation)

The 15 corporate employers in the foundation ship with varied matching-gift
config so the Find Matching Gift flow's scorers, drift-fix branch, and cap
enforcement can be tested end-to-end:

| Field | Value distribution |
|---|---|
| `FQS_Matching_Gift_Program__c` | 10 of 15 = true (5 unflagged so drift-fix prompt is testable) |
| `FQS_Match_Ratio__c` | 2.00 on TechCorp + Meridian; 0.50 on BlueSky; 1.00 on the rest |
| `FQS_Match_Annual_Individual_Maximum__c` | $5000 on TechCorp; $2500 on Summit; blank elsewhere |
| `FQS_Is_Match_Intermediary__c` | 2 dedicated intermediary accounts (`FQS-ACC-INT-01/02`) — Benevity + YourCause — separate from the 15 employer pool |

Foundation gracefully skips fields that aren't deployed yet, so it stays
runnable on orgs without the Matching Gift flow metadata.

## Matching-gift scenario enhancer (post-seed layer)

After running foundation + a donor seed, run the enhancer to make the base
data actually exercise the **Find Matching Gift** screen flow:

```bash
sf apex run -f scripts/apex/seed/fqs-seed-matching-gift-scenarios.apex --target-org FundFirst
```

The enhancer is idempotent and layers on top of whatever donor size you seeded:

1. **AccountContactRelation** — inserts an ACR from every FQS Person Account
   whose `employerIdxByDonor` is set (~30% of individuals) to their assigned
   corporate employer. Lights up the flow's 40-pt "Employer via ACR" scorer
   and the ACR-based candidate query path. Prerequisite: **Setup → Account
   Settings → "Allow users to relate a contact to multiple accounts" = ON**.
2. **Aligned `GiftCommitmentId`** — sets 50% of scenario-1 corp-match GTs to
   share the employee gift's pledge commitment. Lights up the 30-pt "Same
   commitment" scorer and unlocks the pledge test case.
3. **Aligned `CampaignId`** — sets 30% of corp-match GTs to inherit the
   employee gift's campaign. Lights up the 10-pt "Same campaign" scorer.
4. **Intermediary launch-point GTs** — inserts 2 `Unpaid` GiftTransactions
   per intermediary account (4 total) with `DonorId = FQS-ACC-INT-*`. These
   are the launch points for the flow's intermediary branch (external ID
   pattern `FQS-GT-INT-<i>-<g>`).

Bounded at 5000 rows/pass; safe to re-run on the 10k dataset (existing links
are skipped by the dedupe check).

### What each Find Matching Gift path can now be tested against

| Flow path | Trigger record set |
|---|---|
| Individual→corporate happy path (ACR + program flag + amount score) | Any `FQS-GT-<idx>-<g>` on an employer-eligible Person Account, scenario 3/4 (unmatched) |
| Corporate→individual multi-select | Any `FQS-GT-CORP-<idx>-<g>` — remaining capacity ≈ 0 on scenarios 1/2, so create additional un-linked individual GTs to test allocation |
| Pledge-shared-commitment scenario | Scenario 1 corp GTs that got the commitment adopted (~50%) — 30-pt scorer fires |
| No-ACR fallback | Any Person Account whose ACR wasn't inserted (empty `employerIdxByDonor`, ~70% of individuals) |
| Amount ratio 2:1 boost | Any donor whose employer is TechCorp Global or Meridian Bank |
| Amount ratio 0.5:1 | Any donor whose employer is BlueSky Insurance |
| Annual cap ($5000/donor) | Any donor whose employer is TechCorp Global |
| Program-flag drift prompt | Any donor whose employer is Summit/Beacon/Foundry/Waypoint/Copperline (unflagged) |
| Intermediary branch | Any `FQS-GT-INT-*` (Benevity or YourCause launch points) |

## Account launcher coverage (§12)

The seed populates three sets of records specifically so every branch of the
account launcher flow (`FQS_Gift_Entry_Single_Launcher_Account`) has data to
select against instead of forcing testers into the native-lookup escape hatch:

- **CampaignMembers** — every Person Account donor gets one `CampaignMember` per
  distinct Campaign in that donor's gift history. Lights up the launcher's
  Campaign datatable. Org-donor coverage requires seeding synthetic Contacts
  under Org accounts (not covered by this seed — use the lookup escape hatch).
- **Conditional GiftCommitments + GiftDefaultDesignation** — ~30% of the
  recurring + pledged commitments carry `FulfillmentType = 'Conditional'`, and
  each such commitment has a `GiftDefaultDesignation` row (100%) pointing at a
  restricted `GiftDesignation` (Purpose / Time / Permanent, round-robin).
  Lights up the Pledge Payment → Restriction picker branch. Grants remain
  Conditional-always (unchanged).
- **Cross-household CCRs** — ~10% of Person Account donors get an active
  `ContactContactRelation` to another PA donor's Contact. Pairing is deterministic
  and always crosses two different Household Accounts, so the soft-credit datatable's
  "reach a different Account via CCR" branch is testable. All CCRs reference a
  single `PartyRoleRelation` stub named "FQS Spouse" that foundation seeds once.

Prerequisite: Setup → Account Settings → "Allow users to relate a contact to
multiple accounts" must be ON (same requirement as the matching-gift ACRs).

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

Every seeded record carries `External_Id__c` starting with `FQS-`. Teardown
filters on that prefix, so it's precise and safe. External-ID patterns:

| Object | Pattern | Example |
|---|---|---|
| Campaign (Rollup) | `FQS-CMP-ROLLUP-<FY>` | `FQS-CMP-ROLLUP-FY26` |
| Campaign (Strategy) | `FQS-CMP-STRAT-<slug>-<FY>` | `FQS-CMP-STRAT-ANNUAL-FY26` |
| Campaign (Ask) | `FQS-CMP-ASK-<slug>-<FY>` | `FQS-CMP-ASK-YEAREND-EM-FY26` |
| GiftDesignation | `FQS-GD-<slug>` | `FQS-GD-GENERAL-OPERATING` |
| OutreachSourceCode | `FQS-OSC-<ask-body>` | `FQS-OSC-SPRING-EM-FY26` |
| Account (Donor) | `FQS-ACC-<globalIdx>` | `FQS-ACC-42` |
| Account (Corporate Employer) | `FQS-ACC-CORP-<idx>` | `FQS-ACC-CORP-07` |
| GiftCommitment | `FQS-GC-<globalIdx>-<kind>` | `FQS-GC-42-pledged` |
| GiftTransaction (donor) | `FQS-GT-<globalIdx>-<g>` | `FQS-GT-42-3` |
| GiftTransaction (corp match) | `FQS-GT-CORP-<globalIdx>-<g>` | `FQS-GT-CORP-42-3` |

## Run order

### Reseed (wipe + regenerate)

```bash
# 1. Clean up prior FQS test data. On orgs with >9K FQS records, use the auto-loop
#    wrapper — each Apex invocation self-caps at ~9K DML rows (per-tx governor cap),
#    so a single-shot teardown leaves records behind on large datasets.
./scripts/apex/seed/fqs-seed-teardown-loop.sh FundFirst      # loops until 0 deletes
# — OR, for small orgs, a single pass:
sf apex run -f scripts/apex/seed/fqs-seed-teardown.apex --target-org FundFirst

# 2. Seed foundation records
sf apex run -f scripts/apex/seed/fqs-seed-foundation.apex --target-org FundFirst

# 3. Pick a size:
sf apex run -f scripts/apex/seed/fqs-seed-small.apex --target-org FundFirst
# OR
sf apex run -f scripts/apex/seed/fqs-seed-medium.apex --target-org FundFirst
# OR (large — takes ~15 min)
./scripts/apex/seed/fqs-seed-large.sh

# 4. (Optional) Layer matching-gift scenarios for the Find Matching Gift flow.
sf apex run -f scripts/apex/seed/fqs-seed-matching-gift-scenarios.apex --target-org FundFirst
```

### Verify

```bash
sf data query --target-org FundFirst --query \
  "SELECT COUNT() FROM Account WHERE External_Id__c LIKE 'FQS-ACC-%'"

sf data query --target-org FundFirst --query \
  "SELECT COUNT() FROM GiftTransaction WHERE External_Id__c LIKE 'FQS-GT-%'"

# Corporate matches specifically:
sf data query --target-org FundFirst --query \
  "SELECT COUNT() FROM GiftTransaction WHERE External_Id__c LIKE 'FQS-GT-CORP-%'"

# Eligible-but-unclaimed matches (scenario 4 + pending scenario 3):
sf data query --target-org FundFirst --query \
  "SELECT Id, DonorId, OriginalAmount, FQS_Matched__c
   FROM GiftTransaction
   WHERE External_Id__c LIKE 'FQS-GT-%'
     AND External_Id__c NOT LIKE 'FQS-GT-CORP-%'
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
- Upserts (foundation + accounts) are keyed on `External_Id__c`, so partial
  reruns are safe — records with matching IDs get updated in place.

If you want variety, change `BATCH_OFFSET` at the top of the seed scripts.
