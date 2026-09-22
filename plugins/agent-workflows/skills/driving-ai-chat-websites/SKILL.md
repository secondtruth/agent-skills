---
name: driving-ai-chat-websites
license: MIT
description: Drive an AI chat assistant's website through the user's browser — find the composer, put a prompt in without sending it, pick the model, wait for the answer and read it back — on claude.ai, chatgpt.com, gemini.google.com, chat.mistral.ai and kimi.ai. Use whenever a task runs in a logged-in web chat session, once the site is chosen.
---

Type into a chat composer and you are one keystroke away from posting a half-written
message into the user's real account. That is the failure this skill prevents. Which
assistant a task goes to, and whether a CLI or oracle serves it better than the site, is
the `consulting-ai-assistants` skill's call when it is among your available skills; this
skill starts once the site is chosen.

## Which browser surface

Use **claude-in-chrome** (`mcp__claude-in-chrome__*`) — it drives the user's real
browser with their existing logins. The in-app Browser pane starts signed out and lands
on a login wall.

If `tabs_context_mcp` reports a lost connection, check whether the browser is running and
whether it just updated. **A browser update disconnects the extension** — the most
common cause when the tools worked earlier in the same session. The fix is the user's:
restart the browser, open the Claude side panel once. Retry once or twice first; the
disconnect is often transient.

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

## Models, modes and uploads

On every site, take the strongest tier the user's plan includes. Tiers that cost extra
credits, such as Kimi's Max effort, stay unused unless the task names them. A picker
proves only the UI selection; which model served the answer stays unverified — record
model and effort as the picker showed them.

Gemini opens at `gemini.google.com/app`. Its default mode is Flash (the mode picker sits
next to the composer); switch to a stronger mode for long or dense material. A
"Temporary chat" toggle keeps a one-off task out of the user's Gemini history. Its picker
lists models plus a separate "Thinking (extended)" toggle. The "Pro" label marks a tier,
not the newest model: in September 2026 the picker still offered 3.1 Pro while 3.8 Flash,
released on 2 September, was rolling out. Take the newest model the account's picker
actually lists, using announcements only to tell versions and tiers apart, then switch on
extended thinking. To hand Gemini files, open "Uploads & Tools" (the + button): that adds
hidden `input[type=file]` elements, and `file_upload` fills one directly while the native
file dialog stays closed.

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

## Wait, then hand the result back

Thinking models answer in minutes. Wait inside one `browser_batch`: `wait` allows 10
seconds per action, so chain several and end on a screenshot, until the stop button
turns back into the send button. `get_page_text` then returns the whole transcript,
tool calls and thinking trace included and citation markers stripped; keep the answer.

After sending, the chat URL appears in the tab context. **Give the user that link.** When
the chat itself is the deliverable — a button the user presses there, a conversation they
continue — the link is the result. When the result is *content* (a summary, a second
opinion), read it back with `get_page_text` and bring it into the conversation rather
than sending the user to the other tab; the link then serves as a citation, together
with the model and effort as the picker showed them and the plugins the assistant used.

## Boundaries

Do not log in, create accounts, or enter API keys and passwords — if a site shows a
login wall, stop and hand it back to the user.

A task handed to an assistant carries what the task needs: the brief, and the files and
pages it names. Credentials, API keys and tokens stay out of every prompt.
