# Part 3 — Agentic Coding & Agent Mode
**Presenter A · ~75 minutes**

> This is the **#1 requested topic** from the poll. 71% of attendees want sub-agents, worktrees, and background agents. We're giving this section the most time.

---

## 3.1 What Is "Agentic" Coding? (5 min)

The shift from **autocomplete → chat → agent** represents a fundamental change in how you interact with AI.

| Mode | You do | AI does |
|---|---|---|
| Autocomplete | Write code | Suggest next tokens |
| Chat/Inline | Ask questions, apply suggestions | Explain and generate |
| **Agent** | Describe the goal | Plans, edits multiple files, runs commands, iterates |

> In agent mode, Cursor acts as an autonomous engineer: it reads files, creates files, runs terminal commands, checks errors, and fixes them — all in a loop until the task is done.

---

## 3.2 Agent Mode: Multi-File Editing (15 min)

### Opening Agent mode
- `Cmd+L` — opens the chat panel
- Switch to the **Agent** tab at the top
- Agent mode = full autonomous multi-file execution loop

### Ask → Edit → Plan → Agent — the escalation pattern

**Ask** — understand first. No edits made.  
**Edit** — one file, diff in-place, with conversation history.  
**Plan** — Agent proposes a numbered step-by-step plan. You review and approve (or edit) before a single file is touched.  
**Agent** — full autonomous execution: edits → runs tests → fixes errors → repeats.

A common pattern:
```
Ask: "How should I restructure this module?"
→ switch to Plan: "OK, plan the refactor"
→ review and approve the plan
→ switch to Agent: it executes the approved plan
```

### Why Plan mode matters
Without Plan mode, Agent jumps straight to editing. With Plan mode you get:
- A chance to catch architectural mistakes *before* any code changes
- A clear scope to agree on with a colleague or reviewer
- A record of what the agent intended to do (useful for PR descriptions)

Use Plan mode whenever the task is large enough that a wrong first step would be expensive to undo.

### Demo: Build a feature end-to-end (10 min)

**Task:** Add a `/health` endpoint to a FastAPI app that returns uptime and version.

```
Cmd+L → Agent tab →

"Add a /health GET endpoint to the FastAPI app in src/app.py.
It should return:
  - status: 'ok'
  - uptime: process uptime in seconds (use time.monotonic)
  - version: read from pyproject.toml

Also add a test in tests/test_health.py using the existing test setup with httpx."
```

Watch Cursor:
1. Read `src/app.py` to understand existing routing
2. Read `pyproject.toml` for version
3. Read an existing test file to match patterns
4. Write the endpoint code
5. Write the test
6. Run the tests → fix any failures
7. Present a diff for review

**Reviewing changes:**
- Each modified file shows a diff
- Accept all: `Cmd+Enter`
- Reject all: `Esc`
- Accept individual files by clicking the checkmark

### Practical tips for Agent mode prompts
- Be specific about **file paths** when you know them
- Describe the **desired behavior**, not implementation details (let it plan)
- Say "match the existing patterns in the codebase" — it will look
- Break very large features into multiple Agent sessions

---

## 3.3 Taming AI Output Quality (10 min)

> Directly addresses the top poll frustrations: hallucinations (29%), shallow fixes (25%), wrong architecture (17%).

### Why AI produces bad output — and what you control

| Root cause | Your lever |
|---|---|
| Missing context | Attach files with `@Files`, use `@Codebase` |
| Wrong architecture/style | Add `.cursor/rules` (see Part 2) |
| Stale conversation | Start a new chat thread |
| Task too broad | Break into smaller, scoped agent sessions |
| Model limitations | Switch to a stronger reasoning model |

### Pattern: "Verify before trusting"

Never accept agent output without validation. Build these into your workflow:

**Step 1: Constrain the output**
```
"Implement the retry logic. Constraints:
- Use tenacity library (already in requirements.txt)
- Match the retry pattern in @src/services/api_client.py
- Do not change the public interface
- Add type hints to all new functions"
```

**Step 2: Ask for self-critique**
```
"Review the code you just wrote. What edge cases are missing?
What would fail under concurrent access?"
```

**Step 3: Run tests as validation**
```
"Run pytest tests/test_retry.py -v and fix any failures."
```

### Spotting hallucinations — red flags to watch for
- Method/function calls that don't exist in the library
- Import paths that look plausible but are invented
- Config options or parameters with incorrect names
- "Works on my machine" logic that assumes specific environment state

### The high-review-burden problem
One attendee noted: "it's faster to write it myself." This is true when:
- You don't provide context → the agent guesses wrong → you fix it manually
- The task is small enough that typing is faster than prompting

It stops being true when:
- You provide rich context (files, rules, examples) → agent gets it right first try
- The task spans multiple files and would take 30+ minutes by hand
- You use Plan mode to catch mistakes before code is written

### Demo
```
1. Agent generates a function with a subtle hallucination (invented API)
2. Show the "verify" pattern: "@Docs [library] — does this method actually exist?"
3. Show self-critique prompt catching an edge case
4. Re-run with constraints → correct output
```

---

## 3.4 Debugging with AI — Including Debug Mode (10 min)

### Layer 1: Inline fix from lint errors
```
Click the red underline → lightbulb → "Fix with AI"
```
Fastest path for type errors and lint violations.

### Layer 2: Terminal error → fix
```
1. Run a command that fails (e.g., pytest output with traceback)
2. In Chat: "@Terminal — fix the error"
→ Cursor reads the terminal output and proposes a fix
```

### Layer 3: AI Debug mode
Debug mode puts Cursor in a **directed problem-solving loop**. The agent:
- Sets breakpoints or adds logging statements autonomously
- Runs the program and reads the output
- Forms a hypothesis and tests it
- Iterates until the bug is isolated or a fix is proposed

```
Cmd+L → Agent tab →
"Debug why the /api/stats endpoint returns 200 but with an empty body
when the request includes a date range filter.

Start by checking @src/api/stats.py, then trace through the service layer.
Run pytest to confirm your fix doesn't break anything."
```

Key difference from normal Chat debugging: you give it the **symptom and reproduction condition**, not a hypothesis. Let it form the hypothesis.

### Layer 4: Stack trace → root cause
For production errors:
```
"Here's a stack trace from a production incident:
[paste trace]

The service is @src/services/payment.py. The error only occurs under
concurrent load. Find the race condition."
```

### Demo
```
1. Introduce a subtle async bug (missing await)
2. Show the symptom: test passes locally, fails under load
3. Agent mode → symptom + reproduction → watch it add logging → find the cause
```

---

## 3.5 Test Generation (5 min)

### Generating tests that match your patterns
```
Select a function → Cmd+L →
"Write unit tests for this function. Cover the happy path, empty input, and error cases.
Match the test style in @tests/test_users.py"
```
Always reference an existing test file — this prevents Cursor from inventing its own structure.

### TDD loop with Agent mode
```
Cmd+L → Agent tab →
"I need validate_email(email: str) -> bool.
First write tests in tests/test_validate.py (they should fail).
Then implement in src/utils/validate.py until all tests pass."
```

### Coverage gap analysis
```
"@Codebase — find all exported functions in src/services/ that have no corresponding test"
```

---

## 3.6 Sub-agents, Worktrees & Cloud Agents (25 min)

> **#1 requested topic — 71% of attendees want this.** This is the headline section.

### Sub-agents — agents spawning agents

In Agent mode, Cursor can spawn **child sub-agents** to handle isolated sub-tasks in parallel, then collect their results. You see this in the agent's reasoning output as it delegates.

You can also orchestrate this explicitly:
```
Cmd+L → Agent tab →
"I need to migrate this app from Flask to FastAPI.

Split the work into parallel workstreams:
1. Sub-task A: Migrate all route handlers in src/api/
2. Sub-task B: Migrate all middleware in src/middleware/
3. Sub-task C: Update all tests in tests/

Complete each independently, then reconcile the results."
```

Best practice: give each sub-task a **clean scope boundary** so sub-agents don't conflict on the same files.

### When sub-agents shine vs. when they don't

| Good fit | Poor fit |
|---|---|
| Tasks with clear file boundaries | Tasks where files depend on each other |
| Independent migrations (API → API) | Tightly coupled refactors |
| Parallel test generation | Sequential workflow (step 2 depends on step 1) |
| Bulk operations (rename, format, lint fix) | Architectural decisions requiring human review |

### Live demo: sub-agent in action
```
Cmd+L → Agent tab →
"Add comprehensive error handling to all endpoint handlers in @src/api/.
Each file should be handled independently:
- Wrap handler bodies in try/except
- Return appropriate HTTP status codes
- Log errors using the logger from @src/utils/logging.py
- Add tests for error paths in the corresponding test file

Process each handler file as a separate sub-task."
```

Watch Cursor spawn sub-agents for each file and work in parallel.

---

### Worktrees — true parallelism across branches

Git worktrees let you check out **multiple branches simultaneously** in separate directories. Combined with multiple Cursor windows, this means multiple agents working in parallel without interfering with each other.

```bash
# Create a worktree for a parallel workstream
git worktree add ../my-project-feature-b feature/stats-api

# Open the worktree in a new Cursor window
cursor ../my-project-feature-b
```

Now you have:
```
Window 1: main branch  → Agent working on auth refactor
Window 2: feature/stats-api → Agent building the new stats endpoint
```
Both run simultaneously. Neither touches the other's files.

**When to use worktrees:**
- Two large features that need to land independently
- Running a long agent task while continuing to work on main
- Code review: open the PR branch in a worktree, ask Cursor to review it
- **Keeping PRs small**: each worktree = one focused feature = one reviewable PR

### Worktrees + small PRs

> One attendee asked for a "polite way to explain that 5000+ line PRs are not normal." Worktrees are part of the answer.

The pattern:
```
1. Break the feature into 3-4 independent pieces
2. Create a worktree per piece: git worktree add ../project-piece-N feature/piece-N
3. Run an agent in each worktree with a focused scope
4. Each piece → one PR → fast review → merge
```

This produces 3-4 PRs of 200-500 lines each instead of one monster PR.

---

### Cloud / Background agents

Cursor's **Background Agent** runs tasks in a sandboxed cloud environment — not on your machine. You kick off a task and can close your laptop; the agent continues running and notifies you when done.

**How to start a background agent task:**
```
Cmd+L → Agent tab → click the "Background" toggle → describe the task → Submit
```

**Best suited for:**
- Tasks that take 15+ minutes (large refactors, bulk migrations)
- Tasks you want to run overnight
- Running a full test suite in a clean environment
- Generating comprehensive test coverage across a module

**What background agents can do:**
- Read/write files, run tests, install packages
- Commit changes to a branch and open a PR

**What they cannot do (yet):**
- Access resources not in the repo (no internal DB, no local secrets)
- Interact with a running local server

### Orchestration pattern: worktree + background agent
```
1. git worktree add ../project-tests tests/migration
2. Open worktree in Cursor → Agent tab → Background agent:
   "Add integration tests for every endpoint in @src/api/
    using the test patterns in @tests/
    Run the suite and fix failures until all pass.
    Commit and open a PR."
3. Continue working in your main window while it runs
```

### Demo: the full parallelism stack (10 min)
```
1. Show git worktree setup — two Cursor windows, two branches
2. Start an agent task in Window 1 (add error handling to API)
3. Start a different agent task in Window 2 (add tests for services)
4. Show sub-agents spawning within each window
5. Show Background Agent toggle and task submission
6. Show how to review and merge the results
7. Clean up: git worktree remove
```

---

## 3.7 Section Recap & Q&A (5 min)

### Key takeaways
1. **Agent mode** = goal-driven autonomous execution; always commit before running
2. **AI output quality** = constrain the prompt, verify with self-critique, validate with tests
3. **AI Debug mode** = give it the symptom, not the hypothesis
4. **Sub-agents** = delegate parallel subtasks with clean scope boundaries
5. **Worktrees** = true parallel agent workstreams across branches (and smaller PRs)
6. **Background agents** = long-running tasks that continue without you

### Common mistakes
- Giving overlapping file scopes to parallel agents — they will conflict
- Using background agents for tasks that require local secrets or running services
- Not committing before any agent task — you need a clean diff to review
- Running agent mode with a vague prompt — the more specific, the less rework
- Accepting agent output without reading the diff — "plausible but wrong" is the biggest risk

### Safety note
> `git worktree` leaves extra directories on disk. Clean up with `git worktree remove <path>` when done.

---

*Next: [Part 4 — Advanced Workflows & Team Practices →](./04-advanced-workflows.md)*
