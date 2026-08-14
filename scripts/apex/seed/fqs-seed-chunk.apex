// FQS Chunk Seed. Called by fqs-seed-large.sh with different BATCH_OFFSET.
// All generator logic lives in FQSSeedGenerator.cls — this file is a thin invoker
// so we stay well under the 32K anonymous Apex cap and get automatic CMT-derived
// amount bands (see FQSSeedGenerator.deriveBandsFromCmt).
//
// The two constants below are load-bearing: fqs-seed-large.sh's sed substitution
// rewrites their values per chunk. Do not rename.

Integer DONOR_COUNT = 300;
Integer BATCH_OFFSET = 0;   // <<<CHUNK_OFFSET>>>

// Uncomment to override probability knobs for fixture-mode runs:
// FQSSeedGenerator.PROB_LAPSED = 1.0;
// FQSSeedGenerator.PYRAMID_ENTRY_PCT = 0;
// FQSSeedGenerator.PYRAMID_MID_PCT = 0;

FQSSeedGenerator.seedChunk(DONOR_COUNT, BATCH_OFFSET);
