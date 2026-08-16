# FQS Home Page — All Copy, for Review

**Purpose:** every user-visible string on the FQS Home Page (`FQS_Home_Page_Default`) plus every user-visible string in the five flows embedded on it, extracted verbatim, for external review.

**Source of truth:** [`force-app/main/default/flexipages/FQS_Home_Page_Default.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_Home_Page_Default.flexipage-meta.xml) and the five flows referenced below. If you spot a change you want made, mark it inline and I'll edit the metadata.

**What's NOT here:** list-view column labels, dashboard visuals, standard Salesforce component chrome (component headers like "Recent Records" that Salesforce writes automatically), and per-leaf copy inside the huge `FQS_Gift_Entry_Single_Launcher_Account` monolith (that's a separate review — this doc only covers the Home Page's own copy and the *front matter* of the embedded launchers).

---

## Home Page layout at a glance

The Home Page has four regions:

- **Top region — Tabs.**
  - Tab 1: **FQS Set Up** — an 8-section accordion. Sections 1, 2, 3, 4 each embed a Setup flow. Sections 5–8 are pure rich-text guidance.
  - Tab 2: **Dashboard** — embeds the `FQS_Donor_Groupings` dashboard. No copy.
- **Bottom-left region — Accordion.**
  - **Opportunities Needing Action** — Opportunity list view (`MyOpportunities`). No FQS copy.
  - **G. Commitments Needing Action** — Gift Commitment list view (`FQS_Past_Due_Installments`). No FQS copy.
- **Bottom-right region — Accordion.**
  - **Acknowledgments** — rich-text explainer.
  - **Dashboard** — rich-text explainer.
- **Sidebar region — Accordion.**
  - **Recent Records** — standard Salesforce component. No FQS copy.
  - **Glossary** — rich-text.
  - **Process Documentation** — rich-text + two external links.
  - **Guided Gift Entry** — embeds `FQS_Gift_Entry_Guide_Universal` flow.
  - **Create Gift Batch** — embeds `FQS_Create_Gift_Batch` flow.
  - **Today's Tasks** — standard Salesforce component. No FQS copy.

---

# Part 1 — FQS Set Up tab

## Section 1. Set Up Gift Designations

Embeds the **FQS Suggest Designations** flow ([`FQS_Suggest_Designations`](../force-app/main/default/flows/FQS_Suggest_Designations.flow-meta.xml)).

Description on the flow itself: *"Setup-time Screen Flow that seeds a starter Gift Designation catalog. Admin picks which starter designations to create; flow inserts them via recordCreates. Runs from FQS Setup Flow chooser or as a standalone Setup step. Ships 14 curated starter entries across the four restriction categories. v3 adds idempotency: queries existing designations by Name and silently skips any already present in the org, so the flow can be re-run without creating duplicates."*

### Screen: Seed Your Gift Designation Catalog (intro)

> **Review Suggested Designations.**
>
> Gift Designations help you record and understand donor intent, and in some cases the reason why behind the gift. In the next screen you will see a set of suggested designations, choose the ones that make the most sense for your organization.
>
> All organizations will need one default designation, typically an unrestricted or general operating fund. Beyond that, designations can be used to track a variety of purposes (specific programs or specific expense categories) or for permanent restrictions. Typically designations are not created for time-based restrictions, those are set on the gift itself through entering the 'Restriction Release Date'.
>
> On the next screen, pick which starter designations you want. You can and should rename or retire any of them later from the Gift Designation record page.
>
> *This release ships 14 starter entries across the four restriction categories: Without Donor Restriction, With Donor Restriction - Purpose, With Donor Restriction - Permanent, and Earned Revenue.*
>
> *This flow is safe to re-run. Any starter designation already in your org (matched by exact Name) is skipped, and only the new picks are created. Re-run any time to add designations you unchecked earlier.*

### Screen: Pick Designations

Intro:

> Select the starter designations you want in your org. The designations are grouped by restriction category. All are pre-selected; uncheck any you do not want to create.
>
> *A note on time restrictions: FQS deliberately does not offer a "With Donor Restriction - Time" category on the designation. A designation names what the money is for, not when it becomes spendable. Time boundaries (e.g., FY2027, or "hold until the building opens") belong on the individual gift instead, on the **Restriction Release Date** field on the Gift Commitment or Gift Transaction. That lets one purpose-restricted designation (e.g., "Building Fund") carry gifts with many different release dates without proliferating year-suffixed designations.*

Then three category headers and 14 checkboxes. Every checkbox is on by default. Copy for each:

#### Without Donor Restriction

- **FQS General Operating Fund** — The unrestricted org default. Every FQS install ships with this as the org-wide default so the platform's activate-schedule action has a fallback designation. Created as IsDefault = TRUE.
- **FQS Board Designated Fund** — Internal designation, not a donor restriction. The board has earmarked these funds internally but can undesignate at will. The donor imposed no restriction.
- **FQS Cash Reserve** — A reserve is money held back for future need, spendable if the board votes to release. Distinct from Board Designated Fund. Teaches that Without Donor Restriction does not mean unspoken for.

#### With Donor Restriction - Purpose

- **FQS General Program** — Catch-all for gifts a donor restricted to programs broadly without naming a specific program.
- **FQS Program A** — Generic placeholder for a purpose-restricted program designation. Rename to one of your actual programs after install.
- **FQS Program B** — Second generic placeholder. Rename to one of your actual programs after install.
- **FQS Program Expansion Fund** — Distinct purpose from ongoing programs: growth or new-initiative capacity. Donors give here specifically to launch something new.
- **FQS Equipment and Supply Fund** — Purpose can be tangible non-capital spending: below-capitalization-threshold equipment, consumable supplies. Distinct from Capital Campaign Fund.
- **FQS Staff Salary Fund** — Purpose can be donor-restricted personnel costs. Teaches that programs and salaries are separable purposes.
- **FQS Capital Campaign Fund** — Capital-project purpose (building, renovation, major equipment above the capitalization threshold). Capital gifts release when the asset is placed in service, not on a schedule.

#### With Donor Restriction - Permanent

- **FQS Endowment** — Endowment principal is held indefinitely; only earnings are spendable. Add named endowments (e.g., Smith Family Scholarship Endowment) as your program grows.

#### Earned Revenue

- **FQS Events** — Exchange-transaction revenue: gala ticket sales, event registration, workshop admission. Distinct from a donation given AT an event, this is what the ticket itself was worth.
- **FQS Merchandise** — Sale of goods: t-shirts, books, branded items. Exchange transaction, not a contribution. The buyer received something of equivalent value.
- **FQS Program Services** — Program-related fee revenue: participation fees, consulting retainers, service delivery charges. Distinct from a program-restricted donation.

### Screen: Designations Created (success)

> **Your selected Gift Designation records are created.**
>
> You can retire any of these at any time by setting IsActive = FALSE on the record page. Retired designations remain queryable and remain valid for back-dated gifts.
>
> *This flow is safe to re-run. Any starter designation already in your org (matched by exact Name) is skipped, and only the new picks are created. Re-run any time to add designations you unchecked earlier.*

### Screen: No Designations Selected (empty-selection warning)

> **No designations were selected.**
>
> Nothing was created. Click Previous to pick at least one, or Finish to exit without creating any designations.

### Screen: Could Not Create Designations (fault)

> **The flow could not create the selected designations.**
>
> Common causes:
>
> - Your permission set does not grant Create on Gift Designation. Ensure FQS Custom Fields (or an equivalent permset) is assigned.
> - An org-wide default is already set on another Gift Designation. Only one Gift Designation can carry IsDefault = TRUE at a time.
> - A validation rule or trigger on Gift Designation rejected the insert.
>
> Close this flow, resolve the cause, and relaunch it.
>
> Fault message: `{!$Flow.FaultMessage}`

---

## Section 2. Establish Solicitation and Outreach Tracking (Campaign Hierarchy)

Embeds the **FQS Campaign Hierarchy Setup** flow ([`FQS_Campaign_Hierarchy_Setup`](../force-app/main/default/flows/FQS_Campaign_Hierarchy_Setup.flow-meta.xml)).

Description on the flow itself: *"Guides an admin through picking a model (Seasonal, Giving Programs, or Audience), a year cohort (last/this/next), then Strategic/Operational/Tactical campaigns via native MultiSelectCheckboxes. Tactical choices are filtered by the parent picks so only children whose parent was chosen appear. Invokes FQS_CampaignHierarchyBuilder.build to create the tree."*

### Screen: Step 0 — Learn About Campaigns

Three explainer blocks plus a "ready?" gate radio.

**Block 1 — What are campaigns?**

> Campaigns help you track solicitation for gifts and general outreach to the individuals your organization cares about. Put another way, campaigns are where you track asks to your supporters or outreach that could result in a donation immediately or in the future. The ask can be to donate in response to a letter, an invite to an event, or a request to have a one on one meeting — all of these can be tracked as a campaign, especially if the ultimate goal is to cultivate donors.
>
> You can add individuals to a campaign in a number of ways — directly from their record, through a data import, or by running a report. When you add them to a campaign, you create a campaign member record with a status that indicates they were asked but have not yet responded.
>
> When you enter a pledge or a gift, you can associate it with a campaign. The donor's campaign member record is updated to indicate they donated. This lets your organization track who you asked and how they responded.

**Block 2 — What is a campaign hierarchy?**

> Effective fundraising coordinates and reinforces asks through different channels and through a series of messages. For this reason, creating parent campaigns to organize your asks is helpful. This lets you see, monitor, and report on how your tactics are operating. Native fields like "Responses in Hierarchy" and "Contacts in Hierarchy" provide easy metrics to track, and standard reporting extends this further. We recommend your operational campaigns roll up to a campaign that represents your overall strategy.
>
> To recap, we recommend a three-level campaign hierarchy:
>
> - **Level 1 — Strategic:** the organizing anchor (a year or a program).
>   - **Level 2 — Operational:** a coordinated set of asks — the level most staff watch while a campaign is running.
>     - **Level 3 — Tactical:** one concrete solicitation sent to one audience.
>
> A campaign hierarchy can be five records deep, but we recommend using only three. If your fundraising outreach requires depth beyond three, look at outreach source codes before adding another layer of child campaigns.

**Block 3 — What campaign hierarchy model is right for your organization?**

> This step helps you choose between three ways to structure your campaign hierarchy. These are starting points — most organizations will add campaigns beyond what's shown here. This flow gets you a working baseline; you can extend it with manual record creation as your program grows.
>
> On the next screen we will give you three choices:
>
> - Seasonal / Yearly — strategy is formed yearly and giving programs are at the operational level. This model is best for year-over-year reporting and for smaller staffs.
> - Giving Programs — giving programs at the top, allowing the second level to track specific operational elements. This model is best when programs are staffed separately.
> - Audience — strategy is formed yearly and donor segment is the operational component. Best when your team plans by donor segment (lapsed, mid-level, acquisition).

**Radio gate:** "I am ready to set up my campaign hierarchy"

- "Yes, I know what campaign hierarchy to choose."
- "No, I need to think further."

### Screen: Step 1 of 5 — Choose Your Campaign Model

Radio field label: **Campaign Hierarchy Choices**

Helptext: *"Seasonal: year totals and year-over-year comparisons are one filter away. Giving Programs: each program's lifetime performance is one filter away. Audience: donor-segment performance is the primary lens."*

Options:

- **Giving Programs** — giving program at level 1, year at level 2, best when programs are staffed separately
- **Seasonal / Yearly** — year at the level 1, giving program at level 2, best for year-over-year reporting and for smaller staffs
- **Audience** — year at level 1, donor segment at level 2, best when your team plans by audience (lapsed, mid-level, acquisition)

Then a model-specific sample outline is shown based on which radio the user selects. Each outline is a nested bulleted tree of Strategic → Operational → Tactical placeholder names.

**Seasonal / Yearly — sample shape:**

- **FY26 Fundraising** (Strategic)
  - Spring Appeal FY26 (Operational)
    - Spring Appeal Email (Tactical)
    - Spring Appeal Direct Mail (Tactical)
    - Spring Appeal Follow-up Email (Tactical)
  - Annual Celebration FY26 (Operational)
    - Save-the-Date (Tactical)
    - Formal Invitation (Tactical)
    - Sponsorship Packet (Tactical)
    - RSVP Reminder (Tactical)
  - Year-End Push FY26 (Operational)
    - Giving Tuesday Email (Tactical)
    - December Reminder SMS (Tactical)
    - Year-End Match Email (Tactical)
    - New-Year's-Eve Push (Tactical)
  - Foundation Giving FY26 (Operational)
    - LOI Submissions (Tactical)
    - Grant Applications (Tactical)

**Giving Programs — sample shape** (each program is an evergreen Strategic-level rollup; every year, an Operational year-cohort campaign is created underneath, with its own Tactical asks):

- **Major Gifts** (Strategic)
  - FY26 Major Gifts (Operational) → Portfolio Solicitations, Prospect Discovery Visits, Stewardship Touchpoints (Tactical)
- **Annual Giving** (Strategic)
  - FY26 Annual Giving (Operational) → Direct Mail Renewals, Email Renewal Series, Sustainer Upgrade Asks (Tactical)
- **Online Giving** (Strategic)
  - FY26 Online Giving (Operational) → Peer-to-Peer Campaign, Web Donation Form Traffic (Tactical)
- **Events** (Strategic)
  - FY26 Events (Operational) → Annual Gala, Small Fundraising Events (Tactical)
- **Foundation Giving** (Strategic)
  - FY26 Foundation Giving (Operational) → LOIs Submitted, Grant Applications (Tactical)
- **Planned Giving** (Strategic)
  - FY26 Planned Giving (Operational) → Legacy Society Outreach, Bequest Intent Follow-ups (Tactical)

**Audience — sample shape:**

- **FY26 Donor Strategy** (Strategic)
  - Lapsed Reactivation (Operational) → Win-Back Direct Mail, Win-Back Email Series (Tactical)
  - New Donor Acquisition (Operational) → Cold Mail Acquisition, Digital Ads (Tactical)
  - Retention & Stewardship (Operational) → Thank-You Series, Impact Report (Tactical)
  - Mid-Level Cultivation (Operational) → Personalized Ask Letters, Small-Group Cultivation Events (Tactical)
  - Foundation Giving (Operational) → LOIs Submitted, Grant Applications (Tactical)

### Screen: Step 2 of 5 — Choose the Year

> **Which year are you building for?**
>
> Campaign names and dates use the year you pick. **Last year** is useful for backfilling historical reporting. **This year** is the default. **Next year** lets you pre-stage the coming fiscal year before it starts. The year label follows your org's Fiscal Year setting (CY vs FY).

Radio field: **Year Cohort**

Helptext: *"Pick the year the campaigns should target. -1 = last year, 0 = this year, +1 = next year, relative to today."*

Options: Last year / This year / Next year.

### Screen: Step 3 of 5 — Pick Strategic + Operational Campaigns

> **Pick the parent campaigns to create.**
>
> In the **Giving Programs** model, the first section lists the program-level (Strategic) campaigns — check which programs you run. In every model, the operational section picks the mid-tier campaigns that live under the Strategic level. Your picks here filter which Tactical campaigns show up next — only children whose parent you checked will be available.

Two multi-select checkbox groups populated dynamically from `FQS_Campaign_Template__mdt`:

- **Programs (Level 1 — Strategic)** — visible only in Giving Programs model.
- **Operational Campaigns (Level 2)** — visible in Seasonal and Audience models.

Helptext (Programs): *"Check the program-level (Strategic) campaigns to create. Only visible for the Giving Programs model — Seasonal and Audience models auto-create a single top-level Strategic campaign."*

Helptext (Operational): *"Check the operational campaigns to create. Defaults follow the standard shape for your model; uncheck defaults or check additional library items."*

### Screen: Step 4 of 5 — Pick Tactical Campaigns

> **Pick the tactical campaigns (Level 3) to create.**
>
> Each tactical campaign is a concrete solicitation — a letter, an email, an event invite. Only tactics whose parent you picked in the previous step appear here. Defaults reflect the standard shape for the model you chose. Uncheck any you don't need, or check additional library items. Leaving every tactic unchecked skips level 3 entirely.

Multi-select checkbox group: **Tactical Campaigns (Level 3)** with helptext *"Check the tactical campaigns to create. Defaults follow the standard shape for your model; you can uncheck defaults or check additional library items."*

### Screen: Step 5 of 5 — Confirm and Build

Two variants depending on model (Giving Programs uses `varSelectedRollupCount` for level 1; Seasonal / Audience always shows 1 Strategic).

> **Ready to build your campaign hierarchy?**
>
> **Model:** {model} **Year:** {year label}
>
> **You're about to create:**
>
> - **{n}** Strategic (Level 1) campaign(s)
> - **{n}** Operational (Level 2) campaign(s)
> - **{n}** Tactical (Level 3) campaign(s)
>
> Clicking **Next** will create the records. On the next screen you'll see the full hierarchy in a table for review; any renames or date changes can be made from each Campaign's record page after the flow finishes.

### Screen: Review + Edit Campaign Records (success)

> **Your campaigns have been created.**
>
> Model: **{model}**
> Strategic (Level 1) created: **{n}**
> Operational (Level 2) created: **{n}**
> Tactical (Level 3) created: **{n}**
>
> Review the records below. Rename or reschedule any campaign from its record page after this flow finishes. Click **Next** to finish.

Then a datatable ("Created Campaigns") listing every campaign with columns: Name (editable) / Campaign Category / Start Date / End Date / Ultimate Parent Campaign / Parent Campaign ID / Hierarchy Depth.

### Screen: Campaign Hierarchy — Done (final)

> **All set — your campaign hierarchy is ready.**
>
> Model: **{model}**
> Strategic (Level 1) created: **{n}**
> Operational (Level 2) created: **{n}**
> Tactical (Level 3) created: **{n}**
>
> **Your campaign hierarchy is live in the org.**
>
> **Next steps:**
>
> - Head to the Campaigns tab and add details to your campaign. In addition to completing the fields, you will also want to:
>   - Review the Campaign Member Statuses
>   - Set default Gift Designations
> - When it's time to build next year's campaigns, use Salesforce's built-in Campaign clone on the top-level record — this flow is first-run-per-year only.
> - Need to track a/b tests, track different channels, and/or want to report on granular audience segments? Add Outreach Source Codes from the campaign record to get more detail on your tactical (level 3) campaigns.

### Screen: Campaign Hierarchy — Error

> **There was a problem building your campaign hierarchy.**
>
> `{!varErrorMessage}`
>
> Click **Back** to return and try again.

---

## Section 3. Define Donor Tiers and Thresholds

Two parts: a rich-text explainer, then an embedded flow.

### Rich-text explainer on the Home Page

> **What donor groupings do for you**
>
> Donor groupings put every donor into one of three tiers — Entry, Mid, and Major — based on the size of their gifts. The tier drives acknowledgement copy, stewardship routing, gift-level formulas, and the reports and dashboards that ship with FQS. Adjust the thresholds below so they match how your organization thinks about donor tiers.
>
> Each grouping has three dollar bands you can tune: **One-Time** (a single gift big enough to qualify), **Annual** (fiscal-year cumulative giving), and **Lifetime** (all-time cumulative giving). A donor lands in the highest tier they qualify for on any of the three bands.
>
> You can also rebrand the tier names — use *Friend / Partner / Champion* if that fits your voice better than Entry / Mid / Major.
>
> Changes take up to a minute to flow through — FQS writes the new thresholds to Custom Metadata, which the platform deploys asynchronously.

### Embedded flow: FQS Setup — Donor Grouping Thresholds

[`FQS_Setup_Donor_Grouping_Thresholds`](../force-app/main/default/flows/FQS_Setup_Donor_Grouping_Thresholds.flow-meta.xml).

Flow description: *"Bulk-edits the tier $ thresholds (One-Time / Annual / Lifetime) and branded name for the three seeded FQS_Donor_Grouping__mdt rows (Entry / Mid / Major). Companion flow FQS_Setup_Stewardship_Response_Settings governs the stewardship-routing side. Writes go through the FQS_CustomMetadataSaver Apex bridge, which enqueues a single asynchronous Metadata API deployment."*

#### Screen: Donor Grouping Thresholds

Header block:

> **Adjust the giving thresholds for each donor grouping to your nonprofit organization.**
>
> These thresholds decide which donor grouping a gift falls into based on the donor's one-time, annual, and lifetime giving.
>
> These donor groupings will effect the donor acknowledgement process, formula fields for individuals and gift, and reports included in the Fundraising Quick Start.
>
> Changes take up to a minute to appear after you finish this flow.

Then three sections (**Major**, **Mid**, **Entry**), each with sub-header "What does your organization consider to be a {tier} level gift?" and four fields:

- **Branded Name ({tier})** — helptext: *"The branded name of the Grouping Key shown to staff and donors in reports, dashboards, and the Donor Gift Summary record page. Changing this value here automatically updates FQS_Donor_Level_Name__c on all Donor Gift Summary records. Example values: Friend, Partner, Champion or Entry, Rising, Summit."*
- **One-Time Minimum Amount ({tier})** — helptext: *"The minimum gift amount for a single transaction to qualify for this donor grouping. Your administrator controls this threshold. Updating it automatically recalculates the giving level across all Gift Transactions."*
- **Annual Minimum Amount ({tier})** — helptext: *"The minimum fiscal-year giving total for a donor to qualify for this donor grouping annually. Your administrator controls this threshold. Updating it automatically recalculates the annual giving level across all Donor Gift Summary records."*
- **Lifetime Minimum Amount ({tier})** — helptext: *"The minimum lifetime giving total for a donor to qualify for this donor grouping. Your administrator controls this threshold. Updating it automatically recalculates the lifetime giving level across all Donor Gift Summary, Gift Commitment, and related records."*

Footer block:

> **Need a new grouping?** This flow only edits the three included donor groupings. To add a brand-new donor grouping, go to **Setup → Custom Metadata Types → FQS Donor Grouping → Manage Records**.
>
> Additional donor groupings may require you to review and edit fields on Donor Gift Summary, Gift Commitment, and Gift Transaction as well as flow automations dependent on those fields.

#### Screen: Thresholds queued (success)

> **Your changes are being deployed.**
>
> Donor grouping updates run in the background, so the new values may take up to a minute to appear on records.
>
> **Need a new donor grouping?** Go to Setup → Custom Metadata Types → FQS Donor Grouping → Manage Records.

---

## Section 4. Configure Stewardship Response Settings

Two parts: a rich-text explainer, then an embedded flow.

### Rich-text explainer on the Home Page

> **Stewardship Response settings**
>
> Once your donor groupings are defined, use this to decide how the follow-up stewardship touch is delivered for each grouping. Options per grouping:
>
> - **Include All** — every gift in this grouping gets an automated stewardship email.
> - **Exclude Lifetime** — email for most donors in this grouping, but if the donor is already a lifetime major donor, route the gift to a task for personal follow-up instead.
> - **Exclude All** — every gift in this grouping goes to a task for personal follow-up.
>
> Email opt-outs on the donor's Contact always override these settings — those gifts always route to a task.
>
> **Important:** these settings only take effect after you activate the **FQS Stewardship Response** scheduled flow (Setup → Flows).

### Embedded flow: FQS Setup — Stewardship Response Settings

[`FQS_Setup_Stewardship_Response_Settings`](../force-app/main/default/flows/FQS_Setup_Stewardship_Response_Settings.flow-meta.xml).

Flow description: *"Picks per-donor-grouping automatic stewardship routing (Include All / Exclude Lifetime / Exclude All) with a 'set all to same' shortcut. Governs the tier-differentiated stewardship touch fired by the FQS Stewardship Response scheduled flow ~14 days after acknowledgement — NOT the acknowledgement itself (acknowledgement is universal)."*

#### Screen: Automatic Stewardship Routing

Education block:

> **How automatic stewardship routing works**
>
> Every donor with a valid email receives an initial acknowledgement (a "we got your gift, thanks, here is your deduction info" receipt) — that flow is universal and has no per-grouping settings. About two weeks later, the *FQS Stewardship Response* scheduled flow runs a relationship-deepening touch, and each qualifying gift is routed to one of two paths — an automatic stewardship **email** to the donor, or a **task** for a fundraiser to follow up personally. The setting below controls that stewardship decision for each donor grouping.
>
> - **Include All** — every gift in this donor grouping is eligible for an automatic stewardship email.
> - **Exclude Lifetime** — automatic stewardship email for most donors in this donor grouping, *but* if the donor is already a lifetime major donor, route the gift to a task instead.
> - **Exclude All** — every gift in this donor grouping goes to a task for personal follow-up.
>
> Email opt-outs on the donor's Contact always override these settings — those gifts always route to a task.
>
> **Important:** these settings only take effect after you activate the **FQS Stewardship Response** scheduled flow. If it's inactive, no stewardship touches will fire regardless of what you choose here.

Controls:

- Checkbox: **Apply one setting to all three donor groupings**
- Three per-tier dropdowns (visible when the "apply one" box is off): **Major donor grouping stewardship**, **Mid donor grouping stewardship**, **Entry donor grouping stewardship**. All three dropdowns share the same helptext: *"Determines whether a gift in the {tier} donor grouping triggers an automatic stewardship email (Include All), a personal-touch task (Exclude All), or a lifetime-escalating hybrid (Exclude Lifetime). Applies to the stewardship follow-up ~14 days after acknowledgement, not the acknowledgement itself."*
- One shared dropdown: **Stewardship setting for all donor groupings** — visible only when the "apply one" box is on.

All dropdowns list: Include All / Exclude Lifetime / Exclude All.

#### Screen: Settings queued (success)

> **Your changes are being deployed.**
>
> Stewardship setting updates run in the background, so the new values may take up to a minute to appear on records.
>
> **Reminder:** the automatic stewardship settings you chose only take effect after the **FQS Stewardship Response** scheduled flow is activated. If you have not yet activated it, do so from Setup → Flows.

---

## Section 5. Enter Gift Batches with Gift Entry Grid

Rich-text only. No embedded flow.

> The Gift Entry Grid is a spreadsheet-style data entry tool. It's the right tool when you have a stack of gifts to enter that share a shape — a mail-in batch of pledge payments or an event-registration list. You can also use Grid to quickly enter single gifts from any Account Record.
>
> Consider using grid when:
>
> - **You're working from a batch** — a physical mail run, a bank download, an event registration export.
> - **Your volume is steady** — you enter gifts every day or week and the throughput matters.
> - **A dedicated data-entry person or team owns the workflow** — someone who has learned the shortcuts and knows which template to pick.
>
> If these don't apply consider Guided Gift Entry. Guided Gift Entry provides a form based entry tool, more clicks and less flexible but more direction for the user.
>
> **Templates that ship with FQS**
>
> Every template pre-selects the right columns for the shape of gift being entered. Pick the one that matches your batch:
>
> - **Individual Outright Gifts** — One-time cash, check, or card gifts. No pledge, no schedule — a single completed transaction per row.
> - **Single Payment Pledges** — a pledge commitment with only one expected payment. Creates the parent Gift Commitment and its first (and only) Gift Transaction in a single row. Includes match-eligibility and restriction fields.
> - **Pledge Payments** — individual payments applied against pledges that already exist. Each row picks a commitment; designations cascade from the commitment's defaults.
> - **Event Registrations** — ticket / registration payments where part or all of the amount is fee-for-service. Includes a Fair Market Value column so the deductible portion can be split from the goods-received portion.
> - **Undefined Batch** — uses the default Salesforce Standard Template, a clean baseline that mirrors what Salesforce ships out of the box with no FQS columns added. Use it as a starting point when you want to build your own template from scratch.
>
> **How to launch:** open Gift Batches, click **New**, pick the template that fits your batch, set expected total and count, then use the grid to enter rows. FQS ships a batch record page with step-by-step instructions for defaults, entry, dry-run, and processing.

---

## Section 6. Review Guided Gift Entry

Rich-text only. No embedded flow.

> **Guided Gift Entry is for one-off grants, pledges, gifts or other transactions.**
>
> Guided entry walks a user through a single gift one screen at a time. It is a form based experience asking questions to ensure your gift is entered accurately. Based on the donor, it suggests campaigns that the donor is a member of, identifies employers for matching gifts, and provides a list of related individuals. Consider guided gift entry when:
>
> - **You have a one-off gift** — a major-gift check hand-delivered or a pledge phoned in.
> - **Your volume is inconsistent** — some weeks you enter twenty gifts, other weeks two. For those slow weeks the guided entry might be all that's needed.
> - **Your staff is small** — anyone on the team may need to enter a gift, and they shouldn't have to memorize which columns go with which gift shape.
> - **The pledge/grant is complex** — Guided Gift Entry can support a custom pledge/grant schedule where either the dates are inconsistently spaced and/or the amounts are not evenly divided.
>
> **Categories**
>
> Guided entry starts by asking *what kind of gift are you recording?* The three top-level categories:
>
> **1. Log an individual gift transaction**
>
> - **Outright Gift** — a one-time cash / check / card gift, not tied to a pledge.
> - **Pledge Payment** — a payment applied against an existing active commitment. Pick which commitment; designations cascade from its defaults.
> - **Recurring Gift** — a set amount is given every month with no fixed end date, typically created through an integration with an online form tool.
>
> **2. Set up a pledge or grant**
>
> - **Single Payment** — creates a pledge and a single payment to be given at a later date.
> - **Multiple Payment Pledge** — a pledge with more than one expected payment. Either with even installments (monthly, quarterly, yearly) over a defined period or on a custom schedule. A custom schedule is needed when the dates are not on a regular cadence and/or the amounts are not evenly divided.
>
> **3. Log an in-kind, earned income, or event registration**
>
> - **In-Kind Gift** — a donation of goods, services, stock, or property. Records a Fair Market Value and flags the gift as in-kind so it's excluded from cash rollups.
> - **Earned Income** — program-service revenue, honoraria, sponsorship where goods or services were exchanged. Kept out of donor-lifetime rollups.
> - **Event Registration** — ticket revenue where the deductible portion is smaller than the amount paid. Fair Market Value marks the goods-received portion; the difference is the tax-deductible gift.
>
> **How to launch:** use the **Guided Gift Entry** section in the right-hand sidebar of this Home page, the quick action on any donor Account, or the quick action on a Gift Commitment (for pledge payments) or Opportunity (for pledge set-up).

---

## Section 7. Guidance on Stewardship, Acknowledgements, and Tax Receipting

Rich-text only.

Internal Note: I need to add in a section to explain the distinction between

Acknowledgement: An immediate response to a donation for the purpose of receipt.

Stewardship: A welcome and appreciation, to deepen their connection to the mission.

Tax Receipting: A year end or per gift communication for the purpose of the donor's taxes. May or may not be the same acknowledgement. 


> **How FQS thinks about gift dates**
>
> FQS separates two ideas that many orgs blur together:
>
> - **Transaction Date** — when the gift is fully in your hands and reconciled. Check cleared, card settled, wire received, stock sold, in-kind item taken in. This is your canonical "when did this gift happen" date and drives cash-flow reporting, aging, and rollups on the parent commitment.
> - **Donor Tax Date** — when the gift left the donor's control for tax-receipt purposes. Postmark date for a mailed check, charge date for a card, delivery date for stock. This is the date on the donor's receipt for tax purposes.
>
> Many orgs don't have a meaningful gap between the two — low volume, mostly card gifts, jurisdictions that treat receipt as the acknowledgement date. In those cases, leave **Donor Tax Date** blank and let **Transaction Date** speak for both. FQS's acknowledgement, stewardship, and tax-receipting flows use Transaction Date as the anchor.
>
> **Other date fields on a gift**
>
> - **Acknowledgement Date** — when the donor was thanked. Written automatically by the FQS Gift Acknowledgement flow.
> - **Tax Receipt Date** — when the year-end tax receipt was issued. Manual field; managed by whatever year-end receipting process your org runs.
> - **Stewardship Date** — when the follow-up stewardship touch was delivered. Written automatically by the FQS Stewardship Response flow.

---

## Section 8. Update Home Page

Rich-text only.

> **Make this Home page your own.**
>
> Once your setup is complete, edit this Home page to fit your team's workflow. Common changes:
>
> - Delete this Setup accordion once initial configuration is done, or leave parts of it in place — some setup flows are useful whenever you re-tune thresholds or add a new fiscal year's Gift Designations.
> - Swap the *Opportunities Needing Action* and *Gift Commitments Needing Action* list views for filters that match the queues your team actually works — overdue pledge installments, gifts pending acknowledgement, major-gift Opportunities in your assigned portfolio.
> - Point the Process Documentation section at your organization's internal wiki or doc so new staff have a single place to land.
>
> **How to edit:** from any Home page, click the gear icon in the top-right → **Edit Page**. That opens Lightning App Builder where you can drag components, edit rich-text, and change list-view filters. Activate the edited page for your app / profile / org when done.

---

# Part 2 — Bottom-right accordion

## Acknowledgments

> **Acknowledgment queue**
>
> List View

## Stewardship

> Placeholder

---

# Part 3 — Sidebar accordion

## Glossary

> **Opportunity**
>
> - A major gift cultivation plan
> - A grant prospect
>
> **Gift Commitment**
>
> - A pledge to give at a later date
> - A regular recurring gift
>
> **Gift Transaction**
>
> - An outright gift
> - An inkind gift
> - A fee for service or goods
>
> **Campaign**
>
> - A solicitation, appeal, event invite or any action where you want to track who you asked and what gifts resulted from that ask.
>
> **Designation**
>
> - A fund, with or without restriction.

## Process Documentation

> This is a spot for your organization to customize and add your own process documentation for end users.
>
> Salesforce Nonprofit Help: [https://help.salesforce.com/s/products](https://help.salesforce.com/s/products)
>
> Community Commons Best Practice: [https://sfdo-community-sprints.github.io/npc-best-practices/fundraising/](https://sfdo-community-sprints.github.io/npc-best-practices/fundraising/)


## Create Gift Batch (sidebar launcher)

Embeds the **FQS Create Gift Batch** flow ([`FQS_Create_Gift_Batch`](../force-app/main/default/flows/FQS_Create_Gift_Batch.flow-meta.xml)).

Flow description: *"Home-page launcher that creates a new GiftBatch from three inputs: template, estimated value, and estimated gift count. Auto-number Name field is populated by the platform on insert."*

### Screen: Create a Gift Batch (input)

Intro block:

> **Start a new Gift Batch.**
>
> Pick the template that matches the shape of gifts you're about to enter, then estimate the count and total value so the batch can reconcile against your source (deposit slip, event roster, mail run) during dry-run and processing.

Fields:

- **Screen Template** (radio, required) — helptext: *"The template controls which columns appear on every row of the grid. You can't change the template after the batch is created — if you pick the wrong one, delete the batch and start again."*
  - **Individual Outright Gifts** — one-time cash, check, or card gifts. No pledge, no schedule; a single completed transaction per row.
  - **Single Payment Pledges** — a pledge commitment with only one expected payment. Creates the parent Gift Commitment and its first (and only) Gift Transaction in a single row. Includes match-eligibility and restriction fields.
  - **Pledge Payments** — individual payments applied against pledges that already exist. Each row picks a commitment; designations cascade from the commitment's defaults.
  - **Event Registrations** — ticket / registration payments where part or all of the amount is fee-for-service. Includes a Fair Market Value column so the deductible portion can be split from the goods-received portion.
  - **Undefined Batch** — uses the default Salesforce Standard Template, a clean baseline that mirrors what Salesforce ships out of the box with no FQS columns added. Use it as a starting point when you want to build your own template from scratch.
- **Estimated Batch Value** (currency, required) — helptext: *"The total dollar value you expect this batch to add up to — from your deposit slip, event ticket roster, or the sum of the checks in front of you. Dry-run compares this against the sum of entered gifts and flags a mismatch."*
- **Estimated Gift Count** (number, required) — helptext: *"The number of gift entries you expect to add to this batch. Dry-run compares this against the actual row count and flags a mismatch."*

### Screen: Success - Gift Batch Created

> ✓ **Gift Batch created.**
>
> Open the batch to set defaults, then start entering gifts. Dry-run and process from the batch record page when you're ready.
>
> **Open the new Gift Batch →** (link to the new record)
>
> *Click **Finish** to close, or open the record above to keep working.*

## Guided Gift Entry (sidebar launcher)

Embeds the **FQS Gift Entry Guide — Universal** flow ([`FQS_Gift_Entry_Guide_Universal`](../force-app/main/default/flows/FQS_Gift_Entry_Guide_Universal.flow-meta.xml)).

The Universal launcher's only home-page-facing copy is the first screen (shown only when launched from Home with no Account context — the Account quick-action launch skips it):

### Screen: Pick a Donor

> **Who is this gift for?**
>
> Pick the Account of the donor, household, or organization giving the gift. You can search by name.

Field label: **Donor Account**

After the donor is picked, the flow hands off to the shared monolith `FQS_Gift_Entry_Single_Launcher_Account`. That monolith's own copy (category picker + leaf-specific screens for Outright / Pledge / Recurring / Grant / In-Kind / Earned Income / Event Registration) is out of scope for this Home-Page review — it's the same copy shown when a user launches guided entry from a donor's Account record.

# 

End of document

If you spot a wording change or a copy issue, mark it inline (or leave a note where you'd like it) and I'll edit the flexipage / flow metadata to match.
