# /review-week

End-of-week reflection: what got done, what didn't, and why. Closes the outgoing week.

## Usage
```
/review-week
```

Explicitly optional — next `/plan-week` detects carryover from daily logs regardless of whether this runs. But running it produces a richer starting point for the next week's planning.

## When to Run

Typically Friday afternoon or Sunday evening — whenever you want to close out the week.

## Process

### 1. Gather Context

Collect data from the past week:

- **Daily logs**: Read `Journal/YYYY-MM-DD.md` notes from Obsidian (via `get_vault_file`) for the past 7 days
- **Last week's plan**: Read `weekly/YYYY-WNN-plan.md` if it exists
- **Provider data**: Refresh Trello cache and check for cards moved to Done this week
- **Calendar**: What meetings/events happened this week

### 2. Present the Week's Activity

Show the user a summary:

**Completed items** (grouped by source):
- Tasks marked done in daily logs
- Cards moved to Done lists on Trello boards
- Any other provider completions

**Planned but incomplete**:
- Items from last week's plan that weren't checked off
- Tasks that appeared in daily logs but remained unchecked
- Carryover candidates for next week

**Waiting-for items**:
- Check Trello "Waiting For" list on personal board
- Flag anything that's been waiting more than a week

### 3. Reflect (Conversational)

Ask the user:

1. "Anything notable that happened this week that isn't captured above?"
2. "Any items that didn't get done — what blocked them?"
3. "Anything you want to note for next week?"

Keep this brief. The goal is to surface insights, not write an essay.

### 4. System Health Check

Report on GTD system health:

- **Inbox status**: Are provider inboxes at zero?
- **Projects with next actions**: How many active projects have a clear next action?
- **Stale items**: Anything due that was missed? Waiting-for items going stale?

Present as a quick status, not a checklist to work through.

### 5. Write Review Document

After the conversation, write a weekly summary to `weekly/YYYY-WNN-review.md`:

```markdown
# Week Review - YYYY-WNN

## Completed
### Work (trello-software)
- [task-id] Task description
- ...

### Personal (trello-personal)
- [task-id] Task description
- ...

## Incomplete / Carried Forward
- [task-id] Task description — reason if discussed
- ...

## Notes
<!-- User's reflections from the conversation -->

## System Health
- Inbox: clear / N items
- Projects with next actions: X/Y
- Stale waiting-for: N items
```

## Output

- Creates `weekly/YYYY-WNN-review.md`
- Next `/plan-week` reads this if it exists to enrich planning context

## Related Commands

- `/plan-week` — forward-looking planning for the coming week
- `/review-day` — daily equivalent of this reflection
- `/sync` — refresh provider data if needed
