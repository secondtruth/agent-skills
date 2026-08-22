---
name: consolidate-space
license: MIT
description: Export the current Cowork Space into a Digest — STATUS.md (what is in flight), BACKGROUND.md (space-specific context), compendium/ (projects, organizations, topics, conventions) — merged with the previous export. Use when the user asks to export, sync or snapshot the space's knowledge ("exportiere den Space", "aktualisiere den Export", "update memory files").
---

# Consolidate Space

This skill exports and maintains a structured, up-to-date digest of the current Cowork Space (project). The goal is a set of human- and agent-readable files that give any AI assistant (or the user themselves) instant orientation: what's being worked on, who and what the key entities are, and what background context matters.

## Output Structure

All files are written inside a `Digest/` subdirectory of the current space's project folder.

```
{project folder of the current space}/      (Cowork: ~/Documents/Claude/Projects/{Space Name})
└── Digest/
    ├── STATUS.md              — current work status (replaced on every export)
    ├── BACKGROUND.md          — general context and preferences (merged)
    └── compendium/
        ├── INDEX.md           — one-liner overview of all entries (rebuilt on every export)
        ├── projects/
        │   └── {slug}.md      — one file per project (merged individually)
        ├── organizations/
        │   └── {slug}.md      — one file per organization or initiative (merged individually)
        ├── topics/
        │   └── {slug}.md      — tools, systems, protocols, concepts (merged individually)
        └── conventions/
            └── {slug}.md      — rules and conventions that emerged from work in this space (merged individually)
```

If the user specifies a different root path explicitly, use that instead.

**Slugs** are lowercase, hyphenated forms of the entity name — e.g., "Acme Tools" → `acme-tools`, "Open Data Association" → `open-data-association`. Use the slug only for the filename; the full name goes inside the file.

## Source Material

Gather information from all available sources. Read as many as are accessible:

1. **Auto-memory files** — `MEMORY.md` and all linked `.md` files in the current space's memory directory. The most reliable source of structured facts.
2. **Project knowledge files** — any files in the space's `.project-cache` or imported knowledge directory (uploaded docs, syncs.json references).
3. **Notion and Obsidian** — not primary sources to mine systematically. Consult on demand only when needed to clarify or add detail to something already identified from the primary sources above. If navigation in these systems is unclear, the `knowledge-management` skill, when it is among your available skills, knows where entries live.
4. **Existing export files** — read current `Digest/STATUS.md`, `Digest/BACKGROUND.md`, `Digest/compendium/INDEX.md`, and individual entry files first. Use them as the baseline to update rather than starting from scratch.

Note: session transcripts are intentionally excluded here — the session-listing tool lists sessions across all spaces, not just the current one, making them unreliable as a space-specific source.

`STATUS.md` is the space-level counterpart of a handoff document; for a single session's continuation use the `handoff` skill when it is among your available skills.

If a source is inaccessible (MCP not connected, file not found, etc.), skip it and note the gap at the top of the affected file.

## STATUS.md Format

This file answers: *What's been happening, and what's next?*

Template: `references/templates.md` § STATUS.md.

## compendium/ Format

A distilled, encyclopedic reference of everything that matters in this space — who the key players are, what the key things are, and the rules by which this space operates.

### INDEX.md

A single-line entry per entity, sorted alphabetically within each category.

Template: `references/templates.md` § compendium/INDEX.md.

### Entry files

All compendium entries use the same frontmatter structure. Metadata goes in frontmatter, content in the body.

Template: `references/templates.md` § Compendium entry.

Conventions additionally require a `scope` frontmatter field and must include in their body text how the convention came about — what prompted it, what problem it solved, or during what work it was established. This origin context is what makes a convention reusable and trustworthy rather than arbitrary.

Template: `references/templates.md` § Convention entry.

**Category guidance:**
- `projects/` — named projects the user works on or maintains (the product itself, its libraries and internal tools)
- `organizations/` — organizations, initiatives, collectives, communities (the user's companies, collectives, initiatives)
- `topics/` — tools, systems, protocols, or recurring concepts discussed across multiple sessions with project-specific context. Entries go to tools that carry project-specific nuance.
- `conventions/` — rules and conventions that emerged from actual work in the space. Not aspirational guidelines — only things that have demonstrably shaped how work is done here.

**Below the bar:** things mentioned only once in passing, generic tools/technologies without project-specific nuance, or conventions that belong in a project's own AGENTS.md rather than the space digest.

## BACKGROUND.md Format

This file answers: *What context does an agent need to work effectively in this space that isn't already covered by the user's system prompt or compendium entries?*

Capture only what is specific to this space; the user's general profile reaches every agent through the system prompt. Merged on each export.

Template: `references/templates.md` § BACKGROUND.md.

## Merge Behavior

**STATUS.md** — replace entirely on every run. No merging.

**BACKGROUND.md** — merge by section: update existing sections with new information, add new sections if needed, preserve valid content that wasn't touched in this session. Only remove content that is demonstrably outdated or contradicted by newer information.

**compendium/INDEX.md** — rebuild from the current set of entry files on every export.

**Individual compendium entry files** — update in place: edit body and frontmatter if something changed, leave the file untouched if nothing new is known. One file per entity; update in place. If new information contradicts existing content and you can't resolve it confidently, keep both versions with an inline note: `{Conflicting info — verify}`. Mark superseded conventions with `status: Superseded` in frontmatter rather than deleting them.

Always update the `updated` frontmatter field in every file you touch.

## Execution Steps

1. Determine the export directory (default: `Digest/` inside the space's project folder; ask if ambiguous).
2. Create directories as needed (`Digest/`, `Digest/compendium/projects/`, `Digest/compendium/organizations/`, `Digest/compendium/topics/`, `Digest/compendium/conventions/`).
3. Read all existing export files as baseline.
4. Gather source material: memory files → project knowledge files → the knowledge base on demand.
5. Write `Digest/STATUS.md` (replace entirely).
6. Update or create individual compendium entry files.
7. Rebuild `Digest/compendium/INDEX.md` from current entries.
8. Update `Digest/BACKGROUND.md` (merge).
9. Report: files created vs. updated, sources used, any inaccessible sources.

## Quality Checks

Before writing, verify:

- **STATUS.md**: Does it reflect the most recent sessions? Is anything in "Active" actually still active?
- **Compendium entries**: Are all facts grounded in what was discussed — no invented details? Are statuses current? Do convention entries include their origin?
- **BACKGROUND.md**: Is this background still valid? Does it contain anything that's just restating the user's general profile rather than space-specific context?

When memory files are the only source, note this at the top of STATUS.md, since its recency can't be verified.
