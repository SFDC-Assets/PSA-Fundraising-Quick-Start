# FQS Home Page — All Copy, for Review

**Purpose:** every user-visible string on the FQS Home Page (`FQS_Home_Page_Default`) plus every user-visible string in the flows embedded on it, extracted verbatim, for external review.

**Source of truth:** [`force-app/main/default/flexipages/FQS_Home_Page_Default.flexipage-meta.xml`](../force-app/main/default/flexipages/FQS_Home_Page_Default.flexipage-meta.xml) and the flows referenced below. If you spot a change you want made, mark it inline and we'll edit the metadata.

**Doc last synced from org:** 2026-08-17.

**What's NOT here:** list-view column labels, dashboard visuals, standard Salesforce component chrome (component headers like "Recent Records" that Salesforce writes automatically), and per-leaf copy inside the shared `FQS_Guided_Gift_Entry_Account` monolith (that's a separate review — this doc only covers the Home Page's own copy and the *front matter* of the embedded launchers).

---

## Home Page layout at a glance

The Home Page has four regions:

- **Top region — Tabs.**
  - Tab 1: **FQS Set Up** — a 9-section accordion. Sections 1, 2, 3, 6, 7 each embed a Setup or guidance flow. Sections 4, 5, 8, 9 are pure rich-text guidance.
  - Tab 2: **Dashboard** — embeds the `FQS_Donor_Tiers` dashboard. No FQS copy.
- **Bottom-left region — Accordion.**
  - **Opportunities Needing Action** — Opportunity list view (`MyOpportunities`). No FQS copy.
  - **Gift Commitments Needing Action** — Gift Commitment list view (`FQS_Past_Due_Installments`). No FQS copy.
- **Bottom-right region — Accordion.**
  - **To Be Acknowledged** — Gift Transaction list view (`FQS_To_Be_Acknowledged`). No FQS copy.
  - **To Be Stewarded** — Gift Transaction list view (`FQS_To_Be_Stewarded`). No FQS copy.
- **Sidebar region — Accordion.**
  - **Recent Records** — standard Salesforce component. No FQS copy.
  - **Glossary** — rich-text.
  - **Process Documentation** — rich-text + two external links.
  - **Create Gift Batch** — embeds `FQS_Create_Gift_Batch` flow.
  - **Guided Gift Entry** — embeds `FQS_Guided_Gift_Entry_HomePage` flow.
  - **Today's Tasks** — standard Salesforce component. No FQS copy.

---

# Part 1 — FQS Set Up tab

## Section 1. Set Up Gift Designations

Embeds the **FQS Suggest Designations** flow ([`FQS_Suggest_Designations`](../force-app/main/default/flows/FQS_Suggest_Designations.flow-meta.xml)).

Flow description: *"Setup-time Screen Flow that seeds a starter Gift Designation catalog. Admin sees a datatable pre-populated with 14 curated starter designations across the four restriction categories; each row has editable Name + Description and a read-only Restriction Type badge. User un-ticks any they do not want, edits any names/descriptions inline, and clicks Next to insert the selected rows via recordCreates. Idempotent: queries existing designations by Name and silently omits any already present in the org, so the flow can be re-run to top up missing starters."*

### Screen: Seed Your Gift Designation Catalog (intro)

> **Review Suggested Designations.**
>
> Gift Designations help you record and understand donor intent, and in some cases the reason behind the gift. In the next screen you will see a set of suggested designations, choose the ones that make the most sense for your organization.
>
> All organizations will need one default designation, typically an unrestricted or general operating fund. Beyond that, designations can be used to track a variety of purposes (specific programs or specific expense categories) or for permanent restrictions. Typically designations are not created for time-based restrictions, those are set on the gift itself through entering the 'Restriction Release Date'.
>
> On the next screen, pick which designations serve your organization's needs. These are meant to be a starter set, with some generic names, you can rename and manually edit any of these later from the Gift Designation record page.
>
> *This release ships 14 starter entries across the four restriction categories: Without Donor Restriction, With Donor Restriction - Purpose, With Donor Restriction - Permanent, and Earned Revenue.*
>
> *This flow is safe to re-run. Any starter designation already in your org (matched by exact Name) is skipped, and only the new picks are created. Re-run any time to add designations you unchecked earlier.*

### Screen: Review Starter Designations

> Every starter designation missing from your org is pre-selected below. Un-tick any you do not want. Edit Name or Description inline; Restriction Type is fixed for these starters and can be changed later from the record page.
>
> *A note on time restrictions: FQS deliberately does not offer a "With Donor Restriction - Time" category on the designation. A designation names what the money is for, not when it becomes spendable. Time boundaries (e.g., FY2027, or "hold until the building opens") belong on the individual gift instead, on the **Restriction Release Date** field on the Gift Commitment or Gift Transaction. That lets one purpose-restricted designation (e.g., "Building Fund") carry gifts with many different release dates without proliferating year-suffixed designations.*

Datatable columns: **Name** (editable), **Description** (editable), **Restriction Type** (read-only, sourced from `FQS_Restriction_Type__c`).

The 14 starter rows the flow stages (verbatim Name + Description):

#### Without Donor Restriction

- **FQS General Operating Fund** *(default)* — The unrestricted default. Every FQS install ships with this as the org-wide default so the platform's activate-schedule action has a fallback designation.
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

### Screen: Starter Catalog Already Complete (empty-outcome)

> **Every starter designation is already in your org.**
>
> Nothing to do here. Click Finish to exit. To add non-starter designations, create them directly on the Gift Designation object.

### Screen: No Rows Selected (empty-selection warning)

> **No rows were selected.**
>
> Nothing was created. Click Previous to select at least one row, or Finish to exit without creating any designations.

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

Flow description: *"Guides an admin through picking a model (Seasonal, Giving Programs, or Audience), one or more year cohorts (last/this/next as multi-select), then Strategic/Operational/Tactical campaigns via native MultiSelectCheckboxes. Tactical choices are filtered by the parent picks so only children whose parent was chosen appear. Invokes FQS_CampaignHierarchyBuilder.build once per selected year and aggregates counts + created campaigns."*

### Screen: Step 0 — Learn About Campaigns

**Block 1 — What are campaigns?**

> Campaigns help you track solicitation for gifts and general outreach to the individuals your organization cares about. Put another way, campaigns are where you track asks to your supporters or outreach that could result in a donation immediately or in the future. The ask can be to donate in response to a letter, an invite to an event, or a request to have a one-on-one meeting — all of these can be tracked as a campaign, especially if the ultimate goal is to cultivate donors.
>
> You can add individuals to a campaign in a number of ways — directly from their record, through a data import, or by running a report. When you add them to a campaign, you create a campaign member record with a status that indicates they were asked but have not yet responded.
>
> When you enter a pledge or a gift, you can associate it with a campaign. The donor's campaign member record is updated to indicate they donated. You can also set up default designations at a campaign level. This lets your organization track who you asked and how they responded.

Next button label: **Next: Campaign Hierarchy**

**Block 2 — What is a campaign hierarchy?**

> Effective fundraising coordinates and reinforces asks through different channels and through a series of messages. For this reason, creating parent campaigns to organize your asks is helpful. This lets you see, monitor, and report on how your tactics are operating. Native fields like "Responses in Hierarchy" and "Contacts in Hierarchy" provide easy metrics to track, and standard reporting extends this further. We recommend your operational campaigns roll up to a campaign that represents your overall strategy.
>
> To recap, we recommend a three-level campaign hierarchy:
>
> - **Level 1 — Strategic:** the organizing anchor (a year or a program).
>   - **Level 2 — Operational:** a coordinated set of asks — the level most staff watch while a campaign is running.
>     - **Level 3 — Tactical:** one concrete solicitation sent to one audience.
>
> A campaign hierarchy can be five records deep, but we recommend using only three. When running an a/b test on solicitation or when you are coordinating a solicitation between multiple different platforms (physical mail, web, social, etc), consider using Outreach Source Codes before adding another layer of child campaigns.

Back button label: **Back: Campaigns** — Next button label: **Next: Hierarchy Choices**

**Block 3 — What campaign hierarchy model is right for your organization?**

> Three ways to structure your campaign hierarchy — pick the one that matches how your team plans. These are starting points; most organizations will add campaigns beyond what's shown here. This flow gets you a working baseline; you can extend it with manual record creation as your program grows.
>
> On the next screen we will give you three choices:
>
> - Seasonal / Yearly — strategy is formed yearly and giving programs are at the operational level. This model is best for year-over-year reporting and for smaller staffs.
> - Giving Programs — giving programs at the top, allowing the second level to track specific operational elements. This model is best when programs are staffed separately.
> - Audience — strategy is formed yearly and donor segment is the operational component. Best when your team plans by donor segment (lapsed, mid-level, acquisition).

Radio gate — Label: "I am ready to set up my campaign hierarchy"

- "Yes, I know what campaign hierarchy to choose."
- "No, I need to think further."

Back button label: **Back: Campaign Hierarchy** — Next button label: **Next: Set Up Hierarchy or Exit**

### Screen: Step 1 of 5 — Choose Your Campaign Model

Radio field — Label: **Campaign Hierarchy Choices**

Helptext: *"Seasonal: year totals and year-over-year comparisons are one filter away. Giving Programs: each program's lifetime performance is one filter away. Audience: donor-segment performance is the primary lens."*

Options:

- **Giving Programs** — giving program at level 1, year at level 2, best when programs are staffed separately
- **Seasonal / Yearly** — year at level 1, giving program at level 2, best for year-over-year reporting and for smaller staffs
- **Audience** — year at level 1, donor segment at level 2, best when your team plans by audience (lapsed, mid-level, acquisition)

A model-specific sample outline is shown based on the pick:

**Seasonal / Yearly — sample shape**

- **FY26 Fundraising** (Strategic)
  - Spring Appeal FY26 (Operational) — Spring Appeal Email, Spring Appeal Direct Mail, Spring Appeal Follow-up Email (Tactical)
  - Annual Celebration FY26 (Operational) — Save-the-Date, Formal Invitation, Sponsorship Packet, RSVP Reminder (Tactical)
  - Year-End Push FY26 (Operational) — Giving Tuesday Email, December Reminder SMS, Year-End Match Email, New-Year's-Eve Push (Tactical)
  - Foundation Giving FY26 (Operational) — LOI Submissions, Grant Applications (Tactical)

**Giving Programs — sample shape** (each program is an evergreen Strategic-level rollup; every year, an Operational year-cohort campaign is created underneath, with its own Tactical asks):

- **Major Gifts** (Strategic) → FY26 Major Gifts (Operational) → Portfolio Solicitations, Prospect Discovery Visits, Stewardship Touchpoints (Tactical)
- **Annual Giving** (Strategic) → FY26 Annual Giving (Operational) → Direct Mail Renewals, Email Renewal Series, Sustainer Upgrade Asks (Tactical)
- **Online Giving** (Strategic) → FY26 Online Giving (Operational) → Peer-to-Peer Campaign, Web Donation Form Traffic (Tactical)
- **Events** (Strategic) → FY26 Events (Operational) → Annual Gala, Small Fundraising Events (Tactical)
- **Foundation Giving** (Strategic) → FY26 Foundation Giving (Operational) → LOIs Submitted, Grant Applications (Tactical)
- **Planned Giving** (Strategic) → FY26 Planned Giving (Operational) → Legacy Society Outreach, Bequest Intent Follow-ups (Tactical)

**Audience — sample shape**

- **FY26 Donor Strategy** (Strategic)
  - Lapsed Reactivation (Operational) — Win-Back Direct Mail, Win-Back Email Series (Tactical)
  - New Donor Acquisition (Operational) — Cold Mail Acquisition, Digital Ads (Tactical)
  - Retention & Stewardship (Operational) — Thank-You Series, Impact Report (Tactical)
  - Mid-Level Cultivation (Operational) — Personalized Ask Letters, Small-Group Cultivation Events (Tactical)
  - Foundation Giving (Operational) — LOIs Submitted, Grant Applications (Tactical)

Next button label: **Next: Choose the Year**

### Screen: Step 2 of 5 — Choose the Year

> **Which year(s) are you building for?**
>
> Check one or more years — the same template picks will be created under each. **Last year** is useful for backfilling historical reporting. **This year** is the default. **Next year** lets you pre-stage the coming fiscal year before it starts. Building multiple years at once is helpful when pre-staging a rollover or backfilling for reporting. The year label follows your org's Fiscal Year setting (CY vs FY).

Multi-select checkboxes — Label: **Year Cohort(s)**

Helptext: *"Check one or more years. Each checked year creates its own copy of the selected hierarchy. Last = -1, This = 0, Next = +1 relative to the org's current fiscal year."*

Options (default: This year): **Last year**, **This year**, **Next year**.

Back button label: **Back: Choose Campaign Model** — Next button label: **Next: Pick Strategic + Operational**

### Screen: Step 3 of 5 — Pick Strategic + Operational Campaigns

> **Pick the parent campaigns to create.**
>
> In the **Giving Programs** model, the first section lists the program-level (Strategic) campaigns — check which programs you run. In every model, the operational section picks the mid-tier campaigns that live under the Strategic level. Your picks here filter which Tactical campaigns show up next — only children whose parent you checked will be available.

Two multi-select checkbox groups populated dynamically from `FQS_Campaign_Template__mdt`:

- **Programs (Level 1 — Strategic)** — visible only in Giving Programs model. Helptext: *"Check the program-level (Strategic) campaigns to create. Only visible for the Giving Programs model — Seasonal and Audience models auto-create a single top-level Strategic campaign."*
- **Operational Campaigns (Level 2)** — visible in Seasonal and Audience models. Helptext: *"Check the operational campaigns to create. Defaults follow the standard shape for your model; uncheck defaults or check additional library items."*

Back button label: **Back: Choose the Year** — Next button label: **Next: Pick Tactical Campaigns**

### Screen: Step 4 of 5 — Pick Tactical Campaigns

> **Pick the tactical campaigns (Level 3) to create.**
>
> Each tactical campaign is a concrete solicitation — a letter, an email, an event invite. Only tactics whose parent you picked in the previous step appear here. Defaults reflect the standard shape for the model you chose. Uncheck any you don't need, or check additional library items. Leaving every tactic unchecked skips level 3 entirely.

Multi-select checkbox group — Label: **Tactical Campaigns (Level 3)**

Helptext: *"Check the tactical campaigns to create. Defaults follow the standard shape for your model; you can uncheck defaults or check additional library items."*

Back button label: **Back: Pick Strategic + Operational** — Next button label: **Next: Confirm and Build**

### Screen: Step 5 of 5 — Confirm and Build

Two variants depending on model (Giving Programs shows level-1 count; Seasonal / Audience always shows 1 Strategic).

> **Ready to build your campaign hierarchy?**
>
> **Model:** {model} **Year(s):** {year label} ({selected year count})
>
> **You're about to create:**
>
> - **{n}** Strategic (Level 1) campaign(s) — shared across years (Giving Programs variant only)
> - **{n}** Operational (Level 2) campaign(s)
> - **{n}** Tactical (Level 3) campaign(s)
>
> Clicking **Next** will create the records. On the next screen you'll see the full hierarchy in a table for review — including whether the Auto Members checkbox got set on each Tactical row. Any renames or date changes can be made from each Campaign's record page after the flow finishes.

Back button label: **Back: Pick Tactical Campaigns** — Next button label: **Build the Campaigns**

### Screen: Review + Edit Campaign Records (success)

> **Your campaigns have been created.**
>
> Model: **{model}** Strategic (Level 1) created: **{n}** Operational (Level 2) created: **{n}** Tactical (Level 3) created: **{n}** Default Outreach Source Codes created: **{n}**
>
> Review the records below. Rename or reschedule any campaign from its record page after this flow finishes. Click **Next** to finish.

Datatable "Created Campaigns" — columns: Name (editable), Campaign Category, Start Date, End Date, Ultimate Parent Campaign, Parent Campaign ID, Hierarchy Depth, Auto Members Enabled.

Next button label: **Next: Wrap Up**

### Screen: Campaign Hierarchy — Done (final)

> **All set — your campaign hierarchy is ready.**
>
> Model: **{model}** Strategic (Level 1) created: **{n}** Operational (Level 2) created: **{n}** Tactical (Level 3) created: **{n}** Default Outreach Source Codes created: **{n}**
>
> **Your campaign hierarchy is live in the org.**
>
> **Next steps:**
>
> - Head to the Campaigns tab and add details to your campaign. In addition to completing the fields, you may also want to:
>   - Review the Campaign Member Statuses records — you can modify these statuses or add additional ones.
>   - Create Default Gift Designations records.
>   - All tactical campaigns have "Enable Automatic Campaign Members" that will add individuals to a campaign or update to a responded status, if their gift is attributed to that campaign.
>   - A single Outreach Source Code may have been created for some tactical campaigns. By checking the Create First Outreach Source Code, you will fire an automation that creates a single record to begin defining audience segments.
>
> **Considerations:**
>
> - When it's time to build next year's campaigns, use Salesforce's built-in Campaign clone on the top-level record — this flow is first-run-per-year only.
> - Outside of the Gift Entry Grid, Guided Gift Entry, or the integrations using the Fundraising Business Process API, the default gift designations from a campaign will not be copied to the gift commitment or gift designation.
> - Need to track A/B tests, different channels, or granular audience segments? Add more Outreach Source Codes from the campaign record to get more detail on your Tactical (Level 3) campaigns.

Next button label: **Done: Close Flow**

### Screen: Campaign Hierarchy — Error

> **There was a problem building your campaign hierarchy.**
>
> `{!varErrorMessage}`
>
> Click the button below to return to the start and try again.

Back button label: **Back: Confirm and Build** — Next button label: **Retry: Choose Campaign Model**

---

## Section 3. Define Donor Tiers and Thresholds

Embeds the **FQS Setup — Donor Tier Thresholds** flow ([`FQS_Setup_Tier_Thresholds`](../force-app/main/default/flows/FQS_Setup_Tier_Thresholds.flow-meta.xml)). No rich-text explainer above the flow — the flow's first screen carries the explainer.

Flow description: *"FQS Setup Flow — donor tier thresholds only. Bulk-edits the tier $ thresholds (One-Time / Annual / Lifetime) and branded name for the three seeded FQS_Donor_Tier__mdt rows (Entry / Mid / Major). Companion flow FQS_Setup_Stewardship_Response_Settings governs the stewardship-routing side (Include All / Exclude Lifetime / Exclude All). Writes go through the FQS_CustomMetadataSaver Apex bridge, which enqueues a single asynchronous Metadata API deployment for all three donor tiers. New donor tiers must still be added manually via Setup → Custom Metadata Types → FQS Donor Tier."*

### Screen: Donor Tier Thresholds

Header block:

> **What donor tiers do for you**
>
> Donor tiers sort every donor into one of three levels — Entry, Mid, and Major — based on the size of their gifts. The tier drives acknowledgement copy, stewardship routing, gift-level formulas, and the reports and dashboards that ship with FQS.
>
> Each tier has three dollar bands you can tune: **One-Time** (a single gift big enough to qualify), **Annual** (fiscal-year cumulative giving), and **Lifetime** (all-time cumulative giving). A donor lands in the highest tier they qualify for on any of the three bands.
>
> You can also rebrand the tier names — use *Friend / Partner / Champion* if that fits your voice better than Entry / Mid / Major.
>
> **Adjust the giving thresholds for each donor tier to fit your organization.**
>
> These thresholds decide which donor tier a gift falls into based on the donor's one-time, annual, and lifetime giving. Each tier also has a **Credit Type** setting that controls whether soft-credit totals (spouse-attributed gifts, foundation-driven gifts recognized to the donor) count toward that tier alongside the donor's own gifts. Different tiers can have different Credit Type settings.
>
> Changes take up to a minute to appear after you finish this flow — FQS writes the new thresholds to Custom Metadata, which the platform deploys asynchronously.

Then three sections (**Major**, **Mid**, **Entry**), each with sub-header "What does your organization consider to be a {tier}-level gift?" and five fields:

- **Branded Name ({tier})** — helptext: *"The branded name of the Tier Key shown to staff and donors in reports, dashboards, and the Donor Gift Summary record page. Changing this value here automatically updates FQS_Donor_Level_Name__c on all Donor Gift Summary records. Example values: Friend, Partner, Champion or Entry, Rising, Summit."*
- **One-Time Minimum Amount ({tier})** — helptext: *"The minimum gift amount for a single transaction to qualify for this donor tier. Your administrator controls this threshold. Updating it automatically recalculates the giving level across all Gift Transactions."*
- **Annual Minimum Amount ({tier})** — helptext: *"The minimum fiscal-year giving total for a donor to qualify for this donor tier annually. Your administrator controls this threshold. Updating it automatically recalculates the annual giving level across all Donor Gift Summary records."*
- **Lifetime Minimum Amount ({tier})** — helptext: *"The minimum lifetime giving total for a donor to qualify for this donor tier. Your administrator controls this threshold. Updating it automatically recalculates the lifetime giving level across all Donor Gift Summary, Gift Commitment, and related records."*
- **Credit Type ({tier})** — radio: "Hard Credits Only" / "Hard + Soft Credits". Helptext (Major variant): *"Choose which giving totals count toward the Major tier. Hard Credits Only counts the donor's own gifts (TotalGiftsAmount / GiftsThisYearAmount + FQS legacy hard credits). Hard + Soft Credits also counts soft-credit totals (spouse-attributed gifts, foundation-driven gifts recognized to the donor). Different tiers can have different settings — e.g., Major counts soft credits while Entry stays hard-only."*

Footer block:

> **Need a new tier?** This flow only edits the three included donor tiers. To add a brand-new donor tier, go to **Setup → Custom Metadata Types → FQS Donor Tier → Manage Records**.
>
> Additional donor tiers may require you to review and edit fields on Donor Gift Summary, Gift Commitment, and Gift Transaction as well as flow automations dependent on those fields.

### Screen: Thresholds queued (success)

> **Your changes are being deployed.**
>
> Donor tier updates run in the background, so the new values may take up to a minute to appear on records.
>
> **Need a new donor tier?** Go to Setup → Custom Metadata Types → FQS Donor Tier → Manage Records.

---

## Section 4. Enter Gift Batches with Gift Entry Grid

Rich-text only. No embedded flow.

> The Gift Entry Grid is a spreadsheet-style data entry tool. It's the right tool when you have a stack of gifts to enter that share a shape — a mail-in batch of pledge payments or an event-registration list.
>
> Consider using grid when any of these are true:
>
> - **You're working from a batch** — a physical mail run, a bank download, an event registration export.
> - **Your volume is steady** — you enter gifts every day or week and the throughput matters.
> - **A dedicated data-entry person or team owns the workflow** — someone who has learned the shortcuts and knows which template to pick.
>
> Gift Entry Grid can also be used outside of a batch. The "New Gift Entry" on Account is the most streamlined way to enter an outright gift (sometimes called a cash gift, or a one-time gift).
>
> If these don't apply, consider Guided Gift Entry. Guided Gift Entry provides a form based entry tool, more clicks and less flexibility but more direction for the user.
>
> **Templates that ship with FQS**
>
> Every template pre-selects the right columns for the shape of the gift being entered. Pick the one that matches your batch:
>
> - **Individual Outright Gifts** — One-time cash, check, or card gifts. No pledge, no schedule — a single completed transaction per row.
> - **Single Payment Pledges** — a pledge commitment with only one expected payment. Creates the parent Gift Commitment and its first (and only) Gift Transaction in a single row. Includes match-eligibility and restriction fields.
> - **Pledge Payments** — individual payments applied against pledges that already exist. Each row picks a commitment; designations cascade from the commitment's defaults.
> - **Event Registrations** — ticket / registration payments where part or all of the amount is fee-for-service. Includes a Fair Market Value column so the deductible portion can be split from the goods-received portion.
> - **Undefined Batch** — uses the default Salesforce Standard Template, a clean baseline that mirrors what Salesforce ships out of the box with no FQS columns added. Use it as a starting point when you want to build your own template from scratch.
>
> **How to launch:** open Gift Batches, click **New**, pick the template that fits your batch, set expected total and count, then use the grid to enter rows. FQS ships a batch record page with step-by-step instructions for defaults, entry, dry-run, and processing.

---

## Section 5. Review Guided Gift Entry

Rich-text only. No embedded flow.

> **Guided Gift Entry is for one-off grants, pledges, gifts or other transactions.**
>
> Guided entry walks a user through a single gift one screen at a time. It's a form-based experience that asks questions to make sure the gift is entered accurately. Based on the donor, it suggests campaigns that the donor is a member of, identifies employers for matching gifts, and provides a list of related individuals. Consider guided gift entry when:
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

## Section 6. Guidance on Acknowledgement, Stewardship, and Tax Receipting

Embeds the **FQS Acknowledgement, Stewardship & Tax Guide** flow ([`FQS_Acknowledgement_Stewardship_Tax_Guide`](../force-app/main/default/flows/FQS_Acknowledgement_Stewardship_Tax_Guide.flow-meta.xml)).

Flow description: *"Read-only informational Screen Flow that paginates the acknowledgement / stewardship / tax-receipting decision guide into a walk-through. Nine screens, one per section of the doc: intro + three-activities, Q1 through Q5, working-the-process, what-ships. No inputs. No writes. No decisions. No records read. The flow does nothing beyond turning pages — it exists so the guide can be surfaced from the Home page as a flexipage:flowComponent rather than a static markdown file."*

### Screen 1: Acknowledgement, Stewardship & Tax Receipting (intro)

> **Do you need three processes or one?**
>
> Every organization has to answer this question before turning on the shipped post-gift automation. Acknowledgement, stewardship, and tax receipting overlap and can collapse into a single letter or email — but they solve different problems, and mixing them up costs donor trust and, potentially, tax-compliance standing.
>
> This guide walks you through five questions. Each answer narrows what you need to turn on.
>
> **Scope note.** Written for US-based 501(c)(3) organizations. If you operate outside the US — Canadian CRA charities, UK Gift Aid, Australian DGRs, EU equivalents — the shapes below still apply, but the specific tax-receipt rules do not. Consult your local requirements before relying on an acknowledgement as a receipt.
>
> *This is a reading guide, not a wizard. Clicking the button below only turns pages — nothing is saved, nothing is deployed, no records are touched.*

Next button label: **Next: The Three Processes**

### Screen 2: The Three Processes

> **First, the three processes.**
>
> **Acknowledgement** — the immediate "we received your gift" confirmation. Fast, transactional, universal. Every donor with a valid email gets one. Its job is to close the loop on the transaction: we got it, here's the amount, here's the date, here's your deduction info. Timing matters more than eloquence — the sooner it lands, the more the donor trusts that their gift landed where they intended.
>
> **Stewardship** — the follow-up touch that connects the donor to the mission. Ideally a thank-you, but also a story, a program update, an impact metric, an invitation to see the work. Its job is to deepen the relationship, not to restate the transaction. Voice, personalization, and channel matter more than speed. Timing can be three days to two weeks after the gift, again at year-end, or whenever the mission has something worth sharing.
>
> **Tax receipting** — the document a donor uses to substantiate a deduction. In the US, this is governed by IRS Publication 1771 and can typically be satisfied by a well-formed acknowledgement email (see Question 1). In other jurisdictions the receipt often needs its own format, sequence, and record-keeping — separate from the acknowledgement entirely.

### Screen 3: Question 1 — Acknowledgement as Tax Receipt?

> **Question 1 — Can your acknowledgement double as the tax receipt?**
>
> **In the US: usually yes**, if the acknowledgement contains the elements IRS Publication 1771 requires:
>
> - Your organization's name
> - The cash amount (or a description of non-cash property — not its value; the donor determines that)
> - One of: "no goods or services were provided in return" OR a description and good-faith fair-market value of anything provided in return
> - For **quid-pro-quo** gifts over $75 (gala tickets, auction wins, benefit dinners): the FMV of goods received, so the donor knows the deductible portion. This disclosure is required whether the donor asks for it or not.
>
> If your acknowledgement email contains all of the above for every gift ≥ $250, the acknowledgement **is** the tax receipt. No separate document required.
>
> **Sample language for a US template:**
>
> *Thank you for your gift of $[amount] received on [date]. [Organization Name] is a 501(c)(3) nonprofit organization; no goods or services were provided in exchange for this contribution. Please retain this acknowledgement for your tax records.*
>
> For quid-pro-quo gifts, swap the "no goods or services" line for a description of what the donor received and its FMV.
>
> **Salesforce also includes native gift-acknowledgement and tax-receipt functionality** — a built-in engine that generates receipt documents and handles year-end consolidation. If you need formal receipt documents (versus email-based acknowledgements), it's the shortest path.
>
> **Non-US orgs:** the answer is usually no — plan on separate receipts. Skip ahead to Question 3 if that's you.

### Screen 4: Question 2 — Online Donation Tool

> **Question 2 — Does your online donation tool already send a receipt?**
>
> Most online donation platforms send a receipt email automatically when the card charges. That receipt lands within seconds of the gift, includes the amount and date, and — if you've configured the copy — satisfies the US CWA requirement. **In practice, that receipt is often already the acknowledgement.**
>
> Two options for handling this without double-sending:
>
> - **Turn off the Gift Acknowledgement flow entirely** if your donation tool covers every gift. Simplest.
> - **Leave it on** and have your donation tool set Acknowledgement Status to "Sent." The flow only acknowledges gifts where that field is still blank, so online gifts are skipped automatically and offline gifts (checks, cash, stock, in-kind) still get covered.
>
> **Physical gifts always need something.** Checks in the mail, cash walked in, stock transfers, in-kind donations — none of these pass through your online tool, and none get an automatic receipt. If the flow is deactivated, you'll need to handle these manually. If the flow is on, it only acknowledges gifts where Acknowledgement Status is still blank or "To Be Sent."

### Screen 5: Question 3 — Mission Touch

> **Question 3 — Do you want a mission touch separate from the receipt?**
>
> The acknowledgement (or the donation tool's receipt) closes the transaction. A stewardship touch does something different: it connects the donor to the work. A three-day-to-two-week follow-up with a story, program update, or impact metric is considered table stakes in most donor-relations programs.
>
> Very few donation tools send this follow-up. Even if your donation tool handles acknowledgement end-to-end, you likely still want stewardship running.
>
> - **Yes, I want a mission touch** — turn on the Stewardship Response flow. It fires roughly 14 days after the acknowledgement. Entry-tier donors get an automated email; major donors always route to a task for personal outreach.
> - **No, the acknowledgement is enough** — leave the Stewardship Response flow off. Rewrite the acknowledgement template so it carries the mission voice too — gratitude, one line about impact, done.

### Screen 6: Question 4 — Year-End Receipts

> **Question 4 — Do you issue year-end consolidated tax receipts?**
>
> Some orgs — most commonly non-US charities, but also US orgs that prefer a single annual document — send a consolidated receipt every January covering the full prior year of giving.
>
> - **Yes** — choose a tool to help you query and format the document batch. Salesforce's native tax-receipting engine (linked in Question 1) handles year-end consolidation and is worth evaluating before you build custom.
> - **No** — skip.

### Screen 7: Question 5 — Major Donors

> **Question 5 — Do your major donors need something the automation can't do?**
>
> Automated stewardship works well for entry- and mid-tier donors. Major donors typically need a real human touch — a call from the ED, a hand-signed card, a lunch invitation, a program tour.
>
> The shipped stewardship routing already handles this: the **Major** tier is seeded to route every gift to a task in the Stewardship Tasks queue, so major-gift officers see the task and deliver the personal outreach themselves. No automated email fires for those gifts.
>
> If you want to change that — say, send all donors the same automated email regardless of tier — you can retune the routing in the FQS Setup — Stewardship Response Settings flow.

### Screen 8: Working the Process

> **Working the process — List Views, Queues, and Action Plans.**
>
> Once the flows are running, the actual work happens in Salesforce's native record and task-management tools.
>
> **List Views.**
>
> - **To Be Acknowledged** — gifts where Acknowledgement Status is blank or "To Be Sent" and the gift is old enough that the flow should have picked it up. Use this to spot gifts the automation skipped and work them by hand.
> - **To Be Stewarded** — gifts where the acknowledgement has already been sent and stewardship is still pending. Use this to see who's waiting on a mission touch.
>
> **Queues.** Four queues ship to organize the work by role. They're empty at install — add members under Setup → Queues.
>
> - **Stewardship Tasks** — mid-tier stewardship follow-ups. Email notifications: on.
> - **Gift Processing Tasks** — acknowledgements, tax receipting, and gift-entry tasks that need a human. Email notifications: on.
> - **Major Donor Tasks** — prospect research, proposal drafting, cultivation. Email notifications: off.
> - **Executive Fundraising Tasks** — handwritten notes, calls, and high-touch actions reserved for the ED or Board. Email notifications: off.
>
> The email-notification setting is a per-queue choice, not a global rule. The shipped pattern notifies the two high-volume operational queues and stays quiet on the two executive-facing queues so leadership doesn't get pinged constantly. Flip either flag on the queue record if that pattern doesn't fit your team.
>
> **Action Plans.** Two Action Plan Templates ship — both target the Account object and both install as Draft, so an admin activates them after review.
>
> - **Stewardship** — a seven-step mid-tier stewardship playbook running roughly six months, from immediate thank-you (day 3) through a mid-year impact story (day 91) and a mission-experience invitation (day 182). Steps chain on completion of the previous step.
> - **Moves Management** — an eleven-step major-donor cultivation playbook covering prospect research, discovery, cultivation, formal solicitation, proposal, gift processing, and post-ask stewardship. Steps are marked as "Moves" (donor-facing touchpoints, required) or "Tactical" (internal prep, optional).
>
> A gift officer opens the donor Account, launches the appropriate template, and works the resulting task sequence. The Action Plan record itself becomes the source of truth for that donor's cultivation or stewardship journey.

### Screen 9: What Ships

> **What ships in the Quick Start.**
>
> Two flows and three email templates. Both flows ship as drafts with placeholder templates — you'll customize the copy before go-live.
>
> **Flows (Setup → Flows):**
>
> - **Gift Acknowledgement** — runs daily at 06:00 UTC. Emails or creates a task for every paid gift older than 3 days that hasn't been acknowledged. Routes to email if the donor has a valid opted-in email address; otherwise creates a task for a human to handle.
> - **Stewardship Response** — runs daily at 07:00 UTC. Sends a tier-differentiated mission touch roughly 14 days after the acknowledgement. Entry-tier donors get an automated email; major donors always route to a task for personal outreach.
>
> **Email templates (Setup → Email Templates → Public folder):**
>
> - **Gift Acknowledgement** — full-deduction acknowledgement. Ships with placeholder copy.
> - **Gift Acknowledgement (Partial Deduction)** — used when Tax Deduction Amount is less than Current Amount (event tickets, in-kind, quid-pro-quo). Ships with placeholder copy.
> - **Stewardship Response (Standard)** — the mission touch. Ships with placeholder copy.
>
> **Do not go live with the shipped copy.** The templates deliberately read as placeholders so an accidental activation doesn't send generic filler to real donors. Rewriting the copy — and, for US orgs, making sure the acknowledgement contains the IRS-required elements from Question 1 — is a launch-checklist task.
>
> *Click the button below to loop back to the intro. Nothing has been saved or changed — this was a reading walk-through only.*

---

## Section 7. Configure Stewardship Response Settings

Two parts: a rich-text explainer, then an embedded flow.

### Rich-text explainer on the Home Page

> **Stewardship Response settings**
>
> Once your donor tiers are defined, use this to decide how the follow-up stewardship touch is delivered for each tier. Options per tier:
>
> - **Include All** — every gift in this tier gets an automated stewardship email.
> - **Exclude Lifetime** — email for most donors in this tier, but if the donor is already a lifetime major donor, route the gift to a task for personal follow-up instead.
> - **Exclude All** — every gift in this tier goes to a task for personal follow-up.
>
> Email opt-outs on the donor's Person Account always override these settings — those gifts always route to a task.
>
> **Important:** these settings only take effect after you activate the **FQS Stewardship Response** scheduled flow (Setup → Flows).

### Embedded flow: FQS Setup — Stewardship Response Settings

[`FQS_Setup_Stewardship_Response_Settings`](../force-app/main/default/flows/FQS_Setup_Stewardship_Response_Settings.flow-meta.xml).

Flow description: *"Picks per-donor-tier automatic stewardship routing (Include All / Exclude Lifetime / Exclude All) with a 'set all to same' shortcut. Governs the tier-differentiated stewardship touch fired by the FQS Stewardship Response scheduled flow ~14 days after acknowledgement — NOT the acknowledgement itself (acknowledgement is universal)."*

#### Screen: Automatic Stewardship Routing

Education block:

> **How automatic stewardship routing works**
>
> Every donor with a valid email receives an initial acknowledgement (a "we got your gift, thanks, here is your deduction info" receipt) — that flow is universal and has no per-tier settings. About two weeks later, the *FQS Stewardship Response* scheduled flow runs a relationship-deepening touch, and each qualifying gift is routed to one of two paths — an automatic stewardship **email** to the donor, or a **task** for a fundraiser to follow up personally. The setting below controls that stewardship decision for each donor tier.
>
> - **Include All** — every gift in this donor tier is eligible for an automatic stewardship email.
> - **Exclude Lifetime** — automatic stewardship email for most donors in this donor tier, *but* if the donor is already a lifetime major donor, route the gift to a task instead.
> - **Exclude All** — every gift in this donor tier goes to a task for personal follow-up.
>
> Email opt-outs on the donor's Person Account (or Contact) always override these settings — those gifts always route to a task.
>
> **Important:** these settings only take effect after you activate the **FQS Stewardship Response** scheduled flow. If it's inactive, no stewardship touches will fire regardless of what you choose here.

Controls:

- Checkbox: **Apply one setting to all three donor tiers**
- Three per-tier dropdowns (visible when the "apply one" box is off): **Major donor tier stewardship**, **Mid donor tier stewardship**, **Entry donor tier stewardship**. All three dropdowns share this helptext: *"Determines whether a gift in the {tier} donor tier triggers an automatic stewardship email (Include All), a personal-touch task (Exclude All), or route lifetime major donors to a task instead (Exclude Lifetime). Applies to the stewardship follow-up ~14 days after acknowledgement, not the acknowledgement itself."*
- One shared dropdown: **Stewardship setting for all donor tiers** — visible only when the "apply one" box is on. Helptext: *"Determines whether gifts in all three donor tiers trigger an automatic stewardship email (Include All), a personal-touch task (Exclude All), or a lifetime-escalating hybrid (Exclude Lifetime). Applies to Entry, Mid, and Major donor tiers when the 'Apply one setting' box is checked."*

All dropdowns list: Include All / Exclude Lifetime / Exclude All.

#### Screen: Settings queued (success)

> **Your changes are being deployed.**
>
> Stewardship setting updates run in the background, so the new values may take up to a minute to appear on records.
>
> **Reminder:** the automatic stewardship settings you chose only take effect after the **FQS Stewardship Response** scheduled flow is activated. If you have not yet activated it, do so from Setup → Flows.

---

## Section 8. Review Automation and Queue Membership

Rich-text only. No embedded flow.

> **Review the other automation FQS ships.**
>
> Beyond stewardship, acknowledgement, and gift entry (covered in earlier sections), FQS ships a set of behind-the-scenes flows that keep records named, campaign memberships accurate, rollups fresh, and gift commitments processing correctly. Most are active by default; a few need queue members before their tasks route to humans. Nothing here needs configuration to work — but reviewing what's running helps you understand where derived values come from and which flows to gate with the **FQS Bypass Automation** permission set during data loads.
>
> **Naming and categorization** (before-save, no DML):
>
> - **FQS Auto-Name Gift Transaction / Gift Commitment / Opportunity** — writes a human-readable Name onto each record on create/update.
> - **FQS Auto-Category Gift Transaction** — derives *FQS Gift Transaction Category* (Outright / Pledge Payment / Recurring / Grant / In-Kind / Earned Income / Event Registration) so reports and dashboards can group by intent.
>
> **Campaign membership and hierarchy:**
>
> - **FQS Campaign Auto-Members Default** — on Campaign insert, checks *Enable Automatic Campaign Members* on Tactical (Level 3) campaigns only; rollup levels stay unchecked.
> - **FQS Campaign Member Status — Ladder / On Commitment / On Gift Transaction** — seeds the Sent / Responded / Attended ladder on tactical campaigns, then keeps CampaignMember.Status in sync as commitments and transactions land, cancel, or refund.
> - **FQS Campaign Child Count (Update / Delete)** — maintains rollup counts on Strategic and Operational parents when children move between hierarchies.
> - **FQS Campaign Create First OSC** — provisions the first Outreach Source Code on a Tactical campaign when *Create First Outreach Source Code* is checked (by the Campaign Hierarchy Setup flow or by an admin).
>
> **Gift Commitment lifecycle:**
>
> - **FQS Coordinate Gift Commitment Processing** — resolves the enabled Fundraising Cloud processing-engine version and hands off to the platform-managed processor. Runs on GC insert / activation.
> - **FQS GC Fulfillment (From GDD / On Change / Recalculate)** — recomputes GC *Fulfillment Type* whenever a linked Gift Default Designation changes or the *Restriction Release Date* moves. Keeps "restricted vs unrestricted" classification current without a nightly job.
> - **FQS Manage Gift Commitment Actions** — the quick-action screen flow on GC record pages; presents Pause / Resume / Cancel / Adjust and calls the matching platform-managed action. No configuration needed.
>
> **Refunds:**
>
> - **FQS Refund Gift** — quick action on Gift Transaction. Creates a Gift Refund child in *Completed* status; Fundraising Cloud cascades the effect to rollups and campaign members.
> - **FQS Refund Gift From Donor** — account-side launcher for the same refund action; picks a GT from the donor's history first.
>
> **Scheduled rollups:**
>
> - **FQS Automatic Rollup Updates** — daily scheduled flow that invokes *Manage Fundraising Definitions* to refresh Donor Gift Summary, Outreach Summary, and Gift Designation rollups. Installed **deactivated**. Activate once you're past initial data load so overnight rollups stay current.
>
> **Queues** (Setup → Queues) — add members so tasks fired by the acknowledgement, stewardship, and refund flows route to real humans:
>
> - **Stewardship Tasks** — mid-tier stewardship follow-ups.
> - **Gift Processing Tasks** — acknowledgement and gift-entry tasks that need a human.
> - **Major Donor Tasks** — prospect research, proposal drafting, cultivation.
> - **Executive Fundraising Tasks** — handwritten notes and other high-touch actions for the ED or Board.
>
> **Bypass:** every record-triggered flow above checks the **FQS Bypass Automation** permission set. Assign it to your data-load user during bulk imports so triggers don't fire per row; assign a reconciler script (`scripts/apex/*-recalc-*.apex`) after the load to backfill derived state.

---

## Section 9. Update Home Page

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

## To Be Acknowledged

Gift Transaction list view `FQS_To_Be_Acknowledged`. No FQS copy — the list-view columns and filter are configured in the list view itself.

## To Be Stewarded

Gift Transaction list view `FQS_To_Be_Stewarded`. No FQS copy — the list-view columns and filter are configured in the list view itself.

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
> - An in-kind gift
> - A fee-for-service or goods
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
> Salesforce Nonprofit Help: <https://help.salesforce.com/s/products>
>
> Community Commons Best Practice: <https://sfdo-community-sprints.github.io/npc-best-practices/fundraising/>

## Create Gift Batch (sidebar launcher)

Embeds the **FQS Create Gift Batch** flow ([`FQS_Create_Gift_Batch`](../force-app/main/default/flows/FQS_Create_Gift_Batch.flow-meta.xml)).

Flow description: *"Home-page launcher that creates a new GiftBatch from three inputs: template, estimated value, and estimated gift count. Auto-number Name field is populated by the platform on insert."*

### Screen: Create a Gift Batch (input)

> **Start a new Gift Batch.**
>
> Pick the template that matches the shape of gifts you're about to enter, then estimate the count and total value so the batch can reconcile against your source (deposit slip, event roster, mail run) during dry-run and processing.

Fields:

- **Screen Template** (radio, required) — helptext: *"The template controls which columns appear on every row of the grid. You can't change the template after the batch is created — if you pick the wrong one, delete the batch and start again."*
  - **Individual Outright Gifts** — one-time cash, check, or card gifts. No pledge, no schedule; a single completed transaction per row. *(default)*
  - **Pledge Payments** — individual payments applied against pledges that already exist. Each row picks a commitment; designations cascade from the commitment's defaults.
  - **Event Registrations** — ticket / registration payments where part or all of the amount is fee-for-service. Includes a Fair Market Value column so the deductible portion can be split from the goods-received portion.
  - **Single Payment Pledges** — a pledge commitment with only one expected payment.
  - **Undefined Batch** — the default Salesforce Standard Template. A clean starting point.
- **Estimated Batch Value** (currency, required) — helptext: *"The total dollar value you expect this batch to add up to — from your deposit slip, event ticket roster, or the sum of the checks in front of you. Dry-run compares this against the sum of entered gifts and flags a mismatch."*
- **Estimated Gift Count** (number, required) — helptext: *"The number of gift entries you expect to add to this batch. Dry-run compares this against the actual row count and flags a mismatch."*

### Screen: Success — Gift Batch Created

> ✓ **Gift Batch created.**
>
> Open the batch to set defaults, then start entering gifts. Dry-run and process from the batch record page when you're ready.
>
> **Open the new Gift Batch →** (link to the new record)
>
> *Click **Finish** to close.*

## Guided Gift Entry (sidebar launcher)

Embeds the **FQS Guided Gift Entry — Home Page** flow ([`FQS_Guided_Gift_Entry_HomePage`](../force-app/main/default/flows/FQS_Guided_Gift_Entry_HomePage.flow-meta.xml)).

The Home-page launcher's only home-page-facing copy is the first screen — shown only when launched from Home with no Account context. The Account quick-action launch skips it.

### Screen: Pick a Donor

> **Who is this gift for?**
>
> Pick the Account of the donor, household, or organization giving the gift. You can search by name.

Field label: **Donor Account**

After the donor is picked, the flow hands off to the shared monolith `FQS_Guided_Gift_Entry_Account`. That monolith's own copy (category picker + leaf-specific screens for Outright / Pledge / Recurring / Grant / In-Kind / Earned Income / Event Registration) is out of scope for this Home-Page review — it's the same copy shown when a user launches guided entry from a donor's Account record.

---

End of document

If you spot a wording change or a copy issue, mark it inline (or leave a note where you'd like it) and I'll edit the flexipage / flow metadata to match.
