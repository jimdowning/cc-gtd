# Claude Code Project Instructions

This project encodes both a Getting Things Done system, and a specific implementation of a GTD setup along with the data. 

## GTD Processes

This system implements David Allen's GTD methodology. Each timeframe work happens over (daily, weekly, monthly) happens with an OODA loop (Observe, Orient, Decide, Act).  In each timeframe we begin with the second half of the Observation phase (we'll come back to the first half later) with the **processing pipeline** which handles input signals that there could be valuable work to do and gathers it into a form where it can be organised (Orient). The Orient phase triages the items according to the GTD categories, resulting in a short list of potential work for the time period. 
In Decide the user selects work to be prioritised in the timeframe. Act happens mostly outside this project - the works gets done. Work completion might be signalled by changes in other systems (moving cards in trello, sending response emails, marking obsidian checklist items as done, for example). The work cycle finishes with the first half of the Observation phase, in which we rerun the processing pipeline to collect those completion signals, reflect on how the work done compared to the work planned, and decide what to do with the undone work. 

### Processing Pipeline

Three stages move raw inputs into the system. Together, they achieve **inbox zero**.

**Capture** — Collect everything into trusted inboxes
- Quick capture of thoughts, tasks, ideas from anywhere
- Scan external sources (email, journal, notes) for actionable items
- All captures land in an inbox before processing
- Command: `/capture`

**Clarify** — Process each inbox item
- Decision tree: Actionable? → Next action? → 2-min rule? → Project? → Route
- Non-actionable items go to: Trash, Reference, or Someday/Maybe
- Clarify the specific physical next action

**Organize** — Route to the right place
- Next Actions: single actions organized by context
- Projects: multi-step outcomes with their own next actions
- Waiting For: delegated or expected items
- Someday/Maybe: possibilities for the future
- Calendar: time-specific commitments
- Reference: non-actionable information
- Route to appropriate provider based on context

**Clear-cut items** (obvious single action, unambiguous context) are auto-routed silently. **Ambiguous items** (unclear category, uncertain priority, could go multiple ways) are presented to the user for a quick decision. The agent should never guess on categorisation or prioritisation — when in doubt, ask. 

Clarify and Organize run together for each item. The inbox is a transient buffer, not a storage location. **When the pipeline completes, the inbox is empty.**

The processing pipeline runs as the Observe step of `/plan-day` and `/plan-week` — the user never needs to manually process the inbox before planning. `/capture` remains for quick single-item capture at any time.

### The OODA Loop

Each timeframe (daily, weekly, monthly) runs an OODA loop where **Observe is split across the period boundary**:

**Observe (prospective)** — Gather potential work
Run the processing pipeline: scan sources (Obsidian, Gmail), collect inputs, auto-route clear items, present ambiguous items for quick decisions. Result: inbox zero. Also gather calendar, due dates, carryover, recurring tasks.

**Orient** — Assess the situation
Present the landscape: time available, calendar shape, candidate tasks, due dates, carryover. One concentrated briefing.

**Decide** — Choose priorities
Conversation with the user. Select top priorities, allocate time blocks, make carryover/drop decisions. GTD's four engagement criteria apply: context, time available, energy, and priority.

**Act** — Execute
Do the work. Capture anything new that emerges. Mark work done in whatever system it lives in.

**Observe (retrospective, optional)** — Gather completion signals
What got done vs. what was planned? Handle undone items. The retrospective half of one period enriches the prospective half of the next, but is not required — `/plan-day` and `/plan-week` detect carryover directly from daily logs.

### Review Cadences

| Cadence | Start of period (prospective) | End of period (retrospective) | Commands |
|---------|-------------------------------|-------------------------------|----------|
| Daily | Process inbox, orient, decide priorities | Gather completions, reflect | `/plan-day`, `/replan` / `/review-day` |
| Weekly | Process inbox, orient on week, decide focus | Reflect on week, system health | `/plan-week` / `/review-week` |
| Monthly | Areas of focus, goal alignment | Activate/deactivate projects | `/book-monthly-planning` |

**Daily cycle:**
- Morning: Run processing pipeline + orient + decide. (`/plan-day`)
- Mid-day: Re-orient when plans change, re-decide remaining priorities. (`/replan`)
- End of day (optional): Gather completions, reflect, note carryover. (`/review-day`)

**Weekly cycle:**
- Start of week: Run processing pipeline + orient on week + decide focus projects. (`/plan-week`)
- End of week (optional): Reflect on completions, system health. (`/review-week`)
- Daily loops run within the week.

**Monthly/Quarterly:**
- Review Horizons 2–5 (areas, goals, vision, purpose)
- Are projects aligned with goals? Are any areas neglected?
- Activate/deactivate projects accordingly

### Ad-Hoc Engagement

Between planned reviews, choose what to do right now using GTD's four criteria:
1. **Context** — What can I do here? (match @context to environment)
2. **Time** — How long do I have? (fit task to available slot)
3. **Energy** — What can I handle right now?
4. **Priority** — What matters most?

Command: `/pick`

### Command Map

| Command | Phase | Cadence | Purpose |
|---------|-------|---------|---------|
| `/capture` | Observe | Any | Quick single-item capture + route |
| `/plan-day` | Observe(P) → Orient → Decide | Daily | Morning planning (processing embedded) |
| `/replan` | Orient → Decide | Daily | Mid-day adjustment |
| `/review-day` | Observe(R) | Daily | End-of-day reflection (optional) |
| `/plan-week` | Observe(P) → Orient → Decide | Weekly | Start-of-week planning (processing embedded) |
| `/review-week` | Observe(R) → Orient | Weekly | End-of-week reflection (optional) |
| `/pick` | Decide | Ad-hoc | Choose work from available tasks |
| `/today` | — | — | View current plan |
| `/sync` | — | — | Refresh provider data |
| `/calendar` | — | — | View calendar |
| `/mint-id` | — | — | Generate task IDs |

(P) = prospective, (R) = retrospective

### GTD Lists

| List | Purpose | Updated By |
|------|---------|------------|
| Inbox | Raw captures awaiting processing | Capture (continuously) |
| Next Actions | Single actions ready to do, by context | Processing pipeline |
| Projects | Multi-step outcomes (active) | Processing pipeline, weekly review |
| Waiting For | Items delegated or expected from others | Processing pipeline, weekly review |
| Someday/Maybe | Future possibilities, not committed | Processing pipeline, weekly review |
| Calendar | Date/time-specific commitments | Processing pipeline |
| Reference | Non-actionable information | Processing pipeline |

### Contexts

Contexts group actions by the tool, location, or state required:
- `@computer` — at a computer
- `@calls` — phone available
- `@errands` — out of the house
- `@home` — at home
- `@agenda-[person]` — waiting to discuss with someone
- `@anywhere` — can be done from mobile

Contexts may be combined with life areas: `@work-code`, `@home-calls`, etc.

### Horizons of Focus

| Horizon | Timeframe | Review Cadence |
|---------|-----------|----------------|
| Ground | Current actions | Daily |
| H1: Projects | Active outcomes | Weekly |
| H2: Areas of Focus | Ongoing responsibilities | Monthly |
| H3: Goals | 1-2 year objectives | Quarterly |
| H4: Vision | 3-5 year direction | Annually |
| H5: Purpose | Life principles | Annually |

### Key Principles

1. **Capture everything** — The system is only trusted if it catches everything
2. **Clarify to next action** — Vague items create resistance; specificity enables action
3. **One item, one place** — No duplication across lists or systems
4. **Context is king** — Group by what's needed, not by project
5. **Regular reviews are essential** — The system degrades without the OODA loop running at each cadence
6. **Mind like water** — The goal is clear headspace, not task completion metrics

## Git Commits

Use conventional commits format for all commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependencies, etc.

### Examples
- `feat(triage): add inbox processing command`
- `fix(sync): handle empty provider response`
- `docs(readme): update installation instructions`

## Task Identifiers

All tasks should be assigned a unique 5-character alphanumeric identifier for easy reference.

### Format
- **Length**: 5 characters
- **Character set**: lowercase alphanumeric (a-z, 0-9)
- **Examples**: `x7k2m`, `a9f3q`, `p4w8n`

### When to Assign Identifiers
- When collecting tasks from external providers (Trello, Asana, Todoist)
- When creating new tasks via /capture
- When presenting task lists to the user
- When saving tasks to GTD files or memory

### Generating Identifiers
Use `/mint-id` command or:
```bash
LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 5
```

### Display Format
When presenting tasks, show identifier in brackets:
```
[x7k2m] Task description here
```

### Storage Format
In markdown files:
```markdown
- [ ] [x7k2m] Task description here
```

### Cross-Reference
Maintain mapping between local IDs and provider IDs:
```
x7k2m -> trello:679ba2c1d8a2c8071deb9ec1
```
