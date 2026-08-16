# FQS Gift Entry Grid Templates — Current State

**Snapshot date:** 2026-08-04
**Retrieved from:** FundFirst (`justinsgilmore-snmm@force.com.fundfirst`)
**Metadata type:** `GiftEntryGridTemplate` (each template is a `.giftEntryGridTemplate` file whose payload is inline YAML wrapped in one big `<templateConfiguration>` XML element)

---

## 1. Repo vs. Org — what exists where

| Template | In repo | In org | Diff status |
|---|---|---|---|
| `FQS_Individual_Outright_Gifts` | yes | yes | **DIFFERS** (org has 13 columns; repo has 10) |
| `FQS_Single_Payment_Pledges` | yes | yes | clean (matches) |
| `FQS_Pledge_Payments` | yes | yes | **DIFFERS** (org has 12 columns; repo has 10) |
| `FQS_Event_Registrations` | yes | yes | **DIFFERS** (org has 12 columns; repo has 11) |
| `Cloned_Salesforce_Gift_Entry_Standard_Template` | **yes (orphaned)** | **no — you deleted it** | Delete from repo |

**Immediate cleanup needed before any authoring work:**

1. **Retrieve the 3 drifted templates** (`FQS_Individual_Outright_Gifts`, `FQS_Pledge_Payments`, `FQS_Event_Registrations`) so the repo is a truthful starting point. Any local edit on top of stale repo state will silently overwrite the fields you just added in Setup UI.
2. **Delete `Cloned_Salesforce_Gift_Entry_Standard_Template.giftEntryGridTemplate` from the repo** — you already deleted it in the org (that's why the Home Page copy references *Undefined Batch → default Salesforce Standard Template* now). Leaving the local file around would resurrect it on the next full-directory deploy.

---

## 2. What's actually in the org right now (per template)

Column order matters — this is the left-to-right order the user sees.

### 2.1 `FQS_Individual_Outright_Gifts` (13 columns) — `isSingleGiftDefault: false`

| # | Column ID | Type | Source field | Label | Default | Width |
|---|---|---|---|---|---|---|
| 1 | `Donor` | Component | `DonorId` | (donor lookup) | Individual (modal) | 240 |
| 2 | `FQS_Category` | Field | `FQS_Gift_Transaction_Category__c` | GT Category | Outright Gift | 180 |
| 3 | `GiftReceivedDate` | Field | `GiftReceivedDate` | (default) | — | 180 |
| 4 | `GiftAmount` | Field | `GiftAmount` | (default) | — | 160 |
| 5 | `PaymentMethod` | Field | `PaymentMethod` | (default) | — | 180 |
| 6 | `a30ff88e-401a-427b-9b8d-5ccdfe695004` | Field | `PaymentIdentifier` | Payment Identifier | — | 200 |
| 7 | `Designations` | Component | `GiftDesignation1Id` | (designations lookup) | — | 240 |
| 8 | `Campaign` | Field | `CampaignId` | (campaign lookup) | — | 200 |
| 9 | `FQS_MatchStatus` | Field | `FQS_Match_Status__c` | Match Status | N/A | 160 |
| 10 | `FQS_DonorTaxDate` | Field | `FQS_Donor_Tax_Date__c` | Donor Tax Date | — | 160 |
| 11 | `FQS_GT_Restriction_Release_Date__c` | Field | `FQS_GT_Restriction_Release_Date__c` | Restriction Release Date (GT) | — | 200 |
| 12 | `FQS_Fair_Market_Value_Amount__c` | Field | `FQS_Fair_Market_Value_Amount__c` | Fair Market Value | — | 200 |
| 13 | `FQS_GT_Skip_Naming__c` | Field | `FQS_GT_Skip_Naming__c` | Skip Auto Naming (GT) | — | 200 |

Repo-vs-org diff: repo does NOT yet have columns 11, 12, 13 (Restriction Release Date GT, Fair Market Value, Skip Naming GT). You added those in Setup UI.

### 2.2 `FQS_Single_Payment_Pledges` (13 columns) — `isSingleGiftDefault: false`

| # | Column ID | Type | Source field | Label | Default | Width |
|---|---|---|---|---|---|---|
| 1 | `Donor` | Component | `DonorId` | (donor lookup) | Individual (modal) | 240 |
| 2 | `GiftReceivedDate` | Field | `GiftReceivedDate` | (default) | — | 180 |
| 3 | `Commitments` | Component | `GiftCommitmentId` | (commitment column) | — | 240 |
| 4 | `GiftAmount` | Field | `GiftAmount` | (default) | — | 160 |
| 5 | `PaymentMethod` | Field | `PaymentMethod` | (default) | — | 180 |
| 6 | `OutreachSourceCode` | Field | `OutreachSourceCodeId` | (outreach lookup) | — | 200 |
| 7 | `Campaign` | Field | `CampaignId` | (campaign lookup) | — | 200 |
| 8 | `Designations` | Component | `GiftDesignation1Id` | (designations lookup) | — | 240 |
| 9 | `SoftCredits` | Component | `RecipientId` | (soft credits lookup) | — | 240 |
| 10 | `FQS_Category` | Field | `FQS_Gift_Transaction_Category__c` | Category | Pledge Payment ⚠️ | 180 |
| 11 | `FQS_GC_MatchEligible` | Field | `FQS_GC_Match_Eligible__c` | Match Eligible | — | 140 |
| 12 | `FQS_MatchStatus` | Field | `FQS_Match_Status__c` | Match Status | N/A | 160 |
| 13 | `FQS_GC_RestrictionReleaseDate` | Field | `FQS_GC_Restriction_Release_Date__c` | Restriction Release Date (Commitment) | — | 180 |

**⚠️ Bug in repo (matches org):** the `FQS_Category` default is `Pledge Payment` — but this template creates a **single-payment pledge**, so the correct default is `Pledge` (or `Single Payment Pledge`, whichever the picklist has). Confirm the intended Category picklist value and update.

### 2.3 `FQS_Pledge_Payments` (12 columns) — `isSingleGiftDefault: false`

| # | Column ID | Type | Source field | Label | Default | Width |
|---|---|---|---|---|---|---|
| 1 | `Commitments` | Component | `GiftCommitmentId` | (commitment column) | — | 240 |
| 2 | `Donor` | Component | `DonorId` | (donor lookup) | Individual (modal) | 240 |
| 3 | `GiftReceivedDate` | Field | `GiftReceivedDate` | (default) | — | 180 |
| 4 | `GiftAmount` | Field | `GiftAmount` | (default) | — | 160 |
| 5 | `PaymentMethod` | Field | `PaymentMethod` | `""` (empty) ⚠️ | — | 180 |
| 6 | `c0cabaca-bb13-432f-8b2d-6d4472198f50` | Field | `PaymentIdentifier` | Payment Identifier | — | 200 |
| 7 | `Campaign` | Field | `CampaignId` | (campaign lookup) | — | 200 |
| 8 | `Designations` | Component | `GiftDesignation1Id` | (designations lookup) | — | 240 |
| 9 | `FQS_MatchStatus` | Field | `FQS_Match_Status__c` | Match Status | N/A | 160 |
| 10 | `FQS_GT_RestrictionReleaseDate` | Field | `FQS_GT_Restriction_Release_Date__c` | Restriction Release Date | — | 180 |
| 11 | `d1cd4eaf-349d-4114-85fd-0bbaa8f6a1c9` | Field | `EffectiveStartDate` | Pledge Date (Effective Start Date) | — | 200 |
| 12 | `cf876b76-e49b-4540-bfa2-2fe5354aeb2e` | Field | `ExpectedEndDate` | Expected Payment Date (Expected End Date) | — | 200 |

Repo-vs-org diff: repo does NOT yet have columns 11 (Pledge Date) and 12 (Expected Payment Date). You added those in Setup UI.

**⚠️ Two data-modeling smells to check:**
- `PaymentMethod` column label is empty (`""`). Probably an unintended save from Setup UI. Should show the default `$Label.GiftEntryGrid.PaymentMethod` or a plain string like `Payment Method`.
- `FQS_Category` column is **missing** on this template (Outright and Single-Payment-Pledge both have it; Event Registrations has it). Question: should `FQS_Pledge_Payments` also default `FQS_Gift_Transaction_Category__c = 'Pledge Payment'`? The guided-flow monolith sets this per leaf; grid should mirror.

### 2.4 `FQS_Event_Registrations` (12 columns) — `isSingleGiftDefault: false`

| # | Column ID | Type | Source field | Label | Default | Width |
|---|---|---|---|---|---|---|
| 1 | `Donor` | Component | `DonorId` | (donor lookup) | Individual (modal) | 240 |
| 2 | `GiftReceivedDate` | Field | `GiftReceivedDate` | (default) | — | 180 |
| 3 | `Commitments` | Component | `GiftCommitmentId` | (commitment column) | — | 240 |
| 4 | `GiftAmount` | Field | `GiftAmount` | Total Amount (Gift Amount) | — | 160 |
| 5 | `FQS_FairMarketValue` | Field | `FQS_Fair_Market_Value_Amount__c` | Fair Market Value | — | 160 |
| 6 | `PaymentMethod` | Field | `PaymentMethod` | (default) | — | 180 |
| 7 | `OutreachSourceCode` | Field | `OutreachSourceCodeId` | (outreach lookup) | — | 200 |
| 8 | `Campaign` | Field | `CampaignId` | (campaign lookup) | — | 200 |
| 9 | `Designations` | Component | `GiftDesignation1Id` | (designations lookup) | — | 240 |
| 10 | `SoftCredits` | Component | `RecipientId` | (soft credits lookup) | — | 240 |
| 11 | `FQS_Category` | Field | `FQS_Gift_Transaction_Category__c` | Category | Other ⚠️ | 180 |
| 12 | `FQS_Donor_Tax_Date__c` | Field | `FQS_Donor_Tax_Date__c` | Donor Tax Date | — | 200 |

Repo-vs-org diff: repo does NOT yet have column 12 (Donor Tax Date). Added in Setup UI.

**⚠️ Category default on Event Registrations = `Other`.** The plan doc (§3.1) called for the intended default. If the picklist has `Event Registration` as a value, that's what belongs here. `Other` is a fallback.

---

## 3. Why editing has been hard (the actual friction)

### 3.1 The `.giftEntryGridTemplate` file is 400-line inline YAML inside one XML element

The whole templateConfiguration payload is wrapped in **one giant `<templateConfiguration>...</templateConfiguration>` element**. Everything visible in Setup UI's Display Columns / Donor Modal / Payment Modal / Commitment Modal is a nested list of YAML items inside that element.

Consequences:

- **YAML-inside-XML indentation is fragile.** The parser is a strict YAML parser applied to the *inner* text of the XML element. Every list item starts with a `-` at column 1 (relative to the YAML), and every child key indents 2 spaces from there. If Setup UI ever re-saves the file and inserts an extra space, or if you hand-edit and get the indent wrong, the deploy fails with an opaque parse error that doesn't tell you which column is broken.
- **XML-escaping bites you.** Empty strings must be written as `&quot;&quot;` (XML-escaped double quotes). Salesforce-managed labels are literal strings like `$Label.GiftEntryGrid.DonorLookup`. Custom labels get typed as plain YAML strings. Mixing quoting styles across columns makes diffs noisy.
- **File length grows fast.** A template with 13 columns runs 350–400 lines because each column carries `columnId`, `columnType`, a `columnField` sub-block, an optional `columnComponent` sub-block, an optional `columnModal` block (often 100+ lines when it wraps a Donor or Payment modal), plus width and label. Small changes are hard to spot in `git diff` because the surrounding boilerplate dominates.

### 3.2 Column IDs are half-semantic, half-UUID

Salesforce-shipped columns use human names (`Donor`, `GiftReceivedDate`, `PaymentMethod`, `Campaign`). Columns you add via Setup UI get **auto-generated UUIDs** (`a30ff88e-401a-427b-9b8d-5ccdfe695004`, `c0cabaca-bb13-432f-8b2d-6d4472198f50`, `d1cd4eaf-349d-4114-85fd-0bbaa8f6a1c9`, `cf876b76-e49b-4540-bfa2-2fe5354aeb2e`).

Consequences:

- **You can't grep for "Payment Identifier column"** — it's a UUID. You have to open the file and eyeball the `sourceField:` to know what a column is.
- **Reordering columns loses the UUID's link to intent.** If you delete a UUID-ID'd column and re-add it via Setup UI, you get a *new* UUID. Git diff shows a delete + add rather than a modify, and any downstream reference (there aren't many, but scripts and reports could reference by columnId) breaks.
- **The plan doc says "all FQS-added columns use semantic IDs prefixed `FQS_*`"** — that was true for Phase 1 shipped 2026-08-03 (see [fqs-gift-entry-grid-templates-plan.md](fqs-gift-entry-grid-templates-plan.md) §5.3). But **the columns you added via Setup UI *after* Phase 1 landed with UUID IDs**, breaking that convention. This is why the Outright template mixes:
  - `FQS_Category`, `FQS_MatchStatus`, `FQS_DonorTaxDate` (semantic — from Phase 1's source deploy)
  - `FQS_GT_Restriction_Release_Date__c`, `FQS_Fair_Market_Value_Amount__c`, `FQS_GT_Skip_Naming__c` (**named after the field API** — from Setup UI adds)

### 3.3 Setup UI and source deploys write different XML

When you add a column in Setup UI, Salesforce saves the template as a **fresh XML blob**. That blob is not byte-identical to what a source deploy would produce even for the same logical state:

- Setup UI often uses the field API name as the `columnId` when you add a custom field column, resulting in the `FQS_GT_Restriction_Release_Date__c`-style IDs.
- Setup UI can drop or add whitespace / trailing-newline conventions that git flags as diff even when the semantic content is unchanged.
- Setup UI sometimes stores `columnLabel: &quot;&quot;` when you clear a label — hand-writing that in the repo is easy to get wrong.

### 3.4 The FieldMappingConfig is the *actual* controller of what happens on commit

The grid template only decides **which columns the user sees**. The commit-time fanout from `GiftEntry` → `GiftTransaction` / `GiftCommitment` / `GiftDefaultDesignation` etc. is controlled by `FieldMappingConfig`. Two consequences:

- **Adding a column to a template does not mean the field lands anywhere.** If the FieldMappingConfig doesn't have an entry mapping `GiftEntry.FQS_X__c` → the destination sObject field, the value on that column is silently discarded on commit. Every new FQS staging-mirror field on GiftEntry needs both a template column AND a FieldMappingConfig entry.
- **The FieldMappingConfig has its own [DX-vs-mdapi processType bug](../MEMORY.md#fieldmappingconfig-metadata-type) and drops new mappings on redeploy.** So even if you fix the template correctly, the mapping layer may need a Tooling-API-based add rather than a source deploy.

### 3.5 The plan doc is stale

[fqs-gift-entry-grid-templates-plan.md](fqs-gift-entry-grid-templates-plan.md) documents "Phase 1 SHIPPED 2026-08-03" with column counts of 8 / 11 / 9 / 7 for the 4 FQS-labeled templates. Today's actual counts are **13 / 13 / 12 / 12**. The plan doc doesn't reflect the Setup UI adds you made after Phase 1 landed.

- Phase 3 documentation follow-up (plan §6) never happened.
- The plan's §3.3 UAT gate ("open each template in Setup → Gift Entry Templates → Display Columns and confirm") has been done implicitly (you added columns from there) but not written down.

---

## 4. Recommended path forward

**Step 1 — Truth up the repo.** Retrieve the 4 live templates from FundFirst, commit the result as a snapshot commit (message: "Snapshot GiftEntryGridTemplates from FundFirst post-Setup-UI edits"). Delete the orphan `Cloned_Salesforce_Gift_Entry_Standard_Template.giftEntryGridTemplate`. After this commit, `git diff` between repo and org is clean and future changes are attributable.

**Step 2 — Fix the two config-level smells found in §2.** Both are one-line YAML edits:

- `FQS_Single_Payment_Pledges` → change `FQS_Category` default from `Pledge Payment` to the correct picklist value for a single-payment pledge (likely `Pledge` or `Single Payment Pledge`).
- `FQS_Event_Registrations` → change `FQS_Category` default from `Other` to `Event Registration` if that value exists on the `FQS_Gift_Transaction_Category__c` GVS.
- `FQS_Pledge_Payments` → decide whether to add an `FQS_Category` column with default `Pledge Payment` (matches the other three templates).
- `FQS_Pledge_Payments` → restore a non-empty `columnLabel` for the `PaymentMethod` column.

**Step 3 — Normalize column IDs.** Rename the 4 UUID-ID'd columns and the 4 field-API-named ones to semantic `FQS_*` IDs so grep works everywhere. This is a source-level edit, deploy, verify.

**Step 4 — Update the plan doc.** Move `Phase 1` numbers to reflect what actually shipped after Setup UI additions (13 / 13 / 12 / 12), tick off §3.3 UAT for the columns that have been in-org-tested, and either close out the plan doc as "Phase 1 shipped, Phase 2 deferred" or move it into `.planning/archive/`.

**Step 5 — Only then start authoring new changes.** With the repo matching the org and the config smells fixed, hand edits become tractable — you can preview a change in a diff, deploy it as a source file, and Setup UI reflects it. The rule that has been broken up to now is: **don't edit templates in Setup UI when the repo is your source of truth.** Every Setup UI save creates drift you have to reconcile.

---

## 5. Metadata gotchas already logged for this type

From [MEMORY.md](../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/MEMORY.md):

- **[fieldmappingconfig-metadata-type](../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/fieldmappingconfig-metadata-type.md)** — the FieldMappingConfig side of grid templates has its own DX-vs-mdapi processType placement bug + silently drops new items on redeploy; use Tooling API. One sourceField maps to only one destination.

No `giftEntryGridTemplate`-specific memory has been recorded yet. Candidate learnings to capture if any of the following surface again:

- YAML-inside-XML indentation errors on deploy (produce a memory)
- Setup UI writes columnId=`<FieldApi__c>` rather than a semantic `FQS_*` slug (produce a memory)
- Deleting a template's file locally + redeploy does not delete the org-side template — needs a destructiveChanges package (verify then produce a memory)
