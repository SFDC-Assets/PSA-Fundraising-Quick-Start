# FQS Gift Refund Flow — Plan

**Status:** design-locked 2026-07-23, not-implemented
**Owner:** solo (Justin)
**Depends on:** none (uses only OOTB Fundraising Cloud objects + FQS custom perms)

---

## 1. Purpose

Give staff a one-click way to refund a Gift Transaction. Creates a `GiftRefund` child record; the platform handles everything downstream.

## 2. Phase 0 finding — platform does the work

Anonymous-Apex probe on FundFirst (2026-07-23) confirmed that inserting a `GiftRefund` with `Status='Completed'` triggers Fundraising Cloud's own bundled flows and produces the correct end state without any FQS backfill logic:

| Field | Before | After partial (30%) | After full |
|---|---|---|---|
| `GT.CurrentAmount` | 243.12 | 170.18 | 0.00 |
| `GT.RefundedAmount` | 0.00 | 72.94 | 243.12 |
| `GT.IsPartiallyRefunded` | false | true | false |
| `GT.IsFullyRefunded` | false | false | true |
| `GT.Status` | Paid | Paid | **Fully Refunded** (auto) |
| `GTD.Amount` (single-designation GT) | 243.12 | 170.18 | 0.00 (auto-prorated) |
| `GC.ExpectedTotalCmtAmount` | 240.00 | 240.00 | 240.00 (unchanged — correct) |
| `GC.Status` | Active | Active | Active (unchanged — correct) |

**Implication:** no RecordAfterSave flow, no GTD proration subflow, no status backfill. The screen flow is thin.

Probe script preserved at `/tmp/fqs-refund-probe.apex` for regression rerun.

## 3. Scope

**In scope**
- Extend `GiftRefund.Reason` picklist with 6 FQS-specific values
- Screen Flow `FQS_Refund_Gift` — thin: collect input, create refund, confirm
- Fee-reversal fields conditionally shown when the source GT had gateway/processor fees
- Two launchers: GT quickAction + Account-tab variant
- Seed 2–3 refunded GTs per chunk for QA
- Regression verify DGS rollups and donor grouping don't double-count refunded gifts

**Out of scope**
- Two-step Initiated→Completed approval workflow (defer — small orgs don't need it; enterprise adopters can extend)
- Refund reason routing to a workflow queue (Task creation is manual)
- Mass-refund from a GT list view (defer)
- Gift Card / stored-value refunds (defer)

## 4. Reason picklist extension

Existing OOTB values: `Incorrect Amount`, `Donor Request`.

New FQS values (via `StandardValueSet` override if Reason is a StandardValueSet, or field-level `valueSet` addition otherwise — verify at implementation):
- `Duplicate Gift`
- `Fraudulent`
- `Test Transaction`
- `Match Correction`
- `Bounced Check`
- `Chargeback`

## 5. Screen Flow — `FQS_Refund_Gift`

**Type:** Screen Flow, recordId-launched (GT record page context)
**Inputs:** `recordId` (GT.Id)

### Elements

1. **Get_GT** — Get Records on GiftTransaction
   - Filter: `Id = {!recordId}`
   - Store: Id, Name, Donor.Name, TransactionDate, OriginalAmount, CurrentAmount, RefundedAmount, IsPartiallyRefunded, IsFullyRefunded, Status, ProcessorTransactionFee, GatewayTransactionFee

2. **Decision_Already_Refunded**
   - If `{!Get_GT.CurrentAmount} <= 0` OR `{!Get_GT.Status} = "Fully Refunded"` → `Screen_Already_Refunded` (dead-end explainer)
   - Else → `Screen_Refund_Details`

3. **Screen_Refund_Details**
   - Display-only header: donor name, gift date, `OriginalAmount`, `CurrentAmount`, existing `RefundedAmount`
   - `refundAmount` (Currency, required, default `{!Get_GT.CurrentAmount}`, validation: `> 0 AND <= {!Get_GT.CurrentAmount}`)
   - `refundDate` (Date, required, default `{!$Flow.CurrentDate}`)
   - `refundReason` (Picklist, required)
   - Optional `refundNote` (Long Text, 500 chars) — stashed on the refund's `LastGatewayErrorMessage` field as a free-text audit
   - **Conditional fee-reversal section** — component visibility: `{!Get_GT.ProcessorTransactionFee} > 0 OR {!Get_GT.GatewayTransactionFee} > 0`
     - `reverseProcessorFee` (Currency, default `{!Get_GT.ProcessorTransactionFee}`)
     - `reverseGatewayFee` (Currency, default `{!Get_GT.GatewayTransactionFee}`)
   - Buttons: Cancel (Finish) / Refund (Next)

4. **Create_GiftRefund** — Record Create
   - `GiftTransactionId = {!recordId}`
   - `Amount = {!Screen_Refund_Details.refundAmount}`
   - `Date = {!Screen_Refund_Details.refundDate}`
   - `Reason = {!Screen_Refund_Details.refundReason}`
   - `Status = "Completed"`
   - `LastGatewayErrorMessage = {!Screen_Refund_Details.refundNote}` (when present)
   - `ProcessorTransactionFee = {!Screen_Refund_Details.reverseProcessorFee}` (when fees section shown)
   - `GatewayTransactionFee = {!Screen_Refund_Details.reverseGatewayFee}` (when fees section shown)
   - `External_Id__c = "FQS-GR-" + {!recordId} + "-" + {!$Flow.CurrentDateTime}` (idempotency-friendly)

5. **Get_GT_After** — Re-query GT to show fresh balances

6. **Screen_Refund_Processed**
   - Confirmation: "$X refunded from {!Get_GT.Name}"
   - Display: new `CurrentAmount`, new `RefundedAmount`, new `Status`
   - Link: "View Refund Record" → `/{!Create_GiftRefund}`
   - Link: "View Gift Transaction" → `/{!recordId}`
   - Finish

### Error handling

- Fault path from `Create_GiftRefund` → `Screen_Error` displaying `{!$Flow.FaultMessage}`, offering "Try Again" (loops back) or "Cancel"

## 6. Launchers

### 6a. `GiftTransaction.FQS_Refund_Gift` quickAction

- Type: Flow
- Flow: `FQS_Refund_Gift`
- Label: "Refund Gift"
- Placement: GT record page highlights panel + record-page actions
- Icon: reuse the platform Refund icon (or a currency-arrow if not available)

### 6b. Account launcher — `FQS_Refund_Gift_From_Donor` (separate screen flow)

Same flow, but starts with a lookup screen so staff can begin from the donor page:

1. **Screen_Pick_Gift**
   - `<extensionName>flowruntime:lookup</extensionName>` on GiftTransaction
   - `objectApiName=GiftTransaction`, `fieldApiName=DonorId` (or use Custom Search / where clause on `Donor = {!recordId}` AND `CurrentAmount > 0`)
   - Store selected Id in `pickedGtId`
2. Assign `recordId = pickedGtId`
3. From here, continues exactly like `FQS_Refund_Gift` (extract shared logic into a subflow, or duplicate the elements — decide at implementation)
4. Launched via `Account.FQS_Refund_Donor_Gift` quickAction

## 7. Seed data — `FQSSeedGenerator.cls`

Add a `seedRefunds(chunkSize, offset)` method invoked from the medium/small chunk scripts. Per chunk:

- 1 fully-refunded GT (older, closed-donor journey — refunds an older Paid GT to Full)
- 1 partially-refunded GT (30% refund, leaves donor in mid-cycle state)
- 1 refund on a pledge installment (verifies the parent commitment stays Active)

External-ID pattern: `FQS-GR-<donor-idx>-<seq>`. Idempotent upsert.

Add teardown block to `fqs-seed-teardown.apex` — `LIKE 'FQS-GR-%'` — inserted between the GiftTransactionDesignation and GiftSoftCredit steps (refunds must delete before GTs).

## 8. Regression checks

After seeding refunds, re-verify:

- `DGS.TotalGiftsAmount` for a refunded donor equals `SUM(GT.OriginalAmount) - SUM(GT.RefundedAmount)` (or whatever the platform actually rolls up — probe first)
- `DGS.GiftCount` — does a fully-refunded GT drop out of the count, or stay in? Document behavior; do not fix if it's a platform choice.
- `FQS_Lifetime_Donor_Level__c` — refunded donors should downgrade correctly.
- `GC.ExpectedTotalCmtAmount` never shrinks (platform behavior confirmed in Phase 0).

## 9. Test plan

Manual QA passes:

1. **Full refund** — GT record page → Refund Gift → default amount → Refund. Verify: GT.Status flips to Fully Refunded, GTD.Amount → 0, refund record visible in related list.
2. **Partial refund** — Same launcher, halve the amount. Verify: GT.Status stays Paid, GT.CurrentAmount is halved, GT.IsPartiallyRefunded = true, refund record shows the exact partial amount.
3. **Cascade refund** — refund the remaining balance after a partial. Verify: GT.Status flips to Fully Refunded (not stuck in Partial).
4. **Fee reversal** — GT with `ProcessorTransactionFee = $5`. Fee section shows. Confirm the refund record captures the reversed fee.
5. **Account launcher** — from donor tab, refund an arbitrary GT. Verify pick-GT lookup only shows refundable GTs.
6. **Already-refunded** — from a Fully Refunded GT, launch refund. Verify dead-end screen fires.
7. **Fault path** — attempt to refund > CurrentAmount. Verify validation blocks + shows a clear error.

## 10. Delivery order

1. Extend Reason picklist + deploy
2. Build `FQS_Refund_Gift` flow + GT quickAction, deploy, manual test (steps 1–4, 6, 7)
3. Build `FQS_Refund_Gift_From_Donor` variant + Account quickAction, deploy, manual test (step 5)
4. Add seed block, run teardown+seed, verify shape
5. Regression pass on DGS + donor grouping
6. Commit + update `.planning/fqs-release-readiness.md`

## 11. Open questions to resolve at implementation

- Confirm whether `GiftRefund.Reason` is a StandardValueSet (extendable in `standardValueSets/`) or a per-field ValueSet (extendable in `objects/GiftRefund/fields/Reason.field-meta.xml`). `sf sobject describe` doesn't distinguish; check by attempting a StandardValueSet retrieve first.
- Decide whether `FQS_Refund_Gift` and `FQS_Refund_Gift_From_Donor` share a subflow (`FQS_Refund_Gift_Core`) or duplicate their elements. Subflow is cleaner but ~20% more effort.
- Should Reason = "Fraudulent" auto-create a Task for the donor account? Deferred — no signal yet that a rule is needed.
