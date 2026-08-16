# FQS Home Page — Screen Flow Copy-Edit Review

Read-only editorial pass over the seven Screen Flows embedded on `FQS_Home_Page_Default`. Findings only — no `.flow-meta.xml` was modified.

Severity legend: **HIGH** = factual, broken, typo, wrong flow/feature name • **MED** = clarity, parallelism, awkward phrasing • **LOW** = punctuation, hyphenation, capitalization.

---

## 1. Overview

Voice is generally consistent across the seven flows: plainspoken, second-person, with 16px body / 20px header / 14px em-dash-callouts. The two Setup flows (Tier Thresholds, Stewardship Response) share nearly identical Success screens verbatim, and the Acknowledgement/Stewardship Tax Guide is written in a distinctly editorial "reading walk-through" register that is well matched to its role. The most severe drift is a **terminology regression** in the Tax Guide — Q5 refers to a "Configure **Donor Groupings** branch" of the Setup Flow, but the canonical term (used everywhere else in the code base and in the two Setup flows themselves) is **Donor Tier**. There is also one factual homophone error ("effect" for "affect") on the Tier Thresholds intro. Beyond those, the bulk of edits are LOW/MED cleanups: three "a mid/major/entry level gift" hyphenation misses, throat-clearing phrases, one "a entry" article agreement, and a raw picklist value bleeding through to a user-visible label in the Campaign Hierarchy confirmation screen.

---

## 2. Per-flow findings

## FQS_Suggest_Designations.flow-meta.xml

Overall clean. All 14 seeded Description strings are well edited (they ship as GD record content, not just flow copy, so quality matters).

- **LOW** — `Screen_All_Present.label` = `Everything Is Already Present` — grammatically stiff. **After:** `Starter Catalog Already Complete`.
- **LOW** — `DisplayText_Success` body: `You can retire any of these at any time by setting IsActive = FALSE …` — "at any time" is filler. **After:** `You can retire any of these later by setting IsActive = FALSE …`.
- **LOW** — `DisplayText_Pick_Intro` — italic block mixes "restrictions on the individual gift instead, on the **Restriction Release Date** field on the Gift Commitment or Gift Transaction" — long parenthetical, but reads. Optional trim: split into two sentences at "That lets one…".
- **LOW** — `Assign_General_Operating.rsv_Candidate.Description` = `The unrestricted org default. Every FQS install ships …` — "org default" is admin jargon; body copy shown to end users on record page. **After:** `The unrestricted default. Every FQS install ships with this as the org-wide default so the platform's activate-schedule action has a fallback designation.` (drops the redundant "org").

## FQS_Campaign_Hierarchy_Setup.flow-meta.xml

Longest flow, most edits — but each is small.

- **HIGH** — `Screen_Confirm` DisplayText blocks (both `..._GivingPrograms` and `..._SingleTop`) render **`Model: {!radioModel}`**, where `radioModel` holds the raw picklist value `Seasonal` / `GivingPrograms` / `Strategy`. Users choosing "Audience" see `Model: Strategy`, which is confusing (the value is a legacy key). **After:** add a `formulaModelLabel` (String formula) that maps `Seasonal → "Seasonal / Yearly"`, `GivingPrograms → "Giving Programs"`, `Strategy → "Audience"`, and use `{!formulaModelLabel}` on the Confirm and Final screens.
- **HIGH** — `Ready_to_Choose` decision (on `Learn_About_Campaign_Hierarchy_Choices`) has no `<defaultConnector>` target for the `ChoiceIntroGateNo` path — user picks "No, I need to think further." and gets a dead-end. Not strictly a copy issue, but the choice text promises a follow-up the flow doesn't deliver. Either wire a graceful exit screen or reword to **`Not yet — I want to reread the options.`** and keep the loop-back.
- **MED** — `choiceSeasonal.choiceText` = `Seasonal / Yearly — year at the level 1, giving program at level 2, …` — the extra "the" doesn't appear in the parallel `choiceGivingPrograms` or `choiceAudience`. **After:** `Seasonal / Yearly — year at level 1, giving program at level 2, best for year-over-year reporting and for smaller staffs`.
- **MED** — `Screen_Final` body: `Head to the Campaigns tab and add details to your campaign. In addition to completing the fields, you will also want to:` — "In addition to completing the fields" is throat-clearing, and "your campaign" (singular) is wrong after building a multi-year multi-level hierarchy. **After:** `Head to the Campaigns tab and refine each campaign — set start/end dates, review member statuses, and pick a default Gift Designation.`
- **MED** — `Screen_Final` body ends with `Need to track a/b tests, track different channels, and/or want to report on granular audience segments?` — "a/b" should be "A/B"; the "track/track/want to report" cadence is repetitive; "and/or" is legal-ese. **After:** `Want to track A/B tests, channels, or granular audience segments? Add Outreach Source Codes on any Tactical (Level 3) campaign.`
- **MED** — `Learn_About_Campaign_Hierarchy_Choices` DisplayText: `This step helps you choose between three ways to structure your campaign hierarchy.` — throat-clearing per style rule. **After:** `Three ways to structure your campaign hierarchy — pick the one that matches how your team plans.`
- **MED** — Duplicated boilerplate: `Screen_Success` and `Screen_Final` both recap the four count lines (Strategic / Operational / Tactical / OSC created) with identical wording. See §4.
- **LOW** — `Screen_Confirm.DisplayText_ConfirmIntro_GivingPrograms` — hyphenation `Auto Members checkbox` vs the datatable column label `Auto Members Enabled` — either "Auto-Members" (adjective compound) or accept the platform picklist form; consistent with the field API name is fine as-is.
- **LOW** — `collectionProcessors.description` mentions "the pervious screen" — developer-only, not user-visible, but worth fixing if the Builder ever surfaces the note.
- **LOW** — `Step_0_Learn_About_Campaigns.Copy_1_of_DisplayText_Campaign` — "for a one on one meeting" — hyphenate as "one-on-one".
- **LOW** — `Learn_About_Campaign_Hierarchy` DisplayText: `Native fields like "Responses in Hierarchy" and "Contacts in Hierarchy"` — capitalization/quoting fine, but stylistic parallel with the rest of the flow would prefer `<strong>` rather than curly-quotes around the field name.
- **LOW** — `Screen_Choose_Model.helpText` on `radioModel` reads cleanly — keep.

## FQS_Setup_Tier_Thresholds.flow-meta.xml

- **HIGH** — `DisplayText_ThresholdsHeader`: `These donor tiers will **effect** the donor acknowledgement process, formula fields for individuals and gift, and reports included in the Fundraising Quick Start.` — homophone error. **After:** `These donor tiers will **affect** the donor acknowledgement process, formula fields on individuals and gifts, and reports included in the Fundraising Quick Start.` (also fixes "for individuals and gift" → "on individuals and gifts").
- **HIGH** — `DisplayText_EntryHeader`: `What does your organization consider to be **a entry** level gift?` — "a" → "an", and "entry level" should hyphenate as an adjective. **After:** `What does your organization consider to be an entry-level gift?`
- **MED** — `DisplayText_MidHeader`: `… a mid level gift?` → `… a mid-level gift?`
- **MED** — `DisplayText_MajorHeader`: `… a major level gift?` → `… a major-level gift?`
- **MED** — `DisplayText_ThresholdsHeader` opener: `Adjust the giving thresholds for each donor tier **to your nonprofit organization**.` — dangles awkwardly. **After:** `Adjust the giving thresholds for each donor tier to fit your organization.`
- **MED** — `New_Tier_DisplayTxt`: `flow automations` is split by an extraneous span-with-white-background — visible whitespace artifact from the Quill editor. **After:** collapse to one `<span style="font-size: 16px;">flow automations</span>` inline.
- **LOW** — `DisplayText_MidHeader` and `DisplayText_EntryHeader` still carry `background-color: rgb(255, 255, 255);` inline styles — Quill leftover. Harmless but noisy; strip on next Builder round-trip.
- **LOW** — Branded-name `helpText` is verbatim on Major/Mid/Entry (3 copies). See §4.

## FQS_Setup_Stewardship_Response_Settings.flow-meta.xml

- **HIGH** — `DisplayText_AckEducation`: `Email opt-outs on the donor's **Contact** always override these settings — those gifts always route to a task.` — canonical terminology is **Person Account** (per project memory `fundfirst-account-recordtypes` and cross-flow convention). **After:** `Email opt-outs on the donor's Person Account (or Contact) always override these settings — those gifts always route to a task.`
- **MED** — `pkMajorAck.helpText` / `pkMidAck.helpText` / `pkEntryAck.helpText` describe Exclude Lifetime as `a lifetime-escalating hybrid (Exclude Lifetime)` — jargon-y. **After:** `… or route lifetime major donors to a task instead (Exclude Lifetime).`
- **MED** — `pkAllTiers.helpText` opens: `Determines whether a gift in this donor tier triggers …` — but this field applies to *all three* tiers when "apply one setting" is on. **After:** `Determines whether gifts in all three donor tiers trigger an automatic stewardship email (Include All), a personal-touch task (Exclude All), or a lifetime-escalating hybrid (Exclude Lifetime).`
- **MED** — `DisplayText_AckEducation` para 1 uses `&amp;quot;we got your gift, thanks, here is your deduction info&amp;quot;` — the double-encoded quotes render fine in browsers, but reads as noise on inspection. Prefer literal curly quotes or nested `<em>`.
- **LOW** — `Screen_Success.DisplayText_Success` duplicates the Tier-Thresholds Success screen almost verbatim ("Your changes are being deployed…"). See §4.
- **LOW** — `cbSetAllSame.fieldText` = `Apply one setting to all three donor tiers` — fine; parallel with helpText.

## FQS_Create_Gift_Batch.flow-meta.xml

Clean. This flow reads well end-to-end and uses fee-for-service correctly.

- **LOW** — `choiceTemplate_Default.choiceText`: `**Undefined Batch** — uses the default Salesforce Standard Template, **a clean baseline to use as a starting point**.` — the tail is redundant. **After:** `**Undefined Batch** — the default Salesforce Standard Template. A clean starting point.`
- **LOW** — `Screen_Batch_Details.pkScreenTemplate.helpText`: `You can't change the template after the batch is created — if you pick the wrong one, delete the batch and start again.` — good, keep.
- **LOW** — `SuccessSummary` and `SuccessFooter` — footer says "Click **Finish** to close, or open the record above to keep working." — the "Open the new Gift Batch →" link already invites that; footer could trim to `Click **Finish** to close.`

## FQS_Acknowledgement_Stewardship_Tax_Guide.flow-meta.xml

Longest reading-flow, but very well written overall. Two named-thing regressions to fix.

- **HIGH** — `Screen_7_Q5_Major_Donors.Q5_Body`: `… you can retune the routing in the Setup Flow (**Configure Donor Groupings** branch).` — canonical term is **Donor Tier**, and the actual live Setup flow is titled **FQS Setup — Stewardship Response Settings** (not a "Configure Donor Groupings" branch). **After:** `… you can retune the routing in the **FQS Setup — Stewardship Response Settings** flow.`
- **MED** — `Q1_Salesforce_Native`: `See <a…>Set Up Gift **Acknowledgments** and Tax Receipts</a>.` — the flow uses British "Acknowledgement" throughout; this link title is Salesforce Help's US-style title. Preserve the link's own casing (targets external page) but wrap with a lede that uses the British form: **After:** `Salesforce ships a native gift-acknowledgement engine — see Help doc "Set Up Gift Acknowledgments and Tax Receipts".`
- **MED** — `Screen_1_Intro.Intro_Body` para 2: `This guide walks you through five questions, in order.` — "in order" is redundant. **After:** `This guide walks you through five questions.`
- **LOW** — `Screen_2_Three_Activities` — three activity paragraphs are excellent. Keep.
- **LOW** — `Q2_Physical`: `Physical gifts always need something.` reads punchy. Keep.
- **LOW** — `Screen_9_What_Ships.Ships_Warning`: `The templates deliberately read as "placeholder"` — smart-quotes rendered via `&amp;quot;`; consider tightening to `read as placeholders`.
- **LOW** — `Q5_Body`: `send all donors the same automated email regardless of tier` — good; keep.

## FQS_Guided_Gift_Entry_HomePage.flow-meta.xml

Clean. One-screen router flow; only user-visible copy is the donor-picker header.

- **LOW** — `PickDonor_Header.fieldText`: `Pick the Account of the donor, household, or organization giving the gift. You can search by name.` — 3-item Oxford comma present, plain verbs. Keep.

---

## 3. Cross-flow terminology audit

| Term found | Canonical form | Flow files that drift | Severity |
|---|---|---|---|
| "Configure Donor Groupings branch" | **Donor Tier** (and use the actual flow name: FQS Setup — Stewardship Response Settings) | FQS_Acknowledgement_Stewardship_Tax_Guide (Q5_Body) | HIGH |
| "the donor's Contact" | **Person Account (or Contact)** | FQS_Setup_Stewardship_Response_Settings (DisplayText_AckEducation) | HIGH |
| "acknowledgment" (US) inside a Help link title | **acknowledgement** (British) elsewhere | FQS_Acknowledgement_Stewardship_Tax_Guide (Q1_Salesforce_Native) — external link only | MED |
| "in-kind donations" (lowercase) | **In-Kind** (hyphenated capitalized adjective) per style guide | FQS_Acknowledgement_Stewardship_Tax_Guide (Q2_Physical) | LOW |
| "a entry level gift" | **an entry-level gift** | FQS_Setup_Tier_Thresholds (DisplayText_EntryHeader) | HIGH |
| "a mid level" / "a major level" | **mid-level** / **major-level** (hyphenated) | FQS_Setup_Tier_Thresholds | MED |
| "a/b tests" | **A/B tests** | FQS_Campaign_Hierarchy_Setup (Screen_Final) | LOW |
| "one on one meeting" | **one-on-one meeting** | FQS_Campaign_Hierarchy_Setup (Step_0) | LOW |
| Raw picklist value bleed: `Model: Strategy` for Audience | Friendly label via formula (`Audience`) | FQS_Campaign_Hierarchy_Setup (Screen_Confirm, Screen_Final, Screen_Success) | HIGH |
| Currency phrasing: "$ thresholds" vs "giving thresholds" vs "dollar bands" | Pick one — recommend **"giving thresholds"** (already used in Tier Thresholds) | not seen elsewhere in these 7 flows | n/a |
| Em-dash usage | `—` literal Unicode | Used correctly throughout | — |

**Not drifted (verified consistent):** Donor Tier (except the one guide hit), Acknowledgement (British), fee-for-service (hyphenated), em-dash `—`, Oxford commas in three-item lists.

---

## 4. Duplicated boilerplate

Fix once, propagate:

1. **Setup Success screens.** `FQS_Setup_Tier_Thresholds.Screen_Success.DisplayText_Success` and `FQS_Setup_Stewardship_Response_Settings.Screen_Success.DisplayText_Success` share the "Your changes are being deployed. … may take up to a minute to appear on records." paragraph verbatim, plus a "Need a new donor tier?" / "Reminder:" callout with identical framing. If a shared subflow is out of scope, at least keep the two success paragraphs in lockstep going forward.
2. **Tier-Thresholds helpText, x3.** `txtMajorBrandedName / txtMidBrandedName / txtEntryBrandedName` all share the exact same helpText ("The branded name of the Tier Key shown to staff and donors … Example values: Friend, Partner, Champion or Entry, Rising, Summit."). Same for the three One-Time / Annual / Lifetime helpTexts. Any edit must touch all three.
3. **Stewardship-Response helpText, x3.** `pkMajorAck / pkMidAck / pkEntryAck` share the same "Determines whether a gift in the [tier] donor tier triggers…" template — differ only by the tier name.
4. **Campaign Hierarchy recap paragraphs, x2.** `Screen_Success.DisplayText_Success` and `Screen_Final.DisplayText_Final` both re-render the four-count model recap (Strategic / Operational / Tactical / OSC). Consider dropping the Success-screen recap since the datatable directly below already shows the created records — Final can carry the summary.
5. **Campaign Hierarchy Confirm intros, x2.** `DisplayText_ConfirmIntro_GivingPrograms` and `DisplayText_ConfirmIntro_SingleTop` share the identical tail paragraph ("Clicking **Next** will create the records. On the next screen you'll see the full hierarchy in a table for review …"). Only the count formulas above differ.

---

## 5. Recommended patch order

Per project memory `flow-builder-strips-block-style`: safe inline forms are `<span style="font-size: 16px;">TEXT</span>` and `<strong style="font-size: 20px;">HEADER</strong>` inside a bare `<p>`. Every existing DisplayText field already follows that pattern, so text-content edits inside a `<span>`/`<strong>` are safe in-place XML edits.

- **Safe to apply in place (XML edit only, no Builder round-trip):**
  - All `<choiceText>` typo / phrasing changes (no rich-text; plain string).
  - All `<helpText>` phrasing changes (plain string).
  - Screen `<label>` changes (plain string).
  - Text-content changes inside existing `<span style="font-size: 16px;">…</span>` / `<strong style="font-size: 20px;">…</strong>` blocks — the wrapping structure survives Builder.
  - All `<backButtonLabel>` / `<nextOrFinishButtonLabel>` changes (plain string).

- **Requires a Flow Builder round-trip:**
  - New `formulaModelLabel` on `FQS_Campaign_Hierarchy_Setup` and wiring it into `Screen_Confirm` / `Screen_Success` / `Screen_Final` — Formulas can be hand-authored but the Builder-managed complexValue references on the confirm screen are safer edited in Builder.
  - Fixing the `Ready_to_Choose` "No" dead-end connector in `FQS_Campaign_Hierarchy_Setup` — a decision-default-connector wiring change; do this in Builder.
  - Any changes to `flowruntime:datatable` column configs on `FQS_Suggest_Designations` and `FQS_Campaign_Hierarchy_Setup` — per memory `flow-datatable-source-authoring`, v65+ needs Builder-emitted `complexValue` shapes; no datatable changes are recommended in this pass, but flag if any surface later.

- **Do NOT rewrite (leave as-is):**
  - Any existing `&mdash;` / `&rarr;` / `&#10003;` HTML entities inside `<fieldText>` — they're inside HTML content, not the flow XML structure, and render correctly.
  - Picklist-value strings like `With Donor Restriction - Purpose` in the seeded GD Descriptions — those are canonical FQS restriction-type picklist values, not editorial copy.
