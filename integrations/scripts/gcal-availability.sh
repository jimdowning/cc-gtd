#!/bin/bash
# Check availability for a time slot across multiple calendars
# Usage: gcal-availability.sh "YYYY-MM-DD HH:MM" duration_minutes calendar1 [calendar2 ...]
#
# Returns 0 if slot is available, 1 if conflicts exist
# Outputs conflicting events if any

set -e

START_TIME="$1"
DURATION="$2"
shift 2
CALENDARS=("$@")

if [[ -z "$START_TIME" || -z "$DURATION" || ${#CALENDARS[@]} -eq 0 ]]; then
    echo "Usage: $0 \"YYYY-MM-DD HH:MM\" duration_minutes calendar1 [calendar2 ...]"
    echo "Example: $0 \"2026-02-11 14:00\" 60 jim.downing@cyclopsmarine.com"
    exit 1
fi

# Parse start time and calculate end time
START_DATE=$(echo "$START_TIME" | cut -d' ' -f1)
START_HOUR=$(echo "$START_TIME" | cut -d' ' -f2)

# Calculate end time (add duration minutes)
if command -v gdate &> /dev/null; then
    DATE_CMD="gdate"
else
    DATE_CMD="date"
fi

END_TIME=$($DATE_CMD -d "$START_TIME + $DURATION minutes" "+%Y-%m-%d %H:%M" 2>/dev/null || \
           $DATE_CMD -v+${DURATION}M -j -f "%Y-%m-%d %H:%M" "$START_TIME" "+%Y-%m-%d %H:%M" 2>/dev/null)

if [[ -z "$END_TIME" ]]; then
    echo "Error: Could not calculate end time"
    exit 1
fi

echo "Checking availability: $START_TIME to $END_TIME"
echo "Calendars: ${CALENDARS[*]}"
echo ""

CONFLICTS_FOUND=0

for CALENDAR in "${CALENDARS[@]}"; do
    echo "--- $CALENDAR ---"

    # Get agenda for the time window (with some buffer)
    AGENDA=$(gcalcli agenda "$START_DATE 00:00" "$START_DATE 23:59" \
        --calendar "$CALENDAR" \
        --nocolor \
        --tsv 2>/dev/null || echo "")

    if [[ -z "$AGENDA" ]]; then
        echo "  No events found"
        continue
    fi

    # Check each event for overlap
    while IFS=$'\t' read -r date start end title location; do
        # Skip header or empty lines
        [[ -z "$start" || "$start" == "start" ]] && continue

        # Check if event overlaps with requested slot
        EVENT_START="$date $start"
        EVENT_END="$date $end"

        # Simple overlap check: event starts before our end AND event ends after our start
        if [[ "$EVENT_START" < "$END_TIME" && "$EVENT_END" > "$START_TIME" ]]; then
            echo "  CONFLICT: $start-$end $title"
            CONFLICTS_FOUND=1
        fi
    done <<< "$AGENDA"

    if [[ $CONFLICTS_FOUND -eq 0 ]]; then
        echo "  Available"
    fi
done

echo ""
if [[ $CONFLICTS_FOUND -eq 1 ]]; then
    echo "Result: CONFLICTS FOUND"
    exit 1
else
    echo "Result: AVAILABLE"
    exit 0
fi
