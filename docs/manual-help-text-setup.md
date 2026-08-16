# Manual Help Text and Description Setup

Fundraising Quick Start ships help text and field descriptions for every FQS-authored custom field via the unmanaged package. **A handful of standard Salesforce-owned fields need those same edits applied by hand.** This is a Salesforce packaging limitation: unmanaged packages carry `<inlineHelpText>` and `<description>` only on custom (`__c`) fields and on standard fields the package already customizes for another reason. On a stock standard field, the platform ignores the packaged edit at install time.

The steps below walk you through applying the FQS-recommended Help Text and Description to each of those standard fields. Do this once, in every org where you install FQS.

**Scope:** 32 standard fields across 11 objects. The Help Text is what end users see when they hover the "?" icon on the record page. The Description is what admins see in Object Manager. Both are optional — you can apply Help Text only if you don't want to expose the Description in Object Manager, but the Description is where the semantic guidance and cross-field warnings live, so authoring both is recommended.

**Prerequisites:** Nonprofit Cloud Fundraising (FundFirst) installed. FQS deployed. **System Administrator** or **Customize Application** permission.

**Estimated time:** 45–60 minutes for the full pass. Each field is 30 seconds if you paste from this document.

---

## How to apply help text to a standard field

The steps are the same for every field. Do them once so you can move quickly through the list.

1. From **Setup**, click the **Object Manager** tab.
2. Search for and click the target object (e.g., **Gift Commitment**).
3. Click **Fields & Relationships**.
4. Click the field label (e.g., **Effective Start Date**).
5. Click **Edit**.
6. In the **Help Text** field, paste the **Help** value below for that field. Leave blank if the entry lists only a Description.
7. In the **Description** field, paste the **Description** value below. Leave blank if the entry lists only a Help.
8. Click **Save**.

Salesforce enforces a **510-character maximum on Help Text**. Descriptions are longer-form (1,000-character limit) and used only by admins in Object Manager.

Fields already covered by the README **Post-Install Setup and Configuration** section (Gift Commitment `EffectiveStartDate`, Gift Commitment Schedule `StartDate`, Gift Transaction `TransactionDate` / `AcknowledgementDate` / `PaymentIdentifier`) are marked with **✔ already in README** below and can be skipped if you followed the main README post-install steps.

---

## Object: Campaign

### Campaign: Type

- **Help:** The mechanism used to reach donors — e.g., Email for an email appeal, Seminar / Conference for an event campaign. For fundraising-native categorization, use FQS Campaign Category instead.
- **Description:** Unrestricted stock Salesforce picklist. Stock values skew marketing rather than fundraising.

### Campaign: Expected Revenue

- **Help:** The revenue you expect this campaign to raise across its full lifecycle — set at campaign kickoff based on prior-year performance and campaign goals.
- **Description:** User-set target field; not a rollup and not derived from child gifts. For actuals, join to Gift Transaction via CampaignId in reports.

### Campaign: Budgeted Cost

- **Help:** The amount you've budgeted to spend running this campaign — event venue, direct-mail printing, ad spend, staff time.
- **Description:** User-set. Combined with Actual Cost and the Hierarchy* variants for campaign-cost reporting.

### Campaign: Actual Cost

- **Help:** The amount actually spent running this campaign. Update as invoices post; compare against Budgeted Cost and against gift totals for cost-per-dollar-raised reporting.
- **Description:** User-set. Not derived from any related object — FQS does not track campaign expenses at the transaction level.

### Campaign: Campaign Member Record Type

- **Description:** Only used when Campaign Member has record types enabled. The Campaign Member record type used by default when adding new members to this campaign. Leave blank if your org uses a single member record type.

---

## Object: Gift Commitment

### Gift Commitment: Effective Start Date  ✔ already in README

Covered in **README → Post-Install Setup and Configuration → Section IV → step 3 ("Add help text to Gift Commitment: Effective Start Date")**. Skip if applied there.

Fuller version (if you want to author Description too):

- **Help:** The date this commitment begins — usually the date the pledge, grant, or recurring gift was made. Payments before this date won't roll up as "current period" totals.
- **Description:** Anchors period rollups on TotalCurrentMonth / Quarter / Year. For back-dated pledges, set to the original commitment date, not today.

### Gift Commitment: Expected End Date

- **Help:** The date this commitment is expected to be fully paid. For open-ended recurring gifts, leave blank. For fixed-length pledges and grants, set to the date of the final installment.
- **Description:** Fixed-length commitments should have this populated to drive lapse reporting; open-ended recurring gifts leave it blank. Not enforced by the platform — a fixed-length schedule with a null Expected End Date won't error, just under-report.

### Gift Commitment: Total Current Month

- **Help:** Set automatically. Total dollars paid against this commitment in the current calendar month.
- **Description:** System-maintained. Based on calendar year unless changed through customization.

### Gift Commitment: Total Current Quarter

- **Help:** Set automatically. Total dollars paid against this commitment in the current calendar quarter.
- **Description:** System-maintained. Based on calendar year unless changed through customization.

### Gift Commitment: Total Current Year

- **Help:** Set automatically. Total dollars paid against this commitment in the current calendar year.
- **Description:** System-maintained. Based on calendar year unless changed through customization.

### Gift Commitment: Total Next Year

- **Help:** Set automatically. Total dollars paid against this commitment in the next calendar year (projection).
- **Description:** System-maintained. Based on calendar year unless changed through customization.

### Gift Commitment: Gift Commitment Name

- **Help:** Set automatically by the FQS naming flow. Format: donor + gift type + primary campaign. To keep a specific Name from being overwritten — e.g., a name imported from another system — check Skip Naming.
- **Description:** Written by the FQS Auto Name Gift Commitment flow on insert and on relevant updates. Skipped when FQS Skip Naming = TRUE. Not enforced as unique.

---

## Object: Gift Commitment Schedule

### Gift Commitment Schedule: Start Date  ✔ already in README

Covered in **README → Post-Install Setup and Configuration → Section IV → step 4 ("Add help text to Gift Commitment Schedule: Start Date")**. Skip if applied there.

Fuller version (with Description):

- **Help:** The date this schedule becomes active. Payments won't post before this date, and the parent commitment's "next payment" fields stay blank until it arrives.
- **Description:** Required. Also drives Gift Commitment: Current Gift Commitment Schedule activation — the parent commitment's active-schedule lookup populates when Start Date is on or before today.

### Gift Commitment Schedule: End Date

- **Help:** The date this schedule stops generating payments. For open-ended recurring schedules, leave blank. For fixed-length schedules, set to the final installment date.
- **Description:** Combined with Start Date, Transaction Period, and Transaction Interval to fan out Expected Gift Transaction rows.

### Gift Commitment Schedule: Total Schedule Amount

- **Description:** For fixed-length schedules, equal to Transaction Amount × installment count. For open-ended recurring gifts, blank or projected.

### Gift Commitment Schedule: Transaction Interval

- **Help:** How many periods between payments. Combined with Transaction Period — for example, Period=Monthly + Interval=2 means every 2 months; Period=Weekly + Interval=1 means every week.
- **Description:** Required for Recurring schedules. Ignored on Custom schedules.

---

## Object: Gift Transaction

### Gift Transaction: Transaction Date  ✔ already in README

Covered in **README → Post-Install Setup and Configuration → Section IV → step 5**. Skip if applied there.

### Gift Transaction: Acknowledgement Date  ✔ already in README

Covered in **README → Post-Install Setup and Configuration → Section IV → step 6**. Skip if applied there.

### Gift Transaction: Payment Identifier  ✔ already in README

Covered in **README → Post-Install Setup and Configuration → Section IV → step 7**. Skip if applied there.

---

## Object: Gift Transaction Designation

### Gift Transaction Designation: Amount

- **Description:** Populate for absolute-dollar splits (e.g., "$500 of a $2,000 gift to Scholarship, $1,500 to General"). Mutually exclusive with Percent at the row level. Sum of Amount across all sibling Gift Transaction Designations must equal the parent transaction's Original Amount — the platform does NOT enforce this.

### Gift Transaction Designation: Percent

- **Description:** Percentage-based split — the platform derives an equivalent Amount from Gift Transaction: Original Amount × Percent / 100. Sum-to-100 across siblings is a reporting convention; the platform does NOT enforce it. Gift Default Designation routing produces Percent-based Gift Transaction Designations by default.

---

## Object: Gift Default Designation

### Gift Default Designation: Allocated Percentage

- **Description:** Consumed by the managed processGiftCommitment platform flow. Sum-to-100 across sibling Gift Default Designations is a reporting convention; the platform does NOT enforce it — a set summing to 90 will silently under-allocate 10% of every gift on that parent to the org-wide default Gift Designation.

---

## Object: Gift Soft Credit

### Gift Soft Credit: Soft Credit Amount

- **Help:** Set automatically. The dollar amount credited to the recipient — computed from Partial Amount if you entered a dollar figure, or from Partial Percent applied to the parent Gift Transaction's Current Amount. Leave both Partial fields blank to soft-credit the full gift.
- **Description:** Platform-computed. Reads Partial Amount first, falls back to Partial Percent × Gift Transaction: Current Amount, and defaults to Gift Transaction: Current Amount when both are null. Reporting rolls this into donor recognition totals.

### Gift Soft Credit: Partial Amount

- **Help:** Optional. Enter a specific dollar amount to credit — use when the soft credit is only for part of the gift. Leave blank and set Partial Percent instead if the split is percentage-based.
- **Description:** Sibling to Partial Percent. Entering both is rejected by the platform. Blank on both fields = credit the full parent Gift Transaction: Current Amount.

### Gift Soft Credit: Partial Percent

- **Help:** Optional. Enter a percentage (0–100) of the parent gift to credit — use when household members or joint solicitors split recognition. Mutually exclusive with Partial Amount.
- **Description:** Sibling to Partial Amount. Applied against Gift Transaction: Current Amount, not Original Amount — refunds and adjustments shrink the soft-credited amount along with the underlying gift.

---

## Object: Gift Default Soft Credit

### Gift Default Soft Credit: Role

- **Help:** The relationship this recipient has to the parent commitment or opportunity — copies onto every soft credit fanned out from this default.
- **Description:** Shares the value set with Gift Soft Credit: Role. Copies onto every child Gift Soft Credit at fan-out; editing on the default does not backfill previously-created Gift Soft Credits.

### Gift Default Soft Credit: Partial Amount

- **Help:** Optional. Enter a fixed dollar amount to soft-credit on every transaction fanned out from the parent. Mutually exclusive with Partial Percent.
- **Description:** Sibling to Partial Percent. On a recurring commitment, a fixed Partial Amount produces the same soft-credit dollar figure on every installment even if installment amounts differ — usually Partial Percent is the intended choice.

### Gift Default Soft Credit: Partial Percent

- **Help:** Optional. Enter a percentage (0–100) of each transaction to soft-credit — the typical choice for household splits, joint-solicitor recognition, and matching-gift routing.
- **Description:** Sibling to Partial Amount. Applied against each fanned-out Gift Transaction: Current Amount, not Original Amount.

---

## Object: Gift Tribute

### Gift Tribute: Honoree Name

- **Help:** Free-text name of the person being honored or remembered. Use this when the honoree isn't a Person Account or when the family requested the name appear differently on acknowledgment materials than in FundFirst.
- **Description:** Preferred over Honoree Contact when you don't want to create a Person Account for a one-time tribute honoree.

### Gift Tribute: Notification Contact

- **Help:** The Account (typically a Person Account — the family member or friend) who should receive the tribute acknowledgment letter or email. Leave blank if no notification is required.
- **Description:** Lookup to Account. Distinct from Honoree Contact: the honoree is the person being honored; the notification contact is who gets told the gift was made.

### Gift Tribute: Notification Contact Name

- **Help:** Free-text notification recipient name — use when the recipient isn't in FundFirst as an Account or when the name on the letter should differ from the linked record.
- **Description:** FQS does not auto-copy from Notification Contact.

---

## Object: Gift Refund

### Gift Refund: Amount

- **Help:** The refund amount in the gift's currency. Enter as a positive number — do not enter a negative. Partial refunds allowed; multiple refund records against one Gift Transaction are allowed and cumulate.
- **Description:** Currency, unsigned. Cumulative refunds across sibling Gift Refund records should not exceed the parent Gift Transaction: Transaction Amount — FQS does not validate this today.

---

## Object: Campaign Member

### Campaign Member: Status

- **Help:** Where this member sits in the campaign's response funnel — for example, Sent when the appeal was delivered, Responded when the member gave, RSVP'd, or attended. Available values differ per campaign.
- **Description:** Unrestricted picklist, but the effective legal values are configured per-Campaign. Default values across all campaigns: Sent, Responded. Moving a member into any responded status auto-writes Has Responded = true and First Responded Date.

### Campaign Member: Has Responded

- **Help:** Set automatically. Flipped to true the first time this member is moved into any of the campaign's "responded" statuses. Used by Campaign: Number Of Responses.
- **Description:** Platform-managed once true, remains true even if the status is later moved back to a non-responded value.

### Campaign Member: First Responded Date

- **Help:** Set automatically. The first date this member entered a "responded" status on this campaign. Blank until the first response.
- **Description:** Written once by platform automation, on the first Has Responded = false → true transition. Not overwritten on subsequent status flips.

### Campaign Member: Type

- **Help:** Set automatically. Reflects whether this campaign member points to a Person Account or Contact (value "Contact") or a Lead (value "Lead").

---

## Object: Gift Batch

### Gift Batch: Does Total Gift Value Match

- **Description:** Written by the Gift Entry wizard. Compares aggregated Gift Transaction: Original Amount for the batch against Expected Value of Gifts in Batch. Investigate FALSE values before closing a batch.

---

## Post-install verification

After you've applied the edits above:

1. Open an existing record for each affected object (Campaign, Gift Commitment, Gift Commitment Schedule, Gift Transaction, Gift Transaction Designation, Gift Default Designation, Gift Soft Credit, Gift Default Soft Credit, Gift Tribute, Gift Refund, Campaign Member, Gift Batch).
2. Hover the "?" icon next to each affected field. The Help Text should render.
3. In Object Manager for the same object → **Fields & Relationships** → click the field label. The **Description** field should show the text you pasted.

If the "?" icon does not appear on a record page, the field is not on that page layout. Add it via **Setup → Object Manager → [Object] → Page Layouts** before end users benefit from the help text.

---

## Why this doc exists

Salesforce unmanaged packages carry field metadata edits only for **fields the package owns** — either custom (`__c`) fields, or standard fields the package has already customized in another way (e.g., picklist value additions, lookup filter additions). Applying `<inlineHelpText>` or `<description>` on a stock standard field via source deploy works in a scratch org or sandbox where the source has push authority, but the same edit is silently dropped when the metadata is repackaged for an unmanaged customer install.

The FQS metadata pass authored Help Text and Description on 105 custom fields and ~7 standard fields FQS was already customizing. The 32 standard fields in this doc are the remainder — they cannot ride the package, so they need one-time manual application per install.

If a future package framework (managed 2GP, DevOps Center source-tracked deploy) provides a way to ship these edits, they will migrate out of this doc and into the package.
