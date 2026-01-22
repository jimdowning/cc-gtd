# /triage

Process inbox items and decide what to work on next. This command implements the GTD "Clarify/Process" and "Engage" steps on-demand.

## Usage
```
\triage           # Full triage (process inbox, then pick work)
\triage inbox     # Process inbox items only
\triage pick      # Pick work from available tasks
```

## Workflow Position

```
Capture → /triage (Process) → Organized Tasks → /daily → Work
              ↑
         Can run anytime (not just weekly)
```

## Mode 1: Process Inbox (`/triage inbox`)

Process unprocessed items from `inbox.md` and provider inboxes.

### Decision Tree

For each inbox item, work through this flow:

#### 1. Is it actionable?
- **No** → Route to:
  - Trash (delete it)
  - Reference (`reference/` folder)
  - Someday-Maybe (`someday-maybe.md`)
- **Yes** → Continue to step 2

#### 2. What's the specific next action?
- Clarify the exact physical next step
- "Research X" → "Search Google for X comparison articles"
- "Handle email from Bob" → "Reply to Bob with project timeline"

#### 3. Will it take less than 2 minutes?
- **Yes** → Do it now, mark complete
- **No** → Continue to step 4

#### 4. Is it a multi-step project?
- **Yes** → Create project in `projects/active/`, add first action
- **No** → Single action, continue to step 5

#### 5. Route the action
- Assign appropriate @context
- Route to provider via `integrations/config.md` rules
- Add to project's `tasks.md`

### Interactive Flow

Present each inbox item with options:

```
Item: "Look into new project management tools"

What would you like to do?
[T]rash   - Delete this item
[R]ef     - Move to reference/
[S]omeday - Add to someday-maybe.md
[A]ction  - Process as actionable item
[P]roject - Create new project

> A

What's the specific next action?
> Research top 5 project management tools and compare features

Context? [@work-computer, @home-computer, @work-code, etc.]
> @work-computer

2-minute rule: Can this be done right now in under 2 minutes?
[Y]es - Do it now
[N]o  - Add to tasks

> N

Which project does this belong to?
[1] operations (existing)
[2] Create new project
[3] General tasks (no project)

> 1

✓ Added to projects/active/operations/tasks.md
✓ Created in trello-cyclops (matched @work-* route)
```

### Provider Inbox Processing

Also process items from external provider inboxes:
- Check each provider's inbox/unsorted items
- Apply same decision tree
- Route to correct GTD project and provider location

## Mode 2: Pick Work (`/triage pick`)

Interactive selection of what to work on now.

### 1. Gather Available Tasks

Pull ready tasks from:
- All active projects' `tasks.md` files
- All synced providers (already reflected in GTD)
- Filter to incomplete tasks only

### 2. Present Grouped by Context

Show tasks organized by context with provider source:

```
Available Tasks by Context:

@work-code:
  [ ] Fix authentication bug (trello-cyclops)
  [ ] Write unit tests for auth module (trello-cyclops)
  [ ] Refactor database queries (trello-software)

@work-computer:
  [ ] Prepare client presentation (trello-cyclops)
  [ ] Update project documentation (local-gtd)

@home-calls:
  [ ] Call dentist to schedule cleaning (asana-personal)
  [ ] Follow up with insurance company (asana-personal)

@errands:
  [ ] Buy groceries (local-gtd)
  [ ] Pick up dry cleaning (local-gtd)

Which tasks do you want to focus on? (Enter numbers, e.g., 1,3,5)
```

### 3. Selection Options

User picks 1-5 items for current work session:
- Creates lightweight focus list
- Can optionally feed into `/daily` planning
- Tracks selected items for the session

### Focus List Output

```
## Current Focus

Selected for this work session:

1. [ ] Fix authentication bug (@work-code, trello-cyclops)
2. [ ] Call dentist to schedule cleaning (@home-calls, asana-personal)
3. [ ] Prepare client presentation (@work-computer, trello-cyclops)

Context switches required: 3
Estimated providers involved: trello-cyclops, asana-personal
```

## Default Behavior (`/triage`)

When run without arguments:

1. **Check inbox** - If `inbox.md` or provider inboxes have items:
   - Process inbox items first
   - Apply decision tree to each

2. **Offer pick mode** - After inbox is clear (or if already empty):
   - Ask: "Inbox is clear. Would you like to pick work to focus on?"
   - If yes, run pick mode

## AI Guidelines

### Inbox Processing
- Present one item at a time for focused processing
- Suggest likely categorizations based on content
- Remember context from previous items (batch similar items)
- Validate 2-minute rule honestly - most tasks take longer than you think

### Pick Mode
- Show highest-priority items first within each context
- Highlight items with due dates or dependencies
- Suggest context batching (group similar contexts together)
- Respect energy levels if time of day is known

### Conservative Routing
- When uncertain about project assignment, ask
- Default to existing projects over creating new ones
- Use local-gtd for items that don't clearly fit a provider

## Integration with Other Commands

### With /capture
Items captured to inbox flow through `/triage inbox` for processing.

### With /daily
- Run `/triage` before `/daily` to ensure inbox is clear
- `/triage pick` selections can inform daily Top 3 priorities
- Daily plan can reference triage focus list

### With /weekly
- Weekly review includes full inbox processing
- `/triage inbox` allows processing between weekly reviews
- Keeps inbox manageable throughout the week

### With /sync
- Run `/sync` before `/triage pick` to ensure task list is current
- Triage respects provider routing from sync configuration

## Configuration Reference

See `integrations/config.md` for:
- Provider instances and routing rules
- Context-to-provider mappings
- Default provider settings

See `projects/active/*/tasks.md` for:
- Current task organization by context
- Task format and status markers
