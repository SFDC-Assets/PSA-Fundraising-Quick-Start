---
title: Nonprofit Cloud Developer Guide
version: 67.0 (Summer '26)
source: Salesforce official developer guide, imported 2026-07-16
scope: >-
  Full guide - Fundraising, Program Mgmt, Case Mgmt, Outcome Mgmt,
  Grantmaking, Volunteer Mgmt, Group Memberships/Households,
  Record Rollup Definitions, NonProfit Cloud Associated Objects
---

# Nonprofit Cloud Developer Guide

Version 67.0, Summer '26 - Last updated: July 3, 2026

> © Copyright 2000–2026 Salesforce, Inc. All rights reserved. Salesforce is a registered trademark of Salesforce, Inc., as are other names and marks. Other marks appearing herein may be trademarks of their respective owners.

## How to use this doc

This is the Salesforce-authored Nonprofit Cloud Developer Guide, vendored into the FQS repository so seed generator, flow, permission set, and layout work can be grounded in the current object model without a round-trip to developer.salesforce.com.

The largest and most FQS-relevant sections are:

- **Chapter 3 - Fundraising** (standard objects, fields on other objects, business APIs, invocable actions)
- **Chapter 10 - Group Memberships and Households in Nonprofit Cloud**
- **Chapter 11 - Record Rollup Definitions**
- **Chapter 12 - NonProfit Cloud Associated Objects**

The full text is preserved below in reading order. Chapter and section running-header noise from the original PDF has been stripped; field/details tables are preserved in their original key-then-value form rather than reformatted into markdown tables.

## Contents


Chapter 1: Introduction to Nonprofit Cloud . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1
Chapter 2: Nonprofit Cloud Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
Case Management Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
Fundraising Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
Grantmaking Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
Group Membership and Households Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
Outcome Management Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7
Program Management Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8
Provider Management Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
Volunteer Management Data Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11

Chapter 3: Fundraising . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12
Fundraising Standard Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 13
DocGenerationQueryResult . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15
DonorGiftConcept . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 17
DonorGiftConceptOpportunity . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 23
DonorGiftSummary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 25
GiftActuarialEntry . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 39
GiftStewardship . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 44
GiftStewardshipActivity . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 48
GiftAgreement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 51
GiftBatch . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 54
GiftCommitment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 58
GiftCmtChangeAttrLog . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 70
GiftCommitmentSchedule . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 73
GiftDefaultDesignation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 81
GiftDefaultSoftCredit . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 83
GiftDesignation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 86
GiftEntry . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 91
GiftRefund . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 105
GiftSoftCredit . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 108
GiftTransaction . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 112
GiftTransactionDesignation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 123
GiftTribute . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 126
GiftValueForecast . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 131
GratefulPersonInvolvement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 134
OutreachSourceCode . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 138
OutreachSummary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 144

PartyCategory . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 149
PartyPhilanthropicAssessment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 152
PartyPhilanthropicIndicator . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 161
PartyPhilanthropicMilestone . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 168
PartyPhilanthropicOccurrence . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 175
PartyPhilanthropicRsrchPrfl . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 182
PaymentInstrument . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 186
PlannedGift . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 192
PlannedGiftAnnuityRate . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 203
PlannedGiftPerformance . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 206
Fundraising Fields on Other Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 209
ContactPointAddress . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 210
ContactProfile . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 218
ListEmail . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 220
Fundraising Business APIs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 225
Resources . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 226
Request Bodies . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 240
Response Bodies . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 266
Fundraising Invocable Actions . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 290
Close Gift Commitment Action . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 291
Manage Custom Gift Commitment Schedules Action . . . . . . . . . . . . . . . . . . . . . . . . 292
Manage Gift Default Designations Action . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 293
Manage Gift Transaction Designations Action . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 294
Manage Recurring Gift Commitment Schedule Action . . . . . . . . . . . . . . . . . . . . . . . . 296
Process Gift Entries Action . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 297
Pause Gift Commitment Schedule Action . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 299
Process Gift Commitment Action . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 301
Resume Gift Commitment Schedule Action . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 302
Update Processed Gift Entries Action . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 303
Fundraising Metadata API Types . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 304
AffinityScoreDefinition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 305
Flow for Fundraising . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 308
Fundraising Tooling API Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 309
FundraisingConfig . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 310
FieldMappingConfig . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 316
FieldMappingConfigItem . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 318
GiftEntryGridTemplate . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 320

Chapter 4: Program Management . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 322
Program Management Standard Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 323
Benefit . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 324
BenefitAssignment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 329
BenefitDisbursement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 334
BenefitSchedule . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 338

BenefitScheduleAssignment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 341
BenefitSession . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 343
BenefitType . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 346
CaseProgram . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 348
Program . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 349
ProgramCohort . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 354
ProgramCohortMember . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 357
ProgramEnrollment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 360
RecurrenceSchedule . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 366
Program Management Business APIs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 370
REST Reference . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 370

Chapter 5: Case Management . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 390
Case Management Standard Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 391
CarePlan . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 392
CarePlanTemplate . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 396
CarePlanTemplateBenefit . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 398
CarePlanTemplateGoal . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 400
CaseParticipant . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 401
ComplaintCase . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 405
ComplaintParticipant . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 407
GoalAssignment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 410
GoalDefinition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 415
Interaction . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 418
InteractionAttendee . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 421
InteractionRelatedAccount . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 425
InteractionSummary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 427
InteractionSumDiscussedAccount . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 431
PublicComplaint . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 433
Referral . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 443
Case Management Business API . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 453
REST Reference . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 453

Chapter 6: Outcome Management Standard Objects . . . . . . . . . . . . . . . . . . . . . . . 462
ImpactStrategy . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 463
ImpactStrategyAssignment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 466
IndicatorAssignment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 468
IndicatorDefinition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 472
IndicatorPerformancePeriod . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 474
IndicatorResult . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 478
Outcome . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 481
OutcomeActivity . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 484
TimePeriod . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 488
UnitOfMeasure . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 490

Chapter 7: Grantmaking . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 493
Grantmaking Object Reference . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 494
ApplicationDecision . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 495
ApplicationRenderMethod . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 498
ApplicationReview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 501
ApplicationStageDefinition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 507
ApplicationTimeline . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 510
Budget . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 512
BudgetAllocation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 516
BudgetCategory . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 519
BudgetCategoryValue . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 521
BudgetParticipant . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 525
BudgetPeriod . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 527
FundingAward . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 529
FundingAwardAmendment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 535
FundingAwardParticipant . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 539
FundingAwardRequirement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 542
FundingAwardRqmtSection . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 547
FundingDisbursement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 552
FundingOpportunity . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 555
FundingOppParticipant . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 560
IndicatorAssignment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 563
IndicatorPerformancePeriod . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 567
IndividualApplication . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 571
IndividualApplicationTask . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 579
IndvApplicationTaskParticipant . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 584
IndividualApplnParticipant . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 587
OutcomeActivity . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 589
PreliminaryApplicationRef . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 594
Program . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 597
Grantmaking Fields on Other Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 602
ApplicationForm . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 603
ApplicationFormEvaluation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 606
ApplicationFormEvalSection . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 608
Grantmaking Tooling API Object . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 612
ApplicationRecordTypeConfig . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 612
Grantmaking Metadata API Types . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 615
IndustriesSettings . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 615

Chapter 8: Volunteer Management Standard Objects . . . . . . . . . . . . . . . . . . . . . . . 618
JobPositionAssignment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 619
JobPositionQualification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 623
JobPositionShift . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 626
PersonLocationAvailability . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 630

PositionBenefit . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 633
PositionQualification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 635
VolunteerInitiative . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 638

Chapter 9: Volunteer Management Fields on Other Objects . . . . . . . . . . . . . . . . . . 642
ApplicationForm . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 643
ApplicationRenderMethod . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 644
ApplicationStageDefinition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 645
DonorGiftSummary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 647
JobPosition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 648
PersonCompetency . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 652
Position . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 653

Chapter 10: Group Memberships and Households in Nonprofit Cloud . . . . . . . . . . . 655
Group Membership and Households Standard Objects . . . . . . . . . . . . . . . . . . . . . . . . . . 656
AccountAccountRelation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 656
AccountContactRelation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 660
ContactContactRelation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 663
PartyRelationshipGroup . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 667
PartyRoleRelation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 672
Group Membership and Households Business APIs . . . . . . . . . . . . . . . . . . . . . . . . . . . . 675
REST Reference . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 676

Chapter 11: Record Rollup Definitions . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 706
Record Rollup Definitions Standard Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 707
RecordAggregationResult . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 707
Record Rollup Definitions Business APIs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 709
REST Reference . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 710
Record Rollup Definitions Metadata API Types . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 718
RecordAggregationDefinition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 718
Record Rollup Definitions Tooling API Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 725
RecordAggregationDefinition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 726
RecordAggregationJoinCondition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 730
RecordAggregationObject . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 732
RecordAggregationObjectFilter . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 734

Chapter 12: NonProfit Cloud Associated Objects . . . . . . . . . . . . . . . . . . . . . . . . . . . 737
StandardObjectNameShare . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 738
StandardObjectNameOwnerSharingRule . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 738
StandardObjectNameHistory . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 739
StandardObjectNameChangeEvent . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 740
StandardObjectNameFeed . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 742


# Chapter 1: Introduction to Nonprofit Cloud


Introduction to Nonprofit Cloud
Use Nonprofit Cloud to fund, deliver, and measure impact with one
integrated platform. Nurture your most important relationships,
and break down silos between teams with a single source of truth
about your donors, stakeholders, and constituents.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise and
Unlimited Editions.


# Chapter 2: Nonprofit Cloud Data Model

In this chapter ...
•

Case Management
Data Model

•

Fundraising Data
Model

•

Grantmaking Data
Model

•

Group Membership
and Households
Data Model

•

Outcome
Management Data
Model

•

Program
Management Data
Model

•

Provider
Management Data
Model

•

Volunteer
Management Data
Model

Nonprofit Cloud Data Model
Learn about the objects and relationships within Nonprofit Cloud


Case Management Data Model

Case Management Data Model
Learn about the objects and relationships within the Case Management data model.
The Case Management data model provides a set of objects and fields that you can use to store and manage information about cases
and care plans.

To view a larger version, right-click or Ctrl+click the image and select Open Image in New Tab.

Fundraising Data Model
Learn about the objects and relationships within the Fundraising data model.
The Fundraising data model provides a set of objects and fields that you can use to store and manage information about constituents,
campaigns, and donations.


Grantmaking Data Model

To view a larger version, right-click or Ctrl+click the image and select Open Image in New Tab.

Grantmaking Data Model
Learn about the objects and relationships within the Grantmaking data model.
The Grantmaking data model provides a set of objects and fields that you can use to store and
manage information about grants you award.
In Spring '26 a new Grantmaking data model that uses Application Form objects was introduced.
The pre-existing Grantmaking data model that uses Individual Application and related objects
remains available. You can use either the Application Form object or the Individual Application
object to track applications, however, Individual Application won't receive future platform
enhancements.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise,
Performance, and
Unlimited Editions in
Nonprofit Cloud for
Grantmaking
Available in: Enterprise,
Performance, Unlimited,
and Developer Editions in
Public Sector Solutions


Grantmaking Data Model

These objects are unique to the Grantmaking Application Form data model: Applicant, Application Form, Application Form Evaluation,
Application Form Evaluation Participant, Application Form Evaluation Section, Application Form Participant, Application Form Relation,
Intake Form Section, and Intake Form Section Participant.


Group Membership and Households Data Model

These objects are unique to the Grantmaking Individual Application Form data model: Individual Application, Individual Application
Participant, Individual Application Task, Individual Application Task Participant, Application Record Type Configuration, and Application
Review.
For more details and a larger image, visit the Data Model Gallery.

Group Membership and Households Data Model
Learn about the objects and relationships used for group memberships, also known as party
relationship groups.

EDITIONS
Available in: Lightning
Experience. View product
and edition availability.


Outcome Management Data Model

To view a larger version, right-click or Ctrl+click the image and select Open Image in New Tab.

Outcome Management Data Model
Learn about the objects and relationships in the Outcome Management data model.

EDITIONS
Available in: Lightning
Experience. View product
and edition availability.


Program Management Data Model

To view a larger version, right-click or Ctrl+click the image and select Open Image in New Tab.

Program Management Data Model
Learn about the objects and relationships within the Program Management data model.
The Program Management data model provides a set of objects and fields that you can use to store and manage information about
programs and benefits.


Program Management Data Model

To view a larger version, right-click or Ctrl+click the image and select Open Image in New Tab.


Provider Management Data Model

Provider Management Data Model
Learn about the objects and relationships used for provider management in Public Sector
Solutions.

EDITIONS
Available in: Lightning Experience
Available in:
Enterprise, Performance, Unlimited,
and Developer Editions with Public
Sector Solutions

For more details and a larger image, visit the Data Model Gallery.


Volunteer Management Data Model

Volunteer Management Data Model
Learn about the objects and relationships within the Volunteer Management data model.
The Volunteer Management data model provides a set of objects and fields that you can use to
manage volunteer initiatives, track volunteer hours, and report on volunteer metrics.

EDITIONS
Available in: Lightning
Experience
Available in: Unlimited and
Developer Editions.

For more details and a larger image, visit the Data Model Gallery.


# Chapter 3: Fundraising

In this chapter ...
•

Fundraising Standard
Objects

•

Fundraising Fields on
Other Objects

•

Fundraising Business
APIs

•

Fundraising
Invocable Actions

•

Fundraising
Metadata API Types

•

Fundraising Tooling
API Objects

Fundraising
This guide provides information about the objects and APIs that
Fundraising uses.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise
Unlimited and Developer
Editions.


Fundraising Standard Objects

Fundraising Standard Objects
Fundraising data model provides objects and fields to manage gifts and donors for your nonprofit
or education organization.
DocGenerationQueryResult
Represents information, including a report, template, and process lookup, for a document
generation job. This object is available in API version 61.0 and later.
DonorGiftConcept
The initial idea or proposal for a gift, including the donor’s intent and preliminary purpose. This
object is available in API version 64.0 and later.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise,
Unlimited, and Developer
Editions.

DonorGiftConceptOpportunity
The junction between a Donor Gift Concept and an Opportunity. This object is available in API version 66.0 and later.
DonorGiftSummary
Represents gift summaries for accounts and contacts. This object is available in API version 59.0 and later.
GiftActuarialEntry
Represents the foundational data for calculating the future value of a planned gift, including life expectancy and discount rates. This
object is available in API version 65.0 and later.
GiftStewardship
Represents stewardship of a gift by a contact or an organization that isn't a donor. This object is available in API version 65.0 and
later.
GiftStewardshipActivity
Represents an activity carried out as part of gift stewardship. This object is available in API version 65.0 and later.
GiftAgreement
The agreement to accept a gift. This object is available in API version 64.0 and later.
GiftBatch
Represents the details and status of the batch of gifts. This object is available in API version 59.0 and later.
GiftCommitment
Represents the commitment made by a donor. This object is available in API version 59.0 and later.
GiftCmtChangeAttrLog
Represents the history of changes to a Gift Commitment over time with attribution to the source campaign or source code attributed
to that change. This object is available in API version 60.0 and later.
GiftCommitmentSchedule
Represents the schedule for fulfilling the commitment. This object is available in API version 59.0 and later.
GiftDefaultDesignation
Represents the default designation for gifts that originate from an opportunity, campaign, or commitment. This object is available
in API version 59.0 and later.
GiftDefaultSoftCredit
Represents the default allocation for soft credits on gift commitment transactions that are created by a recurrence engine and
credited to constituents who influenced the commitment. This object is available in API version 62.0 and later.
GiftDesignation
Represents a designation that can be assigned to a gift transaction. This object is available in API version 59.0 and later.


Fundraising Standard Objects

GiftEntry
Represents gifts created individually or in a batch before they're processed and logged in their target records. After processing, these
records serve as an audit trail for gift transactions. This object is available in API version 59.0 and later.
GiftRefund
Represents a refund of a gift. This object is available in API version 59.0 and later.
GiftSoftCredit
Represents the soft credit attributed to a person or organization for the gift transaction. This object is available in API version 59.0
and later.
GiftTransaction
Represents a completed transaction from a gift. This object is available in API version 59.0 and later.
GiftTransactionDesignation
Represents a junction between a gift transaction and a gift designation. This object is available in API version 59.0 and later.
GiftTribute
Represents the details and status of the gift tribute. This object is available in API version 59.0 and later.
GiftValueForecast
The past, current, and projected monetary value of a gift. This object is available in API version 64.0 and later.
GratefulPersonInvolvement
Represents a person’s contextual relationship of gratitude with an institution, capturing the originating program or experience,
attribution context, consent status, and engagement or solicitation constraints. This object is available in API version 67.0 and later.
OutreachSourceCode
Represents information about a source code that's associated with an outreach campaign. This object is available in API version 59.0
and later.
OutreachSummary
Represents a summary of results of the outreach campaign. This object is available in API version 59.0 and later.
PartyCategory
The criteria for categorizing contacts and accounts based on specific classification information for a specified time period. This object
is available in API version 64.0 and later.
PartyPhilanthropicAssessment
Represents a formalized assessment of wealth when a rating takes place, such as a third-party wealth assessment, a property valuation,
a financial asset assessment, or an internal assessment. This object is available in API version 63.0 and later.
PartyPhilanthropicIndicator
Represents an unconfirmed or soft indication that highlights a person's wealth or growth potential. This object is available in API
version 63.0 and later.
PartyPhilanthropicMilestone
Represents philanthropic activities and financial status for a period of time. This object is available in API version 63.0 and later.
PartyPhilanthropicOccurrence
xxx This object is available in API version XX.0 and later.
PartyPhilanthropicRsrchPrfl
Captures information associated with a contact or an organization in a many-to-one relationship. Serves as a pivot point for research
on the person or organization. This object is available in API version 64.0 and later.


Represents the details related to the Payment Instrument used to complete the transaction. This object is available in API version
60.0 and later.
PlannedGift
A complex gift such as an annuity, bequest, or trust. This object is available in API version 64.0 and later.
PlannedGiftAnnuityRate
The rate used to calculate payments for a charitable gift annuity. This object is available in API version 64.0 and later.
PlannedGiftPerformance
The performance of a planned gift over time, including returns, expenses, and net value. This object is available in API version 64.0
and later.

DocGenerationQueryResult
Represents information, including a report, template, and process lookup, for a document generation job. This object is available in API
version 61.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the FundraisingAccess license is enabled and the DocGen User permission set and the Fundraising User
system permission are assigned to users.

Fields
Field

Details

DocumentGenerationProcessId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The process associated with the document creation.
This field is a relationship field.
Relationship Name
DocumentGenerationProcess
Relationship Type
Lookup
Refers To
DocumentGenerationProcess


DocumentTemplateId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The template associated with the document creation.
This field is a relationship field.
Relationship Name
DocumentTemplate
Relationship Type
Lookup
Refers To
DocumentTemplate

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the batch query job.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ReportFolderId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The report folder associated with the document generation query result.


This is a relationship field and is available from API version 62.0 and later.
Relationship Name
ReportFolder
Refers To
Folder

RunDateTime

Type
dateTime
Properties
Create, Defaulted on create, Filter, Sort, Update
Description
The date and time when the query and job was run.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
DocGenerationQueryResultChangeEvent
Change events are available for the object.
DocGenerationQueryResultFeed
Feed tracking is available for the object.
DocGenerationQueryResultHistory
History is available for tracked fields of the object.
DocGenerationQueryResultOwnerSharingRule
Sharing rules are available for the object.
DocGenerationQueryResultShare
Sharing is available for the object.

DonorGiftConcept
The initial idea or proposal for a gift, including the donor’s intent and preliminary purpose. This object is available in API version 64.0
and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.


Fields
Field

Details

CaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The case associated with the gift concept record.
This field is a relationship field.
Relationship Name
Case
Refers To
Case

ConceptPriority

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The level of a proposed gift's importance to the donor or institution relative to other proposed
gifts.

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
A contact for the gift concept.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

Description

Type
textarea
Properties
Create, Nillable, Update
Description
A description of the gift concept.


DonorCommitmentLikelihood Type

percent
Properties
Create, Filter, Nillable, Sort, Update
Description
An estimate of the likelihood the donor commits to the gift concept.
DonorId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The donor associated with the gift concept.
This field is a relationship field.
Relationship Name
Donor
Refers To
Account

DonorPriorityRank

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The donor's rank of a gift concept among other potential gifts the donor is considering.

EstimatedGiftValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
An estimate of a proposed gift's potential value, based on preliminary discussions with the
donor.

ExpectedEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description


ExpectedStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The expected end date for formalizing the gift concept.

GiftAgreementId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
A gift agreement record associated with the gift concept, used to track its progression from
concept to commitment.
This field is a relationship field.
Relationship Name
GiftAgreement
Refers To
GiftAgreement

InstitutionPriorityRank Type

double
Properties
Create, Filter, Nillable, Sort, Update
Description
Your institution's rank of a gift concept's importance to its fundraising strategy.
LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

Name

Type
string


Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the gift concept record.

OpportunityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Opportunity records associated with the gift concept, used to track its progression from
concept to commitment.
This field is a relationship field.
Relationship Name
Opportunity
Refers To
Opportunity

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

SequenceNumber

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
A gift concept's position in a sequence of proposals for the donor.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The status of the gift concept.
Possible values are:
• Concept Approved
• In Discussion
• In Review
• Pending Approval
• Planning

Title

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The title of the gift concept.

Type

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of the gift concept.
Possible values are:
• Capital Campaign Concept
• In Development
• Major Gift Concept
• Other Gift Concept
• Planned Gift Concept
• Program and Support Gift Concept
• Specialized Gift Concept

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
DonorGiftConceptChangeEvent
Change events are available for the object.
DonorGiftConceptFeed
Feed tracking is available for the object.


History is available for tracked fields of the object.
DonorGiftConceptOwnerSharingRule
Sharing rules are available for the object.
DonorGiftConceptShare
Sharing is available for the object.

DonorGiftConceptOpportunity
The junction between a Donor Gift Concept and an Opportunity. This object is available in API version 66.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

DonorGiftConceptId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The donor gift concept associated with this donor gift concept opportunity.
This field is a relationship field.
Relationship Name
DonorGiftConcept
Relationship Type
Master-detail
Refers To
DonorGiftConcept (the master object)

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the donor gift concept opportunity.

OpportunityAmount

Type
currency
Properties
Filter, Nillable, Sort
Description
The estimated total gift amount of the associated opportunity. Read-only field that is derived
from the opportunity amount.

OpportunityCloseDate

Type
date
Properties
Filter, Group, Nillable, Sort
Description
The date when the associated opportunity is expected to close. Read-only field that is derived
from the opportunity close date.

OpportunityId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The opportunity associated with the donor gift concept.
This field is a relationship field and unique within your organization.
Relationship Name
Opportunity
Refers To
Opportunity


OpportunityStageName

Type
picklist
Properties
Filter, Group, Nillable, Sort
Description
The stage of the associated opportunity. Read-only field that is derived from the opportunity
stage name.
Possible values are:
• Closed Lost
• Closed Won
• Id. Decision Makers
• Needs Analysis
• Negotiation/Review
• Perception Analysis
• Proposal/Price Quote
• Prospecting
• Qualification
• Value Proposition

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
DonorGiftConceptOpportunityChangeEvent on page 740
Change events are available for the object.
DonorGiftConceptOpportunityFeed on page 742
Feed tracking is available for the object.
DonorGiftConceptOpportunityHistory on page 739
History is available for tracked fields of the object.

DonorGiftSummary
Represents gift summaries for accounts and contacts. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), undelete(), update(), upsert()


Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

AverageGiftAmount

Type
currency
Properties
Filter, Sort
Description
The average value of the gifts the donor directly contributed.
This value of this field is calculated using a formula: (TotalGiftTransactionAmount
/ GiftCount).

BestGiftYear

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The year in which the donor gave the largest value of gifts. Data Processing Engine finds the
year in which the donor gave the largest sum of paid gift transaction amounts. You can
schedule this calculation to run on a regular basis.

BookedPledges

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of a donor's pledges that are fully accounted for. Data Processing Engine
calculates this value by adding the amounts of the donor's pledges with
FormalCommitmentType = Written. You can schedule this calculation to run on
a regular basis.
Available in API version 62.0 and later.

CompositeRfmScore

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The score that represents the composite threshold of gift recency, gift frequency, and gift
monetary value. Data Processing Engine calculates this value according to how you configure
RFM Scoring. You can schedule this calculation to run on a regular basis.
Available in API version 61.0 and later.

CurrentRecurringStartDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the donor's first recurring gift transaction for their active recurring gift. Data
Processing Engine finds the date of the donor's first paid transaction associated with a related
recurring gift commitment that isn't closed. You can schedule this calculation to run on a
regular basis.
CurrentYearGiftCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of gifts that the donor directly contributed this year. Data Processing Engine
calculates this value by counting the paid gift transactions this calendar year. You can schedule
this calculation to run on a regular basis.

CurrentYearSoftCreditCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of gift soft credit records attributed to the donor this year.
Available in API version 63.0 and later.
CurrentYearSoftCreditsAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of gift soft credits earned by the donor this year.
Available in API version 63.0 and later.


DaysSinceLastGift

Type
int
Properties
Filter, Group, Nillable, Sort
Description
The number of days since the donor gave a direct contribution.
This value of this field is calculated using a formula:
IF(ISBLANK(TEXT(LastGiftDate)), NULL, TODAY() LastGiftDate).

DonorId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The person, household, or organization account associated with the donor gift summary.
This field is a relationship field.
Relationship Name
Donor
Relationship Type
Master-Detail
Refers To
Account

FirstGiftAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the first gift the donor directly contributed. Data Processing Engine calculates
this value by finding the amount of the donor's first paid gift transaction. You can schedule
this calculation to run on a regular basis.

FirstGiftCampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The first campaign to which the donor contributed. Data Processing Engine calculates this
value by finding the campaign of the donor's first paid gift transaction related to a campaign.
You can schedule this calculation to run on a regular basis.


This field is a relationship field.
Relationship Name
FirstGiftCampaign
Relationship Type
Lookup
Refers To
Campaign

FirstGiftDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the donor's first direct contribution. Data Processing Engine calculates this value
by finding the date of the donor's first paid gift transaction. You can schedule this calculation
to run on a regular basis.

FirstRecurringStartDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the donor's first recurring gift transaction. Data Processing Engine calculates this
value by finding the date of the donor's first paid gift transaction related to a recurring gift
commitment. You can schedule this calculation to run on a regular basis.
FirstSoftCreditAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the first gift the donor influenced but didn't directly contribute. Data Processing
Engine calculates this value by finding the soft credit amount of the first paid gift transaction
for which the donor receives soft credit. You can schedule this calculation to run on a regular
basis.

FirstSoftCreditDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The date of the first gift the donor influenced but didn't directly contribute. Data Processing
Engine calculates this value by finding the date of the first paid gift transaction for which the
donor receives soft credit. You can schedule this calculation to run on a regular basis.

FirstVolunJobPstnAsgntDt Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the contact's first volunteer shift. Data Processing Engine finds the first job position
assignment that's related to a volunteer initiative and calculates the value. You can schedule
this calculation to run regularly.
FrequencyScore

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The score that represents the giving frequency of the donor. Data Processing Engine calculates
this value according to how you configure RFM Scoring. You can schedule this calculation
to run on a regular basis.
Available in API version 61.0 and later.

GiftCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of gifts the donor directly contributed. Data Processing Engine calculates
this value by counting all of the donor's paid gift transactions. You can schedule this
calculation to run on a regular basis.

GiftsLastYearAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of gifts that the donor directly contributed last year. Data Processing Engine
calculates this value by adding the amounts of paid gift transactions from the last calendar
year. You can schedule this calculation to run on a regular basis.


GiftsThisYearAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of gifts that the donor directly contributed this year. Data Processing Engine
calculates this value by adding the amounts of the donor's paid gift transactions from this
calendar year. You can schedule this calculation to run on a regular basis.

GiftsTwoYearsAgoAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of gifts the donor directly contributed two years ago. Data Processing Engine
calculates this value by adding the amounts of the donor's paid gift transactions from two
calendar years ago. You can schedule this calculation to run on a regular basis.

GivingLevel

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The range within which the donor's total contributions fall for the current year.
Possible values are:
• $25,000,000+
• $10,000,000-$24,999,999
• $5,000,000-$9,999,999
• $1,000,000-$4,999,999
• $250,000-$999,999
• $100,000-$249,999
• $50,000-$99,999
• $25,000-$49,999
• $10,000-$24,999
• $5,000-$9,999
• $2,500-$4,999
• $1,000-$2,499
• $500-$999
• $100-$499
• Under $100


HighestGiftAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The largest single gift that the donor directly contributed. Data Processing Engine calculates
this value by finding the amount of the donor's largest paid gift transaction. You can schedule
this calculation to run on a regular basis.

HighestGiftYearAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount the donor gave in the year they directly contributed the largest value. Data
Processing Engine calculates this value by finding the total amount of all paid gift transactions
in the year when the donor gave the largest amount. You can schedule this calculation to
run on a regular basis.

HighestSoftCreditAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the largest single gift the donor influenced but didn't directly contribute. Data
Processing Engine calculates this value by finding the largest gift transaction for which the
donor receives soft credit. You can schedule this calculation to run on a regular basis.
HighestSoftCreditDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the largest single gift the donor influenced but didn't directly contribute. Data
Processing Engine calculates this value by finding the date of the largest gift transaction for
which the donor receives soft credit. You can schedule this calculation to run on a regular
basis.

LastGiftAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update


Description
The value of the donor's most recent directly contributed gift. Data Processing Engine
calculates this value by finding the amount of the donor's most recent paid gift transaction.
You can schedule this calculation to run on a regular basis.

LastGiftDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the donor's most recent directly contributed gift. Data Processing Engine calculates
this value by finding the date of the donor's most recent paid gift transaction. You can
schedule this calculation to run on a regular basis.

LastRecurringPaymentDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the donor last made a payment toward a recurring gift. Data Processing
Engine calculates this value by finding the date of the donor's most recent paid gift transaction
related to a recurring gift commitment. You can schedule this calculation to run on a regular
basis.
LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastSoftCreditAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the most recent gift the donor influenced but didn't directly contribute. Data
Processing Engine calculates this value by finding the amount of the most recent paid gift
transaction for which the donor received soft credit. You can schedule this calculation to run
on a regular basis.


LastSoftCreditDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the most recent gift the donor influenced but didn't directly contribute. Data
Processing Engine calculates this value by finding the date of the most recent paid gift
transaction for which the donor received soft credit. You can schedule this calculation to run
on a regular basis.

LastTwoYearGiftCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of gifts the donor directly contributed two calendar years ago. Data
Processing Engine calculates this value by counting the donor's paid gift transactions with
a transaction date from two calendar years ago. You can schedule this calculation to run on
a regular basis.

LastTwoYearSoftCreditCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of gift soft credit records attributed to the donor two years ago.
Available in API version 63.0 and later.
LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view.

LastVolunJobPstnAsgntDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The date of the contact's last volunteer shift. Data Processing Engine calculates this value by
finding the most recent job position assignment that is related to a volunteer initiative. You
can schedule this calculation to run on a regular basis.

LastYearGiftCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of gifts that the donor directly contributed last calendar year. Data
Processing Engine calculates this value by counting the number of the donor's paid gift
transactions with a transaction date in the last calendar year. You can schedule this calculation
to run on a regular basis.

LastYearSoftCreditCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of gift soft credits attributed to the donor last year.
Available in API version 63.0 and later.
LastYearSoftCreditsAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of soft credits earned by the donor last year.
Available in API version 63.0 and later.
LowestGiftAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The smallest single gift the donor directly contributed. Data Processing Engine calculates
this value by finding the amount of the smallest paid gift transaction of all of the donor's
paid gift transactions. You can schedule this calculation to run on a regular basis.

MonetaryScore

Type
int


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The score that represents the monetary value of the donor's gifts. Data Processing Engine
calculates this value according to how you configure RFM Scoring. You can schedule this
calculation to run on a regular basis.
Available in API version 61.0 and later.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The auto-numbered name that uniquely identifies the donor gift summary.

RecencyScore

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The score that represents the giving recency of a donor. Data Processing Engine calculates
this value according to how you configure RFM Scoring. You can schedule this calculation
to run on a regular basis.
Available in API version 61.0 and later.

SecondGiftDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the second gift the donor directly contributed. Data Processing Engine calculates
this value by finding the date of the donor's second paid gift transaction. You can schedule
this calculation to run on a regular basis.

SoftCreditCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of gifts the donor influenced and didn't directly contribute. Data Processing
Engine calculates this value by counting paid gift transactions for which the donor receives
soft credit. You can schedule this calculation to run on a regular basis.


TotalBookableRevenue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
Data Processing Engine calculates this value by subtracting any transactions associated with
booked pledges from the value of all transactions and booked pledges. You can schedule
this calculation to run on a regular basis.
Available in API version 62.0 and later.

TotalGiftsAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of all gifts the donor directly contributed. Data Processing Engine calculates this
value by adding the amounts of the donor's paid gift transactions. You can schedule this
calculation to run on a regular basis.

TotalHardSoftCredits

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of gifts the donor directly contributed and influenced. Data Processing Engine
calculates this value by counting the donor's paid transactions and paid transactions for
which the donor receives soft credit.. You can schedule this calculation to run on a regular
basis.

TotalHardSoftCreditsAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of all gifts the donor directly contributed and influenced. Data Processing Engine
calculates this value by adding the amounts of the donor's paid transactions and paid
transactions for which the donor receives soft credit.. You can schedule this calculation to
run on a regular basis.
TotalPaidRcrInstallments Type

int


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of recurring installments that the donor directly contributed. Data Processing
Engine calculates this value by counting the donor's paid gift transactions associated with
recurring gift commitments. You can schedule this calculation to run on a regular basis.

TotalPaidRcrInstlAmt

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of all of the recurring installments that the donor directly contributed. Data
Processing Engine calculates this value by adding the amounts of the donor's paid gift
transactions associated with recurring gift commitments. You can schedule this calculation
to run on a regular basis.

TotalVolunJobPstnAsgnCnt Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of times a contact has volunteered, which is the number of job position
assignments related to volunteer initiatives. The Data Processing Engine adds the assignments
and calculates the value. You can schedule this calculation to run regularly.
TotalVolunteerHours

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total hours a contact volunteered. The Data Processing Engine adds the hours from job
position assignments related to volunteer initiatives and calculates the value. You can schedule
this calculation to run regularly.

TotalSoftCreditsAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of all soft credits the donor has earned.
Available in API version 63.0 and later.


Represents the foundational data for calculating the future value of a planned gift, including life expectancy and discount rates. This
object is available in API version 65.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
Fields
Field

Details

ActuarialMethod

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the actuarial method of the actuarial entry.
Possible values are:
• Commutation Factors
• Discounted Rates
• Expectancy
• Not Applicable
• Present Value

AdjustmentFactor

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The factor used to adjust annuities based on the payment frequency of the actuarial entry.

AgeInYears

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The age in years of the person related to the actuarial entry.


AnnuityFactor

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The factor used to calculate the annuities of the actuarial entry.

CommutationFactor

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The commutation factor used to calculate the annuities and current values of the actuarial
entry.

DiscountFactor

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The factor used to calculate the applicable discount for the actuarial entry.

DurationInYears

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The time in years for which the actuarial entry applies.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date after which the actuarial entry isn't in effect.

Expectancy

Type
double
Properties
Create, Filter, Nillable, Sort, Update


Description
The life expectancy based on the actuarial model of the actuarial entry.

IncomeInterest

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The interest gained on the income of the person related to the actuarial entry.

InterestRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The interest rate percentage of the actuarial entry.

IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the actuarial entry is active (true) or not (false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.


MonthsToAnnualPayout

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of months before the annual payout of the actuarial entry.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the actuarial entry.

OlderAgeInYears

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The older age in years among two individuals.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

PaymentFrequency

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The payment frequency of the actuarial entry.


PayoutRate

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The payout rate of the actuarial entry.

RemainderFactor

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The factor used to calculate the remainder of the actuarial entry.

Source

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The source of the actuarial entry.

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date from which the actuarial entry takes effect.

Title

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The title of the actuarial entry.

ValuationFactor

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the valuation factor for the actuarial entry.


Version

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The version of the actuarial entry.

YoungerAgeInYears

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The younger age in years among two individuals.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftActuarialEntryChangeEvent on page 740
Change events are available for the object.
GiftActuarialEntryFeed on page 742
Feed tracking is available for the object.
GiftActuarialEntryHistory on page 739
History is available for tracked fields of the object.
GiftActuarialEntryOwnerSharingRule on page 738
Sharing rules are available for the object.
GiftActuarialEntryShare on page 738
Sharing is available for the object.

GiftStewardship
Represents stewardship of a gift by a contact or an organization that isn't a donor. This object is available in API version 65.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Special Access Rules
Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
ID of a person, household, or organization involved in the stewardship of the gift.
This field is a relationship field.
Relationship Name
Account
Refers To
Account

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
ID of the contact for the stewardship of the gift.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

DonorPreferences

Type
multipicklist
Properties
Create, Filter, Nillable, Update
Description
The donor's preferences for channels for communicating about the gift.
Possible values are:
• Annual Giving Summary
• Anonymous Recognition
• Custom Stewardship Plan
• Named Recognition
• Newsletter


• Physical Recognition Item
• Quarterly Impact Report

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of stewardship activities for the gift.

GiftAgreementId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
ID of the agreement associated with the stewardship of the gift.
This field is a relationship field.
Relationship Name
GiftAgreement
Refers To
GiftAgreement

GiftId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
ID of the gift under stewardship.
This field is a polymorphic relationship field.
Relationship Name
Gift
Refers To
GiftCommitment, GiftTransaction, PlannedGift

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.


LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the gift stewardship record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of stewardship activities for the gift.

Title

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The title of the gift stewardship record.


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftStewardshipChangeEvent on page 740
Change events are available for the object.
GiftStewardshipFeed on page 742
Feed tracking is available for the object.
GiftStewardshipHistory on page 739
History is available for tracked fields of the object.
GiftStewardshipOwnerSharingRule on page 738
Sharing rules are available for the object.
GiftStewardshipShare on page 738
Sharing is available for the object.

GiftStewardshipActivity
Represents an activity carried out as part of gift stewardship. This object is available in API version 65.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

ActivityDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the stewardship activity.

ActivityDescription

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
A description of the stewardship activity.

ActivityType

Type
picklist


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of stewardship activity.

AssignedToId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
ID of the team member responsible for the stewardship activity.
This field is a relationship field.
Relationship Name
AssignedTo
Refers To
User

GiftStewardshipId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The ID of the gift stewardship associated with the activity.
This field is a relationship field.
Relationship Name
GiftStewardship
Refers To
GiftStewardship

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the gift stewardship activity record.

Notes

Type
textarea
Properties
Create, Nillable, Update
Description
Notes on the stewardship activity and its outcomes.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the stewardship activity.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.


GiftStewardshipActivityChangeEvent on page 740
Change events are available for the object.
GiftStewardshipActivityFeed on page 742
Feed tracking is available for the object.
GiftStewardshipActivityHistory on page 739
History is available for tracked fields of the object.
GiftStewardshipActivityOwnerSharingRule on page 738
Sharing rules are available for the object.
GiftStewardshipActivityShare on page 738
Sharing is available for the object.

GiftAgreement
The agreement to accept a gift. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
A person, household, or organization associated with the gift agreement.
This field is a relationship field.
Relationship Name
Account
Refers To
Account

CaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The case associated with the gift agreement.
This field is a relationship field.
Relationship Name
Case
Refers To
Case

ComplianceStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of compliance review for the gift.
Possible values are:
• Compliant
• In Review
• Noncompliant
• Not Yet Submitted
• Requires Modification

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
A contact for the gift agreement.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

ContractId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The contract associated with the gift agreement.
This field is a relationship field.


Relationship Name
Contract
Relationship Type
Master-detail
Refers To
Contract (the master object)

GiftAgreementTitle

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The title of the gift agreement.

GiftType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of gift.
Possible values are:
• Capital Campaign
• In Development
• Major Gift
• Other Gift Concept
• Planned Gift
• Program and Support Gift Concept
• Specialized Gift

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description


Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the gift agreement record.

TotalGiftValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total monetary value of the gift as stated in the gift agreement.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftAgreementChangeEvent
Change events are available for the object.
GiftAgreementFeed
Feed tracking is available for the object.
GiftAgreementHistory
History is available for tracked fields of the object.
GiftAgreementOwnerSharingRule
Sharing rules are available for the object.
GiftAgreementShare
Sharing is available for the object.

GiftBatch
Represents the details and status of the batch of gifts. This object is available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.


Fields
Field

Details

DefaultGiftFieldValues

Type
textarea
Properties
Create, Nillable, Update
Description
The default values used for new Gift Entry Grid rows in a gift batch.
This field is available from API version 65.0 and later.

Description

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the gift batch.

DoesTotalGiftValueMatch Type

boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the total and estimated amount of gifts or total and estimated count of
gifts in the gift batch match (true) or not (false).
The default value is false.
EstimatedGiftCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The expected number of gifts in the gift batch.

ExpectedValueofGiftsinBatch Type

double
Properties
Create, Filter, Nillable, Sort, Update
Description
When a single currency is accepted, this field shows the expected total value in the default
currency of the gifts in the gift batch. When multiple currencies are accepted, this field is
currency agnostic and is used to validate Estimated and Actual Batch values.


FailedGiftCount

Type
int
Properties
Filter, Group, Nillable, Sort
Description
The number of gifts that failed to process.

LastProcessedDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The last date and time when the gift batch was processed.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The autogenerated name of the gift batch.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update


Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ProcessedGiftCount

Type
int
Properties
Filter, Group, Nillable, Sort
Description
The number of gifts that have been processed.

ScreenTemplateName

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Specifies the name of the screen template that's used for the gift batch.
Possible values are:
• Default
The default value is Default.

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the status of the gift batch.
Possible values are:
• Failed
• In Progress
• Partially Processed
• Processed
• Unprocessed
The default value is Unprocessed.


StatusReason

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reason for a gift batch status.

TotalBatchAmount

Type
double
Properties
Filter, Nillable, Sort
Description
When a single currency is accepted, this field shows the total value in the default currency
of the gifts in the gift batch. When multiple currencies are accepted, this field is currency
agnostic and is used to validate Estimated and Actual Batch values.

TotalGiftCount

Type
int
Properties
Filter, Group, Nillable, Sort
Description
The total number of gifts in the gift batch.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftBatchChangeEvent
Change events are available for the object.
GiftBatchFeed
Feed tracking is available for the object.
GiftBatchHistory
History is available for tracked fields of the object.
GiftBatchOwnerSharingRule
Sharing rules are available for the object.
GiftBatchShare
Sharing is available for the object.

GiftCommitment
Represents the commitment made by a donor. This object is available in API version 59.0 and later.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

CampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The campaign associated with this commitment.
This field is a relationship field.
Relationship Name
Campaign
Relationship Type
Lookup
Refers To
Campaign

CurrentGiftCmtScheduleId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The current, active schedule of the commitment.
This field is a relationship field.
Relationship Name
CurrentGiftCmtSchedule
Relationship Type
Lookup
Refers To
GiftCommitmentSchedule
Description

Type
textarea


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description about the gift commitment.

DonorId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The person, household, or organization account associated with this commitment.
This field is a relationship field.
Relationship Name
Donor
Relationship Type
Lookup
Refers To
Account

DonorGiftConceptId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift concept associated with the gift commitment.
This field is a relationship field.
Relationship Name
DonorGiftConcept
Relationship Type
Lookup
Refers To
DonorGiftConcept

EffectiveStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date from when the commitment is in effect.


EffectiveTransactionInterval Type

int
Properties
Filter, Group, Nillable, Sort
Description
The transaction interval that's applicable based on the currently active schedule.
EffectiveTransactionPeriod Type

string
Properties
Filter, Group, Nillable, Sort
Description
The transaction period that's applicable based on the currently active schedule.
ExpectedAssetMaturityDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The expected maturity date of all the committed assets for a commitment.
ExpectedAssetTransferDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The expected date of transferring all the committed assets for a commitment.
ExpectedEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the total amount of the commitment is expected to be fully paid.

ExpectedTotalCmtAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total donation amount that's expected for this commitment.


FormalCommitmentType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the formality type of the commitment.
Possible values are:
• Verbal
• Written
The default value is Verbal.

FulfillmentType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies whether the commitment fulfillment depends on one or more conditions or is
unconditional.
Possible values are:
• Conditional
• Unconditional
The default value is Unconditional.

GiftAgreementId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift agreement associated with the gift commitment.
This field is a relationship field.
Relationship Name
GiftAgreement
Relationship Type
Lookup
Refers To
GiftAgreement

GiftVehicle

Type
picklist


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the vehicle that's used to fulfill a gift commitment.
Possible values are:
• Bequest
• Charitable Gift Annuity
• Donor Advised Fund
• Life Insurance
• Other
• Pooled Income Fund
• Trust

GiftVehicleType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the type of gift vehicle that fulfills the gift commitment.
Possible values are:
• Charitable Lead Trust
• Charitable Remainder Trust
• Deferred Gift Annuity
• Flexible Gift Annuity
• Immediate Gift Annuity
• Other

IsAssetTransferExpected Type

boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the donor intends to transfer non-monetary assets or not.
The default value is false.
LastNextGenCmtProcDtTm

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update


Description
The date and time that this gift commitment was last processed and updated during the
NextGen commitment processing job.
Available in API version 67.0 and later.

LastNextGenCmtProcError Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The most recent error message for this gift commitment in the scheduled NextGen
commitment processing job.
Available in API version 67.0 and later.
LastPaidTransactionDate Type

date
Properties
Filter, Group, Nillable, Sort
Description
The date of the last paid transaction for the commitment.
LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update


Description
The name of the gift commitment.

NextTransactionAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The expected amount of the next gift transaction in the commitment schedule. This is
calculated automatically based on the currently active schedule.

NextTransactionDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the next gift transaction in the commitment schedule. This is calculated
automatically based on the currently active schedule.

OpportunityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The opportunity associated with this commitment.
This field is a relationship field.
Relationship Name
Opportunity
Relationship Type
Lookup
Refers To
Opportunity

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.


Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PartyPhilanthropicRsrchPrflId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The research profile related to the gift commitment.
This field is a relationship field.
Relationship Name
PartyPhilanthropicRsrchPrfl
Relationship Type
Lookup
Refers To
PartyPhilanthropicRsrchPrfl
PlannedGiftId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The planned gift associated with the gift commitment.
This field is a relationship field.
Relationship Name
PlannedGift
Relationship Type
Lookup
Refers To
PlannedGift

RecurrenceType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of recurrence of a commitment.


Possible values are:
• Fixed Length
• Open Ended
The default value is Open Ended.

ScheduleType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the schedule and type of the commitment.
Possible values are:
• Custom
• Recurring
The default value is Recurring.

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the commitment.
Possible values are:
• Active
• Closed
• Draft
• Failing
• Lapsed
• Paused
The default value is Draft.

TotCommitmentScheduleAmt Type

currency
Properties
Filter, Nillable, Sort
Description
The total expected donation amount that's calculated across all schedules in this commitment.
This field is a calculated field.


TotExpcAssetMaturityVal Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The expected maturity value of all the committed assets for a commitment.
TotExpcAssetTransferVal Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total expected value of all the committed assets when they're transferred for a
commitment.
TotalAssetPresentValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total current value of all the committed assets for a commitment.

TotalCurrentMonth

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of all gift commitments made for the current month. This field is available
from API version 62.0 and later.

TotalCurrentQuarter

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of all gift commitments made for the current quarter. This field is available
from API version 62.0 and later.

TotalCurrentYear

Type
currency
Properties
Create, Filter, Nillable, Sort, Update


Description
The total value of all gift commitments made for the current year. This field is available from
API version 62.0 and later.

TotalNextYear

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of all gift commitments made for the next year. This field is available from
API version 62.0 and later.

TotalPaidTransactionAmount Type

currency
Properties
Filter, Nillable, Sort
Description
The total amount of paid gift transactions for the commitment.
TransactionPaymentCount Type

int
Properties
Filter, Group, Nillable, Sort
Description
The number of paid gift transactions for the commitment.
WrittenOffAmount

Type
currency
Properties
Filter, Nillable, Sort
Description
The total amount of written-off gift transactions for this commitment.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftCommitmentChangeEvent (API Version 62.0)
Change events are available for the object.
GiftCommitmentFeed
Feed tracking is available for the object.


History is available for tracked fields of the object.
GiftCommitmentOwnerSharingRule (API Version 64.0)
Sharing rules are available for the object.
GiftCommitmentShare
Sharing is available for the object.

GiftCmtChangeAttrLog
Represents the history of changes to a Gift Commitment over time with attribution to the source campaign or source code attributed
to that change. This object is available in API version 60.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

CampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The campaign associated with this commitment.
This field is a relationship field.
Relationship Name
Campaign
Relationship Type
Lookup
Refers To
Campaign

ChangePerDayAmount

Type
currency


Properties
Create, Filter, Sort, Update
Description
The change in amount of the commitment converted to amount per day.

ChangeStatus

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update
Description
The status of the change to the commitment.
Possible values are:
• Downgrade
• Neutral
• Pause
• Resume
• Upgrade
The default value is Upgrade.

ChangeType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies the type of change to the commitment. It’s value is populated based on the current
schedule and the schedule before it.
Possible values are:
• Amount- When the amount changes, comparing the actual amount on the schedule.
• Frequency- When the Transaction Interval or Transaction Period changes.
• Frequency and Amount- When both the interval and the amount changes.
Applies when the first commitment is scheduled, the current schedule is paused or when
a paused schedule is resumed.
The default value is Frequency.

EffectiveDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The effective date for the commitment change.


GiftCommitmentId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The commitment associated with this gift commitment schedule.
This field is a relationship field.
Relationship Name
GiftCommitment
Relationship Type
Master-Detail
Refers To
GiftCommitment

GiftCommitmentScheduleId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift commitment schedule associated with the gift transaction.
This field is a relationship field.
Relationship Name
GiftCommitmentSchedule
Relationship Type
Lookup
Refers To
GiftCommitmentSchedule
LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the gift commitment schedule.

OutreachSourceCodeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach source code associated with this gift commitment attribution change log.
This field is a relationship field.
Relationship Name
OutreachSourceCode
Relationship Type
Lookup
Refers To
OutreachSourceCode

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftCmtChangeAttrLogFeed
Feed tracking is available for the object.
GiftCmtChangeAttrLogHistory
History is available for tracked fields of the object.

GiftCommitmentSchedule
Represents the schedule for fulfilling the commitment. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

CampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The campaign associated with this gift commitment schedule. All gift transactions associated
with this gift commitment schedule are associated with this campaign.
This field is a relationship field.
Relationship Name
Campaign
Relationship Type
Lookup
Refers To
Campaign

CampaignName

Type
string
Properties
Filter, Group, Nillable, Sort
Description
The name of the campaign associated with the gift commitment schedule.

CommitmentUpdateReason

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reason the gift commitment schedule changed.
Possible values are:
• Payment Method Declined
• Financial Hardship


EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the new schedule for this gift commitment.

GenerationalCohort

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The generational cohort associated with the gift commitment schedule.
Possible values are:
• Baby Boomers (1946-1964)
• Generation Alpha (2013-2025)
• Generation X (1965-1980)
• Generation Z (1997-2012)
• Millennials (1981-1996)
• Silent Generation (1928-1945)

GiftCommitmentId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The commitment associated with this gift commitment schedule. A value is always required
in this field to save the record.
This field is a relationship field.
Relationship Name
GiftCommitment
Relationship Type
Master-Detail
Refers To
GiftCommitment

GiftCommitmentName

Type
string
Properties
Filter, Group, Nillable, Sort


Description
The name of the related gift commitment.

GiftCommitmentSchdBefEditId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The schedule that's associated with the current gift commitment schedule before it was
edited
This field is a relationship field.
Relationship Name
GiftCommitmentSchdBefEdit
Relationship Type
Lookup
Refers To
GiftCommitmentSchedule
GiftCommitmentStatus

Type
picklist
Properties
Defaulted on create, Filter, Group, Nillable, Sort
Description
The status of the gift commitment that's fulfilled by the schedule.
Possible values are:
• Active
• Closed
• Draft
• Failing
• Lapsed
• Paused
The default value is Draft.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.


LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the gift commitment schedule.

OutreachSourceCodeId

Type
lookup
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach source code associated with the gift transaction.
This field is a relationship field. This field is available from API version 60.0 and later.
Relationship Name
OutreachSourceCode
Relationship Type
Lookup
Refers To
OutreachSourceCode

PaymentInstrumentId

Type
lookup
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The Payment Instrument used to complete the transaction. This field is available from API
version 60.0 and later.
This field is a relationship field.
Relationship Name
PaymentInstrument
Relationship Type
Lookup


Refers To
PaymentInstrument

PaymentMethod

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The payment method for the transactions associated with this gift commitment schedule.
All transactions associated with the commitment schedule default to this gift payment
method.
Possible values are:
• ACH
• Asset
• Cash
• Check
• Credit Card
• Cryptocurrency
• In-Kind
• PayPal
• Stock
• Unknown
• Venmo

ProcessorReference

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reference of the payment processor associated with the payment instrument. This field
is available from API version 60.0 and later.

StartDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The start date of the new schedule for this gift commitment. A value is always required in
this field to save the record.


TotalScheduleAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The expected total amount of all gift transactions associated with the gift commitment
schedule.

TransactionAmount

Type
currency
Properties
Create, Filter, Sort, Update
Description
The gift amount of each transaction associated with the gift commitment schedule. A value
is always required in this field to save the record.

TransactionDay

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The day of the month to create gift transaction in the future for a monthly or yearly transaction
period. If you select the day as 29 or 30, the gift transaction will be created on the last day
for months that don't have that many days.
Possible values are the numbers 1 through 30 or the value LastDay.
The default value is 1.
Always required when the Transaction Period is Monthly.

TransactionInterval

Type
int
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The interval of running the gift commitment schedule. The transaction period and interval
define how the schedule is run. For example, if the transaction period is monthly and the
transaction interval is 3, the schedule is run after every three months.

TransactionPeriod

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update


Description
The period for which the gift commitment schedule is run. The transaction period and
frequency define how the schedule is run. For example, if the transaction period is monthly
and the transaction frequency is 3, the schedule is run after every three months. A value is
always required in this field to save the record.
Possible values are:
• Custom
• Daily
• Monthly
• Weekly
• Yearly
The default value is Monthly.

Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies the type of gift commitment schedule. A value is always required in this field to
save the record.
Possible values are:
• Create Transactions
• Pause Transactions
The default value is Create Transactions.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftCommitmentScheduleChangeEvent (API Version 62.0)
Change events are available for the object.
GiftCommitmentScheduleFeed
Feed tracking is available for the object.
GiftCommitmentScheduleHistory
History is available for tracked fields of the object.
GiftCommitmentScheduleOwnerSharingRule (API Version 64.0)
Sharing rules are available for the object.
GiftCommitmentScheduleShare (API Version 64.0)
Sharing is available for the object.


Represents the default designation for gifts that originate from an opportunity, campaign, or commitment. This object is available in API
version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

AllocatedPercentage

Type
percent
Properties
Create, Filter, Sort, Update
Description
The percentage of the gift that's allocated to this designation.

GiftDesignationId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The gift designation associated with this gift default designation.
A value is always required in this field to save the record.
This field is a relationship field.
Relationship Name
GiftDesignation
Relationship Type
Lookup
Refers To
GiftDesignation

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The auto-numbered name that uniquely identifies this gift default designation.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentRecordId

Type
reference
Properties
Create, Filter, Group, True, Sort, Update
Description
The parent record of this gift default designation.
A value is always required in this field to save the record.
This field is a polymorphic relationship field.


Relationship Name
ParentRecord
Relationship Type
Lookup
Refers To
Campaign, GiftCommitment, Opportunity

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftDefaultDesignationChangeEvent (API Version 64.0)
Change events are available for the object.
GiftDefaultDesignationFeed
Feed tracking is available for the object.
GiftDefaultDesignationHistory
History is available for tracked fields of the object.
GiftDefaultDesignationOwnerSharingRule (API Version 64.0)
Sharing rules are available for the object.
GiftDefaultDesignationShare
Sharing is available for the object.

GiftDefaultSoftCredit
Represents the default allocation for soft credits on gift commitment transactions that are created by a recurrence engine and credited
to constituents who influenced the commitment. This object is available in API version 62.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

LastReferencedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The unique, auto-numbered name of the gift default soft credit.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

ParentRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The parent opportunity, or gift commitment record that's related to this default soft credit.
This field is a polymorphic relationship field.


Relationship Name
ParentRecord
Refers To
GiftCommitment, Opportunity

PartialAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount of the gift transaction that's allocated as a soft credit to the specified recipient.

PartialPercent

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of the gift transaction that's allocated as a soft credit to the specified recipient.

RecipientId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The person or organization account that's associated with the soft credit.
This field is a relationship field.
Relationship Name
Recipient
Refers To
Account

Role

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The soft credit role of the account or contact.
Possible values are:
• Honoree
• Household Member
• Influencer


• Matched Donor
• Other
• Soft Credit
• Solicitor
• Third Party Donor
The default value is Soft Credit.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftDefaultSoftCreditChangeEvent (API Version 64.0)
Change events are available for the object.
GiftDefaultSoftCreditFeed (API Version 64.0)
Feed tracking is available for the object.
GiftDefaultSoftCreditHistory
History is available for tracked fields of the object.
GiftDefaultSoftCreditOwnerSharingRule
Sharing rules are available for the object.
GiftDefaultSoftCreditShare
Sharing is available for the object.

GiftDesignation
Represents a designation that can be assigned to a gift transaction. This object is available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

AverageTransactionAmount Type

currency


Properties
Create, Filter, Nillable, Sort, Update
Description
The average value of all paid gift transactions related to the related gift designation. Data
Processing Engine calculates this value by dividing the gift designation's total transaction
amount by its total transaction count. You can schedule this calculation to run on a regular
basis.

CurrentYearTransactionCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The count of the current year's paid transactions related to the related gift designation. Data
Processing Engine calculates this value by counting the gift designation's paid gift transactions
with a transaction date in this calendar year. You can schedule this calculation to run on a
regular basis.
CurrentYearTrxnAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the current year's paid transactions related to the related gift designation. Data
Processing Engine calculates this value by adding the amounts of the gift designation's paid
gift transactions with a transaction date this calendar year. You can schedule this calculation
to run on a regular basis.

Description

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the gift designation.

FirstPaidTransactionDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the first paid gift transaction related to the related gift designation. Data Processing
Engine calculates this value by finding the date of the first paid gift transaction related to
the gift designation. You can schedule this calculation to run on a regular basis.


HighestTransactionAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The highest transaction value associated with the related gift designation. Data Processing
Engine calculates this value by finding the amount of the largest paid gift transaction related
to the gift designation. You can schedule this calculation to run on a regular basis.
IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates if the gift designation is active (true) or not (false).
The default value is true.

IsDefault

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the unrestricted gift amount is to be allocated to this designation as default
(true) or not (false). There can only be a single designation with this set to true at a
time.
The default value is false.

LastPaidTransactionDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the most recent paid gift transaction related to the related gift designation. Data
Processing Engine calculates this value by finding the date of the most recent related paid
gift transaction related to the gift designation. You can schedule this calculation to run on
a regular basis.
LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastTwoYearTrxnAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the gift transactions completed two calendar years ago related to the related
gift designation. Data Processing Engine calculates this value by adding the amounts of all
paid gift transactions related to the gift designation with a transaction date from two calendar
years ago. You can schedule this calculation to run on a regular basis.

LastTwoYearTrxnCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The count of gift transactions made two calendar years ago that are related to the related
gift designation. Data Processing Engine calculates this value by counting all paid gift
transactions related to the gift designation with a transaction date from two calendar years
ago. You can schedule this calculation to run on a regular basis.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view.

LastYearTransactionCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The count of gift transactions related to the related gift designation and made last calendar
year. Data Processing Engine calculates this value by counting all paid gift transactions related
to the gift designation with a transaction date in the last calendar year. You can schedule
this calculation to run on a regular basis.


LastYearTrxnAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of gift transactions related to the related gift designation and completed last
calendar year. Data Processing Engine calculates this value by adding the amounts of all paid
gift transactions related to the gift designation with a transaction date from the last calendar
year. You can schedule this calculation to run on a regular basis.

LowestTransactionAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the smallest paid transaction related to the related gift transaction. Data
Processing Engine calculates this value by finding the smallest paid gift transaction amount
related to the related gift designation. You can schedule this calculation to run on a regular
basis.
Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the gift designation.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User


TotalTransactionAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of all gift transactions related to the related gift designation. Data Processing
Engine calculates this value by adding the total amounts of all paid gift transactions related
to the gift designation. You can schedule this calculation to run on a regular basis.

TotalTransactionCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The count of all paid transactions related to the related gift designation. Data Processing
Engine calculates this value counting the paid gift transactions related to the gift designation.
You can schedule this calculation to run on a regular basis.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftDesignationChangeEvent (API Version 64.0)
Change events are available for the object.
GiftDesignationFeed
Feed tracking is available for the object.
GiftDesignationHistory
History is available for tracked fields of the object.
GiftDesignationOwnerSharingRule (API Version 64.0)
Sharing rules are available for the object.
GiftDesignationShare
Sharing is available for the object.

GiftEntry
Represents gifts created individually or in a batch before they're processed and logged in their target records. After processing, these
records serve as an audit trail for gift transactions. This object is available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

CampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The campaign that's associated with the gift entry.
This field is a relationship field.
Relationship Name
Campaign
Relationship Type
Lookup
Refers To
Campaign

CheckDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date on the check that is used as the payment method for the gift.

City

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The city where the donor resides.

Country

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The country where the donor resides.


CurrencyIsoCode

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Identifies the currency used for the gift transaction.
Valid value is:
• USD—U.S. Dollar
The default value is USD. Available in API version 61.0 and later.

DonorCoverAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The fee amount that a donor pays in addition to the gift amount.

DonorId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The person, household, or organization account associated with the gift.
This field is a relationship field.
Relationship Name
Donor
Relationship Type
Lookup
Refers To
Account

EffectiveStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date from when the commitment is in effect. Available in API version 61.0 and later.

Email

Type
email


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The email of the donor.

ExpectedEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the total amount of the commitment is expected to be paid. Available in API
version 61.0 and later.

ExpiryMonth

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The month of the credit card expiration date. This field is available from API version 60.0 and
later.

ExpiryYear

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The year of the credit card expiration date. This field is available from API version 60.0 and
later.

FirstName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The first name of the donor.

GiftAmount

Type
currency
Properties
Create, Filter, Sort, Update
Description
The amount of the gift.


GiftBatchId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The parent gift batch that's associated with the gift entry.
This field is a relationship field.
Relationship Name
GiftBatch
Relationship Type
Lookup
Refers To
GiftBatch

GiftCommitmentId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift commitment that's associated with the gift entry.
This field is a relationship field.
Relationship Name
GiftCommitment
Relationship Type
Lookup
Refers To
GiftCommitment

GiftDesignation1Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount to be allocated to designation 1.

GiftDesignation1Id

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the designation 1 to which the gift amount is to be allocated.


This field is a relationship field.
Relationship Name
GiftDesignation1
Relationship Type
Lookup
Refers To
GiftDesignation

GiftDesignation1Percent Type

percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of gift amount to be allocated to designation 1 if the direct amount isn’t
being allocated.
GiftDesignation2Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount to be allocated to designation 2.

GiftDesignation2Id

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the designation 2 to which the gift amount is to be allocated.
This field is a relationship field.
Relationship Name
GiftDesignation2
Relationship Type
Lookup
Refers To
GiftDesignation

GiftDesignation2Percent Type

percent
Properties
Create, Filter, Nillable, Sort, Update


Description
The percentage of gift amount to be allocated to designation 2 if the direct amount isn’t
being allocated.

GiftDesignation3Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount to be allocated to designation 3.

GiftDesignation3Id

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the designation 3 to which the gift amount is to be allocated.
This field is a relationship field.
Relationship Name
GiftDesignation3
Relationship Type
Lookup
Refers To
GiftDesignation

GiftDesignation3Percent Type

percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of gift amount to be allocated to designation 3 if the direct amount isn’t
being allocated.
GiftProcessingResult

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The processing result of the gift entry record.


GiftDesignationInformation Type

textarea
Properties
Create, Nillable, Update
Description
Details about the gift designation such as the designation name, amount, or percentage of
the gift that's allocated to the designation.
Available in API version 66.0 and later.
GiftProcessingStatus

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the processing status of the gift entry.
Possible values are:
• Failure
• New
• Success
The default value is New.

GiftReceivedDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The date when the gift is received.

GiftTransactionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift transaction that's associated with the gift entry.
This field is a relationship field.
Relationship Name
GiftTransaction
Relationship Type
Lookup


Refers To
GiftTransaction

GiftType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies the type of gift that's associated with the gift entry.
Possible values are:
• Individual
• Organizational
The default value is Individual.

HomePhone

Type
phone
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The home phone number of the donor.

IsNewRecurringGift

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the gift is a new recurring gift commitment (true) or not (false).
The default value is false. Available in API version 61.0 and later.

IsSetAsDefault

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the values in the gift entry are used as default values in other gift entries
of the gift batch or not.
The default value is false.

Last4

Type
string


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The last 4 digits of the credit card or bank account. This field is available from API version
60.0 and later.

LastName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The last name of the donor.

LastProcessedDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the gift entry was last processed.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

MobilePhone

Type
phone
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The mobile number of the donor.


Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the gift entry record.

OrganizationName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the donating organization that's associated with the gift entry.

OutreachSourceCodeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach source code that's associated with the campaign for the gift entry record.
This field is a relationship field.
Relationship Name
OutreachSourceCode
Relationship Type
Lookup
Refers To
OutreachSourceCode

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User


PaymentIdentifier

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The identifier of the payment method for the gift, such as check number, transaction order
number, merchant order number.

PaymentMethod

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the payment method used for this gift.
Possible values are:
• ACH
• Asset
• Cash
• Check
• Credit Card
• Cryptocurrency
• In-Kind
• PayPal
• Stock
• Unknown
• Venmo

PostalCode

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The postal code from the donor's address.

Salutation

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
Specifies the honorific abbreviation, word, or phrase to be used in front of the donor's name
in greetings, such as Dr. or Mrs.
Possible values are:
• Dr.
• Mr.
• Mrs.
• Ms.
• Mx.
• Prof.

SoftCreditInformation

Type
textarea
Properties
Create, Nillable, Update
Description
The information about the soft credit, such as the name of the soft creditor, role, and amount
or percentage of soft credit allocated to the soft creditor.

State

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the state or province where the donor resides.

Street

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The street details from the donor's address.

TotalTransactionFeeAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total transaction fees charged by the payment processor for the gift. For example,
application fees, processing fees.


TransactionDay

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the day of the month to create gift transaction in the future for a monthly transaction
period. If you select the day as 29 or 30, the gift transaction will be created on the last day
for months that don't have that many days.
Valid values are: numerals 1–30 and LastDay (of the month)
The default value is 1. Available in API version 61.0 and later.

TransactionInterval

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The interval of running the gift commitment schedule. The transaction period and interval
define how the schedule is run. For example, if the transaction period is monthly and
transaction interval is 3, the schedule is run after every three months. Available in API version
61.0 and later.

TransactionPeriod

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The period for which the gift commitment schedule is run. The transaction period and
frequency define how the schedule is run. For example, if the transaction period is monthly
and transaction frequency is 3, the schedule is run after every three months.
Valid values are:
• Custom
• Daily
• Monthly
• Weekly
• Yearly
The default value is Monthly. Available in API version 61.0 and later.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.


Change events are available for the object.
GiftEntryFeed
Feed tracking is available for the object.
GiftEntryHistory
History is available for tracked fields of the object.
GiftEntryOwnerSharingRule
Sharing rules are available for the object.
GiftEntryShare
Sharing is available for the object.

GiftRefund
Represents a refund of a gift. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

Amount

Type
currency
Properties
Create, Filter, Sort, Update
Description
The amount of the refund.

Date

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The date the transaction was refunded.


GatewayTransactionFee

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The transaction fee charged by the payment gateway. This field is available from API version
60.0 and later.

GiftTransactionId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The gift transaction associated with this refund.
This field is a relationship field.
Relationship Name
GiftTransaction
Relationship Type
Master-Detail
Refers To
GiftTransaction

LastGatewayErrorMessage Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The most recent error message that's received by the gateway. This field is available from
API version 60.0 and later.
LastGatewayProcessedDate Type

dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time of the last processing attempt by the gateway. This field is available from
API version 60.0 and later.
LastGatewayResponseCode Type

string


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The most recent response code that's received by the gateway. This field is available from
API version 60.0 and later.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The unique, auto-numbered name of the gift refund.

ProcessorTransactionFee Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The transaction fee charged by the payment processor. This field is available from API version
60.0 and later.
Reason

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The reason for the refund.
Possible values are:
• Donor Request
• Incorrect Amount

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the refund.
Possible values are:
• Completed
• Failed
• Initiated

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftRefundChangeEvent (API Version 62.0)
Change events are available for the object.
GiftRefundFeed
Feed tracking is available for the object.
GiftRefundHistory
History is available for tracked fields of the object.
GiftRefundOwnerSharingRule (API Version 64.0)
Sharing rules are available for the object.
GiftRefundShare(API Version 64.0)
Sharing is available for the object.

GiftSoftCredit
Represents the soft credit attributed to a person or organization for the gift transaction. This object is available in API version 59.0 and
later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

GiftTransactionId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The gift transaction associated with this soft credit.
This field is a relationship field.
Relationship Name
GiftTransaction
Relationship Type
Master-Detail
Refers To
GiftTransaction

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view


Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The unique, auto-numbered name of the gift soft credit.

PartialAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount of the soft credit when it isn't the full transaction amount.

PartialPercent

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of the full transaction amount for this soft credit when it isn't the full
transaction amount.
Note: Soft Credit percent values don’t need to total to 100% when there are multiple
soft credit records.

PartyPhilanthropicRsrchPrflId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The research profile associated with the gift.
This field is a relationship field.
Relationship Name
PartyPhilanthropicRsrchPrfl
Relationship Type
Lookup
Refers To
PartyPhilanthropicRsrchPrfl
RecipientId

Type
reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The person account that's associated with the soft credit.
This field is a relationship field.
Relationship Name
Recipient
Relationship Type
Lookup
Refers To
Account

Role

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The soft credit role of the account or contact.
Possible values are:
• Honoree
• Household Member
• Influencer
• Matched Donor
• Other
• Soft Credit
• Solicitor
• Third Party Donor
The default value is Soft Credit.

SoftCreditAmount

Type
currency
Properties
Filter, Nillable, Sort
Description
The calculated amount of the soft credit.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.


GiftSoftCreditChangeEvent (API Version 62.0)
Change events are available for the object.
GiftSoftCreditFeed
Feed tracking is available for the object.
GiftSoftCreditHistory
History is available for tracked fields of the object.
GiftSoftCreditOwnerSharingRule
Sharing rules are available for the object.
GiftSoftCreditShare (API Version 64.0)
Sharing is available for the object.

GiftTransaction
Represents a completed transaction from a gift. This object is available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

AcknowledgementDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the gift transaction was acknowledged.

AcknowledgementStatus

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the acknowledgement that's sent for the gift transaction.
Possible values are:
• Don't Send
• Sent


• To Be Sent
The default value is To Be Sent.

CampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The campaign associated with the gift transaction.
This field is a relationship field.
Relationship Name
Campaign
Relationship Type
Lookup
Refers To
Campaign

CheckDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date on the check.

CurrencyIsoCode

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Identifies the currency used for the gift transaction.
Valid value is:
• USD—U.S. Dollar
The default value is USD. Available in API version 61.0 and later.

CurrentAmount

Type
currency
Properties
Filter, Nillable, Sort
Description
This field is a calculated field.


Description

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the gift transaction.

DonorCoverAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount the donor added to their gift to cover fees. Available in API version 61.0 and
later.

DonorGiftConceptId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift concept associated with the gift.
This field is a relationship field.
Relationship Name
DonorGiftConcept
Relationship Type
Lookup
Refers To
DonorGiftConcept

DonorId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The person, household, or organization account associated with the gift transaction.
This field is a relationship field.
Relationship Name
Donor
Relationship Type
Lookup


Refers To
Account

GatewayReference

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Reference of the transaction that the gateway assigned. This field is available from API version
60.0 and later.

GatewayTransactionFee

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The transaction fee charged by the payment gateway. This field is available from API version
60.0 and later.

GiftAgreementId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift agreement associated with the gift transaction.
This field is a relationship field.
Relationship Name
GiftAgreement
Relationship Type
Lookup
Refers To
GiftAgreement

GiftCommitmentId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift commitment associated with the gift transaction.
This field is a relationship field.


Relationship Name
GiftCommitment
Relationship Type
Lookup
Refers To
GiftCommitment

GiftCommitmentScheduleId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift commitment schedule associated with the gift transaction.
This field is a relationship field.
Relationship Name
GiftCommitmentSchedule
Relationship Type
Lookup
Refers To
GiftCommitmentSchedule
GiftType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of gift that's associated with the gift transaction.
Possible values are:
• Individual
• Organizational
The default value is Individual.

IsFullyRefunded

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Set to true when Status equals Fully Refunded. You can query and filter on this
field, but you cannot directly set the value.


IsPaid

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Set to true when Status equals Paid and Current Amount equals 0. You can query
and filter on this field, but you cannot directly set the value.

IsPartiallyRefunded

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Set to true when Status equals Paid and Current Amount is greater than 0. You can
query and filter on this field, but you cannot directly set the value.

IsWrittenOff

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Set to true when Status equals Written-Off. You can query and filter on this field, but
you cannot directly set the value.

LastGatewayErrorMessage Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The most recent error message that's received by the gateway. This field is available from
API version 60.0 and later.
LastGatewayProcessedDate Type

dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time of the last processing attempt by the gateway. This field is available from
API version 60.0 and later.
LastGatewayResponseCode Type

string


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The most recent response code that's received by the gateway. This field is available from
API version 60.0 and later.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn't null, the user accessed this record or list view.

MatchingEmployerTransactionId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift transaction made by the employer that matches the gift transaction.
This field is a relationship field.
Relationship Name
MatchingEmployerTransaction
Relationship Type
Lookup
Refers To
GiftTransaction
Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update


Description
The name of the gift transaction.

NonTaxDeductibleAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The portion of the gift transaction amount that can't be claimed as a tax deduction by the
donor. Available in API version 61.0 and later.

OriginalAmount

Type
currency
Properties
Create, Filter, Sort, Update
Description
The original amount of gift transaction that includes donor cover and excludes the transaction
fees. A value is always required in this field to save the record.

OutreachSourceCodeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach source code associated with the gift transaction.
This field is a relationship field.
Relationship Name
OutreachSourceCode
Relationship Type
Lookup
Refers To
OutreachSourceCode

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.


Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PartyPhilanthropicRsrchPrflId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The research profile associated with the gift.
This field is a relationship field.
Relationship Name
PartyPhilanthropicRsrchPrfl
Relationship Type
Lookup
Refers To
PartyPhilanthropicRsrchPrfl
PaymentIdentifier

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reference number associated with the payment method for the gift, such as check
number, transaction order number, merchant order number.

PaymentInstrumentId

Type
lookup
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The Payment Instrument used to complete the transaction. This field is available from API
version 60.0 and later.
This field is a relationship field.
Relationship Name
PaymentInstrument
Relationship Type
Lookup


Refers To
PaymentInstrument

PaymentMethod

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the payment method used to complete the gift transaction. A value is always
required in this field to save the record.
Possible values are:
• ACH
• Asset
• Cash
• Check
• Credit Card
• Cryptocurrency
• In-Kind
• PayPal
• Stock
• Unknown
• Venmo

ProcessorReference

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reference of the payment processor associated with the payment instrument. This field
is available from API version 60.0 and later.

ProcessorTransactionFee Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The transaction fee charged by the payment processor. This field is available from API version
60.0 and later.
RefundedAmount

Type
currency


Properties
Defaulted on create, Filter, Nillable, Sort
Description
The amount of the original gift transaction that was refunded.
This field is a calculated field.

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Specifies the status of the gift transaction. A value is always required in this field to save the
record.
Possible values are:
• Canceled
• Failed
• Fully Refunded
• Paid
• Pending
• Unpaid
• Written-Off
The default value is Unpaid.

TaxReceiptStatus

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the tax receipt for the gift transaction. This field is available from API
version 62.0 and later.
Possible values are:
• Don't Send
• Sent
• To Be Sent
The default value is To Be Sent.

TotalTransactionFee

Type
currency
Properties
Filter, Nillable, Sort


Description
The total amount of fees charged by the payment gateway and processor for this transaction.
This field is available from API version 60.0 and later.
This field is a calculated field.

TransactionDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the donor completed the gift transaction.
This field is required if the gift transaction status is set to Paid or Fully Refunded.

TransactionDueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The expected date of the scheduled gift transaction.
This field is required if the gift transaction is related to a gift commitment.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftTransactionChangeEvent (API Version 62.0)
Change events are available for the object.
GiftTransactionFeed
Feed tracking is available for the object.
GiftTransactionHistory
History is available for tracked fields of the object.
GiftTransactionOwnerSharingRule
Sharing rules are available for the object.
GiftTransactionShare
Sharing is available for the object.

GiftTransactionDesignation
Represents a junction between a gift transaction and a gift designation. This object is available in API version 59.0 and later.


Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount of the transaction allocated to the designation.

GiftDesignationId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift designation associated with this transaction designation. A value is always required
in this field to save the record.
This field is a relationship field.
Relationship Name
GiftDesignation
Relationship Type
Lookup
Refers To
GiftDesignation

GiftTransactionId

Type
reference
Properties
Create, Filter, Group, Sort


Description
The transaction associated with this transaction designation. A value is always required in
this field to save the record.
This field is a relationship field.
Relationship Name
GiftTransaction
Relationship Type
Master-Detail
Refers To
GiftTransaction

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The auto-numbered name that uniquely identifies this transaction designation.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.


Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

Percent

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of the transaction amount allocated to the designation.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftTransactionDesignationChangeEvent (API Version 62.0)
Change events are available for the object.
GiftTransactionDesignationFeed
Feed tracking is available for the object.
GiftTransactionDesignationHistory
History is available for tracked fields of the object.
GiftTransactionDesignationOwnerSharingRule (API Version 64.0)
Sharing rules are available for the object.
GiftTransactionDesignationShare
Sharing is available for the object.

GiftTribute
Represents the details and status of the gift tribute. This object is available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.


Fields
Field

Details

GiftCommitmentId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift commitment associated with this tribute.
This field is a relationship field.
Relationship Name
GiftCommitment
Relationship Type
Lookup
Refers To
GiftCommitment

GiftTransactionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift transaction associated with this tribute.
This field is a relationship field.
Relationship Name
GiftTransaction
Relationship Type
Lookup
Refers To
GiftTransaction

HonoreeContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact (person account) associated with the tribute gift transaction.
This field is a relationship field.
Relationship Name
HonoreeContact


Relationship Type
Lookup
Refers To
Account

HonoreeInformation

Type
textarea
Properties
Create, Nillable, Update
Description
The additional details of the tribute recipient.

HonoreeName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the person being honored by the tribute gift transaction.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The unique, auto-numbered name of the gift tribute.


NotificationChannel

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies how to notify the tribute notification contact should be notified.
Possible values are:
• Email
• Mail

NotificationContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact (person account) who should be notified of the tribute gift transaction.
This field is a relationship field.
Relationship Name
NotificationContact
Relationship Type
Lookup
Refers To
Account

NotificationContactName Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the person who should be notified of the tribute gift transaction.
NotificationDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the recipient was notified about the tribute.

NotificationEmail

Type
email


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The email that's used to notify a person about the tribute gift transaction.

NotificationInfo

Type
textarea
Properties
Create, Nillable, Update
Description
The information about the person who should be notified of the tribute gift transaction.

NotificationMessage

Type
textarea
Properties
Create, Nillable, Update
Description
The notification message that's sent for the tribute gift transaction.

NotificationStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the notification sent to the tribute recipient.
Possible values are:
• Don't Send
• Sent
• To Be Sent

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup


Refers To
Group, User

TributeType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the type of tribute when a gift is given on behalf of someone else.
Possible values are:
• Honor
• Memorial

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftTributeChangeEvent (API Version 64.0)
Change events are available for the object.
GiftTributeFeed
Feed tracking is available for the object.
GiftTributeHistory
History is available for tracked fields of the object.
GiftTributeOwnerSharingRule (API Version 64.0)
Sharing rules are available for the object.
GiftTributeShare
Sharing is available for the object.

GiftValueForecast
The past, current, and projected monetary value of a gift. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.


Fields
Field

Details

ActuarialFactor

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
A factor based on actuarial assumptions that’s used to calculate the gift’s future value.

CurrentValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The gift's current value.

GiftId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The gift associated with the gift value forecast.
This field is a polymorphic relationship field.
Relationship Name
Gift
Refers To
GiftCommitment, PlannedGift

InitialValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The gift's initial value.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description


LastUpdatedDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the gift’s value was last updated.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

MaturityDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the gift’s expected to mature.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the gift value forecast record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

ProjectedValue

Type
currency


Properties
Create, Filter, Nillable, Sort, Update
Description
The gift’s projected value at maturity.

StartDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The start date for tracking the gift’s value.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GiftValueForecastChangeEvent
Change events are available for the object.
GiftValueForecastFeed
Feed tracking is available for the object.
GiftValueForecastHistory
History is available for tracked fields of the object.
GiftValueForecastOwnerSharingRule
Sharing rules are available for the object.
GiftValueForecastShare
Sharing is available for the object.

GratefulPersonInvolvement
Represents a person’s contextual relationship of gratitude with an institution, capturing the originating program or experience, attribution
context, consent status, and engagement or solicitation constraints. This object is available in API version 67.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Fields
Field

Details

Consent

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the consent status.
Possible values are:
• Not Specified
• Opted In
• Opted Out

ConsentEmbargoUntil

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date until which solicitation and data processing are restricted for this patient.

DepartmentId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the department associated with the patient relationship.
This field is a relationship field.
Relationship Name
Department
Refers To
Account

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the patient relationship or program affiliation.

GratefulPersonId

Type
reference


Properties
Create, Filter, Group, Sort, Update
Description
The contact record of the patient that's associated with the grateful patient profile.
This field is a relationship field.
Relationship Name
GratefulPerson
Refers To
Contact

GratefulnessReason

Type
textarea
Properties
Create, Nillable, Update
Description

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the record.

OwnerId

Type
reference


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

ResponsiblePersonId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact record of the clinician that's associated with the grateful patient profile.
This field is a relationship field.
Relationship Name
ResponsiblePerson
Refers To
Contact

ServiceLineId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The account record of the healthcare program or service line that's associated with the
grateful patient profile.
This field is a polymorphic relationship field.
Relationship Name
ServiceLine
Refers To
Account, Program

SolicitationRestriction Type

picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the reason for solicitation restrictions.


Possible values are:
• Do Not Call
• Do Not Contact
• Do Not Email
• Do Not Mail
• Do Not Visit
• No Restrictions

StartDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The start date of the patient relationship or program affiliation.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GratefulPersonInvolvementChangeEvent on page 740
Change events are available for the object.
GratefulPersonInvolvementFeed on page 742
Feed tracking is available for the object.
GratefulPersonInvolvementHistory on page 739
History is available for tracked fields of the object.
GratefulPersonInvolvementShare on page 738
Sharing is available for the object.

OutreachSourceCode
Represents information about a source code that's associated with an outreach campaign. This object is available in API version 59.0
and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users


Fields
Field

Details

AudienceCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of person accounts, contacts, and businesses in this audience.

AudienceInformation

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Detailed information about the audience for the outreach source code. This field is available
from API version 62.0 and later.

CampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The parent campaign associated with this source code.
This field is a relationship field.
Relationship Name
Campaign
Relationship Type
Lookup
Refers To
Campaign

CurrencyIsoCode

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Identifies the currency used for the gift transaction.
Valid value is:
• USD—U.S. Dollar
The default value is USD. Available in API version 61.0 and later.


Description

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the source code.

FocusSegmentId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Lists individuals who are segmented for this source code.
This field is available with a Data Cloud license.
This field is a relationship field.
Relationship Name
MarketSegment
Relationship Type
Lookup
Refers To
MarketSegment

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

MessageChannel

Type
picklist


Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The channel used for the message from which the donation originated. This field is available
from API version 60.0 and later.
Possible values are:
• Digital Paid
• Direct Mail
• Email
• Organic Web
• Physical
• SMS
• Share Partner
• Social Organic
• Social Paid
• Telemarketing

MessageChannelPlatform

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach message channel platform from which the donation originated. This field is
available from API version 60.0 and later.

MessageChannelPlatformAccount Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The platform account used to send the outreach message. This field is available from API
version 60.0 and later.
MessageContent

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach message content. This field is available from API version 60.0 and later.


MessageContentTitle

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach message title. This field is available from API version 60.0 and later.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the source code.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

SentDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time that the outreach was sent. Available in API version 61.0 and later.

SourceCode

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The unique source code. This field is unique within your organization.


SourceCodeBaseUrl

Type
url
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The base URL for the outreach source code. This field is available from API version 60.0 and
later.

SourceCodeUrl

Type
url
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The URL with UTM codes that's generated for the outreach source code. This field is available
from API version 60.0 and later.

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The status of the source code.
Possible values are:
• Active
• Archived
• Inactive
The default value is Active.

UsageType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the usage of the outreach source code.
Possible values are:
• Fundraising
The default value is Fundraising.


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
OutreachSourceCodeChangeEvent (API Version 62.0)
Change events are available for the object.
OutreachSourceCodeFeed
Feed tracking is available for the object.
OutreachSourceCodeHistory
History is available for tracked fields of the object.
OutreachSourceCodeOwnerSharingRule
Sharing rules are available for the object.
OutreachSourceCodeShare
Sharing is available for the object.

OutreachSummary
Represents a summary of results of the outreach campaign. This object is available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

AverageGiftAmount

Type
currency
Properties
Filter, Sort
Description
The average amount of all gifts in response to the related outreach source code or campaign.
Data Processing Engine calculates this value by dividing the total gift transaction amount
by the gift count. You can schedule this calculation to run on a regular basis.

AverageOnetimeGiftAmount Type

currency
Properties
Filter, Sort


Description
The average amount of all one-time, non-recurring gifts in response to the related outreach
source code or campaign. Data Processing Engine calculates this value by dividing the total
one-time gift amount by the one-time donor count. You can schedule this calculation to
run on a regular basis.

AverageRecurringGiftAmount Type

currency
Properties
Filter, Sort
Description
The average amount of all recurring gifts in response to the related outreach source code
or campaign. Data Processing Engine calculates this value by dividing the total recurring gift
amount by the recurring donor count. You can schedule this calculation to run on a regular
basis.
CampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The campaign associated with this outreach gift summary. You can associate one campaign
with an outreach summary.
This field is a relationship field.
Relationship Name
Campaign
Relationship Type
Lookup
Refers To
Campaign

DonorCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of unique donors in response to the related outreach source code or campaign.
Data Processing Engine calculates this value by counting the unique donors with paid
transactions. You can schedule this calculation to run on a regular basis.

GiftCount

Type
int


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of gifts in response to the related outreach source code or campaign. Data
Processing Engine calculates this value by counting the paid gift transactions related to the
campaign or source code. You can schedule this calculation to run on a regular basis.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The auto-numbered name that uniquely identifies the outreach summary.

OnetimeDonorCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of contacts who gave a one-time, non-recurring donation in response to the
related outreach source code or campaign. Data Processing Engine calculates this value by
counting the unique donors with related gift transactions that are paid and not associated
with a gift commitment. You can schedule this calculation to run on a regular basis.

OutreachSourceCodeId

Type
reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach source code associated with this outreach gift summary. You can associate
one outreach source code with an outreach summary.
This field is a relationship field.
Relationship Name
OutreachSourceCode
Relationship Type
Lookup
Refers To
OutreachSourceCode

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

RecurringDonorCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of contacts who gave a recurring donation in response to the related outreach
source code or campaign. Data Processing Engine calculates this value by counting the
unique donors for gift transactions that are paid and related to recurring gift commitments.
You can schedule this calculation to run on a regular basis.

ResponseRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update


Description
The percentage of responses received from donors to the related outreach source code or
campaign. Data Processing Engine calculates this value by dividing the donor count by the
audience count. You can schedule this calculation to run on a regular basis.

TotalGiftTransactionAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of all paid gifts in response to the related outreach source code or campaign.
Data Processing Engine calculates this value by adding the amounts of all paid gift
transactions. You can schedule this calculation to run on a regular basis.
TotalOnetimeGiftAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of all one-time gifts in response to the related outreach source code or
campaign. Data Processing Engine calculates this value by adding the total amounts of all
related paid gift transactions that aren't related to a gift commitment. You can schedule this
calculation to run on a regular basis.

TotalRecurringGiftAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total value of all recurring gifts in response to the related outreach source code or
campaign. Data Processing Engine calculates this value by adding the total amounts of all
paid gift transactions that are related to recurring gift commitments. You can schedule this
calculation to run on a regular basis.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
OutreachSummaryFeed
Feed tracking is available for the object.
OutreachSummaryHistory
History is available for tracked fields of the object.


Sharing is available for the object.

PartyCategory
The criteria for categorizing contacts and accounts based on specific classification information for a specified time period. This object is
available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The account ID related to the classification record.
This field is a relationship field.
Relationship Name
Account
Refers To
Account

Classification

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The classification associated with the contact or account.
Possible values are:
• High Net Worth Prospect
• Influencer Prospect
• LYBUNT


• Lapsed Donor
• Legacy Prospect
• Lifetime Stewardship
• SYBUNT
• Top 100
• Top 25
• Undergrad or Grad Prospect

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact ID related to the classification record.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the classification.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

Name

Type
string


Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the classification record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the classification.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the status of the classification record.
Possible values are:
• Active
• Archived
• Error
• Inactive
• Pending
• Superseded


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PartyCategoryHistory on page 739
History is available for tracked fields of the object.
PartyCategoryOwnerSharingRule on page 738
Sharing rules are available for the object.
PartyCategoryShare on page 738
Sharing is available for the object.

PartyPhilanthropicAssessment
Represents a formalized assessment of wealth when a rating takes place, such as a third-party wealth assessment, a property valuation,
a financial asset assessment, or an internal assessment. This object is available in API version 63.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The account associated with the assessment.
This field is a relationship field.
Relationship Name
Account
Refers To
Account

AssessmentOrganizationId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The organization performing the assessment.
This field is a relationship field.


Relationship Name
AssessmentOrganization
Refers To
Account

AssessmentType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of assessment, such as executive summary, donor brief, or third-party assessment.
Possible values are:
• Donor Brief
• Executive Summary
• Third Party Assessment

AssetLiquidationValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the party's assets that can be liquidated within a specified time period.

AttributedUserId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The person the research is attributed to.
This field is a relationship field.
Relationship Name
AttributedUser
Refers To
User

BusinessOwnershipValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of private businesses owned by the party.


CaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The case that delivers the research.
This field is a relationship field.
Relationship Name
Case
Relationship Type
Lookup
Refers To
Case

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact associated with the assessment.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

Date

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the assessment.

ExtendedSummary

Type
textarea
Properties
Create, Nillable, Update
Description
A detailed summary of the assessment.


GivingLevel

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The party's giving level.
Possible values are:
• $1,000,000-$4,999,999
• $1,000-$2,499
• $10,000,000-$24,999,999
• $10,000-$24,999
• $100,000-$249,999
• $100-$499
• $2,500-$4,999
• $25,000,000+
• $25,000-$49,999
• $250,000-$999,999
• $5,000,000-$9,999,999
• $5,000-$9,999
• $50,000-$99,999
• $500-$999
• Under $100

GraduationCohort

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The party's graduation cohort, if the party is a person.
Possible values are:
• 0-5 Years Since Graduation
• 11-20 Years Since Graduation
• 21-30 Years Since Graduation
• 31-40 Years Since Graduation
• 41-50 Years Since Graduation
• 50+ Years Since Graduation
• 6-10 Years Since Graduation


GraduationStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The party's graduation status, if the party is a person.
Possible values are:
• Associate Degree
• Certificate or Award
• Multiple Degrees
• Non-Graduate
• Other
• Postgraduate Degree
• Secondary Diploma
• Undergraduate Degree

Income

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The party's annual income.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
the user might have only accessed this record or list view (LastReferencedDate) but
not viewed it.


Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
An auto-generated string or number assigned to the assessment.

OtherAssetsValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the party's assets not covered by other measures of net worth.

OtherNonprofitGiftAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The monetary value of the party's donations to other nonprofits.
OtherNonprofitGiftCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of the party's donations to other nonprofits.
OverallRating

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The overall rating determined by the assessment.
Possible values are:
• High
• Low
• Medium

OwnerId

Type
reference


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The user who owns this record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

PartyPhilanthropicRsrchPrflId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The research profile associated with the research.
This field is a relationship field.
Relationship Name
PartyPhilanthropicRsrchPrfl
Relationship Type
Lookup
Refers To
PartyPhilanthropicRsrchPrfl
RealEstateValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of real estate owned by the party.

ResearchEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the research, used to measure the research period and assess the efficiency
of the research.

ResearchHours

Type
double


Properties
Create, Filter, Nillable, Sort, Update
Description
The total hours spent on research for the assessment, used to track resource allocation and
time spent on researching each prospect.

ResearchSharedDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date the completed research is shared with the relationship officer, used to ensure
transparency and track the flow of information in prospect engagement.

ResearchStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the research, used to create a timeline for the research process and track
the duration of the research phase.

ResponsiblePersonId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The relationship officer assigned to the party.
This field is a relationship field.
Relationship Name
ResponsiblePerson
Refers To
User

RetirementSavingsAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The party's retirement savings.


ShortSummary

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
A short summary of the assessment.

StockValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of public stock owned by the party.

StrengthsAndOpportunities Type

textarea
Properties
Create, Nillable, Update
Description
The strengths and opportunities identified in the assessment.
WeaknessesAndDrawbacks

Type
textarea
Properties
Create, Nillable, Update
Description
The weaknesses and drawbacks identified in the assessment.

WealthAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The party's total wealth.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PartyPhilanthropicAssessmentHistory on page 739
History is available for tracked fields of the object.


PartyPhilanthropicAssessmentOwnerSharingRule on page 738
Sharing rules are available for the object.
PartyPhilanthropicAssessmentShare on page 738
Sharing is available for the object.

PartyPhilanthropicIndicator
Represents an unconfirmed or soft indication that highlights a person's wealth or growth potential. This object is available in API version
63.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The account associated with the indicator.
This field is a relationship field.
Relationship Name
Account
Refers To
Account

AttributedUserId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The person the research is attributed to.
This field is a relationship field.
Relationship Name
AttributedUser
Refers To
User


CaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The case that delivers the research.
This field is a relationship field.
Relationship Name
Case
Relationship Type
Lookup
Refers To
Case

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact associated with the indicator.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

DateCollected

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date the information about the indicator was collected.

EstimatedValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The estimated monetary value of the indicator.


Indicator

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The indicator, such as donation history, net worth, volunteer hours, or inheritance.
Possible values are:
• Donation History
• Inheritance
• Net Worth
• Volunteer Hours

IndicatorType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of indicator, such as engagement, wealth, philanthropy, communication,
volunteerism, or media mention.
Possible values are:
• Communication
• Engagement
• Media Mention
• Philanthropy
• Volunteerism
• Wealth

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last viewed this record or list view. If this value is null,
the user might have only accessed this record or list view (LastReferencedDate) but
not viewed it.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
An auto-generated string or number assigned to the party philanthropic indicator.

OtherSource

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
An indicator source that isn't a Salesforce object.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The user who owns this record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

ParticipantId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The person involved in collecting the research.
This field is a relationship field.
Relationship Name
Participant


Refers To
Contact

PartyPhilanthropicOccurrenceId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The prospect research event associated with the indicator.
This field is a relationship field.
Relationship Name
PartyPhilanthropicOccurrence
Refers To
PartyPhilanthropicOccurrence
PartyPhilanthropicRsrchPrflId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The research profile associated with the indicator.
This field is a relationship field.
Relationship Name
PartyPhilanthropicRsrchPrfl
Relationship Type
Lookup
Refers To
PartyPhilanthropicRsrchPrfl
RelatedOrganizationId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The organization involved in collecting the research.
This field is a relationship field.
Relationship Name
RelatedOrganization
Refers To
Account


ResearchEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the research, used to measure the research period and assess the efficiency
of the research.

ResearchHours

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total hours spent researching the indicator, used to track resource allocation and time
spent on researching each prospect.

ResearchSharedDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the completed research is shared with the relationship officer, used to ensure
transparency and track the flow of information in prospect engagement.

ResearchStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the research, used to create a timeline for the research process and track
the duration of the research phase.

SourceId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The business milestone, life event, or interaction summary associated with the indicator.
This field is a polymorphic relationship field.
Relationship Name
Source


Refers To
BusinessMilestone, InteractionSummary, PersonLifeEvent

SourceType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of source, such as external interaction, internal data, third-party data, or public
records.
Possible values are:
• External Interaction
• Internal Data
• Public Records
• Third-Party Data

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The status of the prospect research indicator, if it hasn't been verified as a party philanthropic
occurrence.
Possible values are:
• Promoted

Summary

Type
textarea
Properties
Create, Nillable, Update
Description
A summary of the indicator.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PartyPhilanthropicIndicatorChangeEvent on page 740
Change events are available for the object.


PartyPhilanthropicIndicatorHistory on page 739
History is available for tracked fields of the object.
PartyPhilanthropicIndicatorOwnerSharingRule on page 738
Sharing rules are available for the object.
PartyPhilanthropicIndicatorShare on page 738
Sharing is available for the object.

PartyPhilanthropicMilestone
Represents philanthropic activities and financial status for a period of time. This object is available in API version 63.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The account associated with the milestone.
This field is a relationship field.
Relationship Name
Account
Refers To
Account

AssetLiquidationValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the party's assets that can be liquidated within a specified time period.

BusinessOwnershipValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update


Description
FIXME: Add the description here. [Writers: - The following description was added by the
developer when they created this field. - It may nor may not be correct, complete, or up to
date. - It is visible to customers in Setup > Object Manager in the UI. If you need to change
what is visible there, ask the developer to change it.] The value of private businesses owned
by the party.

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact associated with the milestone.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

Date

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the milestone.

ExtendedSummary

Type
textarea
Properties
Create, Nillable, Update
Description
A detailed summary of the milestone.

GivingLevel

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The party's giving level.
Possible values are:
• $1,000,000-$4,999,999


• $1,000-$2,499
• $10,000,000-$24,999,999
• $10,000-$24,999
• $100,000-$249,999
• $100-$499
• $2,500-$4,999
• $25,000,000+
• $25,000-$49,999
• $250,000-$999,999
• $5,000,000-$9,999,999
• $5,000-$9,999
• $50,000-$99,999
• $500-$999
• Under $100

GraduationCohort

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The person's graduation cohort.
Possible values are:
• 0-5 Years Since Graduation
• 11-20 Years Since Graduation
• 21-30 Years Since Graduation
• 31-40 Years Since Graduation
• 41-50 Years Since Graduation
• 50+ Years Since Graduation
• 6-10 Years Since Graduation

GraduationStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The person's graduation status.
Possible values are:
• Associate Degree
• Certificate or Award


• Multiple Degrees
• Non-Graduate
• Other
• Postgraduate Degree
• Secondary Diploma
• Undergraduate Degree

Income

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The party's annual income.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
the user might have only accessed this record or list view (LastReferencedDate) but
not viewed it.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
An auto-generated string or number assigned to the milestone.

OtherAssetsValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update


Description
The value of the party's assets not covered by other measures of net worth.

OtherNonprofitGiftAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The monetary value of the party's donations to other nonprofits.
OtherNonprofitGiftCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of the party's donations to other nonprofits.
OverallRating

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The overall rating of the milestone.
Possible values are:
• High
• Low
• Medium

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The user who owns this record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User


PtyPhilanthropicAsmtCnt Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of party philanthropic assessments within the milestone period.
PtyPhilanthropicIndCnt

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of party philanthropic indicators within the milestone period.

PtyPhilanthropicOccrCnt Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of party philanthropic occurrences within the milestone period.
RealEstateValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of real estate owned by the party.

ResponsiblePersonId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The relationship officer assigned to the assessed party at the time the assessment milestone
is generated.
This field is a relationship field.
Relationship Name
ResponsiblePerson
Refers To
User


RetirementSavingsAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The party's retirement savings.
ShortSummary

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
A short summary of the milestone.

StockValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of public stock owned by the party.

StrengthsAndOpportunities Type

textarea
Properties
Create, Nillable, Update
Description
The strengths and opportunities identified in the milestone.
WeaknessesAndDrawbacks

Type
textarea
Properties
Create, Nillable, Update
Description
The weaknesses and drawbacks identified in the milestone.

WealthAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The party's total wealth for the milestone.


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PartyPhilanthropicMilestoneChangeEvent on page 740
Change events are available for the object.
PartyPhilanthropicMilestoneHistory on page 739
History is available for tracked fields of the object.
PartyPhilanthropicMilestoneOwnerSharingRule on page 738
Sharing rules are available for the object.
PartyPhilanthropicMilestoneShare on page 738
Sharing is available for the object.

PartyPhilanthropicOccurrence
xxx This object is available in API version XX.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The account associated with the occurrence.
This field is a relationship field.
Relationship Name
Account
Refers To
Account

AttributedUserId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The user the research is attributed to.


This field is a relationship field.
Relationship Name
AttributedUser
Refers To
User

CaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The case that delivers the research.
This field is a relationship field.
Relationship Name
Case
Relationship Type
Lookup
Refers To
Case

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact associated with the occurrence.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

DateCollected

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date the information about the occurrence was collected.

EstimatedValue

Type
currency


Properties
Create, Filter, Nillable, Sort, Update
Description
The estimated monetary value of the occurrence.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
the user might have only accessed this record or list view (LastReferencedDate) but
not viewed it.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
An auto-generated string or number assigned to the party philanthropic occurrence.

OccurrenceType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The type of occurrence, such as donation history, net worth, volunteer hours, or inheritance.
Possible values are:
• Donation History
• Inheritance
• Net Worth
• Volunteer Hours


OtherSource

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
An occurrence source that isn't a Salesforce record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The user who owns this record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

ParticipantId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The participant contact involved in collecting the research.
This field is a relationship field.
Relationship Name
Participant
Refers To
Contact

PartyPhilanthropicAssessmentId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The party philanthropic assessment associated with the occurrence.
This field is a relationship field.
Relationship Name
PartyPhilanthropicAssessment


Refers To
PartyPhilanthropicAssessment

PartyPhilanthropicRsrchPrflId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The research profile associated with the occurrence.
This field is a relationship field.
Relationship Name
PartyPhilanthropicRsrchPrfl
Relationship Type
Lookup
Refers To
PartyPhilanthropicRsrchPrfl
RelatedOrganizationId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The account of the organization that provided the occurrence.
This field is a relationship field.
Relationship Name
RelatedOrganization
Refers To
Account

ResearchEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the research, used to measure the duration of the research period and assess
the efficiency of the research.

ResearchHours

Type
double
Properties
Create, Filter, Nillable, Sort, Update


Description
The total hours spent researching the occurrence, used to track resource allocation and time
spent on researching each prospect.

ResearchSharedDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the completed research is shared with the relationship officer, used to ensure
transparency and track the flow of information in prospect engagement.

ResearchStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the research, used to create a timeline for the research process and track
the duration of the research phase.

ResearchType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The classification of research for the occurrence.
Possible values are:
• Communication
• Engagement
• Media Mention
• Philanthropy
• Volunteerism
• Wealth

SourceId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The business milestone, life event, or interaction summary associated wiith the occurrence.
This field is a polymorphic relationship field.


Relationship Name
Source
Refers To
BusinessMilestone, InteractionSummary, PersonLifeEvent

SourceType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of source, such as external interaction, internal data, third-party data, or public
records.
Possible values are:
• External Interaction
• Internal Data
• Public Records
• Third-Party Data

Summary

Type
textarea
Properties
Create, Nillable, Update
Description
A description of the occurrence.

VerificationType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies whether the occurrence is known or inferred.
Possible values are:
• Inferred
• Known

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.


PartyPhilanthropicOccurrenceChangeEvent on page 740
Change events are available for the object.
PartyPhilanthropicOccurrenceHistory on page 739
History is available for tracked fields of the object.
PartyPhilanthropicOccurrenceOwnerSharingRule on page 738
Sharing rules are available for the object.
PartyPhilanthropicOccurrenceShare on page 738
Sharing is available for the object.

PartyPhilanthropicRsrchPrfl
Captures information associated with a contact or an organization in a many-to-one relationship. Serves as a pivot point for research on
the person or organization. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The account ID associated with the research profile.
This field is a relationship field.
Relationship Name
Account
Refers To
Account

CaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The case associated with the research profile.
This field is a relationship field.
Relationship Name
Case
Refers To
Case

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact ID associated with the research profile.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

DetailedSummary

Type
textarea
Properties
Create, Nillable, Update
Description
A comprehensive summary of the research findings for the profile.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the research stage, used to measure the duration of the research period and
assess the efficiency of the research.

HoursSpentOnResearch

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total hours spent on the stage, used for resource allocation and performance tracking.


IsResearchCompleted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the research profile is complete (true) or not (false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the research profile record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

PctOfResearchCompleted

Type
percent


Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of completion for the research profile stage.

ResearchProfilePhase

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The research stage of the research profile.
Possible values are:
• Cultivation Strategy Development
• Disqualification
• Identification
• Initial Screening
• Ongoing Monitoring
• Planning
• Prioritization
• Qualification
• Rating and Segmentation
• Research Deep Dive
• Robust Research Completed

ResearchProfileType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of research profile.
Possible values are:
• Capital Campaign
• Planned Giving

ResearcherAssignedId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The team member responsible for completing the research stage, ensuring accountability
and tracking workload across researchers.
This field is a relationship field.
Relationship Name
ResearcherAssigned
Refers To
User

ShortSummary

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
A brief summary of the research findings for the profile.

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the research stage, used to track the duration of the stage and create a
timeline for the research process.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PartyPhilanthropicRsrchPrflChangeEvent on page 740
Change events are available for the object.
PartyPhilanthropicRsrchPrflHistory on page 739
History is available for tracked fields of the object.
PartyPhilanthropicRsrchPrflOwnerSharingRule on page 738
Sharing rules are available for the object.
PartyPhilanthropicRsrchPrflShare on page 738
Sharing is available for the object.

PaymentInstrument
Represents the details related to the Payment Instrument used to complete the transaction. This object is available in API version 60.0
and later.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users

Fields
Field

Details

AccountHolderName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Name of the Payment Instrument Holder.

AccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The Account or PersonAccount that is using the payment instrument.
This field is a relationship field.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account

BankAccountHolderType

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Determines if the bank account holder is an individual or a company.

BankAccountNumber

Type
string


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The bank account number used for payment.

BankAccountType

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Type of the Bank Account.

BankCode

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Code of bank associated with the bank account.

BankName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Name of bank associated with the bank account.

CardBrand

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The credit card brand, network, or issuer.

CurrencyIsoCode

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The currency ISO code. This field is hidden when multicurrency is off.
Possible values are:
• AUD—Australian Dollar


• GBP—British Pound
• USD—U.S. Dollar
The default value is USD.

DigitalWalletProvider

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The provider of the digital wallet.

ExpiryMonth

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Expire month if payment method is credit card.

ExpiryYear

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Expire year if payment method is credit card.

GatewayName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the payment gateway.

GatewayReference

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
A reference number from the gateway for this payment instrument.

Last4

Type
string


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Last 4 digits of payment method.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The unique, auto-numbered name of the payment instrument.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PaymentProcessorName

Type
string


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the payment processor.

ProcessorReference

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reference of the payment processor associated with the payment instrument.

Type

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the type of the payment instrument.
Possible values are:
• ACH
• BACS Debit
• BECS Debit
• Bancontact
• Credit Card
• PayPal
• SEPA Direct Debit
• Venmo
• iDEAL

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PaymentInstrumentFeed
Feed tracking is available for the object.
PaymentInstrumentHistory
History is available for tracked fields of the object.
PaymentInstrumentShare
Sharing is available for the object.


A complex gift such as an annuity, bequest, or trust. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

ActuarialFactor

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
A factor based on actuarial assumptions that’s used to calculate the gift’s future value.

AmountReceived

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount received since the planned gift record was created.

BequestRealizationDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The expected date when a bequest is likely to be realized.

CaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The case associated with the planned gift.


This field is a relationship field.
Relationship Name
Case
Refers To
Case

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact for the planned gift.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

CurrentValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The planned gift's current value.

DateCommitted

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the gift was committed.

DateReceived

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the gift was received.

DeferralPeriod

Type
int


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The time period, in years, after which payments start.

DeferredFutureValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The projected value of a deferred gift annuity at maturity.

DiscountRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The discount rate applied to project the future value of the gift.

DonorGiftConceptId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift concept associated with the planned gift.
This field is a relationship field.
Relationship Name
DonorGiftConcept
Refers To
DonorGiftConcept

DonorId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The donor of the planned gift.
This field is a relationship field.
Relationship Name
Donor


Refers To
Account

Expectancy

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The expected number of years to maturity, based on actuarial assumptions.

ExpectedAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The expected value of the planned gift.

ExpectedEstateValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total estimated value of a donor's estate.

ExpensesAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total management expenses associated with the gift.

FaceValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The face value of the gift, if the gift is life insurance.

FirstPaymentDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The date when the first payment is made, if the gift is a trust or an annuity.

FutureValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The gift's projected value at maturity.

GiftAgreementId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift agreement associated with the planned gift.
This field is a relationship field.
Relationship Name
GiftAgreement
Refers To
GiftAgreement

GiftType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of planned gift.
Possible values are:
• Bequest
• Bequest Specific Amount
• Bequest Specific Percentage
• Charitable Gift Annuity
• Charitable Lead Annuity Trust
• Charitable Remainder Annuity Trust
• Charitable Remainder Trust
• Charitable Remainder Unitrust
• Deferred Gift Annuity
• Donor Advised Fund
• Immediate Gift Annuity


• Life Insurance
• Life Insurance Irrevocable Interest
• Other Planned Gift
• Personal Property
• Pooled Income Fund
• Real Estate
• Securities

InvestmentReturnRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The return rate on investments related to the gift.

IsRevocable

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the gift is revocable (true) or not (false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

LastValuationDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the planned gift value was last updated.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description


MarketValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The gift's current market value.

MaturityDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the gift is expected to mature or be realized.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the planned gift record.

NetReturnRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The expected annual net return rate on the gift’s investments.

NetValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The net value of the gift after expenses and payouts.

OpportunityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The opportunity associated with the planned gift.


This field is a relationship field.
Relationship Name
Opportunity
Refers To
Opportunity

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

PayoutFrequency

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The payment frequency.
Possible values are:
• Annual
• Custom
• Monthly
• One-Time
• Quarterly
• Semi-Annual

PayoutRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The rate at which payouts are made to beneficiaries.

PolicyNumber

Type
string


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The policy number, if the gift is life insurance.

PremiumAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The premium amount, if the gift is life insurance.

PresentValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
A calculated value of future cash flows associated with an asset or planned gift.

PrincipalAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The principal amount of the gift.

PrincipalPercentage

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of the expected amount that's the principal amount of the gift.

ProbabilityFactor

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The probability of receiving the gift.

ResiduaryShare

Type
percent


Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of the estate allocated to the institution for residuary bequests.

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the gift agreement is initiated.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the planned gift.
Possible values are:
• Active
• Closed
• In Probate
• Inactive
• Matured
• Pending Approval
• Realized
• Under Agreement

Term

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The term of a trust for calculating future and present value.

TermEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The date when the gift matures or the trust term ends.

TermType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The term type for the trust, such as fixed number of years, one life, or two lives.
Possible values are:
• Fixed Number of Years
• Joint Life
• Life of Beneficiary
• Life of Donor
• One Life Fixed Term
• Single Life
• Two Lives Fixed Term

TrustName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the trust, if the gift is categorized as a trust.

TrustType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of trust.
Possible values are:
• Charitable Lead Annuity Trust
• Charitable Lead Unitrust
• Charitable Remainder Annuity Trust
• Charitable Remainder Trust
• Charitable Remainder Unitrust
• Irrevocable Trust
• Revocable Trust


• Testamentary Trust

TrusteeFees

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
Fees paid to the trustee.

UnitsHeld

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The number of units that the donor holds in the pooled income fund.

UnitsValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of 1 unit in the pooled income fund.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PlannedGiftChangeEvent
Change events are available for the object.
PlannedGiftFeed
Feed tracking is available for the object.
PlannedGiftHistory
History is available for tracked fields of the object.
PlannedGiftOwnerSharingRule
Sharing rules are available for the object.
PlannedGiftShare
Sharing is available for the object.

PlannedGiftAnnuityRate
The rate used to calculate payments for a charitable gift annuity. This object is available in API version 64.0 and later.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

EffectiveDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date the annuity rate becomes effective.

GiftType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The gift type associated with the gift annuity. Determines the payout rate for the gift.
Possible values are:
• Bequest
• Charitable Gift Annuity
• Charitable Lead Annuity Trust
• Charitable Remainder Annuity Trust
• Charitable Remainder Trust
• Deferred Gift Annuity
• Donor Advised Fund
• Life Insurance
• Other Planned Gift
• Personal Property
• Pooled Income Fund
• Real Estate
• Securities

LastReferencedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

MaturityDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the annuity payments end.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the gift annuity rate record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

PlannedGiftId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The planned gift associated with the gift annuity rate.


This field is a relationship field.
Relationship Name
PlannedGift
Refers To
PlannedGift

Rate

Type
percent
Properties
Create, Filter, Sort, Update
Description
The annuity rate used to calculate payments to the donor or beneficiary.

StartDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The date when the annuity payments begin.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PlannedGiftAnnuityRateChangeEvent
Change events are available for the object.
PlannedGiftAnnuityRateFeed
Feed tracking is available for the object.
PlannedGiftAnnuityRateHistory
History is available for tracked fields of the object.
PlannedGiftAnnuityRateOwnerSharingRule
Sharing rules are available for the object.
PlannedGiftAnnuityRateShare
Sharing is available for the object.

PlannedGiftPerformance
The performance of a planned gift over time, including returns, expenses, and net value. This object is available in API version 64.0 and
later.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

Expenses

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total management expense associated with the planned gift.

InvestmentReturnRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The investment return rate associated with the planned gift.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort


Description
The ID of the gift performance record.

NetValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the planned gift after accounting for expenses and payouts.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

PayoutRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The rate at which payouts are made to beneficiaries of the planned gift.

PayoutStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of payouts to beneficiaries from the planned gift.

PlannedGiftId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The planned gift associated with the performance record.


Fundraising Fields on Other Objects

Details
This field is a relationship field.
Relationship Name
PlannedGift
Refers To
PlannedGift

StartDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The start date of performance tracking for the planned gift.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PlannedGiftPerformanceChangeEvent
Change events are available for the object.
PlannedGiftPerformanceFeed
Feed tracking is available for the object.
PlannedGiftPerformanceHistory
History is available for tracked fields of the object.
PlannedGiftPerformanceOwnerSharingRule
Sharing rules are available for the object.
PlannedGiftPerformanceShare
Sharing is available for the object.

Fundraising Fields on Other Objects
Fundraising includes fields that are available on other Salesforce objects. These fields are available only in orgs with Nonprofit Cloud or
Education Cloud when Fundraising is enabled.
ContactPointAddress
Represents a contact’s billing or shipping address, which is associated with an individual or a person account. This object is available
in API version 61.0 and later.
ContactProfile
Represents information about an individual, such as their ethnicity, citizenship, birth place, race, and so on. The Fundraising fields
on this object are available in API version 59.0 and later.


Represents a list email sent from Salesforce, or sent from Account Engagement and synced to Salesforce. When the list email is sent,
the recipients are generated by combining recipients in the ListEmailIndividualRecipients and ListEmailRecipientSource objects.
Duplicate and other invalid recipients are removed. The result is the recipients are sent any given list email. ListEmail has a one-to-many
relationship with ListEmailRecipientSource and ListEmailIndividualRecipient objects. This object is available in API version 61.0 and
later.

ContactPointAddress
Represents a contact’s billing or shipping address, which is associated with an individual or a person account. This object is available in
API version 61.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the FundraisingAccess license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

ActiveFromDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the contact’s address became active.

ActiveToDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the contact’s address is no longer active.

Address

Type
address
Properties
Filter, Nillable


Description
The full address.

AddressType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of address.
Valid values are:
• Billing
• Shipping

BestTimeToContactEndTime Type

time
Properties
Create, Filter, Nillable, Sort, Update
Description
The latest time to contact the individual.
BestTimeToContactStartTime Type

time
Properties
Create, Filter, Nillable, Sort, Update
Description
The earliest time to contact the individual.
BestTimeToContactTimezone Type

picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The timezone applied to the best time to contact the individual.
City

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The address city.


ContactPointPhoneId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The primary phone number associated with this address.
This field is a relationship field.
Relationship Name
ContactPointPhone
Relationship Type
Lookup
Refers To
ContactPointPhone

Country

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The address country.

GeocodeAccuracy

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The level of accuracy of a location’s geographical coordinates compared with its physical
address. A geocoding service typically provides this value based on the address’s latitude
and longitude coordinates.
Valid values are:
• Address
• Block
• City
• County
• ExtendedZip
• NearAddress
• Neighborhood
• State
• Street
• Unknown


• Zip

IsDefault

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether a contact’s address is the preferred method of communication (true)
or not (false).
The default value is false.

IsPrimary

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether a contact’s address is their primary address (true) or not (false).
The default value is false.

IsThirdPartyAddress

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the address is associated with a third party (true) or not (false).
The default value is false.

IsUndeliverable

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the address is undeliverable (true) or not (false).
The default value is false.

LastAddressStdDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update


Description
The most recent date and time that the address was evaluated by the address standardization
provider.

LastAddressStdStatus

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The most recent status received from the address standardization provider.

LastChangeOfAddressDate Type

dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The most recent date and time that the address was evaluated by the change of address
provider.
LastChangeOfAddressStatus Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the latest change of address request.
LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last referenced a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.


Latitude

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
Used with Longitude to specify the precise geolocation of the address. Acceptable values
are numbers between –90 and 90 with up to 15 decimal places.

Longitude

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
Used with Latitude to specify the precise geolocation of the address. Acceptable values
are numbers between –180 and 180 with up to 15 decimal places.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
Required. The name of the contact point address record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the account’s owner associated with this contact.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The ID of the contact’s parent record. Only an individual or account can be a contact’s parent.
This field is a polymorphic relationship field.
Relationship Name
Parent
Relationship Type
Master-detail
Refers To
Account, Individual (the master object)

PostalCode

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The address postal code.

PreferenceRank

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The preference rank when there are multiple contact point addresses.

SeasonalEndDay

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The day when the seasonal address of the contact is replaced by the default address.
Valid values are: 1–31

SeasonalEndMonth

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The month when the seasonal address of the contact is replaced by the default address.
Valid values are: 1–12


SeasonalStartDay

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The day when the seasonal address of the contact replaces the default address.
Valid values are: 1–31

SeasonalStartMonth

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The month when the seasonal address of the contact replaces the default address.
Valid values are: 1–12

State

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The address state.

Street

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The address street.

UsageType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The usage type of this address. For instance, whether it’s a work address or a home address.
Valid values are:
• Home
• Inactive
• Temporary


• Work

ContactProfile
Represents information about an individual, such as their ethnicity, citizenship, birth place, race, and so on. The Fundraising fields on
this object are available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AssetLiquidationValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of assets that can be liquidated within 90 days.

BusinessOwnershipValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of private businesses the contact owns.

Income

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The annual income amount of the contact.

Location

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The location where the contact currently resides.

OtherAssetsValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the contact's assets that aren't covered by other ways of measuring net worth.

OtherNonprofitGiftAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount of donations the contact has given to other nonprofits.
OtherNonprofitGiftCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of donations the contact has given to other nonprofits.
RealEstateValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of real estate the contact owns.

RecurringDonorType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of recurring donor.
Possible values are:
• Active
• Former
• Lapsed


RetirementSavingsAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount of the contact's retirement savings.
StockValue

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of public stock the contact owns.

Website

Type
url
Properties
Create, Filter, Nillable, Sort, Update
Description
A website that's associated with the contact.

For more information, see ContactProfile in Education Cloud.

ListEmail
Represents a list email sent from Salesforce, or sent from Account Engagement and synced to Salesforce. When the list email is sent, the
recipients are generated by combining recipients in the ListEmailIndividualRecipients and ListEmailRecipientSource objects. Duplicate
and other invalid recipients are removed. The result is the recipients are sent any given list email. ListEmail has a one-to-many relationship
with ListEmailRecipientSource and ListEmailIndividualRecipient objects. This object is available in API version 61.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available to Marketing Cloud users with the FundraisingAccess permission set on Marketing Cloud Growth Edition campaigns.


Fields
Field

Details

CampaignId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the related campaign.
This field is a relationship field.
Relationship Name
Campaign
Relationship Type
Lookup
Refers To
Campaign

FromAddress

Type
textarea
Properties
Create, Filter, Update
Description
Read-only except when the list email is in a draft state. Validated against user’s addresses.

FromName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Read-only except when the list email is in a draft state. Validated against user’s addresses.
This field is null for emails sent from Account Engagement.

HasAttachment

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Read-only. Defaulted on create and update. Indicates if the list email has an attachment
(true) or not (false). This field is null for emails sent from Account Engagement.
The default value is false.


HtmlBody

Type
textarea
Properties
Create, Nillable, Update
Description
The body of the list email. This field is null for emails sent from Account Engagement.
List emails can contain up to 32,000 characters for the body. These limits include visible
characters and other characters in the email, including markup.

IsOutreachSourceCodeEnabled Type

boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Indicates whether outreach source code can be added to this record (true) or not (false).
The default value is false.
This field is a calculated field.
IsTracked

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Indicates if email tracking was on when the list email was sent (true) or not (false). This
field is blank for emails sent from Account Engagement and synced to Salesforce. This field
is null for emails sent from Account Engagement.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
Read-only except when the list email is in a draft state.

OutreachSourceCodeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach source code associated with the gift transaction.
This field is a relationship field.
Relationship Name
OutreachSourceCode
Relationship Type
Lookup
Refers To
OutreachSourceCode

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ScheduledDate

Type
dateTime


Properties
Create, Filter, Nillable, Sort, Update
Description
Read-only. If null and Status is set to Scheduled, then defaults to created time.

Status

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Read-only except when the list email is in a draft state.
Changing the status to Scheduled causes the list email to be sent.
Valid values are:
• Cancelled
• Draft
• LimitError
• Running
• Scheduled
• Sent

Subject

Type
textarea
Properties
Create, Filter, Nillable, Update
Description
Read-only except when the list email is in a draft state. This field is null for emails sent from
Account Engagement.
List emails can contain up to 3,000 characters for the subject. These limits include visible
characters and other characters in the email, including markup.

TextBody

Type
textarea
Properties
Create, Nillable, Update
Description
Read-only except when the list email is in a draft state. This field is null for emails sent from
Account Engagement.

TotalSent

Type
int


Fundraising Business APIs

Details
Properties
Defaulted on create, Filter, Group, Nillable, Sort
Description
Read-only. The total number of list emails sent, including bounced, opted-out, and invalid
To: addresses.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ListEmailChangeEvent
Change events are available for the object.
ListEmailFeed
Feed tracking is available for the object.
ListEmailHistory
History is available for tracked fields of the object.
ListEmailOwnerSharingRule
Sharing rules are available for the object.
ListEmailShare
Sharing is available for the object.

Fundraising Business APIs
You can access Salesforce Fundraising APIs using REST endpoints. These REST APIs follow similar conventions as Connect REST APIs.
To use the Fundraising Business Process APIs:
• Enable Fundraising in your org.
• Enable donor matching method. See Configure Fundraising Settings. See the FundraisingConfig object to know about the donor
matching method details.
• Select a default gift designation. See Gift Designation.
• Configure the duplicate and matching rules for the Account and Contact objects, Or set Duplicate Matching in Settings to No
Matching. See Customize Duplicate Management.
The Fundraising Business Process APIs help teams create strong integrations using industry-standard tools. Use the Salesforce composite
Fundraising BP API to send a single complex payload instead of making multiple calls using multiple APIs to various objects.
Developer-friendly APIs don’t require a detailed and complete understanding of the NPC data model, greatly simplifying integrations.
These APIs offer scalability and flexibility through features like automatic record matching, batch processing, bulk operations, and dynamic
data mapping. Five robust endpoints are currently available to:
• Create bulk gift transactions with related donor and designations
• Create bulk gift commitments with related donor, schedule, and default designations
• Modify the future recurring schedule on a gift commitment
• Apply payment update metadata to gift transactions and future gift commitment installments


The Fundraising Business Process APIs are available as a standard Salesforce Connect API REST endpoint as well as through Apex.
To understand the architecture, authentication, rate limits, and how the requests and responses work, see Connect REST API Developer
Guide.
To use Business APIs on the Postman API platform, see the Postman collection for Fundraising.
Resources
Learn more about the available Fundraising API resources.
Request Bodies
Learn more about the available Fundraising API request bodies.
Response Bodies
Learn more about the available Fundraising API response bodies.

Resources
Learn more about the available Fundraising API resources.
Commitments (POST)
Create recurring gift commitments and schedules, along with associated new or matched donor. Customize fields for donor accounts,
gift commitments, and schedules.
Commitments (PATCH)
Modify the data for the schedule, campaign, outreach source code, donor, and payment instrument on an active gift commitment.
Gift Transactions
Get gift transactions associated with a gift commitment record.
Gift Transaction Designations
Get designations associated with a gift transaction, campaign, commitment, or opportunity.
Gift Commitment Transactions
Get a list of gift transactions associated with a gift commitment for a donor account.
Gift Commitment Default Designations
Get default designations associated with a gift commitment.
Gift Campaign Default Designations
Get default designations associated with a gift campaign.
Gifts Transactions (POST)
Create gift transactions with related new or matched donor, optional transaction designations, and payment-instrument metadata.
This API supports custom fields for the donor account and gift transaction.
Transactions Payment Updates (POST)
Update the gateway and processor metadata for gift transactions. This API supports updating only the properties that are specified
in the request body. If you include any other standard or custom fields in the request body beyond the specified properties, an error
is shown.
Commitments Payment Updates (POST)
Update the metadata for your payment instruments for all active gift commitments.


Commitments (POST)
Create recurring gift commitments and schedules, along with associated new or matched donor. Customize fields for donor accounts,
gift commitments, and schedules.
Resource:
/connect/fundraising/commitments

Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/commitments

Available version: 60.0
HTTP methods: POST
Request body for POST
Note: You can pass the campaign, donor, and designation IDs in an externalId object containing fieldName and
fieldValue.

JSON example
{
"processingOptions": {
"donorOptions": {
"defaultUpdateLogic": "update_all"
},
"disableGiftTransactionValidations": true,
"disableGiftCommitmentValidations": true,
"disableGiftCommitmentScheduleValidations": true
},
"commitments": [
{
"amount": 150.25,
"type": "pledge",
"currencyIsoCode": "USD",
"transactionPeriod": "monthly",
"transactionInterval": 3,
"transactionDay": "5",
"startDate": "2024-07-06",
"endDate": "2024-07-06",
"campaign": {
"id": "701y0030d0zk6t06f4"
},
"outreachSourceCode": {
"id": "0gx000d0d0d0FD",
"sourceCode": "AnimalEmailCampaign2023"
},
"donor": {
"donorType": "individual",
"id": "0015500000WO1ZxxAL",
"organizationName": "mini cat town",
"firstName": "Daniel",
"lastName": "Chavez",


"phone": "510-432-9876",
"email": "d.chavez.com",
"address": [
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}
],
"accountCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
},
"paymentInstrument": {
"type": "Credit Card",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "Diner's Club",
"bankName": "chase",
"digitalWalletProvider": "EwalletProvider",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
},
"designations": [
{
"designationId": "0gd0030f0303024",
"percent": 10
}
],
"firstTransaction": {
"amount": 150.25,
"receivedDate": "2024-07-06",
"donorCoverAmount": 0.25,
"transactionStatus": "Unpaid",
"gatewayTransactionFee": 0.75,
"processorTransactionFee": 0.45,
"processorReference": "cls-1247586928747",
"gatewayReference": "102656693ac3ca6e0cdafbfe89ab99",
"lastGatewayResponseCode": "invalid_cvc",
"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's
security code or use a different card.",


"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z"
},
"giftCommitmentCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
],
"giftCommitmentScheduleCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
],
"giftTransactionCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
}
]
}

Properties
Name

Type

Description

commitments

Create Commitment Details of the request to create the
Request Input[]
commitment.

Required or
Optional

Available Version

Required

60.0

Optional

60.0

Limited to 100 commitments in a single
request.
processing
Options

Processing Options
Details Input

Options for donor matching process and
gift validation pausing.

Response body for POST: Create Commitment
SEE ALSO:
Nonprofit Cloud Developer Guide: Fundraising

Commitments (PATCH)
Modify the data for the schedule, campaign, outreach source code, donor, and payment instrument on an active gift commitment.
Resource:
/connect/fundraising/commitments/commitmentId


Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect
/fundraising/commitments/6gc0000AbCdZF9q

Available version: 60.0
HTTP methods: PATCH
Request body for PATCH
Note: You can pass the campaign, donor, and designation IDs in an externalId object containing fieldName and
fieldValue.

JSON example
{
"amount": 150.25,
"type": "pledge",
"transactionInterval": 3,
"transactionDay": "5",
"startDate": "2024-07-06",
"endDate": "2024-07-06",
"campaign": {
"id": "701y0030d0zk6t06f4"
},
"outreachSourceCode": {
"id": "0gx000d0d0d0FD",
"sourceCode": "AnimalEmailCampaign2023"
},
"processingOptions": {
"donorOptions": {
"defaultUpdateLogic": "update_all"
},
"disableGiftTransactionValidations": true,
"disableGiftCommitmentValidations": true,
"disableGiftCommitmentScheduleValidations": true
},
"donor": {
"donorType": "individual",
"organizationName": "ABC Inc.",
"firstName": "Daniel",
"lastName": "Chavez",
"phone": "510-434-8920",
"email": "d.chavez@salesforce.com",
"address": [
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}
],
"accountCustomFields": [


{
"fieldName": "string",
"fieldValue": "string"
}
],
"paymentInstrument": {
"type": "Credit Card",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "Diner's Club",
"bankName": "chase",
"digitalWalletProvider": "EProvider",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
},
"giftCommitmentCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
],
"giftCommitmentScheduleCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
}
}

Properties
Name

Type

Description

Required or
Optional

amount

Double

Gift amount of each transaction associated Required
with the gift commitment schedule.

60.0

campaign

Campaign Details

Campaign that's associated with the gift
commitment.

Optional

60.0

currency
IsoCode

String

Currency ISO code of the gift commitment. Optional

60.0

donorId

Donor Details Input

Person, household, or organization account Optional
associated with the commitment.

60.0


Available Version

Type

Description

Required or
Optional

Available Version

endDate

String

End date of the new schedule for this gift Optional
commitment. The format is YYYY-MM-DD.

60.0

giftCommitment Custom Field
CustomFields Details[]

Custom fields of the gift commitment.

Optional

60.0

giftCommitment Custom Field
Details[]
Schedule
CustomFields

Custom fields of the gift commitment
schedule.

Optional

60.0

outreach
SourceCode

Outreach Source
Code Details

Outreach source code that's associated with Optional
the campaign for the gift commitment.

60.0

payment
Instrument

Payment Instrument Payment instrument that's used to complete Required
Details
the transaction.

60.0

processing
Options

Processing Options
Details Input

Options for donor matching process and
gift validation pausing

Optional

60.0

startDate

String

Start date of the new schedule for this gift Required
commitment. The format is YYYY-MM-DD.

60.0

transaction
Day

String

Specifies the day of the month to create gift Optional
transactions in the future for a monthly
transaction period. If you select the day as
29 or 30, the gift transaction is created on
the last day for the months that don't have
that many days.

60.0

transaction
Interval

Integer

Transaction interval that's applicable to an Optional
incoming transaction in the commitment.

60.0

transaction
Period

String

Transaction period that's applicable to the Required
incoming transaction in the commitment.
When type is pledge, this property
must be set to Custom. If
transactionPeriod is not provided,
the default isCustom.

60.0

type

String

Type of transaction. Possible values are:

62.0

• Pledge
• Recurring
The default value is the Recurring.

Response body for PATCH: Update Commitment on page 289
SEE ALSO:
Nonprofit Cloud Developer Guide: Fundraising


Optional

Gift Transactions
Get gift transactions associated with a gift commitment record.
Resource:
/connect/fundraising/gift-commitments/${commitmentId}/gift-transactions

Resource examples:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/gift-commitments/6gcxx000004WhULAA0/gift-transactions
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/gift-commitments/6gcxx000004WhULAA0/gift-transactions?count=2&period=Recent&status=Canceled,Failed
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/gift-commitments/6gcxx000004WhULAA0/gift-transactions?count=2&period=Past&fromDate=2023-02-11T13:05:23.000Z

Available version: 59.0
HTTP methods: GET
Query parameters for GET
Parameter Name Type
count

Integer

Description

Required or
Optional

Number of gift transactions to be retrieved. Optional

Available Version
59.0

You can get a maximum of 12 transactions
in one request.
By default, the API returns 12 transactions.
fromDate

String

Date
Optional
(yyyy-MM-dd'T'HH:mm:ss.SSSX)
from when you want to get the transactions.
This field is not applicable if period is
Recent.

59.0

period

String

Period for getting gift transactions. possible Optional
values are:

59.0

• Future
• Past
• Recent
The default period is Future.
status

String[]

Comma-separated list of gift-transactions
statuses. Possible values are:
• Canceled
• Failed
• Fully Refunded
• Paid
• Unpaid
• Written-Off


Optional

59.0

Parameter Name Type

Description

Required or
Optional

Available Version

The default status is Unpaid.

Response body for GET: Gift Transactions Output

Gift Transaction Designations
Get designations associated with a gift transaction, campaign, commitment, or opportunity.
Note: When there are no designations associated with a gift transaction, campaign, commitment, or opportunity, the API returns
the organization-wide default designations.
Resource:
/connect/fundraising/transaction/${transactionId}/designations

Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/transaction/6trRM000000007XYAQ/designations

Available version: 59.0
HTTP methods: GET
Response body for GET: Gift Transaction Linked Designations Output

Gift Commitment Transactions
Get a list of gift transactions associated with a gift commitment for a donor account.
Resource:
/connect/fundraising/donor/${donorId}/commitments

Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/donor/001xx000003GYOpAAO/commitments

Available version: 59.0
HTTP methods: GET
Response body for GET: Gift Commitment Transaction Matching Output

Gift Commitment Default Designations
Get default designations associated with a gift commitment.
Resource:
/connect/fundraising/commitment/${commitmentId}/default-designations

Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/commitment/6trRM000000007XYAQ/default-designations


Available version: 59.0
HTTP methods: GET
Response body for GET: Gift Commitment Default Designations Output

Gift Campaign Default Designations
Get default designations associated with a gift campaign.
Resource:
/connect/fundraising/campaign/${campaignId}/default-designations

Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/campaign/701RM000000FhntYAC/default-designations

Available version: 59.0
HTTP methods: GET
Response body for GET: Gift Campaign Default Designations Output

Gifts Transactions (POST)
Create gift transactions with related new or matched donor, optional transaction designations, and payment-instrument metadata. This
API supports custom fields for the donor account and gift transaction.
Resource:
/connect/fundraising/gifts

Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/gifts

Available version: 60.0
HTTP methods: POST
Request body for POST
Note: You can pass the campaign, donor, and designation IDs in an externalId object containing fieldName and
fieldValue.

JSON example
{
"processingOptions": {
"donorOptions": {
"defaultUpdateLogic": "update_all"
},
"disableGiftTransactionValidations": true,
"disableGiftCommitmentValidations": true,
"disableGiftCommitmentScheduleValidations": true
},
"gifts": [
{


"amount": 150.25,
"currencyIsoCode": "USD",
"receivedDate": "2024-07-06",
"donorCoverAmount": 0.25,
"transactionStatus": "Unpaid",
"commitmentId": "00x324303243fsfd",
"paymentIdentifier": "1234",
"gatewayTransactionFee": 0.75,
"processorTransactionFee": 0.45,
"processorReference": "cls-1247586928747",
"gatewayReference": "102656693ac3ca6e0cdafbfe89ab99",
"lastGatewayResponseCode": "invalid_cvc",
"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's
security code or use a different card.",
"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z",
"campaign": {
"id": "701y0030d0zk6t06f4"
},
"outreachSourceCode": {
"id": "0gx000d0d0d0FD",
"sourceCode": "AnimalEmailCampaign2023"
},
"donor": {
"donorType": "individual",
"id": "0015500000WO1ZiAAL",
"firstName": "Daniel",
"lastName": "Chavez",
"phone": "510-432-1234",
"email": "danielchavez@salesforce.com",
"address": [
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}
],
"accountCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
},
"paymentInstrument": {
"type": "credit card",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "Diners club",
"bankName": "chase",
"digitalWalletProvider": "Diner's Club",


"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
},
"designations": [
{
"designationId": "0gd0030f0303024",
"percent": 10,
"amount": 150.25
}
],
"giftTransactionCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
}
]
}

Properties
Name

Type

Description

Required or
Optional

Available Version

gifts

Create Gift Request
Input[]

Details of the request to create the gift.

Required

60.0

processing
Options

Processing Options
Details Input

Options for donor matching process and
gift validation pausing.

Optional

60.0

Response body for POST: Create Gift
SEE ALSO:
Nonprofit Cloud Developer Guide: Fundraising

Transactions Payment Updates (POST)
Update the gateway and processor metadata for gift transactions. This API supports updating only the properties that are specified in
the request body. If you include any other standard or custom fields in the request body beyond the specified properties, an error is
shown.
Resource:
/connect/fundraising/transactions/payment-updates


Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/transactions/payment-updates

Available version: 60.0
HTTP methods: POST
Request body for POST
Note: You can pass the transaction ID in an externalId object containing fieldName and fieldValue..

JSON example
{
"updates": [
{
"giftTransactionId": "6TR5500000WO1ZIFGE",
"transactionStatus": "Unpaid",
"processorReference": "string",
"gatewayReference": "string",
"lastGatewayResponseCode": "invalid_cvc",
"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's
security code or use a different card.",
"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z"
}
]
}

Properties
Name

Type

Description

Required or
Optional

updates

Transaction Payment Contains the details of the request to update Required
Update Request
the transaction payment.
Input[]

Available Version
60.0

Response body for POST: Transaction Payment Updates on page 287
SEE ALSO:
Nonprofit Cloud Developer Guide: Fundraising

Commitments Payment Updates (POST)
Update the metadata for your payment instruments for all active gift commitments.
Resource:
/connect/fundraising/commitments/payment-updates

Resource example:
https://yourInstance.salesforce.com/services/data/v66.0/connect/fundraising/commitments/payment-updates


Available version: 60.0
HTTP methods: POST
Request body for POST
Note: You can pass the commitment ID in an externalId object containing fieldName and fieldValue.

JSON example
{
"updates": [
{
"giftCommitmentId": "6TR5500000WO1ZIFGE",
"paymentInstrument": {
"type": "Venmo",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "visa",
"bankName": "chase",
"digitalWalletProvider": "Diner's Club",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
}
}
]
}

Properties
Name

Type

Description

Required or
Optional

updates

Commitment
Payment Updates
Request Input[]

Contains the request details to update the Required
commitment payment.

Response body for POST: Commitment Payment Updates
SEE ALSO:
Nonprofit Cloud Developer Guide: Fundraising


Available Version
60.0

Request Bodies

Request Bodies
Learn more about the available Fundraising API request bodies.
Address Details
Input representation of the donor's address details.
Campaign Details Input
Input representation of the campaign that's associated with the gift transaction.
Commitment Payment Updates Input
Input representation of the details of the payment update to the fundraising commitments.
Commitment Payment Updates Request Input
Input representation of the details of the gift commitment and payment instrument.
Create Commitment Input
Input representation of the request to create commitments.
Create Commitment Request Input
Input representation of the request to create a recurring gift commitment. This request body accepts an array of commitment
requests. However, for the API version 60.0, up to 100 commitments is supported per request.<
Create Gift Input
Input representation of the request to create gifts, including donor details, amount, and payment method.
Create Gift Request Input
Input representation of the data required to create a new gift. This request body accepts both standard and custom fields for donor
account and gift transaction. If a standard field does not appear in the request body, you can include it in the customFields section
for the relevant object.
Custom Field Details Input
Input representation of the custom fields for the request to incorporate custom attributes into records.
Designation Details Input
Input representation of the designations that are associated with the request.
Donor Details Input
Input representation of the donor details that's associated with the gift transaction.
Donor Options Details Input
Input representation of the available donor processing options that includes targeted update logic for the donor-related components
of the commitment transaction.
Outreach Source Code Details Input
Input representation of the outreach source code that's associated with the request.
Payment Instrument Details Input
Input representation of the payment instrument used for the request.
Processing Options Details Input
Input representation of the donor processing options and gift validation disablement.
Transaction Details Input
Input representation of the transaction details.


Request Bodies

Transaction Payment Update Request Input
Input representation of the details of the gateway and processor metadata to update the transaction payment. If you include any
other standard or custom fields in the request body beyond the specified properties, an error is shown.
Transaction Payment Updates Input
Input representation of the gateway and processor metadata to update the transaction payment. If you include any other standard
or custom fields in the request body beyond the specified properties, an error is shown.
Update Commitment Input
Input representation of the request to update a commitment.

Address Details
Input representation of the donor's address details.

JSON example
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}

Properties
Name

Type

Description

Required or
Optional

Available Version

city

String

City of the donor.

Required

60.0

country

String

Country of the donor.

Required

60.0

postalCode

String

Postal code of the donor.

Required

60.0

state

String

State of the donor.

Required

60.0

street

String

Street name of the donor.

Required

60.0

Campaign Details Input
Input representation of the campaign that's associated with the gift transaction.

JSON example
{
"campaign": {
"id": "701y0030d0zk6t06f4"
}
}


Request Bodies

Properties
Name

Type

Description

Required or
Optional

Available Version

id

String

ID of the gift designation. This ID can also
be passed as an externalID.

Optional

60.0

Example externalID format:
{
"externalId": {
"fieldName": "<EXTERNAL_ID_FIELD_NAME>",
"fieldValue": "<EXTERNAL_ID_FIELD_VALUE>"
}
}

Commitment Payment Updates Input
Input representation of the details of the payment update to the fundraising commitments.

JSON example
{
"updates": [
{
"giftCommitmentId": "6TR5500000WO1ZIFGE",
"paymentInstrument": {
"type": "Venmo",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "visa",
"bankName": "chase",
"digitalWalletProvider": "Diner's Club",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
}
}
]
}


Request Bodies

Properties
Name

Type

Description

Required or
Optional

updates

Commitment
Payment Updates
Request Input[]

Contains the request details to update the Required
commitment payment.

Available Version
60.0

Commitment Payment Updates Request Input
Input representation of the details of the gift commitment and payment instrument.

JSON example
Note: You can pass the campaign, donor, and designation IDs in an externalId object containing fieldName and
fieldValue.
{
"giftCommitmentId": "6TR5500000WO1ZIFGE",
"paymentInstrument": {
"type": "Venmo",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "visa",
"bankName": "chase",
"digitalWalletProvider": "Diner's Club",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
}
}

Properties
Name

Type

Description

Required or
Optional

gift
CommitmentId

String

ID of the gift commitment record for the
Required
payment update. This ID can also be passed
as an externalID.


Available Version
60.0

Request Bodies

Name

Type

Description

payment
Instrument

Payment Instrument Contains details about the payment
Details Input on
instrument.
page 259

Example externalID format:
{
"externalId": {
"fieldName": "<EXTERNAL_ID_FIELD_NAME>",
"fieldValue": "<EXTERNAL_ID_FIELD_VALUE>"
}
}

Create Commitment Input
Input representation of the request to create commitments.

JSON example
{
"processingOptions": {
"donorOptions": {
"defaultUpdateLogic": "update_all"
},
"disableGiftTransactionValidations": true,
"disableGiftCommitmentValidations": true,
"disableGiftCommitmentScheduleValidations": true
},
"commitments": [
{
"amount": 150.25,
"type": "pledge",
"currencyIsoCode": "USD",
"transactionPeriod": "monthly",
"transactionInterval": 3,
"transactionDay": "5",
"startDate": "2024-07-06",
"endDate": "2024-07-06",
"campaign": {
"id": "701y0030d0zk6t06f4"
},
"outreachSourceCode": {
"id": "0gx000d0d0d0FD",
"sourceCode": "AnimalEmailCampaign2023"
},
"donor": {
"donorType": "individual",
"id": "0015500000WO1ZxxAL",
"organizationName": "mini cat town",


Required or
Optional

Available Version

Required

60.0

Request Bodies

"firstName": "Daniel",
"lastName": "Chavez",
"phone": "510-432-9876",
"email": "d.chavez.com",
"address": [
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}
],
"accountCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
},
"paymentInstrument": {
"type": "Credit Card",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "Diner's Club",
"bankName": "chase",
"digitalWalletProvider": "EwalletProvider",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
},
"designations": [
{
"designationId": "0gd0030f0303024",
"percent": 10
}
],
"firstTransaction": {
"amount": 150.25,
"receivedDate": "2024-07-06",
"donorCoverAmount": 0.25,
"transactionStatus": "Unpaid",
"gatewayTransactionFee": 0.75,
"processorTransactionFee": 0.45,
"processorReference": "cls-1247586928747",
"gatewayReference": "102656693ac3ca6e0cdafbfe89ab99",
"lastGatewayResponseCode": "invalid_cvc",


Request Bodies

"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's
security code or use a different card.",
"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z"
},
"giftCommitmentCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
],
"giftCommitmentScheduleCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
],
"giftTransactionCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
}
]
}

Properties
Name

Type

Description

Required or
Optional

commitments

Create Commitment Details of the request to create the
Required
Request Input[]
commitment. Limited to 100 commitments
in a single request.

60.0

processing
Options

Processing Options
Details Input

60.0

Options for donor matching process and
gift validation pausing.

Optional

Available Version

Create Commitment Request Input
Input representation of the request to create a recurring gift commitment. This request body accepts an array of commitment requests.
However, for the API version 60.0, up to 100 commitments is supported per request.<
To include the standard fields for the donor account, use the Create Commitment Input request body to specify the standard fields.

JSON example
Note: You can pass the campaign, donor, and designation IDs in an externalId object containing fieldName and
fieldValue.
{
"commitments": [


Request Bodies

{
"amount": 15,
"type": "pledge",
"currencyIsoCode": "USD",
"transactionInterval": 1,
"transactionDay": "1",
"startDate": "2023-11-01",
"endDate": "",
"outreachSourceCode": {
"sourceCode": "AnimalEmailCampaign2023"
},
"donor": {
"donorType": "individual",
"id": "0015500000WO1ZixxL",
"firstName": "Daniel",
"lastName": "Chavez",
"phone": "510-432-1234",
"email": "d.chavez@salesforce.com",
"address": [
{
"street": "123 Main Street",
"city": "Tardis",
"state": "NJ",
"postalCode": "08638",
"country": "US"
}
],
"accountCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
},
"paymentInstrument": {
"type": "Credit Card",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "Diner's Club",
"bankName": "chase",
"digitalWalletProvider": "",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
},
"designations": [
{


Request Bodies

"designationId": "0gd0030f0303xx4",
"percent": 0
}
],
"firstTransaction": {
"amount": 15,
"receivedDate": "2023-11-02",
"donorCoverAmount": 0.25,
"transactionStatus": "Paid",
"gatewayTransactionFee": 0.75,
"processorTransactionFee": 0.045,
"processorReference": "cls-1247586928747",
"gatewayReference": "102656693ac3ca6e0cdafbfe89ab99",
"lastGatewayResponseCode": "",
"lastGatewayErrorMessage": "",
"lastGatewayProcessedDateTime": "2023-11-02T21:57:51Z"
}
}
]
}

Properties
Name

Type

Description

accountCustomFields Custom Field Details Standard and custom fields for the donor

Required or
Optional

Available Version

Optional

60.0

Input[]

account.

amount

Double

Expected amount of the gift transaction in Required
the commitment schedule.

60.0

campaign

Campaign Details
Input

Campaign that's associated with the
commitment.

Optional

60.0

currency
IsoCode

String

Currency ISO code for the commitment.

Optional

60.0

designations

Designation Details
Input[]

Default gift designations that are associated Optional
with the commitment.

60.0

donor

Donor Details Input

Person, household, or organization account Required
that's associated with the commitment.

60.0

endDate

String

Date when the total amount of the
commitment is expected to be paid. The
default format is YYYY-MM-DD.

Required

60.0

first
Transaction

Transaction Details
Input

First transaction of the commitment. Note: Optional
When type is pledge, this property
cannot be included.

60.0

giftCommitment Custom Field Details Standard and custom fields of the gift
commitment.
CustomFields Input[]


Optional

60.0

Request Bodies

Type

Description

Required or
Optional

Available Version

Optional

60.0

giftTransaction
CustomFields

Custom Field Details Custom fields for the gift transaction. The Optional
Input[]
giftTransactionCustomFields property also
accepts the standard fields for the gift
transaction.

60.0

outreach
SourceCode

Outreach Source
Code Details Input

Outreach source code that's associated with Optional
the campaign for the gift commitment
schedule.

60.0

payment
Instrument

Payment Instrument Payment instrument that's used to complete Required
Details Input
the transaction.

60.0

payment
Processor
CommitmentId

String

Reference number of the commitment that Optional
was assigned by the processor.

60.0

startDate

String

Date from when the commitment is in
Required
effect. The default format is YYYY-MM-DD.

60.0

transaction
Day

String

Day of the month to create gift transaction Optional
in the future for a monthly transaction
period. If you select the day as 29 or 30, the
gift transaction is created on the last day for
months that don't have that many days.

60.0

transaction
Interval

Integer

Transaction interval that's applicable to the Optional
incoming transaction in the commitment.

60.0

transaction
Period

String

Transaction period that's applicable to the Required
incoming transaction in the commitment.
When type is pledge, this property
must be set to Custom. If
transactionPeriod is not provided,
the default is Custom.

60.0

type

String

Type of transaction. Possible values are:
Optional
Pledge or Recurring. The default value
is Recurring.

62.0

giftCommitment Custom Field Details Standard and custom fields of the gift
Input[]
commitment schedule.
Schedule
CustomFields

Create Gift Input
Input representation of the request to create gifts, including donor details, amount, and payment method.


Request Bodies

JSON example
{
"processingOptions": {
"donorOptions": {
"defaultUpdateLogic": "update_all"
},
"disableGiftTransactionValidations": true,
"disableGiftCommitmentValidations": true,
"disableGiftCommitmentScheduleValidations": true
},
"gifts": [
{
"amount": 150.25,
"currencyIsoCode": "USD",
"receivedDate": "2024-07-06",
"donorCoverAmount": 0.25,
"transactionStatus": "Unpaid",
"commitmentId": "00x324303243fsfd",
"paymentIdentifier": "1234",
"gatewayTransactionFee": 0.75,
"processorTransactionFee": 0.45,
"processorReference": "cls-1247586928747",
"gatewayReference": "102656693ac3ca6e0cdafbfe89ab99",
"lastGatewayResponseCode": "invalid_cvc",
"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's
security code or use a different card.",
"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z",
"campaign": {
"id": "701y0030d0zk6t06f4"
},
"outreachSourceCode": {
"id": "0gx000d0d0d0FD",
"sourceCode": "AnimalEmailCampaign2023"
},
"donor": {
"donorType": "individual",
"id": "0015500000WO1ZiAAL",
"firstName": "Daniel",
"lastName": "Chavez",
"phone": "510-432-1234",
"email": "danielchavez@salesforce.com",
"address": [
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}
],
"accountCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"


Request Bodies

}
]
},
"paymentInstrument": {
"type": "credit card",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "Diners club",
"bankName": "chase",
"digitalWalletProvider": "Diner's Club",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
},
"designations": [
{
"designationId": "0gd0030f0303024",
"percent": 10,
"amount": 150.25
}
],
"giftTransactionCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
}
]
}

Properties
Name

Type

Description

Required or
Optional

Available Version

gifts

Create Gift Request
Input[]

Details of the request to create the gift.

Required

60.0

processing
Options

Processing Options
Details Input

Options for donor matching process and
gift validation pausing.

Optional

60.0


Request Bodies

Create Gift Request Input
Input representation of the data required to create a new gift. This request body accepts both standard and custom fields for donor
account and gift transaction. If a standard field does not appear in the request body, you can include it in the customFields section for
the relevant object.

JSON example
{
"gifts": [
{
"amount": 150.25,
"currencyIsoCode": "USD",
"receivedDate": "2024-07-06",
"donorCoverAmount": 0.25,
"transactionStatus": "Unpaid",
"commitmentId": "00x324303243fsfd",
"paymentIdentifier": "1234",
"gatewayTransactionFee": 0.75,
"processorTransactionFee": 0.45,
"processorReference": "cls-1247586928747",
"gatewayReference": "102656693ac3ca6e0cdafbfe89ab99",
"lastGatewayResponseCode": "invalid_cvc",
"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's
security code or use a different card.",
"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z",
"campaign": {
"id": "701y0030d0zk6t06f4"
},
"outreachSourceCode": {
"id": "0gx000d0d0d0FD",
"sourceCode": "AnimalEmailCampaign2023"
},
"donor": {
"donorType": "individual",
"id": "0015500000WO1ZixxL",
"firstName": "Daniel",
"lastName": "Chavez",
"phone": "510-432-1234",
"email": "example@salesforce.com",
"address": [
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}
],
"accountCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}


Request Bodies

]
},
"paymentInstrument": {
"type": "credit card",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "visa",
"bankName": "chase",
"digitalWalletProvider": "Diner's Club",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "OptiSynth",
"processorPaymentReference": "string",
"gatewayReference": "string"
},
"designations": [
{
"designationId": "0gd0030f0303024",
"percent": 10,
"amount": 150.25
}
],
"giftTransactionCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
}
]
}

Properties
Name

Type

Description

Required or
Optional

accountCustomFields Custom Field Details Custom fields for the donor account. The Optional
Input[]
accountCustomFields property aslo

Available Version
60.0

accepts the standard fields for the donor
account.
amount

Double

Original amount of the gift transaction.

Required

60.0

campaign

Campaign Details
Input

Campaign that's associated with the gift
transaction.

Optional

60.0


Request Bodies

Name

Type

Description

Required or
Optional

Available Version

commitmentId

String

Gift commitment ID that's associated with Optional
the gift transaction.

60.0

currency
IsoCode

String

ISO code of the currency.

Optional

60.0

designations

Designation Details
Input[]

Designations that are associated with the
gift transaction.

Optional

60.0

donor

Donor Details Input

Donor details that are associated with the
gift transaction.

Required

60.0

donorCover
Amount

Double

Amount that the donor added to their gift Optional
to cover fees.

60.0

gateway
Reference

String

Reference of the transaction to which the
gateway is assigned.

Optional

60.0

gateway
Double
TransactionFee

Transaction fees charged by the gateway.

Optional

60.0

giftTransaction Custom Field Details Custom fields for the gift transaction. The Optional
giftTransactionCustomFields
CustomFields Input[]

60.0

property also accepts the standard fields for
the gift transaction.
Most recent error message received by the Optional
gateway.

60.0

lastGateway
String
ProcessedDate
Time

Last attempt made by the gateway.

Optional

60.0

lastGateway
ResponseCode

String

Most recent response code that was
received by the gateway.

Optional

60.0

outreach
SourceCode

Outreach Source
Code Details Input

Outreach source code that's associated with Optional
the gift transaction.

60.0

payment
Identifier

String

Unique ID for the payment transaction.

Optional

60.0

payment
Instrument

Payment Instrument Payment instrument used for the gift
Details Input
transaction.

Required

60.0

processor
Reference

String

Reference of the transaction to which the
payment processor is assigned.

Optional

60.0

processor
Transaction
Fee

Double

Transaction fees charged by the processor. Optional

60.0

lastGateway
ErrorMessage

String


Request Bodies

Name

Type

Description

Required or
Optional

Available Version

receivedDate

String

Date when the donor completed the gift
transaction.

Required

60.0

transaction
Status

String

Status of the gift transaction.

Required

60.0

Custom Field Details Input
Input representation of the custom fields for the request to incorporate custom attributes into records.
You can include the standard fields such as Description, EffectiveStartDate, and more in this request body. To include the standard fields
in the request body, specify the API name of the standard field as the value of the fieldName property, and provide the value for
the standard field in the fieldValue property.

JSON example
This example shows a sample request that includes a standard field.
{
"fieldName": "effectiveStartDate",
"fieldValue": "2024-05-06"
}

This example shows a sample request that includes a custom field.
{
"fieldName": "TShirtSize__c",
"fieldValue": "Medium"
}

Properties
Name

Type

Description

Required or
Optional

Available Version

fieldName

String

API name of the custom or standard field.

Optional

60.0

fieldValue

Object

Value of the custom or standard field.

Optional

60.0

Designation Details Input
Input representation of the designations that are associated with the request.

JSON example
{
"designations": {
"id": "0gd0030f0303xx4",


Request Bodies

"amount": 150.25,
"percent": 10
}
}

Properties
Name

Type

Description

Required or
Optional

amount

Double

Transaction amount that's allocated to the Optional
designation, which is for gifts only.

60.0

id

String

ID of the gift designation. This ID can also
be passed as an externalID.

Optional

60.0

percent

Double

Percentage of the transaction or
Optional
commitment amount that's allocated to the
designation.

60.0

Example externalID format:
{
"externalId": {
"fieldName": "<EXTERNAL_ID_FIELD_NAME>",
"fieldValue": "<EXTERNAL_ID_FIELD_VALUE>"
}
}

Donor Details Input
Input representation of the donor details that's associated with the gift transaction.

JSON example
{
"donorType": "individual",
"id": "0015500000WO1ZiAAL",
"firstName": "Daniel",
"lastName": "Chavez",
"phone": "510-434-8920",
"email": "d.chavez@salesforce.com",
"address": [
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}
],


Available Version

Request Bodies

"accountCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
}

Properties
Name

Type

Description

Required or
Optional

account
CustomFields

Custom Field Details Account standard and custom fields of the Optional
Input[]
donor.

60.0

address

Address Details
Input[]

Address details of the donor.

Optional

60.0

donorType

String

Type of the donor. You can't use the
organizationName when the
donorType is set to Individual.
Similarly, don't use firstName or
lastName properties when the
donorType is Organizational.

Required

60.0

email

String

Email address of the donor.

Optional

60.0

firstName

String

First name of the donor.

Required

60.0

id

String

ID of the gift designation. This ID can also
be passed as an externalID.

Optional

60.0

lastName

String

Last name of the donor.

Required

60.0

organization
Name

String

Organization name of the donor.

Required

60.0

phone

String

Phone number of the donor.

Optional

60.0

Example externalID format:
{
"externalId": {
"fieldName": "<EXTERNAL_ID_FIELD_NAME>",
"fieldValue": "<EXTERNAL_ID_FIELD_VALUE>"
}
}


Available Version

Request Bodies

Donor Options Details Input
Input representation of the available donor processing options that includes targeted update logic for the donor-related components
of the commitment transaction.

JSON example
"donorOptions": {
"defaultUpdateLogic": "update_all"
}

Properties
Name

Type

Description

Required or
Optional

default
UpdateLogic

String

Default update value for the donor updates. Optional

Available Version
60.0

Valid values for defaultUpdateLogic:
• update_all—If an existing donor is matched (whether by a record ID, external ID, or Duplicate Rules), any donor properties that
are provided are updated on the matched donor's account, including any custom account field mappings.
• no_update—If an existing donor is matched (whether by a record ID, external ID, or Duplicate Rules), none of the donor properties
that are provided are updated on the matched donor's account, including any custom account field mappings.

Outreach Source Code Details Input
Input representation of the outreach source code that's associated with the request.

JSON example
{
"id": "0gx000d0d0d0FD",
"sourceCode": "AnimalEmailCampaign2023"
}

Properties
Name

Type

Description

Required or
Optional

Available Version

id

String

ID of the outreach source code.

Optional

60.0

sourceCode

String

Unique code associated with the outreach Optional
source.

60.0


Request Bodies

Payment Instrument Details Input
Input representation of the payment instrument used for the request.

JSON example
{
"type": "Credit Card",
"accountHolderName": "Diana Gómez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "Diner's Club",
"bankName": "chase",
"digitalWalletProvider": "",
"bankAccountHolderType": "",
"bankAccountType": "",
"bankAccountNumber": "",
"bankCode": "",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
}

Properties
Name

Type

Description

Required or
Optional

Available Version

account
HolderName

String

Name of the payment instrument holder.

Optional

60.0

bankAccount
HolderType

String

Specifies if the bank account holder is an
individual or a company.

Optional

60.0

bankAccount
Number

String

Bank account number associated with the Optional
payment instrument.

60.0

bankAccount
Type

String

Type of the bank account.

Optional

60.0

bankCode

String

Code of the bank that's associated with the Optional
bank account.

60.0

bankName

String

Bank name that's associated with the bank Optional
account.

60.0

cardBrand

String

Brand, network, or issuer of the credit card. Optional

60.0

Provider of the digital wallet.

60.0

digital
String
WalletProvider


Optional

Request Bodies

Name

Type

Description

expiryMonth

String

Expiration month if the payment method is Optional
credit card.

60.0

expiryYear

String

Expiration year if the payment method is
credit card.

Optional

60.0

gatewayName

String

Name of the payment gateway.

Optional

60.0

gateway
Reference

String

Reference number of the gateway for this
payment instrument.

Optional

60.0

last4

String

Last four digits of the account number for
the payment method.

Optional

60.0

Name of the payment processor.

Optional

60.0

processorName String

Required or
Optional

Available Version

processor
Payment
Reference

String

Reference of the payment processor that's Optional
associated with the payment instrument.

60.0

type

String

Type of the payment instrument used for
the request.

Required

60.0

Description

Required or
Optional

Available Version

Indicates whether a subset of Gift
Commitment Schedule validation rules is
disabled for the request. The default is
false.

Optional

60.0

Processing Options Details Input
Input representation of the donor processing options and gift validation disablement.

JSON example
{
"processingOptions": {
"donorOptions": {
"defaultUpdateLogic": "update_all"
},
"disableGiftTransactionValidations": true,
"disableGiftCommitmentValidations": true,
"disableGiftCommitmentScheduleValidations": true
}
}

Properties
Name

Type

disableGiftCommitmentScheduleValidations Boolean


Request Bodies

Type

Description

Required or
Optional

Available Version

disableGiftCommitmentValidations Boolean

Indicates whether a subset of Gift
Optional
Commitment validation rules is disabled for
the request. The default is false.

60.0

disableGiftTransactionValidations Boolean

Indicates whether a subset of Gift
Transaction validation rules is disabled for
the request. The default is false.

Optional

60.0

Donor processing options to create gift
commitments.

Optional

60.0

donorOptions

Donor Options
Details Input

Transaction Details Input
Input representation of the transaction details.

JSON example
{
"amount": 150.25,
"receivedDate": "2024-07-06",
"donorCoverAmount": 0.25,
"transactionStatus": "Unpaid",
"gatewayTransactionFee": 0.75,
"processorTransactionFee": 0.45,
"processorReference": "cls-1247586928747",
"gatewayReference": "102656693ac3ca6e0cdafbfe89ab99",
"lastGatewayResponseCode": "invalid_cvc",
"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's security
code or use a different card.",
"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z"
}

Properties
Name

Type

Description

Required or
Optional

Available Version

amount

Double

Original amount of the gift transaction.

Optional

60.0

donor
CoverAmount

Double

Amount that the donor added to their gift Optional
to cover fees.

60.0

gateway
Reference

String

Reference of the transaction to which the
gateway is assigned.

Optional

60.0

gateway
Double
TransactionFee

Transaction fees charged by the gateway.

Optional

60.0


Request Bodies

Name

Type

Description

lastGateway
ErrorMessage

String

Most recent error message received by the Optional
gateway.

60.0

lastGatewayProcessedDateTime String

Last attempt made by the gateway.

Optional

60.0

lastGateway
ResponseCode

String

Most recent response code that was
received by the gateway.

Optional

60.0

processor
Reference

String

Reference of the transaction to which the
payment processor is assigned.

Optional

60.0

Transaction fees charged by the processor. Optional

60.0

processor
Double
TransactionFee

Required or
Optional

Available Version

receivedDate

String

Date when the donor completed the gift
transaction.

Optional

60.0

transaction
Status

String

Transaction status of the gift.

Optional

60.0

Transaction Payment Update Request Input
Input representation of the details of the gateway and processor metadata to update the transaction payment. If you include any other
standard or custom fields in the request body beyond the specified properties, an error is shown.

JSON example
{
"giftTransactionId": "6TR5500000WO1ZIxxE",
"transactionStatus": "Unpaid",
"processorReference": "string",
"gatewayReference": "string",
"lastGatewayResponseCode": "invalid_cvc",
"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's security
code or use a different card.",
"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z"
}

Properties
Name

Type

Description

Required or
Optional

Available Version

gateway
Reference

String

Reference of the transaction to which the
gateway is assigned.

Optional

60.0

ID of the gift transaction record. This ID can Required
also be passed as an externalID.

60.0

gift
String
TransactionId


Request Bodies

Name

Type

Description

Required or
Optional

Available Version

lastGateway
ErrorMessage

String

Most recent error message received by the Optional
gateway.

60.0

lastGateway
Processed
DateTime

String

Last attempt made by the gateway.

Optional

60.0

lastGateway
ResponseCode

String

Most recent response code that was
received by the gateway.

Optional

60.0

processor
Reference

String

Reference of the transaction to which the
payment processor is assigned.

Optional

60.0

transaction
Status

String

Gift status of the transaction.

Required

60.0

Example externalID format:
{
"externalId": {
"fieldName": "<EXTERNAL_ID_FIELD_NAME>",
"fieldValue": "<EXTERNAL_ID_FIELD_VALUE>"
}
}

Transaction Payment Updates Input
Input representation of the gateway and processor metadata to update the transaction payment. If you include any other standard or
custom fields in the request body beyond the specified properties, an error is shown.

JSON example
{
"updates": [
{
"giftTransactionId": "6TR5500000WO1ZIFGE",
"transactionStatus": "Unpaid",
"processorReference": "string",
"gatewayReference": "string",
"lastGatewayResponseCode": "invalid_cvc",
"lastGatewayErrorMessage": "The card's security code is invalid. Check the card's
security code or use a different card.",
"lastGatewayProcessedDateTime": "2023-07-06T21:57:51Z"
}
]
}


Request Bodies

Properties
Name

Type

Description

Required or
Optional

updates

Transaction Payment Contains the details of the request to update Required
Update Request
the transaction payment.
Input[]

Update Commitment Input
Input representation of the request to update a commitment.

JSON example
{
"amount": 150.25,
"type": "pledge",
"transactionInterval": 3,
"transactionDay": "5",
"startDate": "2024-07-06",
"endDate": "2024-07-06",
"campaign": {
"id": "701y0030d0zk6t06f4"
},
"outreachSourceCode": {
"id": "0gx000d0d0d0FD",
"sourceCode": "AnimalEmailCampaign2023"
},
"processingOptions": {
"donorOptions": {
"defaultUpdateLogic": "update_all"
},
"disableGiftTransactionValidations": true,
"disableGiftCommitmentValidations": true,
"disableGiftCommitmentScheduleValidations": true
},
"donor": {
"donorType": "individual",
"organizationName": "ABC Inc.",
"firstName": "Daniel",
"lastName": "Chavez",
"phone": "510-434-8920",
"email": "d.chavez@salesforce.com",
"address": [
{
"street": "123 Main Street",
"city": "Oakland",
"state": "CA",
"postalCode": "94610",
"country": "US"
}


Available Version
60.0

Request Bodies

],
"accountCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
],
"paymentInstrument": {
"type": "Credit Card",
"accountHolderName": "Daniel Chavez",
"expiryMonth": "10",
"expiryYear": "2026",
"last4": "4321",
"cardBrand": "Diner's Club",
"bankName": "chase",
"digitalWalletProvider": "EProvider",
"bankAccountHolderType": "primary",
"bankAccountType": "checking",
"bankAccountNumber": "123456",
"bankCode": "HBUK",
"gatewayName": "Gateway",
"processorName": "Centpro",
"processorPaymentReference": "string",
"gatewayReference": "string"
},
"giftCommitmentCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
],
"giftCommitmentScheduleCustomFields": [
{
"fieldName": "string",
"fieldValue": "string"
}
]
}
}

Properties
Name

Type

Description

Required or
Optional

amount

Double

Gift amount of each transaction associated Required
with the gift commitment schedule.

60.0

campaign

Campaign Details

Campaign that's associated with the gift
commitment.

Optional

60.0

currency
IsoCode

String

Currency ISO code of the gift commitment. Optional

60.0


Available Version

Response Bodies

Name

Type

Description

Required or
Optional

Available Version

donorId

Donor Details Input

Person, household, or organization account Optional
associated with the commitment.

60.0

endDate

String

End date of the new schedule for this gift Optional
commitment. The format is YYYY-MM-DD.

60.0

giftCommitment Custom Field
CustomFields Details[]

Custom fields of the gift commitment.

Optional

60.0

giftCommitment Custom Field
Details[]
Schedule
CustomFields

Custom fields of the gift commitment
schedule.

Optional

60.0

outreach
SourceCode

Outreach Source
Code Details

Outreach source code that's associated with Optional
the campaign for the gift commitment.

60.0

payment
Instrument

Payment Instrument Payment instrument that's used to complete Required
Details
the transaction.

60.0

processing
Options

Processing Options
Details Input

Options for donor matching process and
gift validation pausing

Optional

60.0

startDate

String

Start date of the new schedule for this gift Required
commitment. The format is YYYY-MM-DD.

60.0

transaction
Day

String

Specifies the day of the month to create gift Optional
transactions in the future for a monthly
transaction period. If you select the day as
29 or 30, the gift transaction is created on
the last day for the months that don't have
that many days.

60.0

transaction
Interval

Integer

Transaction interval that's applicable to an Optional
incoming transaction in the commitment.

60.0

transaction
Period

String

Transaction period that's applicable to the Required
incoming transaction in the commitment.
When type is pledge, this property
must be set to Custom. If
transactionPeriod is not provided,
the default is Custom.

60.0

type

String

Type of transaction. Possible values are:
Optional
Pledge or Recurring. The default value
is Recurring.

62.0

Response Bodies
Learn more about the available Fundraising API response bodies.


Response Bodies

Commitment Payment Updates
Output representation of the request to update the commitment payment for a fundraising commitment.
Commitment Payment Updates
Output representation of the updates for the commitment payment.
Commitment Payment Updates Response Link
Output representation of the links to the response object for the commitment payment updates.
Create Commitment
Output representation of the fundraising commitment request that contains the commitment ID and associated links.
Create Commitment Response Details
Output representation of the create commitment result with success status code, error, if any, and associated object links.
Create Commitment Response Link
Output representation of the links to the response object.
Create Gift
Output representation of the details of the created gift transaction response.
Create Gift Response Details
Output representation of the request details to create the gift.
Create Gift Response Link
Output representation of the links to the response object.
Error Details
Output representation of the errors encountered during an API request.
Gift Campaign Default Designations Output
Output representation of a list of default designations associated with a gift campaign record.
Gift Campaign Default Designation Record Output
Output representation of a default designation record associated with a gift campaign.
Gift Commitment Default Designations Output
Output representation of a list of default designations associated with a gift commitment.
Gift Commitment Default Designation Record Output
Output representation of a default designation record associated with a gift commitment.
Gift Commitment Transaction Matching Output
Output representation of a list of gift transactions.
Gift Transactions Output
Output representation of the gift transactions associated with a gift commitment record.
Gift Transaction Linked Designations Output
Output representation of a list of gift designations.
Gift Transaction Record Output
Output representation of a gift transaction record.
Gift Designation Record Output
Output representation of a gift designation record.
Link Details
Output representation of the link details for the response object.


Response Bodies

Transaction Payment Updates
Output representation of the transaction payment updates.
Transaction Payment Updates Response
Output representation of the updates for the transaction payment.
Transaction Payment Updates Response Link
Output representation of the links to the response object for the transaction payment updates.
Update Commitment
Output representation of the update commitment request that contains the status, errors if any, and the links to objects after you
update a gift commitment.
Update Commitment Response Link
Output representation of the links to the response object for the commitment updates.

Commitment Payment Updates
Output representation of the request to update the commitment payment for a fundraising commitment.

Sample Response
{
"successes": 0,
"failures": 0,
"notProcessed": 0,
"details": [
{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}
]
}


Response Bodies

Property Name

Type

Description

Filter Group and
Version

details

Commitment
Payment Updates[]
on page 269

Contains the response of the commitment Small, 60.0
payment update.

60.0

failures

Integer

Number of gift commitments that failed to Small, 60.0
be updated.

60.0

notProcessed

Integer

Number of gift commitments that weren't Small, 60.0
processed.

60.0

successes

Integer

Number of gift commitments that were
updated.

60.0

Small, 60.0

Available Version

Commitment Payment Updates
Output representation of the updates for the commitment payment.

Sample Response
{
"details": [
{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}
]
}

Property Name

Type

Description

Filter Group and
Version

Available Version

errors

Error Details[]

Error message if a process failed.

Small, 60.0

60.0


Response Bodies

Property Name

Type

Description

Filter Group and
Version

Available Version

links

Commitment
Payment Updates
Response Link

Links to the response object.

Small, 60.0

60.0

success

Boolean

Indicates whether the request was
processed successfully (true) or not
(false).

Small, 60.0

60.0

Commitment Payment Updates Response Link
Output representation of the links to the response object for the commitment payment updates.

Sample Response
{
"links": {
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}

Property Name

Type

Description

Filter Group and
Version

Available Version

gift
commitment

Link Details

Link to the gift commitment response.

Small, 60.0

60.0

payment
instrument

Link Details

Link to the first payment instrument
response.

Small, 60.0

60.0

Create Commitment
Output representation of the fundraising commitment request that contains the commitment ID and associated links.

Sample Response
{
"successes": 0,
"failures": 0,
"notProcessed": 0,
"details": [


Response Bodies

{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftcommitmentschedule": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftdefaultdesignation": [
{
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
],
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"account": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}
]
}

Property Name

Type

Description

Filter Group and
Version

Available Version

details

Create Commitment Contains the response to the create
Response Details[] commitment request.

Small, 60.0

60.0

failures

Integer

Number of commitments that failed to be Small, 60.0
created.

60.0

notProcessed

Integer

Number of commitments that weren't
processed.

Small, 60.0

60.0

successes

Integer

Number of successful commitments that
were created.

Small, 60.0

60.0


Response Bodies

Create Commitment Response Details
Output representation of the create commitment result with success status code, error, if any, and associated object links.

Sample Response
{
"details": [
{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftcommitmentschedule": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftdefaultdesignation": [
{
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
],
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"account": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}
]
}

Property Name

Type

Description

Filter Group and
Version

Available Version

errors

Error Details[]

Details of the error if the request failed to
process.

Small, 60.0

60.0


Response Bodies

Property Name

Type

links

success

Description

Filter Group and
Version

Available Version

Create Commitment Links to the response object.
Response Link

Small, 60.0

60.0

Boolean

Small, 60.0

60.0

Indicates whether the request was
processed successfully (true) or not
(false).

Create Commitment Response Link
Output representation of the links to the response object.

Sample Response
{
"links": {
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftcommitmentschedule": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftdefaultdesignation": [
{
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
],
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"account": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}

Property Name

Type

Description

Filter Group and
Version

Available Version

account

Link Details

Link to the donor account.

Small, 60.0

60.0


Property Name

Response Bodies

Type

Description

Filter Group and
Version

Available Version

giftcommitment Link Details

Link to the gift commitment response.

Small, 60.0

60.0

giftcommitment Link Details
schedule

Link to the gift commitment schedule
response.

Small, 60.0

60.0

giftdefault
designation

Link Details[]

Link to the gift default designation response. Small, 60.0

60.0

gift
transaction

Link Details

Link to the first gift transaction response.

Small, 60.0

60.0

payment
instrument

Link Details

Link to the first payment instrument
response.

Small, 60.0

60.0

Create Gift
Output representation of the details of the created gift transaction response.

Sample Response
{
"successes": 0,
"failures": 0,
"notProcessed": 0,
"details": [
{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"account": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},


Response Bodies

"gifttransactiondesignation": [
{
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
],
"campaign": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"outreachsourcecode": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}
]
}

Property Name

Type

details

Description

Filter Group and
Version

Available Version

Create Gift Response Contains the details of the gift response.
Details[]

Small, 60.0

60.0

failures

Integer

Number of transactions that failed to be
created.

Small, 60.0

60.0

notProcessed

Integer

Number of transactions that weren't
processed.

Small, 60.0

60.0

successes

Integer

Number of transactions that were created. Small, 60.0

60.0

Create Gift Response Details
Output representation of the request details to create the gift.

Sample Response
{
"details": [
{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"account": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"


Response Bodies

},
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"gifttransactiondesignation": [
{
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
],
"campaign": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"outreachsourcecode": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}
]
}

Property Name

Type

Description

Filter Group and
Version

Available Version

errors

Error Details[]

Details of the error if the request failed to
process.

Small, 60.0

60.0

links

Create Gift Response Links to the response object.
Link

Small, 60.0

60.0

success

Boolean

Small, 60.0

60.0

Indicates whether the request was
processed successfully (true) or not
(false).

Create Gift Response Link
Output representation of the links to the response object.


Response Bodies

Sample Response
{
"links": {
"account": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"paymentinstrument": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"gifttransactiondesignation": [
{
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
],
"campaign": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"outreachsourcecode": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}

Property Name

Type

Description

Filter Group and
Version

Available Version

account

Link Details

Link to the donor account.

Small, 60.0

60.0

gift
commitment

Link Details

Link to the gift commitment response.

Small, 60.0

60.0

gift
transaction

Link Details

Link to the gift transaction response.

Small, 60.0

60.0

Link to the gift transaction designations.

Small, 60.0

60.0

Link to the payment instrument response.

Small, 60.0

60.0

gifttransaction Link Details
designation
payment
instrument

Link Details


Response Bodies

Error Details
Output representation of the errors encountered during an API request.

Sample Response
{
"errors": {
"field": "string",
"message": "string"
}
}

Property Name

Type

Description

Filter Group and
Version

Available Version

field

String

Name of the field that has errors.

Small, 60.0

60.0

message

String

Error message for the failed process.

Small, 60.0

60.0

Gift Campaign Default Designations Output
Output representation of a list of default designations associated with a gift campaign record.

JSON example
{{
"campaignDefaultDesignations":[
{
"designationId":"6gdRM000000000LYAQ",
"designationName": "Default Designation",
"percent":50
},
{
"designationId":"6gdxx000004WhULAA0",
"designationName": "Other Designation",
"percent":50
}
]
}

Property Name

Type

Description

campaignDefaultDesignations Gift Campaign

List of default gift designations associated
Default Designation with a gift campaign record.
Record Output[]

Gift Campaign Default Designation Record Output
Output representation of a default designation record associated with a gift campaign.


Filter Group and
Version

Available Version

Small, 59.0

59.0

Response Bodies

Property Name

Description

Filter Group and
Version

Available Version

designationId String

ID of the default gift designation record.

Small, 59.0

59.0

designationName String

The name of the gift designation

Small, 66.0

66.0

Percentage value of the default gift
designation record.

Small, 59.0

59.0

Filter Group and
Version

Available Version

Small, 59.0

59.0

Description

Filter Group and
Version

Available Version

designationId String

ID of the default gift designation record.

Small, 59.0

59.0

designationName String

The name of the gift designation

Small, 66.0

66.0

Percentage value of the default gift
designation record.

Small, 59.0

59.0

percentage

Type

Double

Gift Commitment Default Designations Output
Output representation of a list of default designations associated with a gift commitment.

JSON example
{
"commitmentDefaultDesignations":[
{
"designationId":"6idRM000000000LYAQ",
"percent":100
},
{
"designationId":"6gaxx000004WhULAA0",
"percent":50
}
]
}

Property Name

Type

Description

commitmentDefaultDesignations Gift Commitment

List of default gift designations associated
Default Designation with a gift commitment.
Record Output[]

Gift Commitment Default Designation Record Output
Output representation of a default designation record associated with a gift commitment.
Property Name

percentage

Type

Double


Response Bodies

Gift Commitment Transaction Matching Output
Output representation of a list of gift transactions.

JSON example
{
"giftTransactions":[
{
"fields":[
{
"fieldApiName":"GiftCommitmentId",
"label":"Gift Commitment ID",
"type":"String",
"value":"6gcRM0000004CD0YAM"
},
{
"fieldApiName":"Id",
"label":"Gift Transaction ID",
"type":"String",
"value":"6trRM00000000CwYAI"
},
{
"fieldApiName":"Name",
"label":"Name",
"type":"String",
"value":"Tom C3 - Tom C3 GT 7"
},
{
"fieldApiName":"GiftType",
"label":"Gift Type",
"type":"String",
"value":"Individual"
},
{
"fieldApiName":"TransactionDueDate",
"label":"Transaction Due Date",
"type":"DateOnlyWrapper",
"value":"Thu Aug 31 00:00:00 GMT 2023"
},
{
"fieldApiName":"DonorId",
"label":"Donor ID",
"type":"String",
"value":"001RM000005bZRUYA2"
},
{
"fieldApiName":"OwnerId",
"label":"Owner ID",
"type":"String",
"value":"005RM0000027gL8YAI"
},
{
"fieldApiName":"RefundedAmount",


Response Bodies

"label":"Refunded Amount",
"type":"Double",
"value":"0.0"
},
{
"fieldApiName":"Status",
"label":"Status",
"type":"String",
"value":"Unpaid"
},
{
"fieldApiName":"IsDeleted",
"label":"Deleted",
"type":"Boolean",
"value":"false"
},
{
"fieldApiName":"IsPartiallyRefunded",
"label":"Partially Refunded",
"type":"Boolean",
"value":"false"
},
{
"fieldApiName":"CurrentAmount",
"label":"Current Amount",
"type":"Double",
"value":"2.2222222E7"
},
{
"fieldApiName":"AcknowledgementStatus",
"label":"Acknowledgement Status",
"type":"String",
"value":"To Be Sent"
},
{
"fieldApiName":"OriginalAmount",
"label":"Original Amount",
"type":"Double",
"value":"2.2222222E7"
},
{
"fieldApiName":"IsWrittenOff",
"label":"Written Off",
"type":"Boolean",
"value":"false"
},
{
"fieldApiName":"IsFullyRefunded",
"label":"Fully Refunded",
"type":"Boolean",
"value":"false"
},
{
"fieldApiName":"PaymentMethod",


Response Bodies

"label":"Payment Method",
"type":"String",
"value":"Cash"
},
{
"fieldApiName":"IsPaid",
"label":"Paid",
"type":"Boolean",
"value":"false"
}
],
"objectApiName":"GiftTransaction"
},
{
"fields":[
{
"fieldApiName":"GiftCommitmentId",
"label":"Gift Commitment ID",
"type":"String",
"value":"6gcRM0000004CD0YAM"
},
{
"fieldApiName":"Id",
"label":"Gift Transaction ID",
"type":"String",
"value":"6trRM00000000CxYAI"
},
{
"fieldApiName":"Name",
"label":"Name",
"type":"String",
"value":"Tom C3 - Tom C3 GT 6"
},
{
"fieldApiName":"GiftType",
"label":"Gift Type",
"type":"String",
"value":"Individual"
},
{
"fieldApiName":"TransactionDueDate",
"label":"Transaction Due Date",
"type":"DateOnlyWrapper",
"value":"Wed Aug 30 00:00:00 GMT 2023"
},
{
"fieldApiName":"DonorId",
"label":"Donor ID",
"type":"String",
"value":"001RM000005bZRUYA2"
},
{
"fieldApiName":"OwnerId",
"label":"Owner ID",


Response Bodies

"type":"String",
"value":"005RM0000027gL8YAI"
},
{
"fieldApiName":"RefundedAmount",
"label":"Refunded Amount",
"type":"Double",
"value":"0.0"
},
{
"fieldApiName":"Status",
"label":"Status",
"type":"String",
"value":"Unpaid"
},
{
"fieldApiName":"IsDeleted",
"label":"Deleted",
"type":"Boolean",
"value":"false"
},
{
"fieldApiName":"IsPartiallyRefunded",
"label":"Partially Refunded",
"type":"Boolean",
"value":"false"
},
{
"fieldApiName":"CurrentAmount",
"label":"Current Amount",
"type":"Double",
"value":"11111.0"
},
{
"fieldApiName":"AcknowledgementStatus",
"label":"Acknowledgement Status",
"type":"String",
"value":"To Be Sent"
},
{
"fieldApiName":"OriginalAmount",
"label":"Original Amount",
"type":"Double",
"value":"11111.0"
},
{
"fieldApiName":"IsWrittenOff",
"label":"Written Off",
"type":"Boolean",
"value":"false"
},
{
"fieldApiName":"IsFullyRefunded",
"label":"Fully Refunded",


Response Bodies

"type":"Boolean",
"value":"false"
},
{
"fieldApiName":"PaymentMethod",
"label":"Payment Method",
"type":"String",
"value":"Cash"
},
{
"fieldApiName":"IsPaid",
"label":"Paid",
"type":"Boolean",
"value":"false"
}
],
"objectApiName":"GiftTransaction"
}
]
}

Property Name

Type

giftTransactions Standard Object

Details[]

Description

Filter Group and
Version

List of gift transactions associated with a gift Small, 59.0
commitment.

Gift Transactions Output
Output representation of the gift transactions associated with a gift commitment record.

JSON examples
Here's an example of a list of future gift transactions.
{
"giftTransactions":[
{
"amount":9999,
"commitmentId":"6gcxx000004WhULAA0",
"commitmentScheduleId":"6csxx000004WhULAA0",
"paymentMethod":"Cash",
"transactionDate":"2023-09-01T00:00:00.000Z"
},
{
"amount":2099,
"commitmentId":"6gcxx000004WhULAA0",
"commitmentScheduleId":"6csxx000004UhUMAB0",
"paymentMethod":"Cash",
"transactionDate":"2023-10-01T00:00:00.000Z"
}
]
}


Available Version
59.0

Response Bodies

Here's an example of a list of past gift transactions.
{
"giftTransactions":[
{
"amount":9999,
"commitmentId":"6gcxx000004WhULAA0",
"commitmentScheduleId":"6csxx000004WhULAA0",
"paymentMethod":"Cash",
"status":"Canceled"
},
{
"amount":2099,
"commitmentId":"6gcxx000004WhULAA0",
"commitmentScheduleId":"6csxx000004UhUMAB0",
"paymentMethod":"Cash",
"status":"Canceled"
}
]
}

Property Name

Type

Description

Filter Group and
Version

gift
Transactions

Gift Transaction
Record Output[]

List of gift transactions associated with a gift Small, 59.0
commitment record.

Gift Transaction Linked Designations Output
Output representation of a list of gift designations.

JSON example
{
"transactionLinkedDesignations":[
{
"amount":100,
"designationId":"6gdRM000000000LYAQ",
"percent":100
},
{
"amount":100,
"designationId":"6gcxx000004WhULAA0",
"percent":50
}
]
}


Available Version
59.0

Property Name

Response Bodies

Type

transactionLinkedDesignations Gift Designation

Description

Filter Group and
Version

Available Version

List of designations.

Small, 59.0

59.0

Record Output[]

Gift Transaction Record Output
Output representation of a gift transaction record.
Property Name

Type

Description

Filter Group and
Version

Available Version

amount

Double

Transaction amount.

Small, 59.0

59.0

commitmentId

String

ID of the gift commitment record.

Small, 59.0

59.0

commitment
ScheduleId

String

ID of the gift commitment schedule record. Small, 59.0

59.0

Mode of payment for the transaction.

Small, 59.0

59.0

Status of the transaction.

Small, 59.0

59.0

Small, 59.0

59.0

paymentMethod String
status

String

This field is not applicable for future
transactions.
transaction
Date

String

Payment due date.
This field is applicable only for future
transactions.

Gift Designation Record Output
Output representation of a gift designation record.
Property Name

Type

Description

Filter Group and
Version

Available Version

amount

Double

Amount value of the designation record.

Small, 59.0

59.0

ID of the designation record.

Small, 59.0

59.0

Percentage value of the designation record. Small, 59.0

59.0

designationId String
percent

Double

Link Details
Output representation of the link details for the response object.


Response Bodies

Sample Response
{
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}

Property Name

Type

Description

Filter Group and
Version

Available Version

href

String

Object link that provides the direct access
to the resource.

Small, 60.0

60.0

id

String

Salesforce ID of the linked resource.

Small, 60.0

60.0

Transaction Payment Updates
Output representation of the transaction payment updates.

Sample Response
{
"successes": 0,
"failures": 0,
"notProcessed": 0,
"details": [
{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}
]
}

Property Name

Type

details

failures

Description

Filter Group and
Version

Available Version

Transaction Payment Payment update response of the
Updates Response[] transaction.

Small, 60.0

60.0

Integer

Small, 60.0

60.0

Number of gift transactions that failed to
update.


Response Bodies

Property Name

Type

Description

Filter Group and
Version

Available Version

notProcessed

Integer

Number of gift transactions that weren't
processed.

Small, 60.0

60.0

successes

Integer

Number of gift transactions that were
updated.

Small, 60.0

60.0

Transaction Payment Updates Response
Output representation of the updates for the transaction payment.

Sample Response
{
"details": [
{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}
]
}

Property Name

Type

Description

Filter Group and
Version

Available Version

errors

Error Details[]

Error message if a process failed.

Small, 60.0

60.0

links

Transaction Payment Links to the response object.
Updates Response
Link

Small, 60.0

60.0

success

Boolean

Indicates whether a request was processed Small, 60.0
successfully (true) or not (false).

60.0

Transaction Payment Updates Response Link
Output representation of the links to the response object for the transaction payment updates.


Response Bodies

Sample Response
{
"gifttransaction": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}

Property Name

Type

Description

Filter Group and
Version

Available Version

gift
transaction

Link Details

Link to the gift transaction details.

Small, 60.0

60.0

Update Commitment
Output representation of the update commitment request that contains the status, errors if any, and the links to objects after you update
a gift commitment.

Sample Response
{
"success": true,
"errors": [
{
"field": "string",
"message": "string"
}
],
"links": {
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftcommitmentschedule": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}
}

Property Name

Type

Description

Filter Group and
Version

Available Version

errors

Error Details[]

Error message if the process failed.

Small, 60.0

60.0

links

Update
Commitment
Response Link

Links to the response object.

Small, 60.0

60.0


Fundraising Invocable Actions

Property Name

Type

Description

Filter Group and
Version

Available Version

success

Boolean

Indicates whether the request was
processed successfully (true) or not
(false).

Small, 60.0

60.0

Update Commitment Response Link
Output representation of the links to the response object for the commitment updates.

Sample Response
{
"giftcommitment": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
},
"giftcommitmentschedule": {
"href": "/services/data/vXX.X/sobjects/sObject/...",
"id": "string"
}
}

Property Name

Type

Description

Filter Group and
Version

Available Version

gift
commitment

Link Details

Link to the updated gift commitment
details.

Small, 60.0

60.0

Link to the schedule associated with the
updated gift commitment.

Small, 60.0

60.0

giftcommitment Link Details
schedule

Fundraising Invocable Actions
Use actions to add more functionality to your applications. Choose from standard actions, such as processing gift entries, update processed
gift entries, manage gift default designations, and manage gift transaction designations.
To know more about invocable actions, see Actions Developer Guide and REST API Developer Guide.
Close Gift Commitment Action
Updates the status of a gift commitment to closed and updates the status for each of its unpaid and failed gift transactions.
Manage Custom Gift Commitment Schedules Action
Creates or updates up to 15 custom gift commitment schedule records and their associated gift transaction records.
Manage Gift Default Designations Action
Creates and manages Gift Default Designation records for a gift entry associated with a campaign, opportunity, or gift commitment.


Close Gift Commitment Action

Manage Gift Transaction Designations Action
Creates and manages Gift Transaction Designation records for a gift transaction.
Manage Recurring Gift Commitment Schedule Action
Creates or updates a recurring type of gift commitment schedule record and creates the first upcoming gift commitment transaction
record.
Process Gift Entries Action
Processes, singly or as part of a batch, a specified gift entry ID, creating related donor, gift transaction, gift transaction designation,
and gift soft credit records. You may also test gift entry processing to check for errors before creating related records.
Pause Gift Commitment Schedule Action
Pauses a gift commitment schedule for a specified period of time.
Process Gift Commitment Action
Updates the status and other relevant fields for a gift commitment based on the statuses of the associated gift transactions and the
current gift commitment schedule.
Resume Gift Commitment Schedule Action
Resumes a paused gift commitment schedule on a specified date.
Update Processed Gift Entries Action
Updates the status of a specified gift entry record that is already processed. If the processing fails, the failure reason is updated.

Close Gift Commitment Action
Updates the status of a gift commitment to closed and updates the status for each of its unpaid and failed gift transactions.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/closeGiftCommitment
Formats: JSON
HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

Description

giftCommitmentId

String

Required. The ID of the gift commitment record to be closed.

Outputs
None.


Manage Custom Gift Commitment Schedules Action

Example
Here's a request for the Close Gift Commitment action.
{
"inputs": [
{
"giftCommitmentId": "6gcNA000000YshCYAS"
}
]
}

Here's a response for the Close Gift Commitment action.
[
{
"actionName": "closeGiftCommitment",
"errors": null,
"isSuccess": true,
"outputValues": null,
"version": 1
}
]

Manage Custom Gift Commitment Schedules Action
Creates or updates up to 15 custom gift commitment schedule records and their associated gift transaction records.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/manageCustomGiftCmtSchds
Formats: JSON
HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

giftCommitmentSchedules sObject

Description
Required. A collection of gift commitment schedule records to be created or updated.

Outputs
Input

Type

giftCommitmentScheduleList String

Description
A comma-delimited list of gift commitment schedule IDs records that the action created
or updated.


Manage Gift Default Designations Action

Example
Here's a request for the Manage Custom Gift Commitment Schedules action.
{
"inputs": [
{
"giftCommitmentSchedules": [
{
"StartDate": "2023-08-26",
"PaymentMethod": "Check",
"Id": "6csNA000000hbx8YAA",
"EndDate": "2023-08-28"
},
{
"StartDate": "2023-08-29",
"PaymentMethod": "Check",
"Id": "6csNA000000hby4YAA",
"EndDate": "2023-08-30"
}
]
}
]
}

Here's a response for the Manage Custom Gift Commitment Schedules action.
[
{
"actionName": "manageCustomGiftCmtSchds",
"errors": null,
"isSuccess": true,
"outputValues": {
"giftCommitmentScheduleIdsList": [
"6csNA000000hbx8YAA",
"6csNA000000hby4YAA"
]
},
"version": 1
}
]

Manage Gift Default Designations Action
Creates and manages Gift Default Designation records for a gift entry associated with a campaign, opportunity, or gift commitment.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/manageGiftDefaultDesignations
Formats: JSON, XML


Manage Gift Transaction Designations Action

HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

giftDefaultDesignationIds sObject

parentRecordId

ID

Description
Required. A collection of Gift Default Designation record IDs that are to be modified or
deleted.
Required. The ID of the parent record like a campaign, opportunity, or gift commitment
associated with the gift default designation IDs in giftDefaultDesignationIds.

Outputs
None.

Example
Here's a request for the Manage Gift Default Designations action.
{
"inputs": [
{
"giftDefaultDesignationIds": [
{
"GiftDesignationId": "6gdRM0000004CD0YAM",
"AllocatedPercentage": 100
}
]
}
],
"parentRecordId": "6gcRM00000001UNYAY"
}

Here's a response for the Manage Gift Default Designations action.
[
{
"actionName": "manageGiftDefaultDesignations",
"errors": null,
"isSuccess": true,
"outputValues": null,
"version": 1
}
]

Manage Gift Transaction Designations Action
Creates and manages Gift Transaction Designation records for a gift transaction.


Manage Gift Transaction Designations Action

This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/manageGiftTrxnDesignations
Formats: JSON, XML
HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

giftTransactionDesignations sObject

recordId

ID

Description
Required. A collection of Gift Transaction Designation record IDs that are to be modified or
deleted.
Required. The record for which the Gift Transaction Designation record is created. For
example, Gift Transaction.

Outputs
None.

Example
Here's a request for the Manage Gift Transaction Designations action.
{
"inputs": [
{
"giftTransactionDesignations": [
{
"GiftDesignationId": "6gdRM0000004CDAYA2",
"Percent": 100,
"Amount": 76
}
]
}
],
"recordId": "6trRM00000003PJYAY"
}

Here's a response for the Manage Gift Transaction Designations action.
[
{
"actionName": "manageGiftTrxnDesignations",
"errors": null,
"isSuccess": true,


Manage Recurring Gift Commitment Schedule Action

"outputValues": null,
"version": 1
}
]

Manage Recurring Gift Commitment Schedule Action
Creates or updates a recurring type of gift commitment schedule record and creates the first upcoming gift commitment transaction
record.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/manageRcrGiftCmtSchd
Formats: JSON, XML
HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

Description

effectiveFromDate

Date

The date from when the updates to the gift commitment schedule are effective. Only
applicable in a schedule update scenario.

effectiveToDate

Date

The date until when the updates to the gift commitment schedule are effective. Only
applicable in a schedule update scenario.

giftCommitment
Schedule

sObject

Required. The gift commitment schedule record to be created or updated.

PaymentInstrument

sObject

Required. The payment instrument record to be created or updated.

Input

Type

Description

giftCommitment
ScheduleIdsList

Date

A comma-delimited list of gift commitment schedule IDs for schedules that were created
or updated.

Outputs

Example
Here's a request for the Manage Recurring Gift Commitment Schedule action.
{
"inputs": [


Process Gift Entries Action

{
"giftCommitmentSchedules": [
{
"StartDate": "2023-08-26",
"PaymentMethod": "Check",
"Id": "6csNA000000hbx8YAA",
"EndDate": "2023-08-28"
},
{
"StartDate": "2023-08-29",
"PaymentMethod": "Check",
"Id": "6csNA000000hby4YAA",
"EndDate": "2023-08-30"
}
],
"paymentInstrument": {
"Last4": "1234",
"Type": "Credit Card",
"ExpiryMonth": "May",
"ExpiryYear": "29"
}
}
]
}

Here's a response for the Manage Recurring Gift Commitment Schedule action.
[
{
"actionName": "manageRcrGiftCmtSchd",
"errors": null,
"isSuccess": true,
"outputValues": {
"giftCommitmentScheduleIdsList": [
"6csNA000000hbx8YAA",
"6csNA000000hby4YAA"
]
},
"version": 1
}
]

Process Gift Entries Action
Processes, singly or as part of a batch, a specified gift entry ID, creating related donor, gift transaction, gift transaction designation, and
gift soft credit records. You may also test gift entry processing to check for errors before creating related records.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/processGiftEntries


Process Gift Entries Action

Formats: JSON, XML
HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

Description

giftEntryId

ID

Required. The ID of the gift entry record to be processed.

isDryRun

Boolean

Indicates whether to run the action without creating or updating records to determine if
there are any errors (true) or actual processing (false). The default value is false.

Output

Type

Description

donorId

ID

The ID of the person, household, or organization account that's associated with the gift
entry.

giftEntryId

ID

The ID of the gift entry record that is processed.

Outputs

giftProcessingErrorDetails String

The error details when the gift processing status is Failure.

giftProcessingStatus String

The processing status of the gift entry. Valid values are Failure, New, or Success.

giftTransactionId

ID

The ID of the gift transaction that's associated with the gift entry.

Example
Here's a request for the Process Gift Entries action for processing a gift entry.
{
"inputs": [
{
"giftEntryId": "6geRM00000000GdYAI"
}
]
}

Here's a response for the Process Gift Entries action for processing a gift entry.
[
{
"actionName": "processGiftEntries",
"errors": null,
"isSuccess": true,
"outputValues": {
"giftProcessingStatus": "SUCCESS",
"giftEntryId": "6geRM00000000GdYAI",
"giftTransactionId": "6trRM00000003PJ",


Pause Gift Commitment Schedule Action

"giftProcessingErrorDetails": null,
"donorId": "001RM000005ewDDYAY"
},
"version": 1
}
]

Here's a request for the Process Gift Entries action for a dry run of gift entry processing.
{
"inputs": [
{
"giftEntryId": "6geRM00000000GdYAI",
"isDryRun": "true",
}
]
}

Here's a response for the Process Gift Entries action for a dry run of gift entry processing.
[
{
"actionName": "processGiftEntries",
"errors": null,
"isSuccess": true,
"outputValues": {
"giftProcessingStatus": "New",
"giftEntryId": "6geRM00000000GdYAI",
"giftTransactionId": null,
"giftProcessingErrorDetails": null,
"donorId": null
},
"version": 1
}
]

Pause Gift Commitment Schedule Action
Pauses a gift commitment schedule for a specified period of time.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/pauseGiftCommitmentSchedule
Formats: JSON, XML
HTTP Methods: POST
Authentication: Authorization: Bearer token


Pause Gift Commitment Schedule Action

Inputs
Input

Type

Description

endDate

Date

The date to resume the gift commitment schedule.

giftCommitmentScheduleId String

Required. The ID of the gift commitment schedule record to be paused.

startDate

Date

The date to pause the gift commitment schedule.

updateReason

String

The reason the gift commitment schedule is to be paused.

Type

Description

Outputs
Input

giftCommitmentScheduleIdsList String

A comma-delimited list of gift commitment schedule IDs for schedules that were created
or updated.

Example
Here's a request for the Pause Gift Commitment Schedule action.
{
"inputs": [
{
"giftCommitmentScheduleId": "6csNA000000YNbOYAW",
"startDate": "2023-08-25"
}
]
}

Here's a response for the Pause Gift Commitment Schedule action.
[
{
"actionName": "pauseGiftCommitmentSchedule",
"errors": null,
"isSuccess": true,
"outputValues": {
"giftCommitmentScheduleIdsList": [
"6csNA000000YNbOYAW",
"6csNA000000hbxuYAA"
]
},
"version": 1
}
]


Process Gift Commitment Action

Process Gift Commitment Action
Updates the status and other relevant fields for a gift commitment based on the statuses of the associated gift transactions and the
current gift commitment schedule.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/processGiftCommitment
Formats: JSON, XML
HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

Description

giftCommitmentId

String

Required. The ID of the gift commitment record to be processed.

Type

Description

Outputs
Input

giftCommitmentProcessingStatus String

The status of the gift commitment record after it is processed.

Example
Here's a request for the Process Gift Commitment action.
{
"inputs": [
{
"giftCommitmentId": "6gcNA000000PeKhYAK"
}
]
}

Here's a response for the Process Gift Commitment action.
[
{
"actionName": "processGiftCommitment",
"errors": null,
"isSuccess": true,
"outputValues": null,
"version": 1


Resume Gift Commitment Schedule Action

}
]

Resume Gift Commitment Schedule Action
Resumes a paused gift commitment schedule on a specified date.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/resumeGiftCommitmentSchedule
Formats: JSON, XML
HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

giftCommitmentScheduleId String

Description
Required. The ID of the gift commitment schedule record to be resumed.

resumeDate

Date

The date to resume the gift commitment schedule.

updateReason

String

The reason the gift commitment schedule is to be resumed.

Type

Description

Outputs
Input

giftCommitmentScheduleIdsList String

A comma-delimited list of gift commitment schedule IDs for schedules that were created
or updated.

Example
Here's a request for the Resume Gift Commitment Schedule action.
{
"inputs": [
{
"giftCommitmentScheduleId": "6csNA000000hbxpYAA",
"resumeDate": "2023-08-27"
"updateReason": "Test"
}
]
}


Update Processed Gift Entries Action

Here's a response for the Resume Gift Commitment Schedule action.
[
{
"actionName": "resumeGiftCommitmentSchedule",
"errors": null,
"isSuccess": true,
"outputValues": {
"giftCommitmentScheduleIdsList": [
"6csNA000000hbxpYAA"
]
},
"version": 1
}
]

Update Processed Gift Entries Action
Updates the status of a specified gift entry record that is already processed. If the processing fails, the failure reason is updated.
This action is available in API version 59.0 and later for users in orgs where the Fundraising Access license is enabled and the Fundraising
User system permission is assigned.

Supported REST HTTP Methods
URI: /services/data/vXX.X/actions/standard/updateProcessedGiftEntries
Formats: JSON, XML
HTTP Methods: POST
Authentication: Authorization: Bearer token

Inputs
Input

Type

Description

donorId

ID

The ID of the account of the donor that is updated when giftProcessingStatus
is Success.

giftEntryId

ID

Required. The ID of the gift entry record to be updated.

giftProcessingErrorDetails String

The error details when giftProcessingStatus is Failure.

giftProcessingStatus String

The processing status of the gift entry. Valid values are Failure, New, or Success.

giftTransactionId

ID

The ID of the gift transaction record associated with the gift entry that is to be updated
when giftProcessingStatus is Success.


Fundraising Metadata API Types

Outputs
Field

Type

Description

giftEntryId

ID

The ID of the gift entry record that is updated.

Example
Here's a request for the Update Processed Gift Entries action.
{
"inputs": [
{
"donorId": "001RM000005ewDDYAY",
"giftEntryId": "6geRM00000000GdYAI",
"giftProcessingErrorDetails": null,
"giftProcessingStatus": "SUCCESS",
"giftTransactionId": "6trRM00000003PJ"
}
]
}

Here's a response for the Update Processed Gift Entries action.
[
{
"actionName": "updateProcessedGiftEntries",
"errors": null,
"isSuccess": true,
"outputValues": {
"giftEntryId": "6geRM00000000GdYAI"
},
"version": 1
}
]

Fundraising Metadata API Types
Metadata API enables you to access some types and feature settings that you can customize in the user interface.
For more information about Metadata API and to find a complete reference of existing metadata types, see Metadata API Developer
Guide.
AffinityScoreDefinition
Represents the affinity information used in calculations to analyze and categorize contacts for marketing purposes.
Flow for Fundraising
Represents the metadata associated with a flow. With Flow, you can create an application that navigates users through a series of
screens to query and update records in the database. You can also execute logic and provide branching capability based on user
input to build dynamic applications.


Represents the affinity information used in calculations to analyze and categorize contacts for marketing purposes.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Parent Type
This type extends the Metadata metadata type and inherits its fullName field.

File Suffix and Directory Location
AffinityScoreDefinition components have the suffix .affinityScoreDefinition and are stored in the
affinityScoreDefinitions folder.

Version
AffinityScoreDefinition components are available in API version 66.0 and later.

Special Access Rules
This metadata type is available only if the Fundraising Access license is enabled for the org and the Fundraising admin permission is
assigned to users.

Fields
Field Name

Field Type

Description

affinityScoreDefinitionDesc string

Description of the affinity score definition.

affinityScoreDefinitionName string

Name of the affinity score definition.

affinityScoreType

AffinityScoreType Type of the affinity score that's defined. Valid values are CAP—Capacity,
(enumeration Ability, Propensity (CAP), or RFM—Recency, Frequency, Monetary (RFM).
of type string) The default value is RFM.

masterLabel

string

Label for this affinity score definition value. This display value is the internal
label that doesn't get translated.

numberOfMonths

int

Number of months to analyze the records for calculating the affinity score.

numberOfRanges

int

Required. Number of ranges to use in the calculation, ranging from 0 to
9. Provide the corresponding range list values in the scoreRangeList
field.

scoreRangeList

string

Required. Ranges that are referenced in the affinity score calculation. This
field is used with scoreRangeList. For example, to calculate RFM
with numberOfRanges value as 3, provide the values for the
scoreRangeList field.


Field Name

Field Type

Description

sourceFieldApiNameList

string

Required. API names of the source fields that are referenced in the score
calculation.

sourceObjectApiNameList

string

API names of the source objects that are referenced in the score calculation.

targetFieldApiNameList

string

Required. API names of the target fields where the calculated scores are
added.

targetObjectApiName

string

API name of the target object where the calculated scores are added.

Example scoreRangeList format:
{
"R ranges":"0-30, 31-100, 100+",
"F ranges":"0-10, 11-100, 100+",
"M ranges":"0-1000, 1001-5000, 5000+"
}

Declarative Metadata Sample Definition
This example shows a sample of an AffinityScoreDefinition component.
<?xml version="1.0" encoding="UTF-8"?>
<AffinityScoreDefinition
xmlns="http://soap.sforce.com/2006/04/metadata">
<affinityScoreDefinitionDesc>RFM Affinity Score</affinityScoreDefinitionDesc>
<affinityScoreDefinitionName>AffinityScoreDefinition_RFM</affinityScoreDefinitionName>
<affinityScoreType>RFM</affinityScoreType>
<masterLabel>MasterLabel</masterLabel>
<numberOfMonths>12</numberOfMonths>
<numberOfRanges>3</numberOfRanges>
<scoreRangeList>
[
{
"name": "R Ranges",
"direction": "ascending",
"ranges": [30,90,180]
},
{
"name": "F Ranges",
"direction": "descending",
"ranges": [10,15,100]
},
{
"name": "M Ranges",
"direction": "descending",
"ranges": [500,1000,5000]
}
]
</scoreRangeList>
<sourceFieldApiNameList>


[
{
"name": "R Source",
"values":
[
{
"fieldName": "DonorGiftSummary.DaysSinceLastGift",
"fieldWeight": 1
}
]
},
{
"name": "F Source",
"values":
[
{
"fieldName": "DonorGiftSummary.GiftCount",
"fieldWeight": 1
}
]
},
{
"name": "M Source",
"values":
[
{
"fieldName": "DonorGiftSummary.TotalGiftsCount",
"fieldWeight": 1
}
]
}
]
</sourceFieldApiNameList>
<targetFieldApiNameList>
[
{
"name": "R Target",
"values":
[
{
"fieldName": "DonorGiftSummary.RecencyScore",
"fieldWeight": 1
}
]
},
{
"name": "F Target",
"values":
[
{
"fieldName": "DonorGiftSummary.FrequencyScore",
"fieldWeight": 1
}
]


Flow for Fundraising

},
{
"name": "M Target",
"values":
[
{
"fieldName": "DonorGiftSummary.MonetaryScore",
"fieldWeight": 1
}
]
}
]
</targetFieldApiNameList>
</AffinityScoreDefinition>

This example shows a sample of the package.xml file that references the previous definition.
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
<types>
<members>*</members>
<name>AffinityScoreDefinition</name>
</types>
<version>66.0</version>
</Package>

Wildcard Support in the Manifest File
This metadata type supports the wildcard character * (asterisk) in the package.xml manifest file. For information about using the
manifest file, see Deploying and Retrieving Metadata with the Zip File.

Flow for Fundraising
Represents the metadata associated with a flow. With Flow, you can create an application that navigates users through a series of screens
to query and update records in the database. You can also execute logic and provide branching capability based on user input to build
dynamic applications.

FlowActionCall
Fundraising exposes additional actionType values for the FlowActionCall Metadata type. For more information on Flow and FlowActionCall
metadata type, see Flow.
Field Name

Field Type

Description

actionType

InvocableActionType Required. The action type. Additional valid values only for Business Rules
(enumeration of
Engine include:
type string)
• closeGiftCommitment—Updates the status of a gift
commitment to closed and updates the status for each of its unpaid
and failed gift transactions. This value is available in API version 59.0
and later.


Field Name

Fundraising Tooling API Objects

Field Type

Description
• manageCustomGiftCmtSchds—Creates or updates up to
15 custom gift commitment schedule records and their associated
gift transaction records. This value is available in API version 59.0 and
later.
• manageFundraisingDefinitions—Runs up to three
predefined Data Processing Engine (DPE) definitions in a single
action. Use this invocable action to process the Donor Gift Summary,
Outreach Summary, and Gift Designation definitions. This value is
available in API version 64.0 and later.
• manageGiftDefaultDesignations—Creates and manages
Gift Default Designation records for a gift entry associated with a
campaign, opportunity, or gift commitment. This value is available
in API version 59.0 and later.
• manageGiftTrxnDesignations—Creates and manages
Gift Transaction Designation records for a gift transaction. This value
is available in API version 59.0 and later.
• manageRcrGiftCmtSchd—Creates or updates a recurring
type of gift commitment schedule record and creates the first
upcoming gift commitment transaction record. This value is available
in API version 59.0 and later.
• processGiftEntries—Processes, singly or as part of a batch,
a specified gift entry ID, creating related donor, gift transaction, gift
transaction designation, and gift soft credit records. This value is
available in API version 59.0 and later.
• pauseGiftCommitmentSchedule—Pauses a gift
commitment schedule for a specified period of time. This value is
available in API version 59.0 and later.
• processGiftCommitment—Updates the status and other
relevant fields for a gift commitment based on the statuses of the
associated gift transactions and the current gift commitment
schedule. This value is available in API version 59.0 and later.
• resumeGiftCommitmentSchedule—Resumes a paused
gift commitment schedule on a specified date. This value is available
in API version 59.0 and later.
• updateProcessedGiftEntries—Updates the status of a
specified gift entry record that is already processed. If the processing
fails, the failure reason is updated. This value is available in API version
59.0 and later.

Fundraising Tooling API Objects
Tooling API exposes metadata used in developer tooling that you can access through REST or SOAP. Tooling API’s SOQL capabilities for
many metadata types allow you to retrieve smaller pieces of metadata.


For more information about Tooling API objects and to find a complete reference of all the supported objects, see Introducing Tooling
API.
FundraisingConfig
Represents a collection of settings to configure Fundraising. This object is available in API version 59.0 and later.
FieldMappingConfig
Represents the configuration for fields mapped between a source object and one or more destination objects and fields. This object
is available in API version 63.0 and later.
FieldMappingConfigItem
Represents the fields mapped between a defined source object and the destination object and fields. This object is available in API
version 63.0 and later.
GiftEntryGridTemplate
Represents templates that customize the gift entry grid in Fundraising. Available in API version 66.0 and later.

FundraisingConfig
Represents a collection of settings to configure Fundraising. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported SOAP API Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Supported REST API Methods
DELETE, GET, HEAD, PATCH, POST, Query

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

DeveloperName

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
The unqiue name for FundraisingConfig.


DonorExternalIdField

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The field that's used as the external ID for donor lookup during gift entry. Donor name is the
default lookup. This field is available from API version 62.0 and later.

DonorMatchingMethod

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the donor matching method that's used as the default method for the Business
Process API.
Possible values are:
• Duplicate_Management_Rules—Duplicate Management Rules
• No_Matching—No Matching
The default value is Duplicate_Management_Rules.

FailedTransactionCount

Type
int
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The count of consecutively failed transactions before the gift commitment status is changed
to Failing. If set to 0, the status is never auto-changed to Failing.

HouseholdSoftCreditRole Type

string
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The soft credit role that's assigned to members of the donor's household.
InstallmentExtDayCount

Type
int
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update


Description
The number of days before or after the scheduled gift transaction due date for the gift to
appear in Gift Entry as a match to fulfill an open gift transaction.

IsHshldSoftCrAutoCrea

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether soft credits are automatically created for household members (true) or
not (false) when the donor donates.

IsNextGenCmtPrcsParallel Type

boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Indicates whether NextGen Commitment Processing runs batch jobs in parallel (true, the
default) or not (false).
Available in API version 67.0 and later.
Language

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The language of the FundraisingConfig
Possible values are:
• da—Danish
• de—German
• en_US—English
• es—Spanish
• es_MX—Spanish (Mexico)
• fi—Finnish
• fr—French
• it—Italian
• ja—Japanese
• ko—Korean
• nl_NL—Dutch
• no—Norwegian


• pt_BR—Portuguese (Brazil)
• ru—Russian
• sv—Swedish
• th—Thai
• zh_CN—Chinese (Simplified)
• zh_TW—Chinese (Traditional)

LapsedUnpaidTrxnCount

Type
int
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The count of consecutive unpaid transactions before the gift commitment status is changed
to Lapsed. If set to 0, the status is never auto-changed to Lapsed.

MasterLabel

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
Label for the FundraisingConfig. In the UI, this field is Application Record Type Configuration.

NamespacePrefix

Type
string
Properties
Filter, Group, Nillable, Sort
Description
The namespace prefix associated with this object. Each Developer Edition organization that
creates a managed package has a unique namespace prefix. Limit: 15 characters. You can
refer to a component in a managed package by using the
namespacePrefix__componentName notation.
The namespace prefix can have one of the following values:
• In Developer Edition organizations, the namespace prefix is set to the namespace prefix
of the organization for all objects that support it. There is an exception if an object is in
an installed managed package. In that case, the object has the namespace prefix of the
installed managed package. This field’s value is the namespace prefix of the Developer
Edition organization of the package developer.
• In organizations that are not Developer Edition organizations, NamespacePrefix
is only set for objects that are part of an installed managed package. There is no
namespace prefix for all other objects.


NextGenCmtPrcsBatchSize Type

int
Properties
Defaulted on create, Filter, Group, Nillable, Sort
Description
The maximum batch size that NextGen Commitment Processing can run.
Available in API version 67.0 and later.
NextGenCmtPrcsMaxThreads Type

int
Properties
Defaulted on create, Filter, Group, Nillable, Sort
Description
The maximum number of parallel threads that NextGen Commitment Processing can run.
Available in API version 67.0 and later.
OutreachSourceCodeGenFmla Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outreach source code generation formula that's composed of the selected formula
components.
Available in API version 63.0 and later.
ShouldClosePaidRcrCmt

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether to automatically close a recurring gift commitment when it has no ongoing
or future schedule, and no unpaid transaction (true) or not (false).

ShouldCreateRcrSchdTrxn Type

boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the next transaction in a recurring schedule is automatically created
(true) or not (false).


UtmCampaignSrcObj

Type
string
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The UTM code of the campaign for which the donation was received. This field is available
from API version 60.0 and later.

UtmCampaignSrcObjField

Type
string
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The UTM code of the campaign for which the donation was received. This field is available
from API version 60.0 and later.

UtmMediumSrcObj

Type
string
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The UTM code of the outreach message channel from which the donation originated. This
field is available from API version 60.0 and later.

UtmMediumSrcObjField

Type
string
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The UTM code of the outreach message channel from which the donation originated. This
field is available from API version 60.0 and later.

UtmSourceSrcObj

Type
string
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The UTM code of the source from which the donation originated. This field is available from
API version 60.0 and later.

UtmSourceSrcObjField

Type
string


Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The UTM code of the source from which the donation originated. This field is available from
API version 60.0 and later.

FieldMappingConfig
Represents the configuration for fields mapped between a source object and one or more destination objects and fields. This object is
available in API version 63.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

Description

Type
textarea
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The description of the field mapping configuration.

DeveloperName

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
The unqiue name for FieldMappingConfig.

Language

Type
picklist


Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The language of the FieldMappingConfig.
Possible values are:
• da—Danish
• de—German
• en_US—English
• es—Spanish
• es_MX—Spanish (Mexico)
• fi—Finnish
• fr—French
• it—Italian
• ja—Japanese
• ko—Korean
• nl_NL—Dutch
• no—Norwegian
• pt_BR—Portuguese (Brazil)
• ru—Russian
• sv—Swedish
• th—Thai
• zh_CN—Chinese (Simplified)
• zh_TW—Chinese (Traditional)

MasterLabel

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
Label for the FieldMappingConfig.

NamespacePrefix

Type
string
Properties
Filter, Group, Nillable, Sort
Description
The namespace prefix associated with this object. Each Developer Edition organization that
creates a managed package has a unique namespace prefix. Limit: 15 characters. You can
refer to a component in a managed package by using the
namespacePrefix__componentName notation.


The namespace prefix can have one of the following values:
• In Developer Edition organizations, the namespace prefix is set to the namespace prefix
of the organization for all objects that support it. There is an exception if an object is in
an installed managed package. In that case, the object has the namespace prefix of the
installed managed package. This field’s value is the namespace prefix of the Developer
Edition organization of the package developer.
• In organizations that are not Developer Edition organizations, NamespacePrefix
is only set for objects that are part of an installed managed package. There is no
namespace prefix for all other objects.

ProcessType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of process that the field mapping configuration supports.
Possible values are:
• ChangeRequest
• GiftEntry
• Incident
• Problem
The default value is GiftEntry.

SourceObjectId

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The ID of the source object for all of the fields mapped in the configuration.
Possible values are:
• GiftEntry

FieldMappingConfigItem
Represents the fields mapped between a defined source object and the destination object and fields. This object is available in API
version 63.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.


Supported Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Special Access Rules
This object is available only if the Fundraising Access license is enabled and the Fundraising User system permission is assigned to users.

Fields
Field

Details

DestinationFieldId

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The ID of the destination field for the field mapping configuration.

DestinationObjectId

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The ID of the destination object for the field mapping configuration.

FieldMappingConfigId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The parent field mapping configuration associated with the field mapping configuration
item.
This field is a relationship field.
Relationship Name
FieldMappingConfig
Relationship Type
Master-detail
Refers To
FieldMappingConfig (the master object)

Sequence

Type
int


Properties
Create, Filter, Group, Sort, Update
Description
The order number of the field relative to other fields, determining the sequence in which
fields are displayed within a custom user interface.

SourceFieldId

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The ID of the source field for the field mapping configuration.

GiftEntryGridTemplate
Represents templates that customize the gift entry grid in Fundraising. Available in API version 66.0 and later.

Special Access Rules
This object is available only if the Fundraising Access license is enabled, the Fundraising User system permission is assigned to users,
and the Gift Entry Grid is enabled.

Fields
Field

Details

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description of the gift entry grid template.

IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether this template is active and available for use in the Gift Entry Grid. Active
templates appear as values in the Screen Template Name picklist on the gift batch object.


IsSingleGiftDefault

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the template is the default template for single gift entry (true) or not (false,
the default).

TemplateConfiguration

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
The template configuration file that includes the data for fields, columns, and components.


# Chapter 4: Program Management

In this chapter ...
•

Program
Management
Standard Objects

•

Program
Management
Business APIs

Program Management
This guide provides information about the objects and APIs that
Program Management uses. You can also find developer resources
for features that can be used to extend Program Management.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise and
Unlimited Editions.


Program Management Standard Objects

Program Management Standard Objects
Program Management data model provides objects and fields to manage programs and benefits
for your nonprofit organization.
Benefit
Represents information about benefits associated with a program. This object is available with
Program Management in API version 57.0 and later.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise and
Unlimited Editions.

BenefitAssignment
Represents the enrollment information of an individual to a benefit. This object is available with
Program Management in API version 57.0 and later.
BenefitDisbursement
Represents the allocation of an enrollee's benefit that can be made as monetary or non-monetary with different frequencies. This
object is available with Program Management in API version 57.0 and later.
BenefitSchedule
Represents information about the plan for delivering the benefit. This object is available in API version 57.0 and later.
BenefitScheduleAssignment
Represents the junction between Benefit Schedule and Benefit Assignment objects. This object is available in API version 59.0 and
later.
BenefitSession
Represents information about an instance of a planned benefit delivery This object is available in API version 57.0 and later.
BenefitType
Represents the type of benefit being delivered. Use benefit types in conjunction with units of measure to report on how many or
how much of a type of benefit your organization delivers across programs. This object is available with Program Management in API
version 57.0 and later.
CaseProgram
Represents the junction between Case and Program objects. This object is available in API version 57.0 and later.
Program
Represents information about the enrollment and disbursement of benefits in a program. This object is available in API version 57.0
and later.
ProgramCohort
Represents information about the participants of a program cohort. This object is available in API version 61.0 and later.
ProgramCohortMember
Represents program enrollees that are part of a given cohort. This object is available in API version 61.0 and later.
ProgramEnrollment
Represents details of enrollment for benefits in a program. This object is available in API version 57.0 and later.
RecurrenceSchedule
Represents the recurrence schedule for a benefit schedule. This object is available with Program Management in API version 57.0
and later.


Represents information about benefits associated with a program. This object is available with Program Management in API version 57.0
and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

BenefitManagerId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The person in charge of the benefit.
This field is a relationship field.
Relationship Name
BenefitManager
Relationship Type
Lookup
Refers To
User

BenefitStatus

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the benefit.
Possible values are:
• Active
• Cancelled
• Completed
• Planned
The default value is Active.


BenefitTypeId

Type
reference
Properties
Create, Filter, Group, Sort
Description
Specifies the type of the benefit.
This field is a relationship field.
Relationship Name
BenefitType
Relationship Type
Master-Detail
Refers To
BenefitType

BnftDisbFieldSetApiName Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The API name of the field set that groups benefit specific fields for the benefit disbursement
object.
CurrentMonthDisbursedQty Type

double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total quantity of benefits disbursed in the current month. Data Processing Engine
calculates this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.
CurrentYearAssignedQty

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total quantity of benefits assigned in the current year. Data Processing Engine calculates
this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

CurrentYearDisbursedQty Type

double


Properties
Create, Filter, Nillable, Sort, Update
Description
The total quantity of benefits disbursed in the current year. Data Processing Engine calculates
this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

Description

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the benefit.

EndDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The end date until when the benefit is valid.

EnrollmentCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of times the benefit is applicable to an individual.

GoalDefinitionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The goal definition associated with the benefit.
This field is a relationship field.
Relationship Name
GoalDefinition
Relationship Type
Lookup
Refers To
GoalDefinition


IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates if the benefit is active.
The default value is false.

MaximumBenefitAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The maximum amount that can be disbursed for a period.

MinimumBenefitAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The minimum amount that can be disbursed for a period.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the benefit.

PreviousMonthDisbursedQty Type

double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total quantity of benefits disbursed in the previous month. Data Processing Engine
calculates this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.
PreviousYearAssignedQty Type

double


Properties
Create, Filter, Nillable, Sort, Update
Description
The total quantity of benefits assigned in the previous year. Data Processing Engine calculates
this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

PreviousYearDisbursedQty Type

double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total quantity of benefits disbursed in the previous year. Data Processing Engine calculates
this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.
ProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The identifier of the program that's associated with the benefit.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program

StartDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date when the benefit starts.

UnitId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The identifier of the unit of measure that's used to calculate the benefit.
This field is a relationship field.
Relationship Name
Unit
Relationship Type
Lookup
Refers To
UnitOfMeasure

BenefitAssignment
Represents the enrollment information of an individual to a benefit. This object is available with Program Management in API version
57.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

BenefitId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
Name of the benefit that is associated with the assignment.
This field is a relationship field.
Relationship Name
Benefit
Relationship Type
Lookup
Refers To
Benefit

EndDateTime

Type
dateTime


Properties
Create, Filter, Nillable, Sort, Update
Description
The end date up to when the assignment is valid.

EnrolleeId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
Name of the benefit assignee.
This field is a polymorphic relationship field.
Relationship Name
Enrollee
Relationship Type
Lookup
Refers To
Account, Contact

EnrollmentCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of times the benefit is applicable to an individual.

EntitlementAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The benefit amount that an enrollee is eligible for.

MaximumBenefitAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The maximum amount that can be disbursed for a period.


MinimumBenefitAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The minimum amount that can be disbursed for a period.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the benefit assignment.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentRecordId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
Required. The parent record associated with the benefit assignment.
This field is a polymorphic relationship field. Use CarePlan if the benefit is part of a
structured care plan, GoalAssignment if it supports a specific goal,
IndividualApplication if assigned during intake, and ProgramEnrollment
if the participant is only using program management features.
Relationship Name
ParentRecord


Relationship Type
Lookup
Refers To
CarePlan, GoalAssignment, IndividualApplication, ProgramEnrollment

Priority

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the priority of the benefit assignment.
Possible values are:
• High
• Low
• Medium

ProgramEnrollmentId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The identifier of the program enrollment record that's associated with the benefit assignment.
This field is a relationship field.
Relationship Name
ProgramEnrollment
Relationship Type
Lookup
Refers To
ProgramEnrollment

StartDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The start date from when the assignment begins.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
Specifies the status of the benefit assignment.
Possible values are:
• Active
• Completed
• Enrolled
• Waitlisted
• Withdrawn
The default value is Enrolled.

TaskJobStatus

Type
picklist
Properties
Filter, Group, Nillable, Restricted picklist, Sort
Description
Specifies the status of the task in the task queue.
Possible values are:
• Completed
• Failed
• InProgress - In Progress
• Submitted

TaskJobStatusMessage

Type
textarea
Properties
Nillable
Description
The message that describes the status of the task in the queue.

UnitofMeasureId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The identifier of the unit of measure that's used to calculate the benefit type.
This field is a relationship field.
Relationship Name
UnitofMeasure
Relationship Type
Lookup


Refers To
UnitOfMeasure

BenefitDisbursement
Represents the allocation of an enrollee's benefit that can be made as monetary or non-monetary with different frequencies. This object
is available with Program Management in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

ActualCompletionDate

Type
dateTime
Properties
Create, Filter, Sort, Update
Description
The date when the benefit disbursement was completed.

ApprovalStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the disbursement status of the benefit.
Possible values are:
• Approved
• In Review
• Not Applicable
• Pending
• Rejected

BenefitAssignmentId

Type
reference


Properties
Create, Filter, Group, Sort
Description
The benefit assignment that's associated with the disbursement.
This field is a relationship field.
Relationship Name
BenefitAssignment
Relationship Type
Master-Detail
Refers To
BenefitAssignment

BenefitSessionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The benefit session that's associated with the benefit disbursement. This field is accessible
if you enabled Data Protection and Privacy in Setup.
This field is a relationship field.
Relationship Name
BenefitSession
Relationship Type
Lookup
Refers To
BenefitSession

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
A description about the benefit that is disbursed. This field is accessible if you enabled Data
Protection and Privacy in Setup.

DisbursedQuantity

Type
double
Properties
Create, Filter, Nillable, Sort, Update


Description
The quantity of the benefit that's disbursed. This field is accessible if you enabled Data
Protection and Privacy in Setup.

DisbursementStatus

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the benefit disbursement.
Possible values are:
• Absent
• Completed
• Enrolled
• Excused
The default value is Enrolled.
This field is accessible if you enabled Data Protection and Privacy in Setup.

EndDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The end date of the benefit period in every payment cycle.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the benefit disbursement.

ProgramEnrollmentId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program enrollment record that's associated with the benefit disbursement. This field
is accessible if you enabled Data Protection and Privacy in Setup.
This field is a relationship field.


Relationship Name
ProgramEnrollment
Relationship Type
Lookup
Refers To
ProgramEnrollment

RecipientCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The count of recipients who received the benefit. This field is accessible if you enabled Data
Protection and Privacy in Setup.

RecipientId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The participant who receives a benefit.
This field is a polymorphic relationship field.
Relationship Name
Recipient
Relationship Type
Lookup
Refers To
Account, Contact

RecipientType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
Specifies the recipient type of the benefit that's disbursed.
Possible values are:
• Anonymous
• Program Enrollment
• Walk-in
The default value is ProgramEnrollment.


This field is accessible if you enabled Data Protection and Privacy in Setup.

StartDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The start date of the benefit period in every payment cycle.

UnitOfMeasureId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The identifier of the unit of measure that's used to calculate the benefit type. This field is
accessible if you enabled Data Protection and Privacy in Setup.
This field is a relationship field.
Relationship Name
UnitOfMeasure
Relationship Type
Lookup
Refers To
UnitOfMeasure

BenefitSchedule
Represents information about the plan for delivering the benefit. This object is available in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

BenefitId

Type
reference


Properties
Create, Filter, Group, Sort
Description
The identifier of the benefit that's associated with the schedule.
This field is a relationship field.
Relationship Name
Benefit
Relationship Type
Master-Detail
Refers To
Benefit

DefaultBenefitQuantity

Type
double
Properties
Create, Filter, Sort, Update
Description
The default quantity of benefit that's provided within a session of benefit schedule.

Description

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the benefit schedule.

FirstSessionEndDateTime Type

dateTime
Properties
Create, Filter, Sort, Update
Description
The date and time when the first session ends in the benefit schedule.
FirstSessionStartDateTime Type

dateTime
Properties
Create, Filter, Sort, Update
Description
The date and time when the first session begins in the benefit schedule.


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The date when the record was last viewed.

MaximumParticipantCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The maximum number of participants in a session.
Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the benefit schedule.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
BenefitScheduleFeed
Feed tracking is available for the object.
BenefitScheduleHistory
History is available for tracked fields of the object.

BenefitScheduleAssignment
Represents the junction between Benefit Schedule and Benefit Assignment objects. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
Fields
Field

Details

BenefitAssignmentId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The benefit assignment associated with the benefit schedule.
This field is a relationship field.
Relationship Name
BenefitAssignment
Relationship Type
Lookup
Refers To
BenefitAssignment

BenefitScheduleId

Type
reference


Properties
Create, Filter, Group, Sort
Description
The benefit schedule to which benefit participants are being assigned.
This field is a relationship field.
Relationship Name
BenefitSchedule
Relationship Type
Master-Detail
Refers To
BenefitSchedule

EndDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The end date and time of the participant's assignment to the benefit schedule.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the benefit schedule assignment.


StartDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The start date and time of the participant's assignment to the benefit schedule.

BenefitSession
Represents information about an instance of a planned benefit delivery This object is available in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AbsenteesCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of participants who didn't attend the benefit session.
This field is available from API version 65.0 and later.

AttendanceRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of participants who attended the benefit session.
The value of this field is calculated by a formula: (Attendees Count) / (Attendees Count +
Absentees Count)
This field is available from API version 65.0 and later.


AttendeesCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of participants who attended a benefit session.
This field is available from API version 65.0 and later.

BenefitScheduleId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The identifier of the benefit schedule that's associated with the benefit session.
This field is a relationship field.
Relationship Name
BenefitSchedule
Relationship Type
Master-Detail
Refers To
BenefitSchedule

EndDateTime

Type
dateTime
Properties
Create, Filter, Sort, Update
Description
The end date and time of the benefit session.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The date when the record was last viewed.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the benefit session.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the benefit session record owner.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

StartDateTime

Type
dateTime
Properties
Create, Filter, Sort, Update
Description
The start date and time of the benefit session.

Status

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The status of the benefit session.
Possible values are:
• Cancelled
• Completed
• Postponed


• Scheduled

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
BenefitSessionFeed
Feed tracking is available for the object.
BenefitSessionHistory
History is available for tracked fields of the object.

BenefitType
Represents the type of benefit being delivered. Use benefit types in conjunction with units of measure to report on how many or how
much of a type of benefit your organization delivers across programs. This object is available with Program Management in API version
57.0 and later.
Field

Details

Category

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Required. The category of the benefit type. Picklist values aren't provided for this field and
must be added based on the requirements of the organization.

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of benefit type.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the benefit type.


OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ProcessType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Required. The process type associated with the program management benefit type.
Possible value: Program Management

Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of benefit being offered as part of the program.
Possible values are:
• Goods
• Monetary
• Service
The default value is Service.

UnitofMeasureId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The identifier of the unit of measure that's used to calculate the benefit type.


This field is a relationship field.
Relationship Name
UnitofMeasure
Relationship Type
Lookup
Refers To
UnitOfMeasure

CaseProgram
Represents the junction between Case and Program objects. This object is available in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

CaseId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The identifer of the case that’s associated with the program.
This field is a relationship field.
Relationship Name
Case
Relationship Type
Master-Detail
Refers To
Case

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The date when the record was last viewed.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the case program.

ProgramId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The identifier of the program that’s associated with the case.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program

Program
Represents information about the enrollment and disbursement of benefits in a program. This object is available in API version 57.0 and
later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Fields
Field

Details

ActionPlanTemplateId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The action plan template that's associated with the program.
This field is a relationship field.
This field is available from API version 65.0 and later.
Relationship Name
ActionPlanTemplate
Refers To
ActionPlanTemplate

ActiveEnrolleeCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of program enrollees with IsActive on ProgramEnrollment selected. Data
Processing Engine calculates this field if you activate the Program Management Data
Processing Engine Definition templates in Setup. You can schedule this calculation to run
on a regular basis.

AdditionalContext

Type
textarea
Properties
Create, Nillable, Update
Description
The additional context about the program.

CurrentMonthDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed in the current month. Data Processing Engine calculates this
field if you activate the Program Management Data Processing Engine Definition templates
in Setup. You can schedule this calculation to run on a regular basis.


CurrentYearDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed in the current year. Data Processing Engine calculates this
field if you activate the Program Management Data Processing Engine Definition templates
in Setup. You can schedule this calculation to run on a regular basis.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the program ends.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the program.

OwnerId

Type
reference


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The user who owns the object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The associated parent program.
This field is available from API version 59.0 and later.
This field is a relationship field.
Relationship Name
ParentProgram
Relationship Type
Lookup
Refers To
Program

PreviousMonthDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed in the previous month. Data Processing Engine calculates
this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

PreviousYearDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update


Description
The count of benefits disbursed in the previous year. Data Processing Engine calculates this
field if you activate the Program Management Data Processing Engine Definition templates
in Setup. You can schedule this calculation to run on a regular basis.

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the program begins.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the program.
Possible values are:
• Active
• Cancelled
• Completed
• Planned
This field is accessible if you enabled Data Protection and Privacy in Setup.

Summary

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The summary of the program.

TotalEnrolleeCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total count of enrollees in the program. Data Processing Engine calculates this field if
you activate the Program Management Data Processing Engine Definition templates in Setup.
You can schedule this calculation to run on a regular basis.


UsageType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the usage type of the program.
Possible value is ProgramManagement.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ProgramChangeEvent
Change events are available for the object.
ProgramFeed
Feed tracking is available for the object.
ProgramHistory
History is available for tracked fields of the object.
ProgramOwnerSharingRule
Sharing rules are available for the object.
ProgramShare
Sharing is available for the object.

ProgramCohort
Represents information about the participants of a program cohort. This object is available in API version 61.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Advanced Program Management license is enabled, Program Cohorts are enabled, and the Advanced
Program Management system permission is assigned to users.


Fields
Field

Details

CurrentMemberCount

Type
int
Properties
Filter, Group, Nillable, Sort
Description
The number of members that are actively participating in the cohort.
This is a roll-up summary field.

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description of the program cohort.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the program cohort.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

MaximumMemberCount

Type
int


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The maximum number of members that can be active in a cohort. Add custom validation
to enforce this maximum count.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the program cohort.

ProgramId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The program associated with the cohort.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Master-detail
Refers To
Program (the master object)

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the program cohort.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the status of the program cohort.
Possible values are:


• Active
• Canceled
• Completed
• Planned

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ProgramCohortFeed
Feed tracking is available for the object.
ProgramCohortHistory
History is available for tracked fields of the object.

ProgramCohortMember
Represents program enrollees that are part of a given cohort. This object is available in API version 61.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Advanced Program Management license is enabled, Program Cohorts are enabled, and the Advanced
Program Management system permission is assigned to users.

Fields
Field

Details

IsRemovedFromCohort

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates if the program cohort member was removed from the cohort.
The default value is false.


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the program cohort member.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the user who owns the record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ProgramCohortId

Type
reference
Properties
Create, Filter, Group, Sort


Description
The program cohort associated with the program cohort member.
This field is a relationship field.
Relationship Name
ProgramCohort
Relationship Type
Master-detail
Refers To
ProgramCohort (the master object)

ProgramEnrolleeId

Type
reference
Properties
Filter, Group, Nillable, Sort
Description
The account or contact enrolled in the program.
This field is a polymorphic relationship field.
This field is a calculated field.
Relationship Name
ProgramEnrollee
Relationship Type
Lookup
Refers To
Account, Contact

ProgramEnrollmentId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The program enrollment associated with the program cohort member.
This field is a relationship field.
Relationship Name
ProgramEnrollment
Relationship Type
Lookup
Refers To
ProgramEnrollment


ProgramEnrollmentStatus Type

picklist
Properties
Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort
Description
Specifies the status of the program enrollment associated with this cohort member.
This field is a calculated field.
Possible values are:
• Applied
• Completed
• Denied
• In Progress
• Waitlisted
• Withdrawn
The default value is Applied.
RemovalDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the program cohort member was removed from the cohort.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ProgramCohortMemberFeed
Feed tracking is available for the object.
ProgramCohortMemberHistory
History is available for tracked fields of the object.
ProgramCohortMemberOwnerSharingRule
Sharing rules are available for the object.
ProgramCohortMemberShare
Sharing is available for the object.

ProgramEnrollment
Represents details of enrollment for benefits in a program. This object is available in API version 57.0 and later.


Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the account that’s associated with an individual or an organization enrolled in the
program.
This field is a relationship field.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account

ApplicationDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the enrollee applied to the program.

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the contact that’s associated with an individual enrolled in the program.
This field is a relationship field.
Relationship Name
Contact


Relationship Type
Lookup
Refers To
Contact

CurrentMonthDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed to the enrollee in the current month. Data Processing Engine
calculates this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

CurrentYearDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed to the enrollee in the current year. Data Processing Engine
calculates this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

EligibilityLastVerifiedDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the enrollee's program eligibility status was last verified.
EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the enrollment in the program.

IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update


Description
Indicates whether the enrollment for the participant in the program is active (true) or not
(false).
The default value is false.

IsAnonymous

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the participant enrolled to the program anonymously (true) or not
(false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the program enrollment record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update


Description
The user who owns the object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PreviousMonthDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefit disbursed to the enrollee in the previous month. Data Processing Engine
calculates this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

PreviousYearDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed to the enrollee in the previous year. Data Processing Engine
calculates this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

ProgramId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The identifier of the program that's associated with the enrollee.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Master-Detail
Refers To
Program


SessionsAbsentCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of benefit sessions for the program that were scheduled for the participant
but not attended.
This field is available from API version 65.0 and later.

SessionsAttendanceRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of scheduled benefit sessions for the program that the participant attended.
The value of this field is calculated by a formula: (Attended Sessions Count) / (Attended
Sessions Count + Absent Sessions Count)
This field is available from API version 65.0 and later.

SessionsAttendedCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of benefit sessions for the program that were scheduled for and attended
by the participant.
This field is available from API version 65.0 and later.

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the enrollment in the program.

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
The enrollment status of the enrollee for the program.


Possible values are:
• Applied
• Completed
• Denied
• In Progress
• Waitlisted
• Withdrawn
The default value is Applied.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ProgramEnrollmentFeed
Feed tracking is available for the object.
ProgramEnrollmentHistory
History is available for tracked fields of the object.
ProgramEnrollmentOwnerSharingRule
Sharing rules are available for the object.
ProgramEnrollmentShare
Sharing is available for the object.

RecurrenceSchedule
Represents the recurrence schedule for a benefit schedule. This object is available with Program Management in API version 57.0 and
later.

Supported Calls
create(), delete(), describeSObjects(), getDeleted(), getUpdated(), query(), retrieve(),
undelete(), update(), upsert()

Fields
Field

Details

CompletedScheduleCount

Type
int
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update


Description
The number of times the schedule was completed.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the schedule ends.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the recurrence schedule.

NextScheduleDateTime

Type
dateTime
Properties
Create, Filter, Sort, Update
Description
The date and time when the schedule is executed next.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The user who owns the object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ProcessName

Type
picklist


Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The name of the scheduling process that executes the request.
Possible values are:
• Industries_ActionPlan
• Industries_ProgramManagement

ReferenceRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The related record for which you’re creating the recurrence schedule. For example, creating
a recurrence schedule for a related Benefit Schedule entity.
This field is a polymorphic relationship field.
Relationship Name
ReferenceRecord
Relationship Type
Lookup
Refers To
ActionPlan, BenefitSchedule

ScheduleDayValue

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The days in a week when the schedule is executed. This field contains a bit mask.
• Monday = 64
• Tuesday = 32
• Wednesday = 16
• Thursday = 8
• Friday = 4
• Saturday = 2
• Sunday = 1
Multiple days are represented as the sum of their numerical values. For example, Tuesday
and Thursday = 32 + 8 = 40.


ScheduleFrequency

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies the frequency at which the schedule is executed.
Possible values are:
• Biweekly
• Halyearly—Half Yearly
• Monthly
• Quarterly
• Weekly
• Yearly

StartDate

Type
dateTime
Properties
Create, Filter, Sort, Update
Description
The date when the schedule begins.

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The status of the schedule.
Possible values are:
• Active
• Inactive

TotalRecurrencesCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of times the schedule is executed.


Program Management Business APIs

Program Management Business APIs
Program Management Business APIs are RESTful APIs that are sometimes available as Apex classes
and methods.

EDITIONS

Program Management has these resources.

Available in: Lightning
Experience

Resource

Description

/connect/program-mgmt/programs/${programId}/enrollments Enroll participants in a

program. An enrollee
can either be a contact
or an account.

Available in: Program
Management is available
with Enterprise, Unlimited,
and Performance Editions
with the Impact Cloud.

/connect/program-mgmt/programs/${programId}/enrollments Update program

enrollments.
Create a preview of
the benefit scheduling
session.

/connect/program-mgmt/benefit-schedules

/connect/program-mgmt/benefit-schedules/${benefitScheduleId}/sessions Create a benefit

schedule for a benefit
session.
/connect/program-mgmt/benefit-schedules/${benefitScheduleId}/participants Add participants to a

benefit schedule.
/connect/program-mgmt/benefit-schedules/${benefitScheduleId} Add participants to a
/benefit-sessions/${benefitSessionId}/participants benefit session.
/connect/program-mgmt/benefit/${benefitId}/benefit-disbursements Create benefit

disbursements for ad
hoc walk-in
participants.
/connect/program-mgmt/case-programs/${caseId} Create case programs.

REST Reference
You can access Program Management Business APIs using REST endpoints. These REST APIs follow similar conventions as Connect
REST APIs.

REST Reference
You can access Program Management Business APIs using REST endpoints. These REST APIs follow similar conventions as Connect REST
APIs.
To understand the architecture, authentication, rate limits, and how the requests and responses work, see Connect REST API Developer
Guide.


REST Reference

Resources
Here’s a list of Program Management Business API resources.
Requests
Here’s a list of Program Management Business API request bodies.
Responses
Here’s a list of Program Management Business API response bodies.

Resources
Here’s a list of Program Management Business API resources.
Benefit Disbursements (POST)
Create benefit disbursements for ad hoc walk-in participants.
Benefit Session Participants (POST)
Add participants to a benefit session.
Benefit Schedule Participants (POST)
Asynchronously add participants to a benefit schedule.
Benefit Schedule Participants (DELETE)
Remove participants from a benefit schedule asynchronously.
Benefit Schedule Sessions (POST)
Create a benefit schedule for a benefit session.
Benefit Schedule Sessions Preview (POST)
Create a preview of the benefit scheduling session. Users can preview the benefit sessions before they are created.
Benefit Disbursement Field Set API Names
Retrieve the API names of the field sets associated with a benefit disbursement object.
Case Programs (POST)
Create case programs.
Program Enrollments (POST)
Enroll participants in a program.
Program Enrollments (PUT)
Update program enrollments.

Benefit Disbursements (POST)
Create benefit disbursements for ad hoc walk-in participants.
Resource
/connect/program-mgmt/benefit/${benefitId}/benefit-disbursements

Example URI
https://yourInstance.salesforce.com/services/data/v66.0/connect
/program-mgmt/benefit/${benefitId}/benefit-disbursements


REST Reference

Available version
57.0
HTTP methods
POST
Request body for POST
Root XML tag
<BenefitDisbursementsInputRepresentation>

JSON example
{
"enrollees": {
"enrolleeList": [
"003T1000001U6axIAC"
]
},
"quantity": 2.5,
"status": "Enrolled",
"disbursementDate": "2022-12-18T14:30:00.000"
}

Properties
Name

Type

disbursementDate String

Description

Required or
Optional

Available
Version

The date on which the benefit is
disbursed.

Required

57.0

enrollees

String[]

The list of enrollees who will receive the Required
benefit disbursement. The enrollee can
either be a contact or an account.

57.0

quantity

Double

The quantity of the benefit to be
disbursed.

Required

57.0

status

String

The status of the benefit disbursement.

Required

57.0

Response body for POST
Benefit Disbursements Output

Benefit Session Participants (POST)
Add participants to a benefit session.
Resource
/connect/program-mgmt/benefit-schedules/${benefitScheduleId}/benefit-sessions/${benefitSessionId}/participants


REST Reference

Example URI
https://yourInstance.salesforce.com/services/data/v66.0/connect
/program-mgmt/benefit-schedules/${benefitScheduleId}/benefit-sessions/${benefitSessionId}/participants

Available version
57.0
HTTP methods
POST
Request body for POST
Root XML tag
<BenefitSessionParticipantsInputRepresentation>

JSON example
{
"enrollees": {
"enrolleeList": [
"003xx000004WhKeAAK"
]
}
}

Properties
Name

Type

Description

Required or
Optional

Available
Version

enrollees

String[]

The list of enrollees to be added to a
benefit session. The enrollee can either
be a contact, an account, or a program
enrollment.

Required

57.0

Response body for POST
Benefit Session Participants Output

Benefit Schedule Participants (POST)
Asynchronously add participants to a benefit schedule.
Resource
/connect/program-mgmt/benefit-schedules/${benefitScheduleId}/participants

Example URI
https://yourInstance.salesforce.com/services/data/v66.0/connect
/program-mgmt/benefit-schedules/${benefitScheduleId}/participants

Available version
57.0


REST Reference

HTTP methods
POST
Request body for POST
Root XML tag
<BenefitScheduleParticipantsInputRepresentation>

JSON example
{
"enrollees": {
"enrolleeList": [
"003xx000004WhKeAAK"
]
}
}

Properties
Name

Type

Description

Required or
Optional

enrollees

String[]

The list of enrollees to be added to a
Required
benefit schedule. The enrollee can either
be a contact, an account, or a program
enrollment.

Available
Version
57.0

Response body for POST
Benefit Schedule Participants Output

Benefit Schedule Participants (DELETE)
Remove participants from a benefit schedule asynchronously.
Remove participants from a benefit schedule asynchronously. Include benefit schedule assignment records in the API's operation. Benefit
schedule assignments enable accurate updating of end dates when removing participants from sessions.
Removing a participant from a benefit schedule:
• Updates the end date of all the active benefit schedule assignments associated with the participant to a current date. If a future
session's startingBenefitSessionId is provided, Salesforce updates the end date for the benefit schedule assignments
to the end date of that session. If the session is in the past or no startingBenefitSessionId is provided, Salesforce updates
the end date to the current date.
• Deletes benefit disbursements for future sessions whose attendance wasn’t changed from the default Enrolled status to
Completed, Excused, or Absent. If a startingBenefitSessionId is provided, Salesforce removes participants
from that session onwards, including past and future sessions. If a startingBenefitSessionId isn’t provided, Salesforce
removes participants from current and future sessions.
Resource
/connect/program-mgmt/benefit-schedules/${benefitScheduleId}/benefit-assignments


REST Reference

Resource example
https://yourInstance.salesforce.com/services/data/v66.0/connect/program-mgmt/benefit-schedules/BS-000000006/benefit-assignments?ids=BA-000000001,BA-000000002
https://yourInstance.salesforce.com/services/data/v66.0/connect/program-mgmt/benefit-schedules/${benefitScheduleId}/benefit-assignments?ids=BA-000000001,BA-000000002&startingBenefitSessionId=BS-000000001

Available version
59.0
HTTP methods
DELETE
Query parameters for DELETE
Parameter
Name

Type

Description

Required or
Optional

ids

String[]

Valid IDs of benefit assignments related to Required
the participants to be removed.

Available
Version
59.0

You can provide a maximum of 100 IDs.
startingBenefitSessionId String[]

Valid benefit session ID associated with the Optional
benefit assignment IDs. If provided, the
operation will affect that session and all
subsequent sessions where attendance is
yet to be marked. If not provided, the
operation will default to affecting only
future sessions.

61.0

Benefit Schedule Sessions (POST)
Create a benefit schedule for a benefit session.
Resource
/connect/program-mgmt/benefit-schedules/${benefitScheduleId}/sessions

Example URI
https://yourInstance.salesforce.com/services/data/v66.0/connect
/program-mgmt/benefit-schedules/${benefitScheduleId}/sessions

Available version
57.0
HTTP methods
POST
Response body for POST
Generate Benefit Session Output

Benefit Schedule Sessions Preview (POST)
Create a preview of the benefit scheduling session. Users can preview the benefit sessions before they are created.


REST Reference

Resource
/connect/program-mgmt/benefit-schedules

Example URI
https://yourInstance.salesforce.com/services/data/v66.0/connect
/program-mgmt/benefit-schedules

Available version
57.0
HTTP methods
POST
Request body for POST
Root XML tag
<PreviewBenefitSessionInputRepresentation>

JSON example
{
"benefitScheduleName": "Nov Weekday schedule",
"firstSessionStartDate": "2022-11-14T14:30:00.000",
"firstSessionEndDate": "2022-11-14T15:00:00.000",
"scheduleFrequency": "Weekly",
"scheduleDays": 96,
"mode": "dryRun",
"noOfSessions": 5,
"totalRecurrencesCount": 10
}

Properties
Name

Description

Required or
Optional

Available
Version

benefitScheduleName String

The name of the benefit schedule.

Required

57.0

firstSessionEndDate String

The date and time when the first session Required
ends in the benefit schedule.

57.0

firstSessionStartDate String

The date and time when the first session Required
starts in the benefit schedule.

57.0

The mode of the benefit schedule. The
dryRun mode indicates that no data
is created.

Optional

57.0

noOfSessions Integer

The maximum number of participants in Optional
a session. Default value is 5.

57.0

scheduleDays Integer

The number of days in a week when the Optional
benefit schedule is executed.

57.0

scheduleEndDate String

The date when the benefit schedule ends. Optional

57.0

mode

Type

String


REST Reference

Type

Description

Required or
Optional

Available
Version

scheduleFrequency String

The frequency at which the benefit
schedule is executed.

Optional

57.0

totalRecurrencesCount Integer

The number of times the benefit
schedule is executed.

Optional

57.0

Response body for POST
Preview Benefit Sessions Output

Benefit Disbursement Field Set API Names
Retrieve the API names of the field sets associated with a benefit disbursement object.
Resource
/connect/fieldset/${objectName}

Resource example
https://yourInstance.salesforce.com/services/data/v66.0connect/fieldset/BenefitDisbursement

Available version
59.0
HTTP methods
GET
Response body for GET
Field Sets Output

Case Programs (POST)
Create case programs.
Resource
/connect/program-mgmt/case-programs/${caseId}

Example URI
https://yourInstance.salesforce.com/services/data/v66.0/connect
/program-mgmt/case-programs/${caseId}

Available version
57.0
HTTP methods
POST


REST Reference

Request body for POST
JSON example
{
"caseProgramRequest": {
"programIds": [
"11Wxx0000004F0WEAU",
"11Wxx0000004F0WEBQ"
]
}
}

Properties
Name

Type

caseProgramRequest String[]

Description

Required or
Optional

Available
Version

The list of case programs to be added.

Required

57.0

Response body for POST
Case Programs Output

Program Enrollments (POST)
Enroll participants in a program.
Resource
/connect/program-mgmt/programs/${programId}/enrollments

Example URI for POST
https://yourInstance.salesforce.com/services/data/v66.0/connect
/program-mgmt/programs/11Wxx0000004F3kEAE/enrollments

Available version
57.0
HTTP methods
POST
Request body for POST
Root XML tag
<ProgramEnrollmentsInputRepresentation>

Properties
Name

Type

Description

Required or
Optional

enrollees

Program
The list of program enrollments that need Required
Enrollment Input[] to be added or updated.


Available
Version
57.0

REST Reference

Type

Description

Required or
Optional

For POST, the enrollments you want to
add can either be a contact or an
account.
For PUT, specify the program enrollments
that need to be updated.

JSON example
{
"enrollees": {
"enrolleeList": [
{
"id": "003xx000004WhxNAAS"
}
]
}
}

Response body for POST
Program Enrollments Output

Program Enrollments (PUT)
Update program enrollments.
Resource
/connect/program-mgmt/programs/${programId}/enrollments

Example URI for PUT
https://yourInstance.salesforce.com/services/data/v66.0/connect
/program-mgmt/programs/11Wxx0000004F3kEAE/enrollments

Available version
57.0
HTTP methods
PUT
Request body for PUT
Root XML tag
<ProgramEnrollmentsInputRepresentation>


Available
Version

REST Reference

Properties
Name

Type

Description

Required or
Optional

enrollees

Program
The list of program enrollments that need Required
Enrollment Input[] to be added or updated.
For POST, the enrollments you want to
add can either be a contact or an
account.
For PUT, specify the program enrollments
that need to be updated.

JSON example
{
"enrollees": {
"enrolleeList": [
{
"id": "11Xxx0000004Gz5EAE",
"status": "Enrolled",
"endDate": "2025-05-11T13:05:23.000Z"
},
{
"id": "11Xxx0000004Gz6EAE",
"status": "Enrolled",
"startDate": "2023-02-11T13:05:23.000Z",
"endDate": "2024-01-12T13:05:23.000Z"
},
{
"id": "11Xxx0000004Gz7EAE",
"status": "Enrolled",
"startDate": "2023-02-11T13:05:23.000Z",
"applicationDate": "2023-02-11T13:05:23.000Z"
},
{
"id": "11Xxx0000004Gz9EAE",
"status": "Enrolled",
"endDate": "2024-01-11T13:05:23.000Z",
"applicationDate": "2023-02-12T13:05:23.000Z"
}
]
}
}

Response body for PUT
Program Enrollments Output


Available
Version
57.0

REST Reference

Requests
Here’s a list of Program Management Business API request bodies.
Benefit Disbursements Input
Input representation of the request to create benefit disbursements.
Benefit Schedule Participants Input
Input representation of the request to add participants to a benefit schedule.
Benefit Session Participants Input
Input representation of the request to add participants to a benefit session.
Case Programs Input
Input representation of the request to add case programs to a benefit session.
Preview Benefit Session Input
Input representation of the benefit scheduling session preview request.
Program Enrollment Input
Input representation of the enrollee for the program.
Program Enrollments Input
Input representation of the request to enroll or update participants in a program.

Benefit Disbursements Input
Input representation of the request to create benefit disbursements.
Root XML tag
<BenefitDisbursementsInputRepresentation>

JSON example
{
"enrollees": {
"enrolleeList": [
"003T1000001U6axIAC"
]
},
"quantity": 2.5,
"status": "Enrolled",
"disbursementDate": "2022-12-18T14:30:00.000"
}

Properties
Name

Type

disbursementDate String
enrollees

String[]

Description

Required or
Optional

Available
Version

The date on which the benefit is disbursed. Required

57.0

The list of enrollees who will receive the
benefit disbursement. The enrollee can
either be a contact or an account.

57.0


Required

REST Reference

Name

Type

Description

Required or
Optional

Available
Version

quantity

Double

The quantity of the benefit to be disbursed. Required

57.0

status

String

The status of the benefit disbursement.

Required

57.0

Required or
Optional

Available
Version

Benefit Schedule Participants Input
Input representation of the request to add participants to a benefit schedule.
Root XML tag
<BenefitScheduleParticipantsInputRepresentation>

JSON example
{
"enrollees": {
"enrolleeList": [
"003xx000004WhKeAAK"
]
}
}

Properties
Name

Type

Description

enrollees

String[]

The list of enrollees to be added to a
Required
benefit schedule. The enrollee can either
be a contact, an account, or a program
enrollment.

Benefit Session Participants Input
Input representation of the request to add participants to a benefit session.
Root XML tag
<BenefitSessionParticipantsInputRepresentation>

JSON example
{
"enrollees": {
"enrolleeList": [
"003xx000004WhKeAAK"
]
}
}


57.0

REST Reference

Properties
Name

Type

Description

Required or
Optional

enrollees

String[]

The list of enrollees to be added to a
Required
benefit session. The enrollee can either be
a contact, an account, or a program
enrollment.

Available
Version
57.0

Case Programs Input
Input representation of the request to add case programs to a benefit session.
JSON example
{
"caseProgramRequest": {
"programIds": [
"11Wxx0000004F0WEAU",
"11Wxx0000004F0WEBQ"
]
}
}

Properties
Name

Type

caseProgramRequest String[]

Description

Required or
Optional

Available
Version

The list of case programs to be added.

Required

57.0

Preview Benefit Session Input
Input representation of the benefit scheduling session preview request.
Root XML tag
<PreviewBenefitSessionInputRepresentation>

JSON example
{
"benefitScheduleName": "Nov Weekday schedule",
"firstSessionStartDate": "2022-11-14T14:30:00.000",
"firstSessionEndDate": "2022-11-14T15:00:00.000",
"scheduleFrequency": "Weekly",
"scheduleDays": 96,
"mode": "dryRun",
"noOfSessions": 5,
"totalRecurrencesCount": 10
}


REST Reference

Properties
Name

Type

Description

Required or
Optional

Available
Version

benefitScheduleName String

The name of the benefit schedule.

Required

57.0

firstSessionEndDate String

The date and time when the first session
ends in the benefit schedule.

Required

57.0

firstSessionStartDate String

The date and time when the first session
starts in the benefit schedule.

Required

57.0

mode

String

The mode of the benefit schedule. The
Optional
dryRun mode indicates that no data is
created.

57.0

noOfSessions

Integer

The maximum number of participants in
a session. Default value is 5.

Optional

57.0

scheduleDays

Integer

The number of days in a week when the
benefit schedule is executed.

Optional

57.0

scheduleEndDate String

The date when the benefit schedule ends. Optional

57.0

scheduleFrequency String

The frequency at which the benefit
schedule is executed.

Optional

57.0

totalRecurrencesCount Integer

The number of times the benefit schedule Optional
is executed.

57.0

Program Enrollment Input
Input representation of the enrollee for the program.
Root XML tag
<ProgramEnrollmentsDTO>

Properties
Name

Type

applicationDate String

Description

Required or
Optional

Available
Version

The date when the enrollee applied to the Optional
program.

57.0

endDate

String

The end date of the enrollment in the
program.

Optional

57.0

id

String

The ID of the enrollee record. The enrollee Required
can either be a contact or an account.

57.0

startDate

String

The start date of the enrollment in the
program.

57.0


Optional

REST Reference

Name

Type

Description

Required or
Optional

Available
Version

status

String

The enrollment status of the enrollee for
the program.

Optional

57.0

Required or
Optional

Available
Version

Program Enrollments Input
Input representation of the request to enroll or update participants in a program.
Root XML tag
<ProgramEnrollmentsInputRepresentation>

Properties
Name

Type

Description

enrollees

Program Enrollment The list of program enrollments that need Required
Input[]
to be added or updated.
For POST, the enrollments you want to add
can either be a contact or an account.
For PUT, specify the program enrollments
that need to be updated.

Responses
Here’s a list of Program Management Business API response bodies.
Benefit Disbursements Output
Output representation of the request to create benefit disbursements.
Benefit Schedule Participants Output
Output representation of the request to add participants to a benefit schedule.
Benefit Session Participants Output
Output representation of the request to add participants to a benefit session.
Benefit Sessions
Output representation of the benefit sessions that are generated for preview.
Case Programs Output
Output representation of the request to add case programs to a benefit session.
Field Sets Output
Output representation of field sets of a benefit disbursement object.
Field Set Output
Output representation of the details of a field set.
Generate Benefit Session Output
Output representation of the request to create a benefit schedule session.


57.0

REST Reference

Preview Benefit Sessions Output
Output representation of the benefit scheduling session preview request.
Program Enrollments Output
Output representation of the request to enroll or update participants in a program.
Standard Object Details
Output representation of the details of gift transactions.
Standard Field Details
Output representation of the field attributes in a gift transaction object.

Benefit Disbursements Output
Output representation of the request to create benefit disbursements.
Property Name

Type

Description

Filter Group and
Version

Available Version

message

String

The message that provides the request
response details.

Small, 57.0

57.0

success

Boolean

Indicates whether the request was
successful (true) or not (false).

Small, 57.0

57.0

Benefit Schedule Participants Output
Output representation of the request to add participants to a benefit schedule.
Property Name

Type

Description

Filter Group and
Version

Available Version

message

String

The message that provides the request
response details.

Small, 57.0

57.0

success

Boolean

Indicates whether the request was
successful (true) or not (false).

Small, 57.0

57.0

Benefit Session Participants Output
Output representation of the request to add participants to a benefit session.
Property Name

Type

Description

Filter Group and
Version

Available Version

message

String

The message that provides the request
response details.

Small, 57.0

57.0

success

Boolean

Indicates whether the request was
successful (true) or not (false).

Small, 57.0

57.0


REST Reference

Benefit Sessions
Output representation of the benefit sessions that are generated for preview.
Property Name

Type

Description

Filter Group and
Version

Available Version

endDate

String

The end date and time of the benefit
session.

Small, 57.0

57.0

name

String

The name of the benefit session.

Small, 57.0

57.0

startDate

String

The start date and time of the benefit
session.

Small, 57.0

57.0

Case Programs Output
Output representation of the request to add case programs to a benefit session.
Property Name

Type

Description

Filter Group and
Version

Available Version

message

String

The message that provides the request
response details.

Small, 57.0

57.0

success

Boolean

Indicates whether the request was
successful (true) or not (false).

Small, 57.0

57.0

Field Sets Output
Output representation of field sets of a benefit disbursement object.
JSON example
{
"fieldSets": [
{
"description": "FS1",
"fieldSetApiName": "FS1_API",
"fieldSetName": "FS1"
},
{
"description": "FS2",
"fieldSetApiName": "FS2_API",
"fieldSetName": "FS2"
},
{
"description": "FS3",
"fieldSetApiName": "FS3_API",
"fieldSetName": "FS3"
}
],
"objectName": "BenefitDisbursement"
}


REST Reference

Property Name

Type

Description

Filter Group and
Version

Available Version

fieldSets

Field Set Output[]

List of field sets of the benefit disbursement Small, 59.0
object.

59.0

objectName

String

Name of the benefit disbursement object
whose field sets you want to retrieve.

Small, 59.0

59.0

Field Set Output
Output representation of the details of a field set.
Property Name

Type

Description

Filter Group and
Version

Available Version

description

String

Description of the field set.

Small, 59.0

59.0

API name of the field set.

Small, 59.0

59.0

Name of the field set.

Small, 59.0

59.0

fieldSetApiName String
fieldSetName

String

Generate Benefit Session Output
Output representation of the request to create a benefit schedule session.
Property Name

Type

Description

Filter Group and
Version

Available Version

message

String

The message that provides the request
response details.

Small, 57.0

57.0

success

Boolean

Indicates whether the request was
successful (true) or not (false).

Small, 57.0

57.0

Filter Group and
Version

Available Version

Preview Benefit Sessions Output
Output representation of the benefit scheduling session preview request.
Property Name

Type

Description

sessions

Benefit Sessions[]

Specifies the list of the benefit sessions that Small, 57.0
have been returned for preview.

Program Enrollments Output
Output representation of the request to enroll or update participants in a program.


57.0

REST Reference

Property Name

Type

Description

Filter Group and
Version

Available Version

message

String

The message that provides the request
response details.

Small, 57.0

57.0

success

Boolean

Indicates whether the request was
successful (true) or not (false).

Small, 57.0

57.0

Standard Object Details
Output representation of the details of gift transactions.
Property Name

Type

Description

Filter Group and
Version

Available Version

fields

Standard Field
Details[]

List of gift transaction fields.

Small, 59.0

59.0

API name of the gift transaction.

Small, 59.0

59.0

objectApiName String

Standard Field Details
Output representation of the field attributes in a gift transaction object.
Property Name

Type

Description

Filter Group and
Version

Available Version

fieldApiName

String

API name of a field in the gift transaction
object.

Small, 59.0

59.0

label

String

Label of a field in the gift transaction object. Small, 59.0

59.0

type

String

Type of a field in the gift transaction object. Small, 59.0

59.0

value

String

Value of a field in the gift transaction object. Small, 59.0

59.0


# Chapter 5: Case Management

In this chapter ...
•

Case Management
Standard Objects

•

Case Management
Business API

Case Management
This guide provides objects and API information about Case
Management for Nonprofits. Built on the platform, Case
Management helps case managers assist participants in achieving
their goals through individualized plans, collaborative tools, and
full participant data.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise and
Unlimited Editions.


Case Management Standard Objects

Case Management Standard Objects
Case Management data model provides objects and fields to manage cases and care plans for your
nonprofit organization.
CarePlan
Represents an instantiation of a care plan template for a particular individual in order to reach
specific goals. This object is available in API version 55.0 and later.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise and
Unlimited Editions.

CarePlanTemplate
Represents the template for a type of care plan that can be offered for a household scenario.
This object is available in API version 55.0 and later.
CarePlanTemplateBenefit
Represents a junction between a care plan template and a benefit. This object stores the benefit details of a care plan. This object is
available in API version 55.0 and later.
CarePlanTemplateGoal
Represents a junction between a care plan template and a goal definition. This object stores the goal details of a care plan template.
This object is available in API version 55.0 and later.
CaseParticipant
Represents a junction between a case, and an account or a contact. This object stores the details of the participant associated with
a case. This participant could be the applicant, co-applicant, a household, or even a business account. This object is available in API
version 54.0 and later.
ComplaintCase
Represents the association between a public complaint and its corresponding case. This object is available in API version 52.0 and
later.
ComplaintParticipant
Represents a junction between a public complaint, and an account or a contact. This object stores the details of the participant who
registers a complaint with the authorities. This participant could be the applicant, co-applicant, a household, or even a business
account. This object is available in API version 54.0 and later.
GoalAssignment
Represents the assignment of a goal. This object is available in API version 55.0 and later.
GoalDefinition
Represents a goal or a business objective that’s used as a reference. When instantiated, GoalDefinition records create GoalAssignment
records that serve as goals in care plans.
Interaction
Represents an interaction (phone call, in-person meeting, or video conference) between two or more people (attendees), typically
including at least one representative and one customer or partner.
InteractionAttendee
Represents an attendee of an interaction.
InteractionRelatedAccount
Represents a junction between an interaction and account that's related to that interaction.
InteractionSummary
Represents the summary of an interaction, including confidentiality information.


Represents information about the companies discussed in an interaction.
PublicComplaint
Represents the complaints submitted by public users. This object is available in API version 49.0 and later.
Referral
Represents the information on client referrals in an organization. This object is available in API version 56.0 and later.

CarePlan
Represents an instantiation of a care plan template for a particular individual in order to reach specific goals. This object is available in
API version 55.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

CarePlanTemplateId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The care plan template associated with the care plan.
This is a relationship field.
Relationship Name
CarePlanTemplate
Relationship Type
Lookup
Refers To
CarePlanTemplate

CaseId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The case associated with the care plan.


This is a relationship field.
Relationship Name
Case
Relationship Type
Master-Detail
Refers To
Case

CaseProceedingResultId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outcome of a legal case for a participant.
This field is a relationship field.
Available with a Public Sector Solutions license and in API version 58.0 and later.
Relationship Name
CaseProceedingResult
Relationship Type
Lookup
Refers To
CaseProceedingResult

ClaimId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The claim with which the care plan is associated.
Available with a Public Sector Solutions license and in API version 59.0 and later.
This field is a relationship field.
Relationship Name
Claim
Relationship Type
Lookup
Refers To
Claim

Description

Type
textarea


Properties
Create, Nillable, Update
Description
The description for the care plan record.

EndDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date until when the care plan is effective.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user referenced this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user viewed this record.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the care plan record.

ParticipantId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The account associated with the care plan.
This is a polymorphic relationship field.


Relationship Name
Participant
Relationship Type
Lookup
Refers To
Account, Contact

StartDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date from when the care plan is effective.

Status

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the status of the care plan.
Possible values are:
• Active
• Cancelled
• Completed
• Draft
• Proposed

TaskJobStatus

Type
picklist
Properties
Filter, Group, Nillable, Restricted picklist, Sort
Description
Specifies the status of the task in the task queue.
Possible values are:
• Completed
• Failed
• InProgress
• Submitted


TaskJobStatusMessage

Type
textarea
Properties
Nillable
Description
The message that describes the status of the task in the queue.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
CarePlanFeed
Feed tracking is available for the object.
CarePlanHistory
History is available for tracked fields of the object.

CarePlanTemplate
Represents the template for a type of care plan that can be offered for a household scenario. This object is available in API version 55.0
and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description of the care plan template record.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The most recent date on which a user referenced this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user viewed this record.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the care plan template record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the care plan template record owner.
This is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies the status of the care plan template.
Possible values are:
• Draft
• Inactive
• Published


The default value is 'Draft'.

CarePlanTemplateBenefit
Represents a junction between a care plan template and a benefit. This object stores the benefit details of a care plan. This object is
available in API version 55.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

BenefitId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The name of the care plan template benefit record.
This is a relationship field.
Relationship Name
Benefit
Relationship Type
Lookup
Refers To
Benefit

CarePlanTemplateId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The care plan template associated with the care plan template benefit.
This is a relationship field.
Relationship Name
CarePlanTemplate


Relationship Type
Master-Detail
Refers To
CarePlanTemplate

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user referenced this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the care plan template benefit record.

Priority

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the priority of the care plan template benefit.
Possible values are:
• High
• Low
• Medium


Represents a junction between a care plan template and a goal definition. This object stores the goal details of a care plan template.
This object is available in API version 55.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

CarePlanTemplateId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The care plan template associated with the care plan template goal.
This is a relationship field.
Relationship Name
CarePlanTemplate
Relationship Type
Master-Detail
Refers To
CarePlanTemplate

GoalDefinitionId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The goal definition associated with the care plan template goal.
This is a relationship field.
Relationship Name
GoalDefinition
Relationship Type
Lookup
Refers To
GoalDefinition


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user referenced this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the care plan template goal.

Priority

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the priority of the care plan template goal.
Possible values are:
• High
• Low
• Medium

CaseParticipant
Represents a junction between a case, and an account or a contact. This object stores the details of the participant associated with a
case. This participant could be the applicant, co-applicant, a household, or even a business account. This object is available in API version
54.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AuthorizationProof

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
How the participant communicated their consent. This field is available in API version 58.0
and later.
Possible values are:
• Email Consent
• Joint Ownership
• Power of Attorney
• Verbal Consent

CaseId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The case associated with the case participant record.
This field is a relationship field.
Relationship Name
Case
Relationship Type
Master-Detail
Refers To
Case

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user referenced this record.


LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the case participant record.

ParticipantId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The participant associated with the case participant record.
This field is a polymorphic relationship field.
Relationship Name
Participant
Relationship Type
Lookup
Refers To
Account, Contact

PreferredCallTimeFrom

Type
time
Properties
Create, Filter, Nillable, Sort, Update
Description
The start of the preferred time window for contacting the participant. This field is available
in API version 58.0 and later.

PreferredCallTimeTo

Type
time
Properties
Create, Filter, Nillable, Sort, Update


Description
The end of the preferred time window for contacting the participant. This field is available
in API version 58.0 and later.

PreferredCommunicationMode Type

picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
How the participant prefers to receive messages. This field is available in API version 58.0
and later.
Possible values are:
• Email
• Phone
• SMS
Role

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies the role of the case participant.
Possible values are:
• Applicant
• Inspection Officer
• Lawyer
• Observer
• Perpetrator
• Primary Caretaker
• Victim
The default value is Applicant.

Status

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the status of the case participant.
Possible values are:
• Active


• Inactive

ComplaintCase
Represents the association between a public complaint and its corresponding case. This object is available in API version 52.0 and later.
When a public complaint is raised on the portal, multiple department could be involved and each department can create a case record
to track how the complaint is handled. For example, a hazardous chemical complaint can be handled by both the environmental agency
and the fire department.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

CaseId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The name of the case that is associated with the complaint.
This is a relationship field.
Relationship Name
Case
Relationship Type
Lookup
Refers To
Case

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user referenced this record.

LastViewedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description
The most recent date on which a user viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The ID of the complaint being raised.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the complaint case record owner.
This is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PublicComplaintId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The name of the public complaint that is associated to the complaint being raised.
This is a relationship field.
Relationship Name
PublicComplaint
Relationship Type
Lookup
Refers To
PublicComplaint


Represents a junction between a public complaint, and an account or a contact. This object stores the details of the participant who
registers a complaint with the authorities. This participant could be the applicant, co-applicant, a household, or even a business account.
This object is available in API version 54.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.
When Compliant Data Sharing is enabled for the Public Complaint object, a complaint participant represents information about a user
or group of participants who have access to a public complaint.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

Comments

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The comments about why the participant has access to the public complaint.
Available in API version 62.0 and later, when Compliant Data Sharing is enabled for the Public
Complaint object.

IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Specifies whether the participant's association with the public complaint is active (true) or
not (false).
The default value is false.
Available in API version 62.0 and later, when Compliant Data Sharing is enabled for the Public
Complaint object.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the complaint participant record.

ParticipantId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The participant associated with the complaint participant record.
This field is a polymorphic relationship field.
Relationship Name
Participant
Refers To
Account, Contact, Group, User

ParticipantRoleId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The participant role associated with the complaint participant record.
This field is a relationship field.
Available in API version 62.0 and later, when Compliant Data Sharing is enabled for the Public
Complaint object.
Relationship Name
ParticipantRole


Refers To
ParticipantRole

PublicComplaintId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The public complaint associated with the complaint participant record.
This field is a relationship field.
Relationship Name
PublicComplaint
Relationship Type
Master-Detail
Refers To
PublicComplaint

Role

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the role of the complaint participant.
Possible values are:
• Observer
• Perpetrator
• Reporter
• Victim
The new Nillable property is available in API version 58.0 and later.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the complaint participant.
Possible values are:
• Active
• Inactive
The default value is Active.


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ComplaintParticipantFeed
Feed tracking is available for the object.
ComplaintParticipantHistory
History is available for tracked fields of the object.

GoalAssignment
Represents the assignment of a goal. This object is available in API version 55.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available if Program and Benefit Management is enabled in your org. To access the object, you need the Program and
Benefit Management Access permission set or the Program and Benefit Management permission set license.

Fields
Field

Details

CompletionDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the goal is completed.

CompletionPercentage

Type
percent
Properties
Create, Defaulted on create, Filter, Nillable, Sort, Update
Description
Indicates the progress made on the assigned goal in percentage.

CustomGoalName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
A custom name that can be defined for the goal assignment. If this field is empty, the goal
definition name is used for the goal assignment.
This field is available from API version 63.0 and later.

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description of the goal assignment record.

GoalAssigneeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The assigees associated with the goal assignment.
This is a polymorphic relationship field.
Relationship Name
GoalAssignee
Relationship Type
Lookup
Refers To
Account, Contact

GoalDefinitionId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The goal definition associated with the goal assignment.
This is a relationship field.
Relationship Name
GoalDefinition
Relationship Type
Lookup
Refers To
GoalDefinition


DescriptionCodeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The system-defined code that represents the description of a standardized goal.
This field is a polymorphic relationship field.
Available in API version 61.0 and later.
Relationship Name
DescriptionCode
Relationship Type
Lookup
Refers To
CodeSet, CodeSetBundle

GoalType

Type
string
Properties
Filter, Group, Nillable, Sort
Description
Specifies if the goal applies to a group or an individual.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user referenced this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date on which a user viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort


Description
The name of the goal assignment record.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the goal assignment record owner.
This is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The care plan or benefit assignment object associated with the goal assignment.
This is a polymorphic relationship field.
Relationship Name
ParentRecord
Relationship Type
Lookup
Refers To
BenefitAssignment, CarePlan

Priority

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the priority of the goal assignment.
Possible values are:
• High
• Low


• Medium

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the assigned goal.

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the assigned goal.
Possible values are:
• Canceled
• Completed
• In Progress
• Not Started
The default value is 'Not Started'.

TargetCompletionDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date by when the assigned goal is targeted to be completed.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GoalAssignmentFeed
Feed tracking is available for the object.
GoalAssignmentHistory
History is available for tracked fields of the object.
GoalAssignmentOwnerSharingRule
Sharing rules are available for the object.


Sharing is available for the object.

GoalDefinition
Represents a goal or a business objective that’s used as a reference. When instantiated, GoalDefinition records create GoalAssignment
records that serve as goals in care plans.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

Category

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The category that the defined goal belongs to.

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description of the defined goal.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last viewed this record or list view.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the goal definition record.

OwnerId

Type
Polymorphic lookup
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the owner of this goal definition record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
• Group
• User

ParentGoalId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the parent record.
This field is a relationship field.
Relationship Name
ParentGoal
Relationship Type
Lookup
Refers To
GoalDefinition

Status

Type
picklist


Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The status of the goal defintion.
Possible values are:
• Active
• Inactive
The default value is Active.

Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of the defined goal.
Possible values are:
• Individual—Intermediate Goal
• Strategic—Top Goal
The default value is Individual.

UsageType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the usage type of the defined goal.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
GoalDefinitionFeed
Feed tracking is available for the object.
GoalDefinitionHistory
History is available for tracked fields of the object.
GoalDefinitionShare
Sharing is available for the object.


Represents an interaction (phone call, in-person meeting, or video conference) between two or more people (attendees), typically
including at least one representative and one customer or partner.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the account related to the customer or partner who attended the interaction.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description of the interaction.

EndTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time that the interaction ended.

InteractionType

Type
picklist


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of interaction.
Possible values are:
• Conference
• Email
• In Person
• Phone Call

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastSyncedDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when a sync was performed to create or update an interaction from an
email client or other solutions in Salesforce.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

LocationId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The location of the interaction.
Relationship Name
Location


Relationship Type
Lookup
Refers To
Location

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
Required. The name of the interaction.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the record owner.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ReferenceIdentifier

Type
string
Properties
Create, Filter, Group, idLookup, Nillable, Sort, Update
Description
The unique reference ID of the interaction.

RelatedRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The opportunity or financial deal associated with the interaction.
This is a polymorphic relationship field.
Relationship Name
RelatedRecord


Relationship Type
Lookup
Refers To
FinancialDeal, Opportunity

StartTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time that the interaction started.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
InteractionFeed
Feed tracking is available for the object.
InteractionHistory
History is available for tracked fields of the object.
InteractionOwnerSharingRule
Sharing rules are available for the object.
InteractionShare
Sharing is available for the object.

InteractionAttendee
Represents an attendee of an interaction.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Fields
Field

Details

AttendeeResponse

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the response of the attendee to the interaction.
Possible values are:
• Accepted
• Declined
• Awaiting Response

AttendeeType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of attendee.
Possible values are:
• External
• Internal

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact who attended the interaction.
Relationship Name
Contact
Relationship Type
Lookup
Refers To
Contact

EmailAddress

Type
email
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The email address of the attendee.

EventId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The event on Salesforce calendar for this attendee.
Relationship Name
Event
Relationship Type
Lookup
Refers To
Event

InteractionId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
Required. The interaction for which this attendee record is created.
Relationship Name
Interaction
Relationship Type
Master-Detail
Refers To
Interaction

IsOrganizer

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the attendee is the interaction organizer (true) or not (false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp for when the current user last viewed a record related to this record.

LastSyncedDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when a sync was performed to create or update an interaction from an
email client or other solutions in Salesforce.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the interaction attendee.

UserId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The user who attended the interaction.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
InteractionAttendeeFeed
Feed tracking is available for the object.
InteractionAttendeeHistory
History is available for tracked fields of the object.


Represents a junction between an interaction and account that's related to that interaction.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The account of a company that's associated with the interaction.
This field is a relationship field.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account

AccountRole

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the role of the account in the interaction.
Possible values are:
• Audit
• Legal
• Participating
• Primary

Comment

Type
textarea
Properties
Create, Nillable, Update


Description
The description about the account that's associated with the interaction.

InteractionId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
Required. The interaction associated with the account.
This field is a relationship field.
Relationship Name
Interaction
Relationship Type
Lookup
Refers To
Interaction

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the account that's related to the interaction.


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
InteractionRelatedAccountFeed
Feed tracking is available for the object.
InteractionRelatedAccountHistory
History is available for tracked fields of the object.

InteractionSummary
Represents the summary of an interaction, including confidentiality information.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the account related to the customer who attended the client interaction.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account

ConfidentialityType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the level of confidentiality of the information that's recorded in this interaction
summary.
Possible values are:
• Confidential


• Public

InteractionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The client interaction related to the interaction summary.
Relationship Name
Interaction
Relationship Type
Lookup
Refers To
Interaction

InteractionPurpose

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the purpose of the client interaction.
Possible values are:
• Deal Execution
• Meet and Greet
• Quarterly Check-In

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.


MeetingNotes

Type
textarea
Properties
Create, Nillable, Update
Description
The detailed record of what transpired during the client interaction.

MeetingNotesStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the status of the meeting notes. Available in API version 61.0 and later.
Possible values are:
• No
• Yes

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
Required. The title of the interaction summary, capturing the summary of the interaction.

NextSteps

Type
textarea
Properties
Create, Nillable, Update
Description
The next steps that were decided during the interaction.

Offering

Type
multipicklist
Properties
Create, Filter, Nillable, Update
Description
The offerings that were discussed in the client interaction.
Possible values are:
• Debt Capital Markets
• Equity Capital Markets


• Mergers and Acquisitions Advisory

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the record owner.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PartnerAccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the account related to the partner who attended the client interaction.
Relationship Name
Partner Account
Relationship Type
Lookup
Refers To
Account

RelatedRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the record such as an opportunity associated with a client interaction.
This is a polymorphic relationship field.
Relationship Name
RelatedRecord
Relationship Type
Lookup
Refers To
• Application Form - Available in API version 62.0 and later


• Benefit Assignment
• Care Plan
• Case
• Case Participant
• Contact
• Complaint Participant
• Goal Assignment
• Opportunity
• Public Complaint
• Referral
• Service Appointment
• Visit

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the interaction summary.
Possible values are:
• Draft
• Published

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
InteractionSummaryFeed
Feed tracking is available for the object.
InteractionSummaryHistory
History is available for tracked fields of the object.
InteractionSummaryOwnerSharingRule
Sharing rules are available for the object.
InteractionSummaryShare
Sharing is available for the object.

InteractionSumDiscussedAccount
Represents information about the companies discussed in an interaction.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

Comment

Type
textarea
Properties
Create, Nillable, Update
Description
Notes about the account that’s associated with the interaction summary.

DiscussedAccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The company or organization mentioned in the interaction summary.
This is a relationship field.
Relationship Name
DiscussedAccount
Relationship Type
Lookup
Refers To
Account

InteractionSummaryId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
Required. The interaction summary associated with the interaction summary account record.
This is a relationship field.
Relationship Name
InteractionSummary
Relationship Type
Lookup
Refers To
InteractionSummary


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the interaction summary account.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
InteractionSumDiscussedAccountFeed
Feed tracking is available for the object.
InteractionSumDiscussedAccountHistory
History is available for tracked fields of the object.

PublicComplaint
Represents the complaints submitted by public users. This object is available in API version 49.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
ID of the account associated with this complaint.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account

BusinessAddress

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
Address of the business.

BusinessName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Name of the business

CauseSubtype

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The subtype of complaint cause. This field is available in API version 58.0 and later.
Possible value is:
• Misleading advertisement or documentation

CauseType

Type
picklist


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of complaint cause. This field is available in API version 58.0 and later.
Possible value is:
• Product Communication

Comments

Type
textarea
Properties
Create, Nillable, Update
Description
Additional details about the complaint. This field is available in API version 51.0 and later.

CompensationAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
Any amount of money offered to resolve the complaint. This field is available in API version
58.0 and later.

ComplaintCaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
This field is deprecated as of API version 49.0.

ComplaintCaseStatus

Type
picklist
Properties
Defaulted on create, Filter, Group, Nillable, Sort
Description
The status of the related Case. This field is available in API version 58.0 and later.
Possible values are:
• New
• Working
• Escalated
• Closed


The default is New.

ComplaintSubType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Subtype of the complaint.
Possible values are:
• Burns
• Educational Neglect
• Emotional Neglect
• Exploitation
• Fire Safety
• Isolation
• Medical Neglect
• Physical Neglect
• Rough Treatment
• Sexual Activities
• Sexual Exploitation
• Sexual Exposure
• Suffocation
• Terror

ComplaintSummary

Type
textarea
Properties
Create, Nillable, Update
Description
A summary of the complaint information.
This field is available in API version 64.0 and later.

ComplaintType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Type of complaint.
Possible values are:


• Mental Abuse
• Neglect
• Physical Abuse
• Safety
• Sexual Abuse

Description

Type
textarea
Properties
Create, Nillable, Update
Description
Description of the complaint.
Description is filterable and sortable in API version 61.0 and earlier.

Email

Type
email
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Email of the complainant.

EscalationCause

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reason the complaint was escalated. This field is available in API version 58.0 and later.
Possible values are:
• Alleged ADA Violation
• Alleged Discrimination
• Alleged MLA Violation
• Alleged SCRA Violation
• Alleged UDAAP Violation
• Consumer Protection Agency Involvement
• Lawsuit Filed
• Media Involvement
• None
• Received by Executive Leadership
The default is None.


FirstName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
First name of the complainant.

IncidentDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
Date of the incident.

IsComplainantAuthorized Type

boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Whether the person who filed the complaint is an authorized representative of the Account.
This field is available in API version 58.0 and later.
The default value is false.
IsReporterConfidential

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Reporter's request for confidentiality.
The default value is false.

LastName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Last name of the complainant.

LastReferencedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description
The most recent date that a user referenced this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The most recent date that a user viewed this record.

MobileNumber

Type
phone
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Mobile number of the complainant.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the complaint.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the complaint owner.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

Priority

Type
picklist


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Priority of the complaint.
Possible values are:
• Critical
• High
• Low
• Medium

ProductType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The product that the complaint is about. This field is available in API version 58.0 and later.
Possible values are:
• ATM / debit card
• Credit Card or Prepaid Card
• Insurance
• Investments
• Merchant Services
• Mobile / electronic banking
• Money transfers, virtual currency, and money services
• Mortgage / Home Finance
• Other
• Personal Loan / other loans
• Vehicle loan or lease

ReceivedDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date the complaint was received. This field is available in API version 58.0 and later.

ReporterAddress

Type
textarea


Properties
Create, Filter, Nillable, Sort, Update
Description
Address of the reporter for further communication.

ReporterCategory

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Role of the reporter in the organization.
Possible values are:
• Childcare Providers
• Healthcare worker
• Law Enforcement
• Medical Examiners
• Mental Health Professionals
• Other
• School Personnel
• Social Worker
The default value is School Personnel.

ReporterOrganization

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Organization that the reporter is part of.

ResolutionPriority

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Indicates the priority for complaint resolution.
This field is available in API version 64.0 and later.

ShouldInclInRegulatoryRpt Type

boolean


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Whether this complaint must be included in a regulatory report. This field is available in API
version 58.0 and later.
The default value is false.

SourceType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The source of the complaint. This field is available in API version 58.0 and later.
Possible values are:
• Branch
• Consumer Protection Agency
• Contact Centre
• Mobile App
• Regulatory Agency
• Social Media
• Web Chat

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Status of the complaint.
Possible values are:
• In Review
• Resolved
• Submitted

Subject

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Subject of the complaint. This field is available in API version 51.0 and later.


Associated Objects
This object has the following associated objects. Unless noted, they’re available in the same API version as this object.
PublicComplaintFeed
Feed is available for the object.
PublicComplaintHistory
History is available for the object.
PublicComplaintOwnerSharingRule
Sharing rules are available for the object.
PublicComplaintShare
Sharing is available for the object.

Referral
Represents the information on client referrals in an organization. This object is available in API version 56.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AuthorizationStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the authorization status of the referral for the associated provider. Available in API
version 61.0 and later.
Possible values are:
• Authorized
• In Review
• Rejected
• Submitted

CaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The case associated with the referral.


This field is a relationship field.
Relationship Name
Case
Relationship Type
Lookup
Refers To
Case

Category

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The category of referral.

ClientEmail

Type
email
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The email address of the referred client.

ClientId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The account associated with the referred client.
This field is a relationship field.
Relationship Name
Client
Relationship Type
Lookup
Refers To
Account

ClientLanguage

Type
multipicklist
Properties
Create, Filter, Nillable, Update


Description
The languages that the referred client speaks.
Possible values are:
• Arabic
• Chinese
• Dutch
• English
• French
• German
• Hindi
• Portuguese
• Russian
• Spanish

ClientName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the referred client.

ClientPhone

Type
phone
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The phone number of the referred client.

Comments

Type
textarea
Properties
Create, Nillable, Update
Description
Additional details about the referral.

Description

Type
textarea
Properties
Create, Nillable, Update


Description
The description of the referral.

IsSelfReferred

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the referral is made by the client.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
the user might have only accessed this record or list view
(<parmname>LastReferencedDate</parmname>) but not viewed it.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the referral.

OutboundSourceId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The source of an outbound referral.


This field is a polymorphic relationship field.
Relationship Name
OutboundSource
Relationship Type
Lookup
Refers To
Benefit Assignment, Case, Referral

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

Priority

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Indicates the priority of the referral.
Possible values are:
• Critical
• High
• Low
• Medium

ProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program that's associated with the referral.


This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program

ProviderEmail

Type
email
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The email address of the person or the organization that the client is being referred to.

ProviderFacilityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The practitioner or provider facility associated with the referral.
Available in API version 59.0 and later.
This field is a polymorphic relationship field.
Relationship Name
ProviderFacility
Relationship Type
Lookup
Refers To
CareProviderFacilitySpecialty, HealthcarePractitionerFacility

ProviderId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The account or contact associated with the person or the organization that the client is being
referred to.
This field is a polymorphic relationship field.
Relationship Name
Provider


Relationship Type
Lookup
Refers To
Account, Contact, HealthcareProvider

ProviderName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the person or the organization that the client is being referred to.

ProviderOrg

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The organization that the client is being referred to.

ProviderPhone

Type
phone
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The phone number of the person or the organization that the client is being referred to.

RecordTypeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
This field is a relationship field.
Relationship Name
RecordType
Relationship Type
Lookup
Refers To
RecordType

ReferralDate

Type
date


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date on which the referral is received.

ReferralType

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies whether the referral is inbound or outbound.
Possible values are:
• INBOUND—Inbound
• OUTBOUND—Outbound

ReferrerEmail

Type
email
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The email address of the person or the organization that referred the client.

ReferrerId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The account or contact associated with the person or the organization that referred the
client.
This field is a polymorphic relationship field.
Relationship Name
Referrer
Relationship Type
Lookup
Refers To
Account, Contact

ReferrerName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The name of the person or the organization that referred the client.

ReferrerOrg

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The organization that referred the client.

ReferrerPhone

Type
phone
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The phone number of the person or the organization that referred the client.

Result

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The outcome of the referral.

ResultCategory

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the category of the referral result.
Possible values are:
• Approved
• Client Declined Services
• Pending
• Referred Elsewhere
• Rejected

Source

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The source of the referral.
Possible values are:
• Application
• Email
• Message
• Other
• Phone
• Social Media
• Walk-In

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the referral.
Possible values are:
• Approved
• Enrolled
• In Review
• New
• Rejected

Title

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The title of the referral.

UsageType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the usage of the referral.


Case Management Business API

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ReferralFeed
Feed tracking is available for the object.
ReferralHistory
History is available for tracked fields of the object.
ReferralOwnerSharingRule
Sharing rules are available for the object.
ReferralShare
Sharing is available for the object.

Case Management Business API
Case Management Business APIs are RESTful APIs that are sometimes available as Apex classes and
methods.

EDITIONS

Case Management has these resources.

Available in: Lightning
Experience

Resource

Description

/connect/careplan/care-plans/${carePlanId}/tasks Create tasks for

benefits and goals in a
care plan.

Available in: Case
Management is available
with Enterprise, Unlimited,
and Performance Editions
with the Impact Cloud.

/connect/careplan/care-plans/${carePlanId}/tasks Update tasks for

benefits and goals in a
care plan.
/connect/careplan/care-plans/${carePlanId}/tasks Get tasks for benefits

and goals in a care
plan.

REST Reference
You can access Case Management Business APIs using REST endpoints. These REST APIs follow similar conventions as Connect REST
APIs.

REST Reference
You can access Case Management Business APIs using REST endpoints. These REST APIs follow similar conventions as Connect REST
APIs.
To understand the architecture, authentication, rate limits, and how the requests and responses work, see Connect REST API Developer
Guide.
Requests
Here’s a list of Case Management Business API request bodies.


REST Reference

Resources
Here’s a list of Case Management Business API resources.
Responses
Here’s a list of Case Management Business API response bodies.

Requests
Here’s a list of Case Management Business API request bodies.
Create Care Plan Tasks Input
Input representation of the request to create care plan task.
Update Care Plan Tasks Input
Input representation of the request to update care plan task.

Create Care Plan Tasks Input
Input representation of the request to create care plan task.
Root XML tag
<CarePlanTasksInputRepresentation>

JSON example
{
"tasks": {
"records": [
{
"subject": "Update CP Edit GOAL ASSIGNEMENT Task 990",
"dueDate": "2023-19-08T00:00:00.000Z",
"status": "Not Started",
"priority": "Low",
"comment": "Update CP Edit GOAL ASSIGNEMENT Task 990",
"assignedTo": "005xx000001YkA1AAK",
"id": "00Txx000003rMTcEAM"
}
]
}
}

Properties
Parameter
Name

Type

Description

Required or
Optional

carePlanId

String

ID of the care plan or case for a given care Required
team.

56.0

subject

String

Subject of the task assigned to the care
plan.

56.0


Optional

Available
Version

REST Reference

Parameter
Name

Type

Description

Required or
Optional

Available
Version

dueDate

String

Due date of the task assigned to the care Optional
plan.

56.0

status

String

Status of the task assigned to the care plan, Optional
such as In Progress or Completed.

56.0

priority

String

Priority of the task assigned to the care
plan.

Optional

56.0

comment

String

Comments made on the care plan task.

Optional

56.0

assignedTo

String

ID of the user who is assigned the task.

Optional

56.0

id

String

ID of the task record assigned to the care Optional
plan.

56.0

Update Care Plan Tasks Input
Input representation of the request to update care plan task.
Root XML tag
<CarePlanTasksInputRepresentation>

JSON example
{
"tasks": {
"records": [
{
"subject": "Update CP Edit GOAL ASSIGNEMENT Task 990",
"dueDate": "2023-19-08T00:00:00.000Z",
"status": "Not Started",
"priority": "Low",
"comment": "Update CP Edit GOAL ASSIGNEMENT Task 990",
"assignedTo": "005xx000001YkA1AAK",
"id": "00Txx000003rMTcEAM"
}
]
}
}

Properties
Parameter
Name

Type

Description

Required or
Optional

carePlanId

String

ID of the care plan or case for a given care Required
team.

56.0

subject

String

Subject of the task assigned to the care
plan.

56.0


Optional

Available
Version

REST Reference

Parameter
Name

Type

Description

Required or
Optional

Available
Version

dueDate

String

Due date of the task assigned to the care Optional
plan.

56.0

status

String

Status of the task assigned to the care plan, Optional
such as In Progress or Completed.

56.0

priority

String

Priority of the task assigned to the care
plan.

Optional

56.0

comment

String

Comments made on the care plan task.

Optional

56.0

assignedTo

String

ID of the user who is assigned the task.

Optional

56.0

id

String

ID of the task record assigned to the care Optional
plan.

56.0

Resources
Here’s a list of Case Management Business API resources.
Create Care Plan Tasks
Create tasks for the benefits, goals and also at a care plan level.
Update Care Plan Tasks
Resource for updating care plan task.
Get Care Plan Tasks
Resource for getting care plan task.

Create Care Plan Tasks
Create tasks for the benefits, goals and also at a care plan level.
Resource
/connect/careplan/care-plans/${carePlanId}/tasks

Resource example
https://yourInstance.salesforce.com/services/data/v56.0/connect/careplan/care-plans/carePlanId/tasks

Available version
56.0
HTTP methods
POST
Request parameters for POST
Root XML tag
<CarePlanTasksInputRepresentation>


REST Reference

JSON example
{
"tasks": {
"records": [
{
"subject": "Update CP Edit GOAL ASSIGNEMENT Task 990",
"dueDate": "2023-19-08T00:00:00.000Z",
"status": "Not Started",
"priority": "Low",
"comment": "Update CP Edit GOAL ASSIGNEMENT Task 990",
"assignedTo": "005xx000001YkA1AAK",
"id": "00Txx000003rMTcEAM"
}
]
}
}

Properties
Parameter
Name

Type

Description

Required or
Optional

carePlanId

String

ID of the care plan or case for a given care Required
team.

56.0

subject

String

Subject of the task assigned to the care
plan.

Optional

56.0

dueDate

String

Due date of the task assigned to the care Optional
plan.

56.0

status

String

Status of the task assigned to the care
plan, such as In Progress or Completed.

Optional

56.0

priority

String

Priority of the task assigned to the care
plan.

Optional

56.0

comment

String

Comments made on the care plan task.

Optional

56.0

assignedTo

String

ID of the user who is assigned the task.

Optional

56.0

id

String

ID of the task record assigned to the care Optional
plan.

56.0

Response body for POST
Create Care Plan Task Output

Update Care Plan Tasks
Resource for updating care plan task.


Available
Version

REST Reference

Resource
/connect/careplan/care-plans/carePlanId/tasks

Resource example
https://yourInstance.salesforce.com/services/data/v56.0/connect/careplan/care-plans/carePlanId/tasks

Available version
56.0
HTTP methods
PATCH
Request parameters for PATCH
Root XML tag
<CarePlanTasksInputRepresentation>

JSON example
{
"tasks": {
"records": [
{
"subject": "Update CP Edit GOAL ASSIGNEMENT Task 990",
"dueDate": "2023-19-08T00:00:00.000Z",
"status": "Not Started",
"priority": "Low",
"comment": "Update CP Edit GOAL ASSIGNEMENT Task 990",
"assignedTo": "005xx000001YkA1AAK",
"id": "00Txx000003rMTcEAM"
}
]
}
}

Properties
Parameter
Name

Type

Description

Required or
Optional

carePlanId

String

ID of the care plan or case for a given care Required
team.

56.0

subject

String

Subject of the task assigned to the care
plan.

Optional

56.0

dueDate

String

Due date of the task assigned to the care Optional
plan.

56.0

status

String

Status of the task assigned to the care
plan, such as In Progress or Completed.

Optional

56.0

priority

String

Priority of the task assigned to the care
plan.

Optional

56.0


Available
Version

REST Reference

Parameter
Name

Type

Description

Required or
Optional

Available
Version

comment

String

Comments made on the care plan task.

Optional

56.0

assignedTo

String

ID of the user who is assigned the task.

Optional

56.0

id

String

ID of the task record assigned to the care Optional
plan.

56.0

Response body for PATCH
Update Care Plan Task Output

Get Care Plan Tasks
Resource for getting care plan task.
Resource
/connect/careplan/care-plans/carePlanId/tasks

Resource example
https://yourInstance.salesforce.com/services/data/v56.0/connect/careplan/care-plans/carePlanId/tasks

Available version
56.0
HTTP methods
GET
Response body for GET
Get Care Plan Task Output

Responses
Here’s a list of Case Management Business API response bodies.
Create Care Plan Task
Output representation of the request to create a care plan task.
Update Care Plan Task
Output representation of the request to update a care plan task.
Get Care Plan Tasks
Output representation of the request to get care plan task.

Create Care Plan Task
Output representation of the request to create a care plan task.


REST Reference

Property Name

Type

Description

Filter Group and
Version

Available Version

message

String

The message that provides the request
response details.

Small, 56.0

56.0

success

Boolean

Indicates whether the request was
successful (true) or not (false).

Small, 56.0

56.0

Update Care Plan Task
Output representation of the request to update a care plan task.
Property Name

Type

Description

Filter Group and
Version

Available Version

message

String

The message that provides the request
response details.

Small, 56.0

56.0

success

Boolean

Indicates whether the request was
successful (true) or not (false).

Small, 56.0

56.0

Get Care Plan Tasks
Output representation of the request to get care plan task.
JSON example
{
"carePlanTasks": {
"adhocTasks": {
"records": [
{
"subject": "Adhoc Task 19087899",
"dueDate": "2022-08-09T00:00:00.000Z",
"status": "In Progress",
"priority": "High",
"comment": "First Adhoc task 19082343254325",
"assignedTo": "005xx000001YkA1AAK"
},
{
"subject": "Adhoc Task 290889999",
"dueDate": "2022-08-31T00:00:00.000Z",
"status": "Not Started",
"priority": "High",
"comment": "Second Adhoc task 29083424324",
"assignedTo": "005xx000001YkA1AAK"
},
{
"subject": "Adhoc Task 390821324324",
"dueDate": "2022-08-08T00:00:00.000Z",
"status": "Not Started",
"priority": "Low",


REST Reference

"comment": "Third Adhoc task 39082343243245",
"assignedTo": "005xx000001YkA1AAK"
}
]
}
}
}

Properties
Property Name

Type

Description

Filter Group and Available
Version
Version

subject

String

Subject of the task assigned to the care
plan.

Small, 56.0

56.0

dueDate

String

Due date of the task assigned to the care Small, 56.0
plan.

56.0

status

String

Status of the task assigned to the care plan, Small, 56.0
such as In Progress or Completed.

56.0

priority

String

Priority of the task assigned to the care
plan.

Small, 56.0

56.0

comment

String

Comments made on the care plan task.

Small, 56.0

56.0

assignedTo

String

ID of the user who is assigned the task.

Small, 56.0

56.0


# Chapter 6: Outcome Management

In this chapter ...
•

ImpactStrategy

•

ImpactStrategyAssignment

•

IndicatorAssignment

•

IndicatorDefinition

•

IndicatorPerformancePeriod

•

IndicatorResult

•

Outcome

•

OutcomeActivity

•

TimePeriod

•

UnitOfMeasure

Outcome Management Standard Objects
The Outcome Management data model provides objects and fields to define, measure, and evaluate an
organization’s outcome strategy.


Represents a high-level strategy to affect change in an individual, population, stakeholder, or the environment. This object is available
in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available in products that include the Outcome Management license where Outcome Management is enabled and the
Manage Outcomes system permission is assigned to users.

Fields
Field

Details

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description about the impact strategy.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last referenced this impact strategy.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last viewed this impact strategy.

Level

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
Specifies the level or scope of the impact strategy.
Possible values are:
• Department
• Organizational
• Program

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the impact strategy.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the user who owns the impact strategy.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentImpactStrategyId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The associated parent impact strategy.
This field is a relationship field.
Relationship Name
ParentImpactStrategy
Relationship Type
Lookup


Refers To
ImpactStrategy

Status

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the status of the impact strategy.
Possible values are:
• Active
• Canceled
• Completed
• Planned

Type

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the type of the impact strategy.
Possible values are:
• External Requirement
• Logic Model
• Strategic Plan
• Theory of Change

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ImpactStrategyFeed
Feed tracking is available for the object.
ImpactStrategyHistory
History is available for tracked fields of the object.
ImpactStrategyOwnerSharingRule
Sharing rules are available for the object.
ImpactStrategyShare
Sharing is available for the object.


Represents the connection between the impact strategy and the outcome or other object related to the impact strategy. This object is
available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available in products that include the Outcome Management license where Outcome Management is enabled and the
Manage Outcomes system permission is assigned to users.

Fields
Field

Details

ImpactStrategyId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The impact strategy associated with this impact strategy assignment.
This field is a relationship field.
Relationship Name
ImpactStrategy
Relationship Type
Master-Detail
Refers To
ImpactStrategy

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last referenced this impact strategy assignment.


LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last viewed this impact strategy assignment.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The unique number of the impact strategy assignment.

OutcomeId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The outcome associated with this impact strategy assignment.
This field is a relationship field.
Relationship Name
Outcome
Relationship Type
Lookup
Refers To
Outcome

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ImpactStrategyAssignmentFeed
Feed tracking is available for the object.
ImpactStrategyAssignmentHistory
History is available for tracked fields of the object.


Represents the assignment of an indicator definition that's used to measure the performance of an outcome or a related activity. This
object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
• This object is available in products that include the Outcome Management license where Outcome Management is enabled and
the Manage Outcomes system permission is assigned to users.
• This object is available in Net Zero Cloud with a Growth license where the Manage Environmental, Social, and Governance Programs
system permission is assigned to users.

Fields
Field

Details

ApplicationFormId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The application form associated with the funding award.
This field is a relationship field.
This field is available from API version 67.0 and later.
Relationship Name
ApplicationForm
Refers To
ApplicationForm

IndicatorAssignmentType Type

picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the object that the indicator assignment measures.
Possible values are:


• Outcome
• Program

IndicatorDefinitionId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The indicator definition that's associated with the indicator assignment.
This field is a relationship field.
Relationship Name
IndicatorDefinition
Relationship Type
Master-Detail
Refers To
IndicatorDefinition

IntendedDirection

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the intended direction of change in the behavior, knowledge, skills, status, or level
of functioning that's detailed in the parent indicator definition.
Possible values are:
• Decrease
• Increase
• Maintain

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the indicator assignment.

OutcomeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outcome that the indicator assignment measures.
This field is a relationship field.
Relationship Name
Outcome
Relationship Type
Lookup
Refers To
Outcome

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The owner of this indicator assignment.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ProgramId

Type
reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program that the indicator assignment measures.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program

Status

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the status of the indicator assignment.
Possible values are:
• Active
• Canceled
• Completed
• Planned

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndicatorAssignmentFeed
Feed tracking is available for the object.
IndicatorAssignmentHistory
History is available for tracked fields of the object.
IndicatorAssignmentOwnerSharingRule
Sharing rules are available for the object.
IndicatorAssignmentShare
Sharing is available for the object.


Represents information about the indicator assignment and the process of measuring and calculating the indicator results. This object
is available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
• This object is available in products that include the Outcome Management license where Outcome Management is enabled and
the Manage Outcomes system permission is assigned to users.
• This object is available in Net Zero Cloud with a Growth license where the Manage Environmental, Social, and Governance Programs
system permission is assigned to users.

Fields
Field

Details

Description

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the indicator definition.

FlowDefinitionApiName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The API name of the flow definition associated with the indicator definition. This field is
available from API version 60.0 and later.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last referenced this indicator definition.


LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last viewed this indicator definition.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the indicator definition.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the user who owns the outcome.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

Status

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the status of the indicator definition.
Possible values are:
• Active
• Canceled
• Completed
• Planned


UnitOfMeasureId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The unit of measure for the target, baseline, and result values that are associated with this
indicator definition.
This field is a relationship field.
Relationship Name
UnitOfMeasure
Relationship Type
Lookup
Refers To
UnitOfMeasure

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndicatorDefinitionFeed
Feed tracking is available for the object.
IndicatorDefinitionHistory
History is available for tracked fields of the object.
IndicatorDefinitionOwnerSharingRule
Sharing rules are available for the object.
IndicatorDefinitionShare
Sharing is available for the object.

IndicatorPerformancePeriod
Represents information about a specified time period including the frequency at which indicator results should be calculated and the
baseline value of the indicator. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Special Access Rules
• This object is available in products that include the Outcome Management license where Outcome Management is enabled and
the Manage Outcomes system permission is assigned to users.
• This object is available in Net Zero Cloud with a Growth license where the Manage Environmental, Social, and Governance Programs
system permission is assigned to users.

Fields
Field

Details

BaselineDescription

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the baseline value.

BaselineValue

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the indicator assignment at the beginning of the indicator performance period.

Description

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the indicator performance period.

IndicatorAssignmentId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The indicator assignment that’s associated with the indicator performance period.
This field is a relationship field.
Relationship Name
IndicatorAssignment
Relationship Type
Master-Detail


Refers To
IndicatorAssignment

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastResultMeasurementDate Type

date
Properties
Filter, Group, Nillable, Sort
Description
The date when the last result value was measured.
This field is a calculated field.
LastResultValue

Type
double
Properties
Filter, Nillable, Sort
Description
The result value from the most recently measured indicator result.
This field is a calculated field.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the indicator performance period.


TargetProgress

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the progress of the target within the time period.
Possible values are:
• At Risk
• Complete
• Not Met
• Not Started
• On Track

TargetValue

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The target value of the indicator assignment within the time period.

TimePeriodId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The time period that is associated with the indicator performance period.
This field is a relationship field.
Relationship Name
TimePeriod
Relationship Type
Lookup
Refers To
TimePeriod

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndicatorPerformancePeriodFeed
Feed tracking is available for the object.


History is available for tracked fields of the object.

IndicatorResult
Represents the result of an indicator assignment for the specified time period that can be used to track the performance of the indicator.
This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
• This object is available in products that include the Outcome Management license where Outcome Management is enabled and
the Manage Outcomes system permission is assigned to users.
• This object is available in Net Zero Cloud with a Growth license where the Manage Environmental, Social, and Governance Programs
system permission is assigned to users.

Fields
Field

Details

CalculationMethod

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Determines whether the indicator result was added manually or calculated by automation.
This field is available from API version 60.0 and later.
Possible values are:
• AutomaticallyCalculated
• Manual

Denominator

Type
double
Properties
Create, Filter, Nillable, Sort


Description
The denominator in automatically-calculated results that are an average or percent. This field
is available from API version 60.0 and later.

Description

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the indicator result.

FlowDefinitionApiName

Type
string
Properties
Create, Filter, Group, Nillable, Sort
Description
The API name of the flow definition associated with this indicator result. This field is available
from API version 60.0 and later.

FlowVersion

Type
int
Properties
Create, Filter, Group, Nillable, Sort
Description
The version of the flow that calculated this result. This field is available from API version 60.0
and later.

IndicatorPerformancePeriodId Type

reference
Properties
Create, Filter, Group, Sort
Description
The indicator performance period for which the result is defined.
This field is a relationship field.
Relationship Name
IndicatorPerformancePeriod
Relationship Type
Master-Detail
Refers To
IndicatorPerformancePeriod


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last referenced this indicator result.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last viewed this indicator result.

MeasurementDate

Type
date
Properties
Create, Filter, Group, Sort, Update
Description
The date on which the indicator result is measured.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the indicator result.

Numerator

Type
double
Properties
Create, Filter, Nillable, Sort
Description
The numerator in automatically-calculated results that are an average or percent. This field
is available from API version 60.0 and later.

ResultValue

Type
double
Properties
Create, Filter, Sort, Update


Description
The result for the indicator performance period.

Type

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of the result for the time period.
Possible values are:
• Final
• Interim

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndicatorResultFeed
Feed tracking is available for the object.
IndicatorResultHistory
History is available for tracked fields of the object.

Outcome
Represents information about the expected change in participants that is driven by the organization's activity. This object is available in
API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available in products that include the Outcome Management license where Outcome Management is enabled and the
Manage Outcomes system permission is assigned to users.


Fields
Field

Details

Description

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the outcome.

IntendedDirection

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the intended direction of change in the behavior, knowledge, skills, status, or level
of functioning that's detailed in the outcome.
Possible values are:
• Decrease
• Increase
• Maintain

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last referenced this outcome.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last viewed this outcome.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the outcome.


OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the user who owns the outcome.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

SourceName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the source that initially defined the outcome. For example, United Nations
Sustainable Development Goals (UNSDG).

Status

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the status of the outcome.
Possible values are:
• Active
• Canceled
• Completed
• Planned

Term

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the term for which the outcome is defined.


Possible values are:
• Long-Term
• Medium-Term
• Short-Term

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
OutcomeFeed
Feed tracking is available for the object.
OutcomeHistory
History is available for tracked fields of the object.
OutcomeOwnerSharingRule
Sharing rules are available for the object.
OutcomeShare
Sharing is available for the object.

OutcomeActivity
Represents a junction between Outcome and the object that's related to the activity undertaken by an organization to achieve that
outcome. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available in products that include the Outcome Management license where Outcome Management is enabled and the
Manage Outcomes system permission is assigned to users.

Fields
Field

Details

ApplicationFormId

Type
reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The application form associated with the funding award.
This field is a relationship field.
This field is available from API version 67.0 and later.
Relationship Name
ApplicationForm
Refers To
ApplicationForm

BenefitId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The benefit that's associated with the outcome.
This field is a relationship field.
Relationship Name
Benefit
Relationship Type
Lookup
Refers To
Benefit

GoalDefinitionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The goal definition that's associated with the outcome. This field is available from API version
60.0 and later.
This field is a relationship field.
Relationship Name
GoalDefinition
Relationship Type
Lookup
Refers To
GoalDefinition


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last referenced this outcome activity.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last viewed this outcome activity.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the outcome activity.

OutcomeActivityType

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
The type of activity that's associated with the outcome, such as program, benefit.
Possible values are:
• Benefit
• Goal Definition This value is available from API version 60.0 and later.
• Program

OutcomeId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The outcome that's associated with the outcome activity.
This field is a relationship field.
Relationship Name
Outcome


Relationship Type
Master-Detail
Refers To
Outcome

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The owner of the record.
This field is a polymorphic relationship field.
This field is available from API version 63.0 and later.
Relationship Name
Owner
Refers To
Group, User

ProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program that's associated with the outcome.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
OutcomeActivityShare
Sharing is available for the object.
OutcomeActivityOwnerSharingRule
Sharing rules are available for the object.


Feed tracking is available for the object.
OutcomeActivityHistory
History is available for tracked fields of the object.

TimePeriod
Represents the time period that's used to calculate the indicator performance and result. This object is available in API version 59.0 and
later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
• This object is available in products that include the Outcome Management license where Outcome Management is enabled and
the Manage Outcomes system permission is assigned to users.
• This object is available in Net Zero Cloud with a Growth license where the Manage Environmental, Social, and Governance Programs
system permission is assigned to users.

Fields
Field

Details

EndDate

Type
dateTime
Properties
Create, Filter, Sort, Update
Description
The end date and time of the time period.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
Date and time when a user last referenced this time period.

LastViewedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description
Date and time when a user last viewed this time period.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the time period.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the user who owns the time period.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

StartDate

Type
dateTime
Properties
Create, Filter, Sort, Update
Description
The start date and time of the time period.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
TimePeriodFeed
Feed tracking is available for the object.
TimePeriodHistory
History is available for tracked fields of the object.


Sharing rules are available for the object.
TimePeriodShare
Sharing is available for the object.

UnitOfMeasure
Represents the unit of measures for care metrics and care observations. This object is available in API version 49.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of this unit of measure.

ConversionFactor

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The factor or rate that's used to convert this unit of measurement to the base unit.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of this unit of measure.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the user who owns this record.

Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The type of the unit of measure. For example, weight, distance, period.

Sequence

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The sequence number assigned to the unit of measure.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the status of the unit of measure.
Possible values are:
• Active
• Draft


• Inactive

UnitCode

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
The code for this unit of measure. For example, mm[Hg], mcg/mL., kgs, lbs.

UnitOfMeasureClassId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The class associated with the unit of measurement.
This field is a relationship field.
Relationship Name
UnitOfMeasureClass
Refers To
UnitOfMeasureClass

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
UnitOfMeasureChangeEvent (API version 59.0)
Change events are available for the object.
UnitOfMeasureOwnerSharingRule
Sharing rules are available for the object.
UnitOfMeasureShare
Sharing is available for the object.


# Chapter 7: Grantmaking

In this chapter ...
•

Grantmaking Object
Reference

•

Grantmaking Fields
on Other Objects

•

Grantmaking Tooling
API Object

•

Grantmaking
Metadata API Types

Grantmaking
This guide provides information about the objects and APIs that
Grantmaking uses.

EDITIONS
Available in: Lightning
Experience
Available in:
Enterprise, Unlimited,
and Developer Editions


Grantmaking Object Reference

Grantmaking Object Reference
The Grantmaking data model provides objects and fields to calculate and manage grants for your
organization.
ApplicationDecision
Represents a final decision performed for the specified Application. This object is available in
API version 56.0 and later.
ApplicationRenderMethod
Represents how a part of an application can be rendered. This object is available in Grantmaking
API version 61.0 and later.
ApplicationReview
Represents a review performed against a specified Individual Application. This object is available
in API version 56.0 and later.

EDITIONS
Available in: Lightning
Experience
Available in: Enterprise,
Performance, and
Unlimited Editions in
Nonprofit Cloud for
Grantmaking
Available in: Enterprise,
Performance, Unlimited,
and Developer Editions in
Public Sector Solutions

ApplicationStageDefinition
Represents a stage of an application. This object is available in Grantmaking API version 61.0
and later.
ApplicationTimeline
Represents the milestone dates in the application process. This object is available in API version 57.0 and later.
Budget
Tracks an estimate of future revenue or expenses during a specific time period. This object is available in API version 53.0 and later.
BudgetAllocation
Represents a subsection of a Budget that shows where allocated resources are being applied. This object is available in API version
53.0 and later.
BudgetCategory
Represents the purpose of the budget line item. This object is available in API version 57.0 and later.
BudgetCategoryValue
Captures budget values for category and time period. This object is available in API version 57.0 and later.
BudgetParticipant
Represents information about a user or group of participants who have access to a budget. This object is available in API version
59.0 and later.
BudgetPeriod
Defines a distinct time interval in which the estimate applies. This object is available in API version 57.0 and later.
FundingAward
Represents an award given to an individual or organization to facilitate a goal related to the funder’s mission. This object is available
in API version 57.0 and later.
FundingAwardAmendment
Represents a modification to the scope or finances of a previously approved award. This object is available in API version 57.0 and
later.
FundingAwardParticipant
Represents information about a user or group of participants who have access to a funding award. This object is available in API
version 59.0 and later.


Represents a deliverable or milestone for a funding award or funding disbursement. This object is available in API version 57.0 and
later.
FundingAwardRqmtSection
Represents a part of a funding award requirement to be completed or reviewed. This object is available in API version 62.0 and later.
FundingDisbursement
Represents a payment that has been made or scheduled to be made to a funding recipient. This object is available in API version
57.0 and later.
FundingOpportunity
The pool of money available for distribution for a specific purpose. This object is available in API version 57.0 and later.
FundingOppParticipant
Represents information about a user or group of participants who have access to a funding opportunity. This object is available in
API version 60.0 and later.
IndicatorAssignment
Represents the assignment of an indicator definition that's used to measure the performance of an outcome or a related activity
This object is available in API version 59.0 and later.
IndicatorPerformancePeriod
Represents information about a specified time period including the frequency at which indicator results should be calculated and
the baseline value of the indicator. This object is available in API version 59.0 and later.
IndividualApplication
Represents an application form submitted by an individual or organization. This object is available in API version 50.0 and later.
IndividualApplicationTask
Represents a task related to an application. This object is available in Grantmaking API version 61.0 and later.
IndvApplicationTaskParticipant
Represents information about a user or group of participants who have read or write access to an individual application task. This
object is available in API version 61.0 and later.
IndividualApplnParticipant
Represents information about a user or group of participants who have access to a individual application. This object is available in
API version 59.0 and later.
OutcomeActivity
Represents a junction between an outcome and the object that's related to the activity undertaken by an organization to achieve
that outcome. This object is available in API version 59.0 and later.
PreliminaryApplicationRef
Represents the saved applications and pre-screening forms. This object is available in API version 49.0 and later.
Program
Represents information about the enrollment and disbursement of benefits in a program. This object is available in API version 57.0
and later.

ApplicationDecision
Represents a final decision performed for the specified Application. This object is available in API version 56.0 and later.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Application system permission
is assigned to users.

Fields
Field

Details

ApplicationDecision

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the decision for the application.
Possible values are:
• Award
• Deny

ApplicationId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The ID of the application.
This field is a polymorphic relationship field.
Relationship Name
Application
Relationship Type
Lookup
Refers To
IndividualApplication

Comment

Type
textarea
Properties
Create, Nillable, Update
Description
The information about the decision provided on the application.


DecisionAuthorityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The user responsible for the application decision.
This field is a relationship field.
Relationship Name
DecisionAuthority
Relationship Type
Lookup
Refers To
User

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the preliminary application.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner who owns the record.


This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PreliminaryApplicationRefId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the preliminary application reference.
This field is a relationship field.
Relationship Name
PreliminaryApplicationRef
Relationship Type
Lookup
Refers To
PreliminaryApplicationRef

ApplicationRenderMethod
Represents how a part of an application can be rendered. This object is available in Grantmaking API version 61.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Applications system permission
is assigned to users.

Fields
Field

Details

Description

Type
textarea


Properties
Create, Nillable, Update
Description
The description of the application render method.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

MethodName

Type
textarea
Properties
Create, Nillable, Update
Description
The name of the render method associated with the application.

MethodRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The record ID of the method that's associated with the application render method.
This field is a polymorphic relationship field.
Relationship Name
MethodRecord
Relationship Type
Lookup
Refers To
OmniProcess, OmniUiCard


MethodType

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies the type of method that's used to render components in the application.
Possible values are:
• FlexCard
• Flow
• OmniScript

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the application render method.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the user who owns the record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

UsageType

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Specifies the usage type of the application render method.
Possible values are:
• FormFramework This value is available from API version 63.0 and later.


• Grantmaking
• Program This value is available from API version 65.0 and later.
• Volunteer This value is available from API version 65.0 and later.
The default is FormFramework.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ApplicationRenderMethodFeed
Feed tracking is available for the object.
ApplicationRenderMethodHistory
History is available for tracked fields of the object.
ApplicationRenderMethodShare
Sharing is available for the object.

ApplicationReview
Represents a review performed against a specified Individual Application. This object is available in API version 56.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Application system permission
is assigned to users.

Fields
Field

Details

ApplicationCategory

Type
picklist
Properties
Filter, Group, Nillable, Sort
Description
Specifies the category of the application based on the decision period.
Possible values are:
• Basic


• Special

ApplicationId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The individual application associated with the application review.
This field is a polymorphic relationship field.
Relationship Name
Application
Relationship Type
Lookup
Refers To
IndividualApplication

ApplicationRecommendation Type

picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the reviewer's recommended outcome of the application.
Possible values are:
• Ask for Revisions
• Award
• Deny
ApplicationStageDefinitionId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The application stage definition that's associated with the application review.
This field is a relationship field.
Relationship Name
ApplicationStageDefinition
Relationship Type
Lookup
Refers To
ApplicationStageDefinition


AssignedDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application was assigned to the reviewer.

AssignedUserId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Identifies the user assigned to perform the review.
This field is a relationship field.
Relationship Name
AssignedUser
Relationship Type
Lookup
Refers To
User

Comment

Type
textarea
Properties
Create, Nillable, Update
Description
The information about the review provided on the application.

Condition

Type
textarea
Properties
Create, Nillable, Update
Description
The condition that's applicable to an applicant.

DisplayOrder

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The order in which the application review shows on a form.


DueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The last date by which the application review should be completed.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application review was completed.

IsAssignedToMe

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Indicates whether the application review is assigned to the user who's logged in.
The default value is false.
This field is a calculated field.

IsRequired

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the application review is required (true) or not (false).
The default value is false.

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the application review has been submitted.
This field is available from API version 58.0 and later.
The default value is true.


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the application being reviewed.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The owner associated with this application review.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ReviewedById

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The user who reviewed the application.


This field is a relationship field.
Relationship Name
ReviewedBy
Relationship Type
Lookup
Refers To
User

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application review started.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the application review.
Possible values are:
• Canceled
• Completed
• Draft This value is available from API version 63.0 and later.
• In Progress
• Not Started

SubmissionDate

Type
date
Properties
Filter, Group, Nillable, Sort
Description
The date when the applicant submitted the application.

Title

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The descriptive name for the application review.


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ApplicationReviewFeed
Feed tracking is available for the object.
ApplicationReviewHistory
History is available for tracked fields of the object.
ApplicationReviewOwnerSharingRule
Sharing rules are available for the object.
ApplicationReviewShare
Sharing is available for the object.

ApplicationStageDefinition
Represents a stage of an application. This object is available in Grantmaking API version 61.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Applications system permission
is assigned to users.

Fields
Field

Details

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description of the application stage definition.

EditTypeAppRenderMethodId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The render method for an editable form or application that's associated with this application
stage definition.


This field is a relationship field.
Relationship Name
EditTypeAppRenderMethod
Relationship Type
Lookup
Refers To
ApplicationRenderMethod

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the application stage definition.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the user who owns the record.
This field is a polymorphic relationship field.
Relationship Name
Owner


Relationship Type
Lookup
Refers To
Group, User

Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of the application stage definition.
Possible values are:
• FormFramework This value is available from API version 63.0 and later.
• Grantmaking
• Program This value is available from API version 65.0 and later.
• Volunteer This value is available from API version 65.0 and later.

ViewTypeAppRenderMethodId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The render method for a read-only form or application that's associated with this application
stage definition.
This field is a relationship field.
Relationship Name
ViewTypeAppRenderMethod
Relationship Type
Lookup
Refers To
ApplicationRenderMethod

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ApplicationStageDefinitionFeed
Feed tracking is available for the object.
ApplicationStageDefinitionHistory
History is available for tracked fields of the object.


Sharing is available for the object.

ApplicationTimeline
Represents the milestone dates in the application process. This object is available in API version 57.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Application system permission
is assigned to users.

Fields
Field

Details

ApplicationCloseDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The last date when applicants can apply for a grant.

ApplicationOpenDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when applicants can start to apply for a grant.

DecisionReleaseDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application decision is announced.

LastReferencedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
Name of the application timeline being reviewed.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner who owns the record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies which feature this application timeline record belongs to.
Possible values are:
• Grantmaking


Tracks an estimate of future revenue or expenses during a specific time period. This object is available in API version 53.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grants Management or Grantmaking license is enabled, Grants Management or Grantmaking is enabled,
and the Manage Budgets system permission is assigned to users.

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The account associated with the budget.
This field is available from API version 58.0 and later.
This field is a relationship field.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account

Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total amount of funds for a budget shown in currency format.

EstimatedUtilizationAmount Type

currency
Properties
Create, Filter, Nillable, Sort, Update


Description
The amount that's estimated to be utilized from the budget.

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the budget and its related business processes.

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the budget has been submitted. This field is available from API version
58.0 and later.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
Name of the budget.

OwnerId

Type
reference


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner who owns the record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentBudgetId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
ID of the associated parent budget.
This field is available from API version 56.0 and later.
This field is a relationship field.
Relationship Name
ParentBudget
Relationship Type
Lookup
Refers To
Budget

PeriodEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end of the date range for which the budget applies.

PeriodName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the time period to which the budget applies.


PeriodStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The beginning of the date range for which the budget applies.

ProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program associated with the budget.
This field is available from API version 58.0 and later.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program

Quantity

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The quantity used to track a budget for non-currency projects. For example, this could be
number of hours or number of resources.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the budget.
Possible values are:
• Active
• Archived
• Planned


Type

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Categorizes the budget by how it will be used.
Possible values are:
• Department
• Program
• Project

UtilizedAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount that has already been utilized from the budget.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
BudgetFeed
Feed tracking is available for the object.
BudgetHistory
History is available for tracked fields of the object.
BudgetOwnerSharingRule
Sharing rules are available for the object.
BudgetShare
Sharing is available for the object.

BudgetAllocation
Represents a subsection of a Budget that shows where allocated resources are being applied. This object is available in API version 53.0
and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grants Management or Grantmaking license is enabled, Grants Management or Grantmaking is enabled,
and the Manage Budgets system permission is assigned to users.

Fields
Field

Details

Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total amount of allocated funds.

BudgetCategoryValueId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The budget category value that's associated with the grants allocation.
This field is a relationship field.
Relationship Name
BudgetCategoryValue
Relationship Type
Lookup
Refers To
BudgetCategoryValue

BudgetId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The budget that this allocation is related to.
This field is a relationship field.
Relationship Name
Budget


Relationship Type
Master-Detail
Refers To
Budget

FundingDisbursementId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding disbursement associated with the budget allocation.
This field is available from API version 58.0 and later.
This field is a relationship field.
Relationship Name
FundingDisbursement
Relationship Type
Lookup
Refers To
FundingDisbursement

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
A descriptive name for the allocation.


Quantity

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total quantity amount allocated for non-currency projects.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the budget allocation.
Possible values are:
• Allocated
• Committed
• Finalized

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
BudgetAllocationFeed
Feed tracking is available for the object.
BudgetAllocationHistory
History is available for tracked fields of the object.

BudgetCategory
Represents the purpose of the budget line item. This object is available in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Budgets system permission
is assigned to users.

Fields
Field

Details

BudgetId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The parent budget that's associated with the budget category.
This field is a relationship field.
Relationship Name
Budget
Relationship Type
Master-Detail
Refers To
Budget

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the budget category.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.


Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the budget category.

Reason

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reason why an item is being included in the budget.

SequenceNumber

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The number assigned to a budget category that's used to edit or show a category.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
BudgetCategoryFeed
Feed tracking is available for the object.
BudgetCategoryHistory
History is available for tracked fields of the object.

BudgetCategoryValue
Captures budget values for category and time period. This object is available in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Budgets system permission
is assigned to users.

Fields
Field

Details

ActualAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The actual amount of the budget that was used.
This field is available from API version 59.0 and later.

ActualQuantity

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The actual quantity of the budget that was used.
This field is available from API version 59.0 and later.

Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The planned amount for the budget.

BudgetCategoryId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The ID that's associated with this budget category value.
This field is a relationship field.
Relationship Name
BudgetCategory
Relationship Type
Master-Detail


Refers To
BudgetCategory

BudgetDivisionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The budget period that's associated with the budget category value.
This field is a relationship field.
Relationship Name
BudgetDivision
Relationship Type
Lookup
Refers To
BudgetPeriod

Comments

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The comments about how the budget was used.
This field is available from API version 59.0 and later.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string


Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of this budget category value.

Quantity

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The planned quantity for the budget. Use when establishing budgets for non-currency
projects.

VarianceAmount

Type
currency
Properties
Filter, Nillable, Sort
Description
The amount over or under the planned budget that was used.
This field is available from API version 59.0 and later.
This field is a calculated field.

VarianceQuantity

Type
double
Properties
Filter, Nillable, Sort
Description
The quantity over or under the planned budget that was used.
This field is available from API version 59.0 and later.
This field is a calculated field.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
BudgetCategoryValueFeed
Feed tracking is available for the object.
BudgetCategoryValueHistory
History is available for tracked fields of the object.


Represents information about a user or group of participants who have access to a budget. This object is available in API version 59.0
and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), update(), upsert()

Special Access Rules
Example: This object is accessible only when the Grantmaking license is on, Grantmaking is active, Compliant Data Sharing is
on, and users have the Managed Funding Awards system permission.

Fields
Field

Details

BudgetId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The budget associated with the budget participant.
This field is a relationship field.
Relationship Name
Budget
Relationship Type
Master-Detail
Refers To
Budget

Comments

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The comments about why the participant has access to the budget.

IsParticipantActive

Type
boolean


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the budget participant is currently active (true) or not (false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the budget participant.

ParticipantId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The participant associated with the budget.
This field is a polymorphic relationship field.
Relationship Name
Participant
Relationship Type
Lookup
Refers To
Group, User


ParticipantRoleId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The participant role associated with the budget participant.
This field is a relationship field.
Relationship Name
ParticipantRole
Relationship Type
Lookup
Refers To
ParticipantRole

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
BudgetParticipantFeed
Feed tracking is available for the object.
BudgetParticipantHistory
History is available for tracked fields of the object.

BudgetPeriod
Defines a distinct time interval in which the estimate applies. This object is available in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Budgets system permission
is assigned to users.


Fields
Field

Details

BudgetId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The parent budget that's associated with the budget period.
This field is a relationship field.
Relationship Name
Budget
Relationship Type
Master-Detail
Refers To
Budget

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the budget has been submitted. This field is available from API version
59.0 and later.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string


Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the budget period.

PeriodEndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the budget period ends.

PeriodStartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the budget period.

SequenceNumber

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The order in which the budget period is shown.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
BudgetPeriodFeed
Feed tracking is available for the object.
BudgetPeriodHistory
History is available for tracked fields of the object.

FundingAward
Represents an award given to an individual or organization to facilitate a goal related to the funder’s mission. This object is available in
API version 57.0 and later.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.

Fields
Field

Details

Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total award amount.

ApplicationFormId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The application form associated with the funding award.
This field is a relationship field.
This field is available from API version 66.0 and later.
Relationship Name
ApplicationForm
Refers To
ApplicationForm

AwardNumber

Type
string
Properties
Autonumber, Defaulted on create, Filter, Sort
Description
The unique identifier of the funding award in the customer's org.

AwardeeId

Type
reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The entity related to the funding award. The account can be an organization (business
account) or individual (person account) that receives the funding.
This field is a relationship field.
Relationship Name
Awardee
Relationship Type
Lookup
Refers To
Account

BudgetId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The budget that's used to track the use of the award funding.
This field is a relationship field.
Relationship Name
Budget
Relationship Type
Lookup
Refers To
Budget

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The individual receiving the funding award.
This field is a relationship field.
Relationship Name
Contact
Relationship Type
Lookup
Refers To
Contact


ContractId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contract associated with the funding award.
This field is available from API version 59.0 and later.
This field is a relationship field.
Relationship Name
Contract
Relationship Type
Lookup
Refers To
Contract

DecisionDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time of the decision about the funding award.

EndDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the contract related to the award ends.

FundingOpportunityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding opportunity that's associated with the award.
This field is a relationship field.
Relationship Name
FundingOpportunity
Relationship Type
Lookup


Refers To
FundingOpportunity

IndividualApplicationId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The individual application that's related to the award.
This field is a relationship field.
Relationship Name
IndividualApplication
Relationship Type
Lookup
Refers To
IndividualApplication
LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the funding award.

OwnerId

Type
reference


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner who owns the record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentFundingAwardId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The parent funding award for this funding award.
This field is a relationship field.
Relationship Name
ParentFundingAward
Relationship Type
Lookup
Refers To
FundingAward

ProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program associated with the funding award.
This field is available from API version 58.0 and later.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program


StartDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the contract related to the award begins.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the current status of the award.
Possible values are:
• Active
• Cancelled
• Completed

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
FundingAwardFeed
Feed tracking is available for the object.
FundingAwardHistory
History is available for tracked fields of the object.
FundingAwardOwnerSharingRule
Sharing rules are available for the object.
FundingAwardShare
Sharing is available for the object.

FundingAwardAmendment
Represents a modification to the scope or finances of a previously approved award. This object is available in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.

Fields
Field

Details

AdjustedAwardAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The actual amount that's approved for adjustment in the funding award amount.

AdjustedEndDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The actual date of adjustment to the end date of the funding award.

ApprovalStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the approval status of the requested adjustment.
Possible values are:
• Approved
• In Review
• New
• Rejected

Comments

Type
textarea
Properties
Create, Nillable, Update
Description
The comment about the approval or rejection of the adjustment request.


ContractId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The amended contract related to this funding award amendment.
This field is available from API version 59.0 and later.
This field is a relationship field.
Relationship Name
Contract
Relationship Type
Lookup
Refers To
Contract

FundingAwardId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The funding award that's associated with the contract that's adjusted.
This field is a relationship field.
Relationship Name
FundingAward
Relationship Type
Master-Detail
Refers To
FundingAward

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the amendment to the funding award has been submitted (true) or not
(false).
This field is available from API version 58.0 and later.
The default value is false.


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of amendment for the funding award.

ProposedAwardAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount of adjustment requested in the award amount.

ProposedEndDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The requested change to the End Date of the funding award.

Reason

Type
textarea
Properties
Create, Nillable, Update
Description
The reason for the adjustment requested in the contract.


Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the adjustment request.
Possible values are:
• Approved
• Draft
• Rejected
• Submitted

Type

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the type of adjustment.
Possible values are:
• Administrative
• Amount
• Scope
• Timeline

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
FundingAwardAmendmentFeed
Feed tracking is available for the object.
FundingAwardAmendmentHistory
History is available for tracked fields of the object.

FundingAwardParticipant
Represents information about a user or group of participants who have access to a funding award. This object is available in API version
59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), update(), upsert()

Special Access Rules
This object is accessible only when the Grantmaking license is on, Grantmaking is active, Compliant Data Sharing is on, and users have
the Managed Funding Awards system permission.

Fields
Field

Details

Comments

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The comments about why the participant has access to the funding award.

FundingAwardId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The funding award associated with the funding award participant.
This field is a relationship field.
Relationship Name
FundingAward
Relationship Type
Master-Detail
Refers To
FundingAward

IsParticipantActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the funding award participant is currently active (true) or not (false).
The default value is false.


LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the funding award participant.

ParticipantId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The participant associated with the funding award.
This field is a polymorphic relationship field.
Relationship Name
Participant
Relationship Type
Lookup
Refers To
Group, User

ParticipantRoleId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The participant role associated with the funding award participant.


This field is a relationship field.
Relationship Name
ParticipantRole
Relationship Type
Lookup
Refers To
ParticipantRole

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
FundingAwardParticipantFeed
Feed tracking is available for the object.
FundingAwardParticipantHistory
History is available for tracked fields of the object.

FundingAwardRequirement
Represents a deliverable or milestone for a funding award or funding disbursement. This object is available in API version 57.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.

Fields
Field

Details

ActionPlanTemplateId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The action plan template that's related to the funding award requirement and that's used
for funding requirement forms.
This field is a relationship field.
This field is available from API version 64.0 and later.
Relationship Name
ActionPlanTemplate
Refers To
ActionPlanTemplate

ApprovalStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the approval status the information that's submitted against the requirements.
Possible values are:
• Approved
• In Review
• New
• Rejected

AssignedContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact who is responsible for submitting the requirement.
This field is a relationship field.
Relationship Name
AssignedContact
Relationship Type
Lookup
Refers To
Contact

AssignedUserId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The user who submits the funding requirement.
This field is a relationship field.
Relationship Name
AssignedUser
Relationship Type
Lookup
Refers To
User

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description of the funding requirement.

DueDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The last date and time of submitting the requirement.

FundingAwardId

Type
reference
Properties
Create, Filter, Group, Sort
Description
Funding award that's associated with the funding requirement.
This field is a relationship field.
Relationship Name
FundingAward
Relationship Type
Master-Detail
Refers To
FundingAward

FundingDisbursementId

Type
reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding disbursement that's associated with the requirement. The funds are disbursed
only after the requirements are fulfilled.
This field is a relationship field.
Relationship Name
FundingDisbursement
Relationship Type
Lookup
Refers To
FundingDisbursement

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the requirement for the funding award has been submitted (true) or
not (false).
This field is available from API version 58.0 and later.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string


Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the funding requirement.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the funding requirement.
Possible values are:
• Approved
• Delayed
• In Progress
• Open
• Rejected
• Submitted

SubmittedDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The actual date and time when the requirement was submitted.

Type

Type
picklist


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the type of funding requirement.
Possible values are:
• Combined Report
• Contract
• Financial Report
• Narrative Report

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
FundingAwardRequirementFeed
Feed tracking is available for the object.
FundingAwardRequirementHistory
History is available for tracked fields of the object.
FundingAwardRqmtSectionOwnerSharingRule
Sharing rules are available for the object.

FundingAwardRqmtSection
Represents a part of a funding award requirement to be completed or reviewed. This object is available in API version 62.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.


Fields
Field

Details

ApplicationStageDefinitionId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The application stage definition associated with the funding award requirement section.
This field is a relationship field.
Relationship Name
ApplicationStageDefinition
Relationship Type
Lookup
Refers To
ApplicationStageDefinition
AssignedUserId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The user assigned to complete the funding award requirement section.
This field is a relationship field.
Relationship Name
AssignedUser
Relationship Type
Lookup
Refers To
User

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the funding award requirement section.

DisplayOrder

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The order in which the funding award requirement section shows on the form.

DueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the funding award requirement section is due.

EndDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the funding award requirement section ends.

FundingAwardRequirementId Type

reference
Properties
Create, Filter, Group, Sort
Description
The parent funding award requirement associated with the funding award requirement
section.
This field is a relationship field.
Relationship Name
FundingAwardRequirement
Relationship Type
Master-detail
Refers To
FundingAwardRequirement (the master object)
IsAssignedToMe

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Indicates whether the requirement section is assigned to the logged in user (true) or not
(false). This field can be used to filter the sections assigned to the user.
The default value is false.
This field is a calculated field.


IsRequired

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the funding award requirement section is required (true) or not (false).
The default value is false.

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the funding award requirement section has been submitted (true) or not
(false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the funding award requirement section


OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

StartDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the funding award requirement section starts.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the funding award requirement section.
Possible values are:
• Canceled
• Completed
• In Progress
• Not Started

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
FundingAwardRqmtSectionHistory
History is available for tracked fields of the object.
FundingAwardRequirementFeed
Feed tracking is available for the object.


Sharing rules are available for the object.
FundingAwardRqmtSectionShare
Sharing is available for the object.

FundingDisbursement
Represents a payment that has been made or scheduled to be made to a funding recipient. This object is available in API version 57.0
and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.

Fields
Field

Details

Amount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total amount that's disbursed to the awardee.

DisbursementDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The actual date and time of funds disbursement.

FundingAwardId

Type
reference
Properties
Create, Filter, Group, Sort


Description
The funding award that's associated with the funding disbursement.
This field is a relationship field.
Relationship Name
FundingAward
Relationship Type
Master-Detail
Refers To
FundingAward

IsApproved

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort
Description
Indicates whether the funding disbursement is approved (true) or not (false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The autogenerated name of the funding disbursement.

OwnerId

Type
reference


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The owner of the record.
This field is a polymorphic relationship field.
This field is available from API version 63.0 and later.
Relationship Name
Owner
Refers To
Group, User

PaymentMethodType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the payment method for funds disbursement.
Possible values are:
• Cash
• Check
• EFT
• Wire

PaymentNumber

Type
string
Properties
Autonumber, Defaulted on create, Filter, Sort
Description
The unique identifier of the payment related to the funds disbursement.

ScheduledDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The scheduled date and time to disburse the funds.

Status

Type
picklist


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the approval status of the funds disbursement.
Possible values are:
• Approved
• Cancelled
• Paid
• Pending Approval
• Processing
• Returned
• Scheduled

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
FundingDisbursementShare
Sharing is available for the object.
FundingDisbursementOwnerSharingRule
Sharing rules are available for the object.
FundingDisbursementFeed
Feed tracking is available for the object.
FundingDisbursementHistory
History is available for tracked fields of the object.

FundingOpportunity
The pool of money available for distribution for a specific purpose. This object is available in API version 57.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.


Fields
Field

Details

ActionPlanTemplateId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The action plan template that represents the application sections for this funding opportunity.
Relationship Name
ActionPlanTemplate
Refers To
ActionPlanTemplate

ApplicationInstructions Type

textarea
Properties
Create, Nillable, Update
Description
The instructions on how to apply for the funding opportunity.
ApplicationTimelineId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The application timeline associated with the opportunity that describes the milestones in
the application process.
This field is a relationship field.
Relationship Name
ApplicationTimeline
Relationship Type
Lookup
Refers To
ApplicationTimeline

BudgetTemplateId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The budget that's used as a template by the applicants when they apply for the funding
opportunity.
This field is a relationship field.
Relationship Name
BudgetTemplate
Relationship Type
Lookup
Refers To
Budget

Description

Type
textarea
Properties
Create, Nillable, Update
Description
The description about the opportunity in terms of the minimum award requirements and
expected outcome.

EndDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the acceptance of funding opportunity applications ended.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.


MaximumFundingAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The maximum fund amount that's awarded.

MinimumFundingAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The minimum fund amount that's awarded.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the funding opportunity.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner who owns the record.s
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentFundingOpportunityId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The associated parent funding opportunity.


This field is available from API version 59.0 and later.
This field is a relationship field.
Relationship Name
ParentFundingOpportunity
Relationship Type
Lookup
Refers To
FundingOpportunity

ProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program associated with the funding opportunity.
This field is available from API version 58.0 and later.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program

StartDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the acceptance of funding opportunity applications started.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the funding opportunity.
Possible values are:
• Active
• Cancelled


• Completed
• Planned

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
FundingOpportunityFeed
Feed tracking is available for the object.
FundingOpportunityHistory
History is available for tracked fields of the object.
FundingOpportunityOwnerSharingRule
Sharing rules are available for the object.
FundingOpportunityShare
Sharing is available for the object.

FundingOppParticipant
Represents information about a user or group of participants who have access to a funding opportunity. This object is available in API
version 60.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.

Fields
Field

Details

Comments

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The comments about why the participant has access to the funding opportunity.

FundingOpportunityId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The funding opportunity associated with the funding opportunity participant.
This field is a relationship field.
Relationship Name
FundingOpportunity
Relationship Type
Master-Detail
Refers To
FundingOpportunity

IsParticipantActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the funding opportunity participant is currently active (true) or not
(false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.


Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the funding opportunity participant.

ParticipantId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The participant associated with the funding opportunity.
This field is a polymorphic relationship field.
Relationship Name
Participant
Relationship Type
Lookup
Refers To
Group, User

ParticipantRoleId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The participant role associated with the funding opportunity participant.
This field is a relationship field.
Relationship Name
ParticipantRole
Relationship Type
Lookup
Refers To
ParticipantRole

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.


Feed tracking is available for the object.
FundingOppParticipantHistory
History is available for tracked fields of the object.

IndicatorAssignment
Represents the assignment of an indicator definition that's used to measure the performance of an outcome or a related activity This
object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available in products:
• That include the Outcome Management and Grantmaking licenses.
• Where Outcome Management and Grantmaking are enabled.
• The Manage Applications, Manage Funding Awards, Manage Outcomes, and Use Grantmaking system permissions are assigned to
users.

Fields
Field

Details

FundingAwardId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding award that the indicator assignment measures.
This field is a relationship field.
Relationship Name
FundingAward
Relationship Type
Lookup
Refers To
FundingAward


FundingOpportunityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding opportunity that the indicator assignment measures.
This field is a relationship field.
Relationship Name
FundingOpportunity
Relationship Type
Lookup
Refers To
FundingOpportunity

IndicatorAssignmentType Type

picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the object that the indicator assignment measures.
Possible values are:
• Outcome
• Program
IndicatorDefinitionId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The indicator definition that's associated with the indicator assignment.
This field is a relationship field.
Relationship Name
IndicatorDefinition
Relationship Type
Master-detail
Refers To
IndicatorDefinition (the master object)

IndividualApplicationId Type

reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The individual application that the indicator assignment measures.
This field is a relationship field.
Relationship Name
IndividualApplication
Relationship Type
Lookup
Refers To
IndividualApplication

IntendedDirection

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the intended direction of change in the behavior, knowledge, skills, status, or level
of functioning that's detailed in the parent indicator definition.
Possible values are:
• Decrease
• Increase
• Maintain

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.


Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the indicator assignment.

OutcomeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The outcome that the indicator assignment measures.
This field is a relationship field.
Relationship Name
Outcome
Relationship Type
Lookup
Refers To
Outcome

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The owner of this indicator assignment.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program that the indicator assignment measures.


This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program

Status

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the status of the indicator assignment.
Possible values are:
• Active
• Canceled
• Completed
• Planned

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndicatorAssignmentFeed
Feed tracking is available for the object.
IndicatorAssignmentHistory
History is available for tracked fields of the object.
IndicatorAssignmentOwnerSharingRule
Sharing rules are available for the object.
IndicatorAssignmentShare
Sharing is available for the object.

IndicatorPerformancePeriod
Represents information about a specified time period including the frequency at which indicator results should be calculated and the
baseline value of the indicator. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available in products:
• That include the Outcome Management and Grantmaking licenses.
• Where Outcome Management and Grantmaking are enabled.
• The Manage Applications, Manage Funding Awards, Manage Outcomes, and Use Grantmaking system permissions are assigned to
users.

Fields
Field

Details

BaselineDescription

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the baseline value.

BaselineValue

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The value of the indicator assignment at the beginning of the indicator performance period.

Description

Type
textarea
Properties
Create, Filter, Nillable, Sort, Update
Description
The description of the indicator performance period.

FundingAwardRequirementId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding award requirement that's associated with the indicator performance period.


This field is a relationship field.
Relationship Name
FundingAwardRequirement
Relationship Type
Lookup
Refers To
FundingAwardRequirement

IndicatorAssignmentId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The indicator assignment that is associated with the indicator performance period.
This field is a relationship field.
Relationship Name
IndicatorAssignment
Relationship Type
Master-detail
Refers To
IndicatorAssignment (the master object)

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastResultMeasurementDate Type

date
Properties
Filter, Group, Nillable, Sort
Description
The date when the last result value was measured.
This field is a calculated field.
LastResultValue

Type
double


Properties
Filter, Nillable, Sort
Description
The result value from the most recently measured indicator result.
This field is a calculated field.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the indicator performance period.

TargetProgress

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the progress of the target within the time period.
Possible values are:
• At Risk
• Complete
• Not Met
• Not Started
• On Track

TargetValue

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The target value of the indicator assignment within the time period.


TimePeriodId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The time period that is associated with the indicator performance period.
This field is a relationship field.
Relationship Name
TimePeriod
Relationship Type
Lookup
Refers To
TimePeriod

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndicatorPerformancePeriodFeed
Feed tracking is available for the object.
IndicatorPerformancePeriodHistory
History is available for tracked fields of the object.

IndividualApplication
Represents an application form submitted by an individual or organization. This object is available in API version 50.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The ID of the applicant’s account.
This is a relationship field.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account

ApplicationCaseId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of a case that relates to this application.
This is a relationship field.
Relationship Name
ApplicationCase
Relationship Type
Lookup
Refers To
Case

ApplicationChangeOverview Type

textarea
Properties
Create, Nillable, Update
Description
The Einstein-generated historical overview of the changes between application versions.
Available in API versions 62.0 and later. Einstein Generative AI for Public Sector Solutions
must be enabled.
ApplicationName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Descriptive name for the application. This field is available if you enabled Public Sector
Solutions or Grantmaking in Setup.
Available from API version 57.0 and later.


ApplicationOverview

Type
textarea
Properties
Create, Nillable, Update
Description
The Einstein-generated historical overview of application stages, data changes, and processing
actions.
Available in API versions 62.0 and later. Einstein Generative AI for Public Sector Solutions
must be enabled.

ApplicationReferenceNumber Type

string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The custom reference number assigned to the application. This field is available if you enabled
Health Cloud, Public Sector Solutions, or Grantmaking in Setup.
ApplicationType

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The type of the application.
Possible values are:
• Change Of Circumstance—Available in API versions 62.0 and later with Public
Sector Solutions.
• ChangeOfCircumstance—Available in API versions 60.0 and 61.0 with Public
Sector Solutions.
• New
• Recertification—Available in API version 60.0 and later with Public Sector
Solutions.
• Renewal

AppliedDate

Type
dateTime
Properties
Create, Filter, Sort, Update
Description
The date on which the application was received from the applicant.


ApprovedDate

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date on which the application was approved.

BudgetId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The budget associated with the individual application. This field is available if you enabled
Public Sector Solutions or Grantmaking in Setup.
Available from API version 57.0 and later.
This field is a relationship field.
Relationship Name
Budget
Relationship Type
Lookup
Refers To
Budget

Category

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
The service category of the application.
Possible values are:
• License
• Permit
• Grant Application
• Letter of Intent

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The contact associated with the individual application.
This field is a relationship field.
Relationship Name
Contact
Relationship Type
Lookup
Refers To
Contact

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Text description provided by the applicant.

FundingOpportunityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding opportunity associated with the individual application. This field is available if
you enabled Public Sector Solutions or Grantmaking in Setup.
Available in API version 57.0 and later.
This field is a relationship field.
Relationship Name
FundingOpportunity
Relationship Type
Lookup
Refers To
FundingOpportunity

FundingRequestPurpose

Type
textarea
Properties
Create, Nillable, Update
Description
Description of what the individual application funds are used for. This field is available if you
enabled Public Sector Solutions or Grantmaking in Setup.
Available in API version 57.0 and later.


InternalStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Status of the individual application in Salesforce CRM.
Available in API version 57.0 and later.
Possible values are:
• Invited
• In Progress
• Submitted
• Application Accepted
• Revision Requested
• In Review
• Approved
• Denied

IsOwnerEditable

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Whether the owner ID of this record can be changed.
The default value is 'false'.

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the individual application has been submitted. This field is available if you
enabled Public Sector Solutions or Grantmaking in Setup.
Available in API version 58.0 and later.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when a user most recently viewed a record related to this record.


LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when a user most recently viewed this record. If this value is null, this
record might only have been referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The auto-generated unique ID for this application.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the user that owns this record.
This is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

RecordTypeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The record associated to the application.
This is a relationship field.
Relationship Name
RecordType
Relationship Type
Lookup


Refers To
RecordType

RequestedAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
Amount requested in the individual application. This field is available if you enabled Public
Sector Solutions or Grantmaking in Setup.
Available in API version 57.0 and later.

RequirementsCompleteDate Type

dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date when the applicant fulfilled all the requirements for approval.
SavedApplicationRefId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Reference Id of the saved application.
This is a relationship field.
Relationship Name
SavedApplicationRef
Relationship Type
Lookup
Refers To
PreliminaryApplicationRef

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The submission and approval status of the application.
Possible values are:
• Invited


• In Progress
• Submitted
• Application Accepted
• Revision Requested
• In Review
• Approved
• Denied

WasReturned

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Whether a submitted application was sent back to the applicant due to errors.
The default value is 'false'.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndividualApplicationChangeEvent (API Version 55.0)
Change events are available for the object.
IndividualApplicationFeed
Feed tracking is available for the object.
IndividualApplicationHistory
History is available for tracked fields of the object.
IndividualApplicationOwnerSharingRule
Sharing rules are available for the object.
IndividualApplicationShare
Sharing is available for the object.

IndividualApplicationTask
Represents a task related to an application. This object is available in Grantmaking API version 61.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.

Fields
Field

Details

ApplicationStageDefinitionId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The application stage definition associated with the individual application task.
This field is a relationship field.
Relationship Name
ApplicationStageDefinition
Relationship Type
Lookup
Refers To
ApplicationStageDefinition
Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Describes the details of the task to be completed.

DueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the individual application task must be completed.

DueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the individual application task must be completed.


EndDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the individual application task ends.

IndividualApplicationId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The individual application associated with the individual application task.
This field is a relationship field.
Relationship Name
IndividualApplication
Relationship Type
Lookup
Refers To
IndividualApplication
IsRequired

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the individual application task is required (true) or not (false).
The default value is false.

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the individual application task has been submitted.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the individual application task.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the user who owns the record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PreliminaryApplicationRefId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The parent funding award for this funding award.
This field is a relationship field.


Relationship Name
PreliminaryApplicationRef
Relationship Type
Lookup
Refers To
PreliminaryApplicationRef

SavedApplicationUrl

Type
url
Properties
Create, Filter, Nillable, Sort, Update
Description
The URL of a saved application that's associated with the individual application task.

SequenceNumber

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The sequence in which the individual application task must be performed.

StartDateTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time when the individual application task starts.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the individual application task.
Possible values are:
• Cancelled
• Completed
• In Progress
• Not Started


Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of the individual application task.
Possible values are:
• Grantmaking

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndividualApplicationTaskFeed
Feed tracking is available for the object.
IndividualApplicationTaskHistory
History is available for tracked fields of the object.
IndividualApplicationTaskShare
Sharing is available for the object.

IndvApplicationTaskParticipant
Represents information about a user or group of participants who have read or write access to an individual application task. This object
is available in API version 61.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Applications system permission
is assigned to users.


Fields
Field

Details

Comments

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The reasons why a participant is involved in an individual application task.

IndividualApplicationTaskId Type

reference
Properties
Create, Filter, Group, Sort
Description
The individual application task associated with the individual application task participant.
This field is a relationship field.
Relationship Name
IndividualApplicationTask
Relationship Type
Master-Detail
Refers To
IndividualApplicationTask (the master object)
IsParticipantActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates if the participant is currently active.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the individual application task participant.

ParticipantId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The participant associated with the individual application task.
This field is a polymorphic relationship field.
Relationship Name
Participant
Relationship Type
Lookup
Refers To
Group, User

ParticipantRoleId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The participant role associated with the individual application task participant.
This field is a relationship field.
Relationship Name
ParticipantRole
Relationship Type
Lookup
Refers To
ParticipantRole


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndvApplicationTaskParticipantFeed
Feed tracking is available for the object.
IndvApplicationTaskParticipantHistory
History is available for tracked fields of the object.

IndividualApplnParticipant
Represents information about a user or group of participants who have access to a individual application. This object is available in API
version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Funding Awards system
permission is assigned to users.

Fields
Field

Details

Comments

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The comments about why the participant has access to the individual application.

IndividualApplicationId Type

reference
Properties
Create, Filter, Group, Sort
Description
The individual application associated with the individual application participant.
This field is a relationship field.


Relationship Name
IndividualApplication
Relationship Type
Master-Detail
Refers To
IndividualApplication

IsParticipantActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the individual application participant is currently active (true) or not
(false).
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the individual application participant.

ParticipantId

Type
reference
Properties
Create, Filter, Group, Sort


Description
The participant associated with the individual application.
This field is a polymorphic relationship field.
Relationship Name
Participant
Relationship Type
Lookup
Refers To
Group, User

ParticipantRoleId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The participant role associated with the individual application participant.
This field is a relationship field.
Relationship Name
ParticipantRole
Relationship Type
Lookup
Refers To
ParticipantRole

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
IndividualApplnParticipantFeed
Feed tracking is available for the object.
IndividualApplnParticipantHistory
History is available for tracked fields of the object.

OutcomeActivity
Represents a junction between an outcome and the object that's related to the activity undertaken by an organization to achieve that
outcome. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available in products:
• That include the Outcome Management and Grantmaking licenses.
• Where Outcome Management and Grantmaking are enabled.
• The Manage Applications, Manage Funding Awards, Manage Outcomes, and Use Grantmaking system permissions are assigned to
users.

Fields
Field

Details

BenefitId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The benefit that's associated with the outcome.
This field is a relationship field.
Relationship Name
Benefit
Relationship Type
Lookup
Refers To
Benefit

FundingAwardId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding award that's associated with the outcome.
This field is a relationship field.
Relationship Name
FundingAward
Relationship Type
Lookup


Refers To
FundingAward

FundingOpportunityId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The funding opportunity that's associated with the outcome.
This field is a relationship field.
Relationship Name
FundingOpportunity
Relationship Type
Lookup
Refers To
FundingOpportunity

GoalDefinitionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The goal definition that's associated with the outcome. This field is available from API version
60.0 and later.
This field is a relationship field.
Relationship Name
GoalDefinition
Relationship Type
Lookup
Refers To
GoalDefinition

IndividualApplicationId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The individual application that's associated with the outcome.
This field is a relationship field.
Relationship Name
IndividualApplication


Relationship Type
Lookup
Refers To
IndividualApplication

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the outcome activity.

OutcomeActivityType

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
Specifies the type of activity that’s associated with the outcome
Possible values are:
• Benefit
• Goal Definition This value is available from API version 60.0 and later.
• Program

OutcomeId

Type
reference


Properties
Create, Filter, Group, Sort
Description
The outcome that's associated with the outcome.
This field is a relationship field.
Relationship Name
Outcome
Relationship Type
Master-detail
Refers To
Outcome (the master object)

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The owner of the record.
This field is a polymorphic relationship field.
This field is available from API version 63.0 and later.
Relationship Name
Owner
Refers To
Group, User

ProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The program that's associated with the outcome.
This field is a relationship field.
Relationship Name
Program
Relationship Type
Lookup
Refers To
Program


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
OutcomeActivityShare
Sharing is available for the object.
OutcomeActivityOwnerSharingRule
Sharing rules are available for the object.
OutcomeActivityFeed
Feed tracking is available for the object.
OutcomeActivityHistory
History is available for tracked fields of the object.

PreliminaryApplicationRef
Represents the saved applications and pre-screening forms. This object is available in API version 49.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Application system permission
is assigned to users.

Fields
Field

Details

ApplicantId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
ID of the applicant for the application.
This field is a relationship field.
Relationship Name
Applicant
Relationship Type
Lookup
Refers To
Contact


ApplicationCategory

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The category of the application

ApplicationName

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
Name of the preliminary application.

ApplicationType

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Type of application.
Possible values are:
• BusinessLicenseApplication—Business License Application
• BusinessPrescreening—License Requirement Assessment
• IndividualApplication—Individual Application

BusinessAccountNameId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
ID of the account related to the application.
This field is a relationship field.
Relationship Name
BusinessAccountName
Relationship Type
Lookup
Refers To
Account

IsSubmitted

Type
boolean


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the application was submitted.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the preliminary application.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner who owns the record.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User


SavedApplicationUrl

Type
url
Properties
Create, Filter, Group, Sort, Update
Description
Relative path of the saved application.

SubmissionDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application was submitted.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PreliminaryApplicationRefFeed
Feed tracking is available for the object.
PreliminaryApplicationRefHistory
History is available for tracked fields of the object.
PreliminaryApplicationRefOwnerSharingRule
Sharing rules are available for the object.
PreliminaryApplicationRefShare
Sharing is available for the object.

Program
Represents information about the enrollment and disbursement of benefits in a program. This object is available in API version 57.0 and
later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Fields
Field

Details

ActionPlanTemplateId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The action plan template that's associated with the program.
This field is a relationship field.
This field is available from API version 65.0 and later.
Relationship Name
ActionPlanTemplate
Refers To
ActionPlanTemplate

ActiveEnrolleeCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of program enrollees with IsActive on ProgramEnrollment selected. Data
Processing Engine calculates this field if you activate the Program Management Data
Processing Engine Definition templates in Setup. You can schedule this calculation to run
on a regular basis.

AdditionalContext

Type
textarea
Properties
Create, Nillable, Update
Description
The additional context about the program.

CurrentMonthDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed in the current month. Data Processing Engine calculates this
field if you activate the Program Management Data Processing Engine Definition templates
in Setup. You can schedule this calculation to run on a regular basis.


CurrentYearDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed in the current year. Data Processing Engine calculates this
field if you activate the Program Management Data Processing Engine Definition templates
in Setup. You can schedule this calculation to run on a regular basis.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the program ends.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the program.

OwnerId

Type
reference


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The user who owns the object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

ParentProgramId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The associated parent program.
This field is available from API version 59.0 and later.
This field is a relationship field.
Relationship Name
ParentProgram
Relationship Type
Lookup
Refers To
Program

PreviousMonthDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The count of benefits disbursed in the previous month. Data Processing Engine calculates
this field if you activate the Program Management Data Processing Engine Definition
templates in Setup. You can schedule this calculation to run on a regular basis.

PreviousYearDisbCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update


Description
The count of benefits disbursed in the previous year. Data Processing Engine calculates this
field if you activate the Program Management Data Processing Engine Definition templates
in Setup. You can schedule this calculation to run on a regular basis.

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the program begins.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the program.
Possible values are:
• Active
• Cancelled
• Completed
• Planned
This field is accessible if you enabled Data Protection and Privacy in Setup.

Summary

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The summary of the program.

TotalEnrolleeCount

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total count of enrollees in the program. Data Processing Engine calculates this field if
you activate the Program Management Data Processing Engine Definition templates in Setup.
You can schedule this calculation to run on a regular basis.


Grantmaking Fields on Other Objects

Field

Details

UsageType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the usage type of the program.
Possible value is ProgramManagement.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ProgramChangeEvent
Change events are available for the object.
ProgramFeed
Feed tracking is available for the object.
ProgramHistory
History is available for tracked fields of the object.
ProgramOwnerSharingRule
Sharing rules are available for the object.
ProgramShare
Sharing is available for the object.

Grantmaking Fields on Other Objects
Grantmaking includes fields that are available on other Salesforce objects. These fields are available only in orgs with Grantmaking
enabled.
Available in: Lightning Experience
Available in: Enterprise, Performance, and Unlimited Editions in Nonprofit Cloud for Grantmaking
Available in: Enterprise, Performance, Unlimited, and Developer Editions in Public Sector Solutions

ApplicationForm
Represents an application form submitted by an individual or organization. This object is available in API version 66.0 and later.
ApplicationFormEvaluation
Represents the details of the evaluation performed for an application form. This object is available in Grantmaking API version 66.0
and later.
ApplicationFormEvalSection
Represents a section of an Application Form Evaluation. This object is available in API version 66.0 and later.


Represents an application form submitted by an individual or organization. This object is available in API version 66.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and Track Applications is turned on.

Fields
Field

Details

ApplicationStatus

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the status of the application.

BudgetId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The budget that's associated with the application.
This field is a relationship field.
Relationship Name
Budget
Refers To
Budget

CompletionDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date that the application was completed.


ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The contact that's associated with the application.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

DueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application is due.

Purpose

Type
textarea
Properties
Create, Nillable, Update
Description
The purpose of the funding that's requested in the application.

ReferenceRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The opportunity that's associated with the application.
This field is a polymorphic relationship field.
Relationship Name
ReferenceRecord
Refers To
Benefit, FundingOpportunity, Program

ReferralId

Type
reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The referral that's associated with the application.
This field is a relationship field.
Relationship Name
Referral
Refers To
Referral

RequestedAmount

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The amount of funding that's requested in the application.

Title

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The descriptive name of the application. The name includes the applicant and the program
that the applicant is applying to.

UsageType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the type of application.
Possible values are:
• EmployeeRecruitment—Talent Recruitment Management
• Grantmaking
• Other
• Program
• Volunteer


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ApplicationFormFeed
Feed tracking is available for the object.
ApplicationFormHistory
History is available for tracked fields of the object.
ApplicationFormOwnerSharingRule
Sharing rules are available for the object.
ApplicationFormShare
Sharing is available for the object.

ApplicationFormEvaluation
Represents the details of the evaluation performed for an application form. This object is available in Grantmaking API version 66.0 and
later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and Track Applications is turned on.

Fields
Field

Details

AssignedDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application form evaluation was assigned to the evaluator.

DueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application form evaluation is due.


EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application form evaluation was completed.

RelationReferenceRecordId Type

reference
Properties
Filter, Group, Nillable, Sort
Description
The ID of the record that's referenced in the application form relation object that's associated
with this application form evaluation.
This field is a polymorphic relationship field.
Relationship Name
RelationReferenceRecord
Refers To
Benefit, BenefitAssignment, Case, FundingOpportunity, JobPosition, Program,
ProgramEnrollment, RecruitmentRequisition
StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application form evaluation was started.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the status of the application form evaluation.
Possible values are:
• Eligible
• Need more information
• Not Eligible

Title

Type
string


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The name of the application form evaluation.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ApplicationFormEvaluationFeed
Feed tracking is available for the object.
ApplicationFormEvaluationHistory
History is available for tracked fields of the object.
ApplicationFormEvaluationOwnerSharingRule
Sharing rules are available for the object.
ApplicationFormEvaluationShare
Sharing is available for the object.

ApplicationFormEvalSection
Represents a section of an Application Form Evaluation. This object is available in API version 66.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and Track Applications is turned on.

Fields
Field

Details

ApplicationFormEvaluationId Type

reference
Properties
Create, Filter, Group, Sort, Update
Description
The lookup to the related Application Form Evaluation.
This field is a relationship field.


Relationship Name
ApplicationFormEvaluation
Refers To
ApplicationFormEvaluation

ApplicationFormId

Type
reference
Properties
Filter, Group, Nillable, Sort
Description
The lookup to the related Application Form.
This field is a relationship field.
Relationship Name
ApplicationForm
Refers To
ApplicationForm

ApplicationStageDefinitionId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the related Application Stage Definition.
This field is a relationship field.
Relationship Name
ApplicationStageDefinition
Refers To
ApplicationStageDefinition
CurrencyIsoCode

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Identifies the currency used for the Application Form Evaluation section.
Possible values are:
• USD—U.S. Dollar
The default value is USD.


Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The short description of this section.

DisplayOrder

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the order in which to show this section in the list of all Application Form Evaluation
sections.

DueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date by which this section must be submitted.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date that the evaluator completed review of this section.

IsRequired

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Determines whether this evaluation section must be completed.
The default value is false.

IsSubmitted

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update


Description
Determines whether the section was submitted by the evaluator for review.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate isn’t null, the user accessed this record or list view.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the Application Form Evaluation Section.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

StartDate

Type
date


Grantmaking Tooling API Object

Details
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date that the evaluator started reviewing this section.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The evaluation review status of this section.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ApplicationFormEvaluationSectionFeed
Feed tracking is available for the object.
ApplicationFormEvaluationSectionHistory
History is available for tracked fields of the object.
ApplicationFormEvaluationSectionOwnerSharingRule
Sharing rules are available for the object.
ApplicationFormEvaluationSectionShare
Sharing is available for the object.

Grantmaking Tooling API Object
Tooling API exposes metadata used in developer tooling that you can access through REST or SOAP.
Tooling API’s SOQL capabilities for many metadata types allow you to retrieve smaller pieces of
metadata.
For more information about Tooling API objects and to find a complete reference of all the supported
objects, see Introducing Tooling API.
ApplicationRecordTypeConfig
Represents the configuration that maps object record types to an application. This object is
available in API version 57.0 and later.

ApplicationRecordTypeConfig
Represents the configuration that maps object record types to an application. This object is available
in API version 57.0 and later.


EDITIONS
Available in: Lightning
Experience
Available in: Enterprise,
Performance, and
Unlimited Editions in
Nonprofit Cloud for
Grantmaking
Available in: Enterprise,
Performance, Unlimited,
and Developer Editions in
Public Sector Solutions

Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported SOAP API Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Supported REST API Methods
DELETE, GET, HEAD, PATCH, POST, Query

Special Access Rules
This object is available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage Application system permission
is assigned to users.

Fields
Field

Details

ApplicationUsageType

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Count of application records used by Grantmaking.
Possible values are:
• BA—Benefit Assistance
• CCM—Composable Case Management
• EDU—Education Cloud
• Grantmaking
• HC—Health Cloud
• ERM—Others
• LPI—Public Sector Solutions

DeveloperName

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The unqiue name for ApplicationRecordTypeConfig.
The unique name of the object in the API. This name can contain only underscores and
alphanumeric characters, and must be unique in your org. It must begin with a letter, not
include spaces, not end with an underscore, and not contain two consecutive underscores.


In managed packages, this field prevents naming conflicts on package installations. With
this field, a developer can change the object’s name in a managed package and the changes
are reflected in a subscriber’s organization. Label is Record Type Name. This field is
automatically generated, but you can supply your own value if you create the record using
the API.
Note: When creating large sets of data, always specify a unique DeveloperName
for each record. If no DeveloperName is specified, performance may slow while
Salesforce generates one for each record.

Language

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The language of the ApplicationRecordTypeConfig.
Possible values are:
• The language of the account record type configuration.
• da—Danish
• de—German
• en_US—English
• es—Spanish
• es_MX—Spanish (Mexico)
• fi—Finnish
• fr—French
• it—Italian
• ja—Japanese
• ko—Korean
• nl_NL—Dutch
• no—Norwegian
• pt_BR—Portuguese (Brazil)
• ru—Russian
• sv—Swedish
• th—Thai
• zh_CN—Chinese (Simplified)
• zh_TW—Chinese (Traditional)

MasterLabel

Type
string
Properties
Create, Filter, Group, Sort, Update


Grantmaking Metadata API Types

Details
Description
Label for the ApplicationRecordTypeConfig. In the UI, this field is Application Record Type
Configuration.

ObjectName

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Objects used by Grantmaking.
Possible values are:
• IndividualApplication—Individual Application

RecordTypeName

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of record type that was created for Individual Application.

Grantmaking Metadata API Types
Metadata API enables you to access some types and feature settings that you can customize in the user interface. For more information
about Metadata API.
Find a complete reference of existing metadata types, see Metadata API Developer Guide.
IndustriesSettings
Represents the settings for Grantmaking

IndustriesSettings
Represents the settings for Grantmaking
This type extends the metadata type and inherits its fullName field.
In the package manifest, all organization settings metadata types are accessed using the Settings name.

File Suffix and Directory Location
IndustriesSettings are stored in a single file named Industries.settings in the settings directory.


Industries settings for Grantmaking are available in API version 59.0 and later.

Special Access Rules
Unless noted otherwise, these settings are available only if the Grantmaking license is enabled, Grantmaking is enabled, and the Manage
Application system permission is assigned to users.

Fields
Industries settings for Grantmaking are available in API version 59.0 and later.
Field Name

Field
Type

Description

enableCompliantDataSharingForBudget boolean

Indicates whether the Compliant Data Sharing feature is enabled for
the Budget object. The default is false. Available only if the
Grantmaking license is enabled and Grantmaking is enabled.

enableCompliantDataSharingForIndividualApplication boolean

Indicates whether the Compliant Data Sharing feature is enabled for
the Individual Application object. The default is false. Available
only if the Grantmaking license is enabled and Grantmaking is enabled.

enableCompliantDataSharingForFundingAward boolean

Indicates whether the Compliant Data Sharing feature is enabled for
the Funding Award object. The default is false. Available only if
the Grantmaking license is enabled and Grantmaking is enabled.

boolean

Indicates whether the Grantmaking feature is enabled. The default
is false. This option can’t be disabled (false) once it’s enabled
(true). Only requires that the Grantmaking license is enabled in the
org.

enableGrantmaking

Declarative Metadata Sample Definition
The following is an example of an Industries.Settings metadata file.
<?xml version="1.0" encoding="UTF-8"?>
<IndustriesSettings xmlns="http://soap.sforce.com/2006/04/metadata">
<enableGrantmaking>true</enableGrantmaking>
<enableCompliantDataSharingForBudget>true</enableCompliantDataSharingForBudget>
<enableCompliantDataSharingForIndividualApplication>true</enableCompliantDataSharingForIndividualApplication>

<enableCompliantDataSharingForFundingAward>true</enableCompliantDataSharingForFundingAward>
</IndustriesSettings>

The following is an example package.xml that references the previous definition.
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
<types>


<members>Industries</members>
<name>Settings</name>
</types>
<version>54.0</version>
</Package>


# Chapter 8: Volunteer Management

In this chapter ...
•

JobPositionAssignment

•

JobPositionQualification

•

JobPositionShift

•

PersonLocationAvailability

•

PositionBenefit

•

PositionQualification

•

VolunteerInitiative

Volunteer Management Standard Objects
The Volunteer Management data model provides objects and fields
to manage volunteer programs and improve the volunteer
experience for your organization.
Volunteer Management also uses objects from these clouds.
• Education Cloud

EDITIONS
Available in: Lightning
Experience
Available in: Unlimited and
Developer Editions.

• Public Sector Solutions
• Financial Services Cloud
• Nonprofit Cloud for Fundraising


Represents the assignment of a person to a specific JobPositionShift on a specific day. This object is available in API version 64.0 and
later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

ActualDuration

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The time difference in hours between the actual start time and actual end time.

ActualEndTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time the position assignment actually ended.

ActualStartTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time the position assignment actually started.

AssignedAccountId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The lookup to the account record for the position assignment.
This field is a relationship field.
Relationship Name
AssignedAccount
Refers To
Account

AssignedContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the contact record for the position assignment.
This field is a relationship field.
Relationship Name
AssignedContact
Refers To
Contact

AssignedPositionShiftId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the job position shift record for the position assignment.
This field is a relationship field.
Relationship Name
AssignedPositionShift
Refers To
JobPositionShift
DoesCountTowardShiftCapacity Type

boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Determines whether the job position assignment is part of the total capacity of the job
position shift.
The default value is false.


This field is available from API version 65.0 and later.

JobPositionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the related job position.
This field is a relationship field.
Relationship Name
JobPosition
Refers To
JobPosition

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the job position assignment.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update


Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

RelatedVolunteerInitiativeId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the primary volunteer initiative for the position assignment.
This field is a relationship field.
Relationship Name
RelatedVolunteerInitiative
Refers To
VolunteerInitiative
ScheduledEndTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time the position assignment is scheduled to end.

ScheduledStartTime

Type
dateTime
Properties
Create, Filter, Nillable, Sort, Update
Description
The date and time the position assignment is scheduled to start.

Status

Type
picklist
Properties
Create, Filter, Group, Sort, Update
Description
The status of the position assignment.
Possible values are:


• Absent
• Awaiting Approval
• Canceled
• Complete
• In Progress
• Pending Verification
• Upcoming

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as
JopPositionAssignment.
JobPositionAssignmentChangeEvent
Change events are available for the object.
JobPositionAssignmentFeed
Feed tracking is available for the object.
JobPositionAssignmentHistory
History is available for tracked fields of the object.
JobPositionAssignmentOwnerSharingRule
Sharing rules are available for the object.
JobPositionAssignmentShare
Sharing is available for the object.

JobPositionQualification
Represents a job position qualification. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.


Fields
Field

Details

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the qualification.

JobPositionId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The job position that's related to the job position qualification.
This field is a relationship field.
Relationship Name
JobPosition
Relationship Type
Master-detail
Refers To
JobPosition (the master object)

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string


Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the job position qualification.

ProficiencyLevel

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The proficiency level that's required for this qualifiation.
Possible values are:
• Advanced
• Beginner
• Intermediate

QualificationLevel

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number that represents the level requirement for the qualification.

QualificationReferenceRecordId Type

reference
Properties
Create, Filter, Group, Sort, Update
Description
A lookup to the record that confirms the qualification. Options include Competency,
Certification, Examination, Education, and Disability records.
This field is a polymorphic relationship field.
Relationship Name
QualificationReferenceRecord
Refers To
Competency and Examination

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as
JobPositionQualification.


Change events are available for the object.
JobPositionQualificationFeed
Feed tracking is available for the object.
JobPositionQualificationHistory
History is available for tracked fields of the object.
JobPositionQualificationOwnerSharingRule
Sharing rules are available for the object.
JobPositionQualificationShare
Sharing is available for the object.

JobPositionShift
Represents a specific work shift associated with a job position or one of its related recurrence schedules. This object is available in API
version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the job position shift.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the job position shift.


EndTime

Type
time
Properties
Create, Filter, Nillable, Sort, Update
Description
The end time of the job position shift.

JobPositionId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The lookup to the related job position.
This field is a relationship field.
Relationship Name
JobPosition
Refers To
JobPosition

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

MaximumAttendeesCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The maximum capacity for position assignments in the job position shift.


Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the job position shift.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

PositionAssignmentCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of related job position assignments.
RecurrenceScheduleId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the related recurrence schedule.
This field is a relationship field.
Relationship Name
RecurrenceSchedule
Refers To
RecurrenceSchedule

RemainingCapacity

Type
int


Properties
Filter, Group, Nillable, Sort
Description
The remaining capacity after subtracting the position assignments count from the maximum
attendees count.
This field is a calculated field.

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the job position shift.

StartTime

Type
time
Properties
Create, Filter, Nillable, Sort, Update
Description
The start time of the job position shift.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the job position shift.
Possible values are:
• Canceled
• Complete
• In Progress
• Upcoming

TimeZone

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The time zone which the operating hours fall within.


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as
JobPositionShift.
JobPositionShiftChangeEvent
Change events are available for the object.
JobPositionShiftFeed
Feed tracking is available for the object.
JobPositionShiftHistory
History is available for tracked fields of the object.
JobPositionShiftOwnerSharingRule
Sharing rules are available for the object.
JobPositionShiftShare
Sharing is available for the object.

PersonLocationAvailability
Represents a the availability of a person at a specific location.. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The lookup to the related account.
This field is a relationship field.
Relationship Name
Account


Refers To
Account

ContactId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the related contact.
This field is a relationship field.
Relationship Name
Contact
Refers To
Contact

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

LocationId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The lookup to the related location.
This field is a relationship field.
Relationship Name
Location
Refers To
Location


Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the person location availability.

OperatingHoursId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the related operating hours.
This field is a relationship field.
Relationship Name
OperatingHours
Refers To
OperatingHours

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

UsageType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update
Description
The type of usage for the location availability. For example, Volunteer Management is a usage
type.
Possible values are:
• VolunteerManagement


The default value is VolunteerManagement.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as
PersonLocationAvailability.
PersonLocationAvailabilityChangeEvent
Change events are available for the object.
PersonLocationAvailabilityFeed
Feed tracking is available for the object.
PersonLocationAvailabilityHistory
History is available for tracked fields of the object.
PersonLocationAvailabilityOwnerSharingRule
Sharing rules are available for the object.
PersonLocationAvailabilityShare
Sharing is available for the object.

PositionBenefit
Represents how a position and benefit are related. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

BenefitId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The lookup to the related job benefit.


This field is a relationship field.
Relationship Name
Benefit
Refers To
Benefit

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the position benefit.

PositionId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The job position that receives the benefit.
This field is a relationship field.
Relationship Name
Position
Relationship Type
Master-detail
Refers To
Position (the master object)


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as Position
Benefit. Otherwise, they're available in the specified API version and later.
PositionBenefitChangeEvent
Change events are available for the object.
PositionBenefitFeed
Feed tracking is available for the object.
PositionBenefitHistory
History is available for tracked fields of the object.
PositionBenefitOwnerSharingRule
Sharing rules are available for the object.
PositionBenefitShare
Sharing is available for the object.

PositionQualification
Represents a position-based qualification. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

Description

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the qualification.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort


Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the position.

PositionId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The position related to the position qualification.
This field is a relationship field.
Relationship Name
Position
Relationship Type
Master-detail
Refers To
Position (the master object)

ProficiencyLevel

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The proficiency level that's required for this qualifiation.
Possible values are:
• Advanced
• Beginner


• Intermediate

QualificationLevel

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number that represents the level requirement for the qualification.

QualificationReferenceRecordId Type

reference
Properties
Create, Filter, Group, Sort, Update
Description
A lookup to the record that confirms the qualification. Options include Competency,
Certification, Examination, Education, and Disability records.
This field is a polymorphic relationship field.
Relationship Name
QualificationReferenceRecord
Refers To
Competency and Examination

Usage
If a job position requires the person who fills it hold a qualification, the qualification requirement is referenced here. For example, to
work as a child care volunteer, the person performing the work is required to hold a current CPR certification. The CPR certification
requirement would be referenced in this object.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PositionQualificationChangeEvent
Change events are available for the object.
PositionQualificationFeed
Feed tracking is available for the object.
PositionQualificationHistory
History is available for tracked fields of the object.
PositionQualificationOwnerSharingRule
Sharing rules are available for the object.


Sharing is available for the object.

VolunteerInitiative
Represents all volunteer activities within a single volunteering initiative. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

AttendanceRate

Type
percent
Properties
Create, Filter, Nillable, Sort, Update
Description
The percentage of volunteers who've fulfilled their commitments to the volunteer initiative
up to and including today's date.

Description

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the volunteer initiative.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the volunteer initiative.


FilledAssignmentCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of filled volunteer position assignments.

IsPublished

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Determines whether the volunteer initiative is accessible in Experience Cloud.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
Text
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the volunteer initiative.

OpenAssignmentCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The total number of available volunteer position assignments.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object. ID of the creator of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

ParentVolunteerInitiativeId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to the parent volunteer initiative.
This field is a relationship field.
Relationship Name
ParentVolunteerInitiative
Refers To
VolunteerInitiative
StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the volunteer initiative.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the volunteer initiative.
Possible values are:


• Archived
• Canceled
• Complete
• In Progress
• Postponed
• Upcoming

TotalActiveVolunteerCount Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of unique, active volunteers for this initiative who have completed the
hours eligibility and have PositionAssignment statuses in the configured MaxAttendee
eligibility list.
TotalAssignmentCount

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of open volunteer position assignments plus the number of filled volunteer
position assignments.

TotalVolunteerHours

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The total number of hours that were volunteered during this initiative.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as
VolunteerInitiative. Otherwise, they're available in the specified API version and later.
VolunteerInitiativeHistory
History is available for tracked fields of the object.
VolunteerInitiativeOwnerSharingRule
Sharing rules are available for the object.
VolunteerInitiativeShare
Sharing is available for the object.


# Chapter 9: Provider Management

In this chapter ...
•

ApplicationForm

•

ApplicationRenderMethod

•

ApplicationStageDefinition

•

DonorGiftSummary

•

JobPosition

•

PersonCompetency

•

Position

Volunteer Management Fields on Other Objects
Volunteer Management includes fields that are available on other
Salesforce objects. These fields are available only in orgs with
Nonprofit Cloud when Volunteer Management is enabled.

EDITIONS
Available in: Lightning
Experience
Available in: Unlimited and
Developer Editions.


Represents the high level information of a submitted application. This object is available in API version 65.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

CompletionDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date that the application was completed.

DueDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the application is due.

ReferralId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The referral that's associated with the application.
This field is a relationship field.
Relationship Name
Referral
Refers To
Referral

UsageType

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update


Description
Specifies the usage of application.
Possible values are:
• Other
• Program This value is available from API version 65.0 and later.
• VolunteerThis value is available from API version 65.0 and later.

ApplicationRenderMethod
Represents how a part of an application can be rendered. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

MethodType

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Adding a new attribute to relate Flow metadata in the MethodName field.
Possible values are:
• FlexCard
• Flow
• OmniScript

UsageType

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update


Description
Adding a new attribute to relate Flow metadata in the MethodName field.
Possible values are:
• FormFramework

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ApplicationRenderMethodChangeEvent
Change events are available for the object.
ApplicationRenderMethodFeed
Feed tracking is available for the object.
ApplicationRenderMethodHistory
History is available for tracked fields of the object.
ApplicationRenderMethodOwnerSharingRule
Sharing rules are available for the object.
ApplicationRenderMethodShare
Sharing is available for the object.

ApplicationStageDefinition
Represents a stage of an application. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

EditTypeAppRenderMethodId Type

reference


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Add an Omniscript or Flexcard for an editable form or application.
This field is a relationship field.
Relationship Name
EditTypeAppRenderMethod
Refers To
ApplicationRenderMethod

Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Select a type of application stage definition.
Possible values are:
• FormFramework

ViewTypeAppRenderMethodId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Add an Omniscript or Flexcard for a read-only form or application.
This field is a relationship field.
Relationship Name
ViewTypeAppRenderMethod
Refers To
ApplicationRenderMethod

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as
JopPositionAssignment.
ApplicationStageDefinitionChangeEvent
Change events are available for the object.
ApplicationStageDefinitionFeed
Feed tracking is available for the object.


History is available for tracked fields of the object.
ApplicationStageDefinitionOwnerSharingRule
Sharing rules are available for the object.
ApplicationStageDefinitionShare
Sharing is available for the object.

DonorGiftSummary
Represents gift summaries for accounts and contacts. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

FirstVolunJobPstnAsgntDt Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the contact's first volunteer shift. Data Processing Engine finds the first job position
assignment that's related to a volunteer initiative and calculates the value. You can schedule
this calculation to run regularly.
LastVolunJobPstnAsgntDate Type

date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date of the contact's last volunteer shift. Data Processing Engine calculates this value by
finding the most recent job position assignment that is related to a volunteer initiative. You
can schedule this calculation to run on a regular basis.


TotalVolunJobPstnAsgnCnt Type

int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of times a contact has volunteered, which is the number of job position
assignments related to volunteer initiatives. The Data Processing Engine adds the assignments
and calculates the value. You can schedule this calculation to run regularly.
TotalVolunteerHours

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
The total hours a contact volunteered. The Data Processing Engine adds the hours from job
position assignments related to volunteer initiatives and calculates the value. You can schedule
this calculation to run regularly.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
>DonorGiftSummaryChangeEvent
Change events are available for the object.
DonorGiftSummaryFeed
Feed tracking is available for the object.
DonorGiftSummaryHistory
History is available for tracked fields of the object.
DonorGiftSummaryOwnerSharingRule
Sharing rules are available for the object.
DonorGiftSummaryShare
Sharing is available for the object.

JobPosition
Represents an instance of employment in a particular position in the organization. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()


Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

Code

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The code for the job position.

Description

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the job position.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date of the job position.

LastFilledDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the job position was last filled.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed a record related to this record.


Type
dateTime

JobPosition

Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.
LocationId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the location associated with the job position.
This field is a relationship field.
Relationship Name
Location
Refers To
Location

ManagerId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The manager for the job position.
This field is a polymorphic relationship field.
Relationship Name
Manager
Refers To
Account

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the job position.

OwnerId

Type
reference


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the record owner.
This field is a polymorphic relationship field.
Relationship Name
Owner
Refers To
Group, User

PositionId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The ID of the position associated with the job position.
This field is a relationship field.
Relationship Name
Position
Refers To
Position

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date of the job position.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the job position.
Possible values are:
• Canceled
• Complete
• In Progress
• Upcoming


Type
string

PersonCompetency

Properties
Create, Filter, Group, Sort, Update
Description
The title of the job position.
VolunteerInitiativeId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The lookup to a related volunteer initiative that this job is for.
This field is a relationship field.
Relationship Name
VolunteerInitiative
Refers To
VolunteerInitiative

PersonCompetency
Represents information about a competency that a person has. This object is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

QualificationLevel

Type
int


Properties
Create, Filter, Group, Nillabel, Sort, Update
Description
The number that represents the level requirement for the qualification.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as
JobPositionShift.
PersonCompetencyChangeEvent
Change events are available for the object.
PersonCompetencyFeed
Feed tracking is available for the object.
PersonCompetencyHistory
History is available for tracked fields of the object.
PersonCompetencyOwnerSharingRule
Sharing rules are available for the object.
PersonCompetencyShare
Sharing is available for the object.

Position
Represents a functional role that is characterized by specific duties and responsibilities, and required skills and qualifications. This object
is available in API version 64.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available only if the VolunteerManagementPsl permission set license is enabled and the Manage Volunteer Data permission
is assigned to users.

Fields
Field

Details

IsInternalApprovalRequired Type

boolean


Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Determines whether sign-up for the position requires internal approval.
The default value is false.

Status

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The status of the position.
Possible values are:
• Canceled
• Complete
• In Progress
• Upcoming

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PositionChangeEvent
Change events are available for the object.
PositionFeed
Feed tracking is available for the object.
PositionHistory
History is available for tracked fields of the object.
PositionOwnerSharingRule
Sharing rules are available for the object.
PositionShare
Sharing is available for the object.


# Chapter 10: Group Memberships and Households in Nonprofit Cloud

Cloud
In this chapter ...

This guide provides information about the Group Memberships
objects and APIs that Nonprofit Cloud uses.

EDITIONS

•

Group Membership
and Households
Standard Objects

Available in: Lightning
Experience

•

Group Membership
and Households
Business APIs

Available in: Enterprise
Unlimited and Developer
Editions.


Group Membership and Households Standard Objects

Group Membership and Households Standard Objects
The Group Membership and Households data model provides objects and fields to represent the relationships used for group memberships.
AccountAccountRelation
Represents a relationship between accounts, such as a relationship between a business account and a household account. This
object is available in API version 57.0 and later.
AccountContactRelation
Standard and custom fields extend the standard Account object for use in Public Sector Solutions to represent information of
members in a household. This object is available in API version 56.0 and later.
ContactContactRelation
Represents a relationship between contacts. This object is available in API version 57.0 and later.
PartyRelationshipGroup
Represents a group of people living together such as a household, or a group of people affiliated with each other. This object is
available in API version 56.0 and later.
PartyRoleRelation
Represents information about the type of relationship between the participants. This object is available in API version 57.0 and later.

AccountAccountRelation
Represents a relationship between accounts, such as a relationship between a business account and a household account. This object
is available in API version 57.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
ID of the account associated with this account account relationship.
This field is a relationship field.
Relationship Name
Account
Relationship Type
Lookup


Refers To
Account

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the relationship ends.

HierarchyType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Specifies the hierarchy between accounts that are related. For example, an account is related
to another account as a parent, peer, or child.
Possible values are:
• Child
• Parent
• Peer
The default value is Parent.

IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the account is actively involved with the related account.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.

LastViewedDate

Type
dateTime


Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
the user might have only accessed this record or list view
(<parmname>LastReferencedDate</parmname>) but not viewed it.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the account account relationship.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PartyRoleRelationId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The relationship between two accounts.
This field is a relationship field.
Relationship Name
PartyRoleRelation
Relationship Type
Lookup
Refers To
PartyRoleRelation


Type
reference

AccountAccountRelation

Properties
Create, Filter, Group, Sort, Update
Description
The related account in the relationship.
This field is a relationship field.
Relationship Name
RelatedAccount
Relationship Type
Lookup
Refers To
Account
RelatedInverseRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The record that specifies the inverse relationship between the accounts.
This field is a relationship field.
Relationship Name
RelatedInverseRecord
Relationship Type
Lookup
Refers To
AccountAccountRelation

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the relationship starts.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.


AccountAccountRelationChangeEvent (API Version 63.0)
Change events are available for the object.
AccountAccountRelationFeed
Feed tracking is available for the object.
AccountAccountRelationHistory
History is available for tracked fields of the object.
AccountAccountRelationOwnerSharingRule
Sharing rules are available for the object.
AccountAccountRelationShare
Sharing is available for the object.

AccountContactRelation
Standard and custom fields extend the standard Account object for use in Public Sector Solutions to represent information of members
in a household. This object is available in API version 56.0 and later.
For more information, see AccountContactRelation.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), update(), upsert()

Special Access Rules
Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort
Description
Lookup to the Account object.
This field is a relationship field.
Relationship Name
Account
Relationship Type
Lookup
Refers To
Account


Type
reference

AccountContactRelation

Properties
Create, Filter, Group, Sort
Description
Lookup to the Contact object.
This field is a relationship field.
Relationship Name
Contact
Relationship Type
Lookup
Refers To
Contact
DataRollupCategories

Type
multipicklist
Properties
Create, Filter, Nillable, Update
Description
Specifies the categories in which the data associated with a group is aggregated.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date a relationship between a contact and account ended. Use with the Start Date to
keep a history of the relationship.

IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether relationship is active (true) or not (false).
The default value is false.

IsDirect

Type
boolean
Properties
Defaulted on create, Filter, Group, Sort


Description
Indicates whether relationship is direct (true) or not (false).
The default value is false.

IsIncludedInGroup

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the data of a group or a business account is included in the Household
(true) or not (false).
The default value is false.

IsPrimaryGroup

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the group is a primary group for the member (yes) or not (no).
The default value is false.

IsPrimaryMember

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the member is a primary contact of a group (true) or not (false).
The default value is false.

Roles

Type
multipicklist
Properties
Create, Filter, Nillable, Update
Description
The contact’s participating role in the account.
Possible values are:
• Daughter
• Father
• Husband
• Mother


• Other
• Son
• Wife

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date a relationship between a contact and account began. Use with the End Date to
keep a history of the relationship

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
AccountContactRelationChangeEvent (API Version 59.0)
Change events are available for the object.

ContactContactRelation
Represents a relationship between contacts. This object is available in API version 57.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

ContactId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
ID of the account associated with this contact contact relationship.
This field is a relationship field.
Relationship Name
Contact


Relationship Type
Lookup
Refers To
Contact

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the relationship ends.

HierarchyType

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
Indicates the type of association to determine the hierarchy of relationship between the two
parties.
Possible values are:
• Child
• Parent
• Peer
The default value is Parent.

IsActive

Type
boolean
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
Indicates whether the contact is actively involved with the related contact.
The default value is false.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record, a record related to this record,
or a list view.


Type
dateTime

ContactContactRelation

Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
the user might have only accessed this record or list view
(<parmname>LastReferencedDate</parmname>) but not viewed it.
Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the contact contact relationship.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup
Refers To
Group, User

PartyRoleRelationId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The relationship between two contacts.
This field is a relationship field.
Relationship Name
PartyRoleRelation
Relationship Type
Lookup


Refers To
PartyRoleRelation

RelatedContactId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The related contact in the relationship.
This field is a relationship field.
Relationship Name
RelatedContact
Relationship Type
Lookup
Refers To
Contact

RelatedInverseRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The record that specifies the inverse relationship between the contacts.
This field is a relationship field.
Relationship Name
RelatedInverseRecord
Relationship Type
Lookup
Refers To
ContactContactRelation

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The date when the relationship starts.


Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
ContactContactRelationChangeEvent (API Version 63.0)
Change events are available for the object.
ContactContactRelationFeed
Feed tracking is available for the object.
ContactContactRelationHistory
History is available for tracked fields of the object.
ContactContactRelationOwnerSharingRule
Sharing rules are available for the object.
ContactContactRelationShare
Sharing is available for the object.

PartyRelationshipGroup
Represents a group of people living together such as a household, or a group of people affiliated with each other. This object is available
in API version 56.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

AccountId

Type
reference
Properties
Create, Filter, Group, Sort
Description
The parent account associated with the party relationship group.
This field is a relationship field.
Relationship Name
Account
Relationship Type
Master-detail
Refers To
Account (the master object)


Type
picklist

PartyRelationshipGroup

Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the category of the party relationship group.
Possible values are:
• Extended Family
• Meals together
• Staying under same roof
Description

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The description of the party relationship group.

EndDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The end date associated with the party relationship group.

GroupIncome

Type
currency
Properties
Create, Filter, Nillable, Sort, Update
Description
The total income of the party relationship group.

GroupSize

Type
int
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The number of active members associated with the party relationship group.

HousingType

Type
int


Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Specifies the housing type of the party relationship group. Examples include home or
government-assisted housing.
Available in API version 66.0 and later.

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Create, Filter, Group, idLookup, Sort, Update
Description
The name of the party relationship group.

PrimaryAddress

Type
address
Properties
Filter, Nillable
Description
The primary address of the party relationship group.

PrimaryCity

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update


Description
The primary city of the party relationship group.

PrimaryCountry

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The primary country of the party relationship group.

PrimaryGeocodeAccuracy

Type
picklist
Properties
Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The level of accuracy of a location’s geographical coordinates compared with its physical
address. A geocoding service typically provides this value based on the party relationship
group’s latitude and longitude coordinates.
Possible values are:
• Address
• Block
• City
• County
• ExtendedZip—Extended Zip
• NearAddress—Near Address
• Neighborhood
• State
• Street
• Unknown
• Zip

PrimaryLatitude

Type
double
Properties
Create, Filter, Nillable, Sort, Update
Description
Used with Longitude to specify the precise geolocation of the party relationship group.
Acceptable values are numbers between –90 and 90 with up to 15 decimal places.

PrimaryLongitude

Type
double


Properties
Create, Filter, Nillable, Sort, Update
Description
Used with Latitude to specify the precise geolocation of the party relationship group.
Acceptable values are numbers between –180 and 180 with up to 15 decimal places.

PrimaryPostalCode

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The primary postal code of the party relationship group.

PrimaryState

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The primary state of the party relationship group.

PrimaryStreet

Type
textarea
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The primary street of the party relationship group.

StartDate

Type
date
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The start date associated with the party relationship group.

Status

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The status of the party relationship group.
Possible values are:


• Active
• Inactive
The default value is Active.

Subtype

Type
picklist
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The subclassification of the party relationship group type.
Possible values are:
• Extension Household
• Nuclear Household
• Three Person Household

Type

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The type of the party relationship group.
Possible values are:
• Group
• Household
The default value is Group.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PartyRelationshipGroupChangeEvent (API Version 63.0)
Change events are available for the object.
PartyRelationshipGroupFeed
Feed tracking is available for the object.
PartyRelationshipGroupHistory
History is available for tracked fields of the object.

PartyRoleRelation
Represents information about the type of relationship between the participants. This object is available in API version 57.0 and later.


Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Fields
Field

Details

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp for when the current user last viewed this record. If this value is null, it’s
possible that this record was referenced (LastReferencedDate) and not viewed.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
Name of the party role relationship.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner
Relationship Type
Lookup


Refers To
Group, User

RelatedInverseRecordId

Type
reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The record that specifies the inverse relationship between the roles.
This field is a relationship field.
Relationship Name
RelatedInverseRecord
Relationship Type
Lookup
Refers To
PartyRoleRelation

RelatedRoleName

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
The role that's related to another role in the relationship.

RelationshipObjectName

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Update
Description
The object that's associated with the relationship.
Possible values are:
• Account_Account_Relationship—Account Account Relationship
• Contact_Contact_Relationship—Contact Contact Relationship
The default value is Account_Account_Relationship.

RoleName

Type
string
Properties
Create, Filter, Group, Sort, Update


Group Membership and Households Business APIs

Details
Description
The name of the role in the relationship.

ShouldCreaInversRoleAuto Type

boolean
Properties
Create, Defaulted on create, Filter, Group, Sort
Description
Indicates whether a role record should be created automatically for the relationship (true)
or not (false).
The default value is false.

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
PartyRoleRelationChangeEvent (API Version 63.0)
Change events are available for the object.
PartyRoleRelationFeed
Feed tracking is available for the object.
PartyRoleRelationHistory
History is available for the object.
PartyRoleRelationOwnerSharingRule
Sharing rules are available for the object.
PartyRoleRelationShare
Sharing is available for the object.

Group Membership and Households Business APIs
Use business APIs to define and manage party relationship groups of individuals or trusts.

Special Access Rules
To create party relationship groups, users need the Group Membership permission set. To merge party relationship groups, users must
clone the Group Membership permission set, and enable the Merge and Split Groups system permission in the cloned permission set.


REST Reference

REST Reference
You can access the Group Membership and Households APIs using REST endpoints. These REST APIs follow similar conventions as
Connect REST APIs.
SEE ALSO:
Salesforce Help: Group Membership and Households

REST Reference
You can access the Group Membership and Households APIs using REST endpoints. These REST APIs follow similar conventions as
Connect REST APIs.
To understand the architecture, authentication, rate limits, and how the requests and responses work, see Connect REST API Developer
Guide.
Resources
The Group Membership and Households APIs have these resources.
Request Bodies
The Group Membership and Households APIs have these request bodies.
Response Bodies
The Group Membership and Households APIs have these response bodies.

Resources
The Group Membership and Households APIs have these resources.
Group Definitions (POST)
Define a party relationship group of individuals or trusts to deliver support services or to manage shared processes, such as cases
and benefits.
Group Definitions Merge (POST)
Merge the details, members, member relationships, and relationships of a party relationship group.
Group Fields (GET)
Retrieve details from two party relationship groups.
Group Related Records (GET)
Get the related records of a party relationship group.

Group Definitions (POST)
Define a party relationship group of individuals or trusts to deliver support services or to manage shared processes, such as cases and
benefits.
Resource
/connect/group/group-definitions


REST Reference

Resource example
https://yourInstance.salesforce.com/services/data/v66.0/connect/group/group-definitions

Available version
58.0
Requires Chatter
No
HTTP methods
POST
Request body for POST
JSON example
{
"accountDetail":{
"name":"prg5",
"ownerId":"005xx000001X7tNAAS",
"billingAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"90042"
},
"shippingAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"90042"
},
"phone":"0123456789"
},
"groupDetail":{
"name":"prg5",
"category":"Staying under the same roof",
"type":"Household",
"groupSize":"2",
"groupIncome":"20000",
"primaryAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"90042"
}
},
"member":{
"records":[
{
"contactId":"003xx000004WhHQAA0",
"roles":"Decision Maker",
"relations":[


REST Reference

{
"roleRelationId":"0zlxx0000000001AAA",
"relatedContactId":"003xx000004WhJ2AAK",
"startDate":"2023-06-14T00:00:00.000Z"
}
]
}
]
},
"externalMember":{
"records":[
{
"contactId":"003xx000004WhJ2AAK",
"roles":"Decision Maker"
}
]
},
"relatedGroup":{
"relations":[
{
"type":"Direct",
"roleRelationId":"0zlxx000000001dAAA",
"relatedAccountId":"001xx000003GYodAAG"
}
]
},
"relatedAccount":{
"relations":[
]
}
}

Properties
Name

Type

Description

Required or
Optional

account
Detail

Map<String,
Object>

Account details associated with the party Required
relationship group.

58.0

external
Member

Member Record
Input[]

External member details of the party
relationship group.

Optional

58.0

groupDetail

Map<String,
Object>

Party relationship group details, such as Required
group size, group income, address, and
associated custom fields.

58.0

member

Member Record
Input[]

Member details of the party relationship Required
group being created.

58.0

related
Account

Account Relation
Input[]

Data of the account that’s related to the Optional
party relationship group being created.

58.0


Available
Version

Type

relatedGroup Account Relation

Input[]

REST Reference

Description

Required or
Optional

Available
Version

Data of the group that’s related to the
party relationship group being created.

Optional

58.0

Response body for POST
Group Definition

Group Definitions Merge (POST)
Merge the details, members, member relationships, and relationships of a party relationship group.
Resource
/connect/group/group-definitions/actions/merge

Resource example
https://yourInstance.salesforce.com/services/data/v66.0/connect/group/group-definitions/actions/merge

Available version
58.0
Requires Chatter
No
HTTP methods
POST
Request body for POST
JSON example
{
"primaryAccountId":"001RM000005aGUcYAM",
"secondaryAccountId":"001RM000005YYfiYAG",
"accountDetail":{
"customFields":{
"Account_CF1__c":"123",
"Account_CF2__c":"342"
},
"name":"Jones-Marshal HH",
"fax":"213762",
"billingAddress":{
"street":"",
"city":"",
"state":"",
"country":"",
"postalCode":""
},
"shippingAddress":{
"street":"",
"city":"",
"state":"",
"country":"",


REST Reference

"postalCode":""
},
"annualRevenue":"1500",
"numberOfEmployees":"35",
"type":"Agriculture"
},
"groupDetail":{
"customFields":{
"CF2__c":"123"
},
"name":"Jones-Marshal HH",
"category":"Staying under the same roof",
"status":"Active",
"description":"Merged household from Jones and Marshal HH",
"type":"Household",
"groupSize":"52",
"groupIncome":"4132",
"primaryAddress":{
"street":"",
"city":"",
"state":"",
"country":"",
"postalCode":""
},
"partyRelationGroupId":"0wKRM000000001n2AA"
},
"member":{
"records":[
{
"acrId":"07kRM000000Op0fYAC",
"contactId":"003RM00000895N9YAI",
"isPrimaryMember":false,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Economic Decision Maker;Decision Maker",
"direct":false,
"customFields":{
"CF1__c":"2023-02-20",
"CF2__c":"CF2: Geoff"
},
"relations":[
]
},
{
"acrId":"07kRM000000KXvrYAG",
"contactId":"003RM00000895NDYAY",
"isPrimaryMember":true,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Decision Maker",
"direct":false,
"customFields":{
"CF1__c":"2023-02-19",


REST Reference

"CF2__c":"CF2: Howard"
},
"relations":[
]
},
{
"acrId":"07kRM000000KYHkYAO",
"contactId":"003RM000008D6q0YAC",
"isPrimaryMember":false,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Other;Influencer",
"direct":false,
"customFields":{
"CF1__c":"2023-03-08"
},
"relations":[
{
"ccrId":"0zmRM000000002EYAQ",
"roleRelationId":"0zlRM0000000014YAA",
"relatedContactId":"003RM00000895N9YAI",
"isActive":false
},
{
"ccrId":"0zmRM000000002NYAQ",
"roleRelationId":"0zlRM0000004CAaYAM",
"relatedContactId":"003RM00000895NFYAY",
"isActive":true
}
]
}
]
},
"externalMember":{
"records":[
{
"acrId":"07kRM000000KYHpYAO",
"contactId":"003RM00000895NFYAY",
"isPrimaryMember":false,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Technical Buyer",
"direct":false,
"relations":[
]
},
{
"acrId":"07kRM000000OpPdYAK",
"contactId":"003RM0000089pihYAA",
"isPrimaryMember":false,
"isActive":true,
"isPrimaryGroup":false,


REST Reference

"roles":"Influencer",
"direct":false,
"relations":[
]
}
]
},
"relatedGroup":{
"relations":[
{
"aarId":"0zoRM0000004CBKYA2",
"roleRelationId":"0zlRM000000001JYAQ",
"accountId":"001RM000005aVTBYA2",
"relatedAccountId":"001RM000005aGUcYAM",
"isActive":true,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM000000003KYAQ",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005YNUAYA4",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-05T00:00:00.000Z",
"endDate":"2023-03-31T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Parent",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM000000003PYAQ",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005YNUTYA4",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-05T00:00:00.000Z",
"endDate":"2023-03-31T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Parent",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM0000004CBAYA2",
"roleRelationId":"0zlRM000000001JYAQ",
"accountId":"001RM000005iEBkYAM",
"relatedAccountId":"001RM000005aGUcYAM",
"isActive":true,
"hierarchyType":"Peer",


REST Reference

"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM000000003GYAQ",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005YNUOYA4",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-05T00:00:00.000Z",
"endDate":"2023-03-31T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Parent",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM0000004CDPYA2",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005aVWKYA2",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-05T00:00:00.000Z",
"endDate":"2023-03-31T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Parent",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM0000004CBFYA2",
"roleRelationId":"0zlRM000000001JYAQ",
"accountId":"001RM000005aVSIYA2",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-07T00:00:00.000Z",
"endDate":"2023-04-08T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":false
}
}
]
},
"relatedAccount":{
"relations":[
{
"aarId":"0zoRM0000004CAuYAM",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005aGUcYAM",
"relatedAccountId":"001RM000005ZLa5YAG",
"isActive":true,
"hierarchyType":"Peer",


REST Reference

"customFields":{
"CF3__c":false,
"CF4__c":"A;C"
}
},
{
"aarId":"0zoRM0000004CB4YAM",
"roleRelationId":"0zlRM000000001JYAQ",
"accountId":"001RM000005aGUcYAM",
"relatedAccountId":"001RM000005aGUNYA2",
"isActive":false,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":false,
"CF4__c":"A;D"
}
},
{
"aarId":"0zoRM000000004mYAA",
"roleRelationId":"0zlRM000000001TYAQ",
"accountId":"001RM000005aGUcYAM",
"relatedAccountId":"001RM000005YXsUYAW",
"isActive":true,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":true,
"CF4__c":"A;C"
}
}
]
},
"tasks":[
"a03RM0000001Npi",
"a03RM0000001Npn"
]
}

Properties
Name

Type

Description

Required or
Optional

Available
Version

account
Detail

Account Input

Details of the merged account.

Required

58.0

external
Member

Member Record
Input

Details of the external members of a party Optional
relationship group.

58.0

groupDetail

Group Input

Details of the party relationship group,
such as category, address, group size,
group income, and custom fields.

Required

58.0

member

Member Record
Input

Details of the party relationship group
members.

Required

58.0


REST Reference

Name

Type

Description

Required or
Optional

Available
Version

primary
AccountId

String

ID of the primary account.

Required

58.0

related
Account

Account Relation
Input

Details of the related account.

Optional

58.0

Details of the party relationship group.

Optional

58.0

relatedGroup Account Relation

Input
secondary
AccountId

String

ID of the secondary account.

Required

58.0

tasks

String[]

List of the records to create tasks for. For Optional
example, a task to assign benefits from
the source party relationship group to
the destination party relationship group.

58.0

Response body for POST
Group Definition

Group Fields (GET)
Retrieve details from two party relationship groups.
Resource
/connect/group/group-fields

Resource example
https://yourInstance.salesforce.com/services/data/v66.0/connect/group/group-fields?groupIds=<0wKRM000000001n2AA>,<0wKRM000000004n2YY>

Available version
58.0
Requires Chatter
No
HTTP methods
GET
Request parameters for GET
Parameter
Name

Type

Description

Required or
Optional

groupIds

String[]

Comma-separated list of the group IDs to Required
merge the party relationship group details.

Response body for GET
Group Fields


Available
Version
58.0

REST Reference

Group Related Records (GET)
Get the related records of a party relationship group.
Resource
/connect/group/accounts/${accountId}/related-records

Resource example
https://yourInstance.salesforce.com/services/data/v66.0/connect/group/accounts/${001RM000005aVSIYA2}/related-records

Available version
58.0
Requires Chatter
No
HTTP methods
GET
Response body for GET
Group Related Entity

Request Bodies
The Group Membership and Households APIs have these request bodies.
Address Input
Input representation of an account address or a party relationship group address.
Account Input
Input representation of an account.
Account Relation Input
Input representation of an account relationship.
Group Definition Input
Input representation of a party relationship group definition.
Group Input
Input representation of a party relationship group.
Group Merge Input
Input representation of a merge party relationship group request.
Member Record Input
Input representation of the member records of a party relationship group.
Relationships Input
Input representation of the relationship among members of a party relationship group.

Address Input
Input representation of an account address or a party relationship group address.


REST Reference

JSON example
"billingAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"94263"
},
"shippingAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"94263"
},

Properties
Name

Type

Description

Required or
Optional

Available
Version

city

String

City of the account or the party
relationship group.

Optional

58.0

country

String

Country of the account or the party
relationship group.

Optional

58.0

postalCode

String

Postal code of the account or the party
relationship group.

Optional

58.0

state

String

State of the account or the party
relationship group.

Optional

58.0

street

String

Street of the account or the party
relationship group.

Optional

58.0

Account Input
Input representation of an account.
JSON example
"accountDetail":{
"name":"prg5",
"ownerId":"005xx000001X7tNAAS",
"billingAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"90042"
},


REST Reference

"shippingAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"11111"
},
"phone":"0123456789"
}

Properties
Name

Type

Description

Required or
Optional

Available
Version

accountId

String

ID of the account.

Required

58.0

Account number assigned to the account. Optional

58.0

Location of the account.

Optional

58.0

accountSource String

Source of the account record.

Optional

58.0

annualRevenue String

Estimated annual revenue of the account. Optional

58.0

billingAddress Address Input

Billing address of the account.

Optional

58.0

accountNumber String
accountSite

String

customFields

Map<String,
Object>

Custom fields associated with the account. Optional

58.0

description

String

Text description of the account.

Optional

58.0

fax

String

Fax number of the account.

Optional

58.0

industry

String

Industry associated with the account.

Optional

58.0

jigsaw

String

References the ID of a company in
Data.com.

Optional

58.0

name

String

Name of the account.

Required

58.0

numberOf
Employees

String

Number of employees working at the
company represented by the account.

Optional

58.0

ownerId

String

ID of the user who currently owns the
account.

Optional

58.0

ownership

String

Ownership type for the account.

Optional

58.0

parentId

String

ID of the parent object, if any.

Optional

58.0

phone

String

Phone number of the account.

Optional

58.0

rating

String

Account’s prospect rating.

Optional

58.0

recordType

String

ID of the record type assigned to the
object.

Optional

58.0


REST Reference

Name

Type

Description

Required or
Optional

Available
Version

shipping
Address

Address Input

Shipping address of the account.

Optional

58.0

sic

String

Standard Industrial Classification (SIC) code Optional
of the company’s main business
categorization.

58.0

sicDesc

String

Brief description of the org’s line of
business, based on its SIC code.

Optional

58.0

tickerSymbol

String

Stock market symbol of the account.

Optional

58.0

tier

String

Tier type of the account.

Optional

58.0

type

String

Type of account.

Optional

58.0

website

String

Website of the account.

Optional

58.0

Account Relation Input
Input representation of an account relationship.
JSON example
{
"relations":[
{
"type":"Direct",
"roleRelationId":"0zlxx000000001dAAA",
"relatedAccountId":"001xx000003GYodAAG",
"startDate":"2023-06-15T00:00:00.000Z",
"endDate":"2023-12-15T00:00:00.000Z",
"relatedInverseRecordId":"",
"isActive":true,
"customFields":{
"field1":"field1Value",
"field2":"field1Value"
}
},
{
"type":"Indirect",
"roleRelationId":"0zlxx000000001dGAC",
"accountId":"001xx000003GYodACD",
"startDate":"2023-02-15T00:00:00.000Z",
"endDate":"2023-09-15T00:00:00.000Z",
"isActive":true,
"customFields":{
"field1":"field1Value",
"field2":"field1Value"
}
}


REST Reference

]
}

Properties
Name

Type

Description

Required or
Optional

Available
Version

aarId

String

Record ID of the AccountRelationship
object.

Optional

58.0

accountId

String

Primary account involved in the
Optional
relationship. If the account relationship
type is direct, then Account ID is required.

58.0

customFields

Map<String,
Object>

Custom fields associated with the
AccountRelationship object.

Optional

58.0

endDate

String

Date when the account relationship ends. Optional

58.0

hierarchyType String

Hierarchy among the accounts that are
Optional
related. For example, an account is related
to another account as a parent, a peer, or
a child.

58.0

isActive

Boolean

Indicates whether the account is actively Optional
involved with the related account (true)
or not (false).

58.0

related
AccountId

String

Record ID of the related account. If the
account relationship type is direct, then
the related account ID is required.

Optional

58.0

related
Inverse
RecordId

String

Record ID of the related inverse
relationship record.

Optional

58.0

roleRelation
Id

String

Record ID of the party role relationship.

Required

58.0

startDate

String

Date when the account relationship starts. Optional

58.0

type

String

Type of account relationship, such as a
Optional
direct or indirect relationship. The default
value is false. If the related
InverseRecordId property is
specified, then the relationship type is
indirect.

58.0

Group Definition Input
Input representation of a party relationship group definition.


REST Reference

JSON example
{
"accountDetail":{
"name":"prg5",
"ownerId":"005xx000001X7tNAAS",
"billingAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"90042"
},
"shippingAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"90042"
},
"phone":"0123456789"
},
"groupDetail":{
"name":"prg5",
"category":"Staying under the same roof",
"type":"Household",
"groupSize":"2",
"groupIncome":"20000",
"primaryAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"90042"
}
},
"member":{
"records":[
{
"contactId":"003xx000004WhHQAA0",
"roles":"Decision Maker",
"relations":[
{
"roleRelationId":"0zlxx0000000001AAA",
"relatedContactId":"003xx000004WhJ2AAK",
"startDate":"2023-06-14T00:00:00.000Z"
}
]
}
]
},
"externalMember":{
"records":[
{


REST Reference

"contactId":"003xx000004WhJ2AAK",
"roles":"Decision Maker"
}
]
},
"relatedGroup":{
"relations":[
{
"type":"Direct",
"roleRelationId":"0zlxx000000001dAAA",
"relatedAccountId":"001xx000003GYodAAG"
}
]
},
"relatedAccount":{
"relations":[
]
}
}

Properties
Name

Type

accountDetail Map<String,

Description

Required or
Optional

Available
Version

Account details associated with the party Required
relationship group.

58.0

Object>
external
Member

Member Record
Input[]

External member details of the party
relationship group.

Optional

58.0

groupDetail

Map<String,
Object>

Party relationship group details, such as
group size, group income, address, and
associated custom fields.

Required

58.0

member

Member Record
Input[]

Member details of the party relationship
group being created.

Required

58.0

related
Account

Account Relation
Input[]

Data of the account that’s related to the
party relationship group being created.

Optional

58.0

relatedGroup

Account Relation
Input[]

Data of the group that’s related to the
party relationship group being created.

Optional

58.0

Group Input
Input representation of a party relationship group.
JSON example
"groupDetail":{
"name":"prg5",
"category":"Staying under the same roof",


REST Reference

"type":"Household",
"groupSize":"2",
"groupIncome":"20000",
"primaryAddress":{
"street":"",
"city":"Los Angeles",
"state":"California",
"country":"USA",
"postalCode":"90042"
}
}

Properties
Name

Type

Description

category

String

Category of the party relationship group. Optional

58.0

customFields

Map<String,
Object>

Custom fields associated with the party
relationship group.

Optional

58.0

description

String

Description of the party relationship group. Optional

58.0

endDate

String

End date associated with the party
relationship group.

Optional

58.0

groupIncome

String

Total income of the party relationship
group.

Optional

58.0

groupSize

String

Number of active members associated
with the party relationship group.

Optional

58.0

name

String

Name of the party relationship group.

Required

58.0

Record ID of the party relationship group. Required
Record ID is optional when creating a
group and required when merging groups.

58.0

partyRelation String
GroupId

Required or
Optional

Available
Version

primary
Address

Address Input

Primary address of the party relationship
group.

Required

58.0

startDate

String

Start date associated with the party
relationship group.

Optional

58.0

status

String

Status of the party relationship group. Valid Optional
values are:

58.0

• Active
• Inactive
subtype

String

Subclassification of the party relationship Optional
group type.


58.0

REST Reference

Name

Type

Description

Required or
Optional

type

String

Type of the party relationship group. Valid Required
values are:
• Group
• Household

Group Merge Input
Input representation of a merge party relationship group request.
JSON example
{
"primaryAccountId":"001RM000005aGUcYAM",
"secondaryAccountId":"001RM000005YYfiYAG",
"accountDetail":{
"customFields":{
"Account_CF1__c":"123",
"Account_CF2__c":"342"
},
"name":"Jones-Marshal HH",
"fax":"213762",
"billingAddress":{
"street":"",
"city":"",
"state":"",
"country":"",
"postalCode":""
},
"shippingAddress":{
"street":"",
"city":"",
"state":"",
"country":"",
"postalCode":""
},
"annualRevenue":"1500",
"numberOfEmployees":"35",
"type":"Agriculture"
},
"groupDetail":{
"customFields":{
"CF2__c":"123"
},
"name":"Jones-Marshal HH",
"category":"Staying under the same roof",
"status":"Active",
"description":"Merged household from Jones and Marshal HH",
"type":"Household",
"groupSize":"52",
"groupIncome":"4132",


Available
Version
58.0

REST Reference

"primaryAddress":{
"street":"",
"city":"",
"state":"",
"country":"",
"postalCode":""
},
"partyRelationGroupId":"0wKRM000000001n2AA"
},
"member":{
"records":[
{
"acrId":"07kRM000000Op0fYAC",
"contactId":"003RM00000895N9YAI",
"isPrimaryMember":false,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Economic Decision Maker;Decision Maker",
"direct":false,
"customFields":{
"CF1__c":"2023-02-20",
"CF2__c":"CF2: Geoff"
},
"relations":[
]
},
{
"acrId":"07kRM000000KXvrYAG",
"contactId":"003RM00000895NDYAY",
"isPrimaryMember":true,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Decision Maker",
"direct":false,
"customFields":{
"CF1__c":"2023-02-19",
"CF2__c":"CF2: Howard"
},
"relations":[
]
},
{
"acrId":"07kRM000000KYHkYAO",
"contactId":"003RM000008D6q0YAC",
"isPrimaryMember":false,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Other;Influencer",
"direct":false,
"customFields":{
"CF1__c":"2023-03-08"
},


REST Reference

"relations":[
{
"ccrId":"0zmRM000000002EYAQ",
"roleRelationId":"0zlRM0000000014YAA",
"relatedContactId":"003RM00000895N9YAI",
"isActive":false
},
{
"ccrId":"0zmRM000000002NYAQ",
"roleRelationId":"0zlRM0000004CAaYAM",
"relatedContactId":"003RM00000895NFYAY",
"isActive":true
}
]
}
]
},
"externalMember":{
"records":[
{
"acrId":"07kRM000000KYHpYAO",
"contactId":"003RM00000895NFYAY",
"isPrimaryMember":false,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Technical Buyer",
"direct":false,
"relations":[
]
},
{
"acrId":"07kRM000000OpPdYAK",
"contactId":"003RM0000089pihYAA",
"isPrimaryMember":false,
"isActive":true,
"isPrimaryGroup":false,
"roles":"Influencer",
"direct":false,
"relations":[
]
}
]
},
"relatedGroup":{
"relations":[
{
"aarId":"0zoRM0000004CBKYA2",
"roleRelationId":"0zlRM000000001JYAQ",
"accountId":"001RM000005aVTBYA2",
"relatedAccountId":"001RM000005aGUcYAM",
"isActive":true,
"hierarchyType":"Peer",


REST Reference

"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM000000003KYAQ",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005YNUAYA4",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-05T00:00:00.000Z",
"endDate":"2023-03-31T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Parent",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM000000003PYAQ",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005YNUTYA4",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-05T00:00:00.000Z",
"endDate":"2023-03-31T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Parent",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM0000004CBAYA2",
"roleRelationId":"0zlRM000000001JYAQ",
"accountId":"001RM000005iEBkYAM",
"relatedAccountId":"001RM000005aGUcYAM",
"isActive":true,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM000000003GYAQ",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005YNUOYA4",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-05T00:00:00.000Z",
"endDate":"2023-03-31T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Parent",
"customFields":{
"CF3__c":false
}
},


REST Reference

{
"aarId":"0zoRM0000004CDPYA2",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005aVWKYA2",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-05T00:00:00.000Z",
"endDate":"2023-03-31T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Parent",
"customFields":{
"CF3__c":false
}
},
{
"aarId":"0zoRM0000004CBFYA2",
"roleRelationId":"0zlRM000000001JYAQ",
"accountId":"001RM000005aVSIYA2",
"relatedAccountId":"001RM000005aGUcYAM",
"startDate":"2023-03-07T00:00:00.000Z",
"endDate":"2023-04-08T00:00:00.000Z",
"isActive":true,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":false
}
}
]
},
"relatedAccount":{
"relations":[
{
"aarId":"0zoRM0000004CAuYAM",
"roleRelationId":"0zlRM0000004C9mYAE",
"accountId":"001RM000005aGUcYAM",
"relatedAccountId":"001RM000005ZLa5YAG",
"isActive":true,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":false,
"CF4__c":"A;C"
}
},
{
"aarId":"0zoRM0000004CB4YAM",
"roleRelationId":"0zlRM000000001JYAQ",
"accountId":"001RM000005aGUcYAM",
"relatedAccountId":"001RM000005aGUNYA2",
"isActive":false,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":false,
"CF4__c":"A;D"
}
},


REST Reference

{
"aarId":"0zoRM000000004mYAA",
"roleRelationId":"0zlRM000000001TYAQ",
"accountId":"001RM000005aGUcYAM",
"relatedAccountId":"001RM000005YXsUYAW",
"isActive":true,
"hierarchyType":"Peer",
"customFields":{
"CF3__c":true,
"CF4__c":"A;C"
}
}
]
},
"tasks":[
"a03RM0000001Npi",
"a03RM0000001Npn"
]
}

Properties
Name

Type

accountDetail Account Input

Description

Required or
Optional

Available
Version

Details of the merged account.

Required

58.0

external
Member

Member Record
Input

Details of the external members of a party Optional
relationship group.

58.0

groupDetail

Group Input

Details of the party relationship group,
such as category, address, group size,
group income, and custom fields.

Required

58.0

member

Member Record
Input

Details of the party relationship group
members.

Required

58.0

primary
AccountId

String

ID of the primary account.

Required

58.0

related
Account

Account Relation
Input

Details of the related account.

Optional

58.0

relatedGroup

Account Relation
Input

Details of the party relationship group.

Optional

58.0

secondary
AccountId

String

ID of the secondary account.

Required

58.0

tasks

String[]

List of the records to create tasks for. For Optional
example, a task to assign benefits from the
source party relationship group to the
destination party relationship group.

58.0


REST Reference

Member Record Input
Input representation of the member records of a party relationship group.
JSON example
{
"records":[
{
"contactId":"003xx000004WhHQAA0",
"roles":"Decision Maker",
"relations":[
{
"roleRelationId":"0zlxx0000000001AAA",
"relatedContactId":"003xx000004WhJ2AAK",
"startDate":"2023-06-14T00:00:00.000Z"
}
]
}
]
}

Properties
Name

Type

Description

Required or
Optional

acrId

String

ID of the Account Contact relationship.

The acrId
58.0
property is required
if an account ID is
specified when
defining a party
relationship group.

contactId

String

ID of the Contact.

Required

58.0

customFields

Map<String,
Object>

Custom fields associated with a party
relationship group member.

Optional

58.0

Category of the data roll-up summary field. Optional

58.0

dataRollupCategory String

Available
Version

direct

Boolean

Indicates whether the member
Optional
relationship is a direct relationship (true)
or not (false).

58.0

endDate

Date

Date when the member relationship ends. Optional

58.0

relations

Relationships Input Details of the member record relationship. Optional

58.0

roles

String

Role of the member in the party
Required
relationship group. For example, a decision
maker role or a caregiver role.

58.0

startDate

Date

Date when the member relationship starts. Optional

58.0


REST Reference

Relationships Input
Input representation of the relationship among members of a party relationship group.
JSON example
"relations":[
{
"roleRelationId":"0zlRM0000004CAaYAM",
"relatedContactId":"003RM00000895NFYAY",
"startDate":"2023-06-14T00:00:00.000Z",
"endDate":"2024-06-14T00:00:00.000Z",
"isActive":true,
"customFields":{
"field1":"field1Value",
"field2":"field1Value"
}
}
]

Properties
Name

Type

Description

Required or
Optional

Available
Version

ccrId

String

Record ID of the
ContactContactRelationship object.

Optional

58.0

customFields

Map<String,
Object>

Custom fields associated with the
ContactRelationship object.

Optional

58.0

endDate

String

Date when the contact relationship ends. Optional

58.0

Hierarchy among the contacts that are
related.

Optional

58.0

Indicates whether the relationship is active Optional
(true) or not (false).

58.0

relatedContactId String

Record ID of the RelatedContact object.

Required

58.0

relatedInverseRecordId String

Record ID of the related inverse record.

Optional

58.0

roleRelationId String

Record ID of the PartyRoleRelation object. Required

58.0

String

Date when the contact relationship starts. Optional

58.0

hierarchyType String

isActive

startDate

Boolean

Response Bodies
The Group Membership and Households APIs have these response bodies.
Group Definition
Output representation of a party relationship group definition.
Group Fields
Output representation of the fields of the party relationship groups to be merged.


REST Reference

Group Related Entity
Output representation of the request to fetch the related records of a party relationship group.

Group Definition
Output representation of a party relationship group definition.
JSON example
{
"accountId": "001RM000005mkcuYAA",
"code": "200",
"isSuccess": true,
"message": "",
"partyRelationshipId": "0wKRM00000000BT2AY"
}

Property Name

Type

Description

Filter Group and
Version

Available Version

accountId

String

Record ID of the Account object.

Small, 58.0

58.0

code

String

Error code with details of the error.

Small, 58.0

58.0

isSuccess

Boolean

Indicates whether the create request is
successful (true) or not (false).

Small, 58.0

58.0

message

String

Message of the API request.

Small, 58.0

58.0

Record ID of the PartyRelationshipGroup
object.

Small, 58.0

58.0

partyRelationshipId String

Group Fields
Output representation of the fields of the party relationship groups to be merged.
JSON example
{
"accountFields":[
"field1",
"field2",
"field3",
"customFields":[
"customField1",
"customField2"
]
],
"prgFields":[
"field1",
"field2",
"field3",
"customFields":[
"customField1",
"customField2"


REST Reference

]
],
"accId1":{
"Account":{
"name":"Account A",
"shippingAddress":"",
"customFields":{
"customField1":"sample_customfield1",
"customField2":"sample_customfield2"
}
},
"PRG":{
"name":"Smith Household",
"category":"Staying under the same roof",
"customFields":{
"customField1":"sample_customfield3",
"customField2":"sample_customfield4"
}
}
},
"accId2":{
"Account":{
"name":"Account B",
"shippingAddress":"",
"customFields":{
"customField1":"sample_customfield5",
"customField2":"sample_customfield6"
}
},
"PRG":{
"name":"Marshall Household",
"category":"Staying under the same roof",
"customFields":{
"customField1":"sample_customfield7",
"customField2":"sample_customfield8"
}
}
}
}

Property Name

Type

Description

accId1

Map<String,
Object>

ID of the primary party relationship group. Small, 58.0

58.0

accId2

Map<String,
Object>

ID of the secondary party relationship group. Small, 58.0

58.0

List of fields associated with the account.

Small, 58.0

58.0

List of fields associated with the party
relationship group.

Small, 58.0

58.0

accountFields Object[]
prgFields

Object[]

Filter Group and
Version


Available Version

REST Reference

Group Related Entity
Output representation of the request to fetch the related records of a party relationship group.
JSON example
{
"relatedEntities":{
"Task":[
"00Txx000003rIRU",
"00Txx000003rIUi"
],
"CaseParticipant":[
"1caxx00000000BL"
],
"ContentDocumentLink":[
"06Axx0000004C93"
],
"Case":[
"500xx000000bod7",
"500xx000000boej"
],
"Contact":[
"003xx000004Wi5Q"
],
"PublicComplaint":[
"0fhxx000000006T"
],
"WorkOrder":[
"0WOxx0000000001"
],
"CarePlan":[
"1spxx000000003F"
],
"Opportunity":[
"006xx000001a332",
"006xx000001a34e",
"006xx000001a36G"
],
"Lead":[
"00Qxx000002TRbO"
],
"Entity1__c":[
"a01xx000003GaSF"
],
"Asset":[
"02ixx0000004HHi"
],
"Allegation__c":[
"a00xx000000bobV"
],
"Contract":[
"800xx000000bohx"
]
}
}


Property Name

Type

relatedEntities Map<String,

String[]>

REST Reference

Description

Filter Group and
Version

Map of the related objects and their record Small, 58.0
IDs. For example, case participants, tasks,
cases, contacts, and public complaints.


Available Version
58.0


# Chapter 11: Record Rollup Definitions

In this chapter ...
•

Record Rollup
Definitions Standard
Objects

•

Record Rollup
Definitions Business
APIs

•

Record Rollup
Definitions Metadata
API Types

•

Record Rollup
Definitions Tooling
API Objects

Use Record Rollup Definitions to streamline the aggregation of records from various objects or groups.
They also give a consolidated view of data so that your business executives can make accurate decisions
swiftly and effortlessly.
SEE ALSO:
Salesforce Help: Record Rollup Definitions
Salesforce Help: Record Rollup Definitions Basics


Record Rollup Definitions Standard Objects

Record Rollup Definitions Standard Objects
Use standard objects to manage record rollup definitions and data aggregation among records.
RecordAggregationResult
Represents a data aggregation from one record to another record based on the record aggregation definition for the corresponding
objects. This object is available in API version 59.0 and later.

RecordAggregationResult
Represents a data aggregation from one record to another record based on the record aggregation definition for the corresponding
objects. This object is available in API version 59.0 and later.

Supported Calls
create(), delete(), describeLayout(), describeSObjects(), getDeleted(), getUpdated(), query(),
retrieve(), search(), undelete(), update(), upsert()

Special Access Rules
This object is available if your org has the Record Aggregation permission set license, and you have the Record Aggregation Access
permission.

Fields
Field

Details

AggregateFromRecordId

Type
reference
Properties
Create, Filter, Group, Sort, Update
Description
The record from which data is aggregated.
This field is a polymorphic relationship field.
Relationship Name
AggregateFromRecord
Relationship Type
Lookup

AggregateToRecordId

Type
reference
Properties
Create, Filter, Group, Sort, Update


Description
The record to which data is aggregated.
This field is a polymorphic relationship field.
Relationship Name
AggregateToRecord
Relationship Type
Lookup

LastReferencedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last accessed this record indirectly, for example, through
a list view or related record.

LastViewedDate

Type
dateTime
Properties
Filter, Nillable, Sort
Description
The timestamp when the current user last viewed this record or list view. If this value is null,
and LastReferenceDate is not null, the user accessed this record or list view indirectly.

Name

Type
string
Properties
Autonumber, Defaulted on create, Filter, idLookup, Sort
Description
The name of the record aggregation result.

OwnerId

Type
reference
Properties
Create, Defaulted on create, Filter, Group, Sort, Update
Description
The ID of the owner of this object.
This field is a polymorphic relationship field.
Relationship Name
Owner


Record Rollup Definitions Business APIs

Details
Relationship Type
Lookup
Refers To
Group, User

RecordAggregationDefinitionId Type

reference
Properties
Create, Filter, Group, Sort, Update
Description
The record aggregation definition for the data aggregation from the aggregate-from record
to the aggregate-to record.
This field is a relationship field.
Relationship Name
RecordAggregationDefinition
Relationship Type
Lookup
Refers To
RecordAggregationDefinition

Associated Objects
This object has the following associated objects. If the API version isn’t specified, they’re available in the same API versions as this object.
Otherwise, they’re available in the specified API version and later.
RecordAggregationResultChangeEvent (API Version 63.0)
Change events are available for the object.
RecordAggregationResultOwnerSharingRule
Sharing rules are available for the object.
RecordAggregationResultShare
Sharing is available for the object.

Record Rollup Definitions Business APIs
Use the Record Rollup Definitions Business APIs to get a consolidated view of data for a specific record aggregation definition. You can
sort data by name and arrange it in ascending or descending order.


REST Reference

Available Resources
Resource

Description

/connect/record-aggregation/recordAggregationDefinitionId/record-rollup-results Get rollup results for a specific record aggregation definition. Sort

on page 711 (POST)

the data by name and arrange it in ascending or descending order.

/connect/record-aggregation/dpe-generation Generate a Data Processing Engine (DPE) definition for the record

on page 710 (POST)

aggregation definitions that you have configured. Run the DPE
definition to aggregate records.

REST Reference
You can access Record Rollup Definitions Business APIs by using the REST endpoint that follows similar conventions as Connect REST
APIs.

REST Reference
You can access Record Rollup Definitions Business APIs by using the REST endpoint that follows similar conventions as Connect REST
APIs.
Resources
Learn more about the available resource of Record Rollup Definitions Business APIs.
Requests
Learn more about the available request body of Record Rollup Definitions Business APIs.
Responses
Learn more about the available response bodies of Record Rollup Definitions Business APIs.
SEE ALSO:
Connect REST API Developer Guide: Connect REST API Introduction

Resources
Learn more about the available resource of Record Rollup Definitions Business APIs.
Record Aggregation DPE Definition Generation (POST)
Generate a Data Processing Engine (DPE) definition for the record aggregation definitions that you have configured. Run the DPE
definition to aggregate records.
Record Rollup Definitions (POST)
Get rollup results for a specific record aggregation definition. Sort the data by name and arrange it in ascending or descending order.

Record Aggregation DPE Definition Generation (POST)
Generate a Data Processing Engine (DPE) definition for the record aggregation definitions that you have configured. Run the DPE definition
to aggregate records.


REST Reference

Generate a DPE definition for a record aggregation definition or for all the record aggregation definitions that you have configured.
After you generate a DPE definition, if you configure a new record aggregation definition, generate a DPE definition for all your record
aggregation definitions. If you generate a DPE definition for only the new record aggregation definition, the request overwrites the
definition that you generated before and doesn’t append to it.
The DPE definition is generated subject to the Data Processing Engine limits.
Resource
/connect/record-aggregation/dpe-generation

Resource example
https://yourInstance.salesforce.com/services/data/v66.0/connect/record-aggregation/dpe-generation

Available version
59.0
Requires Chatter
No
HTTP methods
POST
Request body for POST
JSON example
{
"definitionId": "ALL"
}

Properties
Name

Type

definitionId String

Description

Required or
Optional

Available
Version

ID of a record aggregation definition
component.

Required

59.0

To generate a Data Processing Engine
definition for all the active record
aggregation definition components,
specify ALL.

Response body for POST
Data Processing Engine Definition List Output
SEE ALSO:
Salesforce Help: Data Processing Engine Limits

Record Rollup Definitions (POST)
Get rollup results for a specific record aggregation definition. Sort the data by name and arrange it in ascending or descending order.


REST Reference

Resource
/connect/record-aggregation/recordAggregationDefinitionId/record-rollup-results

The recordAggregationDefinitionId parameter is the ID of the record aggregation definition.
Resource example
https://yourInstance.salesforce.com/services/data/v66.0/connect/record-aggregation/16y0000001/record-rollup-results?anchorRecordId=10s0000001

Available version
61.0
HTTP methods
POST
Query parameters for POST
Parameter
Name

Type

anchorRecordId String

Description

Required or
Optional

ID of the record to which the aggregated Required
records are rolled up.

Available
Version
61.0

Request body for POST
JSON example
{
"sortBy": "Name",
"isSortOrderAscending": true
}

Properties
Name

Type

Description

Required or
Optional

isSortOrder
Ascending

Boolean

Indicates whether the sort order is
Optional
ascending (true) or not (false). The
default value is true.

61.0

sortBy

String

Criteria to sort the record aggregation
results. The default value is
CreatedDate.

61.0

Response body for POST
Record Rollup Results

Requests
Learn more about the available request body of Record Rollup Definitions Business APIs.


Optional

Available
Version

REST Reference

Record Aggregation Definition Input
Input representation of a Record Aggregation Data Processing Engine definition generation request.
Record Rollup Result Input
Input representation to sort and fetch the record rollup results.

Record Aggregation Definition Input
Input representation of a Record Aggregation Data Processing Engine definition generation request.
JSON example
{
"definitionId": "ALL"
}

Properties
Name

Type

Description

Required or
Optional

Available
Version

definitionId

String

ID of a record aggregation definition
component.

Required

59.0

To generate a Data Processing Engine
definition for all the active record
aggregation definition components,
specify ALL.

Record Rollup Result Input
Input representation to sort and fetch the record rollup results.
JSON example
{
"sortBy": "Name",
"isSortOrderAscending": true
}

Properties
Name

Type

Description

Required or
Optional

Available
Version

isSortOrder
Ascending

Boolean

Indicates whether the sort order is
ascending (true) or not (false). The
default value is true.

Optional

61.0

sortBy

String

Criteria to sort the record aggregation
results. The default value is
CreatedDate.

Optional

61.0


REST Reference

Responses
Learn more about the available response bodies of Record Rollup Definitions Business APIs.
Refer to the HTTP response code to check whether the request was successful, as well as viewing the error messages for the failed
requests.
Data Processing Engine Definition List Output
Output representation of a Record Aggregation Data Processing Engine definition generation request.
Record Rollup Results
Output representation of the record rollup results.
Record Rollup Result Column
Output representation of the consolidated view of the table column data.
Record Rollup Result Last Updated Details
Represents the last updated information of the record rollup results.
Record Rollup Result Row
Output representation of the consolidated view of the table row data.

Data Processing Engine Definition List Output
Output representation of a Record Aggregation Data Processing Engine definition generation request.
JSON example
{
"code": "200",
"dpeIds": [
"9N1SB00000006IL0AY"
],
"isSuccess": true,
"message": "DPE Generated Successfully"
}

Property Name

Type

Description

Filter Group and
Version

Available Version

code

String

Status code of the request.

Small, 59.0

59.0

dpeIds

String[]

List of Data Processing Engine definition IDs. Small, 59.0

59.0

isSuccess

Boolean

Indicates whether the Data Processing
Engine definition is generated (true) or
not (false).

Small, 59.0

59.0

message

String

Indicates whether the generation of the
Data Processing Engine definition
succeeded or failed.

Small, 59.0

59.0

Record Rollup Results
Output representation of the record rollup results.


REST Reference

JSON Example
{
"columns": [
{
"fieldApiName": "Name",
"displayFormatType": "text",
"fieldLabel": "Name",
"sequence": 0,
"isRedirectionEnabled": true,
"isSortable": true,
"isTypeName": true,
"sortByField": "Name"
},
{
"fieldApiName": "BranchUnit",
"displayFormatType": "reference",
"fieldLabel": "Branch Unit",
"sequence": 4,
"isRedirectionEnabled": true,
"isSortable": true,
"isTypeName": false,
"sortByField": "BranchUnit.Name"
}
],
"message": "Successful",
"rows": [
{
"rowData": {
"Status": "Active",
"Type": "Savings",
"Id": "0c7xx000000006TAAQ",
"FinancialAccountNumber": "*********0001",
"Name": "John Doe",
"Case__c": {
"Id": "Some ID",
"CaseNumber": "000001"
}
}
}
],
"statusCode": "200",
"totalResultCount": 1,
"definitionDisplayName": "Savings Financial Account"
"lastUpdatedDetails": {
"errorType": "NOT_FOUND",
"epochTime": 1733734423000,
"processingMode": "Batch"
}
}


REST Reference

Property Name

Type

Description

Filter Group and
Version

Available Version

columns

Record Rollup Result List of fields that represent the columns of Small, 61.0
Column[]
a table.

61.0

definition
DisplayName

String

Name of the record aggregation definition. Small, 61.0

61.0

message

String

Message for the HTTP response code.

Small, 61.0

61.0

lastUpdated
Details

Record Rollup Result The information about the last time the
Last Updated
record rollup results were updated for the
Details[]
specified definition and anchor record ID.

Small, 64.0

64.0

rows

Record Rollup Result List of aggregated records that represent
Row[]
the rows of a table.

Small, 61.0

61.0

statusCode

String

HTTP response code for the request.

Small, 61.0

61.0

totalResult
Count

Integer

Total number of record aggregation results. Small, 61.0

61.0

Record Rollup Result Column
Output representation of the consolidated view of the table column data.
JSON Example
"columns": [
{
"fieldApiName": "Name",
"displayFormatType": "text",
"fieldLabel": "Name",
"sequence": 0,
"isRedirectionEnabled": true,
"isSortable": true,
"isTypeName": true,
"sortByField": "Name"
}
]

Property Name

Type

displayFormat String
Type

Description

Filter Group and
Version

Available Version

Data type of the field that represents the
Small, 61.0
column. This data type corresponds to the
type recognized by the Lightning data table.

61.0

fieldApiName

String

API name of the field that represents the
column of the table.

Small, 61.0

61.0

fieldLabel

String

Name of the field that represents the
column of the table.

Small, 61.0

61.0


Property Name

REST Reference

Type

Description

Filter Group and
Version

Available Version

isRedirection Boolean
Enabled

Indicates whether clicking the column label Small, 61.0
redirects to the relevant record details page
(true) or not (false). The value is true
if fieldApiName is Name or if
displayFormatType is
reference, which is a Lookup relation
in Salesforce.

61.0

sequence

Integer

Sequence in which the column appears in Small, 61.0
the data table.

61.0

isSortable

Boolean

Indicates whether the column is sortable
(true) or not (false).

Small, 61.0

61.0

isTypeName

Boolean

Indicates whether the field is of type Name Small, 61.0
(true) or not (false).

61.0

sortByField

String

Represents the field that’s used to sort the Small, 61.0
table.

61.0

Record Rollup Result Last Updated Details
Represents the last updated information of the record rollup results.
JSON Example
"lastUpdatedDetails": {
"errorType": "NOT_FOUND",
"epochTime": 1733734423000,
"processingMode": "Batch"
}

Property Name

Type

Description

Filter Group and
Version

epochTime

Long

The epoch timestamp in milliseconds when Small, 64.0
the record rollup results were last updated
for the specified definition and anchor
record ID.

64.0

errorType

String

Type of error encountered while fetching
the last updated record rollup definition
details.

Small, 64.0

64.0

processingMode String

The record rollup mode used to generate
the last updated details. Valid Values are:

Small, 64.0

64.0

• Batch
• On-Demand


Available Version

Record Rollup Definitions Metadata API Types

Record Rollup Result Row
Output representation of the consolidated view of the table row data.
JSON Example
"rows": [
{
"rowData": {
"Status": "Active",
"Type": "Savings",
"Id": "0c7xx000000006TAAQ",
"FinancialAccountNumber": "*********0001",
"Name": "John Doe",
"Case__c": {
"Id": "Some ID",
"CaseNumber": "000001"
}
}
}
]

Property Name

Type

Description

Filter Group and
Version

Available Version

rowData

Map<String,
Object>

Map of key-value pairs, where key
represents the field API name and value
represents the field value.

Small, 61.0

61.0

Record Rollup Definitions Metadata API Types
Metadata API enables you to access some types and feature settings that you can customize in the user interface.
RecordAggregationDefinition
Represents a data aggregation from one object to another object to which it is connected by other objects in the data model.
SEE ALSO:
Metadata API Developer Guide: Understanding Metadata API

RecordAggregationDefinition
Represents a data aggregation from one object to another object to which it is connected by other objects in the data model.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Parent Type
This type extends the Metadata metadata type and inherits its fullName field.


File Suffix and Directory Location
RecordAggregationDefinition components have the suffix .RecordAggregationDefinition and are stored in the
RecordAggregationDefinitions folder.

Version
RecordAggregationDefinition components are available in API version 59.0 and later.

Special Access Rules
To access the RecordAggregationDefinition metadata type, you must have the Record Aggregation permission set license and the Record
Aggregation Access permission.

Fields
Field Name

Description

aggregateFromObject

Field Type
string
Description
Required.
API name of the object from which data is aggregated.

aggregateToObject

Field Type
string
Description
Required.
API name of the object to which data is aggregated.

aggregationType

Field Type
RecordAggregationDefinitionAggregationType (enumeration of type string)
Description
Required.
Type of the data aggregation.
Valid value is:
• Record

batchProcessingDefinition

Field Type
string
Description
Data Processing Engine definition that aggregates data from one record to another.


Field Name

Description

description

Field Type
string
Description
Description for this record aggregation definition.

displayName

Field Type
string
Description
Required.
Name of the record aggregation definition that's displayed in the record page.

onDemandProcDefinition

Field Type
string
Description
Data Processing Engine definition that aggregates data from one record to another
on demand. Available in API version 63.0 and later.

recordAggregationObject

Field Type
RecordAggregationObject[]
Description
List of record aggregation objects in the record aggregation join sequence.

status

Field Type
RecordAggregationDefinitionStatus (enumeration of type string)
Description
Required.
Status of this record aggregation definition.
Values are:
• Active
• Draft
• Inactive

RecordAggregationObject
Represents an object in the record aggregation join sequence.
Field Name

Description

associatedObject

Field Type
string


Field Name

RecordAggregationDefinition

Description
Description
Required.
API name of the object associated with this record aggregation object.

developerName

Field Type
string
Description
Developer name of the record aggregation object. May contain only underscores and
alphanumeric characters and must be unique in your org. It must begin with a letter,
not include spaces, not end with an underscore, and not contain two consecutive
underscores.

filterLogic

Field Type
string
Description
Logical sequence in which the record aggregation object filters associated with this
record aggregation object are applied to the associated object's records. If you define
two or more record aggregation object filters, but don’t specify the sequence in which
to apply the filters, the filters are applied by using a logical AND expression.
Available in API version 60.0 and later.

masterLabel

Field Type
string
Description
Required.
A user-friendly name for RecordAggregationDefinition, which is defined when the
RecordAggregationDefinition is created.

recordAggregationJoinCondition Field Type

RecordAggregationJoinCondition[]
Description
List of join conditions that apply to this record aggregation object.
recordAggregationObjectFilter Field Type

RecordAggregationObjectFilter[]
Description
List of filters that are applied to the records of this record aggregation object.
Available in API version 60.0 and later.


Represents a condition in a join between two record aggregation objects.
Field Name

Description

joinField

Field Type
string
Description
Required.
API name of the field on the record aggregation object's associated object that is used
in the join condition.

navigationSequenceNumber

Field Type
int
Description
Required.
Sequence number corresponding to this join in the join sequence from the object to
which the data is aggregated to the object that contains the data being aggregated.

relatedJoinField

Field Type
string
Description
Required.
API name of the field on the related record aggregation object's associated object that
is used in the join condition.

relatedRecordAggregationObject Field Type

string
Description
Required.
Second record aggregation object in the join condition.
type

Field Type
RecordAggregationJoinConditionType (enumeration of type string)
Description
Required.
Type of this record aggregation join in the join path from the object to which the data
is aggregated to the object that contains the data being aggregated.
Valid values are:
• AggregateFrom
• AggregateTo
• Intermediate


Represents a filter that is applied to the records of an object in the record aggregation join sequence. Available in API version 60.0 and
later.
Field Name

Description

associatedObjectField

Field Type
string
Description
Required.
API name of the associated object's field whose value is used to filter the object's
records. The associated object is specified in the record aggregation object.

operator

Field Type
RecordAggregationObjectFilterOperator (enumeration of type string)
Description
Required.
Operator used in the filter expression.
Values are:
• Contains
• Equals
• GreaterThan
• GreaterThanOrEquals
• In
• LessThan
• LessThanOrEquals
• NotEquals
• NotIn

sequenceNumber

Field Type
int
Description
Required.
Sequence number of this record aggregation object filter.

value

Field Type
string
Description
Required.
Reference value with which the designated field's values are compared when the filter
is applied on the associated object's records.


Declarative Metadata Sample Definition
The following is an example of a RecordAggregationDefinition component.
<?xml version="1.0" encoding="UTF-8"?>
<RecordAggregationDefinition xmlns="http://soap.sforce.com/2006/04/metadata">
<aggregateToObject>PartyRelationshipGroup</aggregateToObject>
<aggregateFromObject>PartyIncome</aggregateFromObject>
<status>Active</status>
<aggregationType>Record</aggregationType>
<description>Aggregate head of household's income to household</description>
<displayName>Party Income to Party Relationship Group</displayName>
<recordAggregationObject>
<associatedObject>PartyRelationshipGroup</associatedObject>
<masterLabel>Party Relationship Group Object</masterLabel>
<developerName>PartyRelationshipGroupObject</developerName>
<recordAggregationJoinCondition>
<joinField>Account</joinField>
<navigationSequenceNumber>1</navigationSequenceNumber>
<relatedJoinField>Account</relatedJoinField>
<relatedRecordAggregationObject>AccountContactrelationObject</relatedRecordAggregationObject>
<type>Intermediate</type>
</recordAggregationJoinCondition>
<recordAggregationObjectFilter>
<associatedObjectField>Type</associatedObjectField>
<operator>Equals</operator>
<value>Household</value>
<sequenceNumber>1</sequenceNumber>
</recordAggregationObjectFilter>
</recordAggregationObject>
<recordAggregationObject>
<associatedObject>AccountContactRelation</associatedObject>
<masterLabel>Account Contact Relation Object</masterLabel>
<developerName>AccountContactRelationObject</developerName>
<recordAggregationJoinCondition>
<joinField>Contact</joinField>
<navigationSequenceNumber>2</navigationSequenceNumber>
<relatedJoinField>Party</relatedJoinField>
<relatedRecordAggregationObject>PartyIncomeObject</relatedRecordAggregationObject>
<type>Intermediate</type>
</recordAggregationJoinCondition>
<recordAggregationObjectFilter>
<associatedObjectField>IsPrimaryMember</associatedObjectField>
<operator>Equals</operator>
<value>true</value>
<sequenceNumber>1</sequenceNumber>
</recordAggregationObjectFilter>
</recordAggregationObject>
<recordAggregationObject>
<associatedObject>PartyIncome</associatedObject>
<masterLabel>Party Income Object</masterLabel>
<developerName>PartyIncomeObject</developerName>


Record Rollup Definitions Tooling API Objects

<filterLogic>1 AND 2</filterLogic>
<recordAggregationObjectFilter>
<associatedObjectField>IncomeFrequency</associatedObjectField>
<operator>Equals</operator>
<value>Monthly</value>
<sequenceNumber>1</sequenceNumber>
</recordAggregationObjectFilter>
<recordAggregationObjectFilter>
<associatedObjectField>IncomeStatus</associatedObjectField>
<operator>Equals</operator>
<value>Active</value>
<sequenceNumber>2</sequenceNumber>
</recordAggregationObjectFilter>
</recordAggregationObject>
</RecordAggregationDefinition>

The following is an example package.xml that references the previous definition.
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
<types>
<members>*</members>
<name>RecordAggregationDefinition</name>
</types>
<version>60.0</version>
</Package>

Wildcard Support in the Manifest File
This metadata type supports the wildcard character * (asterisk) in the package.xml manifest file. For information about using the
manifest file, see Deploying and Retrieving Metadata with the Zip File.

Record Rollup Definitions Tooling API Objects
Tooling API exposes metadata used in developer tooling that you can access through REST or SOAP. Tooling API’s SOQL capabilities for
many metadata types allow you to retrieve smaller pieces of metadata.
RecordAggregationDefinition
Represents a data aggregation from one object to another object to which it is connected by other objects in the data model. This
object is available in API version 59.0 and later.
RecordAggregationJoinCondition
Represents a condition in a join between two record aggregation objects. This object is available in API version 59.0 and later.
RecordAggregationObject
Represents an object in the record aggegation join sequence. This object is available in API version 59.0 and later.


Represents a filter that is applied to the records of an object in the record aggregation join sequence. This object is available in API
version 60.0 and later.
SEE ALSO:
Developer Guide: Introducing Tooling API

RecordAggregationDefinition
Represents a data aggregation from one object to another object to which it is connected by other objects in the data model. This object
is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported SOAP API Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Supported REST API Methods
DELETE, GET, HEAD, PATCH, POST, Query

Special Access Rules
To access this object, you must have the Record Aggregation permission set license and the Record Aggregation Access permission.

Fields
Field

Details

AggregateFromObject

Type
picklist
Properties
Filter, Group, Restricted picklist, Sort
Description
Required.
API name of the object from which data is aggregated.

AggregateToObject

Type
picklist
Properties
Filter, Group, Restricted picklist, Sort
Description
Required.


API name of the object to which data is aggregated.

AggregationType

Type
picklist
Properties
Filter, Group, Restricted picklist, Sort
Description
Required.
Type of the data aggregation.
Possible value is:
• Record

BatchProcessingDefinitionId Type

reference
Properties
Filter, Group, Nillable, Sort
Description
Data Processing Engine definition that aggregates data from one record to another.
This field is a relationship field.
Relationship Name
BatchProcessingDefinition
Relationship Type
Lookup
Refers To
BatchCalcJobDefinition
Description

Type
textarea
Properties
Filter, Group, Nillable, Sort
Description
The description for this record aggregation definition.

DeveloperName

Type
string
Properties
Filter, Group, Sort
Description
Unqiue name for the RecordAggregationDefinition object.


The unique name of the object in the API. This name can contain only underscores and
alphanumeric characters, and must be unique in your org. It must begin with a letter, not
include spaces, not end with an underscore, and not contain two consecutive underscores.
In managed packages, this field prevents naming conflicts on package installations. With
this field, a developer can change the object’s name in a managed package and the changes
are reflected in a subscriber’s organization. Label is Record Type Name. This field is
automatically generated, but you can supply your own value if you create the record using
the API.

DisplayName

Type
string
Properties
Filter, Group, idLookup, Sort
Description
Required.
The name of the record aggregation definition that's displayed in the record page.

FullName

Type
string
Properties
Create, Group, Nillable
Description
The full name of the associated RecordAggregationDefinition type in Metadata API.
Query this field only if the query result contains no more than one record. Otherwise, an error
is returned. If more than one record exists, use multiple queries to retrieve the records. This
limit protects performance.

Language

Type
picklist
Properties
Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort
Description
The language of the record aggregation definition.
Possible values are:
• da—Danish
• de—German
• en_US—English
• es—Spanish
• es_MX—Spanish (Mexico)
• fi—Finnish
• fr—French


• it—Italian
• ja—Japanese
• ko—Korean
• nl_NL—Dutch
• no—Norwegian
• pt_BR—Portuguese (Brazil)
• ru—Russian
• sv—Swedish
• th—Thai
• zh_CN—Chinese (Simplified)
• zh_TW—Chinese (Traditional)

MasterLabel

Type
string
Properties
Filter, Group, Sort
Description
Label for the record aggregation definition.

Metadata

Type
RecordAggregationDefinition
Properties
Create, Nillable, Update
Description
The RecordAggregationDefinition’s metadata.

Status

Type
picklist
Properties
Defaulted on create, Filter, Group, Restricted picklist, Sort
Description
The status of the record aggregation definition.
Possible values are:
• Active
• Draft
• Inactive
The default value is Draft.


Represents a condition in a join between two record aggregation objects. This object is available in API version 59.0 and later.

Supported SOAP API Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Supported REST API Methods
DELETE, GET, HEAD, PATCH, POST, Query

Special Access Rules
To access this object, you must have the Record Aggregation permission set license and the Record Aggregation Access permission.

Fields
Field

Details

JoinField

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The API name of the field on the record aggregation object's associated object that is used
in the join condition.

NavigationSequenceNumber Type

int
Properties
Create, Filter, Group, Sort, Update
Description
The sequence number corresponding to this join in the join sequence from the object to
which the data is aggregated to the object that contains the data being aggregated.
RecordAggregationObjectId Type

reference
Properties
Create, Filter, Group, Sort
Description
The record aggregation object with which this record aggregation join condition is associated.
This field is a relationship field.
Relationship Name
RecordAggregationObject


Relationship Type
Lookup
Refers To
RecordAggregationObject

RelatedJoinField

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The API name of the field on the related record aggregation object's associated object that
is used in the join condition.

RelatedRecordAggrObjectId Type

reference
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
The second record aggregation object in the join condition.
This field is a relationship field.
Relationship Name
RelatedRecordAggrObject
Relationship Type
Lookup
Refers To
RecordAggregationObject
Type

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The type of this record aggregation join in the join path from the object to which the data
is aggregated to the object that contains the data being aggregated.
Possible values are:
• AggregateFrom
• AggregateTo
• Intermediate


Represents an object in the record aggegation join sequence. This object is available in API version 59.0 and later.
Important: Where possible, we changed noninclusive terms to align with our company value of Equality. We maintained certain
terms to avoid any effect on customer implementations.

Supported SOAP API Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Supported REST API Methods
DELETE, GET, HEAD, PATCH, POST, Query

Special Access Rules
To access this object, you must have the Record Aggregation permission set license and the Record Aggregation Access permission.

Fields
Field

Details

AssociatedObject

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
The API name of the object associated with this record aggregation object.

DeveloperName

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
The developer name of the record aggregation object. Can contain only underscores and
alphanumeric characters and must be unique in your org. It must begin with a letter, not
include spaces, not end with an underscore, and not contain two consecutive underscores.

FilterLogic

Type
string
Properties
Create, Filter, Group, Nillable, Sort, Update
Description
Logical sequence in which the record aggregation object filters associated with this record
aggregation object are applied to the associated object's records. If you define two or more


record aggregation object filters, but don’t specify the sequence in which to apply the filters,
the filters are applied by using a logical AND expression.
Available in API version 60.0 and later.

Language

Type
picklist
Properties
Create, Defaulted on create, Filter, Group, Nillable, Restricted picklist, Sort, Update
Description
The language of the record aggregation object.
Possible values are:
• da—Danish
• de—German
• en_US—English
• es—Spanish
• es_MX—Spanish (Mexico)
• fi—Finnish
• fr—French
• it—Italian
• ja—Japanese
• ko—Korean
• nl_NL—Dutch
• no—Norwegian
• pt_BR—Portuguese (Brazil)
• ru—Russian
• sv—Swedish
• th—Thai
• zh_CN—Chinese (Simplified)
• zh_TW—Chinese (Traditional)

MasterLabel

Type
string
Properties
Create, Filter, Group, Sort, Update
Description
Label for the record aggregation object.

RecordAggregationDefinitionId Type

reference


Properties
Create, Filter, Group, Sort
Description
The record aggregation definition with which this record aggregation object is associated.
This field is a relationship field.
Relationship Name
RecordAggregationDefinition
Relationship Type
Lookup
Refers To
RecordAggregationDefinition

RecordAggregationObjectFilter
Represents a filter that is applied to the records of an object in the record aggregation join sequence. This object is available in API version
60.0 and later.

Supported SOAP API Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Supported REST API Methods
DELETE, GET, HEAD, PATCH, POST, Query

Special Access Rules
To access this object, you must have the Record Aggregation permission set license and the Record Aggregation Access permission.

Fields
Field

Details

AssociatedObjectField

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
API name of the associated object's field whose value is used to filter the object's records.
The associated object is specified in the record aggregation object.


Operator

Type
picklist
Properties
Create, Filter, Group, Restricted picklist, Sort, Update
Description
Operator used in the filter expression.
Possible values are:
• Contains
• Equals
• GreaterThan
• GreaterThanOrEquals
• In
• LessThan
• LessThanOrEquals
• NotEquals
• NotIn

RecordAggregationObjectId Type

reference
Properties
Create, Filter, Group, Sort
Description
The record aggregation object with which this record aggregation object filter is associated.
This field is a relationship field.
Relationship Name
RecordAggregationObject
Relationship Type
Lookup
Refers To
RecordAggregationObject
SequenceNumber

Type
int
Properties
Create, Filter, Group, Sort, Update
Description
Sequence number of this record aggregation object filter.

Value

Type
string


Properties
Create, Filter, Group, Sort, Update
Description
Reference value with which the designated field's values are compared when the filter is
applied on the associated object's records.


# Chapter 12: NonProfit Cloud Associated Objects

In this chapter ...
•

StandardObjectNameShare

•

StandardObjectNameOwnerSharingRule

•

StandardObjectNameHistory

•

StandardObjectNameChangeEvent

•

StandardObjectNameFeed

This section provides a list of objects associated to Nonprofit Cloud standard objects with their standard
fields.
Some fields may not be listed for some objects. To see the system fields for each object, see System
Fields in the Object Reference for Salesforce and Lightning Platform.
To verify the complete list of fields for an object, use a describe call from the API or inspect with an
appropriate tool. For example, inspect the WSDL or use a schema viewer.


StandardObjectNameShare is the model for all share objects associated with standard objects. These objects represent a sharing

entry on the standard object.
The object name is variable and uses StandardObjectNameShare syntax. For example, AccountBrandShare is a sharing entry on
an account brand. We list the available associated share objects at the end of this topic. For specific version information, see the standard
object documentation.

Supported Calls
create(), delete(), describeSObjects(), query(), retrieve(), update(), upsert()

Special Access Rules
For specific special access rules, if any, see the documentation for the standard object. For example, for AccountBrandShare, see the
special access rules for AccountBrand.

Fields
Field Name

Type

Properties

Description

AccessLevel

picklist

Create, Filter, Group,
Restricted picklist, Sort,
Update

The level of access allowed. Values are All (owner),
Edit (read/write), or Read (read only).

ParentId

reference

Create, Filter, Group, Sort ID of the parent record.

RowCause

picklist

Create, Filter, Group,
Nillable, Restricted
picklist, Sort

UserOrGroupId

reference

Create, Filter, Group, Sort ID of the user or group that has been given access to the
object.

Reason that the sharing entry exists.

StandardObjectNameOwnerSharingRule
StandardObjectNameOwnerSharingRule is the model for all owner sharing rule objects associated with standard objects. These

objects represent a rule for sharing a standard object with users other than the owner.
The object name is variable and uses StandardObjectNameOwnerSharingRule syntax. For example,
ChannelProgramOwnerSharingRule is a rule for sharing a channel program with users other than the channel program owner. We list
the available associated owner sharing rule objects at the end of this topic. For specific version information, see the standard object
documentation.
To enable access to this object, contact Salesforce customer support. But we recommend that you use Metadata API to programmatically
update owner sharing rules instead because it triggers automatic sharing rule recalculation. The SharingRules Metadata API type is
enabled for all orgs.


Supported Calls
create(), delete(), describeSObjects(), getDeleted(), getUpdated(), query(), retrieve(), update(),
upsert()

Special Access Rules
For specific special access rules, if any, see the documentation for the standard object. For example, for ChannelProgramOwnerSharingRule,
see the special access rules for ChannelProgram.

Fields
Field Name

Type

Properties

Description

AccessLevel

picklist

Create, Filter, Group,
Restricted picklist, Sort,
Update

Determines the level of access users have to records. Values
are Read (read only) or Edit (read/write).

Description

textarea

Create, Filter, Nillable,
Sort, Update

Description of the sharing rule. Maximum length is 1000
characters.

DeveloperName

string

Create, Filter, Group,
Nillable, Sort, Update

The unique name of the object in the API. This name can
contain only underscores and alphanumeric characters
and must be unique in your org. It must begin with a letter,
not include spaces, not end with an underscore, and not
contain two consecutive underscores. In managed
packages, this field prevents naming conflicts on package
installations. With this field, a developer can change the
object's name in a managed package, and the changes
are reflected in a subscriber's organization.
When creating large sets of data, always specify a unique
DeveloperName for each record. If no
DeveloperName is specified, performance can slow
while Salesforce generates one for each record.

GroupId

reference

Create, Filter, Group, Sort ID of the source group. Records that are owned by users
in the source group trigger the rule to give access.

Name

string

Create, Filter, Group,
idLookup, Sort, Update

UserOrGroupId

reference

Create, Filter, Group, Sort ID of the user or group that you are granting access to.

Label of the sharing rule as it appears in the UI. Maximum
length is 80 characters.

StandardObjectNameHistory
StandardObjectNameHistory is the model for all history objects associated with standard objects. These objects represent the

history of changes to the values in the fields of a standard object.


The object name is variable and uses StandardObjectNameHistory syntax. For example, AccountHistory represents the history of
changes to the values of an account record's fields. We list the available associated history objects at the end of this topic. For specific
version information, see the documentation for the standard object.

Supported Calls
describeSObjects(), getDeleted(), getUpdated(), query(), retrieve()

Special Access Rules
For specific special access rules, if any, see the documentation for the standard object. For example, for AccountHistory, see the special
access rules for Account.

Fields
Field Name

Type

StandardObjectNameId reference

Properties

Description

Filter, Group, Sort

ID of the standard object.

DataType

picklist

Filter, Group, Nillable,
Restricted picklist, Sort

Data type of the field that was changed.

Field

picklist

Filter, Group, Restricted
picklist, Sort

Name of the field that was changed.

NewValue

anyType

Nillable, Sort

New value of the field that was changed.

OldValue

anyType

Nillable, Sort

Old value of the field that was changed.

StandardObjectNameChangeEvent
A ChangeEvent object is available for each object that supports Change Data Capture. You can subscribe to a stream of change events
using Change Data Capture to receive data tied to record changes in Salesforce. Changes include record creation, updates to an existing
record, deletion of a record, and undeletion of a record. A change event isn’t a Salesforce object—it doesn’t support CRUD operations
or queries. It’s included in the object reference so you can discover which Salesforce objects support change events.

Supported Calls
describeSObjects()

Special Access Rules
• Not all objects may be available in your org. Some objects require specific feature settings and permissions to be enabled.
• For more special access rules, if any, see the documentation for the standard object. For example, for AccountChangeEvent, see the
special access rules for Account.


Change Event Name
Change events are available for all custom objects and a subset of standard objects. The name of a change event is based on the name
of the corresponding object for which it captures the changes.
Standard Object Change Event Name
<Standard_Object_Name>ChangeEvent

Example: AccountChangeEvent
Custom Object Change Event Name
<Custom_Object_Name>__ChangeEvent

Example: MyCustomObject__ChangeEvent

Change Event Fields
The fields that a change event can include correspond to the fields on the associated parent Salesforce object, with a few exceptions.
For example, AccountChangeEvent fields correspond to the fields on Account.
The fields that a change event doesn’t include are:
• The IsDeleted system field.
• The SystemModStamp system field.
• Any field whose value isn’t on the record and is derived from another record or from a formula, except roll-up summary fields, which
are included. Examples are formula fields. Examples of fields with derived values include LastActivityDate and PhotoUrl.
Each change event also contains header fields. The header fields are included inside the ChangeEventHeader field. They contain
information about the event, such as whether the change was an update or delete and the name of the object, like Account.
In addition to the event payload, the event schema ID is included in the schema field. Also included is the event-specific field,
replayId, which is used for retrieving past events.

Event Message Example
The following example is an event message in JSON format for a new account record creation.
{
"schema": "IeRuaY6cbI_HsV8Rv1Mc5g",
"payload": {
"ChangeEventHeader": {
"entityName": "Account",
"recordIds": [
"<record_ID>"
],
"changeType": "CREATE",
"changeOrigin": "com/salesforce/api/soap/51.0;client=SfdcInternalAPI/",
"transactionKey": "0002343d-9d90-e395-ed20-cf416ba652ad",
"sequenceNumber": 1,
"commitTimestamp": 1612912679000,
"commitNumber": 10716283339728,
"commitUser": "<User_ID>"
},
"Name": "Acme",


"Description": "Everyone is talking about the cloud. But what does it mean?",
"OwnerId": "<Owner_ID>",
"CreatedDate": "2021-02-09T23:17:59Z",
"CreatedById": "<User_ID>",
"LastModifiedDate": "2021-02-09T23:17:59Z",
"LastModifiedById": "<User_ID>"
},
"event": {
"replayId": 6
}
}

API Version and Schema
When you subscribe to change events, the subscription uses the latest API version and the event messages received reflect the latest
field definitions. For more information, see API Version and Event Schema in the Change Data Capture Developer Guide.

Usage
For more information about Change Data Capture, see Change Data Capture Developer Guide.

Objects That Support Change Events
These objects have associated ChangeEvent objects.
• GiftCommitment
• GiftCommitmentSchedule
• GiftSoftCredit
• GiftTransaction
• GiftRefund
• GiftTransactionDesignation
• JobPositionAssignment
• JobPositionQualification
• JobPositionShift
• OutreachSourceCode
• PersonLocationAvailability
• PositionBenefit
• PositionQualification
• VolunteerInitiative

StandardObjectNameFeed
StandardObjectNameFeed is the model for all feed objects associated with standard objects. These objects represent the posts

and feed-tracked changes of a standard object.


The object name is variable and uses StandardObjectNameFeed syntax. For example, AccountFeed represents the posts and
feed-tracked changes on an account record. We list the available associated feed objects at the end of this topic. For specific version
information, see the documentation for the standard object.

Supported Calls
delete(), describeSObjects(), getDeleted(), getUpdated(), query(), retrieve()

Special Access Rules
In the internal org, users can delete all feed items they created. This rule varies in communities where threaded discussions and
delete-blocking are enabled. Community members can delete all feed items they created, provided the feed items don't have content
nested under them—like a comment, answer, or reply. Where the feed item has nested content, only feed moderators and users with
the Modify All Data permission can delete threads.
To delete feed items they didn't create, users must have one of these permissions:
• Modify All Data
• Modify All Records on the parent object, like Account for AccountFeed
• Moderate Chatter
Note: Users with the Moderate Chatter permission can delete only the feed items and comments they can see.
Only users with this permission can delete items in unlisted groups.
For more special access rules, if any, see the documentation for the standard object. For example, for AccountFeed, see the special access
rules for Account.

Fields
Field

Type

Properties

Description

BestCommentId

reference

Filter, Group, Nillable,
Sort

The ID of the comment marked as best answer on a question post.

Body

textarea

Nillable, Sort

The body of the post. Required when Type is TextPost.
Optional when Type is ContentPost or LinkPost.

CommentCount

int

Filter, Group, Sort

The number of comments associated with this feed item.

ConnectionId

reference

Filter, Group, Nillable,
Sort

When a PartnerNetworkConnection modifies a record that is
tracked, the CreatedBy field contains the ID of the system
administrator. The ConnectionId contains the ID of the
PartnerNetworkConnection. Available if Salesforce to Salesforce is
enabled for your organization.

InsertedById

reference

Group, Nillable, Sort

ID of the user who added this item to the feed. For example, if an
application migrates posts and comments from another application
into a feed, the InsertedBy value is set to the ID of the
context user.


Type

Properties

Description

isRichText

boolean

Defaulted on create,
Filter, Group, Sort

Indicates whether the feed item Body contains rich text. If you
post a rich text feed comment using SOAP API, set IsRichText
to true and escape HTML entities from the body. Otherwise, the
post is rendered as plain text.

LikeCount

int

Filter, Group, Sort

The number of likes associated with this feed item.

LinkUrl

url

Nillable, Sort

The URL of a LinkPost.

NetworkScope

picklist

Group, Nillable,
Restricted picklist, Sort

Specifies whether this feed item is available in the default
Experience Cloud site, a specific Experience Cloud site, or all sites.
This field is available in API version 26.0 and later, if digital
experiences is enabled for your org.

ParentId

reference

Filter, Group, Sort

ID of the record that is tracked in the feed. The detail page for the
record displays the feed.

Group, Nillable, Sort

ID of the ContentVersion record associated with a ContentPost.
This field is null for all posts except ContentPost.

RelatedRecordId reference

Title

string

Group, Nillable, Sort

The title of the feed item. When the Type is LinkPost, the
LinkUrl is the URL and this field is the link name.

Type

picklist

Filter, Group, Nillable,
Restricted picklist, Sort

The type of feed item.

Visibility

picklist

Filter, Group, Nillable,
Restricted picklist, Sort

Specifies whether this feed item is available to all users or internal
users only. This field is available if Salesforce Communities are
enabled for your organization.

isRichText: Rich text supports the following HTML tags:

• <p>
Tip: Though the <br> tag isn't supported, you can use <p>&nbsp;</p> to create lines.
• <a>
• <b>
• <code>
• <i>
• <u>
• <s>
• <ul>
• <ol>
• <li>
• <img>
The <img> tag is accessible only through the API and must reference files in Salesforce similar to this example: <img
src="sfdc://069B0000000omjh"></img>


NetworkScope can have the following values:

• NetworkId—The ID of the Experience Cloud site in which the FeedItem is available. If left empty, the feed item is only available
in the default Experience Cloud site.
• AllNetworks—The feed item is available in all Experience Cloud sites.
Note the following exceptions for NetworkScope:
• Only feed items with a Group or User parent can set a NetworkId or a null value for NetworkScope.
• For feed items with a record parent, users can set NetworkScope only to AllNetworks.
• You can’t filter a feed item on the NetworkScope field.
The Type field can have the following values:
• ActivityEvent—indirectly generated event when a user or the API adds a Task associated with a feed-enabled parent record
(excluding email tasks on cases). Also occurs when a user or the API adds or updates a Task or Event associated with a case record
(excluding email and call logging).
For a recurring Task with CaseFeed disabled, one event is generated for the series only. For a recurring Task with CaseFeed enabled,
events are generated for the series and each occurrence.
• AdvancedTextPost—created when a user posts a group announcement and, in Lightning Experience as of API version 39.0
and later, when a user shares a post.
• AnnouncementPost—Not used.
• ApprovalPost—generated when a user submits an approval.
• BasicTemplateFeedItem—Not used.
• CanvasPost—a post made by a canvas app posted on a feed.
• CollaborationGroupCreated—generated when a user creates a public group.
• CollaborationGroupUnarchived—Not used.
• ContentPost—a post with an attached file.
• CreatedRecordEvent—generated when a user creates a record from the publisher.
• DashboardComponentAlert—generated when a dashboard metric or gauge exceeds a user-defined threshold.
• DashboardComponentSnapshot—created when a user posts a dashboard snapshot on a feed.
• LinkPost—a post with an attached URL.
• PollPost—a poll posted on a feed.
• ProfileSkillPost—generated when a skill is added to a user’s Chatter profile.
• QuestionPost—generated when a user posts a question.
• ReplyPost—generated when Chatter Answers posts a reply.
• RypplePost—generated when a user creates a Thanks badge in WDC.
• TextPost—a direct text entry on a feed.
• TrackedChange—a change or group of changes to a tracked field.
• UserStatus—automatically generated when a user adds a post. Deprecated.
The following values appear in the Type picklist for all feed objects but apply only to CaseFeed:
• CaseCommentPost—generated event when a user adds a case comment for a case object
• EmailMessageEvent—generated event when an email related to a case object is sent or received
• CallLogPost—generated event when a user logs a call for a case through the user interface. CTI calls also generate this event.
• ChangeStatusPost—generated event when a user changes the status of a case


• AttachArticleEvent—generated event when a user attaches an article to a case
Note: If you set Type to ContentPost, also specify ContentData and ContentFileName.
Visibility can have the following values:

• AllUsers—The feed item is available to all users who have permission to see the feed item.
• InternalUsers—The feed item is available to internal users only.
Note the following exceptions for Visibility:
• For record posts, Visibility is set to InternalUsers for all internal users by default.
• External users can set Visibility only to AllUsers.
• On user and group posts, only internal users can set Visibility to InternalUsers.

Usage
A feed for an object is automatically created when a user enables feed tracking for the object. Use feeds to track changes to records. For
example, AccountFeed tracks changes to an account record. Use feed objects to retrieve the content of feed fields, such as type of feed
or feed ID.
Note the following SOQL restrictions. No SOQL limit if logged-in user has View All Data permission. If not, specify a LIMIT clause of
1,000 records or fewer. SOQL ORDER BY on fields using relationships is not available. Use ORDER BY on fields on the root object
in the SOQL query.


