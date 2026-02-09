# /replan

Mid-day replanning when priorities shift or unexpected work emerges.

## Usage
```
/replan
```

## When to Use

- Something urgent landed and the morning plan is now wrong
- A meeting got cancelled and you have unexpected time
- You finished your planned work early
- You're stuck and need to pivot to something else
- It's after lunch and you want to reset for the afternoon

## Process

### 1. Note the Current Time

Check what time it is. Calculate remaining work hours (typically until 17:00-18:00, but ask if unclear).

### 2. Read Current Plan

Load today's journal note from Obsidian (`Journal/YYYY-MM-DD.md` via `get_vault_file`) and parse:
- What was planned for today
- What's been marked done (checked items)
- What's still open
- Any work log entries

### 3. Present Current State

Show the user where things stand:

**Time remaining**:
```
It's 14:30. Remaining today:
- 15:30-16:00 Modal Students (meeting)
- ~2.5 hours of work time until 17:00
```

**Completed so far**:
- [x] Items checked off

**Still open from this morning's plan**:
- [ ] Items not yet done

**What changed?** Ask: "What's different from this morning? New urgent item? Something got unblocked? Change of energy/focus?"

### 4. Replan Conversation

Based on what changed, discuss:

1. "What's the priority for the rest of the day?"
2. "Anything from the morning plan that should move to tomorrow?"
3. "Any new items to add?"

Keep it focused. This isn't a full daily planning session — it's a tactical adjustment.

### 5. Update the Plan

Modify the existing daily log:

- Update "Last Updated" timestamp
- Adjust time blocks for remaining day only
- Move deferred items to a "Pushed to tomorrow" section
- Add any new items that emerged
- Preserve the morning's time blocks as historical record (don't delete them)

Example update:

```markdown
## Daily Plan
**Last Updated:** 14:35 (replanned)

### Remaining Today
- **14:30-15:30** Focus Block
  - [ ] [8yhe5] Fix EZ-Sag Bitrise — TOP PRIORITY (new)
- **15:30-16:00** Modal Students
- **16:00-17:00** Wind down
  - [ ] [qfo2w] Review ADRs if time

### Pushed to Tomorrow
- [ ] [l4alt] Atto iOS — deprioritized, will continue tomorrow

### Morning (completed)
- [x] [5e1lv] Book 1-1 Will
- **09:30-10:00** Will / Jim — done
- **10:00-11:30** Deep work — worked on Atto iOS
```

### 6. Confirm and Save

Show the updated plan. Confirm it makes sense.

Save the updated plan to Obsidian via `patch_vault_file` on `Journal/YYYY-MM-DD.md`, updating the `# Daily Plan` section. Preserve `# Notes` and `# Daily Review` sections untouched.

## Quick Mode

If the user just says `/replan` with a specific item, like:
```
/replan [8yhe5] is now top priority
```

Skip the conversation and just:
1. Move that item to the top of remaining time blocks
2. Shuffle other items down or to "Pushed to tomorrow"
3. Show the result and confirm

## Related Commands

- `/plan-day` — full morning planning session
- `/today` — view current plan without changes
- `/capture` — if new items need to be captured first
- `/review-day` — end-of-day reflection
