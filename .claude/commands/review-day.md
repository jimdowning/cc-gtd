# /review-day

End-of-day reflection: gather completion signals, compare plan vs. reality, note what to carry forward.

## Usage
```
/review-day
```

Explicitly optional — tomorrow's `/plan-day` detects carryover regardless of whether this runs.

## Process

### 1. Read Today's Plan

Read today's journal note from Obsidian (`Journal/YYYY-MM-DD.md` via `get_vault_file`).

If no plan exists, skip to a lightweight "what did you do today?" conversation.

### 2. Gather Completion Signals

**From the plan itself:**
- Parse checked `- [x]` vs unchecked `- [ ]` items in the Daily Plan section

**From providers (if cache is fresh):**
- Trello: cards moved to Done, In Testing, Code Complete, or other progress lists today
- Any other provider completions visible in cached data

### 3. Present Plan vs. Reality

```
## Today's Results

Completed:
- [x] [5e1lv] Book 1-1 Will
- [x] [8yhe5] Fix EZ-Sag Bitrise

Not completed:
- [ ] [l4alt] Atto iOS testing
- [ ] [qfo2w] Review ADRs

Not in plan but done:
- [r3k9m] Responded to SDK delivery email (from Trello movement)
```

### 4. Brief Conversation

Ask:
1. "Anything notable about today that isn't captured above?"
2. "The incomplete items — carry forward, or drop?"

Keep this short. This is a quick close-out, not a planning session.

### 5. Write Daily Review

Append the `# Daily Review` section to today's journal note via `patch_vault_file` on `Journal/YYYY-MM-DD.md`:

```markdown
# Daily Review

## Completed
- [x] [5e1lv] Book 1-1 Will
- [x] [8yhe5] Fix EZ-Sag Bitrise
- [x] [r3k9m] SDK delivery email response (unplanned)

## Incomplete → Carry Forward
- [ ] [l4alt] Atto iOS testing
- [ ] [qfo2w] Review ADRs

## Notes
<!-- User's reflections from the conversation -->
```

## Related Commands

- `/plan-day` — tomorrow's morning planning (reads this review's carryover)
- `/today` — view current plan
- `/replan` — mid-day adjustment (use instead if there's still work time left)
