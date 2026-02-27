#!/usr/bin/env bash
# =============================================================================
# uninstall.sh — Remove Git hooks installed by setup.sh
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Arguments
# -----------------------------------------------------------------------------
HOOKS_DIR_OVERRIDE=""

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
    *)
      echo "Error: unknown argument '$1'" >&2
      echo "Usage: uninstall [--hooks-dir <path>]" >&2
      exit 1
      ;;
  esac
done

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
source "$(dirname "$0")/lib/common.sh"

# -----------------------------------------------------------------------------
# Step 1 — Verify Git repository
# -----------------------------------------------------------------------------
log_step "Checking Git repository"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  log_error "Not a Git repository. Please run this script from the root of your project."
fi

GIT_ROOT=$(git rev-parse --show-toplevel)
log_success "Git repository found at: ${GIT_ROOT}"

if [ -n "${HOOKS_DIR_OVERRIDE}" ]; then
  if [[ "${HOOKS_DIR_OVERRIDE}" = /* ]]; then
    HOOKS_DIR="${HOOKS_DIR_OVERRIDE}"
  else
    HOOKS_DIR="${GIT_ROOT}/${HOOKS_DIR_OVERRIDE}"
  fi
  log_info "Using custom hooks directory: ${HOOKS_DIR}"
else
  HOOKS_DIR="${GIT_ROOT}/.git/hooks"
fi

# -----------------------------------------------------------------------------
# Step 2 — Remove managed hooks
# -----------------------------------------------------------------------------
log_step "Removing hooks"

MANAGED_MARKER="setup.sh managed"
HOOKS=("commit-msg" "prepare-commit-msg")
REMOVED=0
SKIPPED=0

for HOOK_NAME in "${HOOKS[@]}"; do
  HOOK_PATH="${HOOKS_DIR}/${HOOK_NAME}"

  if [ ! -f "${HOOK_PATH}" ]; then
    log_info "${HOOK_NAME}: not found, nothing to remove"
    continue
  fi

  if ! grep -qF "${MANAGED_MARKER}" "${HOOK_PATH}"; then
    log_warn "${HOOK_NAME}: not managed by commit-gen — skipped (remove manually if needed)"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  rm "${HOOK_PATH}"
  log_success "${HOOK_NAME} removed"
  REMOVED=$((REMOVED + 1))
done

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
if [ "${SKIPPED}" -gt 0 ]; then
  echo -e "${YELLOW}${BOLD}⚠ Uninstall complete with warnings.${RESET}"
  echo -e "  ${SKIPPED} hook(s) were not removed because they are not managed by commit-gen."
else
  echo -e "${GREEN}${BOLD}✔ Uninstall complete.${RESET}"
fi
echo -e "  ${REMOVED} hook(s) removed from ${HOOKS_DIR}"
echo ""
