// test/commitlint.test.js
// Validates commitlint.config.js rules using QUnit + @commitlint/core

const QUnit = require("qunit");
const { lint } = require("@commitlint/core");
const config = require("../src/commitlint.config.js");

const lintOpts = { plugins: config.plugins };

async function check(message) {
  return lint(message, config.rules, lintOpts);
}

// ---------------------------------------------------------------------------
// subject-ticket
// ---------------------------------------------------------------------------
QUnit.module("subject-ticket rule", () => {
  QUnit.test("accepts [TICKET-ID] prefix", async (assert) => {
    const r = await check("feat: [PROJ-123] add login page");
    assert.true(r.valid, r.errors.map((e) => e.message).join(", "));
  });

  QUnit.test("accepts [NO-TICKET] prefix", async (assert) => {
    const r = await check("chore: [NO-TICKET] bump version");
    assert.true(r.valid, r.errors.map((e) => e.message).join(", "));
  });

  QUnit.test("accepts two-letter ticket prefix", async (assert) => {
    const r = await check("fix: [AB-1] correct typo");
    assert.true(r.valid, r.errors.map((e) => e.message).join(", "));
  });

  QUnit.test("accepts five-letter ticket prefix", async (assert) => {
    const r = await check("fix: [ABCDE-999] correct typo");
    assert.true(r.valid, r.errors.map((e) => e.message).join(", "));
  });

  QUnit.test("rejects missing ticket prefix", async (assert) => {
    const r = await check("feat: add login page");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "subject-ticket"));
  });

  QUnit.test("rejects lowercase ticket key", async (assert) => {
    const r = await check("feat: [proj-123] add login page");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "subject-ticket"));
  });

  QUnit.test("rejects ticket key longer than 5 letters", async (assert) => {
    const r = await check("feat: [TOOLONG-1] add login page");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "subject-ticket"));
  });

  QUnit.test("rejects description missing after ticket", async (assert) => {
    const r = await check("feat: [NO-TICKET]");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "subject-ticket"));
  });
});

// ---------------------------------------------------------------------------
// type-enum
// ---------------------------------------------------------------------------
QUnit.module("type-enum rule", () => {
  const validTypes = [
    "feat", "fix", "docs", "style", "refactor",
    "perf", "test", "build", "chore", "revert",
  ];

  validTypes.forEach((type) => {
    QUnit.test(`accepts type '${type}'`, async (assert) => {
      const r = await check(`${type}: [NO-TICKET] some change`);
      assert.false(r.errors.some((e) => e.name === "type-enum"), `${type} should be valid`);
    });
  });

  QUnit.test("rejects unknown type 'ci'", async (assert) => {
    const r = await check("ci: [NO-TICKET] configure pipeline");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "type-enum"));
  });

  QUnit.test("rejects unknown type 'wip'", async (assert) => {
    const r = await check("wip: [NO-TICKET] work in progress");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "type-enum"));
  });
});

// ---------------------------------------------------------------------------
// type-case
// ---------------------------------------------------------------------------
QUnit.module("type-case rule", () => {
  QUnit.test("rejects uppercase type", async (assert) => {
    const r = await check("FEAT: [NO-TICKET] add feature");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "type-case"));
  });

  QUnit.test("rejects mixed-case type", async (assert) => {
    const r = await check("Feat: [NO-TICKET] add feature");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "type-case"));
  });
});

// ---------------------------------------------------------------------------
// scope-case
// ---------------------------------------------------------------------------
QUnit.module("scope-case rule", () => {
  QUnit.test("accepts lowercase scope", async (assert) => {
    const r = await check("feat(auth): [NO-TICKET] add oauth");
    assert.false(r.errors.some((e) => e.name === "scope-case"));
  });

  QUnit.test("rejects uppercase scope", async (assert) => {
    const r = await check("feat(Auth): [NO-TICKET] add oauth");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "scope-case"));
  });
});

// ---------------------------------------------------------------------------
// subject-case
// ---------------------------------------------------------------------------
// NOTE: subject-case checks the first character of the subject string.
// Because all subjects are required to start with "[TICKET]", the first
// character is always "[" (not a letter), so commitlint's built-in case
// detection does not trigger on the description portion that follows.
// The rule still rejects a subject that starts directly with an uppercase
// letter (i.e. when no ticket prefix is present), which validates the
// rule is wired correctly.
QUnit.module("subject-case rule", () => {
  QUnit.test(
    "does NOT reject sentence-case description after [NO-TICKET] (known limitation)",
    async (assert) => {
      const r = await check("feat: [NO-TICKET] Add login page");
      // subject-case does not fire when subject starts with '['
      assert.false(
        r.errors.some((e) => e.name === "subject-case"),
        "subject-case is not enforced on the description part after the ticket prefix",
      );
    },
  );

  QUnit.test(
    "does NOT reject UPPER-CASE description after [NO-TICKET] (known limitation)",
    async (assert) => {
      const r = await check("feat: [NO-TICKET] ADD LOGIN PAGE");
      assert.false(
        r.errors.some((e) => e.name === "subject-case"),
        "subject-case is not enforced on the description part after the ticket prefix",
      );
    },
  );

  QUnit.test("rejects sentence-case subject without ticket prefix", async (assert) => {
    // Message also fails subject-ticket, but subject-case error must be present.
    const r = await check("feat: Add login page");
    assert.true(r.errors.some((e) => e.name === "subject-case"));
  });

  QUnit.test("accepts lower-case subject", async (assert) => {
    const r = await check("feat: [NO-TICKET] add login page");
    assert.false(r.errors.some((e) => e.name === "subject-case"));
  });
});

// ---------------------------------------------------------------------------
// subject-full-stop
// ---------------------------------------------------------------------------
QUnit.module("subject-full-stop rule", () => {
  QUnit.test("rejects subject ending with period", async (assert) => {
    const r = await check("fix: [NO-TICKET] correct the bug.");
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "subject-full-stop"));
  });

  QUnit.test("accepts subject without trailing period", async (assert) => {
    const r = await check("fix: [NO-TICKET] correct the bug");
    assert.false(r.errors.some((e) => e.name === "subject-full-stop"));
  });
});

// ---------------------------------------------------------------------------
// header-max-length
// ---------------------------------------------------------------------------
QUnit.module("header-max-length rule", () => {
  QUnit.test("accepts header at exactly 100 characters", async (assert) => {
    // build a subject that lands the header at exactly 100 chars
    // "fix: " = 5 chars, "[NO-TICKET] " = 12 chars → need 83 more
    const subject = "[NO-TICKET] " + "x".repeat(83);
    const r = await check(`fix: ${subject}`);
    assert.false(r.errors.some((e) => e.name === "header-max-length"), "100 chars should be valid");
  });

  QUnit.test("rejects header over 100 characters", async (assert) => {
    const subject = "[NO-TICKET] " + "x".repeat(84);
    const r = await check(`fix: ${subject}`);
    assert.false(r.valid);
    assert.true(r.errors.some((e) => e.name === "header-max-length"));
  });
});

// ---------------------------------------------------------------------------
// body and footer leading blank
// ---------------------------------------------------------------------------
QUnit.module("body-leading-blank rule", () => {
  QUnit.test("warns when body has no leading blank line", async (assert) => {
    const msg = "fix: [NO-TICKET] correct bug\nbody without blank line";
    const r = await check(msg);
    assert.true(r.warnings.some((w) => w.name === "body-leading-blank"));
  });

  QUnit.test("no warning when body has leading blank line", async (assert) => {
    const msg = "fix: [NO-TICKET] correct bug\n\nbody with blank line";
    const r = await check(msg);
    assert.false(r.warnings.some((w) => w.name === "body-leading-blank"));
  });
});

QUnit.module("footer-leading-blank rule", () => {
  QUnit.test("warns when footer has no leading blank line", async (assert) => {
    const msg = "fix: [NO-TICKET] correct bug\n\nbody\nCloses: #1";
    const r = await check(msg);
    assert.true(r.warnings.some((w) => w.name === "footer-leading-blank"));
  });

  QUnit.test("no warning when footer has leading blank line", async (assert) => {
    const msg = "fix: [NO-TICKET] correct bug\n\nbody\n\nCloses: #1";
    const r = await check(msg);
    assert.false(r.warnings.some((w) => w.name === "footer-leading-blank"));
  });
});

// ---------------------------------------------------------------------------
// full valid message
// ---------------------------------------------------------------------------
QUnit.module("full valid message", () => {
  QUnit.test("accepts a complete well-formed commit", async (assert) => {
    const msg = [
      "feat(auth): [PROJ-42] add token refresh rotation",
      "",
      "Rotates the refresh token on each use to reduce the risk",
      "of token theft via replay attacks.",
      "",
      "Closes: #42",
    ].join("\n");

    const r = await check(msg);
    assert.true(r.valid, r.errors.map((e) => e.message).join(", "));
    assert.strictEqual(r.errors.length, 0);
  });
});
