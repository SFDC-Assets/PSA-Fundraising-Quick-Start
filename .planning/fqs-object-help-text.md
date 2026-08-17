# FQS Object Help Text — Consolidated

**Consolidated:** 2026-08-15. Supersedes `.planning/fqs-object-help-text-gc-gcs-gt.md` (Aug 3) and `.planning/fqs-object-help-text-remaining-objects.md` (Aug 2); originals archived under `.planning/archive/2026-08-15-*.md`.

**Scope:** Manual help-text and description authoring pass across all 21 in-scope FQS objects. Fields have been aggressively pruned in the current draft — anything not appearing below is a **deliberate skip** (owner made a conscious choice not to author help or description for it, either because the value is self-descriptive, platform-labeled, or beyond the FQS starter's coverage).

**Sources:**
- On-flexipage field lists from the FQS record-page flexipages
- Current field metadata under `force-app/main/default/objects/*/fields/`
- `docs/nonprofit-cloud-developer-guide-v67.md` (Chapter 3 — Fundraising)

---

## Rules of the pass

- **Not every field earns help text.** Skip when the API name is a complete sentence, no automation writes it on a hidden trigger, no sibling-field interaction, and the value type is unambiguous.
- **Keep help text** when *any* of these are true: sibling-field interaction, non-obvious writer or trigger, domain-standard name with surprising values, calendar / fiscal / timezone / activation-timing ambiguity, or edit-safety concerns.
- **Restricted picklists:** enumerate legal values in `<description>` (admins see them in Object Manager). Do NOT enumerate them in `<inlineHelpText>` — end users see the values in the dropdown already. Help text names the *meaning* and *when to pick*.
- **Standard-field labels are not renamed.** FQS owns labels only on custom `__c` fields.
- **Voice:** user-set = task-oriented. System-set = "Set automatically." + writer + edit-safety.

## README post-install steps required (combined index)

- `GC.CampaignId` lookup filter (leaf-level campaigns only)
- `GT.CampaignId` lookup filter (leaf-level campaigns only)
- `Opportunity.CampaignId` lookup filter (leaf-level campaigns only)
- `Opportunity.Type` picklist extension — add Grant / Major Gift / Planned Gift / Other
- `Opportunity.StageName` picklist — verify fundraising stages are present (base FundFirst adds them; base Sales Cloud does not)
- **Enable Person Accounts** before installing FQS (immutable once decided; Account tabs and PersonAccount visibility filters assume it is on)
- **Validation rule** preventing `Account.FQS_Matching_Gift_Program__c` and `Account.FQS_Is_Match_Intermediary__c` from both being TRUE
- **Custom Address compound help text does NOT deploy** — author on the visible **Street** subfield of each compound, or accept the compound rendering without a tooltip
- `GiftTribute.HonoreeContactId` lookup filter (Person Accounts only)
- If a target org has narrowed `OutreachSourceCode.MessageChannel` or `UsageType` picklists via a managed value-set override, restore the full FundFirst set post-install

Unmanaged packages don't carry lookup filters or picklist extensions — README must document them.

## Fields deliberately skipped (base convention)

Applies globally unless otherwise noted per-object:

- **Audit fields:** `CreatedById`, `CreatedDate`, `LastModifiedById`, `LastModifiedDate`, `SystemModstamp`, `IsDeleted`, `LastViewedDate`, `LastReferencedDate`, `LastActivityDate` — platform labels suffice.
- **Platform-labeled lookups:** `OwnerId`, `RecordTypeId`, `MasterRecordId`, autonumber `Name` on child objects — no FQS-specific meaning.
- **`External_Id__c` (custom, off-flexipage):** accelerator-wide convention. Pattern `FQS-<OBJ>-<idx>[-<subidx>]`. Not required for real records.
- **Gateway plumbing not written by FQS in the starter** (GT/GCS/GiftRefund): `LastGatewayProcessedDate`, `LastGatewayResponseCode`, `LastGatewayErrorMessage`, `GatewayReference`, `ProcessorReference`, `GatewayTransactionFee`, `ProcessorTransactionFee`, `PaymentInstrumentId`, `PartyPhilanthropicRsrchPrflId`. Defer until a real gateway integration lands.
- **Self-descriptive rollups** on rollup-heavy objects: `TotalPaidTransactionAmount`, `TransactionPaymentCount`, `LastPaidTransactionDate` (GC); the `IsFullyRefunded` / `IsPartiallyRefunded` / `IsWrittenOff` / `IsPaid` booleans (GT); paired amount / count rollups on `GiftDesignation`.
- **CampaignMember snapshot fields** projected from Contact / Lead — source of truth is the related person record.

Object sections below reserve the "Fields deliberately skipped" bullets for object-specific skips that are not covered by the base convention.

## Fields with no help or description authored (per-object inventory)

The list below records fields the owner **deliberately chose not to author** either `<inlineHelpText>` or `<description>` on. Anything above the base-convention skip line is not repeated. See `.planning/fqs-object-help-text-changes.md` for the reasoning behind each drop.

- **Account** (27): `Name`, `FirstName`, `LastName`, `RecordTypeId`, `IsPersonAccount`, `ParentId`, `Type`, `Industry`, `AnnualRevenue`, `NumberOfEmployees`, `BillingAddress`, `ShippingAddress`, `PersonMailingAddress`, `PersonOtherAddress`, `Phone`, `Website`, `PersonEmail`, `PersonMobilePhone`, `PersonHomePhone`, `PersonOtherPhone`, `PersonBirthdate`, `PersonMaritalStatus`, `PersonGenderIdentity`, `PersonPronouns`, `PersonTitle`, `PersonDepartment`, `PersonHasOptedOutOfEmail`, `PersonDoNotCall`, `Description`
- **Campaign** (10): `ParentId`, `Status`, `IsActive`, `StartDate`, `EndDate`, `HierarchyNumberOfContacts`, `HierarchyNumberOfResponses`, `HierarchyNumberSent`, `HierarchyExpectedRevenue`, `HierarchyBudgetedCost`, `HierarchyActualCost`, `Description`
- **Opportunity** (8): `Name`, `AccountId`, `CampaignId`, `LeadSource`, `StageName`, `Type`, `NextStep`, `Description`
- **GiftCommitment** (11): `CampaignId`, `DonorId`, `ExpectedTotalCmtAmount`, `TotCommitmentScheduleAmt`, `NextTransactionAmount`, `NextTransactionDate`, `EffectiveTransactionPeriod`, `EffectiveTransactionInterval`, `WrittenOffAmount`, `Status`, `FormalCommitmentType`, `LastNextGenCmtProcDtTm`, `LastNextGenCmtProcError`, `OpportunityId`, `Description`
- **GiftCommitmentSchedule** (8): `GiftCommitmentId`, `CampaignId`, `PaymentMethod`, `GiftCommitmentStatus`, `GiftCommitmentSchdBefEditId`, `OutreachSourceCodeId`, `Name`
- **GiftTransaction** (20): `CampaignId`, `DonorId`, `GiftCommitmentId`, `GiftCommitmentScheduleId`, `RefundedAmount`, `DonorCoverAmount`, `TotalTransactionFee`, `AcknowledgementDate`, `OutreachSourceCodeId`, `MatchingEmployerTransactionId`, `Description`, `FQS_Matched__c`, `FQS_Processed_Date__c`, `FQS_Stewardship_Status__c`, `FQS_Stewardship_Date__c`, `FQS_Tax_Receipt_Date__c`, `FQS_Recurring__c`
- **GiftDesignation** (2): `Name`, `Description`
- **GiftTransactionDesignation** (3): `GiftTransactionId`, `GiftDesignationId`, `FQS_Restriction_Type__c`
- **GiftDefaultDesignation** (3): `ParentRecordId`, `GiftDesignationId`, `FQS_Restriction_Type__c`
- **GiftSoftCredit** (3): `RecipientId`, `GiftTransactionId`, `GenerationalCohort`
- **GiftDefaultSoftCredit** (2): `ParentRecordId`, `RecipientId`
- **GiftTribute** (8): `GiftTransactionId`, `GiftCommitmentId`, `HonoreeInformation`, `NotificationEmail`, `NotificationInfo`, `NotificationChannel`, `NotificationStatus`, `NotificationDate`, `NotificationMessage`
- **GiftRefund** (9): `GiftTransactionId`, `GatewayTransactionFee`, `ProcessorTransactionFee`, `Date`, `Reason`, `Status`, `LastGatewayResponseCode`, `LastGatewayErrorMessage`, `LastGatewayProcessedDate`
- **OutreachSourceCode** (5): `Name`, `SentDate`, `AudienceInformation`, `MessageContent`, `MessageContentTitle`
- **ActionPlan** (whole object): `TargetId`, `ActionPlanTemplateVersionId`, `ActionPlanState`, `StatusCode`, `ActionPlanType`, `RecordCreationType`, `StartDate`, `EndDate`, `ActualStartDate`, `ActualEndDate`, `IsUsingHolidayHours`, `RecurringScheduleId`, `ScheduleFrequency`, `ShouldAllowOverride`
- **CampaignMember** (4): `CampaignId`, `LeadId`, `ContactId`, `LeadOrContactId`
- **OutreachSummary** (10): `CampaignId`, `OutreachSourceCodeId`, `TotalGiftTransactionAmount`, `AverageGiftAmount`, `AverageOnetimeGiftAmount`, `AverageRecurringGiftAmount`, `GiftCount`, `DonorCount`, `OnetimeDonorCount`, `RecurringDonorCount`
- **GiftBatch** (9): `Name`, `Description`, `Status`, `StatusReason`, `LastProcessedDateTime`, `EstimatedGiftCount`, `ExpectedValueofGiftsinBatch`, `DefaultGiftFieldValues`, `ScreenTemplateName`
- **GiftCmtChangeAttrLog** (whole object)
- **FundraisingConfig** (whole object): deferred pending a "Configure Fundraising Engine Settings" README section
- **DonorGiftSummary** (33): `FirstGiftDate`, `FirstGiftAmount`, `FirstGiftCampaignId`, `SecondGiftDate`, `LastGiftDate`, `LastGiftAmount`, `FirstRecurringStartDate`, `CurrentRecurringStartDate`, `LastRecurringPaymentDate`, `HighestGiftAmount`, `LowestGiftAmount`, `HighestGiftYearAmount`, `AverageGiftAmount`, `GiftCount`, `TotalGiftsAmount`, `GiftsLastYearAmount`, `GiftsTwoYearsAgoAmount`, `CurrentYearGiftCount`, `LastYearGiftCount`, `LastTwoYearGiftCount`, `SoftCreditCount`, `LastSoftCreditAmount`, `LastSoftCreditDate`, `FirstSoftCreditAmount`, `FirstSoftCreditDate`, `HighestSoftCreditAmount`, `HighestSoftCreditDate`, `TotalSoftCreditsAmount`, `CurrentYearSoftCreditCount`, `LastYearSoftCreditCount`, `LastYearSoftCreditsAmount`, `TotalHardSoftCreditsAmount`, `TotalHardSoftCredits`, `Name`, `DonorId`, `DaysSinceLastGift`, `FQS_Legacy_First_Gift_Date__c`, `FQS_Legacy_Gift_Count__c`, `FQS_Legacy_Total_Gifts_Amount__c`, `FQS_Legacy_Soft_Credit_Total__c`

---

## Coverage summary

| Tier | Object | Total fields | Recommended | New `.field-meta.xml` needed |
|---|---|---:|---:|---:|
| Key | Account | 91 | 36 | 31 |
| Key | Campaign | 46 | 22 | 17 |
| Key | Opportunity | 48 | 18 | 0 |
| Key | GiftCommitment | 51 | 30 | 15 |
| Key | GiftCommitmentSchedule | 45 | 25 | 12 |
| Key | GiftTransaction | 56 | 36 | 16 |
| Key | GiftDesignation | 29 | 7 | 2 |
| Key | GiftTransactionDesignation | 17 | 5 | 3 |
| Supporting | GiftDefaultDesignation | 16 | 4 | 2 |
| Supporting | GiftSoftCredit | 19 | 8 | 6 |
| Supporting | GiftDefaultSoftCredit | 17 | 6 | 5 |
| Supporting | GiftTribute | 26 | 14 | 13 |
| Supporting | GiftRefund | 21 | 10 | 10 |
| Supporting | OutreachSourceCode | 29 | 16 | 11 |
| Supporting | ActionPlan | 25 | 12 | 12 |
| Supporting | CampaignMember | 36 | 8 | 8 |
| Background | OutreachSummary | 25 | 12 | 5 |
| Background | GiftBatch | 24 | 10 | 10 |
| Background | GiftCmtChangeAttrLog | 18 | 9 | 9 |
| Background | FundraisingConfig | 30 | 19 | 19 |
| Background | DonorGiftSummary | 73 | 60 | 48 |
| **Total** | **21 objects** | **742** | **367** | **254** |

**Note (2026-08-15):** the table above is the historical scope target. The current draft has been aggressively pruned — the actual authored copy in this file is a subset of "Recommended". See `.planning/fqs-object-help-text-changes.md` for the delta.

---

# Key tier

## Object: Account (`Account`)

**FQS flexipage:** `FQS_Account_Record_Page.flexipage-meta.xml`

### Fields with help text authored

#### Family: Matching-gift capability (surface-or-justify open follow-ups)

The four fields below are OFF the FQS Account flexipage per `.planning/fqs-off-flexipage-inventory.md` — surface them or explicitly justify hiding. Help text is authored regardless because Object Manager and Setup surface these to admins.

##### `FQS_Matching_Gift_Program__c` — custom

- **Help:** Check when this business Account offers an employer matching gift program. Do not check for matching-gift intermediaries such as Benevity or YourCause — use FQS Is Match Intermediary for those.

##### `FQS_Is_Match_Intermediary__c` — custom

- **Help:** Check when this Account is a matching-gift intermediary (Benevity, YourCause, Bright Funds, CyberGrants, etc.) rather than a true corporate donor.

##### `FQS_Match_Ratio__c` — custom

- **Help:** The dollar ratio this employer matches at. Enter 1.00 for 1:1 matching (default), 2.00 for 2:1, 0.50 for half-match, etc. Leave blank to use 1.00.

##### `FQS_Match_Annual_Individual_Maximum__c` — custom

- **Help:** Maximum dollar amount this employer will match per individual per calendar year. Leave blank if the employer has no per-donor cap.

---

## Object: Campaign (`Campaign`)

**FQS record page:** `FQS_Campaign_Record_Page.flexipage-meta.xml` (uses `force:detailPanel` — field visibility is page-layout-driven, not flexipage-driven)

### README post-install steps required

- **Confirm Campaign page layout surfaces the 5 FQS custom fields.** `force:detailPanel` renders whatever page layout is assigned to the running user's profile — help text on `FQS_Campaign_Category__c`, `FQS_Short_Name__c`, `FQS_Child_Campaign_Count__c`, `FQS_Hierarchy_Depth__c`, and `FQS_Ultimate_Parent_Campaign__c` only appears if the field is on that layout. Unmanaged install won't touch the customer's existing Campaign page layout.
- **(Optional)** Extend `Type` picklist with fundraising-native values (Grant, Event, Appeal, Recurring Gift Program, Peer-to-Peer, Planned Giving, Major Gift) via Object Manager. Picklist is unrestricted and stock Salesforce values remain — extension is customer-owned, not FQS-shipped.
- **(Optional)** Extend `Status` picklist beyond stock Planned / In Progress / Completed / Aborted if the fundraising team needs pre-launch or post-close granularity.

### Fields with help text authored

#### Family: Identity & hierarchy

##### `FQS_Short_Name__c` — custom (README layout audit)

- **Help:** Equivalent to `utm_campaign` in web analytics. Used as the campaign segment when naming Outreach Source Codes. Also use this value directly as `utm_campaign` on any URLs promoted by this campaign. Lowercase, alphanumeric and hyphens only.
- **Description:** Fundraising Quick Start: short, URL-safe identifier for use in UTM campaign codes and Outreach Summary source tracking. Lowercase alphanumeric and hyphens recommended (e.g. `fy26-yearend-email`). Read by Outreach Source Code naming conventions; not enforced as unique.

##### `FQS_Ultimate_Parent_Campaign__c` — custom, formula (README layout audit)

- **Help:** Set automatically. The name of the topmost campaign in this hierarchy branch (walks up to 5 levels of parents). Returns this campaign's own name when it has no parent.
- **Description:** Formula walks `Parent.Parent.Parent.Parent.Parent.Name` down to `Name`. Text (name), not an Id. Depth limit is 5; deeper trees return the level-5 ancestor, not the true root.

##### `FQS_Hierarchy_Depth__c` — custom, formula

- **Help:** Set automatically. Depth of this campaign in the hierarchy — 1 for top-level campaigns with no parent, 2 for direct children, up to 5 for the deepest supported nesting.
- **Description:** Boolean depth formula using `ISBLANK(Parent[.Parent...].ParentId)`. Depth ≥ 5 is clamped at 5. Use in list-view filters and reports to isolate leaf-level campaigns versus category branches.

##### `FQS_Child_Campaign_Count__c` — custom, flow-maintained (README layout audit)

- **Help:** Set automatically. Count of direct child campaigns (immediate children only — grand-children are counted by their own parent).
- **Description:** Maintained by FQS_Campaign_Child_Count_Update (after-save) and FQS_Campaign_Child_Count_Delete (before-delete) record-triggered flows. Not a rollup summary. If this stops updating, check the flows are active in Setup → Flows.

##### `CampaignMemberRecordTypeId` — standard

- **Description:** Only used when Campaign Member has record types enabled. The Campaign Member record type used by default when adding new members to this campaign. Leave blank if your org uses a single member record type.

#### Family: Categorization

##### `FQS_Campaign_Category__c` — custom, unrestricted picklist

- **Help:** Classifies the fundraising purpose of this campaign. Drives list-view segmentation on the Campaigns tab and controls related-list visibility on the Campaign record page.

##### `Type` — standard, unrestricted picklist

- **Help:** The mechanism used to reach donors — e.g., Email for an email appeal, Seminar / Conference for an event campaign. For fundraising-native categorization, use `FQS_Campaign_Category__c` instead.
- **Description:** Unrestricted stock Salesforce picklist. Stock values skew marketing rather than fundraising.

#### Family: Financials (user-entered forecasts)

##### `ExpectedRevenue` — standard

- **Help:** The revenue you expect this campaign to raise across its full lifecycle — set at campaign kickoff based on prior-year performance and campaign goals.
- **Description:** User-set target field; not a rollup and not derived from child gifts. For actuals, join to `GiftTransaction` via `CampaignId` in reports.

##### `BudgetedCost` — standard

- **Help:** The amount you've budgeted to spend running this campaign — event venue, direct-mail printing, ad spend, staff time.
- **Description:** User-set. Combined with `ActualCost` and the `Hierarchy*` variants for campaign-cost reporting.

##### `ActualCost` — standard

- **Help:** The amount actually spent running this campaign. Update as invoices post; compare against `Budgeted Cost` and against gift totals for cost-per-dollar-raised reporting.
- **Description:** User-set. Not derived from any related object — FQS does not track campaign expenses at the transaction level.

---

## Object: Opportunity (`Opportunity`)

**FQS flexipage:** `FQS_Opportunity_Record_Page.flexipage-meta.xml`

### README post-install steps required

- `Opportunity.CampaignId` lookup filter (leaf-level campaigns only, matching GC / GT convention) — unmanaged packages don't carry lookup filters
- `Opportunity.Type` picklist extension — add fundraising-oriented values (`Grant`, `Major Gift`, `Planned Gift`, `Other`) to replace the stock `Existing Business` / `New Business` pair; the FQS launcher and Gift Entry Opportunity branch assume these values exist
- `Opportunity.StageName` picklist — FundFirst adds fundraising stages (`Identification`, `Cultivation`, `Solicitation`, `Verbal Commitment`, `Pledged`, `LOI Submitted`, `Proposal Submitted`, `Under Review`, `Awarded`, `Declined`). If installing FQS onto a base Sales Cloud org without FundFirst, README must document adding these stages before the Opportunity path is usable.

### Fields deliberately skipped

- **Self-descriptive stage / forecast derivatives:** `IsClosed`, `IsWon`, `ForecastCategory`, `ForecastCategoryName`, `Fiscal`, `FiscalQuarter`, `FiscalYear`, `HasOpenActivity`, `HasOpportunityLineItem`, `HasOverdueTask`, `LastActivityInDays`, `LastStageChangeDate`, `LastStageChangeInDays`, `AgeInDays`.
- **Sales Cloud plumbing not used by FQS starter:** `Pricebook2Id`, `ContractId`, `TotalOpportunityQuantity`, `IqScore`, `IsPrivate`, `SourceId`.

### Fields with help text authored

#### Family: Identity & naming

##### `FQS_Skip_Naming__c` — custom (off-flexipage), `Skip FQS Auto Naming`

- **Help:** Check to prevent the FQS auto-naming flow from overwriting the Name on this Opportunity. Use for imports or integrations where the record already carries an authoritative external Name.

#### Family: Amounts

##### `Amount` — standard

- **Help:** The dollar value the donor is expected to give if this Opportunity closes-won. For grants, the request amount; for major gifts, the ask amount.
- **Description:** On close-won, the FQS Opportunity launcher writes this value into the resulting `GiftCommitment.ExpectedTotalCmtAmount` or `GiftTransaction.OriginalAmount`.

##### `ExpectedRevenue` — standard, system

- **Help:** Set automatically. `Amount × Probability`. Used by pipeline forecasts to weight open Opportunities.
- **Description:** Platform-computed; not writable. FQS reports on unweighted `Amount` for pipeline totals.

##### `Probability` — standard

- **Help:** Likelihood this Opportunity closes-won, as a percentage. Defaults from the selected Stage — override only when you have Opportunity-specific intelligence.
- **Description:** Stage → Probability mapping is managed at the platform level. Manual override is per-record and does not update the stage default.

#### Family: Timing

##### `CloseDate` — standard

- **Help:** The date this Opportunity is expected to close — award decision date for grants, expected commitment date for major gifts.
- **Description:** Required by the platform. On close-won, the FQS launcher writes this into `GiftCommitment.EffectiveStartDate` or `GiftTransaction.TransactionDate`.

##### `FQS_Solicitation_Date__c` — custom

- **Help:** The date on which the formal ask was presented to the donor. Used for pipeline tracking and time-to-close analysis.
- **Description:** Populated manually by the gift officer on the Solicitation stage. Time-to-close reports use `CloseDate − FQS_Solicitation_Date__c`.

##### `FQS_Grant_Deadline__c` — custom

- **Help:** The deadline to submit this grant application or report to the funder.
- **Description:** Distinct from `CloseDate` (anticipated award decision date). Populated on Grant-type Opportunities during the LOI / Proposal stages.

##### `FQS_Grant_Report_Due__c` — custom

- **Help:** When the grant report (progress or final) must be submitted to the funder after the award.
- **Description:** Populated post-Awarded for grants with reporting requirements. Drives grant-stewardship reminders.

### Open follow-ups for Opportunity

- Reconcile `FQS_Skip_Naming__c` (surface-or-justify) — mirrors GC. Recommendation: keep off-flexipage.
- Coordinate `Type` picklist values with the FQS Opportunity launcher's supported flows (`FQS_Gift_Entry_Single_Launcher_Opportunity`).
- Confirm whether the FQS launcher's close-won conversion writes back an `Opportunity.Id` reference to the resulting `GiftCommitment.OpportunityId`.
- `ContactId` (primary contact) — off-flexipage. Surface-or-justify for the grants / major-gifts path.
- Verify `StageName` fundraising stages ship in the base FundFirst org vs. requiring FQS-side augmentation.

---

## Object: GiftCommitment (GC)

### GC.CurrentGiftCmtScheduleId — standard, platform-managed

- **Help:** Set automatically. The gift commitment schedule currently in force. The platform populates this when a schedule's Start Date is today or earlier. Records with a future Start Date leave this field blank until activation.
- **Description:** Platform-managed lookup. Populated by the Fundraising engine when a schedule's `StartDate` arrives (past-or-today), not at insert time. Do not back-fill in flows or Apex — that overrides the platform's active-vs-pending semantics and breaks reports that filter on `CurrentGiftCmtScheduleId != null` to identify actively giving commitments. See [[gc-current-schedule-activation]].

### GC.EffectiveStartDate — standard

- **Help:** The date this commitment begins — usually the date the pledge, grant, or recurring gift was made. Payments before this date won't roll up as "current period" totals.
- **Description:** Anchors period rollups on `TotalCurrentMonth/Quarter/Year`. For back-dated pledges, set to the original commitment date, not today.

### GC.ExpectedEndDate — standard

- **Help:** The date this commitment is expected to be fully paid. For open-ended recurring gifts, leave blank. For fixed-length pledges and grants, set to the date of the final installment.
- **Description:** Fixed-length commitments should have this populated to drive lapse reporting; open-ended recurring gifts leave it blank. Not enforced by the platform — a fixed-length schedule with a null ExpectedEndDate won't error, just under-report.

### GC.TotalCurrentMonth / Quarter / Year / NextYear — standard, system

- **Help:** Set automatically. Total dollars paid against this commitment in the current calendar month / quarter / year (or the next calendar year for the projection field).
- **Description:** System-maintained. Based on calendar year unless changed through customization.

### GC.ScheduleType — standard-extended, platform-managed picklist

- **Help:** Leave blank for standard recurring gifts and pledges — the platform will fill this in from the schedule you attach. Set to *Custom* only when the schedule has irregular installment amounts or spacing (typical for grants).
- **Description:** Restricted picklist. Legal values: **Recurring** (platform fans out installments from `TransactionPeriod` + `TransactionInterval` + `TransactionDay`), **Custom** (irregular installments — each `GiftTransaction` must be inserted by hand). Platform-managed on Flow inserts (silently overrides to `Recurring` unless left blank). Apex can set `Custom` on insert explicitly.

  This is a system field that describes the schedule attached to the commitment — not the type of gift itself. A wide variety of pledges and gifts can have a `Recurring` value here, not just open-ended online recurring donations for a set amount.

### GC.RecurrenceType — standard-extended, restricted picklist

- **Help:** Choose *Fixed Length* for pledges, grants, and scheduled gifts with a defined end date. Choose *Open Ended* for recurring gifts with no end date — the donor gives on a regular cadence until they cancel.
- **Description:** Restricted picklist. Legal values: **Fixed Length**, **Open Ended**. Set explicitly by the launcher / seed generator; the platform does not derive this from the child schedule. Default: `Open Ended`.

### GC.FulfillmentType — standard-extended, restricted picklist

- **Help:** Choose *Unconditional* when the committed funds are usable as soon as they arrive. Choose *Conditional* when the gift is contingent on specific milestones being met — typical for grants with reporting or programmatic conditions.
- **Description:** Restricted picklist. Legal values: **Unconditional**, **Conditional**. Reporting-only in FQS. Default: `Unconditional`.

### GC.Name — standard, FQS auto-named

- **Help:** Set automatically by the FQS naming flow. Format: donor + gift type + primary campaign. To keep a specific Name from being overwritten — e.g., a name imported from another system — check *Skip Naming*.
- **Description:** Written by the `FQS_Auto_Name_Gift_Commitment` flow on insert and on relevant updates. Skipped when `FQS_Skip_Naming__c = TRUE`. Not enforced as unique.

### GC custom fields

- **GC.FQS_Gift_Commitment_Category__c** — unrestricted picklist, custom, `Gift Commitment Category`
  - **Help:** Classifies the type of commitment this record represents. Choose *Pledged Gift* for a one-time promise paid over time, *Recurring Gift* for an ongoing donation cadence, *Grant Payout* for foundation or institutional grant disbursements.
  - **Description:** Set by the FQS Gift Entry launcher on the parent Gift Commitment based on the branch chosen. Child Gift Transactions inherit the mapped category via the before-save `FQS_Auto_Category_Gift_Transaction` flow when their own `FQS_Gift_Transaction_Category__c` is blank and `GiftCommitmentId` is populated.

- **GC.FQS_Is_Entry_Commitment__c / FQS_Is_Mid_Commitment__c / FQS_Is_Major_Commitment__c** — formula, custom
  - **Help:** Set automatically. Checked when this commitment's total expected amount falls in the corresponding donor grouping. Your administrator controls the threshold through the FQS Setup flow.
  - **Description:** Boolean formula reading the FQS Donor Grouping CMDT thresholds. Configure via Setup → Custom Metadata Types or the FQS Setup flow → Configure Donor Groupings.

- **GC.FQS_Match_Eligible__c** — boolean, custom, `Match Eligible`
  - **Help:** Set to true if a corporate matching gift is expected against this commitment. The Gift Entry launcher reads this to default the match question on payments recorded against this commitment.

- **GC.FQS_Restriction_Release_Date__c** — date, custom, `Restriction Release Date`
  - **Help:** The date restricted funds from this commitment become available for their designated purpose or for general use. Leave blank for gifts with no time restriction.
  - **Description:** Convention: one year past the final installment date for multi-year and custom-schedule grants. Populated automatically by FQSSeedGenerator on grant-multiyear and grant-custom shapes; manually editable for real gifts.

- **GC.FQS_Summary__c** — formula, custom, `Summary`
  - **Help:** Set automatically. A one-sentence plain-English summary of this commitment's schedule — cadence, amount, and start. Updates as the underlying schedule changes.
  - **Description:** Assembled from platform-managed schedule fields with a failsafe for pre-activation commitments — when `ScheduleType` is set but `CurrentGiftCmtScheduleId` is null, returns "Schedule starts in the future."

- **GC.FQS_Skip_Naming__c** — boolean, custom (off-flexipage), `Skip Auto-Naming`
  - **Help:** Check to prevent the FQS auto-naming flow from overwriting the Name on this Gift Commitment. Use for imports or integrations where the record already carries an authoritative external Name.

---

## Object: GiftCommitmentSchedule (GCS)

### GCS.StartDate — standard

- **Help:** The date this schedule becomes active. Payments won't post before this date, and the parent commitment's "next payment" fields stay blank until it arrives.
- **Description:** Required. Also drives `GC.CurrentGiftCmtScheduleId` activation — the parent GC's active-schedule lookup populates when StartDate ≤ today. See [[gc-current-schedule-activation]].

### GCS.EndDate — standard

- **Help:** The date this schedule stops generating payments. For open-ended recurring schedules, leave blank. For fixed-length schedules, set to the final installment date.
- **Description:** Combined with `StartDate`, `TransactionPeriod`, and `TransactionInterval` to fan out Expected `GiftTransaction` rows.

### GCS.TransactionAmount — standard

- **Description:** Per-installment amount. Combined with `TransactionPeriod` + `TransactionInterval` to fan out Expected `GiftTransaction` rows. Required.

### GCS.TotalScheduleAmount — standard

- **Description:** For fixed-length schedules, equal to `TransactionAmount × installment count`. For open-ended recurring gifts, blank or projected.

### GCS.TransactionPeriod — standard, restricted picklist

- **Help:** Choose the cadence for this schedule's installments. For grants and pledges with irregular payment amounts or spacing, choose *Custom* — you'll enter each installment as its own gift transaction.
- **Description:** Restricted picklist. Legal values: **Daily**, **Weekly**, **Monthly**, **Yearly** (platform fans out Expected `GiftTransaction` rows), **Custom** (disables engine fanout — each installment inserted independently). `Custom` requires parent `GiftCommitment.ScheduleType='Custom'` and this row's `Type='CreateTransactions'`. Required. See [[fundfirst-custom-schedule-shape]].

### GCS.TransactionInterval — standard

- **Help:** How many periods between payments. Combined with Transaction Period — for example, Period=Monthly + Interval=2 means every 2 months; Period=Weekly + Interval=1 means every week.
- **Description:** Required for `Recurring` schedules. Ignored on `Custom` schedules.

### GCS.TransactionDay — standard, restricted picklist

- **Help:** The day of the month payments post on. For payments due at the end of the month, choose *LastDay* — this handles February and other short months automatically. Days 29, 30, and 31 aren't selectable; use LastDay instead.
- **Description:** Restricted picklist. Legal values: **'1'..'28'** and **'LastDay'**. Values 29–31 are rejected with `INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`. Required when `TransactionPeriod = 'Monthly'` or `'Yearly'`. Set to `DAY(StartDate)` on seed to avoid monthly-drift to day 1.

### GCS.Type — standard, restricted picklist

- **Help:** Choose *Create Transactions* for a schedule that generates gift transactions as installments come due. Choose *Pause Transactions* to suspend installment generation temporarily — the schedule stays attached but stops producing new gifts.
- **Description:** Restricted picklist. Legal values: **CreateTransactions** (normal), **PauseTransactions** (suspended without deleting the schedule). Used by the managed `frops_flow__PauseResumeSchedule` action to pause / resume without deleting schedule history. Default: `CreateTransactions`.

### GCS.CommitmentUpdateReason — standard, unrestricted picklist

- **Description:** Populated by the schedule edit / pause / resume flows; manual override allowed. Reporting-only.

---

## Object: GiftTransaction (GT)

### GT.OriginalAmount — standard

- **Help:** The full gift amount as originally recorded. For refunds or adjustments, don't change this — record a Gift Refund instead.
- **Description:** Includes donor cover, excludes gateway/processor fees. Required. Once posted, treat as immutable — reductions flow through GiftRefund children so `CurrentAmount` recalculates.

### GT.CurrentAmount — standard, system

- **Help:** Set automatically. The gift amount remaining after any refunds or adjustments. Equals the Original Amount unless a Gift Refund has been posted.
- **Description:** Not writable via API or Apex — attempting to set returns `INVALID_FIELD_FOR_INSERT_UPDATE`. To reduce, insert a GiftRefund child instead of mutating this field.

### GT.TaxDeductionAmount — standard

- **Help:** Automatically calculated as Current Amount minus Non-Tax Deductible Amount. For In-Kind gifts, the deductible portion is instead tracked on Fair Market Value Amount, since the donor determines the FMV and the auto-calculation does not apply.
- **Description:** Manual field. Blank means "assume full deduction" for receipting purposes. For in-kind gifts, work with `FQS_Fair_Market_Value_Amount__c` — legal deduction determination is the donor's responsibility.

### GT.NonTaxDeductibleAmount — standard

- **Help:** The portion of this gift the donor cannot deduct — e.g., the fair-market value of event tickets, dinners, or benefits received in exchange for the gift.
- **Description:** Quid-pro-quo tracking. When populated, `TaxDeductionAmount` should equal `CurrentAmount − NonTaxDeductibleAmount`. Not auto-computed.

### GT.TransactionDate — standard

- **Help:** The date the donor made this gift — check date, credit-card charge date, or the date the wire hit. Required when Status is Paid or Fully Refunded.
- **Description:** For pledge payments, this is the *payment* date, not the pledge date (which lives on the parent commitment's `EffectiveStartDate`). Distinct from `FQS_Processed_Date__c` (when the org entered the gift).

### GT.TransactionDueDate — standard

- **Help:** The date this gift was expected. For a one-time gift you're recording now, set the same date as Transaction Date. For a pledge or recurring payment, this matches the installment's scheduled due date.
- **Description:** Required on insert even for gifts in Paid status. For outright gifts, set equal to `TransactionDate`. For pledge payments, match the parent `GiftCommitmentSchedule` installment row.

### GT.Status — standard, unrestricted picklist

- **Description:** Platform fan-out from schedule sets `Status='Expected'` — see [[gt-expected-status-default]]. FQS Gift Entry launcher defaults to `Paid` for retroactive data entry — see [[gt-status-default-paid]]. Direct-writing `Paid` on insert bypasses normal payment posting; use for seed/test only.

### GT.AcknowledgementStatus — standard, unrestricted picklist

- **Description:** Written by the `FQS_Gift_Acknowledgement` flow. `To Be Sent` (default) queues the gift for the daily run; `Sent` stamps `AcknowledgementDate`. Clearing back to `To Be Sent` re-queues on next daily run.

### GT.TaxReceiptStatus — standard, unrestricted picklist

- **Description:** `Sent` stamps `FQS_Tax_Receipt_Date__c`. Available from API 62.0+. Year-end receipting is out of scope for FQS automation — status is manually set today.

### GT.GiftType — standard, restricted picklist

- **Description:** Restricted picklist. Legal values: **Individual**, **Organizational**. Set explicitly on insert; not derived from `DonorId`. Default: `Individual`. Drives the Matching Employer Transactions related list visibility (shown only when `Individual` AND `FQS_Matched__c = TRUE`).

### GT.PaymentMethod — standard, unrestricted picklist

- **Description:** Required. Drives visibility of downstream fields (`CheckDate` for check gifts; `FQS_Fair_Market_Value_Amount__c` for `In-Kind`). On pledge / recurring payments, inherits from the parent schedule.

### GT.PaymentIdentifier — standard

- **Help:** The reference number for the payment channel — check number, wire confirmation number, or merchant order number. Useful for reconciliation.
- **Description:** Free-text. Common patterns: check number for checks, transaction ID for card / ACH, wire confirmation for wire transfers, order number for gateway transactions.

### GT.Name — standard, FQS auto-named

- **Help:** Set automatically by the FQS naming flow. Format: donor + amount + date + gift kind. To keep a specific Name from being overwritten — e.g., a name imported from another system — check *Skip Naming*.
- **Description:** Written by the `FQS_Auto_Name_Gift_Transaction` flow on insert and on relevant updates. Skipped when `FQS_Skip_Naming__c = TRUE`.

### GT custom fields

- **GT.FQS_Gift_Transaction_Category__c** — unrestricted picklist, custom, `Gift Transaction Category`
  - **Help:** Classifies what kind of transaction this record represents. *Outright Gift* is a one-time gift not tied to a commitment; *Pledge Payment*, *Recurring Gift Payment*, and *Grant Payment* are installments against a commitment; *Other* covers earned income, event registrations, and service fees.
  - **Description:** Set by the FQS Gift Entry launcher, or inherited from the parent Gift Commitment's `FQS_Gift_Commitment_Category__c` by the before-save `FQS_Auto_Category_Gift_Transaction` flow when this field is blank and `GiftCommitmentId` is populated (Pledged Gift → Pledge Payment; Recurring Gift → Recurring Gift Payment; Grant Payout → Grant Payment). `Other` excludes the transaction from acknowledgement and stewardship flows.

- **GT.FQS_Is_Entry_Gift__c / FQS_Is_Mid_Gift__c / FQS_Is_Major_Gift__c** — formula, custom

- **GT.FQS_In_Kind__c** — boolean, custom, `In-Kind`
  - **Help:** Check when this gift is a non-cash contribution — goods, services, or property. In-kind gifts use `OriginalAmount = 0` (they don't count toward cash rollups) and record the estimated value on `Fair Market Value Amount`. Salesforce automation routes off this flag: the in-kind self-recognition soft credit, receipt handling, and reporting all key on it. Distinct from `PaymentMethod` (which may be In-Kind, Stock, or Asset for various non-cash channels) — this flag is the authoritative "treat as non-cash" signal.
  - **Description:** Deterministic gate — TRUE marks this transaction as non-cash. Load-bearing routing key across the Gift Entry launcher and Apex: drives the `OriginalAmount=0` / FMV-on-`FQS_Fair_Market_Value_Amount__c` convention, the auto-generated `GiftSoftCredit` with `Role='In-Kind Recognition'` pointing at the donor, record-page conditional visibility, and seed-data classification. Retained as a boolean instead of collapsed onto `PaymentMethod='In-Kind'` because PaymentMethod is a shared picklist (Stock, Asset, In-Kind, etc.) that carries no single deterministic "treat this as non-cash" signal — Stock and Asset gifts can be cash-equivalent or non-cash depending on liquidation, and users have latitude to key values inconsistently. This boolean is the org's authoritative in-kind flag.

- **GT.FQS_Fair_Market_Value_Amount__c** — currency, custom, `Fair Market Value Amount`
  - **Help:** Estimated fair market value of the donated goods or services. Used for the tax receipt and reporting only — the donor determines the actual tax-deductible value on their own return.
  - **Description:** For in-kind gifts the FQS convention is: `OriginalAmount = 0`, this field carries the estimate. Blank on non-in-kind gifts.

- **GT.FQS_Restriction_Release_Date__c** — date, custom, `Restriction Release Date`
  - **Help:** The date restricted funds from this payment become available for their designated purpose or for general use. Leave blank for gifts with no time restriction.
  - **Description:** Convention: one year past this transaction's date. On a payment against a commitment, defaults from the parent commitment but is independently writable. See [[seed-release-date-followup]].

- **GT.FQS_Skip_Naming__c** — boolean, custom, `Skip Auto-Naming`
  - **Help:** Check to prevent the FQS auto-naming flow from overwriting the Name on this Gift Transaction. Use for imports or integrations where the record already carries an authoritative external Name.

---

## Object: Gift Designation (`GiftDesignation`)

**FQS flexipage:** `FQS_GiftDesignation_Record_Page.flexipage-meta.xml`

### Fields with help text authored

#### Family: Status / lifecycle

##### `IsActive` — standard (FQS-authored)

- **Help:** Uncheck to retire this designation. Retired designations stay on historical gifts but won't appear when adding new gifts.
- **Description:** Controls availability on new `GiftTransactionDesignation` splits via the `GiftDesignationId` lookup filter. An active GD **cannot be deleted** — the platform raises "You can't delete an active designation." Teardown pattern is un-default (`IsDefault=false`) → deactivate (`IsActive=false`) → delete. Deactivation does NOT affect existing historical GTD rows.

##### `IsDefault` — standard (FQS-authored, load-bearing)

- **Help:** Check exactly ONE active designation as the org-wide default — usually the general operating fund. Gifts that arrive without an explicit designation split fall through to this bucket.
- **Description:** **Load-bearing.** The managed `frops_flow__ProcessGiftCommitment` aborts with "org wide default designation is not yet configured" if no active GD has `IsDefault=true`. FQS seed flags `FQS-GD-GENERAL-OPERATING` on install. Only one GD may be `IsDefault=true` at a time; the platform enforces uniqueness across active records. To retire the current default, promote a successor first.

#### Family: Categorization

##### `FQS_Restriction_Type__c` — custom, unrestricted picklist

- **Help:** How the donor restricted the funds. Without Donor Restriction: usable for any program (incl. board-designated). Purpose: must be spent on a specific use. Permanent: endowment principal — only earnings spendable. Earned Revenue: exchange-transaction revenue (fees, ticket sales), not a contribution. Time restrictions live on the gift (see Restriction Release Date on GC / GT).
- **Description:** Time restrictions are NOT represented here — record time boundaries on the gift's `FQS_Restriction_Release_Date__c` field on `GiftCommitment` or `GiftTransaction`. Mirrored via formula onto `GiftTransactionDesignation` and `GiftDefaultDesignation` for report-friendliness.

### Open follow-ups for GiftDesignation

- Confirm `Name` and `Description` field-meta shells exist and are picked up by the flexipage — currently empty XML skeletons.
- No off-flexipage material gaps per inventory — off-page fields are audit/platform only.
- The seven rollup families all trace to the same NPC-engine writer; if a future admin reports "counts stopped incrementing," the debugging pointer belongs in `docs/npc-automation-notes.md`.

---

## Object: Gift Transaction Designation (`GiftTransactionDesignation`)

**FQS flexipage:** `FQS_GiftTransactionDesignation_Record_Page.flexipage-meta.xml`

### Object-level `<description>`

> The per-gift split — one GTD row for every `GiftTransaction` × `GiftDesignation` pairing. A gift can be allocated across one or many designations; every GTD carries either an `Amount` or a `Percent` of the parent gift. Sits in the middle of the FQS gift-processing chain: **GiftCommitment → GiftCommitmentSchedule → GiftTransaction → GiftTransactionDesignation → GiftDesignation**. GTDs are typically written by (a) the managed `frops_flow__ProcessGiftCommitment` from `GiftDefaultDesignation` routing rules, (b) the FQS Gift Entry launcher when the user chooses "Split gift across designations", or (c) manually on the parent Gift Transaction's related list. `FQS_Restriction_Type__c` is a formula mirror of the parent GD — never write it directly.

### Fields with help text authored

#### Family: Amounts

##### `Amount` — standard

- **Description:** Populate for absolute-dollar splits (e.g., "$500 of a $2,000 gift to Scholarship, $1,500 to General"). Mutually exclusive with `Percent` at the row level. Sum of Amount across all sibling GTDs must equal the parent transaction's `OriginalAmount` — the platform does NOT enforce this.

##### `Percent` — standard

- **Description:** Percentage-based split — the platform derives an equivalent `Amount` from `GiftTransaction.OriginalAmount × Percent / 100`. Sum-to-100 across siblings is a reporting convention; the platform does NOT enforce it. `GiftDefaultDesignation` routing produces `Percent`-based GTDs by default.

### Open follow-ups for GiftTransactionDesignation

- Reconcile `FQS_Restriction_Type__c` off-flexipage status — surface on `FQS_GiftTransactionDesignation_Record_Page` or explicitly justify keeping it off.
- `FQS_Restriction_Release_Date__c` seed backfill deferred — will populate on multi-year installments once designations Phase D6 lands.
- Consider a lightweight validation rule (or Flow) enforcing Amount XOR Percent + sum-to-parent at insert/update.

---

# Supporting tier

## Object: Gift Default Designation (`GiftDefaultDesignation`)

**FQS flexipage:** `FQS_GiftDefaultDesignation_Record_Page.flexipage-meta.xml`

### Object-level `<description>`

> Routing rules that tell the managed `frops_flow__ProcessGiftCommitment` where to send an incoming gift when the donor didn't specify a designation split. Attaches a percentage-allocated set of `GiftDesignation`s to a **Campaign, `GiftCommitment`, or Opportunity** parent — `ParentRecordId` is polymorphic across those three sObject types ONLY. **Account is NOT valid** — attempting to seed an Account-parented GDD returns `INVALID_CROSS_REFERENCE_TYPE`. When multiple GDDs exist under one parent, `processGiftCommitment` creates one GTD per row on the resulting gift, splitting `GiftTransaction.OriginalAmount` by `AllocatedPercentage`.

### Fields with help text authored

#### Family: Amounts

##### `AllocatedPercentage` — standard

- **Description:** Consumed by `frops_flow__ProcessGiftCommitment`. Sum-to-100 across sibling GDDs is a reporting convention; **the platform does NOT enforce it** — a set summing to 90 will silently under-allocate 10% of every gift on that parent to the org-wide default GD.

#### Family: Categorization

##### `FQS_Parent_Type__c` — custom, formula

- **Description:** Formula on `ParentRecordId`'s key prefix. Returns "Gift Commitment" (`6gc`), "Opportunity" (`006`), "Campaign" (`701`), or blank if unset.

### Open follow-ups for GiftDefaultDesignation

- Reconcile `FQS_Restriction_Type__c` (off-flexipage) — surface-or-justify (mirrors GTD).
- `ParentRecordId` polymorphism is Campaign / GiftCommitment / Opportunity ONLY — Account is NOT valid. Consider a validation rule that pre-empts the `INVALID_CROSS_REFERENCE_TYPE` error at insert.
- No `IsDefault` field on GDD — winner-selection is via `AllocatedPercentage` sum, not a boolean flag.

---

## Object: Gift Soft Credit (`GiftSoftCredit`)

**FQS flexipage:** `FQS_GiftSoftCredit_Record_Page.flexipage-meta.xml`

### README post-install steps required

- **`GiftSoftCredit.Role`** — if the FQS deploy adds any picklist values beyond FundFirst's standard set, those additions do not survive an unmanaged-package install and MUST be added by hand in Setup.
- **`GiftSoftCredit.GenerationalCohort`** — same picklist-add caveat if FQS extends the cohort list.

### Fields with help text authored

#### Family: Categorization

##### `Role` — standard, unrestricted picklist

- **Help:** Why this party gets credit for a gift they didn't legally give — e.g., *Solicitor* moved the donor, *Household Member* is the donor's partner or family, *Matched Donor* is the matching employer, *Honoree* is the tribute recipient.
- **Description:** FundFirst ships an 8-value default set; FQS relies on the `In-Kind Recognition` value to auto-generate self-recognition soft credits on In-Kind gifts. If any FQS-added value is missing post-install, restore via Setup.

#### Family: Amounts

##### `SoftCreditAmount` — standard, system

- **Help:** Set automatically. The dollar amount credited to the recipient — computed from Partial Amount if you entered a dollar figure, or from Partial Percent applied to the parent Gift Transaction's Current Amount. Leave both Partial fields blank to soft-credit the full gift.
- **Description:** Platform-computed. Reads `PartialAmount` first, falls back to `PartialPercent × GiftTransaction.CurrentAmount`, and defaults to `GiftTransaction.CurrentAmount` when both are null. Reporting rolls this into donor recognition totals.

##### `PartialAmount` — standard

- **Help:** Optional. Enter a specific dollar amount to credit — use when the soft credit is only for part of the gift. Leave blank and set Partial Percent instead if the split is percentage-based.
- **Description:** Sibling to `PartialPercent`. Entering both is rejected by the platform. Blank on both fields = credit the full parent `GiftTransaction.CurrentAmount`.

##### `PartialPercent` — standard

- **Help:** Optional. Enter a percentage (0–100) of the parent gift to credit — use when household members or joint solicitors split recognition. Mutually exclusive with Partial Amount.
- **Description:** Sibling to `PartialAmount`. Applied against `GiftTransaction.CurrentAmount`, not `OriginalAmount` — refunds and adjustments shrink the soft-credited amount along with the underlying gift.

### Open follow-ups for GiftSoftCredit

- Confirm whether FQS's `Role` and `GenerationalCohort` picklist values differ from the shipped FundFirst set. Answer: `GenerationalCohort` is never desired.
- The recent `FQS_Gift_Entry_Soft_Credit_Reach` flow writes GSCs during Gift Entry — audit whether it sets `GenerationalCohort` from the recipient's Person Account attributes.
- `PartyPhilanthropicRsrchPrflId` remains off-flexipage; revisit when a philanthropic-research-profile capability lands.

---

## Object: Gift Default Soft Credit (`GiftDefaultSoftCredit`)

**FQS flexipage:** `FQS_GiftDefaultSoftCredit_Record_Page.flexipage-meta.xml`

### README post-install steps required

- **`GiftDefaultSoftCredit.Role`** — same standard unrestricted picklist as `GiftSoftCredit.Role`. If FQS extends it, additions do not survive an unmanaged-package install.

### Fields with help text authored

#### Family: Categorization

##### `Role` — standard, unrestricted picklist

- **Help:** The relationship this recipient has to the parent commitment or opportunity — copies onto every soft credit fanned out from this default.
- **Description:** Shares the value set with `GiftSoftCredit.Role`. Copies onto every child `GiftSoftCredit` at fan-out; editing on the default does not backfill previously-created GSCs.

#### Family: Amounts

##### `PartialAmount` — standard

- **Help:** Optional. Enter a fixed dollar amount to soft-credit on every transaction fanned out from the parent. Mutually exclusive with Partial Percent.
- **Description:** Sibling to `PartialPercent`. On a recurring commitment, a fixed `PartialAmount` produces the same soft-credit dollar figure on every installment even if installment amounts differ — usually `PartialPercent` is the intended choice.

##### `PartialPercent` — standard

- **Help:** Optional. Enter a percentage (0–100) of each transaction to soft-credit — the typical choice for household splits, joint-solicitor recognition, and matching-gift routing.
- **Description:** Sibling to `PartialAmount`. Applied against each fanned-out `GiftTransaction.CurrentAmount`, not `OriginalAmount`.

#### Family: Identity / naming

##### `FQS_Parent_Type__c` — accelerator-owned formula (off-flexipage — surface flag)

- **Description:** Formula, text. Reads the 3-character key prefix of `ParentRecordId` (`6gc` → Gift Commitment, `006` → Opportunity, else blank). Recommend adding to `Facet-fqs-gdsc-d-s1-left` in the Soft Credit Details section.

### Open follow-ups for GiftDefaultSoftCredit

- Reconcile `FQS_Parent_Type__c` (off-flexipage) — recommend surfacing.
- Confirm no picklist adds on `Role` vs the shipped FundFirst set.
- The v67 platform accepts only GC / Opportunity parents here (Account and Campaign rejected). Cross-reference with `GiftDefaultDesignation.ParentRecordId` (Campaign / GC / Opportunity).

---

## Object: Gift Tribute (`GiftTribute`)

**FQS flexipage:** `FQS_GiftTribute_Record_Page.flexipage-meta.xml`

### README post-install steps required

- `HonoreeContactId` — the FQS `.field-meta.xml` adds an active lookup filter restricting the honoree lookup to Person Accounts (`Account.IsPersonAccount = True`). Verify the filter is present in post-install checkout.

### Fields with help text authored

#### Family: Tribute categorization

##### `TributeType` — standard

- **Help:** Pick whether this tribute is In Honor Of (living recipient) or In Memory Of (deceased).
- **Description:** Unrestricted picklist. Standard values: `Honor`, `Memorial`.

##### `HonoreeContactId` — standard (README lookup filter)

- **Help:** The Person Account the tribute is for. Use this when the honoree already exists in FundFirst as a Person Account; fall back to Honoree Name for one-off honorees who don't need their own record.
- **Description:** Lookup to `Account` with an FQS-added lookup filter restricting selection to `IsPersonAccount = True`. When set, `HonoreeName` should mirror the Person Account's full name; FQS does not auto-sync.

##### `HonoreeName` — standard

- **Help:** Free-text name of the person being honored or remembered. Use this when the honoree isn't a Person Account or when the family requested the name appear differently on acknowledgment materials than in FundFirst.
- **Description:** Preferred over `HonoreeContactId` when you don't want to create a Person Account for a one-time tribute honoree.

#### Family: Notification recipient

##### `NotificationContactId` — standard

- **Help:** The Account (typically a Person Account — the family member or friend) who should receive the tribute acknowledgment letter or email. Leave blank if no notification is required.
- **Description:** Lookup to `Account`. Distinct from `HonoreeContactId`: the honoree is the person being honored; the notification contact is who gets told the gift was made.

##### `NotificationContactName` — standard

- **Help:** Free-text notification recipient name — use when the recipient isn't in FundFirst as an Account or when the name on the letter should differ from the linked record.
- **Description:** FQS does not auto-copy from `NotificationContactId`.

### Open follow-ups for GiftTribute

- Confirm the `HonoreeContactId` lookup filter survives round-tripping through an unmanaged package installer.
- Notification lifecycle currently relies on manual `NotificationStatus` updates. If a future phase adds a Marketing Cloud / SendGrid outbound integration, revisit help text on `NotificationDate` and `NotificationStatus`.

---

## Object: Gift Refund (`GiftRefund`)

**FQS flexipage:** `FQS_GiftRefund_Record_Page.flexipage-meta.xml`

### Fields with help text authored

#### Family: Amounts

##### `Amount` — standard

- **Help:** The refund amount in the gift's currency. Enter as a positive number — do not enter a negative. Partial refunds allowed; multiple refund records against one GT are allowed and cumulate.
- **Description:** Currency, unsigned. Cumulative refunds across sibling `GiftRefund` records should not exceed the parent `GiftTransaction.TransactionAmount` — FQS does not validate this today.

### Open follow-ups for GiftRefund

- **GT Status downgrade on full refund.** A future phase should either add a "Refunded" status write when cumulative refunds equal GT amount, or document the reporting pattern of filtering on `TransactionAmount - RefundedAmount > 0`.
- **Amount overflow validation.** Currently no guard against cumulative refunds exceeding the parent GT amount.
- **Gateway plumbing surfacing.** All four `LastGateway*` fields plus the two fee fields are surfaced on the FQS flexipage but are blank in the FQS starter. Consider a follow-up flexipage pass to move these into a collapsible section.

---

## Object: Outreach Source Code (`OutreachSourceCode`)

**FQS flexipage:** `FQS_OutreachSourceCode_Record_Page.flexipage-meta.xml`

### README post-install steps required

- None. FQS does not add a lookup filter to `OutreachSourceCode.CampaignId`; OSC is authored against the full campaign hierarchy so admins can bind a source code to a category branch.
- If a target org has narrowed `MessageChannel` or `UsageType` picklists via a managed value-set override, restore the full FundFirst set — post-install verify step.

### Fields with help text authored

#### Family: Identity & lifecycle

##### `Status` — standard, unrestricted picklist

- **Description:** Unrestricted picklist — FundFirst ships **Active**, **Inactive**, **Archived**. Reporting-only in FQS.

##### `UsageType` — standard, restricted picklist (FQS-customized)

- **Description:** Restricted picklist. Legal values: **Fundraising** (only value shipped by NPC today). When `UsageType = 'Fundraising'`, `CampaignId` is required or insert/update fails.

#### Family: Categorization — channel & platform

##### `MessageChannel` — standard, restricted picklist (FQS-customized)

- **Help:** Equivalent to *utm_medium* in web analytics.
- **Description:** Restricted picklist. Legal values: **Email**, **SMS**, **Direct Mail**, **Social Organic**, **Social Paid**, **Digital Paid**, **Organic Web**, **Physical**, **Share Partner**, **Telemarketing**. Drives the `FQS_Message_Channel_Segment__c` formula.

##### `FQS_Platform__c` — custom, unrestricted picklist

- **Help:** The specific platform or sender for this source code — equivalent to *utm_source* in web analytics.
- **Description:** Provides a standardized picklist of source values instead of relying on the free-text `MessageChannelPlatform` field. See the OSC record page notes for how Platform contributes to channel-level attribution even though it is not part of the SourceCode string.

##### `FQS_Message_Channel_Segment__c` — custom, formula

- **Help:** Set automatically. Rolls up Message Channel into three planning buckets — *Organic*, *Paid Digital*, or *Owned or Acquired Lists* — used by list views and channel-mix reports.
- **Description:** Formula field reading `MessageChannel`. Segments: **Organic** (Organic Web, Physical, Social Organic, Share Partner); **Paid Digital** (Digital Paid, Social Paid); **Owned or Acquired Lists** (Email, Direct Mail, SMS, Telemarketing). Not writable.

##### `MessageChannelPlatform` — standard

- **Description:** Free text (255). Distinct from the FQS-authored `FQS_Platform__c` picklist.

##### `MessageChannelPlatformAccount` — standard

- **Help:** The specific sender account on the platform — e.g., the email-sending domain, the ad account ID, or the social handle used for this tactic. Useful for reconciling gift attribution against platform-side reports.
- **Description:** Free text (255). No automation reads this; reporting-only.

#### Family: URL scaffold & content

##### `SourceCode` — standard (FQS-customized)

- **Help:** Managed by Outreach Source Code Generation in Setup. The Code Formula populates this field with the parent Campaign's Short Name followed by a random uniqueness suffix.
- **Description:** Managed by Outreach Source Code Generation in Setup.

##### `SourceCodeUrl` — standard, computed URL

- **Help:** The full attributed landing URL for this outreach tactic — combines the campaign's short name (utm_campaign), Message Channel (utm_medium), Platform (utm_source), and Source Code (utm_content). Copy this into the outreach email, ad, or post so gifts route back to the right tactic.
- **Description:** URL scaffold assembled by FQS from `SourceCodeBaseUrl` + the parent Campaign's `FQS_Short_Name__c` + `MessageChannel` + `FQS_Platform__c` + `SourceCode`. Recomputes when any input changes.

#### Family: Audience & timing

##### `AudienceCount` — standard

- **Help:** How many people this outreach was sent to — email list size, print quantity, ad-reach estimate. Required for `Response Rate` on the child Outreach Summary to compute.
- **Description:** Integer. Read by `OutreachSummary.ResponseRate` — `CEIL(DonorCount / AudienceCount × 100)`. Null `AudienceCount` yields null Response Rate.

### Open follow-ups for OutreachSourceCode

- **Surface `FQS_Message_Channel_Segment__c` and `FQS_Platform__c` on the flexipage** — currently off-page per off-flexipage inventory.
- **Uniqueness on `SourceCode`** — today it's not platform-enforced. Track whether an FQS validation rule should land.
- **Empty `SourceCodeBaseUrl` fallback** — either surface it or document a Setup path to populate it.

---

## Object: Campaign Member (`CampaignMember`)

**FQS flexipage:** none — platform default record page

### Fields with help text authored

#### Family: Status / lifecycle

##### `Status` — standard, unrestricted picklist (per-campaign)

- **Help:** Where this member sits in the campaign's response funnel — for example, *Sent* when the appeal was delivered, *Responded* when the member gave, RSVP'd, or attended. Available values differ per campaign.
- **Description:** Unrestricted picklist, but the *effective* legal values are configured per-Campaign. Default values across all campaigns: **Sent**, **Responded**. Moving a member into any responded status auto-writes `HasResponded = true` and `FirstRespondedDate`.

##### `HasResponded` — standard, boolean

- **Help:** Set automatically. Flipped to true the first time this member is moved into any of the campaign's "responded" statuses. Used by `Campaign.NumberOfResponses`.
- **Description:** Platform-managed once true, remains true even if the status is later moved back to a non-responded value.

##### `FirstRespondedDate` — standard

- **Help:** Set automatically. The first date this member entered a "responded" status on this campaign. Blank until the first response.
- **Description:** Written once by platform automation, on the first `HasResponded = false → true` transition. Not overwritten on subsequent status flips.

#### Family: Categorization

##### `Type` — standard, system-set string

- **Help:** Set automatically. Reflects whether this campaign member points to a Person Account or Contact (Contact) or a Lead (Lead).

### Open follow-ups for CampaignMember

- **Object `<description>` copy** — write once FQS decides whether CampaignMember is a primary constituent-to-campaign linkage or a secondary tool behind Gift Transaction's `CampaignId`.
- **Leaf-level lookup filter on `CampaignId`** — evaluate whether to add one for parity with GC / GT. Downside: breaks bulk-add utilities.
- **Person Account clarification** — walk through the "Person Account → underlying Contact → CampaignMember.ContactId" traversal explicitly in docs.
- **Per-campaign status ladders** — FQS should ship at least one or two sample Campaigns with non-default status ladders.

---

# Background tier

## Object: Outreach Summary (`OutreachSummary`)

**FQS flexipage:** `FQS_OutreachSummary_Record_Page.flexipage-meta.xml`

### Fields with help text authored

Background tier framing: every field on Outreach Summary is written by the platform's outreach-rollup engine on a schedule. **Do not hand-edit any field on this object.**

#### Family: Totals (currency rollups)

##### `TotalOnetimeGiftAmount` — standard, platform-rollup

- **Help:** Sum of paid gift transactions that do not have any gift commitment associated with them.
- **Description:** Set automatically. Filters to `GiftTransaction.GiftCommitmentId = null` (strict — the DPE does NOT include Custom-schedule payments here; see the schedule dead-zone note in the object follow-ups).

##### `TotalRecurringGiftAmount` — standard, platform-rollup

- **Help:** Sum of paid gift transactions associated with a gift commitment whose Schedule Type is "Recurring".

##### `AttributedAmount` — standard, platform-rollup

- **Help:** Total revenue credited to this campaign or outreach source code. Combines one-time cash gifts with the earned-to-date value of recurring pledges originated by this outreach.
- **Description:** Set automatically. Distinct from `TotalGiftTransactionAmount` — attribution here credits recurring pledges by *earned-to-date value*, not paid installments.

#### Family: Response

##### `ResponseRate` — standard, platform-rollup

- **Help:** Percentage of the outreach audience who made at least one paid gift. Calculated as `CEIL(DonorCount / AudienceCount × 100)`.
- **Description:** Set automatically. Reads `AudienceCount` from the related `OutreachSourceCode`(s). Null `AudienceCount` yields null Response Rate.

### Open follow-ups for OutreachSummary

- **Refresh cadence** — help text names the platform outreach-rollup engine as the writer but does not specify its cadence (real-time vs scheduled). Per `docs/dpe/OutreachSummary.dpe.json` the DPE runs on CRM Analytics in Batch mode; cadence is caller-scheduled.
- **Custom-schedule dead zone.** Per the archived DPE ([docs/dpe/OutreachSummary.dpe.json](../docs/dpe/OutreachSummary.dpe.json)): paid GTs whose parent `GC.ScheduleType='Custom'` enter `TotalGiftTransactionAmount` and `GiftCount` (via the `*_All` aggregates) but are excluded from BOTH `TotalOnetimeGiftAmount` (they have `GiftCommitmentId`) AND `TotalRecurringGiftAmount` (ScheduleType ≠ 'Recurring'). Therefore `Onetime + Recurring < TotalGiftTransactionAmount` whenever Custom-schedule payments exist. The `AttributedAmount` pipeline is separate and *does* credit Custom-schedule pledges via `GiftCmtChangeAttrLog.ChangePerDayAmount × days-active`.
- **Campaign vs OSC scope enforcement** — verify against seeded data that a row is *either* campaign-scoped *or* OSC-scoped.
- **`AttributedAmount` earned-to-date formula** — confirm the exact formula against NPC docs.
- **Data-quality report for missing `AudienceCount`** — either add the report in FQS or drop the reference from the description.

---

## Object: Gift Batch (`GiftBatch`)

**FQS flexipage:** none — platform default record page (populated by Gift Entry wizard, not hand-authored)

### Fields with help text authored

##### `DoesTotalGiftValueMatch` — standard

- **Description:** Written by the Gift Entry wizard. Compares aggregated `GiftTransaction.OriginalAmount` for the batch against `ExpectedValueofGiftsinBatch`. Investigate `FALSE` values before closing a batch.

### Open follow-ups for GiftBatch

- FQS starter does not yet exercise Gift Entry in bulk — verify `DoesTotalGiftValueMatch` behavior against a real posted batch.
- Confirm whether `Name` is truly free-text-only or whether the wizard enforces uniqueness.

---

## Object: Donor Gift Summary (`DonorGiftSummary`)

**FQS flexipage:** `FQS_DonorGiftSummary_Record_Page.flexipage-meta.xml` (widest-surfaced page in the accelerator)

### Fields with help text authored

#### Family: Largest gift

##### `BestGiftYear` — standard

- **Help:** Set automatically. The calendar year during which this donor gave the most.
- **Description:** Written by the NPC engine as a 4-digit year string ("2024"). Not fiscal-year-aware.

#### Family: Lifetime & rolling-period totals

##### `GiftsThisYearAmount` — standard

- **Help:** Set automatically. Dollar total of this donor's Paid gifts in the current calendar year.
- **Description:** Written by the NPC engine. Calendar-year windowed. Feeds the `FQS_Annual_Donor_Level*` formula fields.

##### `TotalPaidRcrInstallments` — standard

- **Help:** Set automatically. Lifetime count of Paid recurring-gift installments from this donor.
- **Description:** Written by the NPC engine. Excludes pledge installments.

##### `TotalPaidRcrInstlAmt` — standard

- **Help:** Set automatically. Lifetime dollar total of paid transactions against gift commitments whose Schedule Type is "Recurring".
- **Description:** Subset of `TotalGiftsAmount` filtered to recurring commitments (per `docs/dpe/DonorGiftSummary.dpe.json`: `Calculate_Recurring_Installments` groups on `Filter_on_isRecurring` where `ScheduleType Equals 'Recurring'` strictly — Custom-schedule payments excluded).

##### `BookedPledges` — standard

- **Help:** Set automatically. The Expected Total Commitment Amount across all of this donor's open pledges (not yet fully paid).
- **Description:** Written by the NPC engine as `SUM(GiftCommitment.ExpectedTotalCmtAmount)` across pledge-category GCs in Active / Failing / Paused status.

##### `TotalBookableRevenue` — standard

- **Help:** Set automatically. Sum of paid gifts plus outstanding pledge balances — the total revenue "booked" from this donor.
- **Description:** Written by the NPC engine. Combines `TotalGiftsAmount` plus the unpaid portion of open pledges.

##### `CurrentYearSoftCreditsAmount` — standard

- **Help:** Set automatically. Dollar total of soft credits attributed to this donor in the current calendar year.
- **Description:** Written by the NPC engine. Feeds the `FQS_Annual_Donor_Level*` formula fields when a tier's `Credit_Type__c = 'Hard + Soft Credits'`.

#### Family: Giving-level classifications

##### `GivingLevel` — standard, unrestricted picklist

- **Help:** Set automatically. The dollar band that classifies this donor's giving — one of the platform-defined levels from *Under $100* through *$25,000,000+*.
- **Description:** Unrestricted picklist written by the NPC engine. Ships with 15 levels. Distinct from the FQS Donor Grouping fields, which are org-branded (Entry / Mid / Major) and configured via `FQS_Donor_Grouping__mdt`.

##### `FQS_Annual_Donor_Level_Name__c` — custom, formula

- **Help:** Set automatically. The branded donor grouping name (e.g., Friend, Partner, Champion) for this donor based on current-year giving. Blank means the donor is below the Entry annual threshold. Your administrator controls both the thresholds and the branded names.
- **Description:** Text formula written on read from `GiftsThisYearAmount` (optionally combined with `CurrentYearSoftCreditsAmount` when a tier's `Credit_Type__c = 'Hard + Soft Credits'`) against the `FQS_Donor_Grouping__mdt` (Entry / Mid / Major) thresholds. Configure via Setup → Custom Metadata Types or the FQS Setup screen flow.

##### `FQS_Lifetime_Donor_Level_Name__c` — custom, formula

- **Help:** Set automatically. The branded lifetime donor grouping name for this donor based on total giving to date. Your administrator controls both the thresholds and the branded names.
- **Description:** Text formula written on read from `TotalGiftsAmount` (optionally combined with `TotalSoftCreditsAmount`) against the `FQS_Donor_Grouping__mdt` lifetime thresholds.

##### `FQS_Is_Entry_Annual_Donor__c` — custom, formula

- **Help:** Set automatically. Checked when this donor's current-year giving qualifies at the Entry annual tier.
- **Description:** Boolean formula reading `GiftsThisYearAmount` (+ `CurrentYearSoftCreditsAmount` if the tier's `Credit_Type__c` includes soft) against the `Entry` row of `FQS_Donor_Grouping__mdt`.

##### `FQS_Is_Mid_Annual_Donor__c` — custom, formula

- **Help:** Set automatically. Checked when this donor's current-year giving qualifies at the Mid annual tier.
- **Description:** Boolean formula reading `GiftsThisYearAmount` (+ `CurrentYearSoftCreditsAmount` if applicable) against the `Mid` row of `FQS_Donor_Grouping__mdt`.

##### `FQS_Is_Major_Annual_Donor__c` — custom, formula

- **Help:** Set automatically. Checked when this donor's current-year giving qualifies at the Major annual tier.
- **Description:** Boolean formula reading `GiftsThisYearAmount` (+ `CurrentYearSoftCreditsAmount` if applicable) against the `Major` row of `FQS_Donor_Grouping__mdt`.

##### `FQS_Is_Entry_Lifetime_Donor__c` — custom, formula

- **Help:** Set automatically. Checked when this donor's lifetime giving qualifies at the Entry lifetime tier.
- **Description:** Boolean formula reading `TotalGiftsAmount` (+ `TotalSoftCreditsAmount` if applicable) against the `Entry` row of `FQS_Donor_Grouping__mdt` lifetime thresholds.

##### `FQS_Is_Mid_Lifetime_Donor__c` — custom, formula

- **Help:** Set automatically. Checked when this donor's lifetime giving qualifies at the Mid lifetime tier.
- **Description:** Boolean formula against the `Mid` row of `FQS_Donor_Grouping__mdt` lifetime thresholds.

##### `FQS_Is_Major_Lifetime_Donor__c` — custom, formula

- **Help:** Set automatically. Checked when this donor's lifetime giving qualifies at the Major lifetime tier.
- **Description:** Boolean formula against the `Major` row of `FQS_Donor_Grouping__mdt` lifetime thresholds.

#### Family: Recency & retention

##### `RecencyScore` — standard

- **Help:** Set automatically. RFM recency component (1–5). Higher = more recently giving.
- **Description:** Written by the NPC engine as the R in RFM.

##### `FrequencyScore` — standard

- **Help:** Set automatically. RFM frequency component (1–5). Higher = more frequent giving.
- **Description:** Written by the NPC engine as the F in RFM.

##### `MonetaryScore` — standard

- **Help:** Set automatically. RFM monetary component (1–5). Higher = larger lifetime giving.
- **Description:** Written by the NPC engine as the M in RFM.

##### `CompositeRfmScore` — standard

- **Help:** Set automatically. Composite RFM score combining recency, frequency, and monetary components — used for donor segmentation.
- **Description:** Written by the NPC engine. Segmentation banding conventions are platform-defined.

### Open follow-ups for DonorGiftSummary

- Reconcile `LastTwoYearSoftCreditCount` (off-flexipage) — surface-or-justify (soft-credit parity to the on-flex `LastTwoYearGiftCount`).
- Confirm the 4 `FQS_Legacy_*` fields are safe to remove from the flexipage post-migration.
- Verify calendar-vs-fiscal semantics on all current-year / last-year / two-years-ago / best-gift-year rollups against a seeded org.
- Confirm RFM component-score banding semantics from the Nonprofit Cloud Developer Guide.

---

## Open follow-ups (cross-object)

- Calendar vs. fiscal semantics on `GC.TotalCurrentMonth/Quarter/Year/NextYear` — verify against a seeded org before final copy.
- `GT.GenerationalCohort` off-flexipage — surface only if generational segmentation is in use; deferred with the wealth-screening capability.
- **Dead-field references (2026-08-16):** two GT descriptions in this doc reference fields that have been destructively deleted from the schema and need a rewrite in the next help-text pass:
  - Line 59 (GT customized-field roster) still lists `FQS_Matched__c` and `FQS_Processed_Date__c` — both retired.
  - Line 420 (`GT.TransactionDate` description) says *"Distinct from `FQS_Processed_Date__c` (when the org entered the gift)"*. `FQS_Processed_Date__c` no longer exists; `CreatedDate` (the prior wording) is technically the audit field but the *semantic* distinction the sentence tried to draw — *what the donor did* vs. *when Salesforce learned about it* — needs a live-schema rephrase (there is no dedicated FQS field for the latter anymore).
  - Line 441 (`GT.GiftType` description) says *"Individual AND `FQS_Matched__c = TRUE`"*. Live gate is `FQS_Match_Status__c = 'Received'`.
- **Corresponding metadata state:** the retrieve pulled the same dead-field wording into `objects/GiftTransaction/fields/TransactionDate.field-meta.xml` and `.../GiftType.field-meta.xml`. `GiftType.field-meta.xml` was reverted to the prior `FQS_Match_Status__c` wording; `TransactionDate.field-meta.xml` is held un-reverted pending the help-text rewrite.

## Next steps

1. **Reconcile 15 off-flexipage `FQS_*` gaps** identified as "surface-or-justify" open follow-ups across Account (4 matching-gift fields), Campaign (3 hierarchy fields), Opportunity (`FQS_Skip_Naming__c`), GiftTransactionDesignation (`FQS_Restriction_Type__c`), GiftDefaultDesignation (`FQS_Restriction_Type__c`), GiftDefaultSoftCredit (`FQS_Parent_Type__c`), and OutreachSourceCode (`FQS_Message_Channel_Segment__c` + `FQS_Platform__c`).
2. **Audit shipped Campaign page layout** — `force:detailPanel` visibility gate for the 5 FQS custom fields.
3. **Emit metadata edits** — add `<inlineHelpText>` and `<description>` in each field's `.field-meta.xml`. Create files for standard fields not yet customized.
4. **Emit README post-install steps** for the standard-field customizations that don't survive unmanaged install (Opportunity `Type` + `StageName` picklist adds, `Opportunity.CampaignId` lookup filter, `GiftTribute.HonoreeContactId` lookup filter, `GC.CampaignId` + `GT.CampaignId` lookup filters, FundraisingConfig Setup pointer).
5. **Deploy in Foundation + FundFirst sandboxes** and hard-refresh flexipages to confirm help text renders.
6. Extract `sf-help-text-author` skill and fan out to the objects deferred in this pass (ActionPlan, GiftCmtChangeAttrLog, FundraisingConfig).
