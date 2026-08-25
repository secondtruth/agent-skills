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
while Claude sees the new one. The bump is complete once the plugin's three version fields
agree. Check them directly rather than grepping the repository for the old number, which
raises a false alarm whenever another plugin still legitimately carries it:

```bash
p=engineering
{ jq -r --arg p "$p" '.plugins[]|select(.name==$p)|.version' .claude-plugin/marketplace.json
  jq -r .version plugins/$p/.claude-plugin/plugin.json plugins/$p/.codex-plugin/plugin.json
} | sort -u          # one line: the three agree
```

Adding or removing a skill also updates the plugin description, its keywords, and the
README's table.

Validate with `claude plugin validate .` before opening the pull request.

## Releasing

A release is a version bump merged via pull request — adding a skill is a minor bump, a
wording or content fix a patch. Merge by squash; the merge appends the PR number to the
subject, which is where the history's `(#N)` suffixes come from.

## Installed copies are outputs

`scripts/check-drift.sh` compares each skill here with the copy **claude.ai** has synced to
this machine, reporting SAME, DIFFER or NOT ONLINE. It takes that directory from
`CLAUDE_SKILLS_SYNC` when the variable is set and discovers it otherwise, and it looks at no
other install path.

The remaining paths — the skills CLI, the Claude Code plugin install, Codex — each write a
copy of their own somewhere else. Every one of them is an output: an edit made in an
installed copy is lost on the next sync, and the drift script stays silent about it. Every
change starts in this repository.
