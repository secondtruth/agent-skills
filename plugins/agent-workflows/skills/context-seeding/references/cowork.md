# Cowork-Specific Context Seeding

This reference extends the main SKILL.md for **Cowork Projects** — the desktop agent environment. Read the main skill first; this file covers what's different.

## Cowork's context architecture

Cowork has a layered context system. Each layer adds specificity without replacing the others. In order of loading:

| Layer | Where to set it | Persistence | Scope |
|---|---|---|---|
| Global Instructions | Settings → Cowork | Permanent until edited | Every Cowork session |
| Skills & Plugins | Customize sidebar | Permanent (toggled on/off) | Auto-triggered when relevant |
| Project Instructions | Project setup | Permanent until edited | Every task in this Project |
| Context sources | Project setup | Permanent until removed | Available to read on demand |
| Project Memory | Automatic | Persistent across sessions | Scoped to this Project only |

A Cowork Project can have three types of **context sources**, and they can be combined:

- **Local folder** — Claude reads and writes files directly on disk. The filesystem *is* the Knowledge base.
- **Linked Chat project** — imports files and instructions from an existing Claude.ai Project. Useful for bridging Chat and Cowork without duplicating setup.
- **URLs** — links to web pages, documentation, or live resources Claude can reference during tasks. Good for external style guides, API docs, or anything that should stay at its canonical URL rather than being copied locally.

### Key differences from Claude.ai Projects

- **Direct file access**: Claude reads and writes local files. No upload/download friction.
- **Scoped project memory**: Claude remembers corrections and preferences across sessions within a Project. Claude.ai also has memory, but it's global (not project-scoped) and less granular. Cowork's memory is isolated per Project — nothing leaks.
- **Sub-agents**: Cowork can split work across parallel sub-agents. Context setup affects all of them.
- **Scheduled tasks**: Recurring tasks run automatically. Instructions need to be robust enough to work unattended.
- **Multiple context source types**: Local folders, linked Chat projects, and URLs can be combined in one Project.

## Extended context check (for Cowork)

The main skill's Step 0 already covers inspecting the system prompt for active skills, connectors, and instructions. In Cowork, also check:

- **Folder structure**: If the user has pointed to a folder, inspect it via file system tools. Understand what's already there before recommending a structure.
- **Linked context sources**: Check whether Chat projects or URLs are attached as context. These affect what needs to go into Instructions vs. what's already accessible.

**Then ask the user only what you can't determine yourself:**

- **"Will tasks in this Project run unattended?"** (Scheduled tasks, Dispatch from phone) — This is a planning decision, not system state. If yes, Instructions need to be more explicit because there's no human in the loop to catch ambiguity.

## Folder structure

A well-organized folder is half the context. Unlike Claude.ai where you upload curated files, Cowork reads everything in the connected folder — so noise in the folder means noise in the context.

There's no single correct structure. Choose based on Project type:

### Output-oriented Projects (reports, content, deliverables)

```
project-name/
├── context/          # What Claude needs to know
│   ├── about.md      # Background, stakeholders, terminology
│   ├── examples/     # Few-shot examples of desired output
│   └── references/   # Style guides, specs, external docs
├── inputs/           # Source material for current tasks
├── outputs/          # Finished deliverables go here
└── archive/          # Past work — available but not foregrounded
```

**Why this works**: Clear separation between reference material (stable), current work (changing), and output (generated). Claude knows where to read and where to write. `archive/` keeps completed work accessible for memory without cluttering active context.

### Research/analysis Projects

```
project-name/
├── sources/          # Papers, data, raw material
├── notes/            # Intermediate analysis, working docs
├── findings/         # Synthesized results
└── context.md        # Single file: scope, methodology, key terms
```

**Why this works**: Research flows from raw → processed → synthesized. A single `context.md` keeps the overhead low for Projects where the "instructions" are mostly about methodology.

### Recurring/operational Projects (weekly reports, inbox triage)

```
project-name/
├── templates/        # Report templates, output formats
├── rules/            # Business rules, criteria, thresholds
├── history/          # Past outputs for consistency reference
└── staging/          # Current run's working directory
```

**Why this works**: Operational tasks need consistency across runs. `rules/` makes criteria explicit (and editable), `history/` gives Claude examples of what "correct" looked like last time.

### General principles

- **Name files descriptively**: `q3-sales-data.csv` beats `data.csv`. Claude uses filenames to decide relevance.
- **Keep `context/` (or equivalent) lean**: Everything there is potential context for every task. Stale or irrelevant files waste the context budget.
- **Separate inputs from outputs**: Claude should never accidentally overwrite source material.
- **Use markdown for context files**: Better readability for Claude than PDF or DOCX.

## Skills vs. Project Instructions in Cowork

The main skill covers the general rule ("if you'd want it in a second Project, it's a skill"). Here's the Cowork-specific nuance:

**Skills in Cowork are operational, not just advisory.** In Chat, a skill influences a response. In Cowork, a skill governs every file Claude creates, every sub-agent it spawns, every scheduled task it runs. This makes skill quality much more important — and makes it critical to chunk skills rather than building monoliths.

Recommended chunking:
- **Voice/style skill**: How Claude writes (applies to everything)
- **Format skill**: Output structure for a specific deliverable type (report, email, slide deck)
- **Domain skill**: Domain knowledge and terminology (applies across Projects in that domain)

Each stays focused. Claude never confuses which rules apply because each skill handles its own context.

**When to promote from Project Instructions to Skill**: If you catch yourself copying the same Instructions block into a second Project, it should have been a skill from the start.

## Memory and iteration

Cowork's scoped project memory changes the seeding philosophy. Claude.ai has global memory, but it's shared across all conversations and not project-scoped. In Cowork, memory is isolated per Project, which means corrections in one Project don't bleed into others. This makes iterative seeding more practical:

1. **Day 1**: Seed with Instructions and folder context. Keep Instructions at 80% — deliberately leave out edge cases you're not sure about yet.
2. **First few tasks**: Run representative work. Review outputs. Give explicit feedback: "Next time, do X instead of Y" or "When you see pattern A, always handle it as B."
3. **Memory accumulates**: Claude saves corrections automatically. Each session gets smarter within this Project.
4. **Promotion checkpoint** (after ~5 sessions): Review what memory has accumulated. Promote the most important patterns back into Instructions (where they're guaranteed to be loaded, not just remembered). Delete memory entries that are now redundant with Instructions.

This cycle is the Cowork equivalent of "seeding is iterative" — but with a mechanism (memory) that captures the iterations automatically instead of requiring the user to manually rewrite Instructions each time.

### Memory hygiene

- Memory is append-only in practice. If Claude learned something wrong, correct it explicitly ("Forget that. The rule is actually X.").
- Memory doesn't replace Instructions for critical rules. Memory might get crowded out in complex tasks; Instructions are always loaded.
- Different Projects have different memories. If a correction applies everywhere, it belongs in Global Instructions or a skill, not in one Project's memory.

## Importing from Claude.ai Projects

Claude cannot perform this import autonomously — it's a manual process in the Cowork UI. Guide the user through these steps:

1. **Use the built-in import** — Cowork can import a Chat project directly during Project setup ("Import a project"). This transfers both instructions and knowledge files automatically. Alternatively, the user can **link** the Chat project as a context source, which keeps both in sync without duplication.
2. **Layer audit** — Claude.ai forces everything into two buckets (Instructions and Knowledge). Cowork has more layers. Recommend the user check for:
   - Rules that belong in Global Instructions (they were project-scoped only because Chat doesn't have globals)
   - Patterns that should be extracted into skills (they were inlined only because Chat doesn't have skills)
   - Reference material that should be a live connector or URL link instead of a static file (e.g., Notion pages, Google Docs)
3. **Enable relevant plugins** — Cowork has plugins for common workflows. Check if any cover ground the user was handling manually in Chat.

## Delivery checklist (Cowork)

When shipping a Cowork Project setup, deliver:

- The full Instructions as a code block (in English)
- Recommended folder structure with explanation of each directory's purpose
- List of skills/plugins to enable (with one-line justification each)
- Any updates needed to Global Instructions
- Recommended context files to create (e.g., `about.md`, `examples/`)
- URLs to link as context sources (external docs, style guides, live resources)
- A suggested first task to sanity-check the setup
- Whether scheduled tasks make sense for this Project, and if so, a draft schedule
