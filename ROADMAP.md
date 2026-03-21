# Product Roadmap: claude-learn

**North Star:** A patient personal tutor for everyone. Mastery over checkboxing.

---

## The Research Foundation

This roadmap is grounded in learning science, not feature brainstorming. Every phase maps to proven research:

| Principle | Source | Effect Size | Status |
|---|---|---|---|
| 1-on-1 tutoring with mastery learning | Bloom (1984), VanLehn (2011) | d=0.79 | Partially implemented |
| Mastery gates (don't advance with gaps) | Kulik et al. (1990), Khan Academy | d=0.52-0.94 | Implemented |
| Spaced retrieval practice | Ebbinghaus (1885), Dunlosky (2013) | High utility | **Not implemented** |
| Desirable difficulties (interleaving, generation) | Bjork (1994) | Robust, varies | **Not implemented** |
| Scaffolding at the ZPD boundary | Vygotsky (1978), Wood/Bruner (1976) | Core mechanism | Partially implemented |
| Metacognitive prompting | EEF meta-analysis | +7 months progress | **Not implemented** |
| Student-as-teacher (protege effect) | Coleman et al. (1997), Feynman Technique | ~50% retention gain | Partially implemented |
| Guardrails against over-reliance | Bastani et al. (2024) | Negative without | Implemented |
| Engagement sustainability | Stanford CEPA (2025) | 60% drop at 3 weeks | **Not addressed** |

**The biggest gaps are spaced repetition, desirable difficulties, metacognition, and engagement retention.** These are the highest-leverage improvements available.

---

## Phase 0: Foundation (Current — v0.1) ✅

What exists today:

- Curriculum generation from learner background
- Chunked teaching with pace check-ins
- 4-level mastery probing woven into conversation
- Homework assignment and follow-up
- Adaptive learner profile (explanation style, pace, strengths/gaps)
- Adaptive curriculum revision (insert bridge topics, condense easy ones)
- Cross-goal connections
- Session recovery on abrupt exits
- Daily curated reading email via Resend
- Cross-platform install (macOS/Linux/Windows)

**What the research says about v0.1:** We have the core tutoring loop (Bloom) and mastery gating (Kulik). The pacing improvements address the Harvard RCT finding that pedagogical design matters more than model capability. But we're missing the retention mechanisms that make learning *stick*.

---

## Phase 1: Depth of Learning (v0.2 — v0.4)

*Theme: Make learning stick, not just feel good in the moment.*

### 1.1 Spaced Retrieval Engine

**Research basis:** Dunlosky et al. (2013) rated practice testing and distributed practice as the *only* two "high utility" learning strategies out of 10 studied. Roediger & Karpicke (2006) showed retrieval practice produces ~50% better retention after one week vs. re-studying. Andy Matuschak's Mnemonic Medium proved that spaced repetition builds *conceptual understanding*, not just rote recall, when prompts target connections and implications.

**What to build:**
- After mastering a topic, the system generates 3-5 **conceptual retrieval prompts** (not flashcard trivia — "why does X work this way?" not "what is X?")
- Prompts are stored in a new `review-schedule.json` per goal
- At the start of each session, before new teaching, run 2-3 spaced reviews from past topics
- Implement expanding intervals: 1 day → 3 days → 7 days → 14 days → 30 days (adjustable per-user based on recall accuracy)
- Track per-prompt recall strength; retire prompts that hit "durable" status
- **Critical design choice (from Matuschak):** Embed review into the learning flow itself. Don't make it a separate "review mode" the learner has to opt into

**Success metric:** Learner can recall and apply concepts from 4+ weeks ago without re-teaching.

### 1.2 Generation Before Explanation

**Research basis:** Bjork's generation effect — self-generated information is more durable than passively received information. "Make It Stick" calls this the most underused learning principle. Ericsson's deliberate practice research shows that struggling with a problem before seeing the solution builds stronger mental representations.

**What to build:**
- Before teaching a new topic, ask the learner to *predict* or *attempt* first: "Before I explain how Go handles concurrency, what would you guess based on what you know about goroutines and your experience with Java threads?"
- Don't correct immediately — let them think, generate hypotheses, struggle productively
- Then teach, highlighting where their prediction was right and where it diverged
- This leverages two mechanisms: generation effect + the "hypercorrection effect" (confidently wrong predictions are corrected more durably than uncertain ones)

**Success metric:** Learners who generate-then-learn retain more than learners who just receive explanations (measurable via spaced review accuracy).

### 1.3 Progressive Scaffolding (Wood/Bruner's 6 Functions)

**Research basis:** Wood, Bruner & Ross (1976) identified six scaffolding functions that effective tutors use. Currently the skill has binary mastery probing — the learner either gets it or doesn't. Real tutoring uses a graduated hint system.

**What to build:**
- When a learner struggles on a probe, don't immediately re-explain. Use a hint ladder:
  1. **Nudge** — "Think about what happens when..." (direction maintenance)
  2. **Narrow** — "Focus specifically on the relationship between X and Y" (reduction of degrees of freedom)
  3. **Highlight** — "Remember, the key insight was..." (marking critical features)
  4. **Worked example** — walk through a parallel problem step-by-step (demonstration)
  5. **Direct re-teach** — only as a last resort
- Track which scaffolding level each learner typically needs — this is a powerful signal for the learner profile
- Implement **fading** — as the learner progresses, start at lower scaffolding levels

**Success metric:** Learners need decreasing scaffolding levels over time for comparable difficulty topics.

### 1.4 Metacognitive Prompting

**Research basis:** EEF meta-analysis rates metacognition as producing +7 months of additional progress. Expert learners differ from novices primarily in their ability to monitor their own understanding. Novices have poor calibration — they don't know what they don't know.

**What to build:**
- Before a topic: "What do you already know about this? What do you think will be the hard part?"
- During learning: "Is this making sense so far? What specifically is clicking or not clicking?"
- After mastery probing: "How confident were you before I asked that question? How confident are you now?"
- Track **calibration accuracy** over time — compare learner's self-assessed confidence to actual probe performance
- Surface calibration insights: "I've noticed you tend to feel confident on X-type topics but struggle on the probes — that's actually really common and worth paying attention to"
- Every 5 sessions, prompt a **learning reflection**: "What's the most important thing you've learned? What's still fuzzy? What would you teach differently now?"

**Success metric:** Calibration accuracy improves over time (confidence predicts performance).

---

## Phase 2: Retention & Transfer (v0.5 — v0.8)

*Theme: Learning that transfers to real work, not just session performance.*

### 2.1 Interleaving and Desirable Difficulties

**Research basis:** Bjork's research shows interleaving different problem types during practice produces superior long-term retention and transfer vs. blocked practice — even though it *feels* harder and learners rate it as less effective. Epstein ("Range") shows breadth of training predicts breadth of transfer.

**What to build:**
- During review sessions, interleave probes from *different* topics rather than reviewing topic-by-topic
- When teaching a new topic, deliberately reference and mix in elements from earlier topics — "Let's solve this Go concurrency problem, but this time think about the error handling patterns we discussed last week too"
- **Vary contexts** — present the same concept in different scenarios, different code examples, different domains
- Cross-goal interleaving — if someone is learning Go and system design simultaneously, create probes that require both
- **Transparency about difficulty** — explicitly tell the learner: "This is going to feel harder than studying one topic at a time, but the research shows it produces much better long-term retention. Trust the process."

**Success metric:** Performance on novel/transfer problems (not just recall of taught examples).

### 2.2 Deliberate Practice Engine

**Research basis:** Ericsson's research ("Peak") shows expert performance comes from practice that is: (1) at the edge of current ability, (2) focused on specific weaknesses, (3) accompanied by immediate feedback. Young ("Ultralearning") adds: identify the weakest sub-skill and drill it specifically.

**What to build:**
- Analyze knowledge-map.json to identify the learner's *specific* weak sub-skills (not just "weak on concurrency" but "weak on reasoning about channel deadlocks specifically")
- Generate targeted practice problems that drill exactly those weak spots
- Practice problems should be *slightly* beyond current ability — not easy wins, not impossible
- Immediate, specific feedback — not just "that's wrong" but "your reasoning breaks down at step 3 because you're not accounting for..."
- Track improvement on specific sub-skills over time

**Success metric:** Targeted weak sub-skills improve to "strong" within 2-3 focused practice sessions.

### 2.3 Connect to Real Work (Directness)

**Research basis:** Young's "directness" principle — learning is most effective when done in the context where the skill will actually be used. For software engineers, that means connecting to actual code, actual systems, actual problems.

**What to build:**
- If the learner is studying Go and has Go projects on their machine, reference their actual code in explanations: "Look at your handler in `main.go` — this is where the goroutine pattern we discussed would apply"
- Homework that involves the learner's real codebase, not toy examples: "Refactor the error handling in your API service using the patterns we covered"
- When the learner asks Claude Code for help with real work, detect when it relates to an active learning goal and make the connection: "This is exactly the concurrency pattern from topic 1.5 — want to apply what you learned instead of me just giving you the answer?"
- Project-based milestones in the curriculum — not just "understand X" but "build Y using X"

**Success metric:** Learner applies concepts from `/learn` sessions in their actual work without prompting.

### 2.4 Session Pacing & Diffuse Mode Support

**Research basis:** Oakley ("A Mind for Numbers") shows the brain has focused and diffuse modes. Marathon study sessions produce diminishing returns. The Pomodoro Technique (25 min focused, 5 min break) leverages both modes. Stepping away from a stuck problem often triggers breakthroughs via the diffuse mode.

**What to build:**
- Track session duration. After 25-30 minutes of active teaching, suggest a natural break: "Good stopping point — let this settle. We'll pick up with [next concept] next time."
- When the learner is stuck on a probe after 2-3 attempts, don't keep drilling. Say: "Let's park this one. Your brain will keep working on it in the background. We'll revisit it next session." (This is not giving up — it's leveraging diffuse mode.)
- Never let a session exceed 45 minutes of active teaching without explicit learner request
- Between sessions, the daily email serves as a diffuse-mode trigger — light reading that keeps the topic active without focused effort

**Success metric:** Learners report "aha" moments between sessions. Previously-stuck problems resolve more quickly in subsequent sessions.

---

## Phase 3: Community & Engagement (v0.9 — v1.2)

*Theme: Solve the engagement cliff. Learning alone is hard to sustain.*

### 3.1 The Engagement Problem

**Research basis:** Stanford CEPA (2025) found student engagement with AI tutors drops 60% after 3 weeks without teacher facilitation. Khanmigo sees significant results only with 30+ min/week sustained usage. The biggest risk to this product isn't bad pedagogy — it's abandonment.

### 3.2 Learning Streaks & Progress Visibility

**What to build:**
- Visible streak counter (sessions per week, weekly goals)
- Progress visualization — curriculum map showing mastered/in-progress/upcoming topics
- "Forgetting forecast" — show which mastered topics are approaching their review interval: "3 topics due for review this week — 10 minutes total"
- Weekly summary email alongside the daily reading: "This week you mastered 2 topics, reviewed 5, and your longest streak is 8 sessions"
- Milestone celebrations that are *genuine*, not participation trophies — "You just demonstrated you can reason about edge cases in Go's type system. That's a real skill most Go developers take months to develop."

### 3.3 Shareable Curricula & Community Library

**What to build:**
- `export` and `import` already exist in the command routing but aren't implemented
- Export a curriculum + progress as a shareable JSON/markdown
- Community curriculum library — browse and import curricula that others have used and refined
- "Fork" a curriculum — start from someone else's structure, customize to your background
- Curriculum ratings — which paths have the highest completion rates and mastery scores?
- This creates a network effect: every learner who completes a curriculum makes it better for the next one

### 3.4 Study Groups (Protege Effect at Scale)

**Research basis:** Coleman et al. (1997) showed teaching others significantly enhances learning. Mazur's peer instruction research shows explaining concepts to peers builds deeper understanding. The protege effect means the *teacher* learns more than the student.

**What to build:**
- Pair learners studying similar material (opt-in)
- Each session, one person "teaches" a recently-mastered concept to the other (the AI facilitates)
- The AI monitors the explanation for accuracy and fills gaps
- Both learners get mastery credit — the teacher for demonstrating deep understanding, the student for learning
- Async-friendly — leave a 2-minute voice/text explanation of a concept; your study partner reviews it next session
- Leaderboards? Maybe. Research is mixed. Motivation for some, anxiety for others. Make it opt-in.

### 3.5 Teacher/Mentor Mode

**Research basis:** The CEPA finding that engagement drops without teacher facilitation suggests a pure self-service model has a ceiling. For organizational deployment, someone needs to play the facilitator role.

**What to build:**
- A mentor can view a learner's progress, knowledge map, and session history
- The mentor can add notes, adjust the curriculum, or flag topics for review
- Weekly mentor digest: "Here's where your team is. 3 people are stuck on topic X — consider a group session."
- For teams: shared curricula with individual progress tracking
- Does NOT replace the AI tutor — supplements it with human accountability

---

## Phase 4: North Star (v2.0+)

*Theme: A patient personal tutor for everyone.*

### 4.1 Beyond Software Engineering

The current skill assumes the learner is a developer using Claude Code. The pedagogy is universal. Expand to:
- Languages (with conversational practice via voice)
- Mathematics (with step-by-step problem solving)
- Sciences (with interactive experiments and simulations)
- Music (with theory and practice tracking)
- Any structured subject where mastery can be assessed

This requires decoupling the curriculum engine and mastery probing from the Claude Code CLI.

### 4.2 Voice-First Interaction

**Research basis:** The Harvard RCT (Kestin et al., 2025) found AI tutoring was most effective when it felt like a *conversation*. Text-in-terminal has friction. Voice reduces that friction dramatically.

- Voice input/output for teaching sessions (think: study partner you talk to while walking)
- The AI can hear hesitation, confusion, confidence in tone
- "Explain this back to me" works much better spoken than typed

### 4.3 Multimodal Teaching

- Draw diagrams, show visualizations, render code execution
- Learner can sketch their understanding; AI interprets and gives feedback
- For visual/spatial learners, this is transformative

### 4.4 Adaptive Assessment as a Service

The mastery probing engine, spaced repetition scheduler, and learner model are valuable independent of the teaching content. These could become:
- An API that any educational content creator can plug into
- A standard for "learning state" that's portable across tools
- Integration with existing learning platforms (Coursera, Udemy, O'Reilly)

### 4.5 Solving the 2 Sigma Problem

Bloom asked: can we find group instruction methods as effective as 1-on-1 tutoring? The research says the realistic ceiling is ~0.8 sigma. But we're not constrained by group instruction. Every learner gets 1-on-1 AI tutoring, with:

- Personalized pacing (Phase 0 ✅)
- Mastery gating (Phase 0 ✅)
- Spaced retrieval (Phase 1)
- Desirable difficulties (Phase 2)
- Metacognitive coaching (Phase 1)
- Connection to real work (Phase 2)
- Social accountability (Phase 3)

Stacked together, these are the conditions under which Bloom's students achieved 2 sigma. No single intervention does it. The combination might.

---

## Prioritization Framework

When choosing what to build next, score each feature on:

1. **Research effect size** — how strong is the evidence that this improves learning?
2. **Retention impact** — does this bring learners back, or just improve a single session?
3. **Implementation complexity** — how hard is this to build with the current architecture?
4. **Uniqueness** — can learners get this elsewhere, or is this something only an AI tutor can do?

| Feature | Effect Size | Retention | Complexity | Uniqueness | Priority |
|---|---|---|---|---|---|
| Spaced retrieval engine | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★☆☆ | **P0** |
| Generation before explanation | ★★★★☆ | ★★★☆☆ | ★★☆☆☆ | ★★★★☆ | **P0** |
| Metacognitive prompting | ★★★★☆ | ★★★☆☆ | ★★☆☆☆ | ★★★★★ | **P0** |
| Progressive scaffolding | ★★★★☆ | ★★★☆☆ | ★★★☆☆ | ★★★★☆ | **P1** |
| Interleaving | ★★★★☆ | ★★★★☆ | ★★★☆☆ | ★★★☆☆ | **P1** |
| Connect to real work | ★★★☆☆ | ★★★★★ | ★★★★☆ | ★★★★★ | **P1** |
| Deliberate practice engine | ★★★★★ | ★★★★☆ | ★★★★☆ | ★★★★☆ | **P1** |
| Streaks & progress visibility | ★★☆☆☆ | ★★★★★ | ★★☆☆☆ | ★☆☆☆☆ | **P2** |
| Session pacing / diffuse mode | ★★★☆☆ | ★★★☆☆ | ★☆☆☆☆ | ★★★☆☆ | **P2** |
| Shareable curricula | ★☆☆☆☆ | ★★★★☆ | ★★★☆☆ | ★★☆☆☆ | **P2** |
| Study groups | ★★★★☆ | ★★★★★ | ★★★★★ | ★★★★☆ | **P3** |
| Voice interaction | ★★★☆☆ | ★★★★☆ | ★★★★★ | ★★★☆☆ | **P3** |

---

## Key Risks

1. **The 3-week cliff** — Stanford CEPA shows 60% engagement drop. Spaced retrieval (Phase 1) and progress visibility (Phase 3) are the primary mitigations. If learners don't come back, nothing else matters.

2. **Over-reliance** — Bastani et al. showed raw AI access hurts learning. Every feature must ask: "Does this make the learner think harder, or does it let them think less?" If the answer is less, don't ship it.

3. **Illusion of mastery** — "Make It Stick" warns that fluent explanations feel like understanding but aren't. Our mastery probing addresses this, but it must remain rigorous. The temptation to soften probing for engagement is a trap.

4. **Scope creep into platform** — Phases 3-4 move toward a platform. The core value is the tutor quality. Don't sacrifice depth for breadth.

---

## References

- Bloom, B. (1984). "The 2 Sigma Problem." *Educational Researcher.*
- Bjork, R. (1994). "Memory and Metamemory Considerations in the Training of Human Beings."
- Bjork, R. & Bjork, E. (2020). "Desirable Difficulties in Theory and Practice."
- Brown, P., Roediger, H., & McDaniel, M. (2014). *Make It Stick.*
- Dunlosky, J. et al. (2013). "Improving Students' Learning With Effective Learning Techniques." *Psychological Science in the Public Interest.*
- Epstein, D. (2019). *Range: Why Generalists Triumph in a Specialized World.*
- Ericsson, A. & Pool, R. (2016). *Peak: Secrets from the New Science of Expertise.*
- Kestin, G. et al. (2025). "AI Tutoring Outperforms Active Learning." *Scientific Reports.*
- Kulik, C., Kulik, J., & Bangert-Drowns, R. (1990). "Effectiveness of Mastery Learning Programs." *Review of Educational Research.*
- Matuschak, A. & Nielsen, M. (2019). "How Can We Develop Transformative Tools for Thought?"
- Oakley, B. (2014). *A Mind for Numbers.*
- Roediger, H. & Karpicke, J. (2006). "Test-Enhanced Learning." *Psychological Science.*
- VanLehn, K. (2011). "The Relative Effectiveness of Human Tutoring, Intelligent Tutoring Systems, and Other Tutoring Systems." *Educational Psychologist.*
- Vygotsky, L. (1978). *Mind in Society.*
- Wood, D., Bruner, J., & Ross, G. (1976). "The Role of Tutoring in Problem Solving." *Journal of Child Psychology and Psychiatry.*
- Young, S. (2019). *Ultralearning.*
- Bastani, H. et al. (2024). "Generative AI Can Harm Learning." Working paper.
- Stanford CEPA (2025). "AI Tutors in Schools." Policy brief.
