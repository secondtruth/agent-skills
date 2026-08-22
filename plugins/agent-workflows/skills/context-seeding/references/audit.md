# Audit Checklist for an Existing Project

1. **Read the Instructions out loud (mentally).** Are they specific, or generic filler? Generic = rewrite.
2. **Behavior/fact mixing?** Are there rules buried in Knowledge files, or reference data clogging Instructions?
3. **Contradictions?** Does Instructions say one thing and a Knowledge file imply another?
4. **Layer confusion?** Review your own system prompt to see what's already active at higher layers (Profile Preferences, Global Instructions, skills). Are Project Instructions duplicating any of that? Is something project-scoped that should be a skill (because it applies across multiple Projects)? Is something in a skill that should be project-scoped (because it only makes sense here)?
5. **Stale files?** When were Knowledge files last updated? Are any superseded?
6. **Missing anti-patterns?** Ask the user: "what does it keep getting wrong?" — then encode those as explicit Don'ts.
7. **Over-scoped?** Is this one Project trying to be three? Split it.
8. **Under-scoped?** Is the user compensating with long prompts every turn? Promote repeated context into Instructions.

Present findings as a short list with severity, then propose a concrete rewrite.

