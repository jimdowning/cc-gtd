#!/bin/bash
# PreToolUse hook: block any attempt to send email from the container.
# Gmail access is read-only + labelling only.

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // ""')
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Only inspect Bash commands
if [[ "$tool" != "Bash" ]]; then
  exit 0
fi

# Block Gmail API send endpoint (googleapis.com is allowlisted for gcalcli)
if echo "$command" | grep -qiE 'gmail.*messages/send|messages\.send\(|users/me/messages/send'; then
  echo '{"decision":"block","reason":"Email sending is disabled. Gmail access is read-only (scan + label only)."}'
  exit 0
fi

# Block SMTP tools and libraries
if echo "$command" | grep -qiE '\bsendmail\b|\bsmtplib\b|\bnodemailer\b|\bSMTP\(|smtp\.gmail|smtp\.connect|createTransport'; then
  echo '{"decision":"block","reason":"Email sending is disabled. SMTP access is not permitted."}'
  exit 0
fi

# Block the mail/mailx command used to send email
if echo "$command" | grep -qiE '^\s*mail\s+-s\b|^\s*mailx\s'; then
  echo '{"decision":"block","reason":"Email sending is disabled. Use gmail-gtd scan/clear only."}'
  exit 0
fi

exit 0
