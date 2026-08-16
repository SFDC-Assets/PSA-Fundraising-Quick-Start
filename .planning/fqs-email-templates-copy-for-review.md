# FQS Email Templates — Copy for Review

**Purpose:** all copy currently shipping in FQS's three canonical email templates, plus concrete suggestions for tightening the language before go-live. Marketing / comms owns the final wording; engineering wired the merge fields and the send mechanics.

**Deploy status (as of 2026-08-14):** all three templates live in a new dedicated **FQS Templates** Lightning email folder in the org. Legacy versions previously sat in *Unfiled Public Classic Email Templates* (Salesforce's system fallback bucket) and have been relocated. See "House-keeping" at the bottom for one orphan template that needs manual cleanup.

---

## Where the templates sit now


| Template                                     | Folder        | DeveloperName                       | Type | Sent by                                                                                                      |
| -------------------------------------------- | ------------- | ----------------------------------- | ---- | ------------------------------------------------------------------------------------------------------------ |
| FQS Gift Acknowledgement                     | FQS Templates | `FQS_Gift_Acknowledgement`          | text | `FQS_Gift_Acknowledgement` flow — full-deduction path                                                       |
| FQS Gift Acknowledgement (Partial Deduction) | FQS Templates | `FQS_Gift_Acknowledgement_Partial`  | text | `FQS_Gift_Acknowledgement` flow — partial-deduction path (routed when `TaxDeductionAmount < CurrentAmount`) |
| FQS Stewardship Response (Standard)          | FQS Templates | `FQS_Stewardship_Response_Standard` | text | `FQS_Stewardship_Response` flow — daily, T+14 days after acknowledgement                                    |

**Source of truth:** `force-app/main/default/email/FQS_Templates/`. Edits made in Setup should be retrieved back to source (`sf project retrieve start -m EmailTemplate:FQS_Templates/*`).

**Type is `text`.** These are plain-text templates by design — highest deliverability, cleanest fallback, no marketing-suite dependency. Rich HTML variants can be layered in later if the marketing team wants brand chrome, but the underlying tax/impact copy should read cleanly in plain text first.

---

## The philosophy behind the two touches

FQS separates two donor comms that many small shops accidentally collapse into one:

- **Acknowledgement** — *transactional*, universal, IRS-facing. Every donor with a valid email gets one. Purpose: "we received your gift; here's your deduction info; keep this for your records." No storytelling, no ask.
- **Stewardship** — *relational*, tier-gated, mission-facing. Sent T+14 days after acknowledgement so the thank-you has time to land. Purpose: "here's what your gift is doing." Not a fundraising ask — a bridge to the next gift.

The templates below reflect that split. **Keep it that way.** Merging impact stories into the acknowledgement dilutes the tax-receipt integrity; merging tax language into the stewardship touch turns a relationship note into a form letter.

---

## Template 1 — FQS Gift Acknowledgement (Full Deduction)

**Subject:** `Thank you for your gift!`

**Body (current):**

```
Dear {!Contact.Salutation} {!Contact.FirstName},

Thank you for your generous gift of ${!GiftTransaction.CurrentAmount} to {!Organization.Name}, received on {!GiftTransaction.TransactionDate}.

Your support enables us to continue our mission and make a meaningful difference in the communities we serve. We are truly grateful for your generosity.

For your tax records: {!Organization.Name} is a 501(c)(3) nonprofit organization. No goods or services were provided in exchange for this contribution. Please retain this letter as your official acknowledgement of your charitable gift of ${!GiftTransaction.CurrentAmount} made on {!GiftTransaction.TransactionDate}.

With deep gratitude,

{!Organization.Name}

---
Questions about your gift? Please contact us and reference your gift record.
This is an automated acknowledgement sent on behalf of {!Organization.Name}.
```

### Merge fields in use


| Merge field                          | Resolves to                                           | Notes                                                                                                                                                           |
| ------------------------------------ | ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `{!Contact.Salutation}`              | Contact's Salutation picklist (Mr./Ms./Dr./Mx./blank) | Renders`Mr. Jane` — the space between salutation and first name is intentional. Blank salutation → a leading space; consider trimming or using a formula alt. |
| `{!Contact.FirstName}`               | Contact.FirstName                                     | Person Account contacts resolve fine; org gifts route to the primary contact via the flow's Contact lookup.                                                     |
| `{!GiftTransaction.CurrentAmount}`   | The gift amount at time of send                       | Rendered as a raw number (e.g.`250.00`). See suggestion #2 below.                                                                                               |
| `{!GiftTransaction.TransactionDate}` | Gift date                                             | Renders in the user's locale (`8/14/2026`). Consider a long-form suggestion below.                                                                              |
| `{!Organization.Name}`               | Company Info → Organization Name                     | Set in Setup → Company Information. Verify this is set correctly before go-live.                                                                               |

### Suggested improvements

**1. Handle blank salutations gracefully.** Right now `Dear  Jane,` (double space) is possible when Salutation is blank. Two options:

- Drop the salutation entirely — `Dear {!Contact.FirstName},` reads warmer for individual giving anyway.
- Or, if you want honorifics for a formal audience, use a formula field on Contact (e.g. `FQS_Greeting__c = IF(ISBLANK(Salutation), FirstName, Salutation & " " & LastName)`) and merge that instead.

Answer: Drop the salutation entirely

**2. Currency formatting.** `${!GiftTransaction.CurrentAmount}` renders as `$250.00`, which is fine, but rows like `$250` (no cents) or `$1250.00` (no thousands separator) can look sloppy. Salesforce classic email templates don't support inline formatting; the two options are:

- Accept the raw output (safe, always readable)
- Add a currency-formatted formula text field on GiftTransaction and merge that (`FQS_Amount_Formatted__c = TEXT(CurrentAmount)` won't help — you'd want a text-with-thousands-formula, which is doable but ugly). For a plain-text template, honestly the raw number is fine.

Answer: Yes go ahead and create this.

**3. Long-form date for the tax record line.** Tax receipts read more formally if the *record date* is spelled out even though the top-of-letter date is casual. Consider adding a `FQS_Transaction_Date_LongForm__c` formula (`TEXT(MONTH(TransactionDate)) & "/" & TEXT(DAY(TransactionDate)) & "/" & TEXT(YEAR(TransactionDate))` is basically the default; the interesting version spells the month). Not required.

Answer: Yes go ahead and create this.

**4. IRS boilerplate — is it correct for your org?** The line "No goods or services were provided in exchange for this contribution" is the IRS-preferred wording for a fully deductible gift where the donor received nothing of value. This is correct for cash, check, credit-card, and stock gifts that are outright transfers. It is **not** correct for:

- Event tickets (donor got a ticket → partial deduction template)
- Benefit dinners (donor got a meal → partial)
- Auction wins (donor got goods → partial)
- Membership gifts where the member gets tangible benefits

The flow already routes those cases to the Partial template based on `TaxDeductionAmount < CurrentAmount`, so this template is safe *as long as staff correctly stamp TaxDeductionAmount on non-standard gifts.* Worth calling out in training.

Answer: Add to email template review considerations in readme

**5. Consider an "impact preview" line — but keep it universal.** Some shops add one generic sentence between the thank-you and the tax block, like:

> *"Your support helps us run the programs that reach [community/region/mission]."*

This walks up to the stewardship line without crossing it. If you'd rather not risk it, leave the acknowledgement lean — the stewardship email is where impact belongs.

Answer: Make it generic and just say something like [PROVIDE SOME INFO ABOUT YOUR HISTORY, A SPECFIC PROGRAM, PERSON OR YOUR TOTAL IMPACT]

### Full-deduction example rendered

Assuming `Salutation = "Dr."`, `FirstName = "Elena"`, `CurrentAmount = 500.00`, `TransactionDate = 8/14/2026`, `Organization.Name = "Coastal Land Trust"`:

```
Dear Dr. Elena,

Thank you for your generous gift of $500.00 to Coastal Land Trust, received on 8/14/2026.

Your support enables us to continue our mission and make a meaningful difference in the communities we serve. We are truly grateful for your generosity.

For your tax records: Coastal Land Trust is a 501(c)(3) nonprofit organization. No goods or services were provided in exchange for this contribution. Please retain this letter as your official acknowledgement of your charitable gift of $500.00 made on 8/14/2026.

With deep gratitude,

Coastal Land Trust

---
Questions about your gift? Please contact us and reference your gift record.
This is an automated acknowledgement sent on behalf of Coastal Land Trust.
```

---

## Template 2 — FQS Gift Acknowledgement (Partial Deduction)

**Subject:** `Thank you for your gift!`

**Body (current):**

```
Dear {!Contact.Salutation} {!Contact.FirstName},

Thank you for your generous gift of ${!GiftTransaction.CurrentAmount} to {!Organization.Name}, received on {!GiftTransaction.TransactionDate}.

Your support enables us to continue our mission and make a meaningful difference in the communities we serve. We are truly grateful for your generosity.

For your tax records: {!Organization.Name} is a 501(c)(3) nonprofit organization. The tax-deductible portion of your gift is ${!GiftTransaction.TaxDeductionAmount}. Please retain this letter as your official acknowledgement.

With deep gratitude,

{!Organization.Name}

---
Questions about your gift? Please contact us and reference your gift record.
This is an automated acknowledgement sent on behalf of {!Organization.Name}.
```

### Extra merge field beyond the full-deduction template


| Merge field                             | Resolves to                    | Notes                                                                                                                                                                                                                                                                         |
| --------------------------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `{!GiftTransaction.TaxDeductionAmount}` | Deductible portion of the gift | Staff must set this manually or the platform computes it from FMV on event registrations. If it's blank or equal to CurrentAmount, the routing decision in the flow sends the*full-deduction* template — this template only fires when `TaxDeductionAmount < CurrentAmount`. |

### Suggested improvements

**1. Consider naming what the non-deductible portion was.** IRS Publication 1771 recommends that partial-deduction receipts *describe the goods/services* the donor received. The current template omits that — it says the deductible amount but not what was received in exchange. For event tickets, benefit dinners, and auction wins this could be improved with an additional field, e.g. `GiftTransaction.FQS_Benefit_Description__c`, and this line inserted:

> *"In exchange for this gift, you received {!GiftTransaction.FQS_Benefit_Description__c} with a fair-market value of ${!GiftTransaction.FQS_FMV_Received__c}, which is not tax-deductible. The tax-deductible portion is ${!GiftTransaction.TaxDeductionAmount}."*

That's more work — new field, staff have to fill it — but it's what a strict tax auditor wants to see. Flag as **v2 enhancement**, not a blocker for go-live.

Agree on Flag as **v2 enhancement**. Thought is to add it to the campaign.

**2. Consistency with the full-deduction template.** The two templates diverge only in the tax-block paragraph. Keeping the greeting, closing, and footer identical is deliberate — it means the donor sees the same voice regardless of which template fired. Preserve that when editing.

Agree

### Partial-deduction example rendered

Assuming `Salutation = "Mr."`, `FirstName = "Sam"`, `CurrentAmount = 250.00`, `TaxDeductionAmount = 150.00`, `TransactionDate = 8/14/2026`, `Organization.Name = "Coastal Land Trust"` — the donor attended a $100 benefit dinner:

```
Dear Mr. Sam,

Thank you for your generous gift of $250.00 to Coastal Land Trust, received on 8/14/2026.

Your support enables us to continue our mission and make a meaningful difference in the communities we serve. We are truly grateful for your generosity.

For your tax records: Coastal Land Trust is a 501(c)(3) nonprofit organization. The tax-deductible portion of your gift is $150.00. Please retain this letter as your official acknowledgement.

With deep gratitude,

Coastal Land Trust

---
Questions about your gift? Please contact us and reference your gift record.
This is an automated acknowledgement sent on behalf of Coastal Land Trust.
```

---

## Template 3 — FQS Stewardship Response (Standard)

**Subject:** `The impact of your support`

**Body (current):**

```
Dear {!Contact.Salutation} {!Contact.FirstName},

A little while ago you made a gift of ${!GiftTransaction.CurrentAmount} to {!Organization.Name}, and we sent along our thanks. Today we wanted to share a bit more about the difference your support is making.

[Marketing: replace with a short story, program update, or impact metric that connects the donor's specific gift to the mission. This is not a fundraising ask — it is a relationship-building touch.]

Your generosity is not just a transaction. It is a partnership, and we are grateful to have you alongside us in this work.

With warm regards,

{!Organization.Name}

---
If you would prefer not to receive follow-up messages like this, please let us know.
This is an automated stewardship message sent on behalf of {!Organization.Name}.
```

### Suggested improvements

**1. Fill the marketing placeholder before go-live.** The `[Marketing: replace with…]` line is a deliberate scaffold, but it will ship in that state if nobody edits it. The stewardship touch only works if the middle paragraph feels like it was written for *this* donor by a real human. Three swap-in patterns that work:

**a) The single impact stat.**

> *"Since you gave, our conservation crew has restored 4.2 acres of coastal wetland — enough to house the nesting shorebird colonies we've been rebuilding for two years."*

Concrete, verifiable, cites a specific number the donor can feel. Best for gifts under $500 where you don't have staff time to personalize.

**b) The program vignette.**

> *"Last Tuesday morning, twenty-three seventh-graders from Bayview Middle stood on the beach we protect and pulled fifty pounds of plastic out of the tideline. They asked our educator whether the birds would come back. She said yes — because of gifts like yours."*

Story shape: person + action + emotional beat. Best for gifts that support a specific program you can tell a story about.

**c) The named-mission reminder.**

> *"Every dollar you give goes toward keeping this coast wild. That's the whole mission — not a slogan, a headcount, and a boat that runs on donated fuel."*

Values-forward, low personalization cost, works for a foundation gift where you're not sure which program to cite. Best when you don't have a fresh story handy.

**Anti-pattern to avoid.** Do NOT write: *"Consider making another gift today at [link]."* That turns stewardship into acquisition. The whole point of the T+14 gap and the separate template is to build trust *without* asking. The next ask should come from a human on a different channel weeks later.

Answer: Again I don't want any examples just clear instructions on what to do. Some of these examples would be great for some, and cloying for others. 

**2. The subject line "The impact of your support" is fine but generic.** If you want more open-rate lift, personalize the subject slightly:

- `"What your gift to {!Organization.Name} is doing"` — direct, verb-forward
- `"An update from {!Organization.Name}"` — safe and mailable
- `"Thanks again — plus a small update"` — leans into the fact that they were just thanked

Merge fields work in subject lines; test in the Setup preview before locking.

Answer 2: I like "Thanks again'.

**3. The opt-out footer is honest but blunt.** *"If you would prefer not to receive follow-up messages like this, please let us know"* is a plain-language substitute for a real unsubscribe link. If you're using Salesforce's email preferences, replace it with the standard preferences link. If you're not, keep it as-is — telling donors to just reply is fine for small shops and better than a broken link.

Answer: Agree

**4. Consider a stewardship variant per donor tier.** The `FQS_Stewardship_Response` flow already loads `FQS_Donor_Tier__mdt` for the donor's tier and routes based on `FQS_Auto_Stewardship__c` (Include All / Exclude Lifetime / Exclude All). It would be straightforward to add a second stewardship template — `FQS_Stewardship_Response_Major` — for major/leadership tiers, with softer copy and a personal-outreach nudge. That's a **v2 enhancement**; the current single template covers the standard case and hands major-donor stewardship off to a Task queue anyway.

Answer: Answer its v2 enhancement. The readme should encourage folks to use these templates as a starting point for customization from the activity pain of the record.

### Stewardship example rendered

Assuming `Salutation = "Ms."`, `FirstName = "Priya"`, `CurrentAmount = 1000.00`, `Organization.Name = "Coastal Land Trust"`, and marketing has replaced the placeholder with variant (a) above:

```
Dear Ms. Priya,

A little while ago you made a gift of $1000.00 to Coastal Land Trust, and we sent along our thanks. Today we wanted to share a bit more about the difference your support is making.

Since you gave, our conservation crew has restored 4.2 acres of coastal wetland — enough to house the nesting shorebird colonies we've been rebuilding for two years.

Your generosity is not just a transaction. It is a partnership, and we are grateful to have you alongside us in this work.

With warm regards,

Coastal Land Trust

---
If you would prefer not to receive follow-up messages like this, please let us know.
This is an automated stewardship message sent on behalf of Coastal Land Trust.
```

---

## House-keeping (post-review action items)

**1. Orphan template to delete.** The org still has one legacy template in *Public Email Templates* that predates FQS's canonical set:

- **Name:** `FQS Donor Acknowledgment`
- **DeveloperName:** `FQS_Donor_Acknowledgment_1783720302492`
- **Id:** `00XWB000001ekzd2AA`
- **Status:** no subject, no description, no body content retrieved to source, not referenced by any flow

It's the ghost of an earlier experiment. Once marketing has signed off on the three canonical templates above, delete this one via Setup → Email → Classic Email Templates → *FQS Donor Acknowledgment* → Delete. Do not deploy it in source — it should not exist.

Answer: agree delete.

**2. Retrieve any Setup edits back to source.** If marketing edits copy in the Setup UI (which is fine and expected), pull the changes back before committing:

```bash
sf project retrieve start -m EmailTemplate:FQS_Templates/FQS_Gift_Acknowledgement
sf project retrieve start -m EmailTemplate:FQS_Templates/FQS_Gift_Acknowledgement_Partial
sf project retrieve start -m EmailTemplate:FQS_Templates/FQS_Stewardship_Response_Standard
```

Then commit. Otherwise the next `sf project deploy` will overwrite the marketing edits with the source-controlled placeholder copy.

**3. `README.md` reference.** The Post-Install Considerations section of the README should point installers at this file (or the folder) so they know where to find and edit the templates. Not a blocker — worth a one-line pointer.

Answer: I don't think the readme should have links to other internal files.

**4. Description fields.** All three templates now have real `<description>` values in source (they describe purpose, sender, and marketing-vs-engineering ownership). Setup UI shows those on the template detail page. Keep them accurate if intent shifts.

---

## Change log


| Date       | Change                                                                                                                                                            |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-08-14 | Templates moved from*Unfiled Public Classic Email Templates* → new *FQS Templates* Lightning email folder. Deploy IDs `0AfWB00000E2bLB0AZ` (folder + templates). |
| 2026-08-14 | Review markdown authored (`.planning/fqs-email-templates-copy-for-review.md`).                                                                                    |
