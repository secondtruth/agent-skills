# agent-skills - Information for Coding Agents

A plugin marketplace of Agent Skills, published to claude.ai, Claude Code, Codex and the
skills CLI from one repository. Three plugins — `engineering`, `thinking`, `agent-workflows`
— each a set of skills switched on together.

## How to write the skills themselves

The craft rules live in the `writing-for-agents` skill when it is among your available
skills: context pointers, the information hierarchy, progressive disclosure, leading words,
and the pruning tests that decide whether a line earns its load. This file stays out of that
subject and covers only what is specific to this repository.

`scripts/lint-skills.sh --public` mechanises the parts of those rules that can be checked,
and every skill has to pass it before a pull request:

| Check | Why it exists |
|---|---|
| Description budget, 60 words | The description is an always-loaded context pointer |
| Negation density under 8 % | Steering by prohibition makes the forbidden behaviour more available, not less |
| Personal and private markers | This repository is public; names of private projects belong in the private one |
| `license:` in frontmatter | Every published skill states its terms |
| Siblings named without an availability clause | Each plugin has to work on its own |

That last one is the rule most easily missed. A skill naming a sibling writes "the `x` skill
when it is among your available skills", never a bare reference, so installing one plugin
alone leaves no dangling pointers. The same applies to skills outside this marketplace.

## A version bump touches three manifests

The trap this repository sets. Bumping a plugin means editing all of:

1. `.claude-plugin/marketplace.json` — the entry in the `plugins` array
2. `plugins/<plugin>/.claude-plugin/plugin.json`
3. `plugins/<plugin>/.codex-plugin/plugin.json` — which additionally carries
   `interface.shortDescription`

Missing the third produces a plugin that reports a stale version and description to Codex
while Claude sees the new one. `grep -rn "<old-version>" --include='*.json' .` comes back
empty when the bump is complete. Adding or removing a skill also updates the plugin
description, its keywords, and the README's table.

Validate with `claude plugin validate .` before opening the pull request.

## Releasing

A release is a version bump merged via pull request — adding a skill is a minor bump, a
wording or content fix a patch. Merge by squash; the merge appends the PR number to the
subject, which is where the history's `(#N)` suffixes come from.

## The synced copies are install targets

`scripts/check-drift.sh` compares each skill here with the copy claude.ai has synced to the
machine, reporting SAME, DIFFER or NOT ONLINE. Those copies, and the ones under
`~/.agents/skills/` and `~/.codex/plugins/`, are outputs: edits made there are lost on the
next sync. Every change starts in this repository.
