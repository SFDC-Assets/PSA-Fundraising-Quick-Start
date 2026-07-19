# FQS Gift Acknowledgement Flow — Admin Guide

## What it does

The **FQS Gift Acknowledgement** flow runs on a daily schedule. It queries all `GiftTransaction` records where `Status = Paid`, `TransactionDate` is at least 3 days in the past, and `AcknowledgementStatus` is blank or `To Be Sent`. The 3-day window lets digital-platform ingest and any refunds or reversals settle before an acknowledgement fires.

For each qualifying gift it routes to one of two acknowledgement paths:

- **Email path** — sends the FQS Gift Acknowledgement email template to the donor's contact.
- **Task path** — creates a Task owned by the **FQS Gift Acknowledgements** queue so a team member can send a personal acknowledgement (physical letter, phone call, etc.).

After the email is sent, `AcknowledgementStatus` is set to `Sent` and `AcknowledgementDate` is stamped. After a Task is created, `AcknowledgementStatus` is set to `To Be Sent`; the queue member flips it to `Sent` and sets `AcknowledgementDate` after the personal outreach is complete.

---

## Routing logic

Routing is controlled by a picklist field — **Auto Acknowledgement** (`FQS_Auto_Acknowledgement__c`) — on the **FQS Donor Grouping** Custom Metadata Type. Each tier row (Entry / Mid / Major) carries its own setting.

| Auto Acknowledgement setting | Donor is lifetime Major? | Route |
|---|---|---|
| Include All | — | Email |
| Exclude Lifetime | No | Email |
| Exclude Lifetime | Yes | Task |
| Exclude All | — | Task |

**Additional override:** if `Contact.HasOptedOutOfEmail = TRUE`, the flow always takes the Task path regardless of the CMDT setting. The Task subject is prefixed `[OPT-OUT — send by mail]` so the queue member knows to use a non-email channel.

**Default seeded values:**

| Tier | Setting |
|---|---|
| Entry (Friend) | Include All |
| Mid (Partner) | Exclude Lifetime |
| Major (Champion) | Exclude All |

---

## How to tune routing per tier

The easiest way is the **FQS Setup Flow** (admin-friendly, no Setup deep-dive):

1. Open the **Fundraising Quick Start** Lightning app.
2. Click the **Setup** tab (or the **Setup** item in the utility bar) — the FQS Setup Flow launches.
3. Screen 1 lets you tune the giving thresholds for all three tiers. Screen 2 lets you pick the acknowledgement routing for each tier, with a "Apply one setting to all three tiers" shortcut if you want a single choice across the board.
4. Finish the flow. Changes are queued as a Custom Metadata deployment and take up to a minute to appear.

**Reminder:** these settings only take effect once the **FQS Gift Acknowledgement** scheduled flow is activated (Setup → Flows → activate). Deactivating the flow stops all automatic acknowledgements regardless of what's set here.

The classic path also still works — Setup → Custom Metadata Types → FQS Donor Grouping → Manage Records — and is the **only** way to add a *new* tier beyond Entry / Mid / Major.

---

## Email template

File: `force-app/main/default/email/unfiled$public/FQS_Gift_Acknowledgement.email`

The shipped template contains placeholder copy (clearly marked). Before go-live, update the `.email` body file with final marketing copy. Merge fields available in the body:

- `{!Contact.Salutation}` / `{!Contact.FirstName}` — donor greeting
- `{!GiftTransaction.CurrentAmount}` / `{!GiftTransaction.TransactionDate}` — gift details
- `{!GiftTransaction.TaxDeductionAmount}` — for the tax acknowledgement line
- `{!Organization.Name}` — your org's name

After editing the file, redeploy with `sf project deploy start`.

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
| Subject | `Acknowledge <Tier> gift: <Donor Name> — $<Amount>` (opt-out prefix prepended if applicable) |
| Priority | High (Major gifts) / Normal (all others) |
| Activity Date | Today + 3 days (Major) / +7 days (Mid) / +14 days (Entry) |
| Description | Lifetime tier, email opt-out flag, related opportunity name |

---

## Manual re-acknowledgement

To re-process a gift that was already acknowledged (e.g., the original email bounced or needs to be resent):

1. Open the GiftTransaction record.
2. Clear **Acknowledgement Status** (set it back to blank or `To Be Sent`).
3. The flow will pick it up on its next daily run — no further action needed. If you need it processed sooner, go to **Setup → Flows → FQS Gift Acknowledgement** and click **Run** to trigger an immediate execution.

---

## Fault handling

If any critical step fails (record lookups, email send, task creation), the flow sends an error email to the running user with the `$Flow.FaultMessage`. Check **Setup → Apex Jobs** and **Setup → Email Log Files** to investigate failures.
