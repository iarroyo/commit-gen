#!/usr/bin/env bash
# =============================================================================
# lib/vscode.sh — VS Code task installation
# Sourced by setup.sh. Expects GIT_ROOT in scope.
# =============================================================================

install_vscode_task() {
  local VSCODE_DIR="${GIT_ROOT}/.vscode"
  local TASK_FILE="${VSCODE_DIR}/tasks.json"
  local TASK_CONTENT='{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Commit (conventional)",
      "type": "shell",
      "command": "npx --yes github:iarroyo/commit-gen commit",
      "presentation": {
        "reveal": "always",
        "panel": "shared",
        "focus": true
      },
      "problemMatcher": []
    }
  ]
}'

  mkdir -p "${VSCODE_DIR}"

  if [ -f "${TASK_FILE}" ]; then
    local HASH
    HASH=$(file_hash "${TASK_FILE}")
    local BACKUP_PATH="${TASK_FILE}.backup.${HASH}"

    if [ ! -f "${BACKUP_PATH}" ]; then
      cp "${TASK_FILE}" "${BACKUP_PATH}"
      log_warn "Existing tasks.json backed up → $(basename "${BACKUP_PATH}")"
    else
      log_info "Existing tasks.json already backed up with same content (${HASH})"
    fi
  fi

  echo "${TASK_CONTENT}" > "${TASK_FILE}"
  log_success ".vscode/tasks.json installed"
}
