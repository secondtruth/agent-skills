---
name: consulting-ai-assistants
license: MIT
description: Decide which AI assistant gets a task and by which transport — oracle, a CLI in the directory, or the website — for ChatGPT, Gemini, Kimi, Codex, Mistral and claude.ai. Use whenever a task is handed to another assistant, a second opinion or review from another model is wanted, or the user says "ask the other AIs".
---

A consultation hands another model a brief and brings its answer back with provenance.
This skill decides who gets the brief and through which door; the doors themselves are
other skills: `oracle-advisor` and `oracle` for ChatGPT through oracle, and
`driving-ai-chat-websites` for the sites, each when it is among your available skills.

## Routing

| Assistant | The task names a directory | Otherwise: text, files, a bare question |
| --- | --- | --- |
| ChatGPT | oracle, with the files that matter selected from the directory | oracle |
| Gemini | `agy` on a disposable worktree | oracle; gemini.google.com for a Google notebook, the newest model or anything in the user's Google account |
| Kimi | `kimi` on a disposable worktree | kimi.ai |
| Codex | `codex` in the directory, under its read-only sandbox | — |
| Mistral | — | chat.mistral.ai |
| Claude | — | claude.ai, for a skill hosted there or a task that needs the user's claude.ai context |

Second opinions, reviews and design critiques follow this table. A YouTube video follows
the `youtube-video-ingestion` skill when available.

"Ask the other AIs", a second opinion from "the others", a review round: that means
ChatGPT, Gemini **and Kimi**, at least, each by its row above. Every one of them gets the
same brief and the same context, and every answer is kept unabridged beside the others,
each with its provenance: where the project keeps its reviews (`docs/reviews/` is the
usual place), and outside the repository when it keeps none.
An assistant that cannot be reached — a login wall, a transport that fails twice —
is reported as missing from the round, with the error; the round goes on without it.

## A directory review runs on a disposable worktree

A CLI without a read-only sandbox of its own gets a copy of the tree instead:

```bash
git -C <directory> worktree add --detach <review root>/review HEAD
# the CLI runs in <review root>/review
git -C <directory> worktree remove --force <review root>/review
```

`<review root>` is one fixed directory outside every repository, reused for each review.
The worktree protects the repository: it holds the committed files of `HEAD`, so `.env`
files and untracked work stay out of the CLI's reach, and whatever it writes there
vanishes with the worktree. When the review concerns uncommitted work, copy the named
files into the worktree after checking them for credentials. The rest of the machine is
protected by the prompt alone, so state in it that the review is read-only. `kimi -p`
and `agy --print` take the prompt on the command line, where the process list shows it.

## ChatGPT: oracle

The oracle MCP server (a `consult` tool) or the `oracle` CLI pastes prompt and files into
ChatGPT itself, selects and verifies the model and thinking time, and stores every run as
a session that survives a timeout. Follow the `oracle` and `oracle-advisor` skills for
flags, model choice and the evidence to report when they are among your available skills.

Update oracle before a round of runs, through the package manager that installed it
(`brew upgrade steipete/tap/oracle`; Scoop on Windows): the sites change their pickers
faster than an installed version ages well. Verified September 2026 with oracle 0.20
and 0.21:

- Pass `files` as absolute paths — the MCP server resolves relative ones against its own
  working directory.
- For long runs, start with `waitForCompletion: false` and block on the `wait` tool
  instead of holding the turn open.
- When oracle refuses to submit because it cannot confirm the requested model or tier,
  the account most likely lacks it. Pick one the account has.
- The browser engine is fragile about context: file uploads fail when the automated
  browser window is in the background, inline bundles truncate past roughly 15k tokens,
  and a multi-line prompt can arrive cut at its first paragraph. Before a long run, a
  mini run ("name the headings of the attached file") proves that context arrives. When
  it does not, report ChatGPT as unavailable for the day instead of burning attempts.
- One oracle run at a time; the same prompt twice needs `--force`.

chatgpt.com by hand, through `driving-ai-chat-websites` when it is among your available
skills, is for the cases oracle leaves: oracle absent, or the chat itself the deliverable
— a link the user continues in, a button they press there.

## Gemini: oracle for text and files, agy on a directory, the site for the rest

oracle reaches gemini.google.com through its cookie client and takes long inline bundles
without complaint (27k tokens in September 2026). Its Gemini support covers text, images
and YouTube URLs. oracle 0.21.3 resolves `gemini-3-pro` to Gemini 3.1 Pro and reports the
selection as unverified; it falls back to Flash-Lite unless `--no-gemini-fallback` is
set. Notebooks, the newest models and the user's Google account need the website — as
does a text consultation when oracle is absent or refuses the model: gemini.google.com
through `driving-ai-chat-websites` when available.

On a directory, the Antigravity CLI (`agy`) answers headless and reads the files itself,
run on the disposable worktree described above; `agy models` lists its models with
their effort tiers:

```bash
cd <review root>/review && agy --model <model> --print "<prompt>"
```

Verified September 2026 with agy 1.2.8 and 1.2.13:

- Headless mode auto-denies every tool without an allow-rule, `read_file` included. A
  denied turn prints no answer and still exits 0, so an empty answer means a missing
  rule.
- One rule under `permissions.allow` in `~/.gemini/antigravity-cli/settings.json` opens
  the review root for reading, subdirectories included:
  `read_file(<absolute path of the review root>)`. Writes stay denied, which makes the
  review read-only by enforcement. Adding the rule changes the user's configuration:
  ask once.
- `--dangerously-skip-permissions` answers without a rule, on the footing Kimi's `-p`
  mode always has: the worktree protects the repository, the prompt the rest of the
  machine. `--sandbox` confines terminal commands only; the file tool still wrote into
  the home directory with it. Prefer the allow-rule.

## Kimi: the CLI on a directory, kimi.ai otherwise

When the task names a directory — a codebase to review, a repository to critique — run
the Kimi Code CLI (`kimi`) on a disposable worktree of it. It reads the files itself:

```bash
cd <review root>/review && kimi -m <model> -p "<prompt>"
```

Verified September 2026 with kimi-code 0.41 (default model `k3-256k`):

- `-p -` reads nothing from stdin; the prompt has to be the argument.
- `-p` mode edits files without asking, and refuses `--plan`; the worktree is the
  isolation.
- The CLI's plan runs on a five-hour quota. A 403 naming the usage limit means the window
  is spent; the website keeps working on the same account in the meantime.

Every other Kimi task goes to kimi.ai through `driving-ai-chat-websites` when available:
a review that reads knowledge-base pages through Kimi's plugins, a
prompt without a directory, a chat link the user continues in.

## Codex: the CLI reads the files itself

For a second opinion from Codex, keep the prompt file and the answer file in a scratch
directory and run, in the directory under review:

```bash
codex exec --sandbox read-only --skip-git-repo-check --ephemeral \
  -o <scratch>/answer.md - < <scratch>/prompt.md
```

Codex reads the files itself. The prompt arrives on stdin, so it stays out of the
process list and out of shell interpolation, and `--ephemeral` keeps the session off
disk, leaving the answer file as the only output. When it reports that the configured
model requires a newer version, upgrade the CLI first (September 2026: 0.147 to 0.154
for gpt-6-astra). Record the model and reasoning effort from its header as provenance.

## claude.ai: only for what lives there

A skill hosted on claude.ai is updated in a claude.ai chat — the install button lives in
the resulting chat, and the user is the one who presses it, so the chat link is the
deliverable. A skill installed from files is edited at its source, the repository it
was installed from; the browser has no part in that.

## The brief

A brief carries what the task needs: the question, the answer format, the constraints
already decided, and the files and pages it names. A transport that takes no files gets
them inline in the brief. Credentials, API keys and tokens stay out of every prompt. For a review, name the knowledge-base pages it should read; the
request for the review covers sharing them, Kimi's Notion plugin fetches them itself,
and a reviewer who knows the decisions already taken catches contradictions with them
that a reviewer working from the brief alone misses.

Take the strongest tier the user's plan includes; tiers that cost extra credits stay
unused unless the task names them.

## Provenance

Store every answer with: the chat URL or session id, the model and effort as requested
and as observed (a picker label or an oracle selection log proves the UI selection, never
which model served the answer), the transport, and the plugins or tools the assistant
used. A consultation that returned text under an unverified model constraint is reported
as exactly that. The answer is advice: verify it against the repository and the user's
decisions before acting on it.
