# FQS Stewardship Response Flow — Admin Guide

## What it does

The **FQS Stewardship Response** flow runs on a daily schedule (07:00 UTC — one hour after the acknowledgement flow). It queries `GiftTransaction` records that have already been acknowledged and are ready for a relationship-building touch.

Filter:

- `Status = Paid`
- `AcknowledgementStatus = 'Sent'` (acknowledgement is a prerequisite)
- `TransactionDate <= today - 14 days` (two-week gap after the gift so the ack has landed and any donor response has had time to arrive)
- `FQS_Stewardship_Status__c IS NULL` OR `FQS_Stewardship_Status__c = 'To Be Sent'`
- `Category != Other` (excludes earned income, event registrations, and service fees — not gifts)

Stewardship is **not** a second thank-you. It is a follow-up mission-oriented touch meant to deepen the donor's connection to the mission — a story, program update, or impact metric that ties the specific gift to real work.

For each qualifying gift, the flow routes to one of two paths based on the donor's tier and lifetime giving:

- **Email path** — sends the FQS Stewardship Response (Standard) email template to the donor's contact.
- **Task path** — creates a Task owned by the **FQS Stewardship Response** queue so a fundraiser can deliver a personal-touch stewardship outreach.

After the email is sent, `FQS_Stewardship_Status__c` is set to `Sent` and `FQS_Stewardship_Date__c` is stamped. After a Task is created, `FQS_Stewardship_Status__c` is set to `To Be Sent`; the queue member flips it to `Sent` and stamps `FQS_Stewardship_Date__c` after the personal outreach is complete.

---

## Routing logic

Routing is controlled by a picklist field — **Auto Stewardship** (`FQS_Auto_Stewardship__c`) — on the **FQS Donor Grouping** Custom Metadata Type. Each tier row (Entry / Mid / Major) carries its own setting.

| Auto Stewardship setting | Donor is lifetime Major? | Route |
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

Rationale: entry-level donors get an automated impact email — the volume is high and personalization is impractical. Major donors always route to a task — every major gift warrants a personal stewardship touch. Mid-tier is a hybrid — most get the automated email, but if the donor is already a lifetime major-level giver, they get escalated to a personal task instead.

---

## Tier resolution

Tier is derived from formula fields on the GiftTransaction, not by rescoring the donor:

- `FQS_Is_Major_Gift__c = TRUE` → Major
- `FQS_Is_Major_Gift__c = FALSE` AND `FQS_Is_Mid_Gift__c = TRUE` → Mid
- Otherwise → Entry (default; includes gifts below the one-time minimum)

These formula fields consume the CMDT thresholds, so retuning tier thresholds via the Setup Flow automatically retunes stewardship routing.

Lifetime-donor escalation uses `DonorGiftSummary.FQS_Is_Major_Lifetime_Donor__c`, which is TRUE when the donor's cumulative giving (hard credits by default, hard + soft when the tier's `Credit_Type__c = Hard + Soft Credits`) has crossed the Major lifetime threshold.

---

## How to tune routing per tier

The easiest way is the **FQS Setup Flow** (admin-friendly, no Setup deep-dive):

1. Open the **Fundraising Quick Start** Lightning app.
2. Click the **Setup** tab (or the **Setup** item in the utility bar) — the FQS Setup Flow launches.
3. Pick the **Configure Donor Groupings** branch.
4. Screen 1 lets you tune the giving thresholds for all three tiers. Screen 2 lets you pick the stewardship routing for each tier, with an "Apply one setting to all three tiers" shortcut if you want a single choice across the board.
5. Finish the flow. Changes are queued as a Custom Metadata deployment and take up to a minute to appear.

**Reminder:** these settings only take effect once the **FQS Stewardship Response** scheduled flow is activated (Setup → Flows → activate). Deactivating the flow stops all automatic stewardship regardless of what's set here.

The classic path also still works — Setup → Custom Metadata Types → FQS Donor Grouping → Manage Records — and is the **only** way to add a *new* tier beyond Entry / Mid / Major.

---

## Email template

File: `force-app/main/default/email/unfiled$public/FQS_Stewardship_Response_Standard.email`

The shipped template contains placeholder copy (clearly marked). Before go-live, update the `.email` body file with final marketing copy — the stewardship touch is where the mission comes alive, and generic filler here damages the donor relationship more than sending nothing.

Merge fields available:

- `{!Contact.Salutation}` / `{!Contact.FirstName}` — donor greeting
- `{!GiftTransaction.CurrentAmount}` / `{!GiftTransaction.TransactionDate}` — gift context
- `{!Organization.Name}` — your org's name

**Per-tier templates:** the flow currently uses one shared template. If your org wants different copy per tier (Entry impact story vs Mid program update vs Major major-gifts-officer intro), the follow-up is to author `FQS_Stewardship_Response_Entry`, `_Mid`, `_Major` templates and wire the flow to a Decision-based template picker. Deferred until marketing has actual per-tier copy — routing three placeholder templates buys nothing.

After editing the file, redeploy with `sf project deploy start`.

---

## FQS Stewardship Response queue

The queue is shipped without members. After deployment, add staff:

1. **Setup → Queues → FQS Stewardship Response → Edit**.
2. Add users or public groups under **Queue Members**.
3. Save.

Queue members receive an email notification when a new Task is assigned.

The queue's routing email address in the metadata is a placeholder. Update it post-deployment to a real monitored address if needed.

---

## Task fields

| Field | Value |
|---|---|
| Owner | FQS Stewardship Response queue |
| Who (WhoId) | Donor's PersonContactId |
| What (WhatId) | Soonest open Opportunity on the donor Account; falls back to the donor Account if none exists |
| Subject | `Steward <Tier> gift: <Donor Name> — $<Amount>` (opt-out prefix prepended if applicable) |
| Priority | High (Major) / Normal (Mid) / Low (Entry) |
| Activity Date | Today + 3 days (Major) / +7 days (Mid) / +14 days (Entry) |
| Description | Lifetime tier, email opt-out flag, related opportunity name |

Tier-scaled SLAs mean major-gift stewardship stays at the top of the queue; entry-level tasks sit further out.

---

## Manual re-stewardship

To re-run stewardship on a gift that has already been stewarded (e.g., the impact email needs to be resent):

1. Open the GiftTransaction record.
2. Clear **Stewardship Status** (set it back to blank or `To Be Sent`).
3. The flow will pick it up on its next daily run — no further action needed.

Note: stewardship requires `AcknowledgementStatus = 'Sent'`, so if you also cleared that field the ack flow will run first and stewardship will follow ~14 days later (subject to the TransactionDate filter).

---

## Fault handling

If any critical step fails (record lookups, email send, task creation), the flow sends an error email to the running user with the `$Flow.FaultMessage`. Check **Setup → Apex Jobs** and **Setup → Email Log Files** to investigate failures.

---

## Related documentation

- `docs/gift-acknowledgement-flow.md` — the universal receipt that fires first
- `docs/external-tool-integration.md` — contract for suppressing FQS automation when a third-party tool owns acknowledgement or stewardship
