# /pick

Ad-hoc work selection: choose what to work on right now using context, time, energy, and priority.

## Usage
```
/pick
```

## When to Use

Between planned reviews — when you have time and want to choose the most valuable thing to do next. Uses GTD's four engagement criteria:

1. **Context** — What can I do here? (match @context to environment)
2. **Time** — How long do I have? (fit task to available slot)
3. **Energy** — What can I handle right now?
4. **Priority** — What matters most?

## Process

### 1. Gather Available Tasks

Pull ready tasks from:
- All active projects' `tasks.md` files
- Trello boards (Software Team and Personal — use cached data)
- Filter to incomplete tasks only

### 2. Present Grouped by Context

Show tasks organized by context with provider source:

```
Available Tasks by Context:

@work-code:
  [ ] [x7k2m] Fix authentication bug (trello-software)
  [ ] [a9f3q] Write unit tests for auth module (trello-software)
  [ ] [p4w8n] Refactor database queries (trello-software)

@work-computer:
  [ ] [k3m7j] Prepare client presentation (trello-software)
  [ ] [r2f9d] Update project documentation (local-gtd)

@home-calls:
  [ ] [w5n8t] Call dentist to schedule cleaning (trello-personal)
  [ ] [e6h1q] Follow up with insurance company (trello-personal)

@errands:
  [ ] [b4c2v] Buy groceries (local-gtd)
  [ ] [g7y3x] Pick up dry cleaning (local-gtd)

Which tasks do you want to focus on? (Enter numbers, e.g., 1,3,5)
```

### 3. Selection

User picks 1-5 items for current work session:
- Creates lightweight focus list
- Tracks selected items for the session

### Focus List Output

```
## Current Focus

Selected for this work session:

1. [ ] [x7k2m] Fix authentication bug (@work-code, trello-software)
2. [ ] [w5n8t] Call dentist to schedule cleaning (@home-calls, trello-personal)
3. [ ] [k3m7j] Prepare client presentation (@work-computer, trello-software)

Context switches required: 3
Estimated providers involved: trello-software, trello-personal
```

## AI Guidelines

- Show highest-priority items first within each context
- Highlight items with due dates or dependencies
- Suggest context batching (group similar contexts together)
- Respect energy levels if time of day is known

## Related Commands

- `/plan-day` — full morning planning session
- `/plan-week` — weekly planning with focus projects
- `/today` — view current plan
- `/capture` — capture new items before picking
