# Donor Groupings v2 — Build Plan

Status: Approved, ready to build.
Owner: Justin Gilmore
Last updated: 2026-07-06

## Goal

Extend the existing `FQS_Donor_Grouping__mdt` from single-scope (lifetime only) into a three-scope classification system (One-Time / Annual / Lifetime) surfaced as boolean formulas across DonorGiftSummary, GiftTransaction, GiftCommitment, Account, and Contact. Add admin tooling (screen flow + setup page), reports, and a dashboard.

## Design principles

- **Boolean-first.** No new calculated amount fields. All classification is checkbox formulas over existing amount fields + MDT thresholds.
- **Retroactive recalc.** Editing MDT values updates all downstream formulas immediately. Every new field's description and help text says so.
- **Installment inheritance.** A GiftTransaction that is a payment against a large GiftCommitment inherits the parent commitment's tier — a $500 installment on a $50k pledge flags as Major.
- **Hard credit only (v1).** Soft-credit recognition tier is deferred.
- **Fiscal year for Annual scope.** Uses org-configured fiscal year; source field verified during build (fall back to calendar if NPC exposes only calendar-year rollup, and flag for follow-up).

## Thresholds

| Tier            | One-Time  | Annual   | Lifetime  |
|-----------------|-----------|----------|-----------|
| Entry (Friend)  | $25       | $100     | $300      |
| Mid (Partner)   | $500      | $1,000   | $3,000    |
| Major (Champion)| $5,000    | $10,000  | $30,000   |

- Lifetime = 3× Annual (three years of consistent giving = lifetime tier promotion).
- Sub-Entry (below $25 one-time, below $100 annual, below $300 lifetime) → no tier, formula returns `""`.

## Custom Metadata Type changes

**Object:** `FQS_Donor_Grouping__mdt`

**Add fields (Number 18,2):**
- `One_Time_Min_Amount__c` — label "One-Time Minimum Amount"
- `Annual_Min_Amount__c` — label "Annual Minimum Amount"
- `Lifetime_Min_Amount__c` — label "Lifetime Minimum Amount"

**Deprecate:** `Min_Amount__c` — update description to note deprecation, keep for one release.

**Records to update:** `Entry`, `Mid`, `Major` — populate all three new fields per threshold table.

## Field description / help text standard

**Description (admin):**
> Boolean formula that returns TRUE when [source amount field] meets or exceeds the [Tier].[Scope]_Min_Amount__c value in FQS_Donor_Grouping custom metadata. Thresholds are configured via Setup → Custom Metadata Types → FQS Donor Grouping or the FQS Donor Grouping Configurator screen flow. Changing threshold values in Setup or via the configurator flow recalculates this field across all records retroactively — no redeployment or batch job required. Reports and dashboards using this field will reflect the new values immediately.

**Help text (end user):**
> Automatically calculated. Marked TRUE when this [record type]'s [amount context] qualifies for the [tier name] giving tier. Your administrator controls the threshold amounts.

Apply this pattern to every new boolean and text formula, adjusted for the specific source field and scope.

## Object-by-object field additions

### DonorGiftSummary

**Rename existing fields for scope clarity:**
- `FQS_Donor_Level__c` → `FQS_Lifetime_Donor_Level__c` (label: "Lifetime Donor Grouping")
- `FQS_Donor_Level_Name__c` → `FQS_Lifetime_Donor_Level_Name__c` (label: "Lifetime Donor Grouping Name")
- Rewire to `Lifetime_Min_Amount__c`; add sub-Entry → `""` branch.

**Add annual text formulas** (over fiscal-year giving field; verify NPC source during build):
- `FQS_Annual_Donor_Level__c`
- `FQS_Annual_Donor_Level_Name__c`

**Add lifetime booleans** (off `TotalGiftsAmount`):
- `FQS_Is_Entry_Lifetime_Donor__c`
- `FQS_Is_Mid_Lifetime_Donor__c`
- `FQS_Is_Major_Lifetime_Donor__c`

**Add annual booleans** (off fiscal-year total):
- `FQS_Is_Entry_Annual_Donor__c`
- `FQS_Is_Mid_Annual_Donor__c`
- `FQS_Is_Major_Annual_Donor__c`

**List view update:** `FQS_Major_Donors` — refilter on `FQS_Is_Major_Lifetime_Donor__c = TRUE`.

### GiftTransaction

**Add booleans off `CurrentAmount`, installment-aware:**
- `FQS_Is_Entry_Gift__c` = `CurrentAmount >= Entry.One_Time_Min_Amount__c || GiftCommitment.ExpectedTotalCmtAmount >= Entry.Lifetime_Min_Amount__c`
- `FQS_Is_Mid_Gift__c` — same pattern, Mid thresholds
- `FQS_Is_Major_Gift__c` — same pattern, Major thresholds

Add to record page FlexiPage. New list view "Major Gifts YTD".

### GiftCommitment

**Add booleans off `ExpectedTotalCmtAmount` (Lifetime thresholds — GiftCommitment has no CurrentAmount field):**
- `FQS_Is_Entry_Commitment__c`
- `FQS_Is_Mid_Commitment__c`
- `FQS_Is_Major_Commitment__c`

Add to record page FlexiPage.

### Account & Contact

**Cross-object booleans from DonorGiftSummary (via `DonorId` lookup):**
- Lifetime: `FQS_Is_Entry_Lifetime_Donor__c`, `FQS_Is_Mid_Lifetime_Donor__c`, `FQS_Is_Major_Lifetime_Donor__c`
- Annual: `FQS_Is_Entry_Annual_Donor__c`, `FQS_Is_Mid_Annual_Donor__c`, `FQS_Is_Major_Annual_Donor__c`

Surface on Account/Contact FlexiPage highlights panel.

## Screen Flow: `FQS_Donor_Grouping_Configurator`

**Purpose:** Allow admins to update tier thresholds and branded names without navigating Setup.

**Scope:** Edit thresholds AND Branded Name from same flow (no checkbox gate — full config surface).

**Screens:**

1. **Pick tier** — Radio: Entry / Mid / Major. Get Records loads the selected `FQS_Donor_Grouping__mdt` record. Display current Branded Name + all 3 thresholds read-only for context.
2. **Edit values** — Inputs: `Branded_Name__c`, `One_Time_Min_Amount__c`, `Annual_Min_Amount__c`, `Lifetime_Min_Amount__c`. Display-text warning:
   > **Heads up:** Changing these thresholds recalculates Donor Grouping across all Donor Gift Summary, Gift Transaction, Gift Commitment, Account, and Contact records immediately. Reports and dashboards will reflect the new values retroactively.
3. **Confirm + submit** — Read-only summary. Custom Metadata Types record action updates the MDT (Flow-native CMDT update deploys on save). Success screen links to the reports folder.

## Lightning App Page: `FQS_Setup_Configuration`

**Purpose:** Central setup-config surface inside the `Fundraising_Quick_Start` app.

**Layout:**
- Header — "Fundraising Quick Start — Setup Configuration" with short description.
- **Donor Groupings section** — embedded `FQS_Donor_Grouping_Configurator` flow + a read-only "current thresholds" table showing all 3 records.
- **Reports quick links section** — link block to `FQS Donor Groupings` reports folder + dashboard.
- Named regions for future setup tools (fiscal-year override, tribute types, refund reason codes) without layout shuffle.

**Wiring:**
- Add custom tab pointing to this FlexiPage.
- Add tab to `Fundraising_Quick_Start` app navigation labeled "Setup".
- Gate visibility to FQS admin permission set / System Administrator profile (via tab visibility on profile).

## Reports — folder `FQS Donor Groupings`

1. **Major Lifetime Donors** — DonorGiftSummary, `FQS_Is_Major_Lifetime_Donor__c = TRUE`. Columns: Donor, TotalGiftsAmount, LastGiftDate.
2. **Major Annual Donors — This Fiscal Year** — DonorGiftSummary, `FQS_Is_Major_Annual_Donor__c = TRUE`.
3. **Major Gifts — This Fiscal Year** — GiftTransaction, `FQS_Is_Major_Gift__c = TRUE` + fiscal-year date filter. Includes commitment-inherited majors.
4. **Major Commitments — Active** — GiftCommitment, `FQS_Is_Major_Commitment__c = TRUE`, grouped by Status.
5. **Mid → Major Upgrade Pipeline** — DonorGiftSummary, `FQS_Is_Mid_Annual_Donor__c = TRUE AND FQS_Is_Major_Annual_Donor__c = FALSE`, sorted by proximity to Major annual threshold.

## Dashboard `FQS Donor Groupings Overview`

Six components:

1. Donor count by lifetime tier (donut chart) — Major / Mid / Entry.
2. Donor count by annual tier — fiscal YTD (donut chart).
3. Total giving $ by lifetime tier (horizontal bar).
4. Major gifts fiscal YTD — count + total $ (metric widget).
5. Major commitments active — count + total pledged (metric widget).
6. Mid → Major upgrade table (top 20 mid annual donors closest to Major threshold).

## Build order

1. Extend MDT — add 3 new fields with description + help text (retroactive-recalc warning); populate 3 records with threshold values.
2. DonorGiftSummary — rename existing lifetime formulas (rewire to `Lifetime_Min_Amount__c`, add sub-Entry branch); add annual text formulas; add 6 booleans. Description + help text on every field.
3. GiftTransaction booleans (cross-object to GiftCommitment, off `CurrentAmount`). Description + help text.
4. GiftCommitment booleans (off `ExpectedTotalCmtAmount`). Description + help text.
5. Account & Contact cross-object booleans. Description + help text. Wire into FlexiPages.
6. Grep for callers of renamed DonorGiftSummary fields (reports, list views, permission sets, other formulas). Update all in same commit.
7. Build screen flow `FQS_Donor_Grouping_Configurator`.
8. Build FlexiPage `FQS_Setup_Configuration` (App Page) with flow embedded, current-thresholds display, reports quick links.
9. Add "Setup" nav tab to `Fundraising_Quick_Start` app pointing to the new page; gate visibility to admin profile/perm set.
10. Build 5 reports in `FQS Donor Groupings` folder.
11. Build dashboard `FQS Donor Groupings Overview` (6 components).
12. Deploy + validate — test the flow updating a threshold end-to-end; confirm formulas recalc across DonorGiftSummary, GiftTransaction, GiftCommitment, Account, Contact.

## Risks / verify during build

- **Fiscal-year source field on DonorGiftSummary.** NPC may only expose calendar-year rollup (`CurrentYearGiftsAmount`). If no fiscal variant exists, derive via a formula using `$Organization.FiscalYearStartMonth`. If that's blocked, fall back to calendar year with a comment for follow-up.
- **Field rename cascade.** Renaming `FQS_Donor_Level__c` → `FQS_Lifetime_Donor_Level__c` breaks external references. Grep all metadata (reports, list views, permission sets, other formula fields, page layouts, FlexiPages) before the rename and update in the same commit.
- **CMDT update via Flow.** Flow-native CMDT record actions were added in Winter '24 (API 59+) and deploy asynchronously — success screen may show before deploy completes. Validate the flow's behavior during step 12 and adjust messaging if there's a visible delay.

## Deferred (not v1)

- Sticky "Highest Ever Annual Tier" — parked until reactivation-list use case emerges.
- Recognition tier from soft credits — parked until soft-credit data model is exercised.
- Fiscal-year variants beyond the org's default — only one fiscal year supported in v1.
