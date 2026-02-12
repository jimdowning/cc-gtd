#!/usr/bin/env bash
set -euo pipefail

# Start/stop an mcp-proxy bridge that exposes the Obsidian MCP stdio server
# as an SSE endpoint on localhost. The container reaches this via
# host.docker.internal.
#
# Usage:
#   ./start-obsidian-bridge.sh          # start the bridge
#   ./start-obsidian-bridge.sh --stop   # stop a running bridge

CLAUDE_JSON="$HOME/.claude.json"
MCP_KEY="obsidian-mcp-tools"
DEFAULT_PORT=8787

PORT="${OBSIDIAN_BRIDGE_PORT:-$DEFAULT_PORT}"
PIDFILE="${TMPDIR:-/tmp}/obsidian-mcp-bridge.pid"

# Read MCP server config from ~/.claude.json (single source of truth)
if [ ! -f "$CLAUDE_JSON" ]; then
  echo "Error: $CLAUDE_JSON not found" >&2
  exit 1
fi

MCP_SERVER="${OBSIDIAN_MCP_SERVER:-$(jq -r --arg k "$MCP_KEY" '.mcpServers[$k].command // empty' "$CLAUDE_JSON")}"
OBSIDIAN_API_KEY="${OBSIDIAN_API_KEY:-$(jq -r --arg k "$MCP_KEY" '.mcpServers[$k].env.OBSIDIAN_API_KEY // empty' "$CLAUDE_JSON")}"
export OBSIDIAN_API_KEY

stop_bridge() {
  if [ -f "$PIDFILE" ]; then
    pid=$(cat "$PIDFILE")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      echo "Stopped bridge (PID $pid)"
    else
      echo "Bridge not running (stale PID file)"
    fi
    rm -f "$PIDFILE"
  else
    echo "No PID file found — bridge not running"
  fi
}

if [ "${1:-}" = "--stop" ]; then
  stop_bridge
  exit 0
fi

# Preflight checks
if [ -z "${OBSIDIAN_API_KEY:-}" ]; then
  echo "Error: OBSIDIAN_API_KEY not found in $CLAUDE_JSON or environment" >&2
  exit 1
fi

if [ -z "$MCP_SERVER" ] || [ ! -x "$MCP_SERVER" ]; then
  echo "Error: MCP server not found or not executable: ${MCP_SERVER:-<empty>}" >&2
  echo "Check $MCP_KEY config in $CLAUDE_JSON or set OBSIDIAN_MCP_SERVER" >&2
  exit 1
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "Error: npx not found — install Node.js" >&2
  exit 1
fi

# Stop any existing bridge first
if [ -f "$PIDFILE" ]; then
  stop_bridge
fi

# Start the bridge as a detached background process
# Binds to 127.0.0.1 — Docker Desktop forwards host.docker.internal to the
# host's loopback, so this is reachable from containers but not the LAN.
LOGFILE="${TMPDIR:-/tmp}/obsidian-mcp-bridge.log"
nohup npx -y mcp-proxy --host 127.0.0.1 --port "$PORT" --server sse -- "$MCP_SERVER" \
  > "$LOGFILE" 2>&1 &
BRIDGE_PID=$!
disown "$BRIDGE_PID"
echo "$BRIDGE_PID" > "$PIDFILE"

echo "Obsidian MCP bridge started (PID $BRIDGE_PID) on http://127.0.0.1:${PORT}/sse"
echo "Log: $LOGFILE"
echo "Stop with: $0 --stop"
