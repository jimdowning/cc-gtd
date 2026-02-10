# Command Extension Hooks

Extension hooks allow system prompt overlays to inject additional steps into command workflows at defined points.

## How It Works

1. Base commands (`.claude/commands/<command>.md`) define **hook points** — named moments in the workflow
2. System prompt overlays (`systems/<active>/prompts/<command>.md`) declare what runs at each hook
3. At runtime, when the agent reaches a hook point, it checks the loaded overlay for a matching `### Hook: <name>` section under `## Extensions`
4. If a matching hook is found, execute it. If not, continue silently.

Commands without overlays, or overlays without extensions, are unaffected.

## Available Hooks

### /review-day

| Hook | Position | Good for |
|------|----------|----------|
| `before` | Before step 1 (reading today's plan) | Context gathering, activity summaries |
| `after-present` | After step 3 (plan vs reality), before conversation | Additional review data |
| `after` | After step 5 (writing daily review) | Journaling, logging |

### /plan-day

| Hook | Position | Good for |
|------|----------|----------|
| `before` | Before step 1 (note current time) | Context gathering |
| `after-orient` | After step 5 (present the situation), before decide | Coaching, suggestions |
| `after` | After step 8 (save the plan) | Logging, notifications |

## Extension Format

Declare extensions in the system prompt overlay under `## Extensions`:

```markdown
## Extensions

### Hook: before
- **type**: skill
- **skill**: today-in-claude-code
- **description**: Show Claude Code activity summary for context

### Hook: after-orient
- **type**: coaching
- **source**: ~/.claude/usage-data/report.html
- **sections**: friction, features, patterns
- **instructions**: |
    Read the source report. Based on the day's planned work...
```

## Extension Types

### skill
Invoke a named skill (slash command). The agent runs the skill and includes its output as context for the current workflow step.

- **skill** (required): The skill name, e.g., `today-in-claude-code`
- **description**: What the skill provides in this context

### inline
Instructions executed directly by the parent agent. Use for simple operations that don't need a separate skill.

- **instructions** (required): Markdown instructions for the agent to follow
- **description**: What this extension does

### coaching
A specific pattern: read a source document, match relevant sections to the current context, and present targeted suggestions.

- **source** (required): Path to the source document
- **sections**: Which sections of the source to scan
- **instructions** (required): How to match source content to today's context and what format to present

## Adding Hooks to New Commands

To make a command extensible:

1. Identify natural breakpoints in the workflow where extensions could add value
2. Insert `**Extension hook: \`<name>\`**` markers at those points with a brief description
3. Add an `## Extension Hooks` section listing available hooks and referencing this document
4. Hooks should be at meaningful workflow boundaries (before/after phases), not mid-step
