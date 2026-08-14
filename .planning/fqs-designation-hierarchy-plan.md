# FQS Designation Hierarchy — inheritance, override UX, restriction-type gating

**Status:** decisions locked 2026-07-27 (round 3); ready for Phase 2 implementation.
**Created:** 2026-07-26. **Updated:** 2026-07-27 (round 2 processed Q11/Q12/Q13; round 3 backed out the Q11 category-match tier).
**Owner plans it depends on / touches:**
- [fqs-designations-plan.md](./fqs-designations-plan.md) — schema + setup catalog + D2 precedence (baseline this plan refines)
- [fqs-gift-entry-wizard-plan.md](./fqs-gift-entry-wizard-plan.md) — launcher shape this plan changes
- [fqs-account-launcher-flow-parity-plan.md](./fqs-account-launcher-flow-parity-plan.md) — existing precedence in launcher today
- [fqs-fee-designation-plan.md](./fqs-fee-designation-plan.md) — Earned Revenue picklist add (interlocks with restriction-type gate)

---

## Goal

Tighten and unify how the launcher chooses a designation for a gift. Two problems today:

1. **Precedence is inconsistent across leaves.** The current launcher has GC-default, Campaign-default, restriction-picker, and org-wide-default checks scattered across branches with per-leaf routing. It works, but reviewers can't reason about "which designation lands on this GT under conditions X" without reading the whole flow.
2. **Users pick restriction type on leaves where they shouldn't.** Restriction-type filtering (Without / Purpose / Permanent) is exposed today on any Conditional path. That's wrong on payment leaves — a Pledge Payment against a `Purpose`-restricted commitment IS purpose-restricted; the user shouldn't be re-picking a restriction. Restriction-type should only be a user choice at commitment-creation time.

Ship a single, uniform hierarchy and a single UX surface (the Campaign screen) that shows what will apply and lets the user override.

---

## Hierarchy — locked

**Precedence, most-specific wins** (top halts evaluation):

| # | Source | Applies on | Notes |
|---|--------|-----------|-------|
| 1 | Existing `GiftTransactionDesignation` on the GT | Update-existing-GT path (Pledge Payment E2) only | **This flow never touches an existing GTD. Full stop.** If the GT already has one or more GTDs, they are honored as-is regardless of any GDD upstream. |
| 2 | Parent `GiftCommitment`'s `GiftDefaultDesignation` (GDD) | Any leaf that writes a GT parented to a GC (Pledge Payment, Recurring first-GT, Scheduled first-GT) | Only fires when we're creating a **new GT** or the GT has **no GTD**. |
| 3 | `Campaign`'s `GiftDefaultDesignation` (GDD) | Any leaf where a Campaign is selected | Same "new GT / no GTD" gate as #2. |
| 4 | User picker on `Screen_Pick_Designation` | Simple / Scheduled / Recurring / Grant Pledge **commitment-creation** leaves only | Filtered by user-picked restriction type. Not offered on payment leaves. |
| 5 | Org-wide default (`GiftDesignation.IsDefault = TRUE`) | Fallback for every leaf, including Special-category leaves | Platform's `processGiftCommitment` uses this — must always exist. If missing, hard block on Campaign screen per Q6. |

**Category-match tier removed 2026-07-27 (round 3).** Original plan proposed a category-match tier for In-Kind / Earned Income / Event Registration (SOQL on `FQS_Restriction_Type__c`, tiebroken by `TotalTransactionAmount`). Justin backed off — auto-selecting a single GD from a category is unreliable at runtime (multiple candidates, no defensible tiebreaker semantics; revenue-rollup ranking picks a plausible-but-not-obviously-correct answer that the user won't understand). Category identity has value for identifying **which GD is a category's default** at *setup* time, not for runtime auto-pick. Special leaves now fall through to org-default like every other leaf, with the same full-catalog fallback + warning if org-default is missing.

**Restriction-type filter offered only on:** commitment-creation leaves — Simple Pledge, Simple Grant Payout, Scheduled Pledge/Grant (Regular + Custom), Recurring Gift. **Never** on Outright, Pledge Payment, In-Kind, Fee for Service, Event Registration.

**Rationale.** A payment inherits its purpose from the commitment or campaign it's against. Restriction type is a property of the intent (the pledge) — the payments that fulfill that intent don't get to re-choose it. In-Kind and Fee for Service have their own designation-routing logic (fee-designation plan handles Earned Revenue) so they don't participate in the picker either.

### Campaign contract per leaf (locked 2026-07-27, Q4/Q5)

Campaign requirements are tighter than the launcher does today. This unlocks the "no separate Pledge-Payment Campaign picker" simplification and eliminates the GC-vs-Campaign-default conflict scenario at its root.

| Leaf | Campaign | How resolved |
|---|---|---|
| Outright | **Required** | User picks on `Screen_Pick_Campaign` |
| Pledge Payment | **Inherited from the picked GC, not user-picked** | Read `GiftCommitment.CampaignId` on the picked GC. `Screen_Pick_Campaign_Pledge` shows it as read-only. Consequence: **no GC-vs-Campaign-default conflict is possible on Pledge Payment** — Campaign is derived from the GC, so if the GC has GDD → Fund A and its own Campaign has GDD → Fund B, Fund A wins per precedence #2 and Fund B never enters evaluation. `Screen_Designation_Conflict` is not needed and is not built. |
| Pledge Payment — **when GC has no CampaignId** (Q12 locked 2026-07-27) | **Statement + advisory, no picker, no auto-choose** | Read-only display: *"This commitment isn't attached to a campaign. Attach one on the commitment record if this gift should count toward a campaign."* No user-picker on this leaf — the flow proceeds without a Campaign tier in the resolver (falls through to org-default). Never writes `CampaignId` onto the payment GT. |
| Simple / Scheduled / Recurring / Grant (commitment-creation) | **Required** | User picks on `Screen_Pick_Campaign` |
| In-Kind | **Optional** | Show picker but let user skip |
| Earned Income (Fee for Service) | **Optional** | Show picker but let user skip |
| Event Registration | **Required** | User picks on `Screen_Pick_Campaign` — no "walk-up event" fallback for this launcher |

---

## UX — one screen, always-visible, override-first

**Design principle:** the user always knows *which designation is about to land on this gift* before they hit Next. No silent pre-fill they discover after the fact. This diverges from the current `fqs-designations-plan.md` §D2 "silent pre-fill" pattern — flagged as an open question below.

**Surface: `Screen_Pick_Campaign` (and its sibling `Screen_Pick_Campaign_Pledge`)** — the Campaign screen is the natural home because Campaign is where the last inheritance decision resolves. By the time the user is on the Campaign screen we know:

- Which leaf they're on (so we know if we're in the commitment-creation branch or a payment branch)
- Whether they picked a GC (Pledge Payment) — GC-default already resolved
- Which Campaign, if any (Campaign-default will resolve next)

**Screen layout (proposed):**

```
Campaign
  [ Campaign picker ]  ← existing

Designation
  Applying: FQS Youth Services (from Campaign default)     ← read-only summary line
  [ Override designation ]  ← button; opens Screen_Pick_Designation
```

The summary line renders one of these states:

| Resolved from | Summary text |
|---|---|
| Existing GTD (Pledge Payment update path — GT already has GTDs) | "This gift keeps the designations already on the transaction." (no override button — locked; Q3-B) |
| GC's GDD | "Applying: **<GD name>** — from the commitment's default." |
| Campaign's GDD | "Applying: **<GD name>** — from the campaign's default." |
| Org-wide default | "Applying: **<GD name>** — the org default. No campaign or commitment default set." |
| Org-wide default missing (any leaf) | Hard block on Campaign screen per Q6-A: "Set up designations before continuing." Points to `FQS_Suggest_Designations`. |

**Override button behavior (Q2-A locked):**
- Payment leaves (Outright, Pledge Payment, In-Kind, Earned Income, Event Registration): opens `Screen_Pick_Designation` with **no restriction-type filter** — all active GDs shown. User has to pick from the full catalog. No filter = user knows they're taking manual control.
- Commitment-creation leaves: user picks restriction type **after** the Campaign screen (Q7-B), not before. Override on the Campaign screen therefore doesn't need a restriction filter yet — the picker is the same unfiltered picker until the user gets to `Screen_Pick_Restriction` and locks intent.

**Split UX (per fqs-designations-plan.md §D1)** is orthogonal — the split toggle still lives on `Screen_Details`. When split is ON, this screen's summary line reads "Applying: custom split — set on the next screen" and the override button is disabled (the split table on Details owns the picks).

---

## Wiring

### Elements to add / rename

| Element | Type | Purpose |
|---|---|---|
| `var_ResolvedDesignationId` | Text variable | Holds the winning GD Id after hierarchy resolution. Written by the resolver, read by the summary formula. |
| `var_ResolvedDesignationSource` | Text variable | One of `Existing_GTD` / `GC_Default` / `Campaign_Default` / `Org_Default` / `User_Override`. Drives summary text. |
| `Get_Existing_GTDs_For_Update_GT` | Get Records | On the Pledge Payment update-existing path only. If any GTDs exist, halt at #1 in the precedence table. |
| `Get_GC_Default_Designation` | Get Records | Existing element (`Get_Commitment_Default_Designation`), keep. |
| `Get_Campaign_Default_Designation` | Get Records | Existing element (`Get_Campaign_Default_Designations`), keep. |
| `Get_Org_Default_Designation` | Get Records | New — SOQL `SELECT Id, Name FROM GiftDesignation WHERE IsDefault = TRUE AND IsActive = TRUE LIMIT 1`. |
| `Resolve_Designation_Hierarchy` | Decision | Chained routes: existing-GTD → GC-default → Campaign-default → user-restriction-picker (commitment-creation leaves only) → org-default. Writes `var_ResolvedDesignation*` at each terminal. |
| `formulaResolvedDesignationSummary` | Formula | Composes the read-only summary line on the Campaign screen from `var_ResolvedDesignationSource` + `Get_Resolved_GD.Name`. |
| `Screen_Pick_Designation` | Existing | **No restriction-type filter applied on payment leaves.** Filter binding gated on `var_Category = 'Commitment_Create'` or equivalent. |

### Elements to remove or restructure

- `Assign_Restriction_Unrestricted` — remove. Restriction type is no longer a hidden default on payment leaves; the resolver decides based on inheritance, and payment leaves never need a restriction-type variable at all.
- The current implicit precedence chain in `fqs-account-launcher-flow-parity-plan.md` §Redesigned pledge structure — consolidate into the single `Resolve_Designation_Hierarchy` Decision. Every leaf routes into this Decision after its Campaign screen, before its Details screen.

### GTD writes

- **Payment leaves (new GT insert):** `Assign_Build_GTDesignation` writes `GiftDesignationId = var_ResolvedDesignationId`, `Percent = 100`, `Amount = OriginalAmount`.
- **Payment leaves (update-existing GT):** the flow does NOT touch existing GTDs. If none exist on the update-target GT, insert one using `var_ResolvedDesignationId` (open question below — should the update path even insert a GTD if the existing GT has none?).
- **Commitment-creation leaves:** insert one GDD (`AllocatedPercentage = 100`, `GiftDesignationId = var_ResolvedDesignationId`) parented to the new GC. Plus the first GT's GTD if the leaf also creates a first GT (Recurring). This matches today's `Assign_Build_Default_Designation` behavior — just reads from the resolver.

---

## Restriction-type screen — kept, gated, **after Campaign** (Q7-B)

The current restriction-type picker (`Screen_Pick_Restriction`) stays, but only reachable from commitment-creation leaves, and now runs **after** the Campaign screen — not before as originally proposed. Reasoning: if the Campaign GDD (or the resolver's other tiers) already satisfies the intent, the user doesn't need to be prompted for restriction at all. Only if they hit "Override designation" on the Campaign screen do they land in `Screen_Pick_Restriction` to filter the picker.

Wire the wizard so that:

- `var_Category = Monetary` → Outright/Payment leaves → skip `Screen_Pick_Restriction` entirely
- `var_Category = Future` and leaf ∈ {Simple, Scheduled_Regular, Scheduled_Custom, Recurring} → Campaign screen resolves default silently; if the user hits Override, route to `Screen_Pick_Restriction` → filtered `Screen_Pick_Designation` → back to Details
- `var_Category = Special` → skip restriction picker entirely; resolver falls through to org-default. Category-match tier was considered and dropped (see precedence table note below tier 5) — runtime auto-pick from a category is unreliable when the category has multiple candidates.

Restriction-type picker filters `Screen_Pick_Designation` (only reachable via the "Override designation" button when user takes manual control on a commitment-creation leaf, or automatically when no default exists upstream).

---

## Files to touch

- `force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml`
  - Add resolver Decision + var declarations
  - Rewire every leaf to route Campaign screen → resolver → Details screen
  - Add read-only summary field + Override button on both Campaign screens
  - Remove `Assign_Restriction_Unrestricted` and clean up per-leaf precedence forks
- (Same file, sibling variants) `FQS_Gift_Entry_Single_Launcher_GiftCommitment.flow-meta.xml`, `FQS_Gift_Entry_Single_Launcher_Opportunity.flow-meta.xml` — mirror
- No new fields, no picklist changes, no permset changes (all reads on existing GDD / GD)

---

## Execution phases

1. **Metadata prep** — none. Uses only existing fields.
2. **Campaign-contract rewire (Q4-derived).** Make Campaign required on Outright + Event Registration, optional on In-Kind + Earned Income, inherited (read-only) on Pledge Payment from `GC.CampaignId`. Deletes `Screen_Pick_Campaign_Pledge`'s user-picker binding; replaces with read-only display. Deploy + smoke this in isolation so the summary-line work has a stable Campaign contract to sit on.
3. **Resolver Decision** — build `Resolve_Designation_Hierarchy` with placeholder terminal Assignments that write `var_ResolvedDesignation*`. Wire one leaf (Outright) through it first as a proof of concept. Deploy + smoke.
4. **Campaign-screen summary + override** — add read-only summary field + button on `Screen_Pick_Campaign` first (single-instance test surface). Deploy + smoke.
5. **Fan out to remaining leaves** — Pledge Payment (with the existing-GTD short-circuit → Q3-B leave-alone + Q3-C Success-screen warning), Simple/Scheduled/Recurring/Grant, In-Kind, Earned Income, Event Registration.
6. **Restriction-picker relocation (Q7-B).** Move `Screen_Pick_Restriction` from before-Campaign to after-Campaign on commitment-creation leaves. Remove from payment-leaf paths entirely.
7. ~~Category-match resolver tier~~ — **removed 2026-07-27 (round 3).** See precedence-table note below tier 5.
8. **Org-wide-default hard block (Q6-A) + pre-release checklist (Q13 — Gate A + admin README). SHIPPED 2026-07-28 (deploy `0AfWB00000Df1bl0AB`).** New terminal screen `Screen_Block_Missing_Org_Default` fires when `Get_Org_Default_Designation` returns zero rows. `Decide_Resolver_Has_Org_Default`'s default connector was rerouted from `Screen_Pick_Designation` to the block screen. Screen has `allowFinish=true` with no `<connector>` per [[flow-allowfinish-blocks-next]] — Finish exits the flow, admin runs `FQS_Suggest_Designations` (or manually flags `IsDefault=TRUE` on an active GD) and relaunches. Also landed:
   - **Gate A entry** in [fqs-release-readiness.md](./fqs-release-readiness.md) §Gate A — "Org-wide default `GiftDesignation` exists" was already present (added Phase 3); no change needed.
   - **Admin README §V.1** — new post-install step "Establish an org-wide default Gift Designation" with two options (run `FQS_Suggest_Designations` or manually flag an existing GD) plus a SOQL verification step. Positioned as the first item in §V so it lands before the two Active-Designation lookup filter steps.
9. **Regression matrix** — one row per leaf × (GC-default present / not) × (Campaign-default present / not) × (category default present / not, for Special leaves) × (org-default present) × (user override taken / not). Verify `GiftTransactionDesignation.GiftDesignationId` on the created row matches the resolver's decision.
10. **Commit** — Justin gates.

**Ship order (Q10-A locked):** land before Phase G regression. Resolver + summary line become part of the Phase G regression matrix, not a follow-on phase.

**Gate boundary:** phases 2/3/4 are separate deploys. Phase 5 is one deploy per 2–3 leaves. Phase 6/7/8 are separate deploys. Phase 9 is UAT only. Every deploy = Justin's greenlight per session-history norm.

---

## Interaction with in-flight plans

- **`fqs-designations-plan.md` §D2** currently locks "silent pre-fill, most-specific wins, user override always wins." **This plan proposes always-visible, not silent.** Open question below.
- **`fqs-gift-entry-wizard-plan.md`** — the wizard's Screen 2 (leaf picker) is upstream of this work. Resolver runs *after* leaf selection, so the wizard scaffold is unchanged.
- **`fqs-fee-designation-plan.md`** — when Earned Revenue picklist value exists, the Fee for Service and Event Registration leaves should hard-route to the Earned Revenue GD as their designation. That's a leaf-specific override of the resolver, not a fifth precedence level. Handled inside the resolver's Fee/Event branch.
- **Corporate match (`fqs-corporate-match-plan.md`)** — employer GT inherits the donor GT's GTD (per `fqs-designations-plan.md` D5). Unchanged. The resolver writes the donor GT's GTD; the employer GT clones it.

---

## Decisions locked 2026-07-27 (summary of Justin's answers)

| # | Topic | Decision |
|---|---|---|
| 1 | UX visibility | **A** — always-visible summary on Campaign screen |
| 2 | Payment-leaf override picker filter | **A** — no filter, full active-GD catalog |
| 3 | Update-existing-GT with no GTDs | **B + C** — leave GTDs alone AND warn on Success screen (no self-heal insert) |
| 4 | Campaign-optional leaves | **Rewire Campaign contract** — Pledge Payment inherits from GC (read-only), Outright now requires Campaign; no separate optional-Campaign branch needed |
| 5 | GC-vs-Campaign default conflict | **Impossible by construction** — Q4's rewire means Pledge Payment's Campaign IS the GC's Campaign, so no conflict scenario exists. `Screen_Designation_Conflict` is dropped. |
| 6 | Missing org-wide default | **A** — hard block on Campaign screen; also add "verify org-wide default exists" to pre-release checklist |
| 7 | Restriction-type screen order | **B** — after Campaign, not before |
| 8 | Summary rendering | **A** — Display Text field with inline formula reference |
| 9 | In-Kind + Event Registration + Earned Income | **Per-category default pattern** — treat like Outright (inherit → category-default → org-default → full-catalog fallback with warning). Campaign optional for In-Kind + Earned Income, required for Event Registration. |
| 10 | Ship order | **A** — land before Phase G regression pass |

---

## Round-2 decisions (locked 2026-07-27)

| # | Topic | Decision |
|---|---|---|
| 11 | Category-default mechanism | **Reuse existing schema** — `GT.FQS_Gift_Transaction_Category__c` (leaf) maps to a `GD.FQS_Restriction_Type__c` value via formula, resolver SOQLs for the first active GD with that restriction. No new field, no new picklist value, no per-category checkbox. In-Kind → `Without Donor Restriction`; Earned Income + Event Registration → `Earned Revenue` (per fee-designation plan). |
| 12 | Pledge Payment with a GC that has no CampaignId | **Statement + no auto-choose** — read-only advisory on `Screen_Pick_Campaign_Pledge`: *"This commitment isn't attached to a campaign. Attach one on the commitment record if this gift should count toward a campaign."* Never picks a Campaign for the user; resolver skips the Campaign tier for this run and falls through to org-default. |
| 13 | Org-wide-default checklist home | **Gate A + admin README** — dev-time verify in Gate A, install-time verify in README post-install steps. Skip Phase 1 UAT check (redundant if Gate A catches it). |

---

## Follow-up questions

None open. Ready for Phase 2 implementation on Justin's greenlight.


---

## Notes for future sessions

- Resolver is a single Decision element with N terminal Assignments. Do NOT fan it out into per-leaf Decisions — that's the pattern this plan is *replacing*. One resolver, many leaves route into it.
- The Campaign screen's summary line reads a formula, not a variable directly — because the summary text depends on both `var_ResolvedDesignationSource` (which source won) AND `Get_Resolved_GD.Name` (the GD name to render). Formula composes them.
- If you find yourself adding a special-case fork inside the resolver for a specific leaf, stop. That's the smell that this plan is failing. Special cases go on the leaf's own path *before* it enters the resolver (e.g., Fee for Service hard-writes `var_ResolvedDesignationId` before routing, so the resolver's chain is short-circuited at #1-equivalent).
- Per [[fundfirst-gcs-no-scheduletype]] and [[flow-in-operator-gotcha]] — when writing the resolver's `Get_Org_Default_Designation` SOQL, use `EqualTo TRUE` on IsDefault + IsActive, not any `In` operator. Silent 0-row returns break the resolver's fallback.

---

## Leaf × designation-behavior matrix (as-shipped after Phase 5d + multi-GDD bundle 2026-07-28)

Snapshot of what actually lives in [FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml) after Phase 3/4/5a/5b/5c/5d + reconciliation + multi-GDD. Use this table when reasoning about any leaf's designation behavior end-to-end.

| # | Leaf | Campaign | Designation source (resolver tier) | Override allowed | Split-aware (Platform_Split) | Flow writes GTD? | Flow writes/updates GC's GDD? |
|---|---|---|---|---|---|---|---|
| 1 | Outright (one-time cash) | Optional | Tier 3 Campaign → Tier 5 Org | Yes | Yes (Campaign side) | Yes, unless split → platform fans out | N/A (no GC) |
| 2 | In-Kind | Optional | Tier 3 Campaign → Tier 5 Org | Yes | Yes (Campaign) | Yes, unless split | N/A |
| 3 | Earned Income / Earned Revenue | Optional | Tier 3 Campaign → Tier 5 Org | Yes | Yes (Campaign) | Yes, unless split | N/A |
| 4 | Event Registration | Optional (originally required per Q4; runtime allows optional today) | Tier 3 Campaign → Tier 5 Org | Yes (picker filter deferred on payment/Special) | Yes (Campaign) | Yes, unless split | N/A |
| 5 | Special (tribute / grouping) | Optional | Tier 3 Campaign → Tier 5 Org | Deferred — empty-picker bug parked | Yes (Campaign) | Yes, unless split | N/A |
| 6 | Simple Pledge (commitment, no schedule) | Optional | Tier 3 Campaign → Tier 5 Org | Yes; restriction gate applies | Yes (Campaign) | Yes on payment GT if manually added later | Yes — flow inserts GDD unless split |
| 7 | Scheduled Pledge (fixed schedule) | Optional | Tier 3 Campaign → Tier 5 Org | Yes; restriction gate applies | Yes (Campaign) | Platform-managed fanout on Expected GTs | Reconcile only — platform auto-inserts, flow *Updates* to Override pick (skipped when split) |
| 8 | Recurring Pledge (indefinite) | Optional | Tier 3 Campaign → Tier 5 Org | Yes; restriction gate applies | Yes (Campaign) | Flow writes first-payment GT's GTDs (incl. split fanout); platform handles future | Reconcile only (or insert if no auto-GDD) — skipped when split |
| 9 | Pledge Payment | **Inherited from GC** (`GC.CampaignId`) | **Tier 2 GC_Default** → Tier 3 Campaign → Tier 5 Org | Yes | Yes — **GC-side** collection via `Loop_Fanout_Split_GTDs_GC` | Yes, unless split | N/A (parent GC pre-exists) |

**Rules encoded in the flow:**
- **Tier 0 Platform_Split** fires ahead of every tier when either the picked Campaign OR (PP only) the parent GC has >1 GDD. Terminal leaves `rsv_SelectedDesignation.Id` null on purpose so `Decide_Create_Designation` / `Decide_Create_Default_Designation` skip and the platform's native multi-row fanout is authoritative — *except* on Pledge Payment / Recurring first-payment where the flow's own new GT needs `Loop_Fanout_Split_GTDs_*` to walk the collection and write per-row GTDs.
- **Tiers 4 (User_Override) and 5 (Org_Default)** are out of scope for FQS 1.0 per Justin. Tier 5 becomes a Phase 8 hard-block. Tier 4 stays parked post-1.0.
- **Restriction gate** (Simple/Scheduled/Recurring): commitment-creation Override runs through `Decide_Override_Needs_Restriction` first — user must pick a matching `FQS_Restriction_Type__c` before the picker opens.
- **Reconciliation guard**: `Decide_GC_GDD_Post_Process` skips Update-or-Insert entirely when `var_PlatformSplitApplies=true` so the platform's split copy on the GC stays intact.

## Terminology — "Tier" ≠ Campaign hierarchy

"Tier" in this plan refers ONLY to the **designation resolver's precedence order** — the 5-level chain the `Resolve_Designation_Hierarchy` Decision walks to decide *which `GiftDesignation` lands on the GT*. It is unrelated to Salesforce Campaign parent/child hierarchy (`Campaign.ParentId` chains).

| Concept | What it is | Where it lives |
|---|---|---|
| **Resolver tier** (this plan) | Precedence rank inside the launcher's designation-picker logic (Tier 0 Platform_Split → 1 Existing_GTD → 2 GC_Default → 3 Campaign_Default → 4 User_Override → 5 Org_Default) | `Resolve_Designation_Hierarchy` Decision inside the launcher flow |
| **Campaign hierarchy** (Salesforce standard) | Parent → child Campaign relationship via `Campaign.ParentId`; used for rollup summaries (`ParentCampaign` rollups) and grouping | Standard Campaign object, unrelated to this flow |
| **FQS Campaign Hierarchy Setup** (shipped) | Separate flow (`FQS_Campaign_Hierarchy_Setup`) that stamps campaign types + a hierarchy under a parent Appeal | Different flow; different problem space |

The resolver never traverses `Campaign.ParentId`. If a picked Campaign has no GDD, the resolver does NOT walk up to its parent Campaign — it falls straight to Tier 5 Org_Default. (Walking parent-Campaigns for a default was considered and dropped early: introduces silent surprises, and forces the user to know their org's Campaign hierarchy to reason about which designation will land.)

### Resolver tiers at a glance

The 6 tiers, in the evaluation order the `Resolve_Designation_Hierarchy` Decision walks:

| Tier | Source | Fires when | Status in 1.0 |
|---|---|---|---|
| **0 Platform_Split** | Picked Campaign OR (PP only) parent GC has >1 GDD | Skip flow's writes and let the platform fan out; on PP + Recurring first-payment, flow loops the collection and writes matching GTDs via `Loop_Fanout_Split_GTDs_*` | **Shipped** |
| **1 Existing_GTD** | GT already has GTDs (Update path only) | Never touch — honor as-is | **Shipped** |
| **2 GC_Default** | Parent GC's single GDD (`Get_GC_Default_Designation_For_Resolver`) | Pledge Payment only | **Shipped (Phase 5c.a)** |
| **3 Campaign_Default** | Picked Campaign's single GDD (`Get_Campaign_Default_Designations`) | Every leaf that picks a Campaign | **Shipped (Phase 3)** |
| **4 User_Override** | User clicked "Override" on Confirm screen | Out of scope for 1.0 | Parked (post-1.0) |
| **5 Org_Default** | `GiftDesignation.IsDefault = TRUE AND IsActive = TRUE` (`Get_Org_Default_Designation`) | Fallback everywhere | **Shipped (Phase 8)** — hard-block `Screen_Block_Missing_Org_Default` when zero rows; deploy `0AfWB00000Df1bl0AB` 2026-07-28 |

**Not the same as Campaign hierarchy.** The resolver never traverses `Campaign.ParentId`. If the picked Campaign has no GDD, resolver drops straight to Tier 5 — it does not walk up to a parent Campaign.

---

## Commitment-creation leaves — single-GD only; splits are a post-creation GC action (locked 2026-07-28)

**Supported behavior in the launcher for Simple Pledge, Scheduled Pledge, and Recurring Gift:**
- Launcher writes **exactly one** `GiftDefaultDesignation` on the new GC at 100% (`AllocatedPercentage = 100`, `GiftDesignationId = var_ResolvedDesignationId`).
- If the user wants to split the commitment across multiple designations, they do that **after** the GC exists by running the appropriate action on the GC record (managed FROps split-default-designations action, or an FQS-provided equivalent when we ship one).
- The launcher itself does not build a split-editor UI for commitment-creation. Not in 1.0, not planned.

**Why:** the multi-GDD support that already ships (Tier 0 Platform_Split, `Loop_Fanout_Split_GTDs_*`, reconciliation guard) covers the case where the picked **Campaign** is already split — the flow inherits the split cleanly. But letting the user *author* a split inside the launcher screens would (a) duplicate the GC's own split-editor UI, (b) complicate the resolver terminals, and (c) leave no obvious pattern for editing the split later. Keeping the launcher 100%-to-one and pushing splits to the GC record aligns with FROps' own pattern.

**UX consequence — Confirm screen copy addition needed (deferred to a later copy pass):**
- On commitment-creation leaves (Simple / Scheduled / Recurring), when `var_PlatformSplitApplies = false` (i.e., picked Campaign is NOT split and we're about to write a single-GD GDD), the Confirm screen should include an italic note: *"This commitment will use **{resolved GD name}** at 100%. To split across multiple designations, run the split-designations action on the commitment record after saving."*
- When `var_PlatformSplitApplies = true` on a commitment-creation leaf (split inherited from Campaign), the existing `ConfirmDesignationSplitExplain` DisplayText already covers it — no new copy needed.

**Edge case — Simple pledge on a split Campaign:** Tier 0 fires, `rsv_SelectedDesignation.Id` stays null, `Decide_Create_Default_Designation` skips flow's own GDD insert. Platform's `Process_Simple_Commitment` (if present) may or may not fan out — worth a 30-second UAT before Phase 8. If the new Simple GC ends up with **zero GDDs**, the fix is one of: (a) accept and document — user must run split-action on the empty GC, or (b) add a Loop_Fanout branch for Simple pledges too (mirrors the Recurring first-payment fanout, but writes GDDs on the GC instead of GTDs on the GT). Preference is (a) — matches the "splits are post-creation" policy.
