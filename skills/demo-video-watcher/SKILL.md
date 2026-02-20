---
name: demo-video-watcher
description: Watch demo videos linked in GitHub issue/PR comments. Downloads the video, transcribes audio with whisper and extracts frames. Use when encountering a video URL in a teamniteo or mayetrx repository.
argument-hint: "<GitHub comment URL or video attachment URL>"
allowed-tools:
  - Bash(curl *)
  - Bash(file *)
  - Bash(ls *)
  - Bash(mkdir *)
  - Bash(nix-shell *)
  - Glob
  - Read
  - mcp__github__issue_read
  - mcp__github__pull_request_read

---

# Demo Video Watcher

Extract context from demo videos linked in GitHub issues or PR comments.
These are typically User Story demos — screen recordings with narration
showing the implemented feature.

<parse-input>

Parse `$ARGUMENTS` to extract a video URL. Accept:

- GitHub comment URL: `https://github.com/<owner>/<repo>/issues/<n>#issuecomment-<id>`
  — fetch the comment via `mcp__github__issue_read` (method: `get_comments`) to find the video attachment URL.
- GitHub PR comment URL: `https://github.com/<owner>/<repo>/pull/<n>#issuecomment-<id>`
  — fetch via `mcp__github__pull_request_read` (method: `list_comments`) to find the video attachment URL.
- Direct video URL: `https://github.com/user-attachments/assets/<uuid>`

If `$ARGUMENTS` is empty, use `AskUserQuestion` to ask for the URL.

</parse-input>

<download>

GitHub user-attachment URLs require authentication. Download with:

```bash
curl -sL -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" \
  -o /tmp/demo-video.mp4 "<VIDEO_URL>"
```

Verify the download:

```bash
ls -lh /tmp/demo-video.mp4 && file /tmp/demo-video.mp4
```

If the file is tiny (< 1KB) or contains "Not Found", the download failed.

</download>

<transcribe>

Audio transcription gives the best context. Always do this first.

1. Check for audio track:
```bash
nix-shell -p ffmpeg --run "ffprobe -i /tmp/demo-video.mp4 2>&1 | grep Audio"
```

2. Extract audio:
```bash
nix-shell -p ffmpeg --run \
  "ffmpeg -y -i /tmp/demo-video.mp4 -vn -acodec pcm_s16le -ar 16000 -ac 1 /tmp/demo-audio.wav"
```

3. Transcribe with whisper:
```bash
nix-shell -p openai-whisper --run \
  "whisper /tmp/demo-audio.wav --model tiny --language en --output_format txt --output_dir /tmp/demo-transcript"
```

Present the transcription with timestamps.

</transcribe>

<extract-frames>

After audio transcription, extract frames to capture visual context.

```bash
mkdir -p /tmp/demo-frames
nix-shell -p ffmpeg --run \
  "ffmpeg -i /tmp/demo-video.mp4 -vf 'fps=1' -q:v 2 /tmp/demo-frames/frame_%03d.jpg"
```

Use `fps=0.5` for longer videos (> 60s) or `fps=2` for short ones (< 10s)
where detail matters.

View frames with the Read tool. Start with a sample (every 5th frame) to
get an overview, then fill in gaps if needed.

</extract-frames>

<output>

Provide a concise summary of what the demo shows and append the full transcript and key frames.

</output>
