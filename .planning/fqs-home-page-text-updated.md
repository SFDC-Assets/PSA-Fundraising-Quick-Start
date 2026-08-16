# FQS Home Page — All Copy, Updated for Review (Round 2)

**Purpose:** every user-visible string on the FQS Home Page (`FQS_Home_Page_Default`) plus every user-visible string in the seven flows embedded on it, extracted verbatim, for external review. This document replaces `FQS Home Page Review (1).md` and folds in:

- Every surgical copy fix already applied to the deployed flexipage (§Applied-in-flexipage).
- Every flow-copy change recommended by the read-only review at [`.planning/fqs-home-page-flow-copy-edits.md`](fqs-home-page-flow-copy-edits.md) (§Proposed-for-flows — NOT yet deployed).
- Canonicalized terminology: **Donor Tier** (not Donor Grouping), **Person Account** (not Contact), **acknowledgement** (British), **In-Kind** (hyphenated), **fee-for-service** (hyphenated modifier), em-dash **—**, Oxford commas.

**Source of truth:** `force-app/main/default/flexipages/FQS_Home_Page_Default.flexipage-meta.xml` and the seven flows listed below. Deploy IDs for the flexipage edits: `0AfWB00000E2upF0AR` (Home Page copy fixes), `0AfWB00000E2uqr0AB` (OSC page RRDD groups).

**Legend:**
- ✔ **applied** — already in the deployed flexipage on `fundfirst`.
- ⏳ **proposed** — flow-copy edit recommended by the flow-copy review; NOT yet applied.
- 🔄 **carry forward** — text unchanged, quoted here for verbatim review.

**Out of scope (as before):** list-view column labels, dashboard visuals, standard Salesforce component chrome, and per-leaf copy inside the huge `FQS_Gift_Entry_Single_Launcher_Account` monolith.

---

## Home Page layout at a glance (corrected)

The Home Page has four regions:

- **Top region — Tabs.**
  - Tab 1: **FQS Set Up** — a **9-section accordion**. Sections 1, 2, 3, 4 (Tier Thresholds) and 6 (Ack/Steward/Tax Guide) each embed a Setup flow. Section 7 embeds the Stewardship-Response Settings flow. Sections 5, 8, 9 are pure rich-text guidance.
  - Tab 2: **Dashboard** — embeds the `FQS_Donor_Tiers` dashboard. No copy.
- **Bottom-left region — Accordion.**
  - **Opportunities Needing Action** — Opportunity list view (`MyOpportunities`). No FQS copy.
  - **Gift Commitments Needing Action** ✔ (was "G. Commitments Needing Action" — expanded) — Gift Commitment list view (`FQS_Past_Due_Installments`).
- **Bottom-right region — Accordion.**
  - **To Be Acknowledged** — Gift Transaction list view (`FQS_To_Be_Acknowledged`). (The original review doc mislabeled this as a stub — it is a live list.)
  - **To Be Stewarded** — Gift Transaction list view (`FQS_To_Be_Stewarded`). (Ditto.)
- **Sidebar region — Accordion.**
  - **Recent Records** — standard Salesforce component. No FQS copy.
  - **Glossary** — rich-text.
  - **Process Documentation** — rich-text + two external links.
  - **Guided Gift Entry** — embeds `FQS_Guided_Gift_Entry_HomePage` flow.
  - **Create Gift Batch** — embeds `FQS_Create_Gift_Batch` flow.
  - **Today's Tasks** — standard Salesforce component. No FQS copy.

**Corrected section order (deployed):** 1. Set Up Gift Designations · 2. Establish Solicitation and Outreach Tracking · 3. Define Donor Tiers and Thresholds · **4. Review Guided Gift Entry** · 5. Enter Gift Batches with Gift Entry Grid · **6. Guidance on Acknowledgement, Stewardship, and Tax Receipting** · **7. Configure Stewardship Response Settings** · **8. Review Automation** · 9. Update Home Page.

---

# Part 1 — FQS Set Up tab

## Section 1. Set Up Gift Designations

Embeds **FQS Suggest Designations** flow (`FQS_Suggest_Designations.flow-meta.xml`).

### Screen: Seed Your Gift Designation Catalog (intro) 🔄

> **Review Suggested Designations.**
>
> Gift Designations help you record and understand donor intent, and in some cases the reason behind the gift. In the next screen you will see a set of suggested designations; choose the ones that make the most sense for your organization.
>
> All organizations will need one default designation, typically an unrestricted or general operating fund. Beyond that, designations can be used to track a variety of purposes (specific programs or specific expense categories) or for permanent restrictions. Typically designations are not created for time-based restrictions; those are set on the gift itself through entering the "Restriction Release Date."
>
> On the next screen, pick which designations serve your organization's needs. These are meant to be a starter set with some generic names — you can rename and manually edit any of these later from the Gift Designation record page.
>
> *This release ships 14 starter entries across the four restriction categories: Without Donor Restriction, With Donor Restriction — Purpose, With Donor Restriction — Permanent, and Earned Revenue.*
>
> *This flow is safe to re-run. Any starter designation already in your org (matched by exact Name) is skipped, and only the new picks are created. Re-run any time to add designations you unchecked earlier.*

### Screen: Pick Designations 🔄

Intro:

> Select the starter designations you want in your org. The designations are grouped by restriction category. All are pre-selected; uncheck any you do not want to create.
>
> *A note on time restrictions: FQS deliberately does not offer a "With Donor Restriction — Time" category on the designation. A designation names what the money is for, not when it becomes spendable. Time boundaries (e.g., FY2027, or "hold until the building opens") belong on the individual gift instead, on the **Restriction Release Date** field on the Gift Commitment or Gift Transaction. That lets one purpose-restricted designation (e.g., "Building Fund") carry gifts with many different release dates without proliferating year-suffixed designations.*

14 checkboxes across three categories (Without Donor Restriction, With Donor Restriction — Purpose, With Donor Restriction — Permanent, Earned Revenue). All checkbox labels and descriptions carry forward verbatim from the previous review — those descriptions ship as `GiftDesignation.Description` record content, not just flow copy.

**Applied minor fix (⏳ proposed by review, safe in-place):**
- "Every FQS install ships with this as the **org default**" → "Every FQS install ships with this as the **org-wide default**" — drops the redundant tautology.

### Screen: Designations Created (success) 🔄

> **Your selected Gift Designation records are created.**
>
> You can retire any of these later by setting IsActive = FALSE on the record page. Retired designations remain queryable and remain valid for back-dated gifts.

**Applied minor fix ⏳:** "at any time" → "later" (drops filler).

### Screen: Starter Catalog Already Complete (all-present) ⏳

**Was:** "Everything Is Already Present" — grammatically stiff.
**Proposed:** rename the screen label to **"Starter Catalog Already Complete"** and adjust the display text accordingly.

### Screen: No Designations Selected (empty-selection warning) 🔄

> **No designations were selected.**
>
> Nothing was created. Click Previous to pick at least one, or Finish to exit without creating any designations.

### Screen: Could Not Create Designations (fault) 🔄

> **The flow could not create the selected designations.**
>
> Common causes:
> - Your permission set does not grant Create on Gift Designation. Ensure FQS Custom Fields (or an equivalent permission set) is assigned.
> - An org-wide default is already set on another Gift Designation. Only one Gift Designation can carry IsDefault = TRUE at a time.
> - A validation rule or trigger on Gift Designation rejected the insert.
>
> Close this flow, resolve the cause, and relaunch it.
>
> Fault message: `{!$Flow.FaultMessage}`

---

## Section 2. Establish Solicitation and Outreach Tracking (Campaign Hierarchy)

Embeds **FQS Campaign Hierarchy Setup** flow (`FQS_Campaign_Hierarchy_Setup.flow-meta.xml`).

### Screen: Step 0 — Learn About Campaigns 🔄 (with ⏳ hyphen fix)

Three explainer blocks unchanged. Note one **LOW** hyphenation fix in the second explainer: "a one on one meeting" → "a one-on-one meeting" ⏳.

### Screen: Step 1 of 5 — Choose Your Campaign Model 🔄 (with ⏳ parallelism fix)

Radio label: **Campaign Hierarchy Choices**. Options:

- **Giving Programs** — giving program at level 1, year at level 2, best when programs are staffed separately
- **Seasonal / Yearly** — year at level 1, giving program at level 2, best for year-over-year reporting and for smaller staffs ⏳ (drops stray "the" for parallel construction)
- **Audience** — year at level 1, donor segment at level 2, best when your team plans by audience (lapsed, mid-level, acquisition)

### Screens 2–4 🔄

Year cohort picker, Strategic+Operational picker, Tactical picker. All copy carries forward.

### Screen: Step 5 of 5 — Confirm and Build ⏳

Two variants (Giving Programs model uses per-Strategic count; Seasonal/Audience always shows 1 Strategic).

**HIGH proposed fix — raw picklist value bleed:** current confirm screen renders "**Model: {!radioModel}**" where `radioModel` holds the raw picklist value (`Seasonal` / `GivingPrograms` / `Strategy`). A user who picked "Audience" sees "Model: Strategy," which is confusing.

**Proposed:** add a String formula `formulaModelLabel` mapping `Seasonal → "Seasonal / Yearly"`, `GivingPrograms → "Giving Programs"`, `Strategy → "Audience"`, then reference `{!formulaModelLabel}` on the Confirm, Success, and Final screens. **Requires a Flow Builder round-trip.**

### Screen: Review + Edit Campaign Records (success) 🔄

Copy carries forward. **Note:** the four-count recap (Strategic / Operational / Tactical / OSC created) appears on both this screen and the Final screen. Consider dropping it from Success since the datatable directly below already shows the created records.

### Screen: Campaign Hierarchy — Done (final) ⏳ (with two MED rewrites)

**Was (opener):** "Head to the Campaigns tab and add details to your campaign. In addition to completing the fields, you will also want to:"

**Proposed:** "Head to the Campaigns tab and refine each campaign — set start/end dates, review member statuses, and pick a default Gift Designation."

**Was (closer):** "Need to track a/b tests, track different channels, and/or want to report on granular audience segments?"

**Proposed:** "Want to track A/B tests, channels, or granular audience segments? Add Outreach Source Codes on any Tactical (Level 3) campaign."

### Screen: Ready-to-Choose gate on Step 0 ⏳

The "No, I need to think further." radio choice on the Step 0 gate has no `<defaultConnector>` target — the user hits a dead end.

**Proposed:** either reword to **"Not yet — I want to reread the options."** and keep the loop-back to Step 0, OR wire a graceful exit screen. **Requires a Flow Builder round-trip.**

### Screen: Campaign Hierarchy — Error 🔄

> **There was a problem building your campaign hierarchy.**
>
> `{!varErrorMessage}`
>
> Click **Back** to return and try again.

---

## Section 3. Define Donor Tiers and Thresholds

Two parts: a rich-text explainer, then an embedded flow (`FQS_Setup_Tier_Thresholds`, NOT the previously-referenced `FQS_Setup_Donor_Grouping_Thresholds` — that flow does not exist).

### Rich-text explainer on the Home Page ✔ (deployed)

> **What donor tiers do for you**
>
> Donor tiers sort every donor into one of three levels — Entry, Mid, and Major — based on the size of their gifts. The tier drives acknowledgement copy, stewardship routing, gift-level formulas, and the reports and dashboards that ship with FQS. Adjust the thresholds below so they match how your organization thinks about donor tiers.
>
> Each tier has three dollar bands you can tune: **One-Time** (a single gift big enough to qualify), **Annual** (fiscal-year cumulative giving), and **Lifetime** (all-time cumulative giving). A donor lands in the highest tier they qualify for on any of the three bands.
>
> You can also rebrand the tier names — use *Friend / Partner / Champion* if that fits your voice better than Entry / Mid / Major.
>
> Changes take up to a minute to flow through — FQS writes the new thresholds to Custom Metadata, which the platform deploys asynchronously.

*(The `//delete this and put into the header of the flow` placeholder in the previous review doc was stale. This is the deployed text.)*

### Embedded flow: FQS Setup — Donor Tier Thresholds ⏳

#### Screen: Donor Tier Thresholds (header) ⏳

**Was:** "These donor tiers will **effect** the donor acknowledgement process, formula fields for individuals and gift, and reports included in the Fundraising Quick Start."

**Proposed (HIGH):** "These donor tiers will **affect** the donor acknowledgement process, formula fields on individuals and gifts, and reports included in the Fundraising Quick Start." (fixes homophone; fixes singular/plural).

**Was:** "Adjust the giving thresholds for each donor tier to your nonprofit organization."

**Proposed (MED):** "Adjust the giving thresholds for each donor tier to fit your organization." (fixes dangling preposition).

#### Per-tier headers ⏳

**HIGH:** "What does your organization consider to be **a entry** level gift?" → "…**an entry-level** gift?" (article agreement + hyphenation)

**MED:** "…a mid level gift?" → "…a mid-level gift?"

**MED:** "…a major level gift?" → "…a major-level gift?"

#### Per-tier fields 🔄

Four fields per tier (Major / Mid / Entry), unchanged in copy:

- **Branded Name ({tier})** — helptext: *"The branded name of the Tier Key shown to staff and donors in reports, dashboards, and the Donor Gift Summary record page. Changing this value here automatically updates `FQS_Donor_Level_Name__c` on all Donor Gift Summary records. Example values: Friend, Partner, Champion or Entry, Rising, Summit."*
- **One-Time Minimum Amount ({tier})** — helptext: *"The minimum gift amount for a single transaction to qualify for this donor tier. Your administrator controls this threshold. Updating it automatically recalculates the giving level across all Gift Transactions."*
- **Annual Minimum Amount ({tier})** — helptext: *"The minimum fiscal-year giving total for a donor to qualify for this donor tier annually. Your administrator controls this threshold. Updating it automatically recalculates the annual giving level across all Donor Gift Summary records."*
- **Lifetime Minimum Amount ({tier})** — helptext: *"The minimum lifetime giving total for a donor to qualify for this donor tier. Your administrator controls this threshold. Updating it automatically recalculates the lifetime giving level across all Donor Gift Summary, Gift Commitment, and related records."*

#### Footer 🔄

> **Need a new tier?** This flow only edits the three included donor tiers. To add a brand-new donor tier, go to **Setup → Custom Metadata Types → FQS Donor Tier → Manage Records**.
>
> Additional donor tiers may require you to review and edit fields on Donor Gift Summary, Gift Commitment, and Gift Transaction, as well as flow automations dependent on those fields.

#### Screen: Thresholds queued (success) 🔄

> **Your changes are being deployed.**
>
> Donor tier updates run in the background, so the new values may take up to a minute to appear on records.
>
> **Need a new donor tier?** Go to Setup → Custom Metadata Types → FQS Donor Tier → Manage Records.

---

## Section 4. Review Guided Gift Entry

Rich-text only. No embedded flow. ✔ (deployed)

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
> - **Recurring Gift** — a fixed amount given on a recurring schedule (typically monthly) with no fixed end date, usually created through an online donation form integration.
>
> **2. Set up a pledge or grant**
>
> - **Single Payment** — creates a pledge and a single payment to be given at a later date.
> - **Multiple Payment Pledge** — a pledge with more than one expected payment. Either even installments (monthly, quarterly, yearly) over a defined period, or a custom schedule when dates are irregular and/or amounts vary.
>
> **3. Log an in-kind, earned income, or event registration**
>
> - **In-Kind Gift** — a donation of goods, services, stock, or property. Records a Fair Market Value and flags the gift as in-kind so it's excluded from cash rollups.
> - **Earned Income** — program-service revenue, honoraria, sponsorship where goods or services were exchanged. Kept out of donor-lifetime rollups.
> - **Event Registration** — ticket revenue where the deductible portion is smaller than the amount paid. Fair Market Value marks the goods-received portion; the difference is the tax-deductible gift.
>
> **How to launch:** use the **Guided Gift Entry** section in the right-hand sidebar of this Home page, the quick action on any donor Account, or the quick action on a Gift Commitment (for pledge payments) or Opportunity (for pledge set-up).

---

## Section 5. Enter Gift Batches with Gift Entry Grid

Rich-text only. No embedded flow. ✔ (deployed)

> The Gift Entry Grid is a spreadsheet-style data entry tool. It's the right tool when you have a stack of gifts to enter that share a shape — a mail-in batch of pledge payments or an event-registration list. You can also use Grid to quickly enter single gifts from any Account Record.
>
> Consider using **Grid** when:
> - **You're working from a batch** — a physical mail run, a bank download, an event registration export.
> - **Your volume is steady** — you enter gifts every day or week and the throughput matters.
> - **A dedicated data-entry person or team owns the workflow** — someone who has learned the shortcuts and knows which template to pick.
>
> If these don't apply, consider **Guided Gift Entry**. It's a form-based tool — more clicks and less flexibility, but more direction for the user.
>
> **Templates that ship with FQS**
>
> Every template pre-selects the right columns for the shape of gift being entered. Pick the one that matches your batch:
>
> - **Individual Outright Gifts** — one-time cash, check, or card gifts. No pledge, no schedule; a single completed transaction per row.
> - **Single Payment Pledges** — a pledge commitment with only one expected payment. Creates the parent Gift Commitment and its first (and only) Gift Transaction in a single row. Includes match-eligibility and restriction fields.
> - **Multiple Payment Pledges** — a pledge commitment with two or more expected payments on a regular schedule. **(NEW — was omitted from the previous review; the template ships and is offered by the Create Gift Batch launcher.)**
> - **Pledge Payments** — individual payments applied against pledges that already exist. Each row picks a commitment; designations cascade from the commitment's defaults.
> - **Event Registrations** — ticket / registration payments where part or all of the amount is fee-for-service. Includes a Fair Market Value column so the deductible portion can be split from the goods-received portion.
> - **Undefined Batch** — uses the default Salesforce Standard Template, a clean baseline that mirrors what Salesforce ships out of the box with no FQS columns added. Use it as a starting point when you want to build your own template from scratch.
>
> **How to launch:** open Gift Batches, click **New**, pick the template that fits your batch, set expected total and count, then use the grid to enter rows. FQS ships a batch record page with step-by-step instructions for defaults, entry, dry-run, and processing.

---

## Section 6. Guidance on Acknowledgement, Stewardship, and Tax Receipting

Embeds the **FQS Acknowledgement Stewardship Tax Guide** flow (`FQS_Acknowledgement_Stewardship_Tax_Guide.flow-meta.xml`). *(The previous review doc mislabeled this as "rich-text only.")*

### Screen: Three distinct touches, one pipeline (NEW / proposed intro) ⏳

**Proposed** for the opening screen of the flow, replacing the current Screen 1 intro OR as a new pre-question screen:

> **Three distinct touches, one pipeline**
>
> **Acknowledgement** is the first response after a gift is received. Its purpose is to confirm the transaction, thank the donor specifically for the gift they just made, and (when applicable) provide the tax-deductible amount. Acknowledgement should feel prompt — FQS ships a daily scheduled flow that emails or tasks every paid gift older than three days that hasn't been acknowledged.
>
> **Stewardship** is the follow-up touch that comes after acknowledgement — a mission update, an impact story, or a personal call from a fundraiser. Its purpose is not to confirm a gift but to deepen the relationship in the weeks after. Routing is tier-differentiated: mid-tier donors typically receive an automated stewardship email; lifetime major donors are routed to a task for personal follow-up.
>
> **Tax Receipting** is the formal, IRS-facing record the donor may need at year-end to substantiate a deduction. It overlaps with acknowledgement (a well-formed acknowledgement email can double as a receipt) but is not the same thing — a receipt must state the deductible amount, the date, and whether goods or services were received in return. For event tickets and quid-pro-quo gifts, the deductible amount is smaller than the amount paid; FQS ships a separate "Gift Acknowledgement (Partial Deduction)" template for those cases.

### Screen 7 (Q5, Major Donors) — HIGH factual fix ⏳

**Was:** "…you can retune the routing in the Setup Flow (**Configure Donor Groupings** branch)."

**Proposed:** "…you can retune the routing in the **FQS Setup — Stewardship Response Settings** flow." (canonical term is **Donor Tier**, and the actual live Setup flow is named Stewardship Response Settings, not "Configure Donor Groupings.")

### Also proposed in this flow ⏳

- **MED** — Q1 lede: "Salesforce ships a native gift-acknowledgement engine — see Help doc 'Set Up Gift Acknowledgments and Tax Receipts'." (preserves the external link's US spelling, but frames it in the British form the rest of FQS uses)
- **MED** — Screen 1 intro: "This guide walks you through five questions, in order." → drop "in order."
- **LOW** — Screen 9 "The templates deliberately read as 'placeholder'" → "…read as placeholders" (drops smart-quote markup).

---

## Section 7. Configure Stewardship Response Settings

Two parts: a rich-text explainer, then an embedded flow (`FQS_Setup_Stewardship_Response_Settings`).

### Rich-text explainer ✔ (deployed with Person Account fix)

> **Stewardship Response settings**
>
> Once your donor tiers are defined, use this to decide how the follow-up stewardship touch is delivered for each tier. Options per tier:
>
> - **Include All** — every gift in this tier gets an automated stewardship email.
> - **Exclude Lifetime** — email for most donors in this tier, but if the donor is already a lifetime major donor, route the gift to a task for personal follow-up instead.
> - **Exclude All** — every gift in this tier goes to a task for personal follow-up.
>
> Email opt-outs on the donor's **Person Account** always override these settings — those gifts always route to a task.
>
> **Important:** these settings only take effect after you activate the **FQS Stewardship Response** scheduled flow (Setup → Flows).

### Embedded flow: FQS Setup — Stewardship Response Settings

#### Screen: Automatic Stewardship Routing ⏳

Header block **(HIGH proposed fix inside the flow, mirroring the flexipage fix already applied):**

**Was (still in flow XML):** "Email opt-outs on the donor's **Contact** always override these settings"

**Proposed:** "Email opt-outs on the donor's **Person Account** (or Contact) always override these settings."

Full rewrite of the education block (proposed):

> **How automatic stewardship routing works**
>
> Every donor with a valid email receives an initial acknowledgement (a "we got your gift, thanks, here is your deduction info" receipt) — that flow is universal and has no per-tier settings. About two weeks later, the *FQS Stewardship Response* scheduled flow runs a relationship-deepening touch, and each qualifying gift is routed to one of two paths — an automatic stewardship **email** to the donor, or a **task** for a fundraiser to follow up personally. The setting below controls that stewardship decision for each donor tier.
>
> - **Include All** — every gift in this donor tier is eligible for an automatic stewardship email.
> - **Exclude Lifetime** — automatic stewardship email for most donors in this donor tier, *but* if the donor is already a lifetime major donor, route the gift to a task instead.
> - **Exclude All** — every gift in this donor tier goes to a task for personal follow-up.
>
> Email opt-outs on the donor's **Person Account** always override these settings — those gifts always route to a task.
>
> **Important:** these settings only take effect after you activate the **FQS Stewardship Response** scheduled flow. If it's inactive, no stewardship touches will fire regardless of what you choose here.

#### Controls 🔄

- Checkbox: **Apply one setting to all three donor tiers**
- Three per-tier dropdowns (visible when the "apply one" box is off): **Major donor tier stewardship**, **Mid donor tier stewardship**, **Entry donor tier stewardship**.

Per-tier helptext ⏳ (all three) — plural correction on the "apply one" variant:

**Was:** "Determines whether a gift in this donor tier triggers an automatic stewardship email …"

**Proposed for pkAllTiers (only):** "Determines whether gifts in **all three donor tiers** trigger an automatic stewardship email (Include All), a personal-touch task (Exclude All), or route lifetime major donors to a task instead (Exclude Lifetime)."

All dropdowns list: Include All / Exclude Lifetime / Exclude All.

#### Screen: Settings queued (success) 🔄

> **Your changes are being deployed.**
>
> Stewardship setting updates run in the background, so the new values may take up to a minute to appear on records.
>
> **Reminder:** the automatic stewardship settings you chose only take effect after the **FQS Stewardship Response** scheduled flow is activated. If you have not yet activated it, do so from Setup → Flows.

---

## Section 8. Review Automation (NEW — was missing from the previous review) ✔

Rich-text only. Copy already deployed:

> **Turn the automation on when you're ready.**
>
> FQS ships two scheduled flows and three email templates that drive the acknowledgement and stewardship pipeline. Both flows install **deactivated** so an accidental install doesn't send placeholder copy to real donors.
>
> **Scheduled flows** (Setup → Flows):
>
> - **FQS Gift Acknowledgement** — runs daily at 06:00 UTC. Emails or creates a task for every paid gift older than 3 days that hasn't been acknowledged.
> - **FQS Stewardship Response** — runs daily at 07:00 UTC. Sends a tier-differentiated mission touch ~14 days after the acknowledgement.
>
> **Email templates** (Setup → Email Templates → Public folder) — rewrite before activating the flows above:
>
> - **Gift Acknowledgement** — full-deduction acknowledgement (default).
> - **Gift Acknowledgement (Partial Deduction)** — used when Tax Deduction Amount < Current Amount (event tickets, in-kind, quid-pro-quo).
> - **Stewardship Response (Standard)** — the mission touch.
>
> **Queues** (Setup → Queues) — add members so tasks route to real humans:
>
> - **Stewardship Tasks** — mid-tier stewardship follow-ups.
> - **Gift Processing Tasks** — acknowledgement and gift-entry tasks that need a human.
> - **Major Donor Tasks** — prospect research, proposal drafting, cultivation.
> - **Executive Fundraising Tasks** — handwritten notes and other high-touch actions for the ED or Board.
>
> **Suggested activation order:**
>
> 1. Rewrite the three email templates so nothing placeholder can ship.
> 2. Add queue members to at least the two Tasks queues the acknowledgement + stewardship flows fall back to.
> 3. Confirm stewardship routing per tier in step 7 above.
> 4. Activate **FQS Gift Acknowledgement** first; watch the *To Be Acknowledged* sidebar list drain over a few days.
> 5. Activate **FQS Stewardship Response** once acknowledgements are landing cleanly; watch the *To Be Stewarded* list.

---

## Section 9. Update Home Page ✔ (deployed with trailing-space fix)

> **Make this Home page your own.**
>
> Once your setup is complete, edit this Home page to fit your team's workflow. Common changes:
> - Delete this Setup accordion once initial configuration is done, or leave parts of it in place — some setup flows are useful whenever you re-tune thresholds or add a new fiscal year's Gift Designations.
> - Swap the *Opportunities Needing Action* and *Gift Commitments Needing Action* list views for filters that match the queues your team actually works — overdue pledge installments, gifts pending acknowledgement, major-gift Opportunities in your assigned portfolio.
> - Point the Process Documentation section at your organization's internal wiki or doc so new staff have a single place to land.
>
> **How to edit:** from any Home page, click the gear icon in the top-right → **Edit Page**. That opens Lightning App Builder where you can drag components, edit rich-text, and change list-view filters. Activate the edited page for your app / profile / org when done.

---

# Part 2 — Bottom-right accordion ✔ (corrected)

## To Be Acknowledged

Gift Transaction list view `FQS_To_Be_Acknowledged`. Live list, not a stub. Drains as the daily acknowledgement flow runs.

## To Be Stewarded

Gift Transaction list view `FQS_To_Be_Stewarded`. Live list, not a stub. Drains as the daily stewardship flow runs.

---

# Part 3 — Sidebar accordion

## Glossary ✔ (deployed with in-kind + fee-for-service fixes)

> **Opportunity**
> - A major gift cultivation plan
> - A grant prospect
>
> **Gift Commitment**
> - A pledge to give at a later date
> - A regular recurring gift
>
> **Gift Transaction**
> - An outright gift
> - An in-kind gift
> - A fee-for-service or goods
>
> **Campaign**
> - A solicitation, appeal, event invite or any action where you want to track who you asked and what gifts resulted from that ask.
>
> **Designation**
> - A fund, with or without restriction.

## Process Documentation 🔄

> This is a spot for your organization to customize and add your own process documentation for end users.
>
> Salesforce Nonprofit Help: https://help.salesforce.com/s/products
>
> Community Commons Best Practice: https://sfdo-community-sprints.github.io/npc-best-practices/fundraising/

## Create Gift Batch (sidebar launcher) 🔄 (with ⏳ template count fix)

Embeds **FQS Create Gift Batch** flow.

### Screen: Create a Gift Batch (input) 🔄

Intro block unchanged.

**Fields:**

- **Screen Template** (radio, required) — helptext unchanged; **six** options (was five in the previous review — Multiple Payment Pledges was missing):
  - **Individual Outright Gifts**
  - **Single Payment Pledges**
  - **Multiple Payment Pledges** — a pledge commitment with two or more expected payments on a regular schedule. **(NEW in this doc)**
  - **Pledge Payments**
  - **Event Registrations**
  - **Undefined Batch** — proposed tightening ⏳: "the default Salesforce Standard Template. A clean starting point." (drops "a clean baseline to use as a starting point" tautology)
- **Estimated Batch Value** (currency, required) — helptext unchanged.
- **Estimated Gift Count** (number, required) — helptext unchanged.

### Screen: Success — Gift Batch Created ⏳ (minor trim)

**Was:** "Click **Finish** to close, or open the record above to keep working."

**Proposed:** "Click **Finish** to close." (the "Open the new Gift Batch →" link above already invites the alternative)

## Guided Gift Entry (sidebar launcher) 🔄

Embeds **FQS Guided Gift Entry — Home Page** flow (`FQS_Guided_Gift_Entry_HomePage.flow-meta.xml`) — a single-screen donor picker that hands off to the shared `FQS_Gift_Entry_Single_Launcher_Account` monolith.

Only user-visible copy:

### Screen: Pick a Donor 🔄

> **Who is this gift for?**
>
> Pick the Account of the donor, household, or organization giving the gift. You can search by name.

---

# Applied-in-flexipage summary (deploys `0AfWB00000E2upF0AR` + `0AfWB00000E2uqr0AB`)

- Section 4 (Stewardship Response Settings intro) — "donor's Contact" → "donor's Person Account"
- Bottom-left accordion — "G. Commitments Needing Action" → "Gift Commitments Needing Action"
- Glossary — "An inkind gift" → "An in-kind gift"
- Glossary — "A fee for service or goods" → "A fee-for-service or goods"
- Section 5 (Gift Entry Grid) — "grid" → "Grid" in the "Consider using" lede
- Section 5 — "If these don't apply consider…" → "If these don't apply, consider **Guided Gift Entry**. It's a form-based tool — more clicks and less flexibility, but more direction for the user." (adds comma, hyphenates "form-based", rewrites awkward transition, parallelism)
- Section 4 (Guided Gift Entry) — "form based" → "form-based"; "It is a form based experience asking questions to ensure your gift is entered accurately" → "It's a form-based experience that asks questions to make sure the gift is entered accurately."
- Section 4 (Guided Gift Entry) — Recurring Gift definition: "a set amount is given every month with no fixed end date, typically created through an integration with an online form tool" → "a fixed amount given on a recurring schedule (typically monthly) with no fixed end date, usually created through an online donation form integration."
- Section 4 (Guided Gift Entry) — Multiple Payment Pledge: "Either with even installments … over a defined period or on a custom schedule. A custom schedule is needed when the dates are not on a regular cadence and/or the amounts are not evenly divided." → "Either even installments (monthly, quarterly, yearly) over a defined period, or a custom schedule when dates are irregular and/or amounts vary."
- Section 9 (Update Home Page) — trailing double-space before em-dash removed.
- OSC record page `runtime_industries_fundraising:relatedRecordDetailDisplay` — placeholder single-field "New Group" replaced with the four Campaign-page groups (Top Line Numbers, Outwright Gifts, Pledged and Recurring Gifts, System Information).

---

# Proposed-for-flows summary (NOT yet deployed)

**HIGH — do first:**

1. `FQS_Setup_Tier_Thresholds` — "effect" → "affect"; "a entry level" → "an entry-level"; "for individuals and gift" → "on individuals and gifts".
2. `FQS_Setup_Stewardship_Response_Settings` — flow-XML "donor's Contact" → "donor's Person Account (or Contact)" (mirrors the flexipage fix already applied).
3. `FQS_Acknowledgement_Stewardship_Tax_Guide` Q5 — "Configure Donor Groupings branch" → "FQS Setup — Stewardship Response Settings flow".
4. `FQS_Campaign_Hierarchy_Setup` Confirm/Success/Final — replace raw `{!radioModel}` bleed with a `formulaModelLabel` mapping to friendly labels. (Requires Flow Builder round-trip.)
5. `FQS_Campaign_Hierarchy_Setup` Step-0 gate — wire the "No, I need to think further." choice to a target (currently dead-ends). (Requires Flow Builder round-trip.)

**MED — safe in-place XML edits:**

- Screen labels, choice text parallelism, helpText tone (see per-flow details).
- Campaign Hierarchy final screen — replace "Head to the Campaigns tab and add details to your campaign. In addition to completing the fields…" with the tighter version.
- Campaign Hierarchy final closer — replace "Need to track a/b tests…" with "Want to track A/B tests, channels, or granular audience segments? Add Outreach Source Codes…"

**LOW — punctuation/hyphenation/casing:**

- "one on one meeting" → "one-on-one meeting"
- "a mid level" / "a major level" → hyphenated
- Rename `Screen_All_Present` label from "Everything Is Already Present" to "Starter Catalog Already Complete"
- Drop redundant "at any time" from the Suggest-Designations success screen

---

# Terminology audit (canonical forms enforced in this doc)

| Term | Canonical | Notes |
|---|---|---|
| Donor Tier vs Donor Grouping | **Donor Tier** | Flow file is `FQS_Setup_Tier_Thresholds`; every deployed string uses Tier. |
| Person Account vs Contact (as donor) | **Person Account** | FQS ships on FundFirst / NPC — Person Account is the donor. |
| acknowledgement vs acknowledgment | **acknowledgement** | British form; matches majority of deployed copy. |
| In-Kind vs inkind vs "in kind" | **In-Kind** (adjective, capitalized), **in-kind** (attributive lowercase) | Fixed in glossary. |
| fee-for-service vs "fee for service" | **fee-for-service** (as modifier) | Fixed in glossary. |
| em-dash: — vs -- vs " - " | **—** (literal Unicode; `&mdash;` acceptable inside `<fieldText>`) | Deployed rich-text uses `&mdash;`; both render. |
| Oxford commas in 3-item lists | **Required** | Deployed copy is consistent; review doc dropped a few. |
| A/B tests vs "a/b tests" | **A/B tests** | Fixed in Campaign Hierarchy final. |
| one-on-one vs "one on one" | **one-on-one** | Fixed in Campaign Hierarchy Step 0. |

---

## End of document

This version supersedes `FQS Home Page Review (1).md`. Everything marked ✔ is live on `fundfirst`; everything marked ⏳ awaits your sign-off before it lands in the flow XML. If you want to accept them as a bundle I'll write them into `.flow-meta.xml` and deploy — noting that the two Flow-Builder-required items (formula-label mapping + dead-end connector on Campaign Hierarchy) will need a round-trip through Builder rather than a hand-authored XML patch.
