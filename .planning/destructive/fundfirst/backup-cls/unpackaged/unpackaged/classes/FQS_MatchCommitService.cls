/**
 * Applies a confirmed match from the FQS Find Matching Gift flow.
 *
 * All writes for one invocation run inside a single savepoint. If any step fails, everything rolls back
 * and the CommitResponse.success flag is set to false with an error message — the flow's fault path
 * shows this to the user with the guarantee that nothing was saved.
 *
 * Legal-donor rule: GiftSoftCredit rows always credit the counterparty Account, never the Account
 * named in the target GiftTransaction's DonorId.
 */
public with sharing class FQS_MatchCommitService {

    private static final String DIR_INDIVIDUAL = 'INDIVIDUAL';
    private static final String DIR_CORPORATE  = 'CORPORATE';
    private static final String ROLE_MATCHED_DONOR = 'Matched Donor';

    public class CommitRequest {
        @InvocableVariable(required=true label='Source Gift Transaction Id') public Id sourceGiftId;
        @InvocableVariable(required=true label='Direction' description='INDIVIDUAL or CORPORATE — the launch direction of the flow.') public String direction;
        @InvocableVariable(label='Selected Counterparty Gift Ids' description='The corporate gift (single) when INDIVIDUAL, or individual gifts (many) when CORPORATE.') public List<String> selectedCounterpartyIds;
        @InvocableVariable(label='Mark Employer Program Flag') public Boolean markEmployerProgramFlag;
        @InvocableVariable(label='Employer Account Id To Flag') public String employerAccountIdToFlag;
        @InvocableVariable(label='True Corporate Account Id') public String trueCorporateAccountId;
        @InvocableVariable(label='Reuse Corporate Commitment Id') public String reuseCorporateCommitmentId;
        @InvocableVariable(label='Create Recurring Commitment') public Boolean createRecurringCommitment;
        @InvocableVariable(label='Recurring Commitment Amount') public Decimal recurringCommitmentAmount;
        @InvocableVariable(label='Recurring Recurrence Type') public String recurringRecurrenceType;
        @InvocableVariable(label='Recurring Start Date') public Date recurringStartDate;
        @InvocableVariable(label='Individual Person Account Id For Recurring Soft Credit') public String recurringSoftCreditAccountId;
        @InvocableVariable(label='ACR Contact Id') public String acrContactId;
        @InvocableVariable(label='ACR Account Id') public String acrAccountId;
        @InvocableVariable(label='ACR Role') public String acrRole;
    }

    public class CommitResponse {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String errorMessage;
        @InvocableVariable public String createdCorporateCommitmentId;
        @InvocableVariable public String createdRecurringCommitmentId;
        @InvocableVariable public List<String> createdSoftCreditIds;
        @InvocableVariable public String summary;
    }

    @InvocableMethod(label='Commit Matching Gift' description='Applies match link, soft credits, optional intermediary commitment, optional recurring commitment. All-or-nothing under one savepoint.' callout=false)
    public static List<CommitResponse> commitMatch(List<CommitRequest> requests) {
        List<CommitResponse> out = new List<CommitResponse>();
        for (CommitRequest req : requests) out.add(commitOne(req));
        return out;
    }

    private static CommitResponse commitOne(CommitRequest req) {
        CommitResponse resp = new CommitResponse();
        resp.createdSoftCreditIds = new List<String>();
        Savepoint sp = Database.setSavepoint();
        try {
            GiftTransaction src = [
                SELECT Id, DonorId, GiftCommitmentId, OriginalAmount, TotalTransactionFee, CampaignId,
                       MatchingEmployerTransactionId, FQS_Match_Status__c, TransactionDueDate
                FROM GiftTransaction WHERE Id = :req.sourceGiftId LIMIT 1
            ];

            if (req.markEmployerProgramFlag == true && String.isNotBlank(req.employerAccountIdToFlag)) {
                update new Account(Id = (Id) req.employerAccountIdToFlag, FQS_Matching_Gift_Program__c = true);
            }

            if (String.isNotBlank(req.acrContactId) && String.isNotBlank(req.acrAccountId)) {
                AccountContactRelation acr = new AccountContactRelation(
                    ContactId = (Id) req.acrContactId,
                    AccountId = (Id) req.acrAccountId
                );
                if (String.isNotBlank(req.acrRole)) acr.Roles = req.acrRole;
                insert acr;
            }

            Id corpCommitmentId;
            if (String.isNotBlank(req.trueCorporateAccountId)) {
                if (String.isNotBlank(req.reuseCorporateCommitmentId)) {
                    corpCommitmentId = (Id) req.reuseCorporateCommitmentId;
                } else {
                    GiftCommitment gc = new GiftCommitment(
                        Name = 'Corporate Match Commitment',
                        DonorId = (Id) req.trueCorporateAccountId,
                        ExpectedTotalCmtAmount = src.OriginalAmount == null ? 0 : src.OriginalAmount
                    );
                    insert gc;
                    corpCommitmentId = gc.Id;
                    resp.createdCorporateCommitmentId = corpCommitmentId;
                }
                GiftTransaction updSrc = new GiftTransaction(Id = src.Id, GiftCommitmentId = corpCommitmentId);
                if (src.TransactionDueDate == null) updSrc.TransactionDueDate = Date.today();
                update updSrc;
                GiftSoftCredit intermediarySc = new GiftSoftCredit(
                    GiftTransactionId = src.Id,
                    RecipientId = (Id) req.trueCorporateAccountId,
                    PartialAmount =src.OriginalAmount,
                    Role = ROLE_MATCHED_DONOR
                );
                insert intermediarySc;
                resp.createdSoftCreditIds.add(intermediarySc.Id);
            }

            if (req.createRecurringCommitment == true) {
                Id corporateForRecurring = String.isNotBlank(req.trueCorporateAccountId)
                    ? (Id) req.trueCorporateAccountId
                    : (req.direction == DIR_INDIVIDUAL
                        ? (req.selectedCounterpartyIds != null && !req.selectedCounterpartyIds.isEmpty()
                            ? corporateDonorFor((Id) req.selectedCounterpartyIds[0])
                            : null)
                        : src.DonorId);
                if (corporateForRecurring != null) {
                    GiftCommitment rec = new GiftCommitment(
                        Name = 'Recurring Employer Match',
                        DonorId = corporateForRecurring,
                        ExpectedTotalCmtAmount = req.recurringCommitmentAmount == null ? 0 : req.recurringCommitmentAmount,
                        RecurrenceType = req.recurringRecurrenceType
                    );
                    insert rec;
                    resp.createdRecurringCommitmentId = rec.Id;
                    if (String.isNotBlank(req.recurringSoftCreditAccountId)) {
                        insert new GiftDefaultSoftCredit(
                            ParentRecordId = rec.Id,
                            RecipientId = (Id) req.recurringSoftCreditAccountId,
                            Role = ROLE_MATCHED_DONOR
                        );
                    }
                }
            }

            applyMatchLinksAndSoftCredits(src, req, resp);

            resp.success = true;
            resp.summary = buildSummary(req, resp);
            return resp;
        } catch (Exception e) {
            Database.rollback(sp);
            resp.success = false;
            resp.errorMessage = e.getTypeName() + ': ' + e.getMessage();
            return resp;
        }
    }

    private static void applyMatchLinksAndSoftCredits(GiftTransaction src, CommitRequest req, CommitResponse resp) {
        if (req.selectedCounterpartyIds == null || req.selectedCounterpartyIds.isEmpty()) return;
        Set<Id> ids = new Set<Id>();
        for (String s : req.selectedCounterpartyIds) if (String.isNotBlank(s)) ids.add((Id) s);
        List<GiftTransaction> selectedGifts = [
            SELECT Id, DonorId, OriginalAmount, GiftCommitmentId
            FROM GiftTransaction WHERE Id IN :ids
        ];
        List<GiftTransaction> gtUpdates = new List<GiftTransaction>();
        List<GiftSoftCredit> softCredits = new List<GiftSoftCredit>();

        if (req.direction == DIR_INDIVIDUAL) {
            if (selectedGifts.isEmpty()) return;
            GiftTransaction corp = selectedGifts[0];
            gtUpdates.add(new GiftTransaction(
                Id = src.Id,
                MatchingEmployerTransactionId = corp.Id,
                FQS_Match_Status__c = 'Received'
            ));
            gtUpdates.add(new GiftTransaction(Id = corp.Id, FQS_Match_Status__c = 'Received'));
            softCredits.add(new GiftSoftCredit(
                GiftTransactionId = src.Id,
                RecipientId = corp.DonorId,
                PartialAmount =src.OriginalAmount,
                Role = ROLE_MATCHED_DONOR
            ));
            softCredits.add(new GiftSoftCredit(
                GiftTransactionId = corp.Id,
                RecipientId = src.DonorId,
                PartialAmount =src.OriginalAmount,
                Role = ROLE_MATCHED_DONOR
            ));
        } else {
            for (GiftTransaction ind : selectedGifts) {
                gtUpdates.add(new GiftTransaction(
                    Id = ind.Id,
                    MatchingEmployerTransactionId = src.Id,
                    FQS_Match_Status__c = 'Received'
                ));
                softCredits.add(new GiftSoftCredit(
                    GiftTransactionId = ind.Id,
                    RecipientId = src.DonorId,
                    PartialAmount =ind.OriginalAmount,
                    Role = ROLE_MATCHED_DONOR
                ));
                softCredits.add(new GiftSoftCredit(
                    GiftTransactionId = src.Id,
                    RecipientId = ind.DonorId,
                    PartialAmount =ind.OriginalAmount,
                    Role = ROLE_MATCHED_DONOR
                ));
            }
            gtUpdates.add(new GiftTransaction(Id = src.Id, FQS_Match_Status__c = 'Received'));
        }

        if (!gtUpdates.isEmpty()) update gtUpdates;
        if (!softCredits.isEmpty()) {
            insert softCredits;
            for (GiftSoftCredit sc : softCredits) resp.createdSoftCreditIds.add(sc.Id);
        }
    }

    private static Id corporateDonorFor(Id giftId) {
        List<GiftTransaction> g = [SELECT DonorId FROM GiftTransaction WHERE Id = :giftId LIMIT 1];
        return g.isEmpty() ? null : g[0].DonorId;
    }

    private static String buildSummary(CommitRequest req, CommitResponse resp) {
        List<String> parts = new List<String>();
        parts.add('Match committed.');
        if (resp.createdCorporateCommitmentId != null) parts.add('Corporate GiftCommitment created.');
        if (resp.createdRecurringCommitmentId != null) parts.add('Recurring matching GiftCommitment created.');
        parts.add('Soft credits inserted: ' + resp.createdSoftCreditIds.size() + '.');
        return String.join(parts, ' ');
    }
}