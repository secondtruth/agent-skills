---
name: youtube-video-ingestion
license: MIT
description: Bring the content of a YouTube video into the conversation — summary, transcript, timestamps, what the speaker claims — through Gemini, by oracle or in the user's browser, with yt-dlp subtitles as the fallback. Use whenever a task names a YouTube URL or asks what a video says.
---

Gemini reads a public YouTube video straight from its URL, so the URL plus the question
is the whole prompt. The content is the deliverable; the video link and the chat link are
its citations.

## A topic instead of a URL

When the task names a topic ("videos in which someone builds X") rather than a video,
yt-dlp finds the candidates without a browser, with views and duration to rank them by,
and fetches their descriptions, which often carry the prompts, tools and links the video
only shows in passing:

```bash
yt-dlp --flat-playlist --print "%(id)s	%(view_count)s	%(duration)s	%(channel)s	%(title)s" \
  "ytsearch15:<query>"
yt-dlp --skip-download --print-to-file "%(description)s" "<scratch>/%(id)s.desc.txt" "<url>"
```

Several phrasings, in English and in the user's language, widen the net; the results
carry unrelated videos, so sort by title before choosing. The note on YouTube's terms
under the yt-dlp fallback below applies to the search as well. Verified November 2026 with
yt-dlp 2026.11.23: titles can arrive auto-translated into the machine's locale, so the
upload date and channel identify a video better than its title.

## Gemini first: oracle

When the `oracle` CLI is installed, it hands Gemini the video without a browser to drive.
Update it first, through the package manager that installed it (`brew upgrade
steipete/tap/oracle`, `scoop update oracle`):

```bash
oracle --engine browser --model gemini-3-pro --no-gemini-fallback --browser-timeout 10m \
  --youtube "<url>" -p "<question>" --write-output <scratch>/answer.md
```

oracle serves Gemini 3.1 Pro for `gemini-3-pro`; its Gemini route knew no Gemini 4 model
as of 0.23.1. Without `--no-gemini-fallback` an unavailable model drops to Flash-Lite
with nothing but a log line. oracle reports the selection as unverified, so record the
model as requested. `--youtube` only appends a line `YouTube video: <url>` to the prompt;
whether Gemini opens the video is its own decision. A YouTube run aborts after 240
seconds with "This operation was aborted" unless `--browser-timeout` raises the limit
(oracle caps it at 10 minutes).

Several videos run one after another, never in parallel: one oracle run at a time, each
with its own output file and a `--slug` of three to five words (`gta video analysis n7`;
a video ID counts as one word or a few, and oracle refuses the run before it starts).
Verified November 2026 with oracle 0.23.1 on 25 videos of 2 to 50 minutes:

- Half of all attempts came back as a refusal claiming Gemini cannot access YouTube,
  with exit 0, whatever the prompt's wording; a successful run took 2 to 4 minutes.
  Treat an answer of a few hundred bytes as failed and retry with `--force`, up to three
  times; two videos were refused three times in a row.
- Two long answers broke off mid-section with such a refusal appended. Check that every
  section the prompt asked for is present before keeping an answer.
- Gemini reads the screen at about one frame per second and low resolution. Of 97
  on-screen quotes checked against 1080p frames, 56 matched, 21 differed in words,
  numbers or names, and 20 were only partly visible. Short prompts typed into a chat box
  came back right; long prompt documents scrolling past came back reworded. On-screen
  text quoted as verbatim needs the frame check below.

Verified September 2026 with oracle 0.21.3: a 40-second video came back summarised in 14
seconds. The first attempt ended in "This operation was aborted"; the repeat with
`--force` went through.

## Gemini second: the site

For the newest model, a long or dense video, or a machine without oracle, drive
gemini.google.com through the `driving-ai-chat-websites` skill when available; it knows
the composer, the model picker and how to read the answer back. The Antigravity CLI
(`agy`) is no substitute: it reaches the newest Gemini models but not the video — given
a YouTube URL it gets a web-search summary at most, or hands the URL to oracle itself
(November 2026, agy 1.5.18).

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
went wrong". YouTube's terms forbid downloading content and accessing the service by
automated means unless the service, YouTube's written permission or applicable law allows
it, so whether this route runs is the user's call. `yt-dlp` comes from the package
manager (`brew install yt-dlp`, `scoop install yt-dlp`) and is updated there before the
run, since YouTube breaks old versions. Work in a scratch directory, outside the user's
project, and fetch the captions without the video:

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

## Verbatim on-screen text: frames at the timestamps

Gemini finds on-screen text well and copies long text badly. To quote a prompt shown in
the video, take its timestamps from Gemini's answer, fetch one-second sections there at
1080p and read the frames:

```bash
yt-dlp -q -f 'bv*[height<=1080]' --download-sections "*<t>-<t+1>" --download-sections "*<u>-<u+1>" \
  -o '<scratch>/segments/%(section_start)s.%(ext)s' "<url>"
ffmpeg -sseof -0.2 -i <scratch>/segments/<t>.mp4 -frames:v 1 -q:v 2 <scratch>/frames/<t>.jpg
```

This downloads parts of the video, so it waits for the user's go-ahead with the source,
the sections and an estimate of the size; the segments are deleted once the frames are
out. Verified November 2026 with yt-dlp 2026.11.23 and ffmpeg 9.0.2 on eleven videos:

- One-second sections came to about 1 MB each, 12 MB a video for a dozen timestamps.
- ffmpeg on the direct stream URL from `yt-dlp -g` gets HTTP 403; yt-dlp has to fetch
  the sections itself.
- One frame per timestamp often caught a prompt half typed or the facecam instead. Take
  frames across a few seconds and keep the one with the most text.
- Apple Vision OCR (`VNRecognizeTextRequest`) read most frames, but dropped lines, missed
  light-grey chat bubbles and returned nothing on facecam; where it looks thin, read the
  frame itself.

Summarise or quote from the transcript yourself, and record which route produced the
text: Gemini (model and mode as the picker showed them or as oracle requested them, chat
link or session), yt-dlp (caption language, auto-generated or uploaded) or a frame
(timestamp, OCR or read by eye), with the title, channel, date and duration from the
`--print` line.
