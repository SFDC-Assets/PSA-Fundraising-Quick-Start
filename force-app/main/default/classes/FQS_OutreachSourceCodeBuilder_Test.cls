@isTest
private class FQS_OutreachSourceCodeBuilder_Test {

    private static Id fqsRtId() {
        try {
            return [SELECT Id FROM RecordType WHERE SobjectType='Campaign' AND DeveloperName='FQS_Fundraising' LIMIT 1].Id;
        } catch (Exception e) {
            return null;
        }
    }

    private static Campaign makeTactical(String name, String shortName, String category, Boolean active) {
        // Insert as depth-1 first (top-level, no parent) then rehydrate — depth is a formula field.
        // For test purposes we DON'T need real depth-3; the service filters on FQS_Hierarchy_Depth__c >= 3
        // via the SELECT so we insert a tactical shape (with a two-level parent chain) to satisfy that.
        Id rt = fqsRtId();
        Campaign top = new Campaign(Name = 'TopTest ' + name, IsActive = true, StartDate = Date.newInstance(2026, 1, 1));
        if (rt != null) top.RecordTypeId = rt;
        insert top;
        Campaign strat = new Campaign(Name = 'StratTest ' + name, ParentId = top.Id, IsActive = true, StartDate = Date.newInstance(2026, 1, 1));
        if (rt != null) strat.RecordTypeId = rt;
        insert strat;
        Campaign tac = new Campaign(
            Name = name, ParentId = strat.Id,
            FQS_Short_Name__c = shortName,
            FQS_Campaign_Category__c = category,
            IsActive = active,
            StartDate = Date.newInstance(2026, 1, 1)
        );
        if (rt != null) tac.RecordTypeId = rt;
        insert tac;
        return tac;
    }

    @isTest
    static void test_MapsAnnualGivingToDirectMail() {
        Campaign tac = makeTactical('Monthly Sustainer Recruitment', 'SUSTAIN', 'Annual Giving', true);
        Test.startTest();
        Integer created = FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ tac.Id });
        Test.stopTest();

        System.assertEquals(1, created, 'One OSC inserted');
        OutreachSourceCode osc = [
            SELECT Name, SourceCode, Status, UsageType, MessageChannel, FQS_Platform__c,
                   FQS_Message_Channel_Segment__c, CampaignId, External_Id__c
            FROM OutreachSourceCode WHERE CampaignId = :tac.Id LIMIT 1
        ];
        System.assertEquals('Direct Mail', osc.MessageChannel);
        System.assertEquals('direct_mail_house', osc.FQS_Platform__c);
        System.assertEquals('Active', osc.Status);
        System.assertEquals('Fundraising', osc.UsageType);
        // FQS_Message_Channel_Segment__c is a formula derived from MessageChannel — service never writes it.
        System.assertEquals('Owned or Acquired Lists', osc.FQS_Message_Channel_Segment__c, 'Segment auto-derived from Direct Mail');
        System.assertEquals('SUSTAIN-26-DM', osc.SourceCode);
        System.assert(osc.External_Id__c.startsWith('FQS-OSC-'), 'ExtId prefix');
        System.assert(osc.External_Id__c.endsWith('-DEFAULT'), 'ExtId suffix');
        System.assert(osc.Name.endsWith('— Direct Mail'), 'Name channel suffix');
    }

    @isTest
    static void test_MapsEventsToEmailOtherEmail() {
        Campaign tac = makeTactical('Donor Appreciation Reception', 'RECEP', 'Events', true);
        Test.startTest();
        FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ tac.Id });
        Test.stopTest();

        OutreachSourceCode osc = [SELECT MessageChannel, FQS_Platform__c, SourceCode FROM OutreachSourceCode WHERE CampaignId = :tac.Id LIMIT 1];
        System.assertEquals('Email', osc.MessageChannel);
        System.assertEquals('other_email', osc.FQS_Platform__c);
        System.assertEquals('RECEP-26-EM', osc.SourceCode);
    }

    @isTest
    static void test_MapsMajorGiftsToPhysicalNoPlatform() {
        Campaign tac = makeTactical('Portfolio Solicitations', 'PORT', 'Major Gifts', true);
        Test.startTest();
        FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ tac.Id });
        Test.stopTest();

        OutreachSourceCode osc = [SELECT MessageChannel, FQS_Platform__c FROM OutreachSourceCode WHERE CampaignId = :tac.Id LIMIT 1];
        System.assertEquals('Physical', osc.MessageChannel);
        System.assertEquals(null, osc.FQS_Platform__c, 'No platform for Physical');
    }

    @isTest
    static void test_InactiveCampaignYieldsInactiveOSC() {
        Campaign tac = makeTactical('Legacy Circle Outreach', 'LEGACY', 'Planned Giving', false);
        Test.startTest();
        FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ tac.Id });
        Test.stopTest();

        OutreachSourceCode osc = [SELECT Status FROM OutreachSourceCode WHERE CampaignId = :tac.Id LIMIT 1];
        System.assertEquals('Inactive', osc.Status);
    }

    @isTest
    static void test_Idempotent_SecondCallInsertsZero() {
        Campaign tac = makeTactical('Peer-to-Peer Fundraising Drive', 'PEER', 'Annual Giving', true);
        Test.startTest();
        Integer first = FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ tac.Id });
        Integer second = FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ tac.Id });
        Test.stopTest();

        System.assertEquals(1, first);
        System.assertEquals(0, second, 'Second call must not insert dupes');
        Integer total = [SELECT COUNT() FROM OutreachSourceCode WHERE CampaignId = :tac.Id];
        System.assertEquals(1, total);
    }

    @isTest
    static void test_SkipsCampaignsBelowDepth3() {
        Id rt = fqsRtId();
        Campaign top = new Campaign(Name = 'Depth1Only', IsActive = true, StartDate = Date.today());
        if (rt != null) top.RecordTypeId = rt;
        insert top;

        Test.startTest();
        Integer created = FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ top.Id });
        Test.stopTest();

        System.assertEquals(0, created);
        System.assertEquals(0, [SELECT COUNT() FROM OutreachSourceCode WHERE CampaignId = :top.Id]);
    }

    @isTest
    static void test_MapsGrantsAndCorporateMatchAndInKindAndBlank() {
        Campaign g = makeTactical('Family Foundation Proposals', 'GRANT', 'Grants', true);
        Campaign cm = makeTactical('Corporate Match Push', 'CMATCH', 'Corporate Match', true);
        Campaign ik = makeTactical('Stock Donations', 'STOCK', 'In-Kind', true);
        Campaign blank = makeTactical('Uncategorized Tactic', 'UNCAT', null, true);
        Test.startTest();
        FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ g.Id, cm.Id, ik.Id, blank.Id });
        Test.stopTest();

        Map<Id, OutreachSourceCode> byCamp = new Map<Id, OutreachSourceCode>();
        for (OutreachSourceCode o : [SELECT CampaignId, MessageChannel, FQS_Platform__c FROM OutreachSourceCode WHERE CampaignId IN (:g.Id, :cm.Id, :ik.Id, :blank.Id)]) {
            byCamp.put(o.CampaignId, o);
        }
        System.assertEquals('Direct Mail', byCamp.get(g.Id).MessageChannel);
        System.assertEquals('direct_mail_house', byCamp.get(g.Id).FQS_Platform__c);
        System.assertEquals('Email', byCamp.get(cm.Id).MessageChannel);
        System.assertEquals('other_email', byCamp.get(cm.Id).FQS_Platform__c);
        System.assertEquals('Email', byCamp.get(ik.Id).MessageChannel);
        System.assertEquals('Email', byCamp.get(blank.Id).MessageChannel);
        System.assertEquals('other_email', byCamp.get(blank.Id).FQS_Platform__c);
    }

    @isTest
    static void test_SlugFallbackWhenNoShortName() {
        Id rt = fqsRtId();
        Campaign top = new Campaign(Name = 'TopA', IsActive = true, StartDate = Date.newInstance(2026, 1, 1));
        if (rt != null) top.RecordTypeId = rt;
        insert top;
        Campaign strat = new Campaign(Name = 'StratA', ParentId = top.Id, IsActive = true, StartDate = Date.newInstance(2026, 1, 1));
        if (rt != null) strat.RecordTypeId = rt;
        insert strat;
        Campaign tac = new Campaign(
            Name = 'Peer to Peer Drive', ParentId = strat.Id,
            FQS_Short_Name__c = null,
            FQS_Campaign_Category__c = 'Annual Giving',
            IsActive = true
            // StartDate deliberately null to hit the fallback branch
        );
        if (rt != null) tac.RecordTypeId = rt;
        insert tac;

        Test.startTest();
        FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>{ tac.Id });
        Test.stopTest();

        OutreachSourceCode osc = [SELECT SourceCode FROM OutreachSourceCode WHERE CampaignId = :tac.Id LIMIT 1];
        // Slug from "Peer to Peer Drive" (no short name): first 4 of "Peer" + first 2 of "to" = "PEERTO"
        System.assert(osc.SourceCode.startsWith('PEERTO-'), 'Slug fallback: ' + osc.SourceCode);
        System.assert(osc.SourceCode.endsWith('-DM'), 'Channel code DM: ' + osc.SourceCode);
    }

    @isTest
    static void test_InvocableWrapperHandlesNullRequests() {
        Test.startTest();
        List<FQS_OutreachSourceCodeBuilder.BuildResult> r1 =
            FQS_OutreachSourceCodeBuilder.buildInvocable(new List<FQS_OutreachSourceCodeBuilder.BuildRequest>{ new FQS_OutreachSourceCodeBuilder.BuildRequest() });
        Integer nullListCount = FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(null);
        Integer emptyListCount = FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns(new List<Id>());
        Test.stopTest();

        System.assertEquals(0, r1[0].createdCount);
        System.assertEquals(0, nullListCount);
        System.assertEquals(0, emptyListCount);
    }

    @isTest
    static void test_InvocableWrapper() {
        Campaign tac = makeTactical('Community Open House', 'OPEN', 'Events', true);
        FQS_OutreachSourceCodeBuilder.BuildRequest r = new FQS_OutreachSourceCodeBuilder.BuildRequest();
        r.campaignIds = new List<Id>{ tac.Id };

        Test.startTest();
        List<FQS_OutreachSourceCodeBuilder.BuildResult> results =
            FQS_OutreachSourceCodeBuilder.buildInvocable(new List<FQS_OutreachSourceCodeBuilder.BuildRequest>{ r });
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(1, results[0].createdCount);
        System.assertEquals(null, results[0].errorMessage);
    }
}
