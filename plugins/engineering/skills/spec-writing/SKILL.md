---
name: spec-writing
description: Writing, reviewing, and improving protocol specifications, technical standards, and RFC-style documents. Use this skill whenever the user works on a spec, standard, protocol definition, or any formal technical document that uses normative language (MUST, SHOULD, MAY). Also trigger when the user asks to review a spec for quality, requests RFC-style formatting, wants to restructure or improve an existing specification, or discusses spec writing best practices. Covers document structure, normative prose, scope discipline, terminology consistency, example placement, and versioning. This skill should be used even for initial drafts — getting the structure right from the start saves painful refactoring later.
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
4. Never add a section whose sole purpose is to point to another document
5. Verify no concept is defined in two places after changes
6. Update the Version History with a summary of *what* changed

### Reviewing a Spec
1. Check against the review checklist in `references/guide.md` §8
2. Flag: scope violations, terminology drift, redundant definitions, missing error behaviors
3. Provide specific corrections with exact replacement text, not vague suggestions

## Critical Rules

- **A spec knows only what it defines.** Don't reference documents that don't exist yet. Don't name specific alternatives unless the spec defines them.
- **Prose over lists.** Normative sections are paragraphs with RFC 2119 keywords, not bullet points. Tables are fine for structured data (status codes, fields, parameters).
- **One concept, one place.** If something is defined twice, one copy will rot. Define once, reference thereafter.
- **No retrofitting.** When adding to an existing spec, rewrite the relevant sections so the addition is integrated — don't bolt on a new section that exists only to explain the change.
- **A layering section names transports only.** Content format, content model, and application semantics get their own sections.
- **Examples are not normative.** The spec text is authoritative. Examples illustrate; they don't define.
- **Be precise, not clever.** Every sentence should have exactly one interpretation. No metaphors, no humor, no ambiguity.

## Language

- Answer in the conversation's language; write the spec in the suite's language, which is usually English.
- Use active voice, present tense: "The server sends" not "A response is sent."
- Keep sentences short. Protocol specs are read while writing code.

## Common Mistakes to Catch

- Using MUST when SHOULD is meant (over-constraining)
- Status codes / error codes defined but never referenced in normative text
- The Abstract containing motivation or history (belongs in a separate Background section)
- Inline examples that show the same concept multiple times
- Sections that duplicate content from another section
- Terminology shifting mid-document ("transport" → "binding" → "carrier")
- Changelog entries that describe *why* instead of *what*
