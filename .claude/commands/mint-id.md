# /mint-id

Generate unique 5-character alphanumeric identifiers for tasks and items.

## Usage
```
/mint-id [count]
```

- Without arguments: generates 1 identifier
- With count: generates that many identifiers

## Generation Method

Use this bash command to generate identifiers:
```bash
LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 5
```

For multiple identifiers:
```bash
for i in {1..N}; do LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 5; echo; done
```

## Identifier Format

- **Length**: 5 characters
- **Character set**: lowercase alphanumeric (a-z, 0-9)
- **Examples**: `x7k2m`, `a9f3q`, `p4w8n`

## When to Mint Identifiers

Mint new identifiers when:
- Collecting tasks from external providers (Trello, Asana, etc.)
- Creating new tasks via /capture
- Presenting task lists to the user
- Saving tasks to GTD files or memory

## Identifier Storage

When saving tasks, include the identifier:
```markdown
- [ ] [x7k2m] Task description here
```

## Cross-Reference Mapping

When collecting from external providers, maintain a mapping:
```
x7k2m -> trello:679ba2c1d8a2c8071deb9ec1
a9f3q -> trello:685c91d31f14181cf4959291
```

This allows quick lookup and sync between local IDs and provider IDs.

## Example Output

```
> /mint-id
x7k2m

> /mint-id 3
a9f3q
p4w8n
k2j7t
```
