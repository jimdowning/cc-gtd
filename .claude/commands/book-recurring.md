# /book-recurring

Ensure that upcoming instances of periodic meeting series are booked, with intelligent date selection and availability checking.

## System Resolution

1. Read `.claude/active-system` for the active system name
2. Load `systems/<active>/config.md` for calendar provider instances
3. Load `systems/<active>/prompts/book-recurring.md` for meeting series definitions (required — this command does nothing without meeting series to book)

## Usage
```
/book-recurring [series-name]
```

- No argument: Process all meeting series defined in the system prompt
- Series name: Process a specific series only

## Meeting Series Schema

Each meeting series is defined in the system's `prompts/book-recurring.md` with these fields:

```markdown
### series-id
- **title**: Meeting name (used to search for existing instances)
- **cadence**: weekly | biweekly | monthly
- **target_day**: Day of week (monday-friday) or ordinal (2nd wednesday, 1st monday)
- **preferred_time**: e.g., 14:00
- **duration**: e.g., 60 minutes
- **lookahead**: How many future instances to ensure are booked (e.g., 3, 1)
- **match_window**: Days either side of target to count as covered (default: ±7)
- **attendees**: Explicit list, or "from latest" to inherit from most recent instance
- **calendar**: Which calendar provider to use
- **notes**: Any additional booking constraints
```

## Process

### Step 1: Load Meeting Series

Read the system's `prompts/book-recurring.md` for meeting series definitions. If a specific series was requested, filter to that one.

### Step 2: For Each Series

#### A. Find Existing Meetings

Use the calendar adapter from `integrations/adapters/calendar/<type>.md` to search for existing meetings matching the series title.

Parse the output to identify:
- List of existing meeting dates
- Attendees from the most recent instance (if series uses "from latest")
- Confirm duration

#### B. Calculate Target Dates

Based on the series cadence and target_day, calculate the next N target dates (where N = lookahead):

**Monthly with ordinal day** (e.g., "2nd wednesday"):
1. Get the first day of month M
2. Find what day of week that is (0=Sun, 1=Mon, ..., 6=Sat)
3. Calculate the Nth occurrence of the target day in that month

**Weekly/biweekly** (e.g., "thursday"):
1. Find next occurrence of target day from today
2. Add 7 (weekly) or 14 (biweekly) days for subsequent instances

#### C. Identify Gaps

For each target date:
1. Check if a matching meeting exists within ±match_window days
2. If meeting exists within window, that period is covered
3. Build list of periods needing booking

#### D. For Each Gap — Find Available Slot

Use the calendar adapter to check availability:
1. Try target date first at preferred time
2. If conflicts, try alternative times (same day different hour, adjacent days)
3. Present proposed slot to user for approval

#### E. Create Meeting (with confirmation)

Once user approves a slot, use the calendar adapter's create procedure to add the event.

**Important:** Always confirm with user before creating each meeting.

## Output Format

```markdown
## Recurring Meetings — Status

### [Series Title]

#### Existing Meetings Found
- 2026-01-08 (Wed) 14:00-15:00 - Attendees: alice@example.com, bob@example.com

#### Coverage Analysis
| Period | Target Date | Status | Notes |
|--------|-------------|--------|-------|
| Jan 2026 | 2026-01-14 | Covered | Meeting on Jan 8 |
| Feb 2026 | 2026-02-11 | **GAP** | No meeting found |

#### Proposed Bookings
- Target: Wed Feb 11, 2026 at 14:00
- Status: Available / Conflict
- Alternative: [if needed]

**Create this meeting?** [Awaiting confirmation]
```

## Error Handling

- **No series definitions found**: Report that `prompts/book-recurring.md` is missing or empty
- **No existing meetings found for a series**: Ask user for attendees list
- **Calendar adapter not available**: Report error and exit
- **All time slots conflicted**: Present conflicts and ask user to manually select a time
- **Calendar API errors**: Report specific error and retry once

## Related Commands

- `/calendar` - View calendar events
- `/sync` - Sync all providers
