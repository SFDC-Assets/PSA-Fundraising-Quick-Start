/**
 * FQS Campaign Hierarchy Setup — build service.
 *
 * Called by the FQS_Campaign_Hierarchy_Setup screen flow. Takes the chosen model plus three
 * lists of selected FQS_Campaign_Template__mdt.Template_Key__c values (rollups, strategies,
 * asks) — the rows the admin left checked in the flow's Data Tables — and inserts Campaign
 * records in parent-child order.
 *
 * Date rules from Date_Rule__c on each template are resolved against the org's fiscal-year
 * window at build time. Template names run through {yearLabel}/{yearShort} expansion. The
 * FQS_Campaign_Category__c picklist is populated from a small mapping based on the
 * template's key (for program rollups) or the resolved name (for strategies/asks).
 */
public inherited sharing class FQS_CampaignHierarchyBuilder {

    // ─── Build request / result ───────────────────────────────────────────────

    public class BuildRequest {
        @InvocableVariable(required=true label='Model' description='Seasonal | GivingPrograms | Strategy')
        public String model;

        @InvocableVariable(label='Year Offset' description='-1 = last year, 0 = this year, 1 = next year. Defaults to 0.')
        public Integer yearOffset;

        @InvocableVariable(label='Selected Rollup Template Keys' description='Only used when model = GivingPrograms; controls which program rollups are created.')
        public List<String> selectedRollupKeys;

        @InvocableVariable(label='Selected Strategy Template Keys')
        public List<String> selectedStrategyKeys;

        @InvocableVariable(label='Selected Ask Template Keys')
        public List<String> selectedAskKeys;
    }

    public class BuildResult {
        @InvocableVariable(label='Created Model')         public String createdModel;
        @InvocableVariable(label='Created Top Level Ids') public List<String> createdTopLevelIds;
        @InvocableVariable(label='Created Campaigns' description='All Campaigns inserted (rollups + strategies + asks) for downstream Flow use.')
        public List<Campaign> createdCampaigns;
        @InvocableVariable(label='Rollup Count')          public Integer rollupCount;
        @InvocableVariable(label='Strategy Count')        public Integer strategyCount;
        @InvocableVariable(label='Ask Count')             public Integer askCount;
        @InvocableVariable(label='Outreach Source Code Count' description='Count of default OutreachSourceCode records auto-created for the new tacticals.')
        public Integer outreachSourceCodeCount;
        @InvocableVariable(label='Error Message')         public String errorMessage;
    }

    // ─── Constants ────────────────────────────────────────────────────────────

    private static final Map<String, String> TOP_LEVEL_CATEGORY_MAP = new Map<String, String>{
        'prg_major_gifts'       => 'Major Gifts',
        'prg_planned_giving'    => 'Planned Giving',
        'prg_events'            => 'Events',
        'prg_online_giving'     => 'Annual Giving',
        'prg_annual_giving'     => 'Annual Giving',
        'prg_foundation_giving' => 'Grants'
    };

    private class YearWindow {
        Date startDate;
        Date endDate;
        String label;
    }

    private class DateWindow {
        Date startDate;
        Date endDate;
    }

    // ─── BUILD ────────────────────────────────────────────────────────────────

    @InvocableMethod(
        category='FQS'
        label='Build FQS Campaign Hierarchy'
        description='Inserts Campaigns for the selected template keys in parent-child order.'
    )
    public static List<BuildResult> build(List<BuildRequest> requests) {
        BuildRequest req = requests[0];
        BuildResult result = new BuildResult();
        result.createdModel  = req.model;
        result.rollupCount   = 0;
        result.strategyCount = 0;
        result.askCount      = 0;
        result.outreachSourceCodeCount = 0;

        Set<String> selectedRollupKeys   = toSet(req.selectedRollupKeys);
        Set<String> selectedStrategyKeys = toSet(req.selectedStrategyKeys);
        Set<String> selectedAskKeys      = toSet(req.selectedAskKeys);

        Integer yearOffset = (req.yearOffset == null) ? 0 : req.yearOffset;
        YearWindow yw = computeYearWindow(yearOffset);
        // Status by year: last=Completed, this=In Progress, next+=Planned.
        String yearStatus = (yearOffset < 0) ? 'Completed' : (yearOffset == 0 ? 'In Progress' : 'Planned');
        // Historical cohorts land IsActive=false so they don't clutter default Campaign lookups.
        // Backfill/data-import steps can toggle IsActive=true on the specific rows they need to write against.
        Boolean yearIsActive = (yearOffset < 0) ? false : true;

        List<FQS_Campaign_Template__mdt> templates = [
            SELECT Template_Key__c, Suggested_Name__c, Level__c,
                   Applicable_Models__c, Default_In_Model__c,
                   Function_Group__c, Date_Rule__c, Parent_Template_Key__c, Sort_Order__c
            FROM   FQS_Campaign_Template__mdt
            WHERE  Applicable_Models__c LIKE :('%' + req.model + '%')
            ORDER BY Sort_Order__c ASC NULLS LAST
        ];

        Id rtId;
        try {
            rtId = [SELECT Id FROM RecordType WHERE SobjectType='Campaign' AND DeveloperName='FQS_Fundraising' LIMIT 1].Id;
        } catch (Exception e) { /* proceed without RT */ }

        // 1. Rollups
        List<Campaign> rollupCampaigns = new List<Campaign>();
        List<String>   rollupKeys      = new List<String>();

        if (req.model == 'GivingPrograms') {
            for (FQS_Campaign_Template__mdt t : templates) {
                if (t.Level__c != 'Rollup') continue;
                if (!selectedRollupKeys.contains(t.Template_Key__c)) continue;
                Campaign c = new Campaign(
                    Name      = expandName(t.Suggested_Name__c, yw.label),
                    StartDate = yw.startDate,
                    Status    = 'In Progress',
                    IsActive  = true
                    // Category intentionally blank on rollups; use only on Level 2 (Operational) + Level 3 (Tactical).
                );
                if (rtId != null) c.RecordTypeId = rtId;
                rollupCampaigns.add(c);
                rollupKeys.add(t.Template_Key__c);
            }
        } else {
            String topName = yw.label + ' ' + (req.model == 'Seasonal' ? 'Fundraising' : 'Donor Strategy');
            Campaign c = new Campaign(
                Name      = topName,
                StartDate = yw.startDate,
                EndDate   = yw.endDate,
                Status    = yearStatus,
                IsActive  = yearIsActive
                // Category intentionally blank on rollups; use only on Level 2 (Operational) + Level 3 (Tactical).
            );
            if (rtId != null) c.RecordTypeId = rtId;
            rollupCampaigns.add(c);
            rollupKeys.add('rollup');
        }

        if (rollupCampaigns.isEmpty()) {
            result.errorMessage = 'No rollup Campaigns selected. At least one top-level rollup is required.';
            return new List<BuildResult>{ result };
        }

        // Duplicate handling.
        // - GivingPrograms rollups (e.g., "Major Gifts") are perpetual: reuse across years.
        // - Seasonal/Strategy rollups are year-prefixed (e.g., "CY26 Fundraising"): abort on same-year re-run.
        List<String> rollupNames = new List<String>();
        for (Campaign c : rollupCampaigns) rollupNames.add(c.Name);
        Map<String, Campaign> existingByName = new Map<String, Campaign>();
        for (Campaign c : [SELECT Id, Name, StartDate, EndDate, FQS_Campaign_Category__c FROM Campaign WHERE Name IN :rollupNames AND RecordType.DeveloperName = 'FQS_Fundraising']) {
            existingByName.put(c.Name, c);
        }

        if (req.model != 'GivingPrograms' && !existingByName.isEmpty()) {
            result.errorMessage = 'A Campaign named \'' + new List<Campaign>(existingByName.values())[0].Name + '\' already exists. Please rename or delete it before running setup again.';
            return new List<BuildResult>{ result };
        }

        Savepoint sp = Database.setSavepoint();
        try {
        List<Campaign> toInsert = new List<Campaign>();
        for (Campaign c : rollupCampaigns) if (!existingByName.containsKey(c.Name)) toInsert.add(c);
        if (!toInsert.isEmpty()) insert toInsert;

        // Replace new-instance rows with the reused (existing) rollup where applicable,
        // so downstream strategy/ask parenting uses the persisted Id.
        for (Integer i = 0; i < rollupCampaigns.size(); i++) {
            Campaign existing = existingByName.get(rollupCampaigns[i].Name);
            if (existing != null) rollupCampaigns[i] = existing;
        }

        Map<String, Campaign> rollupByTemplateKey = new Map<String, Campaign>();
        for (Integer i = 0; i < rollupKeys.size(); i++) {
            rollupByTemplateKey.put(rollupKeys[i], rollupCampaigns[i]);
        }

        // 2. Strategies
        List<Campaign> strategyCampaigns = new List<Campaign>();
        Map<String, Campaign> strategyByTemplateKey = new Map<String, Campaign>();

        if (req.model == 'GivingPrograms') {
            for (Integer i = 0; i < rollupKeys.size(); i++) {
                Campaign rollup = rollupCampaigns[i];
                Campaign strat = new Campaign(
                    Name      = yw.label + ' ' + rollup.Name,
                    ParentId  = rollup.Id,
                    StartDate = yw.startDate,
                    EndDate   = yw.endDate,
                    Status    = yearStatus,
                    IsActive  = yearIsActive,
                    FQS_Campaign_Category__c = resolveCategoryForTopLevel(rollupKeys[i], req.model)
                );
                if (rtId != null) strat.RecordTypeId = rtId;
                strategyCampaigns.add(strat);
                strategyByTemplateKey.put(rollupKeys[i] + '::str_year_cohort', strat);
            }
        } else {
            Campaign parentRollup = rollupByTemplateKey.get('rollup');
            for (FQS_Campaign_Template__mdt t : templates) {
                if (t.Level__c != 'Strategy') continue;
                if (!selectedStrategyKeys.contains(t.Template_Key__c)) continue;
                DateWindow win = computeWindow(t.Date_Rule__c, yw.startDate, yw.endDate);
                String stratName = yw.label + ' ' + expandName(t.Suggested_Name__c, yw.label);
                Campaign strat = new Campaign(
                    Name      = stratName,
                    ParentId  = parentRollup.Id,
                    StartDate = win.startDate,
                    EndDate   = win.endDate,
                    Status    = yearStatus,
                    IsActive  = yearIsActive,
                    FQS_Campaign_Category__c = resolveCategoryForStrategy(stratName, req.model)
                );
                if (rtId != null) strat.RecordTypeId = rtId;
                strategyCampaigns.add(strat);
                strategyByTemplateKey.put(t.Template_Key__c, strat);
            }
        }

        if (!strategyCampaigns.isEmpty()) insert strategyCampaigns;

        // 3. Asks
        List<Campaign> askCampaigns = new List<Campaign>();
        for (FQS_Campaign_Template__mdt t : templates) {
            if (t.Level__c != 'Ask') continue;
            if (!selectedAskKeys.contains(t.Template_Key__c)) continue;

            Campaign parentStrat;
            if (req.model == 'GivingPrograms') {
                if (!rollupByTemplateKey.containsKey(t.Parent_Template_Key__c)) continue;
                parentStrat = strategyByTemplateKey.get(t.Parent_Template_Key__c + '::str_year_cohort');
            } else {
                parentStrat = strategyByTemplateKey.get(t.Parent_Template_Key__c);
            }
            if (parentStrat == null) continue;

            DateWindow win = computeWindow(t.Date_Rule__c, parentStrat.StartDate, parentStrat.EndDate);
            String askName = expandName(t.Suggested_Name__c, yw.label);
            // Category: substring-based resolver first, then inherit from parent strategy so nothing lands null.
            String askCategory = resolveCategoryForAsk(askName, req.model, parentStrat.Name);
            if (askCategory == null) askCategory = parentStrat.FQS_Campaign_Category__c;
            Campaign ask = new Campaign(
                Name      = askName,
                ParentId  = parentStrat.Id,
                StartDate = win.startDate,
                EndDate   = win.endDate,
                Status    = yearStatus,
                IsActive  = yearIsActive,
                FQS_Campaign_Category__c = askCategory,
                FQS_Short_Name__c = shortNameFromTemplateKey(t.Template_Key__c, yw.label)
            );
            if (rtId != null) ask.RecordTypeId = rtId;
            askCampaigns.add(ask);
        }
        if (!askCampaigns.isEmpty()) insert askCampaigns;

        // 3b. Placeholder OutreachSourceCode per tactical (depth 3+). We set
        //     FQS_Create_First_Outreach_Source_Code__c=true on each Ask; the record-triggered
        //     flow FQS_Campaign_Create_First_OSC fires on the update and creates the placeholder
        //     natively. Flow is idempotent via External_Id__c so re-runs never duplicate.
        //
        //     Skip when FundraisingConfig.OutreachSourceCodeGenFmla is null — the platform
        //     back-fills OutreachSourceCode.SourceCode from that formula at insert; without it
        //     the flow's recordCreate fails REQUIRED_FIELD_MISSING. Admins configure the
        //     formula in Fundraising Setup post-install; until then, skip placeholder OSCs.
        Integer oscCreated = 0;
        Boolean oscConfigured = false;
        List<FundraisingConfig> cfg = [SELECT OutreachSourceCodeGenFmla FROM FundraisingConfig LIMIT 1];
        if (!cfg.isEmpty() && String.isNotBlank(cfg[0].OutreachSourceCodeGenFmla)) oscConfigured = true;

        if (!askCampaigns.isEmpty() && oscConfigured) {
            List<Id> askIds = new List<Id>();
            for (Campaign a : askCampaigns) askIds.add(a.Id);
            try {
                List<Campaign> flagUpdates = new List<Campaign>();
                for (Id askId : askIds) {
                    flagUpdates.add(new Campaign(Id = askId, FQS_Create_First_Outreach_Source_Code__c = true));
                }
                update flagUpdates;
                oscCreated = [SELECT COUNT() FROM OutreachSourceCode WHERE CampaignId IN :askIds];
            } catch (Exception oscEx) {
                // OSC failure must not roll back the whole hierarchy; surface a warning instead.
                result.errorMessage = 'Hierarchy built, but Outreach Source Code creation failed: ' + oscEx.getMessage();
            }
        }
        result.outreachSourceCodeCount = oscCreated;

        // 4. Return
        List<String> topIds = new List<String>();
        for (Campaign c : rollupCampaigns) topIds.add(String.valueOf(c.Id));

        List<Id> allIds = new List<Id>();
        for (Campaign c : rollupCampaigns)   allIds.add(c.Id);
        for (Campaign c : strategyCampaigns) allIds.add(c.Id);
        for (Campaign c : askCampaigns)      allIds.add(c.Id);

        List<Campaign> allCreated = allIds.isEmpty() ? new List<Campaign>() : [
            SELECT Id, Name, StartDate, EndDate, ParentId,
                   FQS_Hierarchy_Depth__c, FQS_Ultimate_Parent_Campaign__c,
                   FQS_Campaign_Category__c, FQS_Enable_Auto_Members__c
            FROM   Campaign
            WHERE  Id IN :allIds
            ORDER BY FQS_Hierarchy_Depth__c ASC NULLS FIRST, Name ASC
        ];

        result.rollupCount        = rollupCampaigns.size();
        result.strategyCount      = strategyCampaigns.size();
        result.askCount           = askCampaigns.size();
        result.createdTopLevelIds = topIds;
        result.createdCampaigns   = allCreated;
        } catch (Exception e) {
            Database.rollback(sp);
            result.rollupCount   = 0;
            result.strategyCount = 0;
            result.askCount      = 0;
            result.outreachSourceCodeCount = 0;
            result.createdTopLevelIds = new List<String>();
            result.createdCampaigns   = new List<Campaign>();
            result.errorMessage = 'Campaign build failed and was rolled back: ' + e.getMessage();
        }

        return new List<BuildResult>{ result };
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private static Set<String> toSet(List<String> l) {
        return l == null ? new Set<String>() : new Set<String>(l);
    }

    private static YearWindow computeYearWindow(Integer offset) {
        Integer fyStartMonth = 1;
        try {
            fyStartMonth = [SELECT FiscalYearStartMonth FROM Organization LIMIT 1].FiscalYearStartMonth;
        } catch (Exception e) { /* default to calendar year */ }

        Date today   = Date.today();
        Boolean isCY = (fyStartMonth == 1);
        YearWindow yw = new YearWindow();

        if (isCY) {
            Integer y = today.year() + offset;
            yw.startDate = Date.newInstance(y, 1, 1);
            yw.endDate   = Date.newInstance(y, 12, 31);
            yw.label     = 'CY' + String.valueOf(y).right(2);
        } else if (today.month() >= fyStartMonth) {
            Integer startYr = today.year()     + offset;
            Integer endYr   = today.year() + 1 + offset;
            yw.startDate = Date.newInstance(startYr, fyStartMonth, 1);
            yw.endDate   = Date.newInstance(endYr,   fyStartMonth, 1).addDays(-1);
            yw.label     = 'FY' + String.valueOf(endYr).right(2);
        } else {
            Integer startYr = today.year() - 1 + offset;
            Integer endYr   = today.year()     + offset;
            yw.startDate = Date.newInstance(startYr, fyStartMonth, 1);
            yw.endDate   = Date.newInstance(endYr,   fyStartMonth, 1).addDays(-1);
            yw.label     = 'FY' + String.valueOf(endYr).right(2);
        }
        return yw;
    }

    private static DateWindow computeWindow(String rule, Date topStart, Date topEnd) {
        DateWindow win = new DateWindow();
        if (rule == null || rule == 'full-window') {
            win.startDate = topStart; win.endDate = topEnd;
        } else if (rule == 'evergreen') {
            win.startDate = topStart; win.endDate = null;
        } else if (rule == 'mirrors-parent') {
            win.startDate = topStart; win.endDate = topEnd;
        } else if (rule == 'q1') {
            win.startDate = topStart; win.endDate = topStart.addMonths(3).addDays(-1);
        } else if (rule == 'q2') {
            win.startDate = topStart.addMonths(3); win.endDate = topStart.addMonths(6).addDays(-1);
        } else if (rule == 'q3') {
            win.startDate = topStart.addMonths(6); win.endDate = topStart.addMonths(9).addDays(-1);
        } else if (rule == 'q4') {
            win.startDate = topStart.addMonths(9); win.endDate = topEnd;
        } else if (rule == 'mar-may') {
            win.startDate = Date.newInstance(topEnd.year(), 3, 1);
            win.endDate   = Date.newInstance(topEnd.year(), 5, 31);
        } else if (rule == 'sep-nov') {
            win.startDate = Date.newInstance(topStart.year(), 9, 1);
            win.endDate   = Date.newInstance(topStart.year(), 11, 30);
        } else if (rule == 'nov-dec') {
            win.startDate = Date.newInstance(topStart.year(), 11, 1);
            win.endDate   = Date.newInstance(topStart.year(), 12, 31);
        } else if (rule == 'may-jun') {
            win.startDate = Date.newInstance(topEnd.year(), 5, 1);
            win.endDate   = Date.newInstance(topEnd.year(), 6, 30);
        } else if (rule == 'aug-oct') {
            win.startDate = Date.newInstance(topStart.year(), 8, 1);
            win.endDate   = Date.newInstance(topStart.year(), 10, 31);
        } else if (rule == 'jan-mar') {
            win.startDate = Date.newInstance(topEnd.year(), 1, 1);
            win.endDate   = Date.newInstance(topEnd.year(), 3, 31);
        } else if (rule == 'jul-aug') {
            win.startDate = Date.newInstance(topStart.year(), 7, 1);
            win.endDate   = Date.newInstance(topStart.year(), 8, 31);
        } else if (rule == 'dec-2-send') {
            win.startDate = Date.newInstance(topStart.year(), 12, 2);
            win.endDate   = Date.newInstance(topStart.year(), 12, 2);
        } else if (rule == 'dec-28-31') {
            win.startDate = Date.newInstance(topStart.year(), 12, 28);
            win.endDate   = Date.newInstance(topStart.year(), 12, 31);
        } else if (rule == 'oct-plus-apr') {
            Integer endYr = (topEnd.year() > topStart.year()) ? topEnd.year() : topStart.year() + 1;
            win.startDate = Date.newInstance(topStart.year(), 10, 1);
            win.endDate   = Date.newInstance(endYr, 4, 30);
        } else if (rule == 'feb') {
            Integer yr = topEnd.year();
            win.startDate = Date.newInstance(yr, 2, 1);
            win.endDate   = Date.newInstance(yr, 2, Date.daysInMonth(yr, 2));
        } else if (rule == 'oct-dec') {
            win.startDate = Date.newInstance(topStart.year(), 10, 1);
            win.endDate   = Date.newInstance(topStart.year(), 12, 31);
        } else if (rule == 'jul-dec') {
            win.startDate = Date.newInstance(topStart.year(), 7, 1);
            win.endDate   = Date.newInstance(topStart.year(), 12, 31);
        } else {
            win.startDate = topStart; win.endDate = topEnd;
        }
        return win;
    }

    private static String resolveCategoryForTopLevel(String templateKey, String model) {
        if (model == 'GivingPrograms') return TOP_LEVEL_CATEGORY_MAP.get(templateKey);
        return null;
    }

    private static String resolveCategoryForStrategy(String strategyName, String model) {
        if (strategyName != null && strategyName.contains('Foundation Giving')) return 'Grants';
        if ((model == 'Seasonal' || model == 'Strategy') && strategyName != null && (
            strategyName.contains('Celebration') ||
            strategyName.contains('Reception') ||
            strategyName.contains('Open House') ||
            strategyName.contains('Appreciation'))) {
            return 'Events';
        }
        return null;
    }

    private static String resolveCategoryForAsk(String askName, String model, String parentStrategyName) {
        if (parentStrategyName != null && parentStrategyName.contains('Foundation Giving')) return 'Grants';
        if (parentStrategyName != null && (
            parentStrategyName.contains('Celebration') ||
            parentStrategyName.contains('Reception') ||
            parentStrategyName.contains('Open House') ||
            parentStrategyName.contains('Appreciation') ||
            parentStrategyName.contains('Events'))) {
            return 'Events';
        }
        return null;
    }

    private static String expandName(String template, String yearLabel) {
        if (template == null) return '';
        return template.replace('{yearLabel}', yearLabel).replace('{yearShort}', yearLabel.right(2));
    }

    // Short Name: lowercase-alphanumeric-and-hyphens slug for URL/UTM/OSC-source-code use.
    // Format: '{yearLabel}-{templateKeyBody}' → e.g. 'fy26-yearend-email', 'cy26-p2p-drive'.
    // Template keys are already snake_case (evt_donor_reception, ret_lapsed_winback); we
    // strip the leading function-group prefix (evt_, acq_, ret_, ...) and convert the rest.
    private static String shortNameFromTemplateKey(String templateKey, String yearLabel) {
        if (String.isBlank(templateKey)) return null;
        String body = templateKey.toLowerCase();
        Integer underscore = body.indexOf('_');
        if (underscore > 0 && underscore < 5) body = body.substring(underscore + 1);
        body = body.replace('_', '-');
        String prefix = (yearLabel == null) ? '' : yearLabel.toLowerCase();
        return String.isBlank(prefix) ? body : (prefix + '-' + body);
    }
}
