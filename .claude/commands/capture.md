# /capture

Quickly capture thoughts, ideas, and tasks. Uses AI to auto-process obvious single-step actions and route to the correct provider.

## Usage
```
\capture [item]
```

## Source: Obsidian Journal

When run without arguments, capture also scans Obsidian daily notes for incomplete checkbox items.

### Obsidian Integration

Uses MCP tools from obsidian-mcp-tools:

1. **List recent daily notes**
   - Tool: `list_vault_files` with directory `Journal/`
   - Filenames are always `YYYY-MM-DD.md`
   - Compute the date 7 days ago and only select files whose filename date is within the last 7 days
   - Ignore subdirectories (e.g. `2024/`, `2025/`) and any file whose name doesn't match `YYYY-MM-DD.md`

2. **Read each matching note**
   - Tool: `get_vault_file` for each daily note from the last 7 days only
   - Parse for incomplete checkboxes: `- [ ] task text`

3. **Present to user**
   - Show found incomplete items grouped by date
   - User confirms which to capture as tasks

4. **Process confirmed items**
   - Route through standard capture analysis
   - Optionally mark as captured in Obsidian (update to `- [x]`)

### Example Flow

```
/capture
-> Scanning Obsidian journal...
-> Found 3 incomplete items:

  2026-01-26.md:
  - [ ] Email response to client
  - [ ] Review PR #123

  2026-01-25.md:
  - [ ] Follow up on invoice

-> [Select items to capture or press Enter for all]
```

See `integrations/adapters/notes/obsidian.md` for MCP tool details.

## Source: Gmail Labeled Emails

When run without arguments, capture also scans Gmail accounts configured as note sources in `integrations/config.md` for emails labeled `gtd`.

### Gmail Integration

Uses the `gmail-gtd` Node.js CLI tool at `integrations/scripts/gmail-gtd/index.js`:

1. **Scan each configured Gmail account**
   - For each note source with `type: gmail` in `integrations/config.md`, run:
   ```bash
   node integrations/scripts/gmail-gtd/index.js scan <account-email>
   ```
   - Parses JSON output containing conversations grouped by subject, with sender, date, message count, UIDs, and link

2. **Present to user**
   - Show found conversations grouped by account
   - Format: `"Subject" from Sender (N messages, Date) — [Link](url)`
   - User selects which conversations to capture as tasks

3. **Process confirmed items**
   - Mint a task ID for each selected conversation
   - Route through standard capture analysis (determine context/project, select provider)
   - Task description includes `[Email](link)` for clickback to the original Gmail thread

4. **Clear label from captured conversations**
   - After tasks are confirmed and created, remove the `gtd` label:
   ```bash
   node integrations/scripts/gmail-gtd/index.js clear <account-email> <uid> [uid...]
   ```
   - Pass all `uids` from each captured conversation

### Example Flow

```
/capture
-> Scanning Obsidian journal...
-> Found 2 incomplete items

-> Scanning Gmail (user@example.com)...
-> Found 2 labeled emails:

  Gmail (user@example.com):
  1. "SDK delivery timeline" from Alice (3 messages, Jan 27)
  2. "Invoice #4521" from billing@vendor.com (1 message, Jan 26)

-> [Select items to capture or press Enter for all]

-> Capturing "Re: SDK delivery timeline"...
   [a9f3q] Follow up on SDK delivery timeline [Email](https://mail.google.com/...)
   → Context: @work-code → trello-software

-> Clearing 'gtd' label from captured emails...
-> Done. 1 email captured, label cleared.
```

### Error Handling

- **No config/App Password:** Skip Gmail source, show warning with setup instructions
- **IMAP connection error:** Skip Gmail source, continue with other capture sources
- **Empty results:** Report "No labeled emails found" and continue

See `integrations/adapters/notes/gmail.md` for full adapter details.

## Smart Processing

The command automatically processes items when they are:
- **Clear single actions** with obvious context
- **Complete information** (no ambiguity about what to do)
- **Actionable immediately** (not research or multi-step projects)

Auto-processed items are simultaneously:
1. Added to the appropriate project's `tasks.md` file in GTD system
2. Created in the matching external provider based on routing rules

## Provider Routing

When capturing, the system routes to the correct provider based on `integrations/config.md`:

### Route Matching Process
1. Parse task to identify context (@work-code, @home-calls, etc.)
2. Identify target GTD project if apparent
3. Find matching provider by route rules:
   - First match by project pattern: `project: cyclops/*`
   - Then match by context pattern: `context: @work-*`
   - Fall back to default provider: `default: true`
4. Load adapter for matched provider type
5. Create task in both GTD and external provider

### Routing Examples

**Work task routes to Trello:**
```
\capture "Fix authentication bug in cyclops"
→ Context: @work-code
→ Routes to: trello-cyclops (matches context: @work-*)
→ Creates: Trello card in Cyclops board + GTD tasks.md
```

**Personal task routes to Asana:**
```
\capture "Schedule dentist appointment"
→ Context: @home-calls
→ Routes to: asana-personal (matches context: @home-*)
→ Creates: Asana task in Personal workspace + GTD tasks.md
```

**Errand stays local:**
```
\capture "Buy milk on way home"
→ Context: @errands
→ Routes to: local-gtd (default fallback)
→ Creates: GTD tasks.md only (no external sync)
```

## Examples

**Auto-processed (goes directly to project + provider):**
```
\capture "Call dentist at 555-1234 to schedule cleaning"
→ Personal health project: @home-calls: Call dentist at 555-1234
→ Routed to: asana-personal

\capture "Email Sarah about Friday meeting agenda"
→ Relevant work project: @work-computer: Email Sarah about Friday meeting
→ Routed to: trello-cyclops (if work context matches)

\capture "Buy milk on way home"
→ General tasks: @errands: Buy milk on way home
→ Routed to: local-gtd (local only)
```

**Sent to inbox (needs clarification):**
```
\capture "Research new project management tools"
→ inbox.md (unclear scope, needs processing)
→ Also created in default provider's inbox if available

\capture "Team meeting went badly"
→ inbox.md (unclear what action to take)

\capture "Fix the website issue"
→ inbox.md (vague, needs more specifics)
```

## AI Analysis

For each captured item, analyzes:
- **Clarity**: Is the action specific and unambiguous?
- **Context**: Can we determine the appropriate @context?
- **Project**: Does this belong to an existing active project?
- **Completeness**: Is all necessary information present?
- **Actionability**: Is it a single physical action?
- **Routing**: Which provider should handle this task?

## Provider Integration

When auto-processing tasks:

### 1. Identify Target Project
From active GTD projects in `projects/active/*/info.md`

### 2. Determine Context
Map to appropriate @context:
- @work-code, @work-errand, @work-calls, @work-computer
- @home-computer, @home-calls
- @sideprojects-code, @sideprojects-errand
- @errands

### 3. Route to Provider
Using `integrations/config.md` routing rules:
- Check project patterns
- Check context patterns
- Use default provider if no match

### 4. Create Task
Using provider's adapter from `integrations/adapters/todo/{{type}}.md`:

**Trello:**
```bash
trello card create --board "{{board}}" --list "{{list}}" --name "{{task}}" --label "{{context}}"
```

**Asana:**
```bash
asana task create --workspace "{{workspace}}" --project "{{project}}" --name "{{task}}" --tags "{{context}}"
```

**Todoist:**
```bash
echo -e "\n" | tod task create --project "{{project}}" --content "{{task}}" --label "{{context}}" --no-section --priority X
```

**Local:**
Add to GTD files only, no external API call

### 5. Handle Inbox Items
If no clear project exists, items go to:
- GTD `inbox.md` with timestamp
- Default provider's inbox (if provider supports inbox)

## Fallback Behavior

When in doubt, items go to inbox with timestamp:
- **GTD**: `- [ ] YYYY-MM-DD HH:MM - [item]` in inbox.md
- **Provider**: Created in default provider's inbox (if available)

**Next step:** Run `/triage inbox` to process inbox items using the GTD clarify workflow (2-minute rule, project creation, routing).

## Implementation Notes

- **Duplicate prevention**: Check if similar task already exists before creating
- **Context mapping**: Use consistent GTD context → provider label/tag mapping
- **Priority assignment**: Default to normal priority, higher for urgent keywords
- **Error handling**: If provider creation fails, still add to GTD system
- **Sync consistency**: Task appears in both GTD and provider immediately

## Configuration Reference

See `integrations/config.md` for:
- Provider instances and their routes
- Adding new providers
- Customizing routing rules

See `integrations/adapters/todo/` for:
- Provider-specific command syntax
- Context-to-label mappings

See `/triage` command for:
- Processing inbox items
- GTD clarify workflow (2-minute rule, project creation)
- Picking work from available tasks
