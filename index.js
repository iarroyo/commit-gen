#!/usr/bin/env node
// Main entrypoint — invoked by npx as:
//   npx github:iarroyo/commit-gen <command> [args]

const [,, command, ...args] = process.argv;

// Shift args so sub-scripts that read process.argv directly receive them correctly
process.argv = [process.argv[0], process.argv[1], ...args];

function help() {
  console.log('Usage: commit-gen <command> [options]');
  console.log('');
  console.log('Commands:');
  console.log('  setup      Install Git hooks in the current repository');
  console.log('             Options: --hooks-dir <path>  Use a custom hooks directory (default: .git/hooks)');
  console.log('  uninstall  Remove managed Git hooks from the current repository');
  console.log('             Options: --hooks-dir <path>  Same path used during setup');
  console.log('  commit     Launch the interactive commitizen prompt');
  console.log('  lint       Validate a commit message against the shared rules');
  console.log('  help       Show this help message');
}

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
  case 'help':
  case '--help':
  case '-h':
    help();
    break;
  default:
    if (command) console.error(`Unknown command: ${command}\n`);
    help();
    process.exit(command ? 1 : 0);
}
