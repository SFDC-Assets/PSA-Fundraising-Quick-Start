# Archived FQS Plans

Plans in this directory are **shipped** — their work is complete and in `main`. They live here as historical context: design decisions, discovered gotchas, deploy sequences, and links to related memory entries.

**Rule:** an archived plan is read-only reference. If work resumes on the same area, either amend the shipped design (edit in place here and note the amendment in `.planning/fqs-release-readiness.md` under Findings) or start a new plan at `.planning/<name>-plan.md`.

## Archived to date

| File | Shipped | Commit(s) / Deploy | What it built |
|---|---|---|---|
| `fqs-gift-acknowledgement-plan.md` | 2026-07-23, superseded 2026-07-26 | `8785b00` (initial), `afc6007` (split) | v2 conflated ack flow — superseded by the ack/stewardship split |
| `fqs-gift-followup-redesign.md` | 2026-07-26 | `afc6007` + `ddd7386` + `a9b1ab3` | Ack/stewardship two-flow split, CMDT rename, admin+integration docs |
| `fqs-duplicate-rules-plan.md` | 2026-07-25 | `0AfWB00000Dbblt0AB` + `0AfWB00000Dbbyn0AB` + `0AfWB00000DbcQD0AZ` | 3 MatchingRules + 3 DuplicateRules (Warn) on Account/Contact |
| `fqs-record-naming-flows-plan.md` | 2026-07-22 | `0AfWB00000DY1lN0AT` | RecordBeforeSave naming flows on GC/GT/Opp with skip-flag opt-outs |
| `fqs-outreach-summary-help-text-plan.md` | 2026-07-23 | `ad2e1f5` | 9 field-meta overlays on OutreachSummary DPE fields |
| `fqs-utm-platform-field-plan.md` | 2026-07-23 | `d6c47d8` | FQS_Platform__c picklist + UTM inline help on OutreachSourceCode |
| `fqs-gift-refund-plan.md` | 2026-07-23 | `0AfWB00000Da4Oz` + `0AfWB00000Da4jx` + `0AfWB00000Da5GD` | 2 refund screen flows + quick actions + GiftRefundReason values |
| `fqs-gc-router-refactor-plan.md` | 2026-07-24 | `0AfWB00000DbaTF0AZ` | 6-state router refactor + FQS_GC_Action__mdt teardown |

For live plans (in-progress or not-yet-implemented), see `.planning/*.md` at the root.
