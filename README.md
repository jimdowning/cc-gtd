# GTD System - Getting Things Done with Claude Code

A comprehensive Getting Things Done (GTD) implementation with Claude Code powered task processing, daily planning, and multi-provider integration.

## Overview

This system implements David Allen's GTD methodology with modern AI enhancements for:
- Smart task capture and processing
- Automated project organization
- Daily planning and work logging
- **Multi-provider integration** (Trello, Asana, Todoist, Google Calendar, and more)

## Features

### Core GTD Implementation
- **Inbox** for quick capture with timestamps
- **Projects** with dedicated tracking and task management
- **Contexts** for organizing next actions by location/tool
- **Waiting For** list for delegated items
- **Someday/Maybe** for future possibilities
- **Reference** materials organization

### AI Enhancements
- Smart capture that auto-processes obvious actions
- Intelligent processing that skips unnecessary GTD steps
- Daily planning assistance
- **Context-aware provider routing**

### Multi-Provider Support
Route tasks and calendars to different services based on context:
- **Work tasks** → Trello (or your work tool)
- **Personal/family tasks** → Asana (or your personal tool)
- **Side projects** → Todoist
- **Local-only tasks** → GTD markdown files (no external sync)
- **Work calendar** → Google Calendar (work account)
- **Personal calendar** → Google Calendar (personal account)

## File Structure

```
gtd/
├── inbox.md                    # Raw capture with timestamps
├── projects.md                 # Project dashboard (read-only overview)
├── waiting-for.md              # Delegated/expected items
├── someday-maybe.md            # Future possibilities
├── calendar.md                 # Time-specific items
├── projects/active/            # Active projects
│   └── [project-name]/
│       ├── info.md             # Project goals, outcomes, progress
│       └── tasks.md            # Context-organized next actions
├── projects/archived/          # Completed projects
├── reviews/weekly-review.md    # Review templates
├── daily/YYYY-MM-DD.md         # Daily planning and work logs
├── integrations/               # Provider configuration
│   ├── config.md               # Provider instances + routing rules
│   └── adapters/               # Provider-specific adapters
│       ├── todo/
│       │   ├── trello.md
│       │   ├── asana.md
│       │   ├── todoist.md
│       │   └── local.md
│       └── calendar/
│           ├── gcal.md
│           └── icalbuddy.md
└── reference/                  # Non-actionable materials
```

## Commands

- `\capture [item]` - Smart capture with auto-processing and provider routing
- `\triage [inbox|pick]` - Process inbox items and pick work (GTD clarify/engage)
- `\daily` - Plan for the day (aggregates all calendar providers)
- `\sync [provider]` - Sync with all or specific todo providers
- `\calendar [range]` - Show unified calendar from all providers
- `\weekly` - Conduct weekly review (syncs all providers)

## Multi-Provider Configuration

### Quick Start

1. Edit `integrations/config.md` to configure your providers
2. Set up authentication for each provider (see adapter docs)
3. Define routing rules based on your workflow

### Example Configuration

```markdown
## Todo Providers

### trello-cyclops
- type: trello
- board: Cyclops
- routes:
  - project: cyclops/*
  - context: @work-*

### asana-personal
- type: asana
- workspace: Personal
- routes:
  - context: @home-*

### local-gtd
- type: local
- routes:
  - default: true
```

### Routing Logic

When capturing or syncing tasks:
1. Identify task context (@work-code, @home-calls, etc.)
2. Match against provider routes in priority order
3. Route to first matching provider
4. Fall back to default provider (local-gtd)

### Provider Types

| Type | Tool | Use Case |
|------|------|----------|
| trello | trello-cli | Work boards, team projects |
| asana | asana-cli/API | Personal task management |
| todoist | tod CLI | Mobile capture, side projects |
| local | GTD files only | Offline, quick captures, someday/maybe |
| gcal | gcalcli | Google Calendar integration |
| icalbuddy | icalBuddy | macOS Calendar.app |

## Context System

Organize tasks by context for efficient execution:
- `@work-code` - Coding tasks (work)
- `@work-errand` - Work-related errands
- `@home-computer` - Personal computer tasks
- `@home-calls` - Personal phone calls
- `@sideprojects-code` - Side project coding
- `@sideprojects-errand` - Side project errands
- `@mobile-anywhere` - Mobile tasks
- `@errands` - Out-of-home tasks
- `@agenda-[person]` - Person-specific items

Contexts determine provider routing via `integrations/config.md`.

## Project Management

Each active project contains:
- **info.md**: Goals, desired outcomes, progress tracking, history
- **tasks.md**: Next actions organized by context

Projects move to `archived/` upon completion with proper status documentation.

## Daily Planning

Daily files (`daily/YYYY-MM-DD.md`) include:
- **Calendar**: Unified view from all calendar providers with labels
- **Daily Plan**: Priorities, time blocks, energy mapping
- **Work Log**: Timestamped activities with durations
- **Reflection**: What worked, improvements, next day focus

## Setup & Installation

### Prerequisites

1. **Claude Code** - The AI assistant that powers this system
2. **Provider CLIs** (install only what you need):
   - **Tod** (Todoist): `cargo install tod`
   - **trello-cli**: `npm install -g trello-cli`
   - **gcalcli**: `pip install gcalcli`
   - **icalBuddy** (macOS): `brew install ical-buddy`

### Installation Steps

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd gtd
   ```

2. Create the directory structure:
   ```bash
   mkdir -p daily weekly projects/active projects/archived
   touch inbox.md projects.md waiting-for.md someday-maybe.md
   ```

3. Configure providers in `integrations/config.md`

4. Set up authentication for each provider you use:
   ```bash
   # Todoist
   tod configure
   tod project import

   # Trello
   trello set-auth

   # Google Calendar
   gcalcli list  # triggers OAuth

   # Asana (set env var or config file)
   export ASANA_ACCESS_TOKEN="your-token"
   ```

5. Start capturing tasks with `/capture`!

## Adding a New Provider

1. Add provider instance to `integrations/config.md`:
   ```markdown
   ### todoist-newclient
   - type: todoist
   - routes:
     - project: newclient/*
     - context: @work-newclient
   ```

2. Set up authentication for the provider

3. Tasks matching the routes will automatically sync

## Smart Processing Logic

The AI assistant intelligently processes captures:
- **Auto-processes**: Clear, single actions with obvious context
- **Routes to provider**: Based on context and routing rules
- **Sends to inbox**: Vague items, multi-step projects, unclear scope

## Triage Workflow

The `/triage` command implements GTD's "Clarify" and "Engage" steps on-demand:

### Processing Inbox (`/triage inbox`)

For each inbox item, applies the GTD decision tree:
1. **Is it actionable?** → No: Trash, Reference, or Someday-Maybe
2. **What's the next action?** → Clarify the specific physical step
3. **Less than 2 minutes?** → Yes: Do it now
4. **Multi-step project?** → Yes: Create project, add first action
5. **Route the action** → Assign context, route to provider

### Picking Work (`/triage pick`)

Interactive selection of what to work on now:
- Gathers tasks from all active projects and providers
- Groups by context for efficient batch processing
- User selects 1-5 items for current focus

### Workflow Position

```
Capture → /triage → Organized Tasks → /daily → Work
              ↑
         Run anytime (not just weekly review)
```

This allows inbox processing between weekly reviews, keeping the system trustworthy.

## Best Practices

1. **Capture everything** - Use the inbox liberally
2. **Process regularly** - Keep inbox at zero
3. **Review weekly** - Maintain system integrity across all providers
4. **One task, one place** - No duplication across files
5. **Update progress** - Keep project info current
6. **Configure routing** - Match your workflow to provider strengths

## Energy Management

The system supports energy-based planning:
- Track energy levels in daily planning
- Map tasks to appropriate energy states
- Review energy patterns in weekly reviews

## Integration Architecture

```
┌─────────────┐     ┌─────────────────┐     ┌────────────────┐
│   Capture   │────▶│  Route Matcher  │────▶│    Provider    │
│  /capture   │     │ (config.md)     │     │    Adapter     │
└─────────────┘     └─────────────────┘     └────────────────┘
       │                   │                        │
       ▼                   ▼                        ▼
┌─────────────┐     ┌─────────────┐          ┌────────────┐
│   Inbox     │────▶│  GTD Files  │          │  External  │
│  (unclear)  │     │  (local)    │          │   Service  │
└─────────────┘     └─────────────┘          └────────────┘
       │                   ▲
       ▼                   │
┌─────────────┐            │
│   Triage    │────────────┘
│  /triage    │  (clarify, route, or trash)
└─────────────┘
```

## License

This GTD system structure is open source and available for anyone to use and adapt for their personal productivity needs.

## Credits

Based on David Allen's Getting Things Done methodology with AI enhancements for modern workflows and multi-provider integration.
