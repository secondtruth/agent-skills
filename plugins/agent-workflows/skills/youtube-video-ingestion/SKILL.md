---
name: youtube-video-ingestion
license: MIT
description: Bring the content of a YouTube video into the conversation — summary, transcript, timestamps, what the speaker claims — through Gemini, by oracle or in the user's browser, with yt-dlp subtitles as the fallback. Use whenever a task names a YouTube URL or asks what a video says.
---

Gemini reads a public YouTube video straight from its URL, so the URL plus the question
is the whole prompt. The content is the deliverable; the video link and the chat link are
its citations.

## Gemini first: oracle

When the `oracle` CLI is installed, it hands Gemini the video without a browser to drive.
Update it first, through the package manager that installed it (`brew upgrade
steipete/tap/oracle`, `scoop update oracle`):

```bash
oracle --engine browser --model gemini-3-pro --youtube "<url>" -p "<question>" \
  --write-output <scratch>/answer.md
```

Verified September 2026 with oracle 0.21.3: a 40-second video came back summarised in 14
seconds. The first attempt ended in "This operation was aborted"; the repeat with
`--force` went through. oracle reports the model selection as unverified, so record the
model as requested.

## Gemini second: the site

For a long or dense video, the newest model, or a machine without oracle, drive
gemini.google.com through the `driving-ai-chat-websites` skill when available; it knows
the composer, the model picker and how to read the answer back.

1. Open a **Temporary chat** for a video worth one look, so the ingestion stays out of the
   user's Gemini history. Switch to a stronger mode than the default Flash for long
   videos or dense material.
2. Paste the video URL together with the question — a summary, a transcript with
   timestamps, "what does the speaker claim about X". Downloads, transcript tools and
   uploads are unnecessary; the URL alone is enough.
3. Wait for the answer, read it back with `get_page_text`, and bring it into the
   conversation together with the chat link.

## Fallback: subtitles through yt-dlp

Take this route when both Gemini routes are closed: oracle missing or failing twice, the
browser extension unavailable, a login wall, or a retry that still ends in "Something
went wrong". `yt-dlp` comes from the package manager (`brew install yt-dlp`, `scoop
install yt-dlp`) and is updated there before the run, since YouTube breaks old
versions. Work in a scratch
directory, outside the user's project, and fetch the captions without the video:

```bash
cd <scratch> && yt-dlp --skip-download --write-subs --write-auto-subs \
  --sub-langs "<spoken language>" --sub-format vtt --no-simulate \
  --print "%(id)s | %(title)s | %(channel)s | %(upload_date)s | %(duration)s s" \
  -o '%(id)s.%(ext)s' "<url>"
```

Then flatten a copy of the VTT into text; the VTT itself stays, for timestamps.
Auto-captions roll: every line is repeated in the two
or three cues that follow it, so adjacent duplicates go and a line spoken again later
stays:

```bash
sed -e '/-->/d' -e 's/<[^>]*>//g' -e '/^WEBVTT/d' -e '/^Kind:/d' -e '/^Language:/d' \
  -e 's/&nbsp;//g' -e 's/[[:space:]]*$//' <id>.<lang>.vtt | grep -v '^$' | uniq > transcript.txt
```

Verified September 2026 with yt-dlp 2026.08.19:

- `--sub-langs` names the language the video is spoken in (`en`, `de`, or a list such
  as `en,de` when it is unknown). Wildcards such as `en.*` also request YouTube's
  auto-translated variants (`en-de`), which answer with HTTP 429.
- `--print` switches on simulation, so the subtitle files appear only with
  `--no-simulate`.
- Auto-captions carry neither punctuation nor speaker labels; timestamps for a quote
  come from the VTT, before the flattening. Uploaded captions carry no rolling
  duplicates, and the same pipeline leaves them intact.
- A video without captions leaves audio transcription: `yt-dlp -x --audio-format m4a`
  fetches the audio for a local speech-to-text tool (unverified here).

Summarise or quote from the transcript yourself, and record which route produced the
text: Gemini (model and mode as the picker showed them, chat link) or yt-dlp (caption
language, auto-generated or uploaded), with the title, channel, date and duration from
the `--print` line.
