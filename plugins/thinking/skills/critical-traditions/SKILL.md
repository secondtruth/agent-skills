---
name: critical-traditions
license: MIT
description: "Apply specific intellectual traditions as analytical lenses on a topic, with each tradition treated as a distinct school with its own concepts, characteristic moves, internal disagreements, and known weaknesses. Use whenever the user names a tradition (e.g. 'ecofeminist take', 'degrowth critique', 'Kantian view'), names a family of traditions ('feminist perspective', 'ecological perspective', 'ethical analysis'), or explicitly asks for ideological / normative / critical-theoretical analysis of a topic. Also use when the user asks 'what would X think about Y' for X being a school or thinker covered here. Activates on explicit request only."
---

# Critical Traditions

A library of intellectual traditions presented as analytical lenses. Each tradition has its own file with the concepts, questions, moves, internal contestation, self-criticism, and primary sources needed to apply it accurately rather than as a caricature.

## Activation modes

There are three ways this skill gets used:

### 1. Single tradition

User names one specific tradition or thinker. Read that tradition's file and apply it. Examples:
- "What would Bookchin say about X" → `social-ecology.md`
- "Give me a degrowth critique of Y" → `degrowth-economics.md`
- "Ecofeminist take on Z" → `ecofeminism.md`

### 2. Family / group activation

User names a family of traditions ("feminist perspective", "ecological perspective", "ethical analysis"). Read `references/families.md` to determine which traditions belong to that family. Then:

1. Read the file for **each** tradition in the family.
2. Apply each in turn, briefly.
3. Synthesize: where do the traditions in this family agree, where do they disagree, what does the family-level picture look like that no single tradition would give?

This is the mode that gives a complete picture from a family, not just one school standing in for the whole.

### 3. Multi-family / "all critical perspectives"

User wants the full picture. Apply the families most relevant to the topic. Synthesize across families at the end.

## Traditions available

Filename in `references/traditions/`:

- `intersectional-feminism.md` – how overlapping axes of oppression compound
- `materialist-feminism.md` – gender as produced by economic relations and reproductive labour
- `liberal-feminism.md` – equal rights, access and representation within existing institutions
- `ecofeminism.md` – the linked domination of women and nature
- `deep-ecology.md` – intrinsic value of the non-human world
- `social-ecology.md` – ecological crisis rooted in social hierarchy (Bookchin)
- `degrowth-economics.md` – deliberate downscaling within biophysical limits
- `ecomodernism.md` – decoupling human flourishing from environmental impact through technology
- `decolonial-critique.md` – coloniality persisting in knowledge, power and being
- `post-colonial.md` – representation, hybridity and the aftermath of empire
- `critical-theory.md` (Frankfurt School) – culture industry, instrumental reason, domination
- `marxist-critique.md` – class, capital and the relations of production
- `virtue-ethics.md` – character and flourishing over rules and outcomes
- `deontological-ethics.md` – duties, rights and universalisable maxims
- `consequentialism.md` – outcomes as the measure of right action

Families are defined in `references/families.md`.

## Universal application rules

These apply regardless of which tradition is being used.

### Use the tradition's own concepts

Apply the tradition using its native vocabulary and characteristic moves, not a generic "critical-sounding" register. A degrowth analysis that does not use degrowth's concepts (autonomy, conviviality, biophysical limits, decommodification) is not a degrowth analysis – it is generic skepticism wearing the name.

### Surface the internal disagreement

Every tradition is internally contested. When applying, note where the school disagrees with itself on the question at hand. This is what prevents the lens from becoming a caricature ("the feminist view is X") and shows the tradition as living thought rather than a fixed position.

### Apply the self-criticism

Each tradition file has a *self-criticism / known weaknesses* section. Read it. When applying the tradition, name what the tradition cannot see well or where its concepts systematically distort the topic. It is the difference between using a lens and being captured by one.

### Skip a tradition that has no purchase

When you would be straining to apply a tradition, say so in one line — "This topic does not really have a [tradition] angle worth pursuing" — and move on.

### Concrete over generic

Output should be specific to the topic, not a recitation of what the tradition generally thinks. If the output could be copy-pasted to a different topic, it has not actually engaged with the topic.

### Neutral register

Apply the tradition's analysis in a neutral register, not in its rhetorical one: the user invited a perspective, and critique reads best without a sermon.

## Output structure

- **Single tradition**: A paragraph on what the tradition sees in this topic, the key concepts engaged, the internal disagreement (if any) on this specific question, and the self-criticism the tradition itself would raise.
- **Family activation**: One short section per tradition in the family, then a **Synthesis** noting agreements and disagreements within the family.
- **Multi-family**: Same as family activation, but organized by family with synthesis per family, plus a closing synthesis across families that identifies cross-cutting tensions.

## Composition with `analytical-lenses`

For topics with a structural dimension, run the `analytical-lenses` skill first when it is among your available skills (its Composition section says how); otherwise sketch stakeholders and power before interpreting. Applying traditions to an unmapped situation tends to reach for familiar pattern-matches rather than engaging with the situation as it actually is.
