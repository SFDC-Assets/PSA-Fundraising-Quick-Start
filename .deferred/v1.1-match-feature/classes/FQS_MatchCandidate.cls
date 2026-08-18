/**
 * Apex-defined type returned by FQS_MatchCandidateService.findCandidates and consumed by Flow
 * datatable components. Kept at the top level (not as an inner class) because Flow variables
 * cannot reference nested Apex types via the apexClass attribute.
 */
public class FQS_MatchCandidate {
    @AuraEnabled @InvocableVariable public String candidateId;
    @AuraEnabled @InvocableVariable public String donorName;
    @AuraEnabled @InvocableVariable public Decimal originalAmount;
    @AuraEnabled @InvocableVariable public Decimal netAmount;
    @AuraEnabled @InvocableVariable public String campaignName;
    @AuraEnabled @InvocableVariable public String giftCommitmentId;
    @AuraEnabled @InvocableVariable public String giftCommitmentName;
    @AuraEnabled @InvocableVariable public Decimal alreadyMatchedAmount;
    @AuraEnabled @InvocableVariable public Decimal remainingCapacity;
    @AuraEnabled @InvocableVariable public Decimal ytdMatchedForDonor;
    @AuraEnabled @InvocableVariable public Boolean employerAccountFlagOn;
    @AuraEnabled @InvocableVariable public Integer score;
    @AuraEnabled @InvocableVariable public String matchReasons;
}
