// FQS Matching-Gift Scenario Enhancer
// Runs AFTER fqs-seed-foundation.apex and a donor seed (small/medium/large).
// Layers realistic matching-gift test data on top of the base seed to exercise
// the FQS Find Matching Gift screen flow end-to-end:
//
//   1. Inserts AccountContactRelation rows linking FQS Person Accounts to a
//      corporate employer — lights up the 40-pt "Employer via ACR" scorer.
//   2. Aligns a subset of corp-match GTs with the employee GT's GiftCommitmentId
//      — lights up the 30-pt "Same commitment" scorer.
//   3. Aligns a subset of corp-match GTs with the employee GT's CampaignId
//      — lights up the 10-pt "Same campaign" scorer.
//   4. Inserts intermediary GTs (DonorId = FQS-ACC-INT-*, Status='Unpaid') as
//      launch points for the flow's intermediary branch.
//
// IDEMPOTENT — safe to re-run. For the 10k large seed, run twice: the ACR pass
// is LIMIT'd to 5000 per run to stay under the 10k DML/tx cap; existing rows are
// skipped by the dedupe check.
//
// Prerequisite: Setup > Account Settings > "Allow users to relate a contact to
// multiple accounts" must be ON for the AccountContactRelation inserts to succeed.

System.debug('=== FQS Matching-Gift Scenario Enhancer starting ===');

// PRNG helpers live on FQSSeedGenerator so the enhancer stays consistent with the
// chunk generator's employer-index derivation. See FQSSeedGenerator.prng / randInt.

// ============ STEP 1: ACRs (Person Account -> corporate employer) ============
List<Account> corpEmployers = [
    SELECT Id FROM Account
    WHERE External_Id__c LIKE 'FQS-ACC-CORP-%'
    ORDER BY External_Id__c
];
System.assert(!corpEmployers.isEmpty(), 'No FQS corporate employers — run fqs-seed-foundation.apex first');
Integer corpCount = corpEmployers.size();

List<Account> personDonors = [
    SELECT Id, PersonContactId, External_Id__c
    FROM Account
    WHERE External_Id__c LIKE 'FQS-ACC-%'
      AND (NOT External_Id__c LIKE 'FQS-ACC-CORP-%')
      AND (NOT External_Id__c LIKE 'FQS-ACC-INT-%')
      AND IsPersonAccount = true
    LIMIT 5000
];
System.debug('Person donors queried: ' + personDonors.size());

// Existing ACRs — skip donors already linked to their assigned employer.
Set<Id> personContactIds = new Set<Id>();
for (Account a : personDonors) if (a.PersonContactId != null) personContactIds.add(a.PersonContactId);
Map<Id, Set<Id>> existingAcrByContact = new Map<Id, Set<Id>>();
if (!personContactIds.isEmpty()) {
    for (AccountContactRelation acr : [
        SELECT ContactId, AccountId FROM AccountContactRelation
        WHERE ContactId IN :personContactIds
    ]) {
        if (!existingAcrByContact.containsKey(acr.ContactId)) existingAcrByContact.put(acr.ContactId, new Set<Id>());
        existingAcrByContact.get(acr.ContactId).add(acr.AccountId);
    }
}

List<AccountContactRelation> newAcrs = new List<AccountContactRelation>();
for (Account donor : personDonors) {
    if (donor.PersonContactId == null) continue;
    String extId = donor.External_Id__c;  // 'FQS-ACC-<idx>'
    Integer globalIdx;
    try { globalIdx = Integer.valueOf(extId.substring(8)); } catch (Exception e) { continue; }
    Integer empIdx = Math.mod(FQSSeedGenerator.prng(globalIdx, 601), corpCount);
    Id employerId = corpEmployers[empIdx].Id;
    Set<Id> existing = existingAcrByContact.get(donor.PersonContactId);
    if (existing != null && existing.contains(employerId)) continue;
    newAcrs.add(new AccountContactRelation(
        ContactId = donor.PersonContactId,
        AccountId = employerId,
        IsActive = true
        // Roles left null — org picklist config varies. Flow scoring only checks ACR presence.
    ));
}
if (!newAcrs.isEmpty()) {
    try {
        insert newAcrs;
        System.debug('ACRs inserted: ' + newAcrs.size());
    } catch (DmlException e) {
        System.debug('ACR insert FAILED. Verify "Allow users to relate a contact to multiple accounts" is enabled. Error: ' + e.getMessage());
    }
} else {
    System.debug('No new ACRs needed (all eligible donors already linked).');
}

// ============ STEP 2 & 3: align GiftCommitmentId + CampaignId on corp GTs ============
// Scoring lift: "Same commitment" (30 pts) and "Same campaign" (10 pts).
//
// Platform gotcha: GiftTransaction.GiftCommitmentId is only editable while
// Status IN ('Unpaid','Pending'). The base seed marks corp matches as 'Paid',
// so we do a three-step dance for the commitment update: flip Status to Unpaid,
// set GiftCommitmentId, restore Status. CampaignId has no such gate — updates
// happen in one pass regardless of Status.
List<GiftTransaction> corpGts = [
    SELECT Id, External_Id__c, Status, MatchingEmployerTransactionId,
           MatchingEmployerTransaction.GiftCommitmentId,
           MatchingEmployerTransaction.CampaignId,
           GiftCommitmentId, CampaignId
    FROM GiftTransaction
    WHERE External_Id__c LIKE 'FQS-GT-CORP-%'
      AND MatchingEmployerTransactionId != null
    LIMIT 5000
];
System.debug('Corp match GTs queried: ' + corpGts.size());

List<GiftTransaction> campaignOnlyUpdates = new List<GiftTransaction>();
List<GiftTransaction> commitmentCandidatesPaid   = new List<GiftTransaction>();  // need status flip
List<GiftTransaction> commitmentCandidatesEditable = new List<GiftTransaction>(); // Unpaid/Pending
Map<Id, String> originalStatusById = new Map<Id, String>();

for (GiftTransaction cg : corpGts) {
    String extId = cg.External_Id__c;  // 'FQS-GT-CORP-<idx>-<g>'
    Integer sepIdx = extId.indexOf('-', 12);
    if (sepIdx < 0) continue;
    Integer globalIdx;
    Integer g;
    try {
        globalIdx = Integer.valueOf(extId.substring(12, sepIdx));
        g = Integer.valueOf(extId.substring(sepIdx + 1));
    } catch (Exception e) { continue; }

    Id empCommitmentId = cg.MatchingEmployerTransaction.GiftCommitmentId;
    Id empCampaignId   = cg.MatchingEmployerTransaction.CampaignId;

    Boolean wantCommitment = (empCommitmentId != null && cg.GiftCommitmentId == null
        && Math.mod(FQSSeedGenerator.prng(globalIdx, 800 + g), 100) < 50);
    Boolean wantCampaign = (empCampaignId != null && cg.CampaignId != empCampaignId
        && Math.mod(FQSSeedGenerator.prng(globalIdx, 801 + g), 100) < 30);

    if (wantCampaign && !wantCommitment) {
        GiftTransaction u = new GiftTransaction(Id = cg.Id, CampaignId = empCampaignId);
        campaignOnlyUpdates.add(u);
    }
    if (wantCommitment) {
        // Bundle CampaignId in with the commitment update while Status is flipped.
        GiftTransaction candidate = new GiftTransaction(
            Id = cg.Id,
            GiftCommitmentId = empCommitmentId
        );
        if (wantCampaign) candidate.CampaignId = empCampaignId;
        if (cg.Status == 'Unpaid' || cg.Status == 'Pending') {
            commitmentCandidatesEditable.add(candidate);
        } else {
            commitmentCandidatesPaid.add(candidate);
            originalStatusById.put(cg.Id, cg.Status);
        }
    }
}

if (!campaignOnlyUpdates.isEmpty()) {
    update campaignOnlyUpdates;
    System.debug('Corp GTs re-aligned (campaign only): ' + campaignOnlyUpdates.size());
}
if (!commitmentCandidatesEditable.isEmpty()) {
    update commitmentCandidatesEditable;
    System.debug('Corp GTs re-aligned (commitment, no status flip needed): ' + commitmentCandidatesEditable.size());
}
if (!commitmentCandidatesPaid.isEmpty()) {
    // Step A: Status -> Unpaid so GiftCommitmentId becomes editable.
    List<GiftTransaction> flipDown = new List<GiftTransaction>();
    for (Id gtId : originalStatusById.keySet()) {
        flipDown.add(new GiftTransaction(Id = gtId, Status = 'Unpaid'));
    }
    update flipDown;
    // Step B: set GiftCommitmentId (and CampaignId if bundled).
    update commitmentCandidatesPaid;
    // Step C: restore original Status.
    List<GiftTransaction> flipUp = new List<GiftTransaction>();
    for (Id gtId : originalStatusById.keySet()) {
        flipUp.add(new GiftTransaction(Id = gtId, Status = originalStatusById.get(gtId)));
    }
    update flipUp;
    System.debug('Corp GTs re-aligned (commitment via status flip): ' + commitmentCandidatesPaid.size());
}
if (campaignOnlyUpdates.isEmpty() && commitmentCandidatesEditable.isEmpty() && commitmentCandidatesPaid.isEmpty()) {
    System.debug('No corp GTs needed re-alignment.');
}

// ============ STEP 4: intermediary launch-point GTs ============
List<Account> intermediaries = [
    SELECT Id FROM Account
    WHERE External_Id__c LIKE 'FQS-ACC-INT-%'
    ORDER BY External_Id__c
];
if (intermediaries.isEmpty()) {
    System.debug('No intermediary accounts found — skipping intermediary GT seed. Ensure fqs-seed-foundation.apex ran with FQS_Is_Match_Intermediary__c deployed.');
} else {
    List<GiftTransaction> existingIntGts = [
        SELECT Id FROM GiftTransaction WHERE External_Id__c LIKE 'FQS-GT-INT-%' LIMIT 1
    ];
    if (!existingIntGts.isEmpty()) {
        System.debug('Intermediary GTs already seeded — skipping.');
    } else {
        List<Campaign> corpCamps = [
            SELECT Id FROM Campaign WHERE External_Id__c = 'FQS-CMP-CORP-MATCH' LIMIT 1
        ];
        Id corpCampId = corpCamps.isEmpty() ? null : corpCamps[0].Id;

        // Two intermediary GTs per intermediary account. Status=Unpaid so the flow's
        // intermediary branch can attach a corporate GiftCommitment on commit. Amounts
        // vary so the flow's amount scorer has non-trivial numbers to work with.
        List<GiftTransaction> intGts = new List<GiftTransaction>();
        for (Integer i = 0; i < intermediaries.size(); i++) {
            for (Integer g = 0; g < 2; g++) {
                Decimal amt = 250 + (i * 175) + (g * 125);  // varied per row
                intGts.add(new GiftTransaction(
                    External_Id__c = 'FQS-GT-INT-' + i + '-' + g,
                    Name = 'FQS Intermediary GT #' + i + '-' + g,
                    DonorId = intermediaries[i].Id,
                    OriginalAmount = amt,
                    GatewayTransactionFee = 0,
                    ProcessorTransactionFee = 0,
                    DonorCoverAmount = 0,
                    TransactionDate = Date.today().addDays(-FQSSeedGenerator.randInt(i, 900 + g, 5, 30)),
                    TransactionDueDate = Date.today().addDays(15),
                    Status = 'Unpaid',
                    GiftType = 'Organizational',
                    PaymentMethod = 'Check',
                    FQS_Gift_Transaction_Category__c = 'Outright Gift',
                    CampaignId = corpCampId,
                    Description = 'FQS Seed — intermediary launch point for Find Matching Gift flow'
                ));
            }
        }
        insert intGts;
        System.debug('Intermediary GTs inserted: ' + intGts.size());
    }
}

System.debug('=== Matching-Gift Scenario Enhancer complete ===');
System.debug('ACR count (FQS pool):       ' + [SELECT COUNT() FROM AccountContactRelation WHERE Account.External_Id__c LIKE 'FQS-ACC-CORP-%']);
System.debug('Corp GTs w/ commitment:     ' + [SELECT COUNT() FROM GiftTransaction WHERE External_Id__c LIKE 'FQS-GT-CORP-%' AND GiftCommitmentId != null]);
System.debug('Intermediary GTs:           ' + [SELECT COUNT() FROM GiftTransaction WHERE External_Id__c LIKE 'FQS-GT-INT-%']);
