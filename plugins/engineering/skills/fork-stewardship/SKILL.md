---
name: fork-stewardship
license: MIT
description: Manage forks of third-party projects over their whole lifecycle — choosing a forking strategy (Embrace vs. Decomposition), setting up fork/upstream branch topology, watching upstream for relevant changes, syncing and backporting upstream commits, maintaining a divergence ledger, and deciding what to contribute back. Use whenever the user plans, creates, or maintains a fork of an existing repository, mentions syncing with upstream, backporting, cherry-picking upstream fixes, watching an origin project, or asks whether to fork at all. Also trigger when a project in discussion is known to be a fork (e.g. a "*-fork of X" project) and work touches its relationship to upstream.
---

# Fork Stewardship

Forking is not a one-time `git fork` click — it is a relationship with an upstream project that must be chosen deliberately and maintained operationally. This skill covers both: the strategy decision and the ongoing stewardship.

## Two strategies (decide first, once)

Every fork follows one of two strategies. Naming it explicitly — in the README, in the divergence ledger, and as an ADR under `docs/adr/` where the repo keeps them — is the single highest-leverage act of fork management, because every later decision (branch topology, sync cadence, refactoring license) follows from it.

### Embrace

The fork adopts upstream largely unchanged and extends it: *upstream plus extras*. Compatibility is a goal; upstream updates are merged regularly.

- **Use when:** upstream meets ~90% of requirements, but specific features or customizations are missing that upstream would not accept.
- **Consequences:** regular synchronization, minimal changes to core code, extensions preferably via plugins/hooks/adapters, long-term maintenance planned.

### Decomposition

The fork extracts a subcomponent from a larger project and develops it as a standalone, lightweight library. The connection to upstream is deliberately severed.

- **Use when:** a monolithic project contains a useful component burdened with baggage; isolate, refactor, release independently.
- **Consequences:** one-time extraction, aggressive refactoring allowed, reduction to core functionality, no upstream compatibility.

The strategy choice belongs to project conception (the `project-conception` skill, when it is among your available skills); everything below is operations.

## Embrace operations

### Branch topology

- `upstream` remote → the origin project; `origin` → the fork.
- Keep a pristine mirror branch (`upstream-main`) that only ever fast-forwards from upstream. Never commit to it.
- The fork's `main` carries upstream plus the fork's changes. Sync = merge `upstream-main` into `main`.
- Prefer **merge over rebase** for the long-lived fork branch: merges preserve traceable sync points and don't rewrite published history. Rebase is for short-lived feature branches only.
- Keep the fork's own changes as a *reviewable set*: few, coherent commits or clearly bounded modules — not scattered edits across upstream files. Every upstream file touched directly raises the cost of every future merge.

### The divergence ledger (FORK.md)

Maintain a `FORK.md` at the repo root listing **every deviation from upstream**: what was changed, where, and why. One line per deviation, linked to commits or modules.

- It is the merge map: during sync conflicts, the ledger tells you which side is intentional.
- It is the honesty check: a ledger that grows every week signals the fork is drifting toward a rewrite — re-examine the strategy.
- It is the contribution queue: entries marked "upstream might accept this" are PR candidates.

### Sync ritual

1. Fetch upstream; fast-forward `upstream-main`.
2. Read what came in *before* merging: release notes, `git log --oneline upstream-main..`, security advisories first.
3. Merge into `main`. When the `resolving-merge-conflicts` skill is among your available skills, run it with the ledger as the intent source for the fork's side; without it, resolve hunk by hunk by intent with the ledger as the map, never by taking one side wholesale.
4. Run the smoke tests / build.
5. Update the ledger if the merge changed any deviation.
6. Record the sync (date, upstream ref) — a `Synced-Upstream:` trailer in the merge commit works.

Cadence: match upstream's release rhythm — per release for released projects, monthly for rolling ones. Never let more than one major release accumulate; merge debt compounds faster than code debt.

**Conflict budget as health metric:** track roughly how long each sync takes. A rising trend means the fork is patching where it should be extending — refactor deviations into plugin/adapter form, or accept the drift consciously and downgrade sync ambitions.

### Selective backporting

When full sync is not wanted (e.g. upstream moved in an unwanted direction), backport selectively:

- `git cherry-pick -x <hash>` — the `-x` records provenance in the commit message.
- Priority order: security fixes → data-integrity bug fixes → bug fixes in code the fork actually uses → features.
- A fork that stops full-syncing must *still* watch upstream for security fixes; that duty never expires while the shared code runs in production.

### Watching upstream

Watching is a prerequisite for both syncing and backporting. Cheap, automatable sources:

- Releases feed: `https://github.com/OWNER/REPO/releases.atom` (also `commits/BRANCH.atom`, `tags.atom`).
- `gh api repos/OWNER/REPO/releases --jq '.[0].tag_name'` or `gh release list` for scripted checks.
- GitHub security advisories for the repo and its ecosystem.
- **Maintainer health:** commit frequency, open-PR backlog, bus factor. A single-maintainer upstream is a strategic risk — watch for slowdown, and keep the fork in a state where adopting orphaned upstream duties (or full Decomposition) remains possible.

Automate the check into an existing routine (scheduled agent task, CI cron) rather than relying on memory; the output should be a short digest of "new upstream activity relevant to our deviations", filtered through the ledger.

## Decomposition operations

- Extract **with history** where feasible: `git filter-repo --path <dir>` (or `git subtree split`) preserves attribution and archaeology.
- Retain upstream's license and copyright notices; state the origin in the README ("extracted from X at commit …"). License obligations survive the severing.
- Rename thoroughly (module paths, namespaces, branding) *immediately* — lingering upstream names invite accidental re-coupling.
- After severing, upstream is a former project, not a remote: no `upstream` remote, no sync duty. Watching upstream is optional and one-directional (idea mining only).

## Existing tooling

The community skill `dris1153/upstream-sync` (GitHub) takes a different philosophy: never merge — extract upstream diffs, evaluate each change, and re-apply by editing files directly. That fits **heavily diverged forks where merge is hopeless** and the fork's own commit history must stay clean. For disciplined Embrace forks, merge-based sync above is cheaper and keeps provenance; switch to diff-reapply only when the conflict budget says merging has failed.
