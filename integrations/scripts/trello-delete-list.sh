#!/bin/bash
# Trello Bulk Delete - Delete all cards passed as arguments or from stdin
# Usage:
#   trello-delete-list.sh <card-id1> <card-id2> ...
#   echo "id1 id2 id3" | trello-delete-list.sh
#   trello-delete-list.sh --list <list-id>  # Delete all cards in a list

set -e

delete_card() {
    local id="$1"
    local result=$(trello-cli --delete-card "$id" 2>/dev/null)
    if [[ $(echo "$result" | jq -r '.ok') == "true" ]]; then
        echo "Deleted: $id"
    else
        echo "Failed: $id - $(echo "$result" | jq -r '.error // "Unknown error"')"
    fi
}

# Handle --list option
if [[ "$1" == "--list" ]]; then
    if [[ -z "$2" ]]; then
        echo "Usage: $0 --list <list-id>"
        exit 1
    fi

    list_id="$2"
    echo "Fetching cards from list $list_id..."
    cards=$(trello-cli --get-cards "$list_id" 2>/dev/null)

    if [[ $(echo "$cards" | jq -r '.ok') != "true" ]]; then
        echo "Error fetching cards from list"
        exit 1
    fi

    count=$(echo "$cards" | jq '.data | length')
    echo "Found $count cards to delete"
    echo ""

    echo "$cards" | jq -r '.data[].id' | while read -r id; do
        delete_card "$id"
    done

    echo ""
    echo "Done"
    exit 0
fi

# Handle card IDs from arguments
if [[ $# -gt 0 ]]; then
    for id in "$@"; do
        delete_card "$id"
    done
    exit 0
fi

# Handle card IDs from stdin
while read -r line; do
    for id in $line; do
        delete_card "$id"
    done
done

echo "Done"
