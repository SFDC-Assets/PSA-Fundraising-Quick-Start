// UAT seed for the Earned Revenue auto-route landed 2026-08-14.
// Produces the minimum viable state to walk the Guided Gift Entry launcher through
// the Earned Income leaf and observe the auto-select / picker / fallback behavior
// against real seeded FQS-GD-* Earned Revenue designations.
//
// Idempotent — uses External_Id__c on Account so re-running is safe.
// Cleanup: run `sf data delete record --sobject Account --where "External_Id__c='FQS-UAT-EARNED-REV-001'" --target-org fundfirst`
// (Person Account cascade removes the shadow Contact automatically).

System.debug('=== UAT Earned Revenue seed starting ===');

// Person Account record type
Id personAccountRT;
try {
    personAccountRT = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName='PersonAccount' AND IsActive=true LIMIT 1].Id;
} catch (Exception e) {
    throw new System.NoAccessException(); // PersonAccount record type not found — this org lacks Person Accounts.
}

// 1) One Person Account donor (idempotent via External_Id__c)
Account donor = new Account(
    FirstName = 'Riley',
    LastName = 'Everett',
    PersonEmail = 'riley.everett@example.com',
    RecordTypeId = personAccountRT,
    External_Id__c = 'FQS-UAT-EARNED-REV-001'
);
upsert donor External_Id__c;
System.debug('Donor: ' + donor.Id + ' (' + donor.FirstName + ' ' + donor.LastName + ')');

// 2) Sanity check — confirm at least one Active Earned Revenue GD exists.
List<GiftDesignation> earnedRevGDs = [
    SELECT Id, Name FROM GiftDesignation
    WHERE FQS_Restriction_Type__c='Earned Revenue' AND IsActive=true
];
if (earnedRevGDs.isEmpty()) {
    System.debug('WARNING: no active Earned Revenue GDs — launcher will fall through to org default. Run fqs-seed-foundation.apex first.');
} else {
    System.debug('Earned Revenue GDs available (' + earnedRevGDs.size() + '):');
    for (GiftDesignation gd : earnedRevGDs) {
        System.debug('  - ' + gd.Name + ' (' + gd.Id + ')');
    }
}

// 3) Grab any active FQS Campaign for the launcher's Campaign picker to render.
//    (Not required for the auto-route to fire — the auto-route runs AFTER Campaign selection.)
List<Campaign> campaigns = [SELECT Id, Name FROM Campaign WHERE IsActive=true ORDER BY CreatedDate DESC LIMIT 3];
System.debug('Active campaigns available for picker (' + campaigns.size() + '):');
for (Campaign c : campaigns) {
    System.debug('  - ' + c.Name + ' (' + c.Id + ')');
}

System.debug('=== UAT seed complete ===');
System.debug('');
System.debug('Next steps in the UI:');
System.debug('  1. Open Account ' + donor.Id + ' (' + donor.FirstName + ' ' + donor.LastName + ') in FundFirst.');
System.debug('  2. Click the "Guided Gift Entry" quick action.');
System.debug('  3. Category = Special → Leaf = Earned Income.');
System.debug('  4. Complete Gift Details + Campaign screens.');
System.debug('  5. Confirm the resolver:');
if (earnedRevGDs.size() == 1) {
    System.debug('     - Exactly one Earned Revenue GD → expect Confirm_Designation SKIPPED, land on Success screen. Resolved GD should be "' + earnedRevGDs[0].Name + '".');
} else if (earnedRevGDs.size() > 1) {
    System.debug('     - ' + earnedRevGDs.size() + ' Earned Revenue GDs → expect Pick_Designation to render, filtered to just those rows (Restriction column = "Earned Revenue").');
} else {
    System.debug('     - Zero Earned Revenue GDs → expect fall-through to Confirm_Designation with org-default GD.');
}
System.debug('  6. On Success, verify: GT.FQS_Gift_Transaction_Category__c = "Other" AND GiftTransactionDesignation.GiftDesignation.FQS_Restriction_Type__c = "Earned Revenue".');
System.debug('  7. Repeat with Category = Special → Leaf = Event Registration to verify the second auto-routed leaf.');
