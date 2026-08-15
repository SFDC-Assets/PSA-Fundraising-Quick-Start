# FQS Earned Revenue Designation — Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst`
**Status:** design-drafted, not-implemented (2026-07-18; updated 2026-07-31 after `Fee/Payment` → `Other` picklist rename)
**Priority:** P1 follow-up to `fqs-account-launcher-flow-parity-plan.md`
**Origin:** surfaced 2026-07-18 during Earned-Income / Event-Registration UI test on Anthony Cohen FQS #42. Justin: *"there is a potential improvement to have a specific category of designation for this type... this needs to be labeled Earned Revenue."*

**Filename note:** kept as `fqs-fee-designation-plan.md` for URL stability; will rename to `fqs-earned-revenue-designation-plan.md` when this plan is picked up for implementation.

---

## Problem

The launcher's Earned Income + Event Registration branches (the two leaves that stamp `GiftTransaction.FQS_Gift_Transaction_Category__c = 'Other'` — formerly `Fee/Payment`, renamed 2026-07-31) currently route into `Screen_Pick_Designation` using the same restriction filter as Outright / In-Kind — default `Without Donor Restriction`. Exchange-transaction revenue isn't a donation. Filtering it into the unrestricted-gifts bucket:

- **Dilutes restriction rollups.** Any downstream reporting that splits revenue by `GiftDesignation.FQS_Restriction_Type__c` treats earned revenue as unrestricted-gift revenue.
- **Makes earned revenue hard to separate.** The transaction-level tag exists (`GiftTransaction.FQS_Gift_Transaction_Category__c = 'Other'`), but the designation-level tag doesn't. Reports that join through `GiftDesignation` or `GiftDefaultDesignation` (i.e., most restriction reports) lose the distinction.
- **UX is wrong.** The Designation picker shows the user all their unrestricted gift designations when they're recording, say, a workshop registration fee. They have to know which of those designations is the "right" one to book earned revenue against.

The right cut is: a **dedicated `Earned Revenue` value** on the restriction-type picklist, with at least one seeded `GiftDesignation` bearing that restriction. Earned-Income / Event-Registration transactions get auto-designated to that GD (or one of several if the org creates multiple); reports naturally separate earned revenue from gift revenue.

---

## Design

### Picklist value

Add one value to [`GiftDesignation.FQS_Restriction_Type__c`](../force-app/main/default/objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml):

```xml
<value>
    <fullName>Earned Revenue</fullName>
    <default>false</default>
    <label>Earned Revenue</label>
</value>
```

**Naming rationale (locked by Justin 2026-07-23):** `Earned Revenue` — the accounting/nonprofit-standard term for exchange-transaction revenue (goods sold, services rendered, event registrations, workshop fees, program service fees). Preferred over the earlier working name `Fee for Good or Service` because it's shorter, familiar to finance/GL staff, and doesn't wobble on singular-vs-plural ("Fee for Goods or Services"). Sits alongside the four FASB values without pretending to be one of them.

**No changes needed on:**
- `GiftDefaultDesignation.FQS_Restriction_Type__c` — formula field, `TEXT(GiftDesignation.FQS_Restriction_Type__c)` — auto-picks up the new value.
- `GiftTransactionDesignation.FQS_Restriction_Type__c` — same, formula mirror.

### Field description / help-text update

The current description reads *"Aligned to FASB ASU 2016-14 net asset classifications."* — accurate for the four existing values, misleading after we add `Earned Revenue` (which is exchange-transaction revenue, not a donor restriction under FASB). Update both:

- **description:** *"Categorizes designations for filtering and reporting. Four values align to FASB ASU 2016-14 donor-restriction classifications (Without Donor Restriction, With Donor Restriction — Purpose / Time / Permanent). A fifth value, Earned Revenue, tags designations used for exchange-transaction revenue (fees, ticketing, workshop registrations) so it can be separated from contribution revenue in reports."*
- **inlineHelpText:** append *"Earned Revenue: revenue from selling goods or providing services — not a donor contribution."*

### Launcher flow wiring

Currently the Earned Income + Event Registration branches flow through the same restriction chain as Outright / In-Kind — `Decide_Restriction_Path`'s default branch routes to `Assign_Restriction_Unrestricted` (sets `var_RestrictionType = 'Without Donor Restriction'`) → `Get_Filtered_Designations` → `Screen_Pick_Designation`.

Two options, in ascending cost:

**Option A — auto-select (cheapest, recommended for v1).**
Add an `Assign_Restriction_EarnedRevenue` element (mirrors `Assign_Restriction_Unrestricted`) that sets `var_RestrictionType = 'Earned Revenue'`. Add a rule to `Decide_Restriction_Path` that fires when the top-level branch is Earned Income OR Event Registration (both stamp `Other` on the GT) and routes to the new assignment. Then `Get_Filtered_Designations` narrows to earned-revenue-eligible GDs and the picker either shows just those or (if there's only one) the picker still opens — no auto-skip.

**Option B — auto-select + skip picker.**
Same as A, but also add a downstream Decide element: if `Get_Filtered_Designations` returns exactly one row, skip `Screen_Pick_Designation` entirely and auto-assign that GD to `rsv_SelectedDesignation`. Reduces click count when the org has a single earned-revenue designation (the common case).

**Recommendation:** ship Option A first. Option B is a follow-on if per-fee-type picking turns out to be common enough to warrant the extra 2 elements. This matches the pattern already used on the Pledge Conditional path — the picker still opens even when filtered narrowly.

**In-Kind Gift branch:** In-Kind stamps `FQS_In_Kind__c = true` and leaves `FQS_Gift_Transaction_Category__c` blank (In-Kind is a giving-mechanism variant of Outright Gift, not earned revenue). In-Kind stays on the `Without Donor Restriction` default; the new Earned-Revenue routing rule fires only on Earned Income + Event Registration.

### Seed generator changes

The seed must produce at least one `GiftDesignation` with `FQS_Restriction_Type__c = 'Earned Revenue'` so the launcher's picker has data on a fresh org. See [`FQSSeedGenerator.cls`](../force-app/main/default/classes/FQSSeedGenerator.cls) — the designation-creation block around line 700 (where the four FASB-restriction GDs are seeded). Add a fifth:

- Name: `Event Registration Fees` (or similar generic label — Justin to confirm; also acceptable: `General Program Fees`, `Earned Revenue`).
- Description: *"Default designation for exchange-transaction revenue — event ticketing, workshop registrations, program service fees. Not a donor contribution."*
- `FQS_Restriction_Type__c = 'Earned Revenue'`
- `IsActive = true`
- `IsDefault = false` (only one GD org-wide should be the org-default unrestricted — the earned-revenue GD is a category default, not org default)

**Note:** as of 2026-07-27's seed-alignment pass, the seed already routes `Other`-category GTs (formerly `Fee/Payment`) to an Earned Revenue GD via `feeDesignationIds` — that branch works today and stays. This plan formalizes it and wires the launcher to the same GD.

### Restriction-picker screen update (Pledge Conditional path)

`Screen_Pick_Restriction` on the Pledge Conditional branch renders four choices matching the four FASB values. Do NOT add `Earned Revenue` here — pledges are contribution transactions by definition; a pledge can't be earned revenue. The new value is filter-scoped to the launcher's Earned Income + Event Registration branches and to whatever list views / reports care about it, not user-selectable on Pledge screens.

---

## Files to touch

| # | File | Change |
|---|---|---|
| 1 | [`objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml`](../force-app/main/default/objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml) | add 5th picklist value; update description + inlineHelpText |
| 2 | [`flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml`](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml) | add `Assign_Restriction_EarnedRevenue`; add rule to `Decide_Restriction_Path` firing on Earned Income / Event Registration leaves |
| 3 | [`classes/FQSSeedGenerator.cls`](../force-app/main/default/classes/FQSSeedGenerator.cls) | seed one Earned Revenue designation if not already present; keep the existing `Other`-category → earned-revenue GD routing |
| 4 | (optional) `objects/GiftDesignation/listViews/*` | audit — if any list view uses restriction-type filter, consider adding a `FQS_Earned_Revenue_Designations.listView-meta.xml` sibling |
| 5 | (optional) Reports on `FQS_Restriction_Type__c` grouping | audit — any report that groups by restriction type will start showing the new bucket; verify labels / sort order look right |

**Not touching:**
- `GiftDefaultDesignation.FQS_Restriction_Type__c.field-meta.xml` — formula, mirrors automatically.
- `GiftTransactionDesignation.FQS_Restriction_Type__c.field-meta.xml` — formula, mirrors automatically.
- Any donor-facing screen text that mentions "restriction" — the new value is org-internal categorization, not a donor-facing concept.

---

## Testing

1. Deploy picklist change + flow change + seed change.
2. Run `sf apex run --file scripts/apex/seed/fqs-seed-small.apex` (or equivalent) — verify: (a) one new `Event Registration Fees` GD created, (b) any `Other`-category GT in the seed has its GTD pointing at that GD.
3. UI test — launcher from any Account → Earned Income (or Event Registration) → complete flow → verify the Designation picker shows only earned-revenue-eligible designations (should be at least the one seeded).
4. Verify the resulting `GiftTransaction` has `FQS_Gift_Transaction_Category__c = 'Other'` AND its `GiftTransactionDesignation.FQS_Restriction_Type__c = 'Earned Revenue'`.
5. Report smoke test — build a simple GT report grouped by `GiftDesignation.FQS_Restriction_Type__c` — verify earned revenue lands in its own bucket, not the unrestricted-gifts bucket.

---

## Non-goals / deferred

- **Multi-earned-revenue-designation UX polish.** If an org has multiple earned-revenue designations (Event Fees, Workshop Fees, Consulting Fees), the picker just shows them all. No auto-select on single-match (Option B above) until real-world usage argues for it.
- **Fee decomposition** (gateway fees, processor fees, donor cover) — separate concern, tracked in `fqs-account-launcher-flow-parity-plan.md` §2.4 (deferred).
- **Renaming `FQS_Restriction_Type__c`** to something more neutral (e.g., `FQS_Designation_Category__c`) — the field's four FASB values still describe restriction; renaming would break existing formulas, list views, reports. Not worth it. The mixed semantic (four FASB restrictions + one exchange-transaction bucket) is acknowledged in the description update.
- **Accounting-side reconciliation.** How earned revenue reconciles against nonprofit chart-of-accounts / GL export is out of scope. This plan only makes the transaction categorizable inside Salesforce.

---

## Open questions for Justin

1. **Seeded GD name.** `Event Registration Fees` is a placeholder. Preferred name?
2. **Ship inside the current launcher-parity plan, or as its own commit?** Small enough to fold into the parity plan; clean enough to stand alone. Recommend: standalone commit, since it touches a picklist (field-metadata change) and the seed generator, not just flow XML — different blast radius from the pure-flow work.
3. **Migration for existing `Other`-category GTs.** The 26 GTs migrated from `Fee/Payment` → `Other` on 2026-07-31 currently have GTDs pointing at whatever designation the pre-rename routing gave them. If those already point at an earned-revenue GD (from the 2026-07-27 seed-alignment pass), no migration is needed. If they point at the unrestricted default, a one-shot re-point script (~10 lines) after the new GD lands.
