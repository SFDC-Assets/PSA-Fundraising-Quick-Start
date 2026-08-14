# FQS Gift Follow-Up Redesign — Execution Plan

**Status:** DRAFT — awaiting approval before implementation
**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst` (Nonprofit Cloud — Fundraising)
**Supersedes:** `.planning/fqs-gift-acknowledgement-plan.md` (v2 — its Entry/Mid/Major matrix moves to stewardship; acknowledgement collapses to a universal rule)

---

## 1. Concept split (source of truth)

Three previously-conflated concepts, now separated:

| Concept | Trigger | Rule | Automation |
|---|---|---|---|
| **Acknowledgement** | Every gift not handled by an external donation platform | Universal: email if `HasOptedOutOfEmail=FALSE` AND `Email` present; else Task | **Automated** (`FQS_Gift_Acknowledgement` — kept as name, but scope shrinks) |
| **Stewardship** | Post-acknowledgement engagement | Tier + giving-history driven (this is where the old Entry/Mid/Major/Lifetime matrix belongs) | **Automated** (new flow, new fields, new templates) |
| **Year-end tax receipt** | Annual, per donor | Manual; org-specific compliance | **Out of scope**; add a manual date field only |

**Rename requirement.** Per user direction: drop "Acknowledgement" from the *flow* file and *template* files. Two-flow clean separation. Proposed names below.

---

## 2. Naming (proposed — confirm)

| Old | New | Notes |
|---|---|---|
| `FQS_Gift_Acknowledgement.flow-meta.xml` | `FQS_Gift_Follow_Up.flow-meta.xml` | Universal acknowledgement branch |
| _(new)_ | `FQS_Stewardship_Response.flow-meta.xml` | Post-ack engagement, tier-routed |
| `FQS_Gift_Acknowledgement` (email tpl) | `FQS_Gift_Follow_Up` (email tpl) | Full-deduction thank-you |
| `FQS_Gift_Acknowledgement_Partial` (email tpl) | `FQS_Gift_Follow_Up_Partial` (email tpl) | Partial-deduction thank-you |
| _(new)_ | `FQS_Stewardship_Response_Standard` (email tpl) | Placeholder stewardship copy |

**Coordinated rename risk.** Templates are referenced by `DeveloperName` inside the flow. Rename order: create new templates first (copy content), update flow to reference new names, deploy, delete old templates. `FQS_Gift_Acknowledgements` queue name is fine to keep — it's a Task queue, not a template.

---

## 3. Field additions

### GiftTransaction (`force-app/main/default/objects/GiftTransaction/fields/`)

| API name | Type | Values / notes |
|---|---|---|
| `FQS_Stewardship_Status__c` | Picklist | `To Be Sent`, `Sent`, `Don't Send` (mirrors `AcknowledgementStatus`) |
| `FQS_Stewardship_Date__c` | Date | Set by stewardship flow when Status flips to `Sent` |
| `FQS_Tax_Receipt_Date__c` | Date | Manual entry (out-of-scope for automation) |

### Standard fields we're REUSING (no add needed)

- `GiftTransaction.AcknowledgementStatus` — already picklist `To Be Sent / Sent / Don't Send`
- `GiftTransaction.AcknowledgementDate` — already exists (v2 plan was wrong)
- `GiftTransaction.TaxReceiptStatus` — already exists; no automation, but visible on layouts

### Permset updates

- Add all three new fields to `FQS_Custom_Fields` permset (or equivalent).
- Add new fields to `FQS_GiftTransaction_Record_Page` flexipage.

---

## 4. Acknowledgement flow (`FQS_Gift_Follow_Up`)

### 4.1 Scope

- **Runs daily.** Same schedule as today (`06:00:00.000Z`).
- **Query filter:**
  - `Status = 'Paid'`
  - `TransactionDate <= TODAY - 3`
  - `AcknowledgementStatus` IS NULL OR `= 'To Be Sent'`
  - **NEW:** gift-type filter — see 4.2
- **Universal rule** (replaces Entry/Mid/Major matrix):
  - IF `Contact.HasOptedOutOfEmail = FALSE` AND `Contact.Email != NULL` → Email path
  - ELSE → Task path (Queue = `FQS_Gift_Acknowledgements`)
- **CMDT `FQS_Auto_Acknowledgement__c` on `FQS_Donor_Grouping__mdt` is NO LONGER READ by this flow.** It moves entirely to the stewardship flow.

### 4.2 External-tool exclusion — no formula field needed

**User direction:** external-tool integrations that send their own acknowledgement should write back `GiftTransaction.AcknowledgementStatus = 'Sent'` on the record they create. The existing flow filter (`AcknowledgementStatus IS NULL OR = 'To Be Sent'`) then naturally excludes those gifts.

If an integration is NOT writing back the status, that's an integration-layer gap to fix there, not a workaround to add here.

**Additional filter** — exclude fee/administrative rows so donors don't get thank-you emails for processing fees:

- `FQS_Gift_Transaction_Category__c != 'Fee/Payment'`

### 4.3 Files touched by acknowledgement flow work

| File | Action |
|---|---|
| `force-app/main/default/flows/FQS_Gift_Acknowledgement.flow-meta.xml` | **Delete** (post new-flow deploy) |
| `force-app/main/default/flows/FQS_Gift_Follow_Up.flow-meta.xml` | **Create** (simplified, universal rule, gift-type filter) |
| `force-app/main/default/email/unfiled$public/FQS_Gift_Acknowledgement.email` | **Rename** → `FQS_Gift_Follow_Up.email` |
| `force-app/main/default/email/unfiled$public/FQS_Gift_Acknowledgement.email-meta.xml` | **Rename** + update `<name>` and `<uiType>` inside |
| `force-app/main/default/email/unfiled$public/FQS_Gift_Acknowledgement_Partial.email(.email-meta.xml)` | **Rename** → `FQS_Gift_Follow_Up_Partial.*` |

---

## 5. Stewardship flow (`FQS_Stewardship_Response`)

### 5.1 Scope

- **Runs daily.** Delayed offset from ack flow (e.g., `07:00:00.000Z`).
- **Query filter:**
  - `Status = 'Paid'`
  - `AcknowledgementStatus = 'Sent'` (only steward gifts that were successfully acknowledged first)
  - `FQS_Stewardship_Status__c` IS NULL OR `= 'To Be Sent'`
  - `TransactionDate <= TODAY - 14` (2-week gap between ack and stewardship — tunable)
- **Routes by donor tier + lifetime status** (this is where the old Entry/Mid/Major × Include-All/Exclude-Lifetime/Exclude-All matrix lives now).
- **CMDT `FQS_Donor_Grouping__mdt.FQS_Auto_Acknowledgement__c`** — repurposed. Rename inside the CMDT to `FQS_Auto_Stewardship__c` (or keep the field name, update meaning in docs). Values `Include All / Exclude Lifetime / Exclude All` semantically re-map to "who gets automated stewardship" instead of "who gets automated acknowledgement."

### 5.2 Routing table (moved from old ack flow, now stewardship semantics)

| Gift Tier | CMDT Setting | Lifetime Major? | Email opt-out? | Route |
|---|---|---|---|---|
| Major | Exclude All | — | — | Task (personal touch — no auto-email) |
| Major | Exclude Lifetime | Yes | — | Task |
| Major | Exclude Lifetime | No | No | Email (stewardship template) |
| Major | Include All | — | No | Email |
| Mid | Exclude All | — | — | Task |
| Mid | Exclude Lifetime | Yes | — | Task |
| Mid | Exclude Lifetime | No | No | Email |
| Mid | Include All | — | No | Email |
| Entry | Exclude All | — | — | Task |
| Entry | Exclude Lifetime | Yes | — | Task |
| Entry | Exclude Lifetime | No | No | Email |
| Entry | Include All | — | No | Email |
| Any | Any | — | Yes | Task |
| Sub-Entry | Follow Entry row | — | — | Per Entry row |

### 5.3 On success, set

- `FQS_Stewardship_Status__c = 'Sent'`
- `FQS_Stewardship_Date__c = TODAY`

### 5.4 Files touched by stewardship flow work

| File | Action |
|---|---|
| `force-app/main/default/flows/FQS_Stewardship_Response.flow-meta.xml` | **New** |
| `force-app/main/default/email/unfiled$public/FQS_Stewardship_Response_Standard.email(.email-meta.xml)` | **New** (placeholder copy — marketing to replace) |
| `force-app/main/default/objects/GiftTransaction/fields/FQS_Stewardship_Status__c.field-meta.xml` | **New** |
| `force-app/main/default/objects/GiftTransaction/fields/FQS_Stewardship_Date__c.field-meta.xml` | **New** |
| `force-app/main/default/objects/GiftTransaction/fields/FQS_Tax_Receipt_Date__c.field-meta.xml` | **New** |
| `force-app/main/default/customMetadata/FQS_Donor_Grouping.*.md-meta.xml` | Update docstring — same field, new semantics; no data migration required |
| `force-app/main/default/queues/FQS_Stewardship_Response.queue-meta.xml` | **New** — Task queue for the manual-touch path |
| `force-app/main/default/flexipages/FQS_GiftTransaction_Record_Page.flexipage-meta.xml` | Add all three new fields |

---

## 6. Deploy order (safe)

1. **Fields:** `FQS_Stewardship_Status__c`, `FQS_Stewardship_Date__c`, `FQS_Tax_Receipt_Date__c` → deploy first (no flow depends on them yet).
2. **Templates:** new `FQS_Gift_Follow_Up`, `FQS_Gift_Follow_Up_Partial`, `FQS_Stewardship_Response_Standard` — deploy alongside existing acknowledgement templates (both live during transition).
3. **Queue:** `FQS_Stewardship_Response` queue.
4. **New flows:** `FQS_Gift_Follow_Up`, `FQS_Stewardship_Response` — deployed inactive first.
5. **Verify** with test data on FundFirst (see §7).
6. **Activate** new flows.
7. **Deactivate + delete** old `FQS_Gift_Acknowledgement` flow and old templates.
8. **Layout / flexipage update** — add new fields.
9. **Permset update** — grant field access.

---

## 7. Test plan

### Acknowledgement flow (`FQS_Gift_Follow_Up`)

| # | Setup | Expected |
|---|---|---|
| A1 | GT: Paid, 4 days old, no PaymentInstrument, opt-out=FALSE, Email present | Email sent, `AcknowledgementStatus='Sent'`, `AcknowledgementDate=TODAY` |
| A2 | GT: Paid, 4 days old, opt-out=TRUE | Task created |
| A3 | GT: Paid, 4 days old, Email blank | Task created |
| A4 | GT: Paid, 4 days old, `AcknowledgementStatus = 'Sent'` (written by external integration) | Skipped (filter excludes) |
| A5 | GT: Paid, 4 days old, Category=`Fee/Payment` | Skipped |
| A6 | GT: Paid, TODAY | Skipped (< 3-day threshold) |
| A7 | GT: Fully Refunded | Skipped |
| A8 | GT: AcknowledgementStatus='Sent' | Skipped |

### Stewardship flow (`FQS_Stewardship_Response`)

| # | Setup | Expected |
|---|---|---|
| S1 | GT: Ack=Sent 15+ days ago, Entry donor, opt-out=FALSE | Email sent, `FQS_Stewardship_Status__c='Sent'`, `FQS_Stewardship_Date__c=TODAY` |
| S2 | GT: Ack=Sent 15+ days ago, Mid donor, IS lifetime major, CMDT=`Exclude Lifetime` | Task |
| S3 | GT: Ack=Sent 15+ days ago, Major donor, CMDT=`Exclude All` | Task |
| S4 | GT: Ack=Sent 15+ days ago, opt-out=TRUE | Task |
| S5 | GT: Ack=`NULL` | Skipped (ack must be Sent first) |
| S6 | GT: Ack=Sent 5 days ago (< 14) | Skipped |
| S7 | GT: Stewardship already Sent | Skipped |

---

## 8. Follow-ups (post-approval, not blockers)

- **External-tool contract.** Document the requirement that any donation-form integration MUST set `GiftTransaction.AcknowledgementStatus = 'Sent'` on the records it creates when it sends its own thank-you. Without that write-back, the auto-ack flow will duplicate the acknowledgement. This is an integration-guide item, not a metadata change.
- **Stewardship template library.** Multiple templates per tier (Entry welcome vs Major relationship-deepener) instead of one generic template.
- **Stewardship cadence.** Currently one-shot per gift; consider N-day sequences for high-value gifts.
- **Year-end tax receipt.** Explicitly out of scope; document standard NPC batch-receipt capabilities in a separate doc.
- **CMDT rename.** `FQS_Auto_Acknowledgement__c` → `FQS_Auto_Stewardship__c` is a picklist field rename with data preservation. Defer unless naming clarity becomes a maintenance issue.
- **Donor Grouping Configurator update.** Its picker UX still says "Auto Acknowledgement"; needs a label update after CMDT rename decision.

---

## 9. Tracker updates required

`.planning/fqs-release-readiness.md`:

- Line 367 area — supersede the "not-implemented" ack row. Replace with two rows (Follow-Up + Stewardship), both `design-approved / not-implemented` until deploy.
- Add Findings entry noting the concept split and the shipped-but-mis-scoped state of the current flow.
