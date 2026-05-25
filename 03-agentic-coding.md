# Part 3 — Agentic Coding & Agent Mode
**Presenter A · ~45 minutes**

> This is the **#1 requested topic** from the poll. 71% of attendees want sub-agents, worktrees, and background agents — this section is the longest of the four for that reason.
>
> All demos and exercises target the CV Builder app at `../cv-builder`.

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

### Demo: Scaffold a new section via Spec-Kit (10 min)

**Task:** Add a new "Volunteering" section to the CV Builder using the full Spec-Kit workflow. This previews Part 4 (Skills + Spec-Kit) but also showcases Agent mode's ability to chain skills, plans, and multi-file edits.

```
Cmd+L → Agent tab →

"Use /speckit-specify to add a Volunteering section to the resume builder.

The section should:
- Appear as a new tab in the navigation, between Projects and Certifications
- Support repeatable entries with: organisation, role, location, start/end month (with 'Currently volunteering' toggle), and bullet-point activities
- Render in the PDF using the same \\resumeSubheading custom command as Experience and Education
- Be conditional — omitted from the PDF when no entries exist
- Follow every convention captured in @specs/001-resume-builder/plan.md (file layout, design tokens, test patterns)

After /speckit-specify completes, run /speckit-plan, then /speckit-tasks, then implement the tasks.
Run npm test after implementation to confirm nothing broke."
```

Watch Cursor:
1. Invoke `speckit-specify` → produce `specs/002-volunteering-section/spec.md` with user stories, FRs, success criteria
2. Invoke `speckit-plan` → produce `plan.md`, `research.md`, `data-model.md`, `contracts/`
3. Invoke `speckit-tasks` → produce `tasks.md` decomposed by user story
4. Execute the tasks: new `VolunteeringEntry` interface, `VolunteeringForm.tsx`, `generateVolunteering()` generator, vitest cases, registration in `App.tsx`
5. Run `npm test` → fix any failures
6. Present a single reviewable diff

> This is the **Spec-Kit-driven** way to use Agent mode for anything bigger than a few files. Part 4 covers the skills in detail; here we're just showing the loop.

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

### UI tips for reading agent output
- **Compact chat responses** — customise how much detail tool calls show in the chat panel: `Compact` (minimal — just outcomes), `Balanced` (default), or `Detailed` (full tool call output). Set it via the density toggle at the top of the chat. Use Compact when the agent is churning through many files and you only care about the result.
- **Full-screen tabs** — press `Cmd+Shift+M` (or `Ctrl+Shift+M`) to maximise the right panel into a full-screen tab. Useful when reviewing a large diff or reading a long agent response without the sidebar competing for space. Press again to restore.

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
"Add a generateLanguages() function to the CV Builder. Constraints:
- Live in @src/lib/latex-generator.ts alongside the other section generators
- Take a single free-text string (the user's languages) — same shape as generateSkills
- Return '' when the input is empty (per the conditional-section contract in @specs/001-resume-builder/spec.md FR-026)
- Use \\section{Languages} and the same itemize-with-leftmargin block as generateSkills
- Escape user input via @src/lib/latex-escape.ts
- Add JSDoc consistent with surrounding functions"
```

**Step 2: Ask for self-critique**
```
"Review generateLanguages() against the constraints above and against @src/lib/latex-generator.ts.
What edge cases are missing? What happens for whitespace-only input?
Does it match the existing style exactly?"
```

**Step 3: Run tests as validation**
```
"Add vitest cases for generateLanguages in @tests/unit/latex-generator.test.ts matching the style
of the generateSkills describe() block. Then run npm test and fix any failures."
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

### Demo (using the CV Builder app)
```
1. Ask Agent: "Add a generateAwards() section using the \\resumeAwardHeading custom command
   from the resume template"
   → watch it confidently emit \\resumeAwardHeading{Name}{Issuer}{Year} — a command that DOES NOT
   exist in resume.tex (the template only defines \\resumeSubheading, \\resumeProjectHeading,
   \\resumeItem, \\resumeSubHeadingListStart, \\resumeItemListStart, etc.)
2. Verify: "@Files @resume.tex — list every \\newcommand and \\renewcommand defined here.
   Does \\resumeAwardHeading exist?"
3. Re-run with constraints: "Add generateAwards() that REUSES \\resumeProjectHeading exactly
   the way generateCertifications() does in @src/lib/latex-generator.ts. Do not invent new
   custom commands." → correct output
4. Self-critique: "Re-read generateAwards() against @specs/001-resume-builder/spec.md FR-023 —
   does it match the 'reuse \\resumeProjectHeading for visual consistency' convention?"
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
1. Run a command that fails (e.g., `npm test` with a failing vitest assertion)
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
"Debug why the Review tab renders an empty PDF when the user has filled all required sections.
The PDF compilation does not throw — it produces a 1-page output with only the contact block visible.

Start by checking how @src/components/ReviewView.tsx wires the data into generateLatex,
then trace through @src/lib/latex-generator.ts.

Run npm test to confirm your fix doesn't break anything."
```

Key difference from normal Chat debugging: you give it the **symptom and reproduction condition**, not a hypothesis. Let it form the hypothesis.

### Layer 4: Compiler / WASM error → root cause
For pdfTeX compile errors:
```
"Here is the LaTeX compilation log from pdf-compiler.ts:

[paste log]

The error fires only when a user enters bullet points containing percent signs.
The service is @src/lib/pdf-compiler.ts. Find the escape gap."
```

### Demo
```
1. Introduce a subtle bug in @src/lib/latex-escape.ts (e.g., remove the percent-sign replacement)
2. Show the symptom: npm test fails on a specific assertion; manually entering "100% growth" in
   the Summary field produces a broken PDF
3. Agent mode → "@Terminal the test output. Find the bug in src/lib/. Fix it. Re-run npm test."
4. Watch it add logging → find the gap → patch latex-escape.ts → confirm tests pass
```

---

## 3.5 Test Generation (5 min)

### Generating tests that match your patterns
```
Select generateProjects() → Cmd+L →
"Write vitest cases for this function. Cover: empty entries array, project with technologies,
project without technologies (empty string), project with no description bullets, escaping of
ampersands in the project name.
Match the test style in @tests/unit/latex-generator.test.ts — especially the describe()/it()
nesting and the fixture pattern at the top of the file."
```
Always reference an existing test file — this prevents Cursor from inventing its own structure.

### TDD loop with Agent mode
```
Cmd+L → Agent tab →
"I need a sortEntriesByDate<T extends { startDate: Date | null }>(entries: T[], direction: 'asc' | 'desc'): T[] helper.
First write tests in tests/unit/sort-entries.test.ts (they should fail — the file doesn't exist).
Then implement in src/lib/sort-entries.ts until all tests pass.
Cover: empty array, null startDate handled last, stable ordering for equal dates."
```

### Coverage gap analysis
```
"@Codebase — find every exported function in src/lib/ that has no corresponding test in tests/unit/"
```

---

## 3.6 Sub-agents, Worktrees & Cloud Agents (25 min)

> **#1 requested topic — 71% of attendees want this.** This is the headline section.

### Sub-agents — agents spawning agents

In Agent mode, Cursor can spawn **child sub-agents** to handle isolated sub-tasks in parallel, then collect their results. You see this in the agent's reasoning output as it delegates.

You can also orchestrate this explicitly:
```
Cmd+L → Agent tab →
"Add Languages and Awards sections to the CV Builder.

Split the work into parallel workstreams:
1. Sub-task A: Add LanguagesForm.tsx + generateLanguages() — Languages is a single free-text
   field, mirror @src/components/SkillsForm.tsx and @src/lib/latex-generator.ts::generateSkills
2. Sub-task B: Add AwardsForm.tsx + generateAwards() — Awards is a repeatable list with name,
   issuer, date; mirror @src/components/CertificationsForm.tsx and generateCertifications
3. Sub-task C: Add vitest cases for both generators in @tests/unit/latex-generator.test.ts
4. Sub-task D: Add the two new tabs to @src/App.tsx (TABS array, TAB_LABELS, INITIAL_DATA,
   the two new <TabsContent> blocks) and add Languages/Awards to ResumeData in @src/lib/types.ts

Complete each independently, then reconcile the results."
```

Best practice: give each sub-task a **clean scope boundary** so sub-agents don't conflict on the same files.

### Multitask Mode — the agent as coordinator

Multitask Mode takes sub-agents further: the agent acts as a **coordinator**, proactively scoping work and delegating to multiple background workers in parallel. Instead of you spelling out the sub-tasks, the agent decomposes the request, spins up async workers, monitors progress, and synthesises results.

```
You: "Implement these three features and update all affected tests."
Agent (coordinator): scopes each feature → launches background worker per feature
                     → monitors completion → reconciles conflicts → runs tests
```

**When to reach for Multitask Mode:**
- Independent features that can be implemented concurrently
- Investigation + implementation running side-by-side (e.g., research an API while building the integration)
- Parallel test generation across modules while you continue working

**How it relates to sub-agents and Best-of-N:**

| Technique | What it parallelises | Who decides the split? |
|---|---|---|
| Sub-agents | Different sub-tasks | You define the scope |
| **Multitask Mode** | Different sub-tasks | The agent decomposes and coordinates |
| Best-of-N | The same task, N attempts | You or the agent picks the winner |

Multitask Mode is the right choice when the agent has enough context to scope the work itself — you describe the end state, it figures out the parallel plan.

### When sub-agents shine vs. when they don't

| Good fit | Poor fit |
|---|---|
| Tasks with clear file boundaries | Tasks where files depend on each other |
| Independent migrations (API → API) | Tightly coupled refactors |
| Parallel test generation | Sequential workflow (step 2 depends on step 1) |
| Bulk operations (rename, format, lint fix) | Architectural decisions requiring human review |

### Live demo: sub-agent in action (using the CV Builder)
```
Cmd+L → Agent tab →
"Add Languages and Publications sections to the CV Builder in parallel.

For each section:
- Add the per-entry interface to @src/lib/types.ts (Languages is a single string;
  Publications is a repeatable list with title, venue, date, URL)
- Create the form component in @src/components/ matching the style of SkillsForm
  (single-field) or ProjectsForm (repeatable)
- Add a generator function in @src/lib/latex-generator.ts matching the contract of
  generateSkills / generateProjects
- Add vitest cases in @tests/unit/latex-generator.test.ts
- Wire into @src/App.tsx (TABS, TAB_LABELS, INITIAL_DATA, TabsContent)

Process Languages and Publications as separate sub-tasks. Run npm test at the end."
```

Watch Cursor spawn sub-agents — one for Languages, one for Publications — and work in parallel.

---

### Worktrees — true parallelism across branches

Git worktrees let you check out **multiple branches simultaneously** in separate directories. Combined with multiple Cursor windows, this means multiple agents working in parallel without interfering with each other.

```bash
# Create a worktree for a parallel workstream
git worktree add ../cv-builder-compact-mode feature/compact-mode

# Open the worktree in a new Cursor window
cursor ../cv-builder-compact-mode
```

Now you have:
```
Window 1: main branch  → Agent adding Languages + Publications sections (via sub-agents)
Window 2: feature/compact-mode → Agent adding a "Compact mode" toggle in ReviewView that
                                  tightens margins in latex-preamble.ts for single-page output
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
2. Create a worktree per piece: git worktree add ../cv-builder-piece-N feature/cv-piece-N
3. Run an agent in each worktree with a focused scope
4. Each piece → one PR → fast review → merge
```

This produces 3-4 PRs of 200-500 lines each instead of one monster PR.

---

### Best-of-N — same task, N attempts

Sub-agents + worktrees parallelise **different** sub-tasks. **Best-of-N** parallelises **the same** task across N attempts — usually with different models or different prompt framings — and lets you pick the best result.

```
                            ┌── attempt 1 (Composer 2.5) ──► ../cv-builder-bon-1
prompt: "refactor X" ──────►├── attempt 2 (Sonnet)       ──► ../cv-builder-bon-2
                            └── attempt 3 (Gemini)       ──► ../cv-builder-bon-3
                                                            │
                                                            ▼
                                                  pick best · cherry-pick · discard rest
```

Under the hood each attempt runs in its own isolated git worktree (Cursor exposes this as the `best-of-n-runner` sub-agent type), so the attempts can't step on each other. You review them like you review three colleagues' PRs and merge the strongest one.

**When Best-of-N is worth the spend:**

| Good fit | Poor fit |
|---|---|
| Architecturally ambiguous tasks (multiple valid designs) | Mechanical edits with one obvious answer |
| Tricky refactors where you want to compare approaches | Simple bug fixes |
| Unfamiliar libraries / APIs ("which idiomatic pattern wins?") | Anything trivially verifiable in seconds |
| High-stakes code (security, money, perf-critical) | Throwaway exploration |
| Picking the right model for a *category* of task | One-off small edits |

**Invocation patterns:**

```
Cmd+L → Agent tab →
"Best-of-3: refactor @src/lib/latex-generator.ts so the section ordering and
the empty-filter logic live in one place. Constraints: keep the public
generateLatex(data) signature; no new dependencies; existing tests must pass.

Run three attempts in isolated worktrees. Use a different model for each
(Composer 2.5, Sonnet, Gemini). Don't merge — show me each diff so I can pick."
```

```
"Best-of-2: write @tests/unit/latex-escape.test.ts so that every escape rule
listed in @specs/001-resume-builder/contracts/latex-generation.md is asserted.
Run two attempts — one minimal, one exhaustive. I'll choose."
```

**Reviewing the attempts — heuristics that beat "I'll just pick the longest one":**

| Signal | What it tells you |
|---|---|
| Diff size relative to the task | Smallest diff that satisfies all constraints usually wins |
| Style match against neighbouring files | Cursor's not measuring this; you have to |
| Test count + assertion specificity | More assertions ≠ better; the right assertions do |
| New abstractions introduced | Usually a smell at this scope — prefer the attempt that resisted them |
| Files touched outside the asked scope | Disqualifying unless the agent flagged it and explained why |

**Why this matters for model selection:** Best-of-N is the cheapest way to learn which model your team's codebase responds to best. Run a few real tasks Best-of-3 across your candidate models; the answer is rarely the model the marketing implies.

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

**Development environments for cloud agents:**

Background agents run in configurable cloud environments. You can define:
- **Dockerfile-based config** — specify the exact runtime (Node version, system dependencies, build tools) so the agent's environment matches your local/CI setup
- **Multi-repo environments** — attach multiple repos so the agent can reason across service boundaries (e.g., frontend + backend + shared types)
- **Environment governance** — admins can lock down allowed base images, restrict network access, and enforce security policies for all cloud agent runs in the org

This solves the "works on my machine" problem for background agents — they run in the same environment your CI does.

**What they cannot do (yet):**
- Access resources not in the repo (no internal DB, no local secrets)
- Interact with a running local server

### Orchestration pattern: worktree + background agent
```
1. git worktree add ../cv-builder-tests feature/test-coverage
2. Open worktree in Cursor → Agent tab → Background agent:
   "Audit @src/lib/ — for every exported function without a corresponding test in @tests/unit/,
    add vitest cases.
    Follow the style in @tests/unit/latex-generator.test.ts (describe per function, it() with
    behaviour-shaped names, top-of-file fixtures).
    Run npm test until everything passes.
    Commit and open a PR."
3. Continue working on the new section in your main window while it runs
```

### Demo: the full parallelism stack (10 min)
```
1. Show git worktree setup — two Cursor windows on the CV Builder
2. Window 1 (main): Agent adding Languages + Publications sections via sub-agents
3. Window 2 (feature/compact-mode): Agent adding a Compact-mode toggle in ReviewView that
   tightens margins in latex-preamble.ts
4. Show sub-agents spawning in Window 1 (Languages + Publications in parallel)
5. Best-of-N moment: kick off Best-of-3 on the Compact-mode refactor with three different
   models, walk through the three diffs side-by-side, pick the winner
6. Show Background Agent toggle: kick off the test-coverage audit
7. Show how to review diffs and merge the results
8. Clean up: git worktree remove ../cv-builder-compact-mode ../cv-builder-bon-*
```

---

## 3.7 Section Recap & Q&A (5 min)

### Key takeaways
1. **Agent mode** = goal-driven autonomous execution; always commit before running
2. **AI output quality** = constrain the prompt, verify with self-critique, validate with tests
3. **AI Debug mode** = give it the symptom, not the hypothesis
4. **Sub-agents** = delegate **different** parallel subtasks with clean scope boundaries
5. **Multitask Mode** = the agent as coordinator — it scopes, delegates, and synthesises across background workers
6. **Worktrees** = true parallel agent workstreams across branches (and smaller PRs)
7. **Best-of-N** = run **the same** task N times across models, pick the strongest diff — also the cheapest way to learn which model your codebase actually prefers
8. **Background agents** = long-running tasks that continue without you; use development environments (Dockerfile config, multi-repo) for production-grade setups

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
