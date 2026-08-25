---
name: skill-scouting
license: MIT
description: Discover, evaluate, and acquire existing skills before writing a new one. Use whenever the user wants a new skill or workflow capability, asks whether a skill for X already exists, wants inspiration for how others structure skills in a domain — and as the first step of writing any new skill.
---

# Skill Scouting

Explore what already exists before building — the skill ecosystem is large enough that "someone already wrote this" is the default assumption, not the exception. Scouting costs minutes; a from-scratch skill costs an evening plus maintenance forever.

## The loop

1. **Name the capability**, not the implementation: "sync a fork with upstream", not "git skill". Two or three phrasings — the ecosystem's vocabulary may differ from the user's.
2. **Search the sources** (below), broad first, then narrow.
3. **Evaluate candidates** against the checklist.
4. **Decide:** adopt, adapt, reference, or build.
5. **Record the verdict** — where the repo keeps decisions (`docs/adr/` when present, else the project notes): what was found, which verdict, why.

## Sources, in order of yield

When the `find-skills` skill is among your available skills, run its search first — the skills.sh leaderboard, then `npx skills find <terms>`; its install-count ranking is a discovery order, not a verdict. Without it, or after it, work the sources below.

1. **GitHub topics** — the richest vein. Query the API directly (no auth needed for search):
   ```bash
   curl -s "https://api.github.com/search/repositories?q=<terms>+topic:claude-skills&per_page=10"
   ```
   Useful topics: `claude-skills`, `claude-code-skills`, `agent-skills`, `skill-md`. Combine `topic:` filters with free-text terms; sort by stars for maturity, by updated for liveness.
2. **Anthropic's own collection** — `anthropics/skills` on GitHub: reference-quality, conservative scope.
3. **Curated collections and awesome lists** — repos like `glebis/claude-skills` (~100 skills) and `awesome-claude-skills` lists; browse the category index rather than searching blind.
4. **Marketplaces and CLIs** — SkillsMP, Praxl, the `skills` CLI (`npx skills`), plugin marketplaces (`claude plugin marketplace`). Good for discovery breadth; quality varies wildly.
5. **General web search** — catches blog-published skills and gists the platforms miss.

## Evaluating a candidate

Fetch the raw SKILL.md and read it — never judge by repo name or README marketing:

```bash
curl -s "https://raw.githubusercontent.com/OWNER/REPO/main/SKILL.md"
```

Checklist:

- **Philosophy fit** — does its approach match how you actually work? A skill can be well-made and still wrong for you (e.g. a fork-sync skill that forbids merging when you want merge-based history). Philosophy mismatch is the most common rejection reason and the least visible from the description.
- **Scope fit** — covers the whole capability or one slice? A slice can still be worth referencing.
- **Quality signals** — clear trigger description, concrete workflow steps, bundled scripts that actually run, restrained length. Stars matter less than content; a 1-star skill can be excellent and a popular one bloated. Treat a discovery tool's popularity cut-offs as ordering, and still read the body.
- **Dependencies** — does it assume Claude Code specifics (subagents, hooks, `claude -p`), certain CLIs, or API keys that don't exist on the target surface?
- **License** — for adapt decisions, check the repo license; retain attribution when reusing substantial content.

## The four verdicts

- **Adopt** — install as-is (`npx skills add <owner/repo@skill>` where the skills CLI is available). Rare; requires philosophy, scope, and surface fit.
- **Adapt** — take the skeleton, rewrite for your conventions. This is a Decomposition-style fork of a skill (the term is the `fork-stewardship` skill's, when it is among your available skills): one-time extraction, aggressive refactoring, attribution retained, no upstream duty.
- **Reference** — build your own, but cite the found skill inside it as alternative tooling and state when its philosophy wins. Preserves the research for future readers.
- **Build** — nothing found or everything mismatched. Write it with whichever of the `skill-creator` and `writing-for-agents` skills are among your available skills: they compose rather than compete, one supplying the draft-test-evaluate loop and the description optimiser, the other the craft rules the draft is graded against. A found skill is a candidate, not a default: if it loses to what you would build, build.
