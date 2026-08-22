---
name: web-compliance
license: MIT
description: >-
  Make a website legally compliant for the German-speaking market and the EU:
  Impressum per legal form and country (DE/AT/CH), consent with
  orestbida/cookieconsent v3 that blocks scripts until opt-in, and a
  Datenschutzerklärung derived from the third-party services the code really
  loads. Use when building, auditing or fixing Impressum, cookie banner,
  DSGVO/GDPR or privacy-policy aspects of a site.
---

# Web Compliance

The legal duties of a website in Germany, Austria, Switzerland and the wider EU are stable enough to encode, and specific enough that a generic attempt gets them wrong: a banner that shows while Google Analytics already fired, an Impressum citing a repealed statute, a privacy policy that names services absent from the site and omits the ones it loads. This skill turns those duties into engineering work.

Your edge over a template generator is that you can read the code. Every obligation below follows from an **inventory of what the site actually does** — which scripts load, which hosts are contacted, which forms collect data. Build the inventory first; everything else derives from it.

**Stand: 2026-08.** Law moves (TMG became DDG and TTDSG became TDDDG in May 2024; the EU ODR platform closed on 2025-07-20; BFSG applies since 2025-06-28; AI Act Art. 50 since 2026-08-02). When a detail matters, verify against the primary source (gesetze-im-internet.de, ris.bka.gv.at, fedlex.admin.ch, the DSK guidance) before relying on the tables in `references/`. This skill produces technically correct implementations and complete inventories; it is no substitute for legal advice, and says so in its output when the case is beyond the standard patterns listed under "Out of scope".

## Workflow

1. **Triage.** Settle the facts that decide which duties apply — from the code, the repo docs, or by asking:
   - *Operator:* private and non-commercial, or geschäftsmäßig (any ads, affiliate links, business presentation, or paid offer makes it geschäftsmäßig)? Legal form? Seat country?
   - *Audience:* consumers (B2C)? Other EU countries (language switch, shipping)?
   - *Content type:* journalistic-editorial content (blog with opinion pieces, news) → extra responsible-person duty. Regulated profession (doctor, lawyer, tax adviser, architect …) → chamber and professional-title duties. Online shop or bookings → consumer-law duties beyond this skill.
   - *Tech:* static site, SPA, CMS, shop system; where the `<head>` and layout live.

2. **Inventory.** Grep the repository for third-party signals using the table and command block in `references/third-party-services.md`. Record every hit as a row: service · purpose · what it stores or contacts before any interaction · consent category · privacy-policy section. Include server-side processors too (hosting, mail provider, payment, error tracking, database-as-a-service) — they are recipients under Art. 13 even without a cookie.

3. **Reduce before you consent.** For each row, ask whether a leaner option removes the duty: self-hosted fonts instead of Google Fonts, a cookieless analytics tool instead of GA4, `youtube-nocookie.com` behind a two-click placeholder instead of a live embed, a bundled library instead of a CDN script. The best consent banner is the one a site has made unnecessary; many brochure sites end up with zero consent-requiring services after this step.

4. **Consent layer** — only for what remains. Implement with orestbida/cookieconsent v3 per `references/consent.md`: self-hosted, categories mapped from the inventory, every optional script blocked via `type="text/plain" data-category="…"`, reject as prominent as accept, a withdrawal link in the footer.

5. **Documents.** Write or fix the Impressum from `references/impressum.md` and the Datenschutzerklärung from `references/privacy-policy.md`, section by section from the inventory. Facts you cannot read from the code (register number, VAT ID, chamber, the data-protection officer) become `TODO:` placeholders — and a page with a placeholder is a draft: it stays unpublished, or the existing page stays live, until the operator supplies the value. Guessing is worse than a gap; publishing the gap is worse than waiting.

6. **Verify.** Run the checklist at the end of `references/consent.md` in a browser: network tab before any interaction, after reject, after accept, after withdrawal. Confirm both legal pages are reachable from every page within two clicks and are labelled `Impressum` and `Datenschutz`/`Datenschutzerklärung`. Grep the legal pages for `TODO` — go-live needs zero hits. Then report what was implemented, what remains `TODO` (and therefore blocks publishing), and which points need counsel.

## Hard rules

These are where real banners and real Impressums fail. Treat them as invariants of any implementation you deliver.

- **Before opt-in, only strictly necessary storage runs.** Every optional script is inert until its category is accepted — implemented as blocking, never as "load, then delete cookies afterwards". Network requests to analytics, font, map, video and social hosts before interaction are the failure signal.
- **Reject is as easy as accept.** Both on the first layer, same size and weight (`equalWeightButtons: true`), checkboxes start unticked, closing the modal means reject, scrolling means nothing.
- **Withdrawal is one click away** from every page: a footer control that reopens the preferences modal (`data-cc="show-preferencesModal"`), and rejecting a category clears its cookies (`autoClear`).
- **The consent tool itself is self-hosted.** A consent script pulled from a CDN contacts a third party before consent exists.
- **Impressum and Datenschutzerklärung are HTML pages**, linked from every page under exactly those labels, reachable within two clicks — hidden under "Kontakt" or "Über uns" or delivered as PDF has been the subject of Abmahnungen.
- **Cite current statutes.** `§ 5 DDG` (DE Impressum), `§ 25 TDDDG` (DE consent), `Art. 13 DSGVO` (privacy information). The ODR-platform link belongs in the Impressum of 2024, removed in 2026.
- **The privacy policy names exactly the inventory.** Every service the site loads or forwards data to appears with purpose, legal basis, recipient and third-country status; services the site dropped in step 3 disappear from the text.
- **Unknown facts stay visible as `TODO` in the draft**, with a one-line note on where the operator finds the value — and the draft goes live only once the last `TODO` is gone.

## Out of scope — say so and point onward

- **Shops and bookings:** Widerrufsbelehrung, Button-Lösung (§ 312j BGB), Preisangaben, AGB, Lieferzeiten. Name the duty, recommend counsel or the shop system's compliance module.
- **Newsletters:** double opt-in, § 7 UWG, the advertising-consent wording. Implementation belongs to the mail tool; the privacy section is covered here.
- **Accessibility (BFSG, since 2025-06-28):** applies to B2C e-commerce and services above the micro-enterprise threshold; WCAG 2.1 AA via EN 301 549. Flag applicability; the implementation is UI work (the `product-ui-design` skill when it is among your available skills).
- **AI transparency (AI Act Art. 50, since 2026-08-02):** chatbots disclose that they are AI; synthetic media is labelled. Flag it when the inventory shows a chat widget or generated imagery.
- **Consent-or-pay ("Pur-Abo") models, employee data, health data, minors:** counsel.

## Tooling and alternatives

Two MIT-licensed projects cover the *audit* side and are worth running as an independent check of your work:

- [website-recht-check](https://github.com/alexaltovate/website-recht-check) — `scripts/check.py <url|path>` scans a live site or a repository; `--deep` drives a headless browser and proves whether tracker hosts are contacted before any interaction, plus an axe-core accessibility pass. Its `references/` hold dated summaries of DDG, TDDDG, BFSG and AI Act duties.
- [deutsches-recht-mit-claude](https://github.com/waldo-van-der-code/deutsches-recht-mit-claude) — the `legal-audit` skill greps a codebase for processors, compares detected hosts with the ones the privacy policy discloses, and drafts a VVT (Art. 30). Pairs with the [rechtsinformationen-bund-de MCP](https://github.com/wolfgangihloff/rechtsinformationen-bund-de-mcp), which fetches live statute text from the federal legal portal — use it when you need to quote a paragraph rather than paraphrase it. Parts of the detection table in `references/third-party-services.md` are adapted from this project.

For complete legal texts beyond the inventory-driven sections, the operator is better served by a maintained generator (Datenschutz-Generator by Dr. Schwenke, eRecht24) than by prose you write; your job is to make sure the generator's answers match the inventory.

## Reference files

- **`references/impressum.md`** — required fields for Germany (§ 5 DDG, § 18 MStV, § 36 VSBG), Austria (§ 5 ECG, § 14 UGB, § 25 MedienG) and Switzerland (Art. 3 UWG), by legal form; placement rules; a German skeleton with placeholders; the errors that trigger Abmahnungen.
- **`references/consent.md`** — when a banner is needed at all; the cookieconsent v3 recipe (install, config, script blocking, embeds, withdrawal, revision, consent records, SPA notes); the verification checklist.
- **`references/privacy-policy.md`** — Art. 13 structure, the section-per-service mapping, legal bases, third-country transfers, rights block, retention; a German heading skeleton.
- **`references/third-party-services.md`** — detection signals, pre-consent behaviour, category, disclosure and leaner alternative for the services found on most sites; the grep block for the inventory.
