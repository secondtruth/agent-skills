---
name: spec-writing
license: MIT
description: Write, review, and improve protocol specifications, technical standards, and RFC-style documents — structure, normative prose (MUST/SHOULD/MAY), scope, terminology, examples, versioning. Use from the first draft on and when reviewing or restructuring an existing spec; feature specs bound for an issue tracker are the to-spec skill's job when it is available.
---

# Spec Writing

Guide for writing protocol specifications, technical standards, and RFC-style documents.

## Before Writing

1. **Read `references/guide.md`** — Full best practices guide. Read it before starting any new spec or major revision.
2. **Check the repo's agent instructions** — `CLAUDE.md`, `AGENTS.md`, or `CONTRIBUTING.md` may define a canonical document structure for the suite. Follow it as the baseline, with `references/guide.md` providing the detailed how-to.
3. **Check existing specs in the project** — Match the conventions already established (terminology, formatting, section ordering) for consistency across the spec suite.
4. **Reuse the repo's glossary** — if it keeps a `CONTEXT.md`, Conventions and Definitions reuses its terms verbatim and feeds new ones back; hard-to-reverse design trade-offs go to `docs/adr/` (the `domain-modeling` skill's layout, when it is among your available skills). Feature specs bound for an issue tracker are the `to-spec` skill's job when it is available; this skill writes protocol and standards documents.

## Core Workflow

### New Spec
1. Start with the canonical section order from `references/guide.md` §1
2. Write the Abstract first — 2–4 sentences, no motivation, no history
3. Define terminology in Conventions and Definitions before using it anywhere
4. Write normative sections in prose paragraphs, not bullet lists
5. For each protocol element, document what happens when things go wrong (edge cases, malformed input, missing resources)
6. Place one canonical example per concept inline; collect full request-response pairs in an appendix
7. Run the review checklist from `references/guide.md` §8 before delivering

### Revising an Existing Spec
1. Read the full spec first — understand the current structure before changing anything
2. Identify: duplicate content, missing edge cases, terminology inconsistencies, misplaced examples
3. Integrate changes organically — additions should read as if they were always there
4. A section carries a concept; a bare cross-reference is a sentence, not a section
5. Verify no concept is defined in two places after changes
6. Update the Version History with a summary of *what* changed

### Reviewing a Spec
1. Check against the review checklist in `references/guide.md` §8
2. Flag: scope violations, terminology drift, redundant definitions, missing error behaviors
3. Provide specific corrections with exact replacement text, not vague suggestions

## Critical Rules

- **A spec knows only what it defines.** Cite only documents that exist; name an alternative only if the spec defines it.
- **Prose over lists.** Normative sections are paragraphs with RFC 2119 keywords, not bullet points. Tables are fine for structured data (status codes, fields, parameters).
- **One concept, one place.** If something is defined twice, one copy will rot. Define once, reference thereafter.
- **Integrate additions.** When adding to an existing spec, rewrite the relevant sections so the addition reads as if it had always been there.
- **A layering section names transports only.** Content format, content model, and application semantics get their own sections.
- **Examples are not normative.** The spec text is authoritative. Examples illustrate; they don't define.
- **Be precise, not clever.** Every sentence has exactly one interpretation.

## Language

- Answer in the conversation's language; write the spec in the suite's language, which is usually English.
- Use active voice, present tense: "The server sends" not "A response is sent."
- Keep sentences short. Protocol specs are read while writing code.
