# FQS Gift Acknowledgement Flow — Admin Guide

## What it does

The **FQS Gift Acknowledgement** flow runs on a daily schedule (06:00 UTC). It queries all `GiftTransaction` records where `Status = Paid`, `TransactionDate` is at least 3 days in the past, `AcknowledgementStatus` is blank or `To Be Sent`, and `Category != Fee/Payment`. The 3-day window lets digital-platform ingest and any refunds or reversals settle before an acknowledgement fires. `Fee/Payment` transactions (event tickets, service fees) are excluded because they are not gifts.

Acknowledgement is a **universal rule** — every donor with a valid email receives one, regardless of donor tier or lifetime giving. Its job is to confirm receipt: "we got your gift, thanks, here is your deduction info." Tier-differentiated relationship-building lives in the separate **FQS Stewardship Response** flow (see `docs/gift-stewardship-flow.md`), which fires ~14 days after acknowledgement is sent.

For each qualifying gift the flow routes to one of two paths:

- **Email path** — sends either the FQS Gift Acknowledgement (full deduction) or FQS Gift Acknowledgement (Partial Deduction) email template to the donor's contact.
- **Task path** — creates a Task owned by the **FQS Gift Acknowledgements** queue so a team member can send a personal acknowledgement (physical letter, phone call, etc.).

After the email is sent, `AcknowledgementStatus` is set to `Sent` and `AcknowledgementDate` is stamped. After a Task is created, `AcknowledgementStatus` is set to `To Be Sent`; the queue member flips it to `Sent` and sets `AcknowledgementDate` after the personal outreach is complete.

---

## Routing logic

Routing is intentionally simple — no CMDT lookup, no lifetime-donor check:

| Condition | Route |
|---|---|
| `Contact.HasOptedOutOfEmail = FALSE` AND `Contact.Email IS NOT NULL` | Email |
| Otherwise | Task |

The Task path handles: opted-out donors, donors with no email address on file, and any gift where the flow can't resolve the donor Contact.

---

## Full vs partial deduction

Two templates ship because tax deduction rules differ by gift shape:

| Condition | Template |
|---|---|
| `TaxDeductionAmount IS NULL` OR `TaxDeductionAmount = CurrentAmount` | FQS Gift Acknowledgement (full deduction) |
| `TaxDeductionAmount < CurrentAmount` | FQS Gift Acknowledgement (Partial Deduction) |

The partial-deduction variant covers in-kind gifts, event tickets, and any contribution where the donor received something of value in return. The flow only handles the routing — marketing owns the actual body copy in both templates.

---

## Overriding the automation

If your org uses an external tool (Marketing Cloud, HubSpot, a payment processor's built-in receipt engine, etc.) to send acknowledgements, see `docs/external-tool-integration.md` for the contract. The short version: write back `GiftTransaction.AcknowledgementStatus = 'Sent'` from your external system, and FQS's ack flow will naturally skip those gifts.

To turn the automation off entirely: **Setup → Flows → FQS Gift Acknowledgement → Deactivate**. Stewardship is a separate flow (`FQS_Stewardship_Response`) and remains active independently.

---

## Email templates

Files:
- `force-app/main/default/email/unfiled$public/FQS_Gift_Acknowledgement.email` (full deduction)
- `force-app/main/default/email/unfiled$public/FQS_Gift_Acknowledgement_Partial.email` (partial deduction)

Both shipped templates contain placeholder copy (clearly marked). Before go-live, replace the `.email` body files with final marketing copy. Merge fields available in the body:

- `{!Contact.Salutation}` / `{!Contact.FirstName}` — donor greeting
- `{!GiftTransaction.CurrentAmount}` / `{!GiftTransaction.TransactionDate}` — gift details
- `{!GiftTransaction.TaxDeductionAmount}` — tax-deduction line (populate only on the partial template — the full template implies deduction = gift amount)
- `{!Organization.Name}` — your org's name

After editing the files, redeploy with `sf project deploy start`.

---

## FQS Gift Acknowledgements queue

The queue is shipped without members. After deployment, add staff:

1. **Setup → Queues → FQS Gift Acknowledgements → Edit**.
2. Add users or public groups under **Queue Members**.
3. Save.

Queue members receive an email notification when a new Task is assigned (configured via `doesSendEmailToMembers = true` on the queue).

The queue's routing email address in the metadata (`fqs-gift-acknowledgements@placeholder.example.com`) is a placeholder. Update it post-deployment to a real monitored address if needed.

---

## Task fields

| Field | Value |
|---|---|
| Owner | FQS Gift Acknowledgements queue |
| Who (WhoId) | Donor's PersonContactId |
| What (WhatId) | Soonest open Opportunity on the donor Account; falls back to the donor Account if none exists |
| Subject | `Acknowledge gift: <Donor Name> — $<Amount>` |
| Priority | Normal (all gifts — tier-based priority now lives on stewardship tasks) |
| Activity Date | Today + 7 days |
| Description | Email-on-file flag, opt-out flag, related opportunity name |

---

## Manual re-acknowledgement

To re-process a gift that was already acknowledged (e.g., the original email bounced or needs to be resent):

1. Open the GiftTransaction record.
2. Clear **Acknowledgement Status** (set it back to blank or `To Be Sent`).
3. The flow will pick it up on its next daily run — no further action needed. If you need it processed sooner, go to **Setup → Flows → FQS Gift Acknowledgement** and click **Run** to trigger an immediate execution.

Note: re-clearing `AcknowledgementStatus` does NOT reset `FQS_Stewardship_Status__c`. If you want stewardship to re-fire, clear that field too — but read `docs/gift-stewardship-flow.md` first to understand the sequencing.

---

## Fault handling

If any critical step fails (record lookups, email send, task creation), the flow sends an error email to the running user with the `$Flow.FaultMessage`. Check **Setup → Apex Jobs** and **Setup → Email Log Files** to investigate failures.

---

## Related documentation

- `docs/gift-stewardship-flow.md` — the tier-differentiated follow-up that fires after acknowledgement
- `docs/external-tool-integration.md` — contract for suppressing FQS automation when a third-party tool owns acknowledgement or stewardship
