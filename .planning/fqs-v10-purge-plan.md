# FQS v1.0 OSS Cutdown — Purge & Rework Plan

**Goal.** Trim the FQS repo + ProdFund org to a clean unmanaged v1.0 open-source package. Every decision below was adjudicated in the 2026-08-17 session against the manifest agent output (520 members), the inventory doc (`docs/fqs-metadata-inventory.md`, 21 flagged), and the ProdFund package-builder list (347 shown).

**Companion artifacts:**

- [`manifest/package.xml`](../manifest/package.xml) — canonical member list; edit alongside this plan
- [`docs/fqs-metadata-inventory.md`](../docs/fqs-metadata-inventory.md) — inventory of every FQS-owned item
- [`.planning/fqs-release-readiness.md`](fqs-release-readiness.md) — parent tracker; Phase-6 gate updates land here after v1.0 ships

**Execution rule.** No item below is destructive until Justin marks it approved. Every `[ ]` is a candidate; `[approved]` fires the change.

---

## Section 1 — Repo removals

### 1.1 Metadata to delete from `force-app/main/default/`


| Item                                                 | Path                                                                                | Reason                                                                                                                                                                           |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [x]`Account-Account Layout` (base)                   | `objects/Account/layouts/Account-Account Layout.layout-meta.xml`                    | Non-FQS Salesforce default; FQS ships the`-FQS Account Layout` overlay only                                                                                                      |
| [x]`PersonAccount-Person Account Layout` (base)      | `objects/PersonAccount/layouts/PersonAccount-Person Account Layout.layout-meta.xml` | Same rationale                                                                                                                                                                   |
| [x]`GiftDesignation-Gift Designation Layout`         | `objects/GiftDesignation/layouts/…`                                                | Not needed — only the Campaign layout survives on the layout side                                                                                                               |
| [x]`GiftTransaction-Gift Transaction Layout`         | `objects/GiftTransaction/layouts/…`                                                | Same rationale                                                                                                                                                                   |
| [ ]`Opportunity-FQS Opportunity Layout`              | `objects/Opportunity/layouts/…`                                                    | Same rationale                                                                                                                                                                   |
| [x]`standard__FundraisingOperationsConsole.app`      | `applications/standard__FundraisingOperationsConsole.app-meta.xml`                  | Fundraising-Cloud-shipped; drop the override                                                                                                                                     |
| [x]`FQSDonorGroupingReports.reportFolder`            | `reports/FQSDonorGroupingReports.reportFolder-meta.xml`                             | Deprecated empty folder (superseded by`FQSDonorTierReports`)                                                                                                                     |
| [x]`FQS_Campaign_Hierarchy_Setup__mdt` type + fields | `objects/FQS_Campaign_Hierarchy_Setup__mdt/`                                        | No longer used per Justin 2026-08-17; delete type + 5 fields<br /><br /><br /><br />Action: confirm no longeer used                                                              |
| [x]`Campaigns_and_Gift_Transactions.reportType`      | `reportTypes/Campaigns_and_Gift_Transactions.reportType-meta.xml`                   | Replaced by`Campaign_Deluxe` — **PRE-CHECK required**: `grep -rln Campaigns_and_Gift_Transactions force-app/` must return zero non-metadata refs before delete                  |
| [ ]`~125 help-text-only field overlays`              | `objects/*/fields/<Standard>.field-meta.xml`                                        | If a standard field carries only`<description>` / `<inlineHelpText>` and no picklist values, move copy → `docs/fqs-post-config-help-text.md`; delete field-meta.xml<br /><br /> |

Action: Don't delete the file, just keep out of manifest and repo.  |
| [X]`FQS_Manage_Gift_Commitment_Actions.flow`      | `flows/…`                                                                                                                    | Deferred to future release; move to holding folder (see §3.2)                                                                                                                                                                                |
| [x]`FQS_Match*.cls` (3 classes + test)               | `classes/FQS_MatchCandidate.cls`, `FQS_MatchCandidateService.cls`, `FQS_MatchCommitService.cls`, `FQS_MatchServices_Test.cls` | Deferred alongside`FQS_Find_Matching_Gift`; move to holding folder                                                                                                                                                                            |

### 1.2 Investigation-first (do NOT delete until confirmed)


| Item                                                         | Investigate                                                                                                                                               | If clean, action                                                |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [ ]`FQS_Email_Template_Builder_Permission.permissionset`     | Read the permset; identify what FLS/object grants it makes. If it's purely record-type visibility for the email templates, merge into`FQS_Custom_Fields`. | Merge + delete permset file                                     |
| [x]`FQS_Campaign_Fields.permissionset`                       | Grep for user-assignment refs; check README for post-install step naming it.                                                                              | Drop OR add to README                                           |
| [x] Global QAs`FQS_New_Grant` + `FQS_New_Major_Gift`         | Confirm not referenced by any flexipage; confirm no in-org publisher-layout dependency.                                                                   | Delete both`.quickAction-meta.xml` files                        |
| [ ] 4`FQSRecordPageReports/*` reports with hash-suffix names | Confirm each is referenced by a`flexipage:reportChart` component.                                                                                         | Keep (per Justin 2026-08-17 "should all be solid and workable") |

---

## Section 2 — Repo edits

### 2.1 Label / rename changes


| Component                                    | Change                                                            | Purpose           |
| -------------------------------------------- | ----------------------------------------------------------------- | ----------------- |
| [x]`Opportunity.Grant` record type           | Label:`Grant` → `Grant Request`                                  | Justin 2026-08-17 |
| [x]`Opportunity.Major_Gift` record type      | Label:`Major Gift` → `Major Gift Plan`                           | Justin 2026-08-17 |
| [x] Auto-name flows (`FQS_Auto_Name_*` × 3) | Add "Type" to the label — awaiting Justin clarification on scope | Justin 2026-08-17 |

### 2.2 Splits & consolidations


| Item                                              | Action                                                                                                                                                                       |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [x]`Campaigns_and_Gift_Transactions` CRT          | Consolidate into`Campaign_Deluxe`. Update any reports depending on the retired CRT to `<baseObject>Campaign_Deluxe</baseObject>` before destructive-delete                   |
| [ ] Non-FQS-prefixed field overlays (~125 fields) | Extract`<description>` + `<inlineHelpText>` content into `docs/fqs-post-config-help-text.md` grouped by object; delete field-meta.xml files; add README post-install pointer |

### 2.3 Classic → Lightning email templates

Convert three Classic templates in `force-app/main/default/email/FQS_Templates/`:

- [X]  `FQS_Gift_Acknowledgement.email` → Lightning `EmailTemplate`
- [X]  `FQS_Gift_Acknowledgement_Partial.email` → Lightning `EmailTemplate`
- [X]  `FQS_Stewardship_Response_Standard.email` → Lightning `EmailTemplate`

For each: preserve body/subject verbatim, migrate merge fields to Lightning `{{{Recipient.Field__c}}}` syntax where needed, verify the referencing flows (`FQS_Gift_Acknowledgement`, `FQS_Stewardship_Response`) can bind the new templates by DeveloperName.

---

## Section 3 — Repo additions

### 3.1 Test coverage

- [X]  `FQSSeedGenerator.cls` (1851 lines, currently `.forceignore`d for 0% coverage). Author `FQSSeedGenerator_Test.cls` targeting **≥75%** so the class can rejoin the package. Strategy: exercise the public `seedFoundation` / `seedSmall` / `seedMedium` entrypoints in `Test.startTest()` / `Test.stopTest()` blocks with a `Test.setMock` where the class hits external systems.

### 3.2 Deferred-work holding folder

- [X]  Create `.deferred/v1.1-match-feature/` at repo root (or your preferred convention — `.deferred/` vs `.tmp/` vs `.parked/`).
- [X]  Move (`git mv`) into it:
  - `FQS_Find_Matching_Gift.flow-meta.xml` (if still in tree)
  - `FQS_Manage_Gift_Commitment_Actions.flow-meta.xml`
  - `FQS_MatchCandidate.cls` + `FQS_MatchCandidateService.cls` + `FQS_MatchCommitService.cls` + `FQS_MatchServices_Test.cls`
- [X]  Add `.deferred/` to `.forceignore` so nothing there deploys.
- [X]  Add a `.deferred/README.md` explaining scope + intended re-integration path.

### 3.3 New docs

- [X]  `docs/fqs-post-config-help-text.md` — content extracted from the ~125 field overlays being deleted from `force-app/`.

---

## Section 4 — Package manifest updates

Update [`manifest/package.xml`](../manifest/package.xml) to reflect all §1 and §2 removals + §3.1 re-inclusion:

- [X]  Remove 5 layout entries (§1.1)
- [X]  Remove `standard__FundraisingOperationsConsole` from `<name>CustomApplication</name>`
- [X]  Remove `FQSDonorGroupingReports` from `<name>ReportFolder</name>`
- [X]  Remove `FQS_Campaign_Hierarchy_Setup__mdt` from `<name>CustomObject</name>` and any `<members>` under `<name>CustomField</name>` prefixed with it
- [X]  Remove `Campaigns_and_Gift_Transactions` from `<name>ReportType</name>`
- [ ]  Remove `~125 <members>` from `<name>CustomField</name>` (help-text-only overlays)
- [X]  Remove `FQS_Manage_Gift_Commitment_Actions` + `FQS_Find_Matching_Gift` from `<name>Flow</name>`
- [X]  Remove 3 `FQS_Match*` classes from `<name>ApexClass</name>`
- [ ]  Add `FQSSeedGenerator` to `<name>ApexClass</name>` (post-test-coverage)
- [ ]  Add `FQSSeedGenerator_Test` to `<name>ApexClass</name>`
- [X]  Investigate: figure out `fieldMappingConfigs/FieldMappingConfig.fieldMappingConfig` (v67 schema violation) so it can ship. Options: (a) hand-author XML that satisfies `processType`, (b) ship the file via mdapi format instead of source format, (c) document manual admin-created steps in README.

---

## Section 5 — Org purges (FundFirst + ProdFund)

### 5.1 ProdFund destructive deletes


| Component                                                                                                        | Purge command                                                                                                                                                                                                      |
| ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [x] Old Donor Grouping CMDT + records + fields + layout (`FQS_Donor_Grouping__mdt`, 3 records, 4 fields, layout) | Destructive-changes deploy — 4-file bundle                                                                                                                                                                        |
| [x] 9`__MISSING LABEL__ PropertyFile - val MRU` list-view refs                                                   | Remove via package-builder UI (Setup → Package Manager)                                                                                                                                                           |
| [x]`FQS_Manage_Gift_Commitment_Actions` flow + all versions                                                      | Tooling API deactivate + delete (per[`flow-destructive-delete-workaround`](../../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/flow-destructive-delete-workaround.md)) |
| [x]`FQSDonorGroupingReports.reportFolder`                                                                        | Destructive delete                                                                                                                                                                                                 |
| [x]`FQS_Campaign_Hierarchy_Setup__mdt` if it exists in org                                                       | Destructive delete                                                                                                                                                                                                 |
| [x] All records of`FQS_Donor_Grouping__mdt`                                                                      | Destructive delete                                                                                                                                                                                                 |
| [x] Global QAs`FQS_New_Grant` + `FQS_New_Major_Gift` (if removed from repo)                                      | Destructive delete                                                                                                                                                                                                 |

### 5.2 FundFirst destructive deletes

FundFirst is likely already ahead of ProdFund on Donor Grouping purges (see tracker line 226 — deploys `0AfWB00000E0mXe0AJ` etc.). Confirm state before firing anything.

- [X]  Retrieve current FundFirst state of the Section 5.1 candidates
- [X]  Fire only the items that still exist in the org

---

## Section 6 — Investigations still owed


| Item                                              | Question                                                                                                                                                                                   | Blocking            |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------- |
| [x] Auto-name flows label "Add Type to the label" | Which specific label element? File-name label / interviewLabel / flow description? Which of the 3 flows? All flows should have Fufillment Type in the flow name                            | §2.1 auto-name row |
| [x]`FieldMappingConfig.fieldMappingConfig`        | v67 schema bug workaround — which path?                                                                                                                                                   | §4 last row        |
| [ ] Action Plan Templates                         | Are`Moves_Management` + `Stewardship` (hash-suffix names) actually FQS-authored or Fundraising-Cloud auto-imports? Justin says keep — verify origin so we can rename to `FQS_*` if needed | v1.0 ship           |
| [ ]`batchCalcJobDefinitions/**`                   | Low priority, currently`.forceignore`d — confirm final decision                                                                                                                           | Post-v1.0           |

---

## Section 7 — Execution order

Suggested phasing so each pass is atomic and reversible:

1. **Investigations** (§6, §1.2) — batch 4-6 grep/read passes, no writes.
2. **Repo edits** (§2.1, §2.2 partial) — labels + rename only; no deletes yet.
3. **Repo additions** (§3.2, §3.3) — create `.deferred/` folder + docs skeleton.
4. **Repo removals** (§1.1) — delete files, `git mv` deferred items into `.deferred/`.
5. **Test coverage** (§3.1) — `FQSSeedGenerator_Test.cls`; run validate against a scratch org.
6. **Manifest update** (§4) — rewrite `manifest/package.xml` to match new tree.
7. **Org destructive** (§5.1, §5.2) — FundFirst first, ProdFund second.
8. **Validate** — `sf project deploy validate --target-org FundFirst --manifest manifest/package.xml --test-level RunLocalTests`; then same against a fresh scratch org.

---

## Approvals

Justin marks `[approved]` inline next to any `[ ]` item they want fired. Anything not approved stays a candidate.
