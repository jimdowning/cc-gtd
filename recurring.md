# Recurring Tasks

Templates for tasks that repeat on a schedule. The `/daily` and `/weekly` commands check this file and create task instances when due.

## How It Works

1. Define templates below with a schedule
2. `/daily` checks which tasks are due (or due soon)
3. Creates instances in the appropriate provider (Trello, local, etc.)
4. Marks last_created date to prevent duplicates

## Schedule Formats

- `monthly: 14` - 14th of each month
- `monthly: last` - last day of each month
- `weekly: monday` - every Monday
- `weekly: monday, thursday` - multiple days
- `daily` - every day
- `biweekly: friday` - every other Friday
- `quarterly: 1` - 1st of Jan, Apr, Jul, Oct

## Template Schema

```
### [task-id]
- **task**: Task description
- **schedule**: monthly: 14
- **provider**: trello-personal
- **list**: This Week (or Today, Committed, etc.)
- **due_offset**: +3d (optional - due date relative to trigger)
- **last_created**: 2026-01-14 (auto-updated)
```

---

## Active Templates

### file-expenses
- **task**: File expenses
- **schedule**: monthly: 14
- **provider**: trello-personal
- **list**: This Week
- **due_offset**: +11d
- **last_created**: 2026-01-14

### pay-amex
- **task**: Pay Amex
- **schedule**: monthly: 10
- **provider**: trello-personal
- **list**: This Week
- **due_offset**: +7d
- **last_created**: 2026-01-27 (skipped - already paid)

### slt-update
- **task**: SLT update
- **schedule**: weekly: monday
- **provider**: trello-personal
- **list**: Today
- **notes**: Prepare Monday afternoon for Tuesday morning meeting
- **last_created**: 2026-01-26

### review-digital-twin-value-prop
- **task**: Review Digital twin value prop progress
- **schedule**: monthly: 15
- **provider**: trello-personal
- **list**: This Week
- **notes**: Check progress on digital twin value prop (trello-software backlog). Either make progress or consciously defer.
- **link**: https://trello.com/c/U2Zpvxb3
- **last_created**: 2026-01-27

### book-monthly-planning
- **task**: Run /book-monthly-planning to ensure next 3 months covered
- **schedule**: monthly: 1
- **provider**: local-gtd
- **notes**: Ensures Monthly Software Planning meetings are booked for the next 3 months around the 2nd Wednesday of each month
- **last_created**: 2026-01-27 (skipped)

---

## Paused Templates

<!-- Move templates here to pause them without deleting -->

