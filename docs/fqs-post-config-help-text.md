# FQS post-install help text for standard fields

**Audience:** Admins configuring an org after installing the FQS unmanaged package.

**Purpose.** FQS ships FLS grants and layout placements for a set of standard Salesforce / Nonprofit Cloud fields, but does not overwrite the platform-owned `<description>` and `<inlineHelpText>` on those fields. If you want admins in your org to see the FQS-authored guidance surfaced by the accelerator, copy the text below into Setup manually.

**How to apply each entry.**

1. Setup → Object Manager → *[object]* → Fields & Relationships → *[field]*.
2. Edit.
3. Paste the "Description" text into the field's Description.
4. Paste the "Help Text" into the field's Help Text.
5. Save.

Entries are grouped by object. The tables below are seeded by `.planning/fqs-v10-purge-plan.md` §2.2; the extraction pass fills them in.

---

## Account

_(To be extracted from the standard-field overlays being removed from `force-app/`.)_

## Campaign

_(To be extracted.)_

## GiftTransaction

_(To be extracted.)_

## GiftCommitment

_(To be extracted.)_

## Opportunity

_(To be extracted.)_

## Other standard objects

_(To be extracted.)_
