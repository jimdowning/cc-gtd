#!/usr/bin/env bash
set -euo pipefail

# --- Claude Code binary integrity check ---
EXPECTED_CHECKSUM=$(cat /etc/claude-expected-checksum)
CLAUDE_BIN=$(readlink -f /root/.local/bin/claude)
ACTUAL_CHECKSUM=$(sha256sum "$CLAUDE_BIN" | awk '{print $1}')

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
  echo "FATAL: Claude Code binary checksum mismatch" >&2
  echo "  Expected: $EXPECTED_CHECKSUM" >&2
  echo "  Actual:   $ACTUAL_CHECKSUM" >&2
  echo "  Binary may have been tampered with." >&2
  echo "  Rebuild the image: docker compose build framework" >&2
  exit 1
fi
echo "Claude Code checksum verified: $ACTUAL_CHECKSUM"

# --- Install gmail-gtd dependencies if needed ---
GMAIL_GTD_DIR="/workspace/cc-gtd/integrations/scripts/gmail-gtd"
if [ -d "$GMAIL_GTD_DIR" ] && [ -f "$GMAIL_GTD_DIR/package.json" ] && [ ! -d "$GMAIL_GTD_DIR/node_modules" ]; then
  echo "Installing gmail-gtd dependencies..."
  (cd "$GMAIL_GTD_DIR" && npm ci --ignore-scripts)
fi

# --- Log tool availability ---
echo "--- Tool availability ---"
for tool in node git jq rg trello tod gcalcli claude; do
  if command -v "$tool" >/dev/null 2>&1; then
    version=$("$tool" --version 2>/dev/null | head -1 || echo "available")
    echo "  $tool: $version"
  else
    echo "  $tool: NOT FOUND"
  fi
done
echo "-------------------------"

exec claude "$@"
