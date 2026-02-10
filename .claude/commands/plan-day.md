# /plan-day

Morning planning: run the processing pipeline, orient on the day, decide priorities, save the plan.

## System Resolution

1. Read `.claude/active-system` for the active system name
2. Load `systems/<active>/config.md` for provider instances and routing
3. Load `systems/<active>/prompts/plan-day.md` if it exists for system-specific instructions
4. Use `systems/<active>/data/` for recurring tasks, inbox, etc.

## Usage
```
/plan-day
```

## Process

### 1. Note the Current Time

Check what time it is. If it's past 10am, acknowledge that the morning is partially gone and only plan remaining time. If it's afternoon, focus on what's realistic for the rest of the day.

### 2. Check for Existing Plan

Check for today's journal note in the system's journal provider (Obsidian or local). If there's already a plan for today:
- This might be a mid-day check-in — consider suggesting `/replan` instead
- Or the user may want to start fresh — ask which they prefer

### 3. Observe — Processing Pipeline (automated)

Run the full processing pipeline to achieve inbox zero. This is the prospective Observe step.

**Source scan (delegated to sub-agents):**
Delegate source scanning to parallel Haiku sub-agents — this is mechanical retrieval that doesn't need the parent agent's intelligence.

For each note source configured in `systems/<active>/config.md`, spawn a Task sub-agent **in parallel**:

| Provider type | Sub-agent type | Reason |
|--------------|----------------|--------|
| `obsidian-mcp` | `general-purpose` | Needs MCP tools |
| `gmail` | `Bash` | Runs adapter scan procedure |

Each sub-agent prompt should include: the adapter doc path (`integrations/adapters/notes/<type>.md`), the instance config excerpt from the system config, and instructions to return structured results. Use `model: "haiku"` for all retrieval sub-agents.

Collect all sub-agent results before proceeding to clarify/route.

**Auto-route clear items silently:**
For each collected item, apply the clarify decision tree:
1. Is it actionable? → No → Trash / Reference / Someday-Maybe (auto-route if obvious)
2. What's the specific next action? (clarify if needed)
3. Less than 2 minutes? → Flag for quick-do
4. Multi-step? → Create project
5. Route: assign @context, match to provider via `systems/<active>/config.md`

Items that are **clear single actions** with obvious context are auto-routed silently — mint an ID, create in the matched provider using its adapter, log the routing.

**Present only ambiguous items** for quick routing decisions. Keep this focused — batch similar items when possible.

**Result:** Inbox zero. All items either routed or decided.

### 4. Observe — Gather Day Context

Delegate external retrieval to parallel Haiku sub-agents. Local file reads stay in the parent agent.

**Sub-agent retrieval (spawn all in parallel, `model: "haiku"`):**

- **Calendar** (`Bash` sub-agent): For each calendar provider in `systems/<active>/config.md`, include the adapter path (`integrations/adapters/calendar/<type>.md`) and instance config (calendar name, account, filter flags) in the prompt. Sub-agent fetches today's events and returns structured text.
- **Due today** (`Bash` sub-agent per todo provider): For each todo provider in the system config, include the adapter path and instance config. Sub-agent queries for tasks with today's due date and returns the list.
- **Candidate tasks** (`Bash` sub-agent per todo provider): From the week's focus projects, sub-agent pulls tasks that could be worked on today. Include project/list identifiers from the week plan in the prompt.

**Parent agent reads directly (no sub-agent needed):**

- **Weekly focus**: Read the current week plan from the system's journal (e.g., `systems/<active>/journal/weekly/YYYY-WNN-plan.md`) to get focus projects and due dates. Read this first — focus project identifiers inform the candidate tasks sub-agent prompts above.
- **Recurring tasks**: Check `systems/<active>/data/recurring.md` for tasks due today. Parse schedules against `last_created` dates. If something is due, create it in the specified provider (using its adapter) and update `last_created`. Report what was created.
- **Yesterday's carryover**: Read yesterday's journal note, note any incomplete items from the Daily Plan section.

Collect all sub-agent results before proceeding to Orient.

### 5. Orient — Present the Situation

Show the user what's available, don't decide for them:

**Processing summary** (from step 3):
```
Processing pipeline: 5 items collected, 3 auto-routed, 2 decided with you. Inbox zero.
```

**Time available**:
```
It's 08:15. Your calendar today:
- 09:30-10:00 Meeting
- 14:00-14:30 Meeting

Available blocks: 08:15-09:30 (1h15m), 10:00-14:00 (4h), 14:30+ (wind down)
```

**Due today**: List any tasks with today's due date

**Weekly focus projects**: Remind what projects were chosen, show candidate tasks

**Carryover from yesterday**: Items that were planned but not completed

**Recurring tasks created**: Note any that were just created

### 6. Decide — Priority Conversation

Ask the user:

1. "What's the most important thing to get done today?"
2. "Any of yesterday's carryover you want to drop or push to later in the week?"
3. "Anything not listed that's on your mind for today?"

This is a conversation. Wait for responses. Don't assume.

### 7. Draft the Plan

Based on the conversation, draft time blocks that fit the available slots.

The daily note has three top-level sections: Daily Plan (written by `/plan-day`), Notes (added manually), and Daily Review (written by `/review-day`).

```markdown
# Daily Plan
**Last Updated:** HH:MM

## Calendar

| Time | Event | Source |
|------|-------|--------|
| 09:30 | Meeting | [work] |
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

Once confirmed, save to the system's journal. Only write the `# Daily Plan` section and the empty `# Notes` and `# Daily Review` stubs.

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
