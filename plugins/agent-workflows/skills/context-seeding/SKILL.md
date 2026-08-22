---
name: context-seeding
license: MIT
description: Set up Claude.ai Projects and Cowork Projects — Instructions, curated Knowledge, and the audit of a Project that "isn't working well". Use when the user creates or reworks a Project, asks what belongs in Project Knowledge versus Instructions, or says their Project keeps forgetting things.
---

# Context Seeding for Claude Projects

A skill for turning a vague "I want a Project for X" into a Project that actually behaves the way the user wants on turn one — through deliberate Instructions and curated context. Covers both **Claude.ai Projects** (web/app chat) and **Cowork Projects** (desktop agent).

**For Cowork-specific guidance** (layered context, folder structure, memory, plugins, import from Chat): read `references/cowork.md` after this file.

## Mental model

Claude offers multiple context layers. Every layer has a scope — putting the right thing in the wrong layer is how Projects break.

| Layer | Scope | What goes here |
|---|---|---|
| Profile Preferences / Global Instructions | Every session, everywhere | Identity, universal style, language defaults |
| Skills | Every session where relevant (auto-triggered) | Reusable patterns: writing voice, report format, review checklists |
| Project Instructions | Every turn in this Project | Purpose, role, scope, project-specific behavior, anti-patterns |
| Project Knowledge / Folder Context | Retrieved on demand | Reference docs, examples, specs, source material |

**The cardinal rule**: behavior goes in Instructions (or Skills/Global for cross-project behavior), facts go in Knowledge. Mixing them is the #1 reason Projects feel "off" — rules buried in a knowledge PDF get ignored, and reference data stuffed into Instructions burns context on every turn.

### Where does this rule belong?

Before adding a line to Project Instructions, run this check:

- **Would you want this in every session, not just this Project?** → Profile Preferences / Global Instructions.
- **Would you want this same behavior in a second Project?** → It's a Skill. Extract it.
- **Is it specific to THIS Project's scope, role, or domain?** → Project Instructions. Correct place.
- **Is it a fact, not a behavior?** → Knowledge / folder context. Don't waste Instructions tokens on it.

Duplicating rules across layers wastes tokens and risks contradictions. When in doubt, place it at the broadest applicable layer. Claude can review its own system prompt to see which Profile Preferences, Global Instructions, and skills are currently active — check there before adding something that's already covered.

## Workflow

Two paths, both starting with recon:

- **New Project** (seed from scratch): recon → steps 1–4 → Ship.
- **Existing Project that misbehaves** (audit & fix): recon → the **Audit path** → loop back through whichever build steps (Interview, Draft, Curate) need redoing → Ship.

### 0. Pre-seeding recon (both paths)

Before asking the user anything, gather existing context from every source available. The more you already know, the sharper your interview questions become.

**Self-check**: Inspect your own system prompt and available tools first. Identify active Profile Preferences / Global Instructions, loaded skills, and connected MCPs/connectors. Anything already covered at these layers doesn't need to be repeated in Project Instructions — and knowing what's there shapes the interview.

**Past conversations**: Search chat history for conversations related to the Project's topic. These often contain implicit decisions, preferences, and pain points that never got written down. Extract anything that looks like a behavior rule, a scope decision, or a repeated complaint — these are interview shortcuts and anti-pattern candidates.

**Existing Project context**: If the user is reworking or extending an existing Project, review what's already in its Knowledge base or folder. Note what's there, what looks stale, and what's missing. This feeds directly into the Audit path or saves you from recommending files the user already has.

**External knowledge bases** (Notion, Google Drive, etc.): Search for pages related to the Project's topic. What you find changes the interview:

- **Existing page on the exact topic** → skim it, then ask targeted questions instead of open-ended ones. You already know half the answers.
- **Related but not exact match** → note it as a Knowledge candidate and ask whether it should be included, excerpted, or ignored.
- **Nothing found** → proceed with the normal interview, but flag at the end: "there's no KB page on this yet — worth documenting after the Project stabilizes?"

This step is best-effort — use whatever sources are available. If none are, skip straight to step 1.

### 1. Interview before writing

Interview first. When the `grilling` skill is among your available skills, run the interview through it with the list below as the first frontier; otherwise ask the user in one batched, numbered message with a recommended answer each, until you can answer all of these. When someone else holds the answers, the `to-questionnaire` skill, if available, turns them into a form.

- **Purpose**: What is this Project *for*? One sentence. If the user can't answer this, the Project shouldn't exist yet.
- **Role**: Who should Claude *be* inside this Project? (Reviewer, collaborator, ghostwriter, research assistant, rubber duck, domain expert, etc.)
- **Scope boundary**: What is explicitly *out of scope*? What should Claude refuse or redirect?
- **Output shape**: What does a typical good response look like? Long-form prose? Code diffs? Checklists? Formal or casual?
- **Recurring context**: What information will Claude need to know on *every* turn? (These become Instructions candidates.)
- **Reference material**: What information will Claude need *sometimes*? (These become Knowledge candidates.)
- **Known failure modes**: Has the user tried this before and watched Claude screw it up? What did it do wrong? (Gold — these become explicit anti-patterns in the Instructions.)
- **Platform**: Is this for Claude.ai (chat) or Cowork (desktop agent)? This determines the context architecture. If Cowork: read `references/cowork.md` for the expanded interview and setup flow.

If the user already has a draft or an existing Project, skip to the Audit path below.

### 2. Research the domain

After the interview, but before drafting, search the web for best practices and known pitfalls relevant to the Project's purpose. The interview gives you enough context to search effectively — you know the domain, the role, and the failure modes.

Examples: if seeding a code review Project, look up current best practices for AI-assisted code review; if seeding a content writing Project, research current style guide conventions; if seeding a legal review Project, find common AI pitfalls in that domain.

Incorporate useful findings as candidate anti-patterns or Working Principles. Don't dump raw research — distill into actionable rules. If nothing useful turns up, move on.

### 3. Draft the Instructions

**Language rule**: Project Instructions are always written in English, regardless of the user's language or the Project's output language — Claude follows instructions most reliably in English, and it keeps the Project portable. If the Project should produce output in a specific language, state that as a Working Principle (e.g., "Always respond in German").

**Voice**: write Instructions in second person ("You are...", "You should..."). Imperative and specific beats descriptive and fluffy.

**Headings**: start at H2 — the Project name is already in the UI, so the building blocks sit at H2.

**Standard opening**: Every Instructions set opens the same way — a metadata block, then a short merged intro.

1. **A `<project_metadata>` block first.** This is machine-readable project identity plus pointers to where related context lives, so Claude knows which Project it's in and where to fetch or file related material. Populate it from recon (step 0 — the knowledge-base search). Include the fields that apply and omit the ones that don't (a work Project may have no notes folder; a throwaway Project may have no knowledge-base page):

   ```
   <project_metadata>
   Name: {project name}
   Emoji: {emoji}
   Type: {personal | work | community | ...}
   Notes Folder: {folder in the user's notes vault — omit if none}
   Knowledge Base Page: {page URL — omit if none}
   </project_metadata>
   ```

2. **Then a short, unheaded intro (2–4 sentences)** that fuses *what the Project is for* and *who Claude is in it* — purpose and role in one breath.

#### Building blocks

After the opening, Instructions are composed from the blocks in `references/building-blocks.md` — Working Principles, Context You Should Know, Out of Scope, Anti-patterns, Workflow, Output Format, References. Read it while drafting; order by importance and omit what does not apply.

**Length target**: 300–800 words for most Projects. If you're pushing past 1500, you're probably putting facts in that belong in Knowledge, or you're over-specifying behavior Claude already does by default. Instructions consume tokens on every turn — brevity is a feature.

Done when the draft fits the length target and every line is a behaviour or an every-turn fact.

### 4. Curate the Knowledge base

For each candidate file, ask: **"Will Claude need this on *every* turn, *some* turns, or *rarely*?"**

- **Every turn** → it's not Knowledge, it's Instructions. Extract the essential bits and inline them.
- **Some turns** → perfect Knowledge candidate. Upload it (or place it in the folder for Cowork).
- **Rarely** → leave it out. Let the user paste it when needed, or store it externally and link.

Done when every candidate file has an every/some/rarely verdict.

**What belongs in Knowledge**:
- Reference docs (API specs, style guides, glossaries)
- Source material (research papers, transcripts, existing drafts the Project works on)
- Examples of desired output (few-shot anchors)
- Structured data the Project queries against

**Keep out of Knowledge**:
- Behavior rules ("always respond in German") — goes in Instructions (or Skills/Global)
- Tiny snippets (< 1 page) — inline them in Instructions
- Stale or superseded material — retrieval will surface the wrong thing
- Giant dumps "just in case" — signal-to-noise matters, retrieval isn't magic
- Duplicate versions of the same document — pick one

**File hygiene**:
- Prefer markdown or plain text over PDF when possible (better retrieval)
- Give files descriptive names — `api-v3-reference.md` beats `doc1.pdf`
- Split huge files by topic if they cover multiple domains; keep cohesive files whole
- If a file has a structure Claude should understand (sections, schemas), state it explicitly in the Instructions under "Context You Should Know"

### Audit path (existing Project)

When the user says "my Project isn't working well," run the checklist in `references/audit.md` instead of the build steps. Findings feed back into a rewrite, so loop through Interview/Draft/Curate as needed afterward.

### 5. Ship it (both paths)

Deliver:
- The full Instructions as a code block (in English), ready to paste into the Project Instructions field
- A list of recommended Knowledge files (with one-line justifications for each)
- A list of things deliberately *not* included and why
- Optionally: a suggested first test prompt the user can run to sanity-check the setup
- For Cowork: see the extended delivery checklist in `references/cowork.md`

## Knowledge-base integration (when available)

If the user works with a live knowledge base (Notion via its MCP, for example), treat it as a first-class source during seeding.

**Notion pages as Knowledge sources**: Notion pages generally should *not* be uploaded as static files into Project Knowledge — they go stale the moment someone edits them in Notion. Instead:

- **Reference them in Instructions** under "Context You Should Know" with their page ID or URL, and note that Claude should fetch fresh via the Notion MCP when needed.
- **Only snapshot into Knowledge** if the content is explicitly frozen (archived decision docs, historical specs) or if the user won't have MCP access in that Project.
- **One copy** — the live reference *or* a frozen snapshot; two versions make retrieval surface the wrong one.

**Cross-linking**: If the Project is tied to an organization, brand, or umbrella already documented in Notion, the Instructions should name the parent entity explicitly so Claude can fetch context on demand rather than having it all inlined.

**Post-seeding documentation**: After shipping the Project setup, consider whether the Project itself deserves a Notion entry — especially for long-lived Projects tied to ongoing work. A short page with purpose, scope, and a link back to the Project makes future seeding of related Projects much faster.
