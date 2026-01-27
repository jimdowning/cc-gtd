#!/bin/bash
# Trello Card Mover - Moves a card to a specified list
# Usage: trello-move.sh <card-id> <list-id>

set -e

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <card-id> <list-id>"
    echo ""
    echo "List IDs: See integrations/config.local.md for your board list mappings"
    exit 1
fi

result=$(trello-cli --move-card "$1" "$2" 2>/dev/null)

if [[ $(echo "$result" | jq -r '.ok') != "true" ]]; then
    echo "Error: Could not move card"
    echo "$result" | jq -r '.error // "Unknown error"'
    exit 1
fi

echo "Card moved successfully"
echo "$result" | jq -r '.data | "Card: \(.name)\nNew List: \(.idList)"'
