# claude-learn

A personal learning assistant for [Claude Code](https://claude.com/claude-code). It turns Claude into an adaptive tutor that tracks your learning goals, teaches interactively, probes for real understanding, assigns homework, and remembers everything across sessions.

## What it does

**`/learn`** gives you a private tutor inside your terminal. Tell it what you want to learn, and it:

- Generates a structured curriculum tailored to your background
- Teaches one concept at a time with pacing that adapts to you
- Asks you to predict before explaining — wrong guesses help your brain encode the answer better (generation effect)
- Probes for mastery at four levels (recall, application, edge cases, connections) — woven into conversation, not as an exam
- Uses a progressive hint ladder when you struggle (nudge → narrow → highlight → worked example → re-teach) instead of just giving the answer
- Runs spaced retrieval reviews at session start — interleaved across topics and goals for stronger retention
- Tracks your confidence calibration — surfaces when you're consistently over/underconfident
- Identifies specific weak sub-skills and generates targeted practice drills
- Connects to your real codebase — references your actual projects in teaching and homework
- Manages session pacing (25-30 min recommended) and parks stuck problems for your brain to process between sessions
- Assigns homework based on what you actually engage with (skips reading? you'll get coding exercises)
- Tracks everything persistently — pick up exactly where you left off days later
- Revises the curriculum as it learns what you know and where you struggle
- Finds cross-connections if you're studying multiple subjects
- Celebrates genuine milestones and tracks your learning streak

**Daily email** (optional) — get a curated reading/watching recommendation each morning based on your current position in the curriculum. Powered by Claude + [Resend](https://resend.com).

## Demo

Here's what a `/learn` session looks like — onboarding a new goal and the first teaching exchange:

https://github.com/user-attachments/assets/038cdfbe-0327-40e6-b43f-523480fef052

## Why not just ask Claude to teach you?

You can — but you'll lose context every conversation. `/learn` adds:

- **Persistent memory** — your curriculum, progress, learner profile, and session history survive across conversations. Session 12 knows what happened in session 1.
- **Mastery gating** — you can't just say "yeah I get it" and move on. The tutor probes at four levels (recall, application, edge cases, connections) before advancing.
- **Spaced retrieval** — past topics resurface at expanding intervals, interleaved across subjects. Research shows this is the single most effective retention technique.
- **Adaptive pacing** — it calibrates over multiple sessions, not just one. If you breezed through topic 3, downstream topics get condensed. If you struggled, bridge topics get inserted.
- **Deliberate practice** — identifies your specific weak sub-skills and generates targeted drills, not vague "review concurrency" but "practice deadlock detection in channel patterns."
- **Homework loop** — it assigns work, then follows up next session. If you never do the reading but always do coding exercises, it adapts. Prefers assignments in your real codebase.
- **Structure without rigidity** — the curriculum evolves based on your actual experience, not a fixed syllabus.

Without `/learn`, every time you start a new Claude conversation, you're back to "I want to learn Go" with zero context. With it, you get continuity.

## Install

```bash
git clone https://github.com/Kornalaarun/claude-learn.git
cd claude-learn
bash install.sh
```

The installer will:
1. Install the `/learn` skill into your Claude Code skills directory — **that's it, you're ready to go**
2. Optionally ask if you want the daily email (say no to skip — you can always set it up later by re-running the installer)
3. If you opt in, schedule the daily email using the right mechanism for your OS:
   - **macOS** — launchd
   - **Linux** — cron
   - **Windows** — Task Scheduler (via Git Bash)

### Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI installed (`npm install -g @anthropic-ai/claude-code`)
- For daily email (optional): a free [Resend](https://resend.com) account and API key, Python 3

## Usage

Open Claude Code and:

```
/learn              # Resume your active goal (shows other goals if you have multiple)
/learn new          # Start a new learning goal (existing goals are preserved)
/learn status       # See your progress (streak, forgetting forecast, weak spots)
/learn plan         # View/discuss your curriculum
/learn list         # List all learning goals with progress bars
/learn switch X     # Switch to a different goal
/learn reset X      # Reset a goal
/learn review       # Run an interleaved review session (spaced retrieval + cross-topic)
/learn practice     # Targeted practice on your weakest sub-skills
/learn export X     # Export a curriculum as shareable JSON
/learn import path  # Import a curriculum file from someone else
```

### How a session works

1. Claude loads your learner profile, progress, and streak
2. Runs spaced retrieval reviews on past topics (interleaved across topics/goals)
3. Revisits any "parked" problems from last session
4. Reviews any pending homework with you
5. Asks what you already know and gets you to predict before explaining (generation effect)
6. Teaches the next topic in small, conversational chunks — connecting to your real projects when possible
7. Probes understanding with a progressive scaffold — hints before answers, confidence checks along the way
8. Identifies weak sub-skills and offers targeted practice
9. Adjusts the curriculum if topics are too easy or too hard
10. Assigns tailored homework (prefers your real codebase over toy exercises)
11. Suggests a break at ~25-30 minutes — shorter focused sessions beat marathons
12. Saves everything so the next session picks up seamlessly

### Learner profile

The tutor builds a model of how you learn best over time:
- Which explanation styles work for you (code examples, analogies, formal definitions, etc.)
- Your pace preference (calibrated over multiple sessions, not assumed)
- Strengths, growth areas, and specific sub-skill levels
- What types of homework you actually complete
- Confidence calibration — are you over/underconfident on certain topic types?
- Learning streak and milestones

All state is stored locally in `~/.claude/learning/`.

### Multiple goals

You can study multiple subjects at once. When you run `/learn`, it resumes your most recent goal and reminds you about your others:

```
Resuming Go (Golang). [You also have: LLMs & AI Agents — /learn switch llms-and-ai-agents]
```

Starting a new goal with `/learn new` never overwrites existing ones — it just sets the new goal as active. Spaced reviews pull from all your goals, so you stay sharp on everything.

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
        review-schedule.json              # Spaced retrieval prompts with review dates
        practice-log.json                 # Deliberate practice session records
        curriculum-revisions.json         # Logged curriculum changes
    exports/
      <goal-slug>-curriculum.json         # Exported shareable curricula
```

## License

MIT
