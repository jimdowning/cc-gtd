# /book-monthly-planning

Ensure the next 3 months of "Monthly Software Planning" meetings are booked, with intelligent date selection around the 2nd Wednesday of each month.

## Usage
```
/book-monthly-planning
```

## Meeting Details
- **Title**: Monthly Software Planning
- **Time**: Afternoon, target 2:00-3:00 PM
- **Duration**: 60 minutes
- **Calendar**: jim.downing@cyclopsmarine.com

## Process

### Step 1: Find Existing Meetings

Search for existing "Monthly Software Planning" meetings:

```bash
integrations/scripts/gcal-search.sh "Monthly Software Planning"
```

Parse the output to identify:
- List of existing meeting dates
- Attendees from the most recent meeting
- Confirm duration (should be 60 minutes)

### Step 2: Calculate Target Dates

For each of the next 3 months, calculate the 2nd Wednesday:

**Algorithm:**
1. Get the first day of month M
2. Find what day of week that is (0=Sun, 1=Mon, ..., 6=Sat)
3. Calculate days until first Wednesday: `(3 - first_day_dow + 7) % 7`
4. First Wednesday = day 1 + days_until_wednesday
5. Second Wednesday = First Wednesday + 7

**Example for February 2026:**
- Feb 1, 2026 is a Sunday (day 0)
- Days to Wednesday: (3 - 0 + 7) % 7 = 3
- First Wednesday: Feb 4
- Second Wednesday: Feb 11

### Step 3: Identify Gaps

For each target date:
1. Check if a "Monthly Software Planning" meeting exists within ±7 days
2. If meeting exists within window, that month is covered
3. Build list of months needing booking

### Step 4: For Each Gap - Find Available Slot

For each month needing a meeting:

1. **Try target date first** (2nd Wednesday at 14:00):
   ```bash
   integrations/scripts/gcal-availability.sh "YYYY-MM-DD 14:00" 60 jim.downing@cyclopsmarine.com [attendee1] [attendee2]
   ```

2. **If conflicts, try alternative times** in order:
   - Same day, 15:00-16:00
   - Same day, 13:00-14:00
   - Tuesday of same week, 14:00-15:00
   - Thursday of same week, 14:00-15:00
   - Monday of same week, 14:00-15:00
   - Friday of same week, 14:00-15:00

3. **Present proposed slot** to user for approval

### Step 5: Create Meeting (with confirmation)

Once user approves a slot:

```bash
gcalcli add \
  --calendar "jim.downing@cyclopsmarine.com" \
  --title "Monthly Software Planning" \
  --when "YYYY-MM-DD 14:00" \
  --duration 60 \
  --who attendee1@email.com \
  --who attendee2@email.com
```

**Important:** Always confirm with user before creating each meeting.

## Output Format

```markdown
## Monthly Software Planning - Status

### Existing Meetings Found
- 2026-01-08 (Wed) 14:00-15:00 - Attendees: alice@example.com, bob@example.com
- 2026-02-12 (Wed) 14:00-15:00

### Coverage Analysis
| Month | Target Date | Status | Notes |
|-------|-------------|--------|-------|
| Jan 2026 | 2026-01-14 | Covered | Meeting on Jan 8 |
| Feb 2026 | 2026-02-11 | Covered | Meeting on Feb 12 |
| Mar 2026 | 2026-03-11 | **GAP** | No meeting found |
| Apr 2026 | 2026-04-08 | **GAP** | No meeting found |

### Proposed Bookings
#### March 2026
- Target: Wed Mar 11, 2026 at 14:00
- Availability: Checking...
- Status: Available / Conflict at [time]
- Alternative: [if needed]

**Create this meeting?** [Awaiting confirmation]
```

## Attendee Extraction

When parsing existing meetings, extract attendees from the `--details all` output which includes:
```
Attendees:
  attendee1@email.com (Organizer)
  attendee2@email.com
  attendee3@email.com
```

Use attendees from the most recent meeting for new bookings.

## Error Handling

- **No existing meetings found**: Ask user for attendees list
- **gcalcli not available**: Report error and exit
- **All time slots conflicted**: Present conflicts and ask user to manually select a time
- **Calendar API errors**: Report specific error and retry once

## Configuration Reference

Calendar provider config in `integrations/config.md`:
- **gcal-cyclops**: jim.downing@cyclopsmarine.com (work calendar)

## Related Commands

- `/calendar` - View calendar events
- `/sync` - Sync all providers

## Recurring Trigger

This command should be run monthly on the 1st to ensure upcoming meetings are booked.
See `recurring.md` for the scheduled trigger.
