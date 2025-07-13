# Capture

Quickly capture thoughts, ideas, and tasks. Uses AI to auto-process obvious single-step actions.

## Usage
```
\capture [item]
```

## Smart Processing
The command automatically processes items when they are:
- **Clear single actions** with obvious context
- **Complete information** (no ambiguity about what to do)
- **Actionable immediately** (not research or multi-step projects)

Auto-processed items are simultaneously:
1. Added to the appropriate project's `tasks.md` file in GTD system
2. Created in the corresponding Todoist project using `tod task create` with proper context labels

## Examples

**Auto-processed (goes directly to project tasks):**
```
\capture "Call dentist at 555-1234 to schedule cleaning"
→ Personal health project: @home-calls: Call dentist at 555-1234 to schedule cleaning

\capture "Email Sarah about Friday meeting agenda"  
→ Relevant work project: @work-computer: Email Sarah about Friday meeting agenda

\capture "Buy milk on way home"
→ General tasks: @errands: Buy milk on way home
```

**Sent to inbox (needs clarification):**
```
\capture "Research new project management tools"
→ inbox.md (unclear scope, needs processing)

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

Tasks are added to the appropriate project's `tasks.md` file under the correct context section and simultaneously created in the corresponding Todoist project using `tod task create` with proper context labels.

## Todoist Integration
When auto-processing tasks, the system:
1. **Identifies the target project** from active GTD projects
2. **Maps GTD context to Todoist label** (@work-code, @work-errand, @home-computer, etc.)
3. **Creates the task** using: `echo -e "\n" | tod task create --project "[Project Name]" --content "[Task]" --label "@context" --no-section --priority X`
4. **Handles inbox items** by creating them in Todoist "Inbox" project for later processing

If no clear project exists, items go to both GTD inbox.md and Todoist Inbox for processing.

## Fallback Behavior
When in doubt, items go to inbox.md with timestamp and Todoist Inbox:
- **GTD**: `- [ ] YYYY-MM-DD HH:MM - [item]` in inbox.md
- **Todoist**: Created in "Inbox" project using `tod task create --project "Inbox" --content "[item]" --no-section`

## Implementation Notes
- **Duplicate prevention**: Check if similar task already exists before creating
- **Context mapping**: Use consistent GTD context → Todoist label mapping
- **Priority assignment**: Default to priority 3, higher for urgent keywords
- **Error handling**: If Todoist creation fails, still add to GTD system
- **Sync consistency**: Maintain bidirectional sync between GTD and Todoist