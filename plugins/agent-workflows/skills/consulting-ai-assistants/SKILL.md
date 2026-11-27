---
name: consulting-ai-assistants
license: MIT
description: Decide which AI assistant gets a task and by which transport — oracle, a CLI in the directory, or the website — for ChatGPT, Gemini, Kimi, Codex, Mistral and claude.ai. Use whenever a task is handed to another assistant, a second opinion or review from another model is wanted, or the user says "ask the other AIs".
---

A consultation hands another model a brief and brings its answer back with provenance.
This skill decides who gets the brief and through which door; the doors themselves are
other skills: `oracle-advisor` and `oracle` for ChatGPT and older Gemini models through
oracle, and
`driving-ai-chat-websites` for the sites, each when it is among your available skills.

## Routing

| Assistant | The task names a directory | Otherwise: text, files, a bare question |
| --- | --- | --- |
| ChatGPT | oracle, with the files that matter selected from the directory | oracle |
| Gemini | `agy --mode plan` on a disposable worktree | `agy --mode plan` in a scratch directory holding the files; gemini.google.com for a Google notebook or anything in the user's Google account |
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

## Update the transport first

Before a round of runs, update oracle and every CLI the round uses, through the package
manager that installed it:

```bash
brew upgrade steipete/tap/oracle    # Homebrew; likewise codex, kimi-code, antigravity-cli
scoop update oracle                 # Scoop, on Windows
```

The sites change their pickers and the vendors their models faster than an installed
version ages well; oracle failing to find a model picker is the usual symptom. The
package manager goes before a tool's own updater (`kimi upgrade`, `agy update`), which
leaves the manager's record behind. Note the version that ran as part of the provenance.

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

Verified September 2026 with oracle 0.20 and 0.21:

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

## Gemini: agy for the newest models, the site for the rest

The Antigravity CLI (`agy`) reaches the newest Gemini models headless and reads files
itself, so it takes text consultations as well as directories. `agy models` lists the
models the account offers with their effort tiers; take the strongest the plan includes.
In November 2026 that was the Gemini 4 family: Carbon (Google's model for the hardest,
long-horizon work, the default for a review), Neon (adapted from Carbon, faster and
cheaper, up to `xhigh`, agy's default) and Hydrogen (fast, everyday); Argon, the first
Gemini 4 model, left agy on 30 November.

Google's Antigravity FAQ counts headless `agy -p` as meant for direct scripting and CI and
says that wrapping it inside third-party coding agents is not supported under consumer
plans; for those it recommends a Google AI Studio or Gemini Enterprise API key, which agy
accepts as `GEMINI_API_KEY`. Reusing the Antigravity login in other software is a
violation of its terms. Which footing a consultation runs on is the user's call. agy
1.5.18 reads the key only from the environment and uses it only with `modelProvider:
"gemini"` in its `settings.json`; the user's key, when there is one, sits in
`~/.gemini/.env`, where the Gemini CLI looks for it.

Run it in plan mode, which reads and writes nothing. On a directory, run it on the
disposable worktree described above; for a text consultation with files, copy the files
into a fresh scratch directory and run it there:

```bash
cd <review root>/review && agy --mode plan --model gemini-4-carbon-high --print "<prompt>"
```

Verified November 2026 with agy 1.5.18 (Homebrew cask `antigravity-cli`):

- Without `--mode`, print mode runs in Auto mode: it reads files outside the workspace
  without asking and runs shell commands after its own review. Asked about a YouTube
  video, it started oracle by itself, following a skill it found in the user's skill
  directory. In plan mode a prompt that asks for a write ends in a plan awaiting
  approval, nothing written, exit 0.
- `--disable-slash-commands` switches plan mode off (agy warns about it), so the two
  never go together.
- Reading no longer needs an allow-rule under `permissions.allow`. `--sandbox` confines
  terminal commands only; in September 2026 the file tool still wrote into the home
  directory with it.
- `--output-format json` returns the answer with a `conversation_id` but not the model;
  record the model as requested.
- agy cannot watch a video: given a YouTube URL it gets a web-search summary at most.
  Videos follow the `youtube-video-ingestion` skill when available.

oracle's Gemini route lags behind the models. Its cookie client carries a fixed table of
Gemini 3.x models: in 0.23.1 `gemini-3-pro` resolves to 3.1 Pro, beside `gemini-3.5-flash`
and `gemini-3-pro-deep-think`. Any other name, a Gemini 4 model included, is served by
3.1 Pro with nothing but a log line, and an unavailable model falls back to Flash-Lite
unless `--no-gemini-fallback` is set; the selection is reported as unverified either way.
Gemini 4 support was an open upstream pull request in November 2026 (steipete/oracle#610);
check oracle's changelog after an update. Until it lands, oracle is Gemini's door for
image generation, for YouTube URLs when the user has no Gemini API key, and the fallback
when agy is absent.

Notebooks and anything in the user's Google account need gemini.google.com, through
`driving-ai-chat-websites` when available; so does a Gemini 4 answer when agy is absent.

## Kimi: the CLI on a directory, kimi.ai otherwise

When the task names a directory — a codebase to review, a repository to critique — run
the Kimi Code CLI (`kimi`) on a disposable worktree of it. It reads the files itself:

```bash
cd <review root>/review && kimi -m <model> -p "<prompt>"
```

Verified September 2026 with kimi-code 0.41 and 2.1.1 (default model `k3-256k`):

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

Store every answer with: the chat URL or session id, the version of the transport, the
model and effort as requested
and as observed (a picker label or an oracle selection log proves the UI selection, never
which model served the answer), the transport, and the plugins or tools the assistant
used. A consultation that returned text under an unverified model constraint is reported
as exactly that. The answer is advice: verify it against the repository and the user's
decisions before acting on it.
