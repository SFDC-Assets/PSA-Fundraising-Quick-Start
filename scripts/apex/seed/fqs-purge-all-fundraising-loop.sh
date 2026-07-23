#!/usr/bin/env bash
# FQS Full Purge — auto-loop wrapper.
#
# DANGER: deletes ALL fundraising records from the target org, not just seeded
# data. See fqs-purge-all-fundraising.apex for scope.
#
# Each Apex invocation self-caps at ~9K DML rows. This script loops until a
# pass reports 0 deletes (or the safety cap is hit).
#
# Usage:
#   ./fqs-purge-all-fundraising-loop.sh                   # target FundFirst, up to 50 passes
#   ./fqs-purge-all-fundraising-loop.sh MyOrg 20          # target MyOrg, cap 20 passes

set -euo pipefail

TARGET_ORG="${1:-FundFirst}"
MAX_PASSES="${2:-50}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PURGE_SCRIPT="${SCRIPT_DIR}/fqs-purge-all-fundraising.apex"

if [[ ! -f "$PURGE_SCRIPT" ]]; then
    echo "ERROR: purge script not found at $PURGE_SCRIPT"
    exit 1
fi

echo "==================================="
echo "FQS Full Purge Auto-Loop"
echo "Target org: $TARGET_ORG"
echo "Max passes: $MAX_PASSES"
echo "==================================="

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

for ((pass=1; pass<=MAX_PASSES; pass++)); do
    LOG="${TMP_DIR}/pass_${pass}.log"
    printf "[pass %2d/%d] running purge ... " "$pass" "$MAX_PASSES"
    START=$(date +%s)

    if ! sf apex run --file "$PURGE_SCRIPT" --target-org "$TARGET_ORG" > "$LOG" 2>&1; then
        END=$(date +%s)
        printf "FAILED (%ds)\n" $((END - START))
        echo ""
        echo "Last 40 lines of log:"
        tail -n 40 "$LOG"
        echo ""
        echo "Full log: $LOG (preserved)"
        trap - EXIT
        exit 1
    fi

    END=$(date +%s)

    DELETED=$(grep -oE 'Purge pass complete: [0-9]+ records deleted' "$LOG" | grep -oE '[0-9]+' | tail -1)
    DELETED="${DELETED:-0}"

    printf "OK (%ds) — %s records deleted\n" $((END - START)) "$DELETED"

    if [[ "$DELETED" -eq 0 ]]; then
        echo ""
        echo "==================================="
        echo "Purge complete in $pass pass(es)."
        echo "==================================="
        exit 0
    fi
done

echo ""
echo "==================================="
echo "WARNING: hit MAX_PASSES=$MAX_PASSES with records still remaining."
echo "Re-run this script, or increase MAX_PASSES."
echo "Log dir preserved: $TMP_DIR"
echo "==================================="
trap - EXIT
exit 2
