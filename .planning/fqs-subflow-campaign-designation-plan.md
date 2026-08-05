# FQS — Campaign + Designation Resolver subflow extraction plan

**User-answered open questions (2026-08-05):**
1. Override branch **moves INTO the subflow** (Pick_Restriction + Pick_Designation + lookup escape hatch + Assign_UserOverride). Original plan had these staying in monolith with a `"OverrideRequested"` re-entry — that was wrong. Cleaner topology: subflow owns the full Override chain, exits at `Decide_After_Designation` with `out_resolvedPath="Accepted"` regardless of tier (Campaign/GC/Org/Split/UserOverride).
2. Legacy R3 chain — **retire in a separate ticket.** The functionality is replaced by the resolver hierarchy already: `Resolve_Designation_Hierarchy` covers Campaign_Default (Tier 3) explicitly; `Decide_Route_Outright_To_Resolver`'s 8 rules cover every live leaf; the default connector at line 5271 is currently unreachable scaffolding. Separate cleanup ticket needed to retire `Decide_Restriction_Path` + `Decide_Commitment_Has_Default_Designation` + `Get_Commitment_Default_Designation` + `Assign_Restriction_Unrestricted/_EarnedIncome/_From_Commitment` + `Decide_Campaign_Provides_Designation` + `Assign_Designation_From_Campaign` + `Get_Campaign_Default_Designation_Detail`. Plan for that ticket: `.planning/fqs-legacy-r3-chain-retirement-plan.md` — not authored yet.
3. Visibility rules **cannot reference subflow-local vars** — must be passed in as inputs / out as outputs. Confirmed: subflow needs its own local declarations of every var the moving elements read, and the monolith needs the output-back for any downstream reader.
4. Naming — **`FQS_Gift_Entry_Subflow_Campaign_Designation_Resolver`** (Campaign is included, so the name reflects that).

**Target:** extract Campaign pick/lookup + Designation resolver chain from `FQS_Gift_Entry_Single_Launcher_Account` into a monolith-only subflow.

**Purpose:** collapse ~30 canvas nodes into a single subflow-call node on the main canvas. Total-system element count is unchanged (elements relocate); the win is main-canvas visualization. Per user feedback 2026-08-04: "worried we aren't going to make a real dent in flow elements any longer... look at removing long strings of elements for subflows... will at the very least make the main flow easier to visualize."

**Scope reference:** `.planning/fqs-launcher-refactor-c4-and-phase-d-research.md` candidate #2 (expanded to "bundle Campaign lookup+confirm + Designation resolver" per user decision 2026-08-05).

**Reuse scope:** monolith-only per user decision 2026-08-05. Input contract designed for `FQS_Gift_Entry_Single_Launcher_Account` variables only; purposeful launchers (Home/Account/Opportunity) do not call this subflow. Can be generalized later once the shape stabilizes.

---

## Terminology corrections vs. research doc

The research doc contained two labels that don't exist in the current flow — recon confirmed the actual state:

| Research-doc label | Actual state | Impact |
|---|---|---|
| "Confirm_Campaign screen" | Does not exist. Campaign screens are `Pick_Campaign` (required) + `Pick_CampaignOptional`. | Bundle absorbs the pick-screen + escape-hatch lookup elements, not a confirm screen. |
| "2 counting loops" (`Loop_Count_Campaign_GDDs`, `Loop_Count_GC_GDDs`) | Already retired. They are `<operator>AssignCount</operator>` assignments: `Count_Campaign_GDDs`, `Count_GC_GDDs`. | Plan speaks of "2 count assignments" not "2 loops." Element-count savings on the Loop→AssignCount conversion already landed. |

---

## Elements that move into the subflow

### Screens (5)
| Element | Line range | Notes |
|---|---|---|
| `Pick_Campaign` (required) | 9971–10172 | Datatable binds `firstSelectedRow` → subflow-local SObject var (renamed inside subflow). Escape-hatch: `chkUseCampaignLookup` + `lkpCampaign` (`flowruntime:lookup`, Opportunity + AccountId per `[[flow-lookup-objectapi-fieldapi]]`). |
| `Pick_CampaignOptional` | 10247–10448 | Same shape; distinguished by `firstSelectedRow` binding. |
| `Confirm_Designation` | 7742–7844 | Renders `formulaResolvedDesignationSummary`, `formulaSplitSource`, `formulaSplitCount`. Screen field `chkOverrideDesignation` (Boolean) drives the exit branch. |
| `Pick_Restriction` | 11045–11094 | Override-branch restriction-type picker. Radio `pkRestrictionType` (subflow-local), populated by 4 `Choice_Restriction_*` choices. Connector → `Assign_Restriction_From_Screen`. |
| `Pick_Designation` | 10651–10852 | Override-branch designation picker. Datatable `dtDesignations` (source `Get_Filtered_Designations`, `firstSelectedRow` → `rsv_SelectedDesignation`), escape-hatch `chkUseDesignationLookup` + `lkpDesignation` (`flowruntime:lookup`). `DesignationHelp` merge-field reads `var_RestrictionType`. Connector → `Decide_Use_Designation_Lookup`. |

### Decisions (12)
| Element | Line | Role |
|---|---|---|
| `Decide_Use_Campaign_Lookup` | 5724–5749 | Routes `Pick_Campaign` exit — table vs. lookup escape hatch. |
| `Decide_Use_Campaign_Lookup_Optional` | 5750–5775 | Same for `Pick_CampaignOptional`. |
| `Decide_Route_Outright_To_Resolver` | 5265–5409 | 8-rule leaf-type gate — resolver entry. |
| `Decide_Set_PlatformSplit_From_Campaign` | 5436–5461 | Reads `var_CampaignGDDCount > 1`. |
| `Decide_Set_PlatformSplit_From_GC` | 5462–5487 | Reads `var_GCGDDCount > 1`. |
| `Decide_GC_Has_Default_Designation` | 4402–4428 | Reads `Get_GC_Default_Designation_For_Resolver.Id IsNull=false`. |
| `Resolve_Designation_Hierarchy` | 5880–5935 | The core 3-tier hierarchy decision (PlatformSplit / GCDefault / CampaignDefault → Org default). |
| `Decide_Resolver_Has_Org_Default` | 5147–5172 | Terminal fork: found Org default vs. `MissingOrgDefault` output. |
| `Decide_Skip_Confirm_On_Update` | 5606–5639 | PP-update-branch fast-exit skip of `Confirm_Designation`. |
| `Decide_Override_Designation` | 4976–5000 | Confirm_Designation exit branch. Default → subflow-exit "Accepted"; rule → `Decide_Override_Needs_Restriction`. |
| `Decide_Override_Needs_Restriction` | 5001–5040 | Reads `varLeafFutureEffective` + `pkLeafMonetary` (subflow inputs). Rule (commitment-creation leaves: Simple / Scheduled / Recurring) → `Pick_Restriction`; default → `Pick_Designation`. |
| `Decide_Use_Designation_Lookup` | 5802–5827 | Reads `chkUseDesignationLookup` (subflow-local, Pick_Designation auto-var). Rule → `Get_Looked_Up_Designation`; default → `Assign_Resolve_Designation_UserOverride`. |

### Assignments (14)
| Element | Line | Role |
|---|---|---|
| `Assign_Campaign_From_Lookup` | 486–501 | Escape-hatch table→SObject assign. **Rewrite in subflow** to avoid `[[flow-sobject-assign-drops-fields]]`: use `<outputReference>` on `Get_Looked_Up_Campaign` with explicit `<queriedFields>` for every field the downstream chain reads. |
| `Assign_Campaign_From_Lookup_Optional` | 502–518 | Same as above for Optional variant. |
| `Assign_Resolve_Designation_CampaignDefault` | 2224–2254 | Writes `var_ResolvedDesignationId`, `var_ResolvedDesignationSource='Campaign_Default'`. |
| `Assign_Resolve_Designation_GCDefault` | 2255–2286 | Same for `GC_Default`. |
| `Assign_Resolve_Designation_OrgDefault` | 2287–2318 | Same for `Org_Default`. |
| `Assign_Resolve_Designation_PlatformSplit` | 2319–2335 | Writes `var_ResolvedDesignationSource='Platform_Split'` — does NOT write Id (platform will fan out post-Create). |
| `Assign_Resolve_Designation_UserOverride` | 2336–2359 | Now moves INTO subflow. Reads `rsv_SelectedDesignation.Id`, writes `var_ResolvedDesignationId` + `var_ResolvedDesignationSource='User_Override'`. Connector → subflow-exit "Accepted". |
| `Assign_ResolverHasGCDefault_True` | 2360–2377 | Subflow-local Boolean. |
| `Assign_Restriction_From_Screen` | 2412–2427 | Reads `pkRestrictionType` (subflow-local, Pick_Restriction auto-var), writes `var_RestrictionType`. Connector → `Get_Filtered_Designations`. |
| `Assign_Designation_From_Lookup` | 1097–1113 | Reads `Get_Looked_Up_Designation` (subflow-local), writes `rsv_SelectedDesignation`. **Refactor at extraction:** convert to `<outputReference>` on `Get_Looked_Up_Designation` per [[flow-sobject-assign-drops-fields]] and delete this Assign. Connector was → `Assign_Resolve_Designation_UserOverride`; after refactor the lookup's success connector goes there directly. |
| `Assign_Set_PlatformSplitApplies_True_Campaign` | 2630–2646 | Sets `var_PlatformSplitApplies=true` on Campaign multi-GDD branch. |
| `Assign_Set_PlatformSplitApplies_True_GC` | 2647–2664 | Same on GC multi-GDD branch. |
| `Count_Campaign_GDDs` | 2968–2984 | `AssignCount(Get_Campaign_GDDs_Multi)` → `var_CampaignGDDCount`. |
| `Count_GC_GDDs` | 2985–3001 | `AssignCount(Get_GC_GDDs_Multi)` → `var_GCGDDCount`. |

### Record Lookups (10)
| Element | Line | Refactor at extraction |
|---|---|---|
| `Get_Looked_Up_Campaign` | 7390–7414 | **Convert to `<outputReference>` pattern per C4 research** — replace `<storeOutputAutomatically>true</storeOutputAutomatically>` with `<outputReference>subflow_rsv_Campaign</outputReference>` + explicit `<queriedFields>`. Deletes `Assign_Campaign_From_Lookup`. |
| `Get_Looked_Up_Campaign_Optional` | 7415–7440 | Same pattern; deletes `Assign_Campaign_From_Lookup_Optional`. |
| `Get_Campaign_Default_Designations` | 6873–6905 | Single-row lookup; `storeOutputAutomatically`. |
| `Get_Campaign_GDDs_Multi` | 6932–6964 | Multi-row lookup; consumed by `Count_Campaign_GDDs`. |
| `Get_GC_Default_Designation_For_Resolver` | 7273–7305 | Single-row lookup on `rsv_SelectedCommitment.Id`. |
| `Get_GC_GDDs_Multi` | 7332–7364 | Multi-row lookup; consumed by `Count_GC_GDDs`. |
| `Get_Org_Default_Designation` | 7581–7612 | Single-row `IsActive=true AND IsDefault=true` on GiftDesignation. |
| `Get_Resolved_GD` | 7655–7680 | Final lookup by `var_ResolvedDesignationId`. Feeds `Confirm_Designation` summary formula. |
| `Get_Filtered_Designations` | 7240–7272 | Override-branch. Filter reads `var_RestrictionType` (subflow-local); auto-stored collection feeds `Pick_Designation`'s datatable. Fault → subflow-local `Error_CouldNotLoadData` (see §Error handling below). |
| `Get_Looked_Up_Designation` | 7467–7491 | Override-branch escape-hatch. Reads `lkpDesignation.recordId` (subflow-local, Pick_Designation auto-var). **Convert to `<outputReference>rsv_SelectedDesignation</outputReference>` + explicit `<queriedFields>`** so `Assign_Designation_From_Lookup` can be deleted. |

### Formulas (3)
| Formula | Line | Where used |
|---|---|---|
| `formulaResolvedDesignationSummary` | 6120–6125 | `Confirm_Designation` summary field. Reads `Get_Resolved_GD.Name`, `var_ResolvedDesignationSource`. |
| `formulaSplitCount` | 6211–6216 | `Confirm_Designation` split-count field. Reads `var_CampaignGDDCount`, `var_GCGDDCount`. |
| `formulaSplitSource` | 6224–6229 | `Confirm_Designation` split-source field. Reads `var_GCGDDCount`. |

Excluded — stays in monolith:
- `formulaSplitGTDAmount` (6217–6223) — consumed by `Assign_Build_Split_GTD_Campaign` and `Assign_Build_Split_GTD_GC`, both outside the resolver chain. Must remain a monolith formula.

### Variables — subflow-locals (fresh declarations inside subflow)
- `var_CampaignGDDCount` — no external readers once `formulaSplitCount` + `formulaSplitSource` move in.
- `var_ResolverHasGCDefault` — no external readers.
- `var_RestrictionType` — every reader inside moving set (`Get_Filtered_Designations` filter + `Pick_Designation.DesignationHelp` merge-field). Note: 3 legacy monolith writers (`Assign_Restriction_Unrestricted`/`_EarnedIncome`/`_From_Commitment`) also write it, but they're on the dead R3 chain — retire in the separate legacy-cleanup ticket. Until that ticket lands, keep the monolith declaration too; subflow's is a separate variable of the same name.
- `pkRestrictionType` — Pick_Restriction screen auto-var (subflow-local by definition).
- `chkOverrideDesignation` — Confirm_Designation screen auto-var (subflow-local).
- `chkUseDesignationLookup` / `dtDesignations` / `lkpDesignation` — Pick_Designation screen auto-vars.
- `chkUseCampaignLookup` / `chkUseCampaignLookupOpt` / `lkpCampaign` / `lkpCampaignOpt` / `dtCampaigns` / `dtCampaignsOpt` — Pick_Campaign(Optional) screen auto-vars.

### Variables — subflow OUTPUTS (with external monolith readers)
- `var_ResolvedDesignationId` — 3 external readers: `Assign_GC_GDD_Update_Fields` (1633), `Decide_GC_GDD_Post_Process` (4360, 4393). Populated by 5 tiers (Campaign/GC/Org/Split/UserOverride) — now ALL inside subflow.
- `var_PlatformSplitApplies` — 3 external readers: `Decide_Create_Designation` (4005), `Decide_GC_GDD_Post_Process` (4346, 4376).
- `var_GCGDDCount` — 1 external reader: `Decide_Split_Source_For_Fanout_IsGC` (5679).
- `rsv_SelectedDesignation` — SObject output. 5 external readers all read `.Id`: `Assign_Build_Default_Designation` (184), `Assign_Build_GTDesignation` (304), `Assign_Employer_Recurring_GDD` (1405), `Decide_Create_Default_Designation` (3979), `Decide_Create_Designation` (4020). Output the full SObject with `<queriedFields>Id</queriedFields>` at minimum; add `Name` if any downstream display needs it (none identified).
- `var_ResolvedDesignationSource` — no external monolith readers if `formulaResolvedDesignationSummary` moves with `Confirm_Designation` (it does). Could stay subflow-local, but export it anyway for potential future consumers (cheap).

### Choices (subflow-local)
- `Choice_Restriction_Without`, `Choice_Restriction_Purpose`, `Choice_Restriction_Time`, `Choice_Restriction_Permanent` — only readers are `Pick_Restriction.pkRestrictionType.choiceReferences`.
- `Choice_Leaf_SimplePledgeGrant`, `Choice_Leaf_ScheduledPledgeGrant`, `Choice_Leaf_RecurringGift` — referenced by `Decide_Override_Needs_Restriction`. **Also read by monolith** (`Decide_Route_Outright_To_Resolver`, `Decide_After_Designation`, etc.) so these choices must be DUPLICATED per-flow (choice records don't cross flow boundaries).
- `var_GCGDDCount` — 1 external reader: `Decide_Split_Source_For_Fanout_IsGC` (5679). Must be output; can't collapse to subflow-local.

### Choices (kept)
Choice_Leaf_* elements (Outright, InKind, EarnedIncome, EventRegistration, SimplePledgeGrant, ScheduledPledgeGrant, PledgePayment, RecurringGift, PledgePayment_Update) — read by `Decide_Route_Outright_To_Resolver`. Choices are inline `<choices>` definitions per flow, so the subflow needs its own copies. Alternative: monolith projects `pkLeafMonetary` / `pkLeafSpecial` / `varLeafFutureEffective` to plain string values before subflow call, subflow compares strings. **Chosen: pass strings.** Screen auto-vars must be projected anyway per `[[flow-screen-autovar-subflow-input]]`.

---

## Subflow: `FQS_Gift_Entry_Subflow_Campaign_Designation_Resolver`

### Input contract (`isInput=true`)

| Input variable | Type | Notes |
|---|---|---|
| `in_leafMonetary` | String | Projected from monolith `pkLeafMonetary` (Screen_Category / Screen_Gift_Details screen auto-var → real var). Read by `Decide_Route_Outright_To_Resolver` + `Decide_Override_Needs_Restriction`. |
| `in_leafSpecial` | String | Projected from `pkLeafSpecial`. Read by `Decide_Route_Outright_To_Resolver`. |
| `in_leafFutureEffective` | String | Already a real var — `varLeafFutureEffective`. Read by `Decide_Route_Outright_To_Resolver` + `Decide_Override_Needs_Restriction`. |
| `in_pledgePaymentMode` | String | Projected from `pkPledgePaymentMode`. Read by `Decide_Skip_Confirm_On_Update`. |
| `in_contextCommitmentId` | String (nullable) | Plain scalar. Read by `Decide_Route_Outright_To_Resolver_IsPledgePayment`. |
| `in_selectedCommitmentId` | String (nullable) | Passed as scalar per `[[flow-unread-sobject-field-throws]]`. Filter operand on `Get_GC_Default_Designation_For_Resolver` + `Get_GC_GDDs_Multi`. |
| `in_selectedGTId` | String (nullable) | Passed as scalar. Populated on PP-Update branch only. Read by `Decide_Skip_Confirm_On_Update`. |
| `in_selectedCampaignIdSeed` | String (nullable) | Populated when caller entered via a screen that pre-selected a Campaign (e.g., commitment-context path). If populated, subflow can skip `Pick_Campaign` and stamp `subflow_rsv_Campaign.Id` directly. |

**Screen-field autovar projection layer** — monolith adds one `<assignments>` element `Assign_Resolver_Inputs` immediately upstream of the subflow call, mapping every `pk*` / `chk*` screen auto-var used by the subflow into a real Flow variable. This is the mandatory bridge per `[[flow-screen-autovar-subflow-input]]`. Screen auto-vars to project: `pkLeafMonetary`, `pkLeafSpecial`, `pkPledgePaymentMode`.

### Output contract (`isOutput=true`)

| Output variable | Type | Populated when |
|---|---|---|
| `out_resolvedPath` | String | Always. Values: `"Accepted"` / `"MissingOrgDefault"`. Because the Override branch now lives inside the subflow, there is no `"OverrideRequested"` return — an override just resolves to `"Accepted"` with `out_resolvedDesignationSource='User_Override'`. |
| `out_resolvedDesignationId` | String | Populated on `Accepted` — written by whichever of the 5 tier-terminals fires (Campaign / GC / Org / Split / UserOverride). |
| `out_resolvedDesignationSource` | String | Same. Values: `Campaign_Default` / `GC_Default` / `Org_Default` / `Platform_Split` / `User_Override`. |
| `out_platformSplitApplies` | Boolean | Populated always. False by default. |
| `out_gcGDDCount` | Number | Populated always. 0 by default. Needed by `Decide_Split_Source_For_Fanout` in monolith. |
| `out_selectedCampaignId` | String | Populated when the subflow's Pick_Campaign(Optional) screens ran (or when `in_selectedCampaignIdSeed` was populated and passed through). Monolith reads this and assigns `rsv_SelectedCampaign.Id` via a 1-line assign after subflow returns. |
| `out_selectedDesignation` | SObject (GiftDesignation) | Populated on `Accepted`. Full SObject with `<queriedFields>Id</queriedFields>`. Consumed by 5 monolith elements that read `rsv_SelectedDesignation.Id`. Written internally by whichever tier-terminal fires (Campaign/GC/Org tier-terminals stamp `rsv_SelectedDesignation.Id` from `Get_Resolved_GD`; UserOverride stamp is a passthrough of whatever `Pick_Designation` selected). |

### Subflow-local variables (chain scratch)

- `subflow_rsv_Campaign` (SObject Campaign) — populated by `<outputReference>` on `Get_Looked_Up_Campaign(_Optional)` or by `Pick_Campaign(Optional)` datatable's `firstSelectedRow`.
- `subflow_var_CampaignGDDCount` (Number).
- `subflow_var_ResolverHasGCDefault` (Boolean).
- `subflow_var_RestrictionType` (String) — populated by `Assign_Restriction_From_Screen`; consumed by `Get_Filtered_Designations` + `Pick_Designation.DesignationHelp` merge field.
- `subflow_rsv_SelectedDesignation` (SObject GiftDesignation) — populated by whichever tier-terminal fires. Marked `isOutput=true` (exports as `out_selectedDesignation`).

### Path preservation contract

Original monolith exit paths from the chain (now all handled inside subflow):
1. **Accept (unchecked override on Confirm_Designation)** — tier resolved (Campaign / GC / Org / Split). Subflow returns `"Accepted"`.
2. **PP-Update skip-confirm path** — `Decide_Skip_Confirm_On_Update` short-circuits past `Confirm_Designation`. Subflow returns `"Accepted"`.
3. **Override checked** — `Decide_Override_Needs_Restriction` → `Pick_Restriction` (commitment-creation leaves) or `Pick_Designation` (payment/special leaves) → `Assign_Resolve_Designation_UserOverride` → subflow returns `"Accepted"` with `out_resolvedDesignationSource='User_Override'`.
4. **Missing org default** — subflow returns `"MissingOrgDefault"`; monolith routes to `Error_MissingDefaultDesignation` terminal Finish.

Subflow return mapping:
| `out_resolvedPath` | Monolith next element |
|---|---|
| `"Accepted"` | `Decide_After_Designation` (unchanged) |
| `"MissingOrgDefault"` | `Error_MissingDefaultDesignation` |

Monolith adds a `Decide_Resolver_Return_Router` decision immediately after the subflow call to fan out these 2 branches. This decision replaces the current implicit routing that lived inside the chain.

**Do NOT let the subflow reach `Error_MissingDefaultDesignation` internally** — Finish screens inside a subflow end the entire interview. Subflow returns `"MissingOrgDefault"` status instead; monolith owns the terminal Finish screen.

### Error-screen boundary (`Get_Filtered_Designations` + `Get_Looked_Up_Designation` faults)

Two Override-branch lookups can fault. In the monolith they route to the shared `Error_CouldNotLoadData` terminal Finish screen (20+ inbound fault connectors from all over the flow). Since Finish screens can't cross flow boundaries, the subflow needs its own handling.

**Chosen shape (parallel to sibling employer-match plan's Shape B):** subflow declares an internal `Assign_DidError_True` element on each fault path, populates `out_didError=true` + `out_errorMessage`, then routes to the subflow's `Finish` (no local Error screen — just a plain finish). Monolith inspects `out_didError` after the subflow call and routes to its own `Error_CouldNotLoadData` when true.

**New outputs to add:**
- `out_didError` (Boolean) — true when any subflow fault path fired.
- `out_errorMessage` (String) — populated when `out_didError=true`.

### DML boundaries

Subflow does **NO DML**. Resolver chain is entirely lookup + assign + decision + screen. The only SObject the subflow touches is `subflow_rsv_Campaign` (via `<outputReference>` on lookup, not DML), `subflow_rsv_SelectedDesignation` (via `<outputReference>` on `Get_Looked_Up_Designation` and stamped Id from tier-terminals), and the read-only `Get_Resolved_GD` / `Get_Filtered_Designations`.

### Field-drop mitigations (per `[[flow-sobject-assign-drops-fields]]`)

Every SObject assignment in the current chain uses the `Assign` operator with an SObject-typed value (both `Assign_Campaign_From_Lookup*` do this). At extraction:
- `Get_Looked_Up_Campaign(_Optional)` converts to `<outputReference>subflow_rsv_Campaign</outputReference>` with explicit `<queriedFields>` for every field the downstream chain reads. Fields required: `Id`, `Name`, plus any field the caller monolith reads on `rsv_SelectedCampaign.<field>` downstream of the subflow call (the current downstream reads only `.Id`, so `<queriedFields>Id</queriedFields>` + `<queriedFields>Name</queriedFields>` for display is sufficient).
- The two `Assign_Campaign_From_Lookup*` elements delete outright.

---

## Monolith changes required to consume the subflow

### New elements (monolith)
- `Assign_Resolver_Inputs` — assignments block projecting 3 screen auto-vars (`pkLeafMonetary`, `pkLeafSpecial`, `pkPledgePaymentMode`) to real Flow vars.
- `Subflow_Call_Campaign_Designation_Resolver` — `<subflows>` element invoking the subflow with the 8-input / 8-output contract.
- `Decide_Resolver_Return_Router` — 2-branch decision on `out_resolvedPath` (`Accepted` / `MissingOrgDefault`) + a preceding didError check.
- `Decide_Resolver_DidError` — checks `out_didError`; true → `Error_CouldNotLoadData`; false → `Decide_Resolver_Return_Router`.
- `Assign_Selected_Campaign_From_Subflow` — 1-line assign `rsv_SelectedCampaign.Id ← out_selectedCampaignId` on the Accepted branch (skip on MissingOrgDefault / error).
- `Assign_Selected_Designation_From_Subflow` — 1-line assign `rsv_SelectedDesignation ← out_selectedDesignation` (SObject-to-SObject; since we're using `<outputReference>` on the subflow side with explicit `<queriedFields>`, this assign is safe from `[[flow-sobject-assign-drops-fields]]`).

### Deleted elements (monolith)
All elements listed in "Elements that move" above (5 screens + 12 decisions + 14 assignments + 10 lookups + 3 formulas + var_RestrictionType if paired with legacy-R3 retirement) PLUS `Error_MissingDefaultDesignation` connectivity rerouted (screen itself stays as a target).

### Preserved external readers
- `Decide_Split_Source_For_Fanout_IsGC` (5679) — now reads `out_gcGDDCount` (subflow output copied to `var_GCGDDCount` via output-var mapping).
- `Decide_GC_GDD_Post_Process` (4346/4360/4376/4393) — reads `var_PlatformSplitApplies` and `var_ResolvedDesignationId` (both output-mapped from subflow).
- `Decide_Create_Designation_IsPlatformSplit` (4005) — reads `var_PlatformSplitApplies`.
- `Assign_GC_GDD_Update_Fields` (1633) — reads `var_ResolvedDesignationId`.
- `Assign_Build_Default_Designation` (184), `Assign_Build_GTDesignation` (304), `Assign_Employer_Recurring_GDD` (1405), `Decide_Create_Default_Designation` (3979), `Decide_Create_Designation` (4020) — all read `rsv_SelectedDesignation.Id`, populated by `Assign_Selected_Designation_From_Subflow`.

---

## Deploy sequence

1. **Author subflow** — create `force-app/main/default/flows/FQS_Gift_Entry_Subflow_Designation_Resolver.flow-meta.xml` v67 Screen Flow, all moved elements + input/output vars.
2. **Deploy subflow standalone** — no monolith changes yet. Verify it deploys cleanly to `FundFirst`. Standalone won't be runnable end-to-end (needs a caller), but the deploy validates the XML shape.
3. **Refactor monolith** — delete moved elements, add the 4 new caller-side elements (`Assign_Resolver_Inputs`, `Subflow_Call_Designation_Resolver`, `Decide_Resolver_Return_Router`, `Assign_Selected_Campaign_From_Subflow`, `Assign_Selected_Designation_From_Subflow`).
4. **Deploy monolith** — must be a single atomic deploy (subflow already in place).
5. **9-leaf regression** — same regression suite as Wizard Phase G. Every leaf must exercise the resolver path once; specifically test the `MissingOrgDefault` path (deactivate the org-wide-default GD before running one leaf, expect the terminal Finish screen).
6. **Rollback plan** — subflow can be deactivated; monolith rollback requires re-adding the deleted elements. Keep a copy of the pre-refactor monolith XML in `.planning/archive/monolith-pre-resolver-subflow.flow-meta.xml.bak` for one commit's worth of insurance.

---

## Risk table

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Screen auto-var input trap | High if unprepared | Runtime "field hasn't been set" or silent zero | `Assign_Resolver_Inputs` projection layer + [[flow-screen-autovar-subflow-input]] as the guardrail memory. |
| SObject field-drop on Campaign lookup return | Medium | Silent zero on downstream `.Name` reads | `<outputReference>` pattern with explicit `<queriedFields>` per [[flow-sobject-assign-drops-fields]]. |
| Subflow reaches `Error_MissingDefaultDesignation` and ends the whole interview | Low if plan followed | Terminal Finish where a subflow return was intended | Return `"MissingOrgDefault"` status string; keep the Error screen in the monolith. |
| Legacy R3 chain (`Get_Campaign_Default_Designation_Detail` + `Assign_Designation_From_Campaign`) still reachable | Low — 8 rules cover all live leaves | Old chain still deployable, just unreachable | Leave in place at this refactor. Retire in a separate cleanup PR. |
| Override path re-entry loop | Medium | Confusing subflow contract | Keep `Assign_Resolve_Designation_UserOverride` in monolith. Subflow does NOT own the override path; it returns `"OverrideRequested"` and monolith does the rest. |
| Choice_Leaf_* not shared across flows | Medium | Subflow duplicates Choice elements | Pass leaf types as string inputs instead of Choice references. Subflow decisions compare on string values. |

---

## Estimated element movement

**Monolith before:** ~250 elements (per research doc; may have drifted with 2026-08-05 Wizard Phase G ship).

**Elements moving into subflow:** 5 screens + 12 decisions + 14 assignments + 10 lookups + 3 formulas + 4 subflow-local choices + 5 variables (subflow-local) = **~53 elements** (variables, formulas, choices don't render on canvas; canvas nodes ≈ 41).

**Elements added to monolith:** 6 (Assign_Resolver_Inputs, Subflow_Call, Decide_Resolver_DidError, Decide_Resolver_Return_Router, Assign_Selected_Campaign_From_Subflow, Assign_Selected_Designation_From_Subflow).

**Net monolith reduction:** ~47 elements / ~36 canvas nodes.

**Total system:** +6 (subflow overhead: version, header, plus the 6 new caller elements) — element-count-neutral or slight-net-positive at system level. **Canvas readability win is the sole objective, per user framing.**

---

## Follow-on work spawned by this plan

### 1. Legacy R3 chain retirement — separate ticket

The R3 chain (`Get_Campaign_Default_Designation_Detail` + `Assign_Designation_From_Campaign` + `Decide_Campaign_Provides_Designation`, plus `Decide_Restriction_Path` + `Decide_Commitment_Has_Default_Designation` + `Get_Commitment_Default_Designation` + `Assign_Restriction_Unrestricted` / `_EarnedIncome` / `_From_Commitment`) is currently unreachable in every live leaf — `Decide_Route_Outright_To_Resolver`'s 8 rules exhaustively cover every combination of `pkLeafMonetary` / `pkLeafSpecial` / `varLeafFutureEffective` / `contextCommitmentId`. Its default connector at line 5271 is dead scaffolding.

**Function replacement (what the current flow does instead):**
- **Campaign-default designation lookup** (was R3's job) → now handled by `Resolve_Designation_Hierarchy` Tier 3 (Campaign_Default) inside the subflow. `Get_Campaign_Default_Designations` (single-row) returns the Campaign's default GD; the tier terminal `Assign_Resolve_Designation_CampaignDefault` stamps `rsv_SelectedDesignation.Id` from that lookup.
- **Restriction picker on payment/special leaves** (was reached via `Decide_Restriction_Path` for Pledge Payment Conditional / Earned Income / else-Unrestricted) → now Override-only, reached from `Decide_Override_Needs_Restriction` when the user checks the Override box on `Confirm_Designation` AND the leaf is commitment-creation. Payment/special leaves default to accepting the resolved default without seeing a Restriction picker.
- **Commitment default designation** (was reached via `Get_Commitment_Default_Designation` off `Decide_Restriction_Path.PledgePaymentConditional`) → now handled by `Get_GC_Default_Designation_For_Resolver` (Tier 2, GC_Default) with the same behavior but through the hierarchy.

**Plan file to author:** `.planning/fqs-legacy-r3-chain-retirement-plan.md` — will spec deletion of 7 elements + adversarial verification that all 8 `Decide_Route_Outright_To_Resolver` rules cover every leaf/context combination + regression sweep confirming default connector is unreachable. Ship AFTER this subflow extraction lands.

### 2. Confirm_Designation visibility rules need explicit outputs

Confirmed per user: Flow visibility rules **cannot** reference subflow-local vars from outside the subflow, and vice versa. Confirm_Designation's field-level visibility rules on `var_PlatformSplitApplies` (lines 7782, 7805, 7834) read the subflow-local copy correctly WHILE Confirm_Designation is being rendered inside the subflow (visibility is evaluated in the child flow's context at render time — this is fine). But the monolith's downstream reads of `var_PlatformSplitApplies` (Decide_Create_Designation at line 4005, Decide_GC_GDD_Post_Process at 4346/4376) require the subflow to output it. Same rule applies to `var_ResolvedDesignationId`, `var_GCGDDCount`, `rsv_SelectedDesignation`. Output contract above reflects this.

### 3. Suggested ship order for this subflow

1. Deploy subflow standalone (validate XML). No monolith changes yet.
2. Deploy monolith with subflow call + all deletions in a single atomic deploy.
3. Full 9-leaf regression + explicit Override-path regression on every leaf (both commitment-creation and payment/special leaves — the Restriction-picker branch must fire on Simple/Scheduled/Recurring and be skipped on Outright/PP/InKind/EarnedIncome/EventReg).
4. Explicit MissingOrgDefault path (deactivate all IsDefault GDs before running one leaf, expect the terminal Finish screen).
5. Explicit `didError` path (temporarily break a filter or lookup, expect monolith Error_CouldNotLoadData).
6. Legacy-R3-chain retirement plan and ticket (separate deploy).