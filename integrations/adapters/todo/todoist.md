# Todoist Adapter

Adapter for syncing GTD tasks with Todoist using the `tod` CLI.

## Prerequisites

Install tod CLI:
```bash
cargo install tod
```

Configure authentication:
```bash
tod configure
```

Import projects:
```bash
tod project import
```

## GTD to Todoist Mapping

| GTD Concept | Todoist Concept |
|-------------|-----------------|
| Project | Project |
| Task | Task |
| Context (@label) | Label |
| Due date | Due date |
| Priority | Priority (1-4) |
| Notes | Task comments |

## Instance Configuration

The adapter receives these parameters from the provider instance config:
- `auth`: "default" (uses tod's configured auth)
- `routes`: Routing rules for matching tasks

## Commands

### List Tasks
```bash
# List all tasks in a project
tod list view --project "{{project}}"

# List today's tasks
tod list view --filter "today"

# List tasks with specific filter
tod list view --filter "{{filter}}"

# List inbox tasks
tod list view --project "Inbox"
```

### Create Task
```bash
# Create task with project, label, and priority
# Note: tod task create requires TTY workaround
echo -e "\n" | tod task create \
  --project "{{project}}" \
  --content "{{task_content}}" \
  --label "{{context}}" \
  --priority {{priority}} \
  --no-section

# Quick add with natural language
tod task quick-add --content "{{task_content}} #{{project}} @{{context}}"
```

### Update Task
```bash
# Edit task (interactive)
tod task edit

# Note: tod has limited update capabilities
# Consider using quick-add for modifications
```

### Complete Task
```bash
# Complete the last fetched task
tod task next  # Fetch task first
tod task complete
```

## Priority Mapping

| GTD Priority | Todoist Priority |
|--------------|------------------|
| High/Urgent | 1 |
| Medium | 2 |
| Normal | 3 |
| Low | 4 |

## Context to Label Mapping

GTD contexts map directly to Todoist labels:

| GTD Context | Todoist Label |
|-------------|---------------|
| @work-code | @work-code |
| @work-errand | @work-errand |
| @home-computer | @home-computer |
| @home-calls | @home-calls |
| @sideprojects-code | @sideprojects-code |
| @sideprojects-errand | @sideprojects-errand |
| @errands | @errands |

## Sync Process

### GTD to Todoist
1. Read tasks from project's `tasks.md`
2. For each uncompleted task:
   - Check if task exists in Todoist (by content match)
   - If not, create with `tod task create`
   - Apply appropriate label and priority

### Todoist to GTD
1. List tasks with `tod list view --project "{{project}}"`
2. For each task:
   - Check if task exists in GTD (by content match)
   - If not, add to appropriate context section in `tasks.md`
   - If completed in Todoist, mark as completed in GTD

### Inbox Processing
1. Get inbox tasks: `tod list view --project "Inbox"`
2. For each task:
   - Determine target project and context
   - Add to GTD project's `tasks.md`
   - Create in proper Todoist project (or leave in Inbox)

## TTY Workaround

`tod task create` requires interactive TTY. Use this workaround:
```bash
echo -e "\n" | tod task create --project "Project" --content "Task" --no-section --priority 3
```

The `echo -e "\n"` pipes a newline to handle any prompts.

## Error Handling

- If project doesn't exist in tod config: Run `tod project import`
- If label doesn't exist: Create it in Todoist web UI
- If auth fails: Run `tod configure`
- If network error: Retry once, then report and continue

## Batch Operations

Tod supports batch operations useful for GTD:
```bash
# Process tasks one by one
tod list process --project "Inbox"

# Batch prioritize
tod list prioritize --project "Project"

# Batch schedule
tod list schedule --project "Project"

# Import tasks from file
tod list import --file tasks.txt
```

## Example Sync Session

```bash
# View inbox
tod list view --project "Inbox"

# Create task from GTD
echo -e "\n" | tod task create \
  --project "Side Projects" \
  --content "Update documentation" \
  --label "@sideprojects-code" \
  --priority 3 \
  --no-section

# Get next task
tod task next

# Mark complete
tod task complete
```

## Reference

See also:
- `reference/todoist-to-tod-migration-notes.md` for migration details
- `reference/todoist-cli-usage-notes.md` for legacy CLI reference
