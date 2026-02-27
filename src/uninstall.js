#!/usr/bin/env node
// Launched by integrators via:
//   npx github:iarroyo/commit-gen uninstall [--hooks-dir <path>]

const { spawnSync } = require("child_process");
const path = require("path");

const script = path.resolve(__dirname, "uninstall.sh");

const result = spawnSync("bash", [script, ...process.argv.slice(2)], { stdio: "inherit" });

process.exit(result.status ?? 1);
