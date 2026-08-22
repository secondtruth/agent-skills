---
name: product-ui-design
license: MIT
description: Distinguish product UIs from marketing surfaces when building frontends, then get the product side right — which facts a surface shows and where, and which typeface carries them. Use whenever building or restyling a web UI (admin consoles, dashboards, management/settings UIs, internal tools = product UI; landing/marketing pages = marketing surface), and whenever deciding what belongs in a header, status bar or detail view, why a screen feels empty, how to render IDs, states, timers or long values, or when a monospace face is warranted.
---

# Product UI vs. Marketing Surface

Before styling any frontend, classify the surface. The push for bold,
distinctive aesthetics (the `frontend-design` skill's, when it is among your
available skills) applies **at full strength to marketing surfaces**
(landing pages, product sites, portfolio pieces). A **product UI** — admin
console, dashboard, management or settings UI, internal tool — is a place
where people work every day, and it earns trust through restraint instead
of staging.

When a layout question is easier to see than to argue and the `prototype`
skill is among your available skills, build the throwaway there and grade
it against the rules below.

## Product UI rules

- **Professional over artistic.** Chrome stays plain: a flat neutral
  ground, literal microcopy, the wordmark only at the logo mark.
  Personality lives in one accent colour and precise type.
- **Orient on reference products,** not on imagination: the category's
  best-in-class consoles (e.g. Tailscale for network control planes, vendor
  consoles of the devices being managed) and on sibling projects, so a
  product family feels like one hand built it.
- **Design tokens over ad-hoc values.** Neutral gray scale, one accent
  palette (ideally runtime-themeable), light *and* dark theme with a toggle,
  system-standard spacing/radius scale (Tailwind's defaults are fine).
- **Functional layouts:** page header (title + subtitle + primary action),
  tab or sidebar navigation, tables for fleets/lists (cards only when a
  preview or visual identity per item carries real information), subtle
  tinted badges for status, empty states that instruct instead of entertain.
- **Long values get their own row.** Command lines, URLs, tokens and paths
  span the full width and wrap on word boundaries, never mid-token. In a
  two-column definition grid, spanning rows go last — one in the middle
  leaves a hole beside its predecessor.
- **Typography stays characterful but calm** — a workhorse family with
  character (IBM Plex, Source Sans, Public Sans …) rather than a display
  face or a default system grotesque. For the UI/mono split, see below.

## Choosing a typeface by purpose

Two faces at most: one for the interface, one for machine text. Pick each
for what it has to do, not for how technical it should feel.

- **The UI face** carries everything a human reads as language: labels,
  headings, descriptions, button text, names, email addresses, status words,
  empty-state copy. Choose a humanist or neutral grotesque with a large
  x-height, unambiguous `I l 1` and `O 0`, and real weights at 400/500/600.
  Prefer a family with a matching monospace (IBM Plex, Source, Fira,
  Recursive) so the two faces share proportions and the mix looks
  intentional.
- **The monospace face** is a tool with exactly three legitimate jobs:
  (1) **identifiers to compare or transcribe** — serial numbers, hashes, IDs,
  MAC and IP addresses, tokens; (2) **values meant to be copied** — URLs,
  commands, config snippets, file paths, code; (3) **columns that must align
  vertically** — log output, diffs, fixed-width tables of technical values.
  If a string fits none of those, it belongs in the UI face.
- **Four mistakes that all *feel* right and are all wrong:** vendor, product
  and provider names ("jetkvm", "Google") are words, not identifiers; user
  emails and display names are language, even when they look technical;
  version numbers in prose ("firmware 0.5.8") read fine in the UI face — in a
  column use tabular figures, not a second typeface; a whole status bar set
  in mono because *some* of its content is technical — set the technical
  parts, or nothing.
- **Numbers that change in place** — bitrates, frame rates, counters, timers,
  live measurements — get **tabular figures** in the UI face
  (`font-variant-numeric: tabular-nums`, Tailwind `tabular-nums`) rather than
  a switch to mono. Layout jitter as digits change is the actual problem; a
  second typeface for a line of prose is not the fix.
- **Size mono down.** At the same nominal size it looks larger and heavier
  than the UI face: set it one step down (13px against 14px) and often one
  shade lighter, or technical values will shout over the labels that explain
  them.

## Information rules

A product UI earns trust by telling people the truth about their own things.
Which facts it shows, and where, is as much a design decision as the type
scale — and the failure modes are systematic.

- **Render from capability, not from kind.** Ask what an object supports —
  does it have a screen, a schedule, a billing address — never what it is
  called (`type === "container"`, `role === "admin"`). A capability the
  object lacks means *no control*, not a disabled one. When a view starts
  branching on a name, the model is missing a field: derive `canUseX` there,
  once, and branch on that — not in the markup.
- **One fact, one place.** Give each region a job — header: identity;
  status bar: state; detail page: everything durable — and let a fact appear
  exactly once. Repetition reads as padding, and in a header it costs the
  width the title needs.
- **A sparse surface is a missing-facts problem, never a decoration
  problem.** When a screen looks empty, ask what it never said — which
  image, whose account, what is this attached to — not what could fill the
  space. Ornament on a surface that failed to inform makes it worse.
- **Show the value that was asked about, or nothing.** The number
  that is easy to measure is rarely the one being asked about: the
  terminal's own size is not the guest's, the cache's age is not the data's,
  the upload's size is not the archive's. If the real one is out of reach,
  show nothing — and where the gap needs explaining, explain it on the
  surface (help text, a tooltip), not in a doc nobody opens.
- **Name absences.** "none", "the image's own entrypoint", "never signed
  in" — an explicit nothing is information, an omitted row is ambiguity.
  Omit only what does not apply at all.
- **Resolve references to names.** A UUID in a status bar is noise. Look the
  name up, and fall back to a placeholder when the lookup fails: a nicety
  must never take the surface down with it.
- **A live number must be honest about what it counts.** Start it where the
  work starts — including the setup nobody sees — and stop it when the work
  stops. A timer that keeps running while the thing is paused is a lie that
  ticks.
- **When a variant loses a control, find the same job's form.** A surface without a screen still needs "save what I am looking
  at" (a log instead of a screenshot) and "make it bigger" (type size
  instead of zoom). Symmetric affordances are learnable; inventions have to
  be discovered.

## Marketing surface rules

When the `frontend-design` skill is among your available skills, it owns
this side at full strength. Without it: one bold aesthetic direction,
distinctive display typography, atmosphere, motion, a memorable composition.

## When mixed

A product may embed marketing moments (onboarding, empty first-run, login
screen). The login screen may carry slightly more brand than the app chrome —
logo, name, one line — but stays on the product side of the line.
