/**
 * FQS Seed Generator.
 *
 * Backs the anonymous-Apex seed scripts (fqs-seed-small/medium/chunk.apex) so those
 * files stay under the 32K anonymous cap and can layer new features without character
 * budgeting. Also feeds shared PRNG helpers to fqs-seed-matching-gift-scenarios.apex.
 *
 * Amount bands per donor level are derived from FQS_Donor_Grouping__mdt at run time
 * (see AmountBands.deriveFromCmt) — the seed always produces donors whose gift totals
 * classify at each Grouping_Key__c per the live app config. Two hard clamps override
 * the CMT: Entry floor stays >= $25 (so we never emit sub-$25 gifts even if the CMT
 * threshold is zero) and Major ceiling is bounded to 2x the Major threshold (large
 * outliers add noise without informing tests).
 *
 * Knobs (probabilities, pyramid split, history years) live as public static fields on
 * this class so anonymous scripts can still tweak them at the top before invocation:
 *
 *     FQSSeedGenerator.PROB_LAPSED = 1.0;
 *     FQSSeedGenerator.seedChunk(100, 0);
 */
public with sharing class FQSSeedGenerator {

    // ============ Public knobs (mutable so anonymous scripts can override) ============
    public static Integer PYRAMID_ENTRY_PCT              = 70;
    public static Integer PYRAMID_MID_PCT                = 25;
    public static Integer PROB_INDIV_PCT                 = 75;
    public static Integer PROB_MAJOR_ORG_PCT             = 40;
    public static Decimal PROB_RECURRING                 = 0.35;
    public static Decimal PROB_PLEDGED_MIDPLUS           = 0.40;
    public static Decimal PROB_GRANT_MAJORORG            = 0.60;
    public static Decimal PROB_LAPSED                    = 0.15;
    public static Decimal PROB_SOFT_CREDIT               = 0.15;
    public static Decimal PROB_TRIBUTE                   = 0.10;
    public static Decimal PROB_REFUND                    = 0.03;
    public static Decimal PROB_INKIND                    = 0.0005;
    public static Decimal PROB_EMPLOYER_MATCH_ELIGIBLE   = 0.30;
    // Populates GiftCommitment.FQS_Match_Eligible__c. Roughly parity with the FQS_Matched__c
    // distribution on transactions — see .planning/fqs-gift-entry-wizard-plan.md §Matching-gift branch.
    // Deterministic PRNG salts: 27 (recurring), 37 (pledged), 47 (grant) — next unused
    // salt integers past the existing 20-26 / 30-35 / 40-44 clusters in each commitment build.
    public static Decimal PROB_COMMITMENT_MATCH_ELIGIBLE = 0.20;
    public static Decimal PROB_DONOR_COVERS_FEES         = 0.35;
    public static Decimal PROB_CONDITIONAL_NONGRANT      = 0.30;   // §12.2 — Conditional share of recurring + pledged
    public static Decimal PROB_BENEFIT_INCLUSION         = 0.10;   // §13.2 — "gala ticket includes dinner" — 15% NTD subset
    public static Integer GIFT_HISTORY_YEARS             = 3;
    public static Integer MATCH_ROLL_PLEDGE_MAX          = 30;
    public static Integer MATCH_ROLL_OUTRIGHT_MAX        = 70;
    public static Integer MATCH_ROLL_PENDING_MAX         = 85;
    // §13.1 — Status weights for recurring commitments only (Active / Failing / Lapsed / Paused).
    // Pledged + Grant commitments stay Active — no domain reason to distribute them.
    // Note: Paused weight is set to 0 because the real "paused" shape produced by managed
    // frops_flow__PauseResumeSchedule (existing GCS truncated + PauseTransactions row + resume-tail
    // CreateTransactions row) fights with the platform's gift-transaction aggregation trigger
    // during seed inserts — the aggregation flips GC.CurrentGiftCmtScheduleId to whatever row
    // is currently "live" (the pause row), then the aggregation itself rejects the flip
    // because PauseTransactions isn't a valid current-schedule type. To exercise the router's
    // RECURRING_PAUSED branch, run the Pause action from the router flow on any seeded
    // Active-status recurring GC — that creates the pause shape via the managed subflow
    // itself, matching production behavior exactly.
    public static List<Integer> RECURRING_STATUS_WEIGHTS = new List<Integer>{80, 10, 10, 0};

    // Hard clamps applied on top of CMT-derived amount bands.
    public static Decimal ENTRY_MIN_FLOOR   = 25;
    public static Decimal MAJOR_MAX_RATIO   = 2.0;   // Major upper = MajorThreshold * ratio

    // ============ PRNG (public so the enhancer script can reuse) ============
    public static Integer prng(Integer seed, Integer salt) {
        Integer h = (seed * 2654 + salt * 4361) & 2147483647;
        h = ((h ^ (h >>> 13)) * 1103515245 & 2147483647);
        h = h ^ (h >>> 15);
        return Math.abs(h);
    }
    public static Decimal randRange(Integer seed, Integer salt, Decimal minVal, Decimal maxVal) {
        Integer r = prng(seed, salt);
        Decimal frac = Math.mod(r, 10000) / 10000.0;
        return minVal + (maxVal - minVal) * frac;
    }
    public static Integer randInt(Integer seed, Integer salt, Integer minVal, Integer maxVal) {
        return minVal + Math.mod(prng(seed, salt), (maxVal - minVal + 1));
    }
    public static Boolean randBool(Integer seed, Integer salt, Decimal probability) {
        return randRange(seed, salt, 0, 1) < probability;
    }
    public static String pickOne(Integer seed, Integer salt, List<String> options) {
        return options[Math.mod(prng(seed, salt), options.size())];
    }

    public static Decimal roundTo5(Decimal amount) {
        return ((amount / 5).round(System.RoundingMode.HALF_UP)) * 5;
    }

    // §14 — Pick a pledge/grant timing window from a 40/40/20 mix:
    //   'past'    → firstPmt + endDate both in the past (fully-fulfilled commitment history)
    //   'mid'     → firstPmt in past, endDate in future (mid-flight — most common state IRL)
    //   'future'  → firstPmt + endDate both in future (signed but no payments yet)
    // Recurring commitments (OpenEnded) skip this — they have no signing event.
    public static String pickTimingWindow(Integer seed, Integer salt) {
        Integer roll = Math.mod(prng(seed, salt), 100);
        if (roll < 40) return 'past';
        if (roll < 80) return 'mid';
        return 'future';
    }

    // §13.1 — Pick a recurring GiftCommitment.Status from RECURRING_STATUS_WEIGHTS.
    // Weights map to ['Active', 'Failing', 'Lapsed', 'Paused'] in that order.
    public static String pickRecurringStatus(Integer seed, Integer salt) {
        List<String> statuses = new List<String>{'Active', 'Failing', 'Lapsed', 'Paused'};
        Integer total = 0;
        for (Integer w : RECURRING_STATUS_WEIGHTS) total += w;
        if (total <= 0) return 'Active';
        Integer roll = Math.mod(prng(seed, salt), total);
        Integer cumulative = 0;
        for (Integer i = 0; i < RECURRING_STATUS_WEIGHTS.size() && i < statuses.size(); i++) {
            cumulative += RECURRING_STATUS_WEIGHTS[i];
            if (roll < cumulative) return statuses[i];
        }
        return 'Active';
    }

    // Human-readable donor label used in GC/GT/Opp Name fields.
    // Person Accounts: "First LastName FQS #N"; Org accounts: "Prefix Suffix FQS #N".
    public static String donorLabel(Account a) {
        if (a.Name != null) return a.Name;
        String fn = (a.FirstName != null) ? a.FirstName : '';
        String ln = (a.LastName != null) ? a.LastName : '';
        return (fn + ' ' + ln).trim();
    }

    // Compact amount formatter for record Names — integer if whole, 2 decimals if not.
    public static String fmtAmt(Decimal amt) {
        if (amt == null) return '$0';
        return (amt == amt.round()) ? '$' + amt.longValue() : '$' + amt.setScale(2);
    }

    // ============ Amount bands (CMT-derived) ============
    // One band per Grouping_Key. Per-gift base amount is drawn from these ranges before
    // fee/donor-cover math is applied. Recurring commitments derive their monthly amount
    // from the same CMT annual thresholds (annual / 12) so recurring donors classify
    // correctly per FQS_Donor_Grouping__mdt.
    public class AmountBands {
        public Decimal entryMin;   public Decimal entryMax;
        public Decimal midMin;     public Decimal midMax;
        public Decimal majorMin;   public Decimal majorMax;
        public Decimal recurEntryMin;   public Decimal recurEntryMax;
        public Decimal recurMidMin;     public Decimal recurMidMax;
        public Decimal recurMajorMin;   public Decimal recurMajorMax;
        public String  entryLabel;
        public String  midLabel;
        public String  majorLabel;
    }

    public static AmountBands deriveBandsFromCmt() {
        Map<String, FQS_Donor_Grouping__mdt> byKey = new Map<String, FQS_Donor_Grouping__mdt>();
        for (FQS_Donor_Grouping__mdt r : [
            SELECT Grouping_Key__c, Branded_Name__c,
                   One_Time_Min_Amount__c, Annual_Min_Amount__c, Lifetime_Min_Amount__c
            FROM FQS_Donor_Grouping__mdt
        ]) {
            if (r.Grouping_Key__c != null) byKey.put(r.Grouping_Key__c, r);
        }
        FQS_Donor_Grouping__mdt entry = byKey.get('Entry');
        FQS_Donor_Grouping__mdt mid   = byKey.get('Mid');
        FQS_Donor_Grouping__mdt major = byKey.get('Major');
        System.assert(entry != null, 'FQS_Donor_Grouping__mdt "Entry" record missing');
        System.assert(mid   != null, 'FQS_Donor_Grouping__mdt "Mid" record missing');
        System.assert(major != null, 'FQS_Donor_Grouping__mdt "Major" record missing');

        Decimal entryFloor = ENTRY_MIN_FLOOR;
        Decimal midThreshold   = (mid.One_Time_Min_Amount__c   != null) ? mid.One_Time_Min_Amount__c   : 500;
        Decimal majorThreshold = (major.One_Time_Min_Amount__c != null) ? major.One_Time_Min_Amount__c : 5000;
        Decimal entryCmtMin    = (entry.One_Time_Min_Amount__c != null) ? entry.One_Time_Min_Amount__c : 0;

        AmountBands b = new AmountBands();
        // Per-gift base amounts.
        b.entryMin = Math.max(entryFloor, entryCmtMin);
        b.entryMax = midThreshold - 5;
        b.midMin   = midThreshold;
        b.midMax   = majorThreshold - 5;
        b.majorMin = majorThreshold;
        b.majorMax = majorThreshold * MAJOR_MAX_RATIO;

        // Recurring monthly amounts. Derive from Annual thresholds / 12 so the yearly
        // total lands squarely within the target grouping.
        Decimal midAnnual   = (mid.Annual_Min_Amount__c   != null) ? mid.Annual_Min_Amount__c   : 1000;
        Decimal majorAnnual = (major.Annual_Min_Amount__c != null) ? major.Annual_Min_Amount__c : 10000;
        b.recurEntryMin = 10;
        b.recurEntryMax = Math.max(15, (midAnnual / 12) - 5);
        b.recurMidMin   = midAnnual / 12;
        b.recurMidMax   = Math.max(b.recurMidMin + 10, (majorAnnual / 12) - 5);
        b.recurMajorMin = majorAnnual / 12;
        b.recurMajorMax = b.recurMajorMin * MAJOR_MAX_RATIO;

        b.entryLabel = (entry.Branded_Name__c != null) ? entry.Branded_Name__c : 'Entry';
        b.midLabel   = (mid.Branded_Name__c   != null) ? mid.Branded_Name__c   : 'Mid';
        b.majorLabel = (major.Branded_Name__c != null) ? major.Branded_Name__c : 'Major';
        return b;
    }

    // ============ Fee model ============
    public static List<Decimal> computeFees(Decimal baseAmountRoundedTo5, String paymentMethod, Boolean donorCoversFees) {
        Decimal gatewayPct;
        Decimal gatewayFlat;
        if (paymentMethod == 'Credit Card') { gatewayPct = 0.022; gatewayFlat = 0.30; }
        else if (paymentMethod == 'ACH')    { gatewayPct = 0.008; gatewayFlat = 0.00; }
        else if (paymentMethod == 'PayPal') { gatewayPct = 0.029; gatewayFlat = 0.49; }
        else                                { gatewayPct = 0.000; gatewayFlat = 0.00; }  // Check / In-Kind
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

    // ============ Main entry point ============
    // Run stamp — prefixes every seeded record's External_Id to sidestep unique-index collisions
    // from prior seed runs whose records have been hard-deleted (past 15-day recycle bin window,
    // not visible in ALL ROWS but still holding External_Id uniqueness). Anonymous scripts can
    // override before invocation for deterministic Ids; default is System.currentTimeMillis().
    public static String RUN_STAMP;

    public static void seedChunk(Integer donorCount, Integer batchOffset) {
        System.debug('=== FQS Seed Chunk: ' + donorCount + ' donors, offset ' + batchOffset + ' ===');
        if (RUN_STAMP == null) RUN_STAMP = String.valueOf(System.currentTimeMillis());
        System.debug('Run stamp: ' + RUN_STAMP);

        AmountBands bands = deriveBandsFromCmt();
        System.debug('Amount bands (CMT-derived): '
            + bands.entryLabel + ' $' + bands.entryMin + '-$' + bands.entryMax + ' | '
            + bands.midLabel   + ' $' + bands.midMin   + '-$' + bands.midMax   + ' | '
            + bands.majorLabel + ' $' + bands.majorMin + '-$' + bands.majorMax);

        Id personAccountRT = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName='PersonAccount' LIMIT 1].Id;
        Id oppGrantRT      = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' AND DeveloperName='Grant' LIMIT 1].Id;
        Id oppMajorGiftRT  = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' AND DeveloperName='Major_Gift' LIMIT 1].Id;

        List<Campaign> campaigns = [SELECT Id, FQS_Campaign_Category__c, External_Id__c, StartDate, EndDate FROM Campaign WHERE External_Id__c LIKE 'FQS-CMP-%'];
        List<GiftDesignation> designations = [SELECT Id, FQS_Restriction_Type__c FROM GiftDesignation WHERE External_Id__c LIKE 'FQS-GD-%'];
        List<OutreachSourceCode> outreachCodes = [SELECT Id, MessageChannel, CampaignId FROM OutreachSourceCode WHERE External_Id__c LIKE 'FQS-OSC-%'];
        List<Account> corpEmployers = [SELECT Id, Name, External_Id__c FROM Account WHERE External_Id__c LIKE 'FQS-ACC-CORP-%' ORDER BY External_Id__c];

        System.assert(campaigns.size() > 0,     'No FQS campaigns — run fqs-seed-foundation.apex first');
        System.assert(designations.size() > 0,  'No FQS designations — run fqs-seed-foundation.apex first');
        System.assert(corpEmployers.size() > 0, 'No FQS corporate employers — run fqs-seed-foundation.apex first');
        // OSCs are optional. When foundation was run with SKIP_OSCS=true, GTs fall back to
        // an ask-campaign assignment (no OutreachSourceCodeId), which the ack flow doesn't
        // care about anyway. Kept as an info log so it surfaces in seed debug output.
        if (outreachCodes.isEmpty()) System.debug('No FQS OSCs found — assigning GTs to ask campaigns directly (no OutreachSourceCodeId).');

        // Bucket asks by FY (26/25/24). Gifts assign strictly by TransactionDate FY window
        // so historical gifts land on the correct fiscal-year ask.
        Map<Integer, List<Id>> askIdsByFY = new Map<Integer, List<Id>>{26 => new List<Id>(), 25 => new List<Id>(), 24 => new List<Id>()};
        Map<Integer, Id> yearendAskByFY = new Map<Integer, Id>();  // corp-match target per FY
        Map<String, List<Id>> asksByCategory = new Map<String, List<Id>>();
        for (Campaign c : campaigns) {
            if (c.External_Id__c == null) continue;
            if (c.External_Id__c.startsWith('FQS-CMP-ASK-')) {
                Integer fy = 26;
                if (c.External_Id__c.endsWith('-FY25')) fy = 25;
                else if (c.External_Id__c.endsWith('-FY24')) fy = 24;
                askIdsByFY.get(fy).add(c.Id);
                if (c.External_Id__c.startsWith('FQS-CMP-ASK-YEAREND-EM-')) yearendAskByFY.put(fy, c.Id);
                if (!asksByCategory.containsKey(c.FQS_Campaign_Category__c)) asksByCategory.put(c.FQS_Campaign_Category__c, new List<Id>());
                asksByCategory.get(c.FQS_Campaign_Category__c).add(c.Id);
            }
        }
        System.assert(!askIdsByFY.get(26).isEmpty(), 'No FY26 ask campaigns found — check foundation script ran');
        // FY25/24 pools may be small; fall back to FY26 when empty so seeding never blocks.
        for (Integer fy : new List<Integer>{25, 24}) {
            if (askIdsByFY.get(fy).isEmpty()) askIdsByFY.put(fy, askIdsByFY.get(26));
            if (!yearendAskByFY.containsKey(fy)) yearendAskByFY.put(fy, yearendAskByFY.get(26));
        }
        if (!yearendAskByFY.containsKey(26)) yearendAskByFY.put(26, askIdsByFY.get(26)[0]);

        // Precompute FY boundaries from Organization for TransactionDate → FY resolution.
        Integer fyStartMonth = [SELECT FiscalYearStartMonth FROM Organization LIMIT 1].FiscalYearStartMonth;
        Date genFy26Start = (Date.today().month() >= fyStartMonth)
            ? Date.newInstance(Date.today().year(),     fyStartMonth, 1)
            : Date.newInstance(Date.today().year() - 1, fyStartMonth, 1);
        Date genFy25Start = genFy26Start.addMonths(-12);
        Date genFy24Start = genFy26Start.addMonths(-24);

        List<Id> allAskCampaignIds = new List<Id>();
        allAskCampaignIds.addAll(askIdsByFY.get(26));
        allAskCampaignIds.addAll(askIdsByFY.get(25));
        allAskCampaignIds.addAll(askIdsByFY.get(24));

        // allDesignationIds = designations valid for contribution-type GTs (everything except Earned Revenue).
        // feeDesignationIds  = designations for exchange-transaction revenue only; consumed for Fee/Payment GTDs.
        // Segregating the two pools keeps earned revenue out of contribution-restriction rollups and vice versa.
        List<Id> allDesignationIds = new List<Id>();
        List<Id> restrictedDesignationIds = new List<Id>();
        List<Id> feeDesignationIds = new List<Id>();
        for (GiftDesignation gd : designations) {
            if ('Earned Revenue'.equals(gd.FQS_Restriction_Type__c)) {
                feeDesignationIds.add(gd.Id);
                continue;
            }
            allDesignationIds.add(gd.Id);
            if (gd.FQS_Restriction_Type__c != null && gd.FQS_Restriction_Type__c.startsWith('With Donor Restriction')) {
                restrictedDesignationIds.add(gd.Id);
            }
        }
        List<Id> allOscIds = new List<Id>();
        Map<Id, Id> oscToCampaign = new Map<Id, Id>();
        for (OutreachSourceCode o : outreachCodes) { allOscIds.add(o.Id); oscToCampaign.put(o.Id, o.CampaignId); }

        Integer corpCount = corpEmployers.size();

        List<String> firstNames = new List<String>{'Sarah','Michael','Jennifer','David','Emily','Robert','Jessica','William','Ashley','James','Amanda','Christopher','Melissa','Daniel','Nicole','Matthew','Stephanie','Joshua','Rachel','Andrew','Lauren','Ryan','Megan','John','Kimberly','Brandon','Amy','Jason','Amber','Kevin','Angela','Justin','Heather','Tyler','Rebecca','Aaron','Michelle','Adam','Danielle','Nathan','Christina','Anthony','Kayla','Eric','Erin','Steven','Samantha','Timothy','Katherine','Thomas','Riley','Priya','Aiden','Zara','Marcus','Elena','Diego','Anika','Jamal','Sofia','Wei','Fatima','Kai','Mei','Omar','Yuki','Aditi','Chen','Aisha','Rohan'};
        List<String> lastNames = new List<String>{'Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin','Lee','Perez','Thompson','White','Harris','Sanchez','Clark','Ramirez','Lewis','Robinson','Walker','Young','Allen','King','Wright','Scott','Torres','Nguyen','Hill','Flores','Green','Adams','Nelson','Baker','Hall','Rivera','Campbell','Mitchell','Carter','Roberts','Chen','Patel','Kim','Wang','Singh','Kumar','Cohen','Reddy','Okafor','Nakamura'};
        List<String> orgSuffixes = new List<String>{'Foundation','Community Fund','Family Foundation','Trust','Charitable Trust','Charities','Nonprofit Group','Endowment','Legacy Fund','Giving Circle','Family Trust','Corporation','Enterprises','Ventures','Holdings','Partners','Society','Alliance'};
        List<String> orgPrefixes = new List<String>{'Riverside','Northgate','Sunrise','Mountain View','Cedar Hills','Bayside','Oakwood','Silverlake','Harbor','Meadowbrook','Pinecrest','Fairmont','Highland','Wellspring','Westside','Eastwood','Legacy','Beacon','Cornerstone','Horizon','Summit','Evergreen','Brightpath','Cascade'};

        List<Account> newAccounts = new List<Account>();
        List<Integer> donorTypes = new List<Integer>();
        List<Integer> donorLevels = new List<Integer>();
        List<Boolean> lapsedFlags = new List<Boolean>();
        List<Boolean> employerEligible = new List<Boolean>();
        List<Integer> employerIdxByDonor = new List<Integer>();

        for (Integer i = 0; i < donorCount; i++) {
            Integer globalIdx = batchOffset + i;
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
            a.External_Id__c = 'FQS-ACC-' + RUN_STAMP + '-' + globalIdx;
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

        // Phase G4: PartyRelationshipGroup per Org donor only (Type='Group'). Person Accounts
        // do NOT get a PRG — the Person Account IS the household, and inserting a second
        // Type='Household' PRG anchored at the same Account is redundant. The launcher's
        // household-vs-employer picker uses ACRs (employer path) and PersonContact (household
        // path); it does not depend on a Type='Household' PRG existing on the Person Account.
        List<PartyRelationshipGroup> donorPrgs = new List<PartyRelationshipGroup>();
        for (Integer i = 0; i < donorCount; i++) {
            if (donorTypes[i] == 0) continue;  // skip Person Accounts
            donorPrgs.add(new PartyRelationshipGroup(
                AccountId = newAccounts[i].Id,
                Name = newAccounts[i].Name,
                Type = 'Group'));
        }
        if (!donorPrgs.isEmpty()) insert donorPrgs;

        // GC Name conventions:
        //   Recurring (OpenEnded)   → "<Donor> - $<amt> Monthly"           (amt = the monthly commitment)
        //   Pledged  (FixedLength)  → "<Donor> - $<total> over N years"    (total = full pledge amount)
        //   Grant    (FixedLength)  → "<Donor> - $<total> over N years"    (total = full grant amount)
        // Recurring uses "monthly amount" (finding a $50/mo donor scans on that), pledged/grant uses
        // total + duration (that's the natural scope of a fixed commitment). All fields are on GC.
        List<GiftCommitment> newCommitments = new List<GiftCommitment>();
        List<Integer> commitmentDonorIdx = new List<Integer>();
        List<String> commitmentKind = new List<String>();
        List<Boolean> commitmentIsConditional = new List<Boolean>();  // §12.2 — drives GiftDefaultDesignation seeding
        // First-payment date per commitment. For pledged + grant-* it diverges from
        // GC.EffectiveStartDate (pledge-signed) by 30-180 days — models real "signed
        // now, first check clears next month" behavior. GCS.StartDate + first GT.TransactionDate
        // anchor here (payment start), while EffectiveStartDate anchors at the signing event.
        // Recurring skips the split (open-ended donor commitments have no signing event).
        List<Date> commitmentFirstPaymentDate = new List<Date>();
        // Irregular installment ladder for grant-custom shape only (empty lists for all other kinds).
        // Populated in the grant block below; consumed by the schedule builder + ladder walker + back-fill.
        List<List<Date>> commitmentCustomInstDates = new List<List<Date>>();
        List<List<Decimal>> commitmentCustomInstAmounts = new List<List<Decimal>>();
        for (Integer i = 0; i < donorCount; i++) {
            Integer level = donorLevels[i];
            Integer donorType = donorTypes[i];
            Id donorId = newAccounts[i].Id;
            String dLabel = donorLabel(newAccounts[i]);
            Integer globalIdx = batchOffset + i;
            if (randBool(globalIdx, 20, PROB_RECURRING)) {
                Decimal amt;
                if (level == 0)      amt = randRange(globalIdx, 21, bands.recurEntryMin, bands.recurEntryMax);
                else if (level == 1) amt = randRange(globalIdx, 21, bands.recurMidMin,   bands.recurMidMax);
                else                 amt = randRange(globalIdx, 21, bands.recurMajorMin, bands.recurMajorMax);
                amt = roundTo5(amt);
                if (amt < 5) amt = 5;
                Date startDate = Date.today().addMonths(-randInt(globalIdx, 22, 6, 30));
                Boolean isCond = randBool(globalIdx, 24, PROB_CONDITIONAL_NONGRANT);
                // §13.1 — recurring commitments distribute across Active/Failing/Lapsed/Paused
                // so the launcher's Get_Active_Commitments filter has coverage on every branch.
                String recurStatus = pickRecurringStatus(globalIdx, 25);
                newCommitments.add(new GiftCommitment(
                    External_Id__c = 'FQS-GC-' + RUN_STAMP + '-' + globalIdx + '-recurring',
                    Name = dLabel + ' - ' + fmtAmt(amt) + ' Monthly',
                    DonorId = donorId, Status = recurStatus,
                    FulfillmentType = isCond ? 'Conditional' : 'Unconditional', RecurrenceType = 'OpenEnded',
                    FQS_Gift_Commitment_Category__c = 'Recurring Gift',
                    ExpectedTotalCmtAmount = amt.setScale(2),
                    EffectiveStartDate = startDate,
                    FQS_Match_Eligible__c = randBool(globalIdx, 27, PROB_COMMITMENT_MATCH_ELIGIBLE),
                    CampaignId = allAskCampaignIds[Math.mod(prng(globalIdx, 23), allAskCampaignIds.size())]));
                commitmentDonorIdx.add(i); commitmentKind.add('recurring'); commitmentIsConditional.add(isCond);
                commitmentFirstPaymentDate.add(startDate);  // Recurring: no signing offset — first pmt = EffectiveStartDate
                commitmentCustomInstDates.add(new List<Date>());
                commitmentCustomInstAmounts.add(new List<Decimal>());
            }
            if (level >= 1 && randBool(globalIdx, 30, PROB_PLEDGED_MIDPLUS)) {
                Decimal totalAmt = roundTo5((level == 1) ? randRange(globalIdx, 31, 2500, 15000) : randRange(globalIdx, 31, 25000, 75000));
                Boolean isCond = randBool(globalIdx, 35, PROB_CONDITIONAL_NONGRANT);
                // §14 — 40/40/20 timing window governs firstPmt placement; pledge-signed date
                // = firstPmt - 30..180 days (signing offset). Duration = 1..5 years from firstPmt.
                String tWindow = pickTimingWindow(globalIdx, 57);
                Integer years = randInt(globalIdx, 33, 1, 5);
                Date firstPmt;
                if (tWindow == 'past') {
                    Integer pastMonths = years * 12 + randInt(globalIdx, 32, 1, 6);
                    firstPmt = Date.today().addMonths(-pastMonths);
                } else if (tWindow == 'mid') {
                    firstPmt = Date.today().addMonths(-randInt(globalIdx, 32, 3, 24));
                } else {
                    firstPmt = Date.today().addDays(randInt(globalIdx, 32, 15, 180));
                }
                Date pledgeSigned = firstPmt.addDays(-randInt(globalIdx, 56, 30, 180));
                Date endDate = firstPmt.addYears(years);
                Integer pledgeYears = Math.max(1, years);
                newCommitments.add(new GiftCommitment(
                    External_Id__c = 'FQS-GC-' + RUN_STAMP + '-' + globalIdx + '-pledged',
                    Name = dLabel + ' - ' + fmtAmt(totalAmt) + ' over ' + pledgeYears + ' year' + (pledgeYears == 1 ? '' : 's'),
                    DonorId = donorId, Status = 'Active',
                    FulfillmentType = isCond ? 'Conditional' : 'Unconditional', RecurrenceType = 'FixedLength',
                    FormalCommitmentType = 'Written',
                    FQS_Gift_Commitment_Category__c = 'Pledged Gift',
                    ExpectedTotalCmtAmount = totalAmt.setScale(2),
                    EffectiveStartDate = pledgeSigned,
                    ExpectedEndDate = endDate,
                    FQS_Match_Eligible__c = randBool(globalIdx, 37, PROB_COMMITMENT_MATCH_ELIGIBLE),
                    CampaignId = allAskCampaignIds[Math.mod(prng(globalIdx, 34), allAskCampaignIds.size())]));
                commitmentDonorIdx.add(i); commitmentKind.add('pledged'); commitmentIsConditional.add(isCond);
                commitmentFirstPaymentDate.add(firstPmt);
                commitmentCustomInstDates.add(new List<Date>());
                commitmentCustomInstAmounts.add(new List<Decimal>());
            }
            if (level == 2 && donorType == 1 && randBool(globalIdx, 40, PROB_GRANT_MAJORORG)) {
                Decimal grantAmt = roundTo5(randRange(globalIdx, 41, 50000, 150000));
                Id campId = asksByCategory.containsKey('Grants')
                    ? asksByCategory.get('Grants')[Math.mod(prng(globalIdx, 44), asksByCategory.get('Grants').size())]
                    : allAskCampaignIds[0];
                // Shape mix (three-way roll on salt 55):
                //   5%  grant-custom     — irregular installments (3-5), irregular spacing, irregular amounts
                //   25% grant-multiyear  — yearly installment ladder over 2-3 years
                //   70% grant-onetime    — single installment, brief admin window
                // §14 — timing window 40/40/20 (past/mid/future) applies to all three shapes.
                //   Pledge-signed (GC.EffectiveStartDate) = firstPmt - 30..180d (signing offset).
                Integer shapeRoll = Math.mod(prng(globalIdx, 55), 100);
                String grantKind;
                if (shapeRoll < 5)       grantKind = 'grant-custom';
                else if (shapeRoll < 30) grantKind = 'grant-multiyear';
                else                     grantKind = 'grant-onetime';

                String tWindow = pickTimingWindow(globalIdx, 57);
                Integer grantYears;
                if (grantKind == 'grant-multiyear')      grantYears = randInt(globalIdx, 43, 2, 3);
                else if (grantKind == 'grant-custom')    grantYears = randInt(globalIdx, 43, 1, 3);
                else                                     grantYears = 1;

                Integer durationDays;
                if (grantKind == 'grant-onetime')        durationDays = randInt(globalIdx, 46, 30, 60);
                else                                     durationDays = grantYears * 365;

                Date firstPmt;
                if (tWindow == 'past') {
                    Integer pastDays = durationDays + randInt(globalIdx, 42, 30, 180);
                    firstPmt = Date.today().addDays(-pastDays);
                } else if (tWindow == 'mid') {
                    firstPmt = Date.today().addMonths(-randInt(globalIdx, 42, 3, 18));
                } else {
                    firstPmt = Date.today().addDays(randInt(globalIdx, 42, 15, 180));
                }
                Date pledgeSigned = firstPmt.addDays(-randInt(globalIdx, 56, 30, 180));
                Date endDate = firstPmt.addDays(durationDays);

                // Build irregular installments for grant-custom. Weights normalized to grantAmt,
                // rounded to $5, last row reconciles rounding drift. Interval gaps 60..540d,
                // sorted ascending, anchored at firstPmt.
                List<Date> customDates = new List<Date>();
                List<Decimal> customAmts = new List<Decimal>();
                if (grantKind == 'grant-custom') {
                    Integer nInstall = randInt(globalIdx, 58, 3, 5);
                    List<Decimal> weights = new List<Decimal>();
                    Decimal weightSum = 0;
                    for (Integer k = 0; k < nInstall; k++) {
                        Decimal w = randRange(globalIdx, 58 + k * 2, 1, 5);
                        weights.add(w); weightSum += w;
                    }
                    Decimal running = 0;
                    for (Integer k = 0; k < nInstall; k++) {
                        Decimal amt;
                        if (k == nInstall - 1) {
                            amt = grantAmt - running;
                            if (amt < 5) amt = 5;
                        } else {
                            amt = roundTo5((grantAmt * weights[k] / weightSum));
                            if (amt < 5) amt = 5;
                            running += amt;
                        }
                        customAmts.add(amt);
                    }
                    // Sample nInstall-1 gaps in 60..540d, sort ascending, layer onto firstPmt.
                    List<Integer> gaps = new List<Integer>();
                    for (Integer k = 1; k < nInstall; k++) {
                        gaps.add(randInt(globalIdx, 59 + k * 3, 60, 540));
                    }
                    // Sort gaps ascending for a monotonic ladder.
                    for (Integer a = 0; a < gaps.size(); a++) {
                        for (Integer b = a + 1; b < gaps.size(); b++) {
                            if (gaps[b] < gaps[a]) { Integer t = gaps[a]; gaps[a] = gaps[b]; gaps[b] = t; }
                        }
                    }
                    customDates.add(firstPmt);
                    Integer cum = 0;
                    for (Integer k = 0; k < gaps.size(); k++) {
                        cum += gaps[k];
                        customDates.add(firstPmt.addDays(cum));
                    }
                    // Extend endDate to cover last installment (+30d admin buffer).
                    endDate = customDates[customDates.size() - 1].addDays(30);
                }

                String grantNameSuffix;
                if (grantKind == 'grant-onetime')        grantNameSuffix = '';
                else if (grantKind == 'grant-custom')    grantNameSuffix = ' custom schedule';
                else                                     grantNameSuffix = ' over ' + grantYears + ' year' + (grantYears == 1 ? '' : 's');

                GiftCommitment grantGc = new GiftCommitment(
                    External_Id__c = 'FQS-GC-' + RUN_STAMP + '-' + globalIdx + '-grant',
                    Name = dLabel + ' - ' + fmtAmt(grantAmt) + grantNameSuffix,
                    DonorId = donorId, Status = 'Active',
                    FulfillmentType = 'Conditional', RecurrenceType = 'FixedLength',
                    FormalCommitmentType = 'Written',
                    FQS_Gift_Commitment_Category__c = 'Grant Payout',
                    ExpectedTotalCmtAmount = grantAmt.setScale(2),
                    EffectiveStartDate = pledgeSigned,
                    ExpectedEndDate = endDate,
                    FQS_Match_Eligible__c = randBool(globalIdx, 47, PROB_COMMITMENT_MATCH_ELIGIBLE),
                    CampaignId = campId);
                // Custom shape: GC.ScheduleType='Custom' required (probe v4/v5 confirmed).
                // Other grant shapes let the platform default ScheduleType from GCS.TransactionPeriod.
                if (grantKind == 'grant-custom') grantGc.ScheduleType = 'Custom';
                // Phase D6 (shipped 2026-07-25): FQS_Restriction_Release_Date__c on multi-year
                // AND custom grants (both walk multiple installments across years).
                if (grantKind == 'grant-multiyear' || grantKind == 'grant-custom') {
                    grantGc.FQS_Restriction_Release_Date__c = endDate;
                }
                newCommitments.add(grantGc);
                commitmentDonorIdx.add(i); commitmentKind.add(grantKind); commitmentIsConditional.add(true);
                commitmentFirstPaymentDate.add(firstPmt);
                commitmentCustomInstDates.add(customDates);
                commitmentCustomInstAmounts.add(customAmts);
            }
        }
        if (!newCommitments.isEmpty()) insert newCommitments;

        // §12.2 — insert GiftDefaultDesignation on every commitment. Conditional (non-grant)
        // commitments round-robin across restricted designations so the launcher's Restriction
        // picker sees a mix; unconditional and grant commitments pull from the full designation
        // pool. Every GC lands with at least one GDD so the Manage Designations action, gift
        // ladder walker, and reports all have coverage on every seeded record.
        List<GiftDefaultDesignation> newGDDs = new List<GiftDefaultDesignation>();
        for (Integer i = 0; i < newCommitments.size(); i++) {
            Integer di = commitmentDonorIdx[i];
            Integer globalIdx = batchOffset + di;
            Id designationId;
            if (commitmentIsConditional[i] && !commitmentKind[i].startsWith('grant') && !restrictedDesignationIds.isEmpty()) {
                designationId = restrictedDesignationIds[Math.mod(prng(globalIdx, 26), restrictedDesignationIds.size())];
            } else if (!allDesignationIds.isEmpty()) {
                designationId = allDesignationIds[Math.mod(prng(globalIdx, 26), allDesignationIds.size())];
            } else {
                continue;
            }
            newGDDs.add(new GiftDefaultDesignation(
                ParentRecordId = newCommitments[i].Id,
                GiftDesignationId = designationId,
                AllocatedPercentage = 100
            ));
        }
        if (!newGDDs.isEmpty()) insert newGDDs;

        // §13.1a — pause-shape emitter.
        // Managed Fundraising Cloud Pause action leaves GC.Status=Active and inserts 3 GCS rows:
        // original CreateTransactions row (truncated to end just before the pause window),
        // PauseTransactions row spanning the window, and a resume-tail CreateTransactions row
        // starting the day after the window ends. The router flow detects "paused" by querying
        // for a live-or-indefinite PauseTransactions GCS — NOT by GC.Status. If we seed
        // Status=Paused with just one CreateTransactions row, the managed Resume subflow finds
        // nothing to resume. So for every recurring GC that pickRecurringStatus() picked as
        // "Paused" above, we (a) restore Status=Active and (b) build the 3-row pause shape.
        Set<Integer> pausedIdxs = new Set<Integer>();
        for (Integer i = 0; i < newCommitments.size(); i++) {
            if (commitmentKind[i] == 'recurring' && newCommitments[i].Status == 'Paused') {
                pausedIdxs.add(i);
            }
        }
        if (!pausedIdxs.isEmpty()) {
            List<GiftCommitment> gcStatusFix = new List<GiftCommitment>();
            for (Integer i : pausedIdxs) {
                gcStatusFix.add(new GiftCommitment(Id = newCommitments[i].Id, Status = 'Active'));
            }
            update gcStatusFix;
        }

        Date todaySched = Date.today();
        List<GiftCommitmentSchedule> newSchedules = new List<GiftCommitmentSchedule>();
        Map<Id, Id> pauseOriginalGcsIdByGcId = new Map<Id, Id>();
        // Track parallel index of each newSchedules row to its source commitment index so the
        // pause-row + resume-tail siblings can be identified by GcId after insert (they don't
        // occupy the same list slots).
        List<Integer> newSchedulesCommitmentIdx = new List<Integer>();
        for (Integer i = 0; i < newCommitments.size(); i++) {
            GiftCommitment gc = newCommitments[i];
            String kind = commitmentKind[i];
            Integer di = commitmentDonorIdx[i];
            Integer globalIdx = batchOffset + di;
            // Schedule.TransactionAmount = per-installment reference.
            //   recurring       → monthly amount (= GC total; OpenEnded has no lifetime cap)
            //   pledged         → total / duration years, yearly
            //   grant-multiyear → total / duration years, yearly (same shape as pledged)
            //   grant-onetime   → full grant amount, single-installment "Yearly" window
            //   grant-custom    → first installment amount as a reference; actual amounts live on
            //                     the emitted GTs (irregular per row). GCS.TransactionPeriod='Custom'
            //                     + Type='CreateTransactions'; Interval + Day intentionally omitted
            //                     (platform post-save defaults both to 1).
            Date firstPmtDate = commitmentFirstPaymentDate[i];
            Decimal schedAmt;
            if (kind == 'recurring') {
                schedAmt = gc.ExpectedTotalCmtAmount;
            } else if (kind == 'grant-onetime') {
                schedAmt = gc.ExpectedTotalCmtAmount;
            } else if (kind == 'grant-custom') {
                schedAmt = commitmentCustomInstAmounts[i].isEmpty() ? gc.ExpectedTotalCmtAmount : commitmentCustomInstAmounts[i][0];
            } else {
                // pledged / grant-multiyear — year count is derived from firstPmt to endDate,
                // NOT EffectiveStartDate (which now sits 30-180d earlier — pledge-signed offset).
                Integer years = Math.max(1, gc.ExpectedEndDate.year() - firstPmtDate.year());
                schedAmt = roundTo5((gc.ExpectedTotalCmtAmount / years).setScale(2));
            }
            Boolean isPaused = pausedIdxs.contains(i);
            String paymentMethod = kind.startsWith('grant') ? 'Check' : (Math.mod(i, 3) == 0 ? 'ACH' : 'Credit Card');
            // Recurring anchors GCS.StartDate at EffectiveStartDate (no signing offset).
            // pledged + grant-* anchor GCS.StartDate at firstPmt (schedule anchor = payment start,
            // NOT signing event).
            Date schedStart = (kind == 'recurring') ? gc.EffectiveStartDate : firstPmtDate;
            GiftCommitmentSchedule sched = new GiftCommitmentSchedule(
                External_Id__c = 'FQS-GCS-' + RUN_STAMP + '-' + globalIdx + '-' + kind,
                GiftCommitmentId = gc.Id,
                TransactionAmount = schedAmt,
                TransactionPeriod = (kind == 'recurring') ? 'Monthly' : (kind == 'grant-custom') ? 'Custom' : 'Yearly',
                StartDate = schedStart,
                PaymentMethod = paymentMethod
            );
            // Custom shape: MUST set Type='CreateTransactions' explicitly (probe confirmed this
            // is required for platform to activate + auto-populate LastPaidTransactionDate).
            // Omit TransactionInterval + TransactionDay — platform defaults both to 1 post-save.
            // Other shapes leave Type unset (previous behavior) so the platform sets it via
            // its own defaulting logic + doesn't reject on GC.ScheduleType null-mismatch.
            if (kind == 'grant-custom') {
                sched.Type = 'CreateTransactions';
            } else {
                // TransactionDay picklist rejects days > 28 on some orgs (only 1-28 + "LastDay"
                // in the restricted values list). Clamp to 28 and use "LastDay" for 29-31.
                Integer schedDay = schedStart.day();
                sched.TransactionDay = (schedDay >= 29) ? 'LastDay' : String.valueOf(schedDay);
            }
            if (kind != 'recurring' && gc.ExpectedEndDate != null) sched.EndDate = gc.ExpectedEndDate;
            // §13.1b — Paused GCs get the real 3-row shape managed Pause action produces.
            // Original CreateTransactions row is truncated to end just before the pause window;
            // Pause + resume-tail rows are added to the SAME batch so the async aggregation
            // trigger (which flips GC status based on the current schedule) sees the final
            // shape once, not the intermediate pause-less state.
            if (isPaused) {
                sched.EndDate = todaySched.addDays(-1);
            }
            newSchedules.add(sched);
            newSchedulesCommitmentIdx.add(i);
            if (isPaused) {
                Integer txDay = gc.EffectiveStartDate.day();
                Date pauseStart = todaySched;
                Date pauseEnd = todaySched.addDays(90);
                newSchedules.add(new GiftCommitmentSchedule(
                    External_Id__c = 'FQS-GCS-' + RUN_STAMP + '-' + globalIdx + '-recurring-pause',
                    GiftCommitmentId = gc.Id,
                    Type = 'PauseTransactions',
                    TransactionAmount = schedAmt,
                    TransactionPeriod = 'Monthly',
                    StartDate = pauseStart,
                    EndDate = pauseEnd,
                    TransactionDay = String.valueOf(txDay),
                    PaymentMethod = paymentMethod
                ));
                newSchedulesCommitmentIdx.add(i);
                newSchedules.add(new GiftCommitmentSchedule(
                    External_Id__c = 'FQS-GCS-' + RUN_STAMP + '-' + globalIdx + '-recurring-resume',
                    GiftCommitmentId = gc.Id,
                    Type = 'CreateTransactions',
                    TransactionAmount = schedAmt,
                    TransactionPeriod = 'Monthly',
                    StartDate = pauseEnd.addDays(1),
                    TransactionDay = String.valueOf(txDay),
                    PaymentMethod = paymentMethod
                ));
                newSchedulesCommitmentIdx.add(i);
            }
        }
        if (!newSchedules.isEmpty()) insert newSchedules;
        for (Integer j = 0; j < newSchedules.size(); j++) {
            Integer ci = newSchedulesCommitmentIdx[j];
            if (pausedIdxs.contains(ci) && newSchedules[j].Type != 'PauseTransactions'
                && newSchedules[j].StartDate == newCommitments[ci].EffectiveStartDate) {
                pauseOriginalGcsIdByGcId.put(newCommitments[ci].Id, newSchedules[j].Id);
            }
        }

        // Back-fill GC.CurrentGiftCmtScheduleId + NextTransactionDate. The platform's async
        // activation batch is meant to stamp these when StartDate <= today, but in practice
        // it lags (hours-to-days) or never fires for seed inserts. Downstream router flows
        // and reports depend on the current-schedule reference being live, so we write it
        // directly. Both fields are user-writable.
        //
        // Paused GCs are handled specially: CurrentGiftCmtScheduleId points at the ORIGINAL
        // truncated CreateTransactions row (stale-but-stable, matching managed Pause behavior);
        // NextTransactionDate points at the first tx date after the pause window ends.
        Date today = Date.today();
        Set<Id> pausedGcIds = pauseOriginalGcsIdByGcId.keySet();
        // Custom shape: NextTransactionDate + Amount point at the first future/pending installment
        // (matches the manual back-fill probe pattern for FundFirst Custom grants).
        Map<Id, GiftCommitment> customGcById = new Map<Id, GiftCommitment>();
        Map<Id, List<Date>> customDatesByGcId = new Map<Id, List<Date>>();
        Map<Id, List<Decimal>> customAmtsByGcId = new Map<Id, List<Decimal>>();
        for (Integer ci = 0; ci < newCommitments.size(); ci++) {
            if (commitmentKind[ci] == 'grant-custom') {
                customGcById.put(newCommitments[ci].Id, newCommitments[ci]);
                customDatesByGcId.put(newCommitments[ci].Id, commitmentCustomInstDates[ci]);
                customAmtsByGcId.put(newCommitments[ci].Id, commitmentCustomInstAmounts[ci]);
            }
        }
        List<GiftCommitment> gcActivations = new List<GiftCommitment>();
        for (GiftCommitmentSchedule s : newSchedules) {
            if (pausedGcIds.contains(s.GiftCommitmentId)) continue;  // handled below
            if (s.StartDate > today) continue;  // future-signed: platform will activate naturally
            // Custom shape: consult the precomputed installment ladder for the first future row.
            if (s.TransactionPeriod == 'Custom') {
                List<Date> cDates = customDatesByGcId.get(s.GiftCommitmentId);
                List<Decimal> cAmts = customAmtsByGcId.get(s.GiftCommitmentId);
                if (cDates == null || cDates.isEmpty()) continue;
                Date nextTx = null;
                Decimal nextAmt = null;
                for (Integer k = 0; k < cDates.size(); k++) {
                    if (cDates[k] > today) {
                        nextTx = cDates[k];
                        nextAmt = cAmts[k];
                        break;
                    }
                }
                // If every installment is in the past (all paid), point at the last row so
                // CurrentGiftCmtScheduleId + NextTransactionDate still populate (matches v4 shape).
                if (nextTx == null) {
                    nextTx = cDates[cDates.size() - 1];
                    nextAmt = cAmts[cAmts.size() - 1];
                }
                gcActivations.add(new GiftCommitment(
                    Id = s.GiftCommitmentId,
                    CurrentGiftCmtScheduleId = s.Id,
                    NextTransactionDate = nextTx,
                    NextTransactionAmount = nextAmt
                ));
                continue;
            }
            Date nextTx;
            // TransactionDay may be numeric "1".."28" or the sentinel "LastDay"; resolve
            // to a per-month integer using Date.daysInMonth when we compute nextTx below.
            Boolean useLastDay = 'LastDay'.equals(s.TransactionDay);
            Integer txDay = useLastDay ? 28 : Integer.valueOf(s.TransactionDay);
            if (s.TransactionPeriod == 'Monthly') {
                nextTx = Date.newInstance(today.year(), today.month(), Math.min(txDay, Date.daysInMonth(today.year(), today.month())));
                if (nextTx <= today) {
                    Date nm = today.addMonths(1);
                    nextTx = Date.newInstance(nm.year(), nm.month(), Math.min(txDay, Date.daysInMonth(nm.year(), nm.month())));
                }
            } else {
                nextTx = Date.newInstance(today.year(), s.StartDate.month(), Math.min(txDay, Date.daysInMonth(today.year(), s.StartDate.month())));
                if (nextTx <= today) nextTx = nextTx.addYears(1);
            }
            if (s.EndDate != null && nextTx > s.EndDate) continue;
            gcActivations.add(new GiftCommitment(
                Id = s.GiftCommitmentId,
                CurrentGiftCmtScheduleId = s.Id,
                NextTransactionDate = nextTx
            ));
        }
        for (Id gcId : pauseOriginalGcsIdByGcId.keySet()) {
            Id originalGcsId = pauseOriginalGcsIdByGcId.get(gcId);
            // NextTx = first tx date after the 90-day pause ends
            Date resumeStart = today.addDays(91);
            Integer txDay = today.day();
            Date nextTx = Date.newInstance(resumeStart.year(), resumeStart.month(), Math.min(txDay, Date.daysInMonth(resumeStart.year(), resumeStart.month())));
            if (nextTx <= resumeStart) {
                Date nm = resumeStart.addMonths(1);
                nextTx = Date.newInstance(nm.year(), nm.month(), Math.min(txDay, Date.daysInMonth(nm.year(), nm.month())));
            }
            gcActivations.add(new GiftCommitment(
                Id = gcId,
                CurrentGiftCmtScheduleId = originalGcsId,
                NextTransactionDate = nextTx
            ));
        }
        if (!gcActivations.isEmpty()) update gcActivations;

        List<Opportunity> newOpps = new List<Opportunity>();
        List<String> grantStages = new List<String>{'Identification','Cultivation','LOI Submitted','Proposal Submitted','Under Review','Awarded'};
        List<String> majorStages = new List<String>{'Identification','Cultivation','Solicitation','Verbal Commitment','Pledged','Closed Won'};
        Set<String> terminalStages = new Set<String>{'Awarded','Closed Won','Closed Lost'};
        for (Integer i = 0; i < donorCount; i++) {
            Integer level = donorLevels[i];
            Integer donorType = donorTypes[i];
            Integer globalIdx = batchOffset + i;
            Boolean createOpp = (level == 2) || (level == 1 && randBool(globalIdx, 50, 0.20));
            if (!createOpp) continue;
            Boolean isGrant = (donorType == 1);
            String stage = isGrant
                ? grantStages[Math.mod(prng(globalIdx, 51), grantStages.size())]
                : majorStages[Math.mod(prng(globalIdx, 51), majorStages.size())];
            Boolean isTerminal = terminalStages.contains(stage);
            Integer daysOffset = isTerminal
                ? randInt(globalIdx, 53, -180, -1)
                : randInt(globalIdx, 53, 7, 365);
            Date closeDate = Date.today().addDays(daysOffset);
            Decimal amt = roundTo5((level == 2) ? randRange(globalIdx, 52, bands.majorMin, bands.majorMax * 5) : randRange(globalIdx, 52, bands.midMin * 5, bands.majorMin));
            Opportunity opp = new Opportunity(
                External_Id__c = 'FQS-OPP-' + RUN_STAMP + '-' + globalIdx,
                Name = donorLabel(newAccounts[i]) + ' - ' + fmtAmt(amt) + ' close ' + String.valueOf(closeDate),
                AccountId = newAccounts[i].Id,
                RecordTypeId = isGrant ? oppGrantRT : oppMajorGiftRT,
                StageName = stage,
                CloseDate = closeDate,
                Amount = amt.setScale(2),
                CampaignId = allAskCampaignIds[Math.mod(prng(globalIdx, 54), allAskCampaignIds.size())]);
            if (isGrant) opp.FQS_Grant_Deadline__c = Date.today().addDays(randInt(globalIdx, 55, -60, 180));
            else opp.FQS_Solicitation_Date__c = Date.today().addDays(randInt(globalIdx, 55, -180, 60));
            newOpps.add(opp);
        }
        if (!newOpps.isEmpty()) insert newOpps;

        List<PaymentInstrument> newPIs = new List<PaymentInstrument>();
        List<String> piTypes = new List<String>{'Credit Card','Credit Card','Credit Card','ACH','ACH','PayPal'};
        List<String> cardBrands = new List<String>{'Visa','MasterCard','American Express','Discover'};
        Integer currentYear = System.today().year();
        for (Integer i = 0; i < donorCount; i++) {
            Integer globalIdx = batchOffset + i;
            String piType = piTypes[Math.mod(prng(globalIdx, 60), piTypes.size())];
            Integer last4int = Math.mod(prng(globalIdx, 61), 10000);
            String last4 = String.valueOf(last4int).leftPad(4, '0');
            PaymentInstrument pi = new PaymentInstrument(
                External_Id__c = 'FQS-PI-' + RUN_STAMP + '-' + globalIdx,
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

        // Group commitments by donor for later cross-referencing (used only by summary/logging paths;
        // commitment-driven GT emission below iterates newCommitments directly).
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
            } else if (k.startsWith('grant')) {
                if (!grantCommitmentByDonor.containsKey(di)) grantCommitmentByDonor.put(di, new List<Id>());
                grantCommitmentByDonor.get(di).add(newCommitments[i].Id);
            }
        }
        // Track schedule by commitment index for the commitment-driven GT ladder walker.
        Map<Id, Id> gcsIdByGcId = new Map<Id, Id>();
        Map<Id, Decimal> gcsAmountByGcId = new Map<Id, Decimal>();
        Map<Id, String> gcsPaymentMethodByGcId = new Map<Id, String>();
        for (GiftCommitmentSchedule s : newSchedules) {
            gcsIdByGcId.put(s.GiftCommitmentId, s.Id);
            gcsAmountByGcId.put(s.GiftCommitmentId, s.TransactionAmount);
            gcsPaymentMethodByGcId.put(s.GiftCommitmentId, s.PaymentMethod);
        }

        // §10.2 — precompute fee lookup keyed by (paymentMethod, coversFees, baseBucket).
        // Base amounts are rounded to $5 by roundTo5(), so we bucket them into $5 increments.
        // A per-gift call to computeFees() runs 4-6 multiplications + rounds; with 300 donors
        // × 15 gifts each that's ~20K calls per chunk. Cache lookups are O(1) and cut the
        // fee-math contribution to CPU-time by roughly 80%.
        Map<String, List<Decimal>> feeCache = new Map<String, List<Decimal>>();
        // Invert: build cache lazily inside the loop — each chunk hits maybe 200 unique buckets
        // out of thousands, so on-demand memoization keeps the map small.

        // Group OSCs by the FY of their CampaignId, so an FY26 gift can grab an FY26 OSC and
        // avoid attributing FY26 revenue to a prior-year outreach code.
        Map<Integer, List<Id>> oscIdsByFY = new Map<Integer, List<Id>>{26 => new List<Id>(), 25 => new List<Id>(), 24 => new List<Id>()};
        Map<Id, Integer> campaignFYById = new Map<Id, Integer>();
        Map<Id, String> campaignCategoryByAskId = new Map<Id, String>();  // §13.2 — Event-benefit lookup during gift loop
        for (Campaign c : campaigns) {
            if (c.External_Id__c == null || !c.External_Id__c.startsWith('FQS-CMP-ASK-')) continue;
            Integer fy = c.External_Id__c.endsWith('-FY25') ? 25 : c.External_Id__c.endsWith('-FY24') ? 24 : 26;
            campaignFYById.put(c.Id, fy);
            campaignCategoryByAskId.put(c.Id, c.FQS_Campaign_Category__c);
        }
        for (OutreachSourceCode o : outreachCodes) {
            Integer fy = campaignFYById.containsKey(o.CampaignId) ? campaignFYById.get(o.CampaignId) : 26;
            oscIdsByFY.get(fy).add(o.Id);
        }
        for (Integer fy : new List<Integer>{25, 24}) {
            if (oscIdsByFY.get(fy).isEmpty()) oscIdsByFY.put(fy, oscIdsByFY.get(26));
        }

        List<GiftTransaction> newGifts = new List<GiftTransaction>();
        List<Integer> giftDonorIdx = new List<Integer>();
        List<Integer> giftIndexInDonor = new List<Integer>();
        List<Boolean> giftIsPaid = new List<Boolean>();
        List<String> giftCategory = new List<String>();
        List<Integer> giftMatchScenario = new List<Integer>();
        List<Integer> giftFY = new List<Integer>();  // §11.3 — FY of TransactionDate, retained for corp-match target FY

        // Inline helper closures aren't a thing in Apex — emitGift() is defined via a shared
        // params object below. Kept the shape of the original in-line emission so the
        // commitment-driven ladder and one-off quota both funnel through the same code.
        //
        // ============ Commitment-driven ladders ============
        // Recurring    → walk StartDate + N months, up to 18 months of history OR to today.
        //                Lapsed/Paused truncate the ladder ~50% along the way (donor stopped paying).
        //                All installments share GCS.TransactionAmount. Statuses: mostly Paid,
        //                a trailing 1-2 may roll Failed/Pending on Failing/Lapsed donors.
        // Pledged      → walk StartDate + N years, up to min(EndDate, today). All installments
        //                share GCS.TransactionAmount. 70% all-Paid, 25% earliest Paid + next
        //                Pending, 5% one overdue Unpaid installment (TransactionDueDate < today).
        // grant-onetime → single installment on StartDate. ~65% TransactionDate lands in ask
        //                campaign's FY, ~35% slips to adjacent FY. Amount = GCS.TransactionAmount
        //                (= full grantAmt).
        // grant-multiyear → walk StartDate + N years like Pledged. Amount = GCS.TransactionAmount
        //                (= grantAmt / years). 5% overdue-installment share matches pledged.
        //                DEFERRED (Phase D6): populate FQS_Restriction_Release_Date__c yearly
        //                on each installment; see [[seed-release-date-followup]].
        for (Integer ci = 0; ci < newCommitments.size(); ci++) {
            GiftCommitment gc = newCommitments[ci];
            String kind = commitmentKind[ci];
            Integer di = commitmentDonorIdx[ci];
            Integer globalIdx = batchOffset + di;
            Decimal schedAmt = gcsAmountByGcId.get(gc.Id);
            String schedPaymentMethod = gcsPaymentMethodByGcId.get(gc.Id);
            // Ladder anchor = firstPmt (payment start), NOT EffectiveStartDate (signing event).
            Date firstPmtDate = commitmentFirstPaymentDate[ci];
            Integer totalMonths = ((Date.today().year() - firstPmtDate.year()) * 12
                                   + (Date.today().month() - firstPmtDate.month()));

            // Compute this commitment's installment ladder — a list of Date+Status+Amount triples.
            // For grant-custom the amounts vary per row (irregular); all others share schedAmt.
            List<Date> instDates = new List<Date>();
            List<String> instStatuses = new List<String>();
            List<Decimal> instAmounts = new List<Decimal>();  // empty means "use schedAmt"

            if (kind == 'recurring') {
                // 18-month cap ⇒ produces at most 18 installments (m in 0..17, inclusive).
                Integer maxMonths = Math.max(0, Math.min(17, totalMonths));
                String gcStatus = gc.Status;
                Integer lapseCutoff = maxMonths;
                if (gcStatus == 'Lapsed' || gcStatus == 'Paused') {
                    lapseCutoff = randInt(globalIdx, 200, Math.min(3, maxMonths), Math.max(3, maxMonths - 2));
                }
                for (Integer m = 0; m <= lapseCutoff; m++) {
                    Date d = firstPmtDate.addMonths(m);
                    if (d > Date.today()) break;
                    instDates.add(d);
                    Boolean isTrailing = (m >= lapseCutoff - 2);
                    if (gcStatus == 'Failing' && isTrailing && randBool(globalIdx, 201 + m, 0.6)) {
                        instStatuses.add(randBool(globalIdx, 202 + m, 0.5) ? 'Failed' : 'Pending');
                    } else if (gcStatus == 'Lapsed' && m == lapseCutoff) {
                        instStatuses.add('Failed');
                    } else {
                        instStatuses.add('Paid');
                    }
                }
            } else if (kind == 'pledged' || kind == 'grant-multiyear') {
                Date walker = firstPmtDate;
                Date walkerEnd = (gc.ExpectedEndDate != null && gc.ExpectedEndDate < Date.today())
                    ? gc.ExpectedEndDate : Date.today();
                Integer y = 0;
                while (walker <= walkerEnd && y < 10) {
                    instDates.add(walker);
                    walker = walker.addYears(1);
                    y++;
                }
                if (instDates.isEmpty()) {
                    // Future-signed pledge/grant with no payments yet — emit one Pending row on firstPmt.
                    instDates.add(firstPmtDate);
                    instStatuses.add('Pending');
                } else {
                    // Lifecycle: 70% all-Paid, 25% earliest Paid + next Pending, 5% one overdue Unpaid.
                    Integer lifecycleRoll = Math.mod(prng(globalIdx, 210), 100);
                    for (Integer k = 0; k < instDates.size(); k++) instStatuses.add('Paid');
                    if (instDates.size() >= 2 && lifecycleRoll >= 70 && lifecycleRoll < 95) {
                        instStatuses[instStatuses.size() - 1] = 'Pending';
                    } else if (instDates.size() >= 1 && lifecycleRoll >= 95) {
                        // Overdue: pick one installment, backdate its due-date so it's past due, mark Unpaid.
                        Integer overdueIdx = Math.mod(prng(globalIdx, 211), instDates.size());
                        instStatuses[overdueIdx] = 'Unpaid';
                    }
                }
            } else if (kind == 'grant-onetime') {
                // One installment on firstPmt; usually Paid if in the past, Pending if future.
                instDates.add(firstPmtDate);
                if (firstPmtDate > Date.today()) {
                    instStatuses.add('Pending');
                } else {
                    instStatuses.add(randBool(globalIdx, 220, 0.95) ? 'Paid' : 'Pending');
                }
            } else if (kind == 'grant-custom') {
                // Irregular installments precomputed in the commitment block. Per-row amount lives on
                // instAmounts. Status: past-dated rows = Paid, future rows = Pending; overall 5%
                // overdue on any single row (mirrors pledged/multiyear lifecycle).
                List<Date> customDates = commitmentCustomInstDates[ci];
                List<Decimal> customAmts = commitmentCustomInstAmounts[ci];
                for (Integer k = 0; k < customDates.size(); k++) {
                    instDates.add(customDates[k]);
                    instAmounts.add(customAmts[k]);
                    instStatuses.add(customDates[k] <= Date.today() ? 'Paid' : 'Pending');
                }
                Integer overdueRoll = Math.mod(prng(globalIdx, 212), 100);
                if (overdueRoll < 5 && !instStatuses.isEmpty()) {
                    Integer overdueIdx = Math.mod(prng(globalIdx, 213), instStatuses.size());
                    instStatuses[overdueIdx] = 'Unpaid';
                }
            }

            String cat = kind.startsWith('grant') ? 'Grant Payment' : 'Pledge Payment';
            Boolean isEligibleForMatch = employerEligible[di];
            for (Integer inst = 0; inst < instDates.size(); inst++) {
                Date txnDate = instDates[inst];
                String status = instStatuses[inst];
                Boolean isPaid = (status == 'Paid');
                // grant-custom overrides per-installment amount; all other kinds share schedAmt.
                Decimal rowAmt = (inst < instAmounts.size()) ? instAmounts[inst] : schedAmt;
                Decimal baseAmount = roundTo5(rowAmt);
                if (baseAmount < 5) baseAmount = 5;
                String paymentMethod = (schedPaymentMethod != null) ? schedPaymentMethod : 'Check';
                Boolean donorCoversFees = (paymentMethod != 'Check') && randBool(globalIdx, 230 + inst, PROB_DONOR_COVERS_FEES);
                String feeKey = paymentMethod + '|' + (donorCoversFees ? '1' : '0') + '|' + baseAmount;
                List<Decimal> feeBreakdown = feeCache.get(feeKey);
                if (feeBreakdown == null) {
                    feeBreakdown = computeFees(baseAmount, paymentMethod, donorCoversFees);
                    feeCache.put(feeKey, feeBreakdown);
                }
                Decimal originalAmount = feeBreakdown[0];
                Decimal gatewayFee     = feeBreakdown[1];
                Decimal processorFee   = feeBreakdown[2];
                Decimal donorCover     = feeBreakdown[3];

                // FY resolution. For grant-onetime, ~35% override the natural FY assignment to
                // land in an adjacent FY vs the parent GC's ask campaign — models real-world
                // grant timing that slips fiscal boundaries.
                Integer txnFY = (txnDate >= genFy26Start) ? 26 : (txnDate >= genFy25Start) ? 25 : 24;
                Id chosenCampaignId = gc.CampaignId;  // Commitment-driven GTs inherit the GC's ask campaign.
                if (kind == 'grant-onetime' && randBool(globalIdx, 240, 0.35)) {
                    // Slip into adjacent FY: shift txnDate by ~6 months in either direction.
                    Integer slipMonths = randBool(globalIdx, 241, 0.5) ? -6 : 6;
                    txnDate = txnDate.addMonths(slipMonths);
                    txnFY = (txnDate >= genFy26Start) ? 26 : (txnDate >= genFy25Start) ? 25 : 24;
                }
                // Overdue installments: force TransactionDueDate < today so aging reports catch them.
                Date dueDate = isPaid ? txnDate : txnDate.addDays(30);
                if (status == 'Unpaid') dueDate = Date.today().addDays(-randInt(globalIdx, 250 + inst, 15, 90));
                if (chosenCampaignId == null) {
                    List<Id> fyAskPool = askIdsByFY.get(txnFY);
                    chosenCampaignId = fyAskPool[Math.mod(prng(globalIdx, 270 + inst), fyAskPool.size())];
                }
                // OSC must belong to the SAME campaign as the GT — platform validation:
                // "Select an Outreach Source Code that's part of this Campaign." So we can't
                // pick any FY-matched OSC; we need one whose CampaignId == chosenCampaignId.
                // If none exists, leave OSC null (legal — foundation ran with SKIP_OSCS=true previously).
                Id chosenOscId = null;
                List<Id> campaignPinnedOscs = new List<Id>();
                for (Id oid : allOscIds) {
                    if (oscToCampaign.get(oid) == chosenCampaignId) campaignPinnedOscs.add(oid);
                }
                if (!campaignPinnedOscs.isEmpty()) {
                    chosenOscId = campaignPinnedOscs[Math.mod(prng(globalIdx, 260 + inst), campaignPinnedOscs.size())];
                }

                Integer scenario = 0;
                if (isEligibleForMatch) {
                    Integer sRoll = Math.mod(prng(globalIdx, 602 + inst), 100);
                    if (sRoll < MATCH_ROLL_PLEDGE_MAX && cat == 'Pledge Payment' && isPaid) scenario = 1;
                    else if (sRoll < MATCH_ROLL_PENDING_MAX && cat == 'Pledge Payment') scenario = 3;
                    else scenario = 4;
                }

                String gtDateLabel = 'due ' + String.valueOf(dueDate);
                Decimal nonDeductible = null;
                Boolean isEventCampaign = 'Events'.equals(campaignCategoryByAskId.get(chosenCampaignId));
                Boolean rolledBenefit = isEventCampaign && randBool(globalIdx, 280 + inst, PROB_BENEFIT_INCLUSION);
                if (rolledBenefit) {
                    nonDeductible = (originalAmount * 0.15).setScale(2);
                } else if (donorCoversFees && (gatewayFee + processorFee) > 0) {
                    nonDeductible = (gatewayFee + processorFee).setScale(2);
                }
                if (nonDeductible != null && nonDeductible > originalAmount) nonDeductible = originalAmount;

                GiftTransaction gt = new GiftTransaction(
                    External_Id__c = 'FQS-GT-' + RUN_STAMP + '-' + globalIdx + '-' + kind + '-' + inst,
                    Name = donorLabel(newAccounts[di]) + ' - ' + fmtAmt(originalAmount) + ' ' + gtDateLabel,
                    DonorId = newAccounts[di].Id,
                    OriginalAmount = originalAmount,
                    GatewayTransactionFee = gatewayFee,
                    ProcessorTransactionFee = processorFee,
                    DonorCoverAmount = donorCover,
                    NonTaxDeductibleAmount = nonDeductible,
                    TransactionDate = txnDate,
                    TransactionDueDate = dueDate,
                    Status = status,
                    GiftType = donorTypes[di] == 0 ? 'Individual' : 'Organizational',
                    PaymentMethod = paymentMethod,
                    FQS_Gift_Transaction_Category__c = cat,
                    CampaignId = chosenCampaignId,
                    OutreachSourceCodeId = chosenOscId,
                    GiftCommitmentId = gc.Id
                );
                // Phase D6 (shipped 2026-07-25): stamp per-installment restriction release
                // date on multi-year + custom grant GTs — one year past the installment date.
                // Per memory [[seed-release-date-followup]].
                if (kind == 'grant-multiyear' || kind == 'grant-custom') {
                    gt.FQS_Restriction_Release_Date__c = txnDate.addYears(1);
                }
                if (kind == 'recurring') gt.FQS_Recurring__c = true;
                if (scenario == 1 || scenario == 3) {
                    gt.FQS_Matched__c = true;
                } else {
                    gt.FQS_Matched__c = false;
                }
                newGifts.add(gt);
                giftDonorIdx.add(di);
                giftIndexInDonor.add(inst);
                giftIsPaid.add(isPaid);
                giftCategory.add(cat);
                giftMatchScenario.add(scenario);
                giftFY.add(txnFY);
            }
        }

        // ============ One-off quota-based GTs (Outright + Fee/Payment only) ============
        // Recurring/Pledge/Grant payments are now emitted from commitment ladders above. This
        // loop covers the remaining categories: outright cash gifts (one-time contributions)
        // and fee/payment revenue (event registrations, program fees). Quota reuses the
        // original giftCount pyramid but subtracts ladder-emitted GTs so heavy-commitment
        // donors don't get flooded with extra outrights.
        Map<Integer, Integer> ladderCountByDonor = new Map<Integer, Integer>();
        for (Integer gi = 0; gi < newGifts.size(); gi++) {
            Integer di = giftDonorIdx[gi];
            ladderCountByDonor.put(di, (ladderCountByDonor.containsKey(di) ? ladderCountByDonor.get(di) : 0) + 1);
        }
        for (Integer i = 0; i < donorCount; i++) {
            Integer level = donorLevels[i];
            Boolean lapsed = lapsedFlags[i];
            Integer globalIdx = batchOffset + i;
            Integer targetQuota = (level == 0) ? randInt(globalIdx, 100, 1, 3)
                                : (level == 1) ? randInt(globalIdx, 100, 3, 10)
                                                : randInt(globalIdx, 100, 5, 20);
            Integer ladderAlready = ladderCountByDonor.containsKey(i) ? ladderCountByDonor.get(i) : 0;
            Integer oneOffCount = Math.max(0, targetQuota - ladderAlready);
            Boolean isEligibleForMatch = employerEligible[i];

            for (Integer g = 0; g < oneOffCount; g++) {
                Integer catRoll = Math.mod(prng(globalIdx, 301 + g), 100);
                String cat = (catRoll < 90) ? 'Outright Gift' : 'Fee/Payment';

                Decimal baseAmount;
                if (cat == 'Fee/Payment')   baseAmount = randRange(globalIdx, 302 + g, 5, 100);
                else if (level == 0)        baseAmount = randRange(globalIdx, 302 + g, bands.entryMin, bands.entryMax);
                else if (level == 1)        baseAmount = randRange(globalIdx, 302 + g, bands.midMin,   bands.midMax);
                else                        baseAmount = randRange(globalIdx, 302 + g, bands.majorMin, bands.majorMax);
                baseAmount = roundTo5(baseAmount);
                if (baseAmount < 5) baseAmount = 5;

                Integer daysBack = lapsed
                    ? randInt(globalIdx, 303 + g, 365, 365 * GIFT_HISTORY_YEARS)
                    : randInt(globalIdx, 303 + g, 0, 365 * GIFT_HISTORY_YEARS);
                Date txnDate = Date.today().addDays(-daysBack);

                Integer statusRoll = Math.mod(prng(globalIdx, 304 + g), 100);
                String status = (statusRoll < 90) ? 'Paid'
                             : (statusRoll < 95) ? 'Pending'
                             : (statusRoll < 98) ? 'Failed' : 'Unpaid';
                Boolean isPaid = (status == 'Paid');

                String paymentMethod = pickOne(globalIdx, 305 + g, new List<String>{'Credit Card','ACH','Check','Credit Card','Credit Card'});
                Boolean donorCoversFees = (paymentMethod != 'Check') && randBool(globalIdx, 306 + g, PROB_DONOR_COVERS_FEES);
                String feeKey = paymentMethod + '|' + (donorCoversFees ? '1' : '0') + '|' + baseAmount;
                List<Decimal> feeBreakdown = feeCache.get(feeKey);
                if (feeBreakdown == null) {
                    feeBreakdown = computeFees(baseAmount, paymentMethod, donorCoversFees);
                    feeCache.put(feeKey, feeBreakdown);
                }
                Decimal originalAmount = feeBreakdown[0];
                Decimal gatewayFee     = feeBreakdown[1];
                Decimal processorFee   = feeBreakdown[2];
                Decimal donorCover     = feeBreakdown[3];

                Integer txnFY = (txnDate >= genFy26Start) ? 26 : (txnDate >= genFy25Start) ? 25 : 24;
                List<Id> fyAskPool = askIdsByFY.get(txnFY);
                Id chosenCampaignId = fyAskPool[Math.mod(prng(globalIdx, 307 + g), fyAskPool.size())];
                Id chosenOscId;
                List<Id> fyOscPool = oscIdsByFY.get(txnFY);
                if (fyOscPool.isEmpty()) {
                    chosenOscId = null;
                } else {
                    chosenOscId = fyOscPool[Math.mod(prng(globalIdx, 308 + g), fyOscPool.size())];
                    Id oscCamp = oscToCampaign.get(chosenOscId);
                    if (oscCamp != null && campaignFYById.get(oscCamp) == txnFY) {
                        chosenCampaignId = oscCamp;
                    }
                }

                Integer scenario = 0;
                if (isEligibleForMatch) {
                    Integer sRoll = Math.mod(prng(globalIdx, 602 + g), 100);
                    if (sRoll < MATCH_ROLL_OUTRIGHT_MAX && cat == 'Outright Gift' && isPaid) scenario = 2;
                    else if (sRoll < MATCH_ROLL_PENDING_MAX && cat == 'Outright Gift') scenario = 3;
                    else scenario = 4;
                }

                Date dueDate = isPaid ? txnDate : txnDate.addDays(30);
                String gtDateLabel = 'on ' + String.valueOf(txnDate);
                Decimal nonDeductible = null;
                Boolean isEventCampaign = 'Events'.equals(campaignCategoryByAskId.get(chosenCampaignId));
                Boolean rolledBenefit = isEventCampaign && randBool(globalIdx, 310 + g, PROB_BENEFIT_INCLUSION);
                if (rolledBenefit) {
                    nonDeductible = (originalAmount * 0.15).setScale(2);
                } else if (donorCoversFees && (gatewayFee + processorFee) > 0) {
                    nonDeductible = (gatewayFee + processorFee).setScale(2);
                }
                if (nonDeductible != null && nonDeductible > originalAmount) nonDeductible = originalAmount;

                GiftTransaction gt = new GiftTransaction(
                    External_Id__c = 'FQS-GT-' + RUN_STAMP + '-' + globalIdx + '-oneoff-' + g,
                    Name = donorLabel(newAccounts[i]) + ' - ' + fmtAmt(originalAmount) + ' ' + gtDateLabel,
                    DonorId = newAccounts[i].Id,
                    OriginalAmount = originalAmount,
                    GatewayTransactionFee = gatewayFee,
                    ProcessorTransactionFee = processorFee,
                    DonorCoverAmount = donorCover,
                    NonTaxDeductibleAmount = nonDeductible,
                    TransactionDate = txnDate,
                    TransactionDueDate = dueDate,
                    Status = status,
                    GiftType = donorTypes[i] == 0 ? 'Individual' : 'Organizational',
                    PaymentMethod = paymentMethod,
                    FQS_Gift_Transaction_Category__c = cat,
                    CampaignId = chosenCampaignId,
                    OutreachSourceCodeId = chosenOscId
                );
                gt.FQS_In_Kind__c = randBool(globalIdx, 308 + g, PROB_INKIND);
                if (gt.FQS_In_Kind__c == true) gt.PaymentMethod = 'In-Kind';
                if (scenario == 2 || scenario == 3) {
                    gt.FQS_Matched__c = true;
                } else {
                    gt.FQS_Matched__c = (donorTypes[i] == 0 && !isEligibleForMatch && randBool(globalIdx, 309 + g, 0.08));
                }
                newGifts.add(gt);
                giftDonorIdx.add(i);
                giftIndexInDonor.add(g);
                giftIsPaid.add(isPaid);
                giftCategory.add(cat);
                giftMatchScenario.add(scenario);
                giftFY.add(txnFY);
            }
        }
        System.debug('Fee cache: ' + feeCache.size() + ' unique buckets across ' + newGifts.size() + ' gifts');

        List<String> inKindItems = new List<String>{
            'Auction items: silent auction baskets',
            'Office equipment: laptops and monitors',
            'Event catering: gala dinner for 50',
            'Vehicle donation: 2018 minivan',
            'Software licenses: annual CRM subs',
            'Legal services: pro bono review',
            'Marketing services: 40 hours design',
            'Books and supplies: 500 books',
            'Medical supplies: PPE and first-aid',
            'Furniture: office chairs and desks',
            'Food donation: 2 pallets nonperishable'
        };
        Integer inKindCount = 0;
        for (GiftTransaction g : newGifts) if (g.FQS_In_Kind__c == true) inKindCount++;
        if (inKindCount < 3) {
            for (Integer i = 0; i < newGifts.size() && inKindCount < 3; i++) {
                if (newGifts[i].FQS_In_Kind__c == true) continue;
                newGifts[i].FQS_In_Kind__c = true;
                newGifts[i].PaymentMethod = 'In-Kind';
                inKindCount++;
            }
        }
        for (Integer i = 0; i < newGifts.size(); i++) {
            if (newGifts[i].FQS_In_Kind__c != true) continue;
            Integer globalIdx = batchOffset + giftDonorIdx[i];
            newGifts[i].Description = inKindItems[Math.mod(prng(globalIdx, 130 + giftIndexInDonor[i]), inKindItems.size())];
        }

        // Stewardship/Ack lifecycle stamping on every GT.
        //  - FQS_Processed_Date__c: TransactionDate + 0..3 days (real data-entry lag)
        //  - AcknowledgementStatus / AcknowledgementDate: Paid gifts older than 14 days
        //    are marked Sent (~85%); newer or non-Paid stay 'To Be Sent' so the ack batch
        //    has a live pipeline
        //  - FQS_Stewardship_Status__c / FQS_Stewardship_Date__c: only on Paid + acked
        //    gifts older than 14 days; ~70% Sent, ~15% To Be Sent (in-pipeline), ~15%
        //    Don't Send (donor opt-out)
        //  - FQS_Tax_Receipt_Date__c: ~10% of Paid gifts older than 30 days (manual entry
        //    field per docs; leaving most null is correct)
        //  - Fee/Payment category excluded from ack + stewardship (matches flow filters)
        Map<String, Schema.SObjectField> gtFieldMap = Schema.SObjectType.GiftTransaction.fields.getMap();
        Boolean hasProcessedDate  = gtFieldMap.containsKey('fqs_processed_date__c');
        Boolean hasStewardStatus  = gtFieldMap.containsKey('fqs_stewardship_status__c');
        Boolean hasStewardDate    = gtFieldMap.containsKey('fqs_stewardship_date__c');
        Boolean hasTaxReceiptDate = gtFieldMap.containsKey('fqs_tax_receipt_date__c');
        Date todayForStamp = Date.today();
        for (Integer i = 0; i < newGifts.size(); i++) {
            GiftTransaction gt = newGifts[i];
            Integer globalIdx = batchOffset + giftDonorIdx[i];
            Integer instIdx = giftIndexInDonor[i];
            Date txnDate = gt.TransactionDate;
            if (txnDate == null) continue;
            Boolean isPaid = (gt.Status == 'Paid');
            String cat = (String) gt.FQS_Gift_Transaction_Category__c;
            Boolean isFee = ('Fee/Payment'.equals(cat));

            if (hasProcessedDate) {
                gt.put('FQS_Processed_Date__c', txnDate.addDays(randInt(globalIdx, 320 + instIdx, 0, 3)));
            }

            if (!isPaid || isFee) continue;
            Integer daysSince = txnDate.daysBetween(todayForStamp);
            if (daysSince < 14) continue;

            if (randBool(globalIdx, 340 + instIdx, 0.85)) {
                gt.AcknowledgementStatus = 'Sent';
                gt.AcknowledgementDate = txnDate.addDays(randInt(globalIdx, 341 + instIdx, 1, 3));

                if (hasStewardStatus && hasStewardDate) {
                    Integer sRoll = Math.mod(prng(globalIdx, 350 + instIdx), 100);
                    if (sRoll < 70) {
                        gt.put('FQS_Stewardship_Status__c', 'Sent');
                        gt.put('FQS_Stewardship_Date__c', txnDate.addDays(randInt(globalIdx, 351 + instIdx, 14, 21)));
                    } else if (sRoll < 85) {
                        gt.put('FQS_Stewardship_Status__c', 'To Be Sent');
                    } else {
                        gt.put('FQS_Stewardship_Status__c', 'Don\'t Send');
                    }
                }

                if (hasTaxReceiptDate && daysSince >= 30 && randBool(globalIdx, 360 + instIdx, 0.10)) {
                    gt.put('FQS_Tax_Receipt_Date__c', txnDate.addDays(randInt(globalIdx, 361 + instIdx, 30, 60)));
                }
            }
        }
        insert newGifts;

        // §12.1 — CampaignMember rows. The account launcher's Campaign picker filters to
        // campaigns whose CampaignMembers include one of the Account's Contacts. Without this,
        // the picker is empty on every donor and testers can only pick via lookup escape hatch.
        // We seed one CampaignMember per (donor's primary Contact, distinct Campaign the donor gave to).
        // Person Accounts only — Org donors don't have a primary Contact on the Account itself,
        // and seeding synthetic Org Contacts is out of scope for this pass.
        //
        // Status ladder alignment: FQS_Campaign_Member_Status_Ladder flow rebrands each new
        // campaign's statuses by category. Baseline (non-event) ladder = Solicited / Responded /
        // Pledged/Gave / Declined; a donor with a gift belongs at Pledged/Gave. Event campaigns
        // are skipped — their ladder is Invited / Registered / Attended / Declined and attendance
        // is captured manually. A gift on an event campaign doesn't mean the donor attended
        // (they may have declined the event and given anyway), so seeding a CM there would lie.
        Set<Id> donorAccountIds = new Set<Id>();
        for (Account a : newAccounts) if (a.RecordTypeId == personAccountRT) donorAccountIds.add(a.Id);
        Map<Id, Id> personContactByAccount = new Map<Id, Id>();
        for (Account pa : [SELECT Id, PersonContactId FROM Account WHERE Id IN :donorAccountIds AND PersonContactId != null]) {
            personContactByAccount.put(pa.Id, pa.PersonContactId);
        }

        // Phase G4: seed AccountContactRelation rows for a fraction of match-eligible
        // Person-Account donors so the launcher's employer-picker datatable has real
        // ACR → PRG.Type='Group' data on fresh seeds. Not every eligible donor gets one:
        // ACR_COVERAGE_PCT (65%) leaves some donors ACR-less so the fallback lookup path
        // remains realistic in demos and QA. Roles='Employee' (native ACR picklist),
        // IsActive left to platform default (true). Uses Database.insert allOrNone=false
        // in case the platform auto-creates certain ACRs from other flows (defensive).
        Integer ACR_COVERAGE_PCT = 65;
        List<AccountContactRelation> matchAcrs = new List<AccountContactRelation>();
        for (Integer i = 0; i < donorCount; i++) {
            if (donorTypes[i] != 0 || !employerEligible[i]) continue;
            Integer globalIdx = batchOffset + i;
            if (Math.mod(prng(globalIdx, 604), 100) >= ACR_COVERAGE_PCT) continue;
            Id contactId = personContactByAccount.get(newAccounts[i].Id);
            if (contactId == null) continue;
            Id employerAccountId = corpEmployers[employerIdxByDonor[i]].Id;
            matchAcrs.add(new AccountContactRelation(
                AccountId = employerAccountId,
                ContactId = contactId,
                Roles = 'Employee'));
        }
        if (!matchAcrs.isEmpty()) {
            Database.SaveResult[] acrResults = Database.insert(matchAcrs, false);
            Integer acrOk = 0;
            for (Database.SaveResult sr : acrResults) if (sr.isSuccess()) acrOk++;
            System.debug('Match ACRs inserted: ' + acrOk + ' / ' + acrResults.size() + ' attempted.');
        }

        Map<Id, String> campaignCategoryById = new Map<Id, String>();
        for (Campaign c : campaigns) campaignCategoryById.put(c.Id, c.FQS_Campaign_Category__c);
        // Build (donorAccountId → set of gift CampaignIds), excluding event campaigns.
        Map<Id, Set<Id>> giftCampaignsByDonor = new Map<Id, Set<Id>>();
        for (Integer i = 0; i < newGifts.size(); i++) {
            Id donorId = newAccounts[giftDonorIdx[i]].Id;
            Id campId = newGifts[i].CampaignId;
            if (campId == null) continue;
            if ('Events'.equals(campaignCategoryById.get(campId))) continue;
            if (!giftCampaignsByDonor.containsKey(donorId)) giftCampaignsByDonor.put(donorId, new Set<Id>());
            giftCampaignsByDonor.get(donorId).add(campId);
        }
        // Initial status = 'Solicited' (baseline ladder's first rung, seeded by
        // FQS_Campaign_Member_Status_Ladder on Campaign insert). When the
        // FQS_Campaign_Member_Status_On_Gift flow is deployed, each preceding gift insert
        // has already created/updated the CM at 'Pledged/Gave' and this loop dedupes on the
        // (CampaignId, ContactId) unique constraint — the seeded 'Solicited' write becomes
        // a no-op. When the flow is NOT deployed, this loop leaves the donor at 'Solicited'
        // so the status-transition path (Solicited → Pledged/Gave) is testable end-to-end
        // once the flow lands.
        List<CampaignMember> newCMs = new List<CampaignMember>();
        for (Id donorId : giftCampaignsByDonor.keySet()) {
            Id contactId = personContactByAccount.get(donorId);
            if (contactId == null) continue;
            for (Id campId : giftCampaignsByDonor.get(donorId)) {
                newCMs.add(new CampaignMember(
                    ContactId = contactId,
                    CampaignId = campId,
                    Status = 'Solicited'
                ));
            }
        }
        // CampaignMember has a (CampaignId, ContactId) unique constraint. Allpartialsuccess
        // + swallow the dupes so idempotent re-seed doesn't blow up.
        if (!newCMs.isEmpty()) {
            Database.SaveResult[] cmResults = Database.insert(newCMs, false);
            Integer cmInserted = 0;
            Integer cmDuped = 0;
            for (Database.SaveResult sr : cmResults) {
                if (sr.isSuccess()) cmInserted++;
                else if (!sr.getErrors().isEmpty() && sr.getErrors()[0].getStatusCode() == StatusCode.DUPLICATE_VALUE) cmDuped++;
            }
            System.debug('CampaignMembers inserted: ' + cmInserted + ' (skipped ' + cmDuped + ' dupes)');
        }

        List<GiftTransaction> corpMatchGifts = new List<GiftTransaction>();
        for (Integer i = 0; i < newGifts.size(); i++) {
            Integer scenario = giftMatchScenario[i];
            if (scenario != 1 && scenario != 2) continue;
            Integer di = giftDonorIdx[i];
            Integer g = giftIndexInDonor[i];
            Integer globalIdx = batchOffset + di;
            Integer empIdx = employerIdxByDonor[di];
            if (empIdx < 0) continue;
            Id employerId = corpEmployers[empIdx].Id;

            Decimal empGiftAmount = newGifts[i].OriginalAmount;
            Decimal matchPct = randBool(globalIdx, 700 + g, 0.5) ? 1.0 : 0.5;
            Decimal matchAmount = roundTo5(empGiftAmount * matchPct);
            if (matchAmount < 5) matchAmount = 5;

            Date empTxnDate = newGifts[i].TransactionDate;
            Date corpTxnDate = empTxnDate.addDays(randInt(globalIdx, 701 + g, 15, 45));

            // §11.3 — corp match targets the year-end email ask in the SAME FY as the employee gift.
            Id corpCampId = yearendAskByFY.get(giftFY[i]);
            // External Id must be unique — post-refactor a single donor can have a ladder GT
            // AND a one-off GT sharing the same giftIndexInDonor value. Use the global new-gifts
            // index `i` as the suffix instead so the corp-match row is guaranteed unique.
            corpMatchGifts.add(new GiftTransaction(
                External_Id__c = 'FQS-GT-CORP-' + RUN_STAMP + '-' + globalIdx + '-' + i,
                Name = donorLabel(corpEmployers[empIdx]) + ' match - ' + fmtAmt(matchAmount) + ' on ' + String.valueOf(corpTxnDate),
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
                CampaignId = corpCampId,
                FQS_Matched__c = true
            ));
        }
        if (!corpMatchGifts.isEmpty()) insert corpMatchGifts;

        // Fee/Payment GTs land on an Earned Revenue designation so reports that group by
        // FQS_Restriction_Type__c separate exchange-transaction revenue from contribution
        // revenue. All other GTs round-robin across allDesignationIds (contribution
        // designations only — Earned Revenue designations are excluded from that pool).
        // ~15% of contribution GTs split across two designations (60/40) to exercise the
        // launcher's split-designation shape and multi-GTD report groupings. Fee/Payment
        // GTs always stay single-designation (exchange transactions aren't split in practice).
        List<GiftTransactionDesignation> newGTDs = new List<GiftTransactionDesignation>();
        for (Integer i = 0; i < newGifts.size(); i++) {
            GiftTransaction gt = newGifts[i];
            Integer di = giftDonorIdx[i];
            Integer globalIdx = batchOffset + di;
            Boolean isFee = 'Fee/Payment'.equals(giftCategory[i]);
            Boolean splitDesignation = !isFee && allDesignationIds.size() >= 2
                && randBool(globalIdx, 220 + i, 0.15);
            if (splitDesignation) {
                Id gdA = allDesignationIds[Math.mod(prng(globalIdx, 221 + i), allDesignationIds.size())];
                Id gdB = allDesignationIds[Math.mod(prng(globalIdx, 222 + i), allDesignationIds.size())];
                if (gdA == gdB) gdB = allDesignationIds[Math.mod(prng(globalIdx, 222 + i) + 1, allDesignationIds.size())];
                Decimal amtA = (gt.OriginalAmount * 0.60).setScale(2);
                Decimal amtB = (gt.OriginalAmount - amtA).setScale(2);
                newGTDs.add(new GiftTransactionDesignation(
                    External_Id__c = 'FQS-GTD-' + RUN_STAMP + '-' + globalIdx + '-' + i + '-a',
                    GiftTransactionId = gt.Id,
                    GiftDesignationId = gdA,
                    Amount = amtA,
                    Percent = 60));
                newGTDs.add(new GiftTransactionDesignation(
                    External_Id__c = 'FQS-GTD-' + RUN_STAMP + '-' + globalIdx + '-' + i + '-b',
                    GiftTransactionId = gt.Id,
                    GiftDesignationId = gdB,
                    Amount = amtB,
                    Percent = 40));
            } else {
                Id gdId;
                if (isFee && !feeDesignationIds.isEmpty()) {
                    gdId = feeDesignationIds[Math.mod(prng(globalIdx, 201 + i), feeDesignationIds.size())];
                } else {
                    gdId = allDesignationIds[Math.mod(prng(globalIdx, 200 + i), allDesignationIds.size())];
                }
                // External_Id must be globally unique per GTD. The ladder + one-off refactor
                // introduced overlapping `giftIndexInDonor` values (both restart at 0), so key
                // off the flat newGifts index `i` instead of `g` to guarantee uniqueness.
                newGTDs.add(new GiftTransactionDesignation(
                    External_Id__c = 'FQS-GTD-' + RUN_STAMP + '-' + globalIdx + '-' + i,
                    GiftTransactionId = gt.Id,
                    GiftDesignationId = gdId,
                    Amount = gt.OriginalAmount,
                    Percent = 100));
            }
        }
        insert newGTDs;

        List<GiftSoftCredit> newSoftCredits = new List<GiftSoftCredit>();
        List<String> softCreditRoles = new List<String>{'Solicitor','Matched Donor','Honoree','Household Member'};
        for (Integer i = 0; i < newGifts.size(); i++) {
            Integer di = giftDonorIdx[i];
            Integer g = giftIndexInDonor[i];
            Integer globalIdx = batchOffset + di;
            if (!randBool(globalIdx, 300 + i, PROB_SOFT_CREDIT)) continue;
            Integer recipIdx = Math.mod(prng(globalIdx, 301 + i), donorCount);
            if (recipIdx == di) recipIdx = Math.mod(recipIdx + 1, donorCount);
            newSoftCredits.add(new GiftSoftCredit(
                External_Id__c = 'FQS-GSC-' + RUN_STAMP + '-' + globalIdx + '-' + i + '-' + recipIdx,
                GiftTransactionId = newGifts[i].Id,
                RecipientId = newAccounts[recipIdx].Id,
                Role = softCreditRoles[Math.mod(prng(globalIdx, 302 + i), softCreditRoles.size())],
                PartialPercent = 100));
        }
        if (!newSoftCredits.isEmpty()) insert newSoftCredits;

        List<GiftTribute> newTributes = new List<GiftTribute>();
        List<String> tributeFirstNames = new List<String>{'Margaret','Elizabeth','Charles','Robert','Frank','Dorothy','Helen','George','Ruth','Walter'};
        for (Integer i = 0; i < newGifts.size(); i++) {
            Integer di = giftDonorIdx[i];
            Integer g = giftIndexInDonor[i];
            Integer globalIdx = batchOffset + di;
            if (!randBool(globalIdx, 400 + i, PROB_TRIBUTE)) continue;
            Boolean isMemorial = randBool(globalIdx, 401 + i, 0.30);
            String honoree = tributeFirstNames[Math.mod(prng(globalIdx, 402 + i), tributeFirstNames.size())]
                + ' ' + lastNames[Math.mod(prng(globalIdx, 403 + i), lastNames.size())];
            newTributes.add(new GiftTribute(
                External_Id__c = 'FQS-GTR-' + RUN_STAMP + '-' + globalIdx + '-' + i,
                TributeType = isMemorial ? 'Memorial' : 'Honor',
                HonoreeName = honoree,
                GiftTransactionId = newGifts[i].Id,
                NotificationChannel = randBool(globalIdx, 404 + i, 0.6) ? 'Email' : 'Mail',
                NotificationStatus = randBool(globalIdx, 405 + i, 0.5) ? 'Sent' : 'To Be Sent'));
        }
        if (!newTributes.isEmpty()) insert newTributes;

        List<GiftRefund> newRefunds = new List<GiftRefund>();
        List<String> refundStatuses = new List<String>{'Initiated','Completed','Completed','Failed'};
        List<String> refundReasons = new List<String>{
            'Donor Request','Incorrect Amount','Duplicate Gift',
            'Match Correction','Bounced Check','Chargeback'
        };
        for (Integer i = 0; i < newGifts.size(); i++) {
            if (!giftIsPaid[i]) continue;
            Integer di = giftDonorIdx[i];
            Integer g = giftIndexInDonor[i];
            Integer globalIdx = batchOffset + di;
            if (!randBool(globalIdx, 500 + i, PROB_REFUND)) continue;
            Decimal refundAmt = newGifts[i].OriginalAmount * randRange(globalIdx, 501 + i, 0.5, 1.0);
            newRefunds.add(new GiftRefund(
                External_Id__c = 'FQS-GR-' + RUN_STAMP + '-' + globalIdx + '-' + i,
                GiftTransactionId = newGifts[i].Id,
                Amount = refundAmt.setScale(2),
                Date = newGifts[i].TransactionDate.addDays(randInt(globalIdx, 502 + i, 1, 60)),
                Status = refundStatuses[Math.mod(prng(globalIdx, 503 + i), refundStatuses.size())],
                Reason = refundReasons[Math.mod(prng(globalIdx, 504 + i), refundReasons.size())]));
        }
        if (!newRefunds.isEmpty()) insert newRefunds;

        // §12.3 — cross-household ContactContactRelations. Deterministic pairing (donor N
        // with donor N+1, striding by 2) guarantees pairs cross household Accounts, which is
        // what the launcher's soft-credit "reach a different Account via CCR" branch needs.
        // Pairs distribute across five role-typed PartyRoleRelations (Spouse, Parent/Child,
        // Sibling, Friend, Neighbor) so the launcher's role-typed reach has coverage on every
        // pair. Every seeded pair gets at least one entry; role selection round-robins by
        // pair-index for determinism.
        Map<String, Id> prrIdByKey = new Map<String, Id>();
        for (PartyRoleRelation prr : [
            SELECT Id, RoleName, RelatedRoleName FROM PartyRoleRelation
            WHERE RelationshipObjectName = 'Contact_Contact_Relationship'
              AND RoleName IN ('Spouse','Parent','Sibling','Friend','Neighbor')
        ]) {
            prrIdByKey.put(prr.RoleName + '-' + prr.RelatedRoleName, prr.Id);
        }
        // Round-robin role plan. Ordered so the first ~5 pairs deterministically cover every
        // role at least once; subsequent pairs cycle. Parent-Child intentionally uses two
        // distinct role names so ShouldCreaInversRoleAuto=true generates the inverse.
        List<String> ccrRolePlan = new List<String>{
            'Spouse-Spouse',
            'Parent-Child',
            'Sibling-Sibling',
            'Friend-Friend',
            'Neighbor-Neighbor'
        };
        List<ContactContactRelation> newCCRs = new List<ContactContactRelation>();
        // Track paired Account IDs by roleKey so downstream GDSC seeding can recognize
        // e.g. a donor's spouse Account (Spouse-Spouse) or friend Account (Friend-Friend).
        // Key = donor Account Id → List<Map>{ 'role': roleKey, 'partnerAccount': relatedAccountId }
        Map<Id, List<Map<String, Object>>> partnersByDonorAccount = new Map<Id, List<Map<String, Object>>>();
        if (!prrIdByKey.isEmpty()) {
            List<Id> paContactIds = new List<Id>();
            List<Id> paAccountIds = new List<Id>();  // 1:1 with paContactIds
            for (Integer i = 0; i < newAccounts.size(); i++) {
                if (newAccounts[i].RecordTypeId != personAccountRT) continue;
                Id ct = personContactByAccount.get(newAccounts[i].Id);
                if (ct != null) { paContactIds.add(ct); paAccountIds.add(newAccounts[i].Id); }
            }
            // Guarantee at least one pair per role when donor pool allows; otherwise pair a
            // conservative ~10% of PAs (each pair covers 2).
            Integer minPairsForCoverage = ccrRolePlan.size();
            Integer pairCount = Math.max(minPairsForCoverage, paContactIds.size() / 20);
            for (Integer p = 0; p < pairCount; p++) {
                Integer a = p * 2;
                Integer b = p * 2 + 1;
                if (b >= paContactIds.size()) break;
                if (paContactIds[a] == paContactIds[b]) continue;
                String roleKey = ccrRolePlan[Math.mod(p, ccrRolePlan.size())];
                Id prrId = prrIdByKey.get(roleKey);
                if (prrId == null) continue;  // missing PRR — skip rather than fabricate wrong role
                newCCRs.add(new ContactContactRelation(
                    ContactId = paContactIds[a],
                    RelatedContactId = paContactIds[b],
                    IsActive = true,
                    PartyRoleRelationId = prrId
                ));
                // Real-world data carries both directions; insert the inverse row too so the
                // launcher's soft-credit reach subflow (which walks ContactId → RelatedContactId)
                // surfaces the partner from either donor's Account.
                newCCRs.add(new ContactContactRelation(
                    ContactId = paContactIds[b],
                    RelatedContactId = paContactIds[a],
                    IsActive = true,
                    PartyRoleRelationId = prrId
                ));
                // Record both directions so a lookup by either donor finds their partner.
                if (!partnersByDonorAccount.containsKey(paAccountIds[a])) partnersByDonorAccount.put(paAccountIds[a], new List<Map<String, Object>>());
                if (!partnersByDonorAccount.containsKey(paAccountIds[b])) partnersByDonorAccount.put(paAccountIds[b], new List<Map<String, Object>>());
                partnersByDonorAccount.get(paAccountIds[a]).add(new Map<String, Object>{'role' => roleKey, 'partnerAccount' => paAccountIds[b]});
                partnersByDonorAccount.get(paAccountIds[b]).add(new Map<String, Object>{'role' => roleKey, 'partnerAccount' => paAccountIds[a]});
            }
            if (!newCCRs.isEmpty()) {
                try {
                    insert newCCRs;
                    System.debug('CCRs inserted: ' + newCCRs.size() + ' (roles rotating over ' + ccrRolePlan.size() + ' PRRs)');
                }
                catch (DmlException e) { System.debug('CCR insert FAILED — likely picklist/permission: ' + e.getMessage()); }
            }
        } else {
            System.debug('No FQS PartyRoleRelations found — skipping CCR seeding. Re-run foundation.');
        }

        // §12.4 — GiftDefaultSoftCredit on GC + Opportunity so the launcher's soft-credit
        // "reach a different Account via CCR" branch and the report groupings have live data.
        // Parent polymorphism: ParentRecordId → Campaign / GiftCommitment / Opportunity ONLY.
        // Recipient rules (aim for real-world defensibility; skip when the semantics don't fit):
        //   - Recurring OR Pledged GC (Individual) + Immediate-family CCR
        //     (Spouse/Parent/Sibling) → 'Household Member', PartialPercent=100. Every scheduled
        //     payment auto-credits the household member.
        //   - Recurring OR Pledged GC (Individual) + Friend-Friend CCR → 'Solicitor',
        //     PartialPercent=100. Friend introduced the donor; recognition rides every payment.
        //   - Recurring OR Pledged GC (Individual) + Neighbor-Neighbor CCR → 'Influencer',
        //     PartialPercent=100. Recognition without a formal solicitor claim.
        //   - Major Gift Opp (Individual) + Spouse/Parent/Sibling CCR → 'Household Member',
        //     PartialPercent=100. Household recognition follows the pipeline.
        //   - Grant GC (Org donor) → skip. Corp-side match GDSCs are the matching-gift flow's
        //     job, not the base seed's.
        //   - Grant Opp (Org donor) → skip. No linked individual to credit at seed time.
        //   - Outright/one-off GTs, Fee/Payment → no GDSC (GDSC is a default; one-offs have
        //     no downstream GT that would inherit).
        // Dedupe key inside this transaction is (ParentRecordId, RecipientId, Role).
        List<GiftDefaultSoftCredit> newGDSCs = new List<GiftDefaultSoftCredit>();
        Set<String> gdscKeySeen = new Set<String>();
        Set<String> householdCcrRoles = new Set<String>{'Spouse-Spouse','Parent-Child','Sibling-Sibling'};
        for (Integer ci = 0; ci < newCommitments.size(); ci++) {
            GiftCommitment gc = newCommitments[ci];
            String cKind = commitmentKind[ci];  // 'recurring' / 'pledged' / 'grant-onetime' / 'grant-multiyear' / 'grant-custom'
            if (cKind.startsWith('grant')) continue;
            List<Map<String, Object>> partners = partnersByDonorAccount.get(gc.DonorId);
            if (partners == null) continue;
            for (Map<String, Object> pr : partners) {
                String roleKey = (String) pr.get('role');
                Id partnerAcctId = (Id) pr.get('partnerAccount');
                String gdscRole = null;
                if (householdCcrRoles.contains(roleKey))       gdscRole = 'Household Member';
                else if ('Friend-Friend'.equals(roleKey))      gdscRole = 'Solicitor';
                else if ('Neighbor-Neighbor'.equals(roleKey))  gdscRole = 'Influencer';
                if (gdscRole == null) continue;
                String dedupeKey = String.valueOf(gc.Id) + '|' + String.valueOf(partnerAcctId) + '|' + gdscRole;
                if (gdscKeySeen.contains(dedupeKey)) continue;
                gdscKeySeen.add(dedupeKey);
                newGDSCs.add(new GiftDefaultSoftCredit(
                    ParentRecordId = gc.Id,
                    RecipientId = partnerAcctId,
                    Role = gdscRole,
                    PartialPercent = 100
                ));
            }
        }
        // Opp branch: Major Gift RT + household CCR → household recognition on the pipeline.
        for (Opportunity opp : newOpps) {
            if (opp.RecordTypeId != oppMajorGiftRT) continue;
            List<Map<String, Object>> partners = partnersByDonorAccount.get(opp.AccountId);
            if (partners == null) continue;
            for (Map<String, Object> pr : partners) {
                if (!householdCcrRoles.contains((String) pr.get('role'))) continue;
                Id partnerAcctId = (Id) pr.get('partnerAccount');
                String dedupeKey = String.valueOf(opp.Id) + '|' + String.valueOf(partnerAcctId) + '|Household Member';
                if (gdscKeySeen.contains(dedupeKey)) continue;
                gdscKeySeen.add(dedupeKey);
                newGDSCs.add(new GiftDefaultSoftCredit(
                    ParentRecordId = opp.Id,
                    RecipientId = partnerAcctId,
                    Role = 'Household Member',
                    PartialPercent = 100
                ));
            }
        }
        if (!newGDSCs.isEmpty()) {
            try {
                insert newGDSCs;
                System.debug('GiftDefaultSoftCredits inserted: ' + newGDSCs.size());
            } catch (DmlException e) {
                System.debug('GDSC insert FAILED: ' + e.getMessage());
            }
        } else {
            System.debug('No GDSCs to seed (no matching CCR + commitment/opp pairs found).');
        }

        Integer total = newAccounts.size() + newCommitments.size() + newSchedules.size()
            + newOpps.size() + newPIs.size() + newGifts.size() + corpMatchGifts.size()
            + newGTDs.size() + newSoftCredits.size() + newTributes.size() + newRefunds.size()
            + newGDDs.size() + newGDSCs.size();
        System.debug('=== Chunk complete (offset ' + batchOffset + '): ' + total + ' records ('
            + 'accounts=' + newAccounts.size()
            + ', commits=' + newCommitments.size()
            + ', scheds=' + newSchedules.size()
            + ', GDDs=' + newGDDs.size()
            + ', GDSCs=' + newGDSCs.size()
            + ', opps=' + newOpps.size()
            + ', PIs=' + newPIs.size()
            + ', GTs=' + newGifts.size()
            + ', corpGTs=' + corpMatchGifts.size()
            + ', GTDs=' + newGTDs.size()
            + ', SCs=' + newSoftCredits.size()
            + ', tribs=' + newTributes.size()
            + ', refunds=' + newRefunds.size()
            + ') ===');
    }
}
