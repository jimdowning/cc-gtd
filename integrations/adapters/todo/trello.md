# Trello Adapter

Adapter for syncing GTD tasks with Trello boards using the `trello-cli` tool.

## Role
- **source_type**: managed
- **capture_signal**: —
- **completion_signal**: Card moved to Done list or archived
- **id_strategy**: external
- **primary_storage**: external

## Prerequisites

Install trello-cli:
```bash
npm install -g trello-cli
# or
brew install trello-cli
```

Configure authentication:
```bash
trello set-auth
```

## GTD to Trello Mapping

| GTD Concept | Trello Concept |
|-------------|----------------|
| Project | Board or List |
| Task | Card |
| Context (@label) | Label |
| Due date | Due date |
| Notes | Card description |

## Instance Configuration

The adapter receives these parameters from the provider instance config:
- `board`: Trello board name
- `list`: Default list for new cards (optional, defaults to first list)
- `auth`: Authentication profile (default or custom)
- `list_mapping`: Optional GTD list mapping for boards organized as GTD systems

## GTD List Mapping

For Trello boards organized as GTD systems, configure list mappings:

```yaml
list_mapping:
  Today: "Today"           # Immediate next actions for today
  This Week: "This Week"   # Actions committed for this week
  Waiting For: "Waiting For"  # Delegated/waiting items
  Committed: "Committed"   # Will do but not soon
  Someday/Maybe: "Someday / Maybe"  # Future possibilities
```

When syncing:
- **Today** list → urgent next actions
- **This Week** list → committed actions for the week
- **Waiting For** list → delegated items tracking
- **Committed** list → actions committed but not scheduled
- **Someday/Maybe** list → future possibilities, no commitment

## Commands

### List Tasks
```bash
# List all cards in a board
trello card list --board "{{board}}"

# List cards in a specific list
trello card list --board "{{board}}" --list "{{list}}"

# Get card details
trello card show --board "{{board}}" --card "{{card_id}}"
```

### Create Task
```bash
# Create a new card
trello card create --board "{{board}}" --list "{{list}}" --name "{{task_content}}"

# Create with due date
trello card create --board "{{board}}" --list "{{list}}" --name "{{task_content}}" --due "{{due_date}}"

# Create with label
trello card create --board "{{board}}" --list "{{list}}" --name "{{task_content}}" --label "{{context}}"
```

### Update Task
```bash
# Move card to different list
trello card move --board "{{board}}" --card "{{card_id}}" --list "{{new_list}}"

# Add label to card
trello card add-label --board "{{board}}" --card "{{card_id}}" --label "{{label}}"

# Update due date
trello card set-due --board "{{board}}" --card "{{card_id}}" --due "{{due_date}}"
```

### Complete Task
```bash
# Archive card (mark as done)
trello card archive --board "{{board}}" --card "{{card_id}}"

# Move to "Done" list (alternative)
trello card move --board "{{board}}" --card "{{card_id}}" --list "Done"
```

## Context to Label Mapping

When creating cards, map GTD contexts to Trello labels:

| GTD Context | Trello Label |
|-------------|--------------|
| @work-code | Code |
| @work-errand | Errand |
| @work-calls | Calls |
| @work-computer | Computer |

Create labels on the board if they don't exist:
```bash
trello board add-label --board "{{board}}" --name "{{label_name}}" --color "{{color}}"
```

## Sync Process

### GTD to Trello
1. Read tasks from project's `tasks.md`
2. For each uncompleted task:
   - Check if card exists in Trello (by name match)
   - If not, create card with appropriate list and labels
   - If exists, update if GTD version is newer

### Trello to GTD
1. List all cards in board
2. For each card:
   - Check if task exists in GTD (by name match)
   - If not, add to appropriate context section in `tasks.md`
   - If card is archived, mark as completed in GTD

## Error Handling

- If board doesn't exist: Report error, skip this provider
- If list doesn't exist: Use first list on board
- If label doesn't exist: Create it or skip labeling
- If network error: Retry once, then report and continue

## Example Sync Session

```bash
# Get all cards from Cyclops board
trello card list --board "Cyclops"

# Create task from GTD
trello card create --board "Cyclops" --list "To Do" --name "Fix authentication bug" --label "Code"

# Mark task complete
trello card archive --board "Cyclops" --card "abc123"
```
