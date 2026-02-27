#!/usr/bin/env node
// Main entrypoint — invoked by npx as:
//   npx github:iarroyo/commit-gen <command> [args]

const [,, command, ...args] = process.argv;

// Shift args so sub-scripts that read process.argv directly receive them correctly
process.argv = [process.argv[0], process.argv[1], ...args];

switch (command) {
  case 'setup':
    require('./src/setup.js');
    break;
  case 'commit':
    require('./src/cli.js');
    break;
  case 'lint':
    require('./src/lint.js');
    break;
  case 'uninstall':
    require('./src/uninstall.js');
    break;
  default:
    console.error(`Unknown command: ${command || '(none)'}`);
    console.error('Usage: commit-gen <setup|uninstall|commit|lint>');
    process.exit(1);
}
