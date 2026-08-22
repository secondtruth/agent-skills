---
name: designer-setup
description: Set up Claude Design's org-level design system cleanly — particularly when the user's current production assets don't represent where they want their brand to go. Use this skill whenever the user wants to configure, onboard, or fix a Claude Design organization, asks for help with "the design system setup form", wants to upload brand assets to Claude Design, or mentions that their current Claude Design extraction "looks wrong" or "pulled the wrong colors". Also trigger for phrases like "set up Claude Design for X", "onboard our team to Claude Design", "what should I put in the Claude Design form", or "my design system in Claude Design needs fixing".
---

# Claude Design — Organization Setup

A skill for configuring Claude Design's org-level design system so that extraction produces a design system that actually reflects where the brand should go — not where the current assets happen to be.

Claude Design is Anthropic Labs' generative design tool. During onboarding it reads a team's codebase and design files and builds a reusable design system (colors, typography, components, layout patterns) that it then applies automatically to every subsequent project. The quality of every future output is bounded by the quality of that onboarding extraction.

## The core risk

The form accepts whatever you give it. It does not know whether those assets represent your brand direction or your brand's legacy. **If the current production site, codebase, or Figma file is out of step with where the brand is headed, feeding any of them into the form poisons the extraction.** The resulting design system will be a faithful summary of a brand you are trying to move past.

This is the single most important judgment call in the setup. Before touching the form, figure out whether the user's existing assets and their intended direction agree.

## Workflow

### 1. Gather before asking

Search project files and past conversations for anything that describes the brand direction: a design direction document, a style guide, a brand deck, a manifesto, a color system. Also look for the opposite: the current production site, any recent Figma files, existing GitHub repos. Note which category each asset falls into — **statement of direction** vs. **representation of current state**.

Only ask the user for clarification after this scan. The question you almost always need to resolve is: *do your current production assets reflect the direction you want Claude Design to extract, or is the direction ahead of the assets?*

### 2. Decide the upload strategy

Three cases, in order of frequency:

**Case A — Direction matches production.** The current site, codebase, or Figma file is an accurate representation of the brand. Feed them to the form directly. This is the path the Claude Design docs assume.

**Case B — Direction is ahead of production.** The user has a design direction document, new brand decisions, or a recent rebrand that has not yet been implemented in any production asset. This is common when the setup conversation is itself part of the rebrand. **Do not feed the old assets to the form.** Build a small reference site first (see step 3).

**Case C — No direction exists at all.** Only legacy assets are available and no direction document exists. Warn the user that extraction will encode the status quo. Offer to draft a design direction first, or accept that the resulting system will be a snapshot of the current state.

### 3. For Case B: build a reference site before uploading

Claude Design's own documentation states that finished real examples teach the extraction far more than specs alone. A short reference site — two or three pages, one stylesheet, the real fonts loaded, the real colors in CSS variables, actual UI components (buttons, nav, lists, a pullquote) rendered — gives the extraction concrete material to work from.

Minimum contents for a useful reference site:

- A homepage with a hero, at least one content section, and a footer. This exercises typography hierarchy and the primary surface treatments.
- A longer-form page (manifesto, about, documentation) that exercises prose measure, headings at all levels, and any editorial elements (pullquotes, captions, illustrations).
- A single shared stylesheet with all design tokens as CSS variables. The variable names themselves help extraction — `--fir` is clearer signal than `#3E4D3B` in isolation.
- The real logo in the real colors. If the logo exists as a legacy asset in old colors, recolor it first.
- Real fonts via `<link>` or `@font-face`, not system fallbacks.
- At least one sample of any non-standard element the brand relies on — a custom illustration style, a particular table treatment, a specific button shape.

Keep the reference site small. The goal is density of signal per page, not coverage. Two pages that embody the system fully beat eight pages that use it inconsistently.

**Implementation note for Case B:** if the brand direction document includes an explicit "what we do not do" or anti-pattern list, read it before writing code. These lists often contradict the generic good-practice patterns a frontend-design skill, when active, would otherwise apply (e.g. Inter may be explicitly required even where a "distinctive display font" would normally be preferred). The brand direction wins over generic taste.

### 4. Fill the form

The form has five fields plus a free-text notes area. Below is the mapping that consistently produces the cleanest extraction.

**Company name and blurb.** One or two sentences. Include the organization name, what it does, and — this is the part most users miss — a single aesthetic descriptor. "Quiet, editorial, academic" or "bold, maximalist, high-contrast" tells extraction which direction to resolve ambiguity in. Without this, the extraction will resolve toward the statistical average of the uploaded material, which is rarely what the user wants.

**Link code on GitHub.** Only populate this if the linked repo genuinely represents current brand direction. When in doubt, leave empty. A clean empty field is better than a contaminated extract.

**Link code from your computer.** This is the primary input for Case B. Upload the reference site folder. For Case A, point at the production frontend — or better, a frontend-focused subfolder that isolates component code from unrelated backend/config files.

**Upload a .fig file.** Only if a current, direction-aligned Figma file exists. Old Figma files are as dangerous as old code. The file is parsed locally in the browser and not uploaded to servers, but it still feeds the extraction.

**Add fonts, logos and assets.** The logo, favicon, and the design direction document itself if one exists. Font files are usually not needed — if fonts are linked from Google Fonts or a CDN in the code, extraction picks them up there. Upload custom font files only if they are self-hosted.

**Any other notes?** The most underused field, and the most powerful one. Use it to encode:

- The exact hex values of the palette, with names and roles
- The font stack with weights used
- Spacing and hierarchy rules (line height, measure, how headings distinguish themselves)
- Component constraints (button radius, shadow policy, focus state style)
- **The anti-pattern list.** Extraction handles "do not use" instructions well. Phrases like "no gradients", "no pill-shaped buttons", "no neural network imagery" directly constrain future generation.

Write notes as a structured list with short declarative lines. Prose paragraphs are processed less cleanly than labeled bullets.

### 5. Validate before publishing

Do not turn the Published toggle on immediately. Create a test project first. Useful validation prompts:

- "Design a simple landing page for [a plausible future product]."
- "Create a one-pager explaining [a topic the team actually writes about]."
- "Make a documentation page for [a real spec or API the team maintains]."

Check the output against the direction document. Common extraction failures to watch for:

- **Role inversion.** A secondary color ends up primary, usually because it had more surface area in the uploaded examples than the intended primary.
- **Font default.** Display font is ignored and body font is used everywhere, usually because the display font only appeared on one page.
- **Ghost tokens.** Colors from old assets leak in despite not being uploaded — usually because a legacy file was left in the repo that got linked.
- **Pattern averaging.** Distinctive layout decisions (asymmetry, particular spacing, specific illustration style) get smoothed into generic patterns. This one is hard to fix without better reference material.

If anything is materially wrong, do not republish-and-pray. Use the Remix mode — open the design system in the org settings, click Remix, and correct it in conversation. The chat interface can adjust specific tokens, reassign roles, and tighten constraints without re-uploading anything.

### 6. Publish and document

Once validation passes, enable Published. Tell the user which assets the system was extracted from — they should know what to update if the brand evolves. If a design direction document exists, add a pointer in it to the Claude Design org settings so the link between the source-of-truth text and the extracted system is visible to future readers.

## When to push back

A few patterns where the right answer is to slow down rather than fill the form.

**User wants to upload the current production site, but describes it as "the old look".** Stop. This is Case B in disguise. Build the reference site first.

**User has no design direction document, just vibes.** The extraction will encode the vibes, for better and worse. Offer to draft a short direction document first — even an hour of writing produces notably better extraction than none.

**User wants to set up multiple design systems for sub-brands at once.** Claude Design supports multiple systems per organization. Do them sequentially, not in parallel. Extraction quality is easier to judge one system at a time.

**User wants to skip the reference site because "we'll iterate in Remix".** Technically possible, but Remix is better at refining an 80% extraction than at rebuilding a 30% one. The reference site is cheaper than fighting a bad initial extract for weeks.

## A note on Claude Design itself

Claude Design is in research preview and changes. The setup form layout, the exact fields, and the extraction behavior may have shifted since this skill was written. If a field described here doesn't exist in the form the user is looking at, or a new field appears, check the current docs at `https://support.claude.com/en/articles/14604397` and adapt. The principles — feed the brand you want, not the brand you have; use a reference site for Case B; validate before publishing — are stable regardless of form details.
