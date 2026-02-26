#!/usr/bin/env node
// Launched by integrators via:
//   npx @iarroyo/commit-config setup

const { spawnSync } = require("child_process");
const path = require("path");

const script = path.resolve(__dirname, "setup.sh");

const result = spawnSync("bash", [script], { stdio: "inherit" });

process.exit(result.status ?? 1);
