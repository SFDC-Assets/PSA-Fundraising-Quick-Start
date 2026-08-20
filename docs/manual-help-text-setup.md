# Manual Help Text and Description Setup

Fundraising Quick Start ships help text and field descriptions for every FQS-authored custom field via the unmanaged package. **A handful of standard Salesforce-owned fields need those same edits applied by hand.** This is a Salesforce packaging limitation: unmanaged packages carry `<inlineHelpText>` and `<description>` only on custom (`__c`) fields and on standard fields the package already customizes for another reason. On a stock standard field, the platform ignores the packaged edit at install time.

The steps below walk you through applying the FQS-recommended Help Text and Description to each of those standard fields. Do this once, in every org where you install FQS.

**Scope:** ~40 standard fields across 10 objects, organized in three tiers:

* **Tier 1 (✔ already in README):** 15 automation-critical fields — walked through step-by-step in the README's per-object post-install sections (`Post-Install Setup and Configuration → Section IV` for Gift Transaction / Gift Commitment / Opportunity, `→ Section V` for Gift Designation). Listed here in a callout at the top of this doc for reference; skip the callout if you followed the README.
* **Tier 2 (critical, non-key objects):** 12 fields where help text protects FQS or platform automation — Gift Commitment Schedule mechanics and Outreach Source Code UTM mapping. Apply these next. Estimated time: 10–15 minutes.
* **Tier 3 (additional recommendations):** the remainder — parity, convention, and clarity edits that aren't automation-critical. Apply at your leisure. Estimated time: 30–40 minutes.

The Help Text is what end users see when they hover the "?" icon on the record page. The Description is what admins see in Object Manager. Both are optional — you can apply Help Text only if you don't want to expose the Description in Object Manager, but the Description is where the semantic guidance and cross-field warnings live, so authoring both is recommended.

**Prerequisites:** Nonprofit Cloud Fundraising (FundFirst) installed. FQS deployed. **System Administrator** or **Customize Application** permission.

**Estimated time:** 40–55 minutes for Tier 2 + Tier 3. Each field is 30 seconds if you paste from this document.

---

## How to apply help text to a standard field

The steps are the same for every field. Do them once so you can move quickly through the list.

1. From **Setup**, click the **Object Manager** tab.
2. Search for and click the target object (e.g., **Gift Commitment Schedule**).
3. Click **Fields & Relationships**.
4. Click the field label (e.g., **Start Date**).
5. Click **Edit**.
6. In the **Help Text** field, paste the **Help** value below for that field. Leave blank if the entry lists only a Description.
7. In the **Description** field, paste the **Description** value below. Leave blank if the entry lists only a Help.
8. Click **Save**.

Salesforce enforces a **510-character maximum on Help Text**. Descriptions are longer-form (1,000-character limit) and used only by admins in Object Manager.

---

## Tier 1 — ✔ already in README (skip if you followed the README)

These 15 automation-critical fields are walked through step-by-step in the README post-install sections. If you completed those sections start-to-finish, skip this callout and jump to Tier 2. The list below is a reference for what was applied.

| Object | Field | README location |
| --- | --- | --- |
| Gift Transaction | Current Amount | §IV.2 step 4 |
| Gift Transaction | Transaction Date | §IV.2 step 5 |
| Gift Transaction | Transaction Due Date | §IV.2 step 6 |
| Gift Transaction | Non-Tax Deductible Amount | §IV.2 step 7 |
| Gift Commitment | Campaign | §IV.3 step 4 |
| Gift Commitment | Formal Commitment Type | §IV.3 step 5 |
| Gift Commitment | Fulfillment Type | §IV.3 step 6 |
| Gift Commitment | Recurrence Type | §IV.3 step 7 |
| Gift Commitment | Schedule Type | §IV.3 step 8 |
| Gift Commitment | Effective Start Date | §IV.3 step 9 |
| Opportunity | Amount | §IV.5 step 2 |
| Opportunity | Close Date | §IV.5 step 3 |
| Opportunity | Probability (%) | §IV.5 step 4 |
| Gift Designation | Is Default | §V.2 step 1 |
| Gift Designation | Active | §V.2 step 2 |

---

## Tier 2 — Critical standard fields on non-key objects

Apply these before moving to Tier 3. Every field below either protects FQS automation, protects platform automation, or is required for an FQS auto-generation formula (Outreach Source Code UTM string).

### Object: Gift Commitment Schedule

Gift Commitment Schedule mechanics drive `processGiftCommitment` fanout, commitment status transitions, and Current Gift Commitment Schedule activation. Every editable standard field on this object feeds one of those.

#### Gift Commitment Schedule: Start Date

- **Help:** The date the first scheduled payment is expected. This can be later than the signing date on the parent commitment. The schedule stays inactive until this date is on or before today.
- **Description:** Required. Also drives Gift Commitment: Current Gift Commitment Schedule activation — the parent commitment's active-schedule lookup populates when Start Date is on or before today.

#### Gift Commitment Schedule: Commitment Update Reason

- **Help:** Set when replacing an active schedule (donor changed amount, cadence, or payment method). Choose the reason that best matches — used by stewardship reporting to distinguish upgrades, downgrades, and renewals from data corrections.
- **Description:** Restricted picklist. Not required by the platform, but populating it powers change-analytics on recurring gifts and pledges.

#### Gift Commitment Schedule: Gift Commitment Status

- **Help:** The state of this schedule (Active, Paused, Cancelled, Completed). Only one Active schedule per commitment; the platform enforces this on save.
- **Description:** The platform derives Current Gift Commitment Schedule on the parent Gift Commitment from the single Active schedule with Start Date on or before today.

#### Gift Commitment Schedule: Payment Method

- **Help:** How this donor intends to pay each installment (Credit Card, ACH, Check). Copies onto every Expected Gift Transaction fanned out from the schedule.
- **Description:** Restricted picklist. Fanned out to each Gift Transaction at create time; changing on the schedule does not backfill previously-created Gift Transaction rows.

#### Gift Commitment Schedule: Transaction Amount

- **Help:** The dollar amount of each installment. For recurring gifts and pledges with equal installments, this is the amount per period; for Custom schedules, this is the amount of the specific installment row.
- **Description:** For Fixed Length and Open Ended schedules, this × installment count feeds Total Schedule Amount. Custom schedules can vary Transaction Amount per row.

#### Gift Commitment Schedule: Transaction Day

- **Help:** The day of the month payments should post — for example, 1 for the 1st of each month, 15 for the 15th. For payments due on the last day of the month, enter `LastDay`.
- **Description:** Values 29–31 are converted to `LastDay` on save to avoid month-boundary drift. Ignored on Weekly schedules.

#### Gift Commitment Schedule: Transaction Period

- **Help:** How often payments recur (Weekly, Monthly, Quarterly, Yearly). Combined with Transaction Interval to describe cadence — for example, Period=Monthly + Interval=1 is "monthly."
- **Description:** Restricted picklist. Required for Recurring schedules. Ignored on Custom schedules where each row carries its own date.

#### Gift Commitment Schedule: Type

- **Help:** The category of this schedule (Recurring, Pledge, Grant, Custom). The platform uses this to decide how to fan out Expected Gift Transactions and how to handle rescheduling.
- **Description:** Restricted picklist. Custom is the escape hatch for irregular installments (variable amounts or non-uniform spacing) — Custom rows must be created via Apex; Flow cannot build them.

### Object: Outreach Source Code

Outreach Source Code auto-generates a UTM-compatible `SourceCode` string from the four channel/platform fields below. If any of them is left blank or filled in incorrectly, the auto-generated code will be malformed and inbound gift attribution will break.

#### Outreach Source Code: Message Channel

- **Help:** The channel used to reach the donor — Email, Direct Mail, Social, Paid Search, Event, Phone. Feeds the Source Code auto-generation formula.
- **Description:** First segment of the auto-generated SourceCode UTM string (`MessageChannel_MessageChannelPlatform_MessageChannelPlatformAccount_...`). Legal values are configured at the org level via Setup → Message Channel.

#### Outreach Source Code: Message Channel Platform

- **Help:** The platform inside the channel (e.g., Facebook for Social, Mailchimp for Email, Google Ads for Paid Search). Second segment of the auto-generated Source Code.
- **Description:** Legal values depend on the parent Message Channel. Feeds the second segment of the auto-generated SourceCode formula.

#### Outreach Source Code: Message Channel Platform Account

- **Help:** The specific account/property on the platform — for example, the ad account name for Google Ads, the newsletter list ID for Mailchimp, the page for Facebook. Third segment of the auto-generated Source Code.
- **Description:** Free-form. Feeds the third segment of the SourceCode UTM string. Avoid spaces and reserved URL characters; the auto-gen formula does not URL-encode.

#### Outreach Source Code: Usage Type

- **Help:** What this source code is used for (Acquisition, Retention, Renewal, Stewardship). Used for cohort analysis in Attribution Report Series.
- **Description:** Restricted picklist. Not part of the auto-generated SourceCode UTM string but consumed by FQS reporting to segment inbound gifts by outreach intent.

---

## Tier 3 — Additional recommendations

The remainder of FQS's standard-field help text and description edits. These are not automation-critical — apply them for parity, admin clarity, and end-user guidance.

### Object: Campaign

#### Campaign: Type

- **Help:** The mechanism used to reach donors — e.g., Email for an email appeal, Seminar / Conference for an event campaign. For fundraising-native categorization, use FQS Campaign Category instead.
- **Description:** Unrestricted stock Salesforce picklist. Stock values skew marketing rather than fundraising.

#### Campaign: Expected Revenue

- **Help:** The revenue you expect this campaign to raise across its full lifecycle — set at campaign kickoff based on prior-year performance and campaign goals.
- **Description:** User-set target field; not a rollup and not derived from child gifts. For actuals, join to Gift Transaction via CampaignId in reports.

#### Campaign: Budgeted Cost

- **Help:** The amount you've budgeted to spend running this campaign — event venue, direct-mail printing, ad spend, staff time.
- **Description:** User-set. Combined with Actual Cost and the Hierarchy* variants for campaign-cost reporting.

#### Campaign: Actual Cost

- **Help:** The amount actually spent running this campaign. Update as invoices post; compare against Budgeted Cost and against gift totals for cost-per-dollar-raised reporting.
- **Description:** User-set. Not derived from any related object — FQS does not track campaign expenses at the transaction level.

#### Campaign: Campaign Member Record Type

- **Description:** Only used when Campaign Member has record types enabled. The Campaign Member record type used by default when adding new members to this campaign. Leave blank if your org uses a single member record type.

### Object: Gift Commitment

#### Gift Commitment: Expected End Date

- **Help:** The date this commitment is expected to be fully paid. For open-ended recurring gifts, leave blank. For fixed-length pledges and grants, set to the date of the final installment.
- **Description:** Fixed-length commitments should have this populated to drive lapse reporting; open-ended recurring gifts leave it blank. Not enforced by the platform — a fixed-length schedule with a null Expected End Date won't error, just under-report.

#### Gift Commitment: Total Current Month

- **Help:** Set automatically. Total dollars paid against this commitment in the current calendar month.
- **Description:** System-maintained. Based on calendar year unless changed through customization.

#### Gift Commitment: Total Current Quarter

- **Help:** Set automatically. Total dollars paid against this commitment in the current calendar quarter.
- **Description:** System-maintained. Based on calendar year unless changed through customization.

#### Gift Commitment: Total Current Year

- **Help:** Set automatically. Total dollars paid against this commitment in the current calendar year.
- **Description:** System-maintained. Based on calendar year unless changed through customization.

#### Gift Commitment: Total Next Year

- **Help:** Set automatically. Total dollars paid against this commitment in the next calendar year (projection).
- **Description:** System-maintained. Based on calendar year unless changed through customization.

#### Gift Commitment: Gift Commitment Name

- **Help:** Set automatically by the FQS naming flow. Format: donor + gift type + primary campaign. To keep a specific Name from being overwritten — e.g., a name imported from another system — check Skip Naming.
- **Description:** Written by the FQS Auto Name Gift Commitment flow on insert and on relevant updates. Skipped when FQS Skip Naming = TRUE. Not enforced as unique.

### Object: Gift Commitment Schedule

#### Gift Commitment Schedule: End Date

- **Help:** The date this schedule stops generating payments. For open-ended recurring schedules, leave blank. For fixed-length schedules, set to the final installment date.
- **Description:** Combined with Start Date, Transaction Period, and Transaction Interval to fan out Expected Gift Transaction rows.

#### Gift Commitment Schedule: Total Schedule Amount

- **Description:** For fixed-length schedules, equal to Transaction Amount × installment count. For open-ended recurring gifts, blank or projected.

#### Gift Commitment Schedule: Transaction Interval

- **Help:** How many periods between payments. Combined with Transaction Period — for example, Period=Monthly + Interval=2 means every 2 months; Period=Weekly + Interval=1 means every week.
- **Description:** Required for Recurring schedules. Ignored on Custom schedules.

### Object: Gift Transaction

Gift Transaction Tier 1 fields (Current Amount, Transaction Date, Transaction Due Date, Non-Tax Deductible Amount) are covered in README §IV.2. The following additional Gift Transaction standard fields ship with FQS-authored guidance.

#### Gift Transaction: Acknowledgement Date

- **Help:** When this donor was thanked for the gift. Usually set automatically by the FQS Gift Acknowledgement flow when the thank-you goes out. Not the tax receipt date and not the donor tax date.
- **Description:** Written by the FQS Gift Acknowledgement flow when the acknowledgement is dispatched. Manual override permitted but rare — end users normally do not set it by hand.

#### Gift Transaction: Payment Identifier

- **Help:** Check Number or Bank Account Name — the reference that ties this gift to the bank record. Populated conditionally on the Gift Entry Gift Details screen when Payment Method is Check or ACH.
- **Description:** Free-form. Surfaces conditionally on the FQS Gift Entry flow when Payment Method requires a bank reference.

### Object: Gift Transaction Designation

#### Gift Transaction Designation: Amount

- **Description:** Populate for absolute-dollar splits (e.g., "$500 of a $2,000 gift to Scholarship, $1,500 to General"). Mutually exclusive with Percent at the row level. Sum of Amount across all sibling Gift Transaction Designations must equal the parent transaction's Original Amount — the platform does NOT enforce this.

#### Gift Transaction Designation: Percent

- **Description:** Percentage-based split — the platform derives an equivalent Amount from Gift Transaction: Original Amount × Percent / 100. Sum-to-100 across siblings is a reporting convention; the platform does NOT enforce it. Gift Default Designation routing produces Percent-based Gift Transaction Designations by default.

### Object: Gift Default Designation

#### Gift Default Designation: Allocated Percentage

- **Description:** Consumed by the managed processGiftCommitment platform flow. Sum-to-100 across sibling Gift Default Designations is a reporting convention; the platform does NOT enforce it — a set summing to 90 will silently under-allocate 10% of every gift on that parent to the org-wide default Gift Designation.

### Object: Gift Soft Credit

#### Gift Soft Credit: Soft Credit Amount

- **Help:** Set automatically. The dollar amount credited to the recipient — computed from Partial Amount if you entered a dollar figure, or from Partial Percent applied to the parent Gift Transaction's Current Amount. Leave both Partial fields blank to soft-credit the full gift.
- **Description:** Platform-computed. Reads Partial Amount first, falls back to Partial Percent × Gift Transaction: Current Amount, and defaults to Gift Transaction: Current Amount when both are null. Reporting rolls this into donor recognition totals.

#### Gift Soft Credit: Partial Amount

- **Help:** Optional. Enter a specific dollar amount to credit — use when the soft credit is only for part of the gift. Leave blank and set Partial Percent instead if the split is percentage-based.
- **Description:** Sibling to Partial Percent. Entering both is rejected by the platform. Blank on both fields = credit the full parent Gift Transaction: Current Amount.

#### Gift Soft Credit: Partial Percent

- **Help:** Optional. Enter a percentage (0–100) of the parent gift to credit — use when household members or joint solicitors split recognition. Mutually exclusive with Partial Amount.
- **Description:** Sibling to Partial Amount. Applied against Gift Transaction: Current Amount, not Original Amount — refunds and adjustments shrink the soft-credited amount along with the underlying gift.

#### Gift Soft Credit: Role

- **Help:** The relationship this recipient has to the parent gift (e.g., Household Member, Joint Solicitor, Matching-Gift Employer). Consumed by donor-recognition rollups on Account.
- **Description:** Shares its picklist value set with Gift Default Soft Credit: Role and with Opportunity Contact Role via role-mapping metadata.

### Object: Gift Default Soft Credit

#### Gift Default Soft Credit: Role

- **Help:** The relationship this recipient has to the parent commitment or opportunity — copies onto every soft credit fanned out from this default.
- **Description:** Shares the value set with Gift Soft Credit: Role. Copies onto every child Gift Soft Credit at fan-out; editing on the default does not backfill previously-created Gift Soft Credits.

#### Gift Default Soft Credit: Partial Amount

- **Help:** Optional. Enter a fixed dollar amount to soft-credit on every transaction fanned out from the parent. Mutually exclusive with Partial Percent.
- **Description:** Sibling to Partial Percent. On a recurring commitment, a fixed Partial Amount produces the same soft-credit dollar figure on every installment even if installment amounts differ — usually Partial Percent is the intended choice.

#### Gift Default Soft Credit: Partial Percent

- **Help:** Optional. Enter a percentage (0–100) of each transaction to soft-credit — the typical choice for household splits, joint-solicitor recognition, and matching-gift routing.
- **Description:** Sibling to Partial Amount. Applied against each fanned-out Gift Transaction: Current Amount, not Original Amount.

### Object: Gift Tribute

#### Gift Tribute: Honoree Contact

- **Help:** The Person Account the tribute is for. Use this when the honoree already exists in FundFirst as a Person Account; fall back to Honoree Name for one-off honorees who don't need their own record.
- **Description:** Lookup to Account with an FQS-added lookup filter restricting selection to `IsPersonAccount = True` (see README §V.5 for the lookup filter setup). When set, Honoree Name should mirror the Person Account's full name; FQS does not auto-sync.

#### Gift Tribute: Honoree Name

- **Help:** Free-text name of the person being honored or remembered. Use this when the honoree isn't a Person Account or when the family requested the name appear differently on acknowledgment materials than in FundFirst.
- **Description:** Preferred over Honoree Contact when you don't want to create a Person Account for a one-time tribute honoree.

#### Gift Tribute: Tribute Type

- **Help:** Whether this is an In Honor Of tribute (celebrating a living person, e.g., birthday, milestone) or an In Memory Of tribute (memorial gift). Shapes acknowledgement letter language.
- **Description:** Restricted picklist. Legal values: In Honor Of, In Memory Of. Referenced by FQS acknowledgement templates.

#### Gift Tribute: Notification Contact

- **Help:** The Account (typically a Person Account — the family member or friend) who should receive the tribute acknowledgment letter or email. Leave blank if no notification is required.
- **Description:** Lookup to Account. Distinct from Honoree Contact: the honoree is the person being honored; the notification contact is who gets told the gift was made.

#### Gift Tribute: Notification Contact Name

- **Help:** Free-text notification recipient name — use when the recipient isn't in FundFirst as an Account or when the name on the letter should differ from the linked record.
- **Description:** FQS does not auto-copy from Notification Contact.

### Object: Gift Refund

#### Gift Refund: Amount

- **Help:** The refund amount in the gift's currency. Enter as a positive number — do not enter a negative. Partial refunds allowed; multiple refund records against one Gift Transaction are allowed and cumulate.
- **Description:** Currency, unsigned. Cumulative refunds across sibling Gift Refund records should not exceed the parent Gift Transaction: Transaction Amount — FQS does not validate this today.

### Object: Campaign Member

#### Campaign Member: Status

- **Help:** Where this member sits in the campaign's response funnel — for example, Sent when the appeal was delivered, Responded when the member gave, RSVP'd, or attended. Available values differ per campaign.
- **Description:** Unrestricted picklist, but the effective legal values are configured per-Campaign. Default values across all campaigns: Sent, Responded. Moving a member into any responded status auto-writes Has Responded = true and First Responded Date.

#### Campaign Member: Has Responded

- **Help:** Set automatically. Flipped to true the first time this member is moved into any of the campaign's "responded" statuses. Used by Campaign: Number Of Responses.
- **Description:** Platform-managed once true, remains true even if the status is later moved back to a non-responded value.

#### Campaign Member: First Responded Date

- **Help:** Set automatically. The first date this member entered a "responded" status on this campaign. Blank until the first response.
- **Description:** Written once by platform automation, on the first Has Responded = false → true transition. Not overwritten on subsequent status flips.

#### Campaign Member: Type

- **Help:** Set automatically. Reflects whether this campaign member points to a Person Account or Contact (value "Contact") or a Lead (value "Lead").

### Object: Gift Batch

#### Gift Batch: Does Total Gift Value Match

- **Description:** Written by the Gift Entry wizard. Compares aggregated Gift Transaction: Original Amount for the batch against Expected Value of Gifts in Batch. Investigate FALSE values before closing a batch.

---

## Post-install verification

After you've applied the edits above:

1. Open an existing record for each affected object.
2. Hover the "?" icon next to each affected field. The Help Text should render.
3. In Object Manager for the same object → **Fields & Relationships** → click the field label. The **Description** field should show the text you pasted.

If the "?" icon does not appear on a record page, the field is not on that page layout. Add it via **Setup → Object Manager → [Object] → Page Layouts** before end users benefit from the help text.

---

## Why this doc exists

Salesforce unmanaged packages carry field metadata edits only for **fields the package owns** — either custom (`__c`) fields, or standard fields the package has already customized in another way (e.g., picklist value additions, lookup filter additions). Applying `<inlineHelpText>` or `<description>` on a stock standard field via source deploy works in a scratch org or sandbox where the source has push authority, but the same edit is silently dropped when the metadata is repackaged for an unmanaged customer install.

The FQS metadata pass authored Help Text and Description on all custom fields and on the handful of standard fields FQS was already customizing (e.g., picklist value additions on `GiftCommitmentSchedule.Type`, lookup filter on `GiftTribute.HonoreeContactId`). The standard fields in this doc are the remainder — they cannot ride the package, so they need one-time manual application per install.

If a future package framework (managed 2GP, DevOps Center source-tracked deploy) provides a way to ship these edits, they will migrate out of this doc and into the package.
