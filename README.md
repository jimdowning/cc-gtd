# GTD System - Getting Things Done with Claude Code

A comprehensive Getting Things Done (GTD) implementation with claude code powered task processing and daily planning features.

## Overview

This system implements David Allen's GTD methodology with modern AI enhancements for:
- Smart task capture and processing
- Automated project organization
- Daily planning and work logging
- Integration with external tools (Todoist, Calendar)

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
- External tool synchronization

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
└── reference/                  # Non-actionable materials
```

## Commands

- `\capture [item]` - Smart capture with auto-processing
- `\daily` - Plan for the day
- `\todoist` - Sync with Todoist
- `\calendar` - Sync with Calendar
- `\weekly` - Conduct weekly review

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

## Project Management

Each active project contains:
- **info.md**: Goals, desired outcomes, progress tracking, history
- **tasks.md**: Next actions organized by context

Projects move to `archived/` upon completion with proper status documentation.

## Daily Planning

Daily files (`daily/YYYY-MM-DD.md`) include:
- **Daily Plan**: Priorities, time blocks, energy mapping
- **Work Log**: Timestamped activities with durations
- **Reflection**: What worked, improvements, next day focus

## Setup & Installation

### Prerequisites

1. **Claude Code** - The AI assistant that powers this system
2. **Just** - Command runner for project automation
   - Install: `cargo install just`
   - Documentation: [https://github.com/casey/just](https://github.com/casey/just)
3. **Tod** - For syncing with Todoist
   - Install: `cargo install tod`
   - Documentation: [https://github.com/alanvardy/tod](https://github.com/alanvardy/tod)
4. **icalBuddy** - For calendar integration
   - macOS: `brew install ical-buddy`
   - Documentation: [https://github.com/ali-rantakari/icalBuddy](https://github.com/ali-rantakari/icalBuddy)

### Installation Steps

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd gtd
   ```

2. Run the setup command:
   ```bash
   just setup
   ```

3. Configure Tod (if using):
   ```bash
   tod configure
   ```

4. Set up Claude Code with the CLAUDE.md instructions (\init)

5. Start capturing tasks with `\capture`!

### Additional Commands

The `justfile` includes helpful commands:
- `just setup` - Creates directory structure and initializes files
- `just add-project` - Creates a new project with info.md and tasks.md
- `just add-task` - Adds a task to Todoist with project and context

## Smart Processing Logic

The AI assistant intelligently processes captures:
- **Auto-processes**: Clear, single actions with obvious context
- **Sends to inbox**: Vague items, multi-step projects, unclear scope

During processing, it skips obvious steps:
- Already defined items skip "What is it?"
- Action verbs skip "Is it actionable?"
- Specific actions skip "Next action?"
- Complex tasks skip "<2 minutes?"

## Best Practices

1. **Capture everything** - Use the inbox liberally
2. **Process regularly** - Keep inbox at zero
3. **Review weekly** - Maintain system integrity
4. **One task, one place** - No duplication across files
5. **Update progress** - Keep project info current

## Energy Management

The system supports energy-based planning:
- Track energy levels in daily planning
- Map tasks to appropriate energy states
- Review energy patterns in weekly reviews

## Integration

Designed to work with:
- Todoist for mobile capture
- Calendar apps for time-specific items
- AI assistants for processing automation

## License

This GTD system structure is open source and available for anyone to use and adapt for their personal productivity needs.

## Credits

Based on David Allen's Getting Things Done methodology with AI enhancements for modern workflows.