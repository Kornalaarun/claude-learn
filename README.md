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

<video src="demo.mp4" autoplay loop muted playsinline width="100%"></video>

<details>
<summary>Full transcript (text version)</summary>

```
> /learn new

What would you like to learn?

> Go / Golang — I want to be productive in it for backend services

Nice. What's your current experience with Go?

> Zero Go. But I've written a lot of Java and Python, 8 years of backend work

Got it — you'll pick up the syntax fast, so we can skip "what is a variable" and focus
on what makes Go different from what you already know. How much time can you give this
per session, and roughly how many sessions per week?

> 30 min sessions, maybe 3-4x a week

Here's your curriculum:

 Module 1: Go Fundamentals (through the lens of Java/Python)
   1.1  Workspace, modules, and the build system
   1.2  Type system — static typing without the Java ceremony
   1.3  Structs, methods, and interfaces (no classes, no inheritance)
   1.4  Error handling — the Go way vs exceptions
   1.5  Concurrency primitives — goroutines and channels

 Module 2: Building Real Services
   2.1  HTTP servers with net/http and routing
   2.2  JSON, middleware, and request lifecycle
   ...

Let's start with 1.1 — Go's workspace and module system.

Coming from Java, you're used to Maven/Gradle with pom.xml or build.gradle managing
dependencies. Go's equivalent is the module system — but it's dramatically simpler.

A Go module is just a directory with a `go.mod` file. It declares the module's import
path and its dependencies. No XML, no DSL — just a flat text file:

  module github.com/you/myservice

  go 1.22

  require (
      github.com/gorilla/mux v1.8.1
  )

That's it. `go mod init github.com/you/myservice` creates it. `go mod tidy` resolves
and cleans up dependencies automatically. No equivalent of `mvn dependency:tree` headaches.

How's that land? If you think about your Java projects — what feels different so far?

> That's way simpler than Maven. Where do dependencies actually get downloaded to though?
  In Java it's ~/.m2/repository

Good question. Go uses a module cache at ~/go/pkg/mod — similar idea to .m2 but with
one key difference...
```

The tutor adapts to your background (skipping basics you already know), teaches in small chunks, and waits for your input before moving on. Every session picks up exactly where you left off.

</details>

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
