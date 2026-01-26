# Claude Code Project Instructions

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
