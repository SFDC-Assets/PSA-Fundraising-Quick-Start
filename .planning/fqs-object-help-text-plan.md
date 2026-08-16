# FQS — Object Help Text & Description Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst` sandbox (default)
**Goal:** Author object-level help text and descriptions for every fundraising object an FQS admin lands on, so that a business admin new to FundFirst can orient themselves on any record page or Object Manager entry without having to cross-reference a doc.

Field-level help text on `GiftEntry` is folded into this plan (§GiftEntry field-level authoring) as of 2026-08-05. The prior standalone plan (`fqs-gift-entry-help-text-plan.md`) moved to `archive/` and its 49-field drafts are the working source for that section.

**Companion inventory:** `.planning/fqs-off-flexipage-inventory.md` lists off-flexipage fields per object, separating audit/platform noise from real gaps (accelerator-owned `FQS_*` fields not surfaced on their own flexipages). Read that before scoping a per-object authoring pass — it tells you which fields the admin will actually see, plus the 16 accelerator-owned custom fields to either surface or justify hiding.

---

## Object scope

Objects are grouped by how much orientation copy they need. The group names shape the help-text contract, not the object's importance — every in-scope object gets copy, just sized to what an admin actually needs to know about it.

### Key Objects — full orientation

Copy explains what the object is, why it matters, what's underneath it, and how it links to its neighbors.

- Account
- Gift Commitment
- Gift Commitment Schedule
- Gift Transaction
- Gift Transaction Designation
- Gift Designation
- Campaign
- Opportunity

### Supporting Objects — purpose-focused

Copy explains what the object does, when you'd use it, and when you wouldn't.

- Action Plan
- Gift Default Designation
- Gift Default Soft Credit
- Gift Refund
- Gift Soft Credit
- Gift Tribute
- Outreach Source Code
- Campaign Member

### Background Objects — hands-off framing

Copy explains what populates/manages the object and points readers away from hand-editing.

- Gift Entry
- Gift Batch
- Gift Commitment Change Attribution Log
- FundraisingConfig
- Donor Gift Summary
- Outreach Summary

---

## Admin Tooling & Templates — separate scope

Distinct from the object-help-text groups above. These are admin-facing artifacts (metadata, tools, templates), not record objects. Each needs its own orientation copy — where it lives in Setup, what it's for in the FQS context, how to adopt or extend what ships with the accelerator — but the copy contract is different from record-page help text.

- Reports
- Dashboards
- Action Plan Templates
- Email Templates
- CSV Import

**Copy contract:** each item gets a short "what ships with FQS" summary plus a "how to adopt / extend" pointer. Delivery surface is likely `docs/*.md` (or README sections) rather than `description`/`inlineHelpText` on a record, since none of these are field- or record-scoped. The `docs/fqs-reports-dashboards-*` and README §III/§VI already cover Reports + Dashboards partially — a future pass consolidates and fills the gaps for Action Plan Templates, Email Templates, and CSV Import.

---

## Out of scope for this version

These objects exist in FundFirst / the platform and will surface in Object Manager, but are deliberately excluded from this help-text pass. A future pass can pick them up when the corresponding capability lands in FQS.

| Object | Group it would join | Why deferred |
|---|---|---|
| Payment Instrument | Supporting | Tokenized recurring / card-updater workflows aren't in FQS starter scope yet |
| Opportunity Contact Role | Supporting | Opportunity path is present but OCR authoring/reporting isn't wired into the FQS launcher / reports |
| Opportunity Team Member | Supporting | Team-selling patterns aren't part of the FQS starter fundraising model |
| Focus Segment | Supporting | Segmentation is out of scope until an audience/segmentation phase lands |
| Account Contact Relationship | Supporting | Relationship mapping isn't wired into FQS starter (SMQS territory) |
| Contact Contact Relationship | Supporting | Same as ACR — deferred to SMQS-parity work |
| Document Generation Query Result | Background | Doc-gen isn't in FQS starter scope |

These are intentional omissions, not misses — surface them in the release-readiness tracker as "deferred, not missing" so a future admin auditing coverage doesn't reopen the debate.

---

## Help-text contract per group

| Group | inline help text / record-page prose | admin description |
|---|---|---|
| **Key** | 1–3 sentences: what it is, what depends on it. Names the immediate child objects when relevant. | Longer: same intro + how the object fits the FQS gift-processing chain (GC → GCS → GT → GTD → GD) and which automations touch it |
| **Supporting** | 1–2 sentences: what it's for, when it applies | Adds "you would use this when… / you would not use this when…" to help admins decide whether to configure it |
| **Background** | 1 short sentence: what fills it, whether to hand-edit | Adds pointer to the automation / flow / rollup that owns writes, so admins don't chase a mis-filed defect against the wrong system |

---

## Authoring order (proposed)

1. **Background objects first** — shortest copy, clears the deck, and forces us to name the automations before we describe the Key objects that trigger them.
2. **Key objects next** — the reference orientation. Longest copy, most cross-references.
3. **Supporting objects last** — inherits vocabulary from both prior passes, so "when to use / when not" copy can name the Key/Background objects without re-defining them.

Order is a working preference, not a gate. If a specific record page is blocked on help copy for one object, jump ahead.

---

## Recovered custom-field gaps (from off-flexipage inventory)

The off-flexipage pass surfaced 16 accelerator-owned `FQS_*` fields NOT on their own object's flexipage. Reconcile these BEFORE authoring help text on the affected object — for each, either add to the flexipage or explicitly document why hidden.

| Object | Field(s) |
|---|---|
| Account | `FQS_Matching_Gift_Program__c`, `FQS_Is_Match_Intermediary__c`, `FQS_Match_Ratio__c`, `FQS_Match_Annual_Individual_Maximum__c` (whole matching-gift capability off-page) |
| GiftCommitment | `FQS_Skip_Naming__c` |
| GiftTransaction | `FQS_In_Kind__c`, `FQS_Recurring__c` |
| GiftTransactionDesignation | `FQS_Restriction_Type__c` |
| GiftDefaultDesignation | `FQS_Restriction_Type__c` |
| GiftDefaultSoftCredit | `FQS_Parent_Type__c` |
| Opportunity | `FQS_Skip_Naming__c` |
| OutreachSourceCode | `FQS_Message_Channel_Segment__c`, `FQS_Platform__c` |
| Campaign (layout-driven, page layout audit needed) | `FQS_Short_Name__c`, `FQS_Child_Campaign_Count__c`, `FQS_Ultimate_Parent_Campaign__c` |

See `.planning/fqs-off-flexipage-inventory.md` for the full off-flexipage bucketing per object.

---

## Open questions

- Do Key-object help texts include a small **"how this fits with"** diagram-in-prose (e.g., GC → GCS → GT → GTD → GD chain), or is that best kept in a separate `docs/fqs-fundraising-object-map.md` and merely linked to? Diagram-in-prose helps cold landings; separate doc is easier to maintain when schema shifts.
- For standard Salesforce objects (Account, Campaign, Opportunity), does FQS override the shipped platform help text, or append FQS-specific guidance underneath? Overriding may collide with managed-package or platform defaults.
- Person Account nuance for Account help text — how much of the Person Account vs Business Account split lives in help text vs a linked doc?
- Campaign uses `force:detailPanel` (page-layout-driven, not flexipage-driven) — audit the shipped Campaign page layout to confirm which of the 3 FQS hierarchy fields are actually visible before authoring their help text.

Resolve these before authoring the first Key object.

---

## GiftEntry field-level authoring (folded in 2026-08-05)

**Scope:** Add `inlineHelpText` (end-user tooltip) and `description` (admin-only) to every field on the standard `GiftEntry` staging object. GiftEntry ships with **no in-app help text** — gift-entry staff are left guessing what "Effective Start Date" vs. "Expected End Date" means, why there are three Gift Designation slots, and what a "Soft Credit Information" long-text field is for. This section closes that gap.

**Working source for the drafts:** `archive/fqs-gift-entry-help-text-plan.md` — 49 field drafts across 9 groups (Donor identity / Address & phone / Gift financial core / Payment instrument / Attribution / Designations / Recurring / Soft credit / System-staging). Sources: Salesforce Fundraising developer docs (`GiftEntry` reference) + Implementation Guide pages 57–63 (source→target mapping).

**Files to create:** `force-app/main/default/objects/GiftEntry/fields/` (directory doesn't exist yet), one `.field-meta.xml` per field. Shape:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>FieldApiName</fullName>
    <description>Admin-facing description — anchors on the developer-doc description and names the target on save.</description>
    <inlineHelpText>End-user tooltip — plain-language guidance.</inlineHelpText>
</CustomField>
```

No `<type>` element on standard-field overrides.

**Copy contract** (differs from the object-group contracts above — GiftEntry is field-level):

| Element | Audience | Where it shows | Style |
|---|---|---|---|
| `inlineHelpText` | End users (gift-entry staff) | Tooltip on the field in Gift Entry / Gift Batch UI | Plain-language, ≤255 chars, tells them what to type and (when useful) what it becomes on save |
| `description` | Admins only | Setup → Object Manager → GiftEntry → Fields | Grounded in the official developer-doc description; names the target object/field on save; notes any constraints |

**Standard-field caveat:** Every GiftEntry field is standard (no `__c`). Salesforce permits `inlineHelpText` and `description` overrides on standard fields via field-meta.xml. If any specific field is locked by the managed package the deploy will fail gracefully with a per-field error — no data risk. Validate before merging.

**Open questions** (from original plan — resolve before authoring lands):
- Which of the 10 System/Staging fields need help text at all? Some are audit-only (`CreatedById`, `LastModifiedDate`) and would ship as empty `<description>`.
- Should the drafts be re-checked against the FundFirst-installed `GiftEntry` object list before authoring, in case the managed package extended the standard field set?
- Do the 3 dual-target fields (Restriction Release Date / Skip Naming — both split into `FQS_GC_*` + `FQS_GT_*` in 2026-08-03) need their staging mirrors documented alongside the standard field set?

