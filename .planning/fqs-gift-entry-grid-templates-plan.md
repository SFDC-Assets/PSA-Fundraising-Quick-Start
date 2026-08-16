# FQS GiftEntryGridTemplate Extension — Plan

**Owner:** Justin (solo)
**Status:** Phase 1 (FQS field columns) **SHIPPED 2026-08-03** — Phase 2 (Post-processing LWCs) drafted
**Created:** 2026-08-03
**Depends on:** GiftEntry staging fields + `FieldMappingConfig` (commits `99a37f4` and `737d4d6`), guided-flow plan `.planning/fqs-gift-entry-guide-plan.md`
**Related metadata types:** `GiftEntryGridTemplate` (per-file YAML under `force-app/main/default/giftEntryGridTemplates/`), `LightningComponentBundle` (for Phase 2 LWCs), `FieldMappingConfig` (already extended to fan out FQS columns to canonical GT/GC on commit).

---

## 1. Vision

The 5 pre-existing FQS grid templates (all cloned from the Salesforce standard) initially exposed only the platform's standard `GiftEntry` columns (Donor, Received Date, Amount, Payment Method, Campaign, Designation, Soft Credits, etc.). Phase 1 wires the 12 FQS staging-mirror fields into the four FQS-labeled templates as top-level columns so bulk-entry admins can populate them alongside standard fields.

The grid template is the **bulk-entry surface**; the guided flow is the **single-record surface**. Both write into the same `GiftEntry` row that Salesforce fans out via `FieldMappingConfig`. Every FQS field the guided flow captures is also captureable on the grid.

Phase 2 layers on **LWC extensions** — post-processing modals, custom column modals, and cell edit components — to close the intelligence gap between grid entry and guided entry. Phase 2 is optional and post-1.0.

## 2. Design principles (corrected 2026-08-03)

### 2.1 Every FQS field on GiftEntry is a top-level column

FQS custom fields live directly on `GiftEntry`. They're all standard field types the platform renders natively (Date, Currency, Checkbox, Picklist). No LWC required to expose them, and there is no functional advantage to burying them in a modal. **Top-level column is the default placement.**

The only reason to move an FQS field into a modal would be if it were part of a **related-object field set** (like `PaymentInstrument.Last4` + `ExpiryMonth` + `ExpiryYear` inside the Payment modal, or `GiftCommitmentSchedule.TransactionPeriod` + `TransactionInterval` + `TransactionDay` inside the Commitment modal). No FQS field falls into that category — they all belong on the GiftEntry row itself.

### 2.2 Modals expose related-object detail; they are not "hide the rare fields"

The three built-in modals in a Gift Entry grid (Donor, Commitment, Payment) are portals into related sObjects: Contact fields, GiftCommitmentSchedule fields, PaymentInstrument fields. Their reason to exist is **field grouping across an object boundary**, not "hide rarely-used fields." A `Stewardship Status` field on `GiftEntry` belongs at the same level as `Payment Method` on `GiftEntry` — both are top-level columns. Moving Stewardship Status into a modal would just make admins hunt for it without providing any conceptual grouping benefit.

### 2.3 Match Eligible ≠ Match Status — they follow different fanout patterns

**Match Eligible** lives on the parent commitment (`GiftCommitment.FQS_Match_Eligible__c` ← mapped from `GiftEntry.FQS_GC_Match_Eligible__c`). It's set once, per commitment. Only templates that *create* a fresh commitment can meaningfully set this field:

- Single Payment Pledges (creates GC + first GT)
- (Future template) Recurring / Scheduled Pledges if we add them (also create GC + first GT)

**Match Status** lives per transaction (`GiftTransaction.FQS_Match_Status__c` ← mapped from `GiftEntry.FQS_Match_Status__c`). Every template that creates a GT can set it:

- Individual Outright Gifts (yes)
- Single Payment Pledges (yes — the first GT)
- Pledge Payments (yes — this specific payment)
- Event Registrations (skip — not a donation, corporate match doesn't apply)

The two fields are **not paired**. They're linked semantically (a corporate match cycle progresses from Eligible on the GC to Status per payment) but they populate at different lifecycle stages and belong on different template shapes.

### 2.4 Restriction Release Date and Skip Naming split by what the template creates

Because Salesforce enforces "one source field → one destination" per `FieldMappingConfig`, these fields are already split into `FQS_GC_*` / `FQS_GT_*` GiftEntry columns (2026-08-03 commit `737d4d6`). Placement follows what the template creates:

- Template creates GC + GT (Single Payment Pledges) → both GC-side and GT-side columns appear
- Template creates only a GT (Outright, Pledge Payment, Event Registration) → only GT-side column appears

### 2.5 The Standard clone stays clean

`Cloned_Salesforce_Gift_Entry_Standard_Template` is the reference baseline showing what Salesforce ships out of the box. **Do not add FQS fields to it** — leaves admins with a clean starting point to copy from.

## 3. Phase 1 — Field column addition (SHIPPED 2026-08-03)

### 3.1 What landed

Deploy IDs:
- Spot-check (Outright only): `0AfWB00000DlTyL0AV`
- Remaining three templates: `0AfWB00000DlUso0AF`

Per-template column additions:

**`FQS_Individual_Outright_Gifts`** — 8 new FQS columns:

| FQS field | Column ID | Column Label |
|---|---|---|
| `FQS_Gift_Transaction_Category__c` | `FQS_Category` | Category |
| `FQS_Match_Status__c` | `FQS_MatchStatus` | Match Status |
| `FQS_Donor_Tax_Date__c` | `FQS_DonorTaxDate` | Donor Tax Date |

Skipped: `FQS_GC_Match_Eligible__c` (no GC created), `FQS_Fair_Market_Value_Amount__c` (outright monetary — in-kind belongs in its own future template), all `FQS_GC_*` fields (no GC created).

**`FQS_Single_Payment_Pledges`** — 11 new FQS columns (most coverage — creates both GC and GT):

| FQS field | Column ID | Column Label |
|---|---|---|
| `FQS_Gift_Transaction_Category__c` | `FQS_Category` | Category |
| `FQS_GC_Match_Eligible__c` | `FQS_GC_MatchEligible` | Match Eligible |
| `FQS_Match_Status__c` | `FQS_MatchStatus` | Match Status |
| `FQS_GC_Restriction_Release_Date__c` | `FQS_GC_RestrictionReleaseDate` | Restriction Release Date (Commitment) |

**`FQS_Pledge_Payments`** — 9 new FQS columns (parent GC exists already, GC-side fields not editable here):

| FQS field | Column ID | Column Label |
|---|---|---|
| `FQS_Gift_Transaction_Category__c` | `FQS_Category` | Category |
| `FQS_Match_Status__c` | `FQS_MatchStatus` | Match Status |
| `FQS_GT_Restriction_Release_Date__c` | `FQS_GT_RestrictionReleaseDate` | Restriction Release Date |

Skipped: `FQS_GC_Match_Eligible__c`, `FQS_GC_Restriction_Release_Date__c`, `FQS_GC_Skip_Naming__c` (parent GC controls these, not editable at payment time).

**`FQS_Event_Registrations`** — 7 new FQS columns (no Match — corporate matches don't apply to non-donation transactions):

| FQS field | Column ID | Column Label |
|---|---|---|
| `FQS_Gift_Transaction_Category__c` | `FQS_Category` | Category |
| `FQS_Fair_Market_Value_Amount__c` | `FQS_FairMarketValue` | Fair Market Value |

Skipped: Match Eligible + Match Status (not a donation), Stewardship Date (event registrations never stewarded — Stewardship Status defaults to "Don't Send" via a future `defaultValue:` refinement).

**`Cloned_Salesforce_Gift_Entry_Standard_Template`** — no changes. Reference baseline preserved.

### 3.2 Validated during Phase 1

- Custom `FQS_*` GiftEntry fields DO work as top-level `columnType: Field` columns (Q1 from earlier draft resolved).
- Column IDs follow `FQS_*` semantic naming — no UUIDs used.
- Deploy pattern via `sf project deploy start --source-dir` works cleanly (no mdapi workaround needed).

### 3.3 Phase 1 UAT (deferred)

Still to verify in-org via Setup UI / grid preview:

- Open each of the four FQS templates in Setup → Gift Entry Templates → Display Columns and confirm the new FQS columns render at the tail of the column list.
- Bulk-enter one row per template that exercises every new FQS column, save the batch, and verify:
  - Every GT field lands on the resulting GiftTransaction record
  - `FQS_GC_Match_Eligible__c`, `FQS_GC_Restriction_Release_Date__c`, `FQS_GC_Skip_Naming__c` land on the GC record (Single Payment Pledges only)
  - Picklist columns (Category, Match Status, Stewardship Status) source their values from the correct GlobalValueSet
- Confirm horizontal scroll is manageable at typical monitor widths — Single Payment Pledges has 20 columns; if too dense, we can `isColumnHidden: true` a few less-critical ones or reorder.

## 4. Phase 2 — LWC extensions (drafted, not started)

Salesforce publishes three integration points for authoring your own LWCs that plug into the grid. All three respect the same "grid template YAML references the LWC by name" pattern and require only `<isExposed>true</isExposed>` + no `<targetConfigs>` in the LWC's `.js-meta.xml`. No source retrieval of the built-in `runtime_industries_frops/*` LWCs is needed (or possible).

### 4.1 Integration points

| Slot | Contract | Return mechanism | Use when |
|---|---|---|---|
| **Post-Processing Modal (single entry only)** | `@api rowData`, `@api configuration`, `@api giftTransactionId`. Fires AFTER Process Gift / Process & New. `rowData` includes the generated `GiftTransactionId` (and `Id` for the source GiftEntry). Modal owns its own DML — typically creates a **related record** using the new IDs. Dispatch a `closemodal` custom event to exit. | Direct DML from within the LWC (using `lightning-record-edit-form` or Apex). | You want to create/link a **related record** (Tribute, honoree contact, external system notification) tied to the just-created GT, using its actual ID. **NOT for pre-commit defaulting.** |
| **Column Modal** | `@api rowData` (row's GiftEntry field values), `@api modalFields` (fields configured in template YAML — usually unused for custom LWCs). Grid renders a wrapper with title + Continue/Cancel. Expose `@api validate()` returning `{isValid, invalidFields}` and `@api getComponentValues()` returning `{FieldApiName: value, ...}`. Values applied to the row on Continue click. | Return object from `@api getComponentValues()`. Fires BEFORE commit. | You want to render a **compound modal** that captures multiple related fields with custom logic (e.g., cross-field validation, dynamic field visibility, external API lookup) and writes back to the GiftEntry row. |
| **Cell Display / Cell Edit Component** | Display: `@api params` (row + colDef). Edit: `@api params`, `static delegatesFocus = true`, `<Component>.tagName = 'c-...'`, `<Component>.isPopup = true`. Cell Edit publishes to `lightning__giftEntryGridComponentAction` message channel with a strict `{action: "ColumnEdit", componentName, colId, details: {rowId, rowIndex, giftEntryFields, rowProperties}}` payload. | Message-channel publish (not return value). Fires BEFORE commit, on cell interaction. | You want to **replace a native column input** with a smarter interaction (e.g., barcode scanner, external lookup, autocomplete) that populates multiple peer columns from one input. |

### 4.2 Post-Processing Modal semantics clarification

Post-processing modals are **not** batch-default configuration. They run:

1. **Per single-gift row**, one at a time — they're wired to single-gift entry, not bulk-grid entry.
2. **After** the GiftEntry commit fans out to the GT/GC/etc.
3. With the `GiftTransactionId` / `GiftCommitmentId` **already populated** in `rowData`.

Use cases:
- **Create a related child record** — Tribute, Honoree Contact, Employer Match Request, GiftBatch entry, Task/Event follow-up — that references the just-created GT/GC by ID
- **Trigger an external side effect** — post a webhook, send a Slack notification, log a Data Cloud event — with the actual record IDs
- **Show a confirmation with a link** — "Gift created: click here to open the record" with the real URL

They are NOT for:
- Setting default values on the row before commit (use `defaultValue:` on the sourceField in the YAML, or a cell-edit component)
- Applying batch-level defaults across many rows (that's a batch-scoped concept — grid templates don't have batch modals; the closest equivalent is the standard "Gift Entry Batch" object's own defaults)
- Overriding fields on the just-created GT (do that pre-commit via `getComponentValues()` from a column modal, or via `FieldMappingConfig` at fanout time)

### 4.3 Proposed FQS LWC extensions (post-1.0 candidates)

Not for Phase 1. Ordered by ROI:

**(a) `fqsGiftTributePostSave` — Post-Processing Modal on all four FQS templates**

- Fires after single-gift commit
- Reads `rowData.GiftTransactionId`
- Displays a `lightning-record-edit-form` for `GiftTribute`: TributeType (default Honoree), HonoreeContactId, HonoreeName, HonoreeInformation
- Hidden `GiftTransactionId` field auto-populated
- Skips itself unless a new `FQS_Is_Tribute__c` boolean on GiftEntry is TRUE (add as a mirror field to GT `FQS_Is_Tribute__c` if it doesn't exist yet — check schema first)
- Direct DML on `GiftTribute` via the record-edit-form
- Dispatches `closemodal` on success

Payoff: single-entry admins can create honor/memorial gifts without leaving the grid workflow. Currently they'd have to navigate to the GT after commit and create the Tribute manually.

**(b) `fqsMatchWizardColumnModal` — Column Modal on Single Payment Pledges' Match Eligible column**

- Replaces the native picklist edit for `FQS_GC_Match_Eligible__c`
- Reads `rowData.DonorId`
- Fires Apex to query the donor's Employer ACR → look up Account.FQS_Matching_Gift_Program__c / FQS_Match_Ratio__c / FQS_Match_Annual_Individual_Maximum__c on the Employer Account
- Shows: "Employer detected: {name}. Match ratio: 1:{ratio}. Projected match: ${amount}."
- User confirms or overrides
- On Continue: `getComponentValues()` returns `{FQS_GC_Match_Eligible__c: true, FQS_Match_Status__c: "Eligible"}` (or leaves both null if declined)

Payoff: grid-entry match detection reaches parity with the guided flow's match branch. Currently admins have to know the donor's employer and their program details manually.

**(c) `fqsHistoricalPaymentCellEdit` — Cell Edit Component on Pledge Payments' Commitment column**

- Replaces the native commitment lookup on the `Commitments` column
- On lookup selection, Apex queries open GTs on the picked `GiftCommitmentId` (Status IN Unpaid / Pending / Failed, ordered by TransactionDueDate ASC)
- If a payable installment exists, shows a mini-datatable inside the popup letting the admin pick which installment this row represents (update-existing) vs. creating a fresh payment (insert-new)
- Publishes to the message channel with `giftEntryFields: {GiftCommitmentId, ...prefilled amount + payment method from the picked GCS + FQS_Match_Status__c defaulted from parent GC.FQS_Match_Eligible__c}`

Payoff: mirrors the guided flow's `Screen_Existing_GTs` decision. Currently grid entry against a pledge can only insert a new GT — admins can't update an existing Expected installment.

### 4.4 Phase 2 implementation shape

Each LWC lives at `force-app/main/default/lwc/<componentName>/` with its `.js`, `.html`, and `.js-meta.xml`. YAML wiring in the grid template references it by `componentName: c/fqsGiftTributePostSave` (post-processing) or `componentName: c/fqsMatchWizardColumnModal` (column modal) or `componentNameEdit: c/fqsHistoricalPaymentCellEdit` (cell edit).

Ship order (if pursued):
- **2a.** `fqsGiftTributePostSave` — simplest LWC, no Apex dependency, exercises the post-processing pattern
- **2b.** `fqsMatchWizardColumnModal` — moderate complexity, requires an Apex controller for the employer lookup
- **2c.** `fqsHistoricalPaymentCellEdit` — most complex, message-channel publish + Apex query + popup logic

Each ships with:
- LWC bundle
- Any required Apex + Apex tests
- YAML wiring change to the target template(s)
- Deploy + UAT

### 4.5 Phase 2 gating

Phase 2 is **not on the FQS 1.0 critical path.** Decision to pursue lives with the accelerator's product story:
- If FQS positions the grid as "as-intelligent-as-guided-entry," (b) and (c) become required
- If FQS 1.0 accepts a rough parity (guided flow is the intelligent surface; grid is the bulk-entry backup), (a) is a nice-to-have and (b)/(c) are deferred

Recommend: revisit after 1.0 UAT feedback surfaces the actual gap.

## 5. Cross-cutting concerns

### 5.1 Deploy discipline

Grid templates deploy cleanly via source format — one file per template, one deploy per template ideally so the audit trail is legible. Batching 2–3 in a single deploy is fine.

### 5.2 YAML gotcha

The `<templateConfiguration>` is **inline YAML inside XML** — indentation is significant, the parser is strict. When editing, preserve exact indentation (2-space list items with a leading ` -`) and escape sequences like `&quot;&quot;` for empty strings. Read + Edit rather than programmatic string manipulation.

### 5.3 Column IDs

Salesforce mixes semantic IDs (`Donor`, `GiftReceivedDate`) with UUIDs on some columns. **All FQS-added columns use semantic IDs prefixed `FQS_*`** (e.g., `FQS_Category`, `FQS_MatchStatus`, `FQS_GC_RestrictionReleaseDate`). This makes future edits greppable.

### 5.4 Localization

FQS column labels use plain English strings (not `$Label.GiftEntryGrid.*` — those are Salesforce-managed labels FQS doesn't own). Example: `columnLabel: Restriction Release Date`.

### 5.5 Rollback

Each phase is a single-file (or few-file) edit. Rollback = `git revert <commit>` + redeploy. No data-loss risk — grid templates don't own data, they only render fields for entry. Data already committed via the FieldMappingConfig fanout stays intact regardless of template state.

### 5.6 Horizontal scroll budget

Single Payment Pledges hit 20 columns after Phase 1. If UAT shows this is too dense on a 1440px monitor, the fix is either:
- `isColumnHidden: true` on 2–3 less-critical columns (admins can un-hide per-user via the grid UI)
- Reorder columns to prioritize the frequently-edited ones on the left
- Move the least-frequently-edited columns (Skip Auto Naming variants, Tax Receipt Date) to `isColumnHidden: true` by default

Do NOT rearrange the standard Salesforce column order (Donor first, etc.) — admins expect that.

## 6. Documentation follow-ups (Phase 3)

After Phase 1 UAT + Phase 2 decision:

- `docs/gift-entry-field-mapping.md` — add a §Grid Templates section with the field placement matrix from §3.1 above
- `docs/custom-fields-recap.md` — note grid-template exposure of each FQS field
- README §III (or wherever grid templates are documented) — inventory the 4 FQS-labeled templates + the Standard clone with a brief per-template description
- `.planning/fqs-release-readiness.md` — append a Phase 1 landing entry

## 7. Open questions (resolved)

- **Q1.** Does `GiftEntryGridTemplate` accept custom `FQS_*` GiftEntry field API names in `sourceField:`? — **YES**, resolved by Phase 1 spot-check (Outright deploy `0AfWB00000DlTyL0AV`).
- **Q2.** Should the `Cloned_Salesforce_Gift_Entry_Standard_Template` be deleted from the org? — **NO, keep as reference baseline.** Admins can clone from it.
- **Q3.** Should we add a dedicated `FQS_In_Kind_Gifts` template for pure in-kind entries (stock, art, goods)? — **Deferred.** Currently in-kind is handled via `PaymentMethod='In-Kind'` inside Pledge Payments (with Fair Market Value column now exposed). Standalone template is a post-1.0 addition if bulk in-kind entry becomes a real workflow.
- **Q4.** Post-install README documentation of templates? — **Yes, add in Phase 3 doc pass.** Templates ship as unmanaged metadata; they'll appear in Setup → Gift Entry Templates on install with no admin action required.

## 8. Success criteria (Phase 1 — MET 2026-08-03)

- ✅ All 4 FQS-labeled templates surface every FQS field that's relevant to their shape (per §3.1)
- ✅ The `Cloned_Salesforce_Gift_Entry_Standard_Template` remains unchanged as the reference baseline
- ✅ Deploy sequence works via `sf project deploy start --source-dir` (source format, no mdapi workaround needed)
- ✅ Grid entry → guided-flow parity: every field the guided flow captures is also captureable in bulk-entry (subject to UAT verification per §3.3)
- ⏳ Documentation updates deferred to Phase 3
- ⏳ Tracker entry in `.planning/fqs-release-readiness.md` deferred to Phase 3
- ⏳ In-org UAT deferred (§3.3)
