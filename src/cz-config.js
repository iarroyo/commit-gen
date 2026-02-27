module.exports = {
  types: [
    { value: "feat", name: "feat:      Adding a new feature" },
    { value: "fix", name: "fix:       Fixing a bug" },
    {
      value: "refactor",
      name: "refactor:  Apply code changes without changing its behaviour or fixing a bug",
    },
    { value: "test", name: "test:      Updating or improving tests" },
    { value: "docs", name: "docs:      Updating or improving documentation" },
    {
      value: "build",
      name: "build:     Updating build scripts or dependencies",
    },
    {
      value: "chore",
      name: "chore:     Other changes, for example: bump version number",
    },
    { value: "revert", name: "revert:    Reverting a change" },
    { value: "style", name: "style:     Formatting, no logic change" },
    { value: "perf", name: "perf:      Improving performance" },
  ],

  messages: {
    customScope: "Denote the SCOPE of this change (optional):",
    subject:
      "Write a SHORT, IMPERATIVE tense description of the change\n E.g.: 'add filter', not 'added filter' or 'adds filter', lowercase, no period at the end\n Following this format: [<TICKET-ID>|NO-TICKET] <description>:\n",
    body: "For non-trivial commits, please include a brief explanation of why the change was made. Use '|' to break new line:\n",
    footer:
      "References to closed issues or tickets (optional). E.g.: <JIRA TICKET-ID> or <GITHUB ISSUE-ID>:\n",
  },
  allowCustomScopes: true,
  allowBreakingChanges: ["feat", "fix"],

  subjectLimit: 100,
  breaklineChar: "|",

  footerPrefix: "Closes:",
  askForBreakingChangeFirst: true,
};
