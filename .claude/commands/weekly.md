# /weekly

Plan the coming week: surface due dates, carryover, and choose project priorities.

## Usage
```
/weekly
```

## Prerequisites

Run `/review-week` first (or have recent review data). The review surfaces what didn't get done last week, which informs carryover.

## Process

### 1. Gather Forward-Looking Context

Collect data for the coming week:

- **Calendar**: Fetch events for the next 7 days from all calendar providers
- **Due dates**: Pull tasks with due dates in the next 7 days from all todo providers
- **Carryover**: Read `weekly/YYYY-WNN-review.md` for incomplete items from last week
- **Active projects**: Scan Trello boards for work packages and their goals/due dates

### 2. Present the Situation

Show the user what's on the horizon:

**Calendar commitments**:
```
Mon: 3 meetings (9:30 standup, 14:00 client call, 16:00 1-1)
Tue: 2 meetings (10:00 sprint planning, 15:00 demo)
Wed: Light day — 1 meeting
...
```

**Tasks due this week**:
- List all tasks with due dates in the next 7 days
- Group by day or by urgency
- Include source (trello-software, trello-personal, etc.)

**Carryover from last week**:
- Items that were planned but not completed
- "Do you still want to do these this week, or defer/drop?"

**Active projects** (from Trello Software Team board):
- List work package goals with their due dates
- Highlight any that are past due or due this week

### 3. Priority Conversation

This is the core of the skill — a dialogue, not a dump.

Ask the user:

1. "Looking at the calendar, which days have the most space for focused work?"
2. "Of the items due this week, any that are at risk or need special attention?"
3. "Which 2-3 projects do you want to make progress on this week?"
4. "Anything from carryover you want to drop or defer to someday/maybe?"

Wait for responses. Discuss trade-offs if needed (e.g., "Tuesday is packed with meetings, probably not a good day for deep work on the SDK").

### 4. Draft the Week Plan

Based on the conversation, draft a plan:

```markdown
# Week Plan - YYYY-WNN

## Focus Projects
1. [Project/Goal] — what you want to accomplish
2. [Project/Goal] — what you want to accomplish
3. [Project/Goal] — what you want to accomplish

## Due This Week
| Day | Task | Source | Status |
|-----|------|--------|--------|
| Mon | [id] Task description | trello-software | |
| Tue | [id] Task description | trello-personal | |
| ... | ... | ... | |

## Calendar Shape
- **Mon**: Heavy meetings, admin only
- **Tue**: Morning free, afternoon meetings
- **Wed**: Open — best day for deep work
- **Thu**: ...
- **Fri**: ...

## Carryover
- [id] Task — carrying forward
- [id] Task — deferred to someday/maybe
- [id] Task — dropped (reason)

## Notes
<!-- Anything else from the conversation -->
```

### 5. Confirm and Save

Show the draft to the user. Ask if anything needs adjusting.

Once confirmed, save to `weekly/YYYY-WNN-plan.md`.

## Output

- Creates `weekly/YYYY-WNN-plan.md`
- Informs `/daily` sessions throughout the week

## Time Awareness

Note the current day when running. If it's Wednesday, the "week" is the remaining days plus the following week, or just the following week — ask the user which makes sense.

## Related Commands

- `/review-week` — backward-looking reflection (run before this)
- `/daily` — daily planning informed by weekly focus
- `/replan` — mid-day adjustments when things change
- `/calendar` — detailed calendar view
