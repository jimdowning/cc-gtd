# /today

Display today's daily plan in the console for quick reference.

## Usage
```
/today
```

## Process

### 1. Determine Today's Date
Compute today's date in `YYYY-MM-DD` format.

### 2. Read Today's Daily Log
Read the file `daily/<YYYY-MM-DD>.md`.

If the file does not exist, report that no daily plan has been created yet and suggest running `/daily` to create one.

### 3. Display the Plan
Output the full contents of the daily log file to the console as-is, preserving all markdown formatting, task identifiers, and checkbox states.

Do not modify, summarize, or reformat the content. Just echo it verbatim.
