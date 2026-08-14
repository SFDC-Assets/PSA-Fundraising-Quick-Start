// FQS Test 8: end-to-end validation of FQS_Campaign_Member_Status_On_Commitment_Delete.
//
// Donor: Nathan White FQS #0 (001WB000017gb56YAA, Contact 003WB00000vG0EYYA0)
// Campaign: FQS Spring Appeal Email FY26 (701WB000017gThEYAU, baseline / non-Events, depth 3, checkbox TRUE)
// Pre-state: no existing GT, GC, or CampaignMember for this donor on this campaign.
//
// Steps:
//   1. INSERT a fresh Active GC → On_Commitment flow should CREATE a CampaignMember at Pledged/Gave.
//   2. DELETE the GC → On_Commitment_Delete flow should DOWNGRADE that CampaignMember to Solicited.
// Records inserted for the test are captured and deleted / verified via SOQL.

Id donorId = '001WB000017gb56YAA';
Id contactId = '003WB00000vG0EYYA0';
Id campaignId = '701WB000017gThEYAU';

//---------------------------------------------------------------
// Step 1: Insert Active GC
//---------------------------------------------------------------
GiftCommitment testGc = new GiftCommitment(
    Name = 'FQS Test Delete Flow',
    DonorId = donorId,
    CampaignId = campaignId,
    Status = 'Active'
);
insert testGc;
System.debug('Step 1: Inserted GC ' + testGc.Id);

// Verify CampaignMember got upgraded
List<CampaignMember> afterInsert = [
    SELECT Id, Status
    FROM CampaignMember
    WHERE ContactId = :contactId AND CampaignId = :campaignId
];
System.debug('Step 1 result: CampaignMember rows = ' + afterInsert.size());
if (!afterInsert.isEmpty()) {
    System.debug('Step 1 result: Status = ' + afterInsert[0].Status);
}
Id cmId = afterInsert.isEmpty() ? null : afterInsert[0].Id;

//---------------------------------------------------------------
// Step 2: Delete the GC
//---------------------------------------------------------------
delete testGc;
System.debug('Step 2: Deleted GC ' + testGc.Id);

// Verify CampaignMember got downgraded
List<CampaignMember> afterDelete = [
    SELECT Id, Status, LastModifiedDate
    FROM CampaignMember
    WHERE ContactId = :contactId AND CampaignId = :campaignId
];
System.debug('Step 2 result: CampaignMember rows = ' + afterDelete.size());
if (!afterDelete.isEmpty()) {
    System.debug('Step 2 result: Status = ' + afterDelete[0].Status + '  (expected: Solicited)');
    System.debug('Step 2 result: LastModifiedDate = ' + afterDelete[0].LastModifiedDate);
}

//---------------------------------------------------------------
// Cleanup: remove the CampaignMember we created so the campaign returns to no-member state
//---------------------------------------------------------------
if (cmId != null) {
    delete [SELECT Id FROM CampaignMember WHERE Id = :cmId];
    System.debug('Cleanup: deleted CampaignMember ' + cmId);
}
