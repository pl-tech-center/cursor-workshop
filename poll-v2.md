# Cursor Workshop Poll — v2 (Suggested Questions)

*Replaces the original 6-question poll. Designed to produce actionable data for tailoring the workshop.*

---

**Intro text:**
> Help us tailor the upcoming Cursor workshop to be as useful as possible. Takes ~3 minutes. Your answers shape which topics we go deep on and which we skip.

---

### 1. How often do you use Cursor? *(required, single select)*

- I don't use it / never tried it
- I've tried it once or twice
- A few times a month
- A few times a week
- Almost daily
- Daily — it's my primary editor

---

### 2. Which Cursor features have you actually used? *(required, multi-select)*

- Tab autocomplete
- Inline edit (`Cmd+K`)
- Chat — Ask mode (Q&A, explanations)
- Chat — Edit mode (single-file diffs with history)
- Chat — Agent mode (autonomous multi-file execution)
- Chat — Plan mode (agent proposes a plan for approval before acting)
- `.cursor/rules` files
- Custom Commands (`.cursor/commands/`)
- MCP integrations
- Background / Cloud agents
- Git worktrees with Cursor
- None of the above

---

### 3. What do you primarily use Cursor for? *(required, multi-select)*

- Writing new features (greenfield)
- Refactoring existing code
- Debugging and fixing bugs
- Writing tests
- Code review
- Documentation
- Planning / architecture
- None yet

---

### 4. What is your biggest frustration with Cursor today? *(optional, multi-select)*

- Gets the context wrong (uses the wrong files or ignores relevant ones)
- Produces shallow or incorrect fixes
- Generates code with the wrong architecture or style
- Security concerns (what's sent to the AI, agent permissions)
- High review burden — it's faster to write it myself
- Hallucinations — confidently wrong code
- Context window limits on large files
- Don't know which feature to use for a given task
- No real frustrations yet

---

### 5. Which workshop topics are most valuable to you? *(required, multi-select, rank top 3)*

- Context mastery — `@` system, codebase indexing
- Rules & Skills — standardizing AI output for the team
- Prompt engineering — getting consistently good results
- Chat modes (Ask / Edit / Agent / Plan) — knowing which to use when
- Agent mode — autonomous multi-file task execution
- Plan mode — reviewing & approving agent plans before execution
- Sub-agents, worktrees & background agents — parallelism
- MCP — integrating Cursor with Jira, Confluence, GitHub, DBs
- Security & privacy — protecting code, using Cursor as a reviewer
- Spec-Kit — specification-driven development
- BMAD Method — agile AI development lifecycle

---

### 6. How concerned are you about security when using Cursor on this codebase? *(required, single select)*

- Not concerned — it's a safe / public codebase
- Mildly concerned — I'd like to understand the data flow better
- Quite concerned — we have proprietary logic / sensitive data
- Very concerned — we have compliance or regulatory requirements
- I've already thought about this and have controls in place

---

### 7. What stack do you use most? *(required, multi-select)*

- TypeScript / JavaScript
- Python
- Go
- Java / Kotlin
- Ruby
- Rust
- C / C++
- React / Next.js
- Node.js / Express / Fastify
- Other *(free text)*

---

### 8. What are you hoping to walk away with? *(optional, free text)*

> *Share your main learning goal or the specific problem you want to solve.*

---

## Changes from v1 and rationale

| v1 Question | Problem | Fix |
|---|---|---|
| Q1: Frequency only | Doesn't distinguish depth of usage | Added Q2: features actually used |
| Q2: "What for" — "Development" too vague | Can't act on it | Replaced with specific task list (Q3) |
| Q3: Frustrations — missing hallucinations, context limits, "which tool" confusion | Misses common blockers | Added those options (Q4) |
| Q4: Topic interests — security missing despite Q3 having it as a frustration | Broken mapping | Added security as explicit topic option (Q5) |
| Q4: Topic interests — didn't cover prompt engineering | Gap | Added (Q5) |
| Q5: Stack — free text only | Won't aggregate across respondents | Structured multi-select with Other fallback (Q7) |
| No security concern depth | Presenter can't gauge urgency | Added Q6 on security posture |
