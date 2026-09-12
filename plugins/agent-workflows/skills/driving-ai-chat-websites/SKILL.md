---
name: driving-ai-chat-websites
license: MIT
description: Drive an AI chat assistant's website through the user's browser to hand it a task and bring the result back — claude.ai, chatgpt.com, gemini.google.com, chat.mistral.ai, kimi.ai. Use for skill updates via claude.ai, YouTube ingestion via Gemini, a second opinion from another model, or any task that must run in a logged-in web session. Prefer oracle for ChatGPT when available.
---

Type into a chat composer and you are one keystroke away from posting a half-written
message into the user's real account. That is the failure this skill prevents.

## ChatGPT: hand it to oracle when it is available

When the oracle MCP server (a `consult` tool) or the `oracle` CLI is available, send
ChatGPT tasks through it instead of driving chatgpt.com. It pastes prompt and files into
the composer itself, selects and verifies the model and thinking time, and stores every
run as a session that survives a timeout. When the `oracle` skill is among your available
skills, follow it for flags and model choice. Verified September 2026 with oracle 0.20.0:

- Pass `files` as absolute paths — the MCP server resolves relative ones against its own
  working directory.
- For long runs, start with `waitForCompletion: false` and block on the `wait` tool
  instead of holding the turn open.
- When oracle refuses to submit because it cannot confirm the requested model or tier,
  the account most likely lacks it. Pick one the account has.

Drive the site by hand when oracle is absent, for claude.ai, Mistral and Kimi, for
YouTube ingestion via Gemini, and whenever the deliverable is the chat itself — a link
the user continues in, or a button they press there.

## Kimi: the CLI for standalone prompts, kimi.ai for the rest

The Kimi Code CLI (`kimi`), when installed, answers a standalone prompt headless: run
`kimi -m <model> -p "<prompt>"` from a scratch directory and read stdout. State in the
prompt that the answer is text only, from the model's own knowledge. Verified September
2026 with kimi-code 0.41:

- `-p` refuses to combine with `--plan`, so the scratch directory is the safeguard.
- The prompt travels on the command line and shows in the process list; keep the CLI for
  prompts that may appear there.
- The CLI's plan runs on a five-hour quota. A 403 naming the usage limit means the window
  is spent; the website keeps working on the same account in the meantime.

Use kimi.ai for everything else: a review that reads knowledge-base pages through Kimi's
plugins, a chat link the user continues in, or a prompt that belongs out of the process
list.

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

## Which browser surface

Use **claude-in-chrome** (`mcp__claude-in-chrome__*`) — it drives the user's real
browser with their existing logins. The in-app Browser pane starts signed out and lands
on a login wall.

If `tabs_context_mcp` reports a lost connection, check whether the browser is running and
whether it just updated. **A browser update disconnects the extension** — the most
common cause when the tools worked earlier in the same session. The fix is the user's:
restart the browser, open the Claude side panel once. Retry once or twice first; the
disconnect is often transient.

## Which site

- **claude.ai** — plugin skill updates (the install button lives in the resulting chat), and anything that should run as Claude with the user's claude.ai context.
- **gemini.google.com** — **YouTube videos.** Gemini reads a public YouTube video straight from its URL: paste the link into the prompt together with the question (summary, transcript, timestamps, "what does the speaker claim about X"). The URL alone is enough; downloads, transcript tools and uploads are unnecessary. Also the natural choice for anything else living in the user's Google account. oracle's Gemini support is documented for text and images only — drive the site for video. The Gemini CLI stopped serving individual accounts in September 2026 (`IneligibleTierError`), so reviews go through the website too. oracle also reaches gemini.google.com through its cookie client, but oracle 0.20.x knows Gemini only up to 3.1 Pro and 3.5 Flash (plus Deep Think) and falls back to Flash-Lite unless `--no-gemini-fallback` is set; the newest models and notebooks need the website.
- **chatgpt.com** — only when oracle is unavailable or the chat itself is the deliverable (see above).
- **chat.mistral.ai**, **kimi.ai** — second opinions, or a task the user explicitly wants run on that model.

For a second opinion, name the knowledge-base pages the review needs in the prompt; the
request for the review covers sharing them. Kimi's Notion plugin fetches them itself, and
a reviewer who knows the decisions already taken catches contradictions with them that a
reviewer working from the brief alone misses.

## Put the prompt in with a synthetic paste

Hand the composer a paste event through `javascript_tool`. It keeps line breaks and blank
lines, sends nothing, leaves the user's clipboard alone and costs one call. Embed the
prompt as a JSON string literal (the output of `JSON.stringify`), so quotes and backticks
arrive intact:

```js
const el = document.querySelector('[contenteditable="true"]');
el.focus();
const dt = new DataTransfer();
dt.setData('text/plain', PROMPT); // PROMPT: the JSON string literal
el.dispatchEvent(new ClipboardEvent('paste', { clipboardData: dt, bubbles: true, cancelable: true }));
```

Verified September 2026 on kimi.ai (`.chat-input-editor`) and claude.ai (tiptap
ProseMirror). Kimi's editor carries `contenteditable="false"` until the page has
hydrated: wait a few seconds and select it by its class. `innerText` read right after the
event can lag behind, so a screenshot is the check, on the other sites before trusting
the event at all.

Gemini's Quill editor ignores the paste event. There, `document.execCommand('insertText',
false, PROMPT)` on the focused `.ql-editor` fills the composer, line breaks included and
the clipboard untouched (verified September 2026).

On Kimi a paste over 4000 bytes becomes a TXT attachment and the composer stays empty.
Type a one-line instruction beside it ("answer the attached brief in the format it asks
for"), then send.

**Fallback when a site ignores the event:** type line by line with `key` `shift+Return`
between lines, all in one batch. Pass `type` single-line strings only — a `\n` inside one
would send, because **Enter sends** in every one of these UIs.

## Composers

`form_input` fails on all of them — the composers are contenteditable elements rather
than form fields ("Element type DIV is not a supported form input"). Locate the element
with `read_page {filter:"interactive"}` for clicks and by selector for the paste event;
**refs are per page load** — `read_page` again after every navigation.

| Site | Composer element |
| --- | --- |
| claude.ai | `textbox "Write your prompt to Claude"` (localised) |
| chatgpt.com | `textbox "Message ChatGPT"` (localised) |
| gemini.google.com | `textbox "Enter a prompt for Gemini"` (localised; German UI: "Einen Prompt für Gemini eingeben") |
| chat.mistral.ai | unnamed `generic` inside a `form`, without an accessible label |
| kimi.ai | unnamed `textbox` |

`chat.mistral.ai/chat` may redirect to `/work` (seen August 2026). If the task belongs in plain chat, switch
tabs after loading rather than trusting the URL.

Gemini opens at `gemini.google.com/app`. Its default mode is Flash (the mode picker sits
next to the composer); switch to a stronger mode for long videos or dense material. A
"Temporary chat" toggle keeps a one-off ingestion out of the user's Gemini history — use
it for a video worth one look. Its picker lists models plus a separate "Thinking
(extended)" toggle. The "Pro" label marks a tier, not the newest model: in September 2026
the picker still offered 3.1 Pro while 3.8 Flash, released on 2 September, was rolling
out. Take the newest model the account's picker actually lists, using announcements only
to tell versions and tiers apart, then switch on extended thinking. To hand Gemini files,
open "Uploads & Tools" (the + button): that adds hidden `input[type=file]` elements, and
`file_upload` fills one directly while the native file dialog stays closed.

Gemini notebooks (Notebooks, then New notebook, a name and Enter) keep sources for
recurring reviews. Their "Add sources" dialog creates the file input only on click and
opens the native dialog with it. Override `HTMLInputElement.prototype.click` for
`type=file` inputs first, so the click hands the input back instead: append it to the
page, give it an `aria-label`, locate it with `find` and fill it with `file_upload`. In
September 2026 a six-part review failed three times in a notebook on 3.8 Flash
("Something went wrong"); the same questions in two halves went through, so split long
asks there. The retry button opens a menu (longer, shorter, retry); retry is its last
item.

Kimi opens in its fast mode; the model picker sits beside the send button and carries a
thinking-effort submenu. Choosing a model reloads the page under `/agent`, so find the
composer again afterwards.

On every site, take the strongest tier the user's plan includes. Tiers that cost extra
credits, such as Kimi's Max effort, stay unused unless the task names them.

## Hand the result back

After sending, the chat URL appears in the tab context. **Give the user that link.**
For a claude.ai skill update it is the whole point — the install button lives in that
chat, and the user is the one who acts on it.

Only skills hosted on claude.ai need this detour. Locally installed skills are
files; edit them directly instead.

When the result is *content* (a video summary, a second opinion), read it back with
`get_page_text` and bring it into the conversation rather than sending the user to
the other tab. The link then serves as a citation; the content is the deliverable.

Thinking models answer in minutes. Wait inside one `browser_batch`: `wait` allows 10
seconds per action, so chain several and end on a screenshot, until the stop button
turns back into the send button. `get_page_text` then returns the whole transcript,
tool calls and thinking trace included and citation markers stripped; keep the answer.

Store a second opinion with its provenance: the chat URL, the model and effort as the
picker showed them, and the plugins the assistant used. A picker proves only the UI
selection; which model served the answer stays unverified.

## Boundaries

Do not log in, create accounts, or enter API keys and passwords — if a site shows a
login wall, stop and hand it back to the user.

A task handed to an assistant carries what the task needs: the brief, and the files and
pages it names. Credentials, API keys and tokens stay out of every prompt.
