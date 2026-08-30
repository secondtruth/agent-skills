---
name: health-critical-audit
license: MIT
description: >-
  Audit an application whose content can affect health outcomes — first-aid
  guides, triage or symptom-checker flows, emergency features: trace every
  instruction to a named clinical source, gate-check the AI safety rails,
  verify the emergency-call UX, and flag MDR/ISO-14971/GDPR gaps in a
  severity-ranked report. Use before releasing, medically reviewing or signing
  off such an app.
---

# Health-Critical Audit

An audit of an app whose instructions a layperson may follow in a medical
situation. It produces findings, each anchored to a file and line — the
deliverable is the report, and fixes happen only when the user asks
afterwards. Two determinations stay out of scope by design: whether content
is medically correct (that belongs to a qualified medical reviewer) and
whether the app is a medical device (that belongs to a regulatory
professional with counsel). The audit establishes *traceability* and
*gate integrity* so those professionals can do their part.

Throughout: tolerate false positives, never false negatives. A finding that
turns out benign costs a minute of review; a missed unsafe instruction costs
a user in an emergency.

## Step 1 — Inventory the health-critical surfaces

Map what the app exposes before judging any of it:

- Content packs: instruction flows, timers, spoken text, per-locale variants.
- AI surfaces: classifiers, chat, prompts, red-flag lexicons, spoken responses.
- Emergency actions: call buttons, dispatcher hints, location readouts.
- Review metadata: reviewer, review date, status fields, source registry.

Done when every surface is listed with its declared review status — including
`null` and `unreviewed`, which are findings when the deployment story claims
otherwise.

## Step 2 — Content traceability

For every instruction node, timer value, and dosage-adjacent statement, name
the authoritative source it derives from (for first aid in Europe: ERC
guidelines and the national society's materials — DRK/JUH/MHD/ASB in
Germany; AHA for US-market content). Verify against the source registry the
repo carries; a registry entry that is a "general pointer" rather than a
line-level derivation is a finding, and content with no source at all is a
severity-1 finding.

Every medication, dosing, or diagnosis statement is a finding regardless of
correctness — first-aid scope excludes all three. The app's own regulatory
notes serve as evidence inside the finding, never as the condition for
raising it: notes that are silent on a statement leave the finding standing.

Done when every instruction is either traced to a named source or flagged.

## Step 3 — Safety rails on AI and triage surfaces

The standard is the gate model: a safety rail is a *non-bypassable gate in
the response pipeline*, enforced in code before or after the model call.
A rule that lives only in the system prompt is prompt *text*, and prompt
text is a finding, not a rail. Check:

- Red-flag detection runs on every user turn before any triage question.
- Emergency-first messaging: on a red flag the emergency number comes first,
  with a one-tap call affordance; triage questions follow, never precede.
- Emergency and crisis numbers are jurisdiction-keyed data, maintained as a
  table, kept out of the prompt. A locale is a language; a jurisdiction is
  where the user stands. Routing keyed to the UI locale is a finding: a
  traveller with a German UI gets a one-tap call to a number that is dead
  where they are. The audit checks for a jurisdiction source (deployment
  region constraint, or device region with a stated fallback) independent of
  localization.
- Each table entry carries its branch condition. Germany: 112 for
  life-threatening emergencies, 116117 only for urgent problems that are
  clearly not life-threatening, Telefonseelsorge 0800-111-0-111 for crisis
  support. US: 911 and 988. A red flag routes to the emergency number
  alone — an entry whose condition is undefined can surface 116117 as an
  emergency option, which is a finding.
- Handoff to a human — dispatcher, crisis line — is reachable from every
  conversational state.
- Offline behaviour: when the model is unreachable, the deterministic path
  still works and says so.
- The bot discloses it is software and stays inside its declared scope.

The `health-chatbots` skill, when it is among your available skills, carries
the full rails checklist (self-harm, abuse, pediatric flags); apply it with
the region table above in place of its US numbers.

Done when every rail above is confirmed in code (with file:line) or filed as
a finding.

## Step 4 — Emergency-call UX

- Calling emergency services requires an explicit user action; auto-dial is
  a severity-1 finding.
- The dispatcher is presented as authoritative; app guidance yields to
  dispatcher instructions in copy and flow order.
- Stress conditions hold: the call path works offline, one-handed, with
  large targets and high contrast, and survives an app crash mid-flow
  (state restore or a clean restart into the emergency screen).

## Step 5 — Regulatory and privacy posture

Flag gaps against the regime the app targets; make no determinations.

- EU market: establish applicability first. Does the repo assess the app's
  intended purpose against MDR Art. 2(1) (MDCG 2019-11 / Annex VIII
  Rule 11)? A missing assessment is its own finding, reported as "MDR
  applicability unresolved". Where the assessment concludes the app is a
  medical device — or the repo itself claims that regime — an absent
  ISO 14971 risk file is a severity-3 finding; for software the assessment
  places outside MDR scope, it is a recommendation rather than a blocker.
  The `mdr-745-specialist` and `risk-management-specialist` skills, when
  they are among your available skills, supply the classification algorithm
  and risk-file structure.
- Health data under GDPR: voice input, location, and path logs are
  Art. 9 special-category candidates — check the DPIA status and that the
  privacy claims in the docs match what the code transmits. The
  `gdpr-health-data` skill, when it is among your available skills, covers
  the Art. 6/9 stacking and DPIA content.
- Disclaimers and review-status claims in README/regulatory notes must match
  the metadata found in step 1; every mismatch is a finding.
- General site-law duties of a public deployment — Impressum, privacy
  policy, consent management — are handled by the
  `web-compliance` skill, when it is among your available skills: flag
  their absence, then hand over rather than re-auditing them here.
  This audit keeps one slice of that surface: whether the privacy claims
  match what the code transmits.

## Step 6 — Report

Rank findings by severity and deliver them as the audit's single output:

| Severity | Meaning |
|---|---|
| 1 | Could contribute to harm in an emergency (wrong/untraceable instruction, missing gate, auto-dial) |
| 2 | Undermines the safety architecture (prompt-text rail, wrong region number, dispatcher not authoritative) |
| 3 | Blocks release readiness (missing risk file, DPIA, review metadata) |
| 4 | Weakens auditability (registry gaps, doc/metadata mismatch) |

Each finding carries location, evidence, and the step that produced it.
Close with a verdict on the app's *claimed* status: does the evidence
support what the repo says it is (prototype, reviewed, released)?
