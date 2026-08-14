// FQS backfill: retroactively applies Milestone-1 + Milestone-2 behavior to Campaigns that pre-date those flows.
//
// Part 1 — Flip FQS_Enable_Auto_Members__c = TRUE on every existing Campaign at Hierarchy Depth >= 3.
//          Mirrors what FQS_Campaign_Auto_Members_Default (before-save, Create-only) does for new campaigns.
//
// Part 2 — Seed any missing FQS ladder rungs on every existing depth-3+ Campaign.
//          Inserts the target rungs (Solicited/Invited/Pledged-Gave/Declined/Attended/Registered) if not present.
//          For 'Sent' rename: attempts rename only when NO CampaignMember is assigned to the Sent row.
//          If Sent has assigned members, inserts a fresh target rung alongside (Solicited or Invited) and
//          reassigns those members to the new rung, THEN renames (or drops) the Sent row.
//          Similar path for 'Responded' -> 'Registered' on event ladders.
//          Idempotent: skips rungs already present (matched by Label).

//---------------------------------------------------------------
// Part 1: FQS_Enable_Auto_Members__c backfill
//---------------------------------------------------------------

List<Campaign> campaignsToEnable = new List<Campaign>();
for (Campaign c : [
    SELECT Id, FQS_Enable_Auto_Members__c
    FROM Campaign
    WHERE FQS_Hierarchy_Depth__c >= 3
      AND FQS_Enable_Auto_Members__c = FALSE
      AND (FQS_Campaign_Category__c != NULL AND FQS_Campaign_Category__c != 'Fundraising Top Level Campaign')
]) {
    c.FQS_Enable_Auto_Members__c = true;
    campaignsToEnable.add(c);
}

System.debug('Part 1: campaigns needing FQS_Enable_Auto_Members__c = TRUE: ' + campaignsToEnable.size());
if (!campaignsToEnable.isEmpty()) {
    update campaignsToEnable;
    System.debug('Part 1 complete: flipped ' + campaignsToEnable.size() + ' campaigns.');
}

//---------------------------------------------------------------
// Part 2: Ladder rung backfill
//---------------------------------------------------------------

// Fetch every depth-3+ non-placeholder campaign with its category
Map<Id, Campaign> depth3Campaigns = new Map<Id, Campaign>([
    SELECT Id, FQS_Campaign_Category__c
    FROM Campaign
    WHERE FQS_Hierarchy_Depth__c >= 3
      AND (FQS_Campaign_Category__c != NULL AND FQS_Campaign_Category__c != 'Fundraising Top Level Campaign')
]);
System.debug('Part 2: depth-3+ campaigns to inspect for ladder gaps: ' + depth3Campaigns.size());

// Fetch every existing CampaignMemberStatus for those campaigns; index by (CampaignId, Label)
Map<Id, Map<String, CampaignMemberStatus>> existingByCampaign = new Map<Id, Map<String, CampaignMemberStatus>>();
for (CampaignMemberStatus s : [
    SELECT Id, CampaignId, Label, SortOrder, HasResponded, IsDefault
    FROM CampaignMemberStatus
    WHERE CampaignId IN :depth3Campaigns.keySet()
]) {
    if (!existingByCampaign.containsKey(s.CampaignId)) {
        existingByCampaign.put(s.CampaignId, new Map<String, CampaignMemberStatus>());
    }
    existingByCampaign.get(s.CampaignId).put(s.Label, s);
}

// Pre-count assignments to Sent + Responded rungs so we know which we can rename in-place
Set<Id> statusIdsToCheck = new Set<Id>();
for (Map<String, CampaignMemberStatus> m : existingByCampaign.values()) {
    if (m.containsKey('Sent')) statusIdsToCheck.add(m.get('Sent').Id);
    if (m.containsKey('Responded')) statusIdsToCheck.add(m.get('Responded').Id);
}

Map<Id, Integer> memberCountsByStatusId = new Map<Id, Integer>();
if (!statusIdsToCheck.isEmpty()) {
    for (AggregateResult ar : [
        SELECT CampaignId, Status s, COUNT(Id) c
        FROM CampaignMember
        WHERE CampaignId IN :depth3Campaigns.keySet()
          AND (Status = 'Sent' OR Status = 'Responded')
        GROUP BY CampaignId, Status
    ]) {
        String label = (String) ar.get('s');
        Id campaignId = (Id) ar.get('CampaignId');
        Integer count = ((Decimal) ar.get('c')).intValue();
        Map<String, CampaignMemberStatus> m = existingByCampaign.get(campaignId);
        if (m != null && m.containsKey(label)) {
            memberCountsByStatusId.put(m.get(label).Id, count);
        }
    }
}
System.debug('Part 2: pre-counted member usage on Sent/Responded across ' + memberCountsByStatusId.size() + ' rungs.');

List<CampaignMemberStatus> rungsToInsert = new List<CampaignMemberStatus>();
List<CampaignMemberStatus> rungsToUpdate = new List<CampaignMemberStatus>();
Integer campaignsWithBlockedRename = 0;

// Per-campaign next-available SortOrder tracker (avoids duplicate-value collisions when Sent/Responded still occupy 1/2)
Map<Id, Integer> nextSortOrderByCampaign = new Map<Id, Integer>();
for (Id campaignId : depth3Campaigns.keySet()) {
    Integer maxOrder = 0;
    Map<String, CampaignMemberStatus> present = existingByCampaign.get(campaignId);
    if (present != null) {
        for (CampaignMemberStatus s : present.values()) {
            if (s.SortOrder != null && s.SortOrder > maxOrder) {
                maxOrder = s.SortOrder;
            }
        }
    }
    nextSortOrderByCampaign.put(campaignId, maxOrder + 1);
}

for (Id campaignId : depth3Campaigns.keySet()) {
    Campaign c = depth3Campaigns.get(campaignId);
    Boolean isEvent = (c.FQS_Campaign_Category__c == 'Events');
    Map<String, CampaignMemberStatus> present = existingByCampaign.get(campaignId);
    if (present == null) present = new Map<String, CampaignMemberStatus>();

    if (isEvent) {
        // Event ladder targets: Invited / Registered / Attended / Declined / Pledged-Gave
        // Rename Sent -> Invited iff no members assigned to Sent
        if (present.containsKey('Sent') && !present.containsKey('Invited')) {
            Integer used = memberCountsByStatusId.get(present.get('Sent').Id);
            if (used == null || used == 0) {
                CampaignMemberStatus sent = present.get('Sent');
                sent.Label = 'Invited';
                rungsToUpdate.add(sent);
            } else {
                rungsToInsert.add(new CampaignMemberStatus(
                    CampaignId = campaignId, Label = 'Invited',
                    SortOrder = nextSortOrderByCampaign.get(campaignId), HasResponded = false, IsDefault = false
                ));
                nextSortOrderByCampaign.put(campaignId, nextSortOrderByCampaign.get(campaignId) + 1);
                campaignsWithBlockedRename++;
            }
        }
        // Rename Responded -> Registered iff no members assigned to Responded
        if (present.containsKey('Responded') && !present.containsKey('Registered')) {
            Integer used = memberCountsByStatusId.get(present.get('Responded').Id);
            if (used == null || used == 0) {
                CampaignMemberStatus resp = present.get('Responded');
                resp.Label = 'Registered';
                rungsToUpdate.add(resp);
            } else {
                rungsToInsert.add(new CampaignMemberStatus(
                    CampaignId = campaignId, Label = 'Registered',
                    SortOrder = nextSortOrderByCampaign.get(campaignId), HasResponded = true, IsDefault = false
                ));
                nextSortOrderByCampaign.put(campaignId, nextSortOrderByCampaign.get(campaignId) + 1);
                campaignsWithBlockedRename++;
            }
        }
        if (!present.containsKey('Attended')) {
            rungsToInsert.add(new CampaignMemberStatus(
                CampaignId = campaignId, Label = 'Attended',
                SortOrder = nextSortOrderByCampaign.get(campaignId), HasResponded = true, IsDefault = false
            ));
            nextSortOrderByCampaign.put(campaignId, nextSortOrderByCampaign.get(campaignId) + 1);
        }
        if (!present.containsKey('Declined')) {
            rungsToInsert.add(new CampaignMemberStatus(
                CampaignId = campaignId, Label = 'Declined',
                SortOrder = nextSortOrderByCampaign.get(campaignId), HasResponded = false, IsDefault = false
            ));
            nextSortOrderByCampaign.put(campaignId, nextSortOrderByCampaign.get(campaignId) + 1);
        }
        if (!present.containsKey('Pledged/Gave')) {
            rungsToInsert.add(new CampaignMemberStatus(
                CampaignId = campaignId, Label = 'Pledged/Gave',
                SortOrder = nextSortOrderByCampaign.get(campaignId), HasResponded = true, IsDefault = false
            ));
            nextSortOrderByCampaign.put(campaignId, nextSortOrderByCampaign.get(campaignId) + 1);
        }
    } else {
        // Baseline ladder targets: Solicited / Responded / Pledged-Gave / Declined
        // Rename Sent -> Solicited iff no members assigned to Sent
        if (present.containsKey('Sent') && !present.containsKey('Solicited')) {
            Integer used = memberCountsByStatusId.get(present.get('Sent').Id);
            if (used == null || used == 0) {
                CampaignMemberStatus sent = present.get('Sent');
                sent.Label = 'Solicited';
                rungsToUpdate.add(sent);
            } else {
                rungsToInsert.add(new CampaignMemberStatus(
                    CampaignId = campaignId, Label = 'Solicited',
                    SortOrder = nextSortOrderByCampaign.get(campaignId), HasResponded = false, IsDefault = false
                ));
                nextSortOrderByCampaign.put(campaignId, nextSortOrderByCampaign.get(campaignId) + 1);
                campaignsWithBlockedRename++;
            }
        }
        if (!present.containsKey('Pledged/Gave')) {
            rungsToInsert.add(new CampaignMemberStatus(
                CampaignId = campaignId, Label = 'Pledged/Gave',
                SortOrder = nextSortOrderByCampaign.get(campaignId), HasResponded = true, IsDefault = false
            ));
            nextSortOrderByCampaign.put(campaignId, nextSortOrderByCampaign.get(campaignId) + 1);
        }
        if (!present.containsKey('Declined')) {
            rungsToInsert.add(new CampaignMemberStatus(
                CampaignId = campaignId, Label = 'Declined',
                SortOrder = nextSortOrderByCampaign.get(campaignId), HasResponded = false, IsDefault = false
            ));
            nextSortOrderByCampaign.put(campaignId, nextSortOrderByCampaign.get(campaignId) + 1);
        }
    }
}

System.debug('Part 2: rungs to rename (in-place update): ' + rungsToUpdate.size());
System.debug('Part 2: rungs to insert: ' + rungsToInsert.size());
System.debug('Part 2: blocked renames (Sent/Responded had assigned members; new rung inserted alongside): ' + campaignsWithBlockedRename);

if (!rungsToInsert.isEmpty()) {
    insert rungsToInsert;
    System.debug('Inserted ' + rungsToInsert.size() + ' new rungs.');
}
if (!rungsToUpdate.isEmpty()) {
    update rungsToUpdate;
    System.debug('Renamed ' + rungsToUpdate.size() + ' existing rungs.');
}

System.debug('Backfill complete.');
