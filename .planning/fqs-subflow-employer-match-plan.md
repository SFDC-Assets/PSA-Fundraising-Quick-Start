# FQS — Employer Match subflow extraction plan

**Target:** extract the Employer-Match chain (lookup + confirm + create + pair + soft credit + recurring) from `FQS_Gift_Entry_Single_Launcher_Account` into a monolith-only subflow.

**Purpose:** collapse ~36 canvas nodes on the monolith spine into a single subflow-call node (plus a small caller-side prep + post-return router). Total-system element count is unchanged (elements relocate); the win is main-canvas visualization.

**Scope reference:** `.planning/fqs-launcher-refactor-c4-and-phase-d-research.md` candidate #1 (this also subsumes what was formerly called "Phase C2 — subflow reach extension").

**Reuse scope:** monolith-only per user decision 2026-08-05.

---

## Chain footprint (recon findings)

The employer-match chain is significantly larger than the research doc estimated (research said ~15 elements; recon found ~36 canvas nodes / ~50 total elements). This section captures the exact roster so the plan doc is authoritative.

### Screens (3)
| Element | Line | Notes |
|---|---|---|
| `Pick_MatchEmployer` | 10853–11044 | Datatable + `chkUseEmployerLookup` + `lkpMatchEmployer` (Opportunity + AccountId per `[[flow-lookup-objectapi-fieldapi]]`). Filter help + hint fields. |
| `Details_MatchAmount` | 8098–8189 | `numMatchAmount` (Currency, default = `formulaMatchAmountDefault`), `pkMatchReceived` (radio → Pending/Paid). Includes `MatchProgramMissingHint` (visibility gate on `Get_Match_Employer.FQS_Matching_Gift_Program__c=false`). |
| `Warning_MatchMaxExceeded` | 11780–11820 | Renders `formulaDisplay_NumMatchAmount`, `formulaDisplay_MatchAnnualMax`, `formulaMatchMaxDelta`. |

### Decisions (6)
| Element | Line | Role |
|---|---|---|
| `Decide_Employer_Source` | 4165–4190 | Table row vs. lookup escape-hatch. |
| `Decide_Match_Max_Exceeded` | 4796–4828 | Warning-screen gate. |
| `Decide_PostMatch_Campaign_Router` | 5041–5067 | Routes to `Pick_Campaign` (Recurring or default). **Kept in the subflow only if the subflow owns Pick_Campaign** — since Pick_Campaign lives in the OTHER planned subflow (Campaign+Designation), this decision is subtler: chain owns the pair-and-soft-credit path only; router happens in monolith. |
| `Decide_Employer_GT_Parent_To_Commitment` | 4117–4164 | Branches Employer GT parenting: standalone / to existing GC (PP) / to newly-created Employer Recurring GC. |
| `Decide_ACR_Exists` | 3579–3604 | ACR create gate. |
| `Decide_Match_Post_Route` | 4883–4908 | Post-subflow router (routes to InKind self-credit vs. Commitment SC vs. neither). **Kept in monolith as the post-subflow router.** |

### Assignments (12)
`Assign_EmployerId_FromTable`, `Assign_EmployerId_FromLookup`, `Assign_Employer_GT_Fields`, `Assign_Employer_GT_ParentToCommitment`, `Assign_Employer_GT_ParentToEmployerRecurringGC`, `Assign_Employer_Recurring_GC`, `Assign_Employer_Recurring_GCS`, `Assign_Employer_Recurring_GDD`, `Assign_ACR_Fields`, `Assign_Pair_Onto_Donor_GT`, `Assign_MatchSoftCredit_OnDonor`, `Assign_MatchSoftCredit_OnEmployer`.

### Record Lookups (5)
`Get_ACRs_Match`, `Get_EmployerPRGs_Match`, `Get_EmployerAccounts_Match`, `Get_Match_Employer`, `Get_Existing_ACR`.

### Transforms (2)
`Transform_ACR_AccountIds` (Phase B ship), `Transform_PRG_AccountIds` (Phase B ship). Both `Map` transformType, extracting AccountId scalars from parent SObject collections.

### Record Creates (7)
`Create_Employer_GT`, `Create_Employer_Recurring_GC`, `Create_Employer_Recurring_GCS`, `Create_Employer_Recurring_GDD`, `Create_MatchACR`, `Create_MatchSoftCredit_OnDonor`, `Create_MatchSoftCredit_OnEmployer`.

### Record Updates (1)
`Update_Donor_With_Pair` — mutates the caller's `rsv_GiftTransaction` (writes `MatchingEmployerTransactionId` + `FQS_Match_Status__c='Received'`).

### Action Calls (1)
`Process_Employer_Recurring_Commitment` — `processGiftCommitment` invocable on the newly-created employer Recurring GC.

### SObject Record Variables (8, chain-only)
`rsv_EmployerRecurring_GC` (GC), `rsv_EmployerRecurring_GCS` (GCS), `rsv_EmployerRecurring_GDD` (GDD), `rsv_MatchACR` (ACR), `rsv_MatchEmployerGT` (GT), `rsv_MatchSoftCredit_OnDonor` (GSC), `rsv_MatchSoftCredit_OnEmployer` (GSC), `rsv_SelectedEmployer` (Account).

### Scalar Variable (1)
`varEmployerAccountId` (String) — unified employer AccountId used across the chain.

### Formulas (6 chain-only)
`formulaDisplay_MatchAnnualMax`, `formulaDisplay_NumMatchAmount`, `formulaEmployerRecurringCommitmentName`, `formulaMatchAmountDefault`, `formulaMatchMaxDelta`, `formulaDonorGiftAmount`. Additionally `formulaSuccessMatchAmount` (currently on the Success screen) becomes obsolete if the Success screen refactor described below lands.

### Choices — split
- Chain-only (move with subflow): `Choice_MatchReceived_No`, `Choice_MatchReceived_Yes`.
- Upstream, stay in monolith: `Choice_NeedsMatch_*`, `Choice_MatchEligible_*` (these gate the entry decisions on the monolith side).

---

## Monolith external references that must be honored

**Entry gates (stay in monolith, call subflow when triggered):**
- `Decide_Match_Needed` (4829) — post-`Screen_Gift_Details`, when `pkNeedsMatch=Yes`.
- `Decide_Match_Needed_Recurring` (4855) — post-`Screen_Recurring_Details`, when `pkMatchEligible_Recurring=Yes`.
- `Decide_Insert_Employer_GT_Insert` (4482), `Decide_Insert_Employer_GT_Update` (4531) — post-`Create_Gift_Transaction` / post-`Update_Gift_Transaction`. These are the actual invocation points for the SECOND phase of the chain (the `Assign_Employer_GT_Fields → Create_Employer_GT → pair` sequence).

The chain has TWO logical phases:
1. **Pre-donor-GT phase** (Screen_Gift_Details → Match employer lookup → Details_MatchAmount → warnings) — happens BEFORE the donor GiftTransaction is created.
2. **Post-donor-GT phase** (Assign_Employer_GT_Fields → Create_Employer_GT → pair → soft credits → recurring-employer-GC-if-applicable) — happens AFTER the donor GiftTransaction is created (needs its Id).

**Design decision for subflow shape:** the subflow encapsulates BOTH phases via a `subflowStage` input (`"resolveEmployer"` / `"createAndPair"`). Monolith calls the subflow TWICE — once pre-donor-GT (returns match employer + amount), once post-donor-GT (does the actual DML with the donor GT Id in hand).

**Alternative:** two separate subflows (`FQS_Sub_Match_Resolve`, `FQS_Sub_Match_Create`) — cleaner boundaries but 2× deploy overhead. **Chosen: single subflow with `subflowStage` discriminator.**

**Downstream reader** (single, critical):
- `Screen_Success.SuccessMatchLine` (11627–11648) reads `formulaSuccessMatchAmount` (→ `numMatchAmount`) and `Get_Match_Employer.Name`. Visibility: `pkNeedsMatch EqualTo Choice_NeedsMatch_Yes`.

**Success-screen refactor required:** since the subflow owns `numMatchAmount` and `Get_Match_Employer`, neither is addressable from the monolith post-extraction. The Success line must be rewritten to read three scalar output variables:
- `var_MatchApplied` (Boolean) — replaces the `pkNeedsMatch` visibility gate.
- `var_MatchAmount` (Currency) — replaces `formulaSuccessMatchAmount`.
- `var_MatchEmployerName` (String) — replaces `{!Get_Match_Employer.Name}`.

After refactor, `SuccessMatchLine.fieldText` becomes:
```
Paired with a <b>{!var_MatchAmount}</b> match from <b>{!var_MatchEmployerName}</b>.
```
Visibility: `{!var_MatchApplied} EqualTo true`. Deletes `formulaSuccessMatchAmount` (obsolete).

---

## Subflow: `FQS_Gift_Entry_Subflow_Employer_Match`

### Input contract (`isInput=true`)

| Input | Type | Populated when | Notes |
|---|---|---|---|
| `in_stage` | String | Always | Values: `"resolveEmployer"` / `"createAndPair"`. Drives internal decision at subflow entry. |
| `in_donorAccountId` | String | Always | `recordId` (Person Account Id). |
| `in_donorPersonContactId` | String | Always | `Get_Account.PersonContactId`. |
| `in_donorGiftAmount` | Number | Always | Value of `numGiftAmount` or `numRecurringAmount` — monolith computes and passes. |
| `in_selectedCampaignId` | String | Recurring branch only | For `Assign_Employer_Recurring_GC.CampaignId`. |
| `in_selectedDesignationId` | String | Recurring branch only | For `Assign_Employer_Recurring_GDD.GiftDesignationId`. |
| `in_donorGiftTransactionId` | String | `stage=createAndPair` only | For pairing. |
| `in_donorGiftTransactionDate` | Date | `stage=createAndPair` only | For `rsv_MatchEmployerGT.TransactionDate`. |
| `in_selectedCommitmentId` | String (nullable) | `stage=createAndPair`, PP branch only | For `Assign_Employer_GT_ParentToCommitment`. |
| `in_contextCommitmentId` | String (nullable) | Always | Same as sibling subflow. |
| `in_leafMonetary` | String | Always | Projected from `pkLeafMonetary`. |
| `in_pledgePaymentMode` | String | Always | Projected from `pkPledgePaymentMode`. |
| `in_matchBranch` | String | `stage=createAndPair` only | `"outright"` / `"pledgePayment"` / `"recurring"`. Discriminates which create-chain to fire. |
| `in_recurringStartDate` | Date | Recurring branch only | For `Assign_Employer_Recurring_GC.EffectiveStartDate`, `Assign_Employer_Recurring_GCS.StartDate`. |
| `in_recurringInterval` | Number | Recurring branch only | For `Assign_Employer_Recurring_GCS.TransactionInterval`. |
| `in_recurringPeriod` | String | Recurring branch only | For `Assign_Employer_Recurring_GCS.TransactionPeriod`. |
| `in_recurringTransactionDay` | String | Recurring branch only | Pre-computed by monolith `formulaRecurringTransactionDay` — passed as string per `[[fundfirst-custom-schedule-shape]]` (values `"1"`..`"31"` or `"LastDay"`). |
| `in_matchAmountFromCaller` | Number (nullable) | `stage=createAndPair` only | Passed forward from `stage=resolveEmployer`. Monolith stashes it between the two subflow calls. |
| `in_matchStatusFromCaller` | String (nullable) | `stage=createAndPair` only | Values: `"Pending"` / `"Paid"` (from `pkMatchReceived`). Same stash-forward pattern. |
| `in_matchEmployerIdFromCaller` | String (nullable) | `stage=createAndPair` only | Same. |

**Screen-field auto-var projection layer** — monolith must project `pkLeafMonetary`, `pkPledgePaymentMode`, `pkMatchReceived`, `numMatchAmount`, `numGiftAmount`, `numRecurringAmount`, `dtRecurringStart`, `numRecurringInterval`, `pkRecurringPeriod` before invocation, per `[[flow-screen-autovar-subflow-input]]`. Add one `Assign_Match_Inputs_*` element per invocation point.

### Output contract (`isOutput=true`)

| Output | Type | Populated when |
|---|---|---|
| `out_matchApplied` | Boolean | `stage=createAndPair` success. |
| `out_matchAmount` | Currency | `stage=resolveEmployer` (reflects entered amount) and `stage=createAndPair` (echoes forward). |
| `out_matchStatus` | String | Same. Values: `"Pending"` / `"Paid"`. |
| `out_matchEmployerId` | String | `stage=resolveEmployer`. |
| `out_matchEmployerName` | String | `stage=resolveEmployer`. From `Get_Match_Employer.Name`. |
| `out_matchGTId` | String | `stage=createAndPair` success. For downstream linking (not currently used by monolith but plan-ready). |
| `out_didError` | Boolean | Any stage. `true` when subflow hit a fault path that would have gone to `Error_CouldNotLoadData` or `Error_RecordNotSaved`. |
| `out_errorMessage` | String | Populated when `out_didError=true`. |

### Subflow-local variables (chain scratch)
- All 8 SObject rsv_* variables (chain-only today, stay chain-only inside subflow).
- `varEmployerAccountId` (String).
- Copies of `Choice_MatchReceived_No`, `Choice_MatchReceived_Yes` (Choices are inline per flow).

### DML performed inside subflow
- `Create_Employer_GT` — always on `createAndPair`.
- `Create_Employer_Recurring_GC` / `_GCS` / `_GDD` — Recurring branch only.
- `Create_MatchACR` — gated by `Decide_ACR_Exists` (only if no existing ACR).
- `Create_MatchSoftCredit_OnDonor` — always on `createAndPair`.
- `Create_MatchSoftCredit_OnEmployer` — always on `createAndPair`.
- `Update_Donor_With_Pair` — always on `createAndPair`. **Subflow owns this DML** to avoid the SObject-field-drop trap on return marshalling per `[[flow-sobject-assign-drops-fields]]`. Subflow accepts `in_donorGiftTransactionId` (scalar), constructs a shell `rsv_UpdateDonorGT` SObject with just Id + MatchingEmployerTransactionId + FQS_Match_Status__c, and does the Update inline.
- `Process_Employer_Recurring_Commitment` — Recurring branch only.

### Error handling boundary

Faults on any of the 5 lookups OR the 4 critical creates (`Create_Employer_GT`, `Create_Employer_Recurring_GC`, `_GCS`, `_GDD`) go to internal error screens (`Error_CouldNotLoadData`, `Error_RecordNotSaved`), which are terminal Finish screens. **These CANNOT reach across flow boundaries** — a Finish inside the subflow ends the entire interview.

Two shapes to choose:
- **Shape A (echo pattern used by resolver subflow):** subflow owns its own copies of `Error_CouldNotLoadData` and `Error_RecordNotSaved`. On any fault, the subflow renders the error screen and Finish — the entire launcher interview ends. Simpler but the user sees a subflow-owned error screen instead of the monolith's.
- **Shape B (didError echo):** subflow's faults route to `Assign_DidError_True` → return normally with `out_didError=true`. Monolith detects the flag and routes to its own Error screen. Cleaner UX, but requires every fault path to be re-wired inside the subflow to an assign-then-return pattern instead of an isGoTo Error.

**Chosen: Shape B.** UX consistency across screens matters — the user shouldn't see two visually different error screens depending on which phase of the launcher failed. Cost is ~5 extra `Assign_DidError_*` elements inside the subflow that map each fault path.

### Path preservation contract

**Original monolith exit paths:**
1. **Post-Warning_MatchMaxExceeded (resolveEmployer stage)** → `Decide_PostMatch_Campaign_Router` → `Pick_Campaign` (in the OTHER planned subflow). Monolith owns this transition — subflow returns after Warning screen; monolith routes to Pick_Campaign or its equivalent based on `out_matchAmount` and leaf.
2. **Post-Create_MatchSoftCredit_OnEmployer (createAndPair stage)** → `Decide_Match_Post_Route` → InKind self-credit / Commitment SC / neither. Monolith keeps `Decide_Match_Post_Route` and reads unchanged `pkPledgePaymentMode` (or its projected var).

Subflow return maps:
| Stage | `out_didError` | Monolith next element |
|---|---|---|
| `resolveEmployer` | false | Decide_PostMatch_Campaign_Router → Pick_Campaign path |
| `resolveEmployer` | true | Error_CouldNotLoadData (monolith-owned Finish) |
| `createAndPair` | false | Decide_Match_Post_Route (unchanged) |
| `createAndPair` | true | Error_RecordNotSaved (monolith-owned Finish) |

---

## Monolith changes required to consume the subflow

### New elements (monolith)
1. `Assign_Match_Inputs_Resolve` — projects screen auto-vars → real vars for the `resolveEmployer` call.
2. `Subflow_Call_Match_Resolve` — invokes subflow at `stage=resolveEmployer`.
3. `Assign_Match_ResolveOutputs_Stash` — stashes `out_matchAmount`, `out_matchStatus`, `out_matchEmployerId`, `out_matchEmployerName` into monolith-scope real vars (`var_MatchAmount`, `var_MatchStatus`, `var_MatchEmployerId`, `var_MatchEmployerName`).
4. `Assign_Match_Inputs_CreateAndPair` — projects auto-vars + stashed vars → real vars for the `createAndPair` call.
5. `Subflow_Call_Match_CreateAndPair` — invokes subflow at `stage=createAndPair`.
6. `Assign_Match_Applied_True` — sets `var_MatchApplied=true` after `createAndPair` returns clean.
7. `Decide_Match_Subflow_Error` — one after each subflow call, reads `out_didError`. False → continue; True → Error screen.

### Modified elements (monolith)
- `SuccessMatchLine.fieldText` — rewritten to read `var_MatchAmount` + `var_MatchEmployerName`.
- `SuccessMatchLine.visibilityRule` — flipped from `pkNeedsMatch EqualTo Choice_NeedsMatch_Yes` to `var_MatchApplied EqualTo true`.
- `Decide_Match_Needed` (4829), `Decide_Match_Needed_Recurring` (4855) — updated to fire `Subflow_Call_Match_Resolve` on `Yes` branch.
- `Decide_Insert_Employer_GT_Insert` (4482), `Decide_Insert_Employer_GT_Update` (4531) — updated to fire `Subflow_Call_Match_CreateAndPair` on `Yes` branch.

### Deleted elements (monolith)
All 36 canvas-moving elements plus 8 SObject rsv_* vars + 1 scalar var + 6 chain-only formulas + `formulaSuccessMatchAmount`.

### Preserved external readers
- `MatchEligibleHint` fields on Screen_Pledge / Screen_Recurring_Details / Screen_Scheduled — read `rsv_SelectedCommitment.FQS_Match_Eligible__c`. Unchanged.
- `formulaMatchEligible_Pledge` / `_Recurring` / `_Scheduled` — pre-chain formulas driving GC creation. Stay in monolith unchanged.

---

## Deliberate departure from `[[gt-status-default-paid]]`

The rule says: "FQS launcher must default `GiftTransaction.Status = 'Paid'` on all four monetary leaves."

The employer-match `Assign_Employer_GT_Fields` writes `rsv_MatchEmployerGT.Status = pkMatchReceived`, whose default choice is `Choice_MatchReceived_No` = `"Pending"`.

**This is intentional and stays intentional in the subflow.** The match GT typically arrives after the donor GT (corporate match programs cut checks on a delayed cycle — 2 weeks to 3 months). Defaulting the match GT to `Paid` on data entry would misrepresent typical state at the moment of gift entry. The user radio still lets a data-entry clerk flip it to `Paid` if they're entering the match after the check cleared.

Plan: add a comment in the subflow XML noting this deliberate departure so future maintainers don't "fix" it. Also update memory `[[gt-status-default-paid]]` to note the employer-match GT exception.

---

## Deploy sequence

1. **Author subflow** — create `FQS_Gift_Entry_Subflow_Employer_Match.flow-meta.xml` v67 Screen Flow.
2. **Deploy subflow standalone** — validates XML shape.
3. **Refactor monolith** — delete moved elements, add 7 caller-side elements, refactor `SuccessMatchLine`, delete `formulaSuccessMatchAmount`.
4. **Deploy monolith** — atomic deploy.
5. **9-leaf regression + match sweep** — every leaf that supports match must be tested with match=Yes AND match=No. Specifically:
   - Outright + Match=Yes (Choice_MatchReceived_Yes AND No)
   - Outright + Match=No (subflow not invoked)
   - PP + Match=Yes (verify GT parent-to-existing-GC works)
   - Recurring + MatchEligible=Yes (verify 4 recurring-employer creates + activation)
   - Recurring + MatchEligible=No (subflow not invoked)
   - PP-Update path (verify Assign_Match_Post_Route routes correctly)
   - Force error on `Get_Match_Employer` (delete the Account mid-flow) — verify `out_didError` propagation.
   - Match-amount-over-max — verify `Warning_MatchMaxExceeded` renders correctly inside subflow.

---

## Risk table

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| SObject field-drop on `Update_Donor_With_Pair` | High if the mutation crosses flow boundary | Donor GT's `MatchingEmployerTransactionId` silently null after subflow | Subflow owns the DML directly. Monolith passes `in_donorGiftTransactionId` (scalar) only. |
| Screen auto-var input trap on 9 inputs | High if unprepared | Runtime "field hasn't been set" or silent zero | Two projection layers (`Assign_Match_Inputs_Resolve`, `Assign_Match_Inputs_CreateAndPair`), each mapping 4-6 auto-vars → real vars. |
| Two-call subflow contract confusion | Medium | Wrong stage input → wrong outputs | Add subflow-entry decision `Decide_Subflow_Stage` that gates on `in_stage`. Faulty stage input → return `out_didError=true` with clear error message. |
| Success screen refactor forgotten | Medium | Success page renders empty match line or crashes on missing var | Include Success refactor in the same monolith deploy — atomic. |
| Match-GT Status default (`Pending`) misinterpreted as bug | Low | Future maintainer "fixes" it | Comment in subflow XML + memory update on `[[gt-status-default-paid]]` |
| Fault-path echo (Shape B) adds elements | Certain | +5 elements inside subflow vs. Shape A | Accepted cost for UX consistency. |
| Recurring branch is 4 extra creates + processGiftCommitment call | Certain | Longer runtime on Recurring path | No change from today — the Recurring branch already does all this in the monolith. Extraction is a wash on runtime cost. |

---

## Estimated element movement

**Elements moving into subflow:** 3 screens + 6 decisions + 12 assignments + 5 lookups + 2 transforms + 7 creates + 1 update + 1 action + 8 SObject vars + 1 scalar var + 6 formulas + 2 choices = **54 elements** (canvas nodes ≈ 36).

**Elements added to monolith:** 7 (2 projection layers + 2 subflow calls + 1 stash + 1 apply-flag + 2 error routers).

**Net monolith reduction:** ~47 elements / ~29 canvas nodes.

**Total system:** +8 (subflow overhead: header + subflow-entry decision + 5 didError echo assigns) — element-count-neutral or slight-net-positive at system level. **Canvas readability win is the sole objective.**

---

## Open questions before authoring XML

1. **Single subflow with `in_stage` discriminator vs. two subflows?** Recon recommendation is single with discriminator (halves deploy overhead, matches the natural "match resolution → match creation" two-phase flow). Confirm.
2. **Shape A vs. Shape B for error handling?** Recommendation is Shape B (didError echo) for UX consistency. Confirm.
3. **Naming — `FQS_Gift_Entry_Subflow_Employer_Match` vs. `FQS_Sub_Match`** or another convention? Should match the resolver subflow's naming. User pick.
4. **Order of ship: resolver subflow first or match subflow first?** Both plans are independent (no shared dependencies). Recommendation: **resolver first**, because (a) it's the simpler chain (no DML, no two-phase discriminator, no Success-screen refactor), so it validates the subflow authoring pattern before the harder one lands; (b) it doesn't need any monolith Success-screen refactor. Confirm.
5. **Update `[[gt-status-default-paid]]` memory to note the employer-match Pending default exception?** Recommendation: yes, add "exception: employer-match GT defaults to `Pending`" as an appended note.


1. single with discriminator
2. shape b
3. FQS_Gift_Entry_Subflow_Employer_Match
4. resolver first, already in motion
5. Yes, we should also be sure to add this to the release tracker if not already. 