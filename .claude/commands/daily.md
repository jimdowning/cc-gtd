# /daily

Plan today's work through conversation: surface what matters, agree on priorities, then write the plan.

## Usage
```
/daily
```

## Process

### 1. Note the Current Time

Check what time it is. If it's past 10am, acknowledge that the morning is partially gone and only plan remaining time. If it's afternoon, focus on what's realistic for the rest of the day.

### 2. Check for Existing Plan

Read `daily/YYYY-MM-DD.md` if it exists. If there's already a plan for today:
- This might be a mid-day check-in — consider suggesting `/replan` instead
- Or the user may want to start fresh — ask which they prefer

### 3. Gather Context

**Weekly focus**: Read `weekly/YYYY-WNN-plan.md` to get:
- Focus projects for the week
- Any due dates flagged for this week

**Recurring tasks**: Check `recurring.md` for tasks due today:
- Parse schedules against `last_created` dates
- If something is due, create it in the specified provider and update `last_created`
- Report what was created

**Calendar**: Fetch today's events from configured calendar providers (use `--calendar` flag to filter to Jim's calendars only)

**Due today**: Pull tasks with due dates of today from Trello boards

**Candidate tasks**: From the week's focus projects, pull tasks that could be worked on today:
- Check In Progress items on Software Team board
- Check cards in focus project work packages
- Check Today/This Week lists on Personal board

**Yesterday's carryover**: Read yesterday's daily log, note any incomplete items

### 4. Present the Situation

Show the user what's available, don't decide for them:

**Time available**:
```
It's 08:15. Your calendar today:
- 09:30-10:00 Will / Jim
- 11:30-12:00 Workout Pilot Updates
- 14:00-14:30 MQTT-Purr
- 15:30-16:00 Modal Students

Available blocks: 08:15-09:30 (1h15m), 10:00-11:30 (1h30m), 12:00-14:00 (2h), 14:30-15:30 (1h), 16:00+ (wind down)
```

**Due today**:
- List any tasks with today's due date

**Weekly focus projects**:
- Remind what projects were chosen for this week
- Show candidate tasks from those projects

**Carryover from yesterday**:
- Items that were planned but not completed
- "Still want these, or defer?"

**Recurring tasks created**:
- Note any that were just created

### 5. Priority Conversation

Ask the user:

1. "What's the most important thing to get done today?"
2. "Any of yesterday's carryover you want to drop or push to later in the week?"
3. "Anything not listed that's on your mind for today?"

This is a conversation. Wait for responses. Don't assume.

### 6. Draft the Plan

Based on the conversation, draft time blocks that fit the available slots:

```markdown
# Daily Log - YYYY-MM-DD

## Calendar

| Time | Event | Source |
|------|-------|--------|
| 09:30 | Will / Jim | [work] |
| ... | ... | ... |

## Daily Plan
**Last Updated:** HH:MM

### Top 3 Priorities
1. [ ] [id] Priority task
2. [ ] [id] Priority task
3. [ ] [id] Priority task

### Time Blocks
- **08:15-09:30** Focus Block
  - [ ] [id] Task from conversation
- **10:00-11:30** Deep Work
  - [ ] [id] Task from conversation
- ...

### Deferred
- [id] Task — pushed to tomorrow/later this week

## Work Log

```

### 7. Confirm and Save

Show the draft. Ask if it looks right.

Once confirmed, save to `daily/YYYY-MM-DD.md`.

## Time Awareness

- Always check the current time before planning
- Only plan time blocks that haven't passed
- If it's late in the day, keep it simple — maybe just "what's the one thing to do before end of day?"
- Acknowledge weekends differently (lighter structure, personal focus)

## Related Commands

- `/weekly` — sets the focus projects that inform daily planning
- `/replan` — mid-day adjustments when priorities shift
- `/today` — quick view of current plan without changes
- `/triage` — process inbox items before planning
