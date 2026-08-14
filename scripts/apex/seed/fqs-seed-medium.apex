// FQS Medium — 100 donors. Run order: teardown -> foundation -> this.
// All generator logic lives in FQSSeedGenerator.cls; this is a thin invoker.

Integer DONOR_COUNT = 100;
Integer BATCH_OFFSET = 0;

// Uncomment to override probability knobs for fixture-mode runs:
// FQSSeedGenerator.PROB_LAPSED = 1.0;

FQSSeedGenerator.seedChunk(DONOR_COUNT, BATCH_OFFSET);
