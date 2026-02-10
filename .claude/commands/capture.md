# /capture

Quickly capture thoughts, ideas, and tasks. Uses AI to auto-process obvious single-step actions and route to the correct provider.

## System Resolution

1. Read `.claude/active-system` for the active system name
2. Load `systems/<active>/config.md` for provider instances and routing
3. Load `systems/<active>/prompts/capture.md` if it exists for system-specific instructions
4. Use `systems/<active>/data/inbox.md` for inbox routing

## Usage
```
\capture [item]
```

## Source Scanning (no arguments)

When run without arguments, scan all configured **note sources** (capture-type providers) from the active system's `config.md`.

For each note source, load its adapter from `integrations/adapters/notes/<type>.md` and follow the adapter's scan procedure.

### Retrieval Delegation

Source scanning is mechanical retrieval work. Delegate it to parallel Haiku sub-agents to reduce cost and latency. The parent agent handles all clarify/route decisions afterward.

**Procedure:**

1. Read `systems/<active>/config.md` to identify all configured note sources
2. For each note source, spawn a Task sub-agent **in parallel** with:
   - `model: "haiku"`
   - `subagent_type:` choose by provider type (see table below)
   - `prompt:` include the adapter doc path, the instance config excerpt (account, auth, folder paths, etc.), and the expected output format

| Provider type | Sub-agent type | Reason |
|--------------|----------------|--------|
| `obsidian-mcp` | `general-purpose` | Needs MCP tools (`list_vault_files`, `get_vault_file`, etc.) |
| `gmail` | `Bash` | Runs `node index.js scan` via shell |

3. Collect all sub-agent results before proceeding to "## Smart Processing"
4. Local file reads (inbox, data files) stay in the parent agent — no sub-agent needed

**Sub-agent prompt pattern:**
```
Read the adapter doc at integrations/adapters/notes/<type>.md and follow its scan procedure.

Provider config:
  <paste instance config excerpt from systems/<active>/config.md>

Return results as structured text: one item per line, with source file/thread and item description.
<any provider-specific instructions from systems/<active>/prompts/capture.md>
```

**What stays in the parent agent:** All clarify/route decisions, ambiguous item presentation (AskUserQuestion), ID minting, provider creation (write operations), and marking captured items in sources (write-back).

### Obsidian Source (sub-agent: general-purpose, haiku)

If a note source of type `obsidian-mcp` is configured:
1. Follow the scan procedure in `integrations/adapters/notes/obsidian.md`
2. Present found incomplete items grouped by date
3. User confirms which to capture

### Gmail Source (sub-agent: Bash, haiku)

If a note source of type `gmail` is configured:
1. Follow the scan procedure in `integrations/adapters/notes/gmail.md`
2. Present found conversations grouped by account
3. User selects which conversations to capture
4. After tasks are confirmed and created, follow the adapter's clear procedure

### Example Flow

```
/capture
-> Scanning note sources...
-> Found 3 incomplete items from Obsidian:

  2026-01-26.md:
  - [ ] Email response to client
  - [ ] Review PR #123

  2026-01-25.md:
  - [ ] Follow up on invoice

-> Found 2 labeled emails from Gmail:
  1. "SDK delivery timeline" from Alice (3 messages, Jan 27)
  2. "Invoice #4521" from billing@vendor.com (1 message, Jan 26)

-> [Select items to capture or press Enter for all]
```

## Smart Processing

The command automatically processes items when they are:
- **Clear single actions** with obvious context
- **Complete information** (no ambiguity about what to do)
- **Actionable immediately** (not research or multi-step projects)

Auto-processed items are simultaneously:
1. Added to the appropriate data file in the active system
2. Created in the matching external provider using its adapter

## Provider Routing

When capturing, the system routes to the correct provider based on the active system's `config.md`:

### Route Matching Process
1. Parse task to identify context (@work-code, @home-calls, etc.)
2. Identify target GTD project if apparent
3. Find matching provider by route rules:
   - First match by project pattern: `project: cyclops/*`
   - Then match by context pattern: `context: @work-*`
   - Fall back to default provider: `default: true`
4. Load adapter from `integrations/adapters/todo/<type>.md`
5. Create task in both system data and external provider

### Routing Examples

**Work task routes to Trello:**
```
\capture "Fix authentication bug in cyclops"
→ Context: @work-code
→ Routes to: trello-cyclops (matches context: @work-*)
→ Uses adapter: integrations/adapters/todo/trello.md
```

**Personal task routes to Asana:**
```
\capture "Schedule dentist appointment"
→ Context: @home-calls
→ Routes to: asana-personal (matches context: @home-*)
→ Uses adapter: integrations/adapters/todo/asana.md
```

**Errand stays local:**
```
\capture "Buy milk on way home"
→ Context: @errands
→ Routes to: local-gtd (default fallback)
→ Uses adapter: integrations/adapters/todo/local.md
```

## Ambiguous Item Routing

When an item is ambiguous (unclear category, uncertain priority, multiple valid destinations), use the `AskUserQuestion` tool to present routing options interactively. For example:

```
Question: "How should we route this item?"
Options:
  - "Someday/Maybe" — Park it for future consideration
  - "Next Action (@context)" — It's actionable now
  - "@agenda-person" — Discussion point for someone
  - "Skip" — Just a note, don't capture
```

This applies to both individual captures and items found during source scanning. Clear-cut items are still auto-routed silently.

## AI Analysis

For each captured item, analyze:
- **Clarity**: Is the action specific and unambiguous?
- **Context**: Can we determine the appropriate @context?
- **Project**: Does this belong to an existing active project?
- **Completeness**: Is all necessary information present?
- **Actionability**: Is it a single physical action?
- **Routing**: Which provider should handle this task?

## Task Creation

### 1. Mint a Task ID

Use `/mint-id` to generate one, then include it in the task name: `[abc12] Task description`

### 2. Determine Context

Map to appropriate @context based on the task content.

### 3. Route to Provider

Using the active system's `config.md` routing rules, find the matching provider instance.

### 4. Create via Adapter

Load the matched adapter from `integrations/adapters/todo/<type>.md` and follow its create procedure with the instance-specific config from the system's `config.md`.

### 5. Handle Inbox Items

If no clear project exists, items go to:
- `systems/<active>/data/inbox.md` with timestamp
- Default provider's inbox (if provider supports inbox)

## Fallback Behavior

When in doubt, items go to inbox with timestamp:
- **System data**: `- [ ] YYYY-MM-DD HH:MM - [item]` in `systems/<active>/data/inbox.md`
- **Provider**: Created in default provider's inbox (if available)

**Next step:** Inbox items are processed automatically by the next `/plan-day` or `/plan-week` run.

## Implementation Notes

- **Duplicate prevention**: Check if similar task already exists before creating
- **Context mapping**: Use consistent GTD context → provider label/tag mapping
- **Priority assignment**: Default to normal priority, higher for urgent keywords
- **Error handling**: If provider creation fails, still add to system data
- **Sync consistency**: Task appears in both system data and provider immediately

## Configuration Reference

See `integrations/config.md` for schema documentation.
See `integrations/adapters/todo/` for provider-specific adapter docs.
See `integrations/adapters/notes/` for capture source adapter docs.
