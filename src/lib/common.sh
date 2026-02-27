#!/usr/bin/env bash
# =============================================================================
# lib/common.sh — Shared utilities: colors, logging, file_hash, detect_os
# Sourced by setup.sh and uninstall.sh
# =============================================================================

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

file_hash() {
  local FILE="$1"
  if command -v md5sum &>/dev/null; then
    md5sum "${FILE}" | awk '{print $1}'
  elif command -v md5 &>/dev/null; then
    md5 -q "${FILE}"
  else
    # Fallback: use file size + mtime as a rough discriminator
    stat -c '%s-%Y' "${FILE}" 2>/dev/null || stat -f '%z-%m' "${FILE}"
  fi
}

detect_os() {
  case "$(uname -s)" in
    Darwin*)              echo "macos" ;;
    Linux*)               echo "linux" ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *)                    echo "unknown" ;;
  esac
}
