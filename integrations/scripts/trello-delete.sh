#!/bin/bash
# Trello Card Delete - Deletes a card permanently
# Usage: trello-delete.sh <card-id>

set -e

if [[ -z "$1" ]]; then
    echo "Usage: $0 <card-id>"
    exit 1
fi

# First get the card name for confirmation
card_info=$(trello-cli --get-card "$1" 2>/dev/null)
if [[ $(echo "$card_info" | jq -r '.ok') != "true" ]]; then
    echo "Error: Could not fetch card $1"
    exit 1
fi

card_name=$(echo "$card_info" | jq -r '.data.name')
echo "Deleting card: $card_name"

result=$(trello-cli --delete-card "$1" 2>/dev/null)

if [[ $(echo "$result" | jq -r '.ok') != "true" ]]; then
    echo "Error: Could not delete card"
    echo "$result" | jq -r '.error // "Unknown error"'
    exit 1
fi

echo "Card deleted successfully"
