---
name: ingesting-youtube-videos
license: MIT
description: Bring the content of a YouTube video into the conversation — summary, transcript, timestamps, what the speaker claims — through Gemini in the user's browser, with yt-dlp subtitles as the fallback. Use whenever a task names a YouTube URL or asks what a video says.
---

Gemini reads a public YouTube video straight from its URL, so the URL plus the question
is the whole prompt. The content is the deliverable; the video link and the chat link are
its citations.

## Gemini first

Drive gemini.google.com through the `driving-ai-chat-websites` skill when available; it
knows the composer, the model picker and how to read the answer back.

1. Open a **Temporary chat** for a video worth one look, so the ingestion stays out of the
   user's Gemini history. Switch to a stronger mode than the default Flash for long
   videos or dense material.
2. Paste the video URL together with the question — a summary, a transcript with
   timestamps, "what does the speaker claim about X". Downloads, transcript tools and
   uploads are unnecessary; the URL alone is enough.
3. Wait for the answer, read it back with `get_page_text`, and bring it into the
   conversation together with the chat link.

Gemini through oracle covers text and images only, and the Gemini CLI stopped serving
individual accounts in September 2026: the website is the route.

## Fallback: subtitles through yt-dlp

Take this route when the browser extension is unavailable, Gemini shows a login wall,
or a retry still ends in "Something went wrong". `yt-dlp` comes from Homebrew
(`brew install yt-dlp`). Fetch the captions without the video:

```bash
yt-dlp --skip-download --write-subs --write-auto-subs --sub-langs "en,de" --sub-format vtt \
  --no-simulate --print "%(title)s | %(channel)s | %(upload_date)s | %(duration)s s" \
  -o '%(id)s.%(ext)s' "<url>"
```

Then flatten the VTT into text — timestamps, tags and the rolling duplicates of
auto-captions removed:

```bash
sed -e '/-->/d' -e 's/<[^>]*>//g' -e '/^WEBVTT/d' -e '/^Kind:/d' -e '/^Language:/d' <id>.<lang>.vtt \
  | grep -v '^[[:space:]]*$' | awk '!seen[$0]++' > transcript.txt
```

Verified September 2026 with yt-dlp 2026.08.19:

- `--sub-langs` names the video's spoken languages. Wildcards such as `en.*` also request
  YouTube's auto-translated variants (`en-de`), which answer with HTTP 429.
- `--print` switches on simulation, so the subtitle files appear only with
  `--no-simulate`.
- Auto-captions carry neither punctuation nor speaker labels; timestamps for a quote
  come from the VTT, before the flattening.
- A video without captions leaves audio transcription: `yt-dlp -x --audio-format m4a`
  fetches the audio for a local speech-to-text tool (unverified here).

Summarise or quote from the transcript yourself, and record which route produced the
text: Gemini (model and mode as the picker showed them, chat link) or yt-dlp (caption
language, auto-generated or uploaded), with the title, channel, date and duration from
the `--print` line.
