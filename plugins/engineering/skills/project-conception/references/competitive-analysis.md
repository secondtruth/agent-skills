# Competitive Analysis Methodology

Read this when running Phase 1, Step 3 of `project-conception`. The goal isn't a market-research report – it's enough structured understanding of the landscape to make a confident go/no-go/pivot/extend decision.

## 1. Purpose & scope

Competitive analysis answers four questions:

1. **Does this already exist?** If yes, in what form, and is it healthy?
2. **What do existing solutions do well, and where do they fail?**
3. **Is there a real gap we can occupy, or are we just adding noise?**
4. **What lessons can we steal from successes and failures?**

It is *not* a sales pitch for the new project. If the analysis says "don't build", that's a successful analysis.

## 2. Taxonomy: types of competition

Map competitors into four buckets. Each tells you something different.

### Direct competitors

Tools that solve the same problem for the same audience in roughly the same way. If the user describes the project in one sentence and another product matches that sentence, it's a direct competitor.

### Indirect competitors

Different approaches to the same underlying problem. Example: if you're building a self-hosted password manager, KeePass (local file) and Bitwarden (server-based) are indirect competitors – same problem, different topology.

### Adjacent competitors

Tools that don't solve the same problem but overlap enough that users might choose them instead. Often the most dangerous category because they're easy to overlook. Example: a custom note-taking app's adjacent competitors include Obsidian *plus* Notion *plus* a folder of Markdown files in Git.

### Dead competitors

Projects that tried this and stopped. The most undervalued category. See §10.

## 3. Where to look

Delegate the search itself to `information-retrieval`. The relevant sources:

- **GitHub** – search by topic + language; sort by stars, also by most-recently-updated to find live ones
- **GitHub Topics** – e.g., `github.com/topics/<keyword>`
- **Hugging Face** – for any ML/AI angle
- **Package registries** – crates.io, npmjs, packagist, pypi, depending on language
- **Awesome-lists** – `github.com/sindresorhus/awesome` and domain-specific ones
- **Hacker News** – `hn.algolia.com` search; check both stories and comments (comments often reveal pain points)
- **Reddit** – `r/selfhosted`, `r/programming`, domain-specific subs
- **Lobste.rs** – higher signal-to-noise for systems/dev tools
- **Product Hunt** – for product framing and positioning language
- **Wikipedia + ACM/arXiv** – for "is there a name for this problem we don't know yet"

Cast wide. The point of this phase is to find things, not to be efficient.

## 4. Dimensions of comparison

For each meaningful competitor, gather:

- **What it does** (one sentence, not their marketing tagline – your interpretation)
- **Who it's for** (real audience, not stated audience)
- **Technical approach** (architecture, stack, key choices)
- **Maturity** (age, version, stability claims)
- **Traction** (see §6)
- **License & business model** (see §7)
- **Strengths** (what they're genuinely good at)
- **Weaknesses** (what users complain about; what's broken or missing)
- **Lessons** (what should we steal, what should we avoid)

Three to five competitors at this depth is usually enough. Don't write essays about each – two or three sentences per dimension is the right resolution.

## 5. Feature matrix template

A simple table comparing the top 3–5 competitors plus the proposed project, across 8–12 features that matter. Keep it markdown so it pastes into any knowledge base cleanly.

```markdown
| Feature                | Us (proposed) | Competitor A | Competitor B | Competitor C |
|------------------------|---------------|--------------|--------------|--------------|
| Self-hostable          | ✅            | ❌           | ✅           | ✅           |
| Active development     | ✅            | ✅           | ⚠️ 2yr stale | ❌ archived  |
| Plugin system          | ✅ core       | ❌           | ⚠️ limited   | ✅           |
| MCP support            | ✅ native     | ❌           | ❌           | ❌           |
| ...                    | ...           | ...          | ...          | ...          |
```

Pick features that:

- Matter to the actual users
- Differentiate the field (a feature everyone has isn't worth listing)
- Surface gaps where the proposed project has an edge

Don't pick features just because the new project happens to have them. That's cherry-picking, and it lies to the user about the landscape.

## 6. Traction signals

A project's health is more informative than its star count. Check, in order:

1. **Last meaningful commit** – not "updated dependency", but actual feature/fix work. <3 months: alive. 3–12 months: slowing. >12 months: probably dead.
2. **Issue velocity** – are issues being closed? Or piling up unanswered for months?
3. **Release cadence** – tagged releases in the last year, or just rolling main?
4. **PR responsiveness** – maintainers reviewing external PRs, or ignoring them?
5. **Star growth shape** – steady growth (healthy) vs. flat-after-spike (HN-driven, never adopted) vs. declining (forgotten)
6. **Fork activity** – are forks living their own lives? Forks of dead projects sometimes become the real successor.
7. **Community signals** – active Discord/forum/mailing list, or ghost town?

A 20k-star project that hasn't merged a PR in 18 months is dead. A 200-star project shipping monthly releases is alive. Stars are vanity; cadence is health.

## 7. License & business-model check

This decides whether you can:

- **Contribute** (instead of competing)
- **Fork** (if the project is dying)
- **Embed** (use as a dependency)
- **Compete in good conscience** (against a company vs. against a community)

Check:

- **License** – MIT/Apache/BSD: maximum flexibility. (A)GPL: viral, plan accordingly. SSPL/BUSL: source-available but commercially restricted. Closed: no embedding option.
- **Business model** – pure FOSS, open-core, hosted SaaS, dual-license, freemium, paid-only. Knowing this tells you who the project is *really* serving and what they'll prioritize.
- **Governance** – single maintainer (bus factor 1), small team, foundation-backed, vendor-controlled. Affects long-term reliability.

If a healthy, well-licensed competitor exists with an active maintainer team, **contributing is almost always cheaper than building**. State this directly in the recommendation.

## 8. USP destillation

After the comparison, write down: **what does the proposed project do that none of the competitors do, or do well?**

Acceptable USPs:

- A real feature gap nobody fills
- A combination of features that exists separately but never together
- A different topology (self-hosted where competition is SaaS, or vice versa)
- A radically different UX for the same capability
- Better integration with a specific ecosystem the user lives in

Unacceptable USPs:

- "It's mine"
- "It's in language X" (unless the ecosystem fit is the actual differentiator)
- "It's simpler" (probably means "less featureful" – not a USP unless tied to a real audience)
- "It's modern" (vague; what does modern mean for this user?)

If you can't write a one-sentence USP after this exercise, the project doesn't have one yet. Either find one or stop.

## 9. Anti-features

Just as important as the USP: **what should this project deliberately not do** that competitors do?

Look at the competitor comparison and ask:

- Which features do competitors include that users actually hate or ignore?
- Which features bloat the competitors and slow them down?
- Which features are bad trade-offs we don't want to make?

Examples: "no auth system, expect to be deployed behind a reverse proxy that handles it"; "no built-in plugin system, use the host language's module loader"; "no GUI, CLI-only".

Anti-features are commitments. They define the project's character as much as its features do. Write them down in the conception doc, not just in your head.

## 10. Dead projects as a goldmine

Archived or abandoned competitors are the most underrated source of intelligence. They contain:

- **What was tried** – maybe your "clever new approach" was tried in 2017 and didn't work
- **Why it died** – check the last issues, the README's "this project is no longer maintained" note, the maintainer's blog post if one exists
- **What was hard** – the issues that piled up unanswered before death often point to the genuinely hard problems
- **Reusable parts** – sometimes the code is still good and just needs a new home

Spend real time in graveyards. A dead project that did 70% of what you want and got tired *is* the warning. Three dead projects in the same niche is a flashing red light.

## 11. Output format

The competitive analysis doc lives in the knowledge base under the new project's page (or a sub-page). Recommended sections:

1. **Summary & recommendation** (top, 3–5 sentences: what we found, what we recommend)
2. **Direct competitors** (one block per competitor, dimensions from §4)
3. **Indirect & adjacent competitors** (briefer, one paragraph each)
4. **Dead projects of note** (what they tried, why they failed)
5. **Feature matrix** (§5)
6. **USP** (one sentence + supporting reasoning)
7. **Anti-features** (bullet list)
8. **Open questions for the conception phase** (things this analysis can't decide alone)

Keep the doc tight enough that the user actually reads it. A 30-page market analysis nobody reads is worth less than a 2-page summary that drives the next decision.
