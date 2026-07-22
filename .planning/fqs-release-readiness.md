# FQS Release Readiness Tracker

**One human, many agents.** This file is the single source of truth for shipping the FQS accelerator to production. Every subagent invocation for release work reads this file first and writes progress back into it.

**Last updated:** 2026-07-22
**Target org:** FundFirst (production)
**Current branch:** `main`
**Owner:** Justin (solo)

**Reference — shipped shape:** SMQS (`~/GitHubRepos/PSA-Stakeholder-Management-Quick-Start-DEV`) is the reference for "what a shipped GPS Accelerator looks like." See the [SMQS Reference Shape](#smqs-reference-shape-what-shipped-looks-like) appendix below. Notable gaps SMQS *has* that FQS also needs, and notable gaps SMQS *lacks* that FQS should not replicate, are called out per phase.

**Related context:**
- `.planning/session-history.md` — chronological index of past Claude Code sessions with topics + transcript paths. Use to reconstruct why a plan or file exists before deciding its fate.
- Nine open `.planning/fqs-*-plan.md` files — one per in-flight feature.

---

## Resume Protocol (session-start)

**Trigger phrase (exact or close):** *"Let's pick up the FQS project. Where did I leave off and what status updates do you need?"*

When the agent sees this trigger, execute the four steps below **in order, without deviation.** Same input → same output shape → no rediscovery drift.

### Step 1 — Silent Read (agent does this alone, no user input)

Read, in this order:
1. This file (`.planning/fqs-release-readiness.md`) — full
2. `.planning/session-history.md` — last 5 entries only
3. `git status --short` — mechanical uncommitted state
4. `git log --oneline -10` — recent shipped work
5. Any `.planning/fqs-*-plan.md` file modified in the last 7 days (check mtime or `git log --since=7.days`)
6. This project's [MEMORY.md](../../../.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/MEMORY.md) — auto-loaded, but explicitly verify anything cited from memory against current state before asserting it as fact

Do not read the entire nine-plan set; do not spawn Explore agents; do not `sf project retrieve`. This step is bounded and fast (~30 seconds).

### Step 2 — Status Report (fixed 5-section format)

Emit a status report in **exactly this structure** — no more, no less:

```
## Where you left off

**Last commit:** <SHA> · <date> · <one-line message>
**Uncommitted work:** <top 3–5 items, grouped by plan file when possible>

## Phase state

<copy the Phase Status table from tracker header verbatim>

## Ready to execute (candidate slate)

<3–5 concrete tasks, each sized for one agent in one work-session>
- Each item: <task name> · <phase> · <linked plan> · <estimated agent minutes>
- Each item marked [P] for parallel-safe with the others, or [S] for sequential

## Blocked / needs-decision

<items where the tracker or plan explicitly asks for a decision that hasn't been made>
```

Keep it under 40 lines. Cite file paths as markdown links using the VSCode conventions in the repo CLAUDE.md.

### Step 3 — Fixed Quiz (AskUserQuestion, ≤4 questions)

Ask **exactly these questions**, in this order, using `AskUserQuestion` (one call, all questions batched):

1. **Focus phase** (single-select) — "Which phase should this session drive?" Options: dynamic — pull from the Phase Status table, showing only phases in state `in-progress` / `not-started` / `blocked`. Recommend the earliest unblocked phase.
2. **FundFirst drift state** (single-select) — "Any UI edits in FundFirst since our last session?" Options: `In sync — no changes` / `Some edits, unclear which` / `Yes, specific edits I'll describe` / `Don't know`. This determines whether P2 sync needs to happen before executing anything that touches org-authoritative metadata.
3. **Task selection** (multi-select) — "Pick 2–3 tasks from the ready-to-execute slate." Options: the items from Step 2's slate, verbatim.
4. **Locked decisions or new context** (single-select, conditional — only ask if any candidate task has an open question in its plan) — "Any decisions since our last session that the agents need to know?" Options: `No — plans are current` / `Yes — I'll describe`.

Do not invent additional questions. If something else needs answering, surface it in the agent prompts as an explicit "confirm before executing" line.

### Step 4 — Agent Prompts (5-part contract template)

For each selected task, emit **exactly one prompt block** in this shape:

```
### Agent N — <short label>

**Type:** <Explore | general-purpose | Plan | Task-tool with subagent-type>
**Independence:** [P] parallel-safe with agents 1..N-1 / [S] must run after agent M
**Estimated agent minutes:** <number>

**Goal:**
<one sentence>

**Inputs:**
- <file path or data the agent needs — every path a markdown link>
- ...

**Constraints:**
- <what NOT to do — cite the Gate the constraint enforces, e.g. "Gate C: retrieve into a scratch worktree, not the working tree">
- ...

**Return format:**
<exactly what the parent expects back — a path, a diff, a summary, a decision — and its length cap>

**Done criteria:**
- <specific check the agent can self-verify — e.g., "gate-A checklist run against the touched flow, all boxes green">
- ...
```

The 5 sections are load-bearing — never merge, reorder, or omit them. This is the same contract Justin's global CLAUDE.md requires under "Parallel-First Delegation."

**Recommended dispatch:** if 2–3 agents are marked `[P]`, launch them in a **single tool-call batch** (per Justin's global agent-behavior policy — parallel is the default, sequential is the exception).

### What the protocol deliberately does NOT do

- **Does not spawn Explore agents during Step 1.** Rediscovery via subagent is slow and costs tokens; the fixed 6-file read is bounded.
- **Does not `sf project retrieve` during Step 1.** That's P2 work and would leak bloat into the working tree (Gate C).
- **Does not invent new tasks.** Only tasks derivable from the tracker + open plans + uncommitted diff. If a genuinely new task exists, surface it in Blocked/needs-decision so Justin adds it to a plan first.
- **Does not skip the quiz.** Even when the answers feel obvious, they change per session — assumptions here are the drift source.

---

---

## Phase Status (glance)

| # | Phase | State | Blocker / next action |
|---|-------|-------|-----------------------|
| 1 | Finish build, test, verify | in-progress | 9 open plans in `.planning/`; large uncommitted diff needs to land in coherent commits. **Gate A (flow best-practices) applies to every flow-touching commit.** |
| 2 | Repo ↔ FundFirst sync | not-started | Blocked on P1 landing. Then run bidirectional diff (org retrieve vs. repo) |
| 3 | Bloat cull (repo + org) | not-started | Blocked on P2. Needs inventories from P5 to know what's real vs. cruft |
| 4 | README / install-steps verify | not-started | Can start in parallel with P3 once P2 lands. Fresh-scratch-org walkthrough |
| 5 | Inventories (metadata / feature / automation) | not-started | Can start in parallel with P3. Feeds P3 cull decisions |
| 6 | Deploy to production | not-started | Gated on P1–P5 all green **and Gate B (GitHub hygiene) green** |

**Legend:** not-started / in-progress / blocked / done / needs-review

**Parallelism map:** P1 sequential (one commit at a time). P2 sequential (one sync pass). P3/P4/P5 run **in parallel** once P2 is green — they touch different files. P6 gated on all.

**Quality Gates (cross-cutting — not phases):**
- **Gate A — Flow best-practices review.** Every commit in P1 that touches a `.flow-meta.xml` runs the flow-review checklist below. Blocks P1 completion.
- **Gate B — GitHub / repo hygiene.** Every item in the GitHub checklist below is green before P6 deploy. Blocks P6.
- **Gate C — Metadata relevance.** Every file entering the repo (via retrieve, hand-authoring, or agent generation) must pass the relevance test below. Runs continuously — a failing file gets deleted immediately, not "tracked for later cleanup."

---

## Agent orchestration rules

- **One phase, one writer.** Never spawn two agents editing the same phase section simultaneously. Different phases in parallel is fine.
- **Every agent updates its phase table row** on completion — state + timestamp + one-line note.
- **Findings go under the phase's "Findings" subheading**, not scattered across new files. Docs stay in `docs/`; plans stay in `.planning/`; this file aggregates state.
- **No new plan files for sub-work** — inline under the phase. New `.planning/*.md` only for a genuinely new feature (which shouldn't happen this close to release).
- **When a phase completes**, move its detailed notes to a "Completed" appendix at the bottom and collapse the phase body to a one-line summary.

---

## Gate A — Flow best-practices review

**Trigger:** every P1 commit that adds/modifies a file matching `force-app/main/default/flows/**/*.flow-meta.xml`. Also runs once at end of P1 against the full flow inventory.

**Definition of done:** every flow in scope passes every check below, or has an explicit "known exception" note here explaining why.

### Design & architecture
- [ ] **Trigger type matches use case.** Record-triggered for row-level automation, scheduled for batch/CRMA, screen for user-guided, autolaunched for callable subflows. No "record-triggered flow doing scheduled work" anti-pattern.
- [ ] **One flow, one responsibility.** Screen flows don't also run record-trigger logic; sync flows don't also compute rollups. If it does two things, split it.
- [ ] **Subflow decomposition** for anything > ~30 elements. SMQS shipped its refactored contact-point flows as sync + subflow (`SMQS_Screen_Manage_ContactPoints_*_Subflow`) — FQS Gift Entry launcher should follow the same pattern.
- [ ] **No custom logic that a formula field, rollup, or DPE can do declaratively.** Prefer platform over flow when both work.
- [ ] **Fault paths on every DML.** Every Create/Update/Delete/Get connects to a fault path (or explicitly routes to a single error screen — the SMQS pattern). No silent failure.
- [ ] **Error messages tell the user what to do next.** "Review and try again" is banned when the user cannot go back; describe closing and relaunching (per `fqs-account-launcher-flow-parity-plan` §5.6).

### Bulkification & governor limits
- [ ] **No DML inside a Loop.** All record creates/updates happen on collections after the loop.
- [ ] **No `Get Records` inside a Loop.** Fetch once before the loop, or restructure to a bulk lookup pattern.
- [ ] **No SOQL-equivalent inside a Loop** (formula referencing `$Record.RelatedObject.Field` in a loop counts).
- [ ] **CMDT reads are pre-fetched** before any loop (SMQS pattern; explicitly called out in `fqs-gift-acknowledgement-plan` §Pre-fetch).
- [ ] **Screen flows respect the 2 MB view-state limit.** Large collections rendered in data tables get filtered before the screen, not inside.

### Naming & conventions (from SMQS shipped)
- [ ] **All flows prefixed `FQS_`.** No exceptions.
- [ ] **Record-triggered:** `FQS_<Object>_<Trigger>_<Verb>` (e.g., `FQS_Campaign_Child_Count_Update`).
- [ ] **Screen flows:** `FQS_Screen_<Verb>_<Object>` or `FQS_Gift_Entry_Single_Launcher_Account`-style descriptive names.
- [ ] **Subflows:** parent flow name + `_Subflow` suffix (`SMQS_Screen_Manage_ContactPoints_Email_Subflow` pattern).
- [ ] **Sync automations:** `FQS_<Object>_<Field>_Sync_<From>_to_<To>` (SMQS `Household_Setup_Name_Sync_*` pattern).
- [ ] **Elements inside a flow follow verb_noun snake_case** (`Get_Account`, `Create_Gift_Transaction`, `Screen_Choose_Type`, `Decide_Ask_Type`).
- [ ] **Variables prefixed by type:** `var_` (primitives), `rsv_` (record SObject variables), `col_` (collections). Already used consistently in `fqs-gift-entry-account-launcher-plan`.

### API version & activation
- [ ] **`<apiVersion>` explicitly set** and matches the target org's version (check `sfdx-project.json` `sourceApiVersion`).
- [ ] **`<status>Active</status>`** on every shipped flow. No `Draft` or `Obsolete` in the release build.
- [ ] **`<runInMode>DefaultMode</runInMode>`** unless there's a specific reason for `SystemModeWithSharing` / `SystemModeWithoutSharing` — and if there is, document it here.
- [ ] **No `<isOverridable>false</isOverridable>` on Screen flows** unless intentional.

### Data & DML hygiene
- [ ] **`OriginalAmount` set, not `CurrentAmount`.** Per `fqs-account-launcher-flow-parity-plan` §4.4 — platform derives `CurrentAmount`.
- [ ] **No hardcoded `GiftTransaction.Status = 'Paid'`** on user-facing entry flows (Tier 0 platform contract; per §P.1).
- [ ] **No `NonTaxDeductibleAmount = 0` assignments** — platform derives it (§4.2).
- [ ] **`GiftCommitment.ScheduleType` not set on insert** — platform back-fills from the schedule child (§P.4).
- [ ] **Person Account save failures route to the single error screen** (§P.8).
- [ ] **Restriction-type / Designation mismatch re-prompts, does not disable lookup escape** (§V.9).

### UX hygiene (screen flows)
- [ ] **Hide fields with obvious defaults** (In-Kind Payment Method, hidden `TransactionDueDate`, etc. — per `fqs-gift-entry-account-launcher-plan` §Simplification principles).
- [ ] **`OriginalAmount` + `CurrentAmount` collapse to one Amount input.**
- [ ] **Picker screens skip cleanly when the data table has zero rows** and the user didn't use the lookup escape (guarded by a Decide element).
- [ ] **Optional pickers advertise "Skip" / "None"** visibly.
- [ ] **Every data table has a lookup-escape hatch** below the table.
- [ ] **Success screens don't lie** — no "return here to record another" claims when relaunch is the actual path (§5.5).

### Testing
- [ ] **Flow-behavior Apex test exists** for anything shipping to prod. SMQS shipped 4: `SMQS_ManageContactPointFlowTest`, `SMQS_HouseholdFlowTest`, `SMQS_AddressSyncFlowTest`, plus service `SMQS_MemberTest`. **FQS gap:** flow-behavior tests for Gift Entry launcher, Campaign hierarchy setup, Gift Acknowledgement scheduled flow don't exist yet.
- [ ] **Playwright coverage** for user-facing screen flows (SMQS shipped 5 spec files). Existing FQS Playwright coverage lives at `tests/playwright/` if present — audit gap.

### Deploy hygiene
- [ ] **Flow doesn't reference an inactive flow, deleted picklist value, or missing record type.** Deploy-time validation catches this — run `sf project deploy validate` before P6.
- [ ] **Flow doesn't reference sample-org-specific hardcoded IDs** (queue IDs, user IDs, record type IDs). Use developer-name lookups instead.

**Findings:** _(agents write here — one bullet per flow that failed a check, with the failing check ID and remediation)_

---

## Gate B — GitHub / repo hygiene

**Trigger:** must be green before P6 deploy. Also worth running once at end of P1 to catch obvious issues early.

### Repo-root files (from SMQS shipped `-DEV-1`)
- [ ] **`LICENSE`** present at root. SMQS ships one — confirm FQS has the same.
- [ ] **`CONTRIBUTING.md`** present.
- [ ] **`CODE_OF_CONDUCT.md`** present.
- [ ] **`SECURITY.md`** present.
- [ ] **`CODEOWNERS`** present (`.github/CODEOWNERS` or root).
- [ ] **`README.md`** matches shipped SMQS outline (see SMQS Reference Shape appendix). ~40+ KB is normal, not a smell.
- [ ] **No stray `package.xml` at root** — SMQS stripped this before shipping.
- [ ] **`destructiveChangesPost.xml`** present at root **if** any install step removes prior state. Confirm need first.
- [ ] **`.gitignore`** clean — no accidentally-tracked `.tmp-*` or `node_modules` or org-cache files.
- [ ] **`.forceignore`** clean and matches shipped SMQS shape (SMQS updated this during productization).

### Branch & commit hygiene
- [ ] **Working tree clean** (`git status` shows nothing before the final release commit).
- [ ] **All commits on `main` land as coherent units** — one plan = one commit (or a small stack). No "wip: stuff" commits in the shipped log.
- [ ] **Commit messages describe the "why"** in the first line and cite the plan file when applicable. Match the existing FQS convention (`git log --oneline` — SMQS-style concise imperative).
- [ ] **No secrets in git history** — scan for tokens, org URLs with credentials, hardcoded IDs. `git log -p | grep -iE '(password|token|secret|apikey)'` before P6.
- [ ] **No large binaries committed accidentally.** `git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectsize) %(rest)' | sort -k2 -n | tail -20` — inspect the top 20.
- [ ] **Tag the release** — `git tag -a v1.0.0 -m "..."` before P6 deploy.

### GitHub-side (not local repo)
- [ ] **Repo description** on GitHub set (short one-liner, matches README first sentence).
- [ ] **Topics/tags** set (`salesforce`, `nonprofit-cloud`, `fundraising`, `gps-accelerator`).
- [ ] **Default branch** is `main`.
- [ ] **Branch protection on `main`**: require PR review, require status checks. Justin is solo, so review can be self-review, but the record matters.
- [ ] **Issues enabled** — GPS Accelerators use issues for user feedback.
- [ ] **Discussions enabled** if the accelerator is meant to support community Q&A (SMQS enables this).
- [ ] **Releases page** — create a GitHub Release with the tag, the unmanaged-package install URLs (sandbox + prod), and copy of the README Revision History entry.
- [ ] **`.github/` directory** with issue templates (bug report, feature request) and PR template. SMQS ships these.
- [ ] **Public visibility confirmed** if this is a public GPS Accelerator.

### CI / hooks
- [ ] **`husky` + `lint-staged` hooks work locally** (per project CLAUDE.md). Confirm on a fresh clone.
- [ ] **`npm run prettier:verify` clean** on the whole tree.
- [ ] **`npm run lint` clean** on the whole tree.
- [ ] **`npm run test:unit` passes** (Jest — no-op if no LWC, but the command must not error).

### Deploy artifact
- [ ] **mdapi export directory built** at repo root (SMQS shipped `Stakeholder Management Quick Start/`; FQS parallel: `Fundraising Quick Start/`).
- [ ] **Unmanaged package built** and install URLs captured for both `test.salesforce.com` and `login.salesforce.com`.
- [ ] **Install URL documented in README** in both sandbox and prod variants.
- [ ] **`datapacks/`** present if the release ships seed data (SMQS shipped this).
- [ ] **`test-results/`** directory present if the release ships regression artifacts (SMQS shipped this).

**Findings:** _(agents write here — one bullet per failed check with remediation)_

---

## Gate C — Metadata relevance (bloat prevention)

**Trigger:** every `sf project retrieve` operation, every agent-generated metadata file, every hand-authored addition. Runs **continuously** — a failing file is deleted immediately, not queued for a P3 cleanup pass. This is a working-tree discipline, not a release-time audit.

**Definition of "relevant":** an FQS metadata file is relevant if AND ONLY IF at least one of the following is true:
1. It's a **file we authored** as part of an FQS plan (prefix `FQS_*` on the API name is a strong signal, but not sufficient — it must also be referenced).
2. It's a **standard-object customization we own** — a custom field, layout section, DPE, rollup, or record type that FQS added or explicitly modified. The **field itself** is FQS-owned even without `FQS_` prefix (e.g., `MessageChannel.field-meta.xml` help-text overlay per `fqs-utm-platform-field-plan`).
3. It's an **install-step dependency** — the file must ship because an install step references it (e.g., a standard object's `.object-meta.xml` shell is required if we add fields under it in SFDX source format).
4. It's **repo-hygiene infrastructure** — `.gitignore`, `.forceignore`, `sfdx-project.json`, `package.json`, etc.

If a file doesn't meet one of those four criteria, **it doesn't belong in the repo.**

### Retrieve-time discipline (biggest bloat vector)

`sf project retrieve start` will happily pull the entire dependency graph of whatever you ask for. This is where 90% of metadata bloat enters a Salesforce repo. Rules:

- [ ] **Never `retrieve` a whole standard object.** `sf project retrieve start --metadata CustomObject:GiftTransaction` pulls *everything on that object*, including 40+ layouts, list views, and compact layouts owned by the managed package or unrelated teams. **Use field-level or component-level retrieves.**
- [ ] **Prefer manifest-scoped retrieves.** Build a `package.xml` listing only the specific `<members>` you want, then retrieve against that manifest. This is how SMQS-DEV-1 shipped clean.
- [ ] **Manifest granularity examples:**
   - `<members>GiftTransaction.FQS_Is_Major_Gift__c</members>` — retrieve one field, not the object
   - `<members>FQS_Gift_Entry_Single_Launcher_Account</members>` — one flow
   - `<members>FQS_Campaign_Compact_Layout</members>` — one compact layout
- [ ] **After every retrieve, run `git status` and eyeball every new file.** Any file that isn't in your intended manifest is bloat — delete it before staging.
- [ ] **Use `.forceignore` aggressively** for known bloat categories the org sends back regardless (Profile permissions on unrelated objects, `.appMenu`s, standard flexipage overrides you didn't touch, etc.).

### Retrieve-bloat patterns to actively filter (SMQS learned these the hard way)

Salesforce retrieve is *especially* greedy on these categories — put them in `.forceignore` unless you have a specific reason to track them:

- [ ] `**/profiles/*.profile-meta.xml` — profiles pull permissions for *every field on the object*, not just FQS fields. FQS uses permission sets, not profiles. Ignore profiles wholesale unless a specific one is FQS-owned.
- [ ] `**/settings/*.settings-meta.xml` — org-wide settings drift constantly, rarely FQS-scoped.
- [ ] `**/applications/standard__*.app-meta.xml` — standard app overrides you didn't intend to touch.
- [ ] `**/appMenus/*.appMenu-meta.xml` — org-wide, not project-scope.
- [ ] `**/globalValueSetTranslations/**`, `**/translations/**` — unless you're shipping localizations.
- [ ] `**/standardValueSets/*.standardValueSet-meta.xml` — the org's picklist values, not FQS's.
- [ ] `**/reports/unfiled$public/**` — unfiled reports are personal, never project-scope.
- [ ] `**/dashboards/**` unless the dashboard is `FQS_*`-named.
- [ ] `**/emailtemplates/unfiled$public/**` — same reason as unfiled reports.
- [ ] `**/objectTranslations/**`.
- [ ] `**/staticresources/**` unless FQS ships a static resource.

**FQS's current `.forceignore`** — audit it now: is it filtering all of the above, or just a subset? Any that leak through become bloat in P2's org sync.

### Every-file relevance checklist (applied per file, per commit)

For each new/modified metadata file entering staging:

- [ ] **Can I name the plan or install step that requires this file?** If no → delete.
- [ ] **Is anything in the repo `grep`-referencing this file's API name?** For a field: any layout, flexipage, flow, apex, permset, or record-type reference. For a flow: any subflow parent, apex flow-launch, or button/action. For a permset: any user-assignment scaffolding or install-step doc. If nothing references it → delete or add the missing reference.
- [ ] **For standard objects: is this file *just* the object shell** (`Account.object-meta.xml` with a `<label>` and nothing else)? If yes, keep it — SFDX requires the shell when subfolder fields exist. But **don't include `<listViews>`, `<compactLayouts>`, `<validationRules>`, `<webLinks>`, `<recordTypes>` we didn't author.**
- [ ] **For layouts / compact layouts / flexipages on standard objects:** is this the FQS-owned page (`FQS_*` in the filename)? If the filename doesn't have `FQS_` and we didn't intentionally modify a standard page → likely bloat.
- [ ] **For custom fields on standard objects:** is the field prefixed `FQS_*` OR is it a documented FQS-owned standard-field override (help text on `MessageChannel`, `SourceCode`, etc. — call these out in the metadata inventory)? If neither → we shouldn't be shipping it.
- [ ] **For permission sets:** does every field/object entry in the permset actually exist in the repo? A permset granting access to `FQS_Foo__c` when no `FQS_Foo__c.field-meta.xml` exists is dangling.
- [ ] **For custom metadata records:** does the parent CMDT type exist in the repo? Are all fields referenced in the record present in the CMDT type?
- [ ] **Reverse check — is anything referenced BUT missing?** `grep -r "FQS_Missing__c" force-app/` returning hits when no field-meta.xml exists → broken reference, either add the field or remove the reference.

### `.forceignore` and `.gitignore` audit (do this now, at Gate C's introduction)

Before P2 sync (which is a giant retrieve), audit both files:
- [ ] Every category in "Retrieve-bloat patterns to actively filter" above is present in `.forceignore` OR has an explicit "we ship this because ___" note here.
- [ ] `.tmp-*` directories are in `.gitignore`. FQS's `.tmp-flow-drift/` is currently untracked but should be ignored, not stripped-per-cycle.
- [ ] `retrieve-tmp/`, `compare-tmp/`, `mdapi-tmp/` patterns in `.gitignore` (SMQS-DEV had these and stripped them for shipping — cleaner to ignore from the start).
- [ ] `test-results/` in `.gitignore` unless we intend to ship it as a release artifact (SMQS shipped it in `-DEV-1`; decide during Gate B).
- [ ] IDE-specific: `.vscode/settings.json` is checked in ONLY if the settings apply project-wide, not personal. `.idea/`, `.cursor/local-*` in `.gitignore`.

### Bloat-catch during P2 (repo↔org sync)

Phase 2's retrieve pass is the highest-risk moment for bloat. Enforce Gate C then by:
1. Retrieve into a **scratch worktree**, not the working tree, so bloat can't accidentally get staged.
2. After retrieve, run `git status` in the worktree and diff every new file against the relevance checklist above.
3. **Delete every file that fails** — do not stage it "to review later."
4. Only after the delete pass does anything move into the real working tree.

### Bloat-catch during P3 (final cull)

Phase 3 becomes a **verification pass** for Gate C, not the primary bloat-catch. If Gate C runs continuously through P1 and P2, P3 should find almost nothing — anything it does find is a Gate C escape and should trigger tightening the `.forceignore` or the retrieve manifest patterns.

**Findings:** _(agents write here — one bullet per file deleted with the failed check ID and where it came from)_

---

## Phase 1 — Finish build, test, verify

**Definition of done:** Every open plan in `.planning/` is either (a) implemented + tested + committed, (b) explicitly deferred to post-1.0 with a note here, or (c) deleted as no-longer-needed.

**Current priority stack (Justin, 2026-07-18):**
1. **FQS Gift Entry Single Launcher — Account** — get it working end-to-end, then run first-pass UI test. Consolidated 2026-07-18: `fqs-account-launcher-flow-parity-plan.md` is the SOT; the launcher plan was merged into its appendix and deleted. Unblocks the no-flow-commits gate.
2. **Custom Report Types → Donor Grouping reports & dashboards** — one working CRT already exists in the org; a prior agent couldn't emit the CRT metadata. Retrieve the working example, template it, build the remaining CRTs, then author reports + dashboards on Donor Grouping on top.
3. **FundFirst ↔ local repo sync** — this is Phase 2 by definition; run it in parallel with 1 & 2 rather than serializing. Dar's items in the P2 "Needs Justin confirmation" bucket require explicit accept before adoption.

Also placeholder-only: **FQS App Home page** — app-level landing surface for the FQS app; no plan file yet.

**Open plans (as of 2026-07-18) — status grounded in plan files + [session-history](session-history.md) + `git status`:**

| Plan | Status | Tests | Notes |
|------|--------|-------|-------|
| `fqs-account-launcher-flow-parity-plan.md` (consolidated) | code-partial, uncommitted, deployed to FundFirst | none yet | **2026-07-18:** absorbed `fqs-gift-entry-account-launcher-plan.md` (deleted). Reviewer decisions captured 2026-07-16 (P.1, 1.2, 1.3, 1.4, 2.2, 4.3, V.3, V.4, 5.5, 5.6, 5.10, 5.11, P.8, V.9 all confirmed). Redesigned pledge-structure 4-branch table locked. Sessions `770ea565` (fixed errors) + `2e5778e0` (analyzed) + `e219427c` (documented) landed some fixes to the flow. **2026-07-18 deploy `0AfWB00000DTWbJ0AX`:** added `Assign_Gift_Details_Defaults` pre-seed (TransactionDate = TODAY, PaymentMethod = Cash) to fix null-Name-on-Create. **2026-07-18 deploy `0AfWB00000DTXfR0AX`:** P.0 sweep (5 picker screens converted to `flowruntime:lookup` — activates Justin's field-level filter on Designation), P.1 (Status default `Pending` w/ override), and Flow filter fix (`In` operator with comma-separated `<stringValue>` was silently returning 0 rows — rewrote all 3 filters as `EqualTo` OR chains). **Tests passing:** Outright (Aaron Mitchell), Outright w/ Designation (Aaron Mitchell), InKind (Sofia), PledgePayment (Sofia $1560, Anthony $315). **Untested still:** Outright w/ Campaign, FeeForService, Pledge (new commitment), soft-credit Yes path, campaign default-designation short-circuit. **Follow-ups flagged (not implemented):** (a) prefill payment method + transaction date from existing GiftCommitmentSchedule on PledgePayment path — medium priority, captured in plan; (b) GT Name convention doesn't match seed — deferred to `fqs-record-naming-flows-plan.md`. Items 1.1–1.4 (pledge redesign) still paused. **2026-07-19: entry-point structure superseded by `fqs-gift-entry-wizard-plan.md`** — new plan restructures the four flat paths into a 2-question wizard (Category → Leaf, 8 leaves), adds In-Kind + Fee for Service as first-class leaves, introduces the match-eligibility branch (orphan-and-pair via `MatchingEmployerTransactionId` on GT + new `FQS_Match_Eligible__c` on GC), and codifies the Pledge Payment update-vs-insert rule (query open GTs on the picked GC; update earliest Expected or insert fresh if none). This plan retains authority on field-parity contract, per-type defaults, soft-credit routing, and datatable pickers. |
| `fqs-gift-entry-wizard-plan.md` | Phases A + B + C.1 + E.prefill + H shipped, C.2/C.3/D/E.update-path/F/G pending | none yet | **New 2026-07-19.** Category-wizard redesign of the launcher entry point. Screen 1 (Monetary/Future/Special) → Screen 2 (8 leaves). Splits current Pledge/Grant into Simple (GC only, no GCS, uses `NextTransactionDate`/`ExpectedTotalCmtAmount` for pipeline visibility) vs. Scheduled (GC + 1 GCS regular or N GCS custom). Adds In-Kind and Fee for Service as first-class leaves. Pledge Payment leaf now branches on existing open GTs under the picked GC (update earliest Expected vs. fresh insert). Matching-gift branch: orphan-and-pair, employer picker from ACRs on Organization-recordtype Accounts, new `FQS_Match_Eligible__c` (Checkbox) on GiftCommitment. Amount-mismatch warning on Pledge Payment update (never touches `OriginalAmount`). OSC picker deferred per Justin 2026-07-19. All four open questions locked 2026-07-19 (see plan §Decisions locked). **Files to touch:** launcher flow XML, new field on GC, permset entry, `FQSSeedGenerator.cls` for demo data. **2026-07-19 Phase A deploy `0AfWB00000DThy90AD`:** added `GiftCommitment.FQS_Match_Eligible__c` (Checkbox, default false) + FQS_Custom_Fields fieldPermissions entry. `sf sobject describe` confirms field is createable/updateable with the wizard-plan inline help text. Drift check found FundFirst launcher-flow copy was newer than local (Flow-Builder round-trip: `{!}` wrapping on formula refs + status flipped Draft→Active); pulled into working tree before edits — no local logic lost. Permset also had 4 new corporate-match `classAccesses` entries (FQS_CampaignHierarchyBuilder, FQS_CustomMetadataSaver, FQS_MatchCandidateService, FQS_MatchCommitService) — pulled and preserved. **Phase B (Screen_Category/Screen_Leaf scaffold) is next; awaiting Justin's gate.** **2026-07-19 Phase B deploys `0AfWB00000DTi9R0AT` (2-screen), `0AfWB00000DTiKj0AL` (consolidated single screen with visibility rules), `0AfWB00000DTiML0A1` (Monetary default).** Wizard consolidated to a single `Screen_Wizard_Entry` with category radio (default Monetary) and 3 conditional leaf pickers. `pkAskType` promoted to global variable, populated by `Assign_Leaf_To_AskType` via `formulaLeafToAskType`. Transform_Campaign_Ids fix preserved. Justin UAT: Outright (Anthony Cohen) + wizard reveal + Monetary default all confirmed working; Sofia pledge-payment prefill deferred to Phase E. **2026-07-19 Phase C.1 deploy `0AfWB00000DTiZF0A1`:** Simple Pledge/Grant leaf now has its own askType (`Simple` — was previously collapsing to Pledge in Phase B). `formulaLeafToAskType` rewritten as CASE (Simple→Simple, Recurring→Pledge, Scheduled→Pledge, else var_Leaf); Recurring/Scheduled still passthrough to a new placeholder `Screen_NotYet_Scheduled_Recurring` until C.2/C.3 land. Added `Choice_Subcategory_Pledged` + `Choice_Subcategory_Grant`. `Screen_Pledge_Details` now collects `pkCommitmentSubcategory` (Pledged Gift vs. Grant Payout radio, default Pledged), `dtNextTransactionDate` (required Date), `FQS_Match_Eligible__c` (ObjectProvided), `IsAssetTransferExpected` (ObjectProvided, required by schema). `Assign_Pledge_Defaults` rewritten: writes `FQS_Gift_Commitment_Category__c` from `pkCommitmentSubcategory` (not hardcoded), writes `NextTransactionAmount = numPledgeAmount`, `NextTransactionDate = dtNextTransactionDate`, `RecurrenceType = FixedLength`. Also writes `var_CommitmentSubcategory` global for downstream branches. `formulaGiftCommitmentName` updated to include subcategory literal. **Ready for Justin UAT: (1) Simple Pledged Gift end-to-end, (2) Simple Grant Payout end-to-end, (3) Recurring/Scheduled leaves should route to the Under Construction screen.** C.2 (Scheduled — GC + GCS regular/custom) and C.3 (Recurring — GC + GCS OpenEnded + first GT) pending Justin's gate. **2026-07-19 Phase E prefill IsNull-gate deploy `0AfWB00000DTiar0AD`:** finished the partial schedule-prefill scaffolding — `Assign_Prefill_From_Schedule` now also prefills `rsv_GiftTransaction.PaymentMethod` from `Get_Commitment_Schedule.PaymentMethod` (in addition to the existing `var_GiftAmount` prefill from `TransactionAmount`); added two IsNull-gate formulas (`formulaDefault_TransactionDate`, `formulaDefault_PaymentMethod`) that resolve to the prefilled value if non-null else the previous defaults (TODAY / Cash); retargeted `Assign_Gift_Details_Defaults` at those formulas. PaymentMethod IsBlank check wraps `TEXT()` — direct picklist-field IsBlank is not permitted in formulas. Rest of Phase E (existing-GT datatable + amount-mismatch warning + update-existing path) still pending Justin's gate. **2026-07-19 Phase H seed generator deploy `0AfWB00000DTihJ0AT`:** added `PROB_COMMITMENT_MATCH_ELIGIBLE = 0.20` public knob and wired `FQS_Match_Eligible__c = randBool(globalIdx, <salt>, PROB)` into all three commitment builds (recurring salt 27, pledged salt 37, grant salt 47 — next unused salt integers past each existing salt cluster; documented in the knob's inline comment). Reseed to see the flag distribution on the wizard's Pledge Payment default. **Still pending Justin gate: C.2, C.3, D (In-Kind + Fee for Service leaves), E existing-GT/update-path, F (match branch), G (Success screen consolidation + full regression).** **2026-07-22 Phase E1 deploy `0AfWB00000DWo0b0AD`:** landed `Get_Existing_GTs` (open Expected GTs on the picked commitment, Status IN Unpaid/Pending/Failed, sorted by TransactionDueDate ASC) + `Decide_Has_Existing_GTs` router + `Screen_Existing_GTs` (help text + Update/New radio `pkPledgePaymentMode` + `dtExistingGTs` datatable single-select gated on Update mode + `rsv_SelectedGT` capture) + two new radio choices `Choice_PledgePayment_New` / `Choice_PledgePayment_Update`. E1 is a pass-through smoke test — both toggle values currently fall through to the existing `Decide_Prefill_From_Schedule` (fresh-insert path); E2 replaces that with the real Update_Gift_Transaction + amount-mismatch + fanout-bypass logic. **First deploy hit a conflict** — retrieved-first (canonical FundFirst copy), backed up local edits to `/tmp`, re-applied on top, semantic-diffed, redeployed clean. **Phase G decision-logged 2026-07-22 (Justin):** flip `GiftTransaction.Status` default from `Pending` → `Paid` on all four monetary leaves (Outright, Pledge Payment, In-Kind, Fee-for-Service — approx. lines 418/469/527/578 in the launcher flow XML). FQS is retroactive data entry — the admin is recording gifts that have already cleared, so `Paid` is the semantically correct default, not `Pending`. `docs/npc-automation-notes.md` GT §Status framing (Paid bypasses NPC payment-recon) assumes upstream-of-recon ingest; FQS is downstream-of-recon, so the framing inverts. Do NOT apply on the E2 update-existing-GT branch (that GT already has a platform-engine-assigned status; E2 handles its own transition logic). See `~/.claude/projects/…/memory/gt-status-default-paid.md`. |
| `fqs-campaign-hierarchy-setup-plan.md` | code-complete, uncommitted | `FQS_CampaignHierarchyBuilder_Test.cls` (11 tests) | v3 shipped 2026-07-13. `FQS_CampaignHierarchyBuilder.cls` + `FQS_CustomMetadataSaver.cls` + `FQS_Campaign_Template__mdt` (24 template records) all present but untracked. Data-table-driven flow authored. **Needs commit + Phase 2 sync verification.** Session `8580c251`. |
| `fqs-corporate-match-plan.md` | code-partial, no flow yet | `FQS_MatchServices_Test.cls` present | Apex layer written: `FQS_MatchCandidate`, `FQS_MatchCandidateService`, `FQS_MatchCommitService`. **Custom fields on Account not yet created** (`FQS_Matching_Gift_Program__c`, `FQS_Match_Ratio__c`, `FQS_Match_Annual_Individual_Maximum__c`, `FQS_Is_Match_Intermediary__c`). **No screen flow yet** — plan describes it but not built. |
| `fqs-gift-acknowledgement-plan.md` | design-locked, not-implemented | none | v2 scheduled-flow design complete. Picklist values verified against org. Routing decision table finalized. Requires: `FQS_Gift_Acknowledgements` queue creation, scheduled flow build, CMDT `FQS_Auto_Acknowledgement__c` field additions. **Nothing built yet.** |
| `fqs-gift-entry-help-text-plan.md` | design-drafted, not-implemented | n/a — metadata only | Plan targets `force-app/main/default/objects/GiftEntry/fields/` directory (does not exist yet). 49 fields grouped into 9 clusters. Field-by-field help-text drafts partially written in the plan. **No metadata files created yet.** |
| `fqs-outreach-summary-help-text-plan.md` | mostly-done? | n/a — metadata only | Plan targets `force-app/main/default/objects/OutreachSummary/fields/`. `git status` shows `M OutreachSourceCode/fields/MessageChannel.field-meta.xml` — some help-text work has landed. **Verify:** are the 9 OutreachSummary field-meta files actually present? |
| `fqs-seed-improvements-plan.md` | code-complete, uncommitted | none yet — Apex tests planned but not in `FQSSeedGenerator` | `FQSSeedGenerator.cls` + `.cls-meta.xml` present untracked. Seed scripts (`fqs-seed-foundation`, `-small`, `-medium`, `-chunk`, `-teardown`, `-matching-gift-scenarios`) all modified. Matching-gift-scenarios script is new. **External_Id__c fields on 13 objects — verify each exists in repo before committing seed.** Plan itself is in a `MM` state (modified both staged + unstaged). **2026-07-19: §13.1 (recurring commitment Status distribution — 70/10/10/10 across Active/Failing/Lapsed/Paused) + §13.2 (NonTaxDeductibleAmount populated to drive partial-deduction branch of Gift Acknowledgement flow; TaxDeductionAmount itself is calculated:true, not writeable) implemented in `FQSSeedGenerator.cls`. Deploy `0AfWB00000DTfuj0AD`. Smoke seed at offset 9000 verified distribution + torn down clean.** |
| `fqs-utm-platform-field-plan.md` | design-drafted, not-implemented | n/a — metadata only | Plan drafted; new field `OutreachSourceCode.FQS_Platform__c` (picklist) + help-text updates to 3 existing fields. `MessageChannel.field-meta.xml` shows uncommitted mods — could be this plan or the OutreachSummary one. **Verify overlap.** |
| `fqs-record-naming-flows-plan.md` | **shipped 2026-07-22** (deploy `0AfWB00000DY1lN0AT`) | none yet | Three `RecordBeforeSave` flows (`FQS_Auto_Name_Gift_Commitment`, `FQS_Auto_Name_Gift_Transaction`, `FQS_Auto_Name_Opportunity`) assign `$Record.Name` in-place from `{donor}` + `${amt}` + verb/date. Plan called for `RecordAfterSave` + `Update Record`, actual implementation is `RecordBeforeSave` + `$Record.Name = Computed_Name` assignment — no DML, no recursion risk. Opt-outs: `FQS_Skip_Record_Naming` custom permission (assign via `FQS_Naming_Opt_Out` permset for integration users) OR per-record `FQS_Skip_Naming__c` checkbox. All 3 Skip fields added to `FQS_Custom_Fields` permset. **Smoke tested 2026-07-22**: GC (Recurring $50 Monthly), GT (Outright $250 on date), Opp ($5000 close date), all 3 skip-flag paths preserve upstream Name. Follow-up: strip dead-weight Name formulas from `FQS_Gift_Entry_Single_Launcher_*` flows now that BeforeSave overwrites them anyway (see 2026-07-18 note below in "Follow-up items"). |
| `fqs-fee-designation-plan.md` | design-drafted, not-implemented | none yet | **New 2026-07-18.** Surfaced during FeeForService UI test on Anthony Cohen FQS #42 (path confirmed passing). Adds fifth `FQS_Restriction_Type__c` picklist value `Fee for Good or Service` (label locked by Justin) so exchange-transaction revenue is categorically separable from donation revenue. Wires launcher's FeeForService branch to auto-filter designation picker on that value. Seed generator adds one seeded fee GD and routes seed Fee/Payment GTDs to it. **Files:** picklist metadata, launcher flow XML, `FQSSeedGenerator.cls`. Blast radius crosses picklist + flow + Apex — recommend shipping as its own commit rather than folding into the parity plan. |
| Duplicate Rules (placeholder) | scope TBD — Justin to define | n/a | Future scope; no plan file yet. Likely dedup rules for donor Account/Contact/Opportunity to protect matching-gift + household consolidation. Placeholder here so it doesn't get lost — Justin to draft `.planning/fqs-duplicate-rules-plan.md` when ready. |
| Custom Report Types + Donor Grouping reports/dashboards | v1 shipped, polish deferred | none | **Deployed 2026-07-18 to FundFirst:** 3 CRTs (`fqs_Gift_Commitments_Deluxe`, `fqs_Gift_Transactions_Deluxe`, `fqs_Donor_Gift_Summary_Deluxe` — kitchen-sink pattern), 5 reports (Major Annual Donors This FY, Major Commitments Active, Major Gifts This Year, Major Lifetime Donors, Mid to Major Upgrade Pipeline) all Summary format w/ HorizontalBar charts, 1 dashboard (`FQS_Donor_Groupings` in the `FQSDashborads` folder — 2×3 grid). Deploy pattern captured in [[fqs-crt-deploy-pattern]] memory. **Polish still needed:** (a) dashboard folder is spelled "FQS Dashborads" — rename to "FQS Dashboards"; (b) rename auto-generated dashboard record still in org (random-string dev name); (c) reports/dashboard themselves need iteration on groupings, chart types, filters (Justin to redesign in a later session — this deploy proved the pipeline works, not that the analytics are right); (d) draft `.planning/fqs-reports-dashboards-plan.md` when ready to polish. |
| FQS App Home page (placeholder) | scope TBD | n/a | App-level landing page for the Fundraising Quick Start app. No plan file yet. Justin to draft `.planning/fqs-app-home-page-plan.md`. |

**Gate: no flow-file commits until the flow passes first-pass UI test.** None of the untracked FQS flows currently pass first-pass UI testing. Flow polish + test is the current work; commit boundaries are downstream. Agents doing P1 flow work should build + iterate + UI-verify in the org first, then stage `.flow-meta.xml` files for commit — never the other way around.

**Uncommitted work needing homes (first commit-boundary pass):**
- Campaign hierarchy: `FQS_CampaignHierarchyBuilder.cls` + test + related metadata → `fqs-campaign-hierarchy-setup-plan`
- Corporate match: `FQS_MatchCandidate.cls`, `FQS_MatchCandidateService.cls`, `FQS_MatchCommitService.cls`, `FQS_MatchServices_Test.cls` → `fqs-corporate-match-plan`
- Custom metadata saver: `FQS_CustomMetadataSaver.cls` + test → likely under campaign hierarchy or its own utility commit
- Campaign templates: ~24 new `FQS_Campaign_Template.*.md-meta.xml` records → campaign hierarchy
- Seed generator: `FQSSeedGenerator.cls` + seed script edits → `fqs-seed-improvements-plan`
- Donor grouping CMDT + rollup fields + flexipage + flow edits → prior donor-grouping work (may already be complete)
- Deleted `FQS_Donor_Grouping_Configurator.flow` → confirm intentional
- `.tmp-flow-drift/` — untracked, investigate before committing anything else

**Findings:**
- **2026-07-18 — Gift Entry Single Launcher — Account · Bug 3 root cause + fix (deployed).** Justin's most recent test hit `REQUIRED_FIELD_MISSING: [Name]` on Outright-gift Create. Connector-graph trace confirmed: `Screen_Gift_Details` runs BEFORE `Assign_Defaults_*`, so `rsv_GiftTransaction.TransactionDate` is null when the Name formula (`Get_Account.Name & " " & TEXT(numGiftAmount) & " " & TEXT(rsv_GiftTransaction.TransactionDate)`) evaluates → concat returns null → Create fails. `ObjectProvided` fields disallow both `<defaultValue>` and `<isRequired>true>` (platform contract — verified both errors empirically during deploy). Fix: added `Assign_Gift_Details_Defaults` element that pre-seeds `rsv_GiftTransaction.TransactionDate = $Flow.CurrentDate` and `rsv_GiftTransaction.PaymentMethod = 'Cash'` before Screen_Gift_Details renders — ObjectProvided binds to the record variable, so the pre-seeded values appear as the on-screen defaults. Rerouted 3 connectors (`Decide_Ask_Type` default, `Decide_Prefill_From_Schedule` default, `Assign_Prefill_From_Schedule` connector) through the new element. Confirmed `Cash` is a valid `GiftTransaction.PaymentMethod` picklist value in FundFirst (11 values total). Deploy 0AfWB00000DTWbJ0AX succeeded; awaiting Justin's UI walkthrough (Outright path minimum) to lift the no-flow-commits gate.
- **2026-07-18 — Consolidation done.** `fqs-gift-entry-account-launcher-plan.md` merged into `fqs-account-launcher-flow-parity-plan.md` (as a "Launcher redesign appendix" at the bottom) and deleted. The parity plan is now the SOT for this flow.
- **2026-07-18 — Lookup-render bug on picker screens.** Test of the Outright path with checkbox=checked showed the Campaign + Designation "search outside the list" lookups do not render. Root cause: those fields are authored as `<fieldType>ObjectProvided</fieldType>` bound to `rsv_LookupCampaign.Id` / `rsv_LookupDesignation.Id`. Screen Flow refuses to render `Id` (system field) as an editable ObjectProvided input, so nothing appears. Fix: convert to native `<fieldType>Lookup</fieldType>` on all four picker screens (`Screen_Pick_Campaign`, `Screen_Pick_Campaign_Pledge`, `Screen_Pick_Designation`, `Screen_Pick_Commitment`, `Screen_Pick_SoftCredit` — audit each). Same fix pattern; testing burden per screen is real. Added to the consolidated plan's Tier list as a Tier 0 correctness bug.
- **2026-07-18 — Decisions.** P.1 → **Pending default with user override** (no platform reconciliation infrastructure exists yet, so "platform-managed" would leave Status stuck at Pending forever). V.10 → **field-level filter on `GiftTransactionDesignation.GiftDesignationId` set directly in FundFirst by Justin**; flow-side change is P.0 (bind the picker to the real lookup field so the filter is honored — no separate flow filter needed). Field-level lookup filters are org-wide and belong in a separate `fqs-lookup-filters-plan.md` if we want to harden Data Loader + list views. 1.1–1.4 (pledge structure redesign) paused pending Justin's design consideration.
- **2026-07-18 — Implementation (deploy `0AfWB00000DTXfR0AX`).** Landed P.0 + P.1 + a Flow filter bug fix in a single deploy: (1) converted all 5 picker screens' lookup-escape fields from `ObjectProvided` bound to `.Id` → `flowruntime:lookup` component instances with `objectApiName`+`fieldApiName` targeting real lookup fields (activates Justin's field-level filter automatically); (2) rewired 5 `Get_Looked_Up_X` recordLookups to source Ids from `<lookupFieldName>.recordId` (SMQS pattern — NO screen-name prefix; over-qualifying breaks the reference); (3) deleted 4 orphaned `rsv_LookupX` record variables; (4) flipped Status default from `'Paid'` → `'Pending'` on all four `Assign_Defaults_*` blocks; (5) fixed `Get_Active_Commitments` filter — `<operator>In</operator>` with a comma-separated `<stringValue>` does NOT work in Flow (SOQL syntax, not Flow syntax); rewrote as `1 AND (2 OR 3 OR 4 OR 5) AND (6 OR 7)` with each status/category as its own `EqualTo` clause. **Grep other flows for the same pattern** — every `<operator>In</operator>` paired with a comma-separated `<stringValue>` is broken the same way. Sofia Garcia + Anthony Cohen PledgePayment tests succeeded post-deploy.
- **2026-07-18 — Follow-up items surfaced during PledgePayment testing (flagged, deferred).** (a) **Prefill payment method + transaction date from existing schedule/GT** on the PledgePayment path — currently defaults to `TODAY()` and `Cash` regardless of what the picked commitment's schedule says. Add `Get_Commitment_Schedule` + `Decide_Prefill_From_Schedule` gate. Priority: medium. Captured in `fqs-account-launcher-flow-parity-plan.md`. (b) **GiftTransaction Name is crude vs. seed.** Runtime-created GT names don't match the seed's naming convention. Do NOT fix in this launcher — `fqs-record-naming-flows-plan.md` will fix globally via record-triggered naming flows. Priority: low, existing plan owns it.
- **2026-07-18 — Follow-up #1 wiring inspection (schedule prefill).** The scaffolding is present but **incomplete**: `Get_Commitment_Schedule` (LIMIT 1 by `GiftCommitmentId`) → `Decide_Prefill_From_Schedule` → `Assign_Prefill_From_Schedule` exists, but that assignment only prefills `var_GiftAmount` from `Get_Commitment_Schedule.TransactionAmount` and then routes to `Assign_Gift_Details_Defaults`, which **unconditionally overwrites** `TransactionDate = TODAY` and `PaymentMethod = 'Cash'`. So the two fields the follow-up cares about are actively stomped after prefill. To finish: (i) add `PaymentMethod` prefill from `Get_Commitment_Schedule.PaymentMethod` in `Assign_Prefill_From_Schedule`; (ii) either bypass `Assign_Gift_Details_Defaults` on the prefill branch or gate its overwrites on `IsNull` of the destination fields. `TransactionDate` from schedule is harder — `GiftCommitmentSchedule` carries a `StartDate` and a cadence, not a specific next-installment date; the more useful prefill is the **next unpaid GiftTransaction on the commitment** (matches how these payments are actually recorded). Recommend implementing PaymentMethod-from-schedule first (small, safe), and treating date prefill as a follow-on that needs a schedule-vs-next-GT design choice.
- **2026-07-18 — FeeForService path verified in UI (Anthony Cohen FQS #42).** End-to-end FeeForService creation succeeded post-fix. This confirms the FeeForService branch of the four `Assign_Defaults_*` blocks, `Decide_Fanout_Path` default routing, `Assign_Fanout_Amount`, and `Create_Gift_Transaction` all behave correctly for Fee/Payment category. **Path pass 2 of 4** toward lifting the no-flow-commits gate.
- **2026-07-18 — Outright w/ Campaign path verified in UI (Anthony Cohen FQS #42, post-transform-fix).** After the `Transform_Campaign_Ids_Into_Text_Strings` self-reference fix (deploy `0AfWB00000DTY0P0AX`), Justin sees all 5 of Anthony's active-campaign-member Campaigns in the picker and the Outright w/ Campaign gift creation completes end-to-end. This confirms the full transaction-path chain: `Get_Account_Contacts` → `Transform_Ids_Into_Text_String` → `Get_CampaignMembers` → `Transform_Campaign_Ids_Into_Text_Strings` (fixed) → `Get_Member_Campaigns` → `Screen_Pick_Campaign` datatable → `Assign_Campaign_Onto_Transaction` → `Create_Gift_Transaction`. **Path pass 3 of 4** toward lifting the no-flow-commits gate. Remaining: Pledge (new commitment) and Soft-credit Yes.
- **2026-07-18 — Fee-designation improvement parked as its own plan.** Justin flagged during the FeeForService UI test: fees currently route through the same designation picker as gift-restriction paths, diluting restriction rollups and forcing users to pick from unrestricted gift GDs. Decision: add fifth `FQS_Restriction_Type__c` picklist value **`Fee for Good or Service`** (label locked by Justin), wire the launcher's FeeForService branch to auto-filter on it, and seed a matching GiftDesignation. Parked as `.planning/fqs-fee-designation-plan.md` — separate commit boundary because it crosses picklist metadata + flow XML + seed Apex. Not in scope for the current launcher-parity commit. See new row in the open-plans table above.
- **2026-07-18 — Campaign picker never populated: self-referential Transform (deploy `0AfWB00000DTY0P0AX`).** Justin tested Outright w/ Campaign against Anthony Cohen FQS #42 after adding him to a Campaign — 0 rows still appeared. Data was fine (5 active CampaignMember rows on 5 active Campaigns confirmed via SOQL). Root cause: `Transform_Campaign_Ids_Into_Text_Strings` mapped `Get_Member_Campaigns[$EachItem].Id` — but the transform is the *input* to `Get_Member_Campaigns`, not its output. Self-reference; runtime returned an empty text collection; `Get_Member_Campaigns` filtered on `Id IN (empty)` → 0 rows, silently. **Fix:** map from `Get_CampaignMembers[$EachItem].CampaignId` (the CampaignMember row's CampaignId is the right source). **Pattern warning:** Flow silently tolerates references to elements that haven't executed in the current path — the value is treated as empty rather than throwing. Grep every Transform in `force-app/main/default/flows/**` for self-references — `<elementReference>SameOrDownstreamElement[$EachItem]...</elementReference>` inside a `<transforms>` block whose `<connector><targetReference>` is that same element.
- **2026-07-18 — Follow-up #2 naming collision check (vs. `fqs-record-naming-flows-plan.md`).** Current launcher formulas produce names like `Aaron Mitchell 250 2026-01-15` (space-separated, no `$`, no `on`/`due`/`over N years` verb). Target seed/naming-flow shape is `Aaron Mitchell FQS #3 - $250 on 2026-01-15`. **No runtime collision** — the naming flows are `RecordAfterSave` on Create+Update and will overwrite the launcher's Name (guarded by `FQS_Skip_Naming__c` + `FQS_Skip_Record_Naming` custom permission). Once naming flows deploy, the launcher's `formulaGiftTransactionName_OneTime` / `_Recurring` / `formulaGiftCommitmentName` and the four `rsv_*.Name = formula*` assignments become dead weight — the AfterSave flow rewrites the Name immediately. **Recommendation (post-naming-flows-deploy):** strip the four Name assignments + three formulas from the launcher rather than leaving them as maintenance debt. No action in this session — flagged for whoever ships `fqs-record-naming-flows-plan.md`.
- **2026-07-19 — Seed §13 gap closure landed (deploy `0AfWB00000DTfuj0AD`).** Closed §13.1 + §13.2 in `FQSSeedGenerator.cls`: (a) added `RECURRING_STATUS_WEIGHTS = [70, 10, 10, 10]` public knob + `pickRecurringStatus(seed, salt)` helper; wired into the recurring-commitment insert at salt 25 (previously unused). Pledged + Grant commitments stay `Active`. (b) Populate `NonTaxDeductibleAmount` on GiftTransaction insert — `TaxDeductionAmount` itself is `calculated:true, createable:false, updateable:false` in the org (verified in-org), so the launcher/ack flow's partial-deduction branch is driven indirectly via `TaxDeductionAmount = CurrentAmount - NonTaxDeductibleAmount`. Priority: Event-benefit-inclusion (15% NTD, salt 110+g, gated on `campaignCategoryByAskId[chosenCampaignId] == 'Events'` + `PROB_BENEFIT_INCLUSION = 0.10`) > donor-covers-fees (NTD = gatewayFee + processorFee) > null (full deduction). In-kind gifts stay null (full-deduction branch, safe). Picklist verification: `GiftCommitment.Status` on FundFirst returns `[Draft, Active, Lapsed, Failing, Paused, Closed]` — all four target values valid, no substitutions. Smoke seed at offset 9000 (10 donors, `PROB_RECURRING=1.0`, `PROB_DONOR_COVERS_FEES=0.5`, `PROB_BENEFIT_INCLUSION=0.5`) produced: 10 recurring commitments split 7 Active / 1 Failing / 1 Lapsed / 1 Paused (+ 1 pledged Active as expected); 25 gifts split 13 with partial NTD ($1.95–$15 range, all `< OriginalAmount`) and 12 with null NTD (full deduction). Invariant `NonTaxDeductibleAmount <= OriginalAmount` held. Smoke data torn down clean — no residual FQS-*-900* rows.

**Next action:** For each `?` plan above, read the plan file and mark status. Delegate in parallel — one Explore agent per plan, 200-word status back.

---

## Phase 2 — Repo ↔ FundFirst sync

**Definition of done:** `sf project retrieve start` against FundFirst produces zero unexpected diffs against `main`. Every drift item is either pulled into the repo or pushed to the org, with a one-liner explaining which direction and why.

**Approach:**
1. Land P1 commits first so `main` is coherent.
2. **Retrieve into a scratch worktree, not the working tree** (Gate C rule). `sf project retrieve start --target-org FundFirst --manifest <manifest of only FQS-scoped members>` — manifest-scoped, not object-scoped (Gate C).
3. **Apply Gate C's per-file relevance checklist to every new file in the worktree.** Delete bloat *before* the diff pass, not after.
4. `git diff` the cleaned worktree vs. `main`. For each diff:
   - If org is authoritative (someone edited in the UI) → pull to repo.
   - If repo is authoritative (planned change not yet deployed) → deploy to org.
   - If it's genuine drift with no clear owner → decision required, log here.
5. `.tmp-flow-drift/` likely holds prior drift artifacts — reconcile or delete (Gate C: add to `.gitignore`).

### Needs Justin confirmation (from Dar Veverka)

Dar is helping troubleshoot the FundFirst org; her org changes are held in this bucket until Justin explicitly accepts them into the repo. Do NOT auto-adopt during P2 retrieves — surface each item, get Justin's explicit accept/reject, then move to the appropriate P1 plan or discard.

Current contents (2026-07-16 FundFirst changes by Dar):
- Campaign object edits
- `FundraisingConfig`
- `Campaign_Base_Page`
- `FQS_Campaign_Record_Page`

**Findings:** _(agents write here)_

---

## Phase 3 — Bloat cull

**Definition of done:** Every `FQS_*` metadata item in the repo is referenced by (a) another metadata item, (b) an install step, (c) a documented feature, or (d) has an explicit "keep for extension" note here. Same for the org side.

**Depends on:** Phase 5 inventories (need the full list first).

**Note on scope:** If Gate C is running continuously through P1 and P2, this phase becomes a **verification pass** for Gate C escapes, not the primary bloat-catch. Anything found here indicates a `.forceignore` or retrieve-manifest gap that needs closing upstream. Ideal state: P3 finds ~zero new bloat and closes fast.

**Cull candidates already visible:**
- Any `FQS_*` field on an object where no flexipage, layout, flow, apex, or report references it
- Custom metadata types with only stale records
- Permission sets granting access to fields nothing else uses
- Docs in `docs/` superseded by newer versions
- `.tmp-flow-drift/` — almost certainly delete

**Findings:** _(agents write here)_

---

## Phase 4 — README / install-steps verification

**Definition of done:** A fresh scratch org, created only from what the README says to do, produces a working FQS install. Every command in the README is copy-pasted verbatim and works. Screenshots reflect current UI.

**Approach:**
1. `sf org create scratch --definition-file config/project-scratch-def.json --alias fqs-install-verify --duration-days 7`
2. Walk the README top-to-bottom. Every deviation from what the doc says → either fix the doc or fix the metadata.
3. Run seed scripts. Confirm they work against a fresh org, not just a warm one.
4. Verify permission sets grant what's claimed.
5. Verify the Fundraising_Quick_Start Lightning app opens and every FlexiPage renders.

**Blockers to watch for:**
- Order-of-deploy dependencies (permsets before pages, CMDT before flows that read it, etc.)
- Assumed prerequisite features (Nonprofit Cloud managed pkg, GiftEntry perms, etc.) not called out in README

**Findings:** _(agents write here)_

---

## Phase 5 — Inventories

Three sibling inventories, each a doc in `docs/` when done. **Run in parallel** — no shared state.

### 5a. Metadata inventory → `docs/fqs-metadata-inventory.md`
Every `FQS_*` metadata item: type, API name, purpose, dependencies, where-used. Build from `force-app/main/default/**` walk, cross-referenced against manifest.

### 5b. Feature inventory → `docs/fqs-feature-inventory.md`
Every user-facing feature: name, entry point (page/button/flow trigger), what it does, which plan it came from, permission required. Written for the end-admin, not the developer.

### 5c. Automation inventory → `docs/fqs-automation-inventory.md`
Every flow, apex trigger, apex scheduled job, DPE, rollup: name, trigger condition, what it does, order-of-execution notes, known interactions with other automation.

**Findings:** _(agents write here)_

---

## Phase 6 — Deploy to production

**Definition of done:** Managed metadata deployed to FundFirst prod (or whatever the "production" target is for GPS Accelerators — confirm), install-verified there, release notes written.

**Gates:**
- P1 green
- P2 zero drift
- P3 cull committed
- P4 README verified in fresh scratch
- P5 all three inventories committed

**Approach:** TBD once gates are green. Likely `sf project deploy start --target-org <prod>` with a validated-only pass first, then real deploy in a change window.

---

## SMQS Reference Shape — what "shipped" actually looks like

Extracted 2026-07-18 from `~/GitHubRepos/PSA-Stakeholder-Management-Quick-Start-DEV-1` (**the shipped repo**, not the working copy `-DEV`). Delta between the two is the most useful signal — it shows what "getting to ship" required.

### README outline (shipped)
```
## Description
### Included Assets
### Documentation Including
### License Requirements
### Accelerator or Technology-Specific Assumptions
## Implementation Steps
### Determine Install Location
### Before You Install
### Installation
### Post-Install Setup and Configuration
## Post-Install Considerations: Making This Work For You In Your Existing Setup
### 1. Review Component Configurations via the Home Page
### 2. Review Agentforce Nonprofit / Nonprofit Cloud Setup Steps
### 3. Review Profiles and Permission Sets
### 4. Review Lightning Apps, Pages, and Page Layouts
### 5. Establish Data Integrity Guardrails
### 6. Standard Address Feature Review
## Known Issues
## Backlog Items
## Miscellaneous
### Revision History
### Acknowledgements
### Terms of Use
```
- README is **47 KB** shipped — grew substantially from the working copy. Heavy "Post-Install Considerations" section with 6 numbered sub-guides. **This is the target size/shape** — expect FQS README to be similar or larger.
- **Known Issues + Backlog Items sections** ship visibly — honest transparency is expected.

### Metadata footprint (shipped, `-DEV-1`)
| Category | Count | Notes |
|---|---|---|
| Custom objects | **0** | extends 11 standard/PSA: Account, Contact, ACR, AAR, CCR, CPA/CPE/CPP, PRG, PRR, PersonAccount |
| Custom fields | **208** | across those standard objects — big surface area, all on standard objects |
| Permission sets | 3 | `SMQS_Custom_Fields`, `SMQS_Person_Account_Fields`, `SMQS_Split_and_Merge_Households` |
| Flexipages | 10 | |
| Flows | **40** | up substantially from `-DEV` — sync/subflow explosion during productization |
| Apex classes | **5** | `SMQS_Member` + 4 test classes. Support/utility only, no business logic |
| LWC | 0 | |
| Custom metadata types | **1** | `SMQS_Party_Relationship_Role__mdt` with 24 seeded records |
| Applications | 1 | |
| Quick actions | 19 | |
| Report types + Reports | 8 + 2 | |
| Tests | Apex: 4 · Playwright: 5 spec files · Jest: config only | No coverage % claim in README |

Previous audit numbers (`-DEV` — the working copy, NOT shipped) were wildly off: it had 9 custom fields vs. the shipped 208, 17 flows vs. shipped 40, zero Apex vs. shipped 5. **Ignore that data — it was pre-productization.**

### Delta `-DEV` (working) → `-DEV-1` (shipped) — the productization diff

**Added to ship:**
- **`Stakeholder Management Quick Start/` mdapi export directory** — the actual package artifact. FQS will need one at P6.
- **`destructiveChangesPost.xml` at repo root** — declares what the install removes. FQS may need one.
- **`datapacks/`** — release-time artifacts.
- **`test-results/`** — regression artifact directory.
- **`core.code-workspace`** — VS Code workspace file.
- **~14 new sync/subflow flows** — massive refactor from monolithic screen flows to sync + subflow pattern (`SMQS_Address_Sync_*`, `SMQS_Email_Sync_*`, `SMQS_Phone_Sync_*`, `SMQS_Screen_Manage_ContactPoints_*_Subflow`, `SMQS_Household_Setup_IsHousehold_Enforcement`). **This is the biggest lift — screen-flow architecture matured during productization.**
- **7 new docs in `docs/`**: `metadata-inventory.md`, `flows-chart.md`, `contact-points-flow-review.md`, `manage-contact-info-refactor-plan.md`, `manage-contact-point-flows-handoff.md`, `screen-flow-test-plan.md`, `telemetry-feedback-plan.md`. **The inventory doc that shipped is a real one, not a placeholder.**

**Stripped before ship:**
- `compare-tmp/`, `retrieve-tmp/` — scratch dirs (FQS's parallel: `.tmp-flow-drift/` — delete)
- Stray root `package.xml` — remove
- **Legacy monolithic screen flows replaced** by the subflow refactor: `SMQS_Screen_Manage_ContactInfo`, `SMQS_Screen_Manage_ContactPointEmail`, `SMQS_Screen_Manage_ContactPointPhone`, `SMQS_Household_Setup_Coupling_Account`

**Normalized:**
- All flow files renamed `.flow` → `.flow-meta.xml` (source-format normalization). FQS is already using `.flow-meta.xml` throughout — no work needed.
- `.forceignore`, `.gitignore`, `.vscode/settings.json` cleaned up.

### docs/ folder — the shipped bar
SMQS shipped **10 docs**, of which only some were canonical inventories. Working docs (flow-review, refactor-plan, handoff) shipped in place. The **`metadata-inventory.md`** is the one that maps cleanly to FQS's Phase 5a.

**FQS implication:** Phase 5 doesn't have to be pristine — SMQS shipped working docs alongside inventories. The bar is "did the doc exist and was it useful," not "was it polished for external readers." That said, do NOT ship `DOCS_FOLDER_INSTRUCTIONS.md` (template stub) — SMQS did and it's noise.

### Permission set pattern (steal this)
- `SMQS_Custom_Fields` — base fields (208 of them on standard objects)
- `SMQS_Person_Account_Fields` — PA overlay
- `SMQS_Split_and_Merge_Households` — narrow admin capability

**FQS parallel already partly in place:** `FQS_Custom_Fields`, `FQS_Person_Account_Fields`. Third narrow-capability permset TBD during P3 — candidates: `FQS_Campaign_Hierarchy_Admin`, `FQS_Match_Processor`, `FQS_Gift_Acknowledgement_Queue_Member`.

### Install-step complexity (shipped)
Single unmanaged package via URL (`04tfn000005a8Vd`) — sandbox + prod links both documented in README. Person Accounts is a pre-req. **24 CMDT records seed default relationship roles** at install time. Post-install setup is manual (documented in 6 numbered README sub-guides).

**FQS parallel:** FQS install will add three SMQS-absent steps — (1) CMDT configuration (donor grouping thresholds, campaign templates, gift-ack routing), (2) queue creation (`FQS_Gift_Acknowledgements`), (3) optional seed-data run. Each needs a README sub-guide.

### Test coverage (shipped)
- **Apex: 4 test classes** — `SMQS_MemberTest`, `SMQS_ManageContactPointFlowTest`, `SMQS_HouseholdFlowTest`, `SMQS_AddressSyncFlowTest`. Note: SMQS wrote tests to cover its **flows**, not just its Apex — flow-behavior tests using Apex are the ship-quality pattern.
- **Playwright: 5 spec files** in `tests/playwright/` (full harness with config, auth, helpers).
- **Jest config present, no LWC to test.**
- **No coverage % claim in README** — parity here is fine.

**FQS implication:** FQS already has `FQS_CampaignHierarchyBuilder_Test`, `FQS_MatchServices_Test`, `FQS_CustomMetadataSaver_Test`. Missing: **Apex tests that cover the flows** (Gift Entry launchers, Campaign hierarchy setup, Gift Acknowledgement scheduled flow). SMQS shipped with flow-behavior Apex tests — FQS should match.

### Repo hygiene (shipped root)
Present: `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CODEOWNERS`. **No `CHANGELOG.md`** — Revision History section in the README serves that purpose. **`destructiveChangesPost.xml` at root.**

### Delivery vehicle
Unmanaged package install URL is the primary path. **Both `test.salesforce.com` (sandbox) and `login.salesforce.com` (prod) links** appear in the README. Also implicit path: metadata deploy from `force-app/main/default/`. No SFDX-scripted install script.

### Signals for FQS release readiness (from the delta)
1. **Add an mdapi export directory** at repo root (SMQS shipped `Stakeholder Management Quick Start/`). FQS's parallel becomes `Fundraising Quick Start/`.
2. **Add `destructiveChangesPost.xml`** at repo root if any FQS install removes things.
3. **Delete scratch/tmp directories** — for FQS, that's `.tmp-flow-drift/` for sure.
4. **Refactor monolithic screen flows into subflow pattern** — the Gift Entry launcher is the FQS-equivalent candidate. This overlaps with `fqs-account-launcher-flow-parity-plan` + `fqs-gift-entry-account-launcher-plan` (consolidate them in P1).
5. **Ship a real `metadata-inventory.md`** — Phase 5a's SMQS analogue exists as a shipped doc.
6. **Add a flows-dependency chart** (SMQS's `flows-chart.md`) — Phase 5c's automation inventory.
7. **README grows substantially during productization** — expect ~47 KB with 6 numbered post-install sub-guides. Don't aim for terse.
8. **Ship flow-behavior Apex tests** — not just service-class tests.

---

## Completed (appendix)

_(empty — collapse phase bodies here as they finish)_
