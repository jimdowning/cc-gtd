# /plan-week

Start-of-week planning: run the processing pipeline, orient on the week ahead, decide focus projects, save the plan.

## Usage
```
/plan-week
```

No prerequisites — stands alone. If `/review-week` was run, its output enriches context but is not required.

## Process

### 1. Observe — Processing Pipeline (automated)

Run the full processing pipeline to achieve inbox zero. This is the prospective Observe step — gathering all potential work inputs before planning.

**Refresh provider data:**
- Refresh Trello cache (both Software Team and Personal boards)

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

**Present only ambiguous items** for quick routing decisions.

**Result:** Inbox zero. All items either routed or decided.

### 2. Observe — Gather Week Context

**Last week's review**: Read `weekly/YYYY-WNN-review.md` if it exists for:
- Incomplete / carried forward items
- System health notes
- Reflections

If no review exists, gather carryover from daily logs directly (read the last 7 days of `Journal/YYYY-MM-DD.md` and extract unchecked items from Daily Plan sections).

**Calendar**: Fetch events for the next 7 days from all calendar providers (use `--calendar` flag for work calendar)

**Due dates**: Pull tasks with due dates in the next 7 days from Trello boards

**Active projects**: Scan Trello Software Team board for work packages and their goals/due dates. Highlight past-due or due-this-week goals.

**Personal board**: Check Today/This Week/Committed lists for personal items

### 3. Orient — Present the Week's Landscape

Show the user what's ahead:

**Processing summary** (from step 1):
```
Processing pipeline: 8 items collected, 5 auto-routed, 3 decided with you. Inbox zero.
```

**Calendar shape by day**:
```
Mon: 3 meetings (9:30 standup, 14:00 client call, 16:00 1-1)
Tue: 2 meetings (10:00 sprint planning, 15:00 demo)
Wed: Light day — 1 meeting
Thu: ...
Fri: ...
```

**Tasks due this week**:
- List all tasks with due dates in the next 7 days
- Group by day or by urgency
- Include source (trello-software, trello-personal, etc.)

**Active project status**:
- List work package goals with their due dates
- Highlight any that are past due or due this week

**Carryover from last week**:
- Items that were planned but not completed
- "Do you still want to do these this week, or defer/drop?"

### 4. Decide — Priority Conversation

This is the core — a dialogue, not a dump.

Ask the user:

1. "Looking at the calendar, which days have the most space for focused work?"
2. "Of the items due this week, any that are at risk or need special attention?"
3. "Which 2-3 projects do you want to make progress on this week?"
4. "Anything from carryover you want to drop or defer to someday/maybe?"

Wait for responses. Discuss trade-offs if needed (e.g., "Tuesday is packed with meetings, probably not a good day for deep work on the SDK").

### 5. Draft the Week Plan

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

### 6. Confirm and Save

Show the draft to the user. Ask if anything needs adjusting.

Once confirmed, save to `weekly/YYYY-WNN-plan.md`.

## Time Awareness

Note the current day when running. If it's Wednesday, the "week" is the remaining days plus the following week, or just the following week — ask the user which makes sense.

## Related Commands

- `/review-week` — end-of-week reflection (enriches next plan but not required)
- `/plan-day` — daily planning informed by weekly focus
- `/replan` — mid-day adjustments when things change
- `/calendar` — detailed calendar view
- `/pick` — ad-hoc work selection between planned reviews
