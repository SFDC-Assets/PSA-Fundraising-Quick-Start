# FQS Pledge Restriction Interlock Plan

**Status:** Draft
**Owner:** Justin (solo)
**Created:** 2026-07-30
**Trigger:** Erin feedback item 7 — *"For 7 I think I want the filter on creation too, and for that and pledge payment for the conditional or unconditional to appear as context to the end users when select designations."*

## Problem statement

Today the `pkFulfillmentType` picklist (Unconditional / Conditional) is captured on Simple and Scheduled pledge-creation screens but has **no effect on the downstream designation picker** on pledge creation. The commitment stores the flag on `GC.FulfillmentType`, but the designation flow presents *all* designations regardless.

On Pledge Payment (post-creation), the flag does drive routing via `Decide_Restriction_Path` (launcher line 4695) — Unconditional skips the picker; Conditional filters by the commitment's existing restriction. That behavior is correct and Erin wants parity on creation.

Additionally, when the designation picker screen appears, users have no visible reminder of *why* they're seeing a filtered list. The screen should render the current fulfillment context ("This is a Conditional pledge — designations below are filtered to Purpose-Restricted") so users don't get confused.

## Scope

**In scope:**
1. Add automatic restriction filtering to Simple + Scheduled pledge *creation* branches when `pkFulfillmentType == Conditional`.
2. Add a display-text context header on the designation picker screen(s) — reads dynamically from fulfillment state.
3. Same context header applies to Pledge Payment's designation picker (parity).

**Out of scope:**
- Recurring pledge creation gets the same treatment automatically because it already routes through the Override-branch restriction picker (`Decide_Override_Needs_Restriction` line 4577); no additional wiring needed once the commitment-creation path is fixed.
- Grant Payout branch has its own restriction semantics — leave untouched.
- Fee-designation interlock is a separate line item.

## Current state (verified via grep)

Elements involved:
- `pkFulfillmentType` — Simple leaf, `Screen_Pledge_Details` line 9389.
- `pkScheduledFulfillmentType` — Scheduled leaf, `Screen_Scheduled_Details` line 9811.
- `Choice_Fulfillment_Unconditional` / `Choice_Fulfillment_Conditional` — line 2735 / 2743.
- `Screen_Pick_Restriction` — the restriction-type picker (Purpose / Time / Permanent / Without-Restriction).
- `Choice_Restriction_Purpose / Time / Permanent / Without` — lines 3008–3032.
- `pkRestrictionType` — captured on the restriction picker; already used at line 2353 (a Get filter).
- `Decide_Override_Needs_Restriction` (line 4577) — Override-path router; currently the only creation-side path to `Screen_Pick_Restriction`.
- `Decide_Restriction_Path` (line 4695) — the transaction-side restriction router (PP + Earned Income + defaults).
- `var_ResolvedDesignationSource` / `var_ResolvedDesignationId` — resolver state (line 2185 et al).
- `Screen_Confirm_Designation` (referenced line 1649, 4551).
- `Screen_Pick_Designation` — the user override/pick screen.

## Proposed changes

### 7a. Automatic restriction filter on pledge creation

**Simple leaf:**
Insert a new decision after `Assign_Pledge_Defaults` and before the current designation-resolution entry point:

```
Decide_Pledge_Creation_Fulfillment_Filter
  Rule: pkFulfillmentType == Conditional
    → Screen_Pick_Restriction (existing screen — reuse)
  Default (Unconditional)
    → current path (resolver runs, org-default or campaign-default lands)
```

After `Screen_Pick_Restriction`, `pkRestrictionType` is populated; downstream `Get_Filtered_Designations` (already referenced at line 2353) filters the designation picker.

**Scheduled leaf:** mirror the same insert after `Assign_Scheduled_Defaults`. Reuse `pkScheduledFulfillmentType` in the decision.

**Recurring leaf:** no change — already routes through `Decide_Override_Needs_Restriction` on Override paths, and there's no automatic-Conditional case (Recurring doesn't collect `pkFulfillmentType` — the assignment hardcodes Unconditional at flow lines 1963/1106). Confirm with Erin: does she want a Recurring `pkFulfillmentType` too? Deferred until asked.

### 7b. Fulfillment context header on designation picker

Add a new display-text field on `Screen_Pick_Designation`:

```
FulfillmentContext (DisplayText)
  Visibility: always (or gate to only-when-fulfillment-known)
  Text: dynamic based on formula
```

Formula source:
- Simple/Scheduled creation: read `pkFulfillmentType` / `pkScheduledFulfillmentType`.
- Pledge Payment: read `rsv_SelectedCommitment.FulfillmentType`.
- Everything else: fall through to a generic "No restriction constraint applies to this gift."

New formula `formulaFulfillmentContext`:

```
IF(
  {!pkLeafFuture} = "Simple",
    IF({!pkFulfillmentType} = "Conditional",
      "This is a **Conditional** pledge — restriction: **" & {!pkRestrictionType} & "**. Designations below are filtered to match.",
      "This is an **Unconditional** pledge — the default unrestricted designation applies. Choose an alternate only if there's a specific reason."),
  {!pkLeafFuture} = "Scheduled",
    IF({!pkScheduledFulfillmentType} = "Conditional",
      "This is a **Conditional** scheduled pledge — restriction: **" & {!pkRestrictionType} & "**. Designations below are filtered to match.",
      "This is an **Unconditional** scheduled pledge — the default unrestricted designation applies."),
  {!pkLeafMonetary} = "PledgePayment",
    IF({!rsv_SelectedCommitment.FulfillmentType} = "Conditional",
      "This pledge payment applies to a **Conditional** commitment. Restriction on the commitment: **" & {!rsv_SelectedCommitment.FQS_Restriction_Type__c} & "**. Designations below are filtered to match.",
      "This pledge payment applies to an **Unconditional** commitment. The default unrestricted designation applies."),
  ""
)
```

**Gotcha:** reading `rsv_SelectedCommitment.FulfillmentType` fires only on PP branch. On non-PP leaves the read of `rsv_SelectedCommitment.*` would throw per [[flow-unread-sobject-field-throws]]. The CASE on leaf handles that — the formula only evaluates the PP branch when `pkLeafMonetary = PledgePayment`.

**Visibility:** the field itself can be always-visible on `Screen_Pick_Designation`, but the formula outputs empty string for non-fulfillment-relevant leaves (Outright / In-Kind / Earned Income / Event Reg / Recurring), so it renders as blank on those.

## Deploy plan

- One flow-file edit (2 new decisions + 1 new display field + 1 new formula + `Screen_Pick_Restriction` reuse wiring).
- No new custom fields or metadata.
- Version cap in target org: monitor. If we're at cap when this deploys, prune obsolete versions via Tooling API (per [[fqs-crt-deploy-pattern]] pattern already used this session).

## UAT scenarios

1. **Simple + Unconditional** — pick Single Payment Pledge, pick Unconditional, land on designation screen; context header reads "This is an **Unconditional** pledge — default unrestricted applies." Designation picker shows unrestricted set.
2. **Simple + Conditional + Purpose** — pick Conditional, land on `Screen_Pick_Restriction`, pick Purpose-Restricted, land on designation screen; context header reads "…Conditional…restriction: Purpose Restricted…" Designation picker shows Purpose-Restricted-tagged designations only.
3. **Scheduled + Conditional + Time** — similar to (2) but on Scheduled leaf.
4. **Pledge Payment on Conditional commitment** — context header reads "This pledge payment applies to a **Conditional** commitment…" Filter matches commitment's restriction.
5. **Pledge Payment on Unconditional commitment** — no picker (per existing `Decide_Restriction_Path_PledgePaymentUnconditional` short-circuit); N/A for header.
6. **Outright Gift** — designation screen appears, context header is blank (no fulfillment context applies).

## Risks

- **Screen_Pick_Restriction reuse across creation + Override paths**: this screen is already invoked from `Decide_Override_Needs_Restriction`. Reusing it from the new creation-side decision means it now has multiple upstream connectors. Confirm Flow XML allows multi-inbound to the same screen (standard — yes it does, as long as downstream connector is deterministic).
- **Formula null-safety on `rsv_SelectedCommitment.FQS_Restriction_Type__c`** — restriction-type field name needs to be verified in the object metadata. If field name differs, adjust formula.
- **Version cap risk** — cap is 50. Prune before deploy.

## Sequencing

Ship this **before** Commit 2 (pledge-with-first-payment), because Commit 2's first-payment GT will re-enter the designation picker and inherits this behavior automatically.
