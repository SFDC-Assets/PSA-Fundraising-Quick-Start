# FQS Duplicate Rules — Plan

**Status:** shipped 2026-07-25 (deploys `0AfWB00000Dbblt0AB` MatchingRules, `0AfWB00000Dbbyn0AB` Contact rule, `0AfWB00000DbcQD0AZ` Account rules)
**Owner:** solo (Justin)
**Depends on:** none (uses only existing Account/Contact/Opportunity fields)

---

## 1. Purpose

Protect donor identity across the FQS surface. The accelerator's matching-gift pairing, household consolidation, and Legacy giving import path all assume donors are unique — a duplicate Account/Contact splits their giving history, breaks corporate-match intermediary detection, and causes duplicate Gift Commitment / Gift Transaction chains during retro data entry.

Salesforce ships standard MatchingRules for Account and Contact, but they default to *inactive*. Neither the FQS nor SMQS repo ships dedup metadata today (both READMEs point admins to Setup and hope for the best). This plan closes that gap with a small set of DuplicateRules keyed off donor identity signals FQS already writes.

## 2. Phase 0 findings

Landscape audit (2026-07-25):

- **Nothing exists yet.** No `duplicateRules/` or `matchingRules/` directories in the FQS repo. Placeholder row already reserved in `.planning/fqs-release-readiness.md`.
- **No SMQS shape to copy.** SMQS ships identical README dedup prose but no metadata — greenfield either way.
- **Fundraising Cloud managed dedup rules — none detected** in the `frops_flow` / `frops` namespace scan.
- **Standard MatchingRules** (`Standard_Account_Match_Rule_v1_0`, `Standard_Contact_Match_Rule_v1_0`) are available on every org but default inactive. Activation is a metadata deploy — no need to author custom Matching Rules for the standard fields; only author custom rules for signals the standards don't cover.
- **FQS already writes strong deterministic keys.** `External_Id__c` (Text 64, `externalId=true`, `caseSensitive=true`) ships on Account **and** Opportunity — pattern `FQS-<OBJ>-<idx>[-<subidx>]`. Contact is not customized in the FQS repo (no Contact object directory), so Contact dedup rides on standard fields only.
- **Account record types split donor shape.** FQS uses `Account.PersonAccount` for individual donors and `Account.Organization` for corporate/foundation donors. Rules that make sense for individuals (name + email) differ from rules for organizations (name + billing city). Rules must filter by record type.

## 3. Scope

**In scope**

- Author 2 custom MatchingRules (Account Organization donor match; Opportunity donor+campaign match)
- Author 4 DuplicateRules (Account/Person Account, Account/Organization, Contact, Opportunity)
- Retrieve + activate the standard `Standard_Account_Match_Rule_v1_0` (via re-emitting active copy) and `Standard_Contact_Match_Rule_v1_0` for Person Account + Contact defaults
- All rules default to `alertText` = warn (Allow Save = true) — no hard block. FQS is an accelerator, not a gate; admins can flip to Block per org policy.
- Deploy pattern: hand-authored XML, retrievable, versioned in repo, iterable in Setup UI post-deploy.

**Out of scope**

- Lead dedup (FQS does not use Lead)
- CRM-wide fuzzy address canonicalization (would require an AppExchange package)
- Person Account / Household merge rules (`Fundraising` handles household consolidation via `PartyRelationshipGroup`)
- Runtime auto-merge (Salesforce dedup surfaces duplicates in the UI; merging is a manual admin action)

## 4. Design

### 4.1 Rule inventory

| Rule | Object | Scope filter | Matching key | Action |
|---|---|---|---|---|
| `FQS_Account_Organization_Dupe` | Account | RecordType.DeveloperName = `Organization` | Custom MR `FQS_Account_Organization_Match` (Name exact + BillingCity exact) OR `External_Id__c` exact | Warn |
| `FQS_Account_Person_Dupe` | Account | RecordType.DeveloperName = `PersonAccount` | `Standard_Account_Match_Rule_v1_0` (FirstName fuzzy + LastName exact + Email exact) OR `External_Id__c` exact | Warn |
| `FQS_Contact_Dupe` | Contact | (no filter) | `Standard_Contact_Match_Rule_v1_0` (Email exact primary; FirstName fuzzy + LastName exact + Phone exact secondary) | Warn |
| `FQS_Opportunity_Donor_Dupe` | Opportunity | (no filter) | Custom MR `FQS_Opportunity_Donor_Match` (AccountId + CampaignId + CloseDate exact) OR `External_Id__c` exact | Warn |

The Opportunity rule catches a specific FQS failure mode: staff enter the same gift twice (once via the launcher, once by paste-import) — same donor, same campaign, same close date → high-confidence duplicate. Amount is intentionally NOT part of the key because partial re-entries of installment splits would false-negative.

### 4.2 New metadata files

**MatchingRules (2 custom + 2 standard-reactivated)**

- `force-app/main/default/matchingRules/Account.matchingRule-meta.xml`
  - Reactivate `Standard_Account_Match_Rule_v1_0`
  - Add custom `FQS_Account_Organization_Match` — 2 criteria: `Name` (Exact) + `BillingCity` (Exact), boolean AND

- `force-app/main/default/matchingRules/Contact.matchingRule-meta.xml`
  - Reactivate `Standard_Contact_Match_Rule_v1_0`

- `force-app/main/default/matchingRules/Opportunity.matchingRule-meta.xml`
  - Custom `FQS_Opportunity_Donor_Match` — 3 criteria: `AccountId` (Exact) + `CampaignId` (Exact) + `CloseDate` (Exact), boolean AND

**DuplicateRules (4)**

- `force-app/main/default/duplicateRules/Account.FQS_Account_Organization_Dupe.duplicateRule-meta.xml`
- `force-app/main/default/duplicateRules/Account.FQS_Account_Person_Dupe.duplicateRule-meta.xml`
- `force-app/main/default/duplicateRules/Contact.FQS_Contact_Dupe.duplicateRule-meta.xml`
- `force-app/main/default/duplicateRules/Opportunity.FQS_Opportunity_Donor_Dupe.duplicateRule-meta.xml`

Each DuplicateRule ships with:
- `isActive = true`
- `operationsOnCreate.allowSave = true` + `operationsOnUpdate.allowSave = true` (Warn, not Block)
- `alertText` = admin-facing text explaining the match key
- `duplicateRuleFilter` block for RecordType filter where applicable
- `duplicateRuleMatchRules` block pointing at the matching rule(s) above
- `securityOption` = `ENFORCE_SHARING_RULES`

### 4.3 Field-level considerations

- `Account.External_Id__c` is already `unique=true, caseSensitive=true` — the platform already rejects duplicate External_Ids at insert. The DuplicateRule's External_Id branch is belt-and-suspenders for the UI-warn path (fires *before* the DML error and gives staff a clearer message than the platform's constraint error).
- `Opportunity.External_Id__c` — same pattern.
- No new fields needed. Every matching key already exists on the target object.

### 4.4 Rule interaction with Account.External_Id__c unique constraint

Because `Account.External_Id__c.unique = true`, any External_Id collision hits `DUPLICATE_VALUE` at DML time regardless of the DuplicateRule. The DuplicateRule fires first in the UI insert path, so users see the FQS warn message and can navigate to the existing record. Data-loader and API inserts still get the DUPLICATE_VALUE — behavior is layered defense, not either/or.

Consider setting `Account.External_Id__c.unique = false` if the DuplicateRule's Warn-not-Block behavior needs to hold for API inserts too. **Deferred decision** — first deploy keeps the platform constraint intact.

## 5. Deploy sequence

1. Retrieve the current `Standard_Account_Match_Rule_v1_0` + `Standard_Contact_Match_Rule_v1_0` from FundFirst (`sf project retrieve start --metadata MatchingRule:Account.Standard_Account_Match_Rule_v1_0` etc.) — captures the exact standard rule DeveloperName/version so we can reactivate cleanly.
2. Author `Account.matchingRule-meta.xml` + `Contact.matchingRule-meta.xml` + `Opportunity.matchingRule-meta.xml` with the custom rules + reactivated standard rules.
3. Author 4 `.duplicateRule-meta.xml` files.
4. `sf project deploy start` — a single deploy covers all 7 files (3 MatchingRule + 4 DuplicateRule).
5. Smoke test in FundFirst:
   - Create a duplicate Organization Account (same Name + BillingCity as an existing FQS-seeded org). Confirm warn appears + link to existing record works.
   - Create a duplicate Person Account (same first/last/email). Confirm standard rule fires.
   - Create a duplicate Opportunity (same AccountId + CampaignId + CloseDate). Confirm warn.
   - Attempt an External_Id collision on Account. Confirm the FQS DuplicateRule warns before the platform DUPLICATE_VALUE fires.
6. Update tracker row from placeholder to shipped; capture UI screenshots for future admin docs.

## 6. Testing checklist

| Case | Expected |
|---|---|
| Insert Org Account matching Name + BillingCity of seed row | Warn, link to existing |
| Insert Org Account matching only Name (different city) | No warn (name alone isn't a match key) |
| Insert Org Account with duplicate External_Id (UI) | Warn (DuplicateRule first) |
| Insert Org Account with duplicate External_Id (Data Loader / Apex) | `DUPLICATE_VALUE` (platform constraint) |
| Insert PersonAccount matching seed donor first/last/email | Warn |
| Insert Contact matching seed contact email | Warn |
| Insert Opportunity matching AccountId + CampaignId + CloseDate | Warn |
| Insert Opportunity matching AccountId + CampaignId, different CloseDate | No warn |
| Data Loader bulk load with duplicates in the batch | Warn per row + platform bulk semantics (rules honor bulk API when `securityOption` allows) |

## 7. Follow-on work

- **Contact FQS customization gap.** Contact has no FQS field additions today. If future FQS features need Contact-level dedup harder than "email exact", the plan should be revisited to add a Contact `External_Id__c` + FQS canonicalization signals. Not blocking this plan.
- **Block-not-Warn per policy.** Every DuplicateRule ships with Warn. Orgs that want hard-block can flip `allowSave=false` in Setup or via a per-org overlay. Adding an org-config metadata flag to toggle this centrally is future work.
- **SMQS parity.** SMQS README duplicates the same placeholder prose. Once FQS ships these rules, echo the shape into SMQS (translate `Account.Organization` → `Account.Group` per memory `fundfirst-account-recordtypes`).

## 8. Deploy learnings — DuplicateRule / MatchingRule XML gotchas

Discovered while iterating on this plan. All non-obvious, all necessary for the deploy to succeed.

1. **`<matchingMethod>` not `<matchCriteria>`.** The MatchingRule child element for the match criterion is `<matchingMethod>` (Exact / Fuzzy / etc). Schema doc-name mismatch cost one deploy cycle.
2. **DuplicateRules require `<actionOnInsert>Allow</actionOnInsert>` + `<actionOnUpdate>Allow</actionOnUpdate>` at the top of the file.** These two are separate from `<operationsOnInsert>Alert/Report</operationsOnInsert>`. Without them the deploy fails with a generic "unexpected error" that reveals nothing — surface-level `operationsOn*` alone won't parse into a valid rule. The real error message ("Select an account matching rule only once") only surfaces when `actionOn*` is present.
3. **On Account, a DuplicateRule can reference each MatchingRule only ONCE.** Two `<duplicateRuleMatchRules>` blocks pointing at two different MatchingRules is fine; two blocks with the same MatchingRule fails. To fire on multiple match rules (e.g., Name+City OR External_Id), split into multiple DuplicateRules.
4. **`operationsOnInsert` and `operationsOnUpdate` accept both `Alert` and `Report`.** Cargo-culted from `Standard_Account_Duplicate_Rule.duplicateRule` — both are needed; missing `Report` may or may not fail deploy but is the shape platform-shipped rules use.
5. **`duplicateRuleFilter` needs `xsi:nil="true"` when unfiltered.** Do NOT hand-author the `<duplicateRuleFilterItems>` block with `<field>RecordType.DeveloperName</field>` — that syntax parses but fails cryptically. RecordType filtering is best done via a separate `PersonAccount.<Name>.duplicateRule` (PersonAccount is its own top-level SObjectType for dedup), not via filter items on `Account.<Name>.duplicateRule`.
6. **Descriptions on both MatchingRule and DuplicateRule are hard-capped at 255 chars.** Salesforce silently truncates in Setup UI but rejects deploys.
7. **`Opportunity` is not a valid object for DuplicateRule.** The platform only supports Account, Contact, Lead, PersonAccount, and a small set of custom-enabled objects. Opportunity dedup requires an off-platform tool or a custom validation rule + trigger.
8. **SortOrder must be sequential from 1 with no gaps.** Account has Standard=1 already, so FQS rules take 2 and 3. If Organization=2 fails to deploy, Person's sortOrder=3 leaves a gap and Salesforce rejects the deploy. Deploy in dependency-safe order or use gap-free numbering.
9. **MatchingRules must be committed BEFORE DuplicateRules that reference them.** Two-deploy pattern: `sf project deploy start --source-dir matchingRules` first, then `--source-dir duplicateRules`. Same-deploy = "unexpected error" cascade.
10. **Standard MatchingRule internals are not retrievable via source API.** `sf project retrieve start --metadata "MatchingRule:Account.Standard_Account_Match_Rule_v1_0"` returns an empty `Account.matchingRule` file. Custom rules live in the same bundle but retrieve fine; standard rule internals are platform-hidden.

## 9. Related memory + docs

- `fundfirst-account-recordtypes` — Account.Organization (FQS) vs Account.Group (SMQS) record-type mapping
- `fqs-crt-deploy-pattern` — for reference on FundFirst-only deploy iterations
- Tracker placeholder row in `.planning/fqs-release-readiness.md` (line ~374)
