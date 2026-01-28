# /review-week

Reflect on the past week: what got done, what didn't, and why.

## Usage
```
/review-week
```

## Process

### 1. Gather Context

Collect data from the past week:

- **Daily logs**: Read all `daily/YYYY-MM-DD.md` files from the past 7 days
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

Present as a quick status, not a checklist to work through (that's what `/triage` is for).

### 5. Write Review Document

After the conversation, write the review to `weekly/YYYY-WNN-review.md`:

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
- Provides context for `/weekly` planning session

## When to Run

Typically Friday afternoon or Sunday evening — whenever you want to close out the week before planning the next one.

## Related Commands

- `/weekly` — forward-looking planning (run after this)
- `/triage` — process inbox items surfaced by health check
- `/sync` — refresh provider data if needed
