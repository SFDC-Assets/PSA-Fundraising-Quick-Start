# FQS — Corporate Matching Gift Screen Flow

**Status:** Draft plan, awaiting review
**Owner:** Justin Gilmore
**Created:** 2026-07-09

## Goal

Give fundraisers a one-click "Find Match" experience on any GiftTransaction that:

1. Detects whether they launched from the individual side or the corporate side.
2. Presents a ranked, scored candidate list in a data table.
3. Lets them select one (individual side) or many (corporate side).
4. Wires up the native `MatchingEmployerTransactionId` link + a `GiftSoftCredit` row for the party that is *not* the legal donor on that transaction (the legal donor — the Account named in `GiftTransaction.DonorId` — never gets a soft credit).
5. Handles the "no employer relationship yet" case by letting the user pick an Account (filtered out of household `PartyRelationshipGroup`s) and creating the ACR inline.
6. Shows remaining match capacity so the corporate gift is never over-allocated.
7. Offers to establish a recurring match commitment **only when the individual (donor-side) GiftTransaction has no `GiftCommitmentId`** — a one-off individual gift is the moment where "should this match recur?" is a meaningful question. When the individual side is already on a commitment, the pledge mechanism handles it and this prompt is suppressed.
8. Detects and offers to fix drift between the selected corporate Account and any `FQS_Matching_Gift_Program__c=false` state.

## Core rules (baked into every decision below)

- **Legal donor never gets a soft credit.** The Account in `GiftTransaction.DonorId` is the legal donor for that transaction and is excluded from any `GiftSoftCredit` we insert. The *other* party — the counterparty to the match — always gets the soft credit.
- **Two soft credits per match, not one.** For each individual↔corporate pair:
  - On the individual's GiftTransaction, soft-credit the **corporate Account** (`Role = 'Matched Donor'`).
  - On the corporate's GiftTransaction, soft-credit the **individual's Person Account** (`Role = 'Matched Donor'`).
  This ensures reporting from either side shows the counterparty without ever crediting the legal donor to their own gift.
- **Dates are not a match criterion.** Enforced by omission from the query and scorers.

## What already exists (don't rebuild)

| Asset | Where | Notes |
|---|---|---|
| `GiftTransaction.MatchingEmployerTransactionId` | Standard, Lookup(GiftTransaction) | The link. Individual gift points at the corporate gift. Reused. |
| `GiftTransaction.FQS_Matched__c` | Custom checkbox | Set to true when a match is wired. Reused. |
| `GiftTransaction.GiftCommitmentId` | Standard | Same-commitment is the pledge signal. |
| `GiftTransaction.ProcessorTransactionFee` / `GatewayTransactionFee` / `TotalTransactionFee` | Standard | Feed the fee-aware amount scoring. |
| `GiftSoftCredit` (with `Role` picklist including "Matched Donor") | Standard | Reused for the soft-credit row. |
| `PartyRelationshipGroup.Type` (picklist: **Group**, **Household**) | Standard on live org — verified via describe | Used to identify household PRGs for the ACR fallback filter. **No new field needed.** |
| Related list "MatchingEmployerTransactions" on GiftTransaction | Already on flexipage + layout | No change. |
| `AccountContactRelation` | Standard | Used for employer relationships. Requires org setting toggled (see §Manual Setup). |

## New metadata

### Required

| Object | API name | Type | Purpose |
|---|---|---|---|
| Account | `FQS_Matching_Gift_Program__c` | Checkbox, default false | Marks a business Account as running a match program. Filters the Account lookup fallback and boosts the score of candidates whose employer Account has it. Drift detection reads this. Help text notes that this field is mutually exclusive with `FQS_Is_Match_Intermediary__c` — an intermediary is not itself a match program, it facilitates one for a true corporate. |
| Account | `FQS_Match_Ratio__c` | Number(4,2), default 1.00 | Multiplier applied to the individual's `OriginalAmount` when comparing to the corporate gift. 2.00 = 2:1, 0.50 = 0.5:1. |
| Account | `FQS_Match_Annual_Individual_Maximum__c` | Currency(16,2) | Per-individual annual cap on match dollars. Flow computes YTD matched from this employer for the individual and enforces the cap. |
| Account | `FQS_Is_Match_Intermediary__c` | Checkbox, default false | Marks an Account (Benevity, YourCause, Bright Funds, CyberGrants, etc.) as a matching-gift intermediary — the legal donor on the check even though the giving originates from a corporate employer. Triggers the intermediary branch in the flow: user is asked which true corporate Account the gift is on behalf of, and a corporate `GiftCommitment` is created/reused so the corporate's giving still rolls up correctly. Help text notes that this field is mutually exclusive with `FQS_Matching_Gift_Program__c`. |

**No new fields on `GiftTransaction`.** Remaining match capacity is computed live in Apex via `SUM(OriginalAmount)` over already-matched children.

Every field ships with `<description>` and `<inlineHelpText>` per FQS convention (see the existing `FQS_Matched__c` metadata as the pattern).

## Manual org setup (not deployable via source, called out in deploy notes)

1. **Setup → Account Settings → "Allow users to relate a contact to multiple accounts" = ON.** Required so `AccountContactRelation` can hold the employer link separately from the person account's own record.
2. Verify `GiftSoftCredit.Role` picklist has a "Matched Donor" value. Add if missing.

## Apex layer — `FQS_MatchCandidateService`

You asked for "separate scorers ranked together" and hinted at an Apex-defined virtual type. This is the right shape.

### Class shape

```apex
public with sharing class FQS_MatchCandidateService {

    public class MatchCandidate {
        @AuraEnabled public Id candidateId;
        @AuraEnabled public String donorName;
        @AuraEnabled public Decimal originalAmount;
        @AuraEnabled public Decimal netAmount;
        @AuraEnabled public String campaignName;
        @AuraEnabled public Id giftCommitmentId;
        @AuraEnabled public String giftCommitmentName;
        @AuraEnabled public Decimal alreadyMatchedAmount;   // sum of children matched so far (corporate side)
        @AuraEnabled public Decimal remainingCapacity;       // corporate candidates only
        @AuraEnabled public Decimal ytdMatchedForDonor;      // guard against annual max
        @AuraEnabled public Boolean employerAccountFlagOn;   // FQS_Matching_Gift_Program__c on the corporate Account
        @AuraEnabled public Integer score;                   // 0-100
        @AuraEnabled public String matchReasons;             // "; " delimited
    }

    @InvocableMethod(label='Find Matching Gift Candidates' callout=false)
    public static List<FindResponse> findCandidates(List<FindRequest> requests) { ... }

    @InvocableMethod(label='Commit Matching Gift' callout=false)
    public static List<CommitResponse> commitMatch(List<CommitRequest> requests) { ... }
}
```

The service exposes **two invocables**. `findCandidates` is read-only and returns the ranked list. `commitMatch` wraps every DML for one confirmation in a single `try` with `Database.setSavepoint()` / `Database.rollback()` so a partial failure never leaves the org half-updated (link written but soft credits missing).

### Scoring model

Each scorer runs independently and contributes to `score`. Weights are tunable class constants.

| Scorer | Weight | Signal |
|---|---:|---|
| `scoreEmployerAcr` | 40 | Individual's Contact → ACR → corporate DonorId (or reverse). |
| `scoreMatchProgramFlag` | 20 | Corporate Account's `FQS_Matching_Gift_Program__c = true`. |
| `scoreSameCommitment` | 30 | `GiftCommitmentId` equal (pledge scenario). |
| `scoreAmountExact` | 25 | `candidate.OriginalAmount == source.OriginalAmount × ratio`. |
| `scoreAmountWithinTolerance` | 10 | Within 5% or $5 (larger). Mutually exclusive with exact. |
| `scoreNetOfFees` | 5 | Same comparison, on `OriginalAmount − TotalTransactionFee`. Additive. |
| `scoreSameCampaign` | 10 | `CampaignId` equal. |

Total max ≈ 130; normalized to 0–100 for display. `matchReasons` is built from any scorer that fired.

### Query strategy

- **Individual → corporate candidates:** corporate GiftTransactions where either (a) DonorId is on the individual's employer ACR chain, OR (b) `GiftCommitmentId = source.GiftCommitmentId`, OR (c) `DonorId.FQS_Matching_Gift_Program__c = true`. Union, dedupe, score.
- **Corporate → individual candidates:** individual GiftTransactions where (a) DonorId is a Person Account with an ACR to the corporate DonorId, OR (b) same `GiftCommitmentId`. Filter out those already fully matched.
- **Capacity check:** `SELECT MatchingEmployerTransactionId, SUM(OriginalAmount) FROM GiftTransaction WHERE MatchingEmployerTransactionId IN :corporateIds GROUP BY MatchingEmployerTransactionId`.
- **YTD-per-donor check:** `SELECT DonorId, SUM(OriginalAmount) FROM GiftTransaction WHERE MatchingEmployerTransactionId != NULL AND MatchingEmployerTransactionId IN (corporate gifts whose DonorId = employer) AND CALENDAR_YEAR(TransactionDate) = THIS_YEAR GROUP BY DonorId`.

### Governor-limit posture

- All SOQL is bulkified and outside loops.
- Candidate query capped at 200 rows (`LIMIT 200`); the ranked top-N is what the data table shows.
- Aggregate queries share `IN :ids` binds; no per-row queries.
- One savepoint / rollback pair per `commitMatch` invocation.

### Test class — `FQS_MatchCandidateService_Test`

Coverage plan:
- Individual→corporate happy path with ACR + amount exact
- Corporate→individual multi-select respecting `remainingCapacity`
- Pledge scenario: shared `GiftCommitmentId`, corporate is legal donor, individual soft-credited
- No ACR present → fallback branch returns `sourceHasEmployerAcr = false`
- Amount ratio 2:1 boosts exact scorer
- Fee-adjusted amount scores via `scoreNetOfFees`
- Capacity exhausted → candidate excluded
- Annual individual max exceeded → candidate excluded with reason
- `commitMatch` rollback: force DML failure on second write, assert first write reverted
- Bulk `commitMatch` with 10 individuals allocated against one corporate

## Screen Flow — `FQS_Find_Matching_Gift`

**Type:** Screen flow, launched from a Lightning quick action on `GiftTransaction`.
**Input variables:**
- `recordId` (Text) — source GiftTransaction Id, passed automatically by the quick action.
**Description:** "Finds and commits an employer/individual match for a GiftTransaction. Context-aware — detects the source side and shows the opposite side's ranked candidates."

Every element carries a `<description>` per Flow best practice — see §Flow audit checklist.

### Element-by-element outline

```
1. [Get Records: srcGT]
      GiftTransaction where Id = {!recordId}
      Fields: DonorId, DonorId.IsPersonAccount, DonorId.FQS_Matching_Gift_Program__c,
              DonorId.FQS_Match_Ratio__c, DonorId.FQS_Match_Annual_Individual_Maximum__c,
              DonorId.FQS_Is_Match_Intermediary__c,
              GiftCommitmentId, OriginalAmount, TotalTransactionFee, CampaignId,
              MatchingEmployerTransactionId, FQS_Matched__c
      Fault → screen "errCannotLoadSource"

2. [Assignment: setDirection]
      direction = IF(srcGT.DonorId.IsPersonAccount, 'INDIVIDUAL', 'CORPORATE')

1a. [Decision: sourceIsIntermediary]  (runs only when direction=CORPORATE)
      IF srcGT.DonorId.FQS_Is_Match_Intermediary__c == true → 1b
      ELSE → 3

1b. [Screen: pickTrueCorporate]
      Header: "This gift came through {!srcGT.DonorId.Name}. Which employer is it on behalf of?"
      Account lookup, filtered:
        - IsPersonAccount = false
        - FQS_Is_Match_Intermediary__c = false
        - Account.Id NOT IN (SELECT AccountId FROM PartyRelationshipGroup WHERE Type = 'Household')
      Optional toggle: "Only Accounts with a matching gift program"
      Description: "Selected Account becomes the true corporate for match scoring, soft credit,
                    and corporate commitment. The intermediary stays as legal donor."

1c. [Get Records: existingCorporateCommitment]
      GiftCommitment WHERE DonorId = {!trueCorporate.Id}
                     AND Status IN ('Active','Pledged')   (adjust to org's picklist)
      LIMIT 1
      Fault → screen "errCommitmentLookup"

1d. [Assignment: setIntermediaryContext]
      overrideEmployerAccountId = {!trueCorporate.Id}
      needCorporateCommitment   = ISBLANK(existingCorporateCommitment.Id)
      reuseCorporateCommitmentId = existingCorporateCommitment.Id  (null if creating)

3. [Action: FQS_MatchCandidateService.findCandidates]
      Input:
        sourceGiftId = {!recordId}
        overrideEmployerAccountId = {!overrideEmployerAccountId}  (null unless intermediary)
      Fault → screen "errCandidateLookup"

4. [Decision: routeByDirection]
      → INDIVIDUAL: go to 5
      → CORPORATE: go to 7

5. [Decision: hasEmployerAcr]  (INDIVIDUAL branch)
      → YES: go to 6 (Candidate screen)
      → NO:  go to 5a (ACR fallback screen)

5a. [Screen: acrFallback]
      Header: "This donor doesn't have an employer on file. Add one to find matches."
      Component: Account lookup, filtered:
        - IsPersonAccount = false
        - Account.Id NOT IN (SELECT AccountId FROM PartyRelationshipGroup WHERE Type = 'Household')
      Optional toggle: "Only Accounts with a matching gift program"
        → adds filter FQS_Matching_Gift_Program__c = true
      ACR Role: free-text input (no default). The picklist value isn't constrained by this flow —
                user types/picks whatever the org uses.

5b. [Create Records: newAcr] via Apex invocable (not raw Flow DML — see §Data-write step)
      OR pure Flow "Create Records" element if we choose to allow this outside the commit savepoint.
      Fault → screen "errAcrCreate"

5c. [Action: findCandidates] again with same recordId (now returns candidates)
      Fault → screen "errCandidateLookup"

6. [Screen: candidatePickIndividual]
      Header dynamic-text: "Find the corporate match for this $X gift from {!srcGT.DonorId.Name}."
      Data table:
        - Source: candidates from action output
        - Columns: Donor Name • Amount (net in tooltip) • Score • Reasons • Campaign • Commitment
        - Sort: Score desc
        - Selection: single (radio)
      Below the table:
        Info tile: "Ratio: {employerAcct.FQS_Match_Ratio__c || 1.00}   Annual max per donor: {…}
                    YTD matched from this employer to this donor: {!candidate.ytdMatchedForDonor}"

7. [Screen: candidatePickCorporate]  (CORPORATE branch)
      Header: "Allocate this $X match among individual gifts."
      Data table:
        - Selection: multi (checkbox)
        - Extra columns: Already Matched, Remaining
        - Live tally at bottom via formula: sum(selected.OriginalAmount) vs sourceRemainingCapacity
      Validation on the screen (Screen component "Validate"):
        - selectedTotal <= sourceRemainingCapacity → error text below the table

8. [Decision: offerRecurringMatch]
      Fires ONLY when the individual-side GiftTransaction has NO GiftCommitmentId.
      Resolve the "individual side" by direction:
        - direction=INDIVIDUAL: individual side = {!srcGT}
        - direction=CORPORATE:  individual side = each selected candidate (evaluated per row;
                                the prompt is offered per-row where the candidate is uncommitted,
                                or once as a batch toggle if all selected are uncommitted)
      IF individualSide.GiftCommitmentId == null → 8a
      ELSE → 9  (suppress — the existing pledge/commitment handles recurrence)

8a. [Screen: recurringMatchPrompt]
      Header: "This is a one-off gift. Should the employer match recur going forward?"
      Body copy: "Set up a new recurring matching commitment with the corporate Account
                  as the legal donor. This does not change the individual's gift."
      Toggle: "Set up a matching commitment"
      If YES:
        - Show inline fields: RecurrenceType (picklist from GiftCommitment), start date, expected schedule, expected total amount
        - Prefill defaults from the individual gift's OriginalAmount × ratio
      Description on toggle: "Creates a new GiftCommitment record with the corporate Account
                              as legal donor and the individual as soft-credited."

9. [Decision: programFlagDrift]
      Fires ONLY when direction=INDIVIDUAL after the user picked a corporate candidate.
      Detects one of:
        a) Selected candidate's DonorId has FQS_Matching_Gift_Program__c = false
           ("The employer Account isn't marked as running a match program.")
        b) User chose an Account in step 5 that doesn't have the flag set.
      Presents: "The Account {!Name} isn't marked as running a matching gift program.
                 Update it now?"
      Options:
        - "Yes, mark it" → will patch Account.FQS_Matching_Gift_Program__c = true on commit
        - "No, proceed anyway" → note added to confirmation screen
        - "Cancel and choose another candidate" → routes back to step 6
      Fault → screen "errDriftDecision"

10. [Action: FQS_MatchCandidateService.commitMatch]
      Input record:
        sourceGiftId
        selectedCandidateIds (collection)
        markEmployerProgramFlag (Boolean, from step 9)
        createRecurringCommitment (Boolean, from step 8a)
        recurringCommitmentFields (record, from step 8a — nullable)
        acrToCreate (record, from step 5b if pure-Flow ACR creation was deferred here)
      Output:
        summary text, created record Ids, warnings collection
      Fault → screen "errCommit" (shows {!$Flow.FaultMessage} + support instructions)

11. [Screen: confirmation]
      Header: "Match recorded."
      Body: shows source + selected counterparties, amounts, capacity remaining,
            any warnings (e.g. "Employer Account flag was updated"; "New recurring commitment created").
      Buttons: "Done" (Finish), "View source gift" (redirect to record).
```

### Data-write step (`commitMatch` in Apex)

Everything that lands data goes through this method inside one savepoint:

1. If `markEmployerProgramFlag = true`: update `Account.FQS_Matching_Gift_Program__c = true` on the corporate Account.
2. If `acrToCreate` present: insert the `AccountContactRelation`.
3. **Intermediary path only** (when `overrideEmployerAccountId` present):
   - If `needCorporateCommitment = true`: insert a new `GiftCommitment` with `DonorId = trueCorporate.Id`, one-time defaults. Track as `corpCommitmentId`.
   - Otherwise `corpCommitmentId = reuseCorporateCommitmentId`.
   - Update `srcGT.GiftCommitmentId = corpCommitmentId`. This is how the intermediary transaction rolls up to the corporate's commitment record.
   - Insert `GiftSoftCredit` on `srcGT` crediting the **true corporate Account** — the extra credit that gives the corporate visibility on their intermediary-facilitated gift. (Legal donor of `srcGT` is still the intermediary, so this doesn't violate the legal-donor rule.)
4. If `createRecurringCommitment = true`: insert a new `GiftCommitment` (corporate Account as `DonorId`, recurrence fields from user). Then insert a `GiftDefaultSoftCredit` linking the individual so future scheduled transactions carry the soft credit automatically. The individual's original GiftTransaction / GiftCommitment is **not** modified — the new commitment stands on its own.
5. Update each individual `GiftTransaction`: `MatchingEmployerTransactionId = corporateId`, `FQS_Matched__c = true`.
6. Insert `GiftSoftCredit` on each individual transaction crediting the **corporate Account** (never the legal donor). In the intermediary case, this credits the true corporate — not the intermediary.
7. Insert `GiftSoftCredit` on the corporate transaction(s) crediting each **individual Person Account** (never the legal donor).

Wrapped in:
```apex
Savepoint sp = Database.setSavepoint();
try {
    // ... all six writes
} catch (Exception e) {
    Database.rollback(sp);
    resp.error = e.getMessage();
    resp.stackTrace = e.getStackTraceString();
    return new List<CommitResponse>{ resp };
}
```

## Fault handling — every DML and every action

Per your directive. Every element that can throw gets an explicit fault path routing to a labeled error screen:

| Element | Fault target | User-visible message |
|---|---|---|
| Get Records `srcGT` | `errCannotLoadSource` | "Couldn't load this gift transaction. Details: {!$Flow.FaultMessage}" |
| Action `findCandidates` | `errCandidateLookup` | "Couldn't build the candidate list. Details: {!$Flow.FaultMessage}" |
| Create Records (ACR fallback, if pure-Flow) | `errAcrCreate` | "Couldn't create the employer relationship. Details: {!$Flow.FaultMessage}" |
| Action `commitMatch` | `errCommit` | "The match couldn't be saved. **Nothing was changed.** Details: {!$Flow.FaultMessage}" |
| Any Decision with no matching outcome | Default outcome → `errUnexpectedRoute` | "The flow reached an unexpected state. Please report this." |

Each error screen has:
- A short human message
- The raw `{!$Flow.FaultMessage}` in a collapsible section
- "Try again" button (routes back to entry) and "Close" button

## Flow audit checklist (best practices we'll comply with)

Applied at build time and re-checked before commit:

- [ ] Flow has a top-level `<description>` explaining purpose and inputs
- [ ] Every element (Screen, Decision, Action, Get/Create/Update/Delete) has a `<description>`
- [ ] Every variable has a `<description>` explaining what it holds and where it's set
- [ ] No hard-coded record Ids anywhere (use Custom Metadata or lookups)
- [ ] No SOQL inside loops (all Get Records live outside loops; use Collection Filter / Sort for in-memory work)
- [ ] No DML inside loops (build a collection, one Update/Create outside the loop, or delegate to Apex)
- [ ] Every DML / Action / Get element has a fault path
- [ ] Naming convention: elements prefixed by type — `get_`, `decide_`, `screen_`, `action_`, `assign_`, `create_`, `update_`
- [ ] Constants used for repeated literal values (role names, direction strings) — stored in a resource, not typed inline
- [ ] `apiVersion` matches project standard (66.0 for FQS)
- [ ] `runInMode = SystemModeWithSharing` (users may not have edit access to `Account.FQS_Matching_Gift_Program__c` directly)
- [ ] Flow trigger type explicit; screen flow, no schedule / record-triggered ambiguity
- [ ] Interview label distinguishes runs in debug logs (e.g. `Find Match: {!srcGT.Name}`)
- [ ] Test coverage via Apex-invoked coverage on `commitMatch` + Flow test class in Winter '25 style if practical
- [ ] Deactivated versions cleaned up before deploy

## Record page & entry points

- New Lightning quick action on GiftTransaction: `FQS_Find_Matching_Gift` (type: Screen Flow, references the flow).
- Adds to the GiftTransaction highlights panel in [`FQS_GiftTransaction_Record_Page.flexipage-meta.xml`](force-app/main/default/flexipages/FQS_GiftTransaction_Record_Page.flexipage-meta.xml).
- Label: "Find Match" — visible on both individual and corporate transactions; the flow handles direction internally.

## Permission set

Update [`FQS_Custom_Fields.permissionset-meta.xml`](force-app/main/default/permissionsets/FQS_Custom_Fields.permissionset-meta.xml):

- Read+Edit on the three new Account fields
- Object permissions: `AccountContactRelation` Create/Read/Edit
- Object permissions: `GiftSoftCredit` Create/Read
- Object permissions: `GiftCommitment` Create (for the recurring-match option)
- Apex class access: `FQS_MatchCandidateService`
- Flow access: `FQS_Find_Matching_Gift`
- Quick action visibility: `GiftTransaction.FQS_Find_Matching_Gift`

## Docs

New file: `docs/corporate-matching-gift-flow.md` — end-user walkthrough, following the pattern of `docs/gift-acknowledgement-flow.md`. Includes:
- When to use / when not to use
- Screenshots per screen
- The legal-donor / soft-credit direction rule stated explicitly
- Troubleshooting: what the error screens mean

## Deliverable checklist

- [ ] `force-app/main/default/objects/Account/fields/FQS_Matching_Gift_Program__c.field-meta.xml`
- [ ] `force-app/main/default/objects/Account/fields/FQS_Match_Ratio__c.field-meta.xml`
- [ ] `force-app/main/default/objects/Account/fields/FQS_Match_Annual_Individual_Maximum__c.field-meta.xml`
- [ ] `force-app/main/default/objects/Account/fields/FQS_Is_Match_Intermediary__c.field-meta.xml`
- [ ] `force-app/main/default/classes/FQS_MatchCandidateService.cls` + `-meta.xml`
- [ ] `force-app/main/default/classes/FQS_MatchCandidateService_Test.cls` + `-meta.xml`
- [ ] `force-app/main/default/flows/FQS_Find_Matching_Gift.flow-meta.xml`
- [ ] `force-app/main/default/quickActions/GiftTransaction.FQS_Find_Matching_Gift.quickAction-meta.xml`
- [ ] Flexipage update: add quick action to highlights panel
- [ ] Permission set update
- [ ] Docs page
- [ ] Deploy notes: enable ACR multi-account setting; verify `GiftSoftCredit.Role` value

## Confirmed decisions (locked, not open)

1. **Household filter:** Exclude Accounts belonging to any `PartyRelationshipGroup` where `Type = 'Household'`. ✅
2. **ACR Role:** Free-text/user's-choice — no default value enforced by the flow. ✅
3. **Recurring match linkage:** New corporate `GiftCommitment` stands alone; the individual's original commitment/gift is not modified. ✅
4. **Recurring match prompt only when donor side has no commitment:** Prompt is suppressed whenever the individual-side GiftTransaction already has a `GiftCommitmentId`. ✅
