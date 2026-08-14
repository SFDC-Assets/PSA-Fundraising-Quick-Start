#!/usr/bin/env bash
# FQS Teardown — auto-loop wrapper.
#
# Each Apex invocation self-caps at ~9K DML rows (see fqs-seed-teardown.apex).
# On orgs with tens of thousands of seeded records, one pass leaves records
# behind and the caller has to remember to re-run. This script loops until a
# pass reports 0 deletes (or the safety cap is hit).
#
# Usage:
#   ./fqs-seed-teardown-loop.sh                   # target FundFirst, up to 50 passes
#   ./fqs-seed-teardown-loop.sh MyOrg 20          # target MyOrg, cap 20 passes

set -euo pipefail

TARGET_ORG="${1:-FundFirst}"
MAX_PASSES="${2:-50}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEARDOWN_SCRIPT="${SCRIPT_DIR}/fqs-seed-teardown.apex"

if [[ ! -f "$TEARDOWN_SCRIPT" ]]; then
    echo "ERROR: teardown script not found at $TEARDOWN_SCRIPT"
    exit 1
fi

echo "==================================="
echo "FQS Teardown Auto-Loop"
echo "Target org: $TARGET_ORG"
echo "Max passes: $MAX_PASSES"
echo "==================================="

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

for ((pass=1; pass<=MAX_PASSES; pass++)); do
    LOG="${TMP_DIR}/pass_${pass}.log"
    printf "[pass %2d/%d] running teardown ... " "$pass" "$MAX_PASSES"
    START=$(date +%s)

    if ! sf apex run --file "$TEARDOWN_SCRIPT" --target-org "$TARGET_ORG" > "$LOG" 2>&1; then
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

    # Extract the "records deleted" count from the "Teardown pass complete: N records deleted"
    # line in the debug output.
    DELETED=$(grep -oE 'Teardown pass complete: [0-9]+ records deleted' "$LOG" | grep -oE '[0-9]+' | tail -1)
    DELETED="${DELETED:-0}"

    printf "OK (%ds) — %s records deleted\n" $((END - START)) "$DELETED"

    if [[ "$DELETED" -eq 0 ]]; then
        echo ""
        echo "==================================="
        echo "Teardown complete in $pass pass(es)."
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
