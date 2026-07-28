# FQS Reports & Dashboards Polish Plan

**Status:** design-drafted 2026-07-28 · polish pass on v1 (shipped 2026-07-18)
**Scope:** rename dashboard folder typo, rename auto-generated dashboard record, iterate on report/dashboard analytics content, plus a small backlog of new reports the seed already supports.
**Non-goals:** no new Custom Report Types (the 3 shipped CRTs are kitchen-sink and cover every field we need); no CRMA/Tableau work (that's a different skill).

---

## 1. Context

v1 shipped 2026-07-18 (see `.planning/fqs-release-readiness.md` — Custom Report Types row). What went in:

- **3 CRTs** (all `category=other`, all "kitchen-sink" column sets):
  - `fqs_Gift_Commitments_Deluxe` — baseObject `GiftCommitment`
  - `fqs_Gift_Transactions_Deluxe` — baseObject `GiftTransaction`
  - `fqs_Donor_Gift_Summary_Deluxe` — baseObject `DonorGiftSummary`
- **5 reports** — all `Summary` format + `HorizontalBar` chart:
  - `FQS_Major_Lifetime_Donors` (source: DGS, group by `Donor.Name`, filter `FQS_Is_Major_Lifetime_Donor__c=TRUE`)
  - `FQS_Major_Annual_Donors_This_FY` (DGS, group by `Donor.Name`, filter `FQS_Is_Major_Annual_Donor__c=TRUE`)
  - `FQS_Major_Gifts_This_Year` (GT, group by `Donor.Name`, filter `FQS_Is_Major_Gift__c=TRUE AND TransactionDate>=THIS_YEAR`)
  - `FQS_Major_Commitments_Active` (GC, group by `Status`, filter `FQS_Is_Major_Commitment__c=TRUE`)
  - `FQS_Mid_to_Major_Upgrade_Pipeline` (DGS, group by `FQS_Annual_Donor_Level_Name__c`, filter `FQS_Is_Mid_Annual_Donor__c=TRUE AND FQS_Is_Major_Annual_Donor__c=FALSE`)
- **1 dashboard** — `FQS_Donor_Groupings` (2×3 grid, 5 components, all `Bar` chart, `sortBy=RowValueAscending`).

The deploy proved the pipeline works. The analytics themselves need iteration — Justin's 2026-07-18 note: "this deploy proved the pipeline works, not that the analytics are right."

Related memory: [[fqs-crt-deploy-pattern]] (fields Salesforce silently rejects at CRT deploy; column tokens vs raw API names).

---

## 2. Findings from v1 audit

### 2.1 Directory / label typo — `FQS Dashborads`

- `force-app/main/default/dashboards/FQSDashborads/` and `FQSDashborads-meta.xml` (folder DeveloperName)
- `<name>FQS Dashborads</name>` inside the folder meta (folder Label)
- Every dashboard `.dashboard-meta.xml` in the folder carries the parent-folder path as its metadata key — because folder DevName is part of the fullName, renaming the folder DevName forces a matching path change on the child dashboard file. The dashboard's `<report>` element paths (e.g. `FQSDonorGroupingReports/FQS_Major_Lifetime_Donors`) reference the *report* folder, not the dashboard folder, so those don't move.

**Action:** rename local + org.
- Local: `git mv FQSDashborads → FQSDashboards`, `FQSDashborads-meta.xml → FQSDashboards-meta.xml`, edit `<name>` inside the meta.
- Org: dashboard-folder DeveloperName is not editable in the Setup UI once created. Two paths:
  - **A. Metadata API rename (recommended)** — deploy the new folder + dashboard under the new DevName; retire the old folder (delete). Requires re-issuing dashboard subscriptions and any Home-page/Lightning-page component links pointing at the old dashboard. Verify there aren't any before delete.
  - **B. Leave the org typo alone** — repo is the source of truth; org still shows "FQS Dashborads" until a future clean-org install picks up the corrected metadata.
- Chosen: **A** — clean install experience for downstream admins.

### 2.2 Auto-generated dashboard record with random-string DevName

An auto-generated dashboard record exists in the org (random-string DevName from the initial `sf project deploy start` — Salesforce assigned it when the dashboard was created via UI rather than metadata). It's orphaned from the repo. Not visible in `git status` because it's an org-only artifact.

**Action:** query it via Tooling API (`SELECT Id, DeveloperName, Title FROM Dashboard WHERE FolderId IN (SELECT Id FROM Folder WHERE DeveloperName IN ('FQSDashborads','FQSDashboards'))`), confirm it's not the canonical `FQS_Donor_Groupings`, and delete via `sf data delete record`. Add a Findings entry on the tracker.

### 2.3 Report / dashboard analytics quality

Applying the `sf-reports-dashboards` rubric (see skill file), v1 scores ~85/120 — passing the numeric floor but sub-threshold on format/grouping match, chart design, and testing. Specific gaps:

| Report | Gap | Fix |
|---|---|---|
| `FQS_Major_Lifetime_Donors` | `timeFrameFilter` uses `INTERVAL_CUSTOM` with no bounds — hidden config, admin can't tell what's applied. Also `<groupingsDown><dateGranularity>Day</dateGranularity>` on a non-date grouping is dead field. | Drop the timeFrameFilter (lifetime is by definition all-time); remove `dateGranularity` on non-date groupings. |
| `FQS_Major_Annual_Donors_This_FY` | Same `dateGranularity` on non-date grouping. Filename says "This FY" but no time filter — relies on the DGS `GiftsThisYearAmount` rollup instead of a report filter. That's actually correct (rollup already scopes to fiscal year), but the report `<description>` should call that out — currently silent. | Add description explaining the FY scope comes from the DGS rollup, not a report filter. Same `dateGranularity` cleanup. |
| `FQS_Major_Gifts_This_Year` | `TransactionDate >= THIS_YEAR` filter uses calendar year, not fiscal year. FundFirst uses standard calendar fiscal so it happens to match, but org-config-fragile. | Switch to `THIS_FISCAL_YEAR` for fiscal-config parity. |
| `FQS_Major_Commitments_Active` | Groups by `Status`, but title says "Active" — filter allows any status. Chart shows Row Count aggregated by Status, which is useful, but should be labeled as such. Also missing `NextTransactionDate` and `ExpectedTotalCmtAmount` cross-summary — a major-commitments report that doesn't show total expected pledge is missing the money question. | Add `Status IN ('Active','Failing','Paused')` filter (exclude Completed/Lapsed) to match the title; add a chart summary showing SUM(ExpectedTotalCmtAmount) alongside RowCount; sort chart by expected amount desc. |
| `FQS_Mid_to_Major_Upgrade_Pipeline` | Grouped by `FQS_Annual_Donor_Level_Name__c` but the mid-donor cohort by definition falls under one level ("Mid Annual Donor") — grouping produces a single bar. Wrong dimension. | Group by `Donor.Name` (individual mid donors trending toward major), sort by `GiftsThisYearAmount` desc, top 25. |

### 2.4 Dashboard component issues

| Component | Issue | Fix |
|---|---|---|
| All 5 | `<sortBy>RowValueAscending</sortBy>` — smallest bar first. Convention for donor / gift charts is largest first (RowValueDescending). | Flip to `RowValueDescending`. |
| Component 1 (Major Lifetime Donors) | Bar chart with 20+ donors renders as tiny bars; better as a Lightning Table with formatted amounts. | Keep Bar for top-10, add a companion Lightning Table below with all rows. Alternatively: `topRows=10` on the report and rename to "Top 10 Major Lifetime Donors". |
| Component 4 (Major Commitments Active) | Uses `RowCount` grouped by `Status` — a Metric or Gauge would communicate "N major pledges outstanding" much better than a bar chart with 3 rows. | Change `<componentType>` to `Metric` with `chartSummary.column=RowCount`, format as integer; add second Metric with `SUM(ExpectedTotalCmtAmount)` formatted as currency. Split the 6-col component into two 6-col Metrics. |
| Component 5 (Mid to Major Upgrade) | 12-col-wide bar chart on a single-bucket dimension is wasted real estate. | After Report §2.3 fix (group by Donor.Name), keep 12-col + Bar; add legend showing GiftsThisYearAmount + LastGiftDate. |
| Running user | `<runningUser>justinsgilmore-snmm@force.com</runningUser>` (personal scratch email). Doesn't exist in FundFirst; won't exist in any subscriber org. Currently the org must have re-pointed at Justin's admin user. | Use `<dashboardType>LoggedInUser</dashboardType>` (dynamic) — each viewer sees their own scope. Falls back to viewer's access; fundraisers see donors they own, exec sees org-wide. Costs a Dynamic Dashboard license slot per org, but every FQS-target org will have one available. |

### 2.5 Report-level charts — CORRECTION (2026-07-28 audit)

**Original claim (draft):** only `FQS_Major_Lifetime_Donors` carried a `<chart>` block. **Actual v1 state:** all 5 v1 reports already ship with matching `<chart>` blocks — the draft was based on a single-file spot check. P4 was consequently a no-op during execution; P2's Mid-to-Major regrouping did update that report's chart `groupingColumn` in the same file edit, which is the only chart-level change that was needed.

No action required — leaving §2.5 documented so future readers see the correction rather than the mistaken original claim.

---

## 3. New reports the seed already supports

The 2026-07-27 and -07-28 seed passes added coverage that the current 5-report set doesn't yet exercise. Two clearly earning additions:

### 3.1 Stewardship pipeline health

**Report:** `FQS_Stewardship_Pipeline` (GT base, `fqs_Gift_Transactions_Deluxe` CRT)
- Format: Matrix
- Row group: `FQS_Stewardship_Status__c` (Sent / To Be Sent / Don't Send / null)
- Col group: `Category` (Contribution / Fee/Payment — filter to Contribution)
- Filter: `Status='Paid' AND TransactionDate >= LAST_N_MONTHS:6`
- Aggregates: RowCount + SUM(CurrentAmount)
- Chart: Stacked Column, groupingColumn = `FQS_Stewardship_Status__c`

**Why:** the two-flow ack/stewardship shape landed 2026-07-26; there's no visibility yet into how many gifts are stuck in "To Be Sent" past SLA. This report is the primary operational surface for that.

### 3.2 Campaign performance rollup

**Report:** `FQS_Campaign_Performance_By_Depth` (GT base)
- Format: Summary
- Group: `Campaign.FQS_Hierarchy_Depth__c` (1-5 seeded)
- Filter: `Status='Paid' AND Campaign.IsActive=TRUE`
- Aggregates: SUM(CurrentAmount) + COUNT(Donor.Id, distinct-count via bucket approach — or `Distinct Values` measure)
- Chart: Vertical Bar

**Why:** validates that the hierarchy filter (2026-07-26 lookup filter on GT.CampaignId / GC.CampaignId, `FQS_Hierarchy_Depth__c >= 3`, isOptional) is being honored. If most rows land on depth 3 (asks), the filter is working; if not, admins are attributing to rollups and skewing performance metrics.

### 3.3 Deferred — hold for later polish rounds

- **Recurring giving retention** — needs `FQS_Recurring_Status_At_Snapshot__c` (doesn't exist). Wait until we ship a rolling snapshot.
- **Corporate match funnel** — needs the match screen flow (fqs-corporate-match-plan.md, still not built) to produce data.
- **Refund audit** — `fqs-gift-refund-plan.md` shipped 2026-07-23 but seed doesn't yet distinguish refunded from originally-Failed rows in a query-friendly way. Deferrable.
- **Fund of Funds / by-designation performance** — depends on the designation hierarchy plan (10 open questions parked for Justin).

---

## 4. Phased execution

Bloat-guard rule: each phase should ship as its own commit so a bad polish pass can be reverted without unraveling the folder rename.

### Phase P1 — Folder rename + orphaned-dashboard cleanup

Contract: repo + org both use `FQSDashboards`; only the canonical `FQS_Donor_Groupings` dashboard exists in the folder.

Steps:
1. Local `git mv` folder + folder-meta; edit `<name>` inside meta. ✅ **(done 2026-07-28)**
2. Deploy new folder + dashboard as new DevName to FundFirst.
3. Query Tooling API for extra Dashboard records in the old folder.
4. Delete orphaned dashboard via `sf data delete record`.
5. Delete old `FQSDashborads` folder via destructiveChanges.
6. Verify subscriptions / Lightning page component references — none expected but confirm.

### Phase P2 — Report content fixes (per §2.3)

Ship as one deploy. Each report's XML edits are small; the risk is per-report rather than cross-cutting.

### Phase P3 — Dashboard component fixes (per §2.4)

Sort direction, Metric conversion for Component 4, running-user flip to LoggedInUser. One deploy.

### Phase P4 — Report-level chart blocks (per §2.5)

Add `<chart>` block to each of the 5 reports so they render usefully outside the dashboard. One deploy.

### Phase P5 — New reports (§3.1 + §3.2)

Ship each new report as its own deploy so it can be UAT'd independently. Add both to the dashboard as additional components (dashboard now 7 components; consider re-layout to 3-column grid or keep 2-col at longer height).

### Phase P6 — Documentation

Update `README.md` §III (Analytics) or add a new "Reports & Dashboards" subsection listing the 5+2 shipped reports and the 1 dashboard with a one-liner per report explaining what question it answers. Non-negotiable per [[readme-standard-field-edits]] — but this is package-owned metadata, not standard-field edits, so it's a nice-to-have vs. mandatory README addition. Include the "install the FQS_Custom_Fields permset before running reports" note if not already there.

---

## 5. Rubric self-score after full plan lands

Applying `sf-reports-dashboards` rubric (120 pts, passing = 90):

| Category | Max | Post-polish score | Rationale |
|---|---|---|---|
| Report Type correctness | 20 | 18 | 3 CRTs cover 3 base objects cleanly; kitchen-sink column bloat costs 2 pts |
| Format and grouping match | 20 | 18 | After §2.3 fixes: Summary where appropriate, Matrix for stewardship, no over-Matrixing |
| Filter correctness | 20 | 17 | THIS_FISCAL_YEAR swap, Status filter on Commitments, description of implicit filters |
| Chart and dashboard design | 20 | 17 | RowValueDescending, Metric for count-of-active, LoggedInUser running user |
| Folder, sharing, and access | 15 | 13 | Renamed folder, `Shared` access type retained, `ReadWrite` public-folder default OK for admin-only pkg |
| Subscription and delivery | 10 | 7 | Not adding subscriptions in this pass; passing baseline via visitable dashboard |
| Testing and performance | 15 | 13 | Row-level spot-check + LoggedInUser test as User A/B/exec |

**Projected total: 103/120.**

---

## 6. Open questions

- **Q1:** Should we introduce a second dashboard folder for "operational" (stewardship pipeline, campaign performance) vs "major donor" (existing 5 components)? Or one dashboard folder with two dashboards? Simplicity argues one folder, two dashboards.
- **Q2:** Dynamic Dashboards cost a per-org license slot. Is that acceptable for the FQS install baseline, or should the running user default to a documented "FQS Reporting" user (a permset-bound integration-style user)?
- **Q3:** Do we need to ship a `Lightning Table` component for the top-25 donor listing, or is a `Bar` chart limited to top-10 + drill-to-report acceptable?
- **Q4:** Should the 5 report `<groupingsDown><dateGranularity>Day</dateGranularity>` on non-date groupings be treated as a Salesforce-authored quirk (Report Builder emits it defensively) or scrubbed as bloat? Safer to scrub — grep other repos.

---

## 7. Blast radius / commit boundaries

Nothing here touches:
- Launcher flow XMLs (wizard gate holds)
- Seed generator (seed agent's territory)
- Any Salesforce-owned standard field (no [[readme-standard-field-edits]] triggers)
- Any permset (existing report/dashboard access is folder-driven, not FLS-gated)

Cross-cutting risk zero. This is a self-contained analytics polish pass — safe to run in parallel with the wizard + seed agents.

---

## 8. Handoff-ready sub-tasks (if delegated)

If splitting across sub-agents:
- **Agent A:** P1 (folder rename + org cleanup) — self-contained, ~20 min
- **Agent B:** P2 + P3 + P4 (report edits + dashboard edits + report charts) — one bundle, ~40 min
- **Agent C:** P5 (2 new reports + dashboard reshape) — ~30 min

P6 (README) stays with the parent so voice + placement stays consistent with the rest of the README.
