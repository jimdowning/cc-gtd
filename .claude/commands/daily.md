# Daily Plan

Create and update today's daily plan with prioritized tasks and time blocks.

Ensure context is synced with Todoist and Calendar.
Run /todoist and /calendar commands before proceeding with the daily plan.

## Usage
```
\daily
```

## Features
- **Smart Task Selection**: Pulls high-priority items from project `tasks.md` files
- **Energy Mapping**: Schedules tasks based on optimal energy levels
- **Time Blocking**: Creates structured focus sessions
- **Project Integration**: Reviews all active projects' `info.md` for status and `tasks.md` for next actions

## Daily Plan Structure
```markdown
# Daily Log - 2025-06-26

## 📋 Daily Plan
**Last Updated:** 09:15

### Top 3 Priorities
1. [ ] Complete user authentication debugging
2. [ ] Client presentation preparation  
3. [ ] Team check-in meetings

### Time Blocks
- **09:00-10:30** High Energy Block
  - [ ] @work-code: Debug authentication system
  - [ ] @work-code: Write unit tests for auth module
- **10:45-12:00** Deep Work Block
  - [ ] @work-computer: Prepare client presentation slides
- **14:00-15:30** Communication Block
  - [ ] @work-calls: Team check-in with Sarah
  - [ ] @work-calls: Client status update call

### Energy Mapping
- **High Energy (9-11am)**: Complex coding tasks
- **Medium Energy (11am-3pm)**: Presentations, planning
- **Low Energy (3-5pm)**: Emails, administrative work
```

## AI Optimization
- Analyzes task complexity and energy requirements
- Suggests optimal scheduling based on typical energy patterns
- Identifies dependencies and suggests task ordering
- Provides realistic time estimates based on similar past tasks
- Flags potential scheduling conflicts

## Update Behavior
- Creates new daily log if none exists for today
- Updates existing plan while preserving work log entries
- Suggests plan adjustments based on completed/remaining work
- Maintains plan history with timestamps