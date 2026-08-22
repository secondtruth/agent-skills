# agent-skills

Agent Skills by [secondtruth](https://github.com/secondtruth), packaged as a plugin marketplace. Three plugins, each a set of skills you switch on together:

| Plugin | Skills |
|---|---|
| `engineering` | code-craftsmanship, cli-design, service-application-design, product-ui-design, fork-stewardship, spec-writing, project-conception, skill-scouting |
| `thinking` | analytical-lenses, critical-traditions, brainstorming, self-review, roadmap-management |
| `agent-workflows` | handoff-debrief, context-seeding, consolidate-space, ai-entity-creator, information-retrieval, driving-ai-chat-websites, designer-setup |

Skills reference each other and [Matt Pocock's skills](https://github.com/mattpocock/skills) softly — "when the `tdd` skill is among your available skills, …; otherwise …" — so every plugin works on its own.

## Install

- **claude.ai, Claude Desktop, Cowork** (Claude Code inherits): Settings → Plugins → Personal plugins → Add marketplace → `secondtruth/agent-skills`.
- **Claude Code only**: `/plugin marketplace add secondtruth/agent-skills`, then `/plugin install engineering@secondtruth`.
- **Codex**: `codex plugin marketplace add secondtruth/agent-skills`.
- **Any agent via the skills CLI**: `npx skills add secondtruth/agent-skills`.

## Develop

```bash
scripts/lint-skills.sh --public   # writing-for-agents rubric + personal-marker scan
scripts/check-drift.sh            # compare with the copies claude.ai has synced locally
claude plugin validate .          # manifest validation
```

Releases are version bumps in `.claude-plugin/marketplace.json` and the plugin manifests, merged via pull request.

## License

MIT — see [LICENSE](LICENSE).
