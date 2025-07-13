# Todoist CLI Usage Notes for GTD Integration

## Overview
Todoist will be used as the primary inbox capture tool, replacing inbox.md. During daily and weekly planning, we'll sync from Todoist to the GTD system.

## Key Commands

### Viewing Tasks

#### List all tasks
```bash
todoist list
```

#### Today's tasks and overdue
```bash
todoist list --filter "today | overdue"
```

#### Inbox items only
```bash
todoist list --filter "#Inbox"
```

#### By priority (p1-p4, where p1 is highest)
```bash
todoist list --filter "p1 | p2"
todoist list --priority  # Sort by priority
```

#### By project
```bash
todoist list --filter "#Taktile"
todoist list --filter "#Projects"
```

#### This week's tasks
```bash
todoist list --filter "7 days"
```

#### No date tasks
```bash
todoist list --filter "no date"
```

### Adding Tasks

#### Quick add (supports natural language)
```bash
todoist quick "Call dentist tomorrow at 2pm #Health"
todoist quick "Review PR today p1 #Taktile"
```

#### Detailed add
```bash
NAME:
   todoist add - Add task

USAGE:
   todoist add [command options] <Item content>

OPTIONS:
   --priority value, -p value      priority (1-4) (default: 4)
   --label-names value, -L value   label names (separated by ,)
   --project-id value, -P value    project id (default: 0)
   --project-name value, -N value  project name
   --date value, -d value          date string (today, 2020/04/02, 2020/03/21 18:00)
   --reminder, -r                  set reminder (only premium users) (default: false)
   --help, -h                      show help
todoist add --project-name "Ship Stoa Project" --label-names "@home-computer" "Add social login"
todoist add "Setup investment automation" --project-name "Finance" --date "next friday" --priority 2
todoist add "Book flights" --label-names "urgent,travel" --date "today"
```

### Managing Tasks

#### Complete a task
```bash
todoist close [task_id]
```

#### Modify task
```bash
todoist modify [task_id] --date "tomorrow"
todoist modify [task_id] --priority 1
```

#### Delete task
```bash
todoist delete [task_id]
```

#### Show task details
```bash
todoist show [task_id]
```

### Other Commands

#### List projects
```bash
todoist projects
```

#### List labels
```bash
todoist labels
```

#### Sync with server
```bash
todoist sync
```

## GTD Integration Strategy

### 1. Capture Phase
Use Todoist as the primary capture tool:
```bash
# Quick capture examples
todoist quick "Research Spain visa requirements"
todoist quick "Fix bug OPTI-1234 #Taktile p2"
todoist quick "Call mom #Personal"
```

### 2. Process Phase (Daily/Weekly)
During processing, fetch from Todoist and decide:
```bash
# Get all inbox items
todoist list --filter "#Inbox"

# Get overdue and today's items
todoist list --filter "today | overdue"

# Get items without dates
todoist list --filter "no date & #Inbox"
```

### 3. Organize Phase
Move processed items to appropriate GTD contexts:
- Tasks → projects/active/<project-name>/next-actions.md
- Projects → projects/active/
- Waiting → waiting-for.md
- Someday → someday-maybe.md

Then close or organize in Todoist:
```bash
# Close processed items
todoist close [task_id]

# Or move to project
todoist modify [task_id] --project-name "Projects"
```

## Current Todoist Projects
- **#Inbox** (ID: 2345697901) - Primary capture
- **#Taktile** (ID: 2345700484) - Work items
- **#Projects** (ID: 2345702237) - Active projects
- **#Health** (ID: 2345699539)
- **#Finance** (ID: 2345699556)
- **#Travel** (ID: 2345699519)
- **#Visa** (ID: 2345706018)
- **#Errands** (ID: 2345699465)
- **#Social** (ID: 2345699459)

## Syncing Workflow

### Daily Planning
1. Fetch inbox items: `todoist list --filter "#Inbox"`
2. Process each item:
   - 2-min tasks: Do immediately, then `todoist close [id]`
   - Tasks: Add to next-actions.md with context
   - Projects: Create project file if needed
3. Clear processed items from Todoist inbox

### Weekly Review
1. Check all projects: `todoist list --filter "#Projects"`
2. Review no-date items: `todoist list --filter "no date"`
3. Clean up completed: `todoist completed-list` (premium only)

## Custom /todoist Command Implementation
The custom command should:
1. Fetch all inbox items from Todoist
2. For each item:
   - Determine if it's a task or project
   - Add to appropriate GTD file
   - Mark as processed in Todoist
3. Generate summary of items processed

## Output Format Notes
- Task IDs are in blue: `[34m8714063836[0m`
- Priorities shown as: `[1;34;40mp4[0m` (p1-p4)
- Overdue dates in red: `[1;37;41m25/06/25(Wed) 00:00[0m`
- Projects in colors: `[91m#Inbox[0m`

## Tips
- Use natural language dates: "today", "tomorrow", "next friday"
- Add projects with #: "#Taktile meeting tomorrow"
- Add priority with p1-p4: "Important task p1"
- Multiple labels: --label-names "urgent,work"
- Filter combinations: "today & #Taktile & p1"