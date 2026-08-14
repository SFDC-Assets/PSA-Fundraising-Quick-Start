// FQS backfill: adds the "Pledged/Gave" CampaignMemberStatus rung (SortOrder=5, HasResponded=true)
// to every existing Event-category Campaign at Hierarchy Depth >= 3 that doesn't already have it.
//
// Idempotent: safe to run multiple times. Skips any campaign already carrying a Pledged/Gave rung.
// Bulk-safe: single SOQL for existing rungs, single insert of new rungs, no per-campaign DML.
//
// Runs in the current user's context — requires Create on CampaignMemberStatus.
// Expected companion of FQS_Campaign_Member_Status_Ladder.flow after the SortOrder=5 rung was added there.
// New Event campaigns get the rung automatically from that flow; this script only patches the historical set.

Set<Id> eventCampaignIds = new Set<Id>();
for (Campaign c : [
    SELECT Id
    FROM Campaign
    WHERE FQS_Campaign_Category__c = 'Events'
      AND FQS_Hierarchy_Depth__c >= 3
]) {
    eventCampaignIds.add(c.Id);
}
System.debug('Event campaigns at depth >= 3: ' + eventCampaignIds.size());

Set<Id> alreadyHavePledgedGave = new Set<Id>();
for (CampaignMemberStatus s : [
    SELECT CampaignId
    FROM CampaignMemberStatus
    WHERE CampaignId IN :eventCampaignIds
      AND Label = 'Pledged/Gave'
]) {
    alreadyHavePledgedGave.add(s.CampaignId);
}
System.debug('Event campaigns already carrying Pledged/Gave: ' + alreadyHavePledgedGave.size());

List<CampaignMemberStatus> toInsert = new List<CampaignMemberStatus>();
for (Id campaignId : eventCampaignIds) {
    if (alreadyHavePledgedGave.contains(campaignId)) {
        continue;
    }
    toInsert.add(new CampaignMemberStatus(
        CampaignId = campaignId,
        Label = 'Pledged/Gave',
        SortOrder = 5,
        HasResponded = true,
        IsDefault = false
    ));
}

System.debug('New Pledged/Gave rungs to insert: ' + toInsert.size());

if (!toInsert.isEmpty()) {
    insert toInsert;
    System.debug('Backfill complete. Inserted ' + toInsert.size() + ' CampaignMemberStatus records.');
} else {
    System.debug('Nothing to backfill — every event campaign already carries the Pledged/Gave rung.');
}
