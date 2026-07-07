// FQS Small Dataset — 10 donors (~200 total records)
// Run order:
//   1. sf apex run -f scripts/apex/seed/fqs-seed-teardown.apex --target-org FundFirst
//   2. sf apex run -f scripts/apex/seed/fqs-seed-foundation.apex --target-org FundFirst
//   3. sf apex run -f scripts/apex/seed/fqs-seed-small.apex --target-org FundFirst

Integer DONOR_COUNT = 10;
Integer BATCH_OFFSET = 0;


// ============ CONFIG KNOBS ============
Integer PYRAMID_ENTRY_PCT              = 70;    // Entry-level donor share
Integer PYRAMID_MID_PCT                = 25;    // Mid-level donor share (Major = remainder)
Integer PROB_INDIV_PCT                 = 75;    // Individual vs Org for Entry/Mid
Integer PROB_MAJOR_ORG_PCT             = 40;    // Extra Org tilt for Major donors
Decimal PROB_RECURRING                 = 0.35;
Decimal PROB_PLEDGED_MIDPLUS           = 0.40;
Decimal PROB_GRANT_MAJORORG            = 0.60;
Decimal PROB_LAPSED                    = 0.15;
Decimal PROB_SOFT_CREDIT               = 0.15;
Decimal PROB_TRIBUTE                   = 0.10;
Decimal PROB_REFUND                    = 0.03;
Decimal PROB_INKIND                    = 0.03;
Decimal PROB_EMPLOYER_MATCH_ELIGIBLE   = 0.30;  // % of Individual donors employed at a seeded FQS-CORP employer
Decimal PROB_DONOR_COVERS_FEES         = 0.35;  // % of gifts where donor tacks fees onto OriginalAmount
Integer GIFT_HISTORY_YEARS             = 3;

Integer MATCH_ROLL_PLEDGE_MAX          = 30;
Integer MATCH_ROLL_OUTRIGHT_MAX        = 70;
Integer MATCH_ROLL_PENDING_MAX         = 85;

// ============ DETERMINISTIC PRNG ============
Integer prng(Integer seed, Integer salt) {
    Integer h = (seed * 2654 + salt * 4361) & 2147483647;
    h = ((h ^ (h >>> 13)) * 1103515245 & 2147483647);
    h = h ^ (h >>> 15);
    return Math.abs(h);
}
Decimal randRange(Integer seed, Integer salt, Decimal minVal, Decimal maxVal) {
    Integer r = prng(seed, salt);
    Decimal frac = Math.mod(r, 10000) / 10000.0;
    return minVal + (maxVal - minVal) * frac;
}
Integer randInt(Integer seed, Integer salt, Integer minVal, Integer maxVal) {
    return minVal + Math.mod(prng(seed, salt), (maxVal - minVal + 1));
}
Boolean randBool(Integer seed, Integer salt, Decimal probability) {
    return randRange(seed, salt, 0, 1) < probability;
}
String pickOne(Integer seed, Integer salt, List<String> options) {
    return options[Math.mod(prng(seed, salt), options.size())];
}

// ============ HELPERS: ROUND-TO-$5 + FEE MODEL ============
Decimal roundTo5(Decimal amount) {
    return ((amount / 5).round(System.RoundingMode.HALF_UP)) * 5;
}

List<Decimal> computeFees(Decimal baseAmountRoundedTo5, String paymentMethod, Boolean donorCoversFees) {
    Decimal gatewayPct;
    Decimal gatewayFlat;
    if (paymentMethod == 'Credit Card') { gatewayPct = 0.022; gatewayFlat = 0.30; }
    else if (paymentMethod == 'ACH')    { gatewayPct = 0.008; gatewayFlat = 0.00; }
    else if (paymentMethod == 'PayPal') { gatewayPct = 0.029; gatewayFlat = 0.49; }
    else                                { gatewayPct = 0.000; gatewayFlat = 0.00; }  // Check
    Decimal gatewayFee   = (baseAmountRoundedTo5 * gatewayPct + gatewayFlat).setScale(2);
    Decimal processorFee = (baseAmountRoundedTo5 * 0.005).setScale(2);
    Decimal donorCover;
    Decimal originalAmount;
    if (donorCoversFees) {
        donorCover     = (gatewayFee + processorFee).setScale(2);
        originalAmount = (baseAmountRoundedTo5 + donorCover).setScale(2);
    } else {
        donorCover     = 0;
        originalAmount = baseAmountRoundedTo5;
    }
    Decimal netAmount = (originalAmount - gatewayFee - processorFee).setScale(2);
    return new List<Decimal>{originalAmount, gatewayFee, processorFee, donorCover, netAmount};
}

// ============ RUN ============
System.debug('=== FQS Chunk Seed: ' + DONOR_COUNT + ' donors, offset ' + BATCH_OFFSET + ' ===');

Id personAccountRT = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName='PersonAccount' LIMIT 1].Id;
Id oppGrantRT      = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' AND DeveloperName='Grant' LIMIT 1].Id;
Id oppMajorGiftRT  = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' AND DeveloperName='Major_Gift' LIMIT 1].Id;

List<Campaign> campaigns = [SELECT Id, FQS_Campaign_Category__c, FQS_External_Id__c FROM Campaign WHERE FQS_External_Id__c LIKE 'FQS-CMP-%'];
List<GiftDesignation> designations = [SELECT Id FROM GiftDesignation WHERE FQS_External_Id__c LIKE 'FQS-GD-%'];
List<OutreachSourceCode> outreachCodes = [SELECT Id, MessageChannel, CampaignId FROM OutreachSourceCode WHERE FQS_External_Id__c LIKE 'FQS-OSC-%'];
List<Account> corpEmployers = [SELECT Id, FQS_External_Id__c FROM Account WHERE FQS_External_Id__c LIKE 'FQS-ACC-CORP-%' ORDER BY FQS_External_Id__c];

System.assert(campaigns.size() > 0,     'No FQS campaigns — run fqs-seed-foundation.apex first');
System.assert(designations.size() > 0,  'No FQS designations — run fqs-seed-foundation.apex first');
System.assert(outreachCodes.size() > 0, 'No FQS OSCs — run fqs-seed-foundation.apex first');
System.assert(corpEmployers.size() > 0, 'No FQS corporate employers — run fqs-seed-foundation.apex first');

Map<String, List<Id>> campaignsByCategory = new Map<String, List<Id>>();
Id corpMatchCampaignId;
for (Campaign c : campaigns) {
    if (c.FQS_External_Id__c == 'FQS-CMP-CORP-MATCH') corpMatchCampaignId = c.Id;
    if (!campaignsByCategory.containsKey(c.FQS_Campaign_Category__c)) campaignsByCategory.put(c.FQS_Campaign_Category__c, new List<Id>());
    campaignsByCategory.get(c.FQS_Campaign_Category__c).add(c.Id);
}
List<Id> allLeafCampaignIds = new List<Id>();
for (Campaign c : campaigns) {
    if (c.FQS_External_Id__c != 'FQS-CMP-MASTER' && !c.FQS_External_Id__c.startsWith('FQS-CMP-CAT-')) {
        allLeafCampaignIds.add(c.Id);
    }
}
List<Id> allDesignationIds = new List<Id>();
for (GiftDesignation gd : designations) allDesignationIds.add(gd.Id);
List<Id> allOscIds = new List<Id>();
Map<Id, Id> oscToCampaign = new Map<Id, Id>();
for (OutreachSourceCode o : outreachCodes) { allOscIds.add(o.Id); oscToCampaign.put(o.Id, o.CampaignId); }

Integer corpCount = corpEmployers.size();

List<String> firstNames = new List<String>{'Sarah','Michael','Jennifer','David','Emily','Robert','Jessica','William','Ashley','James','Amanda','Christopher','Melissa','Daniel','Nicole','Matthew','Stephanie','Joshua','Rachel','Andrew','Lauren','Ryan','Megan','John','Kimberly','Brandon','Amy','Jason','Amber','Kevin','Angela','Justin','Heather','Tyler','Rebecca','Aaron','Michelle','Adam','Danielle','Nathan','Christina','Anthony','Kayla','Eric','Erin','Steven','Samantha','Timothy','Katherine','Thomas','Riley','Priya','Aiden','Zara','Marcus','Elena','Diego','Anika','Jamal','Sofia','Wei','Fatima','Kai','Mei','Omar','Yuki','Aditi','Chen','Aisha','Rohan'};
List<String> lastNames = new List<String>{'Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin','Lee','Perez','Thompson','White','Harris','Sanchez','Clark','Ramirez','Lewis','Robinson','Walker','Young','Allen','King','Wright','Scott','Torres','Nguyen','Hill','Flores','Green','Adams','Nelson','Baker','Hall','Rivera','Campbell','Mitchell','Carter','Roberts','Chen','Patel','Kim','Wang','Singh','Kumar','Cohen','Reddy','Okafor','Nakamura'};
List<String> orgSuffixes = new List<String>{'Foundation','Community Fund','Family Foundation','Trust','Charitable Trust','Charities','Nonprofit Group','Endowment','Legacy Fund','Giving Circle','Family Trust','Corporation','Enterprises','Ventures','Holdings','Partners','Society','Alliance'};
List<String> orgPrefixes = new List<String>{'Riverside','Northgate','Sunrise','Mountain View','Cedar Hills','Bayside','Oakwood','Silverlake','Harbor','Meadowbrook','Pinecrest','Fairmont','Highland','Wellspring','Westside','Eastwood','Legacy','Beacon','Cornerstone','Horizon','Summit','Evergreen','Brightpath','Cascade'};

// ============ ACCOUNTS ============
List<Account> newAccounts = new List<Account>();
List<Integer> donorTypes = new List<Integer>();
List<Integer> donorLevels = new List<Integer>();
List<Boolean> lapsedFlags = new List<Boolean>();
List<Boolean> employerEligible = new List<Boolean>();   // NEW — Individual + rolls-in
List<Integer> employerIdxByDonor = new List<Integer>(); // NEW — index into corpEmployers list

for (Integer i = 0; i < DONOR_COUNT; i++) {
    Integer globalIdx = BATCH_OFFSET + i;
    Integer roll = Math.mod(prng(globalIdx, 1), 100);
    Integer level = (roll < PYRAMID_ENTRY_PCT) ? 0 : (roll < PYRAMID_ENTRY_PCT + PYRAMID_MID_PCT ? 1 : 2);
    donorLevels.add(level);
    Integer typeRoll = Math.mod(prng(globalIdx, 2), 100);
    Integer donorType = (typeRoll < PROB_INDIV_PCT) ? 0 : 1;
    if (level == 2 && Math.mod(prng(globalIdx, 3), 100) < PROB_MAJOR_ORG_PCT) donorType = 1;
    donorTypes.add(donorType);
    lapsedFlags.add(randBool(globalIdx, 4, PROB_LAPSED));

    Boolean eligible = (donorType == 0) && randBool(globalIdx, 600, PROB_EMPLOYER_MATCH_ELIGIBLE);
    employerEligible.add(eligible);
    employerIdxByDonor.add(eligible ? Math.mod(prng(globalIdx, 601), corpCount) : -1);

    Account a = new Account();
    a.FQS_External_Id__c = 'FQS-ACC-' + globalIdx;
    a.Description = 'FQS Seed — donor ' + globalIdx;
    if (donorType == 0) {
        a.RecordTypeId = personAccountRT;
        a.FirstName = firstNames[Math.mod(prng(globalIdx, 10), firstNames.size())];
        a.LastName = lastNames[Math.mod(prng(globalIdx, 11), lastNames.size())] + ' FQS #' + globalIdx;
    } else {
        String prefix = orgPrefixes[Math.mod(prng(globalIdx, 12), orgPrefixes.size())];
        String suffix = orgSuffixes[Math.mod(prng(globalIdx, 13), orgSuffixes.size())];
        a.Name = prefix + ' ' + suffix + ' FQS #' + globalIdx;
        a.Type = (level == 2) ? 'Foundation' : 'Corporate';
    }
    newAccounts.add(a);
}
insert newAccounts;

// ============ COMMITMENTS ============
List<GiftCommitment> newCommitments = new List<GiftCommitment>();
List<Integer> commitmentDonorIdx = new List<Integer>();
List<String> commitmentKind = new List<String>();
for (Integer i = 0; i < DONOR_COUNT; i++) {
    Integer level = donorLevels[i];
    Integer donorType = donorTypes[i];
    Id donorId = newAccounts[i].Id;
    Integer globalIdx = BATCH_OFFSET + i;
    if (randBool(globalIdx, 20, PROB_RECURRING)) {
        Decimal amt = roundTo5((level == 0) ? randRange(globalIdx, 21, 10, 50) : (level == 1) ? randRange(globalIdx, 21, 50, 500) : randRange(globalIdx, 21, 250, 2500));
        Date startDate = Date.today().addMonths(-randInt(globalIdx, 22, 6, 30));
        newCommitments.add(new GiftCommitment(
            FQS_External_Id__c = 'FQS-GC-' + globalIdx + '-recurring',
            Name = 'FQS Recurring #' + globalIdx, DonorId = donorId, Status = 'Active',
            FulfillmentType = 'Unconditional', RecurrenceType = 'OpenEnded',
            FQS_Gift_Commitment_Category__c = 'Recurring Gift',
            ExpectedTotalCmtAmount = amt.setScale(2),
            EffectiveStartDate = startDate,
            CampaignId = allLeafCampaignIds[Math.mod(prng(globalIdx, 23), allLeafCampaignIds.size())]));
        commitmentDonorIdx.add(i); commitmentKind.add('recurring');
    }
    if (level >= 1 && randBool(globalIdx, 30, PROB_PLEDGED_MIDPLUS)) {
        Decimal totalAmt = roundTo5((level == 1) ? randRange(globalIdx, 31, 2500, 15000) : randRange(globalIdx, 31, 25000, 250000));
        Date startDate = Date.today().addMonths(-randInt(globalIdx, 32, 3, 24));
        newCommitments.add(new GiftCommitment(
            FQS_External_Id__c = 'FQS-GC-' + globalIdx + '-pledged',
            Name = 'FQS Pledge #' + globalIdx, DonorId = donorId, Status = 'Active',
            FulfillmentType = 'Unconditional', RecurrenceType = 'FixedLength',
            FormalCommitmentType = 'Written',
            FQS_Gift_Commitment_Category__c = 'Pledged Gift',
            ExpectedTotalCmtAmount = totalAmt.setScale(2),
            EffectiveStartDate = startDate,
            ExpectedEndDate = startDate.addYears(randInt(globalIdx, 33, 1, 5)),
            CampaignId = allLeafCampaignIds[Math.mod(prng(globalIdx, 34), allLeafCampaignIds.size())]));
        commitmentDonorIdx.add(i); commitmentKind.add('pledged');
    }
    if (level == 2 && donorType == 1 && randBool(globalIdx, 40, PROB_GRANT_MAJORORG)) {
        Decimal grantAmt = roundTo5(randRange(globalIdx, 41, 50000, 500000));
        Date startDate = Date.today().addMonths(-randInt(globalIdx, 42, 3, 18));
        Id campId = campaignsByCategory.containsKey('Grants')
            ? campaignsByCategory.get('Grants')[Math.mod(prng(globalIdx, 44), campaignsByCategory.get('Grants').size())]
            : allLeafCampaignIds[0];
        newCommitments.add(new GiftCommitment(
            FQS_External_Id__c = 'FQS-GC-' + globalIdx + '-grant',
            Name = 'FQS Grant Payout #' + globalIdx, DonorId = donorId, Status = 'Active',
            FulfillmentType = 'Conditional', RecurrenceType = 'FixedLength',
            FormalCommitmentType = 'Written',
            FQS_Gift_Commitment_Category__c = 'Grant Payout',
            ExpectedTotalCmtAmount = grantAmt.setScale(2),
            EffectiveStartDate = startDate,
            ExpectedEndDate = startDate.addYears(randInt(globalIdx, 43, 1, 3)),
            CampaignId = campId));
        commitmentDonorIdx.add(i); commitmentKind.add('grant');
    }
}
if (!newCommitments.isEmpty()) insert newCommitments;

// ============ COMMITMENT SCHEDULES ============
List<GiftCommitmentSchedule> newSchedules = new List<GiftCommitmentSchedule>();
for (Integer i = 0; i < newCommitments.size(); i++) {
    GiftCommitment gc = newCommitments[i];
    String kind = commitmentKind[i];
    Integer di = commitmentDonorIdx[i];
    Integer globalIdx = BATCH_OFFSET + di;
    Decimal schedAmt;
    if (kind == 'recurring') {
        schedAmt = gc.ExpectedTotalCmtAmount != null ? gc.ExpectedTotalCmtAmount : 100;
    } else {
        Integer pledgeYears = (gc.ExpectedEndDate != null && gc.EffectiveStartDate != null)
            ? Math.max(1, gc.ExpectedEndDate.year() - gc.EffectiveStartDate.year())
            : 1;
        schedAmt = roundTo5((gc.ExpectedTotalCmtAmount / pledgeYears).setScale(2));
    }
    GiftCommitmentSchedule sched = new GiftCommitmentSchedule(
        FQS_External_Id__c = 'FQS-GCS-' + globalIdx + '-' + kind,
        GiftCommitmentId = gc.Id,
        TransactionAmount = schedAmt,
        TransactionPeriod = (kind == 'recurring') ? 'Monthly' : 'Yearly',
        StartDate = gc.EffectiveStartDate,
        PaymentMethod = (kind == 'grant') ? 'Check' : (Math.mod(i, 3) == 0 ? 'ACH' : 'Credit Card')
    );
    if (kind != 'recurring' && gc.ExpectedEndDate != null) sched.EndDate = gc.ExpectedEndDate;
    newSchedules.add(sched);
}
if (!newSchedules.isEmpty()) insert newSchedules;

// ============ OPPORTUNITIES ============
List<Opportunity> newOpps = new List<Opportunity>();
List<String> grantStages = new List<String>{'Identification','Cultivation','LOI Submitted','Proposal Submitted','Under Review','Awarded'};
List<String> majorStages = new List<String>{'Identification','Cultivation','Solicitation','Verbal Commitment','Pledged','Closed Won'};
Set<String> terminalStages = new Set<String>{'Awarded','Closed Won','Closed Lost'};
for (Integer i = 0; i < DONOR_COUNT; i++) {
    Integer level = donorLevels[i];
    Integer donorType = donorTypes[i];
    Integer globalIdx = BATCH_OFFSET + i;
    Boolean createOpp = (level == 2) || (level == 1 && randBool(globalIdx, 50, 0.20));
    if (!createOpp) continue;
    Boolean isGrant = (donorType == 1);
    String stage = isGrant
        ? grantStages[Math.mod(prng(globalIdx, 51), grantStages.size())]
        : majorStages[Math.mod(prng(globalIdx, 51), majorStages.size())];
    Boolean isTerminal = terminalStages.contains(stage);
    Integer daysOffset = isTerminal
        ? randInt(globalIdx, 53, -180, -1)    // closed in past
        : randInt(globalIdx, 53, 7, 365);     // still open, future date
    Date closeDate = Date.today().addDays(daysOffset);
    Decimal amt = roundTo5((level == 2) ? randRange(globalIdx, 52, 25000, 500000) : randRange(globalIdx, 52, 5000, 25000));
    Opportunity opp = new Opportunity(
        FQS_External_Id__c = 'FQS-OPP-' + globalIdx,
        Name = (isGrant ? 'FQS Grant App #' : 'FQS Major Gift #') + globalIdx,
        AccountId = newAccounts[i].Id,
        RecordTypeId = isGrant ? oppGrantRT : oppMajorGiftRT,
        StageName = stage,
        CloseDate = closeDate,
        Amount = amt.setScale(2),
        CampaignId = allLeafCampaignIds[Math.mod(prng(globalIdx, 54), allLeafCampaignIds.size())]);
    if (isGrant) opp.FQS_Grant_Deadline__c = Date.today().addDays(randInt(globalIdx, 55, -60, 180));
    else opp.FQS_Solicitation_Date__c = Date.today().addDays(randInt(globalIdx, 55, -180, 60));
    newOpps.add(opp);
}
if (!newOpps.isEmpty()) insert newOpps;

// ============ PAYMENT INSTRUMENTS ============
List<PaymentInstrument> newPIs = new List<PaymentInstrument>();
List<String> piTypes = new List<String>{'Credit Card','Credit Card','Credit Card','ACH','ACH','PayPal'};
List<String> cardBrands = new List<String>{'Visa','MasterCard','American Express','Discover'};
Integer currentYear = System.today().year();
for (Integer i = 0; i < DONOR_COUNT; i++) {
    Integer globalIdx = BATCH_OFFSET + i;
    String piType = piTypes[Math.mod(prng(globalIdx, 60), piTypes.size())];
    Integer last4int = Math.mod(prng(globalIdx, 61), 10000);
    String last4 = String.valueOf(last4int).leftPad(4, '0');
    PaymentInstrument pi = new PaymentInstrument(
        FQS_External_Id__c = 'FQS-PI-' + globalIdx,
        AccountId = newAccounts[i].Id,
        Type = piType,
        Last4 = last4,
        AccountHolderName = newAccounts[i].Name != null
            ? newAccounts[i].Name
            : (newAccounts[i].FirstName + ' ' + newAccounts[i].LastName),
        GatewayName = 'Stripe');
    if (piType == 'Credit Card') {
        pi.CardBrand = cardBrands[Math.mod(prng(globalIdx, 62), cardBrands.size())];
        pi.ExpiryMonth = String.valueOf(randInt(globalIdx, 63, 1, 12)).leftPad(2, '0');
        pi.ExpiryYear = String.valueOf(currentYear + randInt(globalIdx, 64, 0, 5));
    }
    newPIs.add(pi);
}
if (!newPIs.isEmpty()) insert newPIs;

// ============ COMMITMENT INDEXES (for gift-linkage lookup) ============
Map<Integer, List<Id>> pledgedCommitmentByDonor = new Map<Integer, List<Id>>();
Map<Integer, List<Id>> recurringCommitmentByDonor = new Map<Integer, List<Id>>();
Map<Integer, List<Id>> grantCommitmentByDonor = new Map<Integer, List<Id>>();
for (Integer i = 0; i < newCommitments.size(); i++) {
    Integer di = commitmentDonorIdx[i];
    String k = commitmentKind[i];
    if (k == 'pledged') {
        if (!pledgedCommitmentByDonor.containsKey(di)) pledgedCommitmentByDonor.put(di, new List<Id>());
        pledgedCommitmentByDonor.get(di).add(newCommitments[i].Id);
    } else if (k == 'recurring') {
        if (!recurringCommitmentByDonor.containsKey(di)) recurringCommitmentByDonor.put(di, new List<Id>());
        recurringCommitmentByDonor.get(di).add(newCommitments[i].Id);
    } else if (k == 'grant') {
        if (!grantCommitmentByDonor.containsKey(di)) grantCommitmentByDonor.put(di, new List<Id>());
        grantCommitmentByDonor.get(di).add(newCommitments[i].Id);
    }
}

// ============ EMPLOYEE GIFT TRANSACTIONS ============
List<GiftTransaction> newGifts = new List<GiftTransaction>();
List<Integer> giftDonorIdx = new List<Integer>();
List<Integer> giftIndexInDonor = new List<Integer>();  // NEW — g value, for corp-match lookback
List<Boolean> giftIsPaid = new List<Boolean>();
List<String> giftCategory = new List<String>();        // NEW — used by matching logic
List<Integer> giftMatchScenario = new List<Integer>(); // NEW — 0=none, 1=pledge-match, 2=outright-match, 3=pending, 4=eligible-unmatched

for (Integer i = 0; i < DONOR_COUNT; i++) {
    Integer level = donorLevels[i];
    Boolean lapsed = lapsedFlags[i];
    Integer globalIdx = BATCH_OFFSET + i;
    Integer giftCount = (level == 0) ? randInt(globalIdx, 100, 1, 3)
                     : (level == 1) ? randInt(globalIdx, 100, 3, 10)
                                     : randInt(globalIdx, 100, 5, 20);
    Boolean hasPledge = pledgedCommitmentByDonor.containsKey(i);
    Boolean hasRecurring = recurringCommitmentByDonor.containsKey(i);
    Boolean hasGrant = grantCommitmentByDonor.containsKey(i);
    Boolean isEligibleForMatch = employerEligible[i];

    for (Integer g = 0; g < giftCount; g++) {
        Integer catRoll = Math.mod(prng(globalIdx, 101 + g), 100);
        String cat;
        if (hasGrant && catRoll < 15) cat = 'Grant Payment';
        else if (hasPledge && catRoll < 65) cat = 'Pledge Payment';
        else if (hasRecurring && catRoll < 85) cat = 'Pledge Payment';
        else if (catRoll < 95) cat = 'Outright Gift';
        else cat = 'Fee/Payment';

        Decimal baseAmount;
        if (cat == 'Fee/Payment')   baseAmount = randRange(globalIdx, 102 + g, 5, 100);
        else if (level == 0)        baseAmount = randRange(globalIdx, 102 + g, 25, 999);
        else if (level == 1)        baseAmount = randRange(globalIdx, 102 + g, 100, 5000);
        else                        baseAmount = randRange(globalIdx, 102 + g, 500, 50000);
        baseAmount = roundTo5(baseAmount);
        if (baseAmount < 5) baseAmount = 5;

        Integer daysBack = lapsed
            ? randInt(globalIdx, 103 + g, 365, 365 * GIFT_HISTORY_YEARS)
            : randInt(globalIdx, 103 + g, 0, 365 * GIFT_HISTORY_YEARS);
        Date txnDate = Date.today().addDays(-daysBack);

        Integer statusRoll = Math.mod(prng(globalIdx, 104 + g), 100);
        String status = (statusRoll < 90) ? 'Paid'
                     : (statusRoll < 95) ? 'Pending'
                     : (statusRoll < 98) ? 'Failed' : 'Unpaid';
        Boolean isPaid = (status == 'Paid');

        String paymentMethod = pickOne(globalIdx, 105 + g, new List<String>{'Credit Card','ACH','Check','Credit Card','Credit Card'});
        Boolean donorCoversFees = (paymentMethod != 'Check') && randBool(globalIdx, 106 + g, PROB_DONOR_COVERS_FEES);
        List<Decimal> feeBreakdown = computeFees(baseAmount, paymentMethod, donorCoversFees);
        Decimal originalAmount = feeBreakdown[0];
        Decimal gatewayFee     = feeBreakdown[1];
        Decimal processorFee   = feeBreakdown[2];
        Decimal donorCover     = feeBreakdown[3];

        Id chosenOscId = allOscIds[Math.mod(prng(globalIdx, 107 + g), allOscIds.size())];
        Id chosenCampaignId = oscToCampaign.get(chosenOscId);

        Integer scenario = 0;
        if (isEligibleForMatch) {
            Integer sRoll = Math.mod(prng(globalIdx, 602 + g), 100);
            if (sRoll < MATCH_ROLL_PLEDGE_MAX && cat == 'Pledge Payment' && isPaid) scenario = 1;
            else if (sRoll < MATCH_ROLL_OUTRIGHT_MAX && cat == 'Outright Gift' && isPaid) scenario = 2;
            else if (sRoll < MATCH_ROLL_PENDING_MAX && (cat == 'Outright Gift' || cat == 'Pledge Payment')) scenario = 3;
            else scenario = 4;
        }

        GiftTransaction gt = new GiftTransaction(
            FQS_External_Id__c = 'FQS-GT-' + globalIdx + '-' + g,
            Name = 'FQS GT #' + globalIdx + '-' + g,
            DonorId = newAccounts[i].Id,
            OriginalAmount = originalAmount,
            GatewayTransactionFee = gatewayFee,
            ProcessorTransactionFee = processorFee,
            DonorCoverAmount = donorCover,
            TransactionDate = txnDate,
            TransactionDueDate = isPaid ? txnDate : txnDate.addDays(30),
            Status = status,
            GiftType = donorTypes[i] == 0 ? 'Individual' : 'Organizational',
            PaymentMethod = paymentMethod,
            FQS_Gift_Transaction_Category__c = cat,
            CampaignId = chosenCampaignId,
            OutreachSourceCodeId = chosenOscId
        );

        if (cat == 'Pledge Payment' && hasPledge) {
            gt.GiftCommitmentId = pledgedCommitmentByDonor.get(i)[0];
        } else if (cat == 'Pledge Payment' && hasRecurring) {
            gt.GiftCommitmentId = recurringCommitmentByDonor.get(i)[0];
            gt.FQS_Recurring__c = true;
        } else if (cat == 'Grant Payment' && hasGrant) {
            gt.GiftCommitmentId = grantCommitmentByDonor.get(i)[0];
        }
        gt.FQS_In_Kind__c = randBool(globalIdx, 108 + g, PROB_INKIND);
        if (scenario == 1 || scenario == 2 || scenario == 3) {
            gt.FQS_Matched__c = true;
        } else {
            gt.FQS_Matched__c = (donorTypes[i] == 0 && !isEligibleForMatch && randBool(globalIdx, 109 + g, 0.08));
        }

        newGifts.add(gt);
        giftDonorIdx.add(i);
        giftIndexInDonor.add(g);
        giftIsPaid.add(isPaid);
        giftCategory.add(cat);
        giftMatchScenario.add(scenario);
    }
}
insert newGifts;

// ============ CORPORATE-SIDE MATCHING GIFTS ============
List<GiftTransaction> corpMatchGifts = new List<GiftTransaction>();
for (Integer i = 0; i < newGifts.size(); i++) {
    Integer scenario = giftMatchScenario[i];
    if (scenario != 1 && scenario != 2) continue;
    Integer di = giftDonorIdx[i];
    Integer g = giftIndexInDonor[i];
    Integer globalIdx = BATCH_OFFSET + di;
    Integer empIdx = employerIdxByDonor[di];
    if (empIdx < 0) continue;  // safety
    Id employerId = corpEmployers[empIdx].Id;

    Decimal empGiftAmount = newGifts[i].OriginalAmount;
    Decimal matchPct = randBool(globalIdx, 700 + g, 0.5) ? 1.0 : 0.5;
    Decimal matchAmount = roundTo5(empGiftAmount * matchPct);
    if (matchAmount < 5) matchAmount = 5;

    Date empTxnDate = newGifts[i].TransactionDate;
    Date corpTxnDate = empTxnDate.addDays(randInt(globalIdx, 701 + g, 15, 45));

    corpMatchGifts.add(new GiftTransaction(
        FQS_External_Id__c = 'FQS-GT-CORP-' + globalIdx + '-' + g,
        Name = 'FQS Corp Match #' + globalIdx + '-' + g,
        DonorId = employerId,
        MatchingEmployerTransactionId = newGifts[i].Id,
        OriginalAmount = matchAmount,
        GatewayTransactionFee = 0,
        ProcessorTransactionFee = 0,
        DonorCoverAmount = 0,
        TransactionDate = corpTxnDate,
        TransactionDueDate = corpTxnDate,
        Status = 'Paid',
        GiftType = 'Organizational',
        PaymentMethod = 'Check',
        FQS_Gift_Transaction_Category__c = 'Outright Gift',
        CampaignId = corpMatchCampaignId,
        FQS_Matched__c = true
    ));
}
if (!corpMatchGifts.isEmpty()) insert corpMatchGifts;

// ============ GIFT TRANSACTION DESIGNATIONS ============
List<GiftTransactionDesignation> newGTDs = new List<GiftTransactionDesignation>();
for (Integer i = 0; i < newGifts.size(); i++) {
    GiftTransaction gt = newGifts[i];
    Integer di = giftDonorIdx[i];
    Integer g = giftIndexInDonor[i];
    Integer globalIdx = BATCH_OFFSET + di;
    newGTDs.add(new GiftTransactionDesignation(
        FQS_External_Id__c = 'FQS-GTD-' + globalIdx + '-' + g,
        GiftTransactionId = gt.Id,
        GiftDesignationId = allDesignationIds[Math.mod(prng(globalIdx, 200 + i), allDesignationIds.size())],
        Amount = gt.OriginalAmount,
        Percent = 100));
}
insert newGTDs;

// ============ GIFT SOFT CREDITS ============
List<GiftSoftCredit> newSoftCredits = new List<GiftSoftCredit>();
List<String> softCreditRoles = new List<String>{'Solicitor','Matched Donor','Honoree','Household Member'};
for (Integer i = 0; i < newGifts.size(); i++) {
    Integer di = giftDonorIdx[i];
    Integer g = giftIndexInDonor[i];
    Integer globalIdx = BATCH_OFFSET + di;
    if (!randBool(globalIdx, 300 + i, PROB_SOFT_CREDIT)) continue;
    Integer recipIdx = Math.mod(prng(globalIdx, 301 + i), DONOR_COUNT);
    if (recipIdx == di) recipIdx = Math.mod(recipIdx + 1, DONOR_COUNT);
    newSoftCredits.add(new GiftSoftCredit(
        FQS_External_Id__c = 'FQS-GSC-' + globalIdx + '-' + g + '-' + recipIdx,
        GiftTransactionId = newGifts[i].Id,
        RecipientId = newAccounts[recipIdx].Id,
        Role = softCreditRoles[Math.mod(prng(globalIdx, 302 + i), softCreditRoles.size())],
        PartialPercent = 100));
}
if (!newSoftCredits.isEmpty()) insert newSoftCredits;

// ============ GIFT TRIBUTES ============
List<GiftTribute> newTributes = new List<GiftTribute>();
List<String> tributeFirstNames = new List<String>{'Margaret','Elizabeth','Charles','Robert','Frank','Dorothy','Helen','George','Ruth','Walter'};
for (Integer i = 0; i < newGifts.size(); i++) {
    Integer di = giftDonorIdx[i];
    Integer g = giftIndexInDonor[i];
    Integer globalIdx = BATCH_OFFSET + di;
    if (!randBool(globalIdx, 400 + i, PROB_TRIBUTE)) continue;
    Boolean isMemorial = randBool(globalIdx, 401 + i, 0.30);
    String honoree = tributeFirstNames[Math.mod(prng(globalIdx, 402 + i), tributeFirstNames.size())]
        + ' ' + lastNames[Math.mod(prng(globalIdx, 403 + i), lastNames.size())];
    newTributes.add(new GiftTribute(
        FQS_External_Id__c = 'FQS-GTR-' + globalIdx + '-' + g,
        TributeType = isMemorial ? 'Memorial' : 'Honor',
        HonoreeName = honoree,
        GiftTransactionId = newGifts[i].Id,
        NotificationChannel = randBool(globalIdx, 404 + i, 0.6) ? 'Email' : 'Mail',
        NotificationStatus = randBool(globalIdx, 405 + i, 0.5) ? 'Sent' : 'To Be Sent'));
}
if (!newTributes.isEmpty()) insert newTributes;

// ============ GIFT REFUNDS ============
List<GiftRefund> newRefunds = new List<GiftRefund>();
List<String> refundStatuses = new List<String>{'Initiated','Completed','Completed','Failed'};
List<String> refundReasons = new List<String>{'Donor Request','Incorrect Amount'};
for (Integer i = 0; i < newGifts.size(); i++) {
    if (!giftIsPaid[i]) continue;
    Integer di = giftDonorIdx[i];
    Integer g = giftIndexInDonor[i];
    Integer globalIdx = BATCH_OFFSET + di;
    if (!randBool(globalIdx, 500 + i, PROB_REFUND)) continue;
    Decimal refundAmt = newGifts[i].OriginalAmount * randRange(globalIdx, 501 + i, 0.5, 1.0);
    newRefunds.add(new GiftRefund(
        FQS_External_Id__c = 'FQS-GR-' + globalIdx + '-' + g,
        GiftTransactionId = newGifts[i].Id,
        Amount = refundAmt.setScale(2),
        Date = newGifts[i].TransactionDate.addDays(randInt(globalIdx, 502 + i, 1, 60)),
        Status = refundStatuses[Math.mod(prng(globalIdx, 503 + i), refundStatuses.size())],
        Reason = refundReasons[Math.mod(prng(globalIdx, 504 + i), refundReasons.size())]));
}
if (!newRefunds.isEmpty()) insert newRefunds;

Integer total = newAccounts.size() + newCommitments.size() + newSchedules.size()
    + newOpps.size() + newPIs.size() + newGifts.size() + corpMatchGifts.size()
    + newGTDs.size() + newSoftCredits.size() + newTributes.size() + newRefunds.size();
System.debug('=== Chunk complete (offset ' + BATCH_OFFSET + '): ' + total + ' records ('
    + 'accounts=' + newAccounts.size()
    + ', commits=' + newCommitments.size()
    + ', scheds=' + newSchedules.size()
    + ', opps=' + newOpps.size()
    + ', PIs=' + newPIs.size()
    + ', GTs=' + newGifts.size()
    + ', corpGTs=' + corpMatchGifts.size()
    + ', GTDs=' + newGTDs.size()
    + ', SCs=' + newSoftCredits.size()
    + ', tribs=' + newTributes.size()
    + ', refunds=' + newRefunds.size()
    + ') ===');
