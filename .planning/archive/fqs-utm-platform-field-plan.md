# FQS — UTM Platform Field & Help Text Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Goal:** Add `FQS_Platform__c` picklist to `OutreachSourceCode` (covering `utm_source`), and update help text on `MessageChannel`, `SourceCode`, and `Campaign.FQS_Short_Name__c` to explicitly name their UTM equivalents so users understand how these fields map to standard campaign tracking.

---

## UTM mapping context

| UTM parameter | What it captures | Our field |
|---|---|---|
| `utm_campaign` | The initiative | `Campaign.FQS_Short_Name__c` |
| `utm_medium` | Channel type (how delivered) | `OutreachSourceCode.MessageChannel` |
| `utm_source` | Specific platform/sender | `OutreachSourceCode.FQS_Platform__c` ← **new** |

---

## Part 1 — New field: `FQS_Platform__c` on OutreachSourceCode

**File:** `force-app/main/default/objects/OutreachSourceCode/fields/FQS_Platform__c.field-meta.xml`

Picklist values are grouped by `MessageChannel` so users can see which platform values apply to which channel.

| Value | Applies to MessageChannel |
|---|---|
| Facebook | Social Paid, Social Organic |
| Instagram | Social Paid, Social Organic |
| LinkedIn | Social Paid, Social Organic |
| X (Twitter) | Social Paid, Social Organic |
| Google Ads | Digital Paid |
| Microsoft Ads | Digital Paid |
| YouTube | Digital Paid, Social Paid |
| Mailchimp | Email |
| Marketing Cloud | Email |
| Constant Contact | Email |
| Other Email Platform | Email |
| Direct Mail House | Direct Mail |
| SMS Platform | SMS |
| Phone / Call Center | Telemarketing |
| Event / Table | Physical |
| Website | Organic Web |
| Blog | Organic Web |
| Coalition Partner | Share Partner |
| Other | (any) |

**Help text:**
> The specific platform or sender for this source code — equivalent to utm_source in web analytics. Use with Message Channel (utm_medium) to fully describe the tactic: e.g. Message Channel = Social Paid + Platform = Facebook. Drives source-level filtering and reporting alongside Outreach Summary.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>FQS_Platform__c</fullName>
    <description>Fundraising Quick Start: the specific platform or sender for this outreach tactic. Equivalent to utm_source. Used alongside Message Channel (utm_medium) and Campaign Short Name (utm_campaign) to build fully attributed source codes and UTM links.</description>
    <externalId>false</externalId>
    <inlineHelpText>The specific platform or sender for this source code — equivalent to utm_source in web analytics. Use with Message Channel (utm_medium) to fully describe the tactic: e.g. Message Channel = Social Paid + Platform = Facebook.</inlineHelpText>
    <label>Platform</label>
    <required>false</required>
    <trackHistory>false</trackHistory>
    <type>Picklist</type>
    <valueSet>
        <restricted>false</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>Facebook</fullName>
                <default>false</default>
                <label>Facebook</label>
            </value>
            <value>
                <fullName>Instagram</fullName>
                <default>false</default>
                <label>Instagram</label>
            </value>
            <value>
                <fullName>LinkedIn</fullName>
                <default>false</default>
                <label>LinkedIn</label>
            </value>
            <value>
                <fullName>X (Twitter)</fullName>
                <default>false</default>
                <label>X (Twitter)</label>
            </value>
            <value>
                <fullName>YouTube</fullName>
                <default>false</default>
                <label>YouTube</label>
            </value>
            <value>
                <fullName>Google Ads</fullName>
                <default>false</default>
                <label>Google Ads</label>
            </value>
            <value>
                <fullName>Microsoft Ads</fullName>
                <default>false</default>
                <label>Microsoft Ads</label>
            </value>
            <value>
                <fullName>Mailchimp</fullName>
                <default>false</default>
                <label>Mailchimp</label>
            </value>
            <value>
                <fullName>Salesforce Marketing Cloud</fullName>
                <default>false</default>
                <label>Salesforce Marketing Cloud</label>
            </value>
            <value>
                <fullName>Constant Contact</fullName>
                <default>false</default>
                <label>Constant Contact</label>
            </value>
            <value>
                <fullName>Other Email Platform</fullName>
                <default>false</default>
                <label>Other Email Platform</label>
            </value>
            <value>
                <fullName>Direct Mail House</fullName>
                <default>false</default>
                <label>Direct Mail House</label>
            </value>
            <value>
                <fullName>SMS Platform</fullName>
                <default>false</default>
                <label>SMS Platform</label>
            </value>
            <value>
                <fullName>Phone / Call Center</fullName>
                <default>false</default>
                <label>Phone / Call Center</label>
            </value>
            <value>
                <fullName>Event / Table</fullName>
                <default>false</default>
                <label>Event / Table</label>
            </value>
            <value>
                <fullName>Website</fullName>
                <default>false</default>
                <label>Website</label>
            </value>
            <value>
                <fullName>Blog</fullName>
                <default>false</default>
                <label>Blog</label>
            </value>
            <value>
                <fullName>Coalition Partner</fullName>
                <default>false</default>
                <label>Coalition Partner</label>
            </value>
            <value>
                <fullName>Other</fullName>
                <default>false</default>
                <label>Other</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
```

---

## Part 2 — Updated help text: `OutreachSourceCode.MessageChannel`

Add the UTM medium equivalence and remove the source code prefix table (that belongs on SourceCode, not here):

**New `inlineHelpText`:**
> Equivalent to utm_medium in web analytics — the type of channel used to reach donors. Drives the Message Channel Segment grouping (Organic, Paid Digital, or Owned or Acquired Lists) used in list views and reporting. Select the channel first, then choose the specific platform in the Platform field (utm_source).

---

## Part 3 — Updated help text: `OutreachSourceCode.SourceCode`

Add UTM context and reference the new Platform field:

**New `inlineHelpText`:**
> Unique identifier for this outreach tactic. Convention: {CHANNEL-PREFIX}-{CAMPAIGN-SHORT-NAME}-{SEQUENCE} — for example, EM-FY26-YEAREND-01 for the first email tactic of a campaign with Short Name "fy26-yearend". Equivalent to utm_content or a combined utm_medium+utm_source slug in web analytics. Must be unique across all Outreach Source Codes. Stored on Gift Transactions and used by the Outreach Summary rollup to attribute revenue to this source code.

---

## Part 4 — Updated help text: `Campaign.FQS_Short_Name__c`

Add the UTM campaign equivalence explicitly:

**New `inlineHelpText`:**
> Equivalent to utm_campaign in web analytics. Used as the campaign segment when naming Outreach Source Codes (e.g. Short Name "fy26-yearend" → source code "EM-FY26-YEAREND-01"). Also use this value directly as utm_campaign on any URLs promoted by this campaign. Lowercase, alphanumeric and hyphens only — no spaces.

---

## Open questions for approval

1. **Picklist restricted?** The plan sets `<restricted>false</restricted>` so users can type in platform values not on the list. Would you prefer it locked to the list only?
2. **Picklist values:** The list covers the most common nonprofit platforms. Any additions (e.g. TikTok, Snapchat, a specific email provider your orgs commonly use)?
3. **Permission set:** `FQS_Custom_Fields.permissionset-meta.xml` will need `FQS_Platform__c` added so users with that perm set can edit the field. Should be included in execution.

---

## Execution steps (on approval)

1. Create `FQS_Platform__c.field-meta.xml` (new picklist field).
2. Update `inlineHelpText` on `MessageChannel`, `SourceCode`, and `FQS_Short_Name__c`.
3. Add `FQS_Platform__c` to `FQS_Custom_Fields` permission set.
4. Deploy all to FundFirst.
