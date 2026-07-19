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
