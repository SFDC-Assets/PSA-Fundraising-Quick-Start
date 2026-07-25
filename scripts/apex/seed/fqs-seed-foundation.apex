// FQS Seed Foundation — creates shared records used by all donor datasets.
// Idempotent via External_Id__c upserts. Safe to run repeatedly.
//
// Produces:
//   - 3 rollup campaigns (FY24/FY25/FY26) + 9 strategy campaigns + 15 ask campaigns
//     (3-level rollup/strategy/ask hierarchy per FQS setup-flow spec)
//   - 10 GiftDesignations
//   - 18 OutreachSourceCodes (pinned to thematic FY26 asks; remainder round-robin across asks)
//   - 15 Corporate Employer Accounts (FQS-ACC-CORP-01..15) for matching-gift scenarios
//
// Knob: SKIP_OSCS — set true to skip the OutreachSourceCode block. The donor generator
// falls back to ask-campaign assignment (no OSC link) when the OSC pool is empty.
// Useful when demoing / testing paths that shouldn't be muddied by attribution codes.

Boolean SKIP_OSCS = false;

System.debug('=== FQS Seed Foundation starting ===');

// -------- CAMPAIGN HIERARCHY (rollup / strategy / ask) --------
// Reads Organization.FiscalYearStartMonth so FY windows mirror the setup flow. FY26 is
// the fiscal year containing today; FY25/FY24 are the two prior. Prior-year rollups
// exist only to parent the FY25/FY24 asks that back YoY reporting.
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
// {extId, name, strategyExtId, dateToken, fyBucket (26/25/24), category, askKind}
List<List<Object>> askSpec = new List<List<Object>>{
    // FY26 (9 asks)
    new List<Object>{'FQS-CMP-ASK-SPRING-EM-FY26',    'FQS Spring Appeal Email FY26',            'FQS-CMP-STRAT-ANNUAL-FY26', 'mar-may',     26, 'Annual Giving', 'email drop'},
    new List<Object>{'FQS-CMP-ASK-SPRING-DM-FY26',    'FQS Spring Appeal Direct Mail FY26',      'FQS-CMP-STRAT-ANNUAL-FY26', 'mar-may',     26, 'Annual Giving', 'mailing'},
    new List<Object>{'FQS-CMP-ASK-YEAREND-EM-FY26',   'FQS Year-End Email FY26',                 'FQS-CMP-STRAT-ANNUAL-FY26', 'nov-dec',     26, 'Annual Giving', 'email drop'},
    new List<Object>{'FQS-CMP-ASK-CELEB-INV-FY26',    'FQS Annual Celebration Invitation FY26',  'FQS-CMP-STRAT-EVENTS-FY26', 'sep-nov',     26, 'Events',        'invitation + RSVP'},
    new List<Object>{'FQS-CMP-ASK-DONOREVT-FY26',     'FQS Donor Appreciation Reception FY26',   'FQS-CMP-STRAT-EVENTS-FY26', 'may-jun',     26, 'Events',        'sponsorship + invitation packet'},
    new List<Object>{'FQS-CMP-ASK-PORTFOLIO-FY26',    'FQS Major Gifts Portfolio FY26',          'FQS-CMP-STRAT-MAJOR-FY26',  'full-window', 26, 'Major Gifts',   '1:1 solicitation meetings'},
    new List<Object>{'FQS-CMP-ASK-LEGACY-FY26',       'FQS Legacy Circle Outreach FY26',         'FQS-CMP-STRAT-MAJOR-FY26',  'full-window', 26, 'Planned Giving','planned-giving letters'},
    new List<Object>{'FQS-CMP-ASK-FOUND-COMM-FY26',   'FQS Community Foundation Proposal FY26',  'FQS-CMP-STRAT-FOUND-FY26',  'aug-oct',     26, 'Grants',        'grant proposal'},
    new List<Object>{'FQS-CMP-ASK-FOUND-CORPFDN-FY26','FQS Corporate Foundation Proposal FY26',  'FQS-CMP-STRAT-FOUND-FY26',  'jan-mar',     26, 'Grants',        'grant proposal'},
    // FY25 (4 asks)
    new List<Object>{'FQS-CMP-ASK-SPRING-EM-FY25',    'FQS Spring Appeal Email FY25',            'FQS-CMP-STRAT-ANNUAL-FY25', 'mar-may',     25, 'Annual Giving', 'email drop'},
    new List<Object>{'FQS-CMP-ASK-YEAREND-EM-FY25',   'FQS Year-End Email FY25',                 'FQS-CMP-STRAT-ANNUAL-FY25', 'nov-dec',     25, 'Annual Giving', 'email drop'},
    new List<Object>{'FQS-CMP-ASK-CELEB-INV-FY25',    'FQS Annual Celebration Invitation FY25',  'FQS-CMP-STRAT-EVENTS-FY25', 'sep-nov',     25, 'Events',        'invitation'},
    new List<Object>{'FQS-CMP-ASK-FOUND-COMM-FY25',   'FQS Community Foundation Proposal FY25',  'FQS-CMP-STRAT-FOUND-FY25',  'aug-oct',     25, 'Grants',        'grant proposal'},
    // FY24 (2 asks)
    new List<Object>{'FQS-CMP-ASK-YEAREND-EM-FY24',   'FQS Year-End Email FY24',                 'FQS-CMP-STRAT-ANNUAL-FY24', 'nov-dec',     24, 'Annual Giving', 'email drop'},
    new List<Object>{'FQS-CMP-ASK-FOUND-COMM-FY24',   'FQS Community Foundation Proposal FY24',  'FQS-CMP-STRAT-FOUND-FY24',  'aug-oct',     24, 'Grants',        'grant proposal'}
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
        FQS_Campaign_Category__c = (String)row[5]
    );
    if (campaignFqsRT != null) c.RecordTypeId = campaignFqsRT;
    asks.add(c);
}
Database.upsert(asks, Campaign.External_Id__c, true);
System.debug('Ask campaigns upserted: ' + asks.size());

// -------- GIFT DESIGNATIONS --------
// {extId, name, restrictionType}
List<List<String>> designationSpec = new List<List<String>>{
    new List<String>{'FQS-GD-GENERAL-OPERATING',   'FQS General Operating Fund',   'Without Donor Restriction'},
    new List<String>{'FQS-GD-COMMUNITY-PROGRAMS',  'FQS Community Programs',       'Without Donor Restriction'},
    new List<String>{'FQS-GD-EDUCATION',           'FQS Education Initiative',     'With Donor Restriction - Purpose'},
    new List<String>{'FQS-GD-YOUTH',               'FQS Youth Services',           'With Donor Restriction - Purpose'},
    new List<String>{'FQS-GD-EMERGENCY',           'FQS Emergency Relief Fund',    'With Donor Restriction - Purpose'},
    new List<String>{'FQS-GD-BUILDING',            'FQS Building Fund',            'With Donor Restriction - Purpose'},
    new List<String>{'FQS-GD-EXPANSION',           'FQS Program Expansion Fund',   'With Donor Restriction - Purpose'},
    new List<String>{'FQS-GD-END-SCHOLAR',         'FQS Endowment - Scholarships', 'With Donor Restriction - Permanent'},
    new List<String>{'FQS-GD-END-OPS',             'FQS Endowment - Operations',   'With Donor Restriction - Permanent'},
    new List<String>{'FQS-GD-END-LEGACY',          'FQS Named Legacy Endowment',   'With Donor Restriction - Permanent'},
    new List<String>{'FQS-GD-FEE-EVENT-REG',       'FQS Event Registration Fees',  'Earned Revenue'}
};

List<GiftDesignation> designations = new List<GiftDesignation>();
for (List<String> row : designationSpec) {
    designations.add(new GiftDesignation(
        Name = row[1],
        External_Id__c = row[0],
        Description = 'FQS Seed — foundation record',
        IsActive = true,
        FQS_Restriction_Type__c = row[2]
    ));
}
Database.upsert(designations, GiftDesignation.External_Id__c, true);
System.debug('Designations upserted: ' + designations.size());

// -------- OUTREACH SOURCE CODES --------
if (SKIP_OSCS) {
    System.debug('SKIP_OSCS=true — skipping OutreachSourceCode block.');
} else {
    // Preferred thematic FY26 ask per OSC (fallback: round-robin across all asks).
    // OSCs and gifts land on level 3 (asks) only — level 1/2 rollup + strategy tiers
    // pick up totals via ParentId chain.
    Map<String, String> preferredAskBySourceCode = new Map<String, String>{
        'EM-GR-01'   => 'FQS-CMP-ASK-FOUND-COMM-FY26',
        'EM-YE-01'   => 'FQS-CMP-ASK-YEAREND-EM-FY26',
        'DM-FALL-01' => 'FQS-CMP-ASK-CELEB-INV-FY26',
        'EM-AA-Q1'   => 'FQS-CMP-ASK-SPRING-EM-FY26',
        'DM-SPR-01'  => 'FQS-CMP-ASK-SPRING-DM-FY26',
        'SMS-TX-01'  => 'FQS-CMP-ASK-YEAREND-EM-FY26'
    };

    Map<String, Id> askIdByExtId = new Map<String, Id>();
    for (Campaign c : [SELECT Id, External_Id__c FROM Campaign WHERE External_Id__c LIKE 'FQS-CMP-ASK-%']) {
        askIdByExtId.put(c.External_Id__c, c.Id);
    }
    List<Id> allAskIds = new List<Id>(askIdByExtId.values());
    System.assert(!allAskIds.isEmpty(), 'Ask campaigns must be inserted before OSCs — check order');

    // {name, sourceCode, channel}
    List<List<String>> oscSpec = new List<List<String>>{
        new List<String>{'FQS Email - Annual Appeal Q1', 'EM-AA-Q1',  'Email'},
        new List<String>{'FQS Email - Year End Push',    'EM-YE-01',  'Email'},
        new List<String>{'FQS Email - Sustainer',        'EM-SUS-01', 'Email'},
        new List<String>{'FQS Direct Mail - Spring',     'DM-SPR-01', 'Direct Mail'},
        new List<String>{'FQS Direct Mail - Fall',       'DM-FALL-01','Direct Mail'},
        new List<String>{'FQS Direct Mail - Newsletter', 'DM-NL-Q1',  'Direct Mail'},
        new List<String>{'FQS Social Paid - Facebook',   'SP-FB-01',  'Social Paid'},
        new List<String>{'FQS Social Paid - Instagram',  'SP-IG-01',  'Social Paid'},
        new List<String>{'FQS Social Organic - LinkedIn','SO-LI-01',  'Social Organic'},
        new List<String>{'FQS Digital Paid - Google Ads','DP-GA-01',  'Digital Paid'},
        new List<String>{'FQS Digital Paid - Retarget',  'DP-RT-01',  'Digital Paid'},
        new List<String>{'FQS Organic Web - Homepage',   'OW-HP-01',  'Organic Web'},
        new List<String>{'FQS Organic Web - Blog',       'OW-BL-01',  'Organic Web'},
        new List<String>{'FQS Physical - Event Table',   'PH-EVT-01', 'Physical'},
        new List<String>{'FQS Share Partner - Coalition','SP-CO-01',  'Share Partner'},
        new List<String>{'FQS SMS - Text Campaign',      'SMS-TX-01', 'SMS'},
        new List<String>{'FQS Telemarketing - Phonathon','TM-PH-01',  'Telemarketing'},
        new List<String>{'FQS Email - Grant Solicit',    'EM-GR-01',  'Email'}
    };

    List<OutreachSourceCode> oscs = new List<OutreachSourceCode>();
    Integer oscIdx = 0;
    for (List<String> row : oscSpec) {
        Id assignedCampaign;
        if (preferredAskBySourceCode.containsKey(row[1]) && askIdByExtId.containsKey(preferredAskBySourceCode.get(row[1]))) {
            assignedCampaign = askIdByExtId.get(preferredAskBySourceCode.get(row[1]));
        } else {
            assignedCampaign = allAskIds[Math.mod(oscIdx, allAskIds.size())];
        }
        oscs.add(new OutreachSourceCode(
            Name = row[0],
            External_Id__c = 'FQS-OSC-' + row[1],
            SourceCode = row[1],
            MessageChannel = row[2],
            UsageType = 'Fundraising',
            Status = 'Active',
            CampaignId = assignedCampaign,
            Description = 'FQS Seed — foundation record'
        ));
        oscIdx++;
    }
    Database.upsert(oscs, OutreachSourceCode.External_Id__c, true);
    System.debug('OSCs upserted: ' + oscs.size());
}

// -------- CORPORATE EMPLOYER ACCOUNTS --------
// Dedicated pool of 15 corporate accounts used by the donor generator to build
// matching-gift scenarios. Kept separate from the donor pyramid so tests can
// distinguish "donor Account" vs "employer Account" purely by External ID prefix.
//
// Matching-gift configuration is intentionally varied so the Find Matching Gift
// flow's scorers, drift-fix branch, ratio math, and annual-cap enforcement can
// all be exercised against real seeded state:
//
//   - programOn   : sets FQS_Matching_Gift_Program__c=true (lights up the 20-pt
//                   score bonus AND the query path that finds candidates purely
//                   by flag). 10 of 15 are flagged; 5 are unflagged so the flow's
//                   drift-fix prompt has a live target.
//   - ratio       : Number(4,2). 1.00 default on most; 2.00 on TechCorp/Meridian,
//                   0.50 on BlueSky — lets amount scorers see ratio variety.
//   - annualCap   : Currency. Set on 2 (TechCorp $5000, Summit $2500) so cap
//                   enforcement / warning path has a testable trigger.
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

// Verify 'Corporate Employer' is a valid Account.Type value, else fall back to 'Corporate'.
Schema.DescribeFieldResult accountTypeDesc = Account.Type.getDescribe();
Set<String> validAccountTypes = new Set<String>();
for (Schema.PicklistEntry pe : accountTypeDesc.getPicklistValues()) validAccountTypes.add(pe.getValue());
String corpAccountType = validAccountTypes.contains('Corporate Employer') ? 'Corporate Employer'
                       : validAccountTypes.contains('Corporate')          ? 'Corporate'
                       : null;

// Skip match-program fields if they aren't deployed yet — foundation should still
// succeed on orgs that haven't picked up the matching-gift flow metadata.
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

// -------- MATCHING-GIFT INTERMEDIARIES --------
// Third-party facilitators (Benevity, YourCause, etc.) that appear as the legal
// donor on a GiftTransaction while the giving originates from a corporate match
// program. Marked FQS_Is_Match_Intermediary__c=true so the Find Matching Gift
// flow routes to its intermediary branch.
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
} else {
    System.debug('FQS_Is_Match_Intermediary__c not deployed; skipping intermediary account seeding.');
}

// -------- PARTY ROLE RELATION (§12.3 prerequisite) --------
// ContactContactRelation.PartyRoleRelationId is NOT NULL in Nonprofit Cloud.
// The FQS seed generator inserts a small pool of cross-household CCRs so the
// account launcher's soft-credit datatable has multi-account reach to test.
// Every seeded CCR points to this shared PartyRoleRelation stub.
// NOTE: PartyRoleRelation.Name auto-populates from RoleName-RelatedRoleName on insert
// (e.g., "Spouse-Spouse-CCR"), so we key idempotency off (RoleName, RelatedRoleName,
// RelationshipObjectName) rather than Name.
List<PartyRoleRelation> existingPrr = [
    SELECT Id, Name FROM PartyRoleRelation
    WHERE RoleName = 'Spouse' AND RelatedRoleName = 'Spouse'
      AND RelationshipObjectName = 'Contact_Contact_Relationship'
    LIMIT 1
];
if (existingPrr.isEmpty()) {
    PartyRoleRelation prr = new PartyRoleRelation(
        RoleName = 'Spouse',
        RelatedRoleName = 'Spouse',
        RelationshipObjectName = 'Contact_Contact_Relationship',
        ShouldCreaInversRoleAuto = false
    );
    insert prr;
    System.debug('PartyRoleRelation stub inserted: ' + prr.Id);
} else {
    System.debug('PartyRoleRelation for Spouse-Spouse-CCR already exists: ' + existingPrr[0].Id + ' — reusing.');
}

System.debug('=== Foundation seed complete ===');
System.debug('Campaigns (all):      ' + [SELECT COUNT() FROM Campaign            WHERE External_Id__c LIKE 'FQS-CMP-%']);
System.debug('  Rollups:            ' + [SELECT COUNT() FROM Campaign            WHERE External_Id__c LIKE 'FQS-CMP-ROLLUP-%']);
System.debug('  Strategies:         ' + [SELECT COUNT() FROM Campaign            WHERE External_Id__c LIKE 'FQS-CMP-STRAT-%']);
System.debug('  Asks:               ' + [SELECT COUNT() FROM Campaign            WHERE External_Id__c LIKE 'FQS-CMP-ASK-%']);
System.debug('Designations:         ' + [SELECT COUNT() FROM GiftDesignation     WHERE External_Id__c LIKE 'FQS-GD-%']);
System.debug('OutreachSourceCodes:  ' + [SELECT COUNT() FROM OutreachSourceCode  WHERE External_Id__c LIKE 'FQS-OSC-%']);
System.debug('Corporate Employers:  ' + [SELECT COUNT() FROM Account             WHERE External_Id__c LIKE 'FQS-ACC-CORP-%']);
System.debug('Intermediaries:       ' + [SELECT COUNT() FROM Account             WHERE External_Id__c LIKE 'FQS-ACC-INT-%']);
