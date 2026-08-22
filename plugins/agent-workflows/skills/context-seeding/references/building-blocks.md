# Instruction Building Blocks

The blocks an Instructions set is composed from, after the metadata block and intro. Order by importance; omit anything that doesn't apply; don't pad.

After the opening (metadata block + intro), Instructions are composed from whichever of these blocks the Project actually needs. Order by importance; omit anything that doesn't apply; don't pad.

- **Working Principles** — 3–7 bullets of how to operate. Behavior, not facts. Examples: output language, formality, when to ask vs. assume, how deep to go by default, when to use artifacts.
- **Context You Should Know** — only information that must be in context every turn. Stable facts about the domain, the user's setup, key vocabulary. If it changes often, it belongs in Knowledge, not here.
- **Out of Scope** — what this Project does NOT do. Useful for broad-purpose Projects; skip for narrowly focused ones where scope is obvious.
- **Anti-patterns** — concrete things to avoid, ideally pulled from past failures and domain research (step 2). "Don't suggest X when the user asks about Y" beats generic "be careful." Skip if the Project is new and there are no known failure modes yet — they'll emerge during iteration.
- **Workflow / Process** — step-by-step instructions for Projects with a repeatable task pattern (e.g., "1. Read the PR diff, 2. Check for X, 3. Output in format Y"). Not needed for open-ended Projects.
- **Output Format** — explicit structure or template for the output, if consistency matters. Can be a few lines or a full example. Unnecessary when the output shape varies by task.
- **References** — pointers to Knowledge files, Notion pages, URLs, or other context sources with brief notes on what each contains and when to consult it. Only needed when the Project has non-obvious reference material.

Purpose and role aren't in this list because they live in the opening intro. Split **Role** into its own H2 block only when it's complex enough to need real elaboration — a distinct stance, multiple hats, a non-obvious relationship to the user — which is rare; for most Projects the intro carries it.

A lightweight Project (rubber duck, brainstorming partner) might need only the metadata block, a one-line intro, and a couple of Working Principles. A heavyweight Project (automated report generation, code review pipeline) might use most blocks plus a detailed Workflow section.

