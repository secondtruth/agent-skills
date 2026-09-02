---
name: cli-design
license: MIT
version: "2.0"
description: >-
  Design command-line applications in any language — the interface layer
  (flags, help, human vs machine output, exit codes, prompting, config
  precedence) and the program layer (command trees, application context,
  error and exit policy, config and output boundaries). Use whenever you
  write, extend, review or migrate a CLI.
---

# CLI Design

A CLI has two layers, and this skill covers both. The **interface layer** is what the user experiences: flags, help, output, errors, prompts. The **program layer** is how the code is shaped: command trees, the application context, error flow, boundaries. Everything in this file is language-agnostic; concrete code shapes live in per-language reference files.

Structure and naming rules come from the `code-craftsmanship` skill when it is among your available skills; the parenthetical names below (one concept per unit, members stay together, …) are what they mean when it is not.

## Interface Design

### Flags and arguments

- **Prefer flags over positional arguments.** Positionals are acceptable for the one obvious operand (`cat FILE`, `cp SRC DST`); avoid two or more distinct positionals beyond such idioms.
- **Every flag has a long form.** Short forms are reserved for frequent flags.
- **Reuse conventional names before inventing:** `--all/-a`, `--force/-f`, `--dry-run/-n`, `--quiet/-q`, `--output/-o`, `--json`, `--no-input`, `--version`. `-h`/`--help` mean help and nothing else.
- **Subcommands:** noun-verb ordering (`profile create`), consistent flag names and output formatting across the tree, no near-synonym siblings (`update` *and* `upgrade`). Match subcommands exactly and keep the namespace closed, so every later addition is non-breaking.

### Output

- **stdout is for data, stderr is for messaging.** Progress, status, warnings, and errors go to stderr so piping stays clean.
- **Detect the audience.** TTY → human formatting; pipe → plain output. `--json` (and `--plain` where tables matter) gives scripts a stable contract; human output may change freely.
- **Color and animation are opt-out extras:** disable on non-TTY, `NO_COLOR`, `TERM=dumb`, or `--no-color`; animation only on a TTY.
- **Success is brief but not silent** — say what changed. No developer-only noise outside `--debug`/`--verbose`.
- **Tables and views:** ALL CAPS headers for horizontal tables; Title Case labels with trailing colons for vertical key/value blocks; preserve acronyms (`ID`, `URL`, `API`); mask tokens and secrets by default; use the CLI's friendly flag names, not raw API field names.

### Help and errors

- `-h`/`--help` works at every level. A bare invocation that needs arguments prints concise help: one-line description, an example or two, the common flags, and a pointer to `--help`.
- **Lead help with examples** — common invocations before flag inventories.
- **Rewrite expected errors for humans** and name the next action ("run `x login` first"). Stack traces only behind `--debug`. Suggest the correction for a mistyped command.

### Exit codes

`0` success, `1` runtime failure, `2` incorrect invocation. Add further codes only for failure modes scripts genuinely need to distinguish — and decide them in one place (see Errors and Exit below).

### Interactivity

- **Prompt only when stdin is a TTY**, and honor `--no-input`. Every prompt has a flag equivalent, so the CLI stays usable in scripts and CI.
- **Destructive actions escalate:** mild → just do it (offer `--dry-run`); moderate → confirm, `--force` skips; severe → require typing a non-trivial value (the resource name) or `--confirm=<name>`.
- **Ctrl-C exits promptly**; a second Ctrl-C skips cleanup.

### Configuration

- **Precedence, highest first:** flags → environment variables → project config → user config → system config.
- **Flags name choices, the environment names context.** When a second subcommand needs the connection details a first one already takes (endpoint, region, credentials), the shared part moves to the ecosystem's env contract — `AWS_*` for S3-compatible stores, `PG*` for Postgres — and each subcommand keeps one flag naming its own target, URL-shaped where the target has a URL form (`--backup-s3 s3://bucket/prefix` — one flag per purpose where a `--backup-s3-*` family would grow five). The general rule and its timing live in the `code-craftsmanship` skill when it is among your available skills (context once, choices per use).
- **Secrets arrive via file, stdin, or a credential service.** Flags and env vars leak them — `ps`, shell history, logs, `docker inspect`.

The full conventions — standard env vars, responsiveness targets, robustness, future-proofing — are in `references/interface.md`.

## Program Structure

### Commands

- **Construct, do not declare.** Every visible command comes from a constructor (`NewProjectCreateCommand(app)`, `ProjectCreateCommand::create($app)`). Local command values are easier to test and reason about than package- or file-level command definitions; reach for the latter only with a strong reason.
- **Assemble the tree explicitly** from the root command or a small assembly file. No hidden or side-effect registration (`init()`, autodiscovery magic) for normal command trees — the tree is visible in one place and constructible twice (Explicit Assembly).
- **Keep option structs local to the constructor** where practical, so a command's flags and its handler are read together (members stay with their group).
- **One command per file when it improves readability, not as doctrine.** For compact groups, one domain file with several explicit subcommand constructors beats a pile of tiny leaf files. What matters is that the parent stays scan-friendly and every visible subcommand has a named construction boundary; split when a file resists scanning, keep members together when splitting would only produce boilerplate (one concept per unit).
- **Top-level shortcuts only for high-frequency actions**, with clear ownership of the shortcut.

### The application context

The app object is the small value passed into command constructors so commands reach shared policy and services without touching globals: output streams and rendering policy, helper construction, service factories, top-level execution behaviour.

**Not every CLI needs one — scale it to the program:**

- **A single command, or a flat tool with a handful of flags:** pass what each function needs as plain parameters. Introducing an `App` here is machinery without a payload.
- **Several commands sharing output policy, services, or clients:** introduce the app object and pass it into constructors. The rule of three applies — when the third command re-plumbs the same dependencies, that is the signal; not before.
- Once it exists: **it is a passed-in value, never a global**, and **not a bag of everything**. Project config, domain clients, and business services belong in the consuming application's own app or core layer, not in reusable console infrastructure. Reusable infrastructure keeps its context thin and generic; an application-specific `App`/`Core` may exist, but never as a wrapper whose sole job is holding the generic one.

### Errors and exit

- **Handlers return errors; the process exits at one boundary.** The process exits in exactly one place, the top-level runner — so tests, shell mode, and command composition stay possible (Exit at the Boundary).
- **Distinguish incorrect invocation from runtime failure** with a typed usage error: usage/help output for the former, concise error output without usage spam for the latter, exit codes decided in that one place.
- **Suppress the framework's automatic usage-on-error output** for runtime errors and render centrally instead.

### Config boundary

Config lifecycle — path handling, defaults, permissions, save policy — belongs to the config package/module, not to private glue in the command layer (Policy Lives With Its Model). Expose intent-revealing helpers for read-only work and mutation; handlers stay focused on command behaviour.

### Output boundary

Structured human-facing output lives in an output/presentation module, not scattered through handlers. Short confirmations may stay inline; resource views go through dedicated render functions that take a writer and a view model — never a client or service. If the output layer starts making business decisions, move the decision back to the domain layer and pass a simpler view model to the renderer. A renderer that takes a writer and a view model is also the seam the `tdd` skill, when it is among your available skills, will want to test at.

## Reference Files

- **`references/interface.md`** — the full interface conventions: standard flag and env-var names, help text anatomy, output and color rules, confirmation tiers, responsiveness and robustness, future-proofing. Read when designing or reviewing the user-facing surface.
- **`references/go.md`** — the Go/Cobra shapes: command constructors, central `Execute()`, `RunE`, typed usage errors, the console helper, config helpers, tabwriter rendering. Read when writing Go CLI code.
- **`references/go-migration.md`** — ordered playbooks for moving an existing Go CLI onto this style. Read when refactoring, not when starting fresh.

Other languages slot in as `references/<language>.md`; the two layers above are the contract they implement.
