# FQS Home Page — Copy Edit Review

Reviewer pass over the FQS Home Page Review doc, cross-checked against
`force-app/main/default/flexipages/FQS_Home_Page_Default.flexipage-meta.xml`
and the five referenced flows.

---

## 1. Overview

The copy is generally warm, plainspoken, and instructive — the strongest
passages (Section 5 Grid, Section 4/6 Guided Gift Entry) read like a
practitioner talking to another practitioner. Three systemic issues drag
the doc down:

1. **The section numbering, ordering, and inventory in the review doc do
   not match what is actually deployed** (flexipage has nine accordion
   sections, review doc describes eight; flexipage puts "Configure
   Stewardship Response Settings" at position 7 while the review doc
   places it at position 4; the entire "8. Review Automation" section is
   absent from the review doc).
2. **Terminology is inconsistent across three axes**: Donor Tier vs.
   Donor Grouping, Contact vs. Person Account, and
   acknowledgement/acknowledgment. The flow name assumption in the task
   brief (`FQS_Setup_Donor_Grouping_Thresholds`) is stale — the deployed
   flow is `FQS_Setup_Tier_Thresholds` and its user-facing label is
   "FQS Setup — Donor Tier Thresholds", so Donor Tier is the canonical
   form on disk.
3. **Two "placeholder" callouts in the review doc are stale**: the
   Section 3 placeholder (`//delete this...`) is already replaced with
   full copy in the deployed flexipage, and Section 6 is described as
   "rich-text only" but actually embeds a flow
   (`FQS_Acknowledgement_Stewardship_Tax_Guide`).

Tone is otherwise consistent. No hype/marketing language triggered
(no "unlock", "supercharge", "deep engagement"). Voice is appropriately
Salesforce-admin-facing.

---

## 2. High-priority edits (factual / structural)

### 2.1 Section numbering + inventory is wrong

**Location:** review doc opening layout ("Section 1 … Section 8").

**Evidence:** `FQS_Home_Page_Default.flexipage-meta.xml` accordion labels
(lines 218, 236, 254, 272, 290, 308, 326, 344, 362) enumerate **nine**
sections in this order:

| # | Deployed label | Review-doc # | Review-doc label |
|---|---|---|---|
| 1 | Set Up Gift Designations | 1 | match |
| 2 | Establish Solicitation and Outreach Tracking (Campaign Hierarchy) | 2 | match |
| 3 | Define Donor Tiers and Thresholds | 3 | match |
| **4** | **Review Guided Gift Entry** | 6 | out of order |
| 5 | Enter Gift Batches with Gift Entry Grid | 5 | match |
| **6** | **Guidance on Acknowledgement, Stewardship, and Tax Receipting** | 7 | out of order |
| **7** | **Configure Stewardship Response Settings** | 4 | out of order |
| **8** | **Review Automation** | — | **missing entirely** |
| 9 | Update Home Page | 8 | number off-by-one |

**Recommendation:** Renumber the review doc to match the deployed
accordion order and add the missing "8. Review Automation" section
(copy is in the flexipage rich-text at
`flexipage_richText_review_automation`, roughly 350 words covering the
two scheduled flows, three email templates, four queues, and the
suggested activation order).

### 2.2 Wrong flow name for donor-tier setup

**Location:** review doc Section 3 references
`FQS_Setup_Donor_Grouping_Thresholds`.

**Evidence:** The flow file on disk is
`force-app/main/default/flows/FQS_Setup_Tier_Thresholds.flow-meta.xml`,
its `<label>` is "FQS Setup — Donor Tier Thresholds", and the flexipage
embeds it by that API name (line 70).

**Recommendation:** Everywhere the review doc says
`FQS_Setup_Donor_Grouping_Thresholds`, use `FQS_Setup_Tier_Thresholds`.
This also resolves the "Donor Grouping" vs. "Donor Tier" terminology
choice — canonical form is **Donor Tier** (see §5).

### 2.3 Section 6 is not rich-text only

**Location:** review doc Section 7 note "rich-text only".

**Evidence:** Flexipage line 164 embeds
`FQS_Acknowledgement_Stewardship_Tax_Guide` inside the "6. Guidance on
Acknowledgement, Stewardship, and Tax Receipting" accordion.

**Recommendation:** Update the review doc to note that this section
embeds a flow (verbatim strings live in the flow XML, not the
flexipage), and either verbatim-quote its screens or note the flow name
so a reviewer can pull them.

### 2.4 Section 3 placeholder is stale

**Location:** review doc Section 3 says
`"//delete this and put into the header of the flow" (PLACEHOLDER)`.

**Evidence:** Flexipage line 52 already contains a full four-paragraph
callout ("What donor tiers do for you… Changes take up to a minute…").

**Recommendation:** Remove the PLACEHOLDER language from the review
doc, or paste the current deployed copy in for reviewer sign-off. §6
below proposes a mild rewrite in case an alternative is wanted.

### 2.5 Bottom-right accordion labels are wrong

**Location:** review doc: "Bottom-right accordion: Acknowledgments
list-view stub, Stewardship placeholder."

**Evidence:** Flexipage lines 662 and 680 — the two accordion labels
are "To Be Acknowledged" and "To Be Stewarded". Both are live
`filterListCard` components pointing at real GiftTransaction list views
(`FQS_To_Be_Acknowledged`, `FQS_To_Be_Stewarded`), not stubs/placeholders.

**Recommendation:** Fix the description to "Bottom-right accordion: To
Be Acknowledged (GiftTransaction list) / To Be Stewarded
(GiftTransaction list)."

### 2.6 Gift Batch template count mismatch

**Location:** review doc Section 5 says "5 templates enumerated".

**Evidence:** The Section 5 flexipage rich-text lists five (Individual
Outright Gifts, Single Payment Pledges, Pledge Payments, Event
Registrations, Undefined Batch). The Create Gift Batch launcher flow
`FQS_Create_Gift_Batch.flow-meta.xml` offers **six** — the five above
**plus Multiple Payment Pledges**.

**Recommendation:** Either add Multiple Payment Pledges to the Section 5
enumeration (recommended — the template exists and users will pick it)
or explicitly note in the review doc that Section 5 enumerates a subset.

### 2.7 Person Account vs. Contact

**Location:** Section 4 flexipage stewardship intro:
"Email opt-outs on the donor's **Contact** always override these
settings" (line 88).

**Evidence:** FQS is a Nonprofit Cloud / Person Account project; the
memory note `fundfirst-account-recordtypes` confirms Account.Organization
+ Person Account. Every other donor reference in the deployed copy uses
"donor" abstractly and dodges the Contact/Person Account distinction.

**Recommendation:** Change the Section 4 intro sentence to
"Email opt-outs on the donor's **Person Account** always override these
settings". Sweep any other "Contact" references in the review doc.

### 2.8 Section 4 name shift (flexipage vs. flow header)

The deployed accordion label is "**Define Donor Tiers and Thresholds**"
(no "Setup" prefix) but the embedded flow's header display text starts
with "**Adjust the giving thresholds for each donor tier to your
nonprofit organization.**". These agree. However the flow's success
screen still says "Donor tier updates run in the background…" while
the review-doc summary uses "Donor Grouping". Standardize on **Donor
Tier** throughout the review doc.

### 2.9 Missing "Review Automation" content in review doc

This is the same as 2.1 but worth calling out separately because
Section 8 is the operational payoff of the whole Home Page (two
scheduled flows install deactivated, three email templates need
rewriting, four queues need members). If the review doc's job is to
verbatim-quote every user-visible string, this omission is the biggest
single gap.

---

## 3. Medium-priority edits (clarity / phrasing)

### 3.1 Section 5 — "consider using grid"

Before: *"Consider using grid when:"*
After: *"Consider using **Grid** when:"* — capitalize product name for
consistency with "Guided Gift Entry" treatment two paragraphs below.

### 3.2 Section 5 — awkward transition

Before: *"If these don't apply consider Guided Gift Entry. Guided Gift
Entry provides a form based entry tool, more clicks and less flexible
but more direction for the user."*

After: *"If these don't apply, consider **Guided Gift Entry**. It's a
form-based tool — more clicks and less flexibility, but more direction
for the user."*

Fixes: missing comma after "apply", hyphenation of "form-based", parallel
construction ("less flexible" → "less flexibility"), replaces the run-on
with an em-dash break.

### 3.3 Section 6 — "form based" hyphenation

Before: *"It is a form based experience asking questions to ensure your
gift is entered accurately."*

After: *"It's a **form-based** experience that asks questions to make
sure the gift is entered accurately."*

### 3.4 Section 6 — Recurring Gift wording

Before: *"a set amount is given every month with no fixed end date,
typically created through an integration with an online form tool."*

After: *"a fixed amount given on a recurring schedule (typically
monthly) with no fixed end date, usually created through an online
donation form integration."*

Fixes: not always monthly; "created through an integration with an
online form tool" is a mouthful.

### 3.5 Section 6 — Multiple Payment Pledge fragment

Before: *"Either with even installments (monthly, quarterly, yearly)
over a defined period or on a custom schedule."*

After: *"Either even installments (monthly, quarterly, yearly) over a
defined period, or a custom schedule when dates are irregular and/or
amounts vary."*

Fixes: sentence-fragment starting with "Either"; the "and/or" tightens
the second clause and matches the flow's own wording.

### 3.6 Section 8 (deployed) — trailing double-space

Deployed rich-text line 200 has a double-space before the em-dash:
*"…initial configuration is done, or leave parts of it in place  — some
setup flows…"*. Fix to a single space.

### 3.7 Sidebar Glossary — "inkind"

Deployed glossary bullet: *"An inkind gift"* (line 727). Every other
place in the flexipage spells it **In-Kind**. Fix to "An in-kind gift".

### 3.8 Sidebar Glossary — "fee for service or goods"

Deployed glossary reads *"A fee for service or goods"*; Gift Batch
Section 5 uses *"fee-for-service"*. Standardize on **fee-for-service**
(hyphenated) as the modifier form, unhyphenated only when used as a
noun phrase.

---

## 4. Low-priority edits (grammar / punctuation / consistency)

- **Em-dash uniformity.** The deployed rich-text uses `&mdash;` (`—`)
  consistently. The review doc mixes `—` and plain `-`. Recommend `—`
  everywhere the intent is a parenthetical break.
- **Acknowledgement vs. acknowledgment.** Deployed copy uses
  **acknowledgement** (British-influenced form) 6× and
  **Acknowledgment(s)** 2× (Section 6 label "…Acknowledgement…" is
  British form; bottom-right list card name pre-refactor may have been
  American). Standardize on **acknowledgement** per the majority.
- **"G. Commitments Needing Action"** (bottom-left accordion label,
  line 557). The single-letter abbreviation is jarring given the sidebar
  has room. Recommend expanding to **"Gift Commitments Needing Action"**
  to match the sibling "Opportunities Needing Action".
- **Oxford comma.** Deployed copy uses the Oxford comma consistently
  ("Entry, Mid, and Major"). Review doc drops it in a couple of
  three-item lists. Add.
- **"tier-differentiated"** (Section 8, line 182): confirm hyphen — it's
  correct as a compound modifier.
- **"quid-pro-quo"** (line 182): review whether to hyphenate — Chicago
  keeps it as three words when noun, hyphenates as adjective. Deployed
  usage is adjectival ("quid-pro-quo") — correct.

---

## 5. Terminology audit

| Term (loose forms found) | Canonical | Deployed hits | Notes |
|---|---|---|---|
| Donor Tier / Donor Grouping | **Donor Tier** | 12 Tier / 0 Grouping | Flow file, flow label, all rich-text use Tier. Review-doc task brief was mistaken about the flow filename. |
| Person Account / Contact (as donor) | **Person Account** | 1 Contact / 0 PA | Fix Section 4 intro. |
| acknowledgement / acknowledgment | **acknowledgement** | 6 / 2 | British form dominates. |
| Gift Commitment / G. Commitment | **Gift Commitment** | many / 1 | Expand the abbreviation in the bottom-left accordion label. |
| In-Kind / inkind | **In-Kind** (adjective), **in-kind** (attributive) | 4 / 1 | Fix glossary. |
| fee-for-service / fee for service | **fee-for-service** (modifier) | 1 / 1 | Standardize modifier form. |
| em-dash — / hyphen - as break | **—** (`&mdash;`) | dominant | Sweep review doc. |
| "Opportunity" for pledge intake | keep — matches flow copy | — | No change; ambiguous but intentional. |

---

## 6. Section 3 — proposed replacement text

The deployed flexipage already carries full copy for Section 3 (the
"//delete this…" placeholder in the review doc is stale). The current
deployed text reads well; a lightly tightened variant if a rewrite is
desired:

> **How donor tiers work in FQS**
>
> Donor tiers sort every donor into one of three levels — Entry, Mid,
> and Major — based on the size of their giving. The tier drives
> acknowledgement copy, stewardship routing, gift-level formulas, and
> the reports and dashboards that ship with FQS. Adjust the thresholds
> below so they match how your organization thinks about donor levels.
>
> Each tier has three dollar bands you can tune: **One-Time** (a single
> gift big enough to qualify), **Annual** (fiscal-year cumulative
> giving), and **Lifetime** (all-time cumulative giving). A donor lands
> in the highest tier they qualify for on any of the three bands.
>
> You can also rebrand the tier names — use *Friend / Partner /
> Champion* if that fits your voice better than Entry / Mid / Major.
>
> Changes take up to a minute to flow through — FQS writes the new
> thresholds to Custom Metadata, which the platform deploys
> asynchronously.

Recommendation: keep the deployed copy as-is; it already matches this
tone. Delete the placeholder note from the review doc.

---

## 7. Section 6 (deployed) / Section 7 (review doc) — proposed
subsection on Acknowledgement vs. Stewardship vs. Tax Receipting

Insert this three-paragraph block at the top of the Section 6 guidance
(or into the embedded `FQS_Acknowledgement_Stewardship_Tax_Guide`
flow's opening screen):

> **Three distinct touches, one pipeline**
>
> **Acknowledgement** is the first response after a gift is received.
> Its purpose is to confirm the transaction, thank the donor
> specifically for the gift they just made, and (when applicable)
> provide the tax-deductible amount. Acknowledgement should feel
> prompt — FQS ships a daily scheduled flow that emails or tasks every
> paid gift older than three days that hasn't been acknowledged.
>
> **Stewardship** is the follow-up touch that comes after
> acknowledgement — a mission update, an impact story, or a personal
> call from a fundraiser. Its purpose is not to confirm a gift but to
> deepen the relationship in the weeks after. Routing is
> tier-differentiated: mid-tier donors typically receive an automated
> stewardship email; lifetime major donors are routed to a task for
> personal follow-up.
>
> **Tax Receipting** is the formal, IRS-facing record the donor may
> need at year-end to substantiate a deduction. It overlaps with
> acknowledgement (a well-formed acknowledgement email can double as a
> receipt) but is not the same thing — a receipt must state the
> deductible amount, the date, and whether goods or services were
> received in return. For event tickets and quid-pro-quo gifts, the
> deductible amount is smaller than the amount paid; FQS ships a
> separate "Gift Acknowledgement (Partial Deduction)" template for
> those cases.

---

## Sanity-check summary

- Deployed flexipage rich-text is generally cleaner than the review
  doc's transcription; several "placeholder" and "stub" notes in the
  review doc are stale.
- Highest-priority fix: renumber sections 4–9 in the review doc and add
  the missing Section 8 (Review Automation).
- Second-highest: replace every "Donor Grouping" and
  `FQS_Setup_Donor_Grouping_Thresholds` reference with "Donor Tier" and
  `FQS_Setup_Tier_Thresholds`.
- Third-highest: fix the "Contact" → "Person Account" reference in the
  Section 4 stewardship intro; fix the two bottom-right accordion labels
  ("To Be Acknowledged" / "To Be Stewarded", not "Acknowledgments list-
  view stub / Stewardship placeholder").
