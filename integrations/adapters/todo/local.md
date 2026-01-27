# Local Adapter

No-op adapter for tasks that don't need external sync. Tasks stay in GTD markdown files only.

## Purpose

The local adapter is used for:
- Quick captures that don't need external tracking
- Someday/maybe items
- Personal notes and ideas
- Offline work
- Items that are too small to warrant external tool overhead
- Default fallback when no other provider matches

## Instance Configuration

The adapter receives minimal configuration:
- `routes`: Routing rules (typically includes `default: true`)

No authentication or external service configuration needed.

## Operations

### Create Task
**Action**: Add task to appropriate GTD file only

No external API calls. Task is added to:
- Project's `tasks.md` if project context is clear
- `inbox.md` if project unclear

Format:
```markdown
- [ ] {{task_content}}
```

With timestamp (for inbox):
```markdown
- [ ] {{timestamp}} - {{task_content}}
```

### List Tasks
**Action**: Read from GTD markdown files

Parse tasks from:
- `projects/active/*/tasks.md`
- `inbox.md`
- `someday-maybe.md`

### Update Task
**Action**: Edit GTD markdown file directly

Modify the task line in the appropriate file.

### Complete Task
**Action**: Mark checkbox in GTD file

Change:
```markdown
- [ ] Task content
```
To:
```markdown
- [x] Task content
```

### Delete Task
**Action**: Remove line from GTD file

Remove the task line entirely (use sparingly).

## Sync Process

Since there's no external service, "sync" for local adapter means:
1. Verify GTD file integrity
2. Ensure tasks are in correct context sections
3. Report any orphaned or malformed tasks

## When to Use Local Adapter

### Good Use Cases
- Personal reminders: "Remember to call mom on Sunday"
- Quick ideas: "Blog post idea: productivity tips"
- Someday/maybe items: "Learn to play guitar"
- Small one-off tasks: "Clean desk"
- Items during offline work

### Consider External Provider For
- Collaborative tasks (use Trello/Asana)
- Mobile capture needs (use Todoist)
- Tasks requiring notifications/reminders
- Work items with team visibility requirements

## Benefits

1. **No dependencies**: Works without internet or external accounts
2. **Fast**: No API latency
3. **Private**: Data stays local
4. **Simple**: Markdown is human-readable and portable
5. **Reliable**: No sync conflicts or API failures

## Error Handling

- If file doesn't exist: Create it with standard template
- If file is malformed: Report and attempt to parse what's valid
- If permissions error: Report and skip

## Example Operations

### Capture to Local
```markdown
# In inbox.md
- [ ] 2025-07-15 10:30 - Research vacation destinations
```

### Add to Project
```markdown
# In projects/active/home-improvement/tasks.md
## @home-computer
- [ ] Order new light fixtures online
```

### Mark Complete
```markdown
# Before
- [ ] Order new light fixtures online

# After
- [x] Order new light fixtures online
```
