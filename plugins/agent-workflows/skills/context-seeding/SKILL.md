---
name: context-seeding
description: Set up Claude.ai Projects and Cowork Projects from scratch with well-crafted Instructions and curated Knowledge/context. Use this skill whenever the user wants to create a new Claude.ai Project or Cowork Project, seed an existing Project with context, rewrite Project Instructions, decide what belongs in Project Knowledge vs. what should stay out, audit a Project that "isn't working well," or set up a Cowork workspace with proper context layers. Trigger even when the user doesn't say "seed" — phrases like "I'm setting up a Project for X", "help me write instructions for my Project", "what should I put into the Project Knowledge", "my Project keeps forgetting X", "set up a Cowork Project for Y", or "help me configure my Cowork workspace" all mean this skill applies.
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

This isn't a single linear sequence — there are two paths, and both start with recon:

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

**Headings**: No H1 anywhere — the Project name is already in the UI, so a `# Project Name` heading just wastes tokens. The building blocks sit at H2.

**Standard opening**: Every Instructions set opens the same way — a metadata block, then a short merged intro.

1. **A `<project_metadata>` block first.** This is machine-readable project identity plus pointers to where related context lives, so Claude knows which Project it's in and where to fetch or file related material. Populate it from recon (step 0 — the Notion/Obsidian search). Include the fields that apply and omit the ones that don't (a work Project may have no Obsidian vault; a throwaway Project may have no Notion page):

   ```
   <project_metadata>
   Name: {project name}
   Emoji: {emoji}
   Type: {personal | work | community | ...}
   Obsidian Directory: {vault folder — omit if none}
   Notion Page: {page URL — omit if none}
   </project_metadata>
   ```

2. **Then a short, unheaded intro (2–4 sentences)** that fuses *what the Project is for* and *who Claude is in it* — purpose and role in one breath.

#### Building blocks

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

**Length target**: 300–800 words for most Projects. If you're pushing past 1500, you're probably putting facts in that belong in Knowledge, or you're over-specifying behavior Claude already does by default. Instructions consume tokens on every turn — brevity is a feature.

### 4. Curate the Knowledge base

For each candidate file, ask: **"Will Claude need this on *every* turn, *some* turns, or *rarely*?"**

- **Every turn** → it's not Knowledge, it's Instructions. Extract the essential bits and inline them.
- **Some turns** → perfect Knowledge candidate. Upload it (or place it in the folder for Cowork).
- **Rarely** → don't include. Let the user paste it when needed, or store it externally and link.

**What belongs in Knowledge**:
- Reference docs (API specs, style guides, glossaries)
- Source material (research papers, transcripts, existing drafts the Project works on)
- Examples of desired output (few-shot anchors)
- Structured data the Project queries against

**What does NOT belong in Knowledge**:
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

When the user says "my Project isn't working well," run this checklist instead of the build steps above. Findings feed back into a rewrite, so loop through Interview/Draft/Curate as needed afterward.

1. **Read the Instructions out loud (mentally).** Are they specific, or generic filler? Generic = rewrite.
2. **Behavior/fact mixing?** Are there rules buried in Knowledge files, or reference data clogging Instructions?
3. **Contradictions?** Does Instructions say one thing and a Knowledge file imply another?
4. **Layer confusion?** Review your own system prompt to see what's already active at higher layers (Profile Preferences, Global Instructions, skills). Are Project Instructions duplicating any of that? Is something project-scoped that should be a skill (because it applies across multiple Projects)? Is something in a skill that should be project-scoped (because it only makes sense here)?
5. **Stale files?** When were Knowledge files last updated? Are any superseded?
6. **Missing anti-patterns?** Ask the user: "what does it keep getting wrong?" — then encode those as explicit Don'ts.
7. **Over-scoped?** Is this one Project trying to be three? Split it.
8. **Under-scoped?** Is the user compensating with long prompts every turn? Promote repeated context into Instructions.

Present findings as a short list with severity, then propose a concrete rewrite.

### 5. Ship it (both paths)

Deliver:
- The full Instructions as a code block (in English), ready to paste into the Project Instructions field
- A list of recommended Knowledge files (with one-line justifications for each)
- A list of things deliberately *not* included and why
- Optionally: a suggested first test prompt the user can run to sanity-check the setup
- For Cowork: see the extended delivery checklist in `references/cowork.md`

## Notion KB integration (when available)

If the user works with a Notion knowledge base (e.g. via the Notion MCP), treat it as a first-class source during seeding.

**Notion pages as Knowledge sources**: Notion pages generally should *not* be uploaded as static files into Project Knowledge — they go stale the moment someone edits them in Notion. Instead:

- **Reference them in Instructions** under "Context You Should Know" with their page ID or URL, and note that Claude should fetch fresh via the Notion MCP when needed.
- **Only snapshot into Knowledge** if the content is explicitly frozen (archived decision docs, historical specs) or if the user won't have MCP access in that Project.
- **Never upload both** the Notion page and a copy — retrieval will surface conflicting versions.

**Cross-linking**: If the Project is tied to an organization, brand, or umbrella already documented in Notion, the Instructions should name the parent entity explicitly so Claude can fetch context on demand rather than having it all inlined.

**Post-seeding documentation**: After shipping the Project setup, consider whether the Project itself deserves a Notion entry — especially for long-lived Projects tied to ongoing work. A short page with purpose, scope, and a link back to the Project makes future seeding of related Projects much faster.

## Heuristics worth keeping in mind

- **If you can't explain why a line is in the Instructions, delete it.** Every sentence earns its place or gets cut.
- **Specific > generic, always.** "Review PRs with a focus on race conditions and error handling" beats "help with code review."
- **Name the failure modes.** Claude responds much better to "don't do X" than to implicit expectations.
- **One Project, one purpose.** If the user describes three unrelated use cases, that's three Projects. Say so.
- **Instructions are not documentation.** Don't explain the domain to a human reader — write directly to Claude, in the shortest form that conveys the behavior.
- **Seeding is iterative.** The first version will be wrong in small ways. Tell the user to expect one or two revisions after real use, and to note what goes wrong so they can encode those as anti-patterns.
- **Context has a budget.** Instructions consume tokens on every turn. Skills share a context budget (~2% of the context window). More isn't always better — prioritize signal over coverage.
