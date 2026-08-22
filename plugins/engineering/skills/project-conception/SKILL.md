---
name: project-conception
description: Shape a rough idea into a concrete concept ready for roadmapping – a whole new project, or a single feature or subsystem inside an existing codebase. Use whenever the user has an idea for a tool, library, service, or project and wants it developed from vague to actionable – competitive landscape, scoping, MVP definition, architecture sketch, stack decision. Also trigger when designing a feature, module, or subsystem into an existing codebase – "how should we build X into Y?", "how do we get this properly into X?", "what would it take to add Z?" – where the job is to survey what already exists and map the target design onto it. Also trigger on "does this already exist?", "should I even build this?", "how do I scope this?", "what's the MVP?", "what's our USP vs. X?", or comparing against existing tools before committing. Use it for re-scoping existing projects too. Triggers naturally after a brainstorming session, once an idea has enough substance to commit to.
---

# Project Conception

## Core Idea

The space between "I have an idea" and "I can write a roadmap" is where most projects die – either from never escaping the idea state, or from rushing into implementation without ever asking whether the thing is worth building or how it should be shaped. This skill owns that space.

Three phases, in rough order but with feedback loops:

1. **Discovery** – establish what already exists, where the gap is, whether to build at all. Ends in a go / no-go.
2. **Concept Shaping** – problem statement, scope, MVP cut, architecture sketch. Ends in a concept document.
3. **Plan Handoff** – risks, dependencies, open questions. Ends in a package `roadmap-management` can consume.

The skill is opinionated about one thing above all: **be willing to recommend not building**. A clear "this is a waste of time because X exists and is healthy" or "this belongs as an extension to your existing project Y" is more valuable than another half-finished repo.

## When to use vs. adjacent skills

| Situation | Skill |
|---|---|
| Wild, divergent idea generation; "what if we…" mode | `brainstorming` |
| Idea has substance, needs sharpening into a plan | **this skill** |
| Concept is shaped, need to prioritize features/timeline | `roadmap-management` |
| Any research during conception – prior art, versions, product capabilities | `information-retrieval` (called from within this skill; it owns source quality) |
| Writing a formal spec/protocol document | `spec-writing` |
| Documenting the result in the user's knowledge base | `knowledge-management` |

The transition from `brainstorming` to this skill happens when the user stops asking "what if" and starts asking "should we" or "how would this work". When in doubt, ask which mode the user is in.

## Pick the path first, then read its reference

Conception looks different depending on what is being conceived. Decide which of the two it is, then **read the matching reference before starting Phase 1** – this document holds only what both paths share.

- **A new project** – tool, library, service, anything starting from an empty repo → `references/new-project.md`
- **A feature, module or subsystem inside a codebase that already exists** → `references/feature-in-existing-codebase.md`

If it is genuinely unclear which one applies, that is itself a finding: ask the user whether this is a new thing or an extension. Extending is almost always cheaper than starting fresh, so the question is worth asking out loud.

Before Phase 1, read the user's profile where one is present — their instructions, memory, or `~/.agents/profile/` — for the portfolio location, default stack, naming convention, umbrella organisations, documentation strategy, and where handoffs land. Absent a profile, ask once.

## Research during conception

Delegate the actual searching to `information-retrieval`. **Source quality is that skill's job, not this one's**: which sources count as primary, how far to trust a blog post, verifying package existence and versions against the registry – all of that lives there. Follow it; don't restate or fork those rules here.

Both paths need it, for different questions: the new-project path asks "who else has built this", the existing-codebase path asks "is there a library that makes this an integration rather than an implementation".

## Ending Phase 1: state a recommendation

What Phase 1 actually surveys is path-specific: portfolio check plus external landscape in `references/new-project.md`, the internal surface inventory in `references/feature-in-existing-codebase.md`. Either way it ends with a verdict, not a summary:

- **Go** – there's a real gap; here's our wedge
- **No-go** – X already solves this well; contribute to X instead, or pick a different problem
- **Pivot** – the original idea is taken, but the underlying motivation could be served by a different cut
- **Extend** – this belongs as a feature/module of an existing project

State the recommendation directly. Don't hedge. The user can override – but they should override an opinion, not a non-answer.

## Phase 2 essentials: what every concept states

Path-independent. Whatever is being conceived, the concept document answers these three before anything path-specific.

### Problem statement

One paragraph. Who has the problem, what is the problem, why does it suck today, what does success look like. If you can't write this paragraph, you don't understand the project yet.

### MVP cut (Walking Skeleton)

What's the smallest version of this that is *end-to-end functional*? Not "the smallest feature set", but the smallest *complete* slice. A walking skeleton ships and works. A truncated feature list often doesn't.

By stack: a CLI tool's walking skeleton is "one command that does one real thing"; a web service's is "one endpoint behind one route serving one real resource"; a library's is "one exported function with a test".

### Architecture sketch

For code projects, draw the rough shape. Components, boundaries, data flow. Doesn't need to be UML – a labeled block diagram or even ASCII is fine. Identify:

- The one or two core abstractions (interfaces, types, modules)
- External integrations and their failure modes
- Where state lives
- Sync vs. async boundaries

If the project must fit an existing deployment platform (reverse-proxy wiring, SSO, network layout, env-file conventions — the user's techdocs or profile describe theirs), name the platform's constraints in the sketch so it fits.

Beyond these, the paths diverge and the rest of Phase 2 lives in the reference: a new project settles scope, stack, naming, umbrella fit and doc strategy (`references/new-project.md`); a feature inherits the last four from its host and scopes itself through the three-way split against the Phase 1 inventory (`references/feature-in-existing-codebase.md`).

## Ending Phase 3: risks, dependencies, open questions

Where the handoff lands is path-specific – a page in the user's knowledge base under the umbrella's project records (`references/new-project.md`), or a concept document in the repo plus tracked issues (`references/feature-in-existing-codebase.md`). Every handoff carries these three regardless of path.

**Risks** – the things most likely to kill the effort:

- Technical unknowns ("not sure if X library can do Y")
- Scope creep vectors ("the moment someone asks for Z, we're doomed")
- Burnout risk ("if this needs more than N weekends, I'll lose interest")
- Dependency on flaky externals ("relies on undocumented API of Z")

**Dependencies** – both code-level (libraries, services, infra) and personal (do you need to learn a new tool first? wait for a release?).

**Open questions** – things that aren't decided yet but don't block starting. List them so they get answered before they become problems.

Then explicitly tell the user "concept is ready for roadmapping" and let them invoke `roadmap-management` from there.

## AI-Era Scoping: Plan as if unassisted, build as if assisted

Implementation cost has collapsed. Visions that were a company founding in 2020 are one-person projects now, so ambition is the correct default — "too much code" is no longer a reason to shrink a concept, and "contribute instead of build" loses weight when building no longer costs a decade. But AI raises the ceiling, not the floor: one human brain still has to verify, decide, and stay motivated, and that is the bottleneck now. The practical rule:

- **Pre-AI methods that rationed *effort* are obsolete.** Relax them without guilt. Phase plans sized by typing speed, "core first, comfort later" as cost control, feature cuts justified only by workload — gone.
- **Pre-AI methods that ration *judgment, verification, and motivation* apply unchanged.** Walking skeleton, ruthless wedge-proof-first sequencing, interfaces before layers. These never existed because of typing speed; they manage risk and morale. Same slices, eaten faster.

**Sequencing rule:** sort features by *dependency on unvalidated decisions* — not by effort, and not by certainty of wanting them. "I definitely want it" is a wish criterion, not a planning criterion.

- Build early: anything behind a stable contract/interface, regardless of where it sits in a classic phase plan.
- Defer: anything that bakes in domain decisions the skeleton hasn't validated yet. Refactoring code is cheap, even free; refactoring *concepts* is expensive, AI or not.

**The walking skeleton stays mandatory.** It was never an effort compromise — it is the planning instrument that tests whether the plan holds. A plan is a hypothesis; good planning without an early end-to-end proof is well-formatted confidence.

When the concept involves forking an existing project, settle the forking strategy (Embrace vs. Decomposition) during conception — consult the fork-stewardship skill; the strategy choice shapes scope, architecture, and long-term maintenance cost.

## Stop-Criteria: When to recommend not building

A short list of patterns that should trigger a "let's not do this" recommendation:

- A healthy, well-maintained open-source project already solves 80%+ of the problem with a compatible license. **Contributing is cheaper than rebuilding.**
- The walking-skeleton cut keeps growing *without proving more* — it accretes features instead of validating the wedge. Per AI-Era Scoping, effort alone is no longer the kill signal; an unbounded skeleton that validates nothing still is. Cut harder, or it's actually multiple projects.
- The user can't name a second user. Hobby projects for one are fine, but be honest about it – it changes the doc/stability/community needs.
- The project's only differentiation from existing tools is "but mine". That's not a USP, that's NIH syndrome.
- The competitive analysis surfaces three or more recently-dead projects in the same niche. The graveyard is telling you something.

Stating these out loud is the job. The user can still say "yeah, I want to build it anyway" – and that's a valid answer when the motive is learning or fun. But the decision should be made with eyes open.

## Output

Every conception pass produces three persistent artifacts – a landscape or inventory, a concept document, and a handoff package. What form each takes, and where it lives, is defined in `references/new-project.md` and `references/feature-in-existing-codebase.md` respectively. The rule that holds for both: the content has to exist somewhere persistent before this skill is "done". Bullets in chat don't count.
