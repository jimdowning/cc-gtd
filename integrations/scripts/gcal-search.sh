#!/bin/bash
# Search for calendar events and output structured format
# Usage: gcal-search.sh "search term" [calendar]
#
# Outputs events with details in a parseable format

set -e

SEARCH_TERM="$1"
CALENDAR="${2:-jim.downing@cyclopsmarine.com}"

if [[ -z "$SEARCH_TERM" ]]; then
    echo "Usage: $0 \"search term\" [calendar]"
    exit 1
fi

# Search for events with full details
# --nocolor removes ANSI codes for easier parsing
gcalcli search "$SEARCH_TERM" \
    --calendar "$CALENDAR" \
    --details all \
    --nocolor
