# Campaign Member Automation — Build Plan

**Started:** 2026-08-12
**Owner:** Justin (solo)
**Status:** in progress

Extends the three shipping CampaignMember automation flows to handle updates, deletes, and status downgrades. Adds a Campaign-level opt-out checkbox and gates all automation on Hierarchy Depth >= 3 (Tactical level).

---

## Scope decisions (locked)

| Decision | Choice | Notes |
|---|---|---|
| Event-ladder gift handling | **Add Pledged/Gave rung (SortOrder=5)** | New rung, HasResponded=true. Backfill on existing event campaigns via anonymous Apex. |
| Downgrade triggers | **Hard delete + GT.Status Refund/Cancel + GC.Status Lapsed** | Three trigger paths. |
| Fallback status on downgrade | **Always revert to Solicited (baseline) / Registered (event)** | No history field; no delete-of-CampaignMember. Simpler, may show walk-in donors as Solicited (accepted tradeoff). |
| Opt-out checkbox | **FQS_Enable_Auto_Members__c on Campaign** | Default TRUE on insert (via before-save flow) ONLY when depth >= 3. Depth 1/2 = never defaulted, hidden on record page. |
| Depth threshold | **Hardcoded >= 3** | Not configurable via CMDT. Simpler to change later than to configure now. |
| GC downgrade set | **Just Lapsed** | Not Closed (often means paid-in-full) or Failing (payment-processor state). |
| Downgrade guard | **Skip downgrade if donor has ANY other Paid GT or Active GC on same campaign** | Prevents partial refunds from downgrading whole-campaign members. Extra SOQL per downgrade branch. |
| Backfill mechanism | **Anonymous Apex** | Single script under scripts/apex/, run once against FundFirst. |
| No Apex at runtime | **Confirmed** | All runtime automation is Flow. Apex is one-shot backfill only. |

## Confirmed picklist values (from docs/nonprofit-cloud-developer-guide-v67.md)

**GiftTransaction.Status** (default `Unpaid`):
- Canceled, Failed, Fully Refunded, Paid, Pending, Unpaid, Written-Off

**GiftCommitment.Status** (default `Draft`):
- Active, Closed, Draft, Failing, Lapsed, Paused

**Downgrade set:**
- GT: `Canceled`, `Failed`, `Fully Refunded`, `Written-Off`
- GC: `Lapsed` only

---

## Combined runtime gate

Applied in every downstream member-status flow before any create/update/downgrade:

```
Campaign.FQS_Enable_Auto_Members__c = TRUE
  AND Campaign.FQS_Hierarchy_Depth__c >= 3
  AND Account is Person Account (has PersonContactId)
```

Depth check is redundant with the checkbox (checkbox only defaults TRUE at depth >= 3) but stays as a hard-coded safety.

---

## Build order (milestone-gated)

### Milestone 1 — Field + gate scaffolding
Deploy in one batch, user validates checkbox behavior on new + existing Campaigns before any member logic changes.

- [x] Create `force-app/main/default/objects/Campaign/fields/FQS_Enable_Auto_Members__c.field-meta.xml`
  - Checkbox, defaultValue=false (platform default), no formula
  - Help text: "When checked, gifts and commitments on this campaign automatically create or advance a Campaign Member row for the donor. Only applies to Tactical-level campaigns (Hierarchy Depth >= 3). Uncheck to opt this campaign out of automatic member tracking."
- [ ] Add flexipage visibility rule on `FQS_Campaign_Record_Page.flexipage-meta.xml` — hide `FQS_Enable_Auto_Members__c` when `FQS_Hierarchy_Depth__c < 3`
- [ ] Create before-save record-triggered flow `FQS_Campaign_Auto_Members_Default`
  - Trigger: `Campaign`, RecordBeforeSave, Create-only, `FQS_Hierarchy_Depth__c >= 3`
  - Action: set `$Record.FQS_Enable_Auto_Members__c = TRUE`
  - Skip Fundraising Top Level Campaign structural placeholder
- [ ] Add `FQS_Enable_Auto_Members__c` (edit permission) to `FQS_Custom_Fields.permissionset-meta.xml`
- [ ] Deploy; user validates:
  - New depth-3 campaign gets checkbox = TRUE
  - New depth-1/2 campaign has field hidden on page
  - Existing campaigns unchanged (no retro-flip)

### Milestone 2 — Ladder + backfill
Deploy Ladder change, run backfill Apex, user validates rung landed on existing event campaigns.

- [ ] Edit `FQS_Campaign_Member_Status_Ladder.flow-meta.xml`
  - Add Event ladder Create Records: `Pledged/Gave`, SortOrder=5, HasResponded=true, IsDefault=false
  - Add flow entry filter: skip when `FQS_Hierarchy_Depth__c < 3` OR checkbox = FALSE (still skip Fundraising Top Level)
- [ ] Write `scripts/apex/backfill-event-ladder-pledged-gave.apex`
  - Query event campaigns without a Pledged/Gave CampaignMemberStatus
  - Insert the missing rung
  - Bulk-safe, idempotent (skip campaigns that already have it)
- [ ] Deploy Ladder flow + run Apex; user validates:
  - Existing event campaigns show Pledged/Gave in the ladder
  - New event campaigns get the rung automatically at insert
  - Depth < 3 campaign inserts skip ladder seeding entirely

### Milestone 3 — Update + downgrade paths on GT and GC
The core new behavior. Deploy On_Gift + On_Commitment rewrites in one batch.

- [ ] Rewrite `FQS_Campaign_Member_Status_On_Gift.flow-meta.xml`
  - Trigger: Create OR Update
  - Entry criteria: `ISNEW() OR ISCHANGED(CampaignId) OR ISCHANGED(DonorId) OR ISCHANGED(Status)`
  - Branches:
    - **Upgrade** (existing behavior): Status in (Paid, Pending, Unpaid) AND Campaign gate passes -> flip/create CampaignMember to Pledged/Gave
    - **Reparent**: `ISCHANGED(CampaignId)` AND non-null prior CampaignId -> downgrade prior campaign's member; then run upgrade against new CampaignId
    - **Donor swap**: `ISCHANGED(DonorId)` -> downgrade old donor's member; upgrade new donor
    - **Downgrade**: `ISCHANGED(Status)` AND new Status in (Canceled, Failed, Fully Refunded, Written-Off) -> revert member to Solicited/Registered, gated by cross-record guard
- [ ] Rewrite `FQS_Campaign_Member_Status_On_Commitment.flow-meta.xml`
  - Mirror of On_Gift
  - GC downgrade trigger: `ISCHANGED(Status)` AND new Status = Lapsed
- [ ] Downgrade guard subflow or inline logic: query GT WHERE DonorId=X AND CampaignId=Y AND Status='Paid' AND Id != current; query GC WHERE DonorId=X AND CampaignId=Y AND Status='Active' AND Id != current. If either returns >= 1, skip downgrade.
- [ ] Deploy; user validates:
  - Reparent GT from Campaign A to Campaign B -> Campaign A member downgrades, Campaign B member upgrades
  - GT.Status Paid -> Fully Refunded -> member downgrades (if no other active gifts on same campaign)
  - GC.Status Active -> Lapsed -> member downgrades
  - Guard: two paid GTs on same campaign, refund one -> member stays at Pledged/Gave

### Milestone 4 — Hard-delete flows
Final safety net. Deploy two new flows.

- [ ] Create `FQS_Campaign_Member_Status_On_Gift_Delete.flow-meta.xml`
  - Trigger: `GiftTransaction`, RecordBeforeDelete
  - Gate: checkbox + depth >= 3 + Person Account
  - Guard: cross-record check (any other Paid GT or Active GC still exists on this campaign for this donor?)
  - Action: flip CampaignMember to Solicited (baseline) or Registered (event)
- [ ] Create `FQS_Campaign_Member_Status_On_Commitment_Delete.flow-meta.xml`
  - Mirror of GT delete flow
- [ ] Deploy; user validates:
  - Delete the last GT on a donor+campaign pair -> member downgrades
  - Delete a GT when the donor still has an Active GC -> member stays

---

## Files touched (running list)

**New:**
- `force-app/main/default/objects/Campaign/fields/FQS_Enable_Auto_Members__c.field-meta.xml` (created)
- `force-app/main/default/flows/FQS_Campaign_Auto_Members_Default.flow-meta.xml`
- `force-app/main/default/flows/FQS_Campaign_Member_Status_On_Gift_Delete.flow-meta.xml`
- `force-app/main/default/flows/FQS_Campaign_Member_Status_On_Commitment_Delete.flow-meta.xml`
- `scripts/apex/backfill-event-ladder-pledged-gave.apex`

**Modified:**
- `force-app/main/default/flows/FQS_Campaign_Member_Status_Ladder.flow-meta.xml`
- `force-app/main/default/flows/FQS_Campaign_Member_Status_On_Gift.flow-meta.xml`
- `force-app/main/default/flows/FQS_Campaign_Member_Status_On_Commitment.flow-meta.xml`
- `force-app/main/default/flexipages/FQS_Campaign_Record_Page.flexipage-meta.xml`
- `force-app/main/default/permissionsets/FQS_Custom_Fields.permissionset-meta.xml`

---

## Known unknowns / follow-up if hit

- Whether `FQS_Campaign_Hierarchy_Setup` currently touches `FQS_Enable_Auto_Members__c` -- it doesn't need to (before-save default flow handles it) but if the setup flow explicitly sets other FQS_* fields on Tactical rows, might want to add this one too for consistency.
- Field-visibility rule syntax on flexipage -- may need to test different comparator forms (`>=` vs `GreaterThanOrEqual`).
- Whether `FQS_Campaign_Fields` permset also needs the new field -- audit which permset owns Campaign FQS_* fields.
- GT.Status transitions from Unpaid -> Paid should NOT re-fire the upgrade because ISCHANGED(Status) will trip -- confirm the upgrade path is idempotent when the member is already Pledged/Gave.
