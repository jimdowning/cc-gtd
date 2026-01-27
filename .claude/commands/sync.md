# /sync

Sync GTD system with all configured todo providers using routing rules.

DO NOT CREATE DUPLICATE PROJECTS/TASKS in external providers.
DO NOT CLOSE ANY TASKS/PROJECTS automatically - mark things as completed in the external provider and they should be reflected in GTD system.

## Usage
```
\sync [provider]
```

Where `provider` is optional:
- No argument: Sync all configured providers
- Provider name: Sync specific provider only (e.g., `\sync trello-cyclops`)

## Process

When this command is run, perform bidirectional sync between external providers and the GTD system:

### 1. Load Provider Configuration
- Read `integrations/config.md` for configured todo providers
- Each provider instance has: type, board/workspace, auth, routes
- Load the appropriate adapter from `integrations/adapters/todo/{{type}}.md`

### 2. For Each Todo Provider Instance

#### Step A: Determine Matching Projects
Based on provider's route rules, identify which GTD projects should sync with this provider:
- Match by project path: `project: cyclops/*` matches `projects/active/cyclops-*`
- Match by context: `context: @work-*` matches tasks with @work-code, @work-errand, etc.
- Default provider gets unmatched projects

#### Step B: Read Local Context
For each matching GTD project:
- Read `projects/active/[project]/info.md` for project goals and context
- Read `projects/active/[project]/tasks.md` for current GTD tasks organized by context
- Parse tasks into list format: `[task content, context, completed_status]`

#### Step C: Read External Provider Context
Query the external provider using adapter commands:

**Trello:**
```bash
trello card list --board "{{board}}"
```

**Asana:**
```bash
asana task list --workspace "{{workspace}}" --project "{{project}}"
```

**Todoist:**
```bash
tod list view --project "{{project}}"
```

**Local:** No external query needed

#### Step D: Compare and Sync
- **Tasks in GTD but not in provider**: Create in external provider using adapter
- **Tasks in provider but not in GTD**: Add to appropriate context section in `tasks.md`
- **Completed tasks in provider**: Mark as completed in GTD (`- [ ]` → `- [x]`) and log in `info.md`

### 3. Process Inbox
For each provider that handles inbox routing:
1. Get inbox tasks from provider
2. Determine which GTD project and context each belongs to
3. Route to appropriate project's `tasks.md`
4. Optionally move task to correct project in external provider

### 4. Report Summary
```
Sync complete:
- trello-cyclops: 5 tasks synced (2 new from GTD, 1 new from Trello, 2 completed)
- asana-personal: 3 tasks synced (1 new from GTD, 2 new from Asana)
- local-gtd: 8 tasks (local only, no external sync)
```

## Provider-Specific Behavior

### Trello (trello.md adapter)
- GTD Project → Trello Board/List
- GTD Task → Trello Card
- GTD Context → Trello Label
- Create: `trello card create --board "{{board}}" --list "{{list}}" --name "{{task}}"`
- Complete: `trello card archive --board "{{board}}" --card "{{card_id}}"`

### Asana (asana.md adapter)
- GTD Project → Asana Project
- GTD Task → Asana Task
- GTD Context → Asana Tag
- Create via API or CLI (see adapter)
- Complete: Mark task complete in Asana

### Todoist (todoist.md adapter)
- GTD Project → Todoist Project
- GTD Task → Todoist Task
- GTD Context → Todoist Label
- Create: `echo -e "\n" | tod task create --project "{{project}}" --label "{{context}}" --content "{{task}}" --no-section --priority X`
- Complete: `tod task complete` (after `tod task next`)

### Local (local.md adapter)
- No external sync - tasks stay in GTD markdown files only
- Useful for someday/maybe, quick captures, offline items
- "Sync" verifies file integrity only

## Routing Examples

### Task: "Fix authentication bug" with context @work-code
1. Check routes in order:
   - `trello-cyclops` routes: `project: cyclops/*`, `context: @work-*` ← MATCH
2. Use trello adapter to create card in Cyclops board

### Task: "Buy groceries" with context @errands
1. Check routes in order:
   - `trello-cyclops` routes: No match
   - `asana-personal` routes: `context: @home-*` - No match (errands != home)
   - `local-gtd` routes: `default: true` ← MATCH
2. Keep in GTD files only (no external sync)

### Task: "Schedule dentist" with context @home-calls
1. Check routes in order:
   - `trello-cyclops` routes: No match
   - `asana-personal` routes: `context: @home-*` ← MATCH
2. Use asana adapter to create task in Personal workspace

## AI Guidelines

### Duplicate Prevention
- Before creating any task, verify it doesn't already exist in target
- Compare task content semantically, not just exact string matches
- Skip creation if task already exists

### Context Mapping
Map GTD contexts to provider-specific tags/labels consistently:
- See adapter files for provider-specific mappings
- Preserve context when syncing bidirectionally

### Completion Handling
- Only mark tasks completed in GTD when completed in external provider
- Never mark tasks completed in external provider automatically
- Log completions in project's info.md task history section

### Conservative Approach
- When in doubt about routing, use local-gtd (no external sync)
- Preserve existing organization rather than reorganizing
- Focus on sync accuracy over automation

## Configuration Reference

See `integrations/config.md` for:
- Adding new todo providers
- Setting up authentication
- Configuring routing rules
- Provider-specific settings

See `integrations/adapters/todo/` for:
- `trello.md` - Trello CLI adapter
- `asana.md` - Asana CLI/API adapter
- `todoist.md` - Tod CLI adapter
- `local.md` - Local-only adapter
