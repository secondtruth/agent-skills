# Digest Templates

The file templates for `consolidate-space`. Placeholders in braces; omit a section when it would be empty.

## STATUS.md

```markdown
---
updated: {YYYY-MM-DD}
---

# Status — {Space Name}

## Recently Worked On

{Chronological or thematic list of the last substantive work threads. For each:
- What the topic/task was
- What was accomplished or decided
- Any open threads or blockers left behind

Aim for 3–8 entries. Skip trivial or purely conversational interactions.}

## Active / In Progress

{Things currently in flight — partially done, awaiting input, or paused mid-task. Be explicit about what's blocking or what the next concrete step is.}

## Upcoming / Backlog

{Things that were mentioned, planned, or implied but not yet started. Include rough priority if known.}

## Notes

{Anything time-sensitive that doesn't fit above — deadlines, dependencies on external events, etc. Omit section if empty.}
```

## compendium/INDEX.md

```markdown
---
updated: {YYYY-MM-DD}
---

# Compendium — {Space Name}

## Projects
- [{Display Name}](projects/{slug}.md) — {one-line description}

## Organizations
- [{Display Name}](organizations/{slug}.md) — {one-line description}

## Topics
- [{Display Name}](topics/{slug}.md) — {one-line description}

## Conventions
- [{Display Name}](conventions/{slug}.md) — {one-line description}
```

## Compendium entry

```markdown
---
type: Project | Organization | Tool | System | Concept | Protocol | Convention | Other
status: Active | Paused | Archived | Planned | Superseded
related: [{Display Name}]
updated: {YYYY-MM-DD}
---

# {Display Name}

{3–6 sentences covering: what it is, its purpose/scope, current state, and any key decisions or constraints worth knowing. Write for a reader with no prior context.}
```

## Convention entry

```markdown
---
type: Convention
scope: {area this applies to — e.g., "file naming", "commit messages", "output format"}
status: Active | Superseded
related: [{Display Name}]
updated: {YYYY-MM-DD}
---

# {Convention Name}

{The rule, stated plainly. How it came about — what work or situation led to establishing it.}
```

## BACKGROUND.md

```markdown
---
updated: {YYYY-MM-DD}
---

# Background — {Space Name}

## Technical Setup

{Stack preferences, tooling choices, language rules, deployment context, and other technical background specific to work in this space.}

## Ongoing Decisions & Constraints

{Architectural decisions, naming conventions, scope boundaries, or strategic directions that have been settled. These are the "already decided" facts that prevent future agents from re-opening closed questions.}

## Communication & Collaboration Notes

{Preferences for output format, tone, language (German/English), and any explicit feedback given about agent behavior in this space — insofar as it differs from or adds to the general user preferences.}

## Cross-Space References

{Pointers to other Cowork spaces, external knowledge bases (Notion, Obsidian, GitHub repos), or resources that are relevant but not housed here. Use file paths or URLs where possible.}
```
