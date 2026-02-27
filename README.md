# @iarroyo/commit-gen

Shared [Conventional Commits](https://www.conventionalcommits.org) tooling for all projects in the org — regardless of tech stack (Frontend, Java/Gradle, .NET, etc.).

Provides:
- **Interactive commit prompt** via [commitizen](https://github.com/commitizen/cz-cli) + [cz-customizable](https://github.com/leoforfree/cz-customizable)
- **Commit message validation** via [commitlint](https://commitlint.js.org)
- **Git hooks** (`commit-msg`, `prepare-commit-msg`) installed with no extra tooling in consumer projects

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Git | Any recent version |
| Node.js + npx | v5.2+ (npx is bundled with Node) |

> **Windows users:** use Git Bash or WSL. Native CMD/PowerShell do not execute `.git/hooks` shell scripts.

---

## Consumer project setup

From the root of any project (frontend, Java, .NET — any stack), run:

```bash
npx github:iarroyo/commit-gen setup
```

No registry authentication required. npx fetches the package directly from the GitHub repository.

To pin to a specific version or branch:

```bash
npx github:iarroyo/commit-gen#v1.0.0 setup
npx github:iarroyo/commit-gen#main setup
```

If your project uses a custom hooks directory (e.g. [Husky](https://typicode.github.io/husky)), pass it with `--hooks-dir`:

```bash
npx github:iarroyo/commit-gen setup --hooks-dir .husky
npx github:iarroyo/commit-gen setup --hooks-dir=.husky
```

Relative paths are resolved from the repository root. Absolute paths are used as-is. The default is `.git/hooks`.

The script will:

1. Verify you are inside a Git repository
2. Check that Node.js and npx are available
3. Install the `commit-msg` Git hook — validates every commit message
4. Install the `prepare-commit-msg` Git hook — launches the interactive prompt on `git commit`

> Existing hooks are backed up as `<hook-name>.backup.<hash>` before being replaced. The hash is derived from the file content, so re-running setup never overwrites a backup with a different hash, and identical content is never backed up twice.

### What gets added to the consumer project

```
<project-root>/
└── .git/hooks/
    ├── commit-msg          # runs commitlint validation
    └── prepare-commit-msg  # runs commitizen interactive prompt
```

---

## Developer workflow

Once setup is complete, the normal `git commit` command is all developers need:

```
git commit
    │
    ▼
prepare-commit-msg hook
    │
    ▼
commitizen interactive prompt
  ? Select the type of change:  feat
  ? Scope (optional):           auth
  ? Short description:          [AUTH-42] add token refresh rotation
  ? Breaking change?            No
    │
    ▼
commit message written → feat(auth): [AUTH-42] add token refresh rotation
    │
    ▼
commit-msg hook
    │
    ▼
commitlint validates the message
  ✔ valid  → commit proceeds
  ✖ invalid → commit blocked, error shown
```

To skip the interactive prompt and commit directly:

```bash
git commit -m "feat(auth): [AUTH-42] add token refresh rotation"
```

---

## Commit message format

```
<type>(<scope>): [<TICKET-ID>|NO-TICKET] <description>

[optional body]

[optional footer]
```

**Subject prefix is mandatory.** Use a Jira-style ticket ID (`PROJ-123`) or `NO-TICKET` when there is no associated ticket.

Examples:

```
feat(auth): [AUTH-42] add token refresh rotation
fix(cart): [SHOP-99] prevent double checkout submission
chore: [NO-TICKET] bump dependency versions
```

### Allowed types

| Type | Description |
|---|---|
| `feat` | Adding a new feature |
| `fix` | Fixing a bug |
| `refactor` | Apply code changes without changing its behaviour or fixing a bug |
| `test` | Updating or improving tests |
| `docs` | Updating or improving documentation |
| `build` | Updating build scripts or dependencies |
| `chore` | Other changes, for example: bump version number |
| `revert` | Reverting a change |
| `style` | Formatting, no logic change |
| `perf` | Improving performance |

### Rules enforced by commitlint

| Rule | Requirement |
|---|---|
| `type-enum` | Type must be one of the allowed values above |
| `type-case` | Type must be lower-case |
| `scope-case` | Scope must be lower-case |
| `subject-empty` | Subject is required |
| `subject-ticket` | Subject must start with `[TICKET-ID]` or `[NO-TICKET]` |
| `subject-case` | Subject must not be sentence-case, PascalCase, or UPPER-CASE |
| `subject-full-stop` | Subject must not end with a period |
| `header-max-length` | Header must be ≤ 100 characters |

---

## Per-project customization

Commit types, scopes, and validation rules are defined in this repo. To adjust them for all projects, edit `src/cz-config.js` (prompt) and `src/commitlint.config.js` (rules), then tag a new release and update the `#ref` in each consumer project's hooks.

---

## Uninstall

From the root of any consumer project, run:

```bash
npx github:iarroyo/commit-gen uninstall
```

The script only removes hooks that contain the `setup.sh managed` marker. Any hook that was not installed by this tool is left untouched with a warning.

If you installed with a custom `--hooks-dir`, pass the same path to uninstall:

```bash
npx github:iarroyo/commit-gen uninstall --hooks-dir .husky
```

---

## Repository structure

```
commit-gen/
├── package.json           # package definition, bin entry, publishConfig
├── index.js               # npx entrypoint — dispatches setup | uninstall | commit | lint
├── src/
│   ├── cli.js             # commitizen interactive prompt
│   ├── lint.js            # commitlint validation
│   ├── setup.js           # invokes setup.sh
│   ├── setup.sh           # onboarding script — installs hooks in consumer projects
│   ├── uninstall.js       # invokes uninstall.sh
│   ├── uninstall.sh       # removes managed hooks from consumer projects
│   ├── cz-adapter.js      # commitizen adapter — loads cz-config directly
│   ├── cz-config.js       # prompt configuration (types, messages, options)
│   └── commitlint.config.js  # shared validation rules
└── test/
    └── commitlint.test.js # QUnit tests for all commitlint rules
```
