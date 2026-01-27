#!/bin/bash
# Pre-commit hook: surface staged diff to Claude for sensitive data review.
#
# This hook intercepts git commit commands and provides the staged diff
# as additional context, asking Claude to review for personal information,
# sensitive data, or individual-specific configuration before committing.
#
# Returns "ask" decision so Claude evaluates the diff with AI judgment
# rather than brittle regex patterns.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Only intercept git commit commands
if ! echo "$command" | grep -qE '^git\s+commit'; then
  exit 0
fi

# Get staged diff
diff=$(git diff --cached --no-color 2>/dev/null)

if [ -z "$diff" ]; then
  exit 0
fi

# Return the diff as additional context with an "ask" decision
# so Claude reviews it before proceeding
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "additionalContext": "SENSITIVE DATA CHECK: Before committing, review the staged diff below for personal information, sensitive data, or individual-specific configuration that should NOT be in version-controlled files. This includes: real email addresses (not examples), API keys/tokens/passwords, Trello member IDs or board IDs tied to specific people, account-specific configuration, real names tied to account data. If any such data is found, ABORT the commit and suggest refactoring to keep that data in .local.md files, .local.json files, or gitignored paths instead. Documentation examples using placeholder data (like you@example.com or 'xxxx xxxx') are fine.\n\nStaged diff:\n$(echo "$diff" | head -500 | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' '\\' | sed 's/\\/\\n/g')"
  }
}
EOF
