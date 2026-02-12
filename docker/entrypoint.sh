#!/usr/bin/env bash
set -euo pipefail

# --- Symlink claude to expected native install path ---
# Claude Code detects installMethod=native and expects the binary at
# /root/.local/bin/claude. Our binary is mounted at /opt/claude/claude.
# /root/.local/bin is a tmpfs mount (writable); directory exists from image.
if [ -x /opt/claude/claude ] && [ ! -e /root/.local/bin/claude ]; then
  ln -s /opt/claude/claude /root/.local/bin/claude
fi
# --- Symlink trello-cli (self-contained .NET binary) ---
if [ -x /opt/trello-cli/TrelloCli ] && [ ! -e /root/.local/bin/trello-cli ]; then
  ln -s /opt/trello-cli/TrelloCli /root/.local/bin/trello-cli
fi
export PATH="/root/.local/bin:$PATH"

# --- Seed .claude.json on the writable bind mount ---
# /root/.claude.json is a symlink (from image) -> /root/.claude/.claude.json (bind mount)
if [ ! -f /root/.claude/.claude.json ]; then
  echo '{}' > /root/.claude/.claude.json
fi

# --- Register Obsidian MCP bridge if configured ---
# Write to the bind-mount path directly — /root/.claude.json is a symlink on the
# read-only root filesystem, so mv would fail trying to replace it.
if [ -n "${OBSIDIAN_MCP_BRIDGE_URL:-}" ]; then
  jq --arg url "$OBSIDIAN_MCP_BRIDGE_URL" \
    '.mcpServers["obsidian-mcp-tools"] = {"type": "sse", "url": $url}' \
    /root/.claude/.claude.json > /tmp/.claude.json.tmp && \
    mv /tmp/.claude.json.tmp /root/.claude/.claude.json
fi

# --- Install gmail-gtd dependencies if needed ---
GMAIL_GTD_DIR="/workspace/cc-gtd/integrations/scripts/gmail-gtd"
if [ -d "$GMAIL_GTD_DIR" ] && [ -f "$GMAIL_GTD_DIR/package.json" ] && [ ! -d "$GMAIL_GTD_DIR/node_modules" ]; then
  echo "Installing gmail-gtd dependencies..."
  (cd "$GMAIL_GTD_DIR" && npm ci --ignore-scripts)
fi

# --- Log tool availability ---
echo "--- Tool availability ---"
for tool in node git jq rg trello-cli tod gcalcli claude; do
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
