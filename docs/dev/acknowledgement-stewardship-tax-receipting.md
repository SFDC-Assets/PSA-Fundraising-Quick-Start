# Acknowledgement, Stewardship, and Tax Receipting — Do You Need Three Processes or One?

Every organization has to answer this question before turning on the shipped post-gift automation. The three activities overlap and can collapse into a single letter or email — but they solve different problems, and mixing them up costs donor trust and, potentially, tax-compliance standing.

Work through the questions below in order. Each answer narrows what you need to turn on.

> **Scope note.** This guide is written for US-based 501(c)(3) organizations. If you operate outside the US — Canadian CRA charities, UK Gift Aid, Australian DGRs, EU equivalents — the shapes below still apply, but the specific tax-receipt rules do not. Consult your local requirements before relying on an acknowledgement as a receipt.

---

## First, the three activities

**Acknowledgement** — the immediate "we received your gift" confirmation. Fast, transactional, universal. Every donor with a valid email gets one. Its job is to close the loop on the transaction: *we got it, here's the amount, here's the date, here's your deduction info*. Timing matters more than eloquence — the sooner it lands, the more the donor trusts that their gift landed where they intended.

**Stewardship** — the follow-up touch that connects the donor to the mission. Ideally a thank-you, but also a story, a program update, an impact metric, an invitation to see the work. Its job is to deepen the relationship, not to restate the transaction. Voice, personalization, and channel matter more than speed. Timing can be three days to two weeks after the gift, again at year-end, or whenever the mission has something worth sharing.

**Tax receipting** — the document a donor uses to substantiate a deduction. In the US, this is governed by IRS Publication 1771 and can typically be satisfied by a well-formed acknowledgement email (see Question 1 below). In other jurisdictions the receipt often needs its own format, sequence, and record-keeping — separate from the acknowledgement entirely.

---

## Question 1 — Can your acknowledgement double as the tax receipt?

**In the US: usually yes**, if the acknowledgement contains the elements IRS Publication 1771 requires:

- Your organization's name
- The cash amount (or a description of non-cash property — not its value; the donor determines that)
- One of: "no goods or services were provided in return" OR a description and good-faith fair-market value of anything provided in return
- For **quid-pro-quo** gifts over $75 (gala tickets, auction wins, benefit dinners): the FMV of goods received, so the donor knows the deductible portion. This disclosure is required whether the donor asks for it or not.

If your acknowledgement email contains all of the above for every gift ≥ $250, the acknowledgement IS the tax receipt. No separate document required.

**Sample language for a US template:**

> Thank you for your gift of $[amount] received on [date]. [Organization Name] is a 501(c)(3) nonprofit organization; no goods or services were provided in exchange for this contribution. Please retain this acknowledgement for your tax records.

For quid-pro-quo gifts, swap the "no goods or services" line for a description of what the donor received and its FMV.

**Salesforce also includes native gift-acknowledgement and tax-receipt functionality** — a built-in engine that generates receipt documents and handles year-end consolidation. If you need formal receipt documents (versus email-based acknowledgements), it's the shortest path. See [Set Up Gift Acknowledgments and Tax Receipts](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_set_up_gift_acknowledgments_and_tax_receipts.htm&type=5).

**Non-US orgs:** the answer is usually no — plan on separate receipts. Move to Question 3.

---

## Question 2 — Does your online donation tool already send a receipt?

Most online donation platforms send a receipt email automatically when the card charges. That receipt lands within seconds of the gift, includes the amount and date, and — if you've configured the copy — satisfies the US CWA requirement. **In practice, that receipt is often already the acknowledgement.**

Two options for handling this without double-sending:

- **Turn off the Gift Acknowledgement flow entirely** if your donation tool covers every gift. Simplest.
- **Leave it on** and have your donation tool set Acknowledgement Status as 'Sent'. The flow only acknowledges gifts where that field is still blank, so online gifts are skipped automatically and offline gifts (checks, cash, stock, in-kind) still get covered.

**Physical gifts always need something.** Checks in the mail, cash walked in, stock transfers, in-kind donations — none of these pass through your online tool, and none get an automatic receipt. If the flow is deactivated, you'll need to handle these manually. If the flow is on, it only acknowledges gifts where Acknowledgement Status is still blank or 'To Be Sent'.

---

## Question 3 — Do you want a mission touch separate from the receipt?

The acknowledgement (or the donation tool's receipt) closes the transaction. A stewardship touch does something different: it connects the donor to the work. A three-day-to-two-week follow-up with a story, program update, or impact metric is considered table stakes in most donor-relations programs.

Very few donation tools send this follow-up. Even if your donation tool handles acknowledgement end-to-end, you likely still want stewardship running.

- **Yes, I want a mission touch** → turn on the **Stewardship Response** flow. It fires ~14 days after the acknowledgement. Entry-tier donors get an automated email; major donors always route to a task for personal outreach. Full admin guide: [FQS Stewardship Response](../fqs-flow-overview.md#fqs-stewardship-response).
- **No, the acknowledgement is enough** → leave the Stewardship Response flow off. Rewrite the acknowledgement template so it carries the mission voice too — gratitude, one line about impact, done.

---

## Question 4 — Do you issue year-end consolidated tax receipts?

Some orgs — most commonly non-US charities, but also US orgs that prefer a single annual document — send a consolidated receipt every January covering the full prior year of giving.

- **Yes** → choose a tool to help you query and format the document batch. Consider Salesforce's native tax-receipting engine (linked in Question 1) also handles year-end consolidation and is worth evaluating before you build custom.
- **No** → skip.

---

## Question 5 — Do your major donors need something the automation can't do?

Automated stewardship works well for entry- and mid-tier donors. Major donors typically need a real human touch — a call from the ED, a hand-signed card, a lunch invitation, a program tour.

The shipped stewardship routing already handles this: the **Major** tier is seeded to route every gift to a task in the Stewardship Tasks queue, so major-gift officers see the task and deliver the personal outreach themselves. No automated email fires for those gifts.

If you want to change that — say, send all donors the same automated email regardless of tier — you can retune the routing in the Setup Flow (Configure Donor Groupings branch). Details in [FQS Stewardship Response](../fqs-flow-overview.md#fqs-stewardship-response).

---

## Working the process — List Views, Queues, and Action Plans

Once the flows are running, the actual work happens in Salesforce's native task-management tooling. Three pieces:

### List Views

Two GiftTransaction list views ship for triage:

- **To Be Acknowledged** — gifts where `AcknowledgementStatus` is blank or `To Be Sent` and the gift is old enough that the flow should have picked it up. Use this to spot gifts the automation skipped (external tool didn't write back, opted-out donor, blank email) and work them by hand.
- **To Be Stewarded** — gifts where the acknowledgement has already been sent and stewardship is still pending. Use this to see who's waiting on a mission touch and pull them into a personal outreach if a task hasn't been created.

Both list views are the fastest way to answer "what's on my plate right now" without navigating to a queue first.

### Queues

Four queues ship to organize the work by role. They're empty at install — add members under **Setup → Queues → [name] → Edit → Queue Members**.

| Queue | Purpose | Sends email to members? |
|---|---|---|
| **Stewardship Tasks** | Mid-tier stewardship follow-ups (mission touch, impact updates, mid-year story). | Yes |
| **Gift Processing Tasks** | Acknowledgements, tax receipting, and gift-entry tasks that need a human. | Yes |
| **Major Donor Tasks** | Prospect research, proposal drafting, and cultivation for the Moves Management pipeline. | No |
| **Executive Fundraising Tasks** | Handwritten notes, calls, and other high-touch actions reserved for the ED or Board. | No |

The email-notification setting is a per-queue choice, not a global rule. The shipped defaults notify the two high-volume operational queues on every task and stay quiet on the two executive-facing queues so leadership doesn't get pinged constantly. Flip either flag on the queue record if that pattern doesn't fit your team.

### Action Plans

Action Plans turn a single stewardship goal into a structured sequence of tasks with due dates, priorities, and owner assignments. Two Action Plan Templates ship — both target the **Account** object and both install as **Draft**, so an admin activates them after review.

**Stewardship** — a mid-tier stewardship playbook, roughly a six-month sequence built on 7-day intervals:

1. Confirm the tax receipt / formal acknowledgement was sent (day 7)
2. Immediate personal thank-you call or email (day 7)
3. Capture donor interests and passions (day 3)
4. Confirm recognition preferences — donor wall name, anonymous preference (day 3)
5. Leadership gratitude note — hand-signed by ED, Board Member, or Program Lead (day 21) → routed to Executive Fundraising Tasks
6. Share mid-year impact story — photo, beneficiary story, or short video (day 91) → routed to Stewardship Tasks
7. Invite to mission experience or insider briefing (day 182) → routed to Stewardship Tasks

Steps chain on completion of the previous step, so a slipping schedule doesn't leave orphaned tasks in the queue.

**Moves Management** — a major-donor cultivation playbook, roughly a six-month sequence covering prospect research through post-ask stewardship:

1. Conduct prospect research and wealth screening (day 14) → Major Donor Tasks
2. Execute discovery call or email outreach (day 21)
3. Log qualification notes and update the donor record (day 28)
4. Host a cultivation touchpoint — site visit, coffee with program staff (day 56)
5. Conduct formal solicitation meeting (day 28 after touchpoint)
6. Draft customized proposal and ask strategy (day 84)
7. Internal proposal review and approval (day 91) → Major Donor Tasks
8. Send post-ask follow-up and pledge form (day 35)
9. Process gift and issue official receipt (day 38) → Gift Processing Tasks
10. Executive or Board stewardship contact — handwritten note or call (day 49) → Executive Fundraising Tasks
11. Deliver impact report and schedule the next cultivation cycle (day 168) → Major Donor Tasks

Steps are marked as "Moves" (intentional donor-facing touchpoints, required) or "Tactical" (internal prep, optional). Each move creates its tactical follow-ups at the same time for clarity.

**How to use:** a gift officer opens the donor Account, launches the appropriate Action Plan Template, and works the resulting task sequence. The Action Plan record itself becomes the source of truth for that donor's cultivation or stewardship journey — the history of moves and tactical follow-ups lives on one record, not scattered across dozens of tasks.

---

## What ships in the Quick Start

Two flows and three email templates. Both flows ship with placeholder templates — you'll customize the copy before go-live.

**Flows** (Setup → Flows):

| Flow | Fires | Purpose |
|---|---|---|
| **Gift Acknowledgement** | Daily, 06:00 UTC | Emails or creates a task for every paid gift older than 3 days that hasn't been acknowledged. Routes to email if the donor has a valid opted-in email address; otherwise creates a task for a human to handle. Deep-dive: [FQS Gift Acknowledgement](../fqs-flow-overview.md#fqs-gift-acknowledgement). |
| **Stewardship Response** | Daily, 07:00 UTC | Sends a tier-differentiated mission touch ~14 days after the acknowledgement. Entry-tier donors get an automated email; major donors always route to a task for personal outreach. Deep-dive: [FQS Stewardship Response](../fqs-flow-overview.md#fqs-stewardship-response). |

**Email templates** (Setup → Email Templates → Public folder):

- **Gift Acknowledgement** — full-deduction acknowledgement. Ships with placeholder copy.
- **Gift Acknowledgement (Partial Deduction)** — used when `TaxDeductionAmount < CurrentAmount` (event tickets, in-kind, quid-pro-quo). Ships with placeholder copy.
- **Stewardship Response (Standard)** — the mission touch. Ships with placeholder copy.

**Do NOT go live with the shipped copy.** The templates deliberately read as "placeholder" so an accidental activation doesn't send generic filler to real donors. Rewriting the copy — and, for US orgs, making sure the acknowledgement contains the IRS-required elements from Question 1 — is a launch-checklist task.

---

## Related documentation

- [FQS Gift Acknowledgement](../fqs-flow-overview.md#fqs-gift-acknowledgement) — full admin guide for the acknowledgement flow.
- [FQS Stewardship Response](../fqs-flow-overview.md#fqs-stewardship-response) — full admin guide for the stewardship flow, including tier routing and CMDT configuration.

- [Salesforce — Set Up Gift Acknowledgments and Tax Receipts](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_set_up_gift_acknowledgments_and_tax_receipts.htm&type=5) — Salesforce's native gift-acknowledgement and tax-receipt engine.
