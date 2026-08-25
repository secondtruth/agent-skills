---
name: style-pass
license: MIT
description: >-
  Sweep a rendered UI for style defects and fix them: spatial audit, token
  drift, cause-and-layer diagnosis for whatever survives, then the pre-ship
  gate. Use when the request is broad — "check the styling", "polish this",
  "does the look hold together" — rather than aimed at one known defect.
disable-model-invocation: true
---

# Style Pass

Five skills each own a slice of visual correctness. This one owns the **order**, which carries knowledge none of them has alone: a yardstick has to exist before conformance means anything, and causation only pays off on findings that survive the audit.

Work the steps in sequence, skipping any whose subject the surface lacks. Each step names the skill that does the work — reach for it when it is among your available skills, and fall back to the note beneath it otherwise.

1. **Establish the yardstick and audit the spatial layer** — the `spacing-rhythm-auditor` skill. Its first phase finds the project's own spacing system, or derives one when none exists, then reports scale conformance, proximity, container consistency, alignment and responsive compression. Everything downstream measures against what it establishes, so it goes first even when the complaint sounds unrelated to spacing. *Without it:* read the scale from the design tokens or the framework config yourself, then compare rendered values against it.

2. **Scan the non-spatial drift** — the `audit-design-tokens` skill, for raw hex colours, font sprawl, hardcoded z-index and near-duplicate values across the codebase. This covers the axes step 1 leaves alone. *Without it:* grep the stylesheets for literal colour values and compare them against the palette tokens.

3. **Diagnose what survives** — the `layout-forensics` skill when it is among your available skills, for each finding whose value looks right, or whose source is unclear, or that reappears after a fix. It settles which rule in which stylesheet sets the value, whether the rule exists at all, and which layer of the stack owns the correction. Findings with an obvious local cause skip this step. *Without it:* walk `document.styleSheets` for rules matching the element, and place the fix at the level whose consumers all share the defect.

4. **Run the gate** — the `design-qa` skill: component states, WCAG contrast, touch targets, breakpoints, keyboard paths, fail-closed. This is the step that decides shippability, so it runs after the corrections rather than before. *Without it:* check contrast ratios against 4.5:1 for body text and 3:1 for large text and non-text UI, and confirm every interactive element is reachable by keyboard.

5. **Ask for judgement when correctness leaves the question open** — the `design-review` skill, for whether the result is *good* rather than *correct*. Reach for it when the original complaint was about quality, or when steps 1 to 4 came back clean and the surface still reads as off. *Without it:* say plainly that the measurable checks pass and name what still bothers you about the composition.

## Reporting

Deliver one merged report rather than five, since the same underlying habit tends to surface in several steps: values off the scale in step 1 and raw hex in step 2 are usually one team convention that drifted. Lead with the two or three systemic causes, list the individual findings beneath them with location and current-to-proposed values, and close with what a person still has to decide.

Corrections follow the audits and stay separated from them: report first, apply on approval, then re-measure. Where the pass touched a design system that other sites consume, say which of its consumers inherit the change.
