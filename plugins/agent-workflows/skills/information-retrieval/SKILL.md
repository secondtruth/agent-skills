---
name: information-retrieval
license: MIT
description: Source rules for any research, lookup or fact-check — primary sources first, registries for versions, secondary sources as signposts only, cite everything. Use on any "research X", "does Y support Z", "what is the current version or behaviour of …", and whenever an answer depends on information newer than training data.
---

# Information Retrieval

## Core Principle

Gather current information before answering whenever it would change the answer. The user expects well-informed answers, not hedged guesses followed by "shall I look that up?"

## When to Proactively Research

Research is warranted in these situations – not just when explicitly asked:

1. **Fast-changing information**: Current events, recent developments, latest versions, trending topics. Anything where "as of my last update" would be a cop-out.
2. **Programming**: New libraries, framework updates, best practices, debugging obscure errors, API changes.
3. **Project planning**: Prior-art checks before building belong to the `project-conception` skill when it is among your available skills; this skill supplies the source rules it uses. Without it, check what already exists on GitHub, HuggingFace, or elsewhere and **warn the user if a similar project or feature already exists** – with links.
4. **Protocol & spec work**: Before designing a new protocol or spec extension, research existing RFCs and prior art, including niche and retro protocol communities.
5. **Technical writing**: Verify facts, find authoritative sources, check current specifications and documentation.
6. **Content creation**: Audience trends, cultural context, comparable content, fact-checking claims before publishing.

## Sources

For the full source hierarchy (internal, code/AI, web, connectors) and when to use which, read `references/research-sources.md`. Where the user's own material lives is the `knowledge-management` skill's to know when it is among your available skills.

When the `research` skill is among your available skills and the user wants a topic investigated and written up, dispatch it and apply the source rules below inside it; otherwise research inline and cite sources in the reply.

## Research Quality Standards

- **Compile across sources.** When a question touches multiple domains or knowledge bases, synthesize from internal, code, and web sources rather than stopping at the first hit. A complete picture often requires combining what the user already has with what exists externally.
- **Always cite sources.** List what was used and why. No anonymous knowledge drops.
- **Prefer primary sources.** Official documentation > blog posts > forum answers > AI-generated summaries. For product/API questions this is not a preference but a rule – see below.
- **Cross-reference.** If a claim matters, verify it from at least two independent sources.
- **Date-stamp.** Note when information was published/updated – a 2022 tutorial for a fast-moving framework may be outdated.
- **Acknowledge gaps.** If something can't be verified or found, say so clearly rather than filling in with assumptions.

## Primary Sources for Product, API and Version Questions

For anything about **product behaviour, APIs, versions, or capabilities**, read the primary source. Always:

- Official help centers and vendor documentation
- Release notes and changelogs
- RFCs and published specifications
- Package registries – crates.io, npm, PyPI, packagist, docs.rs, pkg.go.dev

Secondary sources – blog posts, roundups, summaries, news articles, "what's new in X" pieces – are **signposts only**. Use them to find out *that* something changed and *where* the primary source is. Never let them be the basis of an answer.

**Why, concretely:** secondary sources lag. In August 2026 blog posts were still describing the older Tools menu in the ChatGPT composer, while the official release notes had long since documented the split into Chat, Work and Codex. Anyone reading only the blogs was building on a superseded model of the product – and every downstream conclusion inherited that error.

Two rules that follow from this:

- **A 403 is not a reason to give up on the primary source.** When a page blocks automated fetching (HTTP 403 – `help.openai.com` and `openai.com` are frequent offenders), read it with a browser tool. Falling back to secondary sources because the primary one was inconvenient is the failure mode this section exists to prevent. If the page genuinely cannot be reached, say so explicitly instead of quietly substituting a blog post.
- **Verify existence and version against the authoritative registry** before building on a claim that a package, crate, module or tool exists. "The library X handles this" is a claim, not a fact, until crates.io / npm / PyPI / pkg.go.dev confirms it – along with the current version and whether it is still maintained.

## After Research: Consider Documentation

If research produces substantive results that belong in the user's knowledge base (new project concepts, significant findings, design decisions), the `knowledge-management` skill, when it is among your available skills, handles documentation in the user's knowledge base. This skill stays focused on finding information; that skill handles persisting it.
