# Migration from Todoist CLI to Tod

## Overview
This document outlines the migration from `todoist` CLI to `tod` CLI for GTD system integration. Tod is described as "a tiny unofficial Todoist client" and appears to have a more streamlined, focused command set.

## Command Mapping

### Viewing Tasks

| Todoist CLI | Tod CLI | Notes |
|-------------|---------|-------|
| `todoist list` | `tod list view` | Basic task listing |
| `todoist list --filter "today \| overdue"` | `tod list view --filter "today,overdue"` | Multiple filters use commas |
| `todoist list --filter "#Inbox"` | `tod list view --project "Inbox"` | Project filtering |
| `todoist list --filter "p1 \| p2"` | `tod list view --filter "p1,p2"` | Priority filtering |
| `todoist list --filter "#Taktile"` | `tod list view --project "Taktile"` | Project-specific tasks |
| `todoist list --filter "7 days"` | `tod list view --filter "7 days"` | Week view |
| `todoist list --filter "no date"` | `tod list view --filter "no date"` | Undated tasks |

### Adding Tasks

| Todoist CLI | Tod CLI | Notes |
|-------------|---------|-------|
| `todoist quick "..."` | `tod task quick-add --content "..."` | Natural language processing |
| `todoist add --project-name "..." --label-names "..." "..."` | `tod task create --project "..." --label "..." --content "..."` | Structured task creation |
| `todoist add --date "..." --priority X "..."` | `tod task create --due "..." --priority X --content "..."` | Date and priority support |

### Managing Tasks

| Todoist CLI | Tod CLI | Notes |
|-------------|---------|-------|
| `todoist close [task_id]` | `tod task complete` | Tod works with "next" task concept |
| `todoist modify [task_id] ...` | `tod task edit` | Task editing |
| `todoist delete [task_id]` | No direct equivalent | Tod doesn't seem to have delete |
| `todoist show [task_id]` | No direct equivalent | Tod doesn't show individual tasks |

### Project Management

| Todoist CLI | Tod CLI | Notes |
|-------------|---------|-------|
| `todoist projects` | `tod project list` | List projects |
| `todoist add-project "..."` | `tod project create` | Create new project |
| No equivalent | `tod project import` | Import projects from Todoist to config |

### Other Commands

| Todoist CLI | Tod CLI | Notes |
|-------------|---------|-------|
| `todoist labels` | No direct equivalent | Tod uses labels differently |
| `todoist sync` | No equivalent needed | Tod syncs automatically |

## Key Differences

### 1. Task Selection Philosophy
- **Todoist CLI**: Works with task IDs for specific operations
- **Tod**: Uses "next task" concept - fetches next priority task and operates on it

### 2. Configuration
- **Todoist CLI**: Uses API token directly
- **Tod**: Has configuration file system and OAuth authentication

### 3. Project Management
- **Todoist CLI**: Works directly with all Todoist projects
- **Tod**: Maintains local config of projects to work with (`tod project import`)

### 4. Filtering
- **Todoist CLI**: Uses `|` for OR operations in filters
- **Tod**: Uses commas for multiple filters

### 5. Natural Language
- **Todoist CLI**: `todoist quick` for NLP
- **Tod**: `tod task quick-add` for NLP, plus reminder support with `!` prefix

### 6. TTY Requirements
- **Tod CLI Issue**: `tod task create` requires interactive TTY for prompts
- **Workaround**: Use `echo -e "\n" | tod task create --no-section --priority X` to avoid prompts
- **Alternative**: Use `tod task quick-add` but with less precise control over parameters

## Tod-Specific Features

### Workflow Commands
- `tod list process` - Complete tasks one by one in priority order
- `tod list prioritize` - Batch prioritize tasks
- `tod list timebox` - Assign time blocks to tasks
- `tod list label` - Batch apply labels
- `tod list schedule` - Batch assign dates
- `tod list deadline` - Batch assign deadlines
- `tod list import` - Import tasks from text file

### Task Operations
- `tod task next` - Get next priority task
- `tod task complete` - Complete the last fetched task
- `tod task comment` - Add comment to last fetched task

## Migration Strategy for GTD Command

### Required Changes

1. **Authentication Setup**
   - Need to set up tod OAuth authentication
   - Configure projects in tod config

2. **Command Replacements**
   - Replace `todoist list` with `tod list view`
   - Replace `todoist quick` with `tod task quick-add`
   - Replace `todoist add` with `tod task create`
   - Replace project filtering syntax

3. **Workflow Adaptations**
   - Use `tod list view --project "Inbox"` for inbox processing
   - Use `tod list view --filter` for date/priority filtering
   - Adapt task completion to tod's "next task" model

### Benefits of Migration

1. **Better Workflow Support**: Tod has built-in batch operations for GTD processing
2. **Cleaner Interface**: More focused command set
3. **Configuration Management**: Better project organization
4. **Batch Operations**: `tod list process` could streamline GTD processing

### Challenges

1. **Task ID Management**: Tod doesn't work with explicit task IDs
2. **Limited Individual Task Operations**: Can't easily show/modify specific tasks
3. **Project Setup**: Need to import and configure projects first
4. **TTY Requirements**: `tod task create` needs interactive prompts, requires workaround in non-TTY environments

## Recommended Implementation Approach

1. **Phase 1**: Set up tod authentication and import projects
2. **Phase 2**: Migrate basic list/view operations
3. **Phase 3**: Adapt task creation and management
4. **Phase 4**: Leverage tod's batch processing features for GTD workflows

## Example Commands for GTD Integration

### Setup
```bash
# Import projects from Todoist to tod config
tod project import

# List configured projects
tod project list
```

### Daily Processing
```bash
# View inbox items
tod list view --project "Inbox"

# View today's tasks
tod list view --filter "today"

# Process inbox tasks one by one
tod list process --project "Inbox"
```

### Task Management
```bash
# IMPORTANT: tod task create requires TTY workaround in non-interactive environments
# Use echo pipe with all required parameters to avoid interactive prompts

# Add structured task (TTY workaround)
echo -e "\n" | tod task create --project "Taktile" --content "Fix bug OPTI-1234" --priority 3 --label "@work-code" --no-section

# Alternative: Quick add (less control, uses NLP)
tod task quick-add --content "Research Spain visa requirements #Inbox @home-computer"

# Get next priority task
tod task next

# Complete the current task
tod task complete
```

### Batch Operations
```bash
# Prioritize all tasks in a project
tod list prioritize --project "Taktile"

# Schedule tasks
tod list schedule --project "Projects"

# Apply labels in batch
tod list label --project "Inbox" --label "@work-code" --label "@home-computer"
```