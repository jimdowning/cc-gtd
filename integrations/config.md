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

Note sources provide tasks captured organically in other tools (journaling apps, note-taking apps, email). These are scanned during `/capture` to surface tasks for formalization into the GTD system.

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

### Gmail (IMAP)
```markdown
### gmail-work
- **type**: gmail
- **account**: your-email@example.com
- **auth**: integrations/scripts/gmail-gtd/your-email@example.com
- **label**: gtd
- **description**: Scan Gmail for emails labeled 'gtd'
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

---

## Adding New Providers

To add a new provider instance:

1. Add a new section to `systems/<name>/config.md` under the appropriate category
2. Specify the provider type (must match an adapter in `integrations/adapters/`)
3. Configure type-specific settings (board, workspace, calendar, etc.)
4. Define routing rules to determine when this provider is used
5. For Trello boards, add a reference doc in `systems/<name>/reference/`
