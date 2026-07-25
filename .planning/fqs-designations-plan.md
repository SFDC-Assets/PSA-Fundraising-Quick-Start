# FQS Designations Stack — Implementation Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** FundFirst (Nonprofit Cloud Fundraising, **not** NPSP)
**Status:** partially shipped — Phase 6.1 + 6.2 landed 2026-07-25 (release-date fields on GC + GT, permset). Phase 6.3+ (picklist reshape, setup flow, launcher edits, flexipages) still parked.
**Created:** 2026-07-22
**Owner:** Justin (solo)

**Supersedes:** two 2026-07-22 drafts. Draft 1 assumed GDD parents to Account, proposed 3 validation rules, and used Apex to seed production designations. Draft 2 kept the four-value picklist on `GiftDesignation.FQS_Restriction_Type__c` and treated time restrictions as a designation attribute. Both are wrong — see the correction summary at the bottom of Phase 8.

**Core reshape landing in this draft (Phase 1.5):** time restrictions move off `GiftDesignation` and onto the gift itself. Designation carries **purpose** only (or Permanent / Unrestricted / Fee); time lives on `GiftCommitment` and `GiftTransaction` via a new general-purpose `FQS_Restriction_Release_Date__c` date field. Dual-restriction gifts (donor imposes both purpose and time) = Purpose designation + non-null release date on the gift. No dual-select picklist, no auto-release logic — just a date, and reports interpret it.

**Related plans that constrain this one — read before executing:**
- [fqs-release-readiness.md](./fqs-release-readiness.md) — SOT for shipping FQS. Do not edit; Justin gates.
- [fqs-gift-entry-wizard-plan.md](./fqs-gift-entry-wizard-plan.md) — the category-wizard restructure of `FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml`. **This designation plan bolts onto that wizard, does not fight it.**
- [fqs-fee-designation-plan.md](./fqs-fee-designation-plan.md) — adds a 5th picklist value `Earned Revenue` to `GiftDesignation.FQS_Restriction_Type__c`. Coordination note in Phase 8.
- [fqs-account-launcher-flow-parity-plan.md](./fqs-account-launcher-flow-parity-plan.md) — field-parity contract for the launcher.
- [fqs-corporate-match-plan.md](./fqs-corporate-match-plan.md) — corporate-match rules. Match branch shares the donor GT's GTD split with the employer GT.
- [docs/npc-automation-notes.md](../docs/npc-automation-notes.md) — every platform contract cited below.

**Non-goals (locked out of scope):**
- `GiftSoftCredit` and soft-credit reach — separate initiative.
- Rollup fields on Account / Campaign — separate rollup work in flight.
- Data Cloud / analytics.
- Renaming `FQS_Restriction_Type__c` — see fee-designation plan §Non-goals.
- **No new validation rules.** Justin, 2026-07-22 — designations plan doesn't build any. Row-shape correctness is enforced by the launcher flow's assignment logic and by platform picklist/formula constraints.
- **No Apex creating designation records anywhere — production or dev.** `FQS_Suggest_Designations` (Screen Flow) is the sole path. `fqs-seed-foundation.apex` no longer creates designations; it reads whatever the setup flow created. Long-term goal (OQ12): expand this pattern to Campaigns and other shipped default record sets across FQS.
- **No Account-parent default designation.** Verified 2026-07-22 via `sf sobject describe`: `GiftDefaultDesignation.ParentRecordId.referenceTo = [Campaign, GiftCommitment, Opportunity]`. Account is not an allowed parent. Any "donor-level default" concept must be modeled another way (deferred — Phase 8 OQ4).

---

## Phase 0 — Current-state inventory (verified 2026-07-22 by read-only inspection)

### GiftDesignation

**Object file:** [`objects/GiftDesignation/GiftDesignation.object-meta.xml`](../force-app/main/default/objects/GiftDesignation/GiftDesignation.object-meta.xml) — sharing Private, no compact layout override, search layouts include `FQS_Restriction_Type__c`, `IsActive`, `IsDefault`, `TotalTransactionAmount`.

**Fields present** (in `objects/GiftDesignation/fields/`):
| Field | Type | Purpose | Managed by |
|---|---|---|---|
| `Name` | Text | Standard | Platform |
| `Description` | LongText | Purpose text | Platform (FQS added metadata file — behavior unchanged) |
| `IsActive` | Checkbox | Governs lookup filter on GDD/GTD | Platform |
| `IsDefault` | Checkbox | Org-wide fallback flag (exactly one GD should be `true` — required by `processGiftCommitment` action) | Platform |
| `External_Id__c` | Text(64), unique, external ID | FQS seed idempotency | FQS |
| `FQS_Restriction_Type__c` | Picklist (4 values, restricted) | Reporting restriction bucket + drives launcher's filter | FQS |
| 11 rollup fields | Roll-up-summary computed by `Manage Fundraising Definitions` batch | `TotalTransactionAmount`, `CurrentYearTrxnAmount`, etc. | Platform |
| `OwnerId` | Standard | | Platform |

**List views** (5, in `objects/GiftDesignation/listViews/`): `All_GiftDesignations`, `FQS_Active_Designations`, `FQS_Inactive_Designations`, `FQS_With_Donor_Restriction`, `FQS_Without_Donor_Restriction`.

**Flexipage:** [`FQS_GiftDesignation_Record_Page.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_GiftDesignation_Record_Page.flexipage-meta.xml) — 919 lines, substantive.

**Validation rules:** none. **Deliberately none to be added.**

**Gaps vs. NPC standard model:** none blocking.

### GiftDefaultDesignation (GDD)

**Object file:** [`objects/GiftDefaultDesignation/GiftDefaultDesignation.object-meta.xml`](../force-app/main/default/objects/GiftDefaultDesignation/GiftDefaultDesignation.object-meta.xml).

**Fields present:**
| Field | Type | Purpose |
|---|---|---|
| `ParentRecordId` | Polymorphic lookup — `Campaign` / `GiftCommitment` / `Opportunity` only (verified via describe) | Where the default is attached |
| `GiftDesignationId` | Lookup → GiftDesignation (FQS lookup filter: `IsActive = TRUE`, isOptional) | Which designation to pre-select |
| `AllocatedPercentage` | Percent | % of the parent's outgoing gift to route to this designation |
| `FQS_Parent_Type__c` | Formula(Text) — matches `6gc`/`006`/`701` prefixes | Reporting classification. **No fix needed** — the three prefixes exactly match the polymorphic target set. |
| `FQS_Restriction_Type__c` | Formula(Text), mirrors parent GD's restriction | Reporting |

**List views:** none. Not adding any.

**Flexipage:** [`FQS_GiftDefaultDesignation_Record_Page.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_GiftDefaultDesignation_Record_Page.flexipage-meta.xml) — 493 lines, exists.

**Validation rules:** none. Not adding any.

**Gaps vs. NPC standard model:** none blocking. The AllocatedPercentage-sums-to-100 concern is handled inside the launcher/setup flows (row-level percent validity has no VR — the picklist/percent field types constrain it, and the flow rejects invalid input at screen time).

### GiftTransactionDesignation (GTD)

**Object file:** [`objects/GiftTransactionDesignation/GiftTransactionDesignation.object-meta.xml`](../force-app/main/default/objects/GiftTransactionDesignation/GiftTransactionDesignation.object-meta.xml).

**Fields present:**
| Field | Type | Purpose |
|---|---|---|
| `GiftTransactionId` | Master-detail | Parent transaction |
| `GiftDesignationId` | Lookup → GiftDesignation (FQS lookup filter: `IsActive = TRUE`, isOptional) | Which designation |
| `Amount` | Currency | Dollar allocation for this row |
| `Percent` | Percent | % allocation for this row |
| `External_Id__c` | Text(64), unique | FQS seed idempotency |
| `FQS_Restriction_Type__c` | Formula(Text) mirroring parent GD | Reporting |

**Flexipage:** [`FQS_GiftTransactionDesignation_Record_Page.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_GiftTransactionDesignation_Record_Page.flexipage-meta.xml) — 716 lines, exists.

**Validation rules:** none. Not adding any.

**Gaps vs. NPC standard model:**
1. No mechanism enforcing sum-of-children on the parent GT. Today's launcher only ever creates 1 row per GT (`Percent=100`, `Amount=OriginalAmount`). The split UX in this plan enforces the sum in-flow at write time (no VR).

### Launcher-flow interaction (existing)

[`flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml`](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml) already has (verified via grep 2026-07-22):
- `Get_Campaign_Default_Designations` → checks Campaign for a GDD child
- `Decide_Campaign_Provides_Designation` → if yes, auto-selects that GD, skips picker
- `Get_Commitment_Default_Designation` → checks parent GC for a GDD child (Pledge Payment leaf)
- `Decide_Commitment_Has_Default_Designation` → if yes, filters designation picker by the commitment's restriction type
- `Get_Filtered_Designations` → SOQL: GDs matching selected restriction type
- `Screen_Pick_Designation` → user picks one
- `Assign_Restriction_Unrestricted` → default: `var_RestrictionType = 'Without Donor Restriction'`
- `Assign_Build_Default_Designation` → builds one GDD (100% allocated) — commitment leaves only
- `Assign_Build_GTDesignation` → builds one GTD (`Percent = 100`, `Amount = OriginalAmount`)
- `Create_GTDesignation` → inserts the single GTD
- `Create_GiftDefaultDesignation` → inserts the single GDD

**Implicit precedence today:** GC default (Pledge Payment) → Campaign default → user picker (Conditional path) / Unrestricted fallback → org-wide `IsDefault` at platform level.

### Rollup flow interaction

[`flows/FQS_Automatic_Rollup_Updates.flow-meta.xml`](../force-app/main/default/flows/FQS_Automatic_Rollup_Updates.flow-meta.xml) already invokes `Manage Fundraising Definitions` for `runGiftDesignation`. No changes.

### Existing setup flow surface

- [`flows/FQS_Setup_Orchestrator.flow-meta.xml`](../force-app/main/default/flows/FQS_Setup_Orchestrator.flow-meta.xml) — the setup entrypoint. Currently handles donor grouping CMDT + acknowledgement routing via subflows.
- [`flows/FQS_Setup_Flow.flow-meta.xml`](../force-app/main/default/flows/FQS_Setup_Flow.flow-meta.xml) — the outer wrapper.
- [`flows/FQS_Campaign_Hierarchy_Setup.flow-meta.xml`](../force-app/main/default/flows/FQS_Campaign_Hierarchy_Setup.flow-meta.xml) — invokable-Apex-backed builder that creates Campaigns from a template.

Pattern to follow for the new suggestion flow: Screen Flow with recordCreates, callable as a subflow (or standalone quick-launch) from the orchestrator. **Not** invocable Apex — Justin wants no Apex creating records in production.

### Seed generator interaction (dev/test only)

`FQSSeedGenerator.cls`:
- Seeds one GTD per GT (line 862–872) — `Percent=100, Amount=OriginalAmount`, random GD.
- Seeds one GDD per Conditional non-grant commitment (line 413–428) — `AllocatedPercentage=100`, round-robin restricted GDs.
- Foundation script `fqs-seed-foundation.apex` seeds 10 GDs (line 184–210).

**These are dev/test scripts, kept as-is scope-wise.** Seed generator gets one behavioral change (multi-designation splits at ~10%) so the wizard's split path has real data to exercise. That's a testing concern; not producing records in prod. Per [[seed-scripts-purpose]].

### Permset (existing)

[`permissionsets/FQS_Custom_Fields.permissionset-meta.xml`](../force-app/main/default/permissionsets/FQS_Custom_Fields.permissionset-meta.xml) — 6 field-permission entries covering the designation objects. No `<objectPermissions>` entries here; object CRUD comes from stock NPC permsets.

---

## Phase 1 — Design decisions (locked)

### D1. Split UX at gift entry — **percent-primary, amount-derived, opt-in table**

The single-designation happy path stays fast. Splitting is behind an "Enter custom split" toggle on `Screen_Details` in the wizard (per [fqs-gift-entry-wizard-plan.md](./fqs-gift-entry-wizard-plan.md) §Screen ordering line 276). When toggled on, an inline datatable prompts N rows of `(GiftDesignation lookup, Percent)`. Amount per row is computed at flow-save time as `ROUND(Percent × OriginalAmount / 100, 2)` with the last row absorbing the rounding remainder so amounts sum exactly to `OriginalAmount`.

**Rationale.**
- Percent is stable if user edits amount downstream; amount-primary drifts.
- Amounts are still persisted on `GTD.Amount` for reporting joins.
- Single-designation entry (~90% of gifts per seed distribution after D5) never sees the split table. Toggle default = off.
- **No new field on GT to track "was this split."** The GTDs themselves are the ledger.

### D2. Default-designation precedence — **silent pre-fill, most-specific wins, user override always wins**

**Locked precedence** (top wins if present and active):
1. **User's manual pick on this run** (custom-split toggle ON, or explicit picker choice)
2. **GC default** (Pledge Payment leaf — reads GC's child GDD)
3. **Campaign default** (all leaves — reads Campaign's child GDD)
4. **Restriction-picker screen** (Pledge Conditional path only) → filtered picker — post-D6 reshape offers 3 values (Without / Purpose / Permanent), no longer 4
5. **Org-wide default** (`GiftDesignation.IsDefault = TRUE`) — platform fallback via `processGiftCommitment`

**No donor-level (Account) default in the precedence chain** — the platform doesn't support GDDs parented to Account. If Justin wants donor-level defaults later, the only route is a new FQS-owned custom object (`FQS_Donor_Designation_Default__c` or similar) — deferred to Phase 8 OQ4.

**UX rule:** silent pre-fill for levels 2–3. On `Screen_Details` show a read-only summary line ("Designation: **FQS Youth Services** — from Campaign default") with an `[Override]` button that opens `Screen_Pick_Designation` (or the split table if the split toggle is on). No up-front confirmation; user override always wins.

**Conflict handling:** on the Pledge Payment leaf when GC-default and Campaign-default disagree, show `Screen_Designation_Conflict` — presents both, defaults to the more-specific (GC), lets user re-pick. Otherwise silent.

### D3. Validation strategy — **flow-only, no VRs**

- **Row-level:** platform picklist/percent field types constrain out-of-range Percent (< 0, > 100) at picklist bind time. Amounts are always computed from Percent, never user-entered directly, so no negative-Amount race.
- **Parent-sum:** launcher flow computes `SUM(rsv_GTDesignations.Percent)` and `SUM(rsv_GTDesignations.Amount)` after the split table. If either sum drifts (user-entered percents sum to 90, say), the flow shows `Screen_Split_Warning` — user can go back and correct, or proceed (permissive — accepts intentional partial allocation, e.g., 60% Scholarships + 40% Unrestricted where the user typo'd 30%).
- **Restriction-required-on-active:** covered by the setup flow only creating active GDs with a restriction value; existing GDs are not policed. If an admin manually creates an active-blank GD via UI, no VR blocks them — that's an edge acceptable for the accelerator.
- **Health check:** manual anonymous Apex snippet only, documented in Phase 7 T9 — not shipped as a scheduled Apex.

### D4. Split lives in — **Wizard 1 (the launcher)** with the opt-in toggle from D1

No separate Wizard 2. Splitting is a modality inside `Screen_Details`, not a separate flow.

### D5. Corporate match interaction

Per [fqs-corporate-match-plan.md](./fqs-corporate-match-plan.md) and [fqs-gift-entry-wizard-plan.md](./fqs-gift-entry-wizard-plan.md) §Matching-gift branch: **employer GT inherits the donor GT's GTD split.** After donor GT + GTDs insert, clone the GTD collection with `GiftTransactionId = <employer GT Id>`, keep same GDs / Percents / Amounts (Amounts scaled if match amount ≠ donor amount — proportional per row). External IDs: `FQS-GTD-<globalIdx>-<g>-M` for match rows.

### D6. Schema reshape — decouple time restriction from designation

**Locked.** Restrictions have two orthogonal dimensions and the current schema conflates them. Purpose is intrinsic to the designation ("Youth Coding Bootcamp" is evergreen). Time is intrinsic to the gift ("this pledge releases in FY2027"). A dual-restricted gift (donor imposed both a purpose and a time boundary) can only be moved out of restricted funds when both conditions clear — the schema must track both dimensions independently. A single-value picklist on GD can't represent that.

**Governing principle — GD stays evergreen (locked 2026-07-22, Justin).** A designation names *what the money is for*, not *when* or *whether* it's currently restricted. Every design decision here derives from that: no year-suffixed GD names, no time attribute on GD, no release logic hung off GD. Downstream reviewers and future partner-org admins should read this section and understand: if you're about to create a designation called "2027 Building Fund," you're doing it wrong — create "Building Fund" and put the 2027 boundary on the gift's `FQS_Restriction_Release_Date__c`.

**Picklist reshape on `GiftDesignation.FQS_Restriction_Type__c`:**

| Value | Action | Rationale |
|---|---|---|
| Without Donor Restriction | Keep | Unchanged. |
| With Donor Restriction - Purpose | Keep | The 95% case. |
| With Donor Restriction - Time | **Remove** | Time isn't intrinsic to a designation — belongs on the gift. |
| With Donor Restriction - Permanent | Keep | Endowment principal genuinely IS a designation-level property (whole fund is permanent). |
| Earned Revenue | Add via [fqs-fee-designation-plan.md](./fqs-fee-designation-plan.md) | Separate plan owns this add. |

Post-reshape: 4 active values (Without / Purpose / Permanent / Fee — after fee-designation plan lands; 3 before).

**New field: `FQS_Restriction_Release_Date__c` (Date), on both `GiftCommitment` AND `GiftTransaction`.**

- **Type:** Date. Deliberately not "fiscal year" and not "time restriction release" — general-purpose. The report definition owns the interpretation.
- **Nullable.** Blank = no time restriction on this gift.
- **On GC:** written by the launcher on pledge/scheduled/recurring leaves when the donor imposed a time boundary. Independent of `EffectiveStartDate` (which is when the schedule kicks off) and `ExpectedEndDate` (last installment). None of the 6 standard date fields on GC fits this concept — verified 2026-07-22 via describe. All are either platform-managed rollups, schedule-engine-owned, or reserved for planned-giving asset transfers.
- **On GT:** written by the launcher when the gift is time-locked (outright-cash-but-hold-until, or per-installment release inheriting from parent GC). Independently writable — the GT date may differ from the GC date when a multi-year pledge releases in tranches. Launcher defaults from GC when the GT is a payment against a commitment with a release date; user can override.
- **Not a formula.** Both fields are stored. Enables `sf data update` migrations and per-installment override.

**Reports that fall out for free (no new formula, no rollup):**

1. **Restricted funds ready to move** — `FQS_Restriction_Release_Date__c <= TODAY()` AND `FQS_Restriction_Type__c` starts with `With Donor Restriction`. Grouped by designation. This is the primary use case: Finance's monthly "what can we reclassify" report.
2. **Restricted funds coming due next 90 days** — `FQS_Restriction_Release_Date__c BETWEEN TODAY() AND TODAY()+90`. Cash-flow planning.
3. **Restricted funds with no release date** — `FQS_Restriction_Type__c IN (Purpose, Permanent) AND FQS_Restriction_Release_Date__c = null`. Data-quality catch; staff can backfill on gifts where a time boundary was documented in the pledge but not entered.
4. **Dual-restricted inventory** — `FQS_Restriction_Type__c = Purpose AND FQS_Restriction_Release_Date__c != null`. The subset where the donor imposed both purpose and time.

**Explicitly out of scope for this plan:**
- `FQS_Release_Eligible__c` formula, spend rollups, or ERP-integration hooks. Reports own release semantics. Whether the org actually executes the release in the accounting system is not FQS's concern.
- Auto-computing release date from installment date on a pledge schedule. If the pattern is "each yearly installment releases in its own FY," the launcher can prompt for release date per-GT — but no engine derives it.

**Migration concern.** If FundFirst already has any `GiftDesignation` with `FQS_Restriction_Type__c = 'With Donor Restriction - Time'` (foundation seed currently produces two: `FQS-GD-BUILDING-2026`, `FQS-GD-EXPANSION-2027`), removing the picklist value fails deploy until those records are reclassified. See Phase 2 §Migration and Phase 8 OQ9.

### D7. Setup-time designation catalog — **new Screen Flow, not Apex**

The current story is that a fresh org has zero `GiftDesignation` records. The launcher then trips over "The org wide default designation is not yet configured" from `processGiftCommitment`. Foundation seed script fixes this in test/dev orgs; **production admins need a comparable path that doesn't require running anonymous Apex.**

**Solution:** `FQS_Suggest_Designations` — a Screen Flow shipped inside the FQS setup surface. Curated catalog of 14 designations spanning the 4 restriction types. Admin ticks the ones they want; flow creates them via `<recordCreates>`, marks one as `IsDefault = TRUE` (admin-picked; defaults to General Operating). Wired into `FQS_Setup_Orchestrator` as an offered step.

**This is the ONLY way designations get created in FQS.** Production installs use it. Dev/test orgs use it. `FQSSeedGenerator.cls` and `fqs-seed-foundation.apex` no longer create designations — they read whatever designations exist (regardless of how they got there) via the existing wildcard query on `External_Id__c LIKE 'FQS-GD-%'` and other name-based lookups. Test-org workflow becomes: teardown → run `FQS_Suggest_Designations` → run seed scripts. Same pattern will eventually apply to Campaigns (already prototyped in `FQS_Campaign_Hierarchy_Setup` — see Phase 8 OQ12).

---

## Phase 2 — Metadata inventory

### GiftDesignation

| API name | Action | Notes |
|---|---|---|
| `FQS_Restriction_Type__c` | **Modify picklist** — remove `With Donor Restriction - Time` value; update description and inlineHelpText to note that time restrictions live on the gift, not the designation. | Deploy fails if any GD in the target org still has this value. See Phase 2 §Migration below. |

**Validation rules:** none.

### GiftDefaultDesignation

No changes. `FQS_Parent_Type__c` formula stays as-is (GDD parents to Campaign/GC/Opp only, verified 2026-07-22).

**Validation rules:** none.

### GiftTransactionDesignation

No changes.

**Validation rules:** none.

### GiftCommitment (new field)

| API name | Action | Type | Description | Permset |
|---|---|---|---|---|
| `FQS_Restriction_Release_Date__c` | **Add** | Date | *"Date on or after which a time-restricted gift becomes eligible to be moved out of restricted funds. Blank means no time restriction. Interpretation is report-defined — no automatic release logic. Used with `FQS_Restriction_Type__c` on the gift's designation to identify dual-restricted (purpose + time) gifts."* | `FQS_Custom_Fields` (edit) |

### GiftTransaction (new field)

| API name | Action | Type | Description | Permset |
|---|---|---|---|---|
| `FQS_Restriction_Release_Date__c` | **Add** | Date | Same description as on GC, with an added note: *"On a payment against a commitment, this field defaults from the parent commitment but is independently writable — installments of a multi-year pledge may each carry their own release date."* | `FQS_Custom_Fields` (edit) |

**Not formulas.** Both are stored fields — enables backfill via `sf data update` and per-installment override. Field is nullable; blank = no time restriction.

### Permset (`FQS_Custom_Fields`)

Add 2 field-permission entries (both editable):

```xml
<fieldPermissions>
    <editable>true</editable>
    <field>GiftCommitment.FQS_Restriction_Release_Date__c</field>
    <readable>true</readable>
</fieldPermissions>
<fieldPermissions>
    <editable>true</editable>
    <field>GiftTransaction.FQS_Restriction_Release_Date__c</field>
    <readable>true</readable>
</fieldPermissions>
```

### Custom permission

None.

### Migration (pre-deploy, one-shot)

**No migration required.** FQS is not deployed to any production customer org yet, and FundFirst dev is teardown-safe. The two seeded Time-restricted GDs (`FQS-GD-BUILDING-2026`, `FQS-GD-EXPANSION-2027`) get their `Restriction` value reclassified to Purpose directly in `fqs-seed-foundation.apex` (Phase 5). Existing test-org state is refreshed via the standard `fqs-seed-teardown.apex` → `fqs-seed-foundation.apex` sequence during Phase 6.9 — no separate migration script.

If a partner org later shows up already using FQS at production scale before this reshape lands, revisit OQ9. Until then, the story is: refresh the dev org, deploy the picklist change, move on.

### Total metadata delta

- **Add:** 2 fields (GC + GT release date), 2 permset entries, 0 VRs, 0 list views, 0 record types.
- **Modify:** 1 picklist (`GD.FQS_Restriction_Type__c` — remove Time value + update descriptions).
- **Delete:** 0.

The plan's weight is in **flows** (Phase 3), the **picklist reshape + release date field** (Phase 2), and **flexipage tweaks** (Phase 2b).

### Phase 2b — Flexipage additions (existing files, minor edits)

**GiftCommitment record page** ([`FQS_GiftCommitment_Record_Page.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_GiftCommitment_Record_Page.flexipage-meta.xml)): surface `FQS_Restriction_Release_Date__c` in the Details region alongside the existing pledge/schedule fields. Field is nullable — blank means "no time restriction," which is the majority case.

**GiftTransaction record page** ([`FQS_GiftTransaction_Record_Page.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_GiftTransaction_Record_Page.flexipage-meta.xml)): surface `FQS_Restriction_Release_Date__c` in the Details region.

Plus the Related-List audits (unchanged):


**Campaign record page** ([`FQS_Campaign_Record_Page.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_Campaign_Record_Page.flexipage-meta.xml)): add a **Related List** component for `GiftDefaultDesignations` if not already present. Admins manage per-campaign defaults via the standard Related List (New / Edit / Delete inline), no new flow needed for the Campaign surface.

**GiftCommitment record page** ([`FQS_GiftCommitment_Record_Page.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_GiftCommitment_Record_Page.flexipage-meta.xml)): same — add Related List for `GiftDefaultDesignations` if not present. Downstream, `FQS_Gift_Entry_Single_Launcher_GiftCommitment` already has a placeholder for `frops_flo__ManageGiftDesignations` (managed-package flow). Related List covers the interim.

**Opportunity record page** ([`FQS_Opportunity_Record_Page.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_Opportunity_Record_Page.flexipage-meta.xml)): same audit — Related List for `GiftDefaultDesignations`.

Downstream implementer: `grep -c "GiftDefaultDesignations" <flexipage>` on each; if 0, add the Related List component. Otherwise no-op.

---

## Phase 3 — Flow inventory

### 3.1 New: `FQS_Suggest_Designations` (Screen Flow)

**Trigger:** Screen flow, invoked as a subflow from `FQS_Setup_Orchestrator` (see wiring below), also runnable standalone as a Setup step.
**Purpose:** Seed the target org's `GiftDesignation` catalog at install time without Apex. Admin ticks the ones they want; flow creates them via `<recordCreates>`.
**Reuse:** idempotent — flow first queries existing GDs by Name to skip duplicates.

**Screens:**

1. **`Screen_Intro`** — plain-text explainer. "Fundraising Quick Start ships a curated set of Gift Designation records so gift entry can filter by donor restriction and default the org-wide fallback. Pick the ones that match your org's mission."
2. **`Screen_Pick_Designations`** — 14 checkboxes, one per suggested designation. Default: all checked. Grouped visually by restriction type. Each checkbox has helper subtext (in Flow's `<helpText>` on the display-text or checkbox field) so the admin sees the reasoning inline before ticking. Text below is the exact copy — do not paraphrase:

   - **Without Donor Restriction:**
     - [x] **General Operating Fund** — *The unrestricted org default. Every FQS install ships with this as the org-wide default (IsDefault = TRUE) so the platform's activate-schedule action has a fallback designation.*
     - [x] **Board Designated Fund** — *Internal designation, not a donor restriction. The board has earmarked these funds internally, but can undesignate at will — the donor imposed no restriction.*
     - [x] **Cash Reserve** — *A second internal-designation example, distinct from Board Designated Fund. A reserve is money held back for future need (spendable if the board votes to release). Teaches that "Without Donor Restriction" doesn't mean "unspoken for."*
   - **With Donor Restriction — Purpose:**
     - [x] **General Program** — *Catch-all for gifts a donor restricted to "programs" broadly without naming a specific program.*
     - [x] **Program A** — *Generic placeholder — rename to one of your actual programs after install.*
     - [x] **Program B** — *Generic placeholder — rename to one of your actual programs after install.*
     - [x] **Program Expansion Fund** — *Distinct purpose from ongoing programs: growth or new-initiative capacity. Donors give here specifically to launch something new.*
     - [x] **Equipment and Supply Fund** — *Purpose can be tangible non-capital spending — below-capitalization-threshold equipment, consumable supplies. Distinct from Capital Campaign Fund (which is above the capitalization threshold).*
     - [x] **Staff Salary Fund** — *Purpose can be donor-restricted personnel costs. Teaches that "programs" and "salaries" are separable purposes — a donor may fund a specific role without funding the surrounding program.*
     - [x] **Capital Campaign Fund** — *Capital-project purpose (building, renovation, major equipment above the capitalization threshold). Capital gifts release when the asset is placed in service, not on a schedule.*
   - **Earned Revenue:**
     - [x] **Events** — *Exchange-transaction revenue: gala ticket sales, event registration, workshop admission. Distinct from a donation given AT an event — this is what the ticket itself was worth.*
     - [x] **Merchandise** — *Sale of goods: t-shirts, books, branded items. Exchange transaction, not a contribution — the buyer received something of equivalent value.*
     - [x] **Program Services** — *Program-related fee revenue: participation fees, consulting retainers, service delivery charges. Distinct from a program-restricted donation (which lives in Program A / B / General Program).*
   - **With Donor Restriction — Permanent:**
     - [x] **Endowment** — *Endowment principal is held indefinitely; only earnings are spendable. One entry is enough — add named endowments (e.g., "Smith Family Scholarship Endowment") as your program grows.*
3. **`Screen_Pick_Org_Default`** — radio group, single-select. Options: only the designations the admin ticked in Screen_Pick_Designations that have `Without Donor Restriction` (typically General Operating and Community Programs). Sets which GD gets `IsDefault = TRUE`. Required. Default: General Operating (if ticked; else first available).
4. **`Screen_Confirm`** — summary of what will be created (list of names, restriction type, which is IsDefault), one "I understand these will be created in the current org" checkbox, Next button.
5. **`Get_Existing_By_Name`** — SOQL: `SELECT Id, Name FROM GiftDesignation WHERE Name IN :chosenNames`.
6. **`Loop_Skip_Existing`** — for each chosen name that already exists, mark skipped; add to `var_SkippedNames` collection.
7. **`Assign_Build_Designations`** — build `rsv_NewDesignations` collection: one `GiftDesignation` record per chosen-and-not-existing name, with:
   - `Name = <chosen name>`
   - `Description = <curated description per catalog table below>`
   - `FQS_Restriction_Type__c = <curated per catalog>`
   - `IsActive = TRUE`
   - `IsDefault = TRUE` if this is the admin-picked org default, else `FALSE`.
   - **No `External_Id__c`** — that field is reserved for FQS seed-script idempotency (`FQS-GD-*`). Setup-flow designations are user-owned records; they don't get an External_Id.
8. **`Create_Designations`** — record create (collection) → inserts `rsv_NewDesignations`.
9. **`Screen_Success`** — summary. Shows count created, count skipped, and a note: "You can retire any of these at any time — set IsActive = FALSE on the record page. Retired designations remain queryable and remain valid for back-dated gifts."
10. **`Err_Create`** — single fault-path screen.

**Guard conditions:**
- Cannot proceed past `Screen_Pick_Org_Default` unless at least one Unrestricted designation is ticked (`Screen_Pick_Designations` warns if the admin unticks all Unrestricted → routes them back).
- If org already has `IsDefault = TRUE` on some existing GD (queried in `Get_Existing_By_Name`), the flow warns and lets the admin choose: keep existing default, or transfer to the new pick. If transfer: update the old default's `IsDefault = FALSE` before creating the new one (single-record `<recordUpdates>`).

**Curated catalog (locked 2026-07-22; 14 entries — 3 Without / 7 Purpose / 3 Fee / 1 Permanent).** Each entry earns its slot by teaching a distinct classification pattern; the two generic `Program A` / `Program B` entries are placeholders the admin renames to their actual programs.

**Sequencing note:** the 3 Fee-restricted entries require the `Earned Revenue` picklist value from [fqs-fee-designation-plan.md](./fqs-fee-designation-plan.md) to exist first. That plan ships **before** this one — see updated OQ3.

| # | Name | Restriction | IsDefault candidate? | What this entry teaches |
|---|---|---|---|---|
| 1 | General Operating Fund | Without Donor Restriction | ✅ (default) | The unrestricted org default. |
| 2 | Board Designated Fund | Without Donor Restriction | — | Internal designation ≠ donor restriction. The board has earmarked these funds internally, but can undesignate at will — the donor imposed no restriction. |
| 3 | Cash Reserve | Without Donor Restriction | — | Second internal-designation example — a reserve is spendable in an emergency, distinct from Board Designated Fund's project-earmarked bucket. Teaches that "Without Donor Restriction" doesn't mean "unspoken for." |
| 4 | General Program | Purpose | — | Catch-all for gifts donor-restricted to "programs" broadly (no specific program named). |
| 5 | Program A | Purpose | — | Generic placeholder — admin renames to their actual program. |
| 6 | Program B | Purpose | — | Generic placeholder — admin renames to their actual program. |
| 7 | Program Expansion Fund | Purpose | — | Distinct purpose from ongoing programs — growth / new-initiative capacity. |
| 8 | Equipment and Supply Fund | Purpose | — | Purpose can be tangible non-capital spending (below-capitalization-threshold equipment, consumable supplies), not just program delivery. |
| 9 | Staff Salary Fund | Purpose | — | Purpose can be donor-restricted personnel costs — teaches that "programs" and "salaries" are separable purposes. |
| 10 | Capital Campaign Fund | Purpose | — | Capital-project purpose (building, renovation, major equipment above the capitalization threshold). Capital gifts release when the asset is placed in service, not on a schedule. |
| 11 | Events | Earned Revenue | — | Exchange-transaction revenue — gala ticket sales, event registration, workshop admission. Distinct from a donation *to* an event. |
| 12 | Merchandise | Earned Revenue | — | Sale of goods — t-shirts, books, branded items. Exchange transaction, not a contribution. |
| 13 | Program Services | Earned Revenue | — | Program-related fee revenue — participation fees, consulting retainers, service delivery charges. Distinct from a program-restricted donation (which lives in Program A / B / General Program). |
| 14 | Endowment | Permanent | — | Single Permanent-restriction example. Endowment principal is held indefinitely; only earnings are spendable. |

**All Purpose entries' descriptions include one line each** about time-locking at the gift level: *"When a donor restricts a gift toward this designation to a specific timeframe (e.g., FY2027), record the boundary on the gift's Restriction Release Date — not on this designation."*

**Dropped from earlier drafts** (with rationale, since a downstream reviewer will wonder):
- **Community Programs** — semantically overlaps with General Program.
- **Education Initiative / Youth Services / Emergency Relief Fund** — too sector-specific for a generic accelerator; Program A/B/General Program cover the pattern.
- **Building Fund** — collapsed into Capital Campaign Fund (which teaches the placed-in-service release rule more clearly).
- **Scholarship Fund** — Program A/B absorb this for orgs that run scholarship programs; not worth the slot.
- **Endowment — Scholarships / Endowment — Operations / Named Legacy Endowment** — one Endowment entry is enough. Admins add named endowments via the standard New button as their org grows.
- **Grants Fund** — deliberately excluded. Grant-ness is a property of the gift (`GC.FQS_Gift_Commitment_Category__c = 'Grant Payout'`) and the donor (Account is a foundation), not the designation. A grant toward Program A is still Program A. Adding a Grants designation would conflate two orthogonal axes.

**Design principle applied throughout: donor-type breakouts do not belong on GD.** If a report needs "income by donor type × designation," that's a cross-cut in the report (`GROUP BY Account.Type, GD.Name`), not a doubled catalog like "Foundation Grants — Program A" vs. "Individual Gifts — Program A."

**Descriptions written to `GD.Description` at record-create time are the same helper subtext strings shown on `Screen_Pick_Designations` above.** The admin sees the reasoning inline during setup, then the record itself carries the reasoning forward for anyone opening the record later. Descriptions live inline in the flow's `<recordCreates>` element (or, better, in a Flow constant collection so both the screen helper text and the record description read from a single source of truth — recommended pattern to avoid drift).

For all Purpose entries, append this second line to the description:
> *"When a donor restricts a gift toward this designation to a specific timeframe (e.g., FY2027), record the boundary on the gift's Restriction Release Date — not on this designation."*

This teaches the D6 evergreen-GD principle at record level, so an admin editing the record later sees the rule without needing to consult the plan or setup screen.

### 3.2 Modify: `FQS_Setup_Orchestrator`

Add the `FQS_Suggest_Designations` subflow as an offered step. Existing shape (verified via grep): the orchestrator currently handles donor grouping CMDT + acknowledgement routing. Add:
- A new choice on the top-level "What do you want to configure today?" screen: "Seed the Gift Designation catalog" (or similar).
- On selection, calls `FQS_Suggest_Designations` as a subflow (no input params required beyond `recordId`, which is unused here since the flow doesn't operate on a specific record — pass null).
- Skip if the org already has ≥5 GDs (heuristic: catalog was previously seeded or manually populated). Show a "Designations already look configured — go add more manually if needed" note screen and let the admin proceed anyway if they want to add a few more.

### 3.3 Modify: `FQS_Gift_Entry_Single_Launcher_Account`

**Trigger:** Screen flow, invoked via quick action on Account.
**Purpose (delta):** add split UX, add conflict-detection screen, clone GTDs onto employer GT.
**Guard:** all new elements guarded by their existing wizard branches — no unconditional side effects.

**New elements to add (inside the wizard's `Screen_Details` region per [fqs-gift-entry-wizard-plan.md](./fqs-gift-entry-wizard-plan.md) §Screen ordering line 276):**

| Element | Type | Purpose |
|---|---|---|
| `Screen_Split_Table` | Screen | Datatable of `(GiftDesignation, Percent)` rows. Renders when `var_UseCustomSplit = TRUE`. Datatable's `outputTable` is `<RepeaterName>.AllItems` per [[flow-repeater-output-quirk]] — loop over `.AllItems` to build GTDs. |
| `Decide_Split_Or_Single` | Decision | Reads `var_UseCustomSplit`. TRUE → route to `Screen_Split_Table` → `Loop_Build_GTDs`. FALSE → existing single-row `Assign_Build_GTDesignation` (unchanged). |
| `Loop_Build_GTDs` | Loop over `Screen_Split_Table.<datatable>.AllItems` | Builds N `rsv_GTDesignations` (collection) with `Percent`, `Amount = ROUND(Percent × OriginalAmount / 100, 2)`. Last-row absorbs remainder — running-sum accumulator adjusts final row's Amount. |
| `Assign_Split_Parent_Check` | Assignment | Compute `var_SplitTotalPercent = SUM(rsv_GTDesignations.Percent)`; `var_SplitTotalAmount = SUM(rsv_GTDesignations.Amount)`. |
| `Decide_Split_Totals_Valid` | Decision | If `ABS(var_SplitTotalPercent - 100) > 0.01` OR `ABS(var_SplitTotalAmount - OriginalAmount) > 0.01` → route to `Screen_Split_Warning`. Else continue. |
| `Screen_Split_Warning` | Screen | Warn user, let them go back to `Screen_Split_Table` or proceed anyway. `<allowFinish>true</allowFinish>` per [[flow-allowfinish-blocks-next]]. |
| `Create_Multiple_GTDesignations` | Record create (collection) | Bulk insert `rsv_GTDesignations` (replaces single-record `Create_GTDesignation` on the split branch). |
| `Clone_GTDs_For_Employer_Match` | Loop + Assignment + Create | On the corporate-match branch (per wizard plan §Matching-gift), duplicate the collection with `GiftTransactionId = <employer GT Id>`, scale Amounts if match amount ≠ donor amount, insert. |
| `Screen_Designation_Conflict` | Screen | Renders only if `Get_Commitment_Default_Designation` AND `Get_Campaign_Default_Designations` both return rows AND resolve to different GDs (Pledge Payment leaf only). Defaults to GC. |
| `Screen_Restriction_Release_Date` | Screen | Renders when the chosen designation's restriction is Purpose or Permanent AND the leaf is Pledged Gift / Scheduled Pledge/Grant / Recurring / Outright (any leaf that creates a GC or a GT with a restricted GD). Prompts for `FQS_Restriction_Release_Date__c` (optional Date input, blank = no time restriction). Help text: *"If the donor restricted this gift to a specific timeframe, enter the date on or after which the gift may be moved out of restricted net assets. Leave blank for purpose-only or permanently restricted gifts."* |
| `Assign_Release_Date_On_GC` | Assignment | On commitment leaves, writes `rsv_GC.FQS_Restriction_Release_Date__c = var_ReleaseDate` (may be null). |
| `Assign_Release_Date_On_GT` | Assignment | On all monetary leaves and pledge-payment leaves, writes `rsv_GT.FQS_Restriction_Release_Date__c = var_ReleaseDate`. On Pledge Payment against a GC with a non-null release date, defaults `var_ReleaseDate = parentGC.FQS_Restriction_Release_Date__c` before the screen — user can override on-screen. |

**No new GD/GDD/GTD custom fields** — the reshape adds fields only to GC and GT.

### 3.4 Modify: `FQS_Gift_Entry_Single_Launcher_Opportunity`

Apply the same three deltas as the Account launcher (split UX, conflict screen, employer GTD clone). Mirrored by [fqs-account-launcher-flow-parity-plan.md](./fqs-account-launcher-flow-parity-plan.md). Same element names.

### 3.5 No changes to `FQS_Gift_Entry_Single_Launcher_GiftCommitment`

Placeholder flow for `frops_flo__ManageGiftDesignations`. Ownership: managed package. Out of scope.

### 3.6 No new record-triggered flows

No auto-normalization of GTD/GDD percents on save. All correction happens in-band with user intent in the launcher / setup flows.

---

## Phase 4 — Permset inventory

**No changes.** No new fields → no new field-permission entries. `FQS_Custom_Fields` is untouched.

**No new permsets.** No opt-out toggle (no custom permission). If split-designation UX turns out to be too invasive for some orgs post-launch, revisit and add `FQS_Split_Designations_Opt_Out` — separate ship.

---

## Phase 5 — Seed script updates (testing/dev only)

**Scope decision (locked 2026-07-22, Justin):** Apex no longer creates designation records anywhere. `FQS_Suggest_Designations` is the only path. Test/dev orgs run the same flow to seed their designation catalog. This is the first move in a broader shift — eventually Campaigns follow the same pattern (see OQ12). See [[seed-scripts-purpose]] for the underlying rule (test/dev seeding is fine; Apex creating records is not the desired pattern going forward).

### `scripts/apex/seed/fqs-seed-foundation.apex` — remove designation creation

**Delete lines 184–210** (the `designationSpec` list, the `for` loop building the `List<GiftDesignation>`, and the `Database.upsert`). Also delete line 210's `System.debug` for designations.

The foundation script's downstream queries and inserts keep working:
- Line 423 (`SELECT COUNT() FROM GiftDesignation WHERE External_Id__c LIKE 'FQS-GD-%'`) — informational count; will report whatever exists.
- `FQSSeedGenerator.cls` line 216 (`SELECT Id, FQS_Restriction_Type__c FROM GiftDesignation WHERE External_Id__c LIKE 'FQS-GD-%'`) — reads existing designations. **Change the WHERE clause** to broaden it, since designations created by the suggestion flow do NOT carry an `External_Id__c`:
  ```apex
  List<GiftDesignation> designations = [SELECT Id, FQS_Restriction_Type__c FROM GiftDesignation WHERE IsActive = TRUE];
  ```
- The `System.assert` on line 221 stays — it fails loudly if the running user forgot to run `FQS_Suggest_Designations` first.

**New order-of-operations for a fresh test org:**
1. `fqs-seed-teardown.apex` — deletes all `FQS-%` records (unchanged behavior).
2. Run `FQS_Suggest_Designations` flow in the UI (or via Setup Orchestrator). Ticks all 14 boxes → creates the catalog.
3. `fqs-seed-foundation.apex` — creates Campaigns, OSCs, corporate employers, etc. **No longer touches designations.**
4. `fqs-seed-small.apex` (or medium/large) — creates donors, GCs, GTs, splits.

The README (Phase 5b) documents this. Skipping step 2 leaves the test org designation-less; step 4 hits the assert in `FQSSeedGenerator` and stops with a clear error.

### `FQSSeedGenerator.cls` — no new designation-creation code; keep the read-side changes

**No Apex adds designations.** The class continues to READ designations (line 216 above) and continues to CREATE GDDs and GTDs referencing them (lines 413–428 and 862–872). Both those blocks operate on whatever designations exist, keyed by restriction type and IsActive — they don't hard-code names or external IDs, so they don't care that the catalog is now 14 entries with no external IDs.

**Behavior changes (still in-scope for this plan, still test/dev only):**

- **Multi-designation split coverage.** Extend the GTD-generation block (line 862–872) to emit multi-row splits for ~10% of GTs so the wizard's split path has test data:
  - 90% single-designation (existing behavior)
  - 7% two-designation split (`60/40` or `50/50`)
  - 3% three-designation split (`50/25/25`)

  PRNG salts 400 (split shape) and 401 (which GDs).

- **Release-date coverage.** On seeded GCs pointing at Purpose-restricted GDs (~30% of commitments), populate `FQS_Restriction_Release_Date__c` for ~40% of those GCs:
  - 15% release date in the past ("ready to move" report path)
  - 15% release date 0–90 days out ("coming due")
  - 10% release date beyond 90 days ("locked, future")
  - Remainder null.

  Fan the same distribution onto child GTs via inheritance in the seed's GT loop — default GT release date from parent GC when the GC has one set. PRNG salts 500 (bucket pick) and 501 (offset days).

- **Multi-year Grant release-date coverage (added 2026-07-23).** Independent of the Purpose-restricted GC coverage above. When Phase D6 ships, extend the grant-installment ladder in `FQSSeedGenerator.cls` (introduced 2026-07-23 by the launcher-aligned GT refactor) to write `FQS_Restriction_Release_Date__c` on:
  - The parent multi-year Grant GC → set to `ExpectedEndDate` (grant funds released by end of the funding period).
  - Each installment GT on the grant → walked yearly from `EffectiveStartDate` so each tranche has its own release date (matches how time-restricted grant revenue is recognized in tranches).
  - One-time grants (~60% of grant GCs per the 2026-07-23 seed refactor) do NOT get a release date — they're recognized immediately on `TransactionDate`.

  PRNG salts 502 (nothing to roll for multi-year grants — every installment gets one) and 503 (reserved). Memory cross-ref: [[seed-release-date-followup]] in `/Users/justin.gilmore/.claude/projects/-Users-justin-gilmore-GitHubRepos-PSA-Fundraising-Quick-Start-DEV/memory/`.

- **Fee-restricted GDs — new routing.** When a GT's transaction category is `Fee/Payment`, its GTD should route to a Fee-restricted GD. Add a filter in the GTD block: `restrictedDesignationIds` list expands to include Fee GDs when the parent GT is fee-category. Details in the fee-designation plan; this plan calls out that Fee-restricted rows now exist in the catalog and the seed's routing logic needs to know about them.

- **Org-wide default (`IsDefault = TRUE`).** No longer set by `fqs-seed-foundation.apex` (since it no longer creates the GD). The admin picks the default during `FQS_Suggest_Designations` — the setup flow itself sets `IsDefault = TRUE` on the chosen GD via `<recordUpdates>`. If the admin skipped that step, `FQSSeedGenerator` should assert one exists before proceeding (add a defensive check after line 221):
  ```apex
  System.assert(![SELECT COUNT() FROM GiftDesignation WHERE IsDefault = TRUE] > 0,
      'No default GiftDesignation set — re-run FQS_Suggest_Designations and pick an org default');
  ```

**Do NOT add** any GDD-parented-to-Account rows. Not supported by the platform.

### `scripts/apex/seed/README.md` — document new order-of-operations

Rewrite the "Prerequisites (one-time org setup)" section (currently at line 22–41) to make step 2 explicit:

> **One-time org setup:**
> 1. Deploy External_Id__c fields, `FQS_Donor_Grouping__mdt`, and `FQSSeedGenerator.cls` (existing text).
> 2. **Run `FQS_Suggest_Designations` from Setup.** Tick all 14 designations and pick General Operating Fund as your org default. This creates the designation catalog that the seed scripts assume exists.
> 3. (test/dev only) Run `fqs-seed-teardown.apex` to clear prior seed state.
> 4. Run `fqs-seed-foundation.apex` — creates Campaigns, OSCs, corporate employers. No longer creates designations.
> 5. Run `fqs-seed-small.apex` (or medium/large) to create donors and gifts.

Also append under "Conditional GiftCommitments + GiftDefaultDesignation" (line 211–214):
- **Multi-designation GT splits** — 10% of seeded GTs have >1 GTD child (7% two-way, 3% three-way). Exercises the wizard's split validation path.
- **Restriction release dates** — ~40% of Purpose-restricted seeded GCs carry `FQS_Restriction_Release_Date__c` values distributed across past / near-future / far-future buckets to exercise the release-eligibility reports.
- **Designation catalog** — no longer created by Apex. Run `FQS_Suggest_Designations` before running any seed script. See Prerequisites above.

Also fix the count line at line 12 (currently *"10 Designations"* — becomes *"created via `FQS_Suggest_Designations` setup flow before seeding"*).

---

## Phase 6 — Deploy order

**Constraints:** per [[fqs-crt-deploy-pattern]] — small, verifiable deploys; do not batch fields+picklist-value-removal+flow in one command. The picklist reshape has a hard ordering requirement: **migrate any existing Time-restricted GDs before dropping the value**, or the deploy fails.

### Order

```bash
# Phase 6.0 — PRE-DEPLOY teardown (FundFirst dev only — no production data exists yet).
# Foundation seed no longer creates designations, so teardown+reseed cycle needs the suggestion flow inserted.
sf apex run --file scripts/apex/seed/fqs-seed-teardown.apex --target-org FundFirst
# Verify clean (no Time-restricted designations linger):
sf data query --query "SELECT Id FROM GiftDesignation WHERE FQS_Restriction_Type__c = 'With Donor Restriction - Time'" --target-org FundFirst
# Expect 0 rows. Designations get recreated via FQS_Suggest_Designations after the flow deploys in 6.5.

# Phase 6.1 — fee-designation plan MUST land first (adds `Earned Revenue` picklist value).
# Blocked on: fqs-fee-designation-plan.md deployment.
# If not yet deployed: pause this plan here until fee-designation ships. See OQ3.

# Phase 6.1 — new fields on GC and GT [SHIPPED 2026-07-25, deploy 0AfWB00000DbcYH0AZ]
sf project deploy start --metadata \
  "CustomField:GiftCommitment.FQS_Restriction_Release_Date__c,\
CustomField:GiftTransaction.FQS_Restriction_Release_Date__c" \
  --target-org FundFirst

# Phase 6.2 — permset (grants edit on new fields) [SHIPPED 2026-07-25, deploy 0AfWB00000Dbcek0AB]
sf project deploy start --metadata "PermissionSet:FQS_Custom_Fields" --target-org FundFirst

# Phase 6.3 — picklist reshape on GD (remove Time value + refresh description/help).
# The description update rewrites the field description to no longer imply time-restriction is a designation attribute:
#   "Categorizes designations for filtering and reporting. Restriction dimensions:
#    Without Donor Restriction (unrestricted, incl. internal board designations);
#    With Donor Restriction - Purpose (donor restricted to a specific use);
#    With Donor Restriction - Permanent (endowment principal, held indefinitely);
#    Earned Revenue (exchange-transaction revenue, not a contribution).
#    Time restrictions are NOT represented here — record time boundaries on the gift's FQS_Restriction_Release_Date field."
# Only run after 6.0 confirms zero hits on the retired Time value.
sf project deploy start --metadata "CustomField:GiftDesignation.FQS_Restriction_Type__c" --target-org FundFirst

# Phase 6.4 — new setup subflow
sf project deploy start --metadata "Flow:FQS_Suggest_Designations" --target-org FundFirst

# Phase 6.5 — wire it into the orchestrator
sf project deploy start --metadata "Flow:FQS_Setup_Orchestrator" --target-org FundFirst

# Phase 6.6 — flexipage tweaks (surface release date field on GC + GT; Related-List audits on Campaign/GC/Opp)
sf project deploy start --metadata \
  "FlexiPage:FQS_GiftCommitment_Record_Page,\
FlexiPage:FQS_GiftTransaction_Record_Page,\
FlexiPage:FQS_Campaign_Record_Page,\
FlexiPage:FQS_Opportunity_Record_Page" \
  --target-org FundFirst

# Phase 6.7 — launcher flow (Account) — split UX + conflict + match-clone + release-date prompt
sf project deploy start --metadata "Flow:FQS_Gift_Entry_Single_Launcher_Account" --target-org FundFirst

# Phase 6.8 — launcher flow (Opportunity) — parity mirror
sf project deploy start --metadata "Flow:FQS_Gift_Entry_Single_Launcher_Opportunity" --target-org FundFirst

# Phase 6.9 — dev/test only: seed generator update + refresh test data
sf project deploy start --metadata "ApexClass:FQSSeedGenerator" --target-org FundFirst
# In test/dev orgs only, run the new order-of-operations:
sf apex run --file scripts/apex/seed/fqs-seed-teardown.apex --target-org FundFirst
# Manually run FQS_Suggest_Designations from Setup UI → tick all 14 → pick General Operating Fund as default → Save.
# (No CLI command; the flow is UI-only. Alternative: pause here and require the human step.)
sf apex run --file scripts/apex/seed/fqs-seed-foundation.apex --target-org FundFirst  # no longer creates designations
sf apex run --file scripts/apex/seed/fqs-seed-small.apex --target-org FundFirst
```

**Order rationale:**
- 6.0 blocks — deploy fails if any GD still has the Time value.
- 6.1 lands new fields first — VRs/formulas would reference them if we had any (we don't).
- 6.2 permset — after new fields exist.
- 6.3 picklist reshape — safe once 6.0 confirmed clean.
- 6.4 / 6.5 setup flow + orchestrator wire-up.
- 6.6 flexipages surface the new field and the Related List.
- 6.7 / 6.8 launcher flows — biggest change, deploy after everything else is green.
- 6.9 seed generator — dev-only, gated by org tier.

**Verify after each step:**
```bash
sf data query --query "SELECT COUNT() FROM Flow WHERE DeveloperName = 'FQS_Suggest_Designations'" --target-org FundFirst
sf data query --query "SELECT Id, IsDefault FROM GiftDesignation WHERE IsDefault = TRUE" --target-org FundFirst
```

---

## Phase 7 — Smoke test protocol

### T1. Setup-flow happy path (production-shaped)
1. Fresh org (or one with 0 `GiftDesignation` records). Launch `FQS_Setup_Orchestrator`.
2. Pick "Seed the Gift Designation catalog" step.
3. Leave all 10 checked; pick "General Operating Fund" as org default.
4. Confirm → Success screen.
5. Query: `SELECT COUNT() FROM GiftDesignation` → expect 10.
6. Query: `SELECT Name FROM GiftDesignation WHERE IsDefault = TRUE` → expect exactly one: "General Operating Fund".
7. Re-run the flow immediately. Expect: all 10 skipped (existing), Success screen reports "0 created, 10 skipped."

### T2. Setup-flow — partial pick + swap default
1. Fresh org. Launch flow. Uncheck all Time and Permanent designations. Leave 5 checked. Pick General Operating as default.
2. Save → verify 5 records; verify only General Operating has `IsDefault = TRUE`.
3. Re-run flow. Check Endowment — Scholarships too. On `Screen_Pick_Org_Default`, radio auto-picks the current default (General Operating).
4. Save → verify 6 records (1 new); default still General Operating.

### T3. Setup-flow — existing IsDefault conflict
1. Org has an existing GD `Old General Fund` with `IsDefault = TRUE` (not one of the FQS catalog names).
2. Run flow, tick all 10, pick General Operating as new default.
3. Confirm screen shows warning: "Old General Fund is currently the org default. Transfer to General Operating Fund?"
4. Choose "Transfer." Save.
5. Query: `SELECT Name, IsDefault FROM GiftDesignation WHERE IsDefault = TRUE` → expect exactly one, General Operating Fund. Old default is now `IsDefault = FALSE`.

### T4. Launcher — GC-default precedence (Pledge Payment leaf)
1. Pick a GC with a seeded GDD child. Query first: `SELECT GC.Id FROM GiftCommitment GC WHERE GC.Id IN (SELECT ParentRecordId FROM GiftDefaultDesignation) LIMIT 1`.
2. Launch gift entry → Monetary → Pledge Payment against that GC.
3. On `Screen_Details`, verify "Designation" line reads *"<GD name> — from commitment default"* and `[Override]` present.
4. Do not override. Save. Query new GT's GTD — `GiftDesignationId` matches GDD's GD.

### T5. Launcher — Campaign-default precedence (Outright leaf)
Same shape as T4 but Outright leaf, Campaign with a default. Verify "Designation: <name> — from Campaign default."

### T6. Launcher — GC vs. Campaign conflict
1. Set GC-default to GD-A; set the GC's Campaign to have GD-B.
2. Launch Pledge Payment against that GC → verify `Screen_Designation_Conflict` renders, defaults to GD-A.
3. Save; GTD is GD-A.

### T7. Launcher — split UX (single writer path)
1. Launch gift entry → Monetary → Outright.
2. Enter `$1000`. Check "Enter custom split" toggle.
3. In datatable: row 1 = Youth Services 60%; row 2 = Education Initiative 40%.
4. Save. Query GTDs → expect 2 rows: Youth @ $600 / 60%, Education @ $400 / 40%. Sums to $1000 exactly.

### T8. Launcher — split total mismatch (warn + proceed / correct)
1. Same but enter 60% + 30% (90% total).
2. Expect `Screen_Split_Warning`. Go back → fix to 60/40 → save → passes.
3. Retry 60/30; choose "Proceed anyway" → GTDs insert as-typed. Health check (T10) will surface.

### T9. Launcher — match-gift GTD clone
1. Launch → Outright + custom split (60/40) + Matched, pick employer.
2. Save. Query both GTs' GTDs → employer GT has same 60/40 GDs; Amounts scaled if employer amount ≠ donor amount.

### T10. Health check (drift audit — manual)

```apex
// Paste into anonymous Apex — audits split-total drift
for (AggregateResult ar : [
    SELECT GiftTransactionId gtId, SUM(Percent) pctSum, SUM(Amount) amtSum
    FROM GiftTransactionDesignation
    GROUP BY GiftTransactionId
    HAVING SUM(Percent) != 100
]) {
    System.debug('DRIFT ' + ar.get('gtId') + ' pct=' + ar.get('pctSum') + ' amt=' + ar.get('amtSum'));
}
```

**Not shipped as an Apex class.** Documented here for manual dev/QA use only.

### T11. Toggle-off / no-op paths
- Custom split unchecked → single-designation path produces 1 GTD @ 100%.
- No GC default and no Campaign default → picker or Unrestricted fallback (existing behavior).

### T12. Restriction release date — write path
1. Launch gift entry → Future Commitment → Simple Pledge/Grant. Pick a Purpose-restricted designation (e.g., Youth Services).
2. On `Screen_Restriction_Release_Date`, enter `2027-06-30`.
3. Save. Query the new GC: `SELECT FQS_Restriction_Release_Date__c FROM GiftCommitment WHERE Id = '<newGcId>'` → expect `2027-06-30`.
4. Retry with blank release date → verify GC saves with `FQS_Restriction_Release_Date__c = null`.

### T13. Restriction release date — inheritance to GT
1. From a GC with `FQS_Restriction_Release_Date__c = 2027-06-30`, launch Pledge Payment.
2. On `Screen_Restriction_Release_Date`, verify the field is pre-populated with `2027-06-30`.
3. Override to `2028-06-30`. Save.
4. Query the new GT → expect `2028-06-30`. GC unchanged.

### T14. Restriction release date — reports fire correctly
1. After seed with new release-date coverage, build a report on `GiftCommitment` grouped by `FQS_Restriction_Type__c`, filtered `FQS_Restriction_Release_Date__c <= TODAY()`.
2. Verify only Purpose GCs with past release dates appear (Permanent should not — endowment principal doesn't release, though the report doesn't stop the user from adding a release date to a Permanent GC. That's a data-entry warning, not a hard block).
3. Build the "coming due 0–90 days" variant → filter `FQS_Restriction_Release_Date__c BETWEEN TODAY() AND TODAY()+90`. Verify seed distribution matches (~15% of Purpose GCs).
4. Build the "no release date set" data-quality variant → filter `FQS_Restriction_Type__c = 'With Donor Restriction - Purpose' AND FQS_Restriction_Release_Date__c = null`. Verify the ~60% of Purpose GCs where release date is null.

### T15. Picklist reshape — Time value gone
1. `sf sobject describe --sobject GiftDesignation --target-org FundFirst | grep -A5 FQS_Restriction_Type` — expect 3 picklist values (or 4 post-fee-designation-plan): Without / Purpose / Permanent (/ Fee). No Time value.
2. Try to insert a GD with `FQS_Restriction_Type__c = 'With Donor Restriction - Time'` via anonymous Apex → expect DmlException "bad value for restricted picklist field."
3. Old records that WERE Time before the migration: verify they now read Purpose (spot-check the two reclassified foundation GDs).

### T16. Seed no longer creates designations — sequencing sanity check
1. Fresh org. Run `fqs-seed-teardown.apex`.
2. **Skip** `FQS_Suggest_Designations`. Immediately run `fqs-seed-foundation.apex`.
3. Then run `fqs-seed-small.apex`. Expect the `System.assert` on line 221 of `FQSSeedGenerator.cls` to fire with a clear error: *"No FQS designations — run FQS_Suggest_Designations first"*.
4. Recover: run `FQS_Suggest_Designations` (tick all 14, pick General Operating), then re-run `fqs-seed-small.apex`. Success.
5. Verify old external IDs are gone: `sf data query --query "SELECT External_Id__c FROM GiftDesignation WHERE External_Id__c LIKE 'FQS-GD-%'"` → expect 0 rows (setup flow creates records without `External_Id__c`).
6. Verify the 14 catalog entries exist: `sf data query --query "SELECT COUNT() FROM GiftDesignation"` → expect at least 14.

### T17. Flexipage smoke
- Campaign / GC / Opportunity record pages show a GiftDefaultDesignations Related List. New / Edit / Delete inline works. AllocatedPercentage validates via platform field type (percent — accepts 0–100 by default type semantics).

---

## Phase 8 — Risks / open questions

**OQ1 — Curated catalog names.** The 10 proposed names are cribbed from seed foundation. Are these the names Justin wants surfaced to admins in production? Alternatives per bucket possible ("Annual Fund" vs "General Operating Fund"). Recommendation: **ship these names**, easy to rename post-install. Confirm at review.

**OQ2 — Hoist launcher designation logic into a subflow?** Account and Opportunity launchers will each carry ~7 duplicated split-flow elements. Hoisting to `FQS_Gift_Entry_Designation_Subflow` reduces drift risk at the cost of one more deployable + slightly more complex data-passing. Recommendation: **defer** — clone-and-deploy first, subflow later as cleanup.

**OQ3 — Fee-designation coordination — ship order? (resolved 2026-07-22 — fee-designation ships FIRST).** The catalog now includes 3 `Earned Revenue`-restricted entries (Events, Merchandise, Program Services) that require the picklist value to exist before this plan ships. Sequencing:
1. [fqs-fee-designation-plan.md](./fqs-fee-designation-plan.md) lands first — adds the picklist value, updates field description, wires the Fee for Service leaf's filter.
2. This plan lands second — the setup flow's catalog references the value, no interim misclassification.

**Original OQ3 analysis (for reference only):**
- **A:** This plan first, fee-designation plan second. Simpler; Fee for Service leaf's picker shows unrestricted GDs until fee-designation lands.
- **B:** Fee-designation plan first. Fee for Service leaf works immediately; this plan's setup catalog could include a "Earned Revenue" bucket.
Recommendation: **A** — this plan is bigger and blocking gift-entry correctness; Fee for Service leaf's picker is polish.

**OQ4 — Donor-level (Account) default designations — supported later, how?** GDD's `ParentRecordId` doesn't allow Account. If Justin wants "this donor always gives to Scholarships," the options are:
- **(a)** New FQS custom object `FQS_Donor_Designation_Default__c` — Master-detail to Account, lookup to GD, AllocatedPercentage percent. New flow to manage on the Account record page. Launcher checks it in the precedence chain between GC-default and Campaign-default. ~1 field + 1 object + 1 flow + permset + list view.
- **(b)** Use `GiftDefaultDesignation` on the donor's most-recent-active GiftCommitment as a proxy. Cheap; couples donor-default to commitment lifecycle (dies when commitment ends).
- **(c)** Do nothing — silence is fine; users tick their own designation each time.
Recommendation: **(c) for now**; revisit in a separate plan if partner orgs ask.

**OQ5 — Sum-of-percent enforcement on GDD parents (Campaign / GC / Opp).** Currently no enforcement. An admin could add three GDD rows at 50% each summing to 150%. Launcher only reads the first row today, so the excess is silent-ignored — not a bug, just wasted rows. Recommendation: leave alone; the Related List is admin-facing and the pattern is self-correcting.

**OQ6 — Rounding-remainder policy on split amounts.** Design: last-row absorbs. Alternative: cent-by-cent distribution starting row 1. Recommendation: last-row-absorbs — simplest, deterministic. Max $0.02 delta.

**OQ7 — Setup flow idempotency on partial re-runs.** T1 covers "all 10 already there → 0 created." What if 3 exist and admin ticks 5? Flow should create the 2 new ones and skip the 3 existing. Confirmed handled by `Get_Existing_By_Name` → `Loop_Skip_Existing` logic in §3.1. Explicitly noted here as a design constraint for the downstream implementer.

**OQ8 — Setup flow name-collision on custom-named GDs.** If admin's org has a GD named "General Operating Fund" that isn't in the FQS catalog (e.g., created by prior integration), the flow's dedupe-by-name treats it as "already exists" and skips. That's the right behavior for name-matching, but the existing GD may have `FQS_Restriction_Type__c = blank` or a different restriction. Flow doesn't repair — it skips. Skipped list on `Screen_Success` surfaces the collision so the admin can hand-edit if needed.

**OQ9 — Picklist-value-removal blast radius (resolved 2026-07-22).** No migration needed. FQS has zero production deployments; FundFirst dev refreshes via standard teardown/reseed. The picklist reshape ships clean, no migration Apex, no release-note asterisk. If FQS ever hits a real customer that has been storing Time-restricted GDs at scale before this reshape lands, that's a future problem for a future plan.

**OQ10 — Should `FQS_Restriction_Release_Date__c` also live on GiftTransactionDesignation?** Argument for: a single gift with a 60/40 split across two designations could theoretically have per-row release dates (60% releases FY27, 40% releases FY28). Argument against: this is exotic — most dual-restriction gifts are single-designation, and splitting release dates across rows would break the "one date per gift" mental model that Finance wants. Recommendation: **defer** — GT-level is sufficient for the reporting cut. Revisit only if a partner org actually needs per-row release dates.

**OQ11 — Should Permanent restrictions accept a release date? (resolved 2026-07-22 — soft warning).** Field is not blocked at Permanent level. Launcher-side soft warning on `Screen_Restriction_Release_Date` — if the selected GD is Permanent AND user enters a non-null date, show a warning bar *"Permanent restrictions do not release. Leave blank unless the donor specified otherwise (e.g., term endowment or quasi-endowment)."* User can proceed. No hard block, no VR.

**OQ12 — Long-term goal: replace all Apex-driven org data with setup flows.** This plan takes the first step (designations move to `FQS_Suggest_Designations`; seed script stops creating them). The pattern is the destination: every "shipped default record set" — Campaigns (currently created by `FQS_Campaign_Hierarchy_Setup` invocable Apex `FQS_CampaignHierarchyBuilder`), OSCs, Donor Grouping CMDT, corporate employers — should become admin-facing setup flows. Seed scripts read whatever exists in the org; they don't create it. Justin, 2026-07-22: intent locked, staging deferred. Follow-up plans:
- `.planning/fqs-campaign-suggestion-flow-plan.md` — replace `FQS_CampaignHierarchyBuilder` invocable Apex with an admin-facing flow. Seed script stops creating Campaigns.
- Similar plan for OSCs and corporate employers as they surface as friction.
Not blocking this plan's ship. Track as ongoing architectural direction.

---

## Correction summary (why this replaces the two 2026-07-22 drafts)

**From draft 1 → draft 2 corrections:**
- **Removed** the assumption of Account-parent GDD. `GiftDefaultDesignation.ParentRecordId.referenceTo = [Campaign, GiftCommitment, Opportunity]` — Account is not a supported parent. Any donor-level default requires a new custom object (deferred, Phase 8 OQ4).
- **Removed** three proposed validation rules. Justin: designations plan doesn't build any VRs. Row-level correctness is picklist/percent field-type constrained; parent-sum is enforced in-flow with a warn-and-proceed path.
- **Removed** the Apex-driven approach to seeding designations in a production org. Setup happens through `FQS_Suggest_Designations`, a Screen Flow with `<recordCreates>`, wired into `FQS_Setup_Orchestrator`. `FQSSeedGenerator.cls` and the anonymous Apex seed scripts stay strictly dev/test — per [[seed-scripts-purpose]].
- **Added** `FQS_Suggest_Designations` as the production-facing designation-catalog installer.

**From draft 2 → this draft corrections (D6 schema reshape):**
- **Removed** `With Donor Restriction - Time` from `GiftDesignation.FQS_Restriction_Type__c`. Time isn't intrinsic to a designation; it lives on the gift. Dual-restricted gifts need both dimensions tracked, and the designation only owns the purpose dimension.
- **Added** `FQS_Restriction_Release_Date__c` (Date) on both `GiftCommitment` and `GiftTransaction`. Deliberately general, not "fiscal year." Report definitions interpret. No auto-release logic, no ERP integration hook.
- **No standard NPC date field on GC fit** — `EffectiveStartDate` / `NextTransactionDate` / `Expected*` fields are all overloaded or platform-managed. Verified via describe.
- **Reclassified** the two seed foundation GDs (`Building Fund`, `Program Expansion Fund` — previously Time-restricted) to Purpose. Their name-based year references (`2026`, `2027`) dropped since the time dimension moved to the gift.
- **Added Phase 6.0** — pre-deploy migration blocker. Removing a picklist value requires zero record hits before deploy.
- **Added OQ9** on picklist-removal blast radius (resolved: no migration needed); OQ10 (GTD-level release date, deferred); OQ11 (Permanent + release date warning UX, resolved: soft warning); OQ12 (long-term goal: setup flows replace Apex-driven org data across FQS).

**From draft 3 → this draft corrections (feedback from Justin, 2026-07-22):**
- **Standard references stripped everywhere.** No FASB, GAAP, ASU 2016-14, ASC 958-490. Concepts stay (donor restriction, exchange transaction, released-from-restriction) but with no citation to the accounting standard behind them. Users needing accounting rationale ask their controller.
- **Catalog expanded to 14 entries** with 3 new Fee-restricted entries (Events, Merchandise, Program Services). Fee-designation plan now ships **before** this plan.
- **All Apex removed from the designation creation path.** `FQS_Suggest_Designations` is the sole path. `fqs-seed-foundation.apex` no longer creates designations. `FQSSeedGenerator.cls` no longer references `External_Id__c LIKE 'FQS-GD-%'` (broadens to `WHERE IsActive = TRUE` since setup-flow-created records have no external ID). OQ12 documents the broader intent: eventually Campaigns and other shipped default record sets follow the same pattern.
- **Test-org workflow now has an unavoidable manual step** — admin runs `FQS_Suggest_Designations` in the UI between teardown and seed. New T16 catches the "forgot the manual step" failure mode.
- **Seed README count updated** — old "10 Designations" line becomes "created via setup flow before seeding."

---

## Handoff notes

- **Read [fqs-gift-entry-wizard-plan.md](./fqs-gift-entry-wizard-plan.md) first.** This plan overlays on that wizard.
- **Do not touch [fqs-release-readiness.md](./fqs-release-readiness.md).** Justin gates.
- **Do not deploy in one big command.** Follow Phase 6 sub-phases.
- **Relevant memory:** [[fqs-crt-deploy-pattern]], [[flow-transform-self-reference-gotcha]], [[flow-in-operator-gotcha]], [[flow-allowfinish-blocks-next]], [[flow-repeater-output-quirk]], [[gt-status-default-paid]] (Status='Paid' preserved through split path), [[seed-scripts-purpose]] (why setup flow, not Apex).
- **Rough LOC / metadata delta:**
  - **New fields:** 2 (`FQS_Restriction_Release_Date__c` on GC + on GT), ~20 LOC each including descriptions.
  - **Modified picklist:** 1 (`GD.FQS_Restriction_Type__c` — remove Time, update description/help), ~30 LOC.
  - **New metadata:** 1 flow file (~350 LOC for `FQS_Suggest_Designations`).
  - **Modified metadata:** launcher flow (Account) + launcher flow (Opportunity) — ~150 net LOC each for split + conflict + match-clone + release-date screen; orchestrator flow — ~40 LOC; 4 flexipages — ~10 LOC each (GC + GT for release date; Campaign + Opp for Related List audits).
  - **Modified permset:** `FQS_Custom_Fields` — 2 new field-permission entries.
  - **Apex — net negative.** `fqs-seed-foundation.apex` DELETES ~30 LOC (the entire designationSpec block, upsert, and debug); adds 0. `FQSSeedGenerator.cls` DELETES ~2 LOC on the external-ID-scoped query (broadens to `IsActive = TRUE`), ADDS ~65 LOC for multi-split coverage + release-date coverage + fee-routing distinction + defensive assert. **No migration script.**
  - **Docs:** ~40 LOC delta to `scripts/apex/seed/README.md`.
  - **No VRs / no list views / no new permsets.**
  - **Total:** ~900 LOC across ~11 files. Split across 5–6 focused commits per Phase 6 sub-phases.
