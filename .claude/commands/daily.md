# /daily

Create and update today's daily plan with prioritized tasks and time blocks.

## Prerequisites

Ensure context is synced with all providers and calendar before proceeding.
Run `/sync` and `/calendar` commands before creating the daily plan.

**Optional but recommended:** Run `/triage` first to:
- Process any inbox items that accumulated overnight
- Ensure all tasks are clarified and properly routed
- Pick focus items that inform your Top 3 priorities

## Usage
```
\daily
```

## Process

### 1. Check Recurring Tasks
Before syncing, check `recurring.md` for tasks due today or in the next few days:
- Parse each template's schedule
- Compare against `last_created` date
- If due and not yet created this cycle:
  1. Create task in specified provider (e.g., Trello card)
  2. Update `last_created` date in `recurring.md`
  3. Report what was created

### 2. Sync All Providers
After creating recurring task instances, sync with external providers:
- Run `/sync` to bidirectionally sync with all todo providers
- Run `/calendar` to fetch today's events from all calendar providers

### 3. Aggregate Calendar Events
From all configured calendar providers in `integrations/config.md`:
- Fetch today's events from each provider (gcal-work, gcal-personal, etc.)
- Merge into unified view with source labels
- Example: `[work] 09:00 Standup`, `[personal] 18:00 Dentist`

### 4. Pull Tasks from All Sources
From GTD system (already synced with providers):
- Read all active projects' `tasks.md` files
- Identify high-priority items across all contexts
- Consider tasks from all providers (Trello, Asana, Todoist, local)

### 5. Create Daily Plan
Build structured plan with:
- Calendar commitments (fixed time blocks)
- Available time blocks for task work
- Task assignments optimized for energy levels

## Features

- **Multi-Provider Calendar**: Shows events from all calendar providers with labels
- **Smart Task Selection**: Pulls high-priority items from all synced providers
- **Energy Mapping**: Schedules tasks based on optimal energy levels
- **Time Blocking**: Creates structured focus sessions around calendar commitments
- **Project Integration**: Reviews all active projects' `info.md` for status and `tasks.md` for next actions

## Daily Plan Structure

```markdown
# Daily Log - 2025-06-26

## Calendar
**Source: All providers**
- `[work]` 09:00-10:00 Team Standup
- `[work]` 11:00-12:00 Sprint Planning
- `[personal]` 18:00-19:00 Dentist appointment

## Daily Plan
**Last Updated:** 09:15

### Top 3 Priorities
1. [ ] Complete user authentication debugging (trello-cyclops)
2. [ ] Client presentation preparation (trello-cyclops)
3. [ ] Schedule dentist follow-up (asana-personal)

### Time Blocks
- **08:00-09:00** High Energy Block (before standup)
  - [ ] @work-code: Debug authentication system
- **10:00-11:00** Deep Work Block
  - [ ] @work-code: Write unit tests for auth module
- **14:00-15:30** Focus Block
  - [ ] @work-computer: Prepare client presentation slides
- **17:00-18:00** Admin Block (before dentist)
  - [ ] @home-calls: Schedule dentist follow-up
  - [ ] @home-computer: Pay utility bills

### Energy Mapping
- **High Energy (8-11am)**: Complex coding tasks (@work-code)
- **Medium Energy (11am-3pm)**: Presentations, planning
- **Low Energy (3-5pm)**: Emails, administrative work, calls

## Work Log
<!-- Timestamped activities throughout the day -->
```

## Multi-Provider Calendar View

The calendar section aggregates from all providers:

```markdown
## Today's Calendar

### Work (gcal-work)
- 09:00-10:00 Team Standup
- 11:00-12:00 Sprint Planning
- 14:00-15:00 Client Call

### Personal (gcal-personal)
- 18:00-19:00 Dentist appointment
- 19:30-21:00 Dinner with Sarah

### Merged View
| Time | Event | Source |
|------|-------|--------|
| 09:00 | Team Standup | [work] |
| 11:00 | Sprint Planning | [work] |
| 14:00 | Client Call | [work] |
| 18:00 | Dentist | [personal] |
| 19:30 | Dinner | [personal] |
```

## AI Optimization

- Analyzes task complexity and energy requirements
- Suggests optimal scheduling based on typical energy patterns
- Identifies dependencies and suggests task ordering
- Flags potential scheduling conflicts across calendar providers
- Balances work and personal commitments

## Update Behavior

- Creates new daily log if none exists for today
- Updates existing plan while preserving work log entries
- Suggests plan adjustments based on completed/remaining work
- Maintains plan history with timestamps

## Integration with Providers

Tasks in daily plan link back to their source provider:
- Trello tasks can be opened in Trello
- Asana tasks can be opened in Asana
- Todoist tasks can be opened in Todoist
- Local tasks are GTD-only

## Configuration Reference

See `integrations/config.md` for:
- Calendar provider configuration
- Todo provider configuration
- Routing rules

See `recurring.md` for:
- Recurring task templates
- Schedule formats (monthly, weekly, daily, etc.)
- Provider routing for recurring tasks

See `/calendar` command for calendar aggregation details.
See `/sync` command for todo provider sync details.
See `/triage` command for inbox processing and work selection.
