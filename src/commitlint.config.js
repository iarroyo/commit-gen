module.exports = {
  plugins: [
    {
      rules: {
        "subject-ticket": (parsed) => {
          const regex = /^\[([A-Z]{2,5}-[0-9]+|NO-TICKET)\].+$/;
          const valid = regex.test(parsed.subject || "");
          return [
            valid,
            "Subject must follow this format: [<TICKET-ID>|NO-TICKET] <description>",
          ];
        },
      },
    },
  ],
  rules: {
    "type-enum": [
      2,
      "always",
      [
        "feat",
        "fix",
        "refactor",
        "test",
        "docs",
        "build",
        "chore",
        "revert",
        "style",
        "perf",
      ],
    ],
    "type-case": [2, "always", "lower-case"],
    "type-empty": [2, "never"],
    "scope-case": [2, "always", "lower-case"],
    "subject-empty": [2, "never"],
    "subject-case": [
      2,
      "never",
      ["sentence-case", "start-case", "pascal-case", "upper-case"],
    ],
    "subject-full-stop": [2, "never", "."],
    "subject-ticket": [2, "always"],
    "header-max-length": [2, "always", 100],
    "body-leading-blank": [1, "always"],
    "footer-leading-blank": [1, "always"],
  },
};
