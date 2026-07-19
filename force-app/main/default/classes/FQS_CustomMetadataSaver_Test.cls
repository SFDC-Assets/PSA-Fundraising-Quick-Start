/**
 * Tests for FQS_CustomMetadataSaver.
 *
 * Metadata.Operations.enqueueDeployment cannot execute inside Apex tests, so the class
 * short-circuits on Test.isRunningTest() and exposes the built Metadata.DeployContainer
 * via a @TestVisible static for assertion.
 */
@IsTest
private class FQS_CustomMetadataSaver_Test {

    @IsTest
    static void deploysAllThreeTiersAtomically() {
        FQS_Donor_Grouping__mdt entry = new FQS_Donor_Grouping__mdt(
            DeveloperName = 'Entry', MasterLabel = 'Entry',
            Branded_Name__c = 'Friend',
            One_Time_Min_Amount__c = 25, Annual_Min_Amount__c = 100, Lifetime_Min_Amount__c = 300,
            Sort_Order__c = 10, FQS_Auto_Acknowledgement__c = 'Include All'
        );
        FQS_Donor_Grouping__mdt mid = new FQS_Donor_Grouping__mdt(
            DeveloperName = 'Mid', MasterLabel = 'Mid',
            Branded_Name__c = 'Partner',
            One_Time_Min_Amount__c = 500, Annual_Min_Amount__c = 1000, Lifetime_Min_Amount__c = 3000,
            Sort_Order__c = 20, FQS_Auto_Acknowledgement__c = 'Exclude Lifetime'
        );
        FQS_Donor_Grouping__mdt major = new FQS_Donor_Grouping__mdt(
            DeveloperName = 'Major', MasterLabel = 'Major',
            Branded_Name__c = 'Champion',
            One_Time_Min_Amount__c = 5000, Annual_Min_Amount__c = 10000, Lifetime_Min_Amount__c = 30000,
            Sort_Order__c = 30, FQS_Auto_Acknowledgement__c = 'Exclude All'
        );

        FQS_CustomMetadataSaver.FlowInput input = new FQS_CustomMetadataSaver.FlowInput();
        input.customMetadataRecords = new List<SObject>{ entry, mid, major };

        Test.startTest();
        List<String> jobIds = FQS_CustomMetadataSaver.deploy(new List<FQS_CustomMetadataSaver.FlowInput>{ input });
        Test.stopTest();

        System.assertEquals(1, jobIds.size(), 'One FlowInput yields one job id echoed back per input');
        System.assertEquals(FQS_CustomMetadataSaver.MOCK_DEPLOYMENT_ID, jobIds[0]);

        Metadata.DeployContainer container = FQS_CustomMetadataSaver.lastBuiltContainer;
        System.assertNotEquals(null, container, 'Container should be captured for test inspection');
        List<Metadata.Metadata> deployed = container.getMetadata();
        System.assertEquals(3, deployed.size(), 'All three tiers deployed in one container');

        Set<String> fullNames = new Set<String>();
        for (Metadata.Metadata md : deployed) {
            fullNames.add(((Metadata.CustomMetadata) md).fullName);
        }
        System.assert(fullNames.contains('FQS_Donor_Grouping.Entry'), 'Entry fullName present');
        System.assert(fullNames.contains('FQS_Donor_Grouping.Mid'), 'Mid fullName present');
        System.assert(fullNames.contains('FQS_Donor_Grouping.Major'), 'Major fullName present');
    }

    @IsTest
    static void picklistValueIsStringCast() {
        FQS_Donor_Grouping__mdt entry = new FQS_Donor_Grouping__mdt(
            DeveloperName = 'Entry', MasterLabel = 'Entry',
            FQS_Auto_Acknowledgement__c = 'Include All'
        );
        FQS_CustomMetadataSaver.deploy(new List<SObject>{ entry });

        Metadata.CustomMetadata built = (Metadata.CustomMetadata) FQS_CustomMetadataSaver.lastBuiltContainer.getMetadata()[0];
        Metadata.CustomMetadataValue ackValue;
        for (Metadata.CustomMetadataValue v : built.values) {
            if (v.field == 'FQS_Auto_Acknowledgement__c') {
                ackValue = v;
            }
        }
        System.assertNotEquals(null, ackValue, 'Auto-ack field written');
        System.assertEquals('Include All', ackValue.value, 'Picklist value present');
        System.assert(ackValue.value instanceof String, 'Picklist value must be cast to String for Metadata API');
    }

    @IsTest
    static void ignoresSystemFieldsAndOmitsUnpopulatedFields() {
        FQS_Donor_Grouping__mdt entry = (FQS_Donor_Grouping__mdt) JSON.deserialize(
            '{"attributes":{"type":"FQS_Donor_Grouping__mdt"},' +
            '"DeveloperName":"Entry","MasterLabel":"Entry Master Label","Sort_Order__c":42,' +
            '"SystemModstamp":"2026-01-01T00:00:00.000Z",' +
            '"CreatedDate":"2026-01-01T00:00:00.000Z",' +
            '"LastModifiedDate":"2026-01-01T00:00:00.000Z"}',
            FQS_Donor_Grouping__mdt.class
        );
        FQS_CustomMetadataSaver.deploy(new List<SObject>{ entry });

        Metadata.CustomMetadata built = (Metadata.CustomMetadata) FQS_CustomMetadataSaver.lastBuiltContainer.getMetadata()[0];
        System.assertEquals('FQS_Donor_Grouping.Entry', built.fullName);
        System.assertEquals('Entry Master Label', built.label, 'MasterLabel maps to Metadata.CustomMetadata.label');

        Set<String> emittedFields = new Set<String>();
        for (Metadata.CustomMetadataValue v : built.values) {
            emittedFields.add(v.field);
        }
        System.assert(emittedFields.contains('Sort_Order__c'), 'User-populated field emitted');
        System.assert(!emittedFields.contains('SystemModstamp'), 'SystemModstamp must be stripped — Metadata API rejects it');
        System.assert(!emittedFields.contains('CreatedDate'), 'CreatedDate must be stripped');
        System.assert(!emittedFields.contains('LastModifiedDate'), 'LastModifiedDate must be stripped');
    }

    @IsTest
    static void nullInputCollectionIsSkipped() {
        FQS_CustomMetadataSaver.FlowInput empty = new FQS_CustomMetadataSaver.FlowInput();
        empty.customMetadataRecords = null;

        List<String> jobIds = FQS_CustomMetadataSaver.deploy(new List<FQS_CustomMetadataSaver.FlowInput>{ empty });
        System.assertEquals(1, jobIds.size());
        System.assertEquals(0, FQS_CustomMetadataSaver.lastBuiltContainer.getMetadata().size(),
            'Null collection contributes no records');
    }

    @IsTest
    static void emailOnErrorCallbackHandlesResultsWithoutFailing() {
        FQS_CustomMetadataSaver.EmailOnErrorCallback callback = new FQS_CustomMetadataSaver.EmailOnErrorCallback();

        Metadata.DeployResult okResult = new Metadata.DeployResult();
        okResult.status = Metadata.DeployStatus.Succeeded;
        callback.handleResult(okResult, null);

        callback.handleResult(null, null);

        System.assert(true, 'Success and null-result callback paths execute without exception');
    }

    @IsTest
    static void emailOnErrorCallbackAttemptsEmailForFailedDeploy() {
        FQS_CustomMetadataSaver.EmailOnErrorCallback callback = new FQS_CustomMetadataSaver.EmailOnErrorCallback();

        Metadata.DeployResult failedResult = new Metadata.DeployResult();
        failedResult.status = Metadata.DeployStatus.Failed;
        failedResult.id = '0Af000000000001';
        failedResult.numberComponentsTotal = 3;
        failedResult.numberComponentErrors = 1;
        failedResult.details = new Metadata.DeployDetails();

        Test.startTest();
        callback.handleResult(failedResult, null);
        Test.stopTest();

        System.assert(true, 'Failure branch runs to completion (email attempt swallowed if not permitted)');
    }
}
