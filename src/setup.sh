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
GITHUB_REPO="iarroyo/commit-gen"
PACKAGE="github:${GITHUB_REPO}"
# To pin to a specific tag or branch, append a ref:
#   PACKAGE="github:${GITHUB_REPO}#v1.0.0"

# -----------------------------------------------------------------------------
# Arguments
# -----------------------------------------------------------------------------
HOOKS_DIR_OVERRIDE=""
INSTALL_VSCODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hooks-dir)
      [[ -z "${2:-}" ]] && { echo "Error: --hooks-dir requires a value" >&2; exit 1; }
      HOOKS_DIR_OVERRIDE="$2"
      shift 2
      ;;
    --hooks-dir=*)
      HOOKS_DIR_OVERRIDE="${1#*=}"
      shift
      ;;
    --vscode)
      INSTALL_VSCODE=true
      shift
      ;;
    *)
      echo "Error: unknown argument '$1'" >&2
      echo "Usage: setup [--hooks-dir <path>] [--vscode]" >&2
      exit 1
      ;;
  esac
done

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
source "$(dirname "$0")/lib/common.sh"

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
log_success "Git repository found at: ${GIT_ROOT}"

if [ -n "${HOOKS_DIR_OVERRIDE}" ]; then
  # Resolve relative paths against the git root
  if [[ "${HOOKS_DIR_OVERRIDE}" = /* ]]; then
    HOOKS_DIR="${HOOKS_DIR_OVERRIDE}"
  else
    HOOKS_DIR="${GIT_ROOT}/${HOOKS_DIR_OVERRIDE}"
  fi
  log_info "Using custom hooks directory: ${HOOKS_DIR}"
else
  HOOKS_DIR="${GIT_ROOT}/.git/hooks"
fi

mkdir -p "${HOOKS_DIR}"

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
source "$(dirname "$0")/lib/hooks.sh"
install_hooks

# -----------------------------------------------------------------------------
# Step 4 (optional) — Install VS Code task
# -----------------------------------------------------------------------------
if [ "${INSTALL_VSCODE}" = true ]; then
  log_step "Installing VS Code task"
  source "$(dirname "$0")/lib/vscode.sh"
  install_vscode_task
fi

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
if [ "${INSTALL_VSCODE}" = true ]; then
  echo -e "  • In VS Code: ${BOLD}⇧⌘P${RESET} → Tasks: Run Task → ${BOLD}Commit (conventional)${RESET}"
fi
echo ""
echo -e "  ${BOLD}To uninstall:${RESET} delete .git/hooks/commit-msg and .git/hooks/prepare-commit-msg"
echo ""
