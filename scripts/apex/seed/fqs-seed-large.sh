#!/usr/bin/env bash
# FQS Large Dataset — 10,000 donors seeded via 34 chunks of 300 donors each.
#
# Prerequisites:
#   1. Teardown any prior FQS seed data: sf apex run -f fqs-seed-teardown.apex --target-org FundFirst
#   2. Foundation records exist: sf apex run -f fqs-seed-foundation.apex --target-org FundFirst
#
# Usage:
#   ./fqs-seed-large.sh                    # defaults: 34 chunks × 300 = 10,200 donors, target FundFirst
#   ./fqs-seed-large.sh 20 500 MyOrg       # 20 chunks × 500 = 10,000 donors, target MyOrg
#
# Expected wall-clock: ~10-15 minutes per 10k. Each chunk = one API call.
# Anonymous Apex row budget: 300 donors × ~25 rows/donor = ~7,500 rows/chunk (safe under 10k limit).

set -euo pipefail

CHUNK_COUNT="${1:-34}"
CHUNK_SIZE="${2:-300}"
TARGET_ORG="${3:-FundFirst}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHUNK_SCRIPT="${SCRIPT_DIR}/fqs-seed-chunk.apex"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [[ ! -f "$CHUNK_SCRIPT" ]]; then
    echo "ERROR: chunk script not found at $CHUNK_SCRIPT"
    exit 1
fi

echo "==================================="
echo "FQS Large Dataset Seeder"
echo "==================================="
echo "Chunks:     $CHUNK_COUNT"
echo "Per chunk:  $CHUNK_SIZE donors"
echo "Total:      $((CHUNK_COUNT * CHUNK_SIZE)) donors"
echo "Org:        $TARGET_ORG"
echo "==================================="
echo ""

FAILURES=0
for ((i=0; i<CHUNK_COUNT; i++)); do
    OFFSET=$((i * CHUNK_SIZE))
    CHUNK_FILE="${TMP_DIR}/chunk_${i}.apex"

    # Substitute chunk size + offset into the template
    sed "s/^Integer DONOR_COUNT = 300;$/Integer DONOR_COUNT = ${CHUNK_SIZE};/; s/^Integer BATCH_OFFSET = 0;.*/Integer BATCH_OFFSET = ${OFFSET};/" \
        "$CHUNK_SCRIPT" > "$CHUNK_FILE"

    printf "[%2d/%d] chunk offset %5d ... " $((i+1)) "$CHUNK_COUNT" "$OFFSET"
    START=$(date +%s)

    if sf apex run --file "$CHUNK_FILE" --target-org "$TARGET_ORG" > "${TMP_DIR}/chunk_${i}.log" 2>&1; then
        END=$(date +%s)
        printf "OK (%ds)\n" $((END - START))
    else
        END=$(date +%s)
        printf "FAILED (%ds) — see ${TMP_DIR}/chunk_${i}.log\n" $((END - START))
        FAILURES=$((FAILURES + 1))
        # Uncomment to abort on first failure:
        # exit 1
    fi
done

echo ""
echo "==================================="
if [[ $FAILURES -eq 0 ]]; then
    echo "All chunks succeeded."
else
    echo "WARNING: $FAILURES chunk(s) failed. Check logs in $TMP_DIR"
    # keep TMP_DIR around for debug
    trap - EXIT
    echo "Log dir preserved: $TMP_DIR"
fi
echo "==================================="

# Quick summary query
echo ""
echo "Summary counts:"
sf data query --target-org "$TARGET_ORG" --query "SELECT COUNT() FROM Account WHERE Name LIKE '%FQS #%'" 2>&1 | grep -E "Total" || true
sf data query --target-org "$TARGET_ORG" --query "SELECT COUNT() FROM GiftTransaction WHERE Donor.Name LIKE '%FQS #%'" 2>&1 | grep -E "Total" || true
sf data query --target-org "$TARGET_ORG" --query "SELECT COUNT() FROM GiftCommitment WHERE Donor.Name LIKE '%FQS #%'" 2>&1 | grep -E "Total" || true
