---
name: handoff-debrief
license: MIT
description: Compose the debrief that closes a handoff session — what was done, the current state of the artifacts, out-of-scope observations, recommendations. Trigger automatically when work that started from a handoff file is complete, and when the user asks for a debrief or to report back.
---

# Handoff Debrief

## Why this exists

This is the return leg of a handoff: the `handoff` skill, when it is among your available skills, writes the document that opens a session; this one closes it. As there, reference artifacts by path or URL instead of restating them, and redact secrets.

When you complete a task via handoff, you often notice things that were out of scope — stale references, inconsistencies, decisions made implicitly. Without a debrief, those observations die at the end of the session. The originating agent starts its next session blind.

Write the debrief even when everything went smoothly and there's nothing to flag — a clean debrief is still a useful signal.

## Report structure

Produce a self-contained Markdown document using this template:

```markdown
# Debrief: {task title}

**Date:** {YYYY-MM-DD}
**Completed by:** {agent, space or session identifier}

## What was done

{Concise summary of completed work — what changed, what was created, what was installed.
The receiving agent needs the outcome, not a step-by-step log.}

## Current state

{What exists now. File paths, installed versions, knowledge-base pages created/updated, etc.
Anything the receiving agent needs to know to pick up from here.}

## Observations

{Things noticed that were out of scope but worth flagging:
- Stale references in files that weren't touched
- Inconsistencies between two sources
- Decisions made implicitly that the receiving agent should know about}

If nothing notable: *No observations.*

## Recommendations

{Actionable next steps, most important first.}

If nothing to recommend: *No recommendations.*
```

## Delivery

Deliver the debrief as a standalone Markdown block — or a file, where files are the medium — that the user can copy wherever it needs to go.

Done when every artifact you changed appears under Current state and every out-of-scope finding you noticed appears under Observations.

## Writing observations well

The bar: *would the receiving agent make a wrong assumption without this?* If yes, include it.

Be as specific as the situation calls for. When the fix is surgical and the location is unambiguous, name it precisely. When the issue is a pattern across many places, describe the pattern — a line number that might shift next week is worse than a clear description of what to look for.

Calibration:

- Too vague: "Some files may be outdated."
- Overfit: listing exact coordinates for something that's obviously a widespread pattern
- Just right: describe what's wrong and where to look, specifically enough to act on

Apply the same thinking to recommendations.
