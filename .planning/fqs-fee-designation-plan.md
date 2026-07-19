# FQS Fee-for-Service Designation — Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst`
**Status:** design-drafted, not-implemented (2026-07-18)
**Priority:** P1 follow-up to `fqs-account-launcher-flow-parity-plan.md`
**Origin:** surfaced 2026-07-18 during FeeForService UI test on Anthony Cohen FQS #42. Justin: *"there is a potential improvement to have a specific category of designation for this type... this needs to be labeled Fee for Good or Service."*

---

## Problem

The launcher's FeeForService branch currently routes into `Screen_Pick_Designation` using the same restriction filter as Outright/InKind — default `Without Donor Restriction`. Fees aren't donations. Filtering them into the unrestricted-gifts bucket:

- **Dilutes restriction rollups.** Any downstream reporting that splits revenue by `GiftDesignation.FQS_Restriction_Type__c` treats fee revenue as unrestricted-gift revenue.
- **Makes fee revenue hard to separate.** The transaction-level tag exists (`GiftTransaction.FQS_Gift_Transaction_Category__c = 'Fee/Payment'`), but the designation-level tag doesn't. Reports that join through `GiftDesignation` or `GiftDefaultDesignation` (i.e., most restriction reports) lose the distinction.
- **UX is wrong.** The Designation picker shows the user all their unrestricted gift designations when they're recording, say, a workshop registration fee. They have to know which of those designations is the "right" one to book fee revenue against.

The right cut is: a **dedicated `Fee for Good or Service` value** on the restriction-type picklist, with at least one seeded `GiftDesignation` bearing that restriction. FeeForService transactions get auto-designated to that GD (or one of several if the org creates multiple); reports naturally separate fee revenue from gift revenue.

---

## Design

### Picklist value

Add one value to [`GiftDesignation.FQS_Restriction_Type__c`](../force-app/main/default/objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml):

```xml
<value>
    <fullName>Fee for Good or Service</fullName>
    <default>false</default>
    <label>Fee for Good or Service</label>
</value>
```

**Naming rationale (locked by Justin 2026-07-18):** `Fee for Good or Service` — covers both goods (e.g., merchandise, event ticketing) and services (workshop fees, advisory retainers). Sits alongside the four FASB values without pretending to be one of them.

**No changes needed on:**
- `GiftDefaultDesignation.FQS_Restriction_Type__c` — formula field, `TEXT(GiftDesignation.FQS_Restriction_Type__c)` — auto-picks up the new value.
- `GiftTransactionDesignation.FQS_Restriction_Type__c` — same, formula mirror.

### Field description / help-text update

The current description reads *"Aligned to FASB ASU 2016-14 net asset classifications."* — accurate for the four existing values, misleading after we add `Fee for Good or Service` (which is exchange-transaction revenue, not a donor restriction under FASB). Update both:

- **description:** *"Categorizes designations for filtering and reporting. Four values align to FASB ASU 2016-14 donor-restriction classifications (Without Donor Restriction, With Donor Restriction — Purpose / Time / Permanent). A fifth value, Fee for Good or Service, tags designations used for exchange-transaction revenue (fees, ticketing, workshop registrations) so it can be separated from contribution revenue in reports."*
- **inlineHelpText:** append *"Fee for Good or Service: revenue from selling goods or providing services — not a donor contribution."*

### Launcher flow wiring

Currently the FeeForService branch flows through the same restriction chain as Outright / InKind — `Decide_Restriction_Path`'s default branch routes to `Assign_Restriction_Unrestricted` (sets `var_RestrictionType = 'Without Donor Restriction'`) → `Get_Filtered_Designations` → `Screen_Pick_Designation`.

Two options, in ascending cost:

**Option A — auto-select (cheapest, recommended for v1).**
Add an `Assign_Restriction_FeeForService` element (mirrors `Assign_Restriction_Unrestricted`) that sets `var_RestrictionType = 'Fee for Good or Service'`. Add a rule to `Decide_Restriction_Path` that fires when `pkAskType == 'FeeForService'` and routes to the new assignment. Then `Get_Filtered_Designations` narrows to fee-eligible GDs and the picker either shows just those or (if there's only one) the picker still opens — no auto-skip.

**Option B — auto-select + skip picker.**
Same as A, but also add a downstream Decide element: if `Get_Filtered_Designations` returns exactly one row, skip `Screen_Pick_Designation` entirely and auto-assign that GD to `rsv_SelectedDesignation`. Reduces click count when the org has a single fee designation (the common case).

**Recommendation:** ship Option A first. Option B is a follow-on if per-fee-type picking turns out to be common enough to warrant the extra 2 elements. This matches the pattern already used on the Pledge Conditional path — the picker still opens even when filtered narrowly.

### Seed generator changes

The seed must produce at least one `GiftDesignation` with `FQS_Restriction_Type__c = 'Fee for Good or Service'` so the launcher's picker has data on a fresh org. See [`FQSSeedGenerator.cls`](../force-app/main/default/classes/FQSSeedGenerator.cls) — the designation-creation block around line 700 (where the four FASB-restriction GDs are seeded). Add a fifth:

- Name: `Event Registration Fees` (or similar generic label — Justin to confirm; also acceptable: `General Program Fees`, `Fee Revenue`).
- Description: *"Default designation for exchange-transaction revenue — event ticketing, workshop registrations, program service fees. Not a donor contribution."*
- `FQS_Restriction_Type__c = 'Fee for Good or Service'`
- `IsActive = true`
- `IsDefault = false` (only one GD org-wide should be the org-default unrestricted — the fee GD is a category default, not org default)

**Fee/Payment GT routing in seed:** currently the seed generator emits `GiftTransactionDesignation` rows against whatever the parent commitment's default designation says (or unrestricted default for one-off gifts). After this change, any `GT.FQS_Gift_Transaction_Category__c = 'Fee/Payment'` seed row should route its GTD to the new fee GD instead. One extra Decide-and-lookup at seed time.

### Restriction-picker screen update (Pledge Conditional path)

`Screen_Pick_Restriction` on the Pledge Conditional branch renders four choices matching the four FASB values. Do NOT add `Fee for Good or Service` here — pledges are contribution transactions by definition; a pledge can't be a "fee for good or service." The new value is filter-scoped to the launcher's FeeForService branch and to whatever list views / reports care about it, not user-selectable on Pledge screens.

---

## Files to touch

| # | File | Change |
|---|---|---|
| 1 | [`objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml`](../force-app/main/default/objects/GiftDesignation/fields/FQS_Restriction_Type__c.field-meta.xml) | add 5th picklist value; update description + inlineHelpText |
| 2 | [`flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml`](../force-app/main/default/flows/FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml) | add `Assign_Restriction_FeeForService`; add rule to `Decide_Restriction_Path` |
| 3 | [`classes/FQSSeedGenerator.cls`](../force-app/main/default/classes/FQSSeedGenerator.cls) | seed one Fee designation; route Fee/Payment seed rows' GTDs to it |
| 4 | (optional) `objects/GiftDesignation/listViews/*` | audit — if any list view uses restriction-type filter, consider adding a `FQS_Fee_Designations.listView-meta.xml` sibling to the existing `FQS_Without_Donor_Restriction.listView` / `FQS_With_Donor_Restriction.listView` |
| 5 | (optional) Reports on `FQS_Restriction_Type__c` grouping | audit — any report that groups by restriction type will start showing the new bucket; verify labels / sort order look right |

**Not touching:**
- `GiftDefaultDesignation.FQS_Restriction_Type__c.field-meta.xml` — formula, mirrors automatically.
- `GiftTransactionDesignation.FQS_Restriction_Type__c.field-meta.xml` — formula, mirrors automatically.
- Any donor-facing screen text that mentions "restriction" — the new value is org-internal categorization, not a donor-facing concept.

---

## Testing

1. Deploy picklist change + flow change + seed change.
2. Run `sf apex run --file scripts/apex/seed/fqs-seed-small.apex` (or equivalent) — verify: (a) one new `Event Registration Fees` GD created, (b) any Fee/Payment GT in the seed has its GTD pointing at that GD.
3. UI test — launcher from any Account → FeeForService → complete flow → verify the Designation picker shows only fee-eligible designations (should be at least the one seeded).
4. Verify the resulting `GiftTransaction` has `FQS_Gift_Transaction_Category__c = 'Fee/Payment'` AND its `GiftTransactionDesignation.FQS_Restriction_Type__c = 'Fee for Good or Service'`.
5. Report smoke test — build a simple GT report grouped by `GiftDesignation.FQS_Restriction_Type__c` — verify fee revenue lands in its own bucket, not the unrestricted-gifts bucket.

---

## Non-goals / deferred

- **Multi-fee-designation UX polish.** If an org has multiple fee designations (Event Fees, Workshop Fees, Consulting Fees), the picker just shows them all. No auto-select on single-match (Option B above) until real-world usage argues for it.
- **Fee decomposition** (gateway fees, processor fees, donor cover) — separate concern, tracked in `fqs-account-launcher-flow-parity-plan.md` §2.4 (deferred).
- **Renaming `FQS_Restriction_Type__c`** to something more neutral (e.g., `FQS_Designation_Category__c`) — the field's four FASB values still describe restriction; renaming would break existing formulas, list views, reports. Not worth it. The mixed semantic (four FASB restrictions + one exchange-transaction bucket) is acknowledged in the description update.
- **Accounting-side reconciliation.** How fee revenue reconciles against nonprofit chart-of-accounts / GL export is out of scope. This plan only makes the transaction categorizable inside Salesforce.

---

## Open questions for Justin

1. **Seeded GD name.** `Event Registration Fees` is a placeholder. Preferred name?
2. **Ship inside the current launcher-parity plan, or as its own commit?** Small enough to fold into the parity plan; clean enough to stand alone. Recommend: standalone commit, since it touches a picklist (field-metadata change) and the seed generator, not just flow XML — different blast radius from the pure-flow work.
3. **Migration for existing Fee/Payment GTs (if any).** The launcher hasn't shipped so there aren't user-created Fee/Payment GTs in FundFirst yet — but if there are seeded ones, they need their GTDs re-pointed once the new GD exists. One-shot Apex script, ~10 lines. Confirm needed before writing.
