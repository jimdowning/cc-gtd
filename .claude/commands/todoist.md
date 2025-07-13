# /todoist

Sync Todoist with GTD system using AI-powered processing via tod CLI.

DO NOT CREATE DUPLICATE PROJECTS/TASKS IN Todoist.
DO NOT CLOSE ANY TASKS/PROJECTS automatically, I'll mark things as completed on todoist and they should be reflected in GTD system.
Read the reference/todoist-to-tod-migration-notes.md for usage notes for tod CLI migration.

## Process

When this command is run, perform the following bidirectional sync between Todoist and the GTD system:

### 1. Get Active GTD Projects
- Read all active GTD projects from `projects/active/*/info.md` files
- For each project directory, extract the project name from the directory name or info.md

### 2. Bidirectional Project Sync
For each active GTD project:

**Step A: Read Local Context**
- Read `projects/active/[project]/info.md` to understand project goals and context
- Read `projects/active/[project]/tasks.md` to get current GTD tasks organized by context
- Parse tasks into list format: `[task content, context, completed_status]`

**Step B: Read Todoist Context**
- Query Todoist for tasks in matching project: `tod list view --project "[Project Name]"`
- Parse Todoist tasks into comparable format: `[task content, labels, completed_status]`

**Step C: Compare and Sync**
- **Tasks in GTD but not in Todoist**: Add to Todoist using `echo -e "\n" | tod task create --project "[Project Name]" --label "@context" --content "[Task]" --no-section --priority X`
- **Tasks in Todoist but not in GTD**: Add to appropriate context section in `tasks.md` using format `- [ ] [task content]`
- **Completed tasks in Todoist**: Mark as completed in GTD by changing `- [ ]` to `- [x]` in `tasks.md` and log completion in `info.md` task history

### 3. Process Inbox
- Get all Inbox tasks: `tod list view --project "Inbox"`
- For each inbox task, determine:
  - Which GTD project it belongs to (if any)
  - Appropriate context (@work-code, @work-errand, @home-computer, @home-calls, @sideprojects-code, @sideprojects-errand, @errands)
- Add to appropriate project's `tasks.md` file
- Create corresponding task in proper Todoist project with context label

### 4. Someday/Maybe Sync
- Read `someday-maybe.md` 
- Compare with Todoist `Someday/Maybe` project
- Sync bidirectionally following same diff logic as active projects

### 5. Task Format Standards
**GTD Format**: `- [ ] [task content]` (incomplete) or `- [x] [task content]` (completed)
**Todoist Creation**: `echo -e "\n" | tod task create --project "[Project Name]" --label "@context" --content "[Task]" --no-section --priority X`

## AI Guidelines

**Duplicate Prevention:**
- Before creating any task, verify it doesn't already exist in the target system
- Compare task content semantically, not just exact string matches
- Skip creation if task already exists

**Context Mapping:**
- Map GTD contexts to Todoist labels consistently
- Available contexts: @work-code, @work-errand, @home-computer, @home-calls, @sideprojects-code, @sideprojects-errand, @errands
- Default to @home-computer if context unclear

**Completion Handling:**
- Only mark tasks completed in GTD when they are completed in Todoist
- Never mark tasks completed in Todoist automatically
- Log completions in project's info.md task history section

**Conservative Approach:**
- When in doubt about project assignment, ask for clarification rather than guessing
- Preserve existing organization rather than reorganizing
- Focus on sync accuracy over automation