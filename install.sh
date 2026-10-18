#!/usr/bin/env bash
# Installs track, todo and hook-status into ~/.timetrack/bin and (optionally)
# the /timer command for Claude Code. Never overwrites existing files unless
# you pass --force, and never touches your log or task data.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
TT_DIR="${TT_DIR:-$HOME/.timetrack}"
BIN="$TT_DIR/bin"
CMD_DIR="$HOME/.claude/commands"
FORCE="no"; [ "${1:-}" = "--force" ] && FORCE="yes"

place() {  # place <source> <dest>
  if [ -e "$2" ] && [ "$FORCE" = "no" ]; then
    echo "skip   $2 (already exists; rerun with --force to replace)"
  else
    cp "$1" "$2"; chmod +x "$2" 2>/dev/null || true
    echo "added  $2"
  fi
}

mkdir -p "$BIN"
place "$SRC/track" "$BIN/track"
place "$SRC/todo" "$BIN/todo"
place "$SRC/hooks/hook-status" "$BIN/hook-status"

if [ -d "$HOME/.claude" ]; then
  mkdir -p "$CMD_DIR"
  place "$SRC/claude/commands/timer.md" "$CMD_DIR/timer.md"
fi

cat <<EOF

Done. Next steps:
  1. Add aliases to your shell profile (~/.zshrc or ~/.bashrc):
       alias track="$BIN/track"
       alias todo="$BIN/todo"
  2. Optional, for Claude Code: add the hooks in README.md to ~/.claude/settings.json.
Your data lives in $TT_DIR (log.csv, active, todos.tsv).
EOF
