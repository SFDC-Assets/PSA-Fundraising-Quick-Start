# FQS Launcher refactor — research asks for Phase C4 + Phase D

**Purpose.** Two research items I need before I can safely author XML for the next passes on `FQS_Gift_Entry_Single_Launcher_Account`. Each item includes a "why it matters" so you can judge whether the ask is worth answering vs deferring.

**Context recap (as of 2026-08-04):**
- Phase A shipped `0AfWB00000DnrdC0AR` — screen renames + dead-code cull.
- Phase B (narrowed) shipped `0AfWB00000Do1vv0AB` — 2 loops → Transforms (ACR / PRG ID extractors).
- Phase B2 dropped (GDD lookup consolidation) — Flow's element model can't cleanly extract scalar from collection.
- Phase C decisions locked in: **ship C4** (Get_Looked_Up_* → outputReference), **skip C1 + C3** (net-zero or readability regressions), **split off C2** (subflow reach extension — own deploy).
- Phase D (8 remaining loop conversions) parked pending research below.

---

## Ask #1 — C4 sample: `<recordLookups>` + `<outputReference>` shape at v67

### Why it matters

The 5 `Get_Looked_Up_*` lookups (`Get_Looked_Up_Campaign`, `_Campaign_Optional`, `_Commitment`, `_Designation`, `_SoftCredit_Account`) currently follow this pattern:

```xml
<recordLookups>
    <name>Get_Looked_Up_Campaign</name>
    <storeOutputAutomatically>true</storeOutputAutomatically>
    ...
</recordLookups>
<assignments>
    <name>Assign_Campaign_From_Lookup</name>
    <assignmentItems>
        <assignToReference>rsv_SelectedCampaign</assignToReference>
        <value><elementReference>Get_Looked_Up_Campaign</elementReference></value>
    </assignmentItems>
</assignments>
```

Per memory [[flow-sobject-assign-drops-fields]], this SObject-to-SObject `Assign` **silently drops fields** at downstream `rsv_SelectedCampaign.<field>` reads. `Get_Context_Commitment` was already refactored to `<outputReference>` + `<queriedFields>` for this reason.

The C4 refactor replaces the pair with a single lookup:

```xml
<recordLookups>
    <name>Get_Looked_Up_Campaign</name>
    <outputReference>rsv_SelectedCampaign</outputReference>
    <queriedFields>Id</queriedFields>
    <queriedFields>Name</queriedFields>
    <!-- ...every field the flow reads downstream... -->
</recordLookups>
```

Then delete `Assign_Campaign_From_Lookup`. **Retires 5 assignments** + potentially fixes silent field-drop bugs on lookup escape-hatch paths.

### Two things I'm uncertain about at v67

1. Does Builder emit `<queriedFields>` inline in the `<recordLookups>` block, or as a separately-tagged sibling structure? (Some Salesforce XML has "child spec" sub-elements with different tag names.)
2. Does `<outputReference>` REPLACE `<storeOutputAutomatically>true</storeOutputAutomatically>`, or coexist with `<storeOutputAutomatically>false</storeOutputAutomatically>`?

### What I need from you

**Option A (fastest — 30 seconds):** Confirm I can use `FQS_Gift_Entry_Guide_GiftCommitment.flow-meta.xml` as the reference — it has the working `Get_Context_Commitment` example. If yes, I'll pull it and read the pattern directly. If it doesn't apply for some reason (different at v67, different consumer shape), tell me why.

**Option B (2-3 minutes):** In Flow Builder in FundFirst, open any flow with a record lookup that stores into an existing SObject variable (not auto-var). Retrieve the flow. Paste me the `<recordLookups>` XML block from that flow.

**Option C (fallback):** Point me at any other flow in the repo you've built recently that uses this pattern. I'll grep and read.

**Preference:** A. `Get_Context_Commitment` should be sufficient — I want to sanity-check my mental model, not learn something novel.

### Once I have the sample

I'll grep every `rsv_SelectedCampaign.<field>`, `rsv_SelectedCommitment.<field>`, `rsv_SelectedDesignation.<field>`, `rsv_SelectedSoftCreditAccount.<field>` reference in the monolith to build the full `<queriedFields>` list per lookup. Miss a field → runtime "field hasn't been set" throw, so this needs to be exhaustive. Estimated 20-40 queried-field entries across the 5 lookups.

---

## Ask #2 — Phase D research: v65+ modern-Flow patterns for the 8 remaining loops

### Why it matters

8 loops in the monolith don't fit the simple Map-Transform pattern that Phase B used. Each has a specific reason it's harder — and each corresponds to a modern-Flow feature I haven't verified emits correctly at v67 in hand-authored XML.

**Element budget if all 8 convert cleanly:** approximately −20 to −25 elements (each loop + body-assign pair retires; some replace with 1 Transform, some with 1 formula, some with Filter+Transform).

### The 8 loops, grouped by blocker

#### Group 1: Counting loops (2)

- `Loop_Count_Campaign_GDDs` + `Assign_Increment_Campaign_GDDCount` + var `var_CampaignGDDCount`
- `Loop_Count_GC_GDDs` + `Assign_Increment_GC_GDDCount` + var `var_GCGDDCount`

**What they do:** iterate a collection, `+1` per row, resulting count consumed by downstream decision (`GreaterThan 1.0`) and 2 formulas (`formulaSplitCountText`, `formulaSplitParentText`).

**Blocker:** Flow at v67 has **no built-in `SIZE()` / `COUNT()` primitive** for collections. Transforms operate collection→collection.

**Research question:** Does Winter '26 (v66) or Spring '26 (v67) introduce any of:
- A `COUNT()` or `SIZE()` formula function that accepts an SObject collection?
- A `<transforms>` `<transformType>` other than `Map` (e.g., `Aggregate`, `Count`, `Reduce`)?
- A native Collection element with a "count" option?

**Where to look:** Salesforce Ben article we already have doesn't cover this. Try:
- Salesforce Release Notes v66 / v67 flow-specific sections
- Ferengi (Flow) reference docs for `<transforms><transformValueActions><transformType>`
- Any recent SF Ben / SF Automation Champion articles on "count records in flow without loop"

**If nothing found:** these two loops STAY as-is. That's fine — they're 3 elements each (loop + assign + var), documented, and work.

#### Group 2: Status-flip loop with in-place mutation (1)

- `Loop_Confirm_Paid_GTs` + `Assign_Confirm_Paid_Row` (writes `rsv_ConfirmedGTLoopItem.Status='Paid'`, then `Add` to `col_ConfirmedPaidGTs`)

**What it does:** flips one field on each row, collects into new SObject collection for bulk `Update_Confirmed_Paid_GTs`.

**Blocker:** Transform's `Map` transformType at v67 — can it emit an SObject collection where each row is source-row + one-field-override? I've seen the pattern described (SF Ben article's #1 example, Loop+Assign+Add → Transform) but not seen a v67 SObject-shape XML example.

**Research question:** In Flow Builder v67, if you create a Transform Element with input=SObject-collection and output=SObject-collection (same object type), what does the XML for the field-by-field mapping look like? Specifically:
- Is it `<transformValueActions>` with one entry per field?
- How does it express "map source.Id → target.Id, override target.Status = 'Paid', pass through everything else"?

**Where to look:** Salesforce Ben Ferengi / SF Automation Champion post on modernizing loops with Transform, but specifically SObject-shaped examples. Also try the v66 release notes on "Transform element enhancements."

#### Group 3: SObject-fanout loops with counter side effect (1)

- `Loop_Fanout_GDSC_To_GSC` + `Assign_Build_GSC_From_GDSC` (4 field writes + Add to collection + `var_GSCsFanoutCount += 1`)

**Two blockers:**
1. Same SObject-shape Transform question as Group 2.
2. **Counter side effect** — `var_GSCsFanoutCount` is consumed by `Success_GiftCreated` for a "N default soft credit(s) applied" summary line. Transform can't mutate scalars.

**Workaround if Group 2 unblocks:** replace the counter increment with a formula: `var_GSCsFanoutCount = SIZE(Get_GC_GDSCs)` — but that runs into Group 1's blocker.

**Alternate workaround:** the summary line's `<visibilityRule>` currently fires on `var_GSCsFanoutCount > 0`. If we rewrite that to `Get_GC_GDSCs` `IsNull=false` AND `Get_GC_GDSCs` `IsEmpty=false` (or whatever the "collection has at least one row" idiom is at v67), we don't need the count. Rendering the exact number in the summary text is separately blocked by Group 1.

**Research question:** Same as Group 2 for the Transform shape. Plus: what's the v67 Flow idiom for "collection has ≥1 row" and "count of rows in a collection displayed as text"?

#### Group 4: SObject-fanout loops with formula body dependencies (1 pair, plus 2 identical siblings)

- `Loop_Fanout_Split_GTDs_Campaign` + `Assign_Build_Split_GTD_Campaign` (5 field writes, one reads `formulaSplitGTDAmount`)
- `Loop_Fanout_Split_GTDs_GC` + `Assign_Build_Split_GTD_GC` (structurally identical, connector loops back to GC variant)

**What they do:** for each GDD in a Multi lookup, build a GTD (GiftTransactionDesignation) with `GiftTransactionId + GiftDesignationId + Percent + Amount` where `Amount = OriginalAmount * (AllocatedPercentage / 100)` per row.

**Blocker A:** SObject-shape Transform (Group 2).

**Blocker B:** the per-row `Amount` formula references BOTH `rsv_GiftTransaction.OriginalAmount` (loop-invariant scalar) AND `rsv_SplitGDDLoopItem.AllocatedPercentage` (loop cursor). If Transforms can inline formulas that reference `[$EachItem].AllocatedPercentage`, this works. If not, no dice.

**Research question:** Can a Transform's `<transformValueActions><value>` reference a formula that itself references `[$EachItem].<field>`? Or must the formula operate on scalars only?

**Bonus win if solvable:** the two loops have identical bodies, differing only in source collection. If Transform's input can be driven by a variable (e.g., `var_SplitGDDSource = Get_Campaign_GDDs_Multi | Get_GC_GDDs_Multi`), we can merge to ONE Transform.

**Research question part 2:** Can a Transform's input collection be a variable holding an SObject-collection reference, rewritten per branch?

#### Group 5: Repeater-source SObject-build with per-row formula deps (2)

- `Loop_Build_Custom_GCSs` (source: `CustomInstallmentsRepeater.AllItems`, 10-field body reading `Loop_Build_Custom_GCSs.field_Custom_Amount / .field_Custom_Date` + 2 formulas)
- `Loop_Build_Custom_GTs` (source: `col_CustomGCSs`, 13-field body, gated by `Decide_Custom_PastDate_Needs_GT`)

**Blockers:**
1. Same SObject-shape Transform question.
2. Formulas `formulaCustomGCSEndDate`, `formulaCustomGCSTransactionDay`, `formulaCustomGTName` reference the loop cursor (`{!Loop_Build_Custom_GCSs.field_Custom_Date}`). If Transform can't provide an equivalent per-row context, these formulas break.
3. Second loop has a Filter (`StartDate < TODAY()`) that would map to a Collection Filter element between the source and the Transform.

**Research question:** SF Ben's article says the pattern is "Loop + Assign + Add → Transform," and calls out Collection Filter separately. What does a **Collection Filter + Transform** chain look like at v67, when both operate on SObject collections?

**Where to look:** Salesforce Ben article on outdated flow hacks (we already have it — the SObject-shape example is what's missing). Also try SF Automation Champion posts on Collection Filter with real v65+ examples.

### Deliverable I'd want from the research

A short reference doc (one paragraph per blocker) saying either:
- "Yes, this is possible at v67, here's a sample XML block" (paste the block), OR
- "No, this isn't possible at v67 — the closest workaround is X, cost is Y elements"

Once I have that per blocker, I can decide:
- Groups 2+3+4 unblock → convert those 5 loops (~ −15 elements)
- Groups 1+5 stay blocked → 3 loops remain
- If all 5 blockers stay unresolved → close Phase D and accept the 8 loops as-is.

### Time budget

Don't sink hours into this. If a targeted search turns up nothing in ~30 minutes total, close it out and let me know — I'll accept the 8 loops as-is and Phase D dies quietly. The alternative is a research rabbit hole that yields −20 elements at best on a flow that's already at 245 elements.

---

## Not asks — just for your morning context

**What I'd do next after C4 ships (if it does):** call the launcher refactor "done for now" and move to whatever's next on the release-readiness tracker. Total launcher element reduction across all shipped Phase A + B + (future) C4 would be roughly **249 → 235-240**, a ~4-6% cut. Not massive, but the biggest reduction was really the readability/naming pass in Phase A — everyone who opens the flow now sees a semantically-grouped element list. That's the durable win.

**What I'd NOT do:** re-attempt B2, C1, or C3 without new information. All three have a real reason they didn't work; retrying them from the same starting point would be repeating the same mistake.

---

## Pivot — subflow extraction for canvas readability (2026-08-04 EOD)

**User feedback:** "worried we aren't going to make a real dent in flow elements any longer. Think we should look at removing long strings of elements for subflows. This will at the very least make the main flow easier to visualize."

**Reframe.** Element-count reduction has hit ceiling (~5-10 elements achievable via Phase C4 + Phase D combined). Subflow extraction is a different optimization: **main-canvas visual reduction**, not total-system element reduction. A subflow extraction collapses N monolith elements into 1 subflow-call node on the main canvas, but the elements themselves relocate to the child flow — total-system count unchanged.

### Extraction candidates (ranked by main-canvas space reclaimed)

| # | Candidate | Monolith chain | Canvas reduction | Fires on | Input contract | Output contract |
|---|---|---|---|---|---|---|
| 1 | **Employer match reach + confirm** | Pick_MatchEmployer → 3 lookups (ACR/PRG/EmployerAccounts) → 2 transforms → Details_MatchAmount → Match warnings → ACR create → self-match GTs | ~15 → 1 | Only when user opts into matching | donorId, giftAmount, campaignId | matchGTId (nullable) |
| 2 | **Designation resolver** | Decide_Route_Outright_To_Resolver → 3 GDD lookups → 2 counting loops → 5 resolve-terminal assigns → Get_Resolved_GD → Confirm_Designation | ~15 → 1 | Every leaf, complex 5-tier hierarchy | leafType, campaignId, commitmentId (nullable), userOverride (nullable) | var_ResolvedDesignationId, var_ResolvedDesignationSource, rsv_SelectedDesignation |
| 3 | **Custom installments builder** | Assign_Custom_SeedFirstRow → Details_Scheduled Repeater consumers → 2 loops → 2 assigns → 2 creates → Process action | ~10 → 1 | Scheduled leaf, irregular branch only | commitmentId, donorId, repeaterRows | GCSs + GTs created |
| 4 | **Split-GTD fanout** | Decide_Split_Source_For_Fanout → 2 loops → 2 assigns → Create_Split_GTDs | ~7 → 1 | Only when Campaign or GC has >1 GDDs | giftTransactionId, sourceCollection | GTDs inserted |
| 5 | **GDSC→GSC fanout** | Decide_Fanout_GDSC → Get_GC_GDSCs → Loop → Assign → Create_GSCs | ~6 → 1 | GC-creating leaves + PP first-payment | giftTransactionId, giftCommitmentId | count of GSCs created |
| 6 | **Past-due confirmation** | Get_PastDue → Confirm_PastPayments → Loop → Assign → Update | 5 → 1 | PP-context entry only | commitmentId | side-effect update |

### Honest costs of subflow extraction (apply to every candidate)

- Input + output variables become explicit contracts at the subflow boundary. If the chain reads N monolith vars, they all become `<inputAssignments>`.
- Debug traces jump between flows — mental model has to track which flow the current node lives in.
- SObject fields passed via `<outputReference>` need explicit `<queriedFields>` (same trap as C4).
- Each subflow needs its own version-management + deploy.
- Subflow invocation adds ~50-200ms per call at runtime.
- Total-system element count is unchanged (elements move, don't disappear).

### Recommended first extraction: #1 — Employer match reach + confirm

**Why first:**
1. Fires on single code path — zero risk of breaking non-match leaves.
2. Reclaims most main-canvas space per subflow (~15 elements).
3. Obvious input/output contract (nouns: donor, gift amount → verb: return matched-GT-Id).
4. Aligns with C2 you already agreed to split off.
5. Dependencies self-contained (doesn't feed back into resolver, doesn't gate downstream leaves).

### Two questions to answer before I draft the extraction plan

1. **Is there ONE section of the canvas that's especially painful to visualize today, or is it uniformly cluttered?** If specific pain point, extract that first regardless of my ranking.
2. **Should extracted subflows be shared across launchers** (callable from Home / Account / Opportunity purposeful launchers directly, bypassing the monolith on some paths)? Or **only called from the monolith**? Shared changes the input-contract design considerably.

Answer these and I can draft the employer-match extraction plan.
