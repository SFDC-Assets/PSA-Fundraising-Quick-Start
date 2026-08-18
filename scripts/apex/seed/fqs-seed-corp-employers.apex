// FQS Seed Corp Employers — standalone slice of fqs-seed-foundation.apex.
// Creates the 15 corporate employer Accounts + their Group-Type PartyRelationshipGroups
// that FQSSeedGenerator.seedChunk asserts on. Use this when the two setup flows
// (FQS_Campaign_Hierarchy_Setup + FQS_Suggest_Designations) have produced the
// campaigns and designations, but the demo/training org still needs the corp-match
// prerequisites before running seedChunk.
//
// Idempotent via External_Id__c (FQS-ACC-CORP-01..15). Rerun-safe.
//
// Run order:
//   1. FQS_Campaign_Hierarchy_Setup (flow)
//   2. FQS_Suggest_Designations (flow)
//   3. fqs-stamp-external-ids.apex          — stamps FQS-CMP-% / FQS-GD-%
//   4. fqs-seed-corp-employers.apex         — this script
//   5. FQSSeedGenerator.seedChunk(N, 0)     — donors + gifts

System.debug('=== FQS Seed Corp Employers starting ===');

// {name, domain, industry, city, state, programOn, ratio, annualCap}
// Copied verbatim from fqs-seed-foundation.apex so both scripts produce identical Accounts.
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

// Account.Type picklist varies by org (Corporate Employer vs Corporate). Detect at runtime.
Schema.DescribeFieldResult accountTypeDesc = Account.Type.getDescribe();
Set<String> validAccountTypes = new Set<String>();
for (Schema.PicklistEntry pe : accountTypeDesc.getPicklistValues()) validAccountTypes.add(pe.getValue());
String corpAccountType = validAccountTypes.contains('Corporate Employer') ? 'Corporate Employer'
                       : validAccountTypes.contains('Corporate')          ? 'Corporate'
                       : null;

// Skip match-program fields when not deployed (script stays runnable pre-Phase-G4).
Map<String, Schema.SObjectField> accountFieldMap = Schema.SObjectType.Account.fields.getMap();
Boolean hasProgramFlag  = accountFieldMap.containsKey('fqs_matching_gift_program__c');
Boolean hasRatio        = accountFieldMap.containsKey('fqs_match_ratio__c');
Boolean hasAnnualCap    = accountFieldMap.containsKey('fqs_match_annual_individual_maximum__c');

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

// One Group-Type PRG per corp employer. Launcher's employer picker filters on this.
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

System.debug('=== FQS Seed Corp Employers complete ===');
System.debug('FQS-ACC-CORP-% accounts: ' + [SELECT COUNT() FROM Account WHERE External_Id__c LIKE 'FQS-ACC-CORP-%']);
System.debug('FQS-ACC-CORP-% PRGs:     ' + [SELECT COUNT() FROM PartyRelationshipGroup WHERE Account.External_Id__c LIKE 'FQS-ACC-CORP-%']);
