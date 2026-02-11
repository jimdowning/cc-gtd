#!/usr/bin/env bash
set -euo pipefail

# --- Symlink claude to expected native install path ---
# Claude Code detects installMethod=native and expects the binary at
# /root/.local/bin/claude. Our binary is mounted at /opt/claude/claude.
if [ -x /opt/claude/claude ] && [ ! -e /root/.local/bin/claude ]; then
  mkdir -p /root/.local/bin
  ln -s /opt/claude/claude /root/.local/bin/claude
fi
export PATH="/root/.local/bin:$PATH"

# --- Seed /root/.claude.json if missing (avoids ENOENT on first run) ---
if [ ! -f /root/.claude.json ]; then
  echo '{}' > /root/.claude.json
fi

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

# If arguments are passed, run claude directly (e.g. docker compose run framework)
# Otherwise, keep the container alive for 'docker compose exec' usage
if [ $# -gt 0 ]; then
  exec claude "$@"
else
  echo "Container ready. Use: docker compose exec -it framework claude"
  exec sleep infinity
fi
