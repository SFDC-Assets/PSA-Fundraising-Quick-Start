/**
 * Bridge between Flow and the Metadata API for Custom Metadata Type writes.
 *
 * Flow builds one or more __mdt SObject records (via Get Records + Assignment) and hands them to
 * this invocable, which consolidates every populated field into a single Metadata.DeployContainer
 * and enqueues it asynchronously. Picklist values are string-cast per Salesforce Metadata API
 * requirement; system fields (DeveloperName, Id, Label, MasterLabel, Language, NamespacePrefix,
 * QualifiedApiName) are excluded so they can't clobber existing values.
 *
 * On async deploy failure the running user receives an email (SingleEmailMessage, one org limit
 * tick). Success is silent — the calling Flow's confirmation screen tells the admin to check
 * Setup → Deployment Status.
 *
 * ─────────────────────────────────────────────────────────────────────────────────────────
 * Adapted from Jonathan Gillespie's CustomMetadataSaver
 * (https://github.com/jongpie/CustomMetadataSaver) — scoped down to FQS needs (no custom
 * callback dispatch, no email-on-success option, no consolidated deployment IDs list).
 *
 * Original license:
 *
 *   MIT License
 *
 *   Copyright (c) 2021 Jonathan Gillespie
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy
 *   of this software and associated documentation files (the "Software"), to deal
 *   in the Software without restriction, including without limitation the rights
 *   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *   copies of the Software, and to permit persons to whom the Software is
 *   furnished to do so, subject to the following conditions:
 *
 *   The above copyright notice and this permission notice shall be included in all
 *   copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *   SOFTWARE.
 * ─────────────────────────────────────────────────────────────────────────────────────────
 */
public inherited sharing class FQS_CustomMetadataSaver {

    private static final Set<String> IGNORED_FIELD_NAMES = new Set<String>{
        'DeveloperName', 'Id', 'Label', 'Language', 'MasterLabel', 'NamespacePrefix', 'QualifiedApiName',
        'CreatedById', 'CreatedDate', 'LastModifiedById', 'LastModifiedDate', 'SystemModstamp', 'IsProtected'
    };

    @TestVisible
    private static final String MOCK_DEPLOYMENT_ID = 'mockDeploymentId';

    @TestVisible
    private static Metadata.DeployContainer lastBuiltContainer;

    public class FlowInput {
        @InvocableVariable(required=true label='Custom Metadata Records to Deploy'
            description='Collection of __mdt SObject records with populated fields to write.')
        public List<SObject> customMetadataRecords;
    }

    private FQS_CustomMetadataSaver() {
        // static only
    }

    @InvocableMethod(
        category='FQS'
        label='Save FQS Custom Metadata Records'
        description='Deploys a collection of Custom Metadata Type records in one asynchronous Metadata API job.'
    )
    public static List<String> deploy(List<FlowInput> inputs) {
        List<SObject> consolidated = new List<SObject>();
        for (FlowInput input : inputs) {
            if (input.customMetadataRecords != null) {
                consolidated.addAll(input.customMetadataRecords);
            }
        }

        String jobId = deploy(consolidated);
        List<String> jobIds = new List<String>();
        for (Integer i = 0; i < inputs.size(); i++) {
            jobIds.add(jobId);
        }
        return jobIds;
    }

    public static String deploy(List<SObject> customMetadataRecords) {
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        for (SObject record : customMetadataRecords) {
            container.addMetadata(buildDeployableRecord(record));
        }
        lastBuiltContainer = container;

        if (Test.isRunningTest()) {
            return MOCK_DEPLOYMENT_ID;
        }
        return Metadata.Operations.enqueueDeployment(container, new EmailOnErrorCallback());
    }

    private static Metadata.CustomMetadata buildDeployableRecord(SObject record) {
        Schema.DescribeSObjectResult describe = record.getSObjectType().getDescribe();
        String typePrefix = describe.getName().replace('__mdt', '');
        Map<String, Schema.SObjectField> fieldMap = describe.fields.getMap();

        Metadata.CustomMetadata cmdt = new Metadata.CustomMetadata();
        cmdt.fullName = typePrefix + '.' + (String) record.get('DeveloperName');
        Object masterLabel = record.get('MasterLabel');
        if (masterLabel != null) {
            cmdt.label = (String) masterLabel;
        }

        for (String fieldName : record.getPopulatedFieldsAsMap().keySet()) {
            if (IGNORED_FIELD_NAMES.contains(fieldName)) {
                continue;
            }
            Schema.SObjectField field = fieldMap.get(fieldName);
            if (field == null) {
                continue;
            }

            Metadata.CustomMetadataValue mdValue = new Metadata.CustomMetadataValue();
            mdValue.field = fieldName;
            if (field.getDescribe().getType() == Schema.DisplayType.PICKLIST) {
                mdValue.value = String.valueOf(record.get(fieldName));
            } else {
                mdValue.value = record.get(fieldName);
            }
            cmdt.values.add(mdValue);
        }
        return cmdt;
    }

    public class EmailOnErrorCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            if (result == null || result.status == Metadata.DeployStatus.Succeeded) {
                return;
            }
            String subject = 'FQS Custom Metadata deployment failed';
            String body = String.format(
                'Deployment ID: {0}\nStatus: {1}\nTotal components: {2}\nComponent errors: {3}\n\nDetails:\n{4}',
                new List<Object>{
                    result.id,
                    result.status,
                    result.numberComponentsTotal,
                    result.numberComponentErrors,
                    JSON.serializePretty(result.details)
                }
            );
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
            email.setSubject(subject);
            email.setPlainTextBody(body);
            try {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
            } catch (Exception e) {
                // Org may lack single-email permission; failure detail is still in Setup → Deployment Status.
                System.debug(LoggingLevel.ERROR, 'FQS_CustomMetadataSaver failure email suppressed: ' + e.getMessage());
            }
        }
    }
}
