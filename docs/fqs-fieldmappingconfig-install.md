# FQS FieldMappingConfig — Developer Install Guide

**Audience:** developers or advanced admins maintaining or forking FQS.

**Companion admin doc:** README §IV.9 "Configure Gift Entry field mappings" (click-path only, no CLI).

**Design context:** [`docs/gift-entry-field-mapping.md`](gift-entry-field-mapping.md) explains *why* each mapping exists (which GiftEntry staging column feeds which downstream GC/GT/Account field). This doc is only about the *mechanics* of getting the 12 FQS-authored mappings into a fresh install.

---

## What this metadata is

The `FieldMappingConfig` metadata type stores the Gift Entry field mappings that Salesforce's Fundraising Cloud uses to fan a single `GiftEntry` staging row into downstream `GiftTransaction` / `GiftCommitment` / `GiftCommitmentSchedule` inserts on commit.

- **Setup UI path:** Setup → Fundraising Setup → Gift Entry → Field Mapping.
- **Source-tree path:** [`force-app/main/default/fieldMappingConfigs/FieldMappingConfig.fieldMappingConfig`](../force-app/main/default/fieldMappingConfigs/FieldMappingConfig.fieldMappingConfig).
- **Shape:** a single file per org (no `-meta.xml` suffix — unlike most DX metadata), containing one `<FieldMappingConfig>` envelope with 12 `<fieldMappingConfigItems>` children.

FQS ships 12 mappings that carry the following custom GiftEntry columns to their downstream targets:

| # | GiftEntry source field | Target object   | Target field                       |
|---|------------------------|-----------------|------------------------------------|
| 1 | `FQS_Gift_Transaction_Category__c` | GiftTransaction | `FQS_Gift_Transaction_Category__c` |
| 2 | `FQS_Donor_Tax_Date__c`            | GiftTransaction | `FQS_Donor_Tax_Date__c`            |
| 3 | `FQS_Fair_Market_Value_Amount__c`  | GiftTransaction | `FQS_Fair_Market_Value_Amount__c`  |
| 4 | `FQS_Match_Status__c`              | GiftTransaction | `FQS_Match_Status__c`              |
| 5 | `FQS_GC_Restriction_Release_Date__c` | GiftCommitment | `FQS_Restriction_Release_Date__c` |
| 6 | `FQS_GT_Restriction_Release_Date__c` | GiftTransaction | `FQS_Restriction_Release_Date__c` |
| 7 | `FQS_GC_Skip_Naming__c`            | GiftCommitment  | `FQS_Skip_Naming__c`               |
| 8 | `FQS_GT_Skip_Naming__c`            | GiftTransaction | `FQS_Skip_Naming__c`               |
| 9 | `FQS_Stewardship_Date__c`          | GiftTransaction | `FQS_Stewardship_Date__c`          |
| 10 | `FQS_Stewardship_Status__c`        | GiftTransaction | `FQS_Stewardship_Status__c`        |
| 11 | `FQS_Tax_Receipt_Date__c`          | GiftTransaction | `FQS_Tax_Receipt_Date__c`          |
| 12 | `FQS_GC_Match_Eligible__c`         | GiftCommitment  | `FQS_Match_Eligible__c`            |

Every mapping's constraint — "one source → one destination" — is why several appear paired (`FQS_GC_*` and `FQS_GT_*` for a canonical field that lives on both objects). See [`docs/gift-entry-field-mapping.md`](gift-entry-field-mapping.md) for the full rationale.

---

## Why the source file is `.forceignore`d

At API v66/v67, the source-format `.fieldMappingConfig` file trips a DX ↔ Metadata API disagreement:

- `sf project deploy start --source-dir force-app` throws `ConversionError: Missing processType on FieldMappingConfigItem`.
- Adding `<processType>GiftEntry</processType>` inside each `<fieldMappingConfigItems>` block makes the Metadata API reject it as an invalid location — the DX converter and the mdapi schema disagree.

To keep source-format deploys clean, `.forceignore` excludes `**/fieldMappingConfigs/**` entirely. The file stays checked in as the **canonical record** of what the mappings should be — retrieves diff against it, humans read it — but it never participates in a source-format deploy.

If a future Salesforce release fixes the converter (verify by re-attempting a source deploy after any `sf` CLI major-version bump), remove the `**/fieldMappingConfigs/**` line from `.forceignore` and add `FieldMappingConfig` + one `<members>FieldMappingConfig</members>` to `manifest/package.xml`.

---

## Install paths

### Path A — Setup UI (recommended)

Matches what the admin README §IV.9 tells non-developers to do. Safest, no surprises. ~10 minutes for the full 12 rows.

1. Ensure the 12 `GiftEntry.FQS_*__c` custom fields have deployed. (`FQS_Custom_Fields.permissionset-meta.xml` grants FLS on all of them — if the permset deployed cleanly, so did the fields.)
2. Setup → Fundraising Setup → Gift Entry → **Field Mapping**.
3. Confirm the header reads `masterLabel = FieldMappingConfig`, `sourceObjectId = GiftEntry`, `processType = GiftEntry` (the platform seeds these — you cannot edit the envelope). If missing, click **New Field Mapping Set** and name it `FieldMappingConfig`.
4. For each row in the table above, click **New Mapping** and set:
   - **Source field:** the `GiftEntry.FQS_*__c` column.
   - **Destination object:** GiftTransaction or GiftCommitment.
   - **Destination field:** the target `FQS_*__c` column on that object.
   - **Sequence:** the `#` from the table (Salesforce uses sequence for tie-breaking when multiple sources feed a target — the numbering matches the order in the source file).
5. Save each row.
6. Verify against `force-app/main/default/fieldMappingConfigs/FieldMappingConfig.fieldMappingConfig` — the file is the diff target if you ever need to audit whether the org drifted.

### Path B — Tooling API (bulk/scripted)

Faster for developers repeatedly setting up scratch orgs. Bypasses the source-format converter bug entirely by talking to the Tooling API directly.

**Prereqs:**
- The parent `FieldMappingConfig` record must already exist (Setup UI **New Field Mapping Set** creates it if absent — Salesforce won't let you insert `FieldMappingConfigItem` rows against a nonexistent parent).
- Grab the parent Id:
  ```bash
  sf data query \
    --query "SELECT Id FROM FieldMappingConfig WHERE MasterLabel='FieldMappingConfig'" \
    --use-tooling-api \
    --target-org <alias>
  ```

**Insert the 12 items** (replace `<PARENT_ID>` with the query result above):

```bash
PARENT_ID=<paste-id-here>

for row in \
  "1|FQS_Gift_Transaction_Category__c|GiftTransaction|FQS_Gift_Transaction_Category__c" \
  "2|FQS_Donor_Tax_Date__c|GiftTransaction|FQS_Donor_Tax_Date__c" \
  "3|FQS_Fair_Market_Value_Amount__c|GiftTransaction|FQS_Fair_Market_Value_Amount__c" \
  "4|FQS_Match_Status__c|GiftTransaction|FQS_Match_Status__c" \
  "5|FQS_GC_Restriction_Release_Date__c|GiftCommitment|FQS_Restriction_Release_Date__c" \
  "6|FQS_GT_Restriction_Release_Date__c|GiftTransaction|FQS_Restriction_Release_Date__c" \
  "7|FQS_GC_Skip_Naming__c|GiftCommitment|FQS_Skip_Naming__c" \
  "8|FQS_GT_Skip_Naming__c|GiftTransaction|FQS_Skip_Naming__c" \
  "9|FQS_Stewardship_Date__c|GiftTransaction|FQS_Stewardship_Date__c" \
  "10|FQS_Stewardship_Status__c|GiftTransaction|FQS_Stewardship_Status__c" \
  "11|FQS_Tax_Receipt_Date__c|GiftTransaction|FQS_Tax_Receipt_Date__c" \
  "12|FQS_GC_Match_Eligible__c|GiftCommitment|FQS_Match_Eligible__c"
do
  IFS='|' read -r seq src obj dest <<< "$row"
  sf data create record \
    --sobject FieldMappingConfigItem \
    --values "FieldMappingConfigId=${PARENT_ID} SourceFieldId=${src} DestinationObjectId=${obj} DestinationFieldId=${dest} Sequence=${seq}" \
    --use-tooling-api \
    --target-org <alias>
done
```

Every insert returns the new `FieldMappingConfigItem` Id on success. Salesforce enforces "one source → one destination" — attempting to add a second item with the same `SourceFieldId` fails with `We can't save the mapping because the source field <name> is already mapped to another destination field`. That's why the FQS design uses `FQS_GC_*` / `FQS_GT_*` prefixes for canonical fields that live on both objects.

### Path C — mdapi-format deploy (not recommended)

Theoretically deployable via `sf project deploy start --metadata-dir <dir>` with an mdapi-shape `package.xml`. Skipped in the FQS install path because the deploy has been observed reporting Succeeded while silently dropping every `<fieldMappingConfigItems>` beyond the first. If Salesforce fixes this behavior in a future release, this becomes the cleanest install path — but until then, Path A (UI) and Path B (Tooling API) are the reliable ones.

---

## Retrieval after edits

If you edit the mappings in the org (Setup UI or Tooling API) and want the source-tree file to reflect the new state:

```bash
sf project retrieve start \
  --metadata FieldMappingConfig \
  --target-org <alias>
```

Retrieved files will show 15-char Ids in `SourceFieldId` / `DestinationFieldId` for items inserted via Tooling API. **Before committing**, swap those Ids back to API names (grep for `Id=` patterns, look up the field API name via `sf sobject describe --sobject GiftEntry` and target object) so the file redeploys cleanly to other orgs. This is a one-time chore on the first retrieve after a Tooling API insert — subsequent retrieves round-trip cleanly if the file was API-name-normalized before.

---

## Related

- [`docs/gift-entry-field-mapping.md`](gift-entry-field-mapping.md) — why each mapping exists (design rationale).
- [`README.md`](../README.md) §IV.9 "Configure Gift Entry field mappings" — the admin-facing click-path.
- Memory `fieldmappingconfig-metadata-type` — the origin note that documented the v67 converter bug and the "one source → one destination" constraint the first time FQS hit them.
