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

| Task | Assistant | Transport |
| --- | --- | --- |
| Second opinion, review, design critique on text and files | ChatGPT | oracle |
| The same, on a directory of code | Codex, Kimi, Gemini | their CLIs (`codex`, `kimi`, `agy`), run on a disposable worktree of that directory |
| The same, from a further model | Kimi, Mistral, Gemini | kimi.ai and chat.mistral.ai in the browser; Gemini through oracle for text, its site for the rest and when oracle is absent |
| A YouTube video, a Google notebook, the newest Gemini model, anything in the user's Google account | Gemini | gemini.google.com |
| A plugin skill update, anything that should run as Claude with the user's claude.ai context | Claude | claude.ai |

"Ask the other AIs", a second opinion from "the others", a review round: that means
ChatGPT, Gemini **and Kimi**, at least. Every one of them gets the same brief and the
same context files, and every answer is stored unabridged beside the others (a
`docs/reviews/` directory in the project is the usual place), each with its provenance.

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

## Gemini: oracle for text, agy on a directory, the site for everything else

oracle reaches gemini.google.com through its cookie client and takes long inline bundles
without complaint (27k tokens in September 2026). Its Gemini support covers text and
images, and oracle 0.20.x knows Gemini only up to 3.1 Pro and 3.5 Flash (plus Deep
Think), falling back to Flash-Lite unless `--no-gemini-fallback` is set. Video, notebooks,
the newest models and the user's Google account need the website — as does a text
consultation when oracle is absent or refuses the model: gemini.google.com through
`driving-ai-chat-websites` when available. A YouTube video follows the
`youtube-video-ingestion` skill when available.

On a directory, the Antigravity CLI (`agy`) answers headless and reads the files itself;
`agy models` lists its models with their effort tiers. Verified September 2026 with agy
1.2.8: headless mode auto-denies every tool without an allow-rule, `read_file` included,
so run it on a disposable worktree (as for Kimi below) with permissions skipped:

```bash
cd <scratch>/review && agy --dangerously-skip-permissions --model <model> --print "<prompt>"
```

An allow-rule for `read_file` under `permissions.allow` in its `settings.json` is the
standing alternative to the flag.

## Kimi: the CLI in the directory, kimi.ai otherwise

When the task names a directory — a codebase to review, a repository to critique — run
the Kimi Code CLI (`kimi`) on a disposable copy of it. It reads the files itself:

```bash
git -C <directory> worktree add --detach <scratch>/review HEAD
cd <scratch>/review && kimi -m <model> -p "<prompt>"
git -C <directory> worktree remove --force <scratch>/review
```

Verified September 2026 with kimi-code 0.41 (default model `k3-256k`):

- The prompt travels on the command line and shows in the process list; `-p -` reads
  nothing from stdin.
- `-p` mode edits files without asking, and refuses `--plan`. The worktree is the
  isolation: it holds committed files only, so `.env` files and untracked work stay out
  of Kimi's reach, and whatever it writes vanishes with the worktree. Say in the prompt
  that the review is read-only all the same.
- The CLI's plan runs on a five-hour quota. A 403 naming the usage limit means the window
  is spent; the website keeps working on the same account in the meantime.

Every other Kimi task goes to kimi.ai through `driving-ai-chat-websites` when available:
a review that reads knowledge-base pages through Kimi's plugins, a
prompt without a directory, a chat link the user continues in.

## Codex: the CLI reads the files itself

For a second opinion from Codex, write the prompt to a file in a scratch directory and
run, in the directory under review:

```bash
codex exec --sandbox read-only --skip-git-repo-check --ephemeral -o <answer-file> - < <prompt-file>
```

Codex reads the files itself. The prompt arrives on stdin, so it stays out of the
process list and out of shell interpolation, and `--ephemeral` keeps the session off
disk, leaving the answer file as the only output. When it reports that the configured
model requires a newer version, upgrade the CLI first (September 2026: 0.147 to 0.154
for gpt-6-astra). Record the model and reasoning effort from its header as provenance.

## claude.ai: only for what lives there

Only skills hosted on claude.ai need the browser detour — the install button lives in
the resulting chat, and the user is the one who presses it, so the chat link is the
deliverable. Locally installed skills are files; edit them directly.

## The brief

A brief carries what the task needs: the question, the answer format, the constraints
already decided, and the files and pages it names. Credentials, API keys and tokens stay
out of every prompt. For a review, name the knowledge-base pages it should read; the
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
