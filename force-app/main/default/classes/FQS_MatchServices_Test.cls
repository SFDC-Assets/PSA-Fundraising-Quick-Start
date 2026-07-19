/**
 * Coverage for FQS_MatchCandidateService (findCandidates) and FQS_MatchCommitService (commitMatch).
 *
 * Scenarios exercised:
 *   - Individual → Corporate happy path with ACR, program flag, exact amount
 *   - The $500 / $487 net / $487 corporate scenario using scoreNetOfFees
 *   - Pledge scenario with shared GiftCommitmentId
 *   - Corporate → Individual multi-select allocating against remaining capacity
 *   - Intermediary case (Benevity-style) — commit creates a corporate GiftCommitment and links srcGT
 *   - No-ACR fallback path — sourceHasEmployerAcr = false
 *   - Rollback: forced insert failure reverts everything
 */
@IsTest(IsParallel=false)
private class FQS_MatchServices_Test {

    private static Account bizAccount(String name, Boolean programFlag) {
        Account a = new Account(Name = name);
        a.FQS_Matching_Gift_Program__c = programFlag;
        insert a;
        return a;
    }

    private static Account intermediaryAccount(String name) {
        Account a = new Account(Name = name);
        a.FQS_Is_Match_Intermediary__c = true;
        insert a;
        return a;
    }

    private static Account personAccount(String firstName, String lastName) {
        Id personRt = getPersonAccountRecordTypeId();
        Account pa = new Account(
            FirstName = firstName,
            LastName = lastName,
            RecordTypeId = personRt
        );
        insert pa;
        return [SELECT Id, PersonContactId, IsPersonAccount FROM Account WHERE Id = :pa.Id];
    }

    private static Id getPersonAccountRecordTypeId() {
        for (Schema.RecordTypeInfo rti : Account.SObjectType.getDescribe().getRecordTypeInfosByName().values()) {
            if (rti.isAvailable() && rti.getName().containsIgnoreCase('Person')) return rti.getRecordTypeId();
        }
        return null;
    }

    private static void linkEmployment(Id personContactId, Id corporateAccountId) {
        insert new AccountContactRelation(
            ContactId = personContactId,
            AccountId = corporateAccountId
        );
    }

    private static GiftTransaction newGift(Id donorAccountId, Decimal amount, String type) {
        return newGift(donorAccountId, amount, type, null, null, null);
    }

    private static GiftTransaction newGift(Id donorAccountId, Decimal amount, String type, Decimal fee, Id campaignId, Id commitmentId) {
        return newGift(donorAccountId, amount, type, fee, campaignId, commitmentId, 'Paid');
    }

    private static GiftTransaction newGift(Id donorAccountId, Decimal amount, String type, Decimal fee, Id campaignId, Id commitmentId, String status) {
        GiftTransaction g = new GiftTransaction(
            Name = 'GT-' + Math.mod(Math.abs(Crypto.getRandomLong()), 1000000000),
            DonorId = donorAccountId,
            OriginalAmount = amount,
            GiftType = type,
            Status = status,
            PaymentMethod = 'Check',
            TransactionDate = Date.today()
        );
        if (fee != null) g.ProcessorTransactionFee = fee;
        if (campaignId != null) g.CampaignId = campaignId;
        if (commitmentId != null) {
            g.GiftCommitmentId = commitmentId;
            g.TransactionDueDate = Date.today();
        }
        insert g;
        return g;
    }

    private static GiftCommitment newCommitment(Id donorAccountId, Decimal expected) {
        GiftCommitment gc = new GiftCommitment(
            Name = 'GC-' + Math.mod(Math.abs(Crypto.getRandomLong()), 1000000000),
            DonorId = donorAccountId,
            ExpectedTotalCmtAmount = expected
        );
        insert gc;
        return gc;
    }

    @IsTest
    static void findAndCommit_individualToCorporate_happyPath() {
        Account corp = bizAccount('Acme Corp', true);
        Account ind = personAccount('Jane', 'Donor');
        linkEmployment(ind.PersonContactId, corp.Id);

        GiftTransaction indGift = newGift(ind.Id, 500, 'Individual');
        GiftTransaction corpGift = newGift(corp.Id, 500, 'Organizational');

        Test.startTest();
        FQS_MatchCandidateService.FindRequest req = new FQS_MatchCandidateService.FindRequest();
        req.sourceGiftId = indGift.Id;
        List<FQS_MatchCandidateService.FindResponse> resps = FQS_MatchCandidateService.findCandidates(new List<FQS_MatchCandidateService.FindRequest>{ req });
        Test.stopTest();

        System.assertEquals('INDIVIDUAL', resps[0].direction);
        System.assertEquals(true, resps[0].sourceHasEmployerAcr);
        System.assert(!resps[0].candidates.isEmpty(), 'Expected at least one candidate');
        Boolean sawCorp = false;
        for (FQS_MatchCandidate mc : resps[0].candidates) {
            if (mc.candidateId == corpGift.Id) {
                sawCorp = true;
                System.assert(mc.score >= 40, 'Corp candidate should score high; got ' + mc.score);
                System.assert(mc.matchReasons.contains('Employer'), 'Reasons should include ACR match: ' + mc.matchReasons);
            }
        }
        System.assert(sawCorp, 'Corporate gift should appear as a candidate');

        FQS_MatchCommitService.CommitRequest cReq = new FQS_MatchCommitService.CommitRequest();
        cReq.sourceGiftId = indGift.Id;
        cReq.direction = 'INDIVIDUAL';
        cReq.selectedCounterpartyIds = new List<String>{ corpGift.Id };
        List<FQS_MatchCommitService.CommitResponse> cResps = FQS_MatchCommitService.commitMatch(new List<FQS_MatchCommitService.CommitRequest>{ cReq });

        System.assertEquals(true, cResps[0].success, 'Commit should succeed: ' + cResps[0].errorMessage);
        GiftTransaction indAfter = [SELECT MatchingEmployerTransactionId, FQS_Matched__c FROM GiftTransaction WHERE Id = :indGift.Id];
        System.assertEquals(corpGift.Id, indAfter.MatchingEmployerTransactionId);
        System.assertEquals(true, indAfter.FQS_Matched__c);
        List<GiftSoftCredit> credits = [SELECT Id, RecipientId, GiftTransactionId FROM GiftSoftCredit WHERE GiftTransactionId IN (:indGift.Id, :corpGift.Id)];
        System.assertEquals(2, credits.size(), 'Two soft credits expected');
        for (GiftSoftCredit sc : credits) {
            if (sc.GiftTransactionId == indGift.Id) System.assertEquals(corp.Id, sc.RecipientId);
            if (sc.GiftTransactionId == corpGift.Id) System.assertEquals(ind.Id, sc.RecipientId);
        }
    }

    @IsTest
    static void netOfFees_500gross_487net_487corporate() {
        Account corp = bizAccount('MatchCo', true);
        Account ind = personAccount('Fee', 'Donor');
        linkEmployment(ind.PersonContactId, corp.Id);

        GiftCommitment pledge = newCommitment(ind.Id, 1000);
        GiftTransaction indGift = newGift(ind.Id, 500, 'Individual', 13, null, pledge.Id);
        GiftTransaction corpGift = newGift(corp.Id, 487, 'Organizational', 0, null, pledge.Id);

        Test.startTest();
        FQS_MatchCandidateService.FindRequest req = new FQS_MatchCandidateService.FindRequest();
        req.sourceGiftId = corpGift.Id;
        List<FQS_MatchCandidateService.FindResponse> resps = FQS_MatchCandidateService.findCandidates(new List<FQS_MatchCandidateService.FindRequest>{ req });
        Test.stopTest();

        System.assertEquals('CORPORATE', resps[0].direction);
        FQS_MatchCandidate hit;
        for (FQS_MatchCandidate mc : resps[0].candidates) {
            if (mc.candidateId == indGift.Id) hit = mc;
        }
        System.assertNotEquals(null, hit, 'Individual gift should be a candidate');
        System.assert(hit.matchReasons.contains('Net-of-fees'), 'Expected net-of-fees signal: ' + hit.matchReasons);
        System.assert(hit.matchReasons.contains('Same commitment'), 'Expected same commitment signal: ' + hit.matchReasons);
    }

    @IsTest
    static void corporateToIndividual_multiSelect_capacity() {
        Account corp = bizAccount('BulkMatch', true);
        Account ind1 = personAccount('Ann', 'Alpha');
        Account ind2 = personAccount('Bob', 'Beta');
        linkEmployment(ind1.PersonContactId, corp.Id);
        linkEmployment(ind2.PersonContactId, corp.Id);

        GiftTransaction ig1 = newGift(ind1.Id, 100, 'Individual');
        GiftTransaction ig2 = newGift(ind2.Id, 150, 'Individual');
        GiftTransaction corpGift = newGift(corp.Id, 250, 'Organizational');

        Test.startTest();
        FQS_MatchCandidateService.FindRequest req = new FQS_MatchCandidateService.FindRequest();
        req.sourceGiftId = corpGift.Id;
        List<FQS_MatchCandidateService.FindResponse> resps = FQS_MatchCandidateService.findCandidates(new List<FQS_MatchCandidateService.FindRequest>{ req });

        FQS_MatchCommitService.CommitRequest cReq = new FQS_MatchCommitService.CommitRequest();
        cReq.sourceGiftId = corpGift.Id;
        cReq.direction = 'CORPORATE';
        cReq.selectedCounterpartyIds = new List<String>{ ig1.Id, ig2.Id };
        List<FQS_MatchCommitService.CommitResponse> cResps = FQS_MatchCommitService.commitMatch(new List<FQS_MatchCommitService.CommitRequest>{ cReq });
        Test.stopTest();

        System.assertEquals(250, resps[0].sourceRemainingCapacity);
        System.assert(cResps[0].success == true, 'Commit failed: ' + cResps[0].errorMessage);
        Integer matchedCount = [SELECT COUNT() FROM GiftTransaction WHERE MatchingEmployerTransactionId = :corpGift.Id];
        System.assertEquals(2, matchedCount);
        Integer creditCount = [SELECT COUNT() FROM GiftSoftCredit WHERE GiftTransactionId IN (:ig1.Id, :ig2.Id, :corpGift.Id)];
        System.assertEquals(4, creditCount);
    }

    @IsTest
    static void intermediary_createsCorporateCommitmentAndSoftCredits() {
        Account benevity = intermediaryAccount('Benevity');
        Account trueCorp = bizAccount('True Corp', true);
        Account ind = personAccount('Ivy', 'Indiv');
        linkEmployment(ind.PersonContactId, trueCorp.Id);
        GiftTransaction indGift = newGift(ind.Id, 200, 'Individual');
        GiftTransaction intGift = newGift(benevity.Id, 200, 'Organizational', null, null, null, 'Unpaid');

        Test.startTest();
        FQS_MatchCommitService.CommitRequest cReq = new FQS_MatchCommitService.CommitRequest();
        cReq.sourceGiftId = intGift.Id;
        cReq.direction = 'CORPORATE';
        cReq.selectedCounterpartyIds = new List<String>{ indGift.Id };
        cReq.trueCorporateAccountId = trueCorp.Id;
        List<FQS_MatchCommitService.CommitResponse> cResps = FQS_MatchCommitService.commitMatch(new List<FQS_MatchCommitService.CommitRequest>{ cReq });
        Test.stopTest();

        System.assert(cResps[0].success == true, 'Commit failed: ' + cResps[0].errorMessage);
        System.assertNotEquals(null, cResps[0].createdCorporateCommitmentId, 'Should create corporate commitment');
        GiftTransaction intAfter = [SELECT GiftCommitmentId FROM GiftTransaction WHERE Id = :intGift.Id];
        System.assertEquals((Id) cResps[0].createdCorporateCommitmentId, intAfter.GiftCommitmentId);
        Integer credOnInt = [SELECT COUNT() FROM GiftSoftCredit WHERE GiftTransactionId = :intGift.Id AND RecipientId = :trueCorp.Id];
        System.assert(credOnInt >= 1, 'Intermediary GT should have a soft credit to the true corporate');
    }

    @IsTest
    static void findCandidates_noAcr_returnsFalseFlag() {
        Account corp = bizAccount('DetachedCorp', true);
        Account ind = personAccount('Lonely', 'Donor');
        newGift(corp.Id, 100, 'Organizational');
        GiftTransaction indGift = newGift(ind.Id, 100, 'Individual');

        Test.startTest();
        FQS_MatchCandidateService.FindRequest req = new FQS_MatchCandidateService.FindRequest();
        req.sourceGiftId = indGift.Id;
        List<FQS_MatchCandidateService.FindResponse> resps = FQS_MatchCandidateService.findCandidates(new List<FQS_MatchCandidateService.FindRequest>{ req });
        Test.stopTest();

        System.assertEquals(false, resps[0].sourceHasEmployerAcr);
    }

    @IsTest
    static void commit_rollback_onFailure() {
        Account corp = bizAccount('RollbackCorp', true);
        Account ind = personAccount('Rollback', 'Donor');
        linkEmployment(ind.PersonContactId, corp.Id);
        GiftTransaction indGift = newGift(ind.Id, 100, 'Individual');
        GiftTransaction corpGift = newGift(corp.Id, 100, 'Organizational');

        Test.startTest();
        FQS_MatchCommitService.CommitRequest cReq = new FQS_MatchCommitService.CommitRequest();
        cReq.sourceGiftId = indGift.Id;
        cReq.direction = 'INDIVIDUAL';
        cReq.selectedCounterpartyIds = new List<String>{ corpGift.Id };
        cReq.markEmployerProgramFlag = true;
        cReq.employerAccountIdToFlag = '001000000000000AAA';
        List<FQS_MatchCommitService.CommitResponse> cResps = FQS_MatchCommitService.commitMatch(new List<FQS_MatchCommitService.CommitRequest>{ cReq });
        Test.stopTest();

        System.assertEquals(false, cResps[0].success, 'Bad employer Id should fail commit');
        GiftTransaction indAfter = [SELECT MatchingEmployerTransactionId, FQS_Matched__c FROM GiftTransaction WHERE Id = :indGift.Id];
        System.assertEquals(null, indAfter.MatchingEmployerTransactionId, 'Rollback should leave link unset');
        System.assertEquals(false, indAfter.FQS_Matched__c, 'Rollback should leave FQS_Matched__c false');
        Integer credits = [SELECT COUNT() FROM GiftSoftCredit WHERE GiftTransactionId IN (:indGift.Id, :corpGift.Id)];
        System.assertEquals(0, credits, 'No credits should exist after rollback');
    }
}
