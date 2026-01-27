#!/bin/bash
# Clear the 'gtd' label from Gmail messages after capture.
# Usage: gmail-clear-label.sh <account-email> <uid> [uid...]
node "$(dirname "$0")/gmail-gtd/index.js" clear "$@"
