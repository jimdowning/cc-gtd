#!/bin/bash
# PreToolUse hook: block commands that would display credential file contents
# or dump environment variables containing secrets.
#
# Tools that USE credentials internally (trello, gcalcli, node gmail-gtd, etc.)
# are unaffected — this only blocks commands that would expose credential
# content to stdout.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Credential file paths (regex)
CRED_PATHS='(/root/\.trello-cli|/credentials/gcalcli|/root/\.local/share/gcalcli|integrations/scripts/gmail-gtd/[^/]+$)'

# Block: file-reading commands targeting credential paths
if echo "$command" | grep -qE '(cat|less|head|tail|more|strings|xxd|od|base64)\s' && \
   echo "$command" | grep -qE "$CRED_PATHS"; then
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","additionalContext":"Blocked: direct read of credential file."}}
EOF
  exit 0
fi

# Block: echo/printf expanding credential env vars
if echo "$command" | grep -qE '(echo|printf)\s.*\$(ANTHROPIC_API_KEY|ASANA_ACCESS_TOKEN)'; then
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","additionalContext":"Blocked: credential environment variable would be exposed."}}
EOF
  exit 0
fi

# Block: unfiltered environment dumps
if echo "$command" | grep -qE '^\s*(env|printenv|set)\s*($|\|)'; then
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","additionalContext":"Blocked: environment dump would expose credentials."}}
EOF
  exit 0
fi

# Allow everything else
exit 0
