#!/usr/bin/env node
// Launched by the commit-msg Git hook via:
//   npx @iarroyo/commit-config lint <commit-msg-file>

const { lint } = require("@commitlint/core");
const fs = require("fs");
const path = require("path");

const msgFile = process.argv[2];

if (!msgFile) {
  console.error("Usage: lint <commit-msg-file>");
  process.exit(1);
}

const message = fs.readFileSync(msgFile, "utf8").trim();
const config = require(path.resolve(__dirname, "./commitlint.config.js"));

lint(
  message,
  config.rules,
  config.parserPreset ? { parserPreset: config.parserPreset } : {},
)
  .then((result) => {
    if (result.valid) {
      process.exit(0);
    }
    console.error("\n✖  Invalid commit message:\n");
    result.errors.forEach((e) => console.error(`   ${e.message}`));
    result.warnings.forEach((w) => console.warn(`   ⚠  ${w.message}`));
    console.error("\n   Expected format: <type>(<scope>): <subject>\n");
    process.exit(1);
  })
  .catch((err) => {
    console.error("commitlint error:", err.message);
    process.exit(1);
  });
