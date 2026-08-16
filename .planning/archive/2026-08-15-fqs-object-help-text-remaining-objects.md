# FQS — Object Help Text (Remaining Objects)

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst` sandbox
**Companion to:** `.planning/fqs-object-help-text-plan.md`, `.planning/fqs-off-flexipage-inventory.md`, and `.planning/fqs-object-help-text-gc-gcs-gt.md` (the worked example on GC/GCS/GT that this file models its shape after)
**Scope:** All FQS in-scope objects EXCEPT GiftCommitment / GiftCommitmentSchedule / GiftTransaction (covered separately). Authored via `sf-help-text-author` skill, fanned out across 10 parallel subagents on 2026-08-02.

## Coverage summary

| Tier | Object | Total fields | Recommended | New `.field-meta.xml` needed |
|---|---|---:|---:|---:|
| Key | Account | 91 | 36 | 31 |
| Key | Campaign | 46 | 22 | 17 |
| Key | Opportunity | 48 | 18 | 0 |
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
| **Total (this file)** | **18 objects** | **590** | **276** | **211** |
| Prior file (GC/GCS/GT) | 3 objects | 152 | 91 | 43 |
| **Grand total** | **21 objects** | **742** | **367** | **254** |

**Ratio:** 367 / 742 ≈ **49%** of fields earn help text across all 21 in-scope FQS objects. The ~51% skipped is the deliberate-skip surface (audit, self-descriptive rollups, gateway plumbing, `External_Id__c` convention, snapshot fields projected from parent objects).

---

## Object: Account (`Account`) — Key tier

**FQS flexipage:** `FQS_Account_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 91
**Fields recommended for help text:** 36
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 31

### README post-install steps required
- **Enable Person Accounts** on the org before installing FQS. The flexipage's Person Account tabs, the `IsPersonAccount` visibility filters, and every `Person*` field this help-text pack covers assume Person Accounts are turned on. Salesforce does not allow this to be reverted — decide before install.
- **Add a validation rule** preventing `FQS_Matching_Gift_Program__c` and `FQS_Is_Match_Intermediary__c` from both being TRUE on the same Account. Mutual exclusivity is stated in field descriptions but not enforced.
- **No standard-label renames.** FQS ships `<inlineHelpText>` + `<description>` on standard Account fields; unmanaged install carries those. Label renames, lookup filters, and picklist value additions are not shipped — none are required for Account.
- **Custom Address compound help text does NOT deploy.** `BillingAddress` / `ShippingAddress` / `PersonMailingAddress` / `PersonOtherAddress` are platform-composite fields with no `.field-meta.xml`. Author copy on the visible **Street** subfield of each compound as a workaround, or accept that the compound renders without a tooltip.

### Fields deliberately skipped
- `Id`, `IsDeleted`, `MasterRecordId`, `SystemModstamp`, `CreatedDate`, `CreatedById`, `LastModifiedDate`, `LastModifiedById`, `LastActivityDate`, `LastViewedDate`, `LastReferencedDate` — audit/platform, platform labels suffice.
- `OwnerId` — platform-labeled.
- `Fax` — user-entered, API name is a sentence, no automation.
- `Salutation` — unrestricted picklist, values visible in dropdown, no FQS-specific meaning beyond the standard label.
- `AccountSource`, `PersonLeadSource` — off-flexipage source/lead-attribution fields; FQS uses `OutreachSourceCode` on the gift instead.
- `SicDesc`, `Jigsaw`, `JigsawCompanyId`, `PhotoUrl`, `SourceSystemIdentifier`, `PersonContactId`, `PersonIndividualId` — integration plumbing and platform-managed pointers.
- `PersonAssistantName`, `PersonAssistantPhone` — self-descriptive user-entered.
- `PersonLastCURequestDate`, `PersonLastCUUpdateDate` — Salesforce Data.com Clean plumbing; FQS does not use Clean.
- `PersonEmailBouncedReason`, `PersonEmailBouncedDate` — platform-written on bounce; self-descriptive.
- Address subfields (32 fields) — covered by their parent compound-address help text.

### Fields with help text authored

#### Family: Identity & naming

##### `Name` — standard
- **Help:** Business Accounts: the organization's legal or common name. Person Accounts: read-only — the platform assembles it from First Name + Last Name.
- **Description:** On Business Accounts this is a required user-entered string. On Person Accounts it is platform-assembled from `FirstName` + `LastName` and cannot be written directly. Distinguish via `IsPersonAccount`.

##### `FirstName` — standard (Person Account only)
- **Help:** The individual donor's given name. Populates only on Person Account records — leave blank on Business/Organization Accounts.
- **Description:** Only writable when `IsPersonAccount = TRUE`. Combines with `LastName` to build the platform-managed `Name`.

##### `LastName` — standard (Person Account only)
- **Help:** The individual donor's family name. Required on Person Account records; leave blank on Business/Organization Accounts.
- **Description:** Required when `IsPersonAccount = TRUE`. Ignored on Business Accounts.

##### `RecordTypeId` — standard
- **Help:** Selects whether this Account is an **Organization** (business, foundation, corporate donor) or a **Person Account** (individual donor). FundFirst does not use the platform's Household or Group record types — households are modeled through Account hierarchy via Parent Account.
- **Description:** FundFirst ships **Organization** and **Person Account** record types only — no Household record type. Household grouping is handled via `ParentId`. The FQS Gift Entry launcher branches on `IsPersonAccount` derived from this.

##### `IsPersonAccount` — standard, platform-managed
- **Help:** Set automatically. TRUE when this Account is a Person Account (individual donor); FALSE for Organization Accounts. Determined by Record Type at insert and cannot be changed after creation.
- **Description:** Platform-managed boolean derived from `RecordTypeId`. Immutable after insert. Drives visibility filters on `FQS_Account_Record_Page` and branch logic in the FQS Gift Entry launcher.

##### `ParentId` — standard
- **Help:** The household or parent organization this Account rolls up to. On Person Accounts, use to link individuals to a household Account. On Organization Accounts, use for corporate hierarchy.
- **Description:** Self-referential Account lookup. FundFirst uses this for household grouping and corporate hierarchy. Roll-up summaries against the parent aren't shipped by FQS.

#### Family: Categorization (Organization-side)

##### `Type` — standard, unrestricted picklist
- **Help:** Classifies the Account's relationship to your organization. On Organization Accounts, use to distinguish corporate donors from foundations, government funders, and other institutional relationships.
- **Description:** Unrestricted picklist. Salesforce-shipped values include: Analyst, Competitor, Customer, Integrator, Investor, Partner, Press, Prospect, Reseller, Other. FQS does not ship fundraising-specific values (Corporate, Foundation, Government) — extend in Object Manager. No FQS automation branches on this field.

##### `Industry` — standard, unrestricted picklist
- **Help:** The Organization Account's business sector. Useful for corporate donor segmentation and matching-gift program research.
- **Description:** Unrestricted picklist. Salesforce ships 32 default values. Extend in Object Manager. No FQS automation branches on this field — reporting-only.

##### `AnnualRevenue` — standard
- **Help:** Estimated annual revenue for this Organization Account. Useful for corporate donor prospecting and cultivation prioritization.
- **Description:** Currency, manual entry. No FQS automation reads or writes this. Distinct from lifetime giving totals — those live on `DonorGiftSummary`.

##### `NumberOfEmployees` — standard
- **Help:** Approximate employee headcount for this Organization Account. Useful for sizing corporate matching-gift potential and cultivation strategy.
- **Description:** Integer, manual entry. No FQS automation reads or writes this.

#### Family: Addresses

##### `BillingAddress` — standard, compound
- **Help:** On Organization Accounts, the primary mailing address. On Person Accounts, generally not used — donor mail goes to Person Mailing Address instead. FQS reports and receipting use Person Mailing on individual donors and Billing on organizational donors.
- **Description:** Standard compound address. FQS convention: Business Accounts use `BillingAddress`; Person Accounts use `PersonMailingAddress`. Receipting flows branch on `IsPersonAccount`.

##### `ShippingAddress` — standard, compound
- **Help:** Secondary address for the Organization Account — typically physical/office location distinct from a billing PO Box. Off the FQS flexipage by default.
- **Description:** Off-flexipage in `FQS_Account_Record_Page`. No FQS automation reads this.

##### `PersonMailingAddress` — standard, compound (Person Account only)
- **Help:** The individual donor's primary mailing address. Used by FQS receipting and acknowledgement flows to render tax receipts and thank-you letters.
- **Description:** Standard compound address on Person Account. FQS receipting and acknowledgement flows read this when `IsPersonAccount = TRUE`.

##### `PersonOtherAddress` — standard, compound (Person Account only)
- **Help:** Secondary address for the individual donor — seasonal residence, work address, or historical address. Off the FQS flexipage by default.
- **Description:** Off-flexipage in `FQS_Account_Record_Page`. No FQS automation reads this.

#### Family: Contact channels

##### `Phone` — standard
- **Help:** Main phone number. On Organization Accounts, the primary reception or development-office line. On Person Accounts, the individual's main phone — Person-specific alternatives live in Person Mobile Phone / Person Home Phone / Person Other Phone.
- **Description:** Text. Standard Salesforce phone field — no format validation. FQS does not automate outbound calling.

##### `Website` — standard
- **Help:** The Organization Account's public website. Useful for corporate matching-gift research. Rarely populated on Person Accounts.
- **Description:** URL. No FQS automation reads this — reference and reporting only.

##### `PersonEmail` — standard (Person Account only)
- **Help:** The individual donor's primary email address. Used by FQS acknowledgement and stewardship flows to deliver thank-you emails and follow-up touches. Set `PersonHasOptedOutOfEmail` when the donor asks to be removed.
- **Description:** Email. Read by `FQS_Gift_Acknowledgement` and `FQS_Stewardship_Response` flows. Flows skip when `PersonHasOptedOutOfEmail = TRUE`. Bounce state lives on `PersonEmailBouncedDate` / `PersonEmailBouncedReason` (platform-written).

##### `PersonMobilePhone` — standard (Person Account only)
- **Help:** The individual donor's mobile phone number. Distinct from Phone, which is the main/default number.
- **Description:** Text. No FQS automation reads this.

##### `PersonHomePhone` — standard (Person Account only)
- **Help:** The individual donor's home phone number.
- **Description:** Text. No FQS automation reads this. Respect `PersonDoNotCall` before outbound calling.

##### `PersonOtherPhone` — standard (Person Account only)
- **Help:** Additional phone number for the individual donor — work-direct, alternate line, or emergency contact number.
- **Description:** Text. No FQS automation reads this.

#### Family: Person Account demographic subfields

##### `PersonBirthdate` — standard (Person Account only)
- **Help:** The individual donor's date of birth. Used for age-based cultivation (planned-giving prospecting, birthday touches). Store the full date when known; leave blank rather than guessing.
- **Description:** Date. No FQS automation reads this in the starter. Data-privacy note: birthdate is often classified as sensitive PII; consider field-level security and audit-trail policies for your org.

##### `PersonMaritalStatus` — standard, unrestricted picklist (Person Account only)
- **Help:** The individual donor's marital status. Useful for household grouping decisions and joint-gift receipting conventions.
- **Description:** Unrestricted picklist. Salesforce-shipped values: Married, Single, Divorced, Widowed, Separated. Extend in Object Manager if your org tracks additional statuses. No FQS automation branches on this field.

##### `PersonGenderIdentity` — standard (Person Account only)
- **Help:** How the individual donor self-identifies their gender. Free-text — enter the donor's stated identity verbatim.
- **Description:** Text. FQS does not enumerate gender identity values — the field is authored as free-text to honor donor self-identification. Pair with `PersonPronouns` for correspondence.

##### `PersonPronouns` — standard (Person Account only)
- **Help:** The donor's stated pronouns (e.g., she/her, he/him, they/them). Used in correspondence templates that reference the donor by pronoun rather than by name.
- **Description:** Text. FQS acknowledgement / stewardship email templates can merge this field for pronoun-aware correspondence. Blank means the template falls back to the donor's Name.

##### `PersonTitle` — standard (Person Account only)
- **Help:** The individual donor's job title. Useful for corporate cultivation and matching-gift eligibility research.
- **Description:** Text. No FQS automation reads this.

##### `PersonDepartment` — standard (Person Account only)
- **Help:** The individual donor's department at their employer.
- **Description:** Text. No FQS automation reads this.

#### Family: Consent & opt-out

##### `PersonHasOptedOutOfEmail` — standard (Person Account only)
- **Help:** Check when the donor has asked to be removed from email communication. The FQS Gift Acknowledgement and Stewardship flows skip donors with this flag set.
- **Description:** Boolean. Read by `FQS_Gift_Acknowledgement` and `FQS_Stewardship_Response` flows — both skip records where this is TRUE. Does not suppress mail acknowledgements or tax receipts.

##### `PersonDoNotCall` — standard (Person Account only)
- **Help:** Check when the donor has asked not to be called. FQS does not automate outbound calling — this flag is honored by reports and dialer integrations only.
- **Description:** Boolean. FQS does not consume this in flow automation. Reporting and third-party dialer integrations should filter on it.

#### Family: Matching-gift capability (surface-or-justify open follow-ups)

The four fields below are OFF the FQS Account flexipage per `.planning/fqs-off-flexipage-inventory.md` — surface them or explicitly justify hiding. Help text is authored regardless because Object Manager and Setup surface these to admins.

##### `FQS_Matching_Gift_Program__c` — custom
- **Help:** Check when this business Account offers an employer matching gift program. Do not check for matching-gift intermediaries such as Benevity or YourCause — use FQS Is Match Intermediary for those.
- **Description:** Marks this business Account as running an employer matching gift program. Used by the FQS Find Matching Gift screen flow to filter Account lookups, boost candidate scores, and detect drift. Mutually exclusive with `FQS_Is_Match_Intermediary__c` — add a validation rule preventing both being TRUE on the same Account (see README).

##### `FQS_Is_Match_Intermediary__c` — custom
- **Help:** Check when this Account is a matching-gift intermediary (Benevity, YourCause, Bright Funds, CyberGrants, etc.) rather than a true corporate donor.
- **Description:** Marks this Account as a matching-gift intermediary. When the FQS Find Matching Gift flow launches from a Gift Transaction where the `DonorId` Account has this flag set, the flow prompts the user to identify the true corporate Account, creates or reuses a Gift Commitment on that corporate, and soft-credits the corporate on the intermediary's transaction. Mutually exclusive with `FQS_Matching_Gift_Program__c`.

##### `FQS_Match_Ratio__c` — custom
- **Help:** The dollar ratio this employer matches at. Enter 1.00 for 1:1 matching (default), 2.00 for 2:1, 0.50 for half-match, etc. Leave blank to use 1.00.
- **Description:** Multiplier applied to an individual's `OriginalAmount` when comparing to a corporate match. Used by the FQS Find Matching Gift flow's amount scorer.

##### `FQS_Match_Annual_Individual_Maximum__c` — custom
- **Help:** Maximum dollar amount this employer will match per individual per calendar year. Leave blank if the employer has no per-donor cap.
- **Description:** Per-individual annual cap on match dollars from this employer. The FQS Find Matching Gift flow sums matched amounts already recorded this calendar year for the individual and excludes candidates that would push the individual over this cap.

#### Family: Free text

##### `Description` — standard
- **Help:** Free-text notes about this Account — donor background, cultivation history, stewardship context, or anything a fundraiser landing on this record should know. Not used by any automation.

#### Family: External identifier

##### `External_Id__c` — custom (off-flexipage-by-convention)
- **Help:** External identifier used by FQS seed scripts for idempotent upserts and teardown. Not required for real donor Accounts.
- **Description:** Pattern used by seed scripts: `FQS-<OBJ>-<idx>[-<subidx>]`. Unique + External ID at the platform level on Account. Blank on real donor records; populated only on seeded data.

### Open follow-ups for Account
- **Surface-or-justify the 4 matching-gift `FQS_*` fields.** The whole matching-gift capability is off-page on the shipped `FQS_Account_Record_Page`.
- **Validation rule for `FQS_Matching_Gift_Program__c` XOR `FQS_Is_Match_Intermediary__c`** — descriptions state mutual exclusivity but nothing enforces it.
- **`Type` extension for fundraising vocabulary** — consider shipping a documented recommendation to add Corporate / Foundation / Government values as README guidance.
- **`AccountSource` and `PersonLeadSource`** — deferred until a source-attribution capability lands.
- **`ShippingAddress` / `PersonOtherAddress`** — surface-or-justify pending. Document as a page-layout customization pointer in the README.
- **PII posture on `PersonBirthdate`, demographic subfields, and `PersonEmail` bounce fields** — consider shipping tightened field-level security or a recommended tightening in the README.

---

## Object: Campaign (`Campaign`) — Key tier

**FQS record page:** `FQS_Campaign_Record_Page.flexipage-meta.xml` (uses `force:detailPanel` — field visibility is page-layout-driven, not flexipage-driven)
**Fields on object (FundFirst v67):** 46
**Fields recommended for help text:** 22 (5 custom FQS + 17 standard)
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 17

### README post-install steps required
- **Confirm Campaign page layout surfaces the 5 FQS custom fields.** `force:detailPanel` renders whatever page layout is assigned to the running user's profile — help text on `FQS_Campaign_Category__c`, `FQS_Short_Name__c`, `FQS_Child_Campaign_Count__c`, `FQS_Hierarchy_Depth__c`, and `FQS_Ultimate_Parent_Campaign__c` only appears if the field is on that layout. Unmanaged install won't touch the customer's existing Campaign page layout.
- **(Optional)** Extend `Type` picklist with fundraising-native values (Grant, Event, Appeal, Recurring Gift Program, Peer-to-Peer, Planned Giving, Major Gift) via Object Manager. Picklist is unrestricted and stock Salesforce values remain — extension is customer-owned, not FQS-shipped.
- **(Optional)** Extend `Status` picklist beyond stock Planned / In Progress / Completed / Aborted if the fundraising team needs pre-launch or post-close granularity.

### Fields deliberately skipped
- `Id`, `IsDeleted`, `SystemModstamp`, `CreatedDate`, `CreatedById`, `LastModifiedDate`, `LastModifiedById`, `OwnerId`, `LastActivityDate`, `LastViewedDate`, `LastReferencedDate` — audit / platform-labeled.
- `Name` — self-descriptive user-set text; no FQS auto-naming on Campaign.
- `RecordTypeId` — platform-labeled.
- `NumberSent`, `ExpectedResponse`, `NumberOfLeads`, `NumberOfConvertedLeads` — marketing-legacy Lead-centric fields; no fundraising automation reads them.
- `NumberOfContacts`, `NumberOfResponses`, `NumberOfOpportunities`, `NumberOfWonOpportunities`, `AmountAllOpportunities`, `AmountWonOpportunities` — self-descriptive rollups.
- `External_Id__c` — accelerator-wide convention.

### Fields with help text authored

#### Family: Identity & hierarchy

##### `ParentId` — standard
- **Help:** The parent campaign that this campaign rolls up to. Use to build a fundraising campaign hierarchy — e.g., a top-level fiscal-year campaign with Annual Giving, Events, and Grants as child categories.
- **Description:** Standard self-lookup. Formula fields `FQS_Hierarchy_Depth__c` and `FQS_Ultimate_Parent_Campaign__c` walk this chain up to 5 levels. `FQS_Child_Campaign_Count__c` is maintained by the FQS_Campaign_Child_Count_Update / _Delete record-triggered flows. Lookup filters on `GC.CampaignId` and `GT.CampaignId` (leaf-only, from OTHER objects) rely on this hierarchy.

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
- **Help:** Set automatically. Count of direct child campaigns (immediate children only — grand-children are counted by their own parent). Zero means this is a leaf-level campaign eligible for gift attribution.
- **Description:** Maintained by FQS_Campaign_Child_Count_Update (after-save) and FQS_Campaign_Child_Count_Delete (before-delete) record-triggered flows. Not a rollup summary. If this stops updating, check the flows are active in Setup → Flows.

##### `CampaignMemberRecordTypeId` — standard
- **Help:** The Campaign Member record type used by default when adding new members to this campaign. Leave blank if your org uses a single member record type.
- **Description:** Only used when Campaign Member has record types enabled. Off the FQS flexipage by default.

#### Family: Categorization

##### `FQS_Campaign_Category__c` — custom, restricted picklist
- **Help:** Classifies the fundraising purpose of this campaign. Drives list-view segmentation on the Campaigns tab and controls related-list visibility on the Campaign record page. Set on both parent and leaf campaigns so filters work top-down.
- **Description:** Restricted picklist. Legal values: **Fundraising Top Level Campaign**, **Annual Giving**, **Events**, **Corporate Match**, **In-Kind**, **Major Gifts**, **Planned Giving**, **Grants**. Read as a flexipage visibility filter on `FQS_Campaign_Record_Page` — the only field on Campaign referenced directly in flexipage XML; everything else on Campaign is page-layout-driven.

##### `Type` — standard, unrestricted picklist
- **Help:** The mechanism used to reach donors — e.g., Email for an email appeal, Seminar / Conference for an event campaign. For fundraising-native categorization, use `FQS_Campaign_Category__c` instead.
- **Description:** Unrestricted stock Salesforce picklist. Stock values skew marketing rather than fundraising. Extend via Object Manager to add fundraising-native values (Grant, Event, Appeal, Recurring Gift Program, Peer-to-Peer, Planned Giving, Major Gift) — FQS ships stock values only.

##### `Status` — standard, unrestricted picklist
- **Help:** Where this campaign is in its lifecycle. Choose *Planned* while designing and before launch, *In Progress* while accepting gifts, *Completed* after final gifts have posted, *Aborted* if the campaign was canceled before launch.
- **Description:** Unrestricted stock Salesforce picklist. Legal stock values: **Planned**, **In Progress**, **Completed**, **Aborted**. Does not automatically toggle `IsActive` — set both fields when moving a campaign off the "actively receiving gifts" list.

##### `IsActive` — standard
- **Help:** Whether this campaign is currently receiving gifts. Uncheck when a campaign is complete or aborted so it drops out of active-campaign list views and lookup pickers on Gift Commitment and Gift Transaction.
- **Description:** Read by the leaf-only lookup filter on `GC.CampaignId` and `GT.CampaignId` — inactive campaigns are filtered out of gift-attribution lookups even if they're still leaf-level.

#### Family: Timing

##### `StartDate` — standard
- **Help:** The date this campaign begins accepting gifts. Used for time-boxed reporting.
- **Description:** No platform enforcement — a gift can attribute to a campaign whose StartDate is in the future. Use for campaign-level "days remaining" reports and hierarchy timelines.

##### `EndDate` — standard
- **Help:** The date this campaign stops accepting gifts. Use to time-box multi-year and fiscal-year campaigns; leave blank for open-ended stewardship or evergreen giving programs.
- **Description:** No platform enforcement — gifts can attribute after this date. When a campaign passes EndDate, admins typically flip `Status → Completed` and `IsActive → false`; none of this is automated.

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

#### Family: Rollups (hierarchy)

##### `HierarchyNumberOfContacts` / `HierarchyNumberOfResponses` / `HierarchyNumberSent` — standard, system
- **Help:** Set automatically. Same as the corresponding non-Hierarchy field, but rolled up from this campaign PLUS all campaigns beneath it in the hierarchy.
- **Description:** Platform-maintained rollups walking `ParentId` down. Not fiscal-calendar-aware.

##### `HierarchyExpectedRevenue` / `HierarchyBudgetedCost` / `HierarchyActualCost` — standard, system
- **Help:** Set automatically. Rolls up the corresponding non-Hierarchy field from this campaign PLUS every child, grandchild, etc. Use on parent / top-level campaigns for whole-tree budget and forecast views.
- **Description:** Platform-maintained hierarchy rollups. Aggregates only the Campaign-object financial fields — does NOT include actual gift totals from `GiftTransaction`. For gift-total rollups by campaign, use a report grouped by `Campaign.Name` (with hierarchy grouping enabled).

#### Family: Free text

##### `Description` — standard (free text)
- **Help:** Free-text narrative about this campaign — goals, target audience, key dates, stewardship strategy, or anything a fundraiser landing on this record should know. Not used by any automation.

### Open follow-ups for Campaign
- **Audit the shipped Campaign page layout** to confirm all 5 FQS custom fields are surfaced. `force:detailPanel` picks up whatever layout is assigned to the running user's profile.
- **Decide whether FQS ships a Campaign page layout** or defers to the customer's existing layout.
- **Type / Status picklist extension guidance** — decide whether to ship extended picklist values or leave as README-optional customer extension.
- **Cross-object lookup-filter README consolidation** — leaf-only lookup filters on `GC.CampaignId` and `GT.CampaignId` are documented in the GC / GT help-text pass; ensure the Campaign-side rationale is captured in a single README section.

---

## Object: Opportunity (`Opportunity`) — Key tier

**FQS flexipage:** `FQS_Opportunity_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 48
**Fields recommended for help text:** 18
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 0 (all surfaced standard fields already have FQS-owned stubs in the repo)

### README post-install steps required
- `Opportunity.CampaignId` lookup filter (leaf-level campaigns only, matching GC / GT convention) — unmanaged packages don't carry lookup filters
- `Opportunity.Type` picklist extension — add fundraising-oriented values (`Grant`, `Major Gift`, `Planned Gift`, `Other`) to replace the stock `Existing Business` / `New Business` pair; the FQS launcher and Gift Entry Opportunity branch assume these values exist
- `Opportunity.StageName` picklist — FundFirst adds fundraising stages (`Identification`, `Cultivation`, `Solicitation`, `Verbal Commitment`, `Pledged`, `LOI Submitted`, `Proposal Submitted`, `Under Review`, `Awarded`, `Declined`). If installing FQS onto a base Sales Cloud org without FundFirst, README must document adding these stages before the Opportunity path is usable.

### Fields deliberately skipped
- **Audit / platform:** `OwnerId`, `CreatedById`, `CreatedDate`, `LastModifiedById`, `LastModifiedDate`, `SystemModstamp`, `IsDeleted`, `RecordTypeId`, `LastReferencedDate`, `LastViewedDate`, `LastActivityDate`.
- **Self-descriptive stage / forecast derivatives:** `IsClosed`, `IsWon`, `ForecastCategory`, `ForecastCategoryName`, `Fiscal`, `FiscalQuarter`, `FiscalYear`, `HasOpenActivity`, `HasOpportunityLineItem`, `HasOverdueTask`, `LastActivityInDays`, `LastStageChangeDate`, `LastStageChangeInDays`, `AgeInDays`.
- **Sales Cloud plumbing not used by FQS starter:** `Pricebook2Id`, `ContractId`, `TotalOpportunityQuantity`, `IqScore`, `IsPrivate`, `SourceId`.
- **External ID:** `External_Id__c`.

### Fields with help text authored

#### Family: Identity & naming

##### `Name` — standard, FQS auto-named
- **Help:** Set automatically by the FQS naming flow. Format: donor + gift type + primary campaign, mirroring the Gift Commitment convention. To keep a specific Name from being overwritten, check *Skip FQS Auto Naming*.
- **Description:** Written by the `FQS_Auto_Name_Opportunity` flow on insert and on relevant updates. Skipped when `FQS_Skip_Naming__c = TRUE`. Not enforced as unique.

##### `FQS_Skip_Naming__c` — custom (off-flexipage), `Skip FQS Auto Naming`
- **Help:** Check to prevent the FQS auto-naming flow from overwriting the Name on this Opportunity. Use for imports or integrations where the record already carries an authoritative external Name.
- **Description:** Mirrors `GiftCommitment.FQS_Skip_Naming__c`. Deliberately kept off the flexipage — surfaced via Object Manager for integration admins only. Read by `FQS_Auto_Name_Opportunity`.

#### Family: Relationships

##### `AccountId` — standard
- **Help:** The donor account this Opportunity belongs to — a Person Account for a named individual, a Household for couples / families giving jointly, or an Organization for a corporate, foundation, or grant funder.
- **Description:** Required. For FQS's grant path, this is the funder (typically an Organization Account). Distinct from `ContactId` (primary contact within the funding organization).

##### `CampaignId` — standard (README lookup filter)
- **Help:** The campaign this Opportunity is attributed to. Only leaf-level campaigns are selectable — top-level campaigns and category branches are filtered out by design, matching the Gift Commitment / Gift Transaction convention.
- **Description:** Lookup filter restricts to leaf-level campaigns (README post-install step). When the FQS launcher's Opportunity path closes-won and generates a `GiftCommitment` or `GiftTransaction`, the child inherits this Campaign.

#### Family: Amounts

##### `Amount` — standard
- **Help:** The dollar value the donor is expected to give if this Opportunity closes-won. For grants, the request amount; for major gifts, the ask amount; for planned gifts, the estimated present value.
- **Description:** On close-won, the FQS Opportunity launcher writes this value into the resulting `GiftCommitment.ExpectedTotalCmtAmount` or `GiftTransaction.OriginalAmount`.

##### `ExpectedRevenue` — standard, system
- **Help:** Set automatically. `Amount × Probability`. Used by pipeline forecasts to weight open Opportunities.
- **Description:** Platform-computed; not writable. FQS reports on unweighted `Amount` for pipeline totals.

##### `Probability` — standard
- **Help:** Likelihood this Opportunity closes-won, as a percentage. Defaults from the selected Stage — override only when you have Opportunity-specific intelligence.
- **Description:** Stage → Probability mapping is managed at the platform level. Manual override is per-record and does not update the stage default.

#### Family: Stage & lifecycle

##### `StageName` — standard, unrestricted picklist (README picklist extension)
- **Help:** Where this Opportunity sits in the fundraising pipeline. Grants progress through *LOI Submitted → Proposal Submitted → Under Review → Awarded / Declined*. Major gifts progress through *Identification → Cultivation → Solicitation → Verbal Commitment → Pledged*.
- **Description:** Unrestricted picklist. FundFirst-shipped values: `Identification`, `Cultivation`, `Solicitation`, `Verbal Commitment`, `Pledged`, `LOI Submitted`, `Proposal Submitted`, `Under Review`, `Awarded`, `Declined`. Stage drives `Probability`, `ForecastCategory`, `IsClosed`, and `IsWon`.

##### `Type` — standard, unrestricted picklist (README picklist extension)
- **Help:** The fundraising path this Opportunity represents. Choose *Grant* for foundation and institutional funding, *Major Gift* for named individual asks, *Planned Gift* for bequests and deferred commitments.
- **Description:** Unrestricted picklist. FQS-recommended values: `Grant`, `Major Gift`, `Planned Gift`, `Other`. Read by the FQS launcher's Opportunity branch to select the close-won conversion shape (GC vs. one-shot GT).

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

#### Family: Categorization

##### `LeadSource` — standard, unrestricted picklist
- **Help:** How this Opportunity was originated — the appeal, event, referral source, or channel. For grants, typically the funder-discovery channel.
- **Description:** Unrestricted picklist. Distinct from `CampaignId` (attribution destination) — `LeadSource` describes how the Opportunity entered the pipeline, `CampaignId` describes which fundraising initiative claims it.

#### Family: Free text

##### `NextStep` — standard (free text)
- **Help:** The immediate next move on this Opportunity — the outreach, meeting, or task the gift officer is committing to.
- **Description:** Trending-tracked. Reviewed in pipeline meetings; keep terse and action-oriented.

##### `Description` — standard (free text)
- **Help:** Free-text notes about this Opportunity — funder history, ask context, contingencies, or anything a gift officer landing on this record should know. Not used by any automation.

### Open follow-ups for Opportunity
- Reconcile `FQS_Skip_Naming__c` (surface-or-justify) — mirrors GC. Recommendation: keep off-flexipage.
- Coordinate `Type` picklist values with the FQS Opportunity launcher's supported flows (`FQS_Gift_Entry_Single_Launcher_Opportunity`).
- Confirm whether the FQS launcher's close-won conversion writes back an `Opportunity.Id` reference to the resulting `GiftCommitment.OpportunityId`.
- `ContactId` (primary contact) — off-flexipage. Surface-or-justify for the grants / major-gifts path.
- Verify `StageName` fundraising stages ship in the base FundFirst org vs. requiring FQS-side augmentation.

---

## Object: Gift Designation (`GiftDesignation`) — Key tier

**FQS flexipage:** `FQS_GiftDesignation_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 29
**Fields recommended for help text:** 7
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 2 (`Name`, `Description`)

### Object-level `<description>` (Key-tier)

> The master catalog of "buckets" a gift can be split across — funds, programs, projects, restricted purposes, or the org-wide default. Parent of `GiftTransactionDesignation` (per-payment split) and `GiftDefaultDesignation` (routing rules at the Campaign / GC / Opportunity level). Sits at the end of the FQS gift-processing chain: **GiftCommitment → GiftCommitmentSchedule → GiftTransaction → GiftTransactionDesignation → GiftDesignation**. Every FQS org ships with one seeded default (`FQS-GD-GENERAL-OPERATING`, `IsDefault=true`) — the managed `frops_flow__ProcessGiftCommitment` aborts with "org wide default designation is not yet configured" if no active GD carries `IsDefault=true`. Retiring a designation requires the two-DML teardown pattern (un-default → deactivate → delete).

### README post-install steps required
- None. All GD-owned edits travel with the unmanaged package's FQS-owned `.field-meta.xml`.

### Fields deliberately skipped
- `AverageTransactionAmount`, `HighestTransactionAmount`, `LowestTransactionAmount` — self-descriptive currency rollups; NPC-engine written.
- `FirstPaidTransactionDate`, `LastPaidTransactionDate` — self-descriptive date rollups.
- `CurrentYearTransactionCount`, `LastYearTransactionCount`, `LastTwoYearTrxnCount`, `TotalTransactionCount` — self-descriptive integer rollups.
- `CurrentYearTrxnAmount`, `LastYearTrxnAmount`, `LastTwoYearTrxnAmount`, `TotalTransactionAmount` — self-descriptive currency rollups.
- `OwnerId`, `CreatedById`, `CreatedDate`, `LastModifiedById`, `LastModifiedDate`, `SystemModstamp`, `IsDeleted`, `LastViewedDate`, `LastReferencedDate`, `Id` — audit / platform.
- `External_Id__c` — off-flexipage; already has help text via accelerator-wide external-ID convention.

### Fields with help text authored

#### Family: Identity / naming
##### `Name` — standard (currently blank shell, needs authoring)
- **Help:** The name donors and gift officers will recognize this designation by — for example "General Operating Fund", "2026 Scholarship Fund", or "Building Campaign - Phase II". Keep it short enough to fit in picker dropdowns on gift entry.
- **Description:** User-entered. Not enforced as unique — orgs commonly disambiguate similarly-named designations by year or program prefix. Appears in the Gift Designation column on `GiftTransactionDesignation` splits and in the Gift Entry designation picker.

##### `Description` — standard (currently blank shell, needs authoring)
- **Help:** Free-text notes on what this designation funds and any restrictions attached — background a finance officer or gift officer landing on this record should know. Not used by any automation.
- **Description:** Long-text area. Use for the plain-English scope of the fund. Not a substitute for `FQS_Restriction_Type__c`, which drives FASB/GAAP classification.

#### Family: Status / lifecycle
##### `IsActive` — standard (FQS-authored)
- **Help:** Uncheck to retire this designation. Retired designations stay on historical gifts but won't appear when adding new gifts.
- **Description:** Controls availability on new `GiftTransactionDesignation` splits via the `GiftDesignationId` lookup filter. An active GD **cannot be deleted** — the platform raises "You can't delete an active designation." Teardown pattern is un-default (`IsDefault=false`) → deactivate (`IsActive=false`) → delete. Deactivation does NOT affect existing historical GTD rows.

##### `IsDefault` — standard (FQS-authored, load-bearing)
- **Help:** Check exactly ONE active designation as the org-wide default — usually the general operating fund. Gifts that arrive without an explicit designation split fall through to this bucket.
- **Description:** **Load-bearing.** The managed `frops_flow__ProcessGiftCommitment` aborts with "org wide default designation is not yet configured" if no active GD has `IsDefault=true`. FQS seed flags `FQS-GD-GENERAL-OPERATING` on install. Only one GD may be `IsDefault=true` at a time; the platform enforces uniqueness across active records. To retire the current default, promote a successor first.

#### Family: Categorization
##### `FQS_Restriction_Type__c` — custom, restricted picklist
- **Help:** How the donor restricted the funds. Without Donor Restriction: usable for any program (incl. board-designated). Purpose: must be spent on a specific use. Permanent: endowment principal — only earnings spendable. Earned Revenue: exchange-transaction revenue (fees, ticket sales), not a contribution. Time restrictions live on the gift (see Restriction Release Date on GC / GT).
- **Description:** Restricted picklist. Legal values: **Without Donor Restriction** (unrestricted, includes internal board designations), **With Donor Restriction - Purpose**, **With Donor Restriction - Permanent** (endowment principal), **Earned Revenue** (exchange-transaction revenue, not a contribution). Time restrictions are NOT represented here — record time boundaries on the gift's `FQS_Restriction_Release_Date__c` field on `GiftCommitment` or `GiftTransaction`. Mirrored via formula onto `GiftTransactionDesignation` and `GiftDefaultDesignation` for report-friendliness.

### Open follow-ups for GiftDesignation
- Confirm `Name` and `Description` field-meta shells exist and are picked up by the flexipage — currently empty XML skeletons.
- No off-flexipage material gaps per inventory — off-page fields are audit/platform only.
- The seven rollup families all trace to the same NPC-engine writer; if a future admin reports "counts stopped incrementing," the debugging pointer belongs in `docs/npc-automation-notes.md`.

---

## Object: Gift Transaction Designation (`GiftTransactionDesignation`) — Key tier

**FQS flexipage:** `FQS_GiftTransactionDesignation_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 17
**Fields recommended for help text:** 5
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 3 (`Amount`, `Percent`, `GiftTransactionId`)

### Object-level `<description>` (Key-tier)

> The per-gift split — one GTD row for every `GiftTransaction` × `GiftDesignation` pairing. A gift can be allocated across one or many designations; every GTD carries either an `Amount` or a `Percent` of the parent gift. Sits in the middle of the FQS gift-processing chain: **GiftCommitment → GiftCommitmentSchedule → GiftTransaction → GiftTransactionDesignation → GiftDesignation**. GTDs are typically written by (a) the managed `frops_flow__ProcessGiftCommitment` from `GiftDefaultDesignation` routing rules, (b) the FQS Gift Entry launcher when the user chooses "Split gift across designations", or (c) manually on the parent Gift Transaction's related list. `FQS_Restriction_Type__c` is a formula mirror of the parent GD — never write it directly.

### README post-install steps required
- None — the `GiftDesignationId` lookup filter travels in the FQS-owned custom field metadata for the standard lookup.

### Fields deliberately skipped
- `Name` — autonumber; platform-labeled.
- `OwnerId` — platform-labeled.
- Audit / platform fields.
- `External_Id__c` — off-flexipage; accelerator-wide external-ID convention.

### Fields with help text authored

#### Family: Relationships
##### `GiftTransactionId` — standard
- **Help:** The gift this split belongs to. Required — every designation split must belong to a Gift Transaction. Splits inherit the transaction's date and payment method for reporting.
- **Description:** Master lookup to `GiftTransaction`. Populated automatically when GTD rows are created from Gift Entry, from `processGiftCommitment` fanout, or from `GiftDefaultDesignation` routing on the parent. Not user-editable after insert on managed flows.

##### `GiftDesignationId` — standard (FQS-authored, lookup filter)
- **Help:** By default this picker only shows active Gift Designations. If you need to attach this record to a retired designation (for example, to correct a back-dated gift or to match an inbound integration), uncheck the "Filter by:" checkbox at the top of the lookup dialog to see all designations.
- **Description:** Lookup filter restricts to `GiftDesignation.IsActive = TRUE`, deployed as **Optional** (not Required). Two override rationales: back-dated corrections and inbound integrations.

#### Family: Amounts
##### `Amount` — standard
- **Help:** The dollar amount of the parent gift allocated to this designation. Use Amount OR Percent — not both.
- **Description:** Populate for absolute-dollar splits (e.g., "$500 of a $2,000 gift to Scholarship, $1,500 to General"). Mutually exclusive with `Percent` at the row level. Sum of Amount across all sibling GTDs must equal the parent transaction's `OriginalAmount` — the platform does NOT enforce this.

##### `Percent` — standard
- **Help:** The share of the parent gift allocated to this designation as a percentage (0–100). Use Percent OR Amount — not both. When Percent is used across sibling splits, they should sum to 100.
- **Description:** Percentage-based split — the platform derives an equivalent `Amount` from `GiftTransaction.OriginalAmount × Percent / 100`. Sum-to-100 across siblings is a reporting convention; the platform does NOT enforce it. `GiftDefaultDesignation` routing produces `Percent`-based GTDs by default.

#### Family: Categorization
##### `FQS_Restriction_Type__c` — custom, formula
- **Help:** FASB/GAAP restriction classification inherited from the parent Gift Designation.
- **Description:** Formula. Mirrors `TEXT(GiftDesignation.FQS_Restriction_Type__c)` for report-friendliness. Read-only. Edit at the parent `GiftDesignation` record.

### Open follow-ups for GiftTransactionDesignation
- Reconcile `FQS_Restriction_Type__c` off-flexipage status — surface on `FQS_GiftTransactionDesignation_Record_Page` or explicitly justify keeping it off.
- `FQS_Restriction_Release_Date__c` seed backfill deferred — will populate on multi-year installments once designations Phase D6 lands.
- Consider a lightweight validation rule (or Flow) enforcing Amount XOR Percent + sum-to-parent at insert/update.

---

## Object: Gift Default Designation (`GiftDefaultDesignation`) — Supporting tier

**FQS flexipage:** `FQS_GiftDefaultDesignation_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 16
**Fields recommended for help text:** 4
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 2

### Object-level `<description>` (Supporting-tier)

> Routing rules that tell the managed `frops_flow__ProcessGiftCommitment` where to send an incoming gift when the donor didn't specify a designation split. Attaches a percentage-allocated set of `GiftDesignation`s to a **Campaign, `GiftCommitment`, or Opportunity** parent — `ParentRecordId` is polymorphic across those three sObject types ONLY. **Account is NOT valid** — attempting to seed an Account-parented GDD returns `INVALID_CROSS_REFERENCE_TYPE`. When multiple GDDs exist under one parent, `processGiftCommitment` creates one GTD per row on the resulting gift, splitting `GiftTransaction.OriginalAmount` by `AllocatedPercentage`.

### README post-install steps required
- None.

### Fields deliberately skipped
- `Name` — autonumber.
- `OwnerId` — platform-labeled.
- Audit / platform fields.

### Fields with help text authored

#### Family: Relationships
##### `ParentRecordId` — standard, polymorphic
- **Help:** The Campaign, Gift Commitment, or Opportunity this default designation routing rule applies to. Account is not a valid parent — route account-level defaults through the account's default Gift Commitment or through a household-scoped Campaign.
- **Description:** Polymorphic lookup — legal parent sObjects are **Campaign** (prefix `701`), **GiftCommitment** (prefix `6gc`), and **Opportunity** (prefix `006`). **Account (prefix `001`) is NOT valid** and the platform rejects it with `INVALID_CROSS_REFERENCE_TYPE`. `FQS_Parent_Type__c` (formula) derives the plain-English parent type from this ID's key prefix.

##### `GiftDesignationId` — standard (FQS-authored, lookup filter)
- **Help:** By default this picker only shows active Gift Designations. If you need to attach this record to a retired designation, uncheck the "Filter by:" checkbox to see all designations.
- **Description:** Lookup filter restricts to `GiftDesignation.IsActive = TRUE`, deployed as **Optional**. A single GD may appear across multiple GDDs (once per parent record).

#### Family: Amounts
##### `AllocatedPercentage` — standard
- **Help:** The share of any incoming gift on this parent that should be routed to this designation, as a percentage (0–100). Sibling default designations on the same parent should sum to 100.
- **Description:** Consumed by `frops_flow__ProcessGiftCommitment`. Sum-to-100 across sibling GDDs is a reporting convention; **the platform does NOT enforce it** — a set summing to 90 will silently under-allocate 10% of every gift on that parent to the org-wide default GD.

#### Family: Categorization
##### `FQS_Parent_Type__c` — custom, formula
- **Help:** Set automatically. Which kind of record this default designation belongs to — Campaign, Gift Commitment, or Opportunity.
- **Description:** Formula on `ParentRecordId`'s key prefix. Returns "Gift Commitment" (`6gc`), "Opportunity" (`006`), "Campaign" (`701`), or blank if unset.

##### `FQS_Restriction_Type__c` — custom, formula (off-flexipage)
- **Help:** FASB/GAAP restriction classification inherited from the related Gift Designation.
- **Description:** Formula. Mirrors `TEXT(GiftDesignation.FQS_Restriction_Type__c)`. Read-only. Edit at the parent `GiftDesignation` record.

### Open follow-ups for GiftDefaultDesignation
- Reconcile `FQS_Restriction_Type__c` (off-flexipage) — surface-or-justify (mirrors GTD).
- `ParentRecordId` polymorphism is Campaign / GiftCommitment / Opportunity ONLY — Account is NOT valid. Consider a validation rule that pre-empts the `INVALID_CROSS_REFERENCE_TYPE` error at insert.
- No `IsDefault` field on GDD — winner-selection is via `AllocatedPercentage` sum, not a boolean flag.

---

## Object: Gift Soft Credit (`GiftSoftCredit`) — Supporting tier

**FQS flexipage:** `FQS_GiftSoftCredit_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 19
**Fields recommended for help text:** 8
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 6

### README post-install steps required
- **`GiftSoftCredit.Role`** — if the FQS deploy adds any picklist values beyond FundFirst's standard set, those additions do not survive an unmanaged-package install and MUST be added by hand in Setup.
- **`GiftSoftCredit.GenerationalCohort`** — same picklist-add caveat if FQS extends the cohort list.

### Fields deliberately skipped
- `Id`, `IsDeleted`, `SystemModstamp`, `LastViewedDate`, `LastReferencedDate` — platform audit.
- `CreatedById`, `CreatedDate`, `LastModifiedById`, `LastModifiedDate` — platform-labeled audit.
- `Name` — autoname convention.
- `PartyPhilanthropicRsrchPrflId` — off-flexipage integration plumbing.
- `External_Id__c` — accelerator convention.

### Fields with help text authored

#### Family: Relationships

##### `RecipientId` — standard
- **Help:** The person or organization being soft-credited for this gift. Required. Selecting this doesn't move money — the legal donor stays on the parent Gift Transaction; this field only records who *also* gets recognition.
- **Description:** Lookup to Account (Person Account or Business Account). Blocks self-referencing the parent Gift Transaction's `DonorId` in the FQS launcher.

##### `GiftTransactionId` — standard
- **Help:** The Gift Transaction this soft credit attaches to. Required — soft credits are always tied to a specific paid or expected transaction, not to the parent Gift Commitment.
- **Description:** Master-detail-style lookup to `GiftTransaction`. Delete of the parent GT cascades to its GSCs. For default routing that fans out at every GT insert, configure a `GiftDefaultSoftCredit` on the Gift Commitment or Opportunity instead.

#### Family: Categorization

##### `Role` — standard, restricted picklist
- **Help:** Why this party gets credit for a gift they didn't legally give — e.g., *Solicitor* moved the donor, *Household Member* is the donor's partner or family, *Matched Donor* is the matching employer, *Honoree* is the tribute recipient.
- **Description:** Restricted picklist. Legal values: **Household Member**, **Influencer**, **Solicitor**, **Matched Donor**, **Soft Credit**, **Honoree**, **In-Kind Recognition**, **Third Party Donor**, **Other**.

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

#### Family: Party attribution

##### `GenerationalCohort` — standard, picklist (unrestricted)
- **Help:** Optional. The generation the soft-credit recipient belongs to — used for cohort-aware reporting.
- **Description:** Unrestricted picklist. Ships with the standard FundFirst set: **Silent Generation (1928–1945)**, **Baby Boomers (1946–1964)**, **Generation X (1965–1980)**, **Millennials (1981–1996)**, **Generation Z (1997–2012)**, **Generation Alpha (2013–2025)**. Off-flexipage by default.

### Open follow-ups for GiftSoftCredit
- Confirm whether FQS's `Role` and `GenerationalCohort` picklist values differ from the shipped FundFirst set.
- The recent `FQS_Gift_Entry_Soft_Credit_Reach` flow writes GSCs during Gift Entry — audit whether it sets `GenerationalCohort` from the recipient's Person Account attributes.
- `PartyPhilanthropicRsrchPrflId` remains off-flexipage; revisit when a philanthropic-research-profile capability lands.

---

## Object: Gift Default Soft Credit (`GiftDefaultSoftCredit`) — Supporting tier

**FQS flexipage:** `FQS_GiftDefaultSoftCredit_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 17
**Fields recommended for help text:** 6
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 5

### README post-install steps required
- **`GiftDefaultSoftCredit.Role`** — same standard restricted picklist as `GiftSoftCredit.Role`. If FQS extends it, additions do not survive an unmanaged-package install.

### Fields deliberately skipped
- `Id`, `IsDeleted`, `OwnerId`, `SystemModstamp`, `LastViewedDate`, `LastReferencedDate` — platform audit.
- `CreatedDate`, `LastModifiedDate` — platform-labeled.
- `Name` — autoname convention.
- `CreatedById`, `LastModifiedById` — kept on the flexipage as an audit surface.

### Fields with help text authored

#### Family: Relationships

##### `ParentRecordId` — standard, polymorphic
- **Help:** The record that should automatically fan out this soft credit onto every Gift Transaction posted under it. Choose a Gift Commitment (routes to every installment) or an Opportunity (routes to its resulting transactions). Do not use for one-off transaction credits — attach a `GiftSoftCredit` to that specific transaction instead.
- **Description:** Polymorphic lookup. Accepts **GiftCommitment** and **Opportunity** only — Account and Campaign parents are rejected by the platform. Runtime type is surfaced by `FQS_Parent_Type__c`.

##### `RecipientId` — standard
- **Help:** The person or organization who should receive the soft credit on every transaction fanned out from the parent. Common examples: a household partner for recurring gifts, a solicitor for a grant, or a matching-gift employer for a corporate commitment.
- **Description:** Lookup to Account (Person Account or Business Account). Set once on the default record; the platform copies the recipient onto each `GiftSoftCredit` it fans out.

#### Family: Categorization

##### `Role` — standard, restricted picklist
- **Help:** The relationship this recipient has to the parent commitment or opportunity — copies onto every soft credit fanned out from this default.
- **Description:** Restricted picklist. Legal values: identical to `GiftSoftCredit.Role`. Copies onto every child `GiftSoftCredit` at fan-out; editing on the default does not backfill previously-created GSCs.

#### Family: Amounts

##### `PartialAmount` — standard
- **Help:** Optional. Enter a fixed dollar amount to soft-credit on every transaction fanned out from the parent. Mutually exclusive with Partial Percent.
- **Description:** Sibling to `PartialPercent`. On a recurring commitment, a fixed `PartialAmount` produces the same soft-credit dollar figure on every installment even if installment amounts differ — usually `PartialPercent` is the intended choice.

##### `PartialPercent` — standard
- **Help:** Optional. Enter a percentage (0–100) of each transaction to soft-credit — the typical choice for household splits, joint-solicitor recognition, and matching-gift routing.
- **Description:** Sibling to `PartialAmount`. Applied against each fanned-out `GiftTransaction.CurrentAmount`, not `OriginalAmount`.

#### Family: Identity / naming

##### `FQS_Parent_Type__c` — accelerator-owned formula (off-flexipage — surface flag)
- **Help:** Set automatically. Shows whether this default routes off a Gift Commitment or an Opportunity — useful in list views scoped by parent object type.
- **Description:** Formula, text. Reads the 3-character key prefix of `ParentRecordId` (`6gc` → Gift Commitment, `006` → Opportunity, else blank). Recommend adding to `Facet-fqs-gdsc-d-s1-left` in the Soft Credit Details section.

### Open follow-ups for GiftDefaultSoftCredit
- Reconcile `FQS_Parent_Type__c` (off-flexipage) — recommend surfacing.
- Confirm no picklist adds on `Role` vs the shipped FundFirst set.
- The v67 platform accepts only GC / Opportunity parents here (Account and Campaign rejected). Cross-reference with `GiftDefaultDesignation.ParentRecordId` (Campaign / GC / Opportunity).

---

## Object: Gift Tribute (`GiftTribute`) — Supporting tier

**FQS flexipage:** `FQS_GiftTribute_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 26
**Fields recommended for help text:** 14
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 13

### README post-install steps required
- `HonoreeContactId` — the FQS `.field-meta.xml` adds an active lookup filter restricting the honoree lookup to Person Accounts (`Account.IsPersonAccount = True`). Verify the filter is present in post-install checkout.

### Fields deliberately skipped
- Audit / platform, `Name` (autonumber), `External_Id__c` (accelerator convention).

### Fields with help text authored

#### Family: Relationships (parent gift)
##### `GiftTransactionId` — standard
- **Help:** The gift payment this tribute is attached to. Set on one-off tribute gifts; leave blank when the tribute rides on a pledge or recurring commitment (use Gift Commitment instead).
- **Description:** Lookup to `GiftTransaction`. A tribute should reference either a `GiftTransaction` (one-time gift) or a `GiftCommitment` (pledge / recurring) — not both.

##### `GiftCommitmentId` — standard
- **Help:** The pledge or recurring commitment this tribute is attached to. Set when the tribute should carry across every installment of the commitment.
- **Description:** Lookup to `GiftCommitment`. Mutually exclusive with `GiftTransactionId`.

#### Family: Tribute categorization
##### `TributeType` — standard
- **Help:** Pick whether this tribute is In Honor Of (living recipient) or In Memory Of (deceased). Drives the salutation and default notification message wording.
- **Description:** Unrestricted picklist. Standard values: `Honor`, `Memorial`. Downstream FQS notification flows key on these two values by default.

##### `HonoreeContactId` — standard (README lookup filter)
- **Help:** The Person Account the tribute is for. Use this when the honoree already exists in FundFirst as a Person Account; fall back to Honoree Name for one-off honorees who don't need their own record.
- **Description:** Lookup to `Account` with an FQS-added lookup filter restricting selection to `IsPersonAccount = True`. When set, `HonoreeName` should mirror the Person Account's full name; FQS does not auto-sync.

##### `HonoreeName` — standard
- **Help:** Free-text name of the person being honored or remembered. Use this when the honoree isn't a Person Account or when the family requested the name appear differently on acknowledgment materials than in FundFirst.
- **Description:** Preferred over `HonoreeContactId` when you don't want to create a Person Account for a one-time tribute honoree.

##### `HonoreeInformation` — standard
- **Help:** Notes about the honoree — birth/death dates, relationship to the donor, preferred spelling, cause of death for memorials. Populates optional merge fields in acknowledgment templates.
- **Description:** Long text area. Not for notification-recipient contact info.

#### Family: Notification recipient
##### `NotificationContactId` — standard
- **Help:** The Account (typically a Person Account — the family member or friend) who should receive the tribute acknowledgment letter or email. Leave blank if no notification is required.
- **Description:** Lookup to `Account`. Distinct from `HonoreeContactId`: the honoree is the person being honored; the notification contact is who gets told the gift was made.

##### `NotificationContactName` — standard
- **Help:** Free-text notification recipient name — use when the recipient isn't in FundFirst as an Account or when the name on the letter should differ from the linked record.
- **Description:** FQS does not auto-copy from `NotificationContactId`.

##### `NotificationEmail` — standard
- **Help:** Email address for the tribute acknowledgment. Required when Notification Channel is Email.
- **Description:** Not validated against the linked `NotificationContactId`'s email.

##### `NotificationInfo` — standard
- **Help:** Mailing address or other contact details for the notification recipient. Required when Notification Channel is Mail.
- **Description:** Long text area for full postal address. No structured address parsing — free text.

#### Family: Notification lifecycle
##### `NotificationChannel` — standard
- **Help:** How to send the tribute acknowledgment — Mail (physical letter) or Email. Drives whether Notification Email or Notification Info is the required contact field.
- **Description:** Unrestricted picklist. Standard values: `Mail`, `Email`. FQS does not fire notifications itself — this field flags the intent for the fundraising ops team's outbound tool.

##### `NotificationStatus` — standard
- **Help:** Where this tribute notification is in the send lifecycle. Set to `To Be Sent` when the tribute is captured; move to `Sent` after the letter/email goes out; set to `Don't Send` when the donor declined notification.
- **Description:** Unrestricted picklist. Standard values: `To Be Sent`, `Sent`, `Don't Send`. FQS does not auto-flip to `Sent` — the outbound notification tool or a manual admin update is expected to write this.

##### `NotificationDate` — standard
- **Help:** The date the tribute notification was sent. Populate after the acknowledgment goes out.
- **Description:** User-set. No automation writes this in FQS.

##### `NotificationMessage` — standard
- **Help:** Custom message to include in the tribute notification, if the donor requested specific wording. Leave blank to use the acknowledgment template default.
- **Description:** Long text area. Overrides the default template body in downstream notification tools that honor this field.

### Open follow-ups for GiftTribute
- Confirm the `HonoreeContactId` lookup filter survives round-tripping through an unmanaged package installer.
- Notification lifecycle currently relies on manual `NotificationStatus` updates. If a future phase adds a Marketing Cloud / SendGrid outbound integration, revisit help text on `NotificationDate` and `NotificationStatus`.

---

## Object: Gift Refund (`GiftRefund`) — Supporting tier

**FQS flexipage:** `FQS_GiftRefund_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 21
**Fields recommended for help text:** 10
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 10

### README post-install steps required
- None.

### Fields deliberately skipped
- Audit / platform, `Name` (autonumber), `External_Id__c`.

### Fields with help text authored

#### Family: Relationships (parent gift)
##### `GiftTransactionId` — standard
- **Help:** The Gift Transaction being refunded. Required. One Gift Transaction can have multiple Gift Refunds (partial refunds, then a full refund) — total refunded across all children rolls up to the GT.
- **Description:** Master-detail-style relationship. Refunds sum to the parent GT's `RefundedAmount` rollup. FQS launcher does not auto-downgrade GT status on refund today (see FQS release-readiness for the pending Status handling item).

#### Family: Amounts
##### `Amount` — standard
- **Help:** The refund amount in the gift's currency. Enter as a positive number — do not enter a negative. Partial refunds allowed; multiple refund records against one GT are allowed and cumulate.
- **Description:** Currency, unsigned. Cumulative refunds across sibling `GiftRefund` records should not exceed the parent `GiftTransaction.TransactionAmount` — FQS does not validate this today.

##### `GatewayTransactionFee` — standard
- **Help:** Set automatically by the payment gateway integration when a refund is processed electronically. Blank on manually-entered refunds.
- **Description:** Written by the payment gateway (Stripe, Braintree, etc.). FQS ships without a gateway integration — expect blank in the starter deployment.

##### `ProcessorTransactionFee` — standard
- **Help:** Set automatically by the payment processor when a refund is processed electronically. Distinct from the gateway fee — some stacks report both, some report one.
- **Description:** Same integration-owned pattern as `GatewayTransactionFee`. Blank in FQS out of the box.

#### Family: Dates
##### `Date` — standard
- **Help:** The date the refund cleared / was booked, not the date the refund record was entered. Use the bank-clearing date for reconciled refunds; use today's date for refunds you're issuing now.
- **Description:** User-set on manual refunds; can be set by gateway integrations on electronic refunds. Reporting typically groups by this field, not `CreatedDate`.

#### Family: Categorization
##### `Reason` — standard
- **Help:** Why the refund was issued. Pick the closest match — Donor Request when the donor asked, Duplicate Gift for double-charged gifts, Chargeback when the bank forced it back.
- **Description:** Restricted picklist. Legal values: `Incorrect Amount`, `Donor Request`, `Duplicate Gift`, `Fraudulent`, `Test Transaction`, `Match Correction`, `Bounced Check`, `Chargeback`.

#### Family: Status / lifecycle
##### `Status` — standard
- **Help:** Where the refund is in the processing lifecycle. Set to `Initiated` when captured, move to `Completed` after funds are returned, `Failed` if the gateway rejects.
- **Description:** Unrestricted picklist. Standard values: `Initiated`, `Completed`, `Failed`. FQS does not auto-flip. Cumulative `RefundedAmount` rollup on the parent GT fires regardless of `Status` — an `Initiated` refund still counts against the GT total.

#### Family: Payment / gateway diagnostic
##### `LastGatewayResponseCode` — standard
- **Help:** Set automatically by the payment gateway on the most recent processing attempt. Use with Last Gateway Error Message to triage failed refunds.
- **Description:** Written by the payment gateway integration. Blank in FQS out of the box.

##### `LastGatewayErrorMessage` — standard
- **Help:** Set automatically by the payment gateway when a refund attempt fails. Human-readable version of Last Gateway Response Code.
- **Description:** Written by the payment gateway integration. Blank in FQS out of the box.

##### `LastGatewayProcessedDate` — standard
- **Help:** Set automatically by the payment gateway on the most recent processing attempt. Distinct from `Date` — this is when the gateway last touched the record.
- **Description:** Written by the payment gateway integration. Blank in FQS out of the box.

### Open follow-ups for GiftRefund
- **GT Status downgrade on full refund.** A future phase should either add a "Refunded" status write when cumulative refunds equal GT amount, or document the reporting pattern of filtering on `TransactionAmount - RefundedAmount > 0`.
- **Amount overflow validation.** Currently no guard against cumulative refunds exceeding the parent GT amount.
- **Gateway plumbing surfacing.** All four `LastGateway*` fields plus the two fee fields are surfaced on the FQS flexipage but are blank in the FQS starter. Consider a follow-up flexipage pass to move these into a collapsible section.

---

## Object: Outreach Source Code (`OutreachSourceCode`) — Supporting tier

**FQS flexipage:** `FQS_OutreachSourceCode_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 29
**Fields recommended for help text:** 16
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 11

### README post-install steps required
- None. FQS does not add a lookup filter to `OutreachSourceCode.CampaignId`; OSC is authored against the full campaign hierarchy so admins can bind a source code to a category branch.
- If a target org has narrowed `MessageChannel` or `UsageType` picklists via a managed value-set override, restore the full FundFirst set — post-install verify step.

### Fields deliberately skipped
- Audit / platform (10 fields).
- `External_Id__c` — accelerator convention.
- `Description` (standard free-text) — self-explanatory.
- `SourceCodeBaseUrl` (off-flexipage URL scaffold) — builder-only intermediate value.

### Fields with help text authored

#### Family: Identity & lifecycle
##### `Name` — standard
- **Help:** A short human-readable label for this source code (e.g., "FY26 Year-End Email #1"). Distinct from `Source Code` — Name is the display label; Source Code is the machine token used in URLs and gift attribution.
- **Description:** Free-text string. Not enforced as unique. Distinct from `SourceCode`. No auto-naming flow in FQS for OSC.

##### `Status` — standard, unrestricted picklist
- **Help:** Where this source code sits in its lifecycle. Choose *Active* while the outreach is running or still attracting gifts, *Inactive* to hide it from picklists without losing history, *Archived* once no further gifts are expected.
- **Description:** Unrestricted picklist — FundFirst ships **Active**, **Inactive**, **Archived**. Reporting-only in FQS.

##### `UsageType` — standard, restricted picklist (FQS-customized)
- **Help:** Choose *Fundraising* — this is the only usage type FQS supports today. When set to Fundraising, a Campaign is required.
- **Description:** Restricted picklist. Legal values: **Fundraising** (only value shipped by NPC today). When `UsageType = 'Fundraising'`, `CampaignId` is required or insert/update fails.

#### Family: Categorization — channel & platform
##### `MessageChannel` — standard, restricted picklist (FQS-customized)
- **Help:** Equivalent to *utm_medium* in web analytics — the type of channel used to reach donors. Drives the `Message Channel Segment` grouping used in list views and reporting.
- **Description:** Restricted picklist. Legal values: **Email**, **SMS**, **Direct Mail**, **Social Organic**, **Social Paid**, **Digital Paid**, **Organic Web**, **Physical**, **Share Partner**, **Telemarketing**. Drives the `FQS_Message_Channel_Segment__c` formula.

##### `FQS_Platform__c` — custom, unrestricted picklist
- **Help:** The specific platform or sender for this source code — equivalent to *utm_source* in web analytics. Use with Message Channel (utm_medium) to fully describe the tactic.
- **Description:** Unrestricted picklist — FundFirst ships 19 values (Facebook, Instagram, LinkedIn, X (Twitter), YouTube, Google Ads, Microsoft Ads, Mailchimp, Marketing Cloud, Constant Contact, etc.). Extend via Object Manager.

##### `FQS_Message_Channel_Segment__c` — custom, formula
- **Help:** Set automatically. Rolls up Message Channel into three planning buckets — *Organic*, *Paid Digital*, or *Owned or Acquired Lists* — used by list views and channel-mix reports.
- **Description:** Formula field reading `MessageChannel`. Segments: **Organic** (Organic Web, Physical, Social Organic, Share Partner); **Paid Digital** (Digital Paid, Social Paid); **Owned or Acquired Lists** (Email, Direct Mail, SMS, Telemarketing). Not writable.

##### `MessageChannelPlatform` — standard
- **Help:** Optional free-text override for the platform if the picklist doesn't cover it. Prefer the `Platform` picklist when a value exists.
- **Description:** Free text (255). Distinct from the FQS-authored `FQS_Platform__c` picklist.

##### `MessageChannelPlatformAccount` — standard
- **Help:** The specific sender account on the platform — e.g., the email-sending domain, the ad account ID, or the social handle used for this tactic. Useful for reconciling gift attribution against platform-side reports.
- **Description:** Free text (255). No automation reads this; reporting-only.

#### Family: URL scaffold & content
##### `SourceCode` — standard (FQS-customized)
- **Help:** Unique identifier for this outreach tactic. Convention: `{CHANNEL-PREFIX}-{CAMPAIGN-SHORT-NAME}-{SEQUENCE}` — e.g., `EM-FY26-YEAREND-01`. Equivalent to *utm_content* in web analytics.
- **Description:** Free text. Stored on `GiftTransaction.OutreachSourceCodeId` via the OSC lookup. Used by the Outreach Summary rollup to attribute revenue. Not unique at the platform level today — enforce uniqueness through org convention.

##### `SourceCodeUrl` — standard, computed URL
- **Help:** The full attributed landing URL for this outreach tactic — combines the campaign's short name (utm_campaign), Message Channel (utm_medium), Platform (utm_source), and Source Code (utm_content). Copy this into the outreach email, ad, or post so gifts route back to the right tactic.
- **Description:** URL scaffold assembled by FQS from `SourceCodeBaseUrl` + the parent Campaign's `FQS_Short_Name__c` + `MessageChannel` + `FQS_Platform__c` + `SourceCode`. Recomputes when any input changes.

##### `MessageContentTitle` — standard
- **Help:** The subject line, ad headline, or piece title used in this outreach. Useful for reconciling gift patterns back to specific creative when a Message Channel had multiple variants.
- **Description:** Free text. Reporting-only.

##### `MessageContent` — standard
- **Help:** Free-text notes on the message body, script, or creative used — enough to identify the outreach piece when reviewing gift attribution months later. Not the full message body.
- **Description:** Long text. Reporting / audit surface.

#### Family: Audience & timing
##### `SentDate` — standard
- **Help:** The date this outreach went out to donors — email send date, mail-drop date, ad-launch date, event date. Anchors response-time analysis.
- **Description:** DateTime. Manual field. Reporting-only in FQS.

##### `AudienceCount` — standard
- **Help:** How many people this outreach was sent to — email list size, print quantity, ad-reach estimate. Required for `Response Rate` on the child Outreach Summary to compute.
- **Description:** Integer. Read by `OutreachSummary.ResponseRate` — `CEIL(DonorCount / AudienceCount × 100)`. Null `AudienceCount` yields null Response Rate.

##### `AudienceInformation` — standard
- **Help:** Free-text notes about the audience — segmentation criteria, list source, suppression rules, or exclusions. Useful when auditing later why response rate was high or low.
- **Description:** Long text. Reporting / audit surface.

### Open follow-ups for OutreachSourceCode
- **Surface `FQS_Message_Channel_Segment__c` and `FQS_Platform__c` on the flexipage** — currently off-page per off-flexipage inventory.
- **Uniqueness on `SourceCode`** — today it's not platform-enforced. Track whether an FQS validation rule should land.
- **Empty `SourceCodeBaseUrl` fallback** — either surface it or document a Setup path to populate it.

---

## Object: Outreach Summary (`OutreachSummary`) — Background tier

**FQS flexipage:** `FQS_OutreachSummary_Record_Page.flexipage-meta.xml`
**Fields on object (FundFirst v67):** 25
**Fields recommended for help text:** 12
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 5

### README post-install steps required
- None. Outreach Summary is a platform-managed rollup.

### Fields deliberately skipped
- Audit / platform.
- `Name` — standard label field carrying the parent Campaign or Outreach Source Code name.

### Fields with help text authored

Background tier framing: every field on Outreach Summary is written by the platform's outreach-rollup engine on a schedule. **Do not hand-edit any field on this object.**

#### Family: Relationships (parent scope)
##### `CampaignId` — standard
- **Help:** The Campaign this rollup summarizes. Populated when the summary row aggregates gifts at the campaign level (across all child Outreach Source Codes).
- **Description:** An Outreach Summary row is either campaign-scoped (`CampaignId` populated, `OutreachSourceCodeId` null) or OSC-scoped. Do not populate both by hand.

##### `OutreachSourceCodeId` — standard
- **Help:** The Outreach Source Code this rollup summarizes. Populated when the summary row aggregates gifts at the tactic level.
- **Description:** When populated, this row's numbers reflect only gifts posted with `GiftTransaction.OutreachSourceCodeId` matching this record.

#### Family: Totals (currency rollups)
##### `TotalGiftTransactionAmount` — standard, platform-rollup
- **Help:** Sum of all paid gift transaction amounts attributed to this campaign or outreach source code.
- **Description:** Set automatically by the platform outreach-rollup engine. Includes only paid transactions (`GiftTransaction.Status = 'Paid'`). See `docs/npc-automation-notes.md`.

##### `TotalOnetimeGiftAmount` — standard, platform-rollup
- **Help:** Sum of paid one-time gift amounts (not connected to a recurring commitment) attributed to this campaign or outreach source code.
- **Description:** Set automatically. Filters to `GiftTransaction.GiftCommitmentId = null` OR the commitment is not a Recurring Gift.

##### `TotalRecurringGiftAmount` — standard, platform-rollup
- **Help:** Sum of paid recurring installment amounts attributed to this campaign or outreach source code.
- **Description:** Set automatically. Complement of `TotalOnetimeGiftAmount`.

##### `AttributedAmount` — standard, platform-rollup
- **Help:** Total revenue credited to this campaign or outreach source code. Combines one-time cash gifts with the earned-to-date value of recurring pledges originated by this outreach.
- **Description:** Set automatically. Distinct from `TotalGiftTransactionAmount` — attribution here credits recurring pledges by *earned-to-date value*, not paid installments.

#### Family: Averages (currency rollups)
##### `AverageGiftAmount` — standard, platform-rollup
- **Help:** Set automatically. `TotalGiftTransactionAmount ÷ GiftCount`. Blank when Gift Count is zero.
- **Description:** Platform-managed.

##### `AverageOnetimeGiftAmount` — standard, platform-rollup
- **Help:** Set automatically. `TotalOnetimeGiftAmount ÷` the number of paid one-time gifts.
- **Description:** Platform-managed.

##### `AverageRecurringGiftAmount` — standard, platform-rollup
- **Help:** Set automatically. `TotalRecurringGiftAmount ÷` the number of paid recurring installments.
- **Description:** Platform-managed.

#### Family: Counts (integer rollups)
##### `GiftCount` — standard, platform-rollup
- **Help:** Total number of paid gift transactions attributed to this campaign or outreach source code.
- **Description:** Set automatically. Counts `GiftTransaction` rows with `Status = 'Paid'` scoped to this row's Campaign or OSC.

##### `DonorCount` — standard, platform-rollup
- **Help:** Number of unique donors who made a paid gift attributed to this campaign or outreach source code.
- **Description:** Set automatically. Distinct-count on `GiftTransaction.DonorId`.

##### `OnetimeDonorCount` — standard, platform-rollup
- **Help:** Number of unique donors whose paid gifts were one-time.
- **Description:** Set automatically. A donor with both one-time and recurring gifts appears in both `OnetimeDonorCount` and `RecurringDonorCount`.

##### `RecurringDonorCount` — standard, platform-rollup
- **Help:** Number of unique donors who made at least one paid recurring installment attributed to this campaign or outreach source code.
- **Description:** Set automatically.

#### Family: Response
##### `ResponseRate` — standard, platform-rollup
- **Help:** Percentage of the outreach audience who made at least one paid gift. Calculated as `CEIL(DonorCount / AudienceCount × 100)`.
- **Description:** Set automatically. Reads `AudienceCount` from the related `OutreachSourceCode`(s). Null `AudienceCount` yields null Response Rate.

### Open follow-ups for OutreachSummary
- **Refresh cadence** — help text names the platform outreach-rollup engine as the writer but does not specify its cadence (real-time vs scheduled).
- **Campaign vs OSC scope enforcement** — verify against seeded data that a row is *either* campaign-scoped *or* OSC-scoped.
- **`AttributedAmount` earned-to-date formula** — confirm the exact formula against NPC docs.
- **Data-quality report for missing `AudienceCount`** — either add the report in FQS or drop the reference from the description.

---

## Object: Action Plan (`ActionPlan`) — Supporting tier

**FQS flexipage:** none — platform default record page (Salesforce Industries-managed object)
**Fields on object (FundFirst v67):** 25
**Fields recommended for help text:** 12
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 12

### README post-install steps required
- None. All authored copy is `<inlineHelpText>` / `<description>` on standard fields; unmanaged-package deploys carry both.

### Fields deliberately skipped
- Audit / platform, `Name` (auto-populated from the Action Plan Template on `Autocreated` records).

### Fields with help text authored

#### Family: Relationships (target + template)

##### `TargetId` — standard
- **Help:** The record this Action Plan is attached to — for FQS, typically an Account (donor / prospect) or Opportunity (major gift / grant). One Action Plan drives the task series against exactly one target record.
- **Description:** Polymorphic lookup to any object the assigned Action Plan Template supports. Do not repoint after plan tasks have started — child tasks stay attached to the original target.

##### `ActionPlanTemplateVersionId` — standard
- **Help:** The specific version of the Action Plan Template this plan was launched from. Plans stay pinned to the template version they were created against.
- **Description:** Lookup to `ActionPlanTemplateVersion`. Version-pinned by design — editing the template creates a new version; launched plans keep the version they started with.

#### Family: Status / lifecycle

##### `ActionPlanState` — standard, picklist
- **Help:** Where this plan is in its lifecycle. *Not Started* until the first task is worked; *In Progress* once any task is opened; *Completed* when every task is done or skipped; *Canceled* if the plan is abandoned before completion.
- **Description:** Unrestricted picklist. Standard values: **Not Started**, **In Progress**, **Canceled**, **Completed**. Set automatically by the Action Plan engine as child tasks move through their own lifecycles.

##### `StatusCode` — standard, restricted picklist
- **Help:** Set automatically. The API-normalized form of *Status* — same lifecycle, different casing. Use this field (not *Status*) in Flow and Apex filters.
- **Description:** Restricted picklist. Legal values: **NotStarted**, **InProgress**, **Completed**, **Canceled**. Written in lockstep with `ActionPlanState` by the Action Plan engine.

#### Family: Categorization

##### `ActionPlanType` — standard, restricted picklist
- **Help:** Which flavor of Action Plan feature this record uses. FQS ships plans under *Industries*. Do not switch to *Retail* on FQS records.
- **Description:** Restricted picklist. Legal values: **Industries** (Salesforce Industries Action Plans — the FQS default), **Retail** (not used by FQS).

##### `RecordCreationType` — standard, restricted picklist
- **Help:** How this Action Plan was created. *Master* means an admin created the plan explicitly against a target record; *Autocreated* means a flow, process, or another Action Plan spawned it automatically.
- **Description:** Restricted picklist. Legal values: **Master**, **Autocreated**. Not writable after insert.

#### Family: Schedule mechanics

##### `StartDate` — standard
- **Help:** The date this plan's task series is anchored to. Task due dates offset from this date using the template's day-offsets.
- **Description:** Anchors the entire task schedule. Setting a new Start Date on an in-flight plan does not auto-shift child tasks — the platform recomputes due dates only for tasks not yet created.

##### `EndDate` — standard
- **Help:** Set automatically. The date of the last task in this plan, computed from Start Date plus the template's longest task offset.
- **Description:** Platform-computed from `StartDate` + the highest positive day-offset on the template. Not user-editable.

##### `ActualStartDate` — standard
- **Help:** Set automatically. The date the first task on this plan was actually worked — as opposed to *Start Date*, which is when the plan was scheduled to begin.
- **Description:** Written by the Action Plan engine on the first child-task status change from *Not Started* to any other value.

##### `ActualEndDate` — standard
- **Help:** Set automatically. The date the last task on this plan was closed — as opposed to *End Date*, which is the scheduled completion.
- **Description:** Written by the engine when the plan reaches `ActionPlanState = Completed` or `Canceled`.

##### `IsUsingHolidayHours` — standard, boolean
- **Help:** When checked, task due dates skip weekends and configured holidays — a `+3 day` offset from a Friday Start Date becomes the following Wednesday, not Monday.
- **Description:** Uses the org's Business Hours + Holidays configuration to shift task due dates off nonworking days. FQS ships this default-on for stewardship templates.

##### `RecurringScheduleId` — standard
- **Help:** Set automatically. For recurring Action Plans (e.g., annual donor-anniversary stewardship), the schedule that spawns each new plan instance. Blank for one-time plans.
- **Description:** Lookup to `RecurringSchedule`. Populated only when the parent Action Plan Template is configured as recurring.

##### `ScheduleFrequency` — standard
- **Help:** Set automatically. Human-readable summary of the recurring schedule that spawns this plan — e.g., "Yearly on donor anniversary."
- **Description:** Derived from the linked `RecurringSchedule`. Not writable.

#### Family: Edit-safety

##### `ShouldAllowOverride` — standard, boolean
- **Help:** When checked, users can hand-edit task due dates on this plan without recomputing from Start Date. When unchecked, task-date changes must go through rescheduling the plan.
- **Description:** Guardrail for stewardship-consistency scenarios. Setting to true retroactively unlocks in-flight tasks; setting to false does not re-lock already-edited due dates.

### Open follow-ups for ActionPlan
- **Object `<description>` copy** — write once the FQS shipped Action Plan Template roster is finalized.
- **`ActionPlanState` vs `StatusCode` duplication** — long-term, decide whether FQS docs / reports standardize on one field or the other.
- **Recurrence coverage** — if FQS does not actually ship a recurring Action Plan Template in v1, consider tightening `RecurringScheduleId` / `ScheduleFrequency` copy to "deferred, not missed".
- **`TargetId` polymorphism** — confirm the exact target-object list of FQS-shipped Action Plan Templates.

---

## Object: Campaign Member (`CampaignMember`) — Supporting tier

**FQS flexipage:** none — platform default record page
**Fields on object (FundFirst v67):** 36
**Fields recommended for help text:** 8
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 8

### README post-install steps required
- None.

### Fields deliberately skipped
- Audit / platform.
- **Snapshot fields projected from `Contact` / `Lead`** — CampaignMember carries these as read-through denormalized copies; the source of truth is the related person record. Skipping: `Salutation`, `Name`, `FirstName`, `LastName`, `Title`, `Street`, `City`, `State`, `PostalCode`, `Country`, `Email`, `Phone`, `Fax`, `MobilePhone`, `Description`, `DoNotCall`, `HasOptedOutOfEmail`, `HasOptedOutOfFax`, `LeadSource`, `CompanyOrAccount`, `LeadOrContactOwnerId`.

### Fields with help text authored

#### Family: Relationships

##### `CampaignId` — standard
- **Help:** The campaign this member belongs to. In FQS, add members to leaf-level campaigns (specific appeals, events, mailings) — not top-level campaigns or category branches — so gift attribution rolls up cleanly through the campaign hierarchy.
- **Description:** Required lookup to `Campaign`. FQS convention is leaf-level attribution; unlike GC/GT `CampaignId` fields, CampaignMember does NOT ship with a lookup filter.

##### `LeadId` — standard
- **Help:** The lead this campaign membership is for. Exactly one of *Lead* or *Contact* must be populated on any CampaignMember — never both, never neither.
- **Description:** Mutually exclusive with `ContactId` at the platform level. When a lead converts to a contact, the CM record is retargeted from `LeadId` to `ContactId` automatically.

##### `ContactId` — standard
- **Help:** The contact this campaign membership is for. Exactly one of *Contact* or *Lead* must be populated on any CampaignMember. FQS uses Contact for constituent-to-campaign relationships; on Person Account orgs, the Contact behind the Person Account is what CM points at.
- **Description:** Mutually exclusive with `LeadId`. On Person Account orgs, `ContactId` references the auto-generated Contact record behind each Person Account.

##### `LeadOrContactId` — standard, polymorphic
- **Help:** Set automatically. The unified reference to whichever of *Lead* or *Contact* is populated on this member. Use this in reports and dashboards that treat leads and contacts as a single "audience member" concept.
- **Description:** Platform-managed polymorphic reference — mirrors whichever of `LeadId` / `ContactId` is populated.

#### Family: Status / lifecycle

##### `Status` — standard, unrestricted picklist (per-campaign)
- **Help:** Where this member sits in the campaign's response funnel — for example, *Sent* when the appeal was delivered, *Responded* when the member gave, RSVP'd, or attended. Available values differ per campaign.
- **Description:** Unrestricted picklist, but the *effective* legal values are configured per-Campaign. Default values across all campaigns: **Sent**, **Responded**. Moving a member into any responded status auto-writes `HasResponded = true` and `FirstRespondedDate`.

##### `HasResponded` — standard, boolean
- **Help:** Set automatically. Flipped to true the first time this member is moved into any of the campaign's "responded" statuses. Used by `Campaign.NumberOfResponses`.
- **Description:** Platform-managed by the CampaignMember engine. Once true, remains true even if the status is later moved back to a non-responded value.

##### `FirstRespondedDate` — standard
- **Help:** Set automatically. The first date this member entered a "responded" status on this campaign. Blank until the first response.
- **Description:** Written once by the CampaignMember engine, on the first `HasResponded = false → true` transition. Not overwritten on subsequent status flips.

#### Family: Categorization

##### `Type` — standard, system-set string
- **Help:** Set automatically. Reflects whether this campaign member points at a Contact or a Lead — *Contact* or *Lead*.
- **Description:** Platform-derived string. Not user-editable despite being a text field. If you need audience segmentation beyond lead/contact, add a custom `__c` field.

### Open follow-ups for CampaignMember
- **Object `<description>` copy** — write once FQS decides whether CampaignMember is a primary constituent-to-campaign linkage or a secondary tool behind Gift Transaction's `CampaignId`.
- **Leaf-level lookup filter on `CampaignId`** — evaluate whether to add one for parity with GC / GT. Downside: breaks bulk-add utilities.
- **Person Account clarification** — walk through the "Person Account → underlying Contact → CampaignMember.ContactId" traversal explicitly in docs.
- **Per-campaign status ladders** — FQS should ship at least one or two sample Campaigns with non-default status ladders.

---

## Object: Gift Batch (`GiftBatch`) — Background tier

**FQS flexipage:** none — platform default record page (populated by Gift Entry wizard, not hand-authored)
**Fields on object (FundFirst v67):** 24
**Fields recommended for help text:** 10
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 10

### README post-install steps required
- None.

### Fields deliberately skipped
- **Self-descriptive rollups:** `ProcessedGiftCount`, `FailedGiftCount`, `TotalGiftCount`, `TotalBatchAmount`.
- **Audit / platform.**

### Fields with help text authored

#### Family: Batch identity
##### `Name` — standard
- **Help:** Set by the admin who launches the Gift Entry wizard — a short label the batch is opened under (e.g., "March mail appeal — week 2"). Not auto-numbered.
- **Description:** Free-text label chosen at batch creation. Do not rename after the batch enters `In Progress` — downstream reports and the wizard resumption UI key off the original label.

##### `Description` — standard
- **Help:** Free-text notes about this batch — appeal context, entry-crew handoff notes, reconciliation instructions. Not used by any automation.

#### Family: Batch state
##### `Status` — standard, restricted picklist
- **Help:** Set automatically by the Gift Entry wizard as gifts are keyed and processed. Do not hand-edit — the wizard owns transitions.
- **Description:** Restricted picklist. Legal values: **Unprocessed**, **In Progress**, **Processed**, **Partially Processed**, **Failed**. Written by the Gift Entry wizard's batch-processing engine. Direct edits are overwritten on the next wizard action.

##### `StatusReason` — standard
- **Help:** Set automatically. Explains why the batch landed in its current status — typically populated on `Failed` or `Partially Processed`.
- **Description:** Written by the Gift Entry wizard's batch-processing engine when `Status` transitions to a non-happy-path value.

##### `LastProcessedDateTime` — standard
- **Help:** Set automatically. Timestamp of the most recent processing run against this batch. Refreshes each time the Gift Entry wizard commits a set of gifts.
- **Description:** Blank on `Unprocessed` batches.

##### `DoesTotalGiftValueMatch` — standard
- **Help:** Set automatically. `TRUE` when the sum of posted gift amounts equals the Estimated Batch Value entered at batch creation.
- **Description:** Written by the Gift Entry wizard. Compares aggregated `GiftTransaction.OriginalAmount` for the batch against `ExpectedValueofGiftsinBatch`. Investigate `FALSE` values before closing a batch.

#### Family: Wizard-set planning inputs
##### `EstimatedGiftCount` — standard
- **Help:** The number of gifts the batch owner expects to key. Used as the planning target; the wizard compares it against `TotalGiftCount` as gifts post.
- **Description:** Entered at batch creation. Not enforced — a batch can complete with more or fewer gifts than estimated.

##### `ExpectedValueofGiftsinBatch` — standard
- **Help:** The total dollar value the batch owner expects to post. The wizard compares this against actual `TotalBatchAmount` and flips `DoesTotalGiftValueMatch` accordingly.
- **Description:** Entered at batch creation. Reconciliation input, not a hard cap.

##### `DefaultGiftFieldValues` — standard
- **Help:** Set automatically by the Gift Entry wizard from the batch's default-value configuration. JSON payload — do not hand-edit.
- **Description:** Wizard-serialized JSON of default field values applied to each gift keyed under this batch.

##### `ScreenTemplateName` — standard, unrestricted picklist
- **Help:** The Gift Entry screen template this batch was opened under. Ships with `Default`; extend via the Gift Entry wizard configuration in Setup.
- **Description:** Unrestricted picklist. Ships with a single value **Default**.

### Open follow-ups for GiftBatch
- FQS starter does not yet exercise Gift Entry in bulk — verify `DoesTotalGiftValueMatch` behavior against a real posted batch.
- Confirm whether `Name` is truly free-text-only or whether the wizard enforces uniqueness.

---

## Object: Gift Commitment Change Attribution Log (`GiftCmtChangeAttrLog`) — Background tier

**FQS flexipage:** `FQS_GiftCmtChangeAttrLog_Record_Page.flexipage-meta.xml` (read-only surfacing — admins do not hand-edit; log rows are system-written)
**Fields on object (FundFirst v67):** 18
**Fields recommended for help text:** 9
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 9

### README post-install steps required
- None. Note: API name is the v67 short form `GiftCmtChangeAttrLog`, not `GiftCommitmentChangeAttributionLog`.

### Fields deliberately skipped
- Audit / platform.

### Fields with help text authored

#### Family: Log identity
##### `Name` — standard
- **Help:** Set automatically when the platform writes the change log row. Serves as a stable identifier for a specific commitment change event.
- **Description:** Written by the Fundraising Cloud change-attribution engine on GC / GCS modifications. Not writable — admins do not create or edit these rows.

#### Family: Related records (what changed)
##### `GiftCommitmentId` — standard
- **Help:** Set automatically. The Gift Commitment whose change this row logs. Required.
- **Description:** Written by the Fundraising Cloud change-attribution engine.

##### `GiftCommitmentScheduleId` — standard
- **Help:** Set automatically. The specific schedule version that triggered the change — the newly-written schedule when a pause / resume / edit action fires.
- **Description:** Written by the Fundraising Cloud change-attribution engine, typically by the managed `frops_flow__PauseResumeSchedule` and schedule-edit flows. Points to the *new* schedule; the prior schedule is reachable via `GCS.GiftCommitmentSchdBefEditId`.

##### `CampaignId` — standard
- **Help:** Set automatically. The Campaign in force on the commitment at the time of the change.
- **Description:** Written by the change-attribution engine at log-row creation. Snapshot value — does not update if the commitment's Campaign changes later.

##### `OutreachSourceCodeId` — standard
- **Help:** Set automatically. The Outreach Source Code in force on the commitment at the time of the change.
- **Description:** Written by the change-attribution engine at log-row creation. Snapshot value.

#### Family: Change semantics
##### `ChangeType` — standard, restricted picklist
- **Help:** Set automatically. Names *what* changed on the commitment — the payment cadence, the amount, or both.
- **Description:** Restricted picklist. Legal values: **Frequency**, **Amount**, **Frequency and Amount**. Written by the Fundraising Cloud change-attribution engine on schedule save.

##### `ChangeStatus` — standard, restricted picklist
- **Help:** Set automatically. Names *the direction* of the change from the donor's perspective — an upgrade, a downgrade, or a neutral / pause / resume event.
- **Description:** Restricted picklist. Legal values: **Upgrade**, **Downgrade**, **Neutral**, **Pause**, **Resume**. Written by the change-attribution engine using `ChangePerDayAmount` sign as the primary signal.

##### `ChangePerDayAmount` — standard
- **Help:** Set automatically. Normalized daily-dollar delta of the change — positive on upgrades, negative on downgrades, zero on neutral / pause / resume.
- **Description:** Written by the change-attribution engine. Formula: (new `TransactionAmount` ÷ new period-in-days) − (prior `TransactionAmount` ÷ prior period-in-days). Drives `ChangeStatus` sign.

##### `EffectiveDate` — standard
- **Help:** Set automatically. The date the change becomes active — typically the new schedule's `StartDate`.
- **Description:** Written by the change-attribution engine. Points to the log row's associated schedule `StartDate`, not the timestamp the change was keyed in.

### Open follow-ups for GiftCmtChangeAttrLog
- Verify `ChangePerDayAmount` sign convention (positive = upgrade) against a seeded org.
- Confirm that `Pause` and `Resume` rows always carry `ChangePerDayAmount = 0`.
- Any managed-package flow other than `frops_flow__PauseResumeSchedule` that writes these rows?

---

## Object: Fundraising Config (`FundraisingConfig`) — Background tier

**FQS flexipage:** none — surfaces via Setup / Custom Metadata UI, not a Lightning record page
**Fields on object (FundFirst v67):** 30
**Fields recommended for help text:** 19
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 19

### README post-install steps required
- **Doc README step:** because `FundraisingConfig` surfaces only via Setup and not a record page, README should add a §"Configure Fundraising Engine Settings" post-install pointer telling admins where in Setup to find the record and which settings FQS assumes non-default values for.

### Fields deliberately skipped
- **Custom-metadata-type plumbing:** `Id`, `IsDeleted`, `DeveloperName`, `Language`, `MasterLabel`, `NamespacePrefix`.
- **Audit / platform.**

### Fields with help text authored

#### Family: Commitment lifecycle thresholds
##### `LapsedUnpaidTrxnCount` — standard
- **Help:** How many consecutive unpaid expected installments before the Fundraising engine flips the parent `GiftCommitment.Status` to `Lapsed`. Read by the NextGen commitment processing job.
- **Description:** Integer. Consumed by the platform NextGen commitment processing job at runtime — see `GC.LastNextGenCmtProcDtTm`.

##### `InstallmentExtDayCount` — standard
- **Help:** Grace-period days a pledge installment can slip past its due date before it's counted toward `LapsedUnpaidTrxnCount`.
- **Description:** Integer, days. Consumed by the platform NextGen commitment processing job. Sets the lag between `GT.TransactionDueDate` and the engine treating the installment as truly missed.

##### `FailedTransactionCount` — standard
- **Help:** How many consecutive failed payment attempts before the engine flips `GiftCommitment.Status` to `Failing`.
- **Description:** Integer. Consumed by the NextGen commitment processing job. Pairs with `LapsedUnpaidTrxnCount`.

##### `ShouldClosePaidRcrCmt` — standard
- **Help:** When TRUE, the engine auto-closes recurring commitments once fully paid (flips `GC.Status` to `Closed`). When FALSE, closure is manual.
- **Description:** Boolean. Consumed by the NextGen commitment processing job. Recommended TRUE for FQS starter orgs.

##### `ShouldCreateRcrSchdTrxn` — standard
- **Help:** When TRUE, recurring `GiftCommitmentSchedule` rows fan out Expected `GiftTransaction` installments automatically. When FALSE, the schedule stays passive.
- **Description:** Boolean. Consumed by the NextGen commitment processing job. Recommended TRUE.

#### Family: Household soft credit automation
##### `IsHshldSoftCrAutoCrea` — standard
- **Help:** When TRUE, the engine auto-creates a `GiftSoftCredit` on the donor's Household Account for each gift given by a Person Account member of that household.
- **Description:** Boolean. Consumed by the Fundraising engine's soft-credit auto-creation logic. Pairs with `HouseholdSoftCreditRole`.

##### `HouseholdSoftCreditRole` — standard
- **Help:** The Contact Role stamped on auto-created household soft credits (e.g., `Household Member`, `Spouse`). Set to a value your `GiftSoftCredit.Role` picklist accepts.
- **Description:** String. Consumed by the Fundraising engine only when `IsHshldSoftCrAutoCrea = TRUE`.

#### Family: Donor matching / dedup
##### `DonorMatchingMethod` — standard, restricted picklist
- **Help:** How the Fundraising engine deduplicates incoming donor records on gift entry — either apply Duplicate Management rules already configured in Setup, or skip matching entirely.
- **Description:** Restricted picklist. Legal values: **Duplicate_Management_Rules**, **No_Matching**. FQS starter recommends `Duplicate_Management_Rules` paired with the shipped `FQS_Account_*` MatchingRule / DuplicateRule pair.

##### `DonorExternalIdField` — standard, restricted picklist
- **Help:** The custom External Id field on Account the Fundraising engine uses when matching donors via external identifier. FQS ships `External_Id__c` as the sole legal value.
- **Description:** Restricted picklist. Legal values: **External_Id__c** (FQS convention).

#### Family: UTM source mapping (event / online-form attribution)
##### `UtmSourceSrcObj` / `UtmSourceSrcObjField` — standard
- **Help:** The object and field pair the Fundraising engine reads *utm_source* from when auto-generating an Outreach Source Code. Leave blank to disable auto-population from this UTM parameter.
- **Description:** Consumed by the Outreach Source Code auto-generation logic keyed by `OutreachSourceCodeGenFmla`. FQS starter leaves blank.

##### `UtmMediumSrcObj` / `UtmMediumSrcObjField` — standard
- **Help:** The object and field pair the engine reads *utm_medium* from. Leave blank to disable.
- **Description:** Same pattern as `UtmSourceSrcObj`. FQS starter leaves blank.

##### `UtmCampaignSrcObj` / `UtmCampaignSrcObjField` — standard
- **Help:** The object and field pair the engine reads *utm_campaign* from. Leave blank to disable.
- **Description:** Same pattern. FQS starter leaves blank.

##### `OutreachSourceCodeGenFmla` — standard
- **Help:** The formula the Fundraising engine uses to construct an Outreach Source Code identifier from the mapped UTM fields above. Leave blank to disable auto-generation.
- **Description:** String. FQS starter leaves blank — manual OSC entry via the Gift Entry launcher is the assumed pattern.

#### Family: NextGen commitment processing job tuning
##### `IsNextGenCmtPrcsParallel` — standard
- **Help:** When TRUE, the NextGen commitment processing job runs in parallel batches. Leave FALSE for small orgs; enable for orgs processing thousands of installments per run.
- **Description:** Boolean. Parallelization increases throughput but can amplify governor-limit issues.

##### `NextGenCmtPrcsMaxThreads` — standard
- **Help:** Maximum concurrent threads the parallel NextGen job uses. Ignored when `IsNextGenCmtPrcsParallel = FALSE`.
- **Description:** Integer. Tune with Salesforce support if the job hits Apex governor limits.

##### `NextGenCmtPrcsBatchSize` — standard
- **Help:** Maximum GC records per NextGen job batch chunk. Lower for orgs with heavy triggers on GC / GCS / GT; raise for lightweight orgs.
- **Description:** Integer. Override only after profiling.

### Open follow-ups for FundraisingConfig
- FQS starter needs a documented recommended-value table for each config field. Add to `docs/fqs-setup-guide.md` §"Fundraising Engine Settings".
- Verify against a live FundFirst org whether `FundraisingConfig` allows FQS-owned `.field-meta.xml` overrides at all — some Fundraising Cloud config objects reject custom-metadata edits from unmanaged packages.
- Confirm the API surface writes UTM values in real time on the source object rather than requiring a separate lookup.
- No `.field-meta.xml` files currently exist under `force-app/main/default/objects/FundraisingConfig/` — creation step required.

---

## Object: Donor Gift Summary (`DonorGiftSummary`) — Background tier

**FQS flexipage:** `FQS_DonorGiftSummary_Record_Page.flexipage-meta.xml` (widest-surfaced page in the accelerator)
**Fields on object (FundFirst v67):** 73
**Fields recommended for help text:** 60 (56 on-flexipage + 4 off-flexipage legacy-snapshot)
**Standard fields needing FQS-owned `.field-meta.xml` created from scratch:** 48

### README post-install steps required
- None. DGS is entirely a system-written rollup surface.

### Fields deliberately skipped
- Audit / platform.
- `External_Id__c` — accelerator convention.
- **Deliberately hidden raw variants:** `FQS_Annual_Donor_Level__c`, `FQS_Lifetime_Donor_Level__c` — raw text formula returning the tier threshold; the surfaced pair `FQS_Annual_Donor_Level_Name__c` / `FQS_Lifetime_Donor_Level_Name__c` render the branded name.

### Fields with help text authored

#### Family: Identity & party

##### `Name` — standard
- **Help:** Set automatically. Auto-numbered by the platform when the NPC engine creates the Donor Gift Summary for a new donor.
- **Description:** Autonumber. One `DonorGiftSummary` per unique `DonorId`.

##### `DonorId` — standard
- **Help:** Set automatically. The person, household, or organization this summary rolls up. Do not reassign — the NPC engine owns the one-to-one link from Account to Donor Gift Summary.
- **Description:** Polymorphic lookup to Account. Written on first-gift by the NPC Donor Gift Summary engine.

#### Family: First gift / Last gift

##### `FirstGiftDate` — standard
- **Help:** Set automatically. The date of this donor's first gift. Do not hand-edit — the NPC engine reasserts this from the earliest `GiftTransaction`.
- **Description:** Written by the NPC Donor Gift Summary rollup from the oldest `GiftTransaction.TransactionDate` in Paid status.

##### `FirstGiftAmount` — standard
- **Help:** Set automatically. The Original Amount of this donor's first gift.
- **Description:** Sourced from `GiftTransaction.OriginalAmount` on the first-gift row identified by `FirstGiftDate`.

##### `FirstGiftCampaignId` — standard
- **Help:** Set automatically. The campaign attributed to this donor's first gift — useful for acquisition-source reporting.
- **Description:** Written by the NPC engine from `GiftTransaction.CampaignId` on the first-gift row.

##### `SecondGiftDate` — standard
- **Help:** Set automatically. The date of this donor's second gift. Used for first-to-second retention reporting.
- **Description:** Written by the NPC engine from the second-oldest `GiftTransaction` in Paid status.

##### `LastGiftDate` — standard
- **Help:** Set automatically. The date of this donor's most recent gift.
- **Description:** Written by the NPC Donor Gift Summary rollup from the newest `GiftTransaction.TransactionDate` in Paid status. Drives `DaysSinceLastGift`.

##### `LastGiftAmount` — standard
- **Help:** Set automatically. The Original Amount of this donor's most recent gift.
- **Description:** Sourced from `GiftTransaction.OriginalAmount` on the most-recent-gift row.

##### `FirstRecurringStartDate` — standard
- **Help:** Set automatically. The start date of this donor's first recurring gift commitment — blank if the donor has never given recurring.
- **Description:** Written by the NPC engine from the oldest recurring `GiftCommitmentSchedule.StartDate`.

##### `CurrentRecurringStartDate` — standard
- **Help:** Set automatically. The start date of the donor's currently active recurring gift commitment.
- **Description:** Written by the NPC engine from the `GiftCommitmentSchedule` referenced by `GiftCommitment.CurrentGiftCmtScheduleId` on the donor's active recurring GC.

##### `LastRecurringPaymentDate` — standard
- **Help:** Set automatically. The date of the donor's most recent recurring-gift installment payment.
- **Description:** Written by the NPC engine from the newest `GiftTransaction.TransactionDate` where the parent commitment category is Recurring.

#### Family: Largest gift

##### `HighestGiftAmount` — standard
- **Help:** Set automatically. The largest single-gift Original Amount this donor has ever given.
- **Description:** Sourced by the NPC engine from `MAX(GiftTransaction.OriginalAmount)`.

##### `LowestGiftAmount` — standard
- **Help:** Set automatically. The smallest single-gift Original Amount this donor has ever given.
- **Description:** Sourced by the NPC engine from `MIN(GiftTransaction.OriginalAmount)`.

##### `HighestGiftYearAmount` — standard
- **Help:** Set automatically. The donor's highest total giving in any single calendar year — paired with `BestGiftYear`.
- **Description:** Written by the NPC engine. Calendar-year windowed, not fiscal.

##### `BestGiftYear` — standard
- **Help:** Set automatically. The calendar year during which this donor gave the most.
- **Description:** Written by the NPC engine as a 4-digit year string ("2024"). Not fiscal-year-aware.

##### `AverageGiftAmount` — standard
- **Help:** Set automatically. The donor's average gift size across all lifetime gifts.
- **Description:** Written by the NPC engine as `TotalGiftsAmount / GiftCount`.

#### Family: Lifetime & rolling-period totals

##### `GiftCount` — standard
- **Help:** Set automatically. Lifetime count of Paid gift transactions from this donor.
- **Description:** Written by the NPC engine. Excludes soft credits.

##### `TotalGiftsAmount` — standard
- **Help:** Set automatically. Lifetime dollar total of Paid gift transactions from this donor.
- **Description:** Written by the NPC engine as `SUM(GiftTransaction.OriginalAmount)` on Paid gifts.

##### `GiftsThisYearAmount` — standard
- **Help:** Set automatically. Dollar total of this donor's Paid gifts in the current calendar year.
- **Description:** Written by the NPC engine. Calendar-year windowed. Feeds the `FQS_Annual_Donor_Level*` formula fields.

##### `GiftsLastYearAmount` — standard
- **Help:** Set automatically. Dollar total of this donor's Paid gifts in the prior calendar year.
- **Description:** Written by the NPC engine. Anchors year-over-year retention comparisons.

##### `GiftsTwoYearsAgoAmount` — standard
- **Help:** Set automatically. Dollar total of this donor's Paid gifts two calendar years ago.
- **Description:** Written by the NPC engine. Combined with `GiftsLastYearAmount` for lapsed-donor reporting.

##### `CurrentYearGiftCount` — standard
- **Help:** Set automatically. Count of this donor's Paid gifts in the current calendar year.
- **Description:** Written by the NPC engine.

##### `LastYearGiftCount` — standard
- **Help:** Set automatically. Count of this donor's Paid gifts in the prior calendar year.
- **Description:** Written by the NPC engine.

##### `LastTwoYearGiftCount` — standard
- **Help:** Set automatically. Count of this donor's Paid gifts in the trailing 24-month window.
- **Description:** Written by the NPC engine. Paired with `LastTwoYearSoftCreditCount` (off-flexipage — see open follow-ups).

##### `TotalPaidRcrInstallments` — standard
- **Help:** Set automatically. Lifetime count of Paid recurring-gift installments from this donor.
- **Description:** Written by the NPC engine. Excludes pledge installments.

##### `TotalPaidRcrInstlAmt` — standard
- **Help:** Set automatically. Lifetime dollar total of Paid recurring-gift installments from this donor.
- **Description:** Subset of `TotalGiftsAmount` filtered to recurring commitments.

##### `BookedPledges` — standard
- **Help:** Set automatically. The Expected Total Commitment Amount across all of this donor's open pledges (not yet fully paid).
- **Description:** Written by the NPC engine as `SUM(GiftCommitment.ExpectedTotalCmtAmount)` across pledge-category GCs in Active / Failing / Paused status.

##### `TotalBookableRevenue` — standard
- **Help:** Set automatically. Sum of paid gifts plus outstanding pledge balances — the total revenue "booked" from this donor.
- **Description:** Written by the NPC engine. Combines `TotalGiftsAmount` plus the unpaid portion of open pledges.

#### Family: Soft-credit rollups

##### `SoftCreditCount` — standard
- **Help:** Set automatically. Lifetime count of soft credits attributed to this donor.
- **Description:** Written by the NPC engine.

##### `LastSoftCreditAmount` — standard
- **Help:** Set automatically. The amount of this donor's most recent soft credit.
- **Description:** Sourced by the NPC engine from the most-recent soft-credit row.

##### `LastSoftCreditDate` — standard
- **Help:** Set automatically. The date of this donor's most recent soft credit.
- **Description:** Written by the NPC engine. Parity to `LastGiftDate`.

##### `FirstSoftCreditAmount` — standard
- **Help:** Set automatically. The amount of this donor's first-ever soft credit.
- **Description:** Written by the NPC engine.

##### `FirstSoftCreditDate` — standard
- **Help:** Set automatically. The date of this donor's first-ever soft credit.
- **Description:** Written by the NPC engine.

##### `HighestSoftCreditAmount` — standard
- **Help:** Set automatically. The largest single soft credit ever attributed to this donor.
- **Description:** Written by the NPC engine.

##### `HighestSoftCreditDate` — standard
- **Help:** Set automatically. The date of this donor's largest single soft credit.
- **Description:** Written by the NPC engine.

##### `TotalSoftCreditsAmount` — standard
- **Help:** Set automatically. Lifetime dollar total of soft credits attributed to this donor.
- **Description:** Written by the NPC engine.

##### `CurrentYearSoftCreditCount` — standard
- **Help:** Set automatically. Count of soft credits attributed to this donor in the current calendar year.
- **Description:** Written by the NPC engine.

##### `CurrentYearSoftCreditsAmount` — standard
- **Help:** Set automatically. Dollar total of soft credits attributed to this donor in the current calendar year.
- **Description:** Written by the NPC engine. Feeds the `FQS_Annual_Donor_Level*` formula fields when a tier's `Credit_Type__c = 'Hard + Soft Credits'`.

##### `LastYearSoftCreditCount` — standard
- **Help:** Set automatically. Count of soft credits attributed to this donor in the prior calendar year.
- **Description:** Written by the NPC engine.

##### `LastYearSoftCreditsAmount` — standard
- **Help:** Set automatically. Dollar total of soft credits attributed to this donor in the prior calendar year.
- **Description:** Written by the NPC engine.

##### `TotalHardSoftCreditsAmount` — standard
- **Help:** Set automatically. Lifetime dollar total of hard gifts plus soft credits — the combined "credited" view of this donor's giving.
- **Description:** Written by the NPC engine as `TotalGiftsAmount + TotalSoftCreditsAmount`.

##### `TotalHardSoftCredits` — standard
- **Help:** Set automatically. Lifetime count of hard gifts plus soft credits.
- **Description:** Written by the NPC engine as `GiftCount + SoftCreditCount`.

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

##### `DaysSinceLastGift` — standard
- **Help:** Set automatically. Number of days between today and this donor's most recent gift. Useful for lapsed-donor filtering.
- **Description:** Written by the NPC engine as `TODAY() - LastGiftDate`. Recalculates on the engine's rollup pass, not continuously.

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

#### Family: Legacy migration snapshots

##### `FQS_Legacy_First_Gift_Date__c` — custom
- **Help:** Set automatically at migration cutover. A one-time snapshot of the donor's first-gift date from the prior fundraising system. Do not edit after go-live — the current-system equivalent is `FirstGiftDate`.
- **Description:** Populated once during data migration by the FQS legacy-migration loader. Retained for audit / reconciliation.

##### `FQS_Legacy_Gift_Count__c` — custom
- **Help:** Set automatically at migration cutover. A one-time snapshot of the donor's lifetime gift count from the prior fundraising system. Do not edit after go-live.
- **Description:** Populated once during data migration. Retained for audit / reconciliation.

##### `FQS_Legacy_Total_Gifts_Amount__c` — custom
- **Help:** Set automatically at migration cutover. A one-time snapshot of the donor's lifetime total giving from the prior fundraising system.
- **Description:** Populated once during data migration.

##### `FQS_Legacy_Soft_Credit_Total__c` — custom
- **Help:** Set automatically at migration cutover. A one-time snapshot of the donor's lifetime soft-credit total from the prior fundraising system.
- **Description:** Populated once during data migration.

### Open follow-ups for DonorGiftSummary
- Reconcile `LastTwoYearSoftCreditCount` (off-flexipage) — surface-or-justify (soft-credit parity to the on-flex `LastTwoYearGiftCount`).
- Confirm the 4 `FQS_Legacy_*` fields are safe to remove from the flexipage post-migration.
- Verify calendar-vs-fiscal semantics on all current-year / last-year / two-years-ago / best-gift-year rollups against a seeded org.
- Confirm RFM component-score banding semantics from the Nonprofit Cloud Developer Guide.

---

## Next steps (post-authoring)

1. **Reconcile 15 off-flexipage `FQS_*` gaps** identified as "surface-or-justify" open follow-ups across Account (4 matching-gift fields), Campaign (3 hierarchy fields), Opportunity (`FQS_Skip_Naming__c`), GiftTransactionDesignation (`FQS_Restriction_Type__c`), GiftDefaultDesignation (`FQS_Restriction_Type__c`), GiftDefaultSoftCredit (`FQS_Parent_Type__c`), and OutreachSourceCode (`FQS_Message_Channel_Segment__c` + `FQS_Platform__c`).
2. **Audit shipped Campaign page layout** — `force:detailPanel` visibility gate for the 5 FQS custom fields.
3. **Emit `.field-meta.xml` files** — 211 net-new files across these 18 objects, plus rewrites on the ~30 existing files across all 21 in-scope objects (GC/GCS/GT already-authored files also need voice-rule reruns per the earlier pass).
4. **Emit README post-install steps** for the standard-field customizations that don't survive unmanaged install (Opportunity `Type` + `StageName` picklist adds, `Opportunity.CampaignId` lookup filter, `GiftTribute.HonoreeContactId` lookup filter, FundraisingConfig Setup pointer).
5. **Deploy in Foundation + FundFirst sandboxes** and hard-refresh flexipages to confirm help text renders.

