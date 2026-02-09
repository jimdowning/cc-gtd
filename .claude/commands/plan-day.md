# /plan-day

Morning planning: run the processing pipeline, orient on the day, decide priorities, save the plan.

## Usage
```
/plan-day
```

## Process

### 1. Note the Current Time

Check what time it is. If it's past 10am, acknowledge that the morning is partially gone and only plan remaining time. If it's afternoon, focus on what's realistic for the rest of the day.

### 2. Check for Existing Plan

Read today's note from Obsidian Journal (`Journal/YYYY-MM-DD.md` via `get_vault_file`). If there's already a plan for today:
- This might be a mid-day check-in — consider suggesting `/replan` instead
- Or the user may want to start fresh — ask which they prefer

### 3. Observe — Processing Pipeline (automated)

Run the full processing pipeline to achieve inbox zero. This is the prospective Observe step — gathering all potential work inputs before planning.

**Source scan:**
- **Obsidian journal** (last 7 days): List `Journal/` files via `list_vault_files`, read each with `get_vault_file`, extract incomplete checkboxes `- [ ]`
- **Gmail**: For each `type: gmail` note source in `integrations/config.md`, run `node integrations/scripts/gmail-gtd/index.js scan <account>` for labeled emails

**Auto-route clear items silently:**
For each collected item, apply the clarify decision tree:
1. Is it actionable? → No → Trash / Reference / Someday-Maybe (auto-route if obvious)
2. What's the specific next action? (clarify if needed)
3. Less than 2 minutes? → Flag for quick-do
4. Multi-step? → Create project
5. Route: assign @context, match to provider via `integrations/config.md`

Items that are **clear single actions** with obvious context are auto-routed silently — mint an ID, create in the matched provider, log the routing.

**Present only ambiguous items** for quick routing decisions. Keep this focused — the user shouldn't have to process 20 items one by one. Batch similar items when possible.

**Result:** Inbox zero. All items either routed or decided.

### 4. Observe — Gather Day Context

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

**Yesterday's carryover**: Read yesterday's journal note from Obsidian (`Journal/YYYY-MM-DD.md`), note any incomplete items from the Daily Plan section

### 5. Orient — Present the Situation

Show the user what's available, don't decide for them:

**Processing summary** (from step 3):
```
Processing pipeline: 5 items collected, 3 auto-routed, 2 decided with you. Inbox zero.
```

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

### 6. Decide — Priority Conversation

Ask the user:

1. "What's the most important thing to get done today?"
2. "Any of yesterday's carryover you want to drop or push to later in the week?"
3. "Anything not listed that's on your mind for today?"

This is a conversation. Wait for responses. Don't assume.

### 7. Draft the Plan

Based on the conversation, draft time blocks that fit the available slots.

The daily note lives in Obsidian at `Journal/YYYY-MM-DD.md` and has three top-level sections. The Daily Plan is written by `/plan-day`, Notes are added manually by the user during the day, and the Daily Review is written by `/review-day` or manually at end of day.

```markdown
# Daily Plan
**Last Updated:** HH:MM

## Calendar

| Time | Event | Source |
|------|-------|--------|
| 09:30 | Will / Jim | [work] |
| ... | ... | ... |

## Top 3 Priorities
1. Priority task
2. Priority task
3. Priority task

## Time Blocks
- **08:15-09:30** Focus Block
  - [ ] [id] Task from conversation
- **10:00-11:30** Deep Work
  - [ ] [id] Task from conversation
- ...

## Updates
- Items deferred, priorities changed, etc.

---

# Notes


---

# Daily Review

```

### 8. Confirm and Save

Show the draft. Ask if it looks right.

Once confirmed, save to Obsidian via `create_vault_file` at `Journal/YYYY-MM-DD.md`. Only write the `# Daily Plan` section and the empty `# Notes` and `# Daily Review` stubs — the user fills in Notes manually.

## Time Awareness

- Always check the current time before planning
- Only plan time blocks that haven't passed
- If it's late in the day, keep it simple — maybe just "what's the one thing to do before end of day?"
- Acknowledge weekends differently (lighter structure, personal focus)

## Related Commands

- `/plan-week` — sets the focus projects that inform daily planning
- `/replan` — mid-day adjustments when priorities shift
- `/today` — quick view of current plan without changes
- `/review-day` — end-of-day reflection on what got done
- `/pick` — ad-hoc work selection between planned reviews
