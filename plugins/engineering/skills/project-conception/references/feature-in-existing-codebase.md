# Conception for a Feature or Subsystem in an Existing Codebase

The path reference for a feature, module or subsystem going into a codebase that already exists. `SKILL.md` holds the shared parts – research delegation, the Phase 2 essentials, the Phase 1 verdict, risks/dependencies/open questions, AI-Era Scoping, Stop-Criteria.

Naming, umbrella fit, stack decision and doc strategy do not apply here. All four are inherited from the host project – don't re-litigate them.

## Phase 1: Survey the existing surface

Instead of an external landscape, take inventory of what the codebase already offers. Read the code – do not ask the user to summarize their own repo. Sort what you find into three buckets:

- **Exists and works** – implemented, wired up, has real callers.
- **Stub** – the function, route, handler or command exists and returns a placeholder, an error, or nothing.
- **Declared without consumers** – types, interfaces, protocol messages, events, config keys, DB columns that are fully defined in code and referenced by nobody.

**The check that keeps paying off:** a contract can sit fully declared in the code and still have zero callers. Grep for its consumers *before* redesigning it. Declared-but-unwired usually means unfinished, not dead – and unfinished means most of the work is already done and only the wiring is missing. Rewriting such a contract from scratch is the single most common way to burn a weekend on this kind of work.

Phase 1 still ends with a verdict, in this path's form: **already solved / needs wiring only / worth building**.

One external check still pays off: is there a library that already does this, so the feature becomes an integration rather than an implementation?

## Phase 2: Map the target design onto the inventory

Scope works differently here than for a new project – no in-scope/out-of-scope lists. Produce the target design, then split it against the Phase 1 inventory into exactly three categories:

1. **Already there** – reuse as-is; state explicitly that it is not being redesigned.
2. **Needs wiring** – the pieces exist, they are not connected. Usually the cheapest and largest bucket.
3. **Needs building** – genuinely missing.

This split *is* the scope; it replaces the in-scope/out-of-scope lists. It is also what makes the estimate honest: without it, "needs wiring" work gets quoted as "needs building" work and the plan is wrong by an order of magnitude before it starts.

## Phase 3: Handoff

The handoff lands in the repo, not in the knowledge base:

- **A concept document in the repo**, not only in the knowledge base. It belongs next to the code it describes, where it gets reviewed in diffs and rots visibly instead of silently.
- **Tracked issues**, cut along the three categories from Phase 2.
- **Phases with explicit dependencies between them.** Not just an ordered list – state which phase blocks which and why. Phases without stated dependencies degrade into wish lists the moment something slips.

## Output

1. A **surface inventory** – exists / stub / declared-without-consumers (Phase 1)
2. A **concept document in the repo** with the three-way scope split, MVP cut and architecture sketch (Phase 2)
3. **Tracked issues in phases with explicit dependencies** (Phase 3)

Let `knowledge-management`, when it is among your available skills, decide whether the concept also needs a counterpart in the knowledge base – the repo copy is the primary one.
