# FQS External Tool Integration Contract

Many nonprofits already run donor communications through a third-party tool — Marketing Cloud, HubSpot, Mailchimp, a payment processor's built-in receipt engine, a custom-built receipt service, etc. FQS ships automation for the two most common touches (acknowledgement and stewardship), but expects external tools to be able to take over cleanly when the org prefers.

This document is the contract: what fields FQS reads, what it writes, and how an external system can suppress or coexist with FQS automation without racing it.

## The two flows in scope

FQS runs two scheduled flows against `GiftTransaction`:

| Flow | Schedule | Purpose | Read fields | Write fields |
|---|---|---|---|---|
| `FQS_Gift_Acknowledgement` | Daily 06:00 UTC | Universal receipt confirming gift + deduction info | `Status`, `TransactionDate`, `AcknowledgementStatus`, `Category`, `Contact.HasOptedOutOfEmail`, `Contact.Email`, `TaxDeductionAmount`, `CurrentAmount` | `AcknowledgementStatus`, `AcknowledgementDate` |
| `FQS_Stewardship_Response` | Daily 07:00 UTC | Tier-differentiated relationship-building touch ~14 days after ack | `Status`, `AcknowledgementStatus`, `TransactionDate`, `FQS_Stewardship_Status__c`, `Category`, `FQS_Is_Major_Gift__c`, `FQS_Is_Mid_Gift__c`, `DonorGiftSummary.FQS_Is_Major_Lifetime_Donor__c`, `FQS_Donor_Grouping__mdt.FQS_Auto_Stewardship__c`, `Contact.HasOptedOutOfEmail`, `Contact.Email` | `FQS_Stewardship_Status__c`, `FQS_Stewardship_Date__c` |

Both flows are additive — they *only* act on gifts where their status field is `NULL` or `'To Be Sent'`. Setting the status field to `'Sent'` or `'Don't Send'` from an external tool causes FQS to skip that gift.

---

## Suppression patterns

### Pattern 1: External tool owns acknowledgement, FQS owns stewardship

Most common. Your marketing platform sends the immediate thank-you receipt (often triggered by a payment webhook seconds after the gift lands); FQS handles the 14-day stewardship touch.

**What to write from the external tool, per gift, after your receipt has been sent:**

```
GiftTransaction.AcknowledgementStatus = 'Sent'
GiftTransaction.AcknowledgementDate = <the datetime your platform sent the receipt>
```

FQS's ack flow filter (`AcknowledgementStatus IS NULL OR = 'To Be Sent'`) will now exclude those gifts. Stewardship still fires normally 14 days later because it looks at `AcknowledgementStatus = 'Sent'` as its prerequisite — your writeback satisfies that.

**Timing:** write back within 24 hours of sending the receipt. FQS's ack flow runs daily at 06:00 UTC, so any gift that lands in the org before your writeback lands will get double-acked. If your platform can't guarantee a same-day writeback, set `AcknowledgementStatus = 'Sent'` at gift-insert time (before your platform has actually sent anything) and update `AcknowledgementDate` when the send confirms — race prevention beats accuracy on the date field.

### Pattern 2: External tool owns both

Your platform handles both the immediate receipt and the ongoing mission communications. FQS should stay out of the way entirely.

**Option A — full suppression (recommended for orgs migrating from an existing engagement platform):**

Deactivate both flows. **Setup → Flows → FQS Gift Acknowledgement → Deactivate**, same for FQS Stewardship Response. FQS's custom fields (`FQS_Stewardship_Status__c`, `FQS_Stewardship_Date__c`) remain available for reporting if you want them, and the AcknowledgementStatus / AcknowledgementDate standard fields remain writable from your platform. Nothing else in FQS depends on these flows running.

**Option B — per-gift suppression (recommended for orgs that want FQS as a safety net):**

Leave both flows active. On each gift, write:

```
GiftTransaction.AcknowledgementStatus = 'Sent'
GiftTransaction.FQS_Stewardship_Status__c = 'Don't Send'
```

FQS's ack flow skips because the status is already `Sent`. FQS's stewardship flow skips because `Don't Send` is not in its filter set (`NULL OR 'To Be Sent'`).

The safety net kicks in only if your platform misses a gift — the writeback never happens, so the fields stay `NULL`, so FQS runs on the next scheduled cycle. If you never want FQS to run as a safety net (e.g., your platform is authoritative and any FQS run would be a double-send), use Option A instead.

### Pattern 3: FQS owns acknowledgement, external tool owns stewardship

The reverse of Pattern 1. Your marketing platform runs a mission-oriented drip campaign starting a couple of weeks after the gift. FQS handles the immediate ack.

**What to write from the external tool per gift, before your stewardship campaign fires:**

```
GiftTransaction.FQS_Stewardship_Status__c = 'Don't Send'
```

Or, if your platform can write on send instead of pre-emptively:

```
GiftTransaction.FQS_Stewardship_Status__c = 'Sent'
GiftTransaction.FQS_Stewardship_Date__c = <the datetime your platform sent the stewardship touch>
```

Both values are recognized by FQS's stewardship filter (`NULL OR 'To Be Sent'`) as terminal states and cause FQS to skip.

---

## The contract fields

### `GiftTransaction.AcknowledgementStatus` (standard Fundraising Cloud field)

Picklist. Values FQS respects:

| Value | Meaning to FQS |
|---|---|
| `(blank)` | Not yet acknowledged; eligible for automatic acknowledgement |
| `To Be Sent` | Queued for manual acknowledgement via task; treated same as blank by ack flow |
| `Sent` | Acknowledged; FQS ack flow skips; FQS stewardship flow may now fire ~14 days later |
| `Don't Send` | Explicitly suppressed; both flows skip |

### `GiftTransaction.AcknowledgementDate` (standard Fundraising Cloud field)

Date. Populated by FQS on send. External tools should populate this when they own acknowledgement — the stewardship flow does not consume this date, but reporting and downstream automation may.

### `GiftTransaction.FQS_Stewardship_Status__c` (custom FQS field)

Restricted picklist, mirrors `AcknowledgementStatus`:

| Value | Meaning to FQS |
|---|---|
| `(blank)` | Not yet stewarded; eligible for automatic stewardship |
| `To Be Sent` | Queued for manual stewardship via task; treated same as blank by stewardship flow |
| `Sent` | Stewardship touch delivered; FQS stewardship flow skips |
| `Don't Send` | Explicitly suppressed; FQS stewardship flow skips |

### `GiftTransaction.FQS_Stewardship_Date__c` (custom FQS field)

Date. Populated by FQS on send. External tools should populate this when they own stewardship.

### `GiftTransaction.FQS_Tax_Receipt_Date__c` (custom FQS field)

Date. Manual only — FQS does not automate year-end tax receipting; standard `TaxReceiptStatus` handles receipt state. If your external tool generates year-end tax receipts, write this field on send so FQS reports can find gifts already receipted.

---

## Category exclusion

Both flows skip `GiftTransaction.FQS_Gift_Transaction_Category__c = 'Other'`. The `Other` category covers earned income, event registrations, service fees, and any transaction where the org has already delivered value — sending a "thank you for your generosity" note would be off-brand.

**Restricted picklist note:** `FQS_Gift_Transaction_Category__c` is a restricted picklist. Allowed values are `Outright Gift`, `Pledge Payment`, `Recurring Gift Payment`, `Grant Payment`, `Other`. Sending any other value (including the retired `Fee/Payment` value) will fail with `INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`.

If your external tool wants to acknowledge earned-income or fee-for-service transactions on its own schedule, do so. FQS will not compete.

---

## Testing an integration

Before enabling an external tool's writeback in production:

1. Load a handful of test `GiftTransaction` records in a sandbox with the field values your integration will write.
2. Manually run the FQS ack flow (`Setup → Flows → FQS Gift Acknowledgement → Run`) and confirm your test gifts are skipped.
3. Manually run the FQS stewardship flow (`Setup → Flows → FQS Stewardship Response → Run`) and confirm your test gifts are skipped (or fire, per your pattern).
4. Check `Setup → Email Log Files` for any FQS-sent emails against the test gifts — none should appear if suppression worked.
5. Check the test gifts' Activities related list — no FQS-created tasks should appear if suppression worked.

If FQS still fires against a suppressed gift, the writeback timing lost the race. Fix by writing the status field earlier (see Pattern 1 timing note).

---

## What FQS never depends on

The following are out of scope for the FQS ack + stewardship flows — external tools do NOT need to sync them:

- Chatter feed items on `GiftTransaction`
- `Task.Description` free-text content
- Email attachments on sent messages
- `EmailMessage` records related to gifts (FQS's `logEmailOnSend = TRUE` creates these but does not consume them)
- Any Fundraising Cloud rollup fields on `Account` or `DonorGiftSummary`

External tools that mirror email activity into Salesforce via `EmailMessage` records are welcome to do so — FQS treats them as read-only reporting data.

---

## Contract version

This contract is stable as of 2026-07-26. If FQS adds new fields to either flow's filter set, this document is updated in the same commit and the release readiness tracker calls it out under **Findings**.
