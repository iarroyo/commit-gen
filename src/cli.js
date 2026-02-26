#!/usr/bin/env node
// Launched by the prepare-commit-msg Git hook via:
//   npx @iarroyo/commit-config commit --hook

const path = require("path");
const { bootstrap } = require("commitizen/dist/cli/git-cz");

bootstrap({
  cliPath: path.dirname(require.resolve("commitizen/package.json")),
  config: {
    path: path.resolve(__dirname, "./cz-adapter.js"),
  },
});
