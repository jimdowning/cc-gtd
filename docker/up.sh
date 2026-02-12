#!/usr/bin/env bash
set -euo pipefail

# Wrapper around docker compose up that starts the Obsidian MCP bridge first.
# Usage:
#   ./up.sh          # start bridge + containers (detached)
#   ./up.sh --down   # stop containers + bridge

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "${1:-}" = "--down" ]; then
  docker compose -f "$SCRIPT_DIR/docker-compose.yml" down
  "$SCRIPT_DIR/start-obsidian-bridge.sh" --stop
  exit 0
fi

"$SCRIPT_DIR/start-obsidian-bridge.sh"
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d "$@"
