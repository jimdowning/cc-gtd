# icalBuddy Usage Notes for GTD System

## Quick Reference Commands

### Today's Events
```bash
icalBuddy -f -nc eventsToday
```
- `-f`: Format output with ANSI escape sequences
- `-nc`: No calendar names (cleaner output)

### This Week's Events
```bash
icalBuddy -f -sd eventsToday+7
```
- `-sd`: Separate by date
- `eventsToday+7`: Today plus 7 days

### Events in a Date Range
```bash
icalBuddy -f -sd eventsFrom:"2025-07-13" to:"2025-07-19"
```

### What's Happening Now
```bash
icalBuddy -f eventsNow
```

### Uncompleted Tasks/Reminders
```bash
icalBuddy -f -sp uncompletedTasks
```
- `-sp`: Separate by priority

### Tasks Due This Week
```bash
icalBuddy -f tasksDueBefore:"today+7"
```

### List All Calendars
```bash
icalBuddy calendars
```

## Useful Options for GTD

### Filtering Calendars
- `-ic "Work,Personal"`: Include only specific calendars
- `-ec "Birthdays"`: Exclude specific calendars
- `-ict "local,icloud"`: Include calendar types
- `-ect "subscription"`: Exclude calendar types

### Output Formatting
- `-b "→ "`: Custom bullet point
- `-ps "| - |"`: Property separators
- `-po "title,datetime,location"`: Property order
- `-eep "*"`: Show only titles (exclude all properties)
- `-tf "%I:%M %p"`: 12-hour time format
- `-df "%a %b %d"`: Date format (e.g., "Mon Jul 13")

### Limiting Output
- `-li 10`: Limit to 10 items
- `-n`: Only show events from now onwards (for eventsToday)
- `-ea`: Exclude all-day events

## GTD Integration Examples

### Daily Planning View
```bash
# Today's schedule with proper formatting
icalBuddy -f -nc -ps "| at |" -df "" eventsToday

# Today's remaining events only
icalBuddy -f -nc -n eventsToday
```

### Weekly Review
```bash
# Full week overview separated by date
icalBuddy -f -sd -nc eventsToday+7

# Include empty dates to see free days
icalBuddy -f -sd -sed eventsToday+7
```

### Quick Status Check
```bash
# What's happening right now
icalBuddy -f -nc eventsNow

# Next 3 hours
icalBuddy -f -nc eventsFrom:"now" to:"now+3 hours"
```

### Task Management
```bash
# All uncompleted reminders sorted by date
icalBuddy -f -std uncompletedTasks

# Tasks due today
icalBuddy -f tasksDueBefore:"tomorrow"
```

## Date Format Examples
- Natural language: "tomorrow at noon", "next monday"
- Relative: "today+3", "yesterday-2"
- Absolute: "2025-07-13 14:00:00 +0000"

## Time Zone Note
The tool uses system timezone by default. For EDT (your timezone):
- Use natural language dates when possible
- Or specify timezone: "2025-07-13 14:00:00 -0400"