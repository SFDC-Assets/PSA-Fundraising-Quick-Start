# FQS Launcher Gate A Refactor Plan

**Status:** design-drafted, not-implemented
**Created:** 2026-07-31
**Trigger:** Gate A flow best-practices review of `FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml` (2026-07-31 session; findings in `.planning/fqs-release-readiness.md` Gate A section)
**Related plans:**
- `.planning/fqs-release-readiness.md` — Gate A tracker
- `.planning/fqs-gift-entry-wizard-plan.md` — the wizard shape being refactored
- `.planning/fqs-designation-hierarchy-plan.md` — resolver logic origin

**Owner:** Justin (solo)

---

## 1. Motivation

The 2026-07-31 Gate A review surfaced 4 P0 and 11 P1 findings on the Account launcher flow. The biggest structural finding: the flow is **12,213 lines / ~207 top-level elements**, well past Gate A's "~30 element" subflow-decomposition threshold. Two natural cohesion boundaries emerged:

- **Commitment-creation flow** (Pledge + Recurring + optional employer matching) — ~80 elements, self-contained transaction chain
- **Designation resolver hierarchy** — ~30 elements, reusable across every leaf (both commitment and payment)

Extracting these two subflows shaves ~110 elements from the parent (~55% reduction). Both are candidates for parity across the sibling GC + Opportunity launchers, so the extraction pays down debt twice.

Additionally: verified dead-code islands (`Get_Default_Designation` + `Decide_Has_Default_Designation` + `Assign_Default_Designation`, plus `Assign_Resolve_Designation_ExistingGTD` placeholder, plus 4 unused variables) can be pruned as pre-work independent of the subflow extraction.

## 2. Scope decisions (locked 2026-07-31)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Matching-gift branch** | **Include inside commitment subflow** | Recurring + match already runs `Create_Employer_Recurring_GC` immediately after `Create_Pledge`; splitting requires inter-subflow return-and-hand-off. Subflow grows to ~80 elements but avoids awkward mid-transaction contract. |
| **Designation resolver** | **Extract as separate subflow** | Reusable by all 9 leaves (both commitment and payment). Matches P0-3 finding. Called by both new commitment subflow AND parent's monetary leaves. |
| **PP-Update path** | **Keep in parent** | PP-Update updates an Expected GT to Paid — semantically distinct from commitment creation. Screens (`Screen_Existing_GTs`, `Screen_Confirm_Pledge_Payment_Update`, `Screen_Warning_Amount_Mismatch`) can extract later if they grow. |
| **Description rewrite depth** | **Full rewrite** | Each of ~326 descriptions rewritten for junior-admin voice: no jargon, line breaks between ideas, no external file references. Semantic content preserved; development history stripped. |
| **Description rewrite timing** | **Bundle with each subflow move** | Descriptions get rewritten as elements move into subflows (natural touchpoint). Parent-only descriptions get their pass in a separate commit. Avoids double-editing. |
| **Preserve dev history?** | **No** | Development history (Phase G7.5, deploy IDs, Bug-3 fixes, refactor context) lives in git log + tracker Findings + plan files. Descriptions describe current behavior only. |

## 2a. Description style rule (applies to every touched description)

Every `<description>` on every element (assignments, decisions, recordCreates, recordLookups, recordUpdates, screens, loops, actionCalls, subflows, formulas, variables, choices) that this refactor touches must be rewritten to match this contract. This rule also applies to any future flow work in this repo — not just Gate A cleanup.

**Target reader:** a junior Salesforce admin (Trailhead-basic level) who does NOT know FQS's history, does NOT have access to the `.planning/` folder or the memory files, and is looking at this flow inside Setup → Flows for the first time.

**Must do:**
- Lead with **what this element does today** — one sentence, plain English.
- Use **line breaks between ideas.** One idea per paragraph. Two or three short paragraphs is better than one wall.
- Spell out abbreviations on first use: "Gift Commitment" not "GC"; "Gift Commitment Schedule" not "GCS"; "Gift Transaction" not "GT"; "Gift Designation" not "GD".
- Prefer verbs to jargon: "The platform fills this in automatically" beats "Platform-managed field, back-filled from child record."
- When calling out a rule the admin needs to know, phrase it as a rule ("Do not set this on insert — Salesforce overwrites it") not as a warning about a specific past incident.

**Must not do:**
- **No references to files that don't ship in the org.** Ban list: `.planning/*.md`, `docs/*.md`, `[[memory-name]]` shortcuts, `README.md` sections, session log files. If the admin can't click through to it from inside Setup, don't cite it.
- **No development-phase names.** Ban list: "Phase G7.5", "Phase C.2b-collapse", "wizard plan §...", "launcher plan §...", "Custom-adds-GCS-per-row refactor", "Simple-leaf-adds-GCS refactor", any dated session context.
- **No bug references.** "Bug 3" / "the null-Name-on-Create failure" / "REQUIRED_FIELD_MISSING" — the fix is in the code, the description shouldn't relive the bug.
- **No deploy IDs.** `0AfWB00000...` never appears in a description.
- **No abbreviations without expansion.** No `PRR`, `ACR`, `PRG`, `GDD`, `GDSC`, `GSC`, `GTD`, `OSC` unless the description also spells them out. Prefer just spelling them out and dropping the abbreviation.
- **No developer voice.** No "we deploy", "we chose", "reverted after probe records X1x/XI5/XMv". Describe what IS, not what happened.
- **No internal element names as if the reader knows them.** If you reference `Assign_Prefill_From_Schedule`, follow it with a plain-English clause ("the step that fills in payment method from the schedule").
- **No `.description` field that only makes sense to the author.** If a junior admin can't act on it or learn from it, cut it.

**Sizing target:** most descriptions should land in 100–300 characters. If a description is over 400 characters, it's probably describing more than one thing — split the description across the actual elements that own each piece, or trim.

**Worked example.**

Before (858 chars, references `.md` file, uses "IsNull-gate" jargon, references Bug 3, wall of text):
> Pre-populates rsv_GiftTransaction with smart defaults before Screen_Gift_Details renders. ObjectProvided screen fields display the record variable's current value as the shown default, so seeding TransactionDate = TODAY and PaymentMethod = Cash here makes those defaults visible on the screen. Also guards Bug 3: without a TransactionDate seed, the Name formula (which concatenates TEXT(TransactionDate)) yields null and Create_Gift_Transaction fails with REQUIRED_FIELD_MISSING [Name]. IsNull-gate (Phase E, launcher plan): the assigned value is a formula that returns the existing value if non-null, else the fallback default (TODAY / Cash). This preserves prefilled values (e.g., Get_Commitment_Schedule.PaymentMethod = ACH) from Assign_Prefill_From_Schedule instead of stomping them. See .planning/fqs-gift-entry-wizard-plan.md §State at handoff prefill IsNull-gate policy.

After (~250 chars, two paragraphs, plain language):
> Sets default values for the Gift Details screen so the user sees Today's date and Cash payment method already filled in.
>
> If an earlier step already filled in values (for example, from an existing commitment's schedule), those existing values are kept — this step only fills in the ones that were still blank.

## 3. Deliverables

### 3.1 Subflow — `FQS_Gift_Entry_Commitment_Subflow`
Screen Flow (screens included — screens can live in subflows since Winter '24 platform support).

**Owns:**
- Three leaf details screens: `Screen_Pledge_Details`, `Screen_Scheduled_Details`, `Screen_Recurring_Details`
- Commitment creation chain: `Assign_Pledge_Defaults` / `Assign_Recurring_Defaults` / `Assign_Scheduled_Defaults` → `Create_Pledge`
- Schedule fanout: Simple (Yearly N=1), Scheduled Regular (single GCS), Scheduled Custom (N GCSs — the 2026-07-31 refactor), Recurring (open-ended GCS)
- Custom-branch Repeater + `Loop_Build_Custom_GCSs` + `Loop_Build_Custom_GTs` + `Decide_Custom_PastDate_Needs_GT`
- Past-date compensating GT authoring for Simple and Custom
- `Process_Custom_Commitment`, `Process_Simple_Commitment`, `Process_Scheduled_Commitment`, `Process_Recurring_Commitment` action calls
- Recurring first-payment GT (past-dated Recurring branch)
- **Matching-gift branch:** `Screen_Pick_Match_Employer`, `Screen_Set_Match_Amount`, `Screen_Warning_Match_Max_Exceeded`, ACR / PRG discovery loops (`Loop_ACRs_Match`, `Loop_PRGs_Match`), employer picker lookups (`Get_ACRs_Match`, `Get_EmployerPRGs_Match`, `Get_EmployerAccounts_Match`, `Get_Match_Employer`, `Get_Existing_ACR`), employer GT + GC + GCS + GDD creation (`Create_MatchACR`, `Create_Employer_GT`, `Create_Employer_Recurring_GC`, `Create_Employer_Recurring_GCS`, `Create_Employer_Recurring_GDD`), employer soft-credits (`Create_MatchSoftCredit_OnDonor`, `Create_MatchSoftCredit_OnEmployer`), donor-side pair-back update (`Update_Donor_With_Pair`)

**Inputs (from parent):**
- `recordId` (donor Account Id) — String
- `pkLeafFuture` — String (which future-monetary leaf: `SimplePledgeGrant` / `ScheduledPledgeGrant`)
- `pkLeafMonetary` — String (for Recurring routing)
- `rsv_SelectedCampaign` — Campaign SObject (may be null)
- `Get_Account` — Account SObject (avoids re-querying; passed by reference)
- `pkNeedsMatch` — String (Yes / No)
- Optional: designation inputs (see 3.2 resolver interface — subflow calls resolver subflow internally)

**Outputs (to parent):**
- `rsv_GiftCommitment` — the created GC (SObject)
- `rsv_GiftTransaction` — the first-payment GT if any (SObject, may be null)
- `var_LeafTraversed` — String (marker for smoke tests — see P1-4)
- Optional: `rsv_EmployerRecurring_GC` if matching branch fired

**Estimated size:** ~80 elements (Gate A threshold-bordering but justified — matching adds ~40 that can't cleanly split).

**API name convention:** `FQS_Gift_Entry_Single_Launcher_Account_Commitment_Subflow` (per SMQS `_Subflow` suffix convention, Gate A naming bullet).

### 3.2 Subflow — `FQS_Gift_Entry_Designation_Resolver_Subflow`
AutoLaunched Flow (no screens — pure decision + lookup + assignment).

**Owns:**
- Resolver decision chain: existing GTD → GC's GDD → Campaign's GDD → user picker → org-wide default
- `Resolve_Designation_Hierarchy` decision + all `Decide_Route_Outright_To_Resolver` / `Decide_Set_PlatformSplit_*` variants
- Related lookups: `Get_Commitment_Default_Designation`, `Get_Campaign_Default_Designations`, `Get_Campaign_Default_Designation_Detail`, `Get_Campaign_GDDs_Multi`, `Get_GC_GDDs_Multi`, `Get_GC_Default_Designation_For_Resolver`, `Get_Filtered_Designations`, `Get_Resolved_GD`, `Get_Org_Default_Designation`
- Multi-GDD split flag logic (`Loop_Count_Campaign_GDDs`, `Loop_Count_GC_GDDs`, `var_PlatformSplitApplies`)
- Terminal screens: `Screen_Block_Missing_Org_Default`, `Screen_Pick_Designation` (⚠ screen in autolaunched flow won't work — see §5 open question)

**Inputs (from parent):**
- `pkLeafMonetary` / `pkLeafFuture` / `pkLeafSpecial` (which leaf drives which resolver branch)
- `rsv_SelectedCommitment` (may be null on new-commitment leaves)
- `rsv_SelectedCampaign` (may be null)
- `rsv_GiftTransaction.Id` (for existing GTD check — payment leaves only)
- `pkRestrictionType` (user override input — commitment-creation leaves only)

**Outputs (to parent):**
- `rsv_ResolvedGD` — the resolved GiftDesignation
- `var_PlatformSplitApplies` — Boolean (skip GTD create, let platform fanout)
- `var_ResolvedFromSource` — String (which tier resolved — for the Success screen's "Applying: X — from Y" line)

**Estimated size:** ~30 elements.

**API name:** `FQS_Gift_Entry_Designation_Resolver_Subflow`.

### 3.3 Pre-work commit — dead-code cull
Independent of subflow extraction, ships first (small, isolated diff, easy to verify UAT-clean).

**Delete:**
- `Get_Default_Designation` (L6890) + `Decide_Has_Default_Designation` (L4354) + `Assign_Default_Designation` (L829) — 3-element dead island (verified 2026-07-31 by adversarial verify agent)
- Stale description at L7408 that falsely claims wiring to the "legacy Simple Pledge terminal"
- `Assign_Resolve_Designation_ExistingGTD` (L2297) — placeholder, self-declared not-wired (verified 2026-07-31)
- `col_CampaignIds` (L11656) — 0 references (verified 2026-07-31)
- `collEmployerAccounts` (L11762) — 0 references (verified 2026-07-31)
- `var_LoopId` (L12153) — 0 references (verified 2026-07-31)
- `rsv_SelectedSchedule` (L12039) — write-only, 0 reads (verified 2026-07-31)

Deploy + UAT (must launch each leaf and confirm no runtime regression from the removals — expected: none, since they're already dead).

### 3.4 Parent flow updates
After pre-work + both subflows deploy, edit parent to:

- Replace commitment-creation chain with `<subflows>` call to `FQS_Gift_Entry_Commitment_Subflow`
- Replace resolver chain with `<subflows>` call to `FQS_Gift_Entry_Designation_Resolver_Subflow` (called BOTH from parent's monetary leaves AND from inside the commitment subflow — same input contract)
- Rewire `Decide_Insert_Schedule` / `Decide_Match_Needed` connectors to the subflow input/output
- Update `Screen_Success` to consume `var_LeafTraversed` + `var_ResolvedFromSource` from subflow outputs

### 3.5 Description rewrite pass
Rewrites all ~326 element descriptions in the parent launcher + the two new subflows to match the §2a style rule.

**Scope of the pass:**
- 326 descriptions in the parent flow (as it stands today)
- All descriptions carried into the two new subflows during extraction
- Any new descriptions authored during the refactor (subflow-level `<description>`, new elements added in §3.1/3.2, etc.)

**Not in scope:**
- Sibling launchers (`FQS_Gift_Entry_Single_Launcher_GiftCommitment`, `FQS_Gift_Entry_Single_Launcher_Opportunity`) — those get the same treatment when they adopt the subflows in §3.6
- Any other FQS flow (`FQS_Setup_*`, `FQS_Gift_Acknowledgement`, etc.) — separate polish pass, own commit

**Ship strategy:** bundled with each subflow move so any given description is rewritten exactly once. Parent-only descriptions (elements that stay in the parent flow after the subflow extractions) ship in a final parent-cleanup commit.

**UAT for description-only changes:** deploy + spot-check in Flow Builder on FundFirst. Description edits are functionally inert — no runtime regression path. Confirm ≥5 randomly-picked descriptions read like §2a's target and don't reference `.md` files or Phase-N jargon.

### 3.6 Sibling launcher parity (deferred)
Once these two subflows land + UAT-green, the sibling `FQS_Gift_Entry_Single_Launcher_GiftCommitment.flow-meta.xml` and `FQS_Gift_Entry_Single_Launcher_Opportunity.flow-meta.xml` can adopt the same subflows without duplicating logic. Description rewrite pass runs against those files at the same time. Deferred to a follow-on plan.

### 3.7 Gate A checklist updates
Two stale bullets already flagged in Gate A findings:
- `Status='Paid'` hardcode rule — FQS is retroactive-entry, override intentional (documented)
- `ScheduleType` on insert — shape-dependent (updated 2026-07-31)

## 4. Other Gate A findings NOT in this plan's scope

These are P1/P2 findings from the 2026-07-31 review that are unrelated to the subflow refactor and can be addressed separately:

| Finding | Priority | Where |
|---------|----------|-------|
| 3 unguarded picker screens (Employer / Designation / Campaign) | P1-3 | Would need a `Decide_<Get>_HasRows` before each `Screen_Pick_*` |
| No `var_LeafTraversed` smoke marker | P1-4 | Add in the subflow extraction (§3.1 output) |
| 7 assignments with 10+ field writes | P1-7 | Cosmetic split; low priority |
| Deep 7-decision chain on PP-Update path | P1-9 | Collapse routing Decides; low priority |
| `Get_Campaign_Default_Designation_Detail` vs `_Designations` naming | P1-10 | Rename in subflow extraction |
| `Screen_Category` `allowBack=false` | P1-11 | One-line edit; ship any time |
| ~26 elements missing descriptions | P2 | Bundle with subflow moves |
| 4 variable-name prefix violations | P2 | Bundle with subflow moves |
| `Screen_Block_Missing_Org_Default` `allowBack=true` | P2 | One-line edit |
| `Err_Create` banned copy | P2 | Copy edit |

## 5. Open questions

1. **Screen in resolver subflow.** `Screen_Block_Missing_Org_Default` + `Screen_Pick_Designation` currently live inside the resolver logic. AutoLaunched subflows can't render screens. Options:
   - a. Make resolver a Screen Flow — parent's `<subflows>` invocation still works, screens render at their spot in the chain
   - b. Split resolver into "compute" (AutoLaunched, no screens) + "prompt" (Screen, called only when compute returns null-GD)
   - c. Keep those two screens in parent, resolver never routes to them — parent decides whether to show them post-resolver

   **Recommended:** (a) — Screen Flow subflow. Simpler, one file, matches how the wizard's soft-credit-reach subflows already do it.

2. **Custom-branch Repeater state.** `CustomInstallmentsRepeater.AllItems` is a synthetic screen-output collection. Moving the Repeater screen (`Screen_Scheduled_Details`) into the subflow means `.AllItems` also moves — but the seed-first-row assign (`Assign_Custom_SeedFirstRow`) uses `col_CustomScheduleRows`, which currently lives in parent scope. Whole Repeater state (source collection + Repeater screen + AllItems consumers) needs to move as one unit.

3. **`recordId` propagation.** Every subflow needs `recordId` (donor Account) passed as an input. Confirm this is treated as an input-mode variable, not just a global reference.

4. **`Get_Account` re-use.** Parent already runs `Get_Account` at the top; both subflows need its output. Pass as an SObject input to avoid re-querying — worth confirming SObject-passthrough works cleanly in Screen Flow subflows.

5. **Fault contract across subflows.** Parent's `Err_Create` screen currently handles all fault paths. If a subflow's `Create_*` fails, does the subflow's `faultConnector` catch it and route to a subflow-local `Err_*` screen, or does it re-throw to the parent? Cleaner: subflow catches and displays its own error screen; parent doesn't need to know about internal faults. Confirm.

## 6. Implementation order

1. **Ship dead-code cull first** (§3.3) — small, isolated, easy UAT. Descriptions on the deleted elements go with them; no rewrite needed.
2. **Ship resolver subflow** (§3.2) — smaller, no matching-branch complexity, tests one subflow's I/O contract in isolation. Descriptions on the ~30 extracted elements get rewritten against §2a as they move.
3. **Ship commitment subflow** (§3.1) — bigger, includes matching, reuses resolver from step 2. Descriptions on the ~80 extracted elements get rewritten against §2a as they move.
4. **Update parent flow** (§3.4) — final integration. Descriptions on the remaining parent-only elements get their §2a rewrite pass in this commit.
5. **UAT all 9 leaves** — full regression pass. Also spot-check ≥5 randomly-picked descriptions per §3.5 against §2a.
6. **Update Gate A tracker** with a Findings entry documenting the shipped shape and before/after description-length stats.
7. **Sibling launcher parity** (§3.6) — separate future plan.

## 7. Files to touch

- `force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml` — trim parent
- `force-app/main/default/flows/FQS_Gift_Entry_Commitment_Subflow.flow-meta.xml` — new
- `force-app/main/default/flows/FQS_Gift_Entry_Designation_Resolver_Subflow.flow-meta.xml` — new
- `.planning/fqs-release-readiness.md` — tracker updates
- `.planning/fqs-launcher-gate-a-refactor-plan.md` — this file (findings + progress)

No metadata changes outside of flows. No new fields, no permset edits.

## 8. Definition of done

- Both subflows deployed + Active in FundFirst
- Parent flow deployed with subflow calls
- 9-leaf regression UAT complete (Outright / PP-Insert / PP-Update / Recurring / Simple / Scheduled Regular / Scheduled Custom / InKind / EarnedIncome / EventReg)
- Gate A P0 count drops from 4 to 0
- Gate A P1 count drops by ≥ 5 (dead-code + subflow-extraction findings resolved)
- Every description in the parent flow + both subflows passes §2a: zero `.md` references, zero `docs/*.md` references, zero `[[memory-name]]` shortcuts, zero "Phase [A-Z]" / "wizard plan" / "launcher plan" tokens, average description length < 400 characters
- Tracker Findings entry documents the deploy IDs + before/after element counts + before/after description-length stats
