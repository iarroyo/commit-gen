#!/usr/bin/env bash
# =============================================================================
# lib/hooks.sh — Git hook installation
# Sourced by setup.sh. Expects GITHUB_REPO, PACKAGE, HOOKS_DIR in scope.
# =============================================================================

install_hook() {
  local HOOK_PATH="$1"
  local HOOK_CONTENT="$2"
  local HOOK_NAME
  HOOK_NAME=$(basename "${HOOK_PATH}")

  if [ -f "${HOOK_PATH}" ]; then
    local HASH
    HASH=$(file_hash "${HOOK_PATH}")
    local BACKUP_PATH="${HOOK_PATH}.backup.${HASH}"

    if [ ! -f "${BACKUP_PATH}" ]; then
      cp "${HOOK_PATH}" "${BACKUP_PATH}"
      log_warn "Existing ${HOOK_NAME} backed up → $(basename "${BACKUP_PATH}")"
    else
      log_info "Existing ${HOOK_NAME} already backed up with same content (${HASH})"
    fi
  fi

  echo "${HOOK_CONTENT}" > "${HOOK_PATH}"
  chmod +x "${HOOK_PATH}"
  log_success "${HOOK_NAME} hook installed"
}

install_hooks() {
  # --- commit-msg hook (commitlint validation) --------------------------------
  log_step "Installing commit-msg hook"

  local COMMIT_MSG_CONTENT='#!/usr/bin/env bash
# setup.sh managed — do not remove this comment
#
# commit-msg hook: validates the commit message against conventional commits rules
# using github:'"${GITHUB_REPO}"' via npx (no local install required)

npx --yes '"${PACKAGE}"' lint "$1"
exit $?
'

  install_hook "${HOOKS_DIR}/commit-msg" "${COMMIT_MSG_CONTENT}"

  # --- prepare-commit-msg hook (commitizen interactive prompt) ----------------
  log_step "Installing prepare-commit-msg hook"

  local PREPARE_CONTENT='#!/usr/bin/env bash
# setup.sh managed — do not remove this comment
#
# prepare-commit-msg hook: launches the interactive commitizen prompt
# when running a plain `git commit` (skips for merge commits, fixups, etc.)

COMMIT_SOURCE="${2:-}"
if [ -n "${COMMIT_SOURCE}" ]; then
  exit 0
fi

# VS Code'"'"'s git process has no TTY — skip the interactive prompt.
# Use the "Commit (conventional)" VS Code task instead.
if [ -n "${VSCODE_GIT_IPC_HANDLE:-}" ]; then
  exit 0
fi

exec < /dev/tty
npx --yes '"${PACKAGE}"' commit --hook || true
'

  install_hook "${HOOKS_DIR}/prepare-commit-msg" "${PREPARE_CONTENT}"
}
