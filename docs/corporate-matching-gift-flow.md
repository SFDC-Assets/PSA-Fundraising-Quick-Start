# FQS Corporate Matching Gift Flow — Admin & User Guide

## What it does

The **FQS Find Matching Gift** flow lets a fundraiser stand on any `GiftTransaction` — individual or corporate — and match it to its counterparty in one click. It runs the ranked-candidate search, creates the ACR link, creates a corporate `GiftCommitment` when an intermediary is involved, offers a recurring-match commitment when appropriate, and writes every downstream credit atomically. If any step fails, everything rolls back.

The core problem it solves: **individual gift transactions and corporate matching gifts are two records that fundraising ops staff must manually stitch together**, and doing that correctly (with the right soft credits, on the right side, honoring the legal-donor rule, respecting per-donor annual caps, and handling matching-gift intermediaries) is tedious and error-prone. This flow does it in one screen sequence.

## Legal-donor rule (non-negotiable)

The Account named in `GiftTransaction.DonorId` is the **legal donor** for that transaction and never receives a `GiftSoftCredit` on that transaction. The *counterparty* — the other side of the match — is what gets credited. This is enforced in `FQS_MatchCommitService.commitMatch` and cannot be turned off by configuration.

## When to launch

Click **Find Match** in the highlights panel of any `GiftTransaction` record. The flow auto-detects launch direction:

- **Individual side** — DonorId is a Person Account → flow finds a matching corporate transaction.
- **Corporate side** — DonorId is a business Account → flow lets you allocate the match across one or more individual gifts.

## Records the flow touches

| Object | Change | Notes |
|---|---|---|
| `GiftTransaction` (individual) | `MatchingEmployerTransactionId`, `FQS_Matched__c=true` | Points at the corporate side. |
| `GiftTransaction` (corporate) | `FQS_Matched__c=true` | Also gets `GiftCommitmentId` when the intermediary branch fires. |
| `GiftSoftCredit` | Insert (2 per match) | Corporate Account credited on the individual GT; individual Person Account credited on the corporate GT. |
| `Account` | `FQS_Matching_Gift_Program__c=true` | Only when drift-fix opted in. |
| `AccountContactRelation` | Insert | Only when the individual has no employer ACR and the fallback branch is used. |
| `GiftCommitment` | Insert (corporate legal donor) | Intermediary branch OR recurring-match branch. |
| `GiftDefaultSoftCredit` | Insert | Only when creating a recurring commitment — auto-soft-credits the individual on future scheduled transactions. |

## Signals used to rank candidates

Each scorer runs independently and contributes to the ranked score (0–100). Reasons are surfaced alongside each row so the fundraiser can see *why* a candidate ranked high.

| Scorer | Weight | Signal |
|---|---:|---|
| Employer via ACR | 40 | Individual's Contact → ACR → corporate DonorId (or vice-versa) |
| Employer flag on | 20 | Corporate `Account.FQS_Matching_Gift_Program__c=true` |
| Same commitment | 30 | Shared `GiftCommitmentId` (pledge scenario) |
| Amount exact | 25 | Candidate.OriginalAmount == source.OriginalAmount × match ratio |
| Amount within tolerance | 10 | Within 5% or $5 (mutually exclusive with exact) |
| Net-of-fees | 5 | Same comparison on `OriginalAmount − TotalTransactionFee` |
| Same campaign | 10 | Same `CampaignId` |

**Dates are not used for ranking** by design — corporate matches often arrive weeks or months after the individual gift.

## Scenarios walked through

### 1. Individual donor, corporate match arrives later

- Fundraiser opens the corporate `GiftTransaction`, clicks **Find Match**.
- Flow detects direction = CORPORATE.
- Presents individual gifts whose donors are on the corporate's ACR chain, or whose gifts share the same `GiftCommitment`.
- Fundraiser selects one or more individuals (respecting `sourceRemainingCapacity` shown in the header).
- On confirm: individual GTs get `MatchingEmployerTransactionId` set, soft credits inserted on both sides.

### 2. $1,000 pledge, $500 individual gift ($487 net after CC fee), $487 corporate match

- Both individual GT and corporate GT are on the same `GiftCommitment` (the $1,000 pledge). Corporate is a legal donor on the pledge in this org's pattern.
- Fundraiser opens the corporate ($487) GT, clicks **Find Match**.
- The individual's $500 gift ranks highly: `Same commitment` (30) + `Employer via ACR` (40) + `Employer flag on` (20) + `Amount within tolerance` (10) + `Net-of-fees` (5, since $500 gross − $13 fee = $487).
- Fundraiser confirms. Match link + soft credits land.

### 3. Corporate match arrives via an intermediary (Benevity, YourCause, etc.)

- The intermediary Account has `FQS_Is_Match_Intermediary__c = true`.
- Fundraiser opens the intermediary's `GiftTransaction` and clicks **Find Match**.
- Flow prompts: *Which corporate Account is this gift on behalf of?* — fundraiser picks the true corporate.
- Flow uses the true corporate for ACR-based scoring (not the intermediary).
- On commit:
  - A new `GiftCommitment` is created with the true corporate as `DonorId` (unless a reusable one exists).
  - The intermediary's `GiftTransaction.GiftCommitmentId` points at that commitment.
  - A `GiftSoftCredit` is inserted on the intermediary's GT crediting the true corporate.
  - Individual match links + soft credits proceed as normal.
- **Legal donor on the intermediary GT is still the intermediary** — the true corporate gets soft credit only, not hard credit.

### 4. Individual has no employer on file

- Fundraiser opens the individual GT, clicks **Find Match**.
- Flow detects no ACR for this person.
- Presents the **Add Employer Relationship** fallback screen: pick a business Account, optionally set a Role (free-text — no default enforced).
- On commit, the `AccountContactRelation` is inserted inside the same savepoint as the match writes.

### 5. Recurring match prompt

The flow asks *"Should the employer match recur going forward?"* **only when the donor-side GT has no `GiftCommitmentId`**. When the individual is already on a commitment, pledge mechanics handle recurrence and the prompt is suppressed.

If opted in, a new `GiftCommitment` is created with the corporate as legal donor, plus a `GiftDefaultSoftCredit` so the individual is soft-credited on every future scheduled transaction. The individual's original gift is not touched.

### 6. Program-flag drift

The flow detects when a chosen corporate Account isn't marked `FQS_Matching_Gift_Program__c = true` and offers to fix it inline (inside the same savepoint as the match write, so it rolls back on any failure).

## Custom fields shipped

All on `Account`, all in the **FQS Custom Fields** permission set:

| API name | Type | Purpose |
|---|---|---|
| `FQS_Matching_Gift_Program__c` | Checkbox | Marks a corporate as running a match program. |
| `FQS_Is_Match_Intermediary__c` | Checkbox | Marks an Account as a matching-gift intermediary. Mutually exclusive with the program flag. |
| `FQS_Match_Ratio__c` | Number(4,2), default 1.00 | Multiplier for the amount-exact scorer (2.00 = 2:1). |
| `FQS_Match_Annual_Individual_Maximum__c` | Currency | Per-donor annual cap. Candidates that would exceed the cap get a warning in the reasons string. |

## Fault paths

Every action and every DML has a fault path. On failure:

- **Get Source Gift / Get Source Donor Account** fails → *Error — Could Not Load Source Gift*. No writes attempted.
- **Find Matching Gift Candidates** fails → *Error — Candidate Lookup Failed*. No writes attempted.
- **Commit Matching Gift** fails → *Error — Match Not Saved*. **Everything is rolled back** by the Apex savepoint — no partial state.

All three error screens surface `{!$Flow.FaultMessage}` and (for commit) the rolled-back error text.

## Screen flow best-practices audit

The flow was authored with the following in place:

- Top-level `<description>` explaining purpose and inputs.
- Every element (Screen, Decision, Action, Get Records, Assignment) has a `<description>`.
- Every variable has a `<description>`.
- No hard-coded record Ids anywhere.
- No SOQL inside loops (all queries are outside loops in the Apex service).
- No DML inside loops (bulk collections built, then one DML per object).
- Every DML / Action / Get Records has a fault path.
- `<runInMode>SystemModeWithSharing</runInMode>` so match writes work regardless of the running user's edit access to `Account.FQS_Matching_Gift_Program__c`.
- `<interviewLabel>` includes `{!$Flow.CurrentDateTime}` so debug logs are distinguishable per run.

## Manual org setup

Before this flow works end-to-end, admins need to click through:

1. **Setup → Account Settings → "Allow users to relate a contact to multiple accounts" = ON.** Required so the employer ACR can be created separately from the person account's own record. (README already documents this in *Before You Install*.)
2. Confirm `GiftSoftCredit.Role` picklist has a `Matched Donor` value. Add if missing.
3. **Consider** a validation rule enforcing that `FQS_Matching_Gift_Program__c` and `FQS_Is_Match_Intermediary__c` are not both true on the same Account. See README *Establish Data Integrity Guardrails* for the suggested rule.

## Deploy notes

- **Test coverage** on the two Apex classes hits 6 scenarios (individual→corporate happy path, net-of-fees $487 case, corporate→individual multi-select, intermediary, no-ACR fallback, rollback).
- **Flow ships in Draft status** — activate in Flow Builder after reviewing screen copy for your org's tone.

### Follow-up: swap the two selection screens for the standard data-table component

The candidate-selection screens (`Screen_Candidate_Individual` and `Screen_Candidate_Corporate`) currently use plain text inputs — a single Id on the individual side, a semicolon-separated list on the corporate side. This works but is a poor UX for what should be a ranked-row picker.

The ranked candidates are already returned as a `List<FQS_MatchCandidate>` (Apex-defined, `@AuraEnabled`) from `FQS_MatchCandidateService.findCandidates`. To upgrade the UX inside Flow Builder (5–10 minutes total):

1. Open **FQS Find Matching Gift** in Flow Builder.
2. On **Screen_Candidate_Individual**: delete the `SelectedCorporateCandidateInput` text input. Add a **Data Table** screen component in its place. Bind:
   - **Data Source Collection** → `Call_Find_Candidates.candidates`
   - **Selection Mode** → *Single row can be selected*
   - **Data Type** → *Apex-Defined*, class `FQS_MatchCandidate`, key field `candidateId`
   - Wire the datatable's `First Selected Row → candidateId` output to `selectedCorporateCandidateId` (existing variable). Update the follow-up assignment to reference the variable directly instead of the old text input.
3. On **Screen_Candidate_Corporate**: same shape, but **Selection Mode** = *Multiple rows can be selected*. Loop the datatable's `Selected Rows` output and append each row's `candidateId` into `selectedCounterpartyIds` (replacing the current single-append Assignment).
4. Save and re-activate.

The Apex layer and commit path need no changes — they already accept the Ids in whatever collection the flow produces. This was done as a Flow-Builder follow-up rather than shipped in source metadata because the datatable's input parameters became a complex-object shape in flow version 65+ that Flow Builder emits reliably but doesn't hand-author cleanly from source XML.

## Known caveats

- **Paid GiftTransactions block `GiftCommitmentId` edits.** The intermediary branch attaches the intermediary GT to a corporate `GiftCommitment`, which the platform only permits while `Status` is `Unpaid` or `Pending`. The flow now pre-checks this immediately after loading the source and, when the status is anything else on an intermediary source, routes to a dedicated error screen (**Error — Intermediary Gift Status Locks Commitment Edit**) before any writes are attempted. The user sees a plain-English explanation and two paths forward: (1) revert Status to Unpaid, run Find Match, restore the Status; (2) handle this match outside the flow. Non-intermediary paths are unaffected — `MatchingEmployerTransactionId` and `FQS_Matched__c` update fine on Paid gifts.
- **Only one corporate candidate can be selected** in the individual-side branch. If a single individual gift needs to be split across multiple corporate matches, run the flow from each corporate side.
