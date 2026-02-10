# /today

Display today's daily plan in the console for quick reference.

## System Resolution

1. Read `.claude/active-system` for the active system name
2. Load `systems/<active>/prompts/today.md` if it exists for system-specific instructions

## Usage
```
/today
```

## Process

### 1. Determine Today's Date
Compute today's date in `YYYY-MM-DD` format.

### 2. Read Today's Journal Note
Read today's journal from the active system's journal provider.

If the file does not exist, report that no daily plan has been created yet and suggest running `/plan-day` to create one.

### 3. Display the Plan
Output the `# Daily Plan` section to the console as-is, preserving all markdown formatting, task identifiers, and checkbox states.

Do not modify, summarize, or reformat the content. Just echo it verbatim.
