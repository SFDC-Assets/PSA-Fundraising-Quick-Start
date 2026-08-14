// FQS Test 9: guard holds on GC delete because donor has a Paid GT on the same campaign.
//
// Donor: Nathan White FQS #0 (same as Test 8 — clean state after Test 8 cleaned up)
// Campaign: FQS Spring Appeal Email FY26
//
// Steps:
//   1. INSERT a Paid GT → On_Gift upgrade fires, CampaignMember at Pledged/Gave.
//   2. INSERT an Active GC → also runs through On_Commitment upgrade, but CampaignMember already exists, no-op flip to Pledged/Gave.
//   3. DELETE the GC → On_Commitment_Delete fires. Guard finds the Paid GT (varPaidGTCount = 1), so downgrade is SKIPPED. CampaignMember stays Pledged/Gave.
// Cleanup: delete GT + CampaignMember at end.

Id donorId = '001WB000017gb56YAA';
Id contactId = '003WB00000vG0EYYA0';
Id campaignId = '701WB000017gThEYAU';

// Step 1: Insert Paid GT
GiftTransaction testGt = new GiftTransaction(
    DonorId = donorId,
    CampaignId = campaignId,
    Status = 'Paid',
    OriginalAmount = 100,
    PaymentMethod = 'Check',
    TransactionDate = System.today()
);
insert testGt;
System.debug('Step 1: Inserted GT ' + testGt.Id);
CampaignMember cm1 = [SELECT Id, Status FROM CampaignMember WHERE ContactId = :contactId AND CampaignId = :campaignId LIMIT 1];
System.debug('Step 1 result: CampaignMember Status = ' + cm1.Status + '  (expected: Pledged/Gave)');

// Step 2: Insert Active GC
GiftCommitment testGc = new GiftCommitment(
    Name = 'FQS Test Guard',
    DonorId = donorId,
    CampaignId = campaignId,
    Status = 'Active'
);
insert testGc;
System.debug('Step 2: Inserted GC ' + testGc.Id);
CampaignMember cm2 = [SELECT Id, Status FROM CampaignMember WHERE Id = :cm1.Id];
System.debug('Step 2 result: CampaignMember Status = ' + cm2.Status + '  (expected: still Pledged/Gave)');

// Step 3: Delete the GC — guard should hold
delete testGc;
System.debug('Step 3: Deleted GC ' + testGc.Id);
CampaignMember cm3 = [SELECT Id, Status, LastModifiedDate FROM CampaignMember WHERE Id = :cm1.Id];
System.debug('Step 3 result: CampaignMember Status = ' + cm3.Status + '  (expected: Pledged/Gave — GUARD HELD)');

// Cleanup
delete testGt;
delete [SELECT Id FROM CampaignMember WHERE Id = :cm1.Id];
System.debug('Cleanup: deleted GT and CampaignMember.');
