# Research Sources

Pick sources by what you're trying to find, not by source type. Many queries benefit from combining multiple sources — synthesize across internal, code, and web sources rather than stopping at the first hit.

## Internal Sources (user's own data)

Always check internal sources first when the query could touch the user's own projects, decisions, or documentation.

- **Past conversations**: When the user references something discussed before, or when previous context would improve the answer.
- **The user's knowledge base**: project documentation, specs, planning, notes, drafts. Where it lives and how it is structured is the `knowledge-management` skill's to know when it is among your available skills; otherwise ask the user once and remember the answer.
- **Shared drives**: Internal documents, shared files, organizational content.

## Code & AI Sources

For implementation research, prior art discovery, and "does this exist already?" questions. These are **not** general web search — they target code repositories and AI model registries specifically.

- **GitHub**: Repositories, issues, documentation, existing solutions. First stop for prior art and implementation patterns.
- **HuggingFace**: Models, datasets, spaces. First stop for AI/ML related queries.
- **DeepWiki**: Repository documentation and deep analysis of codebases.

## Web Sources

For current events, general knowledge, external documentation, and anything that changes frequently. Distinct from code/AI sources — use web search for *information about things*, code sources for *the things themselves*.

- **Web search**: News, current events, documentation, general information, fact-checking.
- **Web fetch**: Full content of a specific page when search snippets aren't enough.

## Connectors

Use available MCP servers and connected services when they're the most direct path to the information.

## Source Selection by Scenario

| Scenario | Primary Source | Secondary |
|---|---|---|
| **Internal knowledge** | | |
| The user's documentation, specs, plans, notes, drafts | The knowledge base (`knowledge-management` when available) | Past conversations |
| Historical decisions | Past conversations | The knowledge base |
| **Prior art & implementation** | | |
| "Does this exist already?" | GitHub, HuggingFace | DeepWiki |
| Existing implementations | GitHub | DeepWiki |
| AI models and datasets | HuggingFace | GitHub |
| Repository deep dive | DeepWiki | GitHub |
| **Current information** | | |
| News and current events | Web search | – |
| Latest versions / releases | Package registry (crates.io, npm, PyPI, pkg.go.dev), release notes | GitHub, web search |
| Product behaviour / capabilities | Vendor help center, official docs, release notes | Web search (as signpost only) |
| External documentation | Web fetch of the official docs | Web search |
| Fact-checking claims | Web search (2+ sources) | – |
| **Protocol & spec work** | | |
| Existing RFCs / standards | Web search + Web fetch | – |
| Niche / retro protocols | Web search | GitHub |
| Prior art before designing | GitHub, Web search | HuggingFace |
