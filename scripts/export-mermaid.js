#!/usr/bin/env node
/**
 * Extracts mermaid code blocks from markdown files and exports each as a PNG
 * into docs/diagrams/. Output filenames are derived from the heading immediately
 * preceding each diagram block.
 *
 * Usage: node scripts/export-mermaid.js
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

const PROJECT_ROOT = path.resolve(__dirname, '..');
const DOCS_DIR = path.join(PROJECT_ROOT, 'docs');
const OUT_DIR = path.join(DOCS_DIR, 'diagrams');
const SOURCE_FILES = [
  'fqs-account-launcher-flow-diagram.md',
  'fqs-flow-overview.md',
];

// Manual overrides: map "source-file:n" (1-based block index) → output slug.
// Used when the auto-derived heading is ambiguous or duplicated across sections.
const NAME_OVERRIDES = {
  'fqs-account-launcher-flow-diagram:1': 'gge-account-launcher-full',
  'fqs-flow-overview:1':                 'gge-account-monolith-architecture',
  'fqs-flow-overview:2':                 'suggest-designations-phase1-existence-check',
  'fqs-flow-overview:3':                 'suggest-designations-phase2-staging-commit',
  'fqs-flow-overview:4':                 'campaign-hierarchy-setup-full',
  'fqs-flow-overview:5':                 'campaign-member-status-on-commitment-full',
  'fqs-flow-overview:6':                 'campaign-member-status-on-gift-transaction-full',
  'fqs-flow-overview:7':                 'designation-resolver-sectionA-campaign-selection',
  'fqs-flow-overview:8':                 'designation-resolver-sectionB-designation-hierarchy',
  'fqs-flow-overview:9':                 'designation-resolver-sectionC-confirm-override',
};

fs.mkdirSync(OUT_DIR, { recursive: true });

let total = 0;

for (const filename of SOURCE_FILES) {
  const filePath = path.join(DOCS_DIR, filename);
  const content = fs.readFileSync(filePath, 'utf8');
  const baseName = path.basename(filename, '.md');

  // Extract all ```mermaid ... ``` blocks
  const regex = /```mermaid\n([\s\S]*?)```/g;
  let match;
  let index = 1;

  while ((match = regex.exec(content)) !== null) {
    const diagramCode = match[1];
    const overrideKey = `${baseName}:${index}`;
    const slug = NAME_OVERRIDES[overrideKey] || `${baseName}-${index}`;
    const outputName = `${slug}.png`;
    const outputPath = path.join(OUT_DIR, outputName);

    // Write diagram to a temp file
    const tmpFile = path.join(os.tmpdir(), `mermaid-${Date.now()}.mmd`);
    fs.writeFileSync(tmpFile, diagramCode);

    try {
      execSync(
        `npx --yes @mermaid-js/mermaid-cli -i "${tmpFile}" -o "${outputPath}" --backgroundColor white`,
        { stdio: 'pipe' }
      );
      console.log(`  exported: docs/diagrams/${outputName}`);
      total++;
    } catch (err) {
      console.error(`  FAILED: ${outputName}`);
      console.error(err.stderr?.toString() || err.message);
    } finally {
      fs.unlinkSync(tmpFile);
    }

    index++;
  }
}

console.log(`\nDone — ${total} diagram(s) exported to docs/diagrams/`);
