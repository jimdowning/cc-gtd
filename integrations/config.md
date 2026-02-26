# Integration Configuration

This file documents the provider schema, routing logic, and serves as a template. Actual provider instances live in each system's `config.md` at `systems/<active>/config.md`.

**Resolution:** Commands read the active system from `.claude/active-system`, then load `systems/<active>/config.md` for provider instances. This file defines the schema those configs follow.

**Migration note:** If `integrations/config.local.md` exists, it is a legacy flat-structure config. System-specific config should be moved to `systems/<name>/config.md`.

## Routing Logic

When capturing or syncing:
1. Determine context/project of item
2. Find matching provider instance by route rules (from `systems/<active>/config.md`)
3. Load adapter for that provider type
4. Execute operation with instance-specific config

Route matching priority:
1. Explicit project match (`project: cyclops/*`)
2. Context match (`context: @work-*`)
3. Default fallback (`default: true`)

---

## Todo Provider Schema

```yaml
name: unique-instance-id
type: trello | asana | todoist | local
# Type-specific config:
board: Board Name             # trello
board_id: BOARD_ID            # trello
workspace: Workspace Name     # asana
# Authentication:
auth: default | path-to-config
# Board structure reference:
reference: reference/board-name.md  # optional
board_type: kanban | gtd            # optional
# List mapping (trello):
list_mapping:
  List Name: LIST_ID
# Routing rules (first match wins):
routes:
  - project: glob-pattern
  - context: glob-pattern
  - default: true
```

### Example: Trello GTD Board
```markdown
### trello-personal
- **type**: trello
- **board**: My Personal Board
- **board_id**: YOUR_BOARD_ID
- **auth**: your-email@example.com
- **list_mapping**:
  - Today: `LIST_ID`
  - This Week: `LIST_ID`
  - Waiting For: `LIST_ID`
  - Committed: `LIST_ID`
  - Someday/Maybe: `LIST_ID`
  - Projects: `LIST_ID`
  - Inbox: `LIST_ID`
  - Done: `LIST_ID`
  - Reference: `LIST_ID`
- **routes**:
  - context: `@personal-*`
  - default: true
```

### Example: Trello Kanban Board
```markdown
### trello-software
- **type**: trello
- **board**: Software Team
- **board_id**: YOUR_BOARD_ID
- **auth**: your-email@example.com
- **reference**: `reference/software-team-board.md`
- **board_type**: kanban
- **list_mapping**:
  - Reference: `LIST_ID`
  - Inbox: `LIST_ID`
  - Backlog: `LIST_ID`
  - In Progress: `LIST_ID`
  - Done: `LIST_ID`
- **routes**:
  - project: `software/*`
  - context: `@work-code`
```

### Example: Other Providers
```markdown
### asana-personal
- **type**: asana
- **workspace**: Personal
- **routes**:
  - project: `personal/*`
  - context: `@home-*`

### todoist-main
- **type**: todoist
- **auth**: default (tod CLI configured)
- **routes**:
  - project: `sideprojects/*`
  - context: `@sideprojects-*`

### local-gtd
- **type**: local
- **routes**:
  - default: true (fallback for unmatched items)
```

---

## Calendar Provider Schema

```yaml
name: unique-instance-id
type: gcal
# Type-specific config:
calendar: email-or-name
# Authentication:
auth: path-to-oauth-config
# Display:
label: "[source-label]"
# Routing rules:
routes:
  - context: glob-pattern
  - default: true
```

### Example: Google Calendar
```markdown
### gcal-work
- **type**: gcal
- **calendar**: your-email@example.com
- **auth**: default
- **label**: `[work]`
- **routes**:
  - context: `@work-*`

### gcal-personal
- **type**: gcal
- **calendar**: personal@example.com
- **auth**: `~/.config/gcal-personal-oauth`
- **label**: `[personal]`
- **routes**:
  - context: `@home-*`
  - default: true
```

---

## Note Source Schema

Note sources provide tasks captured organically in other tools (journaling apps, note-taking apps). These are scanned during `/capture` to surface tasks for formalization into the GTD system.

### Obsidian (MCP)
```markdown
### obsidian
- **type**: obsidian-mcp
- **daily_notes_folder**: Journal/
- **scan_days**: 7
- **checkbox_pattern**: `- [ ]`
- **mark_captured**: true
- **mcp_server**: obsidian-mcp-tools
- **description**: Scan daily notes for incomplete checkbox items
```

---

## Messaging Source Schema

Messaging sources provide read-only context from archived team communication. Scanned during Orient phase to surface conversations, requests, and missed messages.

### Slackdump (SQLite)
```markdown
### slackdump
- **type**: slackdump
- **db_path**: path to SQLite database (relative to system root)
- **user_match**: display name or real name to identify user in Slack records
- **scan_hours**: 24 (default, how far back to scan)
- **excluded_channels**: (optional list of channel names to skip)
- **description**: Scan Slack archive for conversations, requests, and missed messages
```

---

## Journal Provider Schema

The journal provider tells commands where to read and write daily plans, weekly plans, and reviews. Without this, commands must guess at journal location.

```yaml
name: unique-instance-id
type: local | obsidian
# Type-specific config:
daily_path: journal/daily/          # local: relative to system root
weekly_path: journal/weekly/        # local: relative to system root
daily_note_format: "YYYY-MM-DD.md"  # filename format for daily notes
weekly_note_format: "YYYY-WNN-plan.md"  # filename format for weekly plans
weekly_review_format: "YYYY-WNN-review.md"  # filename format for weekly reviews
# Obsidian-specific (type: obsidian):
vault_daily_folder: Journal/        # Obsidian vault path for daily notes
vault_weekly_folder: Journal/       # Obsidian vault path for weekly plans
```

### Behaviour by Type

**local** — Journal files live in `systems/<active>/journal/`. Commands use the Read/Write tools directly.

**obsidian** — Journal files live in both the local system directory AND in the Obsidian vault. Commands write to both locations to keep them in sync. Reading prefers local (faster, not gitignored-tool-limited).

### Example: Local + Obsidian Mirror
```markdown
### journal
- **type**: local
- **daily_path**: journal/daily/
- **weekly_path**: journal/weekly/
- **daily_note_format**: `YYYY-MM-DD.md`
- **weekly_note_format**: `YYYY-WNN-plan.md`
- **weekly_review_format**: `YYYY-WNN-review.md`
- **obsidian_mirror**: true
- **vault_daily_folder**: Journal/
- **vault_weekly_folder**: Journal/
```

When `obsidian_mirror: true`, after writing a journal file locally, also write it to the Obsidian vault using the MCP tools. This keeps the Obsidian daily notes in sync without making Obsidian the primary storage.

### Content Rules

Journal notes are scanned by the capture pipeline (Obsidian adapter). Every unchecked checkbox (`- [ ]`) is treated as a potential task to capture. This means journal content must be written carefully to avoid creating noise that resurfaces on every scan.

**Rule 1: Act in providers, don't narrate in the journal.**
When a task's status changes (due date moved, completed, deferred), make the change in the provider (update Trello card due date, move card to Done, etc.). Do NOT write a journal note describing the change — that creates a text fragment that the scanner may pick up as a new item.

Bad: `- [ab12c] Migration project — due date pushed to Mar 9` (bare text, re-capturable)
Good: Update the Trello card's due date to Mar 9. Omit from journal entirely.

Bad: `- [xy34z] Review vendor agreement — done` (bare text, re-capturable)
Good: Ensure the Trello card is in the Done column. Omit from journal entirely.

**Rule 2: Only `- [ ]` for today's active work.**
Unchecked checkboxes (`- [ ]`) should only appear in **today's** daily plan for tasks that are actively being worked on today. They represent "I intend to do this today."

**Rule 3: All task references in past days must be `- [x]`.**
Once a day is over, every checkbox in that day's journal should be checked (`- [x]`). Whether the task was completed, deferred, or dropped — the checkbox is checked because it has been **dealt with** (processed, not necessarily done). This prevents the capture scanner from re-surfacing old items.

**Rule 4: No bare task-ID text outside checkboxes.**
Never write task IDs (`[xxxxx]`) in free text, bullet points, or update notes. If a task needs to appear in the journal, it must be in checkbox format. If it doesn't need to appear (status change handled in provider), omit it.

**Rule 5: The `## Top 3 Priorities` section uses numbered lists, not checkboxes.**
These are descriptive headings for the day's focus, not capturable items. They reference tasks but are not themselves tasks. This format is safe from the scanner.

**What belongs in journal notes:**
- Calendar (table format — not capturable)
- Top 3 priorities (numbered list — not capturable)
- Time blocks with checkboxes for today's tasks
- User-written notes and reflections (free text under `# Notes`)
- Daily review with checked checkboxes

**What does NOT belong in journal notes:**
- Status updates about provider changes ("pushed to...", "moved to...", "done")
- Informational notes that reference task IDs without checkboxes
- Unchecked checkboxes for tasks not being worked on today

---

## Adding New Providers

To add a new provider instance:

1. Add a new section to `systems/<name>/config.md` under the appropriate category
2. Specify the provider type (must match an adapter in `integrations/adapters/`)
3. Configure type-specific settings (board, workspace, calendar, etc.)
4. Define routing rules to determine when this provider is used
5. For Trello boards, add a reference doc in `systems/<name>/reference/`
