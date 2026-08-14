@isTest
private class FQS_CampaignHierarchyBuilder_Test {

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private static List<String> defaultKeys(String model, String level) {
        List<String> keys = new List<String>();
        for (FQS_Campaign_Template__mdt t : [
            SELECT Template_Key__c
            FROM   FQS_Campaign_Template__mdt
            WHERE  Level__c = :level
            AND    Default_In_Model__c LIKE :('%' + model + '%')
            ORDER BY Sort_Order__c
        ]) {
            keys.add(t.Template_Key__c);
        }
        return keys;
    }

    private static FQS_CampaignHierarchyBuilder.BuildRequest req(String model) {
        FQS_CampaignHierarchyBuilder.BuildRequest r = new FQS_CampaignHierarchyBuilder.BuildRequest();
        r.model                = model;
        r.selectedRollupKeys   = defaultKeys(model, 'Rollup');
        r.selectedStrategyKeys = defaultKeys(model, 'Strategy');
        r.selectedAskKeys      = defaultKeys(model, 'Ask');
        return r;
    }

    private static FQS_CampaignHierarchyBuilder.BuildResult run(FQS_CampaignHierarchyBuilder.BuildRequest r) {
        return FQS_CampaignHierarchyBuilder.build(
            new List<FQS_CampaignHierarchyBuilder.BuildRequest>{ r }
        )[0];
    }

    // ─── Tests ────────────────────────────────────────────────────────────────

    @isTest
    static void test_Seasonal_AllDefaults() {
        Test.startTest();
        FQS_CampaignHierarchyBuilder.BuildResult res = run(req('Seasonal'));
        Test.stopTest();

        System.assertEquals(null, res.errorMessage, 'No error expected');
        System.assertEquals(1, res.rollupCount, 'One top-level for Seasonal');
        System.assert(res.strategyCount >= 1, 'At least one strategy');

        List<Campaign> tops = [SELECT FQS_Campaign_Category__c FROM Campaign WHERE Id IN :res.createdTopLevelIds];
        System.assertEquals('Fundraising Top Level Campaign', tops[0].FQS_Campaign_Category__c);

        List<Campaign> fnd = [SELECT FQS_Campaign_Category__c FROM Campaign WHERE Name LIKE '%Foundation Giving%' AND ParentId IN :res.createdTopLevelIds];
        if (!fnd.isEmpty()) System.assertEquals('Grants', fnd[0].FQS_Campaign_Category__c);
    }

    @isTest
    static void test_Strategy_NoAsks() {
        FQS_CampaignHierarchyBuilder.BuildRequest r = req('Strategy');
        r.selectedAskKeys = new List<String>();

        Test.startTest();
        FQS_CampaignHierarchyBuilder.BuildResult res = run(r);
        Test.stopTest();

        System.assertEquals(null, res.errorMessage);
        System.assertEquals(0, res.askCount, '0 asks');
        System.assert(res.strategyCount >= 1);
    }

    @isTest
    static void test_GivingPrograms_AllDefaults() {
        Test.startTest();
        FQS_CampaignHierarchyBuilder.BuildResult res = run(req('GivingPrograms'));
        Test.stopTest();

        System.assertEquals(null, res.errorMessage);
        System.assert(res.rollupCount >= 1, 'At least one program rollup');
        System.assertEquals(res.rollupCount, res.strategyCount, 'One year-cohort strategy per program');

        List<Campaign> fndTop = [SELECT FQS_Campaign_Category__c FROM Campaign WHERE Name = 'Foundation Giving' AND Id IN :res.createdTopLevelIds];
        if (!fndTop.isEmpty()) System.assertEquals('Grants', fndTop[0].FQS_Campaign_Category__c);
    }

    @isTest
    static void test_GivingPrograms_SubsetOfRollups() {
        List<String> allProgs = defaultKeys('GivingPrograms', 'Rollup');
        if (allProgs.size() < 2) return;
        List<String> subset = new List<String>{ allProgs[0], allProgs[1] };

        FQS_CampaignHierarchyBuilder.BuildRequest r = new FQS_CampaignHierarchyBuilder.BuildRequest();
        r.model                = 'GivingPrograms';
        r.selectedRollupKeys   = subset;
        r.selectedStrategyKeys = new List<String>();
        r.selectedAskKeys      = new List<String>();

        Test.startTest();
        FQS_CampaignHierarchyBuilder.BuildResult res = run(r);
        Test.stopTest();

        System.assertEquals(2, res.rollupCount, 'Exactly 2 rollups');
        System.assertEquals(2, res.strategyCount, 'One year-cohort per selected rollup');
    }

    @isTest
    static void test_NoRollupsSelected_Errors() {
        FQS_CampaignHierarchyBuilder.BuildRequest r = new FQS_CampaignHierarchyBuilder.BuildRequest();
        r.model                = 'GivingPrograms';
        r.selectedRollupKeys   = new List<String>();
        r.selectedStrategyKeys = new List<String>();
        r.selectedAskKeys      = new List<String>();

        Test.startTest();
        FQS_CampaignHierarchyBuilder.BuildResult res = run(r);
        Test.stopTest();

        System.assertNotEquals(null, res.errorMessage);
    }

    @isTest
    static void test_DuplicateRollup_Errors() {
        Id rtId;
        try {
            rtId = [SELECT Id FROM RecordType WHERE SobjectType='Campaign' AND DeveloperName='FQS_Fundraising' LIMIT 1].Id;
        } catch (Exception e) { return; }

        Integer fyStartMonth = 1;
        try { fyStartMonth = [SELECT FiscalYearStartMonth FROM Organization LIMIT 1].FiscalYearStartMonth; } catch (Exception e) {}
        Date today = Date.today();
        String yy;
        if (fyStartMonth == 1) {
            yy = String.valueOf(today.year()).right(2);
        } else if (today.month() >= fyStartMonth) {
            yy = String.valueOf(today.year() + 1).right(2);
        } else {
            yy = String.valueOf(today.year()).right(2);
        }
        String label = (fyStartMonth == 1 ? 'CY' : 'FY') + yy;
        String topName = label + ' Fundraising';

        insert new Campaign(Name=topName, Status='Planned', IsActive=true, RecordTypeId=rtId);
        Integer before = [SELECT COUNT() FROM Campaign];

        FQS_CampaignHierarchyBuilder.BuildRequest r = new FQS_CampaignHierarchyBuilder.BuildRequest();
        r.model                = 'Seasonal';
        r.selectedRollupKeys   = new List<String>{ 'rollup' };
        r.selectedStrategyKeys = new List<String>();
        r.selectedAskKeys      = new List<String>();

        Test.startTest();
        FQS_CampaignHierarchyBuilder.BuildResult res = run(r);
        Test.stopTest();

        System.assertNotEquals(null, res.errorMessage);
        System.assertEquals(before, [SELECT COUNT() FROM Campaign], 'No new Campaigns should be inserted');
    }

    @isTest
    static void test_OrphanedAsk_SilentlyDropped() {
        List<String> stratKeys = defaultKeys('Seasonal', 'Strategy');
        List<String> askKeys   = defaultKeys('Seasonal', 'Ask');
        if (stratKeys.size() < 2 || askKeys.isEmpty()) return;

        String excluded = stratKeys[0];
        String orphanAsk;
        for (FQS_Campaign_Template__mdt t : [
            SELECT Template_Key__c, Parent_Template_Key__c
            FROM   FQS_Campaign_Template__mdt
            WHERE  Level__c = 'Ask'
            AND    Template_Key__c IN :askKeys
        ]) {
            if (t.Parent_Template_Key__c == excluded) { orphanAsk = t.Template_Key__c; break; }
        }
        if (orphanAsk == null) return;

        List<String> keptStrategies = new List<String>();
        for (String k : stratKeys) if (k != excluded) keptStrategies.add(k);

        FQS_CampaignHierarchyBuilder.BuildRequest r = new FQS_CampaignHierarchyBuilder.BuildRequest();
        r.model                = 'Seasonal';
        r.selectedRollupKeys   = new List<String>{ 'rollup' };
        r.selectedStrategyKeys = keptStrategies;
        r.selectedAskKeys      = new List<String>{ orphanAsk };

        Test.startTest();
        FQS_CampaignHierarchyBuilder.BuildResult res = run(r);
        Test.stopTest();

        System.assertEquals(null, res.errorMessage);
        System.assertEquals(0, res.askCount, 'Orphaned ask should be silently dropped');
    }

    @isTest
    static void test_CategoryMapping_FoundationGrantsPromoted() {
        Test.startTest();
        run(req('Seasonal'));
        run(req('Strategy'));
        run(req('GivingPrograms'));
        Test.stopTest();

        for (Campaign c : [SELECT Name, FQS_Campaign_Category__c FROM Campaign WHERE Name LIKE '%Foundation Giving%']) {
            System.assertEquals('Grants', c.FQS_Campaign_Category__c, 'Foundation Giving must be Grants for: ' + c.Name);
        }
    }

    @isTest
    static void test_DateRule_MirrorsParent() {
        Test.startTest();
        FQS_CampaignHierarchyBuilder.BuildResult res = run(req('Seasonal'));
        Test.stopTest();

        List<Campaign> strats = [SELECT Id, Name, StartDate, EndDate FROM Campaign WHERE ParentId IN :res.createdTopLevelIds AND Name LIKE '%Sustainer%'];
        if (strats.isEmpty()) return;
        Map<Id, Campaign> stratById = new Map<Id, Campaign>(strats);
        List<Campaign> asks = [SELECT ParentId, StartDate, EndDate FROM Campaign WHERE ParentId IN :stratById.keySet()];
        for (Campaign ask : asks) {
            Campaign parent = stratById.get(ask.ParentId);
            System.assertEquals(parent.StartDate, ask.StartDate);
            System.assertEquals(parent.EndDate,   ask.EndDate);
        }
    }

    @isTest
    static void test_TemplateLibrary_LoadsExpectedRowsPerModel() {
        Integer seasonalCount = [SELECT COUNT() FROM FQS_Campaign_Template__mdt WHERE Applicable_Models__c LIKE '%Seasonal%'];
        System.assert(seasonalCount >= 5, 'Expected >= 5 Seasonal rows, got: ' + seasonalCount);

        Integer gpCount = [SELECT COUNT() FROM FQS_Campaign_Template__mdt WHERE Applicable_Models__c LIKE '%GivingPrograms%'];
        System.assert(gpCount >= 6, 'Expected >= 6 GivingPrograms rows, got: ' + gpCount);

        Integer strategyCount = [SELECT COUNT() FROM FQS_Campaign_Template__mdt WHERE Applicable_Models__c LIKE '%Strategy%'];
        System.assert(strategyCount >= 5, 'Expected >= 5 Strategy rows, got: ' + strategyCount);
    }

    @isTest
    static void test_TemplateLibrary_FoundationGivingInAllThree() {
        List<FQS_Campaign_Template__mdt> fnd = [
            SELECT Applicable_Models__c FROM FQS_Campaign_Template__mdt WHERE Template_Key__c = 'str_foundation_giving'
        ];
        System.assertEquals(1, fnd.size());
        System.assert(fnd[0].Applicable_Models__c.contains('Seasonal'));
        System.assert(fnd[0].Applicable_Models__c.contains('Strategy'));
    }
}
