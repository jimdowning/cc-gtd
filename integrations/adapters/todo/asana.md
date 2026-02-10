# Asana Adapter

Adapter for syncing GTD tasks with Asana workspaces and projects.

## Role
- **source_type**: managed
- **capture_signal**: —
- **completion_signal**: Task marked complete in Asana
- **id_strategy**: external
- **primary_storage**: external

## Prerequisites

Install asana CLI or use the API directly:
```bash
# Option 1: asana-cli (if available)
npm install -g asana-cli

# Option 2: Use curl with Personal Access Token
# Set up PAT at: https://app.asana.com/0/developer-console
```

Configure authentication:
```bash
# Set environment variable
export ASANA_ACCESS_TOKEN="your-personal-access-token"

# Or create config file
echo "access_token: your-token" > ~/.asana/config
```

## GTD to Asana Mapping

| GTD Concept | Asana Concept |
|-------------|---------------|
| Project | Project |
| Task | Task |
| Context (@label) | Tag or Custom Field |
| Due date | Due date |
| Notes | Task description |
| Subtasks | Subtasks |

## Instance Configuration

The adapter receives these parameters from the provider instance config:
- `workspace`: Asana workspace name or GID
- `project`: Default project for new tasks (optional)
- `auth`: Path to auth config or "default"

## Commands (CLI)

### List Tasks
```bash
# List tasks in a project
asana task list --workspace "{{workspace}}" --project "{{project}}"

# List tasks assigned to me
asana task list --workspace "{{workspace}}" --assignee me

# Get task details
asana task show --task "{{task_gid}}"
```

### Create Task
```bash
# Create a new task
asana task create --workspace "{{workspace}}" --project "{{project}}" --name "{{task_content}}"

# Create with due date
asana task create --workspace "{{workspace}}" --project "{{project}}" --name "{{task_content}}" --due-on "{{due_date}}"

# Create with tags
asana task create --workspace "{{workspace}}" --project "{{project}}" --name "{{task_content}}" --tags "{{tag1}},{{tag2}}"
```

### Update Task
```bash
# Update task name
asana task update --task "{{task_gid}}" --name "{{new_name}}"

# Update due date
asana task update --task "{{task_gid}}" --due-on "{{due_date}}"

# Add tag
asana task add-tag --task "{{task_gid}}" --tag "{{tag_gid}}"
```

### Complete Task
```bash
# Mark task as complete
asana task complete --task "{{task_gid}}"
```

## Commands (API via curl)

### List Tasks
```bash
# List tasks in a project
curl -s -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/projects/{{project_gid}}/tasks?opt_fields=name,completed,due_on,tags.name"
```

### Create Task
```bash
# Create a new task
curl -s -X POST -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"name":"{{task_content}}","projects":["{{project_gid}}"],"workspace":"{{workspace_gid}}"}}' \
  "https://app.asana.com/api/1.0/tasks"
```

### Complete Task
```bash
# Mark task as complete
curl -s -X PUT -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"completed":true}}' \
  "https://app.asana.com/api/1.0/tasks/{{task_gid}}"
```

## Context to Tag Mapping

When creating tasks, map GTD contexts to Asana tags:

| GTD Context | Asana Tag |
|-------------|-----------|
| @home-computer | Computer |
| @home-calls | Calls |
| @errands | Errands |
| @home-* | Home |

## Sync Process

### GTD to Asana
1. Read tasks from project's `tasks.md`
2. For each uncompleted task:
   - Check if task exists in Asana (by name match)
   - If not, create task with appropriate project and tags
   - If exists, update if GTD version is newer

### Asana to GTD
1. List all incomplete tasks in workspace/project
2. For each task:
   - Check if task exists in GTD (by name match)
   - If not, add to appropriate context section in `tasks.md`
   - If task is completed in Asana, mark as completed in GTD

## Error Handling

- If workspace doesn't exist: Report error, skip this provider
- If project doesn't exist: Create it or use default
- If tag doesn't exist: Create it or skip tagging
- If rate limited: Wait and retry
- If network error: Retry once, then report and continue

## Example Sync Session

```bash
# Get workspace GID
curl -s -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/workspaces" | jq '.data[] | select(.name=="Personal")'

# List tasks in Personal project
curl -s -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/projects/{{project_gid}}/tasks?opt_fields=name,completed"

# Create task from GTD
curl -s -X POST -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"name":"Buy groceries","projects":["{{project_gid}}"]}}' \
  "https://app.asana.com/api/1.0/tasks"
```
