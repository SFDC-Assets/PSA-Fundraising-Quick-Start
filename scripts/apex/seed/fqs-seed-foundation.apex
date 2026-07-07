// FQS Seed Foundation — creates shared records used by all donor datasets.
// Idempotent via FQS_External_Id__c upserts. Safe to run repeatedly.
//
// Produces:
//   - 1 Master Campaign + 5 Category Campaigns + 12 Leaf Campaigns (3-level hierarchy)
//   - 10 GiftDesignations
//   - 18 OutreachSourceCodes (some pinned to thematic campaigns, remainder round-robin)
//   - 15 Corporate Employer Accounts (FQS-ACC-CORP-01..15) for matching-gift scenarios

System.debug('=== FQS Seed Foundation starting ===');

// -------- CAMPAIGN HIERARCHY --------
Id campaignFqsRT;
try {
    campaignFqsRT = [SELECT Id FROM RecordType WHERE SobjectType='Campaign' AND DeveloperName='FQS_Fundraising' LIMIT 1].Id;
} catch (Exception e) {
    System.debug('FQS_Fundraising RT not found; campaigns will use default RT');
}

Date campaignStart = Date.today().addMonths(-6);
Date campaignEnd   = Date.today().addMonths(6);

// --- Tier 1: Master ---
Campaign master = new Campaign(
    Name = 'FQS Master Fundraising',
    FQS_External_Id__c = 'FQS-CMP-MASTER',
    Description = 'FQS Seed — master campaign (top of hierarchy)',
    IsActive = true,
    Status = 'In Progress',
    StartDate = campaignStart,
    EndDate = campaignEnd
);
if (campaignFqsRT != null) master.RecordTypeId = campaignFqsRT;

Database.upsert(new List<Campaign>{master}, Campaign.FQS_External_Id__c, true);
// Re-query to get authoritative Id (upsert of new record populates Id on the passed sobj)
Id masterId = [SELECT Id FROM Campaign WHERE FQS_External_Id__c = 'FQS-CMP-MASTER' LIMIT 1].Id;
System.debug('Master campaign upserted: ' + masterId);

// --- Tier 2: Categories ---
// {extId, name, category}
List<List<String>> categorySpec = new List<List<String>>{
    new List<String>{'FQS-CMP-CAT-ANNUAL',   'FQS Annual Giving',         'Annual Giving'},
    new List<String>{'FQS-CMP-CAT-EVENTS',   'FQS Events',                'Events'},
    new List<String>{'FQS-CMP-CAT-MAJOR',    'FQS Major Gifts',           'Major Gifts'},
    new List<String>{'FQS-CMP-CAT-GRANTS',   'FQS Grants',                'Grants'},
    new List<String>{'FQS-CMP-CAT-CORPCOMM', 'FQS Corporate & Community', 'Corporate Match'}
};

List<Campaign> categories = new List<Campaign>();
for (List<String> row : categorySpec) {
    Campaign c = new Campaign(
        Name = row[1],
        FQS_External_Id__c = row[0],
        ParentId = masterId,
        Description = 'FQS Seed — category campaign',
        IsActive = true,
        Status = 'In Progress',
        StartDate = campaignStart,
        EndDate = campaignEnd,
        FQS_Campaign_Category__c = row[2]
    );
    if (campaignFqsRT != null) c.RecordTypeId = campaignFqsRT;
    categories.add(c);
}
Database.upsert(categories, Campaign.FQS_External_Id__c, true);

Map<String, Id> categoryIdByExtId = new Map<String, Id>();
for (Campaign c : [SELECT Id, FQS_External_Id__c FROM Campaign WHERE FQS_External_Id__c IN ('FQS-CMP-CAT-ANNUAL','FQS-CMP-CAT-EVENTS','FQS-CMP-CAT-MAJOR','FQS-CMP-CAT-GRANTS','FQS-CMP-CAT-CORPCOMM')]) {
    categoryIdByExtId.put(c.FQS_External_Id__c, c.Id);
}
System.debug('Categories upserted: ' + categoryIdByExtId.size());

// --- Tier 3: Leaves ---
// {extId, name, category-extid, campaignCategory}
List<List<String>> leafSpec = new List<List<String>>{
    new List<String>{'FQS-CMP-ANNUAL-2026',  'FQS Annual Fund 2026',           'FQS-CMP-CAT-ANNUAL',   'Annual Giving'},
    new List<String>{'FQS-CMP-ANNUAL-2025',  'FQS Annual Fund 2025',           'FQS-CMP-CAT-ANNUAL',   'Annual Giving'},
    new List<String>{'FQS-CMP-ANNUAL-2024',  'FQS Annual Fund 2024',           'FQS-CMP-CAT-ANNUAL',   'Annual Giving'},
    new List<String>{'FQS-CMP-GALA-2026',    'FQS Spring Gala 2026',           'FQS-CMP-CAT-EVENTS',   'Events'},
    new List<String>{'FQS-CMP-AUCTION-2025', 'FQS Fall Auction 2025',          'FQS-CMP-CAT-EVENTS',   'Events'},
    new List<String>{'FQS-CMP-MG-INIT',      'FQS Major Gifts Initiative',     'FQS-CMP-CAT-MAJOR',    'Major Gifts'},
    new List<String>{'FQS-CMP-LEGACY',       'FQS Legacy Circle',              'FQS-CMP-CAT-MAJOR',    'Planned Giving'},
    new List<String>{'FQS-CMP-GRANTS-2026',  'FQS Foundation Grants 2026',     'FQS-CMP-CAT-GRANTS',   'Grants'},
    new List<String>{'FQS-CMP-CORP-MATCH',   'FQS Corporate Matching Program', 'FQS-CMP-CAT-CORPCOMM', 'Corporate Match'},
    new List<String>{'FQS-CMP-INKIND',       'FQS In-Kind Donations Drive',    'FQS-CMP-CAT-CORPCOMM', 'In-Kind'},
    new List<String>{'FQS-CMP-CAPITAL-2026', 'FQS Capital Campaign 2026',      'FQS-CMP-CAT-CORPCOMM', 'Fundraising Top Level Campaign'},
    new List<String>{'FQS-CMP-GENERAL',      'FQS General Fundraising',        'FQS-CMP-CAT-CORPCOMM', 'Fundraising Top Level Campaign'}
};

List<Campaign> leaves = new List<Campaign>();
for (List<String> row : leafSpec) {
    Campaign c = new Campaign(
        Name = row[1],
        FQS_External_Id__c = row[0],
        ParentId = categoryIdByExtId.get(row[2]),
        Description = 'FQS Seed — leaf campaign',
        IsActive = true,
        Status = 'In Progress',
        StartDate = campaignStart,
        EndDate = campaignEnd,
        FQS_Campaign_Category__c = row[3]
    );
    if (campaignFqsRT != null) c.RecordTypeId = campaignFqsRT;
    leaves.add(c);
}
Database.upsert(leaves, Campaign.FQS_External_Id__c, true);
System.debug('Leaf campaigns upserted: ' + leaves.size());

// -------- GIFT DESIGNATIONS --------
// {extId, name, restrictionType}
List<List<String>> designationSpec = new List<List<String>>{
    new List<String>{'FQS-GD-GENERAL-OPERATING',   'FQS General Operating Fund',   'Without Donor Restriction'},
    new List<String>{'FQS-GD-COMMUNITY-PROGRAMS',  'FQS Community Programs',       'Without Donor Restriction'},
    new List<String>{'FQS-GD-EDUCATION',           'FQS Education Initiative',     'With Donor Restriction - Purpose'},
    new List<String>{'FQS-GD-YOUTH',               'FQS Youth Services',           'With Donor Restriction - Purpose'},
    new List<String>{'FQS-GD-EMERGENCY',           'FQS Emergency Relief Fund',    'With Donor Restriction - Purpose'},
    new List<String>{'FQS-GD-BUILDING-2026',       'FQS 2026 Building Fund',       'With Donor Restriction - Time'},
    new List<String>{'FQS-GD-EXPANSION-2027',      'FQS 2027 Expansion Fund',      'With Donor Restriction - Time'},
    new List<String>{'FQS-GD-END-SCHOLAR',         'FQS Endowment - Scholarships', 'With Donor Restriction - Permanent'},
    new List<String>{'FQS-GD-END-OPS',             'FQS Endowment - Operations',   'With Donor Restriction - Permanent'},
    new List<String>{'FQS-GD-END-LEGACY',          'FQS Named Legacy Endowment',   'With Donor Restriction - Permanent'}
};

List<GiftDesignation> designations = new List<GiftDesignation>();
for (List<String> row : designationSpec) {
    designations.add(new GiftDesignation(
        Name = row[1],
        FQS_External_Id__c = row[0],
        Description = 'FQS Seed — foundation record',
        IsActive = true,
        FQS_Restriction_Type__c = row[2]
    ));
}
Database.upsert(designations, GiftDesignation.FQS_External_Id__c, true);
System.debug('Designations upserted: ' + designations.size());

// -------- OUTREACH SOURCE CODES --------
// Preferred thematic leaf per OSC (fallback: round-robin across all leaves).
Map<String, String> preferredLeafBySourceCode = new Map<String, String>{
    'EM-GR-01'   => 'FQS-CMP-GRANTS-2026',
    'EM-YE-01'   => 'FQS-CMP-ANNUAL-2026',
    'DM-FALL-01' => 'FQS-CMP-AUCTION-2025',
    'EM-AA-Q1'   => 'FQS-CMP-ANNUAL-2026',
    'DM-SPR-01'  => 'FQS-CMP-GALA-2026'
};

Map<String, Id> leafIdByExtId = new Map<String, Id>();
for (Campaign c : [SELECT Id, FQS_External_Id__c FROM Campaign WHERE FQS_External_Id__c LIKE 'FQS-CMP-%' AND FQS_External_Id__c != 'FQS-CMP-MASTER' AND (NOT FQS_External_Id__c LIKE 'FQS-CMP-CAT-%')]) {
    leafIdByExtId.put(c.FQS_External_Id__c, c.Id);
}
List<Id> allLeafIds = new List<Id>(leafIdByExtId.values());
System.assert(!allLeafIds.isEmpty(), 'Leaf campaigns must be inserted before OSCs — check order');

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
    if (preferredLeafBySourceCode.containsKey(row[1]) && leafIdByExtId.containsKey(preferredLeafBySourceCode.get(row[1]))) {
        assignedCampaign = leafIdByExtId.get(preferredLeafBySourceCode.get(row[1]));
    } else {
        assignedCampaign = allLeafIds[Math.mod(oscIdx, allLeafIds.size())];
    }
    oscs.add(new OutreachSourceCode(
        Name = row[0],
        FQS_External_Id__c = 'FQS-OSC-' + row[1],
        SourceCode = row[1],
        MessageChannel = row[2],
        UsageType = 'Fundraising',
        Status = 'Active',
        CampaignId = assignedCampaign,
        Description = 'FQS Seed — foundation record'
    ));
    oscIdx++;
}
Database.upsert(oscs, OutreachSourceCode.FQS_External_Id__c, true);
System.debug('OSCs upserted: ' + oscs.size());

// -------- CORPORATE EMPLOYER ACCOUNTS --------
// Dedicated pool of 15 corporate accounts used by the donor generator to build
// matching-gift scenarios. Kept separate from the donor pyramid so tests can
// distinguish "donor Account" vs "employer Account" purely by External ID prefix.
List<List<String>> employers = new List<List<String>>{
    new List<String>{'TechCorp Global',        'techcorp.demo',     'Technology',             'Chicago',      'IL'},
    new List<String>{'Meridian Bank',          'meridianbank.demo', 'Banking',                'New York',     'NY'},
    new List<String>{'BlueSky Insurance',      'bluesky.demo',      'Insurance',              'Hartford',     'CT'},
    new List<String>{'Northwind Energy',       'northwind.demo',    'Energy',                 'Houston',      'TX'},
    new List<String>{'Cascade Manufacturing',  'cascade.demo',      'Manufacturing',          'Portland',     'OR'},
    new List<String>{'Vertex Analytics',       'vertex.demo',       'Technology',             'Seattle',      'WA'},
    new List<String>{'Halcyon Health Systems', 'halcyon.demo',      'Healthcare',             'Boston',       'MA'},
    new List<String>{'Ironclad Legal',         'ironclad.demo',     'Legal Services',         'Washington',   'DC'},
    new List<String>{'Green Meadow Foods',     'greenmeadow.demo',  'Food & Beverage',        'Minneapolis',  'MN'},
    new List<String>{'Aurora Media Group',     'aurora.demo',       'Media',                  'Los Angeles',  'CA'},
    new List<String>{'Summit Consulting',      'summit.demo',       'Professional Services',  'Denver',       'CO'},
    new List<String>{'Beacon Retail',          'beacon.demo',       'Retail',                 'Atlanta',      'GA'},
    new List<String>{'Foundry Partners',       'foundry.demo',      'Financial Services',     'San Francisco','CA'},
    new List<String>{'Waypoint Logistics',     'waypoint.demo',     'Transportation',         'Memphis',      'TN'},
    new List<String>{'Copperline Utilities',   'copperline.demo',   'Utilities',              'Phoenix',      'AZ'}
};

// Verify 'Corporate Employer' is a valid Account.Type value, else fall back to 'Corporate'.
Schema.DescribeFieldResult accountTypeDesc = Account.Type.getDescribe();
Set<String> validAccountTypes = new Set<String>();
for (Schema.PicklistEntry pe : accountTypeDesc.getPicklistValues()) validAccountTypes.add(pe.getValue());
String corpAccountType = validAccountTypes.contains('Corporate Employer') ? 'Corporate Employer'
                       : validAccountTypes.contains('Corporate')          ? 'Corporate'
                       : null;

List<Account> corpAccounts = new List<Account>();
for (Integer i = 0; i < employers.size(); i++) {
    List<String> row = employers[i];
    String extId = 'FQS-ACC-CORP-' + String.valueOf(i + 1).leftPad(2, '0');
    Account a = new Account(
        Name = row[0] + ' FQS-CORP',
        FQS_External_Id__c = extId,
        Industry = row[2],
        BillingCity = row[3],
        BillingState = row[4],
        Website = 'https://' + row[1],
        Phone = '555-01' + String.valueOf(10 + i).leftPad(2, '0'),
        Description = 'FQS Seed — corporate employer for matching gifts'
    );
    if (corpAccountType != null) a.Type = corpAccountType;
    corpAccounts.add(a);
}
Database.upsert(corpAccounts, Account.FQS_External_Id__c, true);
System.debug('Corporate employer accounts upserted: ' + corpAccounts.size());

System.debug('=== Foundation seed complete ===');
System.debug('Campaigns:            ' + [SELECT COUNT() FROM Campaign            WHERE FQS_External_Id__c LIKE 'FQS-CMP-%']);
System.debug('Designations:         ' + [SELECT COUNT() FROM GiftDesignation     WHERE FQS_External_Id__c LIKE 'FQS-GD-%']);
System.debug('OutreachSourceCodes:  ' + [SELECT COUNT() FROM OutreachSourceCode  WHERE FQS_External_Id__c LIKE 'FQS-OSC-%']);
System.debug('Corporate Employers:  ' + [SELECT COUNT() FROM Account             WHERE FQS_External_Id__c LIKE 'FQS-ACC-CORP-%']);
