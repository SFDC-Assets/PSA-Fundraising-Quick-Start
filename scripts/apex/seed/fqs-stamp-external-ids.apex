// FQS Stamp External Ids — patch Campaigns + Designations created by the two setup flows
// (FQS_Campaign_Hierarchy_Setup, FQS_Suggest_Designations) with the External_Id values
// FQSSeedGenerator.seedChunk queries against. Idempotent: skips rows already stamped.
//
// Run once after both setup flows complete, before FQSSeedGenerator.seedChunk.
//
// Stamps:
//   Campaign  → FQS-CMP-ROLLUP-<slug>[-FY##]     (Depth 1)
//   Campaign  → FQS-CMP-STRAT-<slug>[-FY##]      (Depth 2)
//   Campaign  → FQS-CMP-ASK-<slug>-FY##          (Depth 3+)   -- FY defaults to FY26 if unparseable
//   Campaign  → FQS-CMP-ASK-YEAREND-EM-FY##      (one Year-End Email ask per FY, for corp-match target)
//   GiftDesignation → FQS-GD-<slug>              (matched by Name against the 14 well-known FQS names)

System.debug('=== FQS Stamp External Ids starting ===');

// ─── GIFT DESIGNATIONS ───────────────────────────────────────────────────────
// The 14 designations FQS_Suggest_Designations creates, keyed by exact Name.
Map<String, String> gdExtIdByName = new Map<String, String>{
    'FQS General Operating Fund'    => 'FQS-GD-GENERAL-OPERATING',
    'FQS Board Designated Fund'     => 'FQS-GD-BOARD-DESIGNATED',
    'FQS Cash Reserve'              => 'FQS-GD-CASH-RESERVE',
    'FQS General Program'           => 'FQS-GD-GENERAL-PROGRAM',
    'FQS Program A'                 => 'FQS-GD-PROGRAM-A',
    'FQS Program B'                 => 'FQS-GD-PROGRAM-B',
    'FQS Program Expansion Fund'    => 'FQS-GD-PROGRAM-EXPANSION',
    'FQS Equipment and Supply Fund' => 'FQS-GD-EQUIPMENT-SUPPLY',
    'FQS Staff Salary Fund'         => 'FQS-GD-STAFF-SALARY',
    'FQS Capital Campaign Fund'     => 'FQS-GD-CAPITAL-CAMPAIGN',
    'FQS Endowment'                 => 'FQS-GD-ENDOWMENT',
    'FQS Events'                    => 'FQS-GD-EVENTS',
    'FQS Merchandise'               => 'FQS-GD-MERCHANDISE',
    'FQS Program Services'          => 'FQS-GD-PROGRAM-SERVICES'
};

List<GiftDesignation> gdsToUpdate = new List<GiftDesignation>();
for (GiftDesignation gd : [SELECT Id, Name, External_Id__c FROM GiftDesignation WHERE Name IN :gdExtIdByName.keySet()]) {
    String want = gdExtIdByName.get(gd.Name);
    if (gd.External_Id__c == want) continue;
    if (String.isNotBlank(gd.External_Id__c) && gd.External_Id__c.startsWith('FQS-GD-')) continue;
    gd.External_Id__c = want;
    gdsToUpdate.add(gd);
}
if (!gdsToUpdate.isEmpty()) {
    update gdsToUpdate;
}
System.debug('GiftDesignations stamped: ' + gdsToUpdate.size() + ' / ' + gdExtIdByName.size() + ' known names');

// ─── CAMPAIGNS ───────────────────────────────────────────────────────────────
Set<Id> fqsRtIds = new Set<Id>();
for (RecordType rt : [SELECT Id FROM RecordType WHERE SobjectType='Campaign' AND DeveloperName='FQS_Fundraising']) {
    fqsRtIds.add(rt.Id);
}
System.debug('FQS_Fundraising Campaign RT ids: ' + fqsRtIds);

List<Campaign> allFqsCampaigns = [
    SELECT Id, Name, External_Id__c, FQS_Hierarchy_Depth__c, FQS_Campaign_Category__c, ParentId
    FROM   Campaign
    WHERE  RecordTypeId IN :fqsRtIds
    ORDER BY FQS_Hierarchy_Depth__c ASC NULLS FIRST, Name ASC
];
System.debug('FQS campaigns found: ' + allFqsCampaigns.size());

// Slug helper: 'FY26 Year-End Push' → 'YEAR-END-PUSH', stripping FY/CY year-label prefix.
// FY parser: pulls first FY## or CY## from the Name; defaults to 'FY26'.
Set<String> stampedExtIds = new Set<String>();
for (Campaign c : allFqsCampaigns) {
    if (String.isNotBlank(c.External_Id__c)) stampedExtIds.add(c.External_Id__c);
}

List<Campaign> updates = new List<Campaign>();

// Track one YEAREND-EM candidate per FY (Depth 3, Name contains Year-End + Email/EM).
Map<String, Campaign> yearendEmailByFY = new Map<String, Campaign>();

for (Campaign c : allFqsCampaigns) {
    if (String.isNotBlank(c.External_Id__c) && c.External_Id__c.startsWith('FQS-CMP-')) continue;

    String nm = (c.Name == null) ? '' : c.Name;

    // Detect year label anywhere in Name: FY26 / CY26 / FY24 etc.
    String fyToken = null;
    Pattern yp = Pattern.compile('(FY|CY)(\\d{2})');
    Matcher ym = yp.matcher(nm.toUpperCase());
    if (ym.find()) fyToken = ym.group(1) + ym.group(2);

    // Build slug: uppercase, strip year label, non-alphanumerics → dashes, collapse repeats.
    String slug = nm.toUpperCase();
    if (fyToken != null) slug = slug.replace(fyToken, '');
    slug = slug.replaceAll('[^A-Z0-9]+', '-').replaceAll('-+', '-');
    if (slug.startsWith('-')) slug = slug.substring(1);
    if (slug.endsWith('-'))   slug = slug.substring(0, slug.length() - 1);
    if (String.isBlank(slug)) slug = 'UNNAMED';
    if (slug.length() > 30) slug = slug.substring(0, 30);

    Integer depth = (c.FQS_Hierarchy_Depth__c == null) ? 3 : c.FQS_Hierarchy_Depth__c.intValue();
    String tier = (depth == 1) ? 'ROLLUP' : (depth == 2) ? 'STRAT' : 'ASK';

    // Asks REQUIRE an FY suffix (seedChunk buckets by -FY26/-FY25/-FY24). Default to FY26.
    // Rollups/strategies: append FY when present in Name, else leave off.
    String fySuffix;
    if (tier == 'ASK') {
        fySuffix = (fyToken == null) ? '-FY26' : '-' + fyToken;
    } else {
        fySuffix = (fyToken == null) ? '' : '-' + fyToken;
    }

    String candidate = 'FQS-CMP-' + tier + '-' + slug + fySuffix;
    // Guarantee uniqueness within this run in case two rows slugify to the same string.
    String extId = candidate;
    Integer dupCounter = 2;
    while (stampedExtIds.contains(extId)) {
        extId = candidate + '-' + dupCounter;
        dupCounter++;
    }
    stampedExtIds.add(extId);

    c.External_Id__c = extId;
    updates.add(c);

    // Remember Year-End + Email ask as YEAREND-EM target (one per FY).
    if (tier == 'ASK') {
        String nmUp = nm.toUpperCase();
        Boolean isYearEnd = nmUp.contains('YEAR-END') || nmUp.contains('YEAR END') || nmUp.contains('YEAREND');
        Boolean isEmail   = nmUp.contains('EMAIL') || nmUp.contains(' EM ') || nmUp.endsWith(' EM') || nmUp.contains('E-MAIL');
        String fyKey = (fyToken == null) ? 'FY26' : fyToken;
        if (isYearEnd && isEmail && !yearendEmailByFY.containsKey(fyKey)) {
            yearendEmailByFY.put(fyKey, c);
        }
    }
}

// Rewrite the chosen Year-End Email ask per FY to the YEAREND-EM shape.
for (String fyKey : yearendEmailByFY.keySet()) {
    Campaign c = yearendEmailByFY.get(fyKey);
    String preferred = 'FQS-CMP-ASK-YEAREND-EM-' + fyKey;
    if (c.External_Id__c == preferred) continue;
    stampedExtIds.remove(c.External_Id__c);
    String finalId = preferred;
    Integer dupCounter = 2;
    while (stampedExtIds.contains(finalId)) {
        finalId = preferred + '-' + dupCounter;
        dupCounter++;
    }
    stampedExtIds.add(finalId);
    c.External_Id__c = finalId;
}

if (!updates.isEmpty()) {
    update updates;
}
System.debug('Campaigns stamped: ' + updates.size());
System.debug('Year-End Email asks flagged as YEAREND-EM: ' + yearendEmailByFY.keySet());

// ─── SUMMARY ────────────────────────────────────────────────────────────────
Integer cmpCount = [SELECT COUNT() FROM Campaign WHERE External_Id__c LIKE 'FQS-CMP-%'];
Integer askCount = [SELECT COUNT() FROM Campaign WHERE External_Id__c LIKE 'FQS-CMP-ASK-%'];
Integer askFy26  = [SELECT COUNT() FROM Campaign WHERE External_Id__c LIKE 'FQS-CMP-ASK-%-FY26'];
Integer gdCount  = [SELECT COUNT() FROM GiftDesignation WHERE External_Id__c LIKE 'FQS-GD-%'];
System.debug('=== FQS Stamp External Ids complete ===');
System.debug('FQS-CMP-% campaigns: ' + cmpCount + ' (asks: ' + askCount + ', FY26 asks: ' + askFy26 + ')');
System.debug('FQS-GD-% designations: ' + gdCount);
if (askFy26 == 0) System.debug(LoggingLevel.WARN, 'No FY26 asks found — FQSSeedGenerator.seedChunk will fail assertion. Re-run FQS_Campaign_Hierarchy_Setup with yearOffset=0.');
