#!/bin/bash
# PreToolUse hook: restrict gcalcli to read-only operations.
# Blocks: add, quick, delete, edit, import (write operations)
# Allows: agenda, list, search, calw, calm, updates, conflicts, remind, config, util

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

if echo "$command" | grep -qE 'gcalcli\s+(add|quick|delete|edit|import)\b'; then
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","additionalContext":"Blocked: gcalcli write operations are disabled in the container. Calendar is read-only."}}
EOF
  exit 0
fi

exit 0
