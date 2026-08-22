# Interface Conventions

Additive detail for the Interface Design section of `SKILL.md` — the rules there are assumed, not repeated. Largely distilled from clig.dev and POSIX/GNU practice.

## Standard flag vocabulary

The full version of the conventional-names rule. A flag that means something else than listed here is a usability bug.

| Flag | Meaning |
|---|---|
| `-a, --all` | All items |
| `-d, --debug` | Debugging output |
| `-f, --force` | Skip confirmations; force the operation |
| `-h, --help` | Help — and nothing else |
| `-n, --dry-run` | Describe changes without executing |
| `--no-input` | Disable all prompts |
| `--no-color` | Disable color |
| `-o, --output` | Output file |
| `-q, --quiet` | Suppress non-essential output |
| `-v, --verbose` | More output (reserve `-v` for this *or* version, not both) |
| `--json` | Machine-readable JSON on stdout |
| `--plain` | Plain tabular text for `grep`/`awk` |
| `--version` | Version information |

## Help text anatomy

Concise help (bare invocation without required args):

```text
<one-line description>

Usage:
  <app> <command> [flags]

Examples:
  <the single most common invocation>
  <one more, slightly less common>

Common flags:
  <3–6 flags max>

Run '<app> --help' for the full reference.
```

- `-h` anywhere in the argv still means help; full help exists at every subcommand level.
- Order flags and commands by frequency of use, not alphabet; top-level help links to the website or repository.
- On an unknown or mistyped command, suggest the nearest match — and ask before executing it.

## Output

- The test for the stdout/stderr split: `results | jq` must never choke on a status line.
- No `[INFO]`/`[WARN]` log-level labels on stderr outside `--verbose` — stderr is messaging, not a log file.
- Red is for errors, sparingly.
- Human-facing output carries no stability promise; `--json`/`--plain` do. Point script authors at them.
- Long output on a TTY goes through a pager (`less -FIRX`).

## Errors and exit codes

- Group repeated errors; put the most important information last — that's where the eye lands.
- Unexpected failures: short human message, traceback behind `--debug`, plus where to report the bug — pre-populate the issue URL when feasible.
- Validate input early and fail before any damage is done.
- Exit codes beyond `0`/`1`/`2` are documented in `--help` or the man page.

## Interactivity

- If input is required and stdin is not a TTY (or `--no-input` was passed), fail and name the flag the user should have provided.
- Read secrets with terminal echo off.

## Environment variables and configuration

- Env vars are for context that varies per execution environment, not a substitute for a config file. Uppercase, digits, underscores; single-line values.
- Respect the general-purpose set where relevant: `NO_COLOR`, `DEBUG`, `EDITOR`, `PAGER`, `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY`, `TERM`, `TMPDIR`, `HOME`, `LINES`/`COLUMNS`. A POSIX name keeps its POSIX meaning.
- Write new config files rather than rewriting the user's; when modifying is unavoidable, ask first and leave dated comments.

## Responsiveness and robustness

- Print *something* within 100 ms; print before the first network request, not after.
- Show progress on anything long: spinner or progress bar on a TTY, periodic plain lines otherwise.
- Network operations time out with a sane, configurable default.
- Ctrl-C exits as soon as possible; announce cleanup if it must run, cap it with a timeout, and let a second Ctrl-C skip it. Expect the previous run's cleanup to have never happened (crash-only mindset).
- Expect misuse: scripts, broken pipes, concurrent instances, weird environments.

## Future-proofing

- Keep changes additive: new flags over changed flags. Warn a release before any breaking change and name the compatible invocation.
- Human output may evolve; the machine flags are the stable contract.
- No time bombs: no hard dependencies on services that may not outlive the tool.
