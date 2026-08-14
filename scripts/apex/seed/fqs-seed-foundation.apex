// FQS Seed Foundation — shared records for all donor datasets. Idempotent via External_Id__c.
// Produces: 3 rollups + 9 strategies + 15 asks; 14 GDs (mirror FQS_Suggest_Designations);
// 1 OSC/ask; 15 corp employers; 5 PRRs (Spouse/Parent-Child/Sibling/Friend/Neighbor).
// SKIP_OSCS=true bypasses the OSC block (donor generator falls back to campaign-only).

Boolean SKIP_OSCS = false;

System.debug('=== FQS Seed Foundation starting ===');

// -------- CAMPAIGN HIERARCHY (rollup / strategy / ask) --------
// FY windows follow Organization.FiscalYearStartMonth.
Id campaignFqsRT;
try {
    campaignFqsRT = [SELECT Id FROM RecordType WHERE SobjectType='Campaign' AND DeveloperName='FQS_Fundraising' LIMIT 1].Id;
} catch (Exception e) {
    System.debug('FQS_Fundraising RT not found; campaigns will use default RT');
}

Integer fyStartMonth = [SELECT FiscalYearStartMonth FROM Organization LIMIT 1].FiscalYearStartMonth;
Date todayDate = Date.today();
Date fy26Start = (todayDate.month() >= fyStartMonth)
    ? Date.newInstance(todayDate.year(),     fyStartMonth, 1)
    : Date.newInstance(todayDate.year() - 1, fyStartMonth, 1);
Date fy26End   = fy26Start.addMonths(12).addDays(-1);
Date fy25Start = fy26Start.addMonths(-12);  Date fy25End = fy26End.addMonths(-12);
Date fy24Start = fy26Start.addMonths(-24);  Date fy24End = fy26End.addMonths(-24);
System.debug('FY windows — FY26: ' + fy26Start + '..' + fy26End
    + ' | FY25: ' + fy25Start + '..' + fy25End
    + ' | FY24: ' + fy24Start + '..' + fy24End);

// Date-rule resolver — returns [startDate, endDate] for a token within a given FY window.
Map<String, List<Date>> fy26Windows = new Map<String, List<Date>>();
Map<String, List<Date>> fy25Windows = new Map<String, List<Date>>();
Map<String, List<Date>> fy24Windows = new Map<String, List<Date>>();

for (Integer fyi = 0; fyi < 3; fyi++) {
    Date fyStart = (fyi == 0) ? fy26Start : (fyi == 1) ? fy25Start : fy24Start;
    Date fyEnd   = (fyi == 0) ? fy26End   : (fyi == 1) ? fy25End   : fy24End;
    Map<String, List<Date>> target = (fyi == 0) ? fy26Windows : (fyi == 1) ? fy25Windows : fy24Windows;
    Integer fyYear = fyStart.year();
    // Month/day windows anchored to calendar months inside the fiscal year.
    target.put('full-window', new List<Date>{fyStart, fyEnd});
    target.put('mar-may',     new List<Date>{Date.newInstance(fyYear + (fyStartMonth <= 3 ? 0 : 1), 3, 1),
                                             Date.newInstance(fyYear + (fyStartMonth <= 3 ? 0 : 1), 5, 31)});
    target.put('may-jun',     new List<Date>{Date.newInstance(fyYear + (fyStartMonth <= 5 ? 0 : 1), 5, 1),
                                             Date.newInstance(fyYear + (fyStartMonth <= 5 ? 0 : 1), 6, 30)});
    target.put('aug-oct',     new List<Date>{Date.newInstance(fyYear + (fyStartMonth <= 8 ? 0 : 1), 8, 1),
                                             Date.newInstance(fyYear + (fyStartMonth <= 8 ? 0 : 1), 10, 31)});
    target.put('sep-nov',     new List<Date>{Date.newInstance(fyYear + (fyStartMonth <= 9 ? 0 : 1), 9, 1),
                                             Date.newInstance(fyYear + (fyStartMonth <= 9 ? 0 : 1), 11, 30)});
    target.put('nov-dec',     new List<Date>{Date.newInstance(fyYear + (fyStartMonth <= 11 ? 0 : 1), 11, 1),
                                             Date.newInstance(fyYear + (fyStartMonth <= 11 ? 0 : 1), 12, 31)});
    target.put('jan-mar',     new List<Date>{Date.newInstance(fyYear + (fyStartMonth <= 1 ? 0 : 1), 1, 1),
                                             Date.newInstance(fyYear + (fyStartMonth <= 3 ? 0 : 1), 3, 31)});
}

// --- Tier 1: Rollups (FY26/FY25/FY24) ---
// {extId, name, startDate, endDate}
List<List<Object>> rollupSpec = new List<List<Object>>{
    new List<Object>{'FQS-CMP-ROLLUP-FY26', 'FQS FY26 Fundraising', fy26Start, fy26End},
    new List<Object>{'FQS-CMP-ROLLUP-FY25', 'FQS FY25 Fundraising', fy25Start, fy25End},
    new List<Object>{'FQS-CMP-ROLLUP-FY24', 'FQS FY24 Fundraising', fy24Start, fy24End}
};

List<Campaign> rollups = new List<Campaign>();
for (List<Object> row : rollupSpec) {
    Campaign c = new Campaign(
        Name = (String)row[1],
        External_Id__c = (String)row[0],
        Description = 'FQS Seed — rollup campaign (top of ' + (String)row[1] + ' tree)',
        IsActive = true,
        Status = 'In Progress',
        StartDate = (Date)row[2],
        EndDate = (Date)row[3],
        FQS_Campaign_Category__c = 'Fundraising Top Level Campaign'
    );
    if (campaignFqsRT != null) c.RecordTypeId = campaignFqsRT;
    rollups.add(c);
}
Database.upsert(rollups, Campaign.External_Id__c, true);

Map<String, Id> rollupIdByExtId = new Map<String, Id>();
for (Campaign c : [SELECT Id, External_Id__c FROM Campaign WHERE External_Id__c IN ('FQS-CMP-ROLLUP-FY26','FQS-CMP-ROLLUP-FY25','FQS-CMP-ROLLUP-FY24')]) {
    rollupIdByExtId.put(c.External_Id__c, c.Id);
}
System.debug('Rollup campaigns upserted: ' + rollupIdByExtId.size());

// --- Tier 2: Strategies ---
// {extId, name, rollupExtId, category, fyStart, fyEnd}
List<List<Object>> strategySpec = new List<List<Object>>{
    new List<Object>{'FQS-CMP-STRAT-ANNUAL-FY26', 'FQS Annual Giving FY26',           'FQS-CMP-ROLLUP-FY26', 'Annual Giving',   fy26Start, fy26End},
    new List<Object>{'FQS-CMP-STRAT-EVENTS-FY26', 'FQS Events FY26',                  'FQS-CMP-ROLLUP-FY26', 'Events',          fy26Start, fy26End},
    new List<Object>{'FQS-CMP-STRAT-MAJOR-FY26',  'FQS Major & Planned Giving FY26',  'FQS-CMP-ROLLUP-FY26', 'Major Gifts',     fy26Start, fy26End},
    new List<Object>{'FQS-CMP-STRAT-FOUND-FY26',  'FQS Foundation Giving FY26',       'FQS-CMP-ROLLUP-FY26', 'Grants',          fy26Start, fy26End},
    new List<Object>{'FQS-CMP-STRAT-ANNUAL-FY25', 'FQS Annual Giving FY25',           'FQS-CMP-ROLLUP-FY25', 'Annual Giving',   fy25Start, fy25End},
    new List<Object>{'FQS-CMP-STRAT-EVENTS-FY25', 'FQS Events FY25',                  'FQS-CMP-ROLLUP-FY25', 'Events',          fy25Start, fy25End},
    new List<Object>{'FQS-CMP-STRAT-FOUND-FY25',  'FQS Foundation Giving FY25',       'FQS-CMP-ROLLUP-FY25', 'Grants',          fy25Start, fy25End},
    new List<Object>{'FQS-CMP-STRAT-ANNUAL-FY24', 'FQS Annual Giving FY24',           'FQS-CMP-ROLLUP-FY24', 'Annual Giving',   fy24Start, fy24End},
    new List<Object>{'FQS-CMP-STRAT-FOUND-FY24',  'FQS Foundation Giving FY24',       'FQS-CMP-ROLLUP-FY24', 'Grants',          fy24Start, fy24End}
};

List<Campaign> strategies = new List<Campaign>();
for (List<Object> row : strategySpec) {
    Campaign c = new Campaign(
        Name = (String)row[1],
        External_Id__c = (String)row[0],
        ParentId = rollupIdByExtId.get((String)row[2]),
        Description = 'FQS Seed — strategy campaign',
        IsActive = true,
        Status = 'In Progress',
        StartDate = (Date)row[4],
        EndDate = (Date)row[5],
        FQS_Campaign_Category__c = (String)row[3]
    );
    if (campaignFqsRT != null) c.RecordTypeId = campaignFqsRT;
    strategies.add(c);
}
Database.upsert(strategies, Campaign.External_Id__c, true);

Map<String, Id> strategyIdByExtId = new Map<String, Id>();
Set<String> strategyExtIds = new Set<String>();
for (List<Object> row : strategySpec) strategyExtIds.add((String)row[0]);
for (Campaign c : [SELECT Id, External_Id__c FROM Campaign WHERE External_Id__c IN :strategyExtIds]) {
    strategyIdByExtId.put(c.External_Id__c, c.Id);
}
System.debug('Strategy campaigns upserted: ' + strategyIdByExtId.size());

// --- Tier 3: Asks (level 3 — where OSCs and gifts land) ---
// {extId, name, strategyExtId, dateToken, fyBucket (26/25/24), category, askKind, shortName}
// shortName feeds FQS_OutreachSourceCodeBuilder's slug generator: normalized slug in URL/UTM style.
List<List<Object>> askSpec = new List<List<Object>>{
    // FY26 (9 asks)
    new List<Object>{'FQS-CMP-ASK-SPRING-EM-FY26',    'FQS Spring Appeal Email FY26',            'FQS-CMP-STRAT-ANNUAL-FY26', 'mar-may',     26, 'Annual Giving', 'email drop',              'fy26-spring-email'},
    new List<Object>{'FQS-CMP-ASK-SPRING-DM-FY26',    'FQS Spring Appeal Direct Mail FY26',      'FQS-CMP-STRAT-ANNUAL-FY26', 'mar-may',     26, 'Annual Giving', 'mailing',                 'fy26-spring-directmail'},
    new List<Object>{'FQS-CMP-ASK-YEAREND-EM-FY26',   'FQS Year-End Email FY26',                 'FQS-CMP-STRAT-ANNUAL-FY26', 'nov-dec',     26, 'Annual Giving', 'email drop',              'fy26-yearend-email'},
    new List<Object>{'FQS-CMP-ASK-CELEB-INV-FY26',    'FQS Annual Celebration Invitation FY26',  'FQS-CMP-STRAT-EVENTS-FY26', 'sep-nov',     26, 'Events',        'invitation + RSVP',       'fy26-celebration-invite'},
    new List<Object>{'FQS-CMP-ASK-DONOREVT-FY26',     'FQS Donor Appreciation Reception FY26',   'FQS-CMP-STRAT-EVENTS-FY26', 'may-jun',     26, 'Events',        'sponsorship + invitation','fy26-donor-reception'},
    new List<Object>{'FQS-CMP-ASK-PORTFOLIO-FY26',    'FQS Major Gifts Portfolio FY26',          'FQS-CMP-STRAT-MAJOR-FY26',  'full-window', 26, 'Major Gifts',   '1:1 solicitation meetings','fy26-mg-portfolio'},
    new List<Object>{'FQS-CMP-ASK-LEGACY-FY26',       'FQS Legacy Circle Outreach FY26',         'FQS-CMP-STRAT-MAJOR-FY26',  'full-window', 26, 'Planned Giving','planned-giving letters',  'fy26-legacy-outreach'},
    new List<Object>{'FQS-CMP-ASK-FOUND-COMM-FY26',   'FQS Community Foundation Proposal FY26',  'FQS-CMP-STRAT-FOUND-FY26',  'aug-oct',     26, 'Grants',        'grant proposal',          'fy26-community-foundation'},
    new List<Object>{'FQS-CMP-ASK-FOUND-CORPFDN-FY26','FQS Corporate Foundation Proposal FY26',  'FQS-CMP-STRAT-FOUND-FY26',  'jan-mar',     26, 'Grants',        'grant proposal',          'fy26-corporate-foundation'},
    // FY25 (4 asks)
    new List<Object>{'FQS-CMP-ASK-SPRING-EM-FY25',    'FQS Spring Appeal Email FY25',            'FQS-CMP-STRAT-ANNUAL-FY25', 'mar-may',     25, 'Annual Giving', 'email drop',              'fy25-spring-email'},
    new List<Object>{'FQS-CMP-ASK-YEAREND-EM-FY25',   'FQS Year-End Email FY25',                 'FQS-CMP-STRAT-ANNUAL-FY25', 'nov-dec',     25, 'Annual Giving', 'email drop',              'fy25-yearend-email'},
    new List<Object>{'FQS-CMP-ASK-CELEB-INV-FY25',    'FQS Annual Celebration Invitation FY25',  'FQS-CMP-STRAT-EVENTS-FY25', 'sep-nov',     25, 'Events',        'invitation',              'fy25-celebration-invite'},
    new List<Object>{'FQS-CMP-ASK-FOUND-COMM-FY25',   'FQS Community Foundation Proposal FY25',  'FQS-CMP-STRAT-FOUND-FY25',  'aug-oct',     25, 'Grants',        'grant proposal',          'fy25-community-foundation'},
    // FY24 (2 asks)
    new List<Object>{'FQS-CMP-ASK-YEAREND-EM-FY24',   'FQS Year-End Email FY24',                 'FQS-CMP-STRAT-ANNUAL-FY24', 'nov-dec',     24, 'Annual Giving', 'email drop',              'fy24-yearend-email'},
    new List<Object>{'FQS-CMP-ASK-FOUND-COMM-FY24',   'FQS Community Foundation Proposal FY24',  'FQS-CMP-STRAT-FOUND-FY24',  'aug-oct',     24, 'Grants',        'grant proposal',          'fy24-community-foundation'}
};

List<Campaign> asks = new List<Campaign>();
for (List<Object> row : askSpec) {
    Integer fyBucket = (Integer)row[4];
    Map<String, List<Date>> windows = (fyBucket == 26) ? fy26Windows : (fyBucket == 25) ? fy25Windows : fy24Windows;
    List<Date> window = windows.get((String)row[3]);
    Campaign c = new Campaign(
        Name = (String)row[1],
        External_Id__c = (String)row[0],
        ParentId = strategyIdByExtId.get((String)row[2]),
        Description = 'Ask: ' + (String)row[6],
        IsActive = true,
        Status = 'In Progress',
        StartDate = window[0],
        EndDate = window[1],
        FQS_Campaign_Category__c = (String)row[5],
        FQS_Short_Name__c = (String)row[7]
    );
    if (campaignFqsRT != null) c.RecordTypeId = campaignFqsRT;
    asks.add(c);
}
Database.upsert(asks, Campaign.External_Id__c, true);
System.debug('Ask campaigns upserted: ' + asks.size());

// Depth capped at 3. Teardown still sweeps legacy SUBASK-*/SUBASK2-* for migrations.

// -------- GIFT DESIGNATIONS --------
// 14 entries mirror the FQS_Suggest_Designations flow catalog exactly; suggester re-runs
// dedupe by Name. Descriptions are short — the flow carries the full copy.
// {extId, name, restrictionType, description}
List<List<String>> designationSpec = new List<List<String>>{
    new List<String>{'FQS-GD-GENERAL-OPERATING', 'FQS General Operating Fund',    'Without Donor Restriction',           'Unrestricted org default; used as org-wide default GD.'},
    new List<String>{'FQS-GD-BOARD-DESIGNATED',  'FQS Board Designated Fund',     'Without Donor Restriction',           'Board-earmarked, undesignateable; donor imposed no restriction.'},
    new List<String>{'FQS-GD-CASH-RESERVE',      'FQS Cash Reserve',              'Without Donor Restriction',           'Reserved by board; spendable on board vote.'},
    new List<String>{'FQS-GD-GENERAL-PROGRAM',   'FQS General Program',           'With Donor Restriction - Purpose',    'Broad purpose restriction, no specific program named.'},
    new List<String>{'FQS-GD-PROGRAM-A',         'FQS Program A',                 'With Donor Restriction - Purpose',    'Placeholder purpose-restricted program; rename post-install.'},
    new List<String>{'FQS-GD-PROGRAM-B',         'FQS Program B',                 'With Donor Restriction - Purpose',    'Second placeholder purpose-restricted program.'},
    new List<String>{'FQS-GD-PROGRAM-EXPANSION', 'FQS Program Expansion Fund',    'With Donor Restriction - Purpose',    'Growth/new-initiative capacity.'},
    new List<String>{'FQS-GD-EQUIPMENT-SUPPLY',  'FQS Equipment and Supply Fund', 'With Donor Restriction - Purpose',    'Below-cap equipment and consumable supplies.'},
    new List<String>{'FQS-GD-STAFF-SALARY',      'FQS Staff Salary Fund',         'With Donor Restriction - Purpose',    'Donor-restricted personnel costs.'},
    new List<String>{'FQS-GD-CAPITAL-CAMPAIGN',  'FQS Capital Campaign Fund',     'With Donor Restriction - Purpose',    'Capital purpose; releases on asset placed-in-service.'},
    new List<String>{'FQS-GD-ENDOWMENT',         'FQS Endowment',                 'With Donor Restriction - Permanent',  'Principal held indefinitely; only earnings spendable.'},
    new List<String>{'FQS-GD-EVENTS',            'FQS Events',                    'Earned Revenue',                      'Gala/event ticket sale value; exchange transaction.'},
    new List<String>{'FQS-GD-MERCHANDISE',       'FQS Merchandise',               'Earned Revenue',                      'Goods sold; exchange transaction.'},
    new List<String>{'FQS-GD-PROGRAM-SERVICES',  'FQS Program Services',          'Earned Revenue',                      'Program-fee/service-charge revenue.'}
};

List<GiftDesignation> designations = new List<GiftDesignation>();
for (List<String> row : designationSpec) {
    designations.add(new GiftDesignation(
        Name = row[1],
        External_Id__c = row[0],
        Description = row[3],
        IsActive = true,
        FQS_Restriction_Type__c = row[2]
    ));
}
Database.upsert(designations, GiftDesignation.External_Id__c, true);
System.debug('Designations upserted: ' + designations.size());

// -------- ORG-WIDE DEFAULT DESIGNATION --------
// Managed frops_flow__ProcessGiftCommitment requires exactly one GD with IsDefault=true.
// Two-pass: clear stale, then set canonical. Memory: [[fqs-orgwide-default-designation]]
List<GiftDesignation> defaultFlagWrites = new List<GiftDesignation>();
for (GiftDesignation gd : [SELECT Id, External_Id__c, IsDefault FROM GiftDesignation WHERE External_Id__c LIKE 'FQS-GD-%']) {
    if ('FQS-GD-GENERAL-OPERATING'.equals(gd.External_Id__c)) {
        if (gd.IsDefault != true) defaultFlagWrites.add(new GiftDesignation(Id = gd.Id, IsDefault = true));
    } else if (gd.IsDefault == true) {
        defaultFlagWrites.add(new GiftDesignation(Id = gd.Id, IsDefault = false));
    }
}
if (!defaultFlagWrites.isEmpty()) {
    List<GiftDesignation> clears = new List<GiftDesignation>();
    List<GiftDesignation> sets = new List<GiftDesignation>();
    for (GiftDesignation gd : defaultFlagWrites) {
        if (gd.IsDefault == true) sets.add(gd); else clears.add(gd);
    }
    if (!clears.isEmpty()) update clears;
    if (!sets.isEmpty()) update sets;
    System.debug('Org-wide default designation flagged: FQS-GD-GENERAL-OPERATING (cleared ' + clears.size() + ' stale, set ' + sets.size() + ')');
} else {
    System.debug('Org-wide default designation already correct — no change.');
}

// -------- OUTREACH SOURCE CODES --------
// One OSC per ask campaign. SourceCode = ask ext-id minus 'FQS-CMP-ASK-' prefix.
// MessageChannel inferred from ext-id body ('-EM-' → Email, '-DM-' → Direct Mail).
if (SKIP_OSCS) {
    System.debug('SKIP_OSCS=true — skipping OutreachSourceCode block.');
} else {
    List<Campaign> askCampaigns = [
        SELECT Id, Name, External_Id__c FROM Campaign
        WHERE External_Id__c LIKE 'FQS-CMP-ASK-%'
        ORDER BY External_Id__c];
    System.assert(!askCampaigns.isEmpty(), 'Ask campaigns must be inserted before OSCs — check order');

    List<OutreachSourceCode> oscs = new List<OutreachSourceCode>();
    for (Campaign c : askCampaigns) {
        String body = c.External_Id__c.substring('FQS-CMP-ASK-'.length());
        String channel;
        if (body.contains('-EM-') || body.startsWith('EM-')) channel = 'Email';
        else if (body.contains('-DM-') || body.startsWith('DM-')) channel = 'Direct Mail';
        else if (body.contains('SMS')) channel = 'SMS';
        else channel = 'Direct Mail';
        oscs.add(new OutreachSourceCode(
            Name = 'FQS OSC ' + body,
            External_Id__c = 'FQS-OSC-' + body,
            SourceCode = body,
            MessageChannel = channel,
            UsageType = 'Fundraising',
            Status = 'Active',
            CampaignId = c.Id,
            Description = 'FQS Seed — ' + c.Name
        ));
    }
    Database.upsert(oscs, OutreachSourceCode.External_Id__c, true);
    System.debug('OSCs upserted (one per ask campaign): ' + oscs.size());
}

// -------- CORPORATE EMPLOYER ACCOUNTS --------
// 15 corp employers, varied matching-gift config: 10/15 programOn (5 unflagged for
// drift-fix testing); ratios 2.0/1.0/0.5; caps on 2 (TechCorp $5000, Summit $2500).
// {name, domain, industry, city, state, programOn, ratio, annualCap}
List<List<Object>> employers = new List<List<Object>>{
    new List<Object>{'TechCorp Global',        'techcorp.demo',     'Technology',             'Chicago',      'IL', true,  2.00, 5000},
    new List<Object>{'Meridian Bank',          'meridianbank.demo', 'Banking',                'New York',     'NY', true,  2.00, null},
    new List<Object>{'BlueSky Insurance',      'bluesky.demo',      'Insurance',              'Hartford',     'CT', true,  0.50, null},
    new List<Object>{'Northwind Energy',       'northwind.demo',    'Energy',                 'Houston',      'TX', true,  1.00, null},
    new List<Object>{'Cascade Manufacturing',  'cascade.demo',      'Manufacturing',          'Portland',     'OR', true,  1.00, null},
    new List<Object>{'Vertex Analytics',       'vertex.demo',       'Technology',             'Seattle',      'WA', true,  1.00, null},
    new List<Object>{'Halcyon Health Systems', 'halcyon.demo',      'Healthcare',             'Boston',       'MA', true,  1.00, null},
    new List<Object>{'Ironclad Legal',         'ironclad.demo',     'Legal Services',         'Washington',   'DC', true,  1.00, null},
    new List<Object>{'Green Meadow Foods',     'greenmeadow.demo',  'Food & Beverage',        'Minneapolis',  'MN', true,  1.00, null},
    new List<Object>{'Aurora Media Group',     'aurora.demo',       'Media',                  'Los Angeles',  'CA', true,  1.00, null},
    new List<Object>{'Summit Consulting',      'summit.demo',       'Professional Services',  'Denver',       'CO', false, 1.00, 2500},
    new List<Object>{'Beacon Retail',          'beacon.demo',       'Retail',                 'Atlanta',      'GA', false, 1.00, null},
    new List<Object>{'Foundry Partners',       'foundry.demo',      'Financial Services',     'San Francisco','CA', false, 1.00, null},
    new List<Object>{'Waypoint Logistics',     'waypoint.demo',     'Transportation',         'Memphis',      'TN', false, 1.00, null},
    new List<Object>{'Copperline Utilities',   'copperline.demo',   'Utilities',              'Phoenix',      'AZ', false, 1.00, null}
};

Schema.DescribeFieldResult accountTypeDesc = Account.Type.getDescribe();
Set<String> validAccountTypes = new Set<String>();
for (Schema.PicklistEntry pe : accountTypeDesc.getPicklistValues()) validAccountTypes.add(pe.getValue());
String corpAccountType = validAccountTypes.contains('Corporate Employer') ? 'Corporate Employer'
                       : validAccountTypes.contains('Corporate')          ? 'Corporate'
                       : null;

// Skip match-program fields when not deployed (foundation stays runnable).
Map<String, Schema.SObjectField> accountFieldMap = Schema.SObjectType.Account.fields.getMap();
Boolean hasProgramFlag  = accountFieldMap.containsKey('fqs_matching_gift_program__c');
Boolean hasRatio        = accountFieldMap.containsKey('fqs_match_ratio__c');
Boolean hasAnnualCap    = accountFieldMap.containsKey('fqs_match_annual_individual_maximum__c');
Boolean hasIntermediary = accountFieldMap.containsKey('fqs_is_match_intermediary__c');

List<Account> corpAccounts = new List<Account>();
for (Integer i = 0; i < employers.size(); i++) {
    List<Object> row = employers[i];
    String extId = 'FQS-ACC-CORP-' + String.valueOf(i + 1).leftPad(2, '0');
    Account a = new Account(
        Name = (String)row[0] + ' FQS-CORP',
        External_Id__c = extId,
        Industry = (String)row[2],
        BillingCity = (String)row[3],
        BillingState = (String)row[4],
        Website = 'https://' + (String)row[1],
        Phone = '555-01' + String.valueOf(10 + i).leftPad(2, '0'),
        Description = 'FQS Seed — corporate employer for matching gifts'
    );
    if (corpAccountType != null) a.Type = corpAccountType;
    if (hasProgramFlag) a.put('FQS_Matching_Gift_Program__c', (Boolean)row[5]);
    if (hasRatio)       a.put('FQS_Match_Ratio__c', row[6]);
    if (hasAnnualCap && row[7] != null) a.put('FQS_Match_Annual_Individual_Maximum__c', row[7]);
    corpAccounts.add(a);
}
Database.upsert(corpAccounts, Account.External_Id__c, true);
System.debug('Corporate employer accounts upserted: ' + corpAccounts.size());

// -------- CORP EMPLOYER PRGs (Phase G4) --------
// One PRG per corp employer, Type='Group'. Launcher's employer picker filters on this.
List<Account> corpAccountsForPrg = [SELECT Id, Name FROM Account WHERE External_Id__c LIKE 'FQS-ACC-CORP-%'];
Set<Id> corpAccountIdsWithPrg = new Set<Id>();
for (PartyRelationshipGroup existingPrg : [SELECT AccountId FROM PartyRelationshipGroup WHERE AccountId IN :corpAccountsForPrg]) {
    corpAccountIdsWithPrg.add(existingPrg.AccountId);
}
List<PartyRelationshipGroup> corpPrgs = new List<PartyRelationshipGroup>();
for (Account a : corpAccountsForPrg) {
    if (corpAccountIdsWithPrg.contains(a.Id)) continue;
    corpPrgs.add(new PartyRelationshipGroup(AccountId = a.Id, Name = a.Name, Type = 'Group'));
}
if (!corpPrgs.isEmpty()) {
    insert corpPrgs;
    System.debug('Corporate employer PRGs inserted: ' + corpPrgs.size());
} else {
    System.debug('Corporate employer PRGs already present — skipped.');
}

// -------- MATCHING-GIFT INTERMEDIARIES --------
// Facilitators (Benevity/YourCause) that legally hold DonorId while match originates
// from a corp program. FQS_Is_Match_Intermediary__c=true routes to the intermediary branch.
// {name, city, state}
List<List<String>> intermediaries = new List<List<String>>{
    new List<String>{'Benevity FQS-INT',   'Calgary',  'AB'},
    new List<String>{'YourCause FQS-INT',  'Plano',    'TX'}
};
if (hasIntermediary) {
    List<Account> intAccounts = new List<Account>();
    for (Integer i = 0; i < intermediaries.size(); i++) {
        List<String> row = intermediaries[i];
        String extId = 'FQS-ACC-INT-' + String.valueOf(i + 1).leftPad(2, '0');
        Account a = new Account(
            Name = row[0],
            External_Id__c = extId,
            Industry = 'Nonprofit',
            BillingCity = row[1],
            BillingState = row[2],
            Description = 'FQS Seed — matching-gift intermediary (facilitator, not employer)'
        );
        if (corpAccountType != null) a.Type = corpAccountType;
        a.put('FQS_Is_Match_Intermediary__c', true);
        if (hasProgramFlag) a.put('FQS_Matching_Gift_Program__c', false);
        intAccounts.add(a);
    }
    Database.upsert(intAccounts, Account.External_Id__c, true);
    System.debug('Match intermediary accounts upserted: ' + intAccounts.size());

    // Same PRG treatment as corp employers for launcher datatable coverage.
    List<Account> intAccountsForPrg = [SELECT Id, Name FROM Account WHERE External_Id__c LIKE 'FQS-ACC-INT-%'];
    Set<Id> intAccountIdsWithPrg = new Set<Id>();
    for (PartyRelationshipGroup existingPrg : [SELECT AccountId FROM PartyRelationshipGroup WHERE AccountId IN :intAccountsForPrg]) {
        intAccountIdsWithPrg.add(existingPrg.AccountId);
    }
    List<PartyRelationshipGroup> intPrgs = new List<PartyRelationshipGroup>();
    for (Account a : intAccountsForPrg) {
        if (intAccountIdsWithPrg.contains(a.Id)) continue;
        intPrgs.add(new PartyRelationshipGroup(AccountId = a.Id, Name = a.Name, Type = 'Group'));
    }
    if (!intPrgs.isEmpty()) {
        insert intPrgs;
        System.debug('Match intermediary PRGs inserted: ' + intPrgs.size());
    } else {
        System.debug('Match intermediary PRGs already present — skipped.');
    }
} else {
    System.debug('FQS_Is_Match_Intermediary__c not deployed; skipping intermediary account seeding.');
}

// -------- PARTY ROLE RELATION (§12.3 prerequisite) --------
// CCR.PartyRoleRelationId is NOT NULL in Nonprofit Cloud. Seed 5 role-typed PRRs so the
// account launcher's soft-credit datatable has multi-role multi-account reach.
// Idempotency keyed off (RoleName, RelatedRoleName, RelationshipObjectName).
Map<String, Schema.SObjectField> prrFieldMap = Schema.SObjectType.PartyRoleRelation.fields.getMap();
Boolean hasPrrExternalId       = prrFieldMap.containsKey('external_id__c');
Boolean hasPrrDefaultHierarchy = prrFieldMap.containsKey('default_hierarchy_type__c');
Boolean hasPrrType             = prrFieldMap.containsKey('type__c');

// {roleName, relatedRoleName, type, defaultHierarchyType, shouldAutoInverse, extIdSuffix}
List<List<Object>> prrSpec = new List<List<Object>>{
    new List<Object>{'Spouse',   'Spouse',   'Immediate Family', 'Peer',   false, 'SPOUSE-SPOUSE'},
    new List<Object>{'Parent',   'Child',    'Immediate Family', 'Parent', true,  'PARENT-CHILD'},
    new List<Object>{'Sibling',  'Sibling',  'Immediate Family', 'Peer',   false, 'SIBLING-SIBLING'},
    new List<Object>{'Friend',   'Friend',   'Other',            'Peer',   false, 'FRIEND-FRIEND'},
    new List<Object>{'Neighbor', 'Neighbor', 'Other',            'Peer',   false, 'NEIGHBOR-NEIGHBOR'}
};

// Query existing rows once, key by (roleName + relatedRoleName + relationshipObjectName).
Map<String, Id> existingPrrByKey = new Map<String, Id>();
for (PartyRoleRelation existing : [
    SELECT Id, RoleName, RelatedRoleName, RelationshipObjectName
    FROM PartyRoleRelation
    WHERE RelationshipObjectName = 'Contact_Contact_Relationship'
      AND RoleName IN ('Spouse','Parent','Child','Sibling','Friend','Neighbor')
]) {
    existingPrrByKey.put(existing.RoleName + '|' + existing.RelatedRoleName + '|' + existing.RelationshipObjectName, existing.Id);
}

List<PartyRoleRelation> prrsToInsert = new List<PartyRoleRelation>();
for (List<Object> row : prrSpec) {
    String key = (String)row[0] + '|' + (String)row[1] + '|Contact_Contact_Relationship';
    if (existingPrrByKey.containsKey(key)) continue;
    PartyRoleRelation prr = new PartyRoleRelation(
        RoleName = (String)row[0],
        RelatedRoleName = (String)row[1],
        RelationshipObjectName = 'Contact_Contact_Relationship',
        ShouldCreaInversRoleAuto = (Boolean)row[4]
    );
    if (hasPrrType)             prr.put('Type__c', (String)row[2]);
    if (hasPrrDefaultHierarchy) prr.put('Default_Hierarchy_Type__c', (String)row[3]);
    if (hasPrrExternalId)       prr.put('External_Id__c', 'FQS-PRR-' + (String)row[5]);
    prrsToInsert.add(prr);
}
if (!prrsToInsert.isEmpty()) {
    insert prrsToInsert;
    System.debug('PartyRoleRelations inserted: ' + prrsToInsert.size() + ' (existing: ' + existingPrrByKey.size() + ')');
} else {
    System.debug('PartyRoleRelations already present — skipped (existing: ' + existingPrrByKey.size() + ')');
}

System.debug('=== Foundation seed complete ===');
System.debug('Campaigns (all):        ' + [SELECT COUNT() FROM Campaign            WHERE External_Id__c LIKE 'FQS-CMP-%']);
System.debug('  Rollups:              ' + [SELECT COUNT() FROM Campaign            WHERE External_Id__c LIKE 'FQS-CMP-ROLLUP-%']);
System.debug('  Strategies:           ' + [SELECT COUNT() FROM Campaign            WHERE External_Id__c LIKE 'FQS-CMP-STRAT-%']);
System.debug('  Asks (depth 3):       ' + [SELECT COUNT() FROM Campaign            WHERE External_Id__c LIKE 'FQS-CMP-ASK-%']);
System.debug('Designations (14):      ' + [SELECT COUNT() FROM GiftDesignation     WHERE External_Id__c LIKE 'FQS-GD-%']);
System.debug('OSCs (one per ask):     ' + [SELECT COUNT() FROM OutreachSourceCode  WHERE External_Id__c LIKE 'FQS-OSC-%']);
System.debug('Corporate Employers:    ' + [SELECT COUNT() FROM Account             WHERE External_Id__c LIKE 'FQS-ACC-CORP-%']);
System.debug('  Corp PRGs (Group):    ' + [SELECT COUNT() FROM PartyRelationshipGroup WHERE Account.External_Id__c LIKE 'FQS-ACC-CORP-%']);
System.debug('Intermediaries:         ' + [SELECT COUNT() FROM Account             WHERE External_Id__c LIKE 'FQS-ACC-INT-%']);
System.debug('  Intermediary PRGs:    ' + [SELECT COUNT() FROM PartyRelationshipGroup WHERE Account.External_Id__c LIKE 'FQS-ACC-INT-%']);
System.debug('PartyRoleRelations:     ' + [SELECT COUNT() FROM PartyRoleRelation   WHERE RelationshipObjectName = 'Contact_Contact_Relationship' AND RoleName IN ('Spouse','Parent','Sibling','Friend','Neighbor')]);
