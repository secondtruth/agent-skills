# Go Migration Playbooks

Ordered steps for moving an existing Go CLI onto the style in `SKILL.md` and `references/go.md`. Each step is a separate commit — behaviour changes never ride along with structural ones (leave the campsite cleaner, in its own commit).

## A. From legacy Cobra: `Run`, package-global commands, `init()` registration, global `Core`, `h.Fatal`

Run these in order; each leaves the CLI working.

1. **Introduce `App`.** Create the application context and have `Execute()` build it. Nothing else changes yet. (If the CLI is small enough that `SKILL.md`'s application-context rule says it doesn't need one, skip to step 2 and pass dependencies as parameters instead.)
2. **Add command constructors** — `NewFooCommand(app)` — while preserving the existing one-command-per-file layout. Keep the old package-level variables in place initially if callers depend on them.
3. **Move options into the constructors.** Each command's flags and option struct become local to its constructor, replacing package-level option variables.
4. **Convert handlers from `Run` to `RunE`.** Mechanical, but do it as its own commit: signature change plus `return err` where the code previously swallowed or fatal'd.
5. **Replace `h.Fatal` with returned errors.** Wrap with context (`fmt.Errorf("…: %w", err)`) as you go.
6. **Add central error rendering** in `Execute()`, set `SilenceErrors`/`SilenceUsage` on the root, and introduce `UsageError` so incorrect invocation still prints usage while runtime failures stay concise.

Once step 6 lands, delete the `init()` registrations and the package-level command variables: the tree is now assembled explicitly.

## B. From inline Cobra literals: a domain file that has outgrown itself, but is not large enough for one file per leaf command

1. **Keep the existing domain file.** Do not start by splitting — splitting before extracting produces boilerplate files that then need merging back.
2. **Extract each visible subcommand** into `New<Domain><Action>Command(app)` inside that same file. The parent constructor becomes a table of contents.
3. **Leave execution helpers near the domain** until they earn their own package. A helper with one caller belongs next to that caller (fewer concepts, deeper concepts).
4. **Move config lifecycle** into `internal/config` (or equivalent): `LoadAnd`, `Update`, path handling, defaults, permissions.
5. **Move structured resource rendering** into `internal/output` (or equivalent). Short inline confirmations may stay in the handlers.
6. **Split files only afterwards** — and only if the extracted constructors still leave the domain file hard to scan.

## Order matters

Both playbooks share a shape: make the boundaries explicit *before* moving code across them. Extracting constructors before splitting files, and centralizing error rendering before deleting `Fatal`, means every intermediate state is a working CLI. The reverse order produces a long-lived broken branch — which is how migrations get abandoned.
