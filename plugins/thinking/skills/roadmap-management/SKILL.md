---
name: roadmap-management
license: MIT
description: Plan and prioritize a product roadmap — pick the format (Now/Next/Later, quarterly themes, OKR-aligned, timeline), score initiatives (RICE, ICE, MoSCoW, value/effort), map dependencies, fit capacity, and communicate changes. Use when creating or reprioritizing a roadmap or presenting its tradeoffs.
---

# Roadmap Management

Input: a concept package from the `project-conception` skill (problem, scope, MVP cut, risks, dependencies) when one exists; otherwise elicit the initiative list first. Record the result where the user tracks work — their issue tracker or knowledge base, through the `lodestar` or `knowledge-management` skill when one is among your available skills; otherwise deliver the roadmap inline.

## Steps

1. **Gather** the initiatives, the constraints (team size, period, fixed dates) and what the roadmap is for — execution planning or communication.
2. **Pick the format and the scoring framework** from the tables below; say why.
3. **Score, map dependencies, check capacity.** Every initiative gets a bucket and a score or a stated rationale; every dependency gets an owner and a need-by date.
4. **Deliver** the roadmap plus what was cut and why.

Done when every initiative has a bucket, a score or rationale, and its dependencies named — and the total fits the capacity.

## Formats

| Format | Use when |
|---|---|
| **Now / Next / Later** — committed / planned / directional | Most teams, most of the time; communicating outward without false date precision |
| **Quarterly themes** — 2–3 investment themes per quarter, initiatives beneath | Showing strategic alignment to leadership |
| **OKR-aligned** — initiatives listed under the Key Result they move, with expected impact | Organisations that run on OKRs |
| **Timeline / Gantt** — dates, durations, parallelism | Execution planning with engineering; internal only, dates read as promises outside |

## Scoring

| Framework | Formula | Use when |
|---|---|---|
| **RICE** | (Reach × Impact × Confidence) / Effort, with Impact 3/2/1/0.5/0.25 and Confidence 100/80/50 % | A large backlog needs a defensible, quantitative order; weak for strategic bets whose impact resists estimation |
| **ICE** | Impact × Confidence × Ease, each 1–10 | Quick ordering with little data; early-stage products |
| **MoSCoW** | Must / Should / Could / Won't | Scoping a release or quarter with stakeholders; the *Won't* list is the one that prevents sprawl |
| **Value vs. effort** | 2×2: quick wins first, big bets scoped carefully, fill-ins on spare capacity, money pits removed from the backlog | Building shared understanding in a planning session |

## Dependencies

Technical, team, external, knowledge, sequential. Each one is listed, owned, dated, and buffered — dependencies are the highest-risk items on any roadmap, cross-team ones most of all. Reduce them before managing them: a simpler version that avoids the dependency, an interface contract or mock that lets work run in parallel, a resequencing that pulls the dependency forward, or absorbing the work into the team.

## Capacity

Engineers × period, minus meetings, on-call, interviews, holidays and ramp-up; plan on 60–70 % of time for planned work. A healthy split is **70 % planned features / 20 % technical health / 10 % unplanned** — shifted toward features for a new product, toward reliability for a mature one or after an incident, toward scalability in rapid growth. When commitments exceed capacity, cut scope; adding an item to the roadmap means naming what comes off.

## Communicating changes

Change the roadmap only past a threshold — a new strategic priority, research that reorders priorities, a technical discovery, a dependency slip, a resource change, a competitive move — and batch updates monthly or quarterly otherwise. Distinguish a roadmap change (strategic reprioritisation) from a scope adjustment (normal execution refinement). When communicating a change: name what changes and why, show the tradeoff (what was deprioritised or slips), show the new plan, and tell the affected stakeholders directly. Frequent changes signal unclear strategy rather than responsiveness.
