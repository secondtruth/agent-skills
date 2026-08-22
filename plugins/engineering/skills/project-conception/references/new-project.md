# Conception for a New Project

The path reference for a project starting from an empty repo. `SKILL.md` holds the shared parts – research delegation, the Phase 2 essentials, the Phase 1 verdict, risks/dependencies/open questions, AI-Era Scoping, Stop-Criteria.

## Phase 1: Discovery & Competitive Landscape

The single most-skipped phase in hobby project work. Do it anyway.

### Step 1: Check the user's own portfolio first

Before researching the wider world, check if the idea already lives somewhere in the user's existing projects — the "real competition" is sometimes the user themselves. The profile says where the portfolio is recorded; the `knowledge-management` skill, when it is among your available skills, knows how to scan it. Ask: is this a new project, an extension to an existing one, or a rename/refocus of something that already exists?

If it overlaps significantly with an existing project: **stop and discuss before continuing**. Extending is almost always cheaper than starting fresh – and it may mean switching to `feature-in-existing-codebase.md`.

### Step 2: External landscape

The list below is not a source-quality ranking – it's where competitors hide, in the order worth checking:

- GitHub (search by topic + language; check forks of dead projects too)
- Hugging Face for ML/AI projects
- Crates.io / npmjs / packagist for language-specific competition
- Awesome-lists for the domain
- Hacker News / Reddit / r/selfhosted for community sentiment
- Product Hunt / lobste.rs / Show HN for product framing
- Wikipedia + academic search for "is this a solved problem with a name we don't know yet"

### Step 3: Structured analysis

Read `competitive-analysis.md` for the full methodology – taxonomy, feature matrix template, traction signals, license/business-model check, USP distillation, anti-features, and how to mine dead projects for lessons.

Produce a written competitive landscape document. Not bullets in chat. A real artifact filed in the knowledge base under the project page.

## Phase 2: Concept Shaping

On top of the Phase 2 essentials in `SKILL.md`, a new project settles these axes. Not all are needed for every project – pick what's load-bearing for this one.

### Scope

Two lists: **in scope** and **explicitly out of scope**. The out-of-scope list is often the more important one – it prevents the project from sprawling into yet another half-finished maximalist thing.

### Stack decision

Pick the stack and **write down why**. Not "Go because Go is cool". Reasons should reference: language fit for the problem, ecosystem maturity in the relevant niche, existing user expertise, deployment target constraints, integration with adjacent projects.

If the user's profile names default languages, deviations need stronger justification than preference.

### Naming

If the user's profile defines a naming convention (a pool of names, a prefix scheme), suggest 3–5 candidates from it that fit thematically. If nothing fits, name it descriptively for now and flag it as TBD – bad names are easier to change before code than after.

Also check: is there an umbrella prefix or suffix convention to follow? Different umbrellas usually have different feels.

### Umbrella fit

Decide explicitly where the project lives. The candidate umbrellas and what belongs to each come from the user's profile; **Standalone** is the answer when it fits none of them (rare; justify). Without umbrellas in the profile, Standalone needs no justification.

This decision affects naming, license preference, repo org, doc style, and which community channels announce it. Get it right early.

### Doc strategy

Follow the documentation framework the user's profile names (Diátaxis — Tutorials / How-Tos / Reference / Explanation — is the common one). Even at conception, name which quadrants will exist and roughly what goes in each. Most hobby projects need at minimum a Reference (API/CLI docs) and a single Tutorial (getting started). Defer Explanation for later if the concepts aren't novel.

## Phase 3: Handoff format

A single page in the user's knowledge base (or an update to an existing one) containing risks, dependencies and open questions. Then trigger `knowledge-management`, when it is among your available skills, to file it where the umbrella's project records live and to note the new conception wherever the user tracks project evolutions.

## Output

1. A **competitive landscape document** (Phase 1, Step 3)
2. A **concept document** with problem statement, scope, MVP cut, architecture sketch, stack rationale, naming, umbrella, doc strategy (Phase 2)
3. A **handoff package** with risks, dependencies, open questions (Phase 3)

These can live as one page or three linked pages in the knowledge base – the user's call.
