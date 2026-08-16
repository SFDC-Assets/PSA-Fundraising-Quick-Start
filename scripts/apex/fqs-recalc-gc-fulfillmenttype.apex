// FQS post-migration reconciler for GiftCommitment.FulfillmentType.
//
// Purpose: when a migration/data-loader user holds the FQS Bypass Automation permset, the
// FQS_GC_Fulfillment_On_Change / FQS_GC_Fulfillment_From_GDD / FQS_GC_Fulfillment_From_GDD_Delete
// flows skip execution, so FulfillmentType may not reflect the loaded GDD population or release
// date. This script walks every GC, applies the same OR rule that the flow subflow implements,
// and writes back only when the value differs (idempotent).
//
// Rule (matches FQS_Recalculate_GC_FulfillmentType): FulfillmentType = 'Conditional' if ANY child
// GDD has FQS_Restriction_Type__c != 'Without Donor Restriction' (Purpose, Permanent, or
// Earned Revenue) OR GC.FQS_Restriction_Release_Date__c is populated; otherwise 'Unconditional'.
//
// Batching: chunked to 200 GCs per DML pass to stay well under governor limits. Adjust CHUNK_SIZE
// if the org has GCs beyond typical batch scaling. Runs sync — invoke from anonymous Apex or
// wrap in a Batchable for very large orgs.

Integer CHUNK_SIZE = 200;
Integer scanned = 0;
Integer updated = 0;

Map<Id, GiftCommitment> gcById = new Map<Id, GiftCommitment>([
    SELECT Id, FulfillmentType, FQS_Restriction_Release_Date__c
    FROM GiftCommitment
]);

if (gcById.isEmpty()) {
    System.debug('No GiftCommitment records found — nothing to reconcile.');
    return;
}

Map<Id, Boolean> gcHasRestrictedGDD = new Map<Id, Boolean>();
for (Id gcId : gcById.keySet()) {
    gcHasRestrictedGDD.put(gcId, false);
}

for (GiftDefaultDesignation gdd : [
    SELECT Id, ParentRecordId, FQS_Restriction_Type__c
    FROM GiftDefaultDesignation
    WHERE ParentRecordId IN :gcById.keySet()
      AND FQS_Restriction_Type__c != NULL
      AND FQS_Restriction_Type__c != 'Without Donor Restriction'
]) {
    gcHasRestrictedGDD.put(gdd.ParentRecordId, true);
}

List<GiftCommitment> toUpdate = new List<GiftCommitment>();
for (GiftCommitment gc : gcById.values()) {
    scanned++;
    Boolean isConditional = gcHasRestrictedGDD.get(gc.Id) || gc.FQS_Restriction_Release_Date__c != null;
    String target = isConditional ? 'Conditional' : 'Unconditional';
    if (gc.FulfillmentType != target) {
        gc.FulfillmentType = target;
        toUpdate.add(gc);
    }
}

System.debug('Scanned ' + scanned + ' GCs; ' + toUpdate.size() + ' need FulfillmentType update.');

while (!toUpdate.isEmpty()) {
    Integer sliceEnd = Math.min(CHUNK_SIZE, toUpdate.size());
    List<GiftCommitment> chunk = new List<GiftCommitment>();
    for (Integer i = 0; i < sliceEnd; i++) {
        chunk.add(toUpdate.remove(0));
    }
    Database.SaveResult[] results = Database.update(chunk, false);
    for (Integer i = 0; i < results.size(); i++) {
        if (results[i].isSuccess()) {
            updated++;
        } else {
            System.debug(LoggingLevel.ERROR, 'Failed to update GC ' + chunk[i].Id + ': ' + results[i].getErrors());
        }
    }
}

System.debug('Reconcile complete: ' + updated + ' GCs updated out of ' + scanned + ' scanned.');
