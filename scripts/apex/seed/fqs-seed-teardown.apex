// FQS Seed Teardown — removes all FQS-seeded test data.
// Idempotent: safe to run multiple times. Only deletes records whose FQS_External_Id__c
// starts with 'FQS-', which is populated exclusively by the FQS seed scripts.
//
// Deletion order matters — leaf children first, roots last.

System.debug('=== FQS Seed Teardown starting ===');

Integer totalDeleted = 0;
Map<String, Integer> counts = new Map<String, Integer>();

// 1. GiftRefund
List<GiftRefund> refunds = [
    SELECT Id FROM GiftRefund
    WHERE FQS_External_Id__c LIKE 'FQS-GR-%'
    LIMIT 50000
];
if (!refunds.isEmpty()) { delete refunds; counts.put('GiftRefund', refunds.size()); totalDeleted += refunds.size(); }

// 2. GiftTransactionDesignation
List<GiftTransactionDesignation> gtds = [
    SELECT Id FROM GiftTransactionDesignation
    WHERE FQS_External_Id__c LIKE 'FQS-GTD-%'
    LIMIT 50000
];
if (!gtds.isEmpty()) { delete gtds; counts.put('GiftTransactionDesignation', gtds.size()); totalDeleted += gtds.size(); }

// 3. GiftSoftCredit
List<GiftSoftCredit> softCredits = [
    SELECT Id FROM GiftSoftCredit
    WHERE FQS_External_Id__c LIKE 'FQS-GSC-%'
    LIMIT 50000
];
if (!softCredits.isEmpty()) { delete softCredits; counts.put('GiftSoftCredit', softCredits.size()); totalDeleted += softCredits.size(); }

// 4. GiftTribute
List<GiftTribute> tributes = [
    SELECT Id FROM GiftTribute
    WHERE FQS_External_Id__c LIKE 'FQS-GTR-%'
    LIMIT 50000
];
if (!tributes.isEmpty()) { delete tributes; counts.put('GiftTribute', tributes.size()); totalDeleted += tributes.size(); }

// 5. GiftTransaction — catches donor GTs (FQS-GT-<idx>-<g>) AND corp matches (FQS-GT-CORP-<idx>).
// Corp matches carry MatchingEmployerTransactionId → employee GT; delete order within this
// object doesn't matter as long as the whole set goes at once.
List<GiftTransaction> gts = [
    SELECT Id FROM GiftTransaction
    WHERE FQS_External_Id__c LIKE 'FQS-GT-%'
    LIMIT 50000
];
if (!gts.isEmpty()) { delete gts; counts.put('GiftTransaction', gts.size()); totalDeleted += gts.size(); }

// 6. GiftCommitmentSchedule
List<GiftCommitmentSchedule> schedules = [
    SELECT Id FROM GiftCommitmentSchedule
    WHERE FQS_External_Id__c LIKE 'FQS-GCS-%'
    LIMIT 50000
];
if (!schedules.isEmpty()) { delete schedules; counts.put('GiftCommitmentSchedule', schedules.size()); totalDeleted += schedules.size(); }

// 7. GiftCommitment
List<GiftCommitment> gcs = [
    SELECT Id FROM GiftCommitment
    WHERE FQS_External_Id__c LIKE 'FQS-GC-%'
    LIMIT 50000
];
if (!gcs.isEmpty()) { delete gcs; counts.put('GiftCommitment', gcs.size()); totalDeleted += gcs.size(); }

// 8. Opportunity
List<Opportunity> opps = [
    SELECT Id FROM Opportunity
    WHERE FQS_External_Id__c LIKE 'FQS-OPP-%'
    LIMIT 50000
];
if (!opps.isEmpty()) { delete opps; counts.put('Opportunity', opps.size()); totalDeleted += opps.size(); }

// 9. PaymentInstrument
List<PaymentInstrument> pis = [
    SELECT Id FROM PaymentInstrument
    WHERE FQS_External_Id__c LIKE 'FQS-PI-%'
    LIMIT 50000
];
if (!pis.isEmpty()) { delete pis; counts.put('PaymentInstrument', pis.size()); totalDeleted += pis.size(); }

// 10. DonorGiftSummary — MD child of Account. No FQS_External_Id__c on this object;
// filter via the Donor lookup which does carry the marker.
List<DonorGiftSummary> dgss = [
    SELECT Id FROM DonorGiftSummary
    WHERE Donor.FQS_External_Id__c LIKE 'FQS-ACC-%'
    LIMIT 50000
];
if (!dgss.isEmpty()) {
    try { delete dgss; counts.put('DonorGiftSummary', dgss.size()); totalDeleted += dgss.size(); }
    catch (Exception e) { System.debug('DonorGiftSummary delete skipped: ' + e.getMessage()); }
}

// 11. Account — catches donors (FQS-ACC-<idx>) AND corporate employers (FQS-ACC-CORP-<idx>).
List<Account> donors = [
    SELECT Id FROM Account
    WHERE FQS_External_Id__c LIKE 'FQS-ACC-%'
    LIMIT 50000
];
if (!donors.isEmpty()) { delete donors; counts.put('Account', donors.size()); totalDeleted += donors.size(); }

// 12. OutreachSourceCode
List<OutreachSourceCode> oscs = [
    SELECT Id FROM OutreachSourceCode
    WHERE FQS_External_Id__c LIKE 'FQS-OSC-%'
    LIMIT 50000
];
if (!oscs.isEmpty()) { delete oscs; counts.put('OutreachSourceCode', oscs.size()); totalDeleted += oscs.size(); }

// 13. GiftDesignation — must be deactivated before delete.
List<GiftDesignation> gds = [
    SELECT Id, IsActive FROM GiftDesignation
    WHERE FQS_External_Id__c LIKE 'FQS-GD-%'
    LIMIT 50000
];
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

// 14. Campaigns — ParentId FK means leaves must go before categories before Master.
// Pass A: everything with a ParentId (leaves + categories). Deleting leaves before
// categories inside a single DML batch is not required — Salesforce processes them
// as a set, and the FK is satisfied as long as the parent is also being deleted or
// still exists. To be safe against edge cases, do leaves + categories together first,
// then Master.
List<Campaign> childCamps = [
    SELECT Id FROM Campaign
    WHERE FQS_External_Id__c LIKE 'FQS-CMP-%' AND ParentId != null
    LIMIT 50000
];
if (!childCamps.isEmpty()) { delete childCamps; counts.put('Campaign (leaves+categories)', childCamps.size()); totalDeleted += childCamps.size(); }

List<Campaign> masterCamps = [
    SELECT Id FROM Campaign
    WHERE FQS_External_Id__c = 'FQS-CMP-MASTER'
    LIMIT 50000
];
if (!masterCamps.isEmpty()) { delete masterCamps; counts.put('Campaign (master)', masterCamps.size()); totalDeleted += masterCamps.size(); }

System.debug('=== Teardown complete: ' + totalDeleted + ' records deleted ===');
for (String obj : counts.keySet()) {
    System.debug('  ' + obj + ': ' + counts.get(obj));
}
