# claude-learn

A personal learning assistant for [Claude Code](https://claude.com/claude-code). It turns Claude into an adaptive tutor that tracks your learning goals, teaches interactively, probes for real understanding, assigns homework, and remembers everything across sessions.

## What it does

**`/learn`** gives you a private tutor inside your terminal. Tell it what you want to learn, and it:

- Generates a structured curriculum tailored to your background
- Teaches one concept at a time with pacing that adapts to you
- Probes for mastery at four levels (recall, application, edge cases, connections) — woven into conversation, not as an exam
- Assigns homework based on what you actually engage with (skips reading? you'll get coding exercises)
- Tracks everything persistently — pick up exactly where you left off days later
- Revises the curriculum as it learns what you know and where you struggle
- Finds cross-connections if you're studying multiple subjects

**Daily email** (optional) — get a curated reading/watching recommendation each morning based on your current position in the curriculum. Powered by Claude + [Resend](https://resend.com).

## Demo

Here's what a `/learn` session looks like — onboarding a new goal and the first teaching exchange:

https://github.com/user-attachments/assets/038cdfbe-0327-40e6-b43f-523480fef052

## Why not just ask Claude to teach you?

You can — but you'll lose context every conversation. `/learn` adds:

- **Persistent memory** — your curriculum, progress, learner profile, and session history survive across conversations. Session 12 knows what happened in session 1.
- **Mastery gating** — you can't just say "yeah I get it" and move on. The tutor probes at four levels (recall, application, edge cases, connections) before advancing.
- **Adaptive pacing** — it calibrates over multiple sessions, not just one. If you breezed through topic 3, downstream topics get condensed. If you struggled, bridge topics get inserted.
- **Homework loop** — it assigns work, then follows up next session. If you never do the reading but always do coding exercises, it adapts.
- **Structure without rigidity** — the curriculum evolves based on your actual experience, not a fixed syllabus.

Without `/learn`, every time you start a new Claude conversation, you're back to "I want to learn Go" with zero context. With it, you get continuity.

## Install

```bash
git clone https://github.com/Kornalaarun/claude-learn.git
cd claude-learn
bash install.sh
```

The installer will:
1. Copy the `/learn` skill into your Claude Code skills directory
2. Optionally set up the daily email (prompts for Resend API key and email address)
3. Schedule the daily email using the right mechanism for your OS:
   - **macOS** — launchd
   - **Linux** — cron
   - **Windows** — Task Scheduler (via Git Bash)

### Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI installed (`npm install -g @anthropic-ai/claude-code`)
- For daily email: a free [Resend](https://resend.com) account and API key
- Python 3 (for JSON escaping in the email script)

## Usage

Open Claude Code and:

```
/learn new          # Start a new learning goal
/learn              # Resume where you left off
/learn status       # See your progress
/learn plan         # View/discuss your curriculum
/learn list         # List all learning goals
/learn switch X     # Switch to a different goal
/learn reset X      # Reset a goal
```

### How a session works

1. Claude loads your learner profile and progress
2. Reviews any pending homework with you
3. Teaches the next topic in small, conversational chunks — pausing for your input after each concept
4. Checks your understanding through natural conversation (not rapid-fire quizzes)
5. Adjusts the curriculum if topics are too easy or too hard
6. Assigns tailored homework
7. Saves everything so the next session picks up seamlessly

### Learner profile

The tutor builds a model of how you learn best over time:
- Which explanation styles work for you (code examples, analogies, formal definitions, etc.)
- Your pace preference (calibrated over multiple sessions, not assumed)
- Strengths and growth areas
- What types of homework you actually complete

All state is stored locally in `~/.claude/learning/`.

## Uninstall

```bash
bash uninstall.sh
```

Removes the skill, scheduled task, and email config. Your learning data (goals, progress, profile) is preserved — delete `~/.claude/learning/` manually if you want a clean slate.

## File structure

```
~/.claude/
  skills/learn/
    SKILL.md                              # The skill definition
  learning/
    .env                                  # Resend API key + email (daily email only)
    daily-reading.sh                      # Email script (daily email only)
    daily-reads.md                        # Log of all recommendations
    learner-profile.json                  # Your learning style model
    goals.json                            # Index of all goals
    cross-connections.json                # Links between goals
    goals/
      <goal-slug>/
        curriculum.json                   # Modules and topics
        progress.json                     # Mastery tracking per topic
        sessions.json                     # Session history
        assignments.json                  # Pending homework
        knowledge-map.json                # Strengths, gaps, misconceptions
        curriculum-revisions.json         # Logged curriculum changes
```

## License

MIT
