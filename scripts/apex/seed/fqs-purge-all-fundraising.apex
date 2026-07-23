// FQS Full Purge — deletes ALL fundraising records regardless of origin.
//
// DANGER: unlike fqs-seed-teardown.apex, this script does NOT filter by
// External_Id__c LIKE 'FQS-%'. It removes every row from the target objects,
// including manually-created data, imports, and non-seed records.
//
// Intended for full-org resets (e.g. wiping FundFirst before re-seeding at
// scale). Idempotent and re-runnable. Each pass consumes at most ~9,000 DML
// rows to stay under the 10K per-transaction cap; larger datasets need
// multiple invocations. Pair with fqs-purge-all-fundraising-loop.sh.
//
// Leaves untouched: Users, Profiles, PermSets, metadata, Reports/Dashboards.

System.debug('=== FQS Full Purge starting ===');

Integer DML_BUDGET = 9000;
Integer totalDeleted = 0;
Map<String, Integer> counts = new Map<String, Integer>();
Integer slot;

// 0a. ContactContactRelation — before Contacts/Accounts.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<ContactContactRelation> ccrs = Database.query('SELECT Id FROM ContactContactRelation LIMIT ' + slot);
    if (!ccrs.isEmpty()) { delete ccrs; counts.put('ContactContactRelation', ccrs.size()); totalDeleted += ccrs.size(); }
}

// 0b. CampaignMember — before Campaigns/Contacts.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<CampaignMember> cms = Database.query('SELECT Id FROM CampaignMember LIMIT ' + slot);
    if (!cms.isEmpty()) { delete cms; counts.put('CampaignMember', cms.size()); totalDeleted += cms.size(); }
}

// 0c. GiftDefaultDesignation — MD child of GiftCommitment.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftDefaultDesignation> gdds = Database.query('SELECT Id FROM GiftDefaultDesignation LIMIT ' + slot);
    if (!gdds.isEmpty()) { delete gdds; counts.put('GiftDefaultDesignation', gdds.size()); totalDeleted += gdds.size(); }
}

// 0d. AccountContactRelation — must go before Accounts.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<AccountContactRelation> acrs = Database.query('SELECT Id FROM AccountContactRelation WHERE IsDirect = false LIMIT ' + slot);
    if (!acrs.isEmpty()) {
        try { delete acrs; counts.put('AccountContactRelation', acrs.size()); totalDeleted += acrs.size(); }
        catch (Exception e) { System.debug('AccountContactRelation delete skipped: ' + e.getMessage()); }
    }
}

// 1. GiftRefund
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftRefund> refunds = Database.query('SELECT Id FROM GiftRefund LIMIT ' + slot);
    if (!refunds.isEmpty()) { delete refunds; counts.put('GiftRefund', refunds.size()); totalDeleted += refunds.size(); }
}

// 2. GiftTransactionDesignation
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftTransactionDesignation> gtds = Database.query('SELECT Id FROM GiftTransactionDesignation LIMIT ' + slot);
    if (!gtds.isEmpty()) { delete gtds; counts.put('GiftTransactionDesignation', gtds.size()); totalDeleted += gtds.size(); }
}

// 3. GiftSoftCredit
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftSoftCredit> softCredits = Database.query('SELECT Id FROM GiftSoftCredit LIMIT ' + slot);
    if (!softCredits.isEmpty()) { delete softCredits; counts.put('GiftSoftCredit', softCredits.size()); totalDeleted += softCredits.size(); }
}

// 4. GiftTribute
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftTribute> tributes = Database.query('SELECT Id FROM GiftTribute LIMIT ' + slot);
    if (!tributes.isEmpty()) { delete tributes; counts.put('GiftTribute', tributes.size()); totalDeleted += tributes.size(); }
}

// 5. GiftTransaction — get full remaining budget. Blocks Commitment delete downstream.
slot = DML_BUDGET - totalDeleted;
Boolean gtQueueRemaining = false;
if (slot > 0) {
    List<GiftTransaction> gts = Database.query('SELECT Id FROM GiftTransaction LIMIT ' + slot);
    if (!gts.isEmpty()) { delete gts; counts.put('GiftTransaction', gts.size()); totalDeleted += gts.size(); }
    gtQueueRemaining = (gts.size() == slot);
}

// 6. GiftCommitmentSchedule (skip if GTs may still exist)
slot = gtQueueRemaining ? 0 : Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftCommitmentSchedule> schedules = Database.query('SELECT Id FROM GiftCommitmentSchedule LIMIT ' + slot);
    if (!schedules.isEmpty()) { delete schedules; counts.put('GiftCommitmentSchedule', schedules.size()); totalDeleted += schedules.size(); }
}

// 7. GiftCommitment (skip if GTs still remaining)
slot = gtQueueRemaining ? 0 : Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftCommitment> gcs = Database.query('SELECT Id FROM GiftCommitment LIMIT ' + slot);
    if (!gcs.isEmpty()) { delete gcs; counts.put('GiftCommitment', gcs.size()); totalDeleted += gcs.size(); }
}

// 8. OpportunityContactRole — before Opportunity/Contact cascade.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<OpportunityContactRole> ocrs = Database.query('SELECT Id FROM OpportunityContactRole LIMIT ' + slot);
    if (!ocrs.isEmpty()) {
        try { delete ocrs; counts.put('OpportunityContactRole', ocrs.size()); totalDeleted += ocrs.size(); }
        catch (Exception e) { System.debug('OpportunityContactRole delete skipped: ' + e.getMessage()); }
    }
}

// 9. Opportunity
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Opportunity> opps = Database.query('SELECT Id FROM Opportunity LIMIT ' + slot);
    if (!opps.isEmpty()) { delete opps; counts.put('Opportunity', opps.size()); totalDeleted += opps.size(); }
}

// 10. PaymentInstrument
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<PaymentInstrument> pis = Database.query('SELECT Id FROM PaymentInstrument LIMIT ' + slot);
    if (!pis.isEmpty()) { delete pis; counts.put('PaymentInstrument', pis.size()); totalDeleted += pis.size(); }
}

// 11. DonorGiftSummary — MD child of Account.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<DonorGiftSummary> dgss = Database.query('SELECT Id FROM DonorGiftSummary LIMIT ' + slot);
    if (!dgss.isEmpty()) {
        try { delete dgss; counts.put('DonorGiftSummary', dgss.size()); totalDeleted += dgss.size(); }
        catch (Exception e) { System.debug('DonorGiftSummary delete skipped: ' + e.getMessage()); }
    }
}

// 12. OutreachSummary
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    try {
        List<SObject> osums = Database.query('SELECT Id FROM OutreachSummary LIMIT ' + slot);
        if (!osums.isEmpty()) { delete osums; counts.put('OutreachSummary', osums.size()); totalDeleted += osums.size(); }
    } catch (Exception e) { System.debug('OutreachSummary skipped: ' + e.getMessage()); }
}

// 13. Contact — non-person Contacts on business accounts. Person Account contacts
// cascade with Account delete, so this will error on them; catch and continue.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Contact> contacts = Database.query('SELECT Id FROM Contact WHERE Account.IsPersonAccount = false LIMIT ' + slot);
    if (!contacts.isEmpty()) {
        try { delete contacts; counts.put('Contact', contacts.size()); totalDeleted += contacts.size(); }
        catch (Exception e) { System.debug('Contact delete partial: ' + e.getMessage()); }
    }
}

// 14. Account — everything. Person Accounts cascade their Contact.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Account> accts = Database.query('SELECT Id FROM Account LIMIT ' + slot);
    if (!accts.isEmpty()) { delete accts; counts.put('Account', accts.size()); totalDeleted += accts.size(); }
}

// 15. OutreachSourceCode
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<OutreachSourceCode> oscs = Database.query('SELECT Id FROM OutreachSourceCode LIMIT ' + slot);
    if (!oscs.isEmpty()) { delete oscs; counts.put('OutreachSourceCode', oscs.size()); totalDeleted += oscs.size(); }
}

// 16. GiftDesignation — must clear IsDefault, then deactivate, before delete.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftDesignation> gds = Database.query('SELECT Id, IsActive, IsDefault FROM GiftDesignation LIMIT ' + slot);
    if (!gds.isEmpty()) {
        // Pass 1: clear IsDefault (Salesforce blocks deactivation of the default).
        List<GiftDesignation> toUndefault = new List<GiftDesignation>();
        for (GiftDesignation gd : gds) {
            if (gd.IsDefault) { gd.IsDefault = false; toUndefault.add(gd); }
        }
        if (!toUndefault.isEmpty()) {
            try { update toUndefault; }
            catch (Exception e) { System.debug('GiftDesignation clear-default skipped: ' + e.getMessage()); }
        }
        // Pass 2: deactivate.
        List<GiftDesignation> toDeactivate = new List<GiftDesignation>();
        for (GiftDesignation gd : gds) {
            if (gd.IsActive) { gd.IsActive = false; toDeactivate.add(gd); }
        }
        if (!toDeactivate.isEmpty()) {
            try { update toDeactivate; }
            catch (Exception e) { System.debug('GiftDesignation deactivate skipped: ' + e.getMessage()); }
        }
        // Pass 3: delete.
        try { delete gds; counts.put('GiftDesignation', gds.size()); totalDeleted += gds.size(); }
        catch (Exception e) { System.debug('GiftDesignation delete skipped: ' + e.getMessage()); }
    }
}

// 17. Campaigns — hierarchy: leaves before roots. Two-pass by ParentId != null / null.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Campaign> children = Database.query('SELECT Id FROM Campaign WHERE ParentId != null LIMIT ' + slot);
    if (!children.isEmpty()) { delete children; counts.put('Campaign (children)', children.size()); totalDeleted += children.size(); }
}
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Campaign> roots = Database.query('SELECT Id FROM Campaign WHERE ParentId = null LIMIT ' + slot);
    if (!roots.isEmpty()) { delete roots; counts.put('Campaign (roots)', roots.size()); totalDeleted += roots.size(); }
}

// 18. PartyRoleRelation — Spouse-Spouse-CCR stubs.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<PartyRoleRelation> prrs = Database.query('SELECT Id FROM PartyRoleRelation WHERE RoleName = \'Spouse\' AND RelatedRoleName = \'Spouse\' AND RelationshipObjectName = \'Contact_Contact_Relationship\' LIMIT ' + slot);
    if (!prrs.isEmpty()) {
        try { delete prrs; counts.put('PartyRoleRelation', prrs.size()); totalDeleted += prrs.size(); }
        catch (Exception e) { System.debug('PartyRoleRelation delete skipped: ' + e.getMessage()); }
    }
}

System.debug('=== Purge pass complete: ' + totalDeleted + ' records deleted ===');
for (String obj : counts.keySet()) {
    System.debug('  ' + obj + ': ' + counts.get(obj));
}
if (totalDeleted >= DML_BUDGET) {
    System.debug('NOTE: hit DML budget — re-run purge to continue.');
}
