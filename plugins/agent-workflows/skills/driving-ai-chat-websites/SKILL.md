---
name: driving-ai-chat-websites
description: Drive an AI chat assistant's website through the browser to hand it a task and bring the result back. Use for claude.ai, chatgpt.com, gemini.google.com, chat.mistral.ai and kimi.com — updating plugin skills via claude.ai, ingesting a YouTube video via Gemini, asking another model for a second opinion, or any task that must run in a logged-in web session rather than through an API.
---

Type into a chat composer and you are one keystroke away from posting a half-written
message into the user's real account. That is the failure this skill prevents.

## Which browser surface

Use **claude-in-chrome** (`mcp__claude-in-chrome__*`) — it drives the user's real
browser with their existing logins. The in-app Browser pane has no sessions and lands
on a login wall.

If `tabs_context_mcp` reports "not connected": check whether the browser is running and
whether it just updated. **A browser update disconnects the extension** — the most
common cause when the tools worked earlier in the same session. The fix is the user's:
restart the browser, open the Claude side panel once. Retry once or twice first; the
disconnect is often transient.

## Which site

- **claude.ai** — plugin skill updates (the install button lives in the resulting chat), and anything that should run as Claude with the user's claude.ai context.
- **gemini.google.com** — **YouTube videos.** Gemini reads a public YouTube video straight from its URL: paste the link into the prompt together with the question (summary, transcript, timestamps, "what does the speaker claim about X"). No download, no transcript tool, no upload step. Also the natural choice for anything else living in the user's Google account.
- **chatgpt.com**, **chat.mistral.ai**, **kimi.com** — second opinions, or a task the user explicitly wants run on that model.

## Paste the prompt — do not type it

Verified on claude.ai, chatgpt.com, chat.mistral.ai and kimi.com: pasting preserves line
breaks **and** blank lines, sends nothing, and costs one round trip instead of dozens.
Gemini's composer is the same kind of contenteditable element; paste behaviour there has
not been checked yet — take a screenshot before trusting it.

```bash
pbpaste > /tmp/clip.bak                    # the user's clipboard is theirs — save it
printf '%s' "$PROMPT" | pbcopy
```

(macOS. Linux: `wl-paste`/`wl-copy` on Wayland, `xclip -selection clipboard` on X11.)

Then, in one `browser_batch`: `left_click` the composer `ref`, `key` `cmd+v`,
`wait`, `screenshot` to confirm the text landed and nothing was sent. Restore the
clipboard afterwards with `pbcopy < /tmp/clip.bak`.

**Fallback when the clipboard is unavailable or must not be touched:** type line by
line with `key` `shift+Return` between lines, all in one batch. Never pass a string
containing `\n` to `type` — **Enter sends** in every one of these UIs.

## Composers

`form_input` fails on all of them — the composers are contenteditable elements, not
form fields ("Element type DIV is not a supported form input"). Always locate the
element with `read_page {filter:"interactive"}` first; **refs shift between page
loads**, so never reuse one from an earlier call.

| Site | Composer element |
| --- | --- |
| claude.ai | `textbox "Write your prompt to Claude"` (localised) |
| chatgpt.com | `textbox "Message ChatGPT"` (localised) |
| gemini.google.com | `textbox "Enter a prompt for Gemini"` (localised; German UI: "Einen Prompt für Gemini eingeben") |
| chat.mistral.ai | unnamed `generic` inside a `form` — no accessible label |
| kimi.com | unnamed `textbox` |

`chat.mistral.ai/chat` may redirect to `/work`. If the task belongs in plain chat, switch
tabs after loading rather than trusting the URL.

Gemini opens at `gemini.google.com/app`. Its default mode is Flash (the mode picker sits
next to the composer); switch to a stronger mode for long videos or dense material. A
"Temporary chat" toggle keeps a one-off ingestion out of the user's Gemini history — use
it when the video is not worth keeping.

## Hand the result back

After sending, the chat URL appears in the tab context. **Give the user that link.**
For a claude.ai skill update it is the whole point — the install button lives in that
chat, and the user acts on it, not you.

Only skills hosted on claude.ai need this detour. Locally installed skills are
files; edit them directly instead.

When the result is *content* (a video summary, a second opinion), read it back with
`get_page_text` and bring it into the conversation rather than sending the user to
the other tab. The link is then a citation, not the deliverable.

## Boundaries

Do not log in, create accounts, or enter API keys and passwords — if a site shows a
login wall, stop and hand it back to the user.

Sending a prompt into a third-party assistant publishes that content to an external
service. Do not paste private code, credentials or client material without the user
saying so for that specific content. A YouTube URL is public by nature; the question
you attach to it may not be.
