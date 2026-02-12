#!/usr/bin/env bash
docker compose -f "$(dirname "$0")/docker-compose.yml" exec -it framework claude --dangerously-skip-permissions "$@"
