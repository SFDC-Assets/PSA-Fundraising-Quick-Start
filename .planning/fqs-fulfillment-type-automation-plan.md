# FQS GiftCommitment.FulfillmentType Automation Plan

**Status:** Planned. Not yet built.
**Owner:** Justin (solo).
**Related:** [[fqs-designation-hierarchy-plan]], [[fqs-designations-plan]], [[flow-formula-picklist-comparison]].

---

## Problem statement

`GiftCommitment.FulfillmentType` (values: `Unconditional` / `Conditional`) records whether a donor placed a restriction on a pledge / grant / recurring commitment. Historically the FQS launcher asked the user directly ("Did the donor put any conditions on this gift?"), then Commit 3 (2026-07-30) tried to derive it from the resolved designation inside the launcher flow. Both approaches were rejected:

- **User-prompted** duplicates information already carried by the designation, and lets the two sources go out of sync (user picks Unconditional but chooses a restricted designation → silently inconsistent GC record).
- **Launcher-derived** (Commit 3) only fires at insert time, doesn't cover Platform_Split cases correctly, and can't react to later changes to the associated designations (a designation reclassified from `Without Donor Restriction` to `With Donor Restriction — Purpose` should retroactively flip every GC that references it).

Commit 4 (2026-07-30, this session) stripped the launcher-side derivation. `FulfillmentType` now falls to the platform default (`Unconditional`) at GC insert. This plan defines the automation that owns the field going forward.

---

## Core rule

For a given `GiftCommitment`, gather all `GiftDefaultDesignation` rows where `ParentRecordId = GC.Id`, then load the `GiftDesignation` each of those points at. For each of those GDs:

- If **any** GD has `FQS_Restriction_Type__c != 'Without Donor Restriction'` → `GC.FulfillmentType = 'Conditional'`.
- Otherwise (all associated GDs are `Without Donor Restriction`, OR the GC has zero GDDs) → `GC.FulfillmentType = 'Unconditional'`.

**Restriction release date does NOT participate.** Per Justin (2026-07-30 conversation): the pledge was conditional at inception; the release date records when the funds become spendable but the fulfillment classification does not flip. Release date remains reporting / compliance metadata on the `GiftDesignation` and — separately — is planned to drive `GiftTransactionDesignation.FQS_Restriction_Release_Date__c` fanout (see [[seed-release-date-followup]] and Phase D6 in [[fqs-designations-plan]]).

**Zero-GDD case is Unconditional.** A GC that carries no default designations at all is treated as unconditional. Platform default already lands this way; automation does not need to write when the collection is empty.

**Once Conditional, always Conditional? No.** If all restricted GDDs are removed from a GC, the automation must flip it back to Unconditional. Reclassification and removal both need to be reactive.

---

## Trigger surfaces

Every surface below fans in to a single service method:
`GiftCommitmentFulfillmentService.recompute(Set<Id> gcIds)`.

| # | Trigger | Fires when | GC set to recompute |
|---|---|---|---|
| 1 | `GiftDefaultDesignation` — after insert / update / delete | User (or automation, or launcher) attaches / detaches / rewrites a GC-level default designation | Distinct `ParentRecordId` values whose `Parent.Type = 'GiftCommitment'`. Includes `Trigger.old` on delete and on update-with-parent-change. |
| 2 | `GiftDesignation` — after update where `FQS_Restriction_Type__c` changed | A designation is reclassified (`Without → Purpose`, etc.). Every GC that has a GDD pointing at this GD must recompute. | `SELECT ParentRecordId FROM GiftDefaultDesignation WHERE GiftDesignationId IN :changedGDIds AND Parent.Type = 'GiftCommitment'` — the distinct set of GC Ids. |
| 3 | `GiftCommitment` — after insert | Bootstrap the value from the initial GDD set (usually empty at insert; platform default 'Unconditional' is already correct in that case, so the automation will typically no-op on insert). | Just the inserted GC Ids. |

**Deliberately NOT triggered on:**
- `GiftTransactionDesignation` — GTDs are per-transaction outputs of the GDD fan-out; they don't define GC intent.
- `GiftCommitment` on update — no reason to react to arbitrary GC edits.
- Time-based sweep — release date does not participate, so nothing needs a nightly scan.
- Campaign-level GDDs — commitments are point-in-time snapshots; if a Campaign's default designation later changes, existing GCs already own their copies of the resolved designation via their own GDDs. Campaign edits do not cascade.

---

## Automation shape

**Trigger handler + service class** in Apex. Reasons over record-triggered flow:

- Bulk-safe: 200-row DML operations on GDD must not fire 200 individual GC recomputes; the service class batches by GC.
- Testable in isolation — a service-class unit test does not need to instantiate GDs / GDDs / GCs to prove the rule logic.
- Handles the many-to-one designation → many-GCs cascade (trigger 2 above) — record-triggered flow can do this but it's cleaner in Apex.

### Class structure

```
GiftDefaultDesignationTrigger        (trigger on GiftDefaultDesignation)
  → GiftDefaultDesignationTriggerHandler.handle(...)
  → GiftCommitmentFulfillmentService.recompute(Set<Id> gcIds)

GiftDesignationTrigger                (trigger on GiftDesignation)
  → GiftDesignationTriggerHandler.handle(...)
  → GiftCommitmentFulfillmentService.recompute(Set<Id> gcIds)

GiftCommitmentTrigger                 (may already exist — add after-insert hook)
  → GiftCommitmentTriggerHandler.handle(...)
  → GiftCommitmentFulfillmentService.recompute(Set<Id> gcIds)

GiftCommitmentFulfillmentService     (public with sharing)
  + recompute(Set<Id> gcIds): void
  + recomputeForGDIds(Set<Id> gdIds): void       // helper for surface 2
  - buildIntendedValueMap(Set<Id>): Map<Id,String>
  - loadCurrentValues(Set<Id>): Map<Id,String>
  - dmlDiff(Map<Id,String>, Map<Id,String>): List<GiftCommitment>
```

### Recursion guard

`GiftCommitmentFulfillmentService.recompute` will DML `GiftCommitment` records — which fires any GC after-update handler. If a GC after-update handler ever gets added (not planned right now), it must NOT re-invoke this service. Guard via:

```apex
public class GiftCommitmentFulfillmentService {
    public static Boolean isRecomputing = false;

    public static void recompute(Set<Id> gcIds) {
        if (isRecomputing) return;
        try {
            isRecomputing = true;
            // ... query + diff + update
        } finally {
            isRecomputing = false;
        }
    }
}
```

Standard static-flag pattern. Also covers the GC-insert bootstrap case (surface 3) — that trigger's after-insert handler calls the same service, and its update will itself fire after-update, so the guard prevents infinite loop.

### SOQL / DML budget per recompute call

For `Set<Id> gcIds` of size N:

- 1 SOQL against `GiftDefaultDesignation` (with `GiftDesignation.FQS_Restriction_Type__c` traversal) filtered by `ParentRecordId IN :gcIds`.
- 1 SOQL against `GiftCommitment` filtered by `Id IN :gcIds` for current-value diff.
- 1 DML on `GiftCommitment` for the diff-only update list.

**Total: 2 SOQL + 1 DML** regardless of N (up to the 50k-row query limit). Comfortably under limits for any realistic import.

---

## Edge cases + decisions

### 1. Inactive designations
`GiftDesignation.IsActive = false` — do inactive GDs still count toward Conditional?

**Decision: yes.** If a restricted GD becomes inactive but the GDD still points at it, the commitment is still historically conditional. Deactivating a GD does not change what the donor intended. If the admin wants to flip the GC to Unconditional they must delete the GDD.

### 2. GDD without `GiftDesignationId`
Some GDDs may have a null `GiftDesignationId` (schema allows it — the platform's Process_ chain writes such rows during pending states). These rows contribute nothing to the calculation — skip them in the aggregation. If **all** GDDs on the GC have null `GiftDesignationId`, treat the GC as if it had no GDDs → Unconditional.

### 3. Recurring commitments
Recurring GCs today land with hardcoded `FulfillmentType = 'Unconditional'` in `Assign_Recurring_Defaults` (donor line 1956) and `Assign_Employer_Recurring_Defaults` (employer line 1106) in the launcher flow. Once this automation lands, those hardcoded assigns should be **stripped** (same as Simple/Scheduled were stripped in Commit 4). The automation will bootstrap correctly at GC insert whether the field was pre-set or platform-defaulted. Deferred until this plan builds — no code change to Recurring at the moment.

### 4. Manual admin override
If an admin manually edits `GC.FulfillmentType` in the UI, this automation will silently overwrite that value on the next trigger fire — arguably wrong.

**Decision: automation always wins.** Rationale: automation is authoritative; manual overrides represent stale intent that predates the automation and shouldn't survive. If an admin needs to force a specific value, they should adjust the underlying GDDs / GD restriction types instead.

Optional escape hatch (deferred): a `GiftCommitment.FQS_Manual_Fulfillment_Override__c` boolean that suppresses the recompute. Only build if a real use case surfaces.

### 5. Bulk data loads
CSV imports of GDDs (e.g., historical data migration) may create thousands of GDDs at once, all pointing at the same handful of GDs and referencing hundreds of GCs. The recompute must not exceed governor limits:

- Group by GC before recomputing — the service already does this via `Set<Id> gcIds`.
- If the caller passes >10,000 GC Ids in one shot, consider chunking within the service (200 GCs / chunk). Not a v1 requirement unless we see a real import that busts limits.

### 6. Async vs sync
This automation is a straightforward diff-and-update. Runs synchronously in the trigger context. No need for `@future` or Queueable unless we see governor issues under real load. Defer until observed.

### 7. Test data — Platform_Split
A test case must cover a GC with 2+ GDDs where at least one points at a restricted GD → the GC lands as Conditional. And the mirror: all GDDs unrestricted → Unconditional.

---

## Test plan

`GiftCommitmentFulfillmentServiceTest`:

1. **Insert GC, no GDDs** → assert `FulfillmentType = 'Unconditional'` (platform default persists).
2. **Insert GC, then attach 1 unrestricted GDD** → assert `FulfillmentType = 'Unconditional'` (no change; automation may no-op).
3. **Insert GC, then attach 1 restricted GDD** → assert `FulfillmentType = 'Conditional'`.
4. **Insert GC with 2 unrestricted GDDs + 1 restricted GDD** (Platform_Split with mixed restriction) → assert `Conditional`.
5. **Existing Conditional GC — delete the last restricted GDD** → assert flip to `Unconditional`.
6. **Existing Conditional GC — reclassify the referenced GD from Purpose → Without Donor Restriction** → assert flip to `Unconditional`.
7. **Existing Unconditional GC — reclassify a referenced GD from Without → Permanent** → assert flip to `Conditional`.
8. **Bulk: 200 GCs, all attached to a mix of GDDs** → assert governor-safe (2 SOQL, 1 DML), assert all 200 land with correct values.
9. **Bulk: 200 GDs each referenced by 5 GCs (1000 GCs total), one GD reclassified** → assert only the 5 GCs pointing at that GD are updated; SOQL/DML budget still holds.
10. **Recursion guard** — force a scenario where the service is called mid-execution; assert it no-ops (implicit via the static flag).

**Test data pattern:**
- `@testSetup` creates 3 GDs (Without, Purpose, Permanent) + 1 default Account + 1 default Campaign.
- Each test method builds its own GCs + GDDs.

---

## Rollout

1. **Build service class + trigger handlers + triggers + test class** (this milestone).
2. **Deploy to sandbox.**
3. **Verify existing sandbox data**: run a SOQL sweep — count GCs where automation-derived value ≠ current value. Any drift is legacy data pre-automation; run a one-time backfill script (`GiftCommitmentFulfillmentService.recompute(<all GC Ids>)` in anonymous Apex) to bring everything into alignment.
4. **Add to admin README** — this is FQS-standard-field-owned via automation, no manual maintenance required. Note that removing the FQS unmanaged package will drop the triggers → the field's value will freeze at whatever last-computed state.
5. **Strip hardcoded Recurring `FulfillmentType = 'Unconditional'` seeds** from the launcher (lines 1106, 1956) — becomes redundant after automation lands, and continues to lie if a Recurring is created with a restricted GDD.
6. **Update [[fqs-release-readiness.md]]** — new §Gate row: "FulfillmentType automation live" required for release.

---

## Non-goals

- **Restriction release date does not flip fulfillment.** Confirmed above.
- **User prompts for fulfillment are not restored.** The field is automation-owned; users interact with the designation only.
- **Campaign-level GDD changes do NOT cascade to existing GCs.** Commitments are snapshots.
- **Opportunity-side fulfillment.** FundFirst's Opportunity object has its own restriction/fulfillment story handled elsewhere; out of scope here.
- **Multi-currency.** No currency conversion needed for a picklist field.

---

## Open questions

1. **Recurring seed strip timing** — do it in the same commit as the automation, or a follow-up? Recommendation: same commit, so the launcher stops writing a value the automation will immediately re-derive.
2. **Backfill script scope** — do we scan all historical GCs on first automation deploy, or only recompute on next relevant trigger fire? Recommendation: one-time full backfill in anonymous Apex at deploy time; ensures immediate consistency for all existing records.
3. **Should GC-insert automation actually write, or is the platform-default 'Unconditional' guaranteed to match the intended value?** At GC insert, there are typically zero GDDs → intended = 'Unconditional' = platform default → no-op. The GC-insert trigger might be pure defense; deferrable. Leaving it in scope as a safety net.
