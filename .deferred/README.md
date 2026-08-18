# .deferred/ — Work parked for future FQS releases

Metadata under this folder is **not deployed**. It is excluded from `.forceignore` and omitted from `manifest/package.xml`.

Files stay in the repo so future re-integration can restore them via `git mv` without hunting through history.

## Current parked work

### `v1.1-match-feature/`

Matching-gift automation (donor-triggered corporate match candidacy scoring + commit workflow).

**Deferred out of v1.0 because**
- `FQS_Manage_Gift_Commitment_Actions.flow` is deactivated in FundFirst and not release-scope.
- Match services (`FQS_MatchCandidate`, `FQS_MatchCandidateService`, `FQS_MatchCommitService`) depend on the deferred flow to trigger commits and have no other consumer today.
- Existing test class (`FQS_MatchServices_Test`) moves with the services so the trio can be resurrected together.

**Related still-in-package artifacts (kept, still exercised elsewhere)**
- `Account.FQS_Match_Annual_Individual_Maximum__c`, `Account.FQS_Match_Ratio__c`, `Account.FQS_Matching_Gift_Program__c` — donor-side match config; still surfaced on Account layouts and read by non-Match flows.
- `GiftTransaction.FQS_Match_Status__c`, `GiftEntry.FQS_Match_Status__c`, `GiftCommitment.FQS_Match_Eligible__c` — status columns visible on list views + reports.
- `FQS_Match_Status` global value set.
- `GiftDefaultSoftCredit.FQS_Matched_Donor_Defaults` field.

**Re-integration path for a future v1.x**
1. `git mv .deferred/v1.1-match-feature/classes/*.cls* force-app/main/default/classes/`
2. `git mv .deferred/v1.1-match-feature/flows/*.flow-meta.xml force-app/main/default/flows/`
3. Restore `classAccesses` for `FQS_MatchCandidateService` + `FQS_MatchCommitService` in `permissionsets/FQS_Custom_Fields.permissionset-meta.xml`.
4. Add the four Apex members + one flow member back to `manifest/package.xml`.
5. Confirm the flow's `<status>Active</status>` before deploying.
