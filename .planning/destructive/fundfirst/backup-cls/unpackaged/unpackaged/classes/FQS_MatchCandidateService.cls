/**
 * Backing service for the FQS Find Matching Gift screen flow.
 *
 * Two invocables:
 *   - findCandidates: read-only. Returns a ranked list of counterparty candidates for a source GiftTransaction.
 *   - commitMatch:    all writes for one confirmed match, wrapped in a savepoint/rollback.
 *
 * Legal-donor rule (enforced everywhere): the Account in GiftTransaction.DonorId is the legal donor for that
 * transaction and NEVER receives a GiftSoftCredit on that transaction. The counterparty is always the one
 * credited on each side.
 */
public with sharing class FQS_MatchCandidateService {

    private static final String DIR_INDIVIDUAL = 'INDIVIDUAL';
    private static final String DIR_CORPORATE  = 'CORPORATE';
    private static final String ROLE_MATCHED_DONOR = 'Matched Donor';

    private static final Integer W_ACR                = 40;
    private static final Integer W_PROGRAM_FLAG       = 20;
    private static final Integer W_SAME_COMMITMENT    = 30;
    private static final Integer W_AMOUNT_EXACT       = 25;
    private static final Integer W_AMOUNT_TOLERANCE   = 10;
    private static final Integer W_NET_OF_FEES        = 5;
    private static final Integer W_SAME_CAMPAIGN      = 10;
    private static final Integer SCORE_MAX_NOMINAL    = 130;
    private static final Decimal TOLERANCE_PERCENT    = 0.05;
    private static final Decimal TOLERANCE_ABSOLUTE   = 5.00;
    private static final Integer CANDIDATE_QUERY_LIMIT = 200;

    // ---------- findCandidates ----------

    public class FindRequest {
        @InvocableVariable(required=true label='Source Gift Transaction Id')
        public Id sourceGiftId;
        @InvocableVariable(label='Override Employer Account Id' description='When source is an intermediary, the true corporate Account for scoring.')
        public Id overrideEmployerAccountId;
    }

    public class FindResponse {
        @InvocableVariable public String direction;
        @InvocableVariable public Boolean sourceHasEmployerAcr;
        @InvocableVariable public Boolean sourceIsIntermediary;
        @InvocableVariable public Decimal sourceOriginalAmount;
        @InvocableVariable public Decimal sourceRemainingCapacity;
        @InvocableVariable public List<FQS_MatchCandidate> candidates;
    }

    @InvocableMethod(label='Find Matching Gift Candidates' description='Returns ranked counterparty GiftTransactions for a source gift, plus direction and capacity metadata.' callout=false)
    public static List<FindResponse> findCandidates(List<FindRequest> requests) {
        List<FindResponse> out = new List<FindResponse>();
        for (FindRequest req : requests) {
            out.add(findOne(req));
        }
        return out;
    }

    private static FindResponse findOne(FindRequest req) {
        FindResponse resp = new FindResponse();
        resp.candidates = new List<FQS_MatchCandidate>();

        GiftTransaction src = loadSource(req.sourceGiftId);
        Account srcDonor = src.DonorId != null ? loadAccount(src.DonorId) : null;
        Boolean isPerson = srcDonor != null && srcDonor.IsPersonAccount;
        resp.direction = isPerson ? DIR_INDIVIDUAL : DIR_CORPORATE;
        resp.sourceOriginalAmount = src.OriginalAmount;
        resp.sourceIsIntermediary = srcDonor != null && srcDonor.FQS_Is_Match_Intermediary__c == true;

        Id effectiveEmployerId = req.overrideEmployerAccountId != null ? req.overrideEmployerAccountId : (isPerson ? null : src.DonorId);
        Set<Id> individualEmployers = isPerson ? employerAccountIdsForPerson(src.DonorId) : new Set<Id>();
        resp.sourceHasEmployerAcr = !individualEmployers.isEmpty();

        if (resp.direction == DIR_CORPORATE) {
            resp.sourceRemainingCapacity = computeRemainingCapacity(src);
        }

        List<GiftTransaction> raw = queryCandidates(src, resp.direction, individualEmployers, effectiveEmployerId);
        if (raw.isEmpty()) return resp;

        Map<Id, Decimal> childMatchedByCorporate = corporateChildMatchedTotals(raw, resp.direction);
        Map<Id, Decimal> ytdByDonor = ytdMatchedForDonors(raw, resp.direction, effectiveEmployerId);

        Map<Id, Account> donorAccountsById = loadCandidateDonorAccounts(raw);
        Set<Id> corporateEmployeePersonAccountIds = resp.direction == DIR_CORPORATE && effectiveEmployerId != null
            ? personAccountIdsForCorporate(effectiveEmployerId)
            : new Set<Id>();

        for (GiftTransaction cand : raw) {
            Account candDonor = cand.DonorId == null ? null : donorAccountsById.get(cand.DonorId);
            Decimal ratio;
            Decimal annualMax;
            if (resp.direction == DIR_CORPORATE) {
                ratio = srcDonor != null && srcDonor.FQS_Match_Ratio__c != null ? srcDonor.FQS_Match_Ratio__c : 1.00;
                annualMax = srcDonor == null ? null : srcDonor.FQS_Match_Annual_Individual_Maximum__c;
            } else {
                ratio = candDonor != null && candDonor.FQS_Match_Ratio__c != null ? candDonor.FQS_Match_Ratio__c : 1.00;
                annualMax = candDonor == null ? null : candDonor.FQS_Match_Annual_Individual_Maximum__c;
            }
            FQS_MatchCandidate mc = scoreOne(src, cand, candDonor, resp.direction, individualEmployers, corporateEmployeePersonAccountIds, effectiveEmployerId, ratio, childMatchedByCorporate, ytdByDonor, annualMax);
            if (mc != null) resp.candidates.add(mc);
        }
        resp.candidates.sort(new CandidateComparator());
        return resp;
    }

    private static GiftTransaction loadSource(Id giftId) {
        List<GiftTransaction> src = [
            SELECT Id, DonorId, GiftCommitmentId, OriginalAmount, TotalTransactionFee,
                   CampaignId, MatchingEmployerTransactionId, FQS_Match_Status__c, GiftType
            FROM GiftTransaction
            WHERE Id = :giftId
            LIMIT 1
        ];
        if (src.isEmpty()) {
            throw new FQS_MatchException('Source GiftTransaction not found: ' + giftId);
        }
        return src[0];
    }

    private static Account loadAccount(Id accountId) {
        List<Account> a = [
            SELECT Id, Name, IsPersonAccount, PersonContactId,
                   FQS_Matching_Gift_Program__c, FQS_Is_Match_Intermediary__c,
                   FQS_Match_Ratio__c, FQS_Match_Annual_Individual_Maximum__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
        return a.isEmpty() ? null : a[0];
    }

    private static Set<Id> employerAccountIdsForPerson(Id personAccountId) {
        Set<Id> employers = new Set<Id>();
        Id personContactId;
        List<Account> pa = [SELECT PersonContactId FROM Account WHERE Id = :personAccountId LIMIT 1];
        if (!pa.isEmpty()) personContactId = pa[0].PersonContactId;
        if (personContactId == null) return employers;
        for (AccountContactRelation acr : [
            SELECT AccountId
            FROM AccountContactRelation
            WHERE ContactId = :personContactId
              AND IsDirect = false
        ]) {
            employers.add(acr.AccountId);
        }
        return employers;
    }

    private static Set<Id> personAccountIdsForCorporate(Id corporateAccountId) {
        Set<Id> contactIds = new Set<Id>();
        for (AccountContactRelation acr : [
            SELECT ContactId FROM AccountContactRelation
            WHERE AccountId = :corporateAccountId AND IsDirect = false
        ]) {
            contactIds.add(acr.ContactId);
        }
        Set<Id> personAccountIds = new Set<Id>();
        if (contactIds.isEmpty()) return personAccountIds;
        for (Account a : [
            SELECT Id FROM Account
            WHERE PersonContactId IN :contactIds
        ]) {
            personAccountIds.add(a.Id);
        }
        return personAccountIds;
    }

    private static List<GiftTransaction> queryCandidates(
        GiftTransaction src,
        String direction,
        Set<Id> individualEmployers,
        Id effectiveEmployerId
    ) {
        Set<Id> candidateIds = new Set<Id>();

        if (direction == DIR_INDIVIDUAL) {
            Set<Id> employerScope = new Set<Id>();
            if (effectiveEmployerId != null) employerScope.add(effectiveEmployerId);
            employerScope.addAll(individualEmployers);
            if (!employerScope.isEmpty()) {
                for (GiftTransaction g : [
                    SELECT Id FROM GiftTransaction
                    WHERE DonorId IN :employerScope
                      AND Id != :src.Id
                    LIMIT :CANDIDATE_QUERY_LIMIT
                ]) candidateIds.add(g.Id);
            }
            if (src.GiftCommitmentId != null) {
                for (GiftTransaction g : [
                    SELECT Id FROM GiftTransaction
                    WHERE GiftCommitmentId = :src.GiftCommitmentId
                      AND Id != :src.Id
                    LIMIT :CANDIDATE_QUERY_LIMIT
                ]) candidateIds.add(g.Id);
            }
            for (GiftTransaction g : [
                SELECT Id FROM GiftTransaction
                WHERE DonorId IN (SELECT Id FROM Account WHERE FQS_Matching_Gift_Program__c = true)
                  AND Id != :src.Id
                LIMIT :CANDIDATE_QUERY_LIMIT
            ]) candidateIds.add(g.Id);
        } else {
            Set<Id> employerForCorporate = new Set<Id>{ effectiveEmployerId };
            Set<Id> personAccountIds = personAccountIdsForCorporate(effectiveEmployerId);
            if (!personAccountIds.isEmpty()) {
                for (GiftTransaction g : [
                    SELECT Id FROM GiftTransaction
                    WHERE DonorId IN :personAccountIds
                      AND (MatchingEmployerTransactionId = null OR MatchingEmployerTransactionId != :src.Id)
                      AND Id != :src.Id
                    LIMIT :CANDIDATE_QUERY_LIMIT
                ]) candidateIds.add(g.Id);
            }
            if (src.GiftCommitmentId != null) {
                for (GiftTransaction g : [
                    SELECT Id FROM GiftTransaction
                    WHERE GiftCommitmentId = :src.GiftCommitmentId
                      AND Id != :src.Id
                      AND MatchingEmployerTransactionId = null
                    LIMIT :CANDIDATE_QUERY_LIMIT
                ]) candidateIds.add(g.Id);
            }
        }

        if (candidateIds.isEmpty()) return new List<GiftTransaction>();
        return [
            SELECT Id, Name, DonorId, OriginalAmount, TotalTransactionFee, CampaignId, Campaign.Name,
                   GiftCommitmentId, GiftCommitment.Name, MatchingEmployerTransactionId,
                   GiftType
            FROM GiftTransaction
            WHERE Id IN :candidateIds
            LIMIT :CANDIDATE_QUERY_LIMIT
        ];
    }

    private static Decimal computeRemainingCapacity(GiftTransaction src) {
        AggregateResult[] rows = [
            SELECT SUM(OriginalAmount) total
            FROM GiftTransaction
            WHERE MatchingEmployerTransactionId = :src.Id
        ];
        Decimal alreadyAllocated = rows.isEmpty() || rows[0].get('total') == null ? 0 : (Decimal) rows[0].get('total');
        return (src.OriginalAmount == null ? 0 : src.OriginalAmount) - alreadyAllocated;
    }

    private static Map<Id, Decimal> corporateChildMatchedTotals(List<GiftTransaction> raw, String direction) {
        Map<Id, Decimal> out = new Map<Id, Decimal>();
        if (direction != DIR_INDIVIDUAL) return out;
        Set<Id> corporateIds = new Set<Id>();
        for (GiftTransaction g : raw) corporateIds.add(g.Id);
        if (corporateIds.isEmpty()) return out;
        for (AggregateResult ar : [
            SELECT MatchingEmployerTransactionId corpId, SUM(OriginalAmount) total
            FROM GiftTransaction
            WHERE MatchingEmployerTransactionId IN :corporateIds
            GROUP BY MatchingEmployerTransactionId
        ]) {
            out.put((Id) ar.get('corpId'), (Decimal) ar.get('total'));
        }
        return out;
    }

    private static Map<Id, Decimal> ytdMatchedForDonors(List<GiftTransaction> raw, String direction, Id effectiveEmployerId) {
        Map<Id, Decimal> out = new Map<Id, Decimal>();
        if (direction != DIR_CORPORATE || effectiveEmployerId == null) return out;
        Set<Id> donorIds = new Set<Id>();
        for (GiftTransaction g : raw) if (g.DonorId != null) donorIds.add(g.DonorId);
        if (donorIds.isEmpty()) return out;
        Set<Id> employerGiftIds = new Set<Id>();
        for (GiftTransaction g : [
            SELECT Id FROM GiftTransaction WHERE DonorId = :effectiveEmployerId
        ]) employerGiftIds.add(g.Id);
        if (employerGiftIds.isEmpty()) return out;
        Integer currentYear = Date.today().year();
        for (AggregateResult ar : [
            SELECT DonorId donorId, SUM(OriginalAmount) total
            FROM GiftTransaction
            WHERE DonorId IN :donorIds
              AND MatchingEmployerTransactionId IN :employerGiftIds
              AND CALENDAR_YEAR(TransactionDate) = :currentYear
            GROUP BY DonorId
        ]) {
            out.put((Id) ar.get('donorId'), (Decimal) ar.get('total'));
        }
        return out;
    }

    private static Map<Id, Account> loadCandidateDonorAccounts(List<GiftTransaction> raw) {
        Set<Id> donorIds = new Set<Id>();
        for (GiftTransaction g : raw) if (g.DonorId != null) donorIds.add(g.DonorId);
        Map<Id, Account> out = new Map<Id, Account>();
        if (donorIds.isEmpty()) return out;
        for (Account a : [
            SELECT Id, Name, IsPersonAccount,
                   FQS_Matching_Gift_Program__c, FQS_Is_Match_Intermediary__c,
                   FQS_Match_Ratio__c, FQS_Match_Annual_Individual_Maximum__c
            FROM Account WHERE Id IN :donorIds
        ]) out.put(a.Id, a);
        return out;
    }

    private static FQS_MatchCandidate scoreOne(
        GiftTransaction src,
        GiftTransaction cand,
        Account candDonor,
        String direction,
        Set<Id> individualEmployers,
        Set<Id> corporateEmployeePersonAccountIds,
        Id effectiveEmployerId,
        Decimal ratio,
        Map<Id, Decimal> childMatchedByCorporate,
        Map<Id, Decimal> ytdByDonor,
        Decimal annualMax
    ) {
        FQS_MatchCandidate mc = new FQS_MatchCandidate();
        mc.candidateId = cand.Id;
        mc.originalAmount = cand.OriginalAmount == null ? 0 : cand.OriginalAmount;
        Decimal fee = cand.TotalTransactionFee == null ? 0 : cand.TotalTransactionFee;
        mc.netAmount = mc.originalAmount - fee;
        mc.campaignName = cand.Campaign != null ? cand.Campaign.Name : null;
        mc.giftCommitmentId = cand.GiftCommitmentId;
        mc.giftCommitmentName = cand.GiftCommitment != null ? cand.GiftCommitment.Name : null;
        mc.donorName = candDonor != null ? candDonor.Name : null;
        mc.employerAccountFlagOn = candDonor != null && candDonor.FQS_Matching_Gift_Program__c == true;

        List<String> reasons = new List<String>();
        Integer score = 0;

        Boolean acrHit;
        if (direction == DIR_INDIVIDUAL) {
            acrHit = individualEmployers.contains(cand.DonorId) || (effectiveEmployerId != null && effectiveEmployerId == cand.DonorId);
        } else {
            acrHit = corporateEmployeePersonAccountIds.contains(cand.DonorId);
        }
        if (acrHit) { score += W_ACR; reasons.add('Employer via ACR'); }

        if (mc.employerAccountFlagOn == true) { score += W_PROGRAM_FLAG; reasons.add('Employer flag on'); }

        if (src.GiftCommitmentId != null && cand.GiftCommitmentId == src.GiftCommitmentId) {
            score += W_SAME_COMMITMENT; reasons.add('Same commitment');
        }

        Decimal srcAmt = src.OriginalAmount == null ? 0 : src.OriginalAmount;
        Decimal srcNet = srcAmt - (src.TotalTransactionFee == null ? 0 : src.TotalTransactionFee);
        Decimal expectedFromIndividual = direction == DIR_INDIVIDUAL ? srcAmt * ratio : mc.originalAmount * ratio;
        Decimal comparedTo = direction == DIR_INDIVIDUAL ? mc.originalAmount : srcAmt;

        if (expectedFromIndividual == comparedTo) {
            score += W_AMOUNT_EXACT; reasons.add('Amount exact (' + ratio.setScale(2) + ':1)');
        } else if (amountsWithinTolerance(expectedFromIndividual, comparedTo)) {
            score += W_AMOUNT_TOLERANCE; reasons.add('Amount within tolerance');
        }

        Decimal expectedNetFromIndividual = direction == DIR_INDIVIDUAL ? srcNet * ratio : mc.netAmount * ratio;
        Decimal comparedNet = direction == DIR_INDIVIDUAL ? mc.netAmount : srcNet;
        if (expectedNetFromIndividual == comparedNet && expectedFromIndividual != comparedTo) {
            score += W_NET_OF_FEES; reasons.add('Net-of-fees match');
        } else if (expectedNetFromIndividual == comparedNet && expectedFromIndividual == comparedTo) {
            score += W_NET_OF_FEES; reasons.add('Net-of-fees confirmed');
        }

        if (src.CampaignId != null && cand.CampaignId == src.CampaignId) {
            score += W_SAME_CAMPAIGN; reasons.add('Same campaign');
        }

        if (direction == DIR_INDIVIDUAL) {
            mc.alreadyMatchedAmount = childMatchedByCorporate.get(cand.Id) == null ? 0 : childMatchedByCorporate.get(cand.Id);
            mc.remainingCapacity = mc.originalAmount - mc.alreadyMatchedAmount;
            if (mc.remainingCapacity != null && mc.remainingCapacity <= 0) return null;
        } else {
            mc.ytdMatchedForDonor = ytdByDonor.get(cand.DonorId) == null ? 0 : ytdByDonor.get(cand.DonorId);
            if (annualMax != null && mc.ytdMatchedForDonor + mc.originalAmount > annualMax) {
                reasons.add('WARNING: would exceed annual individual maximum');
            }
        }

        mc.score = Math.min(100, (score * 100) / SCORE_MAX_NOMINAL);
        mc.matchReasons = String.join(reasons, '; ');
        return mc;
    }

    private static Boolean amountsWithinTolerance(Decimal a, Decimal b) {
        if (a == null || b == null) return false;
        Decimal diff = Math.abs(a - b);
        Decimal pct = a == 0 ? 999 : diff / a;
        return diff <= TOLERANCE_ABSOLUTE || pct <= TOLERANCE_PERCENT;
    }

    private class CandidateComparator implements Comparator<FQS_MatchCandidate> {
        public Integer compare(FQS_MatchCandidate x, FQS_MatchCandidate y) {
            Integer sx = x.score == null ? 0 : x.score;
            Integer sy = y.score == null ? 0 : y.score;
            if (sx == sy) return 0;
            return sx > sy ? -1 : 1;
        }
    }

    public class FQS_MatchException extends Exception {}
}