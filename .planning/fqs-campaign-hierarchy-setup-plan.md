# FQS Campaign Hierarchy Setup — Execution Plan (v3)

**v3 changes (shipped 2026-07-13):**

- **Row-level picking replaces model-plus-toggle.** The flow now shows admins a Data Table of suggested campaigns per tier (rollups, strategies, asks) and they multi-select the rows they want. "Skip level-3 asks" is no longer a top-of-flow toggle — leaving the Asks table empty has the same effect.
- **CMDT-direct data tables.** `flowruntime:datatable` only accepts SObject/CMDT rows (verified against SMQS's `SMQS_Party_Role_Relationship_Suggestion` flow). The flow does three `Get Records` on `FQS_Campaign_Template__mdt` filtered by `Level__c` + `Applicable_Models__c`, feeds each into a table with `dataTypeMappings.typeValue = FQS_Campaign_Template__mdt`, then loops the `selectedRows` to build a `List<String>` of `Template_Key__c` values.
- **No `VirtualCampaign` wrapper class.** Was designed but abandoned when we discovered the data table can't render Apex-defined rows. Users see raw CMDT columns instead of computed date-window previews; the Date_Rule__c value is shown as a "Date Window" column (Sep–Nov, Full-window, etc.). Concrete dates are still computed at build time.
- **No `Preview` companion class.** Preview was only needed to compute display dates for the wrapper class — moot now.
- **`FQS_Campaign_Hierarchy_Setup__mdt` deleted.** Audit CMDT and audit-write step removed from Apex. First-run-only setup doesn't need an audit trail; if Deep Clone ships later it can key off the created Campaigns directly.
- **`FQS_CampaignHierarchyBuilder.build()` signature changed.** Now takes `model`, `selectedRollupKeys`, `selectedStrategyKeys`, `selectedAskKeys` (three `List<String>` of template keys) instead of the old `model` + `createAsks` pair.
- **`oct-plus-apr` date rule bug fixed.** Previously produced an invalid window (end before start) when parent's start and end years matched (calendar-year orgs); now shifts end year forward when the two years collide.
- **Tests rewritten** to match the new signature: 11 tests covering all-defaults per model, no-asks, program subsets, no-rollups error, duplicate-rollup error, orphaned-ask silent drop, category mapping, mirrors-parent dates, and template-library sanity checks. All pass.

---

# FQS Campaign Hierarchy Setup — Execution Plan (v2)

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst` (Nonprofit Cloud — Fundraising)
**Flow type:** **Screen Subflow** — invoked from a parent `FQS_Setup_Flow` alongside other setup steps (Donor Grouping, Gift Acknowledgement, etc.). The subflow is *authored* to be self-contained (its Screen 0 handles null parent inputs, its Screen 4 has its own success state) so a future standalone launch surface is a zero-code addition — but that surface is **not shipped in v1**. The only launch path in v1 is through the parent setup flow.
**Outreach Source Codes:** not created by this flow in v1 — see "OSC as an advanced expansion" below.
**Deep Clone:** referenced conceptually but **not shipped in v1**. "Next year" is documented as a manual workflow for now.

---

## What changed from v1

| v1 | v2 |
|---|---|
| Re-run reads CMDT, replays the same model to add another top-level (year cohort, program cohort, etc.) | **Re-run functionality removed.** First-run only. Adding a subsequent year (or any variation) uses **Deep Clone** on an existing parent Campaign instead — a separate button/flow surface, not this setup subflow. |
| CMDT stores `Chosen_Model__c` + `Last_Top_Level_Id__c` + `Last_Ask_Creation_Choice__c` so re-runs can pre-fill | CMDT still stores model + last-created rollup Id **only as a record of what was built** (useful for support, for Deep Clone target selection, and for tests). No pre-fill logic. |
| Standalone flow, launched from FlexiPage | **Subflow** — designed for use inside a parent `FQS_Setup_Flow` that orchestrates all FQS setup steps in one guided walkthrough. Authored to also run standalone (Screen 0 handles null parent inputs), but no standalone launch surface (FlexiPage tile, App Launcher entry, URL button) ships in v1 — that's a follow-on when someone asks for it. |
| Suggested campaigns hard-coded in Apex per model | **Suggested campaigns are CMDT records** — `FQS_Campaign_Template__mdt` — one row per template. A single `Applicable_Models__c` multi-select picklist declares which model(s) each template applies to. The three model row-sets are assembled at flow-load time by filtering the CMDT once; no per-model duplication. |
| Test #13, #18, #19 covered re-run pre-fill and append behavior | Those tests are removed. New tests cover Deep Clone behavior and CMDT-driven template loading. |

---

## What is a Campaign in FQS? (framing for the flow's intro copy)

Before an admin picks a hierarchy, they need to understand what a campaign actually represents. This section is the source-of-truth wording that Screen 1's intro rich-text block quotes verbatim.

**A campaign is a way to organize and track a concrete ask made to donors.** Most asks are letters, mailings, or emails — but the model also covers grant proposals, donor meetings, and event attendance. Each ask gets its own campaign at level 3.

**The three levels serve different purposes:**

| Level | What it is | Primary job |
|---|---|---|
| **3 — The ask** | One concrete ask sent to one defined audience. In v1 of this flow, each level-3 campaign represents exactly **one ask** — a 1:1 relationship between the campaign record and the ask that went out. | Track response for that single ask: how many were solicited, how many responded, what was raised. |
| **2 — The strategy** | A coordinated set of asks working toward one goal (e.g. `Spring Appeal FY26` bundles the email drop, direct-mail piece, and follow-up reminder into one push). | **Track performance of a strategy in-flight.** Effective fundraising layers reinforcing asks; the strategy's real result is the mid-level total. This is the level most staff watch while a campaign is running. |
| **1 — The rollup** | The organizing anchor (year, or program, depending on model). | Provide the reporting anchor: either "how did FY26 do overall?" or "how has Major Gifts trended?" — depending on which model you chose. |

**Why level 2 is the most critical:** donors rarely respond to the first touch. Mid-tier totals answer *"is this strategy working?"* while there's still time to adjust.

---

## OSC as an advanced expansion (post-build, not in this flow's config)

**In v1, level 3 is a 1:1 relationship** — one campaign record per ask. Outreach Source Codes exist for the more advanced case: when a single ask fans out into multiple audience × channel variants that all belong to the same strategy but need distinct tracking. Screen 4 surfaces OSCs as a "ready to track more nuance?" post-build note, no creation UX inside this flow.

---

## "Next year" — how re-run is replaced (Deep Clone is future work)

**Motivation:** admins will eventually ask for "add another year cohort" and "spin up next year's campaigns in the same shape." Rather than overloading this setup flow with a re-run mode, the v2 design assumes a future **Deep Clone** capability that operates on any existing Campaign subtree. Deep Clone is **not shipped in v1** — it's called out here so the setup subflow's design doesn't accidentally take on re-run logic that Deep Clone will later obsolete.

**Why re-run isn't the right shape:**

- Re-run couples "add next year" to a flow that only knows about setup-flow-created trees. Admins who built their hierarchy manually get nothing.
- Re-run forces the setup flow to reason about append/reuse semantics per model. That's complexity for a workflow that runs once.

**What the setup subflow does today (v1):**

- Runs first-time-only. No re-run, no pre-fill, no append.
- Records what it built in a CMDT audit row (`FQS_Campaign_Hierarchy_Setup.Default`) — useful for support and as an anchor when Deep Clone ships.
- Screen 4 tells the admin "next year, clone this Campaign" with a link to the newly created top-level. Until Deep Clone ships, "clone" means Salesforce's built-in Campaign clone (which only copies one level) plus manual re-creation of children — an accepted limitation for v1.

---

## User-confirmed design decisions (v2)

1. **Flexible depth.** Rollup (level 1) required. Strategies (level 2) and asks (level 3) both optional per branch.
2. **Do not modify `FQS_Campaign_Category__c`.** Leave the existing picklist alone. Category is applied by mapping table (below), never re-authored.
3. **Model choice is recorded but not sticky.** After a successful run the flow writes a CMDT row with the chosen model + created top-level Id + skip-asks choice, for audit/support/Deep Clone discovery. **No re-run pre-fill.** Every run of this flow starts at Screen 1.
4. **No OSC creation in v1.** Level-3 campaigns are 1:1 with the ask. OSCs are educated-only on Screen 4.
5. **Year basis auto-detected from `Organization.FiscalYearStartMonth`.** Same rules as v1 — `1` → Calendar (`CY{yy}`), else Fiscal (`FY{yy}` where `yy` = ending calendar year).
6. **Always build the full current year window, even when run mid-year.** Same rule as v1: anchor to the year window that contains `{!$Flow.CurrentDate}`, backfill past-dated rows.
7. **Foundation Giving is a first-class branch in every model.** Represented as a template row with `Applicable_Models__c` = all three.
8. **Skipping level 3 asks entirely is a first-class option.** Screen 2 opens with a **`Create level-3 asks?`** toggle at the top of the ask section, defaulted **on**. Off → the ask section collapses, and the Apex action skips step 3 (ask insert) entirely.
9. **Subflow-first design.** The flow is authored as a callable subflow. `FQS_Setup_Flow` invokes it via a Subflow element; each setup subflow (Donor Grouping, Campaign Hierarchy, Gift Acknowledgement config, etc.) has its own screens and own success state, but they run as a single interview when launched from the Setup FlexiPage. Standalone launch (direct URL, App Launcher) also works — the subflow's Screen 0 detects whether it was called from a parent and skips its own intro if so.
10. **Suggested campaigns live in CMDT, not Apex.** New CMDT `FQS_Campaign_Template__mdt` holds every template row. `Applicable_Models__c` (Multi-Select Picklist: Seasonal, GivingPrograms, Strategy) declares which model(s) the template belongs to. The flow reads all rows once at Screen 0 (or the parent Setup Flow reads once and passes down), filters by chosen model, and populates Screen 2's Data Tables from that filtered set. **Adding a new suggested campaign is a metadata deploy, not an Apex change.**

---

## The three organizing models (unchanged from v1)

Each option is presented on Screen 1 with a **why**, a **best-fit signal**, and a **bulleted example**. Examples assume the flow has detected FY basis (Jul 1 start). If the org's FY starts January, every window collapses to CY and the top-level suffix becomes `CY{yy}`.

### The core trade-off: Seasonal vs Giving Programs

| Model | Level 1 (top) | Level 2 (mid) | One-filter report | Harder report |
|---|---|---|---|---|
| **Seasonal / Yearly** | Year (`FY26 Fundraising`) | Program/appeal | Year totals & YoY | Program lifetime (aggregate across years) |
| **Giving Programs** | Program (`Major Gifts`, evergreen) | Year cohort (`FY26`) | Program lifetime & per-program trending | Whole-org yearly (aggregate across programs) |
| **Strategy** | Year (`FY26 Donor Strategy`) | Donor segment | Donor-journey performance | Program lifetime (like Seasonal) |

Same data, different default rollup. Pick based on which report you run most often.

### 1. Seasonal / Yearly
- **Why:** Year sits at the top of the tree, so every campaign automatically rolls up into a single year total. Year-over-year comparisons are one filter away.
- **Best fit:** Calendar drives your fundraising. Board and finance reporting cares about "this year vs last year."
- **Example (3-level, FY basis, Jul 1 FY start, current date in FY26):**
  - `FY26 Fundraising` *(rollup — 2025-07-01 → 2026-06-30)*
    - `Spring Appeal FY26` *(strategy — 2026-03-01 → 2026-05-31)*
      - `Spring Appeal – Email` *(ask — mirrors strategy dates)*
      - `Spring Appeal – Direct Mail` *(ask — mirrors strategy dates)*
    - `Annual Celebration FY26` *(strategy — 2025-09-01 → 2025-11-30)*
      - `Annual Celebration – Save-the-Date Email` *(ask — Jul–Aug 2025)*
      - `Annual Celebration – Invitation + RSVP` *(ask — mirrors strategy)*
      - `Annual Celebration – Sponsorship Packet` *(ask — mirrors strategy)*
    - `Year-End Push FY26` *(strategy — 2025-11-01 → 2025-12-31)*
      - `Year-End – Giving Tuesday Email` *(ask — Dec 2 2025 send)*
      - `Year-End – December Reminder SMS` *(ask — Dec 28–31 2025)*
    - `Monthly Sustainer Drive FY26` *(strategy — 2025-07-01 → 2026-06-30, always-on)*
      - `Sustainer Recruitment – Landing Page` *(ask — mirrors strategy)*
    - `Foundation Giving FY26` *(strategy — mirrors rollup; grants land any time)*
      - `Community Foundation Proposal FY26` *(ask — Aug–Oct 2025)*
      - `Corporate Foundation Proposal FY26` *(ask — Jan–Mar 2026)*
- **Next-year workflow:** Deep Clone this rollup with a `FY26 → FY27` name transform and `+12 months` date shift.

### 2. Giving Programs
- **Why:** Each program is its own **evergreen top-level** with year cohorts as level-2 children. Program lifetime is one filter away.
- **Best fit:** Program areas are staffed separately; each program lead wants their own long-running dashboard.
- **Shape:** the flow creates **multiple top-level Campaigns in one run** — one per program — each with an FY26 year-cohort strategy underneath.
- **Example (3-level, FY basis, current date in FY26):**
  - `Major Gifts` *(rollup — evergreen; StartDate = FY26 start, EndDate blank/far-future)*
    - `FY26` *(strategy — 2025-07-01 → 2026-06-30, year cohort)*
      - `Portfolio Solicitations` *(ask — mirrors strategy)*
      - `Prospect Discovery Visits` *(ask — Jul–Dec 2025)*
  - `Planned Giving` *(rollup — evergreen)*
    - `FY26` *(strategy — year cohort)*
      - `Legacy Circle Outreach` *(ask — mirrors strategy)*
      - `Estate Planning Webinar Invitation` *(ask — Sep–Oct 2025)*
  - `Online Giving` *(rollup — evergreen)*
    - `FY26` *(strategy — year cohort)*
      - `Monthly Sustainer Recruitment` *(ask — mirrors strategy)*
      - `Peer-to-Peer Fundraising Drive` *(ask — Apr–May 2026)*
  - `Events` *(rollup — evergreen)*
    - `FY26` *(strategy — year cohort)*
      - `Annual Celebration` *(ask — 2025-09-01 → 2025-11-30, event-window)*
      - `Donor Appreciation Reception` *(ask — 2026-05-01 → 2026-06-30)*
      - `Community Open House` *(ask — Feb 2026)*
  - `Foundation Giving` *(rollup — evergreen)*
    - `FY26` *(strategy — year cohort)*
      - `Community Foundation Proposal FY26` *(ask — Aug–Oct 2025)*
      - `Corporate Foundation Proposal FY26` *(ask — Jan–Mar 2026)*
      - `Family Foundation Proposals FY26` *(ask — rolling)*
- **Next-year workflow:** Deep Clone each program's FY26 year-cohort strategy (not the program top-level) to produce `FY27` siblings.

### 3. Strategy
- **Why:** Anchor to *who* you're targeting. Makes donor-journey performance the primary reporting lens.
- **Best fit:** Development team plans by audience segment.
- **Example (3-level, FY basis, current date in FY26):**
  - `FY26 Donor Strategy` *(rollup — 2025-07-01 → 2026-06-30)*
    - `Lapsed Donor Reactivation` *(strategy)*
      - `Lapsed – Winback Postcard` *(ask — 2025-07-01 → 2025-09-30)*
      - `Lapsed – Personal Phone Call` *(ask — Oct–Dec 2025)*
      - `Lapsed – Last-Chance Email` *(ask — Jun 2026)*
    - `New Donor Acquisition` *(strategy)*
      - `New Donor – Digital Ads` *(ask — full year)*
      - `New Donor – Welcome Series Email` *(ask — evergreen)*
      - `New Donor – Peer Referral Drive` *(ask — Jan–Mar 2026)*
    - `Retention & Stewardship` *(strategy)*
      - `Second-Gift Follow-Up` *(ask — evergreen)*
      - `Impact Report Mailing` *(ask — Sep–Oct 2025)*
      - `Recurring Donor Anniversary Notes` *(ask — evergreen)*
    - `Mid-Level Donor Cultivation` *(strategy)*
      - `Mid-Level – Personal Update Letter` *(ask — Oct 2025 and Apr 2026)*
      - `Mid-Level – Program Site Visit Invitations` *(ask — mirrors strategy)*
    - `Foundation Giving` *(strategy)*
      - `Community Foundation Proposal FY26` *(ask — Aug–Oct 2025)*
      - `Corporate Foundation Proposal FY26` *(ask — Jan–Mar 2026)*
- **Next-year workflow:** Deep Clone this rollup with a `FY26 → FY27` name transform.

---

## Suggested campaigns as Custom Metadata (`FQS_Campaign_Template__mdt`)

The library of pre-seeded rows is now a CMDT. **One record per template.** A single record supports all three models via `Applicable_Models__c` — no per-model duplication.

### CMDT fields

| Field | Type | Notes |
|---|---|---|
| `MasterLabel` | Standard | Human-readable name — e.g. `Spring Appeal – Email` |
| `DeveloperName` | Standard | Stable key — e.g. `sol_spring_email` (underscore-safe version of the template key) |
| `Template_Key__c` | Text(80) | Kebab-case slug matching v1's template keys (`sol-spring-email`) — used in Apex for logging/deep clone lookup |
| `Suggested_Name__c` | Text(120) | The default `Campaign.Name` for this row. Template placeholders `{yearLabel}` and `{yearShort}` are expanded at load time (e.g. `Spring Appeal {yearLabel}` → `Spring Appeal FY26`). |
| `Level__c` | Picklist(Strategy, Ask) | Which tier this template applies to |
| `Applicable_Models__c` | Multi-Select Picklist (Seasonal, GivingPrograms, Strategy) | Which model row-sets include this template |
| `Function_Group__c` | Picklist(Acquisition, Retention, Solicitation, Foundation, PlannedGiving, Events, Advocacy) | Groups rows in the "+ Add from library" picker |
| `Date_Rule__c` | Picklist(full-window, q1, q2, q3, q4, mar-may, sep-nov, nov-dec, may-jun, aug-oct, jan-mar, jul-aug, dec-2-send, dec-28-31, oct-plus-apr, feb, mirrors-parent, evergreen) | Token consumed by Apex to compute concrete `StartDate`/`EndDate` from the year window |
| `Default_In_Model__c` | Multi-Select Picklist (Seasonal, GivingPrograms, Strategy) | Subset of `Applicable_Models__c` — models where this template is a **pre-seeded default row** (visible in Screen 2 without library picker). Templates in `Applicable_Models__c` but not `Default_In_Model__c` show up only in the "+ Add from library" picker. |
| `Parent_Template_Key__c` | Text(80) | For asks: the `Template_Key__c` of the strategy this ask lives under (e.g. `sol_spring_email` → parent `str_spring_appeal`). For strategies: blank in Seasonal/Strategy models (parent is the run's rollup); for Giving Programs, the program name (`Major Gifts`, `Events`, `Foundation Giving`) so ask rows attach to the right program's year cohort. |
| `Sort_Order__c` | Number(3,0) | Display order within a section |
| `Notes__c` | Long Text (optional) | Author notes; not surfaced in UI |

### How model row-sets are assembled

At Screen 0 (or in the parent Setup Flow), one Get Records:

```
SELECT ... FROM FQS_Campaign_Template__mdt
WHERE Applicable_Models__c INCLUDES (:varModel)
ORDER BY Sort_Order__c
```

Then two flow-side collection filters:

- **`varDefaultTemplates`** — subset where `Default_In_Model__c INCLUDES varModel`. Pre-seeds the Data Tables on Screen 2.
- **`varLibraryTemplates`** — the complement. Fuels the "+ Add from library" picker.

Because `Applicable_Models__c` and `Default_In_Model__c` are multi-select, **one CMDT record can be a default in Seasonal and a library option in Strategy** — exactly the behavior the v1 hard-coded row lists had, with none of the duplication.

### Strategy templates (mid-tier)

| Template Key | Suggested Name | Date Rule | Applicable Models | Default In | Parent |
|---|---|---|---|---|---|
| `str_spring_appeal` | `Spring Appeal {yearLabel}` | mar-may | Seasonal | Seasonal | — |
| `str_annual_celebration` | `Annual Celebration {yearLabel}` | sep-nov | Seasonal | Seasonal | — |
| `str_year_end_push` | `Year-End Push {yearLabel}` | nov-dec | Seasonal | Seasonal | — |
| `str_monthly_sustainer` | `Monthly Sustainer Drive {yearLabel}` | full-window | Seasonal | Seasonal | — |
| `str_foundation_giving` | `Foundation Giving {yearLabel}` | full-window | Seasonal, Strategy | Seasonal, Strategy | — |
| `str_lapsed_reactivation` | `Lapsed Donor Reactivation` | full-window | Strategy | Strategy | — |
| `str_new_donor_acquisition` | `New Donor Acquisition` | full-window | Strategy | Strategy | — |
| `str_retention_stewardship` | `Retention & Stewardship` | full-window | Strategy | Strategy | — |
| `str_mid_level_cultivation` | `Mid-Level Donor Cultivation` | full-window | Strategy | Strategy | — |
| `str_year_cohort` | `{yearLabel}` | full-window | GivingPrograms | GivingPrograms | — |

*Note:* Giving Programs uses the single `str_year_cohort` template attached to every program top-level. Program top-levels themselves are represented by their own template rows (below) and are not "strategies."

### Program-top-level templates (Giving Programs model only, `Level__c = Rollup`)

Extend `Level__c` picklist to `Rollup | Strategy | Ask` to support this. Program top-levels are `Applicable_Models__c = GivingPrograms`.

| Template Key | Suggested Name | Category (auto-mapped) |
|---|---|---|
| `prg_major_gifts` | `Major Gifts` | Major Gifts |
| `prg_planned_giving` | `Planned Giving` | Planned Giving |
| `prg_online_giving` | `Online Giving` | Annual Giving |
| `prg_events` | `Events` | Events |
| `prg_foundation_giving` | `Foundation Giving` | Grants |
| `prg_annual_giving` | `Annual Giving` | Annual Giving |

### Ask templates (level 3, `Level__c = Ask`)

Full library — a subset that lists which strategies/programs each ask hangs off. `Parent_Template_Key__c` links asks to their parent strategy (Seasonal/Strategy models) or program (Giving Programs model).

**Acquisition asks:**

| Template Key | Suggested Name | Date Rule | Applicable Models | Default In | Parent Key (per model) |
|---|---|---|---|---|---|
| `acq_digital_ads` | `New Donor – Digital Ads` | full-window | Strategy | Strategy | `str_new_donor_acquisition` |
| `acq_welcome_series` | `New Donor – Welcome Series Email` | evergreen | Strategy | — | `str_new_donor_acquisition` |
| `acq_peer_referral` | `New Donor – Peer Referral Drive` | jan-mar | Strategy | Strategy | `str_new_donor_acquisition` |
| `acq_p2p_drive` | `Peer-to-Peer Fundraising Drive` | mar-may | GivingPrograms | GivingPrograms | `prg_online_giving` |
| `acq_open_house` | `Community Open House` | feb | GivingPrograms | — | `prg_events` |

**Retention asks:**

| Template Key | Suggested Name | Date Rule | Applicable Models | Default In | Parent Key |
|---|---|---|---|---|---|
| `ret_second_gift` | `Second-Gift Follow-Up` | evergreen | Strategy | Strategy | `str_retention_stewardship` |
| `ret_impact_report` | `Impact Report Mailing` | sep-nov | Strategy | Strategy | `str_retention_stewardship` |
| `ret_anniversary_notes` | `Recurring Donor Anniversary Notes` | evergreen | Strategy | — | `str_retention_stewardship` |
| `ret_lapsed_winback` | `Lapsed – Winback Postcard` | q1 | Strategy | Strategy | `str_lapsed_reactivation` |
| `ret_lapsed_phone` | `Lapsed – Personal Phone Call` | q2 | Strategy | Strategy | `str_lapsed_reactivation` |
| `ret_lapsed_last_chance` | `Lapsed – Last-Chance Email` | may-jun | Strategy | Strategy | `str_lapsed_reactivation` |

**Solicitation asks:**

| Template Key | Suggested Name | Date Rule | Applicable Models | Default In | Parent Key |
|---|---|---|---|---|---|
| `sol_spring_email` | `Spring Appeal – Email` | mar-may | Seasonal | Seasonal | `str_spring_appeal` |
| `sol_spring_dm` | `Spring Appeal – Direct Mail` | mar-may | Seasonal | Seasonal | `str_spring_appeal` |
| `sol_giving_tuesday` | `Year-End – Giving Tuesday Email` | dec-2-send | Seasonal | Seasonal | `str_year_end_push` |
| `sol_dec_reminder_sms` | `Year-End – December Reminder SMS` | dec-28-31 | Seasonal | Seasonal | `str_year_end_push` |
| `sol_yearend_dm` | `Year-End – Direct Mail Appeal` | nov-dec | Seasonal | — | `str_year_end_push` |
| `sol_mid_level_letter` | `Mid-Level – Personal Update Letter` | oct-plus-apr | Strategy | Strategy | `str_mid_level_cultivation` |
| `sol_mid_level_site_visit` | `Mid-Level – Program Site Visit Invitations` | mirrors-parent | Strategy | Strategy | `str_mid_level_cultivation` |
| `sol_portfolio_solicitation` | `Portfolio Solicitations` | mirrors-parent | GivingPrograms | GivingPrograms | `prg_major_gifts` |
| `sol_discovery_visits` | `Prospect Discovery Visits` | jul-dec | GivingPrograms | GivingPrograms | `prg_major_gifts` |
| `sol_monthly_sustainer_lp` | `Sustainer Recruitment – Landing Page` | mirrors-parent | Seasonal, GivingPrograms | Seasonal, GivingPrograms | Seasonal: `str_monthly_sustainer`; GP: `prg_online_giving` |
| `sol_sustainer_recruitment` | `Monthly Sustainer Recruitment` | mirrors-parent | GivingPrograms | GivingPrograms | `prg_online_giving` |

**Foundation asks:**

| Template Key | Suggested Name | Date Rule | Applicable Models | Default In | Parent Key (per model) |
|---|---|---|---|---|---|
| `fnd_community_proposal` | `Community Foundation Proposal {yearLabel}` | aug-oct | Seasonal, GivingPrograms, Strategy | Seasonal, GivingPrograms, Strategy | Seasonal: `str_foundation_giving`; GP: `prg_foundation_giving`; Strategy: `str_foundation_giving` |
| `fnd_corporate_proposal` | `Corporate Foundation Proposal {yearLabel}` | jan-mar | Seasonal, GivingPrograms, Strategy | Seasonal, GivingPrograms, Strategy | Same three parents as above |
| `fnd_family_proposals` | `Family Foundation Proposals {yearLabel}` | full-window | GivingPrograms | GivingPrograms | `prg_foundation_giving` |
| `fnd_daf_outreach` | `Donor-Advised Fund Outreach` | oct-dec | GivingPrograms | — | `prg_foundation_giving` |
| `fnd_corporate_sponsorship` | `Corporate Sponsorship Solicitations` | jul-aug | GivingPrograms | — | `prg_foundation_giving` |

**Planned Giving asks:**

| Template Key | Suggested Name | Date Rule | Applicable Models | Default In | Parent Key |
|---|---|---|---|---|---|
| `pg_legacy_outreach` | `Legacy Circle Outreach` | mirrors-parent | GivingPrograms | GivingPrograms | `prg_planned_giving` |
| `pg_estate_webinar` | `Estate Planning Webinar Invitation` | sep-nov | GivingPrograms | GivingPrograms | `prg_planned_giving` |
| `pg_bequest_society` | `Bequest Society Recognition Notes` | may-jun | GivingPrograms | — | `prg_planned_giving` |

**Events asks:**

| Template Key | Suggested Name | Date Rule | Applicable Models | Default In | Parent Key (per model) |
|---|---|---|---|---|---|
| `evt_celebration_savedate` | `Annual Celebration – Save-the-Date Email` | jul-aug | Seasonal | Seasonal | `str_annual_celebration` |
| `evt_celebration_invite` | `Annual Celebration – Invitation + RSVP` | sep-nov | Seasonal, GivingPrograms | Seasonal | Seasonal: `str_annual_celebration`; GP: `prg_events` (as ask "Annual Celebration") |
| `evt_celebration_sponsor` | `Annual Celebration – Sponsorship Packet` | sep-nov | Seasonal | Seasonal | `str_annual_celebration` |
| `evt_donor_reception` | `Donor Appreciation Reception` | may-jun | GivingPrograms | GivingPrograms | `prg_events` |
| `evt_open_house` | `Community Open House` | feb | GivingPrograms | GivingPrograms | `prg_events` |

**Advocacy asks (library-only across models):**

| Template Key | Suggested Name | Date Rule | Applicable Models | Default In | Parent Key |
|---|---|---|---|---|---|
| `adv_newsletter_signup` | `Newsletter Signup Drive` | evergreen | Seasonal, GivingPrograms, Strategy | — | (context-dependent — picker prompts) |
| `adv_volunteer_recruit` | `Volunteer Recruitment` | full-window | Seasonal, GivingPrograms, Strategy | — | (context-dependent) |
| `adv_petition` | `Advocacy Petition` | mirrors-parent | Seasonal, GivingPrograms, Strategy | — | (context-dependent) |

For rows where `Parent_Template_Key__c` is "context-dependent," the library picker on Screen 2 asks the admin to pick a parent strategy from the tree at add-time (small dropdown next to the row).

### Placeholder expansion

Two placeholders in `Suggested_Name__c` are expanded when templates load into Screen 2's tables:

- `{yearLabel}` → `varYearLabel` (e.g. `FY26`, `CY26`)
- `{yearShort}` → `varYearShort` (e.g. `26`)

Expansion is done in-flow via a Formula element or in Apex; either is fine because the CMDT is read once per interview.

### Date-rule → date window mapping

Applied in Apex before insert:

| Date Rule | Start | End |
|---|---|---|
| `full-window` | `topStart` | `topEnd` |
| `q1` | `topStart` | `topStart + 3 months - 1 day` |
| `q2` | `topStart + 3 months` | `topStart + 6 months - 1 day` |
| `q3` | `topStart + 6 months` | `topStart + 9 months - 1 day` |
| `q4` | `topStart + 9 months` | `topEnd` |
| `mar-may` | Mar 1 of ending year | May 31 of ending year |
| `sep-nov` | Sep 1 of starting year | Nov 30 of starting year |
| `nov-dec` | Nov 1 of starting year | Dec 31 of starting year |
| `may-jun` | May 1 of ending year | Jun 30 of ending year |
| `aug-oct` | Aug 1 of starting year | Oct 31 of starting year |
| `jan-mar` | Jan 1 of ending year | Mar 31 of ending year |
| `jul-aug` | Jul 1 of starting year | Aug 31 of starting year |
| `dec-2-send` | Dec 2 of starting year | Dec 2 of starting year |
| `dec-28-31` | Dec 28 of starting year | Dec 31 of starting year |
| `oct-plus-apr` | Oct 1 of starting year | Apr 30 of ending year (two-window strategy — treat as single spanning campaign; admin can split into two rows manually if desired) |
| `feb` | Feb 1 of ending year | Feb 28/29 of ending year |
| `mirrors-parent` | Parent strategy's `StartDate` | Parent strategy's `EndDate` |
| `evergreen` | `topStart` | null |
| `oct-dec` | Oct 1 of starting year | Dec 31 of starting year |
| `jul-dec` | Jul 1 of starting year | Dec 31 of starting year |

"Starting year" = calendar year of `topStart`; "ending year" = calendar year of `topEnd`. For calendar-year orgs the two are the same, and rules like `sep-nov` collapse to Sep–Nov of the current calendar year.

---

## FQS_Campaign_Category__c mapping (unchanged from v1, applied in Apex)

| Model | Level | Suggested category |
|---|---|---|
| Seasonal | Top-level (year rollup) | `Fundraising Top Level Campaign` |
| Seasonal | Strategy named "Foundation Giving…" | `Grants` |
| Seasonal | Strategy or ask under "Annual Celebration"/"Donor Appreciation"/"…Reception"/"…Open House" | `Events` |
| Seasonal | Other Strategy / Ask | Blank |
| Giving Programs | Top-level = "Major Gifts" | `Major Gifts` |
| Giving Programs | Top-level = "Planned Giving" | `Planned Giving` |
| Giving Programs | Top-level = "Events" | `Events` |
| Giving Programs | Top-level = "Annual Giving" or contains "Online" | `Annual Giving` |
| Giving Programs | Top-level = "Corporate Match" | `Corporate Match` |
| Giving Programs | Top-level = "In-Kind" | `In-Kind` |
| Giving Programs | Top-level = "Foundation Giving" | `Grants` |
| Giving Programs | Year-cohort strategy | Blank |
| Strategy | Top-level (year rollup) | `Fundraising Top Level Campaign` |
| Strategy | Strategy named "Foundation Giving" | `Grants` |
| Strategy | Other Strategy / Ask | Blank |

---

## Subflow structure

### Subflow inputs (from parent `FQS_Setup_Flow` if orchestrated; defaulted otherwise)

- `inLaunchedFromSetupFlow` (Boolean, default false) — when true, the subflow skips its own intro screen because the parent already framed the walkthrough.
- `inFiscalYearStartMonth` (Integer, optional) — if parent already read `Organization`, pass it down to avoid a duplicate query. If null, the subflow reads it itself.
- `inAllTemplates` (Record Collection, optional) — if parent already read `FQS_Campaign_Template__mdt`, pass it down. If null, the subflow reads it itself. This makes the subflow self-contained but efficient inside an orchestrated walkthrough.

### Subflow outputs

- `outCreatedModel` (Text) — the model the admin chose (`Seasonal` | `GivingPrograms` | `Strategy`)
- `outCreatedTopLevelIds` (Text Collection) — Ids of the created top-level Campaigns (one for Seasonal/Strategy, N for Giving Programs)
- `outCreatedRollupCount`, `outCreatedStrategyCount`, `outCreatedAskCount` (Integer)
- `outSkippedAsks` (Boolean)

### Screen 0 — Boot (invisible)

1. If `inFiscalYearStartMonth` is null → Get Records `Organization` (single row, `SELECT FiscalYearStartMonth`).
2. If `inAllTemplates` is null → Get Records `FQS_Campaign_Template__mdt` (all rows, sorted by `Sort_Order__c`).
3. Compute `varYearBasis`, `varYearStart`, `varYearEnd`, `varYearLabel`, `varYearShort` from `FiscalYearStartMonth` + `{!$Flow.CurrentDate}` (same rules as v1).
4. **No CMDT pre-fill** — every run enters Screen 1.

### Screen 1 — Choose model
- Rich-text intro block — expandable "What is a campaign?" that quotes the framing section verbatim. When `inLaunchedFromSetupFlow = true`, this block is collapsed by default (parent flow already introduced the walkthrough); otherwise expanded on first render.
- Detected-settings note: `We detected your org uses {!varYearBasis} Year (starts {!fiscalStartMonthName} 1). Date defaults will use this.`
- Sub-heading: **"Pick how you want to organize your campaigns."**
- Radio: `Seasonal / Yearly`, `Giving Programs`, `Strategy`.
- Reactive preview panel below the radio: why + best-fit + example, with example dates computed live from `varYearStart` / `varYearEnd`.
- Callout: **"You'll do most of your ongoing tracking at level 2 — that's where reinforcing asks bundle into one strategy total."**
- Second callout: **"Not ready to name individual asks yet? Screen 2 lets you skip level 3 entirely."**
- Next → Screen 2.

### Screen 2 — Configure the tree

Same layout logic as v1 (Seasonal/Strategy: one top-level, N strategies, optional asks; Giving Programs: N program top-levels, one FY-cohort strategy each, optional asks). The change is in **row population**:

- On Screen 1's Next → the flow filters `varAllTemplates` by the chosen model:
  - `varDefaultStrategies` = `Level__c = Strategy` AND `Default_In_Model__c INCLUDES varModel`
  - `varDefaultAsks` = `Level__c = Ask` AND `Default_In_Model__c INCLUDES varModel`
  - `varLibraryStrategies` = `Level__c = Strategy` AND `Applicable_Models__c INCLUDES varModel` AND NOT `Default_In_Model__c INCLUDES varModel`
  - `varLibraryAsks` = same pattern for `Level__c = Ask`
  - Giving Programs also filters `varDefaultPrograms` where `Level__c = Rollup` AND `Default_In_Model__c INCLUDES 'GivingPrograms'`
- For each default row, Apex-side (or Formula) expansion converts `Suggested_Name__c` placeholders and evaluates `Date_Rule__c` into concrete dates using the year window.
- Data Tables render pre-seeded from `varDefaultStrategies` / `varDefaultAsks`. "+ Add from library" picker draws from `varLibraryStrategies` / `varLibraryAsks`, filtered further by ask parent when the picker is opened under a specific strategy.
- `Create level-3 asks?` toggle at top of the ask section, defaulted `Yes`. Off → ask section collapses; ask insertion is skipped downstream.
- Past-dated rows carry a "Past — backfill" badge (formula column).

Next → Screen 3.

### Screen 3 — Confirm & build
- Read-only nested-bullet preview of the tree with level labels.
- Buttons: `Back`, `Build hierarchy`.
- Runs the Apex action.

### Apex action — `FQS_CampaignHierarchyBuilder.build(...)`

- **Inputs:**
  - `model` (String) — `Seasonal` | `GivingPrograms` | `Strategy`
  - `createAsks` (Boolean) — from Screen 2 toggle
  - `topLevels` (List<TopLevelWrapper>) — for Seasonal/Strategy: one entry. For GivingPrograms: N entries (one per program, each carrying its `Template_Key__c` for category mapping).
  - `strategies` (List<StrategyWrapper>) — each carries `ParentTemplateKey` (for GivingPrograms: which program) or `ParentIndex` (for Seasonal/Strategy: always 0).
  - `asks` (List<AskWrapper>) — each carries `ParentStrategyIndex` linking to the strategies list. Ignored when `createAsks = false`.

- **Steps:**
  1. **Resolve top-levels (rollup layer):**
     - Seasonal / Strategy: single insert with `RecordTypeId = FQS_Fundraising`, `FQS_Campaign_Category__c = 'Fundraising Top Level Campaign'`.
     - Giving Programs: for each entry, insert with category derived from `Template_Key__c` (`prg_major_gifts` → `Major Gifts`, etc.). **v2 change:** no reuse-by-name — the setup flow is first-run-only. If a program top-level with the same name already exists, the flow raises a friendly duplicate error asking the admin to rename or delete the pre-existing top-level.
  2. **Insert strategy Campaigns (level 2):** `ParentId` set from the resolved top-level. Apply category mapping.
  3. **Insert ask Campaigns (level 3) — only when `createAsks = true`:** `ParentId` from strategy Id. Apply category mapping. Each ask is 1:1 with its Campaign.
  4. **Persist audit record:** upsert the CMDT row (`FQS_Campaign_Hierarchy_Setup.Default`) via existing `FQS_CustomMetadataSaver` action, storing `Chosen_Model__c`, `Last_Top_Level_Id__c` (Seasonal/Strategy: the single rollup; GP: the first program in the list, plus a serialized JSON of all Ids in a text field for support/Deep Clone discovery), `Last_Ask_Creation_Choice__c`, and `Last_Run_At__c`.
  5. Return counts + Ids for the subflow's outputs.

### Screen 4 — Success
- **Confirmation block:** counts + link to the newly created top-level Campaign(s).
- **Asks-skipped panel** (only when `createAsks = false`): "You skipped level-3 asks — that's fine. When you're ready, add them manually or use Deep Clone."
- **Next-year panel:** *"When it's time to build **next** year's campaigns, don't re-run this flow — it's first-run only. For now, use Salesforce's built-in Campaign clone on the top-level you just created and rebuild the child strategies manually with next year's dates. A one-click deep-clone action is on the roadmap."*
- **OSC panel** (unchanged from v1): educational note + link to OSC list view.
- **Continue button:** when `inLaunchedFromSetupFlow = true`, the button reads `Continue Setup →` and Finish returns to the parent flow. When standalone, reads `Finish` and closes the flow.

---

## Parent Setup Flow — how the subflow fits

`FQS_Setup_Flow.flow-meta.xml` (existing, currently a stub) is expanded into an orchestrator screen flow:

- **Screen A — Welcome:** intro to FQS Setup with a table of the setup steps and per-step status (from CMDT audit records — each subflow's success writes its CMDT).
- **Pre-work:** one Get Records on `Organization` and one on `FQS_Campaign_Template__mdt`, both passed as inputs to each subflow that needs them. Avoids redundant queries when the admin runs the full walkthrough.
- **Screen B — Step selector:** which step to do (or `All`). Radio + Next.
- **Subflow — Campaign Hierarchy** (this plan): invoked with `inLaunchedFromSetupFlow = true`, `inFiscalYearStartMonth`, `inAllTemplates`.
- **Subflow — Donor Grouping Configurator** (existing plan, currently `FQS_Donor_Grouping_Configurator` — recently deleted per git status; needs its own re-plan or the delete confirmed).
- **Subflow — Gift Acknowledgement Config** (future — CMDT `FQS_Donor_Grouping__mdt.FQS_Auto_Acknowledgement__c` editor).
- **Screen C — All done:** summary of what was configured, links to each subflow's landing point.

Each subflow keeps its own Screen 4 (self-contained success state), and each returns its counts/Ids to the parent so the parent's Screen C can summarize. **Subflows never call each other directly** — only the parent orchestrates.

---

## New / modified metadata

| Kind | Name | Notes |
|---|---|---|
| Flow (new) | `FQS_Campaign_Hierarchy_Setup.flow-meta.xml` | Screen Subflow, API 66.0 |
| Flow (modify) | `FQS_Setup_Flow.flow-meta.xml` | Convert stub to orchestrator; add Subflow elements for each setup step |
| Apex class (new) | `FQS_CampaignHierarchyBuilder` | Invocable, `@InvocableMethod`; wrappers for TopLevel / Strategy / Ask |
| Apex test (new) | `FQS_CampaignHierarchyBuilderTest` | ≥85% coverage |
| CMDT (new) | `FQS_Campaign_Template__mdt` | Fields per the section above |
| CMDT records (new) | `FQS_Campaign_Template.*.md-meta.xml` | One record per template — ~35 rows total across strategies, program rollups, and asks. Shipped pre-populated in the repo. |
| CMDT (new) | `FQS_Campaign_Hierarchy_Setup__mdt` | Fields: `Chosen_Model__c` (picklist), `Last_Top_Level_Id__c` (Text 18), `All_Created_Top_Level_Ids_JSON__c` (Long Text — for GP multi-top-level runs), `Last_Ask_Creation_Choice__c` (Checkbox), `Last_Run_At__c` (DateTime) |
| CMDT record | `FQS_Campaign_Hierarchy_Setup.Default.md-meta.xml` | Written by flow on first success, not shipped pre-populated |
| FlexiPage (modify) | `FQS_Setup_Configuration.flexipage-meta.xml` | Already launches `FQS_Setup_Flow` — no change needed once parent flow is updated. **No standalone launch surface for the Campaign Hierarchy subflow ships in v1.** |
| Permission set (modify) | Existing FQS permset(s) | Add read access to `FQS_Campaign_Template__mdt` and `FQS_Campaign_Hierarchy_Setup__mdt`, and access to the new Apex class |

---

## Deep Clone — future work, not v1

Called out for design coherence (it's the natural "next year" path once it exists), but **not part of this deliverable**. When it's picked up, it'll be planned separately. The setup subflow's Screen 4 next-year panel is worded to reference the built-in Campaign clone today so it doesn't promise functionality that isn't shipped; when Deep Clone lands, that panel gets a one-line copy update.

---

## Open items / assumptions

- **Fiscal year source:** unchanged — `Organization.FiscalYearStartMonth`. Custom fiscal years supported at the 12-month-window level only.
- **Duplicate protection:** if a top-level Campaign already exists with the exact same name, insert errors — the flow catches and surfaces a friendly message that also mentions Deep Clone as the correct next-year path.
- **CMDT deploy order:** `FQS_Campaign_Template__mdt` (object + fields) must deploy before the ~35 template records. Standard SFDX deploy handles this automatically when the whole `force-app` tree is pushed together; call out for anyone doing partial deploys.
- **CMDT record count budget:** ~35 rows is well below any org limit. If the library grows past ~100, consider a `Retired__c` checkbox to hide old templates without deleting them.
- **Placeholder expansion:** `{yearLabel}` and `{yearShort}` are the only supported placeholders in v2. Rich substitution (e.g. `{orgName}`) is deferred.
- **Parent template key for context-dependent asks:** the three advocacy asks have no fixed parent; the library picker asks the admin to pick one at add-time. Design detail for the picker LWC — noted here but implemented in the picker's own spec.

---

## Test plan (Apex)

1. `test_SeasonalModel_3Levels` — 1 rollup + 5 strategies (incl. Foundation Giving) + 2 asks per strategy where applicable. Assert every ask has `ParentId` pointing at its strategy.
2. `test_StrategyModel_2Levels` — rollup + strategies only, no asks. Foundation Giving present as a strategy.
3. `test_GivingPrograms_CreatesAllTopLevels` — asserts N program rollups + N year-cohort strategies created; category mapping assigns Major Gifts → `Major Gifts`, Foundation Giving → `Grants`, etc.
4. `test_GivingPrograms_DuplicateTopLevelErrors` — pre-insert an evergreen `Major Gifts` Campaign; run flow with Major Gifts included; assert the friendly duplicate error is surfaced and no partial hierarchy is created (full rollback on error).
5. `test_GivingPrograms_MixedDepth` — Events year cohort has two asks with event-window dates; another program's year cohort has zero asks.
6. `test_CategoryMapping_FoundationGrantsPromoted` — Foundation Giving campaigns get category `Grants` in all three models.
7. `test_CategoryMapping_BlankWhereUnmapped` — `FQS_Campaign_Category__c` is blank for year-cohort strategies named `FY26` and for Strategy-model mids.
8. `test_YearBasis_FiscalJulyStart` — inject `FiscalYearStartMonth=7`, assert rollup window is Jul 1 → Jun 30 and label is `FY{yy}` where `yy` = ending calendar year.
9. `test_YearBasis_CalendarWhenStartMonthIsOne` — inject `FiscalYearStartMonth=1`, assert window is Jan 1 → Dec 31 and label is `CY{yy}`.
10. `test_MidYearRun_BackfillsFullYear_FiscalBasis` — inject `FiscalYearStartMonth=7` and simulate a run mid-FY26. Assert Annual Celebration strategy (Sep–Nov 2025) is created with past dates.
11. `test_MidYearRun_BackfillsFullYear_CalendarBasis` — inject `FiscalYearStartMonth=1` and simulate a mid-year run; assert Q1 strategies created with past Jan–Mar dates.
12. `test_MidYearRun_EarlyInYear_DoesNotSkipToNextYear` — inject `FiscalYearStartMonth=7` and simulate a run early in FY26; assert the flow anchors to FY26, not FY25 or FY27.
13. `test_NoOSCsCreated` — run the flow; query OutreachSourceCode; assert zero records inserted.
14. `test_SkipAsks_Seasonal` — `createAsks=false` with a populated asks list. Assert zero level-3 campaigns and CMDT audit records `Last_Ask_Creation_Choice__c = false`.
15. `test_SkipAsks_GivingPrograms` — same for Giving Programs.
16. `test_CMDT_AuditWritten` — assert `FQS_Campaign_Hierarchy_Setup.Default` CMDT row is upserted with the correct `Chosen_Model__c`, `Last_Top_Level_Id__c`, `All_Created_Top_Level_Ids_JSON__c` (for GP), `Last_Ask_Creation_Choice__c`, and `Last_Run_At__c`.
17. `test_TemplateLibrary_LoadsExpectedRowsPerModel` — for each model, query `FQS_Campaign_Template__mdt` with the same filter the flow uses (`Applicable_Models__c INCLUDES :model`) and assert the row count matches expectations (Seasonal: 5 default strategies + N default asks; GP: 6 default programs + 1 year cohort + N default asks; Strategy: 5 default strategies + N default asks). Locks in the CMDT data as a versioned fixture.
18. `test_TemplateLibrary_FoundationGivingInAllThree` — assert the Foundation Giving strategy template and both foundation proposal ask templates surface as defaults in all three models.
19. `test_PlaceholderExpansion` — assert `Spring Appeal {yearLabel}` becomes `Spring Appeal FY26` when yearLabel is `FY26`, and `Corporate Foundation Proposal {yearLabel}` becomes `Corporate Foundation Proposal FY26`.
20. `test_DateRule_MirrorsParent` — assert an ask with `Date_Rule__c = mirrors-parent` gets the same StartDate/EndDate as its parent strategy after both are computed.
21. `test_DateRule_FullWindow` — assert `full-window` produces `topStart` / `topEnd`.
22. `test_DateRule_SepNov_FiscalYear` — assert `sep-nov` in FY26 (Jul 2025 – Jun 2026) produces Sep 1 2025 – Nov 30 2025.

---

## Out of scope (for this task)

- Extending `FQS_Campaign_Category__c` picklist values.
- Creating Outreach Source Codes.
- **Deep Clone implementation** — future work, not v1.
- **Standalone launch surface** (FlexiPage tile, App Launcher entry, URL button) — future work. In v1, the subflow only launches via the parent `FQS_Setup_Flow`. The subflow is *authored* to run standalone so adding a surface later is metadata-only.
- Re-run / append behavior — obsoleted by the deep-clone direction.
- Non-standard fiscal years' quarter shapes.
- Deleting or reorganizing existing hierarchies.

---

## Audit findings (2026-07-19)

Cross-check of this plan against what has actually shipped in git and in FundFirst. Read-only audit performed 2026-07-19 by Opus. Follow-on session prior to release should validate the recommended fixes below.

### What shipped

**Committed (SHA [`7c30b24`](../) "Add FQS Campaign Hierarchy setup"):**
- Apex: [FQS_CampaignHierarchyBuilder.cls](../force-app/main/default/classes/FQS_CampaignHierarchyBuilder.cls) + [Test](../force-app/main/default/classes/FQS_CampaignHierarchyBuilder_Test.cls) (11 tests, not 22 as v2 plan promised)
- Utility: [FQS_CustomMetadataSaver.cls](../force-app/main/default/classes/FQS_CustomMetadataSaver.cls) + [Test](../force-app/main/default/classes/FQS_CustomMetadataSaver_Test.cls)
- CMDT type: [FQS_Campaign_Template__mdt/](../force-app/main/default/objects/FQS_Campaign_Template__mdt/) with 10 fields
- **53 CMDT records** in `force-app/main/default/customMetadata/FQS_Campaign_Template.*.md-meta.xml` (plan promised ~35 — over-shipped, no known issue)
- Campaign hierarchy fields: `FQS_Child_Campaign_Count__c`, `FQS_Hierarchy_Depth__c`, `FQS_Short_Name__c`, `FQS_Ultimate_Parent_Campaign__c`
- Permission set grants (via [FQS_Custom_Fields](../force-app/main/default/permissionsets/FQS_Custom_Fields.permissionset-meta.xml))

**Rollup flows (SHA `17897c6`):** `FQS_Campaign_Child_Count_Update` + `_Delete` (siblings; maintain `FQS_Child_Campaign_Count__c`).

**Campaign layout / compact layout / `FQS_Campaign_Category__c` (SHA `1c38110`):** refinements landed.

**Uncommitted, held back by no-flow-commits gate:**
- [FQS_Campaign_Hierarchy_Setup.flow-meta.xml](../force-app/main/default/flows/FQS_Campaign_Hierarchy_Setup.flow-meta.xml) — 757 lines, Active, deployed to FundFirst (`301WB000016ftftYAA`).

**FundFirst org state (verified via `sf sobject describe` + `FlowDefinitionView`):**
- All 5 Campaign FQS_* fields deployed.
- 10-field CMDT type + 53 records present in org.
- `Campaign.FQS_Fundraising` record type present.
- `FQS_Campaign_Hierarchy_Setup` flow Active.
- `FQS_Setup_Flow` Active but is the Donor Grouping flow, **not** the orchestrator the plan describes.

### Plan cross-reference — item-by-item status

| Plan item | Status |
|---|---|
| CMDT `FQS_Campaign_Template__mdt` with 10 fields | DONE |
| ~35 seeded template records | DONE (53 shipped) |
| `Applicable_Models__c` as Multi-Select | DIVERGENT — implemented as Text(255) with semicolon values (CMDT does not support MultiSelectPicklist). Apex uses `LIKE '%model%'`, flow uses `Contains`. Acceptable but note substring-match risk. |
| `Default_In_Model__c` for library-picker split | DIVERGENT — field exists on all 53 CMDT records but Apex never reads it and flow does not split default vs. library. Dead metadata. |
| Builder signature `build(model, rollupKeys, strategyKeys, askKeys)` | DONE |
| `oct-plus-apr` date-rule fix | DONE (`endYr = topStart.year() + 1` when equal) |
| Removal of `FQS_Campaign_Hierarchy_Setup__mdt` audit CMDT | DONE |
| 11 Apex tests | DONE (v3 shipped 11; v2 plan listed 22 — see gaps below) |
| Placeholder expansion `{yearLabel}` / `{yearShort}` | DONE (in Apex only) |
| Category mapping (all three models) | DONE |
| Duplicate-name error | PARTIAL — Apex only checks within `RecordType.DeveloperName = 'FQS_Fundraising'`; an RT-less duplicate slips through. |
| Screen Subflow authored to run standalone | PARTIAL — flow is standalone-capable but `inLaunchedFromSetupFlow` input is declared and **never referenced** anywhere. |
| Parent `FQS_Setup_Flow` orchestrator (Screens A / B / C + subflow calls) | MISSING — the current `FQS_Setup_Flow` is the 1001-line Donor Grouping flow. No orchestrator exists. |
| Standalone launch surface (App Launcher / FlexiPage tile) | MISSING (plan defers to future work — acceptable) |
| Reactive Screen 1 preview panel | MISSING — Screen 1 renders a static HTML block showing all three model examples |
| Screen 4 conditional asks-skipped panel | MISSING — Screen_Success shows unconditional text |
| Screen 4 `Continue Setup →` vs. `Finish` toggle by launch context | MISSING |

### Gaps

**Missing:**
- Parent `FQS_Setup_Flow` orchestrator. The current `FQS_Setup_Flow` is the Donor Grouping configurator, and the `FQS_Setup_Configuration` FlexiPage routes to it. On a fresh scratch install the Campaign Hierarchy Setup flow deploys but nothing runs it.
- Screen 0 boot logic. Apex handles fiscal-year detection, but flow-level `varYearBasis` / `varYearStart` / etc. don't exist, so nothing in the UI reflects the fiscal window.
- `inLaunchedFromSetupFlow` behavior wiring — the input is declared but referenced nowhere.
- `Default_In_Model__c` filtering / library picker on Screen 2 (all rows appear in one table today).
- Screen 1 reactive preview per model choice (still a static HTML block with FY26 hardcoded).
- Screen 4 conditional panels (asks-skipped, launch-context-aware button label).
- Formula-level `{yearLabel}` expansion on Screen 2 — column shows raw `{yearLabel}` string in the datatable (expansion happens only in Apex).

**Divergent:**
- `Applicable_Models__c` is Text-with-LIKE-matching (CMDT constraint). A future value like `SeasonalV2` would silently substring-match `Seasonal`.
- Screens labeled "Step 1 of 4" through "Step 4 of 4" but there are 5 user-facing screens (Model, Strategies, Asks, Confirm, Success/Error). Copy is stale.
- Category picker's `Suggested_Name__c` column shows raw `{yearLabel}` placeholder (Apex expands only on insert).

**Extra (not covered by plan):**
- `FQS_Campaign_Category__c` picklist expanded to include `Corporate Match` and `In-Kind` values (org-authoritative, done via Donor Grouping commit). Plan never enumerated these.
- Two Campaign rollup flows (`FQS_Campaign_Child_Count_Update` / `_Delete`) that maintain `FQS_Child_Campaign_Count__c`. Orthogonal to this plan.

### Gate A findings for FQS_Campaign_Hierarchy_Setup.flow-meta.xml

Only FAILs and load-bearing PASSes listed.

- **UX — `allowFinish=true` on every screen** — **FAIL**. `Screen_Choose_Model`, `Screen_Choose_Strategies`, `Screen_Choose_Asks`, `Screen_Confirm` all allow Finish. Clicking Finish on any of them terminates the flow **before** `Build_Hierarchy` runs → no error, no Campaigns, silent zero-result. Only `Screen_Success` and `Screen_Error` should have Finish enabled.
- **Design — Subflow contract not honored** — **FAIL**. `inLaunchedFromSetupFlow` declared but not referenced. No parent orchestrator calls this flow.
- **Screen label copy vs. reality** — **FAIL** (cosmetic). "Step 1 of 4"–"Step 4 of 4" but there are 5 screens.
- **Variable prefixing convention (`var_`, `rsv_`, `col_`)** — **FAIL** (nit). Uses `var*`/`out*`/`dt*`/`radio*` (mixed camelCase, no underscore). Inconsistent with launcher-plan convention.
- **Duplicate protection completeness** — **PARTIAL**. SOQL scoped to `RecordType.DeveloperName = 'FQS_Fundraising'` only; RT-less duplicates slip through.
- **UX — success screen doesn't lie** — PASS (accurate counts, honest "first-run only" note).
- **Error message tells user next step** — PASS (`Screen_Error` shows `varErrorMessage` + Back-to-retry).
- **Fault path on DML** — PASS (`Build_Hierarchy` has fault connector to `Screen_Error`).
- **No DML / Get Records inside loops** — PASS (all Get Records precede loops; loops only run assignments).
- **CMDT reads pre-fetched** — PASS (3 sequential `Get_*_Templates` before Screen 2).
- **API version 66.0, Status=Active, runInMode=DefaultMode** — PASS.

### Risks / open questions

1. **No launch surface.** On a fresh scratch org the flow deploys but nothing reaches it. `FQS_Setup_Configuration` FlexiPage points to `FQS_Setup_Flow` (the Donor Grouping flow). Blocks Phase 4 install verification.
2. **`allowFinish=true` premature-exit trap.** A user clicking Finish on Screen 1 gets zero-Campaign silent success. Production-quality bug.
3. **Parent orchestrator plan overlaps with active work.** Building `FQS_Setup_Flow` as an orchestrator will collide with the current Donor Grouping flow that owns that name. Decision required: rename Donor Grouping flow, or split responsibilities.
4. **CMDT LIKE-matching substring risk.** Nothing violates it today, but future `SeasonalV2`-like values would double-match. Low risk, worth documenting in the field description.
5. **`Default_In_Model__c` is dead metadata today.** Either wire it (library picker) or delete field + values on Gate C-relevance grounds.
6. **Test coverage narrower than v2 plan.** v2 listed 22 tests; v3 shipped 11. Missing: year-basis fiscal / calendar, mid-year backfill, no-OSCs assertion, date-rule full-window / sep-nov concrete-date checks, placeholder-expansion assertion.
7. **Naming-flow overlap.** [fqs-record-naming-flows-plan.md](fqs-record-naming-flows-plan.md) will auto-rewrite `Campaign.Name` on AfterSave; the Apex `expandName` result is doomed to be overwritten shortly after insert. Not a bug — just noting the write-once semantics.

### Recommended next steps (ranked, effort estimates)

1. **[15 min] Set `allowFinish=false`** on `Screen_Choose_Model`, `Screen_Choose_Strategies`, `Screen_Choose_Asks`, `Screen_Confirm`. Only Success and Error should allow Finish. Single-flow edit + redeploy. Low risk, high value.
2. **[10 min] Fix "Step N of 4" copy** — bump to "of 5", drop the counter, or renumber screens.
3. **[30 min] Author launch surface** — one of: (a) build orchestrator `FQS_Setup_Flow` per plan and repoint FlexiPage; (b) rename Donor Grouping flow and split; (c) create an interim `FQS_Campaign_Hierarchy_Setup_Launcher` FlexiPage tile. **Requires a design call.**
4. **[20 min] UI test then commit** `FQS_Campaign_Hierarchy_Setup.flow-meta.xml`. The no-flow-commits gate lifts once UI passes. Include #1 and #2 in the same commit.
5. **[45 min] Widen test coverage** — add fiscal-year, mid-year backfill, date-rule window, placeholder-expansion tests from the v2 test plan (items 4, 5, 6, 12, 15, 17, 18, 19, 20, 21, 22 in this plan's Test section above). Straight extensions to the existing test class.
6. **[15 min] Decide `Default_In_Model__c`'s fate.** Wire a library picker (matches original v2 spec), or delete field + values from all 53 records.
7. **[10 min] Tighten duplicate check.** Remove the RecordType filter so any Campaign with the same name errors early.

### Manual UI acceptance checklist

Run against a fresh scratch org that installed everything from `main`. This is the release acceptance test for the feature.

- [ ] From App Launcher → Fundraising Quick Start → Setup Configuration tab, the Campaign Hierarchy Setup flow can be reached (**blocked** until launch surface built).
- [ ] Screen 1 (Choose Model): three radio options render, Seasonal is default, help text visible, sample outline block legible.
- [ ] Screen 2 (Strategies), Seasonal model: `dtRollups` table renders (may be empty if no Rollup rows apply); `dtStrategies` shows 5 seasonal strategies (Spring Appeal, Annual Celebration, Year-End Push, Monthly Sustainer, Foundation Giving).
- [ ] Screen 2 (Strategies), Giving Programs model: `dtRollups` shows 6 program rollups (Major Gifts, Planned Giving, Online Giving, Events, Foundation Giving, Annual Giving). Multi-select works.
- [ ] Screen 2 (Strategies), Strategy model: `dtStrategies` shows 5 strategies (Lapsed, New Donor, Retention, Mid-Level, Foundation).
- [ ] Screen 3 (Asks): table populates per model. `Suggested_Name__c` column shows literal `{yearLabel}` (expected pending flow-level formula fix).
- [ ] Leave Asks table empty → Next → Confirm → Build. Verify **rollup + strategies created, zero asks**.
- [ ] Click Finish on Screen 1 / 2 / 3 / 4 (not Success) — should NOT terminate flow (**fix #1 must land first**).
- [ ] Seasonal all-defaults build: one top-level `FY26 Fundraising` (or `CY26` per fiscal year) with `FQS_Campaign_Category__c = 'Fundraising Top Level Campaign'` and `RecordType.DeveloperName = 'FQS_Fundraising'`.
- [ ] Foundation Giving strategy has `FQS_Campaign_Category__c = 'Grants'` after Seasonal build.
- [ ] Giving Programs build: 6 top-levels created, each has one child year-cohort strategy named `FY26`.
- [ ] Under `Major Gifts` top-level, `FQS_Campaign_Category__c = 'Major Gifts'`.
- [ ] Duplicate-name check: manually create `FY26 Fundraising` with `FQS_Fundraising` RT, rerun flow → `Screen_Error` surfaces the friendly duplicate message, zero new records.
- [ ] After a successful build, `FQS_Child_Campaign_Count__c` on top-level increments (rollup flow working).
- [ ] `FQS_Hierarchy_Depth__c` is 1 for rollup, 2 for strategy, 3 for ask.
- [ ] `FQS_Ultimate_Parent_Campaign__c` on an ask returns the rollup's name.
- [ ] `Screen_Success` shows correct counts and OSC / next-year copy.
- [ ] Delete a strategy → parent's `FQS_Child_Campaign_Count__c` decrements (Delete flow).
- [ ] Reparent a Campaign → both old and new parent counts adjust (Update flow).

---

## Remediation applied (2026-07-19)

Justin decisions on the audit shipped in one working session. Every change deployed to FundFirst before commit.

- **Fix #2 — `allowFinish` bug (deploy `0AfWB00000DTkb30AD`).** Set `<allowFinish>false</allowFinish>` on `Screen_Choose_Strategies`, `Screen_Choose_Asks`, and `Screen_Confirm` in [FQS_Campaign_Hierarchy_Setup.flow-meta.xml](../force-app/main/default/flows/FQS_Campaign_Hierarchy_Setup.flow-meta.xml). `Screen_Choose_Model` left at `allowFinish=true` because Salesforce forbids `allowBack=false` + `allowFinish=false` on the same screen (initial deploy `0AfWB00000DTkSz0AL` failed on that constraint) — acceptable because no user data has been captured at Screen 1, Finish there is functionally "cancel." `Screen_Success` / `Screen_Error` unchanged.
- **Fix #3 — orchestrator seed (deploy `0AfWB00000DTkhV0AT`).** Copied `FQS_Setup_Flow.flow-meta.xml` → new file [FQS_Setup_Orchestrator.flow-meta.xml](../force-app/main/default/flows/FQS_Setup_Orchestrator.flow-meta.xml) with `<label>FQS Setup Orchestrator</label>` and `<status>Draft</status>`. Original `FQS_Setup_Flow` untouched; `FQS_Setup_Configuration` FlexiPage still routes to the original. Seed only — nothing wired yet.
- **Fix #4 — Applicable_Models__c substring warning (bundled deploy — see below).** Added a WARNING sentence to `<description>` in [Applicable_Models__c.field-meta.xml](../force-app/main/default/objects/FQS_Campaign_Template__mdt/fields/Applicable_Models__c.field-meta.xml) documenting the `LIKE '%model%'` / Flow `Contains` substring-match risk. No Apex or flow logic changed.
- **Fix #5 — `Default_In_Model__c` deletion — NOT SHIPPED, reclassified.** Halted per the plan's STOP directive: `FQS_CampaignHierarchyBuilder.cls` line 86 SELECTs the field and [FQS_CampaignHierarchyBuilder_Test.cls](../force-app/main/default/classes/FQS_CampaignHierarchyBuilder_Test.cls) line 12 uses it in a live `WHERE Default_In_Model__c LIKE :('%' + model + '%')` clause plus [FQS_Campaign_Template__mdt-FQS Campaign Template Layout.layout-meta.xml](../force-app/main/default/layouts/FQS_Campaign_Template__mdt-FQS%20Campaign%20Template%20Layout.layout-meta.xml) references it — deletion would break Apex compilation and empty a test query. Reverted the field-file delete and the value-block strip across the 53 records (`git checkout HEAD` on the field file + all 53 CMDT records) before deploying. **Decision (Justin, 2026-07-19):** reclassify `Default_In_Model__c` from "dead" to **"referenced, currently unused"** — the field is queried by Apex and filtered in tests, but no downstream UI/Screen consumes the result. It stays. If a future library-picker split lands (v2 spec), the field is already there; if not, an Apex-first cleanup would remove the SELECT + test WHERE first, then delete the field/records/layout. No further action this release.
- **Fix #6 — naming-flow scope clarification.** Added an "Explicitly excluded from scope" section to [.planning/fqs-record-naming-flows-plan.md](fqs-record-naming-flows-plan.md) — Campaign is not covered by the auto-naming flows because `FQS_CampaignHierarchyBuilder.expandName` already writes the final Campaign name at insert, and an AfterSave flow would overwrite it.
- **Fix #7 — step counter copy (no change needed).** Verified the four pre-terminal screen labels already read "Step 1 of 4" → "Step 4 of 4" and the Success/Error screens are correctly excluded from the count. Copy matches reality — no edit required.

**Deploy 3 (field description warning):** field-level XML change only. Deploy ID recorded in the return summary. CMDT type + 53 records left as they are on `main` (fix #5 aborted before any record edits landed).

**Out of scope (Justin gated) and unchanged this session:** launch surface / FQS App Home page, `FQS_Setup_Configuration` FlexiPage, `FQS_Setup_Flow` (original), duplicate-name check tightening, widened test coverage, orchestrator screen wiring, launcher / wizard / release-readiness files.

**Screen_Choose_Model Finish behavior (accepted 2026-07-19):** Screen 1 keeps `allowFinish=true` because Salesforce metadata validation blocks the `allowBack=false + allowFinish=false` combination. Since Seasonal is pre-selected as default on Screen 1 (radio group defaults to first option), clicking Finish there terminates a pre-populated draft with nothing further built — functionally a cancel. UI-verified 2026-07-19. If a future UX pass wants Finish uniformly locked, options are (a) enable `allowBack=true` on Screen 1 (meaningless but unblocks the validator), or (b) redesign Screen 1 with an explicit Cancel button.

**Fix #2 rescinded (2026-07-19).** The audit's premise was wrong: `allowFinish` on a screen does not mean "show a Finish button" — it means "this screen is terminal-eligible." Salesforce's footer emits **Next** when there is a downstream connector, and **Finish** only on genuine terminal screens. Setting `allowFinish=false` on Screens 2, 3, 4 changed nothing at runtime (the footer already showed Next). Flow Builder re-enables `allowFinish=true` on save-as-new-version and that is the correct state; the flow's real terminal semantics live in its connector graph, not in the `allowFinish` field. The audit misread the risk. `Screen_Confirm` currently sits at `allowFinish=false` (bounced from Flow Builder unchanged); leaving it that way is fine — Confirm has a downstream connector to Build_Hierarchy so the footer emits Next anyway. No fix required. **Note for future audits:** do not treat `allowFinish=true` on a non-terminal screen as a bug; verify via UI which button renders.

**Fix #7 rescinded (implicit — the "Step N of 4" copy was correct all along).** The audit flagged this as a bug based on there being 5 physical screens. But the 5th (Success/Error) is terminal, not a step in the wizard. The 4-of-4 counter is correct.

**Fix — Screen_Confirm hidden-button + selection summary (2026-07-19, deploy `0AfWB00000DTmHt0AL`).** Two changes to `Screen_Confirm`:
- `allowFinish=true` (was `false`). Reversing my earlier misread — `Screen_Confirm` has a downstream `<connector>` to `Decide_Model_Is_GivingPrograms` (a Decision, not a Screen), and when `allowFinish=false` on a screen with only a Decision downstream, Salesforce hides the terminal action entirely. Setting `allowFinish=true` lets the footer render **Next** which the Decision then routes through — exactly the behavior needed. This is a hard bug fix, not a cosmetic one.
- Added selection counts to `DisplayText_ConfirmIntro`: `Programs (Level 1): {!dtRollups.selectedRows.size} selected`, same for Strategies and Asks. Users can now sanity-check what they picked before building. Full row-by-row summary was considered but deferred — the counts are the minimum viable disclosure, and a real summary table needs Flow Builder authoring.

**Follow-up — Screen 2 parent-context (2026-07-19).** The Choose Strategies screen's `dtStrategies` and `dtAsks` tables don't show which parent each row will roll up under. In Seasonal mode the parent is implicit (one top-level, e.g. `FY26 Fundraising`) so this is a minor issue. In Giving Programs mode each strategy rolls up to whichever program the user picked in `dtRollups` — a Parent column on Strategies would clarify this. Add a `Parent_Template_Key__c` column to the `dtStrategies` columns JSON, and consider a text-derived "Parent Program" display column that resolves the key. `dtAsks` already shows `Parent_Template_Key__c`. Not a correctness bug; a UX authoring gap.

**Follow-up — Screen 4 full-row summary (2026-07-19).** The Confirm screen now shows selection **counts** but not the row identities. A "You selected: [Spring Appeal, Year-End Push]" style summary would need a Get_* + Loop + text-accumulation pattern before Screen_Confirm renders, or a Flow-Builder-authored table. Deferred to a UX iteration.

**P1 BLOCKER — RESOLVED 2026-07-20** by [MultiSelectCheckboxes rebuild](#multiselectcheckboxes-rebuild-2026-07-20) — see section at end of file. The datatable-selectedRows binding was abandoned rather than diagnosed; three native `MultiSelectCheckboxes` screen fields replace the datatables and bind reliably.

**P1 BLOCKER (historical) — flowruntime:datatable selectedRows binding is broken (2026-07-19, ships with feature disabled).** Confirmed via Flow Debug log during Test 3 run. The `flowruntime:datatable` component's `selectedRows` output does NOT reflect the user's checkbox state:

- Screen 2 test: user checked **2** of 5 strategy rows (Spring Appeal + Annual Celebration). `selectedRows` output returned **4** rows (added Monthly Sustainer Drive + Foundation Giving that were not checked). Year-End Push was NOT in `selectedRows` even though it was also unchecked. Non-deterministic; not "return all rows."
- Screen 3 test: user checked **0** of 13 ask rows. `selectedRows` output returned all **13** rows.
- `firstSelectedRow` mirrors this — reports the first row of `selectedRows`, not the first user-checked row.
- Downstream loops iterate `selectedRows` faithfully. Apex `FQS_CampaignHierarchyBuilder` filters correctly on the keys it receives. Bug is exclusively in the component's output binding.

Verified fixes that did NOT resolve this:
- Setting `shouldDisplayLabel = true` (fixes label rendering, unrelated to selection)
- Adding `keyField` complexValue with `fieldReferences: ["Id"]` (default emitted by Flow Builder)
- Hand-editing `keyField.fieldReferences` from `["Id"]` to `["Template_Key__c"]` (deployed via `0AfWB00000DTmwD0AT`; no change in behavior)

Salesforce docs on the component are behind a login and not accessible from CLI tooling. Community search deferred.

**Impact:** The Campaign Hierarchy Setup flow is **not user-shippable** in its current form. Every run builds a partial hierarchy of records the user did not fully choose. Direct SOQL cleanup is required after any test run.

**Do not release this flow to end users until the datatable binding is diagnosed and fixed.** In the interim, the Apex `FQS_CampaignHierarchyBuilder` is directly invocable from a developer console — that's the working release path for organizations that want the hierarchy built without the wizard UI.

**Diagnosis paths to try later, in order of expected cost:**
1. Salesforce Trailblazer Community + Stack Exchange search for `flowruntime:datatable selectedRows multi_select`.
2. Rebuild the 3 datatable components from scratch in Flow Builder (delete + re-add) — fresh authoring may emit correct XML that round-tripping doesn't.
3. Try `preselectedRows` input parameter with an empty collection — may reset default-all-selected behavior.
4. Switch to the older `flow_datatable` Aura component instead of `flowruntime:datatable`.
5. Wire the datatable to a `flowruntime:LookupRecord`-based multi-picker instead — less rich UI but known to work.

**Fix (datatable label + keyField) applied via Flow Builder (2026-07-19).** All three `flowruntime:datatable` fields (`dtRollups`, `dtStrategies`, `dtAsks`) were missing two input parameters that Flow Builder emits but don't hand-author cleanly:
- `<name>shouldDisplayLabel</name>` with `<booleanValue>true</booleanValue>` — the "Use Label as the table title" checkbox in Flow Builder's datatable properties. Without it, the datatable's `label` input parameter is stored but not rendered as chrome.
- `<name>keyField</name>` with a `<complexValue>{...JSON...}</complexValue>` + `<complexValueType>ComplexObjectFieldDetails</complexValueType>` wrapper. Hand-authored `<stringValue>` was rejected: *"Input parameters of type FlowComplexObjectFieldDetails need to have a ComplexValue."* Only Flow Builder emits the correct XML shape (parity with the gotcha documented in [FQS_Find_Matching_Gift.flow-meta.xml](../force-app/main/default/flows/FQS_Find_Matching_Gift.flow-meta.xml) description).

Justin applied both switches to all three datatables in Flow Builder and saved as new version. Then a `sf project retrieve start --metadata Flow:FQS_Campaign_Hierarchy_Setup` pulled the correct XML back to the repo — this is the pattern for authoring datatable configuration going forward.

---

## MultiSelectCheckboxes rebuild (2026-07-20)

Abandoning the datatable approach entirely. The P1 blocker above is not diagnosed — it is *routed around* by replacing the three `flowruntime:datatable` screen fields with native Flow `MultiSelectCheckboxes` screen fields whose selection binding is a first-class Flow primitive.

**Deploy ID:** `0AfWB00000DUlgL0AT` (single atomic deploy of the full rewrite).

### What was removed

- **Three datatable screen fields:** `dtRollups`, `dtStrategies`, `dtAsks` — all with `<extensionName>flowruntime:datatable</extensionName>`.
- **Three loops over `selectedRows`:** `Loop_Selected_Rollups`, `Loop_Selected_Strategies`, `Loop_Selected_Asks`.
- **Three assignments that appended `Template_Key__c` into the intermediate collection vars:** `Assign_Selected_Keys_Rollups`, `Assign_Selected_Keys_Strategies`, `Assign_Selected_Keys_Asks`.
- **Rollup-default-for-non-GP workaround:** `Assign_Rollup_Default_For_Non_GP` (which shoved a literal `'rollup'` into `varSelectedRollupKeys` for Seasonal/Strategy) removed. Seasonal/Strategy now simply pass an empty rollup collection; the Apex builder enters the `else` branch at line 117 and hardcodes the top-level.
- **Model gating decision** `Decide_Model_Is_GivingPrograms` — no longer needed because the empty-rollup-list path handles both cases uniformly.

### What was added

**Three `MultiSelectCheckboxes` screen fields:**

- `msRollups` on `Screen_Choose_Strategies`, gated by `<visibilityRule>` `radioModel EqualTo 'GivingPrograms'`.
- `msStrategies` on `Screen_Choose_Strategies`, always visible.
- `msAsks` on `Screen_Choose_Asks`, always visible.

Each MSCS field references a `<dynamicChoiceSets>` element that queries `FQS_Campaign_Template__mdt` filtered by `Applicable_Models__c Contains {!radioModel}` + `Level__c EqualTo Rollup|Strategy|Ask`, sorted by `Sort_Order__c` ASC. `<displayField>Suggested_Name__c</displayField>` renders the choice label; `<valueField>Template_Key__c</valueField>` is the value the Apex expects. `{yearLabel}` placeholders in choice labels are left un-expanded (Apex expands them at insert time — acceptable per Justin's decision).

**Pre-checked defaults:**

For each level, a Get Records queries the same CMDT with an extra filter `Default_In_Model__c Contains {!radioModel}` (see `Get_Default_Rollup_Templates`, `Get_Default_Strategy_Templates`, `Get_Default_Ask_Templates`). A follow-on loop (`Loop_Default_Rollups` / `_Strategies` / `_Asks`) appends each row's `Template_Key__c` plus a `;` separator into a `String` accumulator (`varDefaultRollupKeysStr` / `_Strategy_` / `_Ask_`). A trailing-semicolon-stripping formula (`formulaDefaultRollupKeysClean`, etc.) is bound to the MSCS field's `<defaultValue>` so the field renders with those choices pre-checked.

The default-loading pipeline runs after `Screen_Choose_Model` and before `Screen_Choose_Strategies`. Sequence: `Get_Rollup_Templates` → `Get_Strategy_Templates` → `Get_Ask_Templates` → `Get_Default_Rollup_Templates` → `Loop_Default_Rollups` → `Get_Default_Strategy_Templates` → `Loop_Default_Strategies` → `Get_Default_Ask_Templates` → `Loop_Default_Asks` → `Screen_Choose_Strategies`. Six Get Records total in the pre-flight (three "all applicable" for the dynamic choice sets to reference, three "defaults only" to power the pre-check state). Not the leanest possible; correct.

### Semicolon-string → List&lt;String&gt; boundary handling

`<fieldType>MultiSelectCheckboxes</fieldType>` output type is a single `String` (semicolon-separated), not a text collection. Rather than modify the Apex `BuildRequest` (out of scope — 11 tests would need updates), the flow rebuilds the `List<String>` server-side using a Loop-plus-Decision-plus-Add pattern:

For each level, after `Screen_Confirm` and before `Build_Hierarchy`:
1. Loop over the full CMDT set for that level (`Get_Rollup_Templates` / `_Strategy_` / `_Ask_` — the same collections that already back the dynamic choice sets).
2. On each iteration, a Decision (`Decide_Rollup_In_Selection` / etc.) tests whether the MSCS output string `Contains` the current row's `Template_Key__c`.
3. If matched, an Assignment adds that key to the true text-collection variable (`varSelectedRollupKeys` / `varSelectedStrategyKeys` / `varSelectedAskKeys`).
4. When the loop completes, the accumulated collection is passed to `Build_Hierarchy` on the invocable input parameter, unchanged.

Why not `SPLIT()`? Flow's formula-level `SPLIT` returns a text collection in some contexts but is fragile as an inline default for an invocable input parameter — Flow Builder rejects it in some templates and there are documented cases where the return type is coerced to a single string. The loop-membership-test pattern is explicit, deploys cleanly, and stays inside patterns already in use elsewhere in FQS. Extra queries are zero because the Get Records for the dynamic choice sets are reused as the loop collection.

Sequence: `Screen_Confirm` → `Loop_Rollup_Membership` → `Decide_Rollup_In_Selection` → (`Assign_Add_Rollup_Key` or fall-through) → next iteration; after loop exhaust → `Loop_Strategy_Membership` → similar → `Loop_Ask_Membership` → similar → `Build_Hierarchy`.

### Screen_Confirm selection-count status

**Dropped.** The stale bindings (`{!dtRollups.selectedRows.size}` etc.) were removed from the DisplayText block on `Screen_Confirm`. The counts are not rewritten to reference MSCS output because MSCS output is a single semicolon-string that has no `.size` accessor — a proper count would need either a formula that counts `;` or a wait-until-loops-run-then-bind-to-collection-size which happens after the Confirm screen renders. Kept the "Model: {!radioModel}" line and the boilerplate. Row-identity summary is deferred (was already noted as follow-up).

### Screen structure

Preserved (five user-facing screens, four numbered steps + terminal Success/Error):

1. `Screen_Choose_Model` — unchanged. Radio buttons, intro copy, sample-shape outline.
2. `Screen_Choose_Strategies` — rebuilt with `msRollups` (visibility-gated on `radioModel == GivingPrograms`) + `msStrategies` (always visible).
3. `Screen_Choose_Asks` — rebuilt with `msAsks` (always visible).
4. `Screen_Confirm` — kept, with count lines dropped. Downstream connector now goes to `Loop_Rollup_Membership` (was `Decide_Model_Is_GivingPrograms`).
5. `Screen_Success` / `Screen_Error` — unchanged.

### Divergences from the plan

- **Six Get Records, not four.** The plan suggested "if the choice-set syntax lets you skip separate GetRecords elements ... delete the redundant GetRecords. Otherwise keep them." Native `<dynamicChoiceSets>` is a self-contained SOQL query — but the *loop-membership-test* selection-collection rebuild needs a Flow collection variable to iterate, and dynamic choice sets are not exposed as flow variables. So the three "all applicable" Get Records stay (as loop collections) AND the dynamic choice sets each carry their own query. Three additional "defaults only" Get Records added on top for pre-check state. Six total. Bulkified, all outside loops.
- **`SPLIT()` formula path not used.** Justin's plan floated `SPLIT()` as the "cleaner" way to convert semicolon-string to text collection. The loop-membership pattern was chosen instead — it re-uses the CMDT collections already loaded, avoids formula/invocable parameter binding uncertainty, and is a pattern used elsewhere in FQS flows.

### UI test protocol for Justin

Run each test against FundFirst. Between runs, clean up created Campaigns with:

```
sf apex run --file scripts/apex/soql-adhoc.apex --target-org FundFirst
```

(or an inline `delete [SELECT Id FROM Campaign WHERE RecordType.DeveloperName = 'FQS_Fundraising']`).

**Test 1 — Seasonal, all defaults, happy path.**
1. Launch the flow. Screen 1: leave `Seasonal` selected (default). Next.
2. Screen 2 (`Screen_Choose_Strategies`): `msRollups` should be **hidden** (visibility rule). `msStrategies` should show 5–6 strategy options with 4–5 pre-checked (Spring Appeal, Annual Celebration, Year-End Push, Monthly Sustainer, Foundation Giving). Leave all defaults. Next.
3. Screen 3 (`Screen_Choose_Asks`): `msAsks` shows the seasonal ask templates with defaults pre-checked. Leave defaults. Next.
4. Screen_Confirm: shows `Model: Seasonal`. Next.
5. Screen_Success: shows Model=Seasonal, non-zero rollup/strategy/ask counts.
6. Verify: single top-level `FY26 Fundraising` (or CY26) + N strategy children + N ask grandchildren.

**Test 2 — Seasonal, custom selection.**
1. Launch. Seasonal → Next.
2. Screen_Choose_Strategies: **uncheck** Foundation Giving and Monthly Sustainer from `msStrategies`. Next.
3. Screen_Choose_Asks: **uncheck ALL** asks (leave `msAsks` blank). Next.
4. Confirm → Build.
5. Expected: 1 top-level + only Spring Appeal / Annual Celebration / Year-End Push strategies + zero asks. Foundation Giving strategy and Monthly Sustainer must NOT exist.
6. This is the test that would have failed under the datatable bug (bug returned rows the user didn't check).

**Test 3 — Giving Programs, happy path.**
1. Launch. Screen 1: pick `Giving Programs`. Next.
2. Screen_Choose_Strategies: **both** MSCS fields visible. `msRollups` shows 6 program rollups pre-checked (Major Gifts, Planned Giving, Online Giving, Events, Foundation Giving, Annual Giving). `msStrategies` shows the year-cohort strategy pre-checked (single row `{yearLabel}` — leave as-is). Uncheck `Annual Giving` from `msRollups` (leave 5 programs). Next.
3. Screen_Choose_Asks: defaults pre-checked. Leave defaults. Next.
4. Confirm → Build.
5. Expected: 5 top-level program Campaigns + 5 year-cohort strategies (one per program) + defaults asks under the appropriate programs. NOT 6 programs; the deselection must have taken effect.

### File state

Deploy `0AfWB00000DUlgL0AT` applied to FundFirst (Active). Local flow file at [FQS_Campaign_Hierarchy_Setup.flow-meta.xml](../force-app/main/default/flows/FQS_Campaign_Hierarchy_Setup.flow-meta.xml). No commits made per Justin's gate.

