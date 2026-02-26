// cz-config.js — customize types, scopes, and prompt behavior
module.exports = {
  types: [
    { value: "fix", name: "fix:       Fixing a bug" },
    { value: "feat", name: "feat:      Adding a new feature" },
    { value: "docs", name: "docs:      Updating or improving documentation" },
    {
      value: "refactor",
      name: "refactor:  Apply code changes without changing its behaviour or fixing a bug",
    },
    { value: "perf", name: "perf:      Improving performance" },
    { value: "test", name: "test:      Updating or improving tests" },
    {
      value: "build",
      name: "build:     Updating build scripts or dependencies",
    },
    {
      value: "chore",
      name: "chore:     Other changes, for example: bump version number",
    },
    { value: "style", name: "style:     Formatting, no logic change" },
    { value: "revert", name: "revert:    Reverting a change" },
  ],

  messages: {
    customScope: "Denote the SCOPE of this change (optional):",
    subject:
      "Write a SHORT, IMPERATIVE tense description of the change:\n Following this format: [<TICKET-ID>|NO-TICKET] <description>\n",
    body: "For non-trivial commits, please include a brief explanation of why the change was made. Use '|' to break new line:\n",
  },
  allowCustomScopes: true,
  allowBreakingChanges: ["feat", "fix"],

  subjectLimit: 100,
  breaklineChar: "|",

  footerPrefix: "Closes:",
  askForBreakingChangeFirst: true,
};
