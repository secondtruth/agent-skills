---
name: layout-forensics
license: MIT
description: >-
  Find the cause behind a rendered-UI defect: which rule in which stylesheet
  sets a value, which cascade layer should own the fix, whether the rule exists
  at all, and which non-spacing culprits produce spacing symptoms. Use when a
  visual bug survives the obvious fix, or when a design system and the sites
  consuming it disagree.
---

# Layout Forensics

A spacing audit tells you a value is wrong. This skill tells you **where the value comes from and where the fix belongs** — the two questions that decide whether a defect stays fixed or returns in the next component.

Reasoning from the screenshot alone sends you to the wrong file, because one symptom fits several causes:

- Icons that read as *too small* could be a font the browser rejected, drawing every glyph as a fallback box.
- A button *a few pixels too high* could be a blanket bottom margin on every button in the framework: centring aligns the margin box, so the visible box rides up by half of it.
- A wedge that renders *black* could be a utility class the framework never generated, leaving `fill` at its initial value.

Every one of those also fits a simpler reading — an icon sized wrong, an alignment property missing, a colour value mistyped — and the simpler reading comes with a fix that removes the symptom while the cause stays behind to surface elsewhere. Measurement is what tells the two apart, which is why each question below ends at a number or a named rule rather than an impression.

## The four questions

Work them in order. The first answer that lands redirects the rest.

### 1. Which rule sets this value?

Walk the loaded stylesheets and collect every rule that matches the element and touches the property. This converts "the margin is 16px" into "*this* selector in *this* file sets it", and it routinely names a file nobody was editing.

```js
(() => {
  const el = document.querySelector('.your-element'), prop = 'margin-bottom', hits = [];
  const walk = (rules, href) => { for (const r of rules) {
    if (r.selectorText && r.style?.getPropertyValue(prop)) {
      try { if (el.matches(r.selectorText)) hits.push({ file: href, sel: r.selectorText,
        value: r.style.getPropertyValue(prop), important: r.style.getPropertyPriority(prop) }); }
      catch { /* a selector the engine declines to match, e.g. ::before */ }
    }
    if (r.cssRules?.length) walk(r.cssRules, href);       // @media, @supports, @layer, nesting
  }};
  for (const s of document.styleSheets) {
    try { walk(s.cssRules, (s.href || 'inline').split('/').pop()); } catch { /* cross-origin */ }
  }
  return hits;                                    // last entry usually wins; !important always does
})()
```

Test the recursion condition on `r.cssRules?.length` rather than on `r.cssRules`. Since CSS nesting shipped, every plain style rule carries an empty rule list, which is truthy — a version that branches on the bare property skips every rule it was meant to examine and reports a confident empty result.

A rule that applies to *every* instance of a component — `.btn`, `.card`, `.nav-link` — is the interesting find: one base declaration produces symptoms across a dozen screens, and each looks local.

### 2. Does the rule exist at all?

A missing rule and a wrong rule look identical in a screenshot and behave differently under diagnosis. When a property sits at its initial value — a transparent background, a black fill, an unstyled disc — check for the class before hunting for its value.

```js
(() => {
  let n = 0;
  const walk = rules => { for (const r of rules) {
    if (r.selectorText?.includes('fill-success')) n++;
    if (r.cssRules?.length) walk(r.cssRules);
  }};
  for (const s of document.styleSheets) { try { walk(s.cssRules) } catch { } }
  return n;                                   // 0 means the class was never generated
})()
```

Frameworks generate utility families selectively: a theme-colour loop that covers backgrounds may skip fills, and a consuming template that assumes the full set gets silence rather than an error. Confirm against the built stylesheet, since the source may define what the build declines to emit.

### 3. Which layer owns the fix?

In a stack of framework base → theme layer → template, the correct value written at the wrong level is a fix today and drift tomorrow: the next consumer inherits the original defect, and the override quietly disagrees with it.

| The value is wrong for | Fix belongs in |
|---|---|
| Every consumer of the design system | The system's variables or base |
| This brand or site alone | The site's theme layer |
| This page alone | The template |

Two clues place it: how many rendered instances the defect touches, and whether the reference implementation — the previous version's *built* stylesheet, when there is one — held a different value for the same selector. A value the reference set globally belongs in the system; a value it set per brand belongs in the theme.

### 4. Is the cause spacing at all?

Geometry has inputs beyond margins and padding. Check these when the numbers look right and the render still disagrees:

- **A rejected font shifts metrics.** `[...document.fonts].filter(f => f.status === 'error').map(f => f.family)` — an empty array clears the suspicion in one line.
- **Centring aligns the margin box.** Compare `getComputedStyle(el).margin` against the rect: a stray margin offsets the visible box by half its value, opposite the margin.
- **The containing block decides absolute placement.** `el.offsetParent` names the ancestor actually positioning a panel that clips or hangs off-screen at narrow widths.
- **Midpoints settle alignment, tops settle stacking.** Items centred in a flex row share a midpoint and legitimately differ in top edge, so compare `rect.top + rect.height / 2`.

## Confirming the fix

Re-measure at every viewport that was in question, against a control element that already rendered correctly. Stylesheets cache aggressively: when a verified-correct edit appears to do nothing, force a fresh document — a changed query string on the page URL is the blunt, reliable way — before doubting the edit. Two rounds of chasing a fix that had already landed is the usual cost of skipping this.

## Scope

This skill owns causation. The spatial audit itself — scale conformance, proximity ratios, container consistency, responsive compression — belongs to [spacing-rhythm-auditor](https://github.com/emcquesten/claude-design-kit) (MIT), which inventories values statically or through a headless browser and reports them severity-ranked. Run it to find *which* values are wrong, and the four questions above to find where they come from. Its guardrail holds here too: a deliberate optical adjustment is correct, and worth documenting rather than flagging.

For the neighbouring gates, humbleteam publishes ten MIT skills, each in its own repository: [design-qa](https://github.com/humbleteam/design-qa) for the pre-ship checklist (states, contrast, targets, breakpoints, keyboard paths), [design-review](https://github.com/humbleteam/design-review) for scored UX critique, [audit-design-tokens](https://github.com/humbleteam/audit-design-tokens) for token drift once step 3 keeps finding values off the scale.

Generating the interface in the first place is separate work — the `product-ui-design` skill when it is among your available skills.
