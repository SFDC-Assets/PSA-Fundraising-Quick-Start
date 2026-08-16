# FQS Gift Entry Guide — Multi-Surface Launcher Plan

**Owner:** Justin (solo)
**Status:** DRAFT — awaiting final approval
**Created:** 2026-07-31
**Depends on:** existing `FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml` (12,096 lines, currently the only monolithic launcher)
**Supersedes (in scope):** the postponed Gate A Stages 2–5 — subflow extraction now has real ROI because three additional launchers will consume the same subflows

---

## 1. Vision (one paragraph)

Today, gift entry is a single 12k-line Screen Flow launched only from the Account record page. This plan expands the surface area to **four callers** — the same Account launcher (extended to also work from the Home page / utility bar via a first-screen donor lookup), a new GiftCommitment-context "pledge payment" launcher, and a new Opportunity-context commitment-creator (with an optional "close the opportunity" step). To make that tractable without 4× drift on every bug fix, the current monolith is first **decomposed into three shared Screen-Flow subflows** — one each for the commitment-shape leaves (Pledge / Recurring / Grant), the outright-transaction leaves, and the new pledge-payment leaf — and each parent flow becomes a thin router that resolves donor context from its surface and calls the subflow(s).

Naming convention (per user 2026-07-31): **new flows use the `FQS_Gift_Entry_Guide_*` prefix** and the existing `FQS_Gift_Entry_Single_Launcher_Account` monolith is **left in place, untouched**, until the new suite is UAT-green. This is a "build-alongside" migration, not an in-place refactor.

---

## 2. Current state (2026-07-31)

| Surface | Flow | Lines | Status |
|---|---|---|---|
| Account record page (quick action) | `FQS_Gift_Entry_Single_Launcher_Account` | 12,096 | Monolith; Gate A Stage 1 shipped (commit `3f20a50`); Stages 2–5 postponed → **now folded into this plan** |
| GiftCommitment record page | `FQS_Gift_Entry_Single_Launcher_GiftCommitment` | 302 | Placeholder-only (six frops_flo routing stubs); **will be scrapped and rewritten** |
| Opportunity record page | `FQS_Gift_Entry_Single_Launcher_Opportunity` | 380 | Working (Major_Gift → Pledge, Grant → Grant Payout); **will be scrapped and rewritten with expanded scope + optional close-opp** |
| Home page / utility bar | — | — | Does not exist; **will be folded into the Account launcher** (same flow, donor lookup on first screen when `recordId` is null) |

Element inventory of the current Account monolith (drives extraction sizing):

| Element type | Count |
|---|---|
| screens | 24 top-level (excludes fields nested within) |
| decisions | 63 |
| assignments | 77 |
| loops | 10 |
| recordCreates | 23 |
| recordUpdates | 4 |
| recordLookups | 31 |
| actionCalls (subflows/invocables) | 5 |
| transforms | 2 |
| variables | 58 |
| formulas | 51 |
| choices | 56 |

The four monetary leaves (Outright, Simple Pledge, Custom Pledge, Recurring, Scheduled Pledge, Scheduled Grant, Single Payment Pledge, Single Payment Grant, Pledge Payment, In-Kind, Earned Income, Event Registration) all currently live inline. The lion's share of the 12k lines is in the commitment-shape leaves and their downstream fanouts (schedules, expected GTs, designations, soft credits).

---

## 3. Target architecture

### 3.1 The four parent flows (thin routers)

| Parent | Surface | Entry inputs | Approx. size after extraction | New/existing |
|---|---|---|---|---|
| `FQS_Gift_Entry_Guide_Universal` | Account quick action **and** Home/Utility Lightning launcher | `recordId` (nullable) | 1,000–1,500 lines | NEW — replaces `FQS_Gift_Entry_Single_Launcher_Account` |
| `FQS_Gift_Entry_Guide_GiftCommitment` | GiftCommitment quick action | `recordId` (required — the GC) | ~250 lines | NEW — replaces the 302-line placeholder stub |
| `FQS_Gift_Entry_Guide_Opportunity` | Opportunity quick action | `recordId` (required — the Opp) | ~600 lines | NEW — replaces the 380-line existing Opp launcher |
| — | — | — | — | Existing 3 launcher files are **deleted only after** UAT-green cutover |

Parent responsibilities (kept in the parent, NOT extracted):

- **Donor resolution** (surface-specific): Universal reads `recordId` → if blank, show `flowruntime:lookup` on Account; otherwise `Get_Account` with fields. GC parent gets `Donor__c` from the GC. Opp parent gets `Account.Id` from the Opp.
- **Menu-level routing decisions** (leaf pick — see §3.5).
- **Success / warning / error screens** that reference surface-specific record context (e.g., "Open the new commitment on this Opportunity's related list").
- **Surface-specific side effects**: Opp parent's optional "close the Opportunity" (`StageName = 'Closed Won'`) after the subflow returns the GC id.
- **Fault paths** to a shared surface-appropriate error screen.

### 3.2 The three shared subflows

Screen-flow subflows (Winter '24+ supports embedding screen flows as subflows in screen flows), invoked via `<subflows>` element. The main flow renders each subflow's screens inline as the interview progresses.

| Subflow | Purpose | Approx. size | Inputs (`isInput=true`) | Outputs (`isOutput=true`) |
|---|---|---|---|---|
| `FQS_Gift_Entry_Guide_Sub_Commitment` | Pledge/Recurring/Grant creation. Handles all four `Screen_Pledge_Details` / `Screen_Recurring_Details` / `Screen_Scheduled_Details` shapes, plus Custom-branch GCS generation, Expected-GT hand-authoring (per [[processgiftcommitment-multi-gcs-fanout]]), Employer-recurring GDSC fanout to GSCs, past-payment confirmation. | 5,000–6,000 lines | `donorId` (String), `donorName` (String, for UI), `defaultCampaignId` (String, nullable), `defaultAmount` (Currency, nullable, from Opp), `defaultStartDate` (Date, nullable, from Opp), `sourceContext` (String — 'Account' \| 'Opportunity' — for header copy) | `outCommitmentId` (String), `outCommitmentCategory` (String — 'Pledged Gift' \| 'Recurring Gift' \| 'Grant Payout'), `outExpectedTotal` (Currency) |
| `FQS_Gift_Entry_Guide_Sub_Outright` | Outright / In-Kind / Earned Income / Event Registration — single paid GT with designations + soft credits + optional employer match. No GC created. | 2,000–2,500 lines | `donorId`, `donorName`, `defaultCampaignId`, `sourceContext` ('Account' — Home surfaces route the same way) | `outGiftTransactionId` (String), `outAmount` (Currency), `outCategory` (String) |
| `FQS_Gift_Entry_Guide_Sub_PledgePayment` | Payment against an existing active pledge. Creates paid GT stamped with `GiftCommitmentId = <input>`, cascades designations from the parent GC's GiftDefaultDesignations, optional employer match, optional past-due multi-payment. **This is the one net-new leaf.** | 1,500–2,000 lines | `donorId`, `donorName`, `commitmentId` (String — the GC to pay against, REQUIRED), `defaultCampaignId`, `sourceContext` ('Account' \| 'GiftCommitment') | `outGiftTransactionId`, `outAmount`, `outCategory` ('Pledge Payment' constant) |

**Why three subflows, not one?** The three flows have materially different input requirements (Commitment needs pledge-specific defaults, Outright needs none, PledgePayment needs a commitment id), materially different output shapes (GC id vs GT id), and different execution shapes (Commitment has 4 branches + Custom GCS loop + multi-GCS fanout; Outright is a 1–2 DML happy path; PledgePayment cascades from an existing parent). One monolithic "do anything" subflow would just move the routing complexity down a level.

**Why not extract more (Designation resolver, GSC fanout, employer-match, etc.)?** Those are utilities called from multiple leaves within a single subflow. Extracting them adds subflow-invocation ceremony without saving anything (each call site is 3–5 elements). Handle them via well-named element groups within the parent subflow. Rule: **extract a subflow when it has independent callers across parent flows**, not when it has repeated call sites within one flow.

### 3.3 Universal parent — first-screen donor-context handling

Per user 2026-07-31: **the donor lookup lives on the same screen as the leaf menu**, gated by `recordId` presence.

```
Screen_Universal_Entry
├─ (visible when recordId IS BLANK) — flowruntime:lookup on Account
│   • fieldApiName = "AccountId" on Person or Organization (uses lookup filter for donor RTs)
│   • sets rsvDonorFromLookup.recordId
├─ (visible when recordId IS NOT BLANK) — DisplayText: "Recording a gift for {!Get_Account.Name}"
└─ Radio: pkCategory (Set up pledge/grant | Log individual transaction | Log in-kind/earned/event)
```

After Next: decide `varDonorId = COALESCE(recordId, rsvDonorFromLookup.recordId)`, `Get_Account` on that, then route into the same category-decision the current Account launcher uses.

**Note:** Home / utility surfaces expose the Universal flow via a **new Lightning App Page** or **Utility Bar item** — this is a Flexipage change, not a quick action (quick actions require a record context). The exact surface (App Page component vs. Utility Item vs. Home component) is a Flexipage-level detail — recommend a **Home page Flow component** first (simplest to install and screenshot for docs) with the option to add a utility item later.

**Quick action (per user 2026-08-02):**
- API name: `Account.FQS_Guided_Gift_Entry.quickAction-meta.xml`
- Label: **Guided Gift Entry**
- `flowDefinition`: `FQS_Gift_Entry_Guide_Universal`
- Existing `Account.FQS_Launch_Gift_Entry.quickAction` is **deleted** in Phase 4 (not repointed — user wants a clean rename). The Flexipage that currently references the old action must also be updated in the same phase.
- Conditional visibility (Flexipage-level Dynamic Action — see §5.6):
  - Show when `Account.RecordType.DeveloperName` IN `{'Organization', 'PersonAccount'}` — hide on Household or other non-donor RTs. (User can override at install time if their donor RTs differ; document as post-install README step.)

### 3.4 GC parent — pledge payment only

Per user 2026-07-31: **pledge payment is not new functionality — it already exists inside the Universal flow as one leaf**, but the GC launcher provides a **shortcut** into just that leaf from the GC record page.

```
Get_Commitment → validates Status='Active' and Category IN ('Pledged Gift','Grant Payout')
    ↓
Decide_Payable
    ├─ true → Subflow(FQS_Gift_Entry_Guide_Sub_PledgePayment, donorId=Donor__c, commitmentId=recordId, ...)
    │           ↓
    │       Screen_Success (offers link to the new GT + link back to GC)
    │
    └─ false → Screen_Not_Payable ("This commitment can't accept payments. Only Active pledges and grants can. Detected: Status={!Get_Commitment.Status}, Category={!Get_Commitment.Category}.")
```

Total ~250 lines. No frops_flo placeholders; those live in a **separate future launcher** (per §7).

**Quick action (per user 2026-08-02):**
- API name: `GiftCommitment.FQS_Pledge_Payment.quickAction-meta.xml`
- Label: **Pledge Payment**
- `flowDefinition`: `FQS_Gift_Entry_Guide_GiftCommitment`
- Conditional visibility (Flexipage-level Dynamic Action — see §5.6):
  - Show when `GiftCommitment.Status == 'Active'`
  - AND `GiftCommitment.FQS_Gift_Commitment_Category__c` IN `{'Pledged Gift', 'Grant Payout'}` (expressed as two OR'd equality filters)
  - Hidden on Recurring Gift, Outright Contribution, In-Kind Gift, Earned Income, Event Registration commitments (they aren't paid via pledge-payment shape); hidden on Closed / Cancelled GCs.

### 3.5 Opportunity parent — commit + optional close

Rewritten to route ALL Opp RecordTypes through the Commitment subflow with sensible defaults; adds the optional close-opp step per user 2026-07-31.

```
Get_Opportunity (+ RecordType)
    ↓
Decide_RecordType
    ├─ Major_Gift → Subflow(Sub_Commitment,
    │                  donorId=AccountId, defaultAmount=Amount, defaultStartDate=CloseDate,
    │                  sourceContext='Opportunity',
    │                  # subflow's own Pledge/Recurring picker still shows — user might want Recurring)
    │
    ├─ Grant → Subflow(Sub_Commitment, ... same, subflow's picker defaults to Grant Payout)
    │
    └─ Other (Donation, Fundraising, etc.) → Subflow(Sub_Outright,
                donorId=AccountId, ... — treat Opps of misc. record types as outright-donation contexts)
    ↓
(all branches converge)
Screen_Offer_Close (visibility: outCommitmentId IS NOT BLANK — outright branch has no GC, skips this)
    "Also close this Opportunity as 'Closed Won'?" [Yes / No radio]
    ↓
Decide_Close
    ├─ Yes → Update_Opportunity (StageName='Closed Won')
    │           ↓ (fault → Err_Close_Failed but keep the created GC/GT — surface a warning, not a rollback)
    │       Screen_Success (mentions Opp is closed)
    │
    └─ No  → Screen_Success (mentions Opp left open)
```

**Amount reconciliation:** the subflow's Pledge Details screen shows the Opp Amount as the default but lets the user override. **We do NOT auto-copy the final GC.ExpectedTotalCmtAmount back to Opp.Amount** — that's out of scope for this pass (would require another user decision on whether the Opp's Amount represents forecasted revenue vs. committed amount, which is org-policy dependent). Add as a future extension bullet in §7.

**Quick action (per user 2026-08-02):**
- API name: `Opportunity.FQS_Pledge_Set_Up.quickAction-meta.xml`
- Label: **Pledge Set Up**
- `flowDefinition`: `FQS_Gift_Entry_Guide_Opportunity`
- Existing `Opportunity.FQS_Launch_Gift_Entry.quickAction` is **deleted** in Phase 5 (not repointed).
- Conditional visibility (Flexipage-level Dynamic Action — see §5.6):
  - Show when `Opportunity.IsClosed == false` (open Opps only — no point pledge-setting-up on a Closed Won / Closed Lost Opp)
  - AND `Opportunity.RecordType.DeveloperName` IN a supported set — for the initial ship, all record types are supported (Major_Gift, Grant, Donation, Fundraising, etc.); leave the visibility open on RecordType and let the flow's internal routing handle unsupported types with `Err_Unsupported_RecordType`. (Rationale: whitelisting RecordTypes in Flexipage means every new org RT breaks the button silently; better to let the flow tell the user.)

### 3.6 Element migration map (Account monolith → new suite)

The 24 top-level screens in the current Account launcher map as follows:

| Current screen | Target | Notes |
|---|---|---|
| `Screen_Block_Missing_Org_Default` | Universal parent | pre-flight, stays in parent (before subflow) |
| `Screen_Category` | Universal parent | menu screen — folds into `Screen_Universal_Entry` with donor lookup |
| `Screen_Confirm_Designation` | Sub_Commitment + Sub_Outright + Sub_PledgePayment (identical logic; hand-copy into each and confirm parity in UAT) |
| `Screen_Confirm_Past_Payments` | Sub_Commitment (past-payment ledger for retroactive pledges) |
| `Screen_Confirm_Pledge_Payment_Update` | Sub_PledgePayment |
| `Screen_Existing_GTs` | Sub_PledgePayment (past-due picker) |
| `Screen_Gift_Details` | Sub_Outright |
| `Screen_Pick_Campaign_Optional` | Sub_Commitment + Sub_Outright (both consume) — accepts `defaultCampaignId` input |
| `Screen_Pick_Campaign_Required` | Sub_Commitment |
| `Screen_Pick_Commitment` | Sub_PledgePayment |
| `Screen_Pick_Designation` | Sub_Commitment + Sub_Outright + Sub_PledgePayment |
| `Screen_Pick_Match_Employer` | Sub_Outright + Sub_PledgePayment (employer match applies to both) |
| `Screen_Pick_Restriction` | Sub_Commitment (only pledges/grants ask for restriction) |
| `Screen_Pick_SoftCredit` | Sub_Outright + Sub_PledgePayment |
| `Screen_Pick_SoftCredit_Commitment` | Sub_Commitment |
| `Screen_Pledge_Details` | Sub_Commitment |
| `Screen_Recurring_Details` | Sub_Commitment |
| `Screen_Scheduled_Details` | Sub_Commitment |
| `Screen_Set_Match_Amount` | Sub_Outright + Sub_PledgePayment |
| `Screen_SoftCredit_Amount` | Sub_Outright + Sub_PledgePayment + Sub_Commitment (GDSC-driven GSC fanout too) |
| `Screen_Success` | Each parent has its own (surface-specific copy + surface-specific next-step link) |
| `Screen_Warning_Amount_Mismatch` | Sub_Commitment (Custom-branch row-sum vs. Total mismatch) |
| `Screen_Warning_Match_Max_Exceeded` | Sub_Outright + Sub_PledgePayment |

---

## 4. Implementation phases

### Phase 1 — Sub_PledgePayment (net-new subflow, smallest, exercises the pattern)

Ship the PledgePayment subflow first because (a) it's the smallest (~1,500 lines), (b) it's net-new so there's no monolith-parity concern, (c) it's the sole leaf the GC parent needs, and (d) shipping it end-to-end proves the subflow-invocation pattern before extracting the harder subflows.

- **1a.** Draft `FQS_Gift_Entry_Guide_Sub_PledgePayment.flow-meta.xml` (Screen Flow, isInput=true for `donorId`/`donorName`/`commitmentId`/`defaultCampaignId`/`sourceContext`; isOutput=true for `outGiftTransactionId`/`outAmount`/`outCategory`)
- **1b.** Draft `FQS_Gift_Entry_Guide_GiftCommitment.flow-meta.xml` (Screen Flow, parent)
- **1c.** Draft `GiftCommitment.FQS_Pledge_Payment.quickAction-meta.xml` (label "Pledge Payment", flow `FQS_Gift_Entry_Guide_GiftCommitment`) AND author the Flexipage `<visibilityRule>` for the GC record page — Status='Active' AND Category IN ('Pledged Gift','Grant Payout'). Include the Flexipage delta in the same deploy.
- **1d.** Deploy + UAT: launch from a Pledged Gift GC → confirm the guide runs, GT is created with `GiftCommitmentId` correctly stamped, designations cascade from GDD, employer-match happy path.
- **1e.** Add to release-readiness tracker.

**Success criteria:** GC launcher works end-to-end; the pattern of "thin parent + Screen-Flow subflow" is validated.

### Phase 2 — Sub_Outright (moderate difficulty, isolates single-DML shape)

- **2a.** Extract Sub_Outright from the current monolith's Outright / In-Kind / Earned Income / Event Registration branches. Draft as a standalone Screen Flow.
- **2b.** Draft a scaffold `FQS_Gift_Entry_Guide_Universal.flow-meta.xml` that ONLY handles the Outright category → confirms the Universal parent + Sub_Outright pair works end-to-end from an Account record (parked behind a temporary "Outright only" menu for UAT).
- **2c.** Deploy + UAT the 4 non-commitment leaves (Outright, In-Kind, Earned Income, Event Registration).
- **2d.** Add to release-readiness tracker.

**Success criteria:** Sub_Outright is UAT-green. Universal parent skeleton runs.

### Phase 3 — Sub_Commitment (largest, highest risk, most parity concerns)

- **3a.** Extract Sub_Commitment. This carries the majority of the monolith complexity (Custom GCS refactor, GDSC-to-GSC fanout, Expected-GT hand-authoring, multi-GCS fanout awareness per [[processgiftcommitment-multi-gcs-fanout]], past-payment confirmation, restriction routing).
- **3b.** Wire it into the Universal parent's Pledge/Grant/Recurring branches. Add donor-lookup gating on the first screen for the Home/utility variant.
- **3c.** Deploy + full-monolith UAT across all commitment-shape leaves.
- **3d.** Add to release-readiness tracker.

**Success criteria:** All 9 commitment-shape leaves (Simple / Custom / Scheduled Pledge / Scheduled Grant / Single Payment Pledge / Single Payment Grant / Recurring / Recurring w/ end date / Recurring w/ employer match) run through the subflow with parity vs. current Account launcher.

### Phase 4 — Universal parent finish + Home surface

- **4a.** Finalize the Universal parent's donor-lookup gating (first-screen conditional lookup).
- **4b.** Add the Universal flow to a Home-page Flexipage as a Flow component (or a Utility item — final decision at time of build; recommend Home component for its lower install ceremony).
- **4c.** Deploy + UAT from Home page (no `recordId`) and from Account record page (with `recordId`).
- **4d.** **Delete** `Account.FQS_Launch_Gift_Entry.quickAction-meta.xml`. **Add** `Account.FQS_Guided_Gift_Entry.quickAction-meta.xml` (label "Guided Gift Entry", flow `FQS_Gift_Entry_Guide_Universal`). Update `FQS_Account_Record_Page.flexipage-meta.xml` to reference the new API name AND author the `<visibilityRule>` (RecordType.DeveloperName IN Organization/PersonAccount).
- **4e.** Add to release-readiness tracker.

**Success criteria:** Both surfaces (Account record + Home page) launch the same flow. The monolith is now unused in production and can be scheduled for deletion.

### Phase 5 — Opportunity parent (thin wrapper + optional close)

- **5a.** Draft `FQS_Gift_Entry_Guide_Opportunity.flow-meta.xml`. Reuses Sub_Commitment (+ Sub_Outright for misc-RecordType Opps).
- **5b.** Add the `Screen_Offer_Close` + `Update_Opportunity` (StageName='Closed Won') branch, gated on the subflow returning `outCommitmentId IS NOT BLANK`.
- **5c.** **Delete** `Opportunity.FQS_Launch_Gift_Entry.quickAction-meta.xml`. **Add** `Opportunity.FQS_Pledge_Set_Up.quickAction-meta.xml` (label "Pledge Set Up", flow `FQS_Gift_Entry_Guide_Opportunity`). Update the Opportunity Flexipage to reference the new API name AND author the `<visibilityRule>` (IsClosed=false).
- **5d.** Deploy + UAT: Major_Gift Opp → pledge → decline close (Opp stays Open) → verify. Then Major_Gift Opp → pledge → accept close → verify Opp is Closed Won and GC exists. Then Grant Opp → grant payout → close → verify. Then Other-RecordType Opp → outright → verify no close prompt (outright branch skips).
- **5e.** Add to release-readiness tracker.

**Success criteria:** Opp launcher creates GCs + optionally closes Opps.

### Phase 6 — Cleanup + docs

- **6a.** Delete the three obsolete launcher files (`FQS_Gift_Entry_Single_Launcher_Account.flow-meta.xml`, `FQS_Gift_Entry_Single_Launcher_GiftCommitment.flow-meta.xml`, `FQS_Gift_Entry_Single_Launcher_Opportunity.flow-meta.xml`).
- **6b.** Update `docs/npc-automation-notes.md` + README with the new launcher suite architecture (four surfaces, three subflows, one entry pattern).
- **6c.** Retire `.planning/fqs-launcher-gate-a-refactor-plan.md` (superseded by this doc).
- **6d.** Final release-readiness update.

**Success criteria:** No dead monolith file; docs match reality.

---

## 5. Cross-cutting concerns

### 5.1 Subflow authoring gotchas (learned in earlier FQS work)

- **[[flow-screen-authoring-gotchas]]** — first-screen `<allowBack>`, formula screen-field refs, `flowruntime:lookup` needing 5 extra inputs for `.recordId`, `Get_Records` null-check via `.Id`. All apply inside each subflow.
- **[[flow-transform-self-reference-gotcha]]** — Custom-branch transform on `col_CustomGCSs` MUST NOT reference an element that hasn't executed yet. Preserve current ordering when copying into Sub_Commitment.
- **[[flow-unread-sobject-field-throws]]** — every SObject variable in a subflow must be null-init'd before any downstream `Assign_...` reads a field of it. Preserve current null-init assignments verbatim.
- **[[flow-datatable-source-authoring]]** — datatables can't be hand-authored at v65+. Current monolith has one on Past Due GTs — copy the Builder-emitted `complexValue` block verbatim to Sub_PledgePayment.
- **[[flowruntime-lookup-pattern]]** — the donor lookup on the first screen of Universal uses `<extensionName>flowruntime:lookup</extensionName>` with `objectApiName=Account`, `fieldApiName=AccountId` (activates lookup filters). Downstream refs use `<screenFieldName>.recordId`.
- **[[flow-radio-stores-choicetext]]** — radio decisions on `pkCategory` compare by `elementReference` in Decision rules, NOT by `<stringValue>` — silent `false` otherwise.

### 5.2 Description-quality rule (§2a)

Every element in every new flow follows the description-rewrite rule established for Gate A: junior-admin voice, no `.md`/`[[memory]]` refs, no "Phase [A-Z]" tokens, targets ≤400 chars. Do not carry forward developer-shorthand descriptions from the monolith; rewrite as they're copied.

### 5.3 Deploy discipline

Each phase's target flow(s) deploy in isolation (`sf project deploy start -m "Flow:<name>"`). Do NOT deploy `Flow:*` — that would drag in every other unrelated flow and risk collateral changes.

### 5.4 UAT record shopping

Each phase carves a small UAT record set:
- Phase 1 UAT: 1 Active Pledged Gift GC + 1 Active Grant Payout GC + 1 Closed GC (negative case)
- Phase 2 UAT: 1 Account with GDD + 1 Account with GDSC + 1 Account with an active Employer relationship (for match)
- Phase 3 UAT: cover Simple / Custom / Scheduled / Single Payment / Recurring shapes at least once each. Include a Custom shape with 3+ irregular rows to stress the multi-GCS fanout code path per [[processgiftcommitment-multi-gcs-fanout]].
- Phase 4 UAT: Home page + Account record page + logged-in as a low-priv Fundraiser (to catch FLS surprises).
- Phase 5 UAT: Major_Gift Opp + Grant Opp + Other-RT Opp; decline-close AND accept-close for each.

### 5.5 Rollback plan

Each phase's quick action swap (4d, 5c) is a **delete-and-add** rather than a repoint, per user 2026-08-02:
- Delete old: `Account.FQS_Launch_Gift_Entry.quickAction-meta.xml` (Phase 4) and `Opportunity.FQS_Launch_Gift_Entry.quickAction-meta.xml` (Phase 5).
- Add new: `Account.FQS_Guided_Gift_Entry.quickAction-meta.xml`, `Opportunity.FQS_Pledge_Set_Up.quickAction-meta.xml`, `GiftCommitment.FQS_Pledge_Payment.quickAction-meta.xml` (Phase 1 for the last one).
- Flexipage(s) referencing the old actions get updated in the same phase to reference the new API names.
- README documents the label change as a user-visible release note.

Rollback (if UAT fails): re-add the deleted `quickAction-meta.xml` from git history (`git show <sha>:path`), revert the Flexipage change, redeploy. The old monolith flow file is left in place through Phases 1–5; only in Phase 6 does it get deleted. Between Phase 1 and Phase 6, both flow suites coexist.

### 5.6 Dynamic Action / conditional visibility on quick actions

All three new quick actions carry **conditional visibility** rules per user 2026-08-02. In Salesforce metadata this is NOT part of the `quickAction-meta.xml` — it's set on the **Flexipage** that renders the action (`<flexiPageRegions>` → `<itemInstances>` → `<componentInstance>` with `<visibilityRule>`).

Practical implications:
- The `quickAction-meta.xml` files are minimal — just label, flow, target object, action type.
- The `<visibilityRule>` blocks are hand-authored into the Flexipages that host the actions (Account, Opportunity, GiftCommitment record pages). Salesforce's Dynamic Actions editor generates these; we hand-author them in XML for source discipline.
- Each rule is a set of AND'd `<criteria>` blocks with `<leftValue>{!Record.Field}</leftValue><operator>EQUAL</operator><rightValue>string</rightValue>` shape. Multiple values on the same field ("IN a set") = multiple rules OR'd via `<visibilityRule>` blocks with `<booleanFilter>1 OR 2</booleanFilter>` or by using `NOT_EQUAL` for the negative set.
- **Gotcha:** picklist fields in Flexipage `visibilityRule` compare by API value, not label. `Status = 'Active'` works because the value is "Active"; `FQS_Gift_Commitment_Category__c = 'Pledged Gift'` needs the exact value string. Double-check picklist API values before committing rules.
- **Gotcha:** RecordType comparisons in Flexipage visibility use `{!Record.RecordType.DeveloperName}`, NOT `{!Record.RecordTypeId}`. The ID form silently fails to match across sandboxes/orgs where IDs differ.
- **Testing:** UAT for each quick action MUST verify both the "should show" and "should hide" branches. A hidden action isn't a bug — a wrongly-visible action pointing at an unsupported record IS.

Per-action visibility rules are captured in §3.3, §3.4, §3.5.

---

## 6. Delayed / out-of-scope items (parked for later)

- **frops_flo integration for the GC launcher's original placeholder menu.** Close Gift Commitment, Get Gift Commitments, Manage Gift Commitment Schedule, Manage Gift Designations, Pause | Resume, Update Recurring Schedule — these are Fundraising Operations Managed-Package flows. This plan takes them OUT of the FQS unmanaged launcher. Recommend building a **separate future launcher** (`FQS_Gift_Commitment_Manage_Guide` or similar) that hosts those six routes as subflow calls into the managed package. That's a future workstream.
- **Opp.Amount ↔ GC.ExpectedTotalCmtAmount reconciliation** on close (§3.5).
- **"Donor not in system" new-Account creation** from the Home surface's donor lookup. Parked; user can still cancel out and use Salesforce's own New Account flow, then re-launch.
- **Utility Bar** surface variant (in addition to Home page component). Same flow, different Flexipage placement — a 5-minute add once Universal is UAT-green.
- **Sibling launcher parity** (Contact, Person Account, etc.) — beyond current scope; a Universal + donor-lookup approach may obviate the need entirely.

---

## 7. Open questions (nothing blocks Phase 1)

None blocking. Two nice-to-have decisions are on the docket:

1. **GC launcher name.** User said "may be a flow name though" — options:
   - `FQS_Gift_Entry_Guide_GiftCommitment` (matches suite naming — recommended)
   - `FQS_Gift_Entry_Guide_Pledge_Payment` (describes what it does — user-friendly but less obviously a member of the launcher suite)
   - `FQS_Gift_Entry_Guide_From_Commitment` (mirrors "From X" phrasing that some Salesforce admins prefer)
   - Recommend option 1 for grep-ability; option 2 for user-facing clarity.

2. **Home-surface implementation** — Flexipage Flow component vs. Utility item vs. dedicated App Page. Recommend Flexipage Flow component on the standard Home page for the first ship; add Utility Bar entry after UAT.

Both can be resolved during Phase 1 without blocking Phase 1 itself.

---

## 8. Success criteria (whole plan)

- Four working entry surfaces: Home page, Account record page, GiftCommitment record page, Opportunity record page — all launch a flow named `FQS_Gift_Entry_Guide_*`.
- All 12 monetary leaves supported: Outright / In-Kind / Earned Income / Event Registration / Pledge Payment / Simple Pledge / Custom Pledge / Scheduled Pledge / Scheduled Grant / Single Payment Pledge / Single Payment Grant / Recurring Gift.
- Zero regression against the current Account launcher's UAT harness.
- Monolith deleted, docs updated, release-readiness tracker reflects the new architecture.
- Net-line-count delta: current 12,096 + 302 + 380 = **12,778 lines across 3 monoliths** → target **~1,500 + 250 + 600 + 6,000 + 2,500 + 2,000 = ~12,850 across 6 files**. Roughly line-neutral overall, but each individual file is now humanly reviewable and independently deployable.
