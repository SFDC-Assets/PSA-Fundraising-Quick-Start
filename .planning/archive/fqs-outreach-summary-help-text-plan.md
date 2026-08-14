# FQS — OutreachSummary DPE Field Help Text Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Goal:** Add `inlineHelpText` to each field on the standard `OutreachSummary` object that is written by the `OutreachSummary` DPE, so users understand what each field means, where the data comes from, and how it behaves.

---

## Context

The `OutreachSummary` DPE runs nightly in CRMA batch mode and upserts 9 calculated values onto every `OutreachSummary` record (one per Campaign, one per OutreachSourceCode). None of these fields currently carry help text. The same pattern was used for `DonorGiftSummary` custom fields in the FQS package.

**Caveat:** These are standard Salesforce Fundraising Cloud fields (no `__c` suffix). Salesforce generally permits `inlineHelpText` overrides on standard object fields via metadata, but if the managed package locks field customization on any specific field the deploy will fail gracefully with an error for that field only — no data risk. Recommend validating against the FundFirst scratch/sandbox org before merging.

---

## Files to create

All files go under: `force-app/main/default/objects/OutreachSummary/fields/`

The `fields/` directory does not currently exist for OutreachSummary and will need to be created.

---

## Field-by-field plan

### 1. `DonorCount.field-meta.xml`

**Help text:**
> Number of unique donors who made a paid gift attributed to this campaign or outreach source code. A donor who gave multiple times is counted once.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>DonorCount</fullName>
    <inlineHelpText>Number of unique donors who made a paid gift attributed to this campaign or outreach source code. A donor who gave multiple times is counted once.</inlineHelpText>
</CustomField>
```

---

### 2. `OnetimeDonorCount.field-meta.xml`

**Help text:**
> Number of unique donors whose paid gifts were one-time (not connected to a recurring gift commitment).

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>OnetimeDonorCount</fullName>
    <inlineHelpText>Number of unique donors whose paid gifts were one-time (not connected to a recurring gift commitment).</inlineHelpText>
</CustomField>
```

---

### 3. `RecurringDonorCount.field-meta.xml`

**Help text:**
> Number of unique donors who made at least one paid recurring installment attributed to this campaign or outreach source code.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>RecurringDonorCount</fullName>
    <inlineHelpText>Number of unique donors who made at least one paid recurring installment attributed to this campaign or outreach source code.</inlineHelpText>
</CustomField>
```

---

### 4. `GiftCount.field-meta.xml`

**Help text:**
> Total number of paid gift transactions attributed to this campaign or outreach source code. One donor may contribute multiple gifts, each counted separately.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>GiftCount</fullName>
    <inlineHelpText>Total number of paid gift transactions attributed to this campaign or outreach source code. One donor may contribute multiple gifts, each counted separately.</inlineHelpText>
</CustomField>
```

---

### 5. `TotalGiftTransactionAmount.field-meta.xml`

**Help text:**
> Sum of all paid gift transaction amounts attributed to this campaign or outreach source code, across one-time and recurring gift types.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>TotalGiftTransactionAmount</fullName>
    <inlineHelpText>Sum of all paid gift transaction amounts attributed to this campaign or outreach source code, across one-time and recurring gift types.</inlineHelpText>
</CustomField>
```

---

### 6. `TotalOnetimeGiftAmount.field-meta.xml`

**Help text:**
> Sum of paid one-time gift amounts (not connected to a recurring commitment) attributed to this campaign or outreach source code.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>TotalOnetimeGiftAmount</fullName>
    <inlineHelpText>Sum of paid one-time gift amounts (not connected to a recurring commitment) attributed to this campaign or outreach source code.</inlineHelpText>
</CustomField>
```

---

### 7. `TotalRecurringGiftAmount.field-meta.xml`

**Help text:**
> Sum of paid recurring installment amounts attributed to this campaign or outreach source code.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>TotalRecurringGiftAmount</fullName>
    <inlineHelpText>Sum of paid recurring installment amounts attributed to this campaign or outreach source code.</inlineHelpText>
</CustomField>
```

---

### 8. `ResponseRate.field-meta.xml`

**Help text:**
> Percentage of the outreach audience who made at least one paid gift. Calculated as CEIL(DonorCount / AudienceCount × 100). Only populated if your org uses Outreach Source Codes and Audience Count is populated on them. For campaign-level records, audience size is the sum across all related outreach source codes. Null otherwise.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>ResponseRate</fullName>
    <inlineHelpText>Percentage of the outreach audience who made at least one paid gift. Calculated as CEIL(DonorCount / AudienceCount × 100). Only populated if your org uses Outreach Source Codes and Audience Count is populated on them. For campaign-level records, audience size is the sum across all related outreach source codes. Null otherwise.</inlineHelpText>
</CustomField>
```

---

### 9. `AttributedAmount.field-meta.xml`

**Help text:**
> Total revenue credited to this campaign or outreach source code. Combines one-time cash gifts with the earned-to-date value of recurring pledges originated by this outreach (daily rate × days active). Increases over time while recurring pledges remain active — it represents cumulative revenue earned, not just what was raised during the campaign window.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>AttributedAmount</fullName>
    <inlineHelpText>Total revenue credited to this campaign or outreach source code. Combines one-time cash gifts with the earned-to-date value of recurring pledges originated by this outreach (daily rate × days active). Increases over time while recurring pledges remain active — it represents cumulative revenue earned, not just what was raised during the campaign window.</inlineHelpText>
</CustomField>
```

---

## Execution steps (for approval)

1. Create `force-app/main/default/objects/OutreachSummary/fields/` directory.
2. Write all 9 `.field-meta.xml` files above.
3. Validate deploy against FundFirst org: `sf project deploy start --dry-run --source-dir force-app/main/default/objects/OutreachSummary/fields`
4. If any field returns a "cannot set help text on this field" error (managed lock), note it here and skip that field.
5. Full deploy on confirmation.

---

## Open questions for approval

- **Help text length:** The `AttributedAmount` help text is the longest (~220 chars). Salesforce truncates help text over 255 chars in some UI contexts. Current drafts are all under 255 — confirm this is acceptable or if you'd like shorter versions.
- **Tone:** Drafts use a technical but readable tone consistent with the DonorGiftSummary FQS fields. OK, or do you prefer more plain-language phrasing?
- **ResponseRate note:** The text says "Null when no audience size is recorded" — this is what the DPE does. OK to leave as-is or would you like to suggest how admins should populate audience size?
