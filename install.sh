#!/usr/bin/env bash
# install.sh — claude-agent-mesh project installer
# Copies .claude/commands/ into the target project directory.
# Does NOT install to ~/.claude/ — this is a project-only plugin.
#
# Usage:
#   ./install.sh                    # install into current directory
#   ./install.sh --dir=/path/to/project

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

ok()   { echo -e "${GREEN}✓${RESET} $*"; }
info() { echo -e "${CYAN}→${RESET} $*"; }
warn() { echo -e "${YELLOW}⚠${RESET} $*"; }

# ── Parse arguments ───────────────────────────────────────────────────────────
TARGET_DIR="$(pwd)"

for arg in "$@"; do
  case "$arg" in
    --dir=*) TARGET_DIR="${arg#--dir=}" ;;
    -h|--help)
      echo "Usage: ./install.sh [--dir=/path/to/project]"
      echo "Installs claude-agent-mesh commands into the target project."
      exit 0
      ;;
    *)
      warn "Unknown argument: $arg"
      ;;
  esac
done

# Resolve source directory (location of this script)
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BOLD}claude-agent-mesh installer${RESET}"
echo -e "Source:  ${SOURCE_DIR}"
echo -e "Target:  ${TARGET_DIR}"
echo ""

# ── Validate target ───────────────────────────────────────────────────────────
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: target directory does not exist: $TARGET_DIR"
  exit 1
fi

# ── Create .claude/commands in target ────────────────────────────────────────
TARGET_COMMANDS="${TARGET_DIR}/.claude/commands"
mkdir -p "$TARGET_COMMANDS"
info "Ensuring ${TARGET_COMMANDS} exists"

# ── Copy commands ─────────────────────────────────────────────────────────────
COMMANDS_SOURCE="${SOURCE_DIR}/.claude/commands"
COPIED=0
SKIPPED=0

for cmd_file in "${COMMANDS_SOURCE}"/*.md; do
  filename="$(basename "$cmd_file")"
  dest="${TARGET_COMMANDS}/${filename}"

  if [[ -f "$dest" ]]; then
    warn "Skipping ${filename} (already exists)"
    SKIPPED=$((SKIPPED + 1))
  else
    cp "$cmd_file" "$dest"
    ok "Installed ${filename}"
    COPIED=$((COPIED + 1))
  fi
done

# ── Add .gitignore entries ─────────────────────────────────────────────────────
GITIGNORE="${TARGET_DIR}/.gitignore"
ADDED_GITIGNORE=0

add_gitignore_entry() {
  local entry="$1"
  if [[ -f "$GITIGNORE" ]] && grep -qxF "$entry" "$GITIGNORE" 2>/dev/null; then
    return
  fi
  echo "$entry" >> "$GITIGNORE"
  ok "Added ${entry} to .gitignore"
  ADDED_GITIGNORE=$((ADDED_GITIGNORE + 1))
}

add_gitignore_entry ".mesh/"
add_gitignore_entry ".mesh-archive/"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Done.${RESET}"
echo -e "  Commands installed: ${GREEN}${COPIED}${RESET}"
[[ $SKIPPED -gt 0 ]] && echo -e "  Commands skipped:   ${YELLOW}${SKIPPED}${RESET} (already present)"
[[ $ADDED_GITIGNORE -gt 0 ]] && echo -e "  .gitignore entries: ${GREEN}${ADDED_GITIGNORE}${RESET}"
echo ""
echo -e "Run ${CYAN}/mesh your task here${RESET} in Claude Code to start."
echo ""
