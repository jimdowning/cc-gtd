# /system

Manage the active GTD system. Each system is an independent repo cloned into `systems/<name>/` representing a distinct work context.

## Usage
```
/system              — show active system and its summary
/system <name>       — switch active system
/system list         — list available systems
```

## Process

### Show Active System (`/system`)

1. Read `.claude/active-system` for the current system name
2. If no active system is set:
   - Scan `systems/*/system.md` for available systems
   - If exactly one exists, auto-select it and save to `.claude/active-system`
   - If multiple exist, list them and ask the user to choose
   - If none exist, report that no systems are mounted and point to `systems/README.md`
3. Read `systems/<active>/system.md` and display:
   - System name and description
   - Configured providers (from `systems/<active>/config.md`)
   - Data file status (inbox empty? how many items in lists?)

### Switch System (`/system <name>`)

1. Verify `systems/<name>/system.md` exists
2. If not found, report error and list available systems
3. Write `<name>` to `.claude/active-system`
4. Confirm: "Switched to system: <name>"
5. Show brief summary of the system

### List Systems (`/system list`)

1. Scan `systems/*/system.md`
2. For each found system, read name and description from `system.md`
3. Mark the active system (from `.claude/active-system`) with an indicator
4. Display as a table:

```
Available Systems:
  * work       — Cyclops Marine work context (active)
    personal   — Personal life admin and projects
```

## Auto-Selection

When any command needs the active system and none is set:
- If exactly one system exists in `systems/`, auto-select it
- If multiple exist, prompt the user to choose
- If none exist, report error with setup instructions

## Related Commands

All other commands operate on the active system. The system determines:
- Which provider config to load (`systems/<active>/config.md`)
- Where data files live (`systems/<active>/data/`)
- Which per-command prompts to load (`systems/<active>/prompts/`)
- Where cache files go (`systems/<active>/cache/`)
