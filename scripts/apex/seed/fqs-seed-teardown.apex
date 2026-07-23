// FQS Seed Teardown — removes all FQS-seeded test data.
// Idempotent and re-runnable: safe to invoke as many times as needed. Each run
// consumes at most ~9,000 DML rows to stay under the 10K per-transaction cap;
// datasets larger than that are cleaned across multiple invocations.
//
// Deletion order matters — leaf children first, roots last.

System.debug('=== FQS Seed Teardown starting ===');

Integer DML_BUDGET = 9000;
Integer totalDeleted = 0;
Map<String, Integer> counts = new Map<String, Integer>();

// Each block queries LIMIT min(DML_BUDGET - spent, 5000). If nothing remains in the
// budget, the block short-circuits and the next teardown run picks up where this
// one left off.
Integer slot;

// 0a. ContactContactRelation — cross-household spouse links; before Contacts/Accounts.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<ContactContactRelation> ccrs = Database.query(
        'SELECT Id FROM ContactContactRelation WHERE Contact.Account.External_Id__c LIKE \'FQS-ACC-%\' OR RelatedContact.Account.External_Id__c LIKE \'FQS-ACC-%\' LIMIT ' + slot);
    if (!ccrs.isEmpty()) { delete ccrs; counts.put('ContactContactRelation', ccrs.size()); totalDeleted += ccrs.size(); }
}

// 0b. CampaignMember — before Campaigns/Contacts.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<CampaignMember> cms = Database.query(
        'SELECT Id FROM CampaignMember WHERE Campaign.External_Id__c LIKE \'FQS-CMP-%\' OR Contact.Account.External_Id__c LIKE \'FQS-ACC-%\' LIMIT ' + slot);
    if (!cms.isEmpty()) { delete cms; counts.put('CampaignMember', cms.size()); totalDeleted += cms.size(); }
}

// 0c. GiftDefaultDesignation — MD child of GiftCommitment; can be deleted independently.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftDefaultDesignation> gdds = Database.query(
        'SELECT Id FROM GiftDefaultDesignation WHERE ParentRecordId IN (SELECT Id FROM GiftCommitment WHERE External_Id__c LIKE \'FQS-GC-%\') LIMIT ' + slot);
    if (!gdds.isEmpty()) { delete gdds; counts.put('GiftDefaultDesignation', gdds.size()); totalDeleted += gdds.size(); }
}

// 0d. AccountContactRelation — must go before Accounts.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<AccountContactRelation> acrs = Database.query(
        'SELECT Id FROM AccountContactRelation WHERE Account.External_Id__c LIKE \'FQS-ACC-CORP-%\' OR Account.External_Id__c LIKE \'FQS-ACC-INT-%\' LIMIT ' + slot);
    if (!acrs.isEmpty()) { delete acrs; counts.put('AccountContactRelation', acrs.size()); totalDeleted += acrs.size(); }
}

// 1. GiftRefund
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftRefund> refunds = Database.query('SELECT Id FROM GiftRefund WHERE External_Id__c LIKE \'FQS-GR-%\' LIMIT ' + slot);
    if (!refunds.isEmpty()) { delete refunds; counts.put('GiftRefund', refunds.size()); totalDeleted += refunds.size(); }
}

// 2. GiftTransactionDesignation
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftTransactionDesignation> gtds = Database.query('SELECT Id FROM GiftTransactionDesignation WHERE External_Id__c LIKE \'FQS-GTD-%\' LIMIT ' + slot);
    if (!gtds.isEmpty()) { delete gtds; counts.put('GiftTransactionDesignation', gtds.size()); totalDeleted += gtds.size(); }
}

// 3. GiftSoftCredit
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftSoftCredit> softCredits = Database.query('SELECT Id FROM GiftSoftCredit WHERE External_Id__c LIKE \'FQS-GSC-%\' LIMIT ' + slot);
    if (!softCredits.isEmpty()) { delete softCredits; counts.put('GiftSoftCredit', softCredits.size()); totalDeleted += softCredits.size(); }
}

// 4. GiftTribute
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftTribute> tributes = Database.query('SELECT Id FROM GiftTribute WHERE External_Id__c LIKE \'FQS-GTR-%\' LIMIT ' + slot);
    if (!tributes.isEmpty()) { delete tributes; counts.put('GiftTribute', tributes.size()); totalDeleted += tributes.size(); }
}

// 5. GiftTransaction — catches donor GTs (FQS-GT-<idx>-<g>) AND corp matches (FQS-GT-CORP-<idx>).
// Also picks up historical GTs whose External_Id__c was never stamped but whose
// DonorId points at an FQS-tagged Account. Without this, orphaned GTs block Account
// delete a few steps down.
// GTs get PRIORITY — we take up to the full remaining budget to avoid leaving orphans
// that would block Commitment deletion in step 7.
slot = DML_BUDGET - totalDeleted;
Boolean gtQueueRemaining = false;
if (slot > 0) {
    List<GiftTransaction> gts = Database.query('SELECT Id FROM GiftTransaction WHERE External_Id__c LIKE \'FQS-GT-%\' OR Donor.External_Id__c LIKE \'FQS-ACC-%\' OR Name LIKE \'FQS %\' OR Donor.Name LIKE \'%FQS #%\' LIMIT ' + slot);
    if (!gts.isEmpty()) { delete gts; counts.put('GiftTransaction', gts.size()); totalDeleted += gts.size(); }
    gtQueueRemaining = (gts.size() == slot);   // may be more; skip commitments this pass
}

// 6. GiftCommitmentSchedule (skip if GTs may still exist — they'd cascade-block)
slot = gtQueueRemaining ? 0 : Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftCommitmentSchedule> schedules = Database.query('SELECT Id FROM GiftCommitmentSchedule WHERE External_Id__c LIKE \'FQS-GCS-%\' OR GiftCommitment.Name LIKE \'FQS %\' OR GiftCommitment.Donor.Name LIKE \'%FQS #%\' LIMIT ' + slot);
    if (!schedules.isEmpty()) { delete schedules; counts.put('GiftCommitmentSchedule', schedules.size()); totalDeleted += schedules.size(); }
}

// 7. GiftCommitment (skip if GTs still remaining — they'd block delete)
// Sweeps ext-ID + legacy name patterns to catch pre-External_Id__c seed leftovers.
slot = gtQueueRemaining ? 0 : Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftCommitment> gcs = Database.query('SELECT Id FROM GiftCommitment WHERE External_Id__c LIKE \'FQS-GC-%\' OR Donor.External_Id__c LIKE \'FQS-ACC-%\' OR Name LIKE \'FQS %\' OR Donor.Name LIKE \'%FQS #%\' LIMIT ' + slot);
    if (!gcs.isEmpty()) { delete gcs; counts.put('GiftCommitment', gcs.size()); totalDeleted += gcs.size(); }
}

// 8. Opportunity
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Opportunity> opps = Database.query('SELECT Id FROM Opportunity WHERE External_Id__c LIKE \'FQS-OPP-%\' OR Name LIKE \'FQS %\' OR Account.Name LIKE \'%FQS #%\' LIMIT ' + slot);
    if (!opps.isEmpty()) { delete opps; counts.put('Opportunity', opps.size()); totalDeleted += opps.size(); }
}

// 9. PaymentInstrument
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<PaymentInstrument> pis = Database.query('SELECT Id FROM PaymentInstrument WHERE External_Id__c LIKE \'FQS-PI-%\' OR Account.Name LIKE \'%FQS #%\' LIMIT ' + slot);
    if (!pis.isEmpty()) { delete pis; counts.put('PaymentInstrument', pis.size()); totalDeleted += pis.size(); }
}

// 10. DonorGiftSummary — MD child of Account. No External_Id__c; filter via Donor.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<DonorGiftSummary> dgss = Database.query('SELECT Id FROM DonorGiftSummary WHERE Donor.External_Id__c LIKE \'FQS-ACC-%\' LIMIT ' + slot);
    if (!dgss.isEmpty()) {
        try { delete dgss; counts.put('DonorGiftSummary', dgss.size()); totalDeleted += dgss.size(); }
        catch (Exception e) { System.debug('DonorGiftSummary delete skipped: ' + e.getMessage()); }
    }
}

// 11. Account — catches donors + corporate employers + intermediaries.
// Sweeps BOTH External_Id__c pattern AND legacy name patterns, since prior seed
// runs (pre-External_Id__c convention) left FQS-named accounts with null ext IDs.
// Without this, the Standard Account duplicate rule flags corp employer upserts
// in foundation against these orphans.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Account> donors = Database.query('SELECT Id FROM Account WHERE External_Id__c LIKE \'FQS-ACC-%\' OR Name LIKE \'%FQS-CORP%\' OR Name LIKE \'%FQS-INT%\' OR Name LIKE \'%FQS #%\' LIMIT ' + slot);
    if (!donors.isEmpty()) { delete donors; counts.put('Account', donors.size()); totalDeleted += donors.size(); }
}

// 12. OutreachSourceCode
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<OutreachSourceCode> oscs = Database.query('SELECT Id FROM OutreachSourceCode WHERE External_Id__c LIKE \'FQS-OSC-%\' LIMIT ' + slot);
    if (!oscs.isEmpty()) { delete oscs; counts.put('OutreachSourceCode', oscs.size()); totalDeleted += oscs.size(); }
}

// 13. GiftDesignation — must be deactivated before delete.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<GiftDesignation> gds = Database.query('SELECT Id, IsActive FROM GiftDesignation WHERE External_Id__c LIKE \'FQS-GD-%\' LIMIT ' + slot);
    if (!gds.isEmpty()) {
        List<GiftDesignation> toDeactivate = new List<GiftDesignation>();
        for (GiftDesignation gd : gds) {
            if (gd.IsActive) { gd.IsActive = false; toDeactivate.add(gd); }
        }
        if (!toDeactivate.isEmpty()) update toDeactivate;
        delete gds;
        counts.put('GiftDesignation', gds.size());
        totalDeleted += gds.size();
    }
}

// 14. Campaigns — ParentId FK means asks first, then strategies, then rollups.
// Also sweeps the older Master/Categories/Leaves taxonomy so a mid-migration org can be
// cleared without leftover records. Order: ASKS, then STRATEGIES, then LEGACY CAT/LEAF,
// then ROLLUPS, then LEGACY MASTER. The "ParentId != null" heuristic handles legacy rows.
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Campaign> asks = Database.query('SELECT Id FROM Campaign WHERE External_Id__c LIKE \'FQS-CMP-ASK-%\' LIMIT ' + slot);
    if (!asks.isEmpty()) { delete asks; counts.put('Campaign (asks)', asks.size()); totalDeleted += asks.size(); }
}
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Campaign> strats = Database.query('SELECT Id FROM Campaign WHERE External_Id__c LIKE \'FQS-CMP-STRAT-%\' LIMIT ' + slot);
    if (!strats.isEmpty()) { delete strats; counts.put('Campaign (strategies)', strats.size()); totalDeleted += strats.size(); }
}
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    // Legacy taxonomy: CAT + old leaves. Anything with a ParentId that isn't ROLLUP/STRAT/ASK.
    List<Campaign> legacyChildren = Database.query('SELECT Id FROM Campaign WHERE External_Id__c LIKE \'FQS-CMP-%\' AND ParentId != null AND (NOT External_Id__c LIKE \'FQS-CMP-ROLLUP-%\') LIMIT ' + slot);
    if (!legacyChildren.isEmpty()) { delete legacyChildren; counts.put('Campaign (legacy cat+leaf)', legacyChildren.size()); totalDeleted += legacyChildren.size(); }
}
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Campaign> rollups = Database.query('SELECT Id FROM Campaign WHERE External_Id__c LIKE \'FQS-CMP-ROLLUP-%\' LIMIT ' + slot);
    if (!rollups.isEmpty()) { delete rollups; counts.put('Campaign (rollups)', rollups.size()); totalDeleted += rollups.size(); }
}
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<Campaign> masterCamps = Database.query('SELECT Id FROM Campaign WHERE External_Id__c = \'FQS-CMP-MASTER\' LIMIT ' + slot);
    if (!masterCamps.isEmpty()) { delete masterCamps; counts.put('Campaign (legacy master)', masterCamps.size()); totalDeleted += masterCamps.size(); }
}

// 15. PartyRoleRelation — FQS-owned Spouse-Spouse-CCR stub. Delete after CCRs (step 0a).
slot = Math.min(5000, DML_BUDGET - totalDeleted);
if (slot > 0) {
    List<PartyRoleRelation> prrs = Database.query('SELECT Id FROM PartyRoleRelation WHERE RoleName = \'Spouse\' AND RelatedRoleName = \'Spouse\' AND RelationshipObjectName = \'Contact_Contact_Relationship\' LIMIT ' + slot);
    if (!prrs.isEmpty()) {
        try { delete prrs; counts.put('PartyRoleRelation', prrs.size()); totalDeleted += prrs.size(); }
        catch (Exception e) { System.debug('PartyRoleRelation delete skipped: ' + e.getMessage()); }
    }
}

// 16. Empty Recycle Bin — hard-delete FQS-tagged records that just landed in the
// bin, plus any leftover archived rows still holding External_Id__c unique-index
// slots. Without this, soft-deleted records survive the 15-day window as archived
// rows, forcing every future reseed to salt with RUN_STAMP to avoid dupe errors.
// Only runs when we still have DML budget left this pass.
Map<String, Integer> purgeCounts = new Map<String, Integer>();
Integer PURGE_BATCH = 500;
Integer purged = 0;
List<String> purgeObjects = new List<String>{
    'GiftRefund', 'GiftTransactionDesignation', 'GiftSoftCredit', 'GiftTribute',
    'GiftTransaction', 'GiftCommitmentSchedule', 'GiftCommitment',
    'Opportunity', 'PaymentInstrument', 'Account', 'OutreachSourceCode',
    'GiftDesignation', 'Campaign'
};
for (String obj : purgeObjects) {
    Integer remaining = DML_BUDGET - totalDeleted - purged;
    if (remaining <= 0) break;
    Integer batch = Math.min(PURGE_BATCH, remaining);
    try {
        List<SObject> archived = Database.query(
            'SELECT Id FROM ' + obj + ' WHERE IsDeleted = true AND External_Id__c LIKE \'FQS-%\' LIMIT ' + batch + ' ALL ROWS');
        if (archived.isEmpty()) continue;
        Database.EmptyRecycleBinResult[] results = Database.emptyRecycleBin(archived);
        Integer okCount = 0;
        for (Database.EmptyRecycleBinResult r : results) if (r.isSuccess()) okCount++;
        if (okCount > 0) {
            purgeCounts.put(obj, okCount);
            purged += okCount;
        }
    } catch (Exception e) {
        System.debug('  Recycle bin purge skipped for ' + obj + ': ' + e.getMessage());
    }
}

System.debug('=== Teardown pass complete: ' + totalDeleted + ' records deleted, ' + purged + ' purged from recycle bin ===');
for (String obj : counts.keySet()) {
    System.debug('  deleted ' + obj + ': ' + counts.get(obj));
}
for (String obj : purgeCounts.keySet()) {
    System.debug('  purged  ' + obj + ': ' + purgeCounts.get(obj));
}
if (totalDeleted >= DML_BUDGET) {
    System.debug('NOTE: hit DML budget — re-run teardown to continue (recycle-bin purge will run on the final pass when deletes drain).');
}
