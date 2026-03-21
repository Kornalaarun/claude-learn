#!/usr/bin/env bash
# Daily learning recommendation — generates via Claude CLI and emails via Resend
# Works on macOS, Linux, and Windows (Git Bash)

set -euo pipefail

LEARNING_DIR="$HOME/.claude/learning"
OUTPUT_FILE="$LEARNING_DIR/daily-reads.md"
ENV_FILE="$LEARNING_DIR/.env"

# Load config
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found. Run install.sh first." >&2
  exit 1
fi
source "$ENV_FILE"

if [ -z "${RESEND_API_KEY:-}" ] || [ -z "${LEARNING_EMAIL:-}" ]; then
  echo "Error: RESEND_API_KEY and LEARNING_EMAIL must be set in $ENV_FILE" >&2
  exit 1
fi

# Find claude CLI
if command -v claude &>/dev/null; then
  CLAUDE_CMD="claude"
elif [ -f "$HOME/AppData/Roaming/npm/claude" ]; then
  CLAUDE_CMD="$HOME/AppData/Roaming/npm/claude"
elif [ -f "$HOME/.npm-global/bin/claude" ]; then
  CLAUDE_CMD="$HOME/.npm-global/bin/claude"
else
  echo "Error: claude CLI not found in PATH" >&2
  exit 1
fi

# Skip weekends
DAY_OF_WEEK=$(date +%u)
if [ "$DAY_OF_WEEK" -eq 6 ] || [ "$DAY_OF_WEEK" -eq 7 ]; then
  exit 0
fi

TODAY=$(date +%Y-%m-%d)

# Find the active learning goal
GOALS_DIR="$LEARNING_DIR/goals"
if [ ! -d "$GOALS_DIR" ]; then
  echo "Error: No learning goals found. Start one with /learn new first." >&2
  exit 1
fi

# Build context about available goals for the prompt
GOAL_LIST=""
for goal_dir in "$GOALS_DIR"/*/; do
  if [ -d "$goal_dir" ]; then
    goal_name=$(basename "$goal_dir")
    GOAL_LIST="$GOAL_LIST- ~/.claude/learning/goals/$goal_name/curriculum.json\n- ~/.claude/learning/goals/$goal_name/progress.json\n"
  fi
done

PROMPT=$(cat <<PROMPT_EOF
You are a daily learning curator. Find ONE (max two) high-quality recommendations for a learner.

## Context

Read these files to understand where the learner is:
- ~/.claude/learning/learner-profile.json
$(echo -e "$GOAL_LIST")

Based on the learner profile and current progress, recommend something that matches their level and interests.

## What to recommend

Vary the type across days. Pick from:

**Blog posts & articles** — In-depth technical posts, illustrated explainers, seminal papers
**Books** — Specific chapters or sections (not "go read this 500-page book")
**Podcast episodes** — Specific episodes, not whole podcasts
**People to follow** — Researchers, builders, or thinkers sharing insights. Explain why with examples
**Videos & talks** — Conference talks, technical deep-dives, live coding sessions
**GitHub repos** — Projects to study. Explain what to look at and why
**Papers** — Only if accessible and well-written. Link to arxiv. Suggest which sections to focus on

## Quality bar — be RUTHLESS

HARD AVOID:
- Listicles, shallow overviews, "Top 10 tools"
- Paid course promotions, SEO filler, engagement bait
- Medium posts without real substance
- Pure API wrapper tutorials
- Anything older than 18 months unless it's a classic/foundational piece
- Generic "follow this person" without specific examples of why

## Output format

Output ONLY in this exact HTML format (no preamble, no markdown, no extra text). This will be sent as an email body.

For articles/blogs/papers/videos:
<h3>Daily Pick — $TODAY</h3>
<p><strong><a href="URL">Title</a></strong> by Author Name</p>
<p><em>Type:</em> blog / book chapter / podcast episode / video / paper / repo</p>
<p><em>Why:</em> 1-2 sentences connecting to current learning position.</p>
<p><em>Time:</em> ~X min</p>

For a person to follow:
<h3>Worth Following — $TODAY</h3>
<p><strong><a href="profile URL">Name</a></strong> — one-line description</p>
<p><em>Platform:</em> Twitter/X, YouTube, GitHub, etc.</p>
<p><em>Why:</em> 1-2 sentences with a specific example of recent great content.</p>
<p><em>Start with:</em> <a href="URL">specific post/video/thread</a></p>

For a book:
<h3>Book Pick — $TODAY</h3>
<p><strong>Title</strong> by Author Name</p>
<p><em>Focus on:</em> specific chapter(s) or section relevant right now</p>
<p><em>Why:</em> 1-2 sentences connecting to current learning position.</p>
<p><em>Time:</em> ~X min for the recommended section</p>

If nothing meets the quality bar today, output ONLY:
<h3>Daily Pick — $TODAY</h3>
<p><em>No recommendation today — nothing met the quality bar.</em></p>
PROMPT_EOF
)

# Run claude in pipe mode
RESULT=$("$CLAUDE_CMD" -p "$PROMPT" --allowedTools 'Read' 'WebSearch' 'WebFetch' 2>/dev/null) || {
  RESULT="<p>Failed to generate recommendation today (claude error).</p>"
}

# Send email via Resend
EMAIL_BODY=$(cat <<EOF
<div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
  $RESULT
  <hr style="margin-top: 30px; border: none; border-top: 1px solid #eee;">
  <p style="color: #999; font-size: 11px;">Sent by your /learn assistant</p>
</div>
EOF
)

# Escape HTML for JSON — use python3 or python depending on what's available
PYTHON_CMD="python3"
if ! command -v python3 &>/dev/null; then
  PYTHON_CMD="python"
fi
EMAIL_JSON=$(printf '%s' "$EMAIL_BODY" | "$PYTHON_CMD" -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

curl -s -X POST 'https://api.resend.com/emails' \
  -H "Authorization: Bearer $RESEND_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{
    \"from\": \"onboarding@resend.dev\",
    \"to\": [\"$LEARNING_EMAIL\"],
    \"subject\": \"Daily Learn — $TODAY\",
    \"html\": $EMAIL_JSON
  }" > /dev/null 2>&1

# Append to local log
if [ ! -f "$OUTPUT_FILE" ]; then
  cat > "$OUTPUT_FILE" <<'HEADER'
# Daily Reading Recommendations

Curated daily by Claude based on current learning goals.
Quality over quantity — some days may be empty.

HEADER
fi

echo "" >> "$OUTPUT_FILE"
echo "$RESULT" >> "$OUTPUT_FILE"
