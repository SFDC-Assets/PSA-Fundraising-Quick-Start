# FQS — Process Date Refactor Plan

**Repo:** `/Users/justin.gilmore/GitHubRepos/PSA-Fundraising-Quick-Start-DEV`
**Target org:** `FundFirst` sandbox (default)
**Author:** 2026-08-02
**Status:** Draft — awaiting execution

---

## Semantic thesis

Two distinct real-world dates are currently muddled behind the FQS custom field `GiftTransaction.FQS_Processed_Date__c` and casual references to "Gift Date":

| Concept | Meaning | Field it should live on |
|---|---|---|
| **Transaction complete** | The gift is fully in the org's hands and reconciled — check cleared, card charge settled, wire received, stock sold, in-kind item received | `GiftTransaction.TransactionDate` (standard, "Transaction Completion Date") |
| **Donor tax date** | The date the org treats the gift as leaving the donor's control for tax-receipt purposes. Varies by payment channel, local law, and org policy — postmark for mailed checks, charge date for cards, delivery date for stock, etc. | New custom field `GiftTransaction.FQS_Donor_Tax_Date__c` |

Many orgs have no meaningful gap between the two (low volume, few mailed gifts, jurisdictions that prioritize receipt). FQS documentation and the field itself must make the distinction explicit **and** signal that the distinction is optional for most orgs — "leave blank; the platform will assume equal to Transaction Date."

The `FQS_Processed_Date__c` field carried a third, less-useful concept ("date the org keyed the gift into Salesforce"). That's already recoverable from `CreatedDate` and doesn't earn a dedicated field. It gets deprecated.

---

## Decisions taken (2026-08-02)

1. **Deprecate `FQS_Processed_Date__c` entirely.** Not repurposed, not renamed. Removed from permset, flexipage, seed generator, layouts, and eventually via `destructiveChanges.xml`. Historical values on real records are lost — accepted trade-off; the field never went to a production customer (still pre-1.0 accelerator).
2. **Home page copy lands in section 6 — "6. Guidance on Stewardship, Acknowledgements, and Tax Receipting".** That section exists on the live FundFirst home page but is currently `<p>Placeholder</p>`. The working-copy `FQS_Home_Page_Default.flexipage-meta.xml` is significantly drifted from live (missing sections 4–7 and both flow embeds); syncing the flexipage from live is a **prerequisite** to editing it.
3. **Guided Gift Entry flows are OUT OF SCOPE.** Two flows currently write `FQS_Processed_Date__c`: `FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml` and `FQS_Gift_Entry_Guide_Sub_PledgePayment.flow-meta.xml`. These are under active refactor (Gate A Stages 2–5, postponed 2026-07-31). Do NOT touch them here. Log the field-sweep as an open item on `.planning/fqs-release-readiness.md` so the flow refactor picks it up.

---

## Scope in

- Metadata edit: `GiftTransaction.TransactionDate.field-meta.xml` — write description + help text.
- Metadata edit: `GiftTransaction.AcknowledgementDate.field-meta.xml` — write description + help text.
- New field: `GiftTransaction.FQS_Donor_Tax_Date__c` — full `<CustomField>` XML.
- Permset update: add read/edit on new field; remove `FQS_Processed_Date__c` FLS.
- GT record page: add new field, remove old.
- GT layout: same swap.
- Seed generator (`FQSSeedGenerator.cls`): stop writing `FQS_Processed_Date__c`; populate new field with a payment-type-aware offset so seeded data illustrates the concept.
- Home page section 6: write copy explaining the date model.
- README: post-install note documenting the new field (unmanaged pkg carries the field itself, but the semantic guidance is worth calling out) + a Salesforce-owned-standard-field help-text step for `TransactionDate` if help text is set at the org level (verify — see open questions).
- Destructive changes: emit `destructiveChanges.xml` entry for `FQS_Processed_Date__c` in a **separate** follow-up deploy after all references are cleared.
- Release-readiness tracker: log open item for the flow sweep.

## Scope out (deliberate)

- **Guided Gift Entry flows.** See decision #3.
- **Renaming or repurposing `FQS_Processed_Date__c`.** See decision #1.
- **Any change to `FQS_Tax_Receipt_Date__c`.** That field is the *outcome* of year-end tax receipting (receipt issued); the new field is the *inbound anchor* (when the donor's gift acknowledgement clock started). They're complementary, not overlapping. No edit needed to its help text unless the audit surfaces confusion.
- **The Cash Flow / reconciliation reporting angle.** `FQS_Processed_Date__c` was mentioned in its description as supporting "cash-flow and reconciliation reporting" — no report actually uses it (grep clean across `force-app/main/default/reports/`). Killing it kills no reports.

---

## Prerequisite — sync working copy of the home flexipage

The working copy is stale. Diff (`diff -u force-app/.../FQS_Home_Page_Default.flexipage-meta.xml /tmp/fqs-home-retrieve/unpackaged/unpackaged/flexipages/FQS_Home_Page_Default.flexipage`) shows live has: the `FQS_Suggest_Designations` flow embed, the `FQS_Campaign_Hierarchy_Setup` flow embed, three more placeholder facets, and accordion sections 4/5/6/7 that the working copy doesn't know about.

**Before touching home page copy:**

1. `sf project retrieve start --target-org FundFirst --metadata "FlexiPage:FQS_Home_Page_Default"` into the source tree.
2. Commit the retrieved delta as its own commit — "Sync FQS_Home_Page_Default from live" — so the semantic edit lands as a clean diff on top of a synchronized baseline.
3. Only then, edit section 6's `richTextValue` (currently `<p>Placeholder</p>` at `Facet-by42dxkgq2u`).

Skipping this prerequisite = the deploy either overwrites live sections 4/5/7 with nothing, or drifts further; either way it's a Gate C violation (metadata bloat / drift). This step is non-negotiable.

---

## Work items

### 1. New field — `GiftTransaction.FQS_Donor_Tax_Date__c`

**Path:** `force-app/main/default/objects/GiftTransaction/fields/FQS_Donor_Tax_Date__c.field-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>FQS_Donor_Tax_Date__c</fullName>
    <description>The date the gift is treated as having left the donor's control for tax-receipt purposes. Varies by payment channel and local law — postmark date for mailed checks, charge-authorization date for credit-card gifts, delivery date for stock or in-kind gifts. Distinct from Transaction Date (Transaction Completion Date), which is when the gift is fully in the org's hands. Optional for most orgs — leave blank when the org has no operationally meaningful gap between the two dates (typical for low-volume, credit-card-heavy, or jurisdiction-simple orgs).</description>
    <externalId>false</externalId>
    <inlineHelpText>The date the donor is credited for tax purposes — postmark for mailed checks, charge date for cards, delivery date for stock. Leave blank if your org treats the Transaction Date as the tax date (fine for most orgs).</inlineHelpText>
    <label>Donor Tax Date</label>
    <required>false</required>
    <trackHistory>false</trackHistory>
    <trackTrending>false</trackTrending>
    <type>Date</type>
</CustomField>
```

### 2. Standard-field help text — `TransactionDate`

Currently `force-app/main/default/objects/GiftTransaction/fields/TransactionDate.field-meta.xml` carries only `<trackHistory>false</trackHistory>`. Extend with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>TransactionDate</fullName>
    <description>Standard: Transaction Completion Date. The date the gift is fully in the org's hands and reconciled — check cleared, card settled, wire received, stock sold, in-kind item taken into custody. This is FQS's canonical "when did this gift happen" date and drives cash-flow reporting, aging, and rollups on the parent commitment. Distinct from Donor Tax Date, which records when the gift left the donor's control (a different date for mailed checks, delivered stock, etc.).</description>
    <inlineHelpText>When the org fully received and reconciled the gift — check cleared, card settled, wire received. If you also track when the donor sent the gift (postmark, charge date), use Donor Tax Date. Required when Status is Paid or Fully Refunded.</inlineHelpText>
    <trackHistory>false</trackHistory>
</CustomField>
```

**⚠ README post-install step required.** Standard-field help *does* deploy via metadata (confirmed), but per [[readme-standard-field-edits]] every FQS edit to a Salesforce-owned standard field must also be documented as a README post-install step — the metadata edit rides on the initial unmanaged deploy but downstream customers pulling only subsets of the repo, or re-installing on top of an existing org, don't inherit it consistently. Ship the copy in `TransactionDate.field-meta.xml` *and* mirror it in README.

### 3. Standard-field help text — `AcknowledgementDate` (touch-up, not core)

Optional but cheap while adjacent — clarify that this is the *thank-you* date, not the *tax* date. If the audit doesn't surface confusion, skip.

### 4. Flexipage & list-view sweep

**Referenced today (grepped 2026-08-02):**

| File | Field(s) referenced | Action |
|---|---|---|
| `flexipages/FQS_GiftTransaction_Record_Page.flexipage-meta.xml` | `FQS_Processed_Date__c`, `TransactionDate`, `AcknowledgementDate`, `FQS_Tax_Receipt_Date__c` | Remove `FQS_Processed_Date__c` field block; add `FQS_Donor_Tax_Date__c` field block adjacent to `TransactionDate` (same section). Field-order convention: `TransactionDate` first, `FQS_Donor_Tax_Date__c` second (the tax-anchor date follows the canonical gift date). |
| `layouts/GiftTransaction-Gift Transaction Layout.layout-meta.xml` | `FQS_Processed_Date__c` | Same swap — remove old `<layoutItems>` block, add new one in the same section. |
| `flexipages/FQS_Account_Record_Page.flexipage-meta.xml` | `TransactionDate` in a `Paid and Pending Gift Transactions` dynamic related list (columns + sortField) | **No change.** Related list already shows Transaction Date — that's still the canonical anchor. Do NOT add the new tax-ack field to this related list; it would clutter the account overview without adding donor-facing value. |
| `flexipages/FQS_GiftCommitment_Record_Page.flexipage-meta.xml` | `LastPaidTransactionDate`, `NextTransactionDate` (both GC rollup fields, not GT.TransactionDate directly) | **No change.** Rollup fields have their own semantics unrelated to this refactor. |
| `flexipages/FQS_GiftCommitmentSchedule_Record_Page.flexipage-meta.xml` | `TransactionDate` in 3 related-list `valueListItems` blocks | **No change.** Same rationale as Account page — related list already shows the canonical date. Do NOT add the tax-ack field. |
| `flexipages/FQS_GiftTransactionDesignation_Record_Page.flexipage-meta.xml` | `Record.GiftTransaction.TransactionDate` (parent-lookup field on GTD page) | **No change.** Parent GT's Transaction Date is what's useful on a GTD; the new tax-ack field on a designation split isn't. |
| `flexipages/FQS_PaymentInstrument_Record_Page.flexipage-meta.xml` | `TransactionDate` reference | **No change** — audit at execution time. |
| `flexipages/FQS_GiftDesignation_Record_Page.flexipage-meta.xml` | `TransactionDate` reference | **No change** — audit at execution time. |
| `flexipages/FQS_OutreachSourceCode_Record_Page.flexipage-meta.xml` | `TransactionDate` reference | **No change** — audit at execution time. |

**Rule of thumb for the "no change" rows:** `TransactionDate` is *already* the canonical anchor across the accelerator — the refactor renames what people mean by it (from "the gift date" muddle to "the gift is complete") but doesn't change which field appears on any related list. `FQS_Donor_Tax_Date__c` is an *opt-in nuance field* — only surface it on the GT record page + layout, not on cross-object related lists.

**List views on GiftTransaction (grepped 2026-08-02):**

| List view | Columns referencing date fields | Action |
|---|---|---|
| `FQS_Failed_Canceled_7d.listView-meta.xml` | `<field>TransactionDate</field>` | **No change** — TransactionDate is the right anchor for a "failed / canceled in last 7 days" view. |
| `FQS_To_Be_Acknowledged.listView-meta.xml` | `<field>TransactionDate</field>` | **No change** — TransactionDate is what the ack flow queues from; the tax-ack field is irrelevant to this list. |
| All other GT list views (`FQS_Grant_Payments`, `FQS_Outright_Gifts`, `FQS_Pledge_Payments`, `FQS_Recurring_Gift_Payments`, `FQS_Transaction_Category_Other`, `All_GiftTransactions`) | No date-field columns | **No change** — these filter on category/status, not date. |
| GiftCommitment list views (`FQS_Past_Due_Installments`, `FQS_Lapsed_Recurring`, `FQS_Recurring_Gifts`) | `NextTransactionDate`, `LastPaidTransactionDate` (GC rollups, not GT.TransactionDate directly) | **No change** — GC rollups are unaffected by this refactor. |

**No GT list view references `FQS_Processed_Date__c` today** — that's a happy discovery from the grep; deprecating the field doesn't break any shipped list view.

**Optional follow-up (not in this refactor):** consider a new list view `FQS_Gifts_Where_Tax_Ack_Differs` filtered on `FQS_Donor_Tax_Date__c != null AND FQS_Donor_Tax_Date__c != TransactionDate` (or equivalent formula) for orgs that want to audit gifts where the two dates diverge. Skip on v1 — user hasn't asked for it and the semantic guidance in the home page copy covers the concept.

### 5. Deprecate `FQS_Processed_Date__c`

Two-phase deprecation (reversible until Phase B ships):

**Phase A — dereference (single deploy):**
- Remove `<field>GiftTransaction.FQS_Processed_Date__c</field>` block from `force-app/main/default/permissionsets/FQS_Custom_Fields.permissionset-meta.xml` (line 277). Add read/edit for `FQS_Donor_Tax_Date__c` adjacent.
- Flexipage / layout edits per work item 4.
- Update `force-app/main/default/classes/FQSSeedGenerator.cls`:
  - Delete line 1349 comment and line 1376 assignment.
  - Add adjacent line writing `FQS_Donor_Tax_Date__c` with a payment-type-aware offset from `TransactionDate` (e.g., Check → `TransactionDate.addDays(-randInt(0, 5))` for postmark lag; Credit Card → equals `TransactionDate`; Stock → `TransactionDate.addDays(-randInt(2, 7))`; leave blank on ~40% of Cash gifts to model the "org doesn't distinguish" case). Payment-type map lives inline in seed — no CMDT needed.

**Phase B — hard-remove (separate follow-up deploy):**
- After Phase A ships and any lingering data on `FQS_Processed_Date__c` is either backfilled to the new field or accepted as lost, add to `manifest/destructiveChanges.xml`:
  ```xml
  <types>
      <members>GiftTransaction.FQS_Processed_Date__c</members>
      <name>CustomField</name>
  </types>
  ```
- Delete `force-app/main/default/objects/GiftTransaction/fields/FQS_Processed_Date__c.field-meta.xml`.
- Verify no report/dashboard/listview reference (grep clean today — recheck at execution time).

Phase B is a separate PR so Phase A can bake and be reverted independently if a downstream (Dar's org, a demo org) surfaces a hidden dependency.

### 6. Home page section 6 copy

**After** the sync prerequisite above lands, replace `<p>Placeholder</p>` at `Facet-by42dxkgq2u` (section 6 body) with copy along these lines:

```html
<p><strong>How FQS thinks about gift dates</strong></p>
<p>FQS separates two ideas that many orgs blur together:</p>
<ul>
  <li><strong>Transaction Date</strong> — when the gift is fully in your hands and reconciled. Check cleared, card settled, wire received, stock sold, in-kind item taken in. This is your canonical "when did this gift happen" date.</li>
  <li><strong>Donor Tax Date</strong> — when the gift left the donor's control for tax-receipt purposes. Postmark date for a mailed check, charge date for a card, delivery date for stock. This is the date on the donor's receipt for tax purposes.</li>
</ul>
<p>Many orgs don't have a meaningful gap between the two — low volume, mostly card gifts, jurisdictions that treat receipt as the acknowledgement date. In those cases, leave Donor Tax Date blank and let Transaction Date speak for both. FQS's acknowledgement, stewardship, and tax-receipting flows use Transaction Date as the anchor.</p>
<p><strong>Other date fields on a gift</strong></p>
<ul>
  <li><strong>Acknowledgement Date</strong> — when the donor was thanked. Written automatically by the FQS Gift Acknowledgement flow.</li>
  <li><strong>Tax Receipt Date</strong> — when the year-end tax receipt was issued. Manual field; managed by whatever year-end receipting process your org runs.</li>
  <li><strong>Stewardship Date</strong> — when the follow-up stewardship touch was delivered. Written automatically by the FQS Stewardship Response flow.</li>
</ul>
```

Tone matches the existing Glossary block on the same page — plain HTML, `<strong>` for term intros, `<ul>` for definitions. No inline `font-size` styles (Glossary uses them; leaving them off keeps the section rendering with theme defaults, which is what more modern accelerator pages do).

### 7. Release-readiness tracker entry

Append to `.planning/fqs-release-readiness.md` under the "Deferred / open items" section (near line 226 where Gate A Stages 2–5 postponement lives):

```markdown
- **2026-08-02 — Process Date refactor: flow sweep deferred to Gate A Stage 2–5 resumption.**
  `FQS_Processed_Date__c` is deprecated in a metadata-only pass (permset / flexipage / seed / layout /
  destructiveChanges). Two Guided Gift Entry flows still write the deprecated field:
  `FQS_Gift_Entry_Single_Launcher_Account` and `FQS_Gift_Entry_Guide_Sub_PledgePayment`. These flows
  are under active refactor (Gate A Stages 2–5) and are deliberately not touched here. When Stage 2/3
  extraction resumes: (a) drop the `FQS_Processed_Date__c` assignment nodes, (b) if a "when did we
  key this" concept is still useful, wire to `CreatedDate` in downstream reports rather than
  reintroducing a custom field, (c) add a `FQS_Donor_Tax_Date__c` input screen with
  a per-payment-type default (blank on card, blank on cash if org policy allows, prompt on check /
  stock / in-kind). Semantic rationale in `.planning/fqs-process-date-refactor-plan.md`.
```

### 8. README updates

Under §Post-install steps (or wherever standard-field help text lives — see [[readme-standard-field-edits]]):

- Add step: **"Verify Transaction Date help text"** — quote the description + inline help text from work item 2. Ships via metadata deploy, but the README step is required per accelerator policy (documents every standard-field edit so partial re-installs and manual audits stay accurate).
- Add step (only if `AcknowledgementDate` help text is refreshed): same pattern.

New custom field `FQS_Donor_Tax_Date__c` doesn't need a post-install step — the unmanaged package deploys it directly.

---

## Deploy sequence

1. **Sync commit** — retrieve live home page, commit as its own commit.
2. **Phase A commit** — new field + `TransactionDate` help + (optional) `AcknowledgementDate` help + permset + flexipage + layout + seed generator changes + home page section 6 copy + release-readiness entry + README updates. Deploy to FundFirst as one unit; verify.
3. **Phase B commit** (later) — `destructiveChanges.xml` + delete `FQS_Processed_Date__c.field-meta.xml`. Deploy standalone.

Rationale for splitting Phase A/B: destructive deploys are non-reversible and lose history. Phase A gets exercised in the wild first (in FundFirst, then any Dar demo org, then packaging cut) — if a hidden consumer surfaces, we haven't burned the field yet.

---

## Verification checklist

Post-Phase-A deploy:

- [ ] Open a Gift Transaction record page. `Donor Tax Date` renders with the help-text bubble; `Processed Date` is gone.
- [ ] Hover the `?` on `Transaction Date` — new inline help renders.
- [ ] Home page → section 6 renders the new copy (not "Placeholder"); other sections unaffected.
- [ ] Run seed generator (`sf apex run -f scripts/apex/fqs-seed.apex`) — no compile error; sample query returns `FQS_Donor_Tax_Date__c` populated on check gifts, blank on some cash gifts, equal to Transaction Date on card gifts.
- [ ] Permset FQS_Custom_Fields → GT field list shows new field, not old.
- [ ] Guided Gift Entry launcher still runs (do NOT deploy flow changes; sanity-check the flow still works because the field it writes still exists — it's just deprecated on the layout).
- [ ] `git grep FQS_Processed_Date` returns only the release-readiness tracker entry, the field file itself, and the two flows.

Post-Phase-B deploy:

- [ ] `git grep FQS_Processed_Date` returns only the release-readiness tracker entry (historical mention) and, if the flow sweep hasn't happened yet, the two flow files (broken — Phase B blocked until flows are swept).
- [ ] Actually — **Phase B blocks on the flow sweep**. Order of operations is: Phase A → Gate A Stage 2/3 flow refactor (which also drops the `FQS_Processed_Date__c` writes) → then Phase B destructive. Update the release-readiness entry to make this ordering explicit.

---

## Open questions

- Does the seed generator have a `PaymentMethod` handle at the point where it currently writes `FQS_Processed_Date__c` (line 1376 of `FQSSeedGenerator.cls`)? Confirm before drafting the payment-type-aware default logic in work item 5-Phase-A.
- Should the home page section 6 copy also link to the object help text on `GT.TransactionDate` / `GT.FQS_Donor_Tax_Date__c`? Cross-navigation would help, but flexipage rich text doesn't support Salesforce-relative links cleanly. Skip on v1.

---

## Related planning docs / memories

- `.planning/fqs-object-help-text-gc-gcs-gt.md` — GT.TransactionDate description at line 264 currently references `FQS_Processed_Date__c`; update after this plan executes.
- `.planning/fqs-pledge-with-first-payment-plan.md` — references processed date; audit and refresh at plan-execution time.
- `.planning/fqs-release-readiness.md` line 226 — Gate A Stage 2–5 postponement (owns the flow-sweep follow-up).
- Memory `[[readme-standard-field-edits]]` — governs how standard-field help edits are documented.
- Memory `[[seed-scripts-purpose]]` — seed is testing-first, demo-second; guides the "leave blank on 40% of cash gifts" choice for realistic test data.
