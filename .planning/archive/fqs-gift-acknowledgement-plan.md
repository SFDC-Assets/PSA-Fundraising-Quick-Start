# FQS Gift Acknowledgement — Execution Plan (v2)

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst` (Nonprofit Cloud — Fundraising)
**Flow type:** **Scheduled Flow** — runs daily, queries all unacknowledged Paid GiftTransactions older than 3 days, processes each in a loop.

---

## What changed from v1

| v1 (record-triggered) | v2 (scheduled) |
|---|---|
| AutoLaunchedFlow with RecordAfterSave + scheduled path | AutoLaunchedFlow with `Scheduled` triggerType, daily schedule |
| Processed one record at a time | Queries a collection, iterates via Loop |
| Picked up `$Record` references directly | Must Get Records first; loop variable is the triggering record proxy |
| emailSimple action with formula body | **Send Email** action (`sendEmail`) with `FQS_Gift_Acknowledgement` template + targetObjectId |
| Wrong picklist values (made up) | Correct values from org: see below |

---

## Confirmed picklist values (from org)

| Field | Valid values |
|---|---|
| `GiftTransaction.AcknowledgementStatus` | `To Be Sent`, `Sent`, `Don't Send` |
| `GiftTransaction.Status` | `Unpaid`, `Paid`, `Failed`, `Fully Refunded`, `Written-Off`, `Canceled`, `Pending` |
| `Task.Status` | `Not Started`, `In Progress`, `Completed`, `Waiting on someone else`, `Deferred` |
| `Task.Priority` | `High`, `Normal`, `Low` |

---

## User-confirmed design decisions

1. **CMDT drives routing.** `FQS_Auto_Acknowledgement__c` per tier: `Include All`, `Exclude Lifetime`, `Exclude All`. Semantics: gift-tier drives, lifetime escalates.
2. **Defaults seeded:** Entry → `Include All`, Mid → `Exclude Lifetime`, Major → `Exclude All`.
3. **Task owner:** dedicated Queue `FQS_Gift_Acknowledgements` (sObjectType `Task`).
4. **Opportunity attach:** soonest open CloseDate; fallback to donor Account.
5. **WhoId** = `PersonContactId` from donor person account.
6. **Email:** `Send Email` action using the `FQS_Gift_Acknowledgement` template already deployed. `targetObjectId` = Contact (`PersonContactId`). Related record (for merge context) = the GiftTransaction.
7. **Email opt-out honored.** `Contact.HasOptedOutOfEmail = TRUE` → force Task path; subject prefixed `[OPT-OUT — send by mail]`.
8. **Timing:** Scheduled flow runs daily. Queries `GiftTransaction` where `Status = 'Paid'` AND `AcknowledgementStatus` is blank OR `To Be Sent` AND `TransactionDate <= TODAY - 3`.
9. **Flow type:** Scheduled (daily). `processType = AutoLaunchedFlow`, `triggerType = Scheduled`.

---

## Routing decision table (unchanged)

| Gift Tier | CMDT Setting | Lifetime Major? | Email opt-out? | Route |
|---|---|---|---|---|
| Major | Exclude All | — | — | Task |
| Major | Exclude Lifetime | Yes | — | Task |
| Major | Exclude Lifetime | No | No | Email |
| Major | Include All | — | No | Email |
| Mid | Exclude All | — | — | Task |
| Mid | Exclude Lifetime | Yes | — | Task |
| Mid | Exclude Lifetime | No | No | Email |
| Mid | Include All | — | No | Email |
| Entry | Exclude All | — | — | Task |
| Entry | Exclude Lifetime | Yes | — | Task |
| Entry | Exclude Lifetime | No | No | Email |
| Entry | Include All | — | No | Email |
| Any | Any | — | Yes | Task (`[OPT-OUT — send by mail]` prefix) |
| Sub-Entry | Follow Entry row | — | — | Per Entry row |

---

## Pre-fetch: CMDT values loaded before the loop

A Scheduled flow can't use `$CustomMetadata` formula references inside a loop reliably across iterations. Instead, **Get Records** for all three CMDT rows before entering the loop and store them in individual record variables (`varCMDT_Entry`, `varCMDT_Mid`, `varCMDT_Major`). The loop's tier-resolution decision picks which variable's `FQS_Auto_Acknowledgement__c` to use.

---

## Flow elements (ordered, within the loop)

**Before the loop:**

1. **Get Records — GiftTransaction collection**
   - Object: `GiftTransaction`
   - Filters: `Status = Paid` AND `TransactionDate <= {!frmThreeDaysAgo}` AND (`AcknowledgementStatus = null` OR `AcknowledgementStatus = 'To Be Sent'`)
   - Store all records; variable: `varGiftTransactions` (collection)

2. **Get Records — Entry CMDT row** → `varCMDT_Entry`
3. **Get Records — Mid CMDT row** → `varCMDT_Mid`
4. **Get Records — Major CMDT row** → `varCMDT_Major`

5. **Loop** over `varGiftTransactions` → current item variable `varCurrentGT`

**Inside the loop (per gift):**

6. **Get Records — Donor Account** where `Id = {!varCurrentGT.DonorId}` → `varAccount`
   - Fields needed: `PersonContactId`, `Id`, `Name`

7. **Get Records — Contact** where `Id = {!varAccount.PersonContactId}` → `varContact`
   - Fields needed: `HasOptedOutOfEmail`, `Email`, `FirstName`, `Salutation`

8. **Get Records — DonorGiftSummary** where `DonorId = {!varCurrentGT.DonorId}` → `varDGS`
   - Fields needed: `FQS_Is_Major_Lifetime_Donor__c`, `FQS_Lifetime_Donor_Level_Name__c`

9. **Decision — Resolve Gift Tier**
   - Major if `{!varCurrentGT.FQS_Is_Major_Gift__c}` TRUE → set `varAutoAckSetting = varCMDT_Major.FQS_Auto_Acknowledgement__c`, `varResolvedTier = 'Major'`
   - Mid if `{!varCurrentGT.FQS_Is_Mid_Gift__c}` TRUE → Mid CMDT
   - Default (Entry) → Entry CMDT
   - *(Three assignment elements, one per branch, all converge to step 10)*

10. **Decision — Route: Email or Task?**
    - **Email** when: `varContact.HasOptedOutOfEmail = FALSE` AND `varAutoAckSetting != 'Exclude All'` AND NOT(`varAutoAckSetting = 'Exclude Lifetime'` AND `varDGS.FQS_Is_Major_Lifetime_Donor__c`)
    - **Task** (default): everything else, including opt-out override

11. **Email path — Send Email action** (`sendEmail`)
    - `templateId` = Id of `FQS_Gift_Acknowledgement` template (looked up by DeveloperName pre-loop, stored in `varEmailTemplateId`)
    - `targetObjectId` = `{!varAccount.PersonContactId}` (Contact — required recipient)
    - `whatId` = `{!varCurrentGT.Id}` (GiftTransaction — provides merge context for template)
    - Fault → `Send_Fault_Email`

12. **Email path — Update GiftTransaction**
    - `AcknowledgementStatus = 'Sent'`
    - *(no AcknowledgementDate field exists on GiftTransaction in this org — omit)*

13. **Task path — Get Queue Id** (pre-loop if possible; Salesforce allows this)
    - `Group` where `Type = 'Queue' AND DeveloperName = 'FQS_Gift_Acknowledgements'` → `varQueueId`
    - *(moved pre-loop to avoid redundant queries)*

14. **Task path — Get Open Opportunity** (inside loop, per-donor)
    - `Opportunity` where `AccountId = {!varCurrentGT.DonorId}` AND `IsClosed = FALSE`, order by `CloseDate ASC`, LIMIT 1

15. **Decision — Opp found?** → set `varTaskWhatId` to Opp Id or Account Id

16. **Task path — Create Task**
    - `OwnerId` = `varQueueId`
    - `WhoId` = `{!varAccount.PersonContactId}`
    - `WhatId` = `{!varTaskWhatId}`
    - `Subject` = formula (opt-out prefix + tier + account name + amount)
    - `Priority` = `'High'` if Major, else `'Normal'`
    - `ActivityDate` = today + 3 (Major) / +7 (Mid) / +14 (Entry)
    - `Status` = `'Not Started'`
    - `Description` = lifetime tier + opt-out flag + opp name
    - Fault → `Send_Fault_Email`

17. **Task path — Update GiftTransaction**
    - `AcknowledgementStatus = 'To Be Sent'`

*(Loop end — next record)*

**Pre-loop lookups to add:**

- **Get Records — Email Template** where `DeveloperName = 'FQS_Gift_Acknowledgement'` → `varEmailTemplateId` (store only Id)
- **Get Records — Queue** where `Type = 'Queue' AND DeveloperName = 'FQS_Gift_Acknowledgements'` → `varQueueId` (store only Id)

**Fault element (global):**

- `Send_Fault_Email` — `emailSimple` to `$User.Email` with `$Flow.FaultMessage` and `$Flow.CurrentDateTime` (mirrors `FQS_Automatic_Rollup_Updates` pattern)

**Formula:**
- `frmThreeDaysAgo` (Date): `{!$Flow.CurrentDate} - 3` — used in the opening Get Records filter

---

## Schedule

- **Frequency:** Daily
- **Start time:** `06:00:00.000Z` (adjustable post-deploy; runs in org's time zone context)
- **Start date:** set to deployment date

---

## Files to touch

**Edit (replace flow):**
- `force-app/main/default/flows/FQS_Gift_Acknowledgement.flow-meta.xml` — complete rewrite as scheduled flow; `processType = AutoLaunchedFlow`, `triggerType = Scheduled`

**No other files need changing** — CMDT field, CMDT records, queue, email template, permset all already deployed successfully in v1.

---

## Corrected values vs. v1

| Element | v1 (wrong) | v2 (correct) |
|---|---|---|
| Task.Status | `'Open'` | `'Not Started'` |
| GT.AcknowledgementStatus (email path) | `'Acknowledged'` | `'Sent'` |
| GT.AcknowledgementStatus (task path) | `'To Be Acknowledged'` | `'To Be Sent'` |
| GT re-check exit condition | `'Acknowledged'` | `'Sent'` |
| Email action | `emailSimple` + formula body | `sendEmail` + `FQS_Gift_Acknowledgement` template |
| Flow structure | Record-triggered + scheduled path | Scheduled, loop over collection |

---

## Test plan (manual, in FundFirst)

| # | Setup | Expected |
|---|---|---|
| 1 | GT: Status=Paid, TransactionDate=4 days ago, no AcknowledgementStatus, Entry donor | Flow runs → email sent, `AcknowledgementStatus = 'Sent'` |
| 2 | GT: Status=Paid, TransactionDate=4 days ago, Mid donor, not lifetime major | Email sent |
| 3 | GT: Status=Paid, TransactionDate=4 days ago, Mid donor, IS lifetime major | Task created, `AcknowledgementStatus = 'To Be Sent'` |
| 4 | GT: Status=Paid, TransactionDate=4 days ago, Major donor | Task created |
| 5 | GT: Status=Paid, TransactionDate=**today** (< 3 days) | Skipped — not in query results |
| 6 | GT: Status=Paid, TransactionDate=4 days ago, `HasOptedOutOfEmail = TRUE` | Task created, subject prefixed `[OPT-OUT — send by mail]` |
| 7 | GT: Status=Fully Refunded, TransactionDate=4 days ago | Skipped — Status filter excludes it |
| 8 | GT: AcknowledgementStatus=Sent already | Skipped — AcknowledgementStatus filter excludes it |
| 9 | Donor has open Opportunity | Task WhatId = Opportunity |
| 10 | Donor has no open Opportunity | Task WhatId = Account |

Verify email: Setup → Email Log Files.
Verify fault path: temporarily delete the template to force a failure; check inbox for fault email.

---

## Open follow-ups (post-approval, not blockers)

- **Bulk/backfill:** for historical unacknowledged gifts, adjust `TransactionDate` filter or run a one-time anonymous Apex loop to simulate re-triggering.
- **Partial refunds:** `Status` stays `Paid` on partial refund — flow will still process. Confirm this matches donor-relations policy.
- **Configurator flow:** `FQS_Donor_Grouping_Configurator` still needs the new `FQS_Auto_Acknowledgement__c` picklist. Deferred.
- **Email template copy:** shell copy is deployed; marketing should replace before go-live.
