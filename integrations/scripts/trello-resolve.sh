#!/bin/bash
# Trello Card Resolver - Gets details of a card by ID or short URL code
# Usage: trello-resolve.sh <card-id>

set -e

if [[ -z "$1" ]]; then
    echo "Usage: $0 <card-id>"
    echo "  card-id can be full ID or short code from URL (e.g., MZ72St99)"
    exit 1
fi

result=$(trello-cli --get-card "$1" 2>/dev/null)

if [[ $(echo "$result" | jq -r '.ok') != "true" ]]; then
    echo "Error: Could not fetch card $1"
    exit 1
fi

echo "$result" | jq -r '.data | "Name: \(.name)\nDescription: \(.desc // "(none)")\nURL: \(.url)\nList ID: \(.idList)\nClosed: \(.closed)"'
