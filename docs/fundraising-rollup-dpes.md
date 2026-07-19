# DonorGiftSummary — Data Processing Engine Definition

This is a **Fundraising DPE** that maintains the standard **`DonorGiftSummary`** rollup object — the per-donor "everything you'd ever want to know about their giving history" record that powers donor pages, dashboards, moves-management screens, and segmentation. It runs in **batch on CRM Analytics** and refreshes ~40 aggregate fields per donor from raw `GiftTransaction`, `GiftSoftCredit`, and `GiftCommitment` records.

## What it actually produces

For every donor (Account) and soft-credit recipient, it computes and writes back these buckets:

| Bucket | Fields |
|---|---|
| **Lifetime giving** | `GiftCount`, `TotalGiftsAmount`, `HighestGiftAmount`, `LowestGiftAmount` |
| **First / second / last gift** | `FirstGiftDate`, `FirstGiftAmount`, `FirstGiftCampaignId`, `SecondGiftDate`, `LastGiftDate`, `LastGiftAmount` |
| **Best year** | `BestGiftYear`, `HighestGiftYearAmount` (the calendar year with the largest total) |
| **Year-over-year totals** | `GiftsThisYearAmount` / `CurrentYearGiftCount`, `GiftsLastYearAmount` / `LastYearGiftCount`, `GiftsTwoYearsAgoAmount` / `LastTwoYearGiftCount` |
| **Recurring** | `FirstRecurringStartDate`, `LastRecurringPaymentDate`, `CurrentRecurringStartDate` (earliest open commitment), `TotalPaidRcrInstlAmt`, `TotalPaidRcrInstallments` |
| **Soft credits** (parallel set) | `SoftCreditCount`, `TotalSoftCreditsAmount`, first/last/highest soft credit + amount + date, and current/last/last-two-year counts & amounts |
| **Combined** | `TotalHardSoftCredits`, `TotalHardSoftCreditsAmount` |
| **Pipeline** | `BookedPledges` (sum of written commitments), `TotalBookableRevenue` (paid + booked − already-counted-written), `Total_Written_Formal_Transaction_Amount` |

## The household roll-up trick (the big idea)

The most important pattern here — and what distinguishes it from a naive rollup — is how it **rolls Person Account gifts up to the Household**:

1. Pull `PartyRelationshipGroup` filtered to `Type = 'Household'` → this is the **Households** dataset.
2. Pull `AccountContactRelation` → maps Person Contact → Household Account.
3. For each of `GiftTransaction`, `GiftSoftCredit`, `GiftCommitment`:
   - **`Members_*`** node: inner-join to `AccountContactRelation` on the Contact ID → attaches the household to each gift/commitment given by a household member.
   - **`*_swap_HouseholdId`** node: inner-join to `Households` → **replaces the individual donor's Id with the Household Id** so the record rolls up to the household instead.
4. **`Add_Member_*_to_Household`** (`appends`): unions the swapped-to-household records with the original non-Person-Account records → downstream aggregations see both organizational giving and household-member giving under one donor Id.

That's why every donor summary aggregation is done twice: once at the individual/organizational donor level, and once with member gifts re-parented to the household.

## Soft-credit de-duplication

`Replicate_GiftTransactionId` → `Find_Unique_Soft_Credits` → `Filter_Unique_Soft_Credits` handles a subtle case: if two members of the same household both received a soft credit for the same `GiftTransaction`, the household would double-count it. It uses `LEAD({GiftTransactionId})` partitioned by `RecipientId` to detect adjacent duplicates and keeps only one row per gift per household.

## The pipeline in three phases

### Phase 1 — Prepare the inputs
- Filter `GiftTransaction` to `IsPaid = true`; filter `GiftSoftCredit` to `IsPaid = true`.
- Filter out future-dated transactions (`Days_Since_Transaction >= 0`).
- Union individual + swapped-household gifts (the appends step above).

### Phase 2 — Compute aggregates in parallel
Two large parallel branches, one for gifts and one for soft credits, each computing:
- **Group by donor** — sum, min, max, count.
- **Year windows** — filter to `CURRENT_CALENDAR_YEAR` / `LAST_CALENDAR_YEAR` / `LAST_TWO_CALENDAR_YEAR` (Date parameters passed in at runtime), then aggregate.
- **Ordinal facts** — use `ROWNUMBER()` partitioned by donor ordered by date/amount, then filter `RowNumber = 1` to get "first gift", "last gift", "highest soft credit", "first soft credit" etc.
- **Best year** — sub-aggregate by `(DonorId, Year)` using `SUBSTR(TransactionDate, 0, 4)`, take the max, join back to find which year hit the max.
- **Recurring** — filter gifts where `ScheduleType = 'Recurring'`, aggregate min/max/sum/count; separately compute `Current_Recurring_Start_Date` from commitments where `Status != 'Closed'`.
- **Written pledges** — `Booked_Pledges` = sum of `ExpectedTotalCmtAmount` on commitments with `FormalCommitmentType = 'Written'`.

### Phase 3 — Merge, upsert, delete
- Merge the transaction and soft-credit branches on `DonorId = RecipientId` (a full **Outer** join, so a donor with only soft credits still gets a row).
- `Merge_Donor_Id_Field` coalesces to a single `Donor_Or_Recipient_Id`.
- `Calculate_Total_Bookable_Revenue`: `TotalGiftAmount + BookedPledges − TotalWrittenFormalTransactionAmount` (avoids double-counting paid written pledges).
- `Order_by_AccountId` + `Filter_Unique_And_Valid_Donor_Gift_Summary` deduplicates by `RowNumber=1` per donor and drops null donor IDs.
- **Left-join** against existing `DonorGiftSummary` records to determine insert vs. update.

Three writebacks fire (in order):
1. **Insert** — new summaries where no existing record was found.
2. **Update** — existing summary Id + fresh values.
3. **Delete** — summaries whose donor no longer has any qualifying gifts (e.g., all transactions refunded, no soft credits) — `Donor_Gift_Summary_Id IS NOT NULL AND Donor_Or_Recipient_Id IS NULL`.

## Why it's structured this way

- **`processType: Fundraising` + `executionPlatformType: CRMA` + `definitionRunMode: Batch`** — it's the standard Fundraising Operations pattern: heavy analytical pipelines are pushed to CRMA and materialized back to sObject rows so page layouts and reports can query them cheaply.
- **Three date parameters (`CURRENT_CALENDAR_YEAR`, `LAST_CALENDAR_YEAR`, `LAST_TWO_CALENDAR_YEAR`)** — provided at run time by whatever schedules this (a flow or Apex scheduler), so year boundaries are decided by the caller rather than baked into the definition. Contrast with the `CreatePartyCategories` DPE, which reads `FiscalYearSettings` directly and uses fiscal (not calendar) year.
- **Outer joins between transaction and soft-credit branches** — ensures pure-soft-credit recipients (people who never gave directly but were credited) still get a `DonorGiftSummary` row.
- **The "insert + update + delete" triad** — makes this idempotent and self-healing: rerunning it always converges to the correct state, no matter what the previous state looked like.

Together with `CreatePartyCategories`, these two DPEs form the **standard nightly rollup pair** for Fundraising Cloud: one classifies donors into lifecycle segments (LYBUNT/SYBUNT/Lapsed), the other maintains their giving-history rollup fields. Both are batch-idempotent and template-based (`isTemplate: true`) so orgs inherit and can extend them.

---

# OutreachSummary — Data Processing Engine Definition

This is the **campaign-side counterpart** to `DonorGiftSummary`. Where `DonorGiftSummary` rolls giving up to the **donor**, this DPE rolls it up to the **outreach**: every `Campaign` and every `OutreachSourceCode` gets a maintained `OutreachSummary` row summarizing how it performed. It powers campaign dashboards, source-code A/B analyses, direct-mail ROI reports, and any "which appeal is working?" screen. It runs in the same **batch on CRM Analytics** mode as the other Fundraising rollup DPEs.

## What it actually produces

For every `Campaign` and every `OutreachSourceCode` that has activity, it writes back:

| Bucket | Fields |
|---|---|
| **Donor counts** | `DonorCount` (unique donors), `OnetimeDonorCount`, `RecurringDonorCount` |
| **Gift volume** | `GiftCount` (paid transactions), `TotalGiftTransactionAmount` |
| **Split by schedule** | `TotalOnetimeGiftAmount` (paid gifts with no commitment), `TotalRecurringGiftAmount` (paid gifts against a commitment where `ScheduleType = 'Recurring'`) |
| **Effectiveness** | `ResponseRate` = `CEIL(DonorCount / AudienceCount × 100)` |
| **Attribution** | `AttributedAmount` = `TotalOnetimeGiftAmount` + amortized recurring-pledge value earned during the campaign/source-code window |

Two writeback rows per outreach: one keyed by `CampaignId` (aggregate across all its source codes) and one keyed by `OutreachSourceCodeId` (aggregate for that specific tactic/list/segment).

## The two-dimensional bifurcation (the big idea)

Where the `DonorGiftSummary` DPE bifurcated to solve household roll-up, this DPE bifurcates on **two orthogonal dimensions of "outreach"**:

1. **Campaign** — the marketing container ("Spring Appeal 2026").
2. **OutreachSourceCode** — a specific execution of that campaign to a defined audience ("Spring Appeal 2026 — Lapsed Household direct mail, list v3"). Every gift can be tagged with both.

The pipeline literally runs each aggregation path twice — once grouping by `CampaignId`, once grouping by `OutreachSourceCodeId` — and produces two independent `OutreachSummary` records. That's why nearly every node has a `_Campaign_*` / `_Source_Code_*` twin: `Sum_on_Campaign_All_Paid` ↔ `Sum_on_Source_Code_All_Paid`, `Filter_on_Campaign_Recurring_Paid` ↔ `Filter_on_Source_Code_Recurring_Paid`, and so on.

## Splitting one-time vs recurring giving

Every paid `GiftTransaction` is left-joined to its `GiftCommitment` so `ScheduleType` (Recurring / Installment / One-time / null) is available downstream. From `Filter_on_Campaign_All` (or `Filter_on_Source_Code_All`), the pipeline forks three ways:

- **All Paid** — everything.
- **Onetime Paid** — `GiftCommitmentId IS NULL` (no commitment behind it → true one-off gift).
- **Recurring Paid** — `ScheduleType = 'Recurring'` (paid installments of an active recurring pledge).

Each fork aggregates independently (sum of `CurrentAmount`, unique count of `DonorId`, count of gifts), then the three are stitched back together with cascading left joins: `Join_Campaign_All_Onetime_Paid` → `Join_Campaign_All_Onetime_Recurring_Paid`. Same shape on the source-code side.

## Recurring-pledge attribution (the subtle part)

One-time gifts are easy to attribute: the gift already carries a `CampaignId` and `OutreachSourceCodeId`, so summing `CurrentAmount` gives you what the campaign earned. Recurring pledges are harder — a donor who signs up for $25/month during "Spring Appeal 2026" keeps giving forever, and you want the campaign credited only for the value it actually generated (not the whole lifetime), and only while the pledge is active.

The pipeline solves this using `GiftCmtChangeAttrLog` (Gift Commitment Change Attribution Log), which records `ChangePerDayAmount` — the daily value of an adjustment — for every change to a commitment schedule:

1. **`Get_Latest_Start_and_End_Date`** — for each `GiftCommitmentId`, find the max effective start and end date of its schedules.
2. **`Get_Most_Recent_Active_Date`** — clamp to today if the pledge is still active (`CurrentGiftCmtScheduleId` is not null, or the end date is in the future, or the start is future/inverted).
3. **`Get_Number_of_Days_Pass`** — `DATEDIFF(MostRecentActiveDate, EffectiveDate)` — how many days this attribution line has been in effect.
4. **`Get_Attribute_Amount_Per_Change_Attr_Log`** — `NumberOfDaysPass × ChangePerDayAmount` — the dollar value earned during that window.
5. Aggregate by `CampaignId` and `OutreachSourceCodeId` to get `CampaignAttributedAmount` / `SourceCodeAttributedAmount`.

Finally, `Calculate_CampaignId_and_Attributed_Amount` combines the two revenue streams into a single field:

```
TotalAttributedAmount = Sum_on_Campaign_Onetime  +  CampaignAttributedAmount
                        (one-off cash gifts)       (recurring earned-to-date)
```

Same math on the source-code side. This is why the final joins are **Outer** and not LeftOuter: a campaign might have only recurring-pledge attribution (no direct paid gifts yet) or only one-time gifts (no active pledges) — either side needs to survive.

## Response rate

`ResponseRate` requires an audience size, which lives on `OutreachSourceCode.AudienceCount` (how many people the appeal was actually sent to). For source-code rows, it's a direct join. For campaign rows, `Group_Audience_Size_by_Campaign` sums `AudienceCount` across all source codes belonging to the campaign, giving a campaign-wide denominator. The response-rate formula:

```
ResponseRate = CEIL(UniqueDonorCount / AudienceCount × 100)
```

Guarded with null / zero checks so unmailed or unpopulated campaigns just leave the field null rather than dividing by zero.

## The pipeline in three phases

### Phase 1 — Prepare the inputs
- Filter `GiftTransaction` to `IsPaid = true`.
- Left-join `GiftCommitment` to attach `ScheduleType`.
- Filter Change Attribution Log rows to those that reference a `GiftCommitmentScheduleId`.

### Phase 2 — Two parallel aggregation towers
For **Campaign** and **OutreachSourceCode** in parallel:
1. Split the paid-gift stream into All / Onetime / Recurring.
2. Aggregate each split (unique donors, gift count, sum of amount).
3. Cascade-left-join the three splits so every campaign/source-code carries `Sum_All`, `Sum_Onetime`, `Sum_Recurring`, and the matching donor counts on a single row.
4. Join in audience count (`AudienceCount` per source code; `CampaignAudienceCount` = sum for the campaign side).
5. Outer-join in the recurring-pledge attribution amount.
6. Compute `ResponseRate` and `TotalAttributedAmount` per outreach.

### Phase 3 — Merge, upsert, delete
- Outer-join each aggregate stream against the existing `OutreachSummary` table filtered to that dimension (`CampaignId IS NOT NULL` for the campaign side, `OutreachSourceCodeId IS NOT NULL` for the source-code side).
- **`Filter_Updated_*`** — rows where the new aggregate still has a valid outreach id → **Upsert** (updates existing summary Id or inserts a new one).
- **`Filter_Outdated_*`** — rows where an existing `OutreachSummary` Id still exists but the aggregate side is now null (no more qualifying gifts) → append into `Append_Outdated_Outreach_Summary` → **Delete**.

Three writebacks fire in sequence: upsert campaign summaries, upsert source-code summaries, delete stale summaries.

## Why it's structured this way

- **Same platform stack as `DonorGiftSummary`** (`processType: Fundraising` + `executionPlatformType: CRMA` + `Batch` + `isTemplate: true`) — this is the sibling analytical pipeline; both are expected to run on the same schedule so donor and campaign rollups stay consistent.
- **Symmetric campaign/source-code branches** — because a single record type (`OutreachSummary`) serves both aggregation dimensions with `CampaignId` and `OutreachSourceCodeId` as alternate keys. Splitting the pipeline this cleanly means each dimension's writeback can be reasoned about (and extended) independently.
- **Attribution log instead of raw commitment amount** — using `GiftCmtChangeAttrLog.ChangePerDayAmount × days-active` gives correct time-boxed revenue credit even when a donor upgrades or cancels their pledge mid-campaign. Just summing `ExpectedTotalCmtAmount` would over-credit whichever campaign happened to sign the donor up.
- **Outer joins for the recurring-attribution merge** — a brand-new recurring pledge with no paid installments yet still needs to show attributed revenue against its source code. A campaign that only ran one-time appeals still needs a row. Outer joins keep both branches alive.
- **Insert + Update + Delete triad** — same idempotency guarantee as the donor rollup. Rerunning always converges: campaigns that no longer have any activity get their summary rows cleaned up.

Alongside `DonorGiftSummary` and `CreatePartyCategories`, this DPE closes the loop of the **standard Fundraising Cloud nightly rollup set**: donors get their lifecycle categories and giving-history rollups; campaigns and source codes get their performance rollups. Together they populate almost every out-of-the-box Fundraising dashboard and report.
