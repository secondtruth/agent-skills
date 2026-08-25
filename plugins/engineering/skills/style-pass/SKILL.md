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

Five skills each own a slice of visual correctness. This one owns the order.

1. **Spatial audit** — the `spacing-rhythm-auditor` skill. Establishes the project's spacing system, then measures against it. First, because everything downstream needs that yardstick.
2. **Token drift** — the `audit-design-tokens` skill, for the colour, type and z-index axes step 1 leaves alone.
3. **Causation** — the `layout-forensics` skill when it is among your available skills, for findings whose source or owning layer is unclear, or that return after a fix. Findings with an obvious local cause skip it.
4. **The gate** — the `design-qa` skill. After the corrections, so it judges the corrected surface.
5. **Judgement** — the `design-review` skill, when the measurable checks pass and the surface still reads as off.

Skip a step whose subject the surface lacks. When a step's skill is missing, do what you can by hand, then report that step as partial and name the skill that would complete it — substituting for it wholesale duplicates work these skills already do well.

## Phases

**Audit** (steps 1–3, findings only) → **report and approve** → **apply** → **re-measure and gate** (step 4). A delayed approval pauses the pass after the report; the gate waits for the corrections either way.

One merged report rather than five: the same drifted convention usually surfaces in several steps. Lead with the systemic causes, list findings beneath them with location and current-to-proposed values, close with what a person still has to decide. Where the pass touched a design system other sites consume, say which consumers inherit the change.
