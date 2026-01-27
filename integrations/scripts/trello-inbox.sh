#!/bin/bash
# Trello Inbox Helper - Lists inbox items with resolved card links
# Usage: trello-inbox.sh [personal|software|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/trello-ids.local.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: Missing $ENV_FILE"
    echo ""
    echo "Create it with your Trello list IDs:"
    echo "  PERSONAL_INBOX_ID=your_list_id"
    echo "  SOFTWARE_INBOX_ID=your_list_id"
    exit 1
fi

source "$ENV_FILE"

resolve_card() {
    local name="$1"
    # Check if the name is a trello URL
    if [[ "$name" =~ trello\.com/c/([a-zA-Z0-9]+) ]]; then
        local card_id="${BASH_REMATCH[1]}"
        local result=$(trello-cli --get-card "$card_id" 2>/dev/null)
        if [[ $(echo "$result" | jq -r '.ok') == "true" ]]; then
            echo "$result" | jq -r '.data.name'
            return
        fi
    fi
    echo "$name"
}

list_inbox() {
    local inbox_id="$1"
    local inbox_name="$2"

    echo "=== $inbox_name Inbox ==="
    echo ""

    local cards=$(trello-cli --get-cards "$inbox_id" 2>/dev/null)

    if [[ $(echo "$cards" | jq -r '.ok') != "true" ]]; then
        echo "Error fetching cards"
        return 1
    fi

    local count=$(echo "$cards" | jq '.data | length')
    echo "Found $count items:"
    echo ""

    echo "$cards" | jq -r '.data[] | "\(.id)|\(.name)|\(.url)"' | while IFS='|' read -r id name url; do
        resolved_name=$(resolve_card "$name")
        if [[ "$name" != "$resolved_name" ]]; then
            echo "  - [LINK] $resolved_name"
            echo "    (from: $name)"
        else
            echo "  - $name"
        fi
        echo "    ID: $id"
        echo ""
    done
}

case "${1:-all}" in
    personal)
        list_inbox "$PERSONAL_INBOX_ID" "Personal"
        ;;
    software)
        list_inbox "$SOFTWARE_INBOX_ID" "Software Team"
        ;;
    all)
        list_inbox "$PERSONAL_INBOX_ID" "Personal"
        echo ""
        list_inbox "$SOFTWARE_INBOX_ID" "Software Team"
        ;;
    *)
        echo "Usage: $0 [personal|software|all]"
        exit 1
        ;;
esac
