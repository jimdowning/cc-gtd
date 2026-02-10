# icalBuddy Adapter

Adapter for fetching calendar events from macOS Calendar app using `icalBuddy`.

## Role
- **source_type**: read-only
- **capture_signal**: —
- **completion_signal**: —
- **id_strategy**: —
- **primary_storage**: external

## Prerequisites

Install icalBuddy:
```bash
brew install ical-buddy
```

No additional configuration needed - uses macOS Calendar.app data.

## Instance Configuration

The adapter receives these parameters from the provider instance config:
- `calendars`: Comma-separated list of calendar names to include
- `exclude`: Comma-separated list of calendar names to exclude
- `label`: Display label for merged views
- `routes`: Routing rules

## Commands

### List Today's Events
```bash
# Today's events
icalBuddy -f -nc eventsToday

# Today's remaining events only
icalBuddy -f -nc -n eventsToday
```

### List Week's Events
```bash
# Today plus 7 days, separated by date
icalBuddy -f -sd eventsToday+7
```

### List Events in Range
```bash
icalBuddy -f -sd eventsFrom:"{{start_date}}" to:"{{end_date}}"
```

### What's Happening Now
```bash
icalBuddy -f eventsNow
```

### Uncompleted Tasks/Reminders
```bash
icalBuddy -f -sp uncompletedTasks
```

### Tasks Due This Week
```bash
icalBuddy -f tasksDueBefore:"today+7"
```

### List All Calendars
```bash
icalBuddy calendars
```

## Calendar Filtering

### Include Specific Calendars
```bash
icalBuddy -ic "Work,Personal" eventsToday
```

### Exclude Calendars
```bash
icalBuddy -ec "Birthdays,Holidays" eventsToday
```

### Filter by Type
```bash
# Include only local and iCloud calendars
icalBuddy -ict "local,icloud" eventsToday

# Exclude subscribed calendars
icalBuddy -ect "subscription" eventsToday
```

## Output Formatting

### For GTD Integration
```bash
# Clean output without calendar names
icalBuddy -nc eventsToday

# Custom property order
icalBuddy -po "title,datetime,location" eventsToday

# Custom separators
icalBuddy -ps "| - |" eventsToday
```

### For Display
```bash
# With ANSI formatting
icalBuddy -f eventsToday

# Custom bullet point
icalBuddy -b "* " eventsToday
```

### Time and Date Formatting
```bash
# 12-hour time format
icalBuddy -tf "%I:%M %p" eventsToday

# Custom date format
icalBuddy -df "%a %b %d" eventsToday
```

## Multi-Provider Integration

icalBuddy accesses all calendars configured in macOS Calendar.app, which can include:
- iCloud calendars
- Google Calendar (synced via macOS)
- Exchange calendars
- CalDAV calendars
- Subscribed calendars

To simulate multi-provider with icalBuddy:
```bash
# Work calendars only
icalBuddy -ic "Work,Meetings" eventsToday

# Personal calendars only
icalBuddy -ic "Personal,Family" eventsToday
```

## Limiting Output

```bash
# Limit to 10 items
icalBuddy -li 10 eventsToday

# Exclude all-day events
icalBuddy -ea eventsToday
```

## Example Usage

### Daily Planning View
```bash
# Today's schedule with clean formatting
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

- Natural language: `tomorrow at noon`, `next monday`
- Relative: `today+3`, `yesterday-2`
- Absolute: `2025-07-13 14:00:00 +0000`

## Error Handling

- If calendar not found: Check calendar name in Calendar.app
- If no events returned: Verify date range and calendar filters
- If permission denied: Grant Full Disk Access in System Preferences

## Comparison with gcalcli

| Feature | icalBuddy | gcalcli |
|---------|-----------|---------|
| Source | macOS Calendar.app | Google Calendar API |
| Multi-account | Via Calendar.app sync | Via config directories |
| Create events | No (read-only) | Yes |
| Offline access | Yes (cached) | No |
| Setup complexity | Low | Medium (OAuth) |

## When to Use icalBuddy

- **Use icalBuddy** when:
  - All calendars sync to macOS Calendar.app
  - You want read-only calendar view
  - Offline access is important
  - Simple setup preferred

- **Use gcalcli** when:
  - Need to create/modify events programmatically
  - Direct Google Calendar API access needed
  - Not on macOS

## Integration Notes

- Events are read-only (create via Calendar.app or other tools)
- Good for daily planning views and weekly reviews
- Combine with gcalcli for write operations if needed
- Use provider label in merged views: `[personal] 18:00 Dinner`
