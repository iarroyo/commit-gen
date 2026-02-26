#!/usr/bin/env bash
# =============================================================================
# setup.sh — Conventional Commits tooling setup
# Installs Git hooks for commitlint validation and commitizen prompt
# Compatible with macOS and Windows (Git Bash / WSL)
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------
GITHUB_REPO="iarroyo/commit-config"
PACKAGE="github:${GITHUB_REPO}"
# To pin to a specific tag or branch, append a ref:
#   PACKAGE="github:${GITHUB_REPO}#v1.0.0"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

log_info()    { echo -e "${BLUE}ℹ${RESET}  $1"; }
log_success() { echo -e "${GREEN}✔${RESET}  $1"; }
log_warn()    { echo -e "${YELLOW}⚠${RESET}  $1"; }
log_error()   { echo -e "${RED}✖${RESET}  $1"; exit 1; }
log_step()    { echo -e "\n${BOLD}▶ $1${RESET}"; }

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Darwin*)              echo "macos" ;;
    Linux*)               echo "linux" ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *)                    echo "unknown" ;;
  esac
}

OS=$(detect_os)
log_info "Detected OS: ${OS}"

# -----------------------------------------------------------------------------
# Step 1 — Verify we are inside a Git repository
# -----------------------------------------------------------------------------
log_step "Checking Git repository"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  log_error "Not a Git repository. Please run this script from the root of your project."
fi

GIT_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="${GIT_ROOT}/.git/hooks"
log_success "Git repository found at: ${GIT_ROOT}"

# -----------------------------------------------------------------------------
# Step 2 — Verify Node.js and npx are available
# -----------------------------------------------------------------------------
log_step "Checking Node.js / npx"

if ! command -v node &> /dev/null; then
  log_error "Node.js is not installed or not in PATH. Please install it from https://nodejs.org"
fi

if ! command -v npx &> /dev/null; then
  log_error "npx is not available. Please update Node.js to a version that includes npx (v5.2+)."
fi

NODE_VERSION=$(node --version)
log_success "Node.js ${NODE_VERSION} found"

# -----------------------------------------------------------------------------
# Step 3 — Install Git hooks
# -----------------------------------------------------------------------------

install_hook() {
  local HOOK_PATH="$1"
  local HOOK_CONTENT="$2"
  local HOOK_NAME
  HOOK_NAME=$(basename "${HOOK_PATH}")

  if [ -f "${HOOK_PATH}" ]; then
    if grep -q "setup.sh managed" "${HOOK_PATH}" 2>/dev/null; then
      log_success "${HOOK_NAME} hook already managed by setup.sh — skipping"
      return
    fi
    cp "${HOOK_PATH}" "${HOOK_PATH}.backup"
    log_warn "Existing ${HOOK_NAME} hook backed up to ${HOOK_PATH}.backup"
  fi

  echo "${HOOK_CONTENT}" > "${HOOK_PATH}"
  chmod +x "${HOOK_PATH}"
  log_success "${HOOK_NAME} hook installed"
}

# --- commit-msg hook (commitlint validation) ----------------------------------
log_step "Installing commit-msg hook"

COMMIT_MSG_CONTENT='#!/usr/bin/env bash
# setup.sh managed — do not remove this comment
#
# commit-msg hook: validates the commit message against conventional commits rules
# using github:'"${GITHUB_REPO}"' via npx (no local install required)

npx --yes '"${PACKAGE}"' lint "$1"
exit $?
'

install_hook "${HOOKS_DIR}/commit-msg" "${COMMIT_MSG_CONTENT}"

# --- prepare-commit-msg hook (commitizen interactive prompt) ------------------
log_step "Installing prepare-commit-msg hook"

PREPARE_CONTENT='#!/usr/bin/env bash
# setup.sh managed — do not remove this comment
#
# prepare-commit-msg hook: launches the interactive commitizen prompt
# when running a plain `git commit` (skips for merge commits, fixups, etc.)

COMMIT_SOURCE="${2:-}"
if [ -n "${COMMIT_SOURCE}" ]; then
  exit 0
fi

if [ -s "$1" ]; then
  exit 0
fi

exec < /dev/tty
npx --yes '"${PACKAGE}"' commit --hook || true
'

install_hook "${HOOKS_DIR}/prepare-commit-msg" "${PREPARE_CONTENT}"

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}${BOLD}✔ Setup complete!${RESET}"
echo ""
echo -e "  ${BOLD}How it works:${RESET}"
echo -e "  • Run ${BOLD}git commit${RESET} as usual — the interactive prompt will guide you"
echo -e "  • Or write your message manually — it will be validated on save"
echo -e "  • To commit non-interactively: ${BOLD}git commit -m 'feat(scope): message'${RESET}"
echo ""
echo -e "  ${BOLD}To uninstall:${RESET} delete .git/hooks/commit-msg and .git/hooks/prepare-commit-msg"
echo ""
