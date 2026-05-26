# Part 3 — Agentic Coding & Agent Mode
**Presenter A · ~45 minutes**

> This is the **#1 requested topic** from the poll. 71% of attendees want sub-agents, worktrees, and background agents — this section is the longest of the four for that reason.
>
> All demos and exercises target the CV Builder app at `../cv-builder`.

---

## 3.1 What Is "Agentic" Coding? (5 min)

A coding agent is a program powered by an LLM that performs development tasks **autonomously**. It doesn't just generate text — it uses a **reason-and-act loop**: break the goal into sub-tasks, use tools (file system, terminal, version control) to execute each one, observe the result, and iterate.

The defining feature is the **self-correction loop**. The agent doesn't output code and stop. It writes code, runs tests, observes failures, and rewrites until the tests pass. This is what separates an agent from autocomplete or a chatbot.

### Agentic coding vs. "vibe coding"

"Vibe coding" describes a flow state where you focus on logic and creativity while AI handles syntax and boilerplate. **Agentic coding** is the methodology that enables that state — the structured, autonomous process where the AI handles execution. Vibe coding is the experience; agentic coding is the engine.

### The shift

| Mode | You do | AI does |
|---|---|---|
| Autocomplete | Write code | Suggest next tokens |
| Chat/Inline | Ask questions, apply suggestions | Explain and generate |
| **Agent** | Describe the goal | Plans, edits multiple files, runs commands, iterates |

> In agent mode, Cursor acts as an autonomous engineer: it reads files, creates files, runs terminal commands, checks errors, and fixes them — all in a loop until the task is done.

---

## 3.2 Agent Mode: Multi-File Editing (15 min)

### Opening Agent mode
- `Cmd+L` — opens the chat panel (Agent is the default mode)
- `Shift+Tab` to cycle between modes (Agent → Plan → Ask)
- Or use the mode picker dropdown in the chat input

### Ask → Plan → Agent → Multitask — the escalation pattern

**Ask** — understand first. Read-only — no edits made.  
**Plan** — Agent proposes a numbered step-by-step plan. You review and approve (or edit) before a single file is touched.  
**Agent** — full autonomous execution: edits → runs tests → fixes errors → repeats.  
**Multitask** — multiple parallel agent sessions running concurrently on independent tasks.

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
| Missing context | Attach files with `@Files`/`@Folders`, or ask the agent to search the codebase |
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

### Demo: Verify before trusting (live, ~5 min)

**Do not script a hallucination live.** With codebase indexing, Agent often reads `@resume.tex` first and either reuses `\resumeProjectHeading`, refuses the fake `\resumeAwardHeading`, or asks you to clarify — so the “watch it invent a LaTeX command” moment is unreliable on stage.

**What works every time:** run the three-step loop from above on a real task.

```
1. Agent — Step 1 (constrain):
   Use the generateLanguages() prompt from Step 1 above (or Exercise 3a).
   Review the diff before accepting.

2. Agent — Step 2 (self-critique):
   Use the generateLanguages() review prompt from Step 2 above.
   Typical catch: whitespace-only input, missing FR-026 empty-string contract, style drift.

3. Agent — Step 3 (tests):
   Use the vitest + npm test prompt from Step 3 above.
```

**Hallucinations — talk track only (30 sec):** walk through the red flags list. Example: `\resumeAwardHeading` is not defined in `resume.tex` (only `\resumeSubheading`, `\resumeProjectHeading`, etc.) — agents *used* to invent it; now verification matters more than provocation.

**Optional 10-second Ask check (reliable):**
```
Ask mode → "@Files @resume.tex — list every \\newcommand. Does \\resumeAwardHeading exist?"
```
Always returns no — shows verification without depending on Agent writing bad code.

**Hands-on:** [Exercise 3b](./exercises/README.md#3b-tame-a-hallucination) — attendees try the awards prompt themselves and compare outcomes (invented command vs self-correction vs constrained re-run).

---

## 3.4 Debugging with AI — Including Debug Mode (10 min)

Debugging with AI follows a **layered approach** — escalate from quick fixes to full investigation as needed.

### Layer 1: Inline fix from lint errors
```
Click the red underline → lightbulb → "Fix with AI"
```
Fastest path for type errors and lint violations. Zero context switching — stays in the editor.

### Layer 2: Terminal error → fix
```
1. Run a command that fails (e.g., `npm test` with a failing vitest assertion)
2. In Chat: "@Terminals — fix the error"
→ Cursor reads the terminal output and proposes a fix
```

Best for: build errors, test failures with clear stack traces, missing imports. The agent sees exactly what you see in the terminal.

### Layer 3: Debug mode — hypothesis-driven investigation

Debug mode puts Cursor in a **directed problem-solving loop**. The critical difference from regular Agent mode: you give it a **symptom and reproduction condition**, not a hypothesis. Let the agent form its own hypothesis and test it.

**What the agent does in Debug mode:**
- Reads the relevant source files to understand the code path
- Adds strategic logging or assertions to narrow the cause
- Runs the program and reads the output
- Forms a hypothesis from the evidence
- Tests the hypothesis by modifying code and re-running
- Iterates until the bug is isolated and a fix is verified

**Good Debug mode prompts:**
```
"Debug why the Review tab renders an empty PDF when the user has filled all required sections.
The PDF compilation does not throw — it produces a 1-page output with only the contact block visible.
The issue started after the last commit to latex-generator.ts."
```

```
"Debug: npm test passes locally but generateExperience returns unexpected output when
the entry has isCurrent=true and endDate is null. The test expects 'Present' but gets ''."
```

**Bad Debug mode prompts:**
```
"I think the bug is in line 42 of latex-generator.ts — fix it"
→ This bypasses the investigation. If you already know the line, use Cmd+K.
```

**When to use Debug mode vs. regular Agent mode:**

| Use Debug mode | Use Agent mode |
|---|---|
| You see a symptom but don't know the cause | You know what's broken and how to fix it |
| The bug spans multiple files | The fix is in one known location |
| You need the agent to investigate and narrow down | You need the agent to implement a known fix |
| Intermittent or hard-to-reproduce issues | Clear, deterministic failures |

### Layer 4: Compiler / WASM error → root cause
For pdfTeX compile errors or runtime WASM issues, paste the log directly:
```
"Here is the LaTeX compilation log from pdf-compiler.ts:

[paste log]

The error fires only when a user enters bullet points containing percent signs.
The service is @src/lib/pdf-compiler.ts. Find the escape gap."
```

The agent can reason about LaTeX compilation errors even without running the WASM compiler itself — it traces from user input through the escape layer to the generated `.tex` string.

### Demo
```
1. Introduce a subtle bug: remove the percent-sign replacement in @src/lib/latex-escape.ts
2. Show the symptom: npm test fails on a specific assertion; manually entering "100% growth"
   in the Summary field produces a broken PDF
3. Switch to Debug mode → "npm test is failing on the latex-escape tests. Also, entering
   '100% growth' in the Summary field produces a broken PDF. The issue is somewhere in
   src/lib/. Investigate and fix."
4. Watch the agent:
   - Read latex-escape.ts and the test file
   - Identify the missing percent-sign rule
   - Patch the file
   - Re-run npm test → pass
5. Show the difference: Agent would have just "fixed the test" — Debug mode investigated the root cause
```

---

## 3.5 Test Generation & TDD with Agents (5 min)

### The key principle: always reference an existing test

If you let the agent invent its own test structure, you'll get inconsistent style across your test suite. **Always point at an existing test file** so it matches your patterns.

### Generating tests that match your patterns
```
Select generateProjects() → Cmd+L →
"Write vitest cases for this function. Cover: empty entries array, project with technologies,
project without technologies (empty string), project with no description bullets, escaping of
ampersands in the project name.
Match the test style in @tests/unit/latex-generator.test.ts — especially the describe()/it()
nesting and the fixture pattern at the top of the file."
```

**What to specify in the prompt:**
- Which edge cases to cover (don't leave this to the agent — it will miss domain-specific cases)
- Which test file to match (style, nesting, assertion patterns)
- Whether to use fixtures, factories, or inline data
- Whether to run the tests after writing them

### TDD loop with Agent mode

The agent can write tests first, then implement until they pass — true red-green-refactor:

```
Cmd+L → Agent tab →
"I need a sortEntriesByDate<T extends { startDate: Date | null }>(entries: T[], direction: 'asc' | 'desc'): T[] helper.
First write tests in tests/unit/sort-entries.test.ts (they should fail — the file doesn't exist).
Then implement in src/lib/sort-entries.ts until all tests pass.
Cover: empty array, null startDate handled last, stable ordering for equal dates."
```

The agent will:
1. Create the test file with failing tests
2. Create the implementation file
3. Run `npm test` — see failures
4. Iterate until all tests pass

### Coverage gap analysis
```
"Find every exported function in src/lib/ that has no corresponding test in tests/unit/.
List them as a table: function name | file | tested (yes/no)."
```

### Regression tests from bugs
After fixing a bug, immediately ask for a regression test:
```
"The bug was: percent signs in user input broke the PDF.
Add a regression test in @tests/unit/latex-escape.test.ts that ensures
'100% growth' is properly escaped to '100\\% growth'. Use the existing test style."
```

### When agent-generated tests are dangerous

| Risk | Mitigation |
|---|---|
| Tests that test the implementation, not the behaviour | Review: does the test break if you refactor internals? |
| Assertions copied from current (buggy) output | Check: are the expected values independently correct? |
| Missing edge cases the agent didn't think of | Always specify edge cases explicitly in your prompt |
| Overly permissive assertions (`.toBeDefined()`) | Rule: "every assertion must check a specific value" |

### Demo
```
1. Select generateCertifications() → "Write vitest cases matching the style in
   @tests/unit/latex-generator.test.ts. Cover: empty array, single cert with all fields,
   cert missing issueDate, cert with special characters in the name."
2. Run npm test → watch them pass
3. TDD: "I need a formatBulletPoints(text: string): string[] helper that splits on newlines,
   trims whitespace, and drops empty lines. Write failing tests first, then implement."
4. Coverage gap: "Find every untested export in src/lib/" → generate missing tests
```

---

## 3.6 Sub-agents, Worktrees & Cloud Agents (25 min)

> **#1 requested topic — 71% of attendees want this.** This is the headline section.

### Sub-agents — what they are

Sub-agents are specialized AI assistants that the parent agent can delegate tasks to. Each sub-agent operates in its **own context window**, handles specific work, and returns a result to the parent. This gives you:

- **Context isolation** — long research or exploration doesn't consume the main conversation's context
- **Parallel execution** — multiple sub-agents run simultaneously
- **Specialized expertise** — each sub-agent can have custom prompts, tools, and even a different model
- **Cost efficiency** — sub-agents can use faster/cheaper models for context-heavy work

### Built-in sub-agents

Cursor includes three built-in sub-agents that fire automatically — you don't configure them:

| Sub-agent | Purpose | Why it's isolated |
|---|---|---|
| **Explore** | Searches and analyses the codebase | Exploration generates large intermediate output that would bloat the main context. Uses a faster model for many parallel searches. |
| **Bash** | Runs series of shell commands | Command output is verbose. Isolating it keeps the parent focused on decisions, not logs. |
| **Browser** | Controls browser via MCP tools | DOM snapshots and screenshots are noisy. The sub-agent filters down to relevant results. |

These were designed based on analysis of agent conversations where context window limits were hit. The explore sub-agent uses a faster model by default, enabling 10 parallel searches in the time a single main-agent search would take. Since Cursor 2.5, sub-agents can launch child sub-agents to create a tree of coordinated work.

You'll see these in action any time the agent decides to search the codebase, run a command, or interact with a browser — it's spawning a sub-agent under the hood.

### Foreground vs. background sub-agents

| Mode | Behaviour | Best for |
|---|---|---|
| **Foreground** | Blocks until complete. Returns the result immediately. | Sequential tasks where the parent needs the output before proceeding. |
| **Background** | Returns immediately. Sub-agent works independently. | Long-running tasks or parallel workstreams. |

### Automatic delegation

The agent spawns sub-agents automatically based on task complexity. You can also trigger it explicitly by describing parallel work:

```
Cmd+L → Agent tab →
"Add Languages and Awards sections to the CV Builder.

Split the work into parallel workstreams:
1. Sub-task A: Add LanguagesForm.tsx + generateLanguages() — Languages is a single free-text
   field, mirror @src/components/SkillsForm.tsx and generateSkills in @src/lib/latex-generator.ts
2. Sub-task B: Add AwardsForm.tsx + generateAwards() — Awards is a repeatable list with name,
   issuer, date; mirror @src/components/CertificationsForm.tsx and generateCertifications
3. Sub-task C: Add vitest cases for both generators in @tests/unit/latex-generator.test.ts
4. Sub-task D: Add the two new tabs to @src/App.tsx (TABS array, TAB_LABELS, INITIAL_DATA,
   the two new <TabsContent> blocks) and add Languages/Awards to ResumeData in @src/lib/types.ts

Complete each independently, then reconcile the results."
```

Best practice: give each sub-task a **clean scope boundary** so sub-agents don't conflict on the same files.

### Custom sub-agents — `.cursor/agents/`

This is the power feature. You can define **reusable, project-specific sub-agents** as markdown files.

**File locations:**
- **Project-level:** `.cursor/agents/` (committed to git — team-shared)
- **User-level:** `~/.cursor/agents/` (personal, across all projects)
- For compatibility, `.claude/agents/` and `.codex/agents/` are also supported. `.cursor/` takes precedence on name conflict.

The agent includes all custom sub-agents in its available tools — they appear alongside built-in ones.

```
.cursor/agents/
├── verifier.md        ← Validates completed work — catches "marked done but broken"
├── security-auditor.md ← Reviews code for vulnerabilities
└── test-runner.md      ← Proactively runs tests and fixes failures
```

Each file is markdown with YAML frontmatter:

```markdown
---
name: verifier
description: Validates completed work. Use after tasks are marked done to confirm implementations are functional.
model: inherit
readonly: true
---

You are a skeptical validator. Your job is to verify that work claimed as complete actually works.

When invoked:
1. Identify what was claimed to be completed
2. Check that the implementation exists and is functional
3. Run relevant tests or verification steps
4. Look for edge cases that may have been missed

Be thorough and skeptical. Report:
- What was verified and passed
- What was claimed but incomplete or broken
- Specific issues that need to be addressed
```

### Configuration fields

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `name` | string | No | From filename | Display name. Use lowercase + hyphens. |
| `description` | string | Yes | — | Controls when the agent delegates automatically. Invest time here. |
| `model` | string | No | `inherit` | `inherit` (same as parent) or a specific model ID |
| `readonly` | boolean | No | `false` | If true, no file edits or state-changing shell commands |
| `is_background` | boolean | No | `false` | If true, runs without blocking the parent |

### Invocation patterns

**Explicit:** Use the `/name` syntax in your prompt:
```
> /verifier confirm the auth flow is complete
> /security-auditor review the payment module
```

**Natural language:** Mention the sub-agent by name:
```
> Use the verifier subagent to confirm all generators handle empty input correctly
```

**Automatic:** Write a good `description` field and the agent delegates on its own. Include phrases like "use proactively" or "always use for X" to encourage automatic delegation.

### Common patterns for custom sub-agents

**Verification agent** — independently validates that claimed work actually passes:
```markdown
---
name: verifier
description: Validates completed work. Use after tasks are marked done.
readonly: true
---
```
Catches the common problem where the agent marks tasks done but implementations are incomplete.

**Orchestrator pattern** — a parent coordinates specialist sub-agents in sequence:
```
1. Planner analyzes requirements → creates technical plan
2. Implementer builds the feature based on the plan
3. Verifier confirms implementation matches requirements
```

**Security reviewer** — read-only audit of sensitive code paths:
```markdown
---
name: security-auditor
description: Security specialist. Use when implementing auth, payments, or handling sensitive data.
model: inherit
readonly: true
---
```

### Performance and cost trade-offs

| Benefit | Trade-off |
|---|---|
| Context isolation | Startup overhead (each sub-agent gathers its own context) |
| Parallel execution | Higher token usage (multiple contexts simultaneously) |
| Specialized focus | Latency (may be slower than main agent for simple tasks) |

**Rule of thumb:** For quick, simple tasks, the main agent is faster. Sub-agents shine for complex, long-running, or parallel work where context isolation matters.

### Anti-patterns to avoid

- **Too many generic sub-agents** — 50+ sub-agents with vague descriptions. The agent won't know when to use them.
- **Vague descriptions** — "Use for general tasks" gives no signal. Be specific: "Use when implementing LaTeX generators for new resume sections."
- **Sub-agents for simple tasks** — If the task completes in one shot and doesn't need context isolation, just let the agent do it directly or use a skill.
- **Overlapping scopes** — Two sub-agents editing the same file = conflicts.

**Best practice:** Start with 2–3 focused sub-agents. Add more only when you have clear, distinct use cases.

### When to use sub-agents vs. skills

| Use sub-agents when… | Use skills when… |
|---|---|
| You need context isolation for long research tasks | The task is single-purpose |
| Running multiple workstreams in parallel | You want a quick, repeatable action |
| The task requires specialized expertise across many steps | The task completes in one shot |
| You want an independent verification of work | You don't need a separate context window |

### Multitask Mode & `/multitask` — the agent as coordinator

Multitask Mode takes sub-agents further: the agent acts as a **coordinator**, proactively scoping work and delegating to multiple background workers in parallel. Instead of you spelling out the sub-tasks, the agent decomposes the request, spins up async workers, monitors progress, and synthesises results.

Use the **`/multitask`** slash command to enter Multitask Mode explicitly. Available in the Agents Window since Cursor 3.2 (April 24, 2026). If you already have queued messages, you can ask Cursor to multitask on them instead of waiting for the current run to finish.

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
| Custom sub-agents | Specialized work | The agent delegates based on description |
| **Multitask Mode** | Different sub-tasks | The agent decomposes and coordinates |
| Best-of-N | The same task, N attempts | You or the agent picks the winner |

Multitask Mode is the right choice when the agent has enough context to scope the work itself — you describe the end state, it figures out the parallel plan.

### When sub-agents shine vs. when they don't

| Good fit | Poor fit |
|---|---|
| Tasks with clear file boundaries | Tasks where files depend on each other |
| Independent migrations (API → API) | Tightly coupled refactors |
| Context-heavy research/exploration | Quick lookups |
| Parallel test generation | Sequential workflow (step 2 depends on step 1) |
| Independent verification of work | Architectural decisions requiring human review |
| Bulk operations (rename, format, lint fix) | Simple single-file edits |

### Live demo: sub-agents in action (using the CV Builder)
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

Then: `/verifier confirm both sections render in the PDF and all tests pass`

---

### Worktrees — true parallelism across branches

Git worktrees let you check out **multiple branches simultaneously** in separate directories. Combined with multiple Cursor windows, this means multiple agents working in parallel without interfering with each other.

#### `/worktree` — the recommended path in Cursor 3

The **`/worktree`** slash command starts an isolated Git checkout for the rest of a chat. Your main branch stays untouched until you explicitly bring changes back with **`/apply-worktree`**.

```
Cmd+L → Agent tab →
"/worktree — add a Compact-mode toggle in ReviewView that tightens margins
in latex-preamble.ts for single-page output"
```

When you're happy with the result:
```
/apply-worktree
```

Customise worktree setup (install deps, copy `.env`, run migrations) via **`.cursor/worktrees.json`** in your project root.

> **UI-native worktrees** are only available in the Agents Window. In the Editor Window, use the `/worktree` and `/best-of-n` commands.

#### Manual `git worktree` (still works)

The manual approach still works and gives you full control:

```bash
git worktree add ../cv-builder-compact-mode feature/compact-mode
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
2. /worktree per piece (or git worktree add ../cv-builder-piece-N feature/cv-piece-N)
3. Run an agent in each worktree with a focused scope
4. Each piece → one PR → fast review → merge
```

This produces 3-4 PRs of 200-500 lines each instead of one monster PR.

---

### Best-of-N — same task, N attempts

Sub-agents + worktrees parallelise **different** sub-tasks. **Best-of-N** parallelises **the same** task across N attempts — usually with different models or different prompt framings — and lets you pick the best result.

#### `/best-of-n` syntax

```
/best-of-n sonnet,gpt,composer <task>
```

Each run gets its own worktree. A parent agent provides commentary on the different results. Best-of-N does **not** merge changes back automatically — you pick a winner, then run `/apply-worktree` to bring the changes back. Supports multi-repo setups.

```
                            ┌── attempt 1 (Composer 2.5) ──► worktree-bon-1
/best-of-n sonnet,gpt, ────►├── attempt 2 (Sonnet)       ──► worktree-bon-2
composer "refactor X"       └── attempt 3 (GPT)          ──► worktree-bon-3
                                                            │
                                                            ▼
                                                  pick best · /apply-worktree · discard rest
```

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
"/best-of-n sonnet,gpt,composer refactor @src/lib/latex-generator.ts so the
section ordering and the empty-filter logic live in one place. Constraints:
keep the public generateLatex(data) signature; no new dependencies;
existing tests must pass."
```

```
"/best-of-n sonnet,composer write @tests/unit/latex-escape.test.ts so that
every escape rule listed in @specs/001-resume-builder/contracts/latex-generation.md
is asserted. One minimal, one exhaustive. I'll choose."
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

### Cloud Agents (formerly Background Agents)

> **Presenter note:** Cloud Agents are **not available on every machine** — many Nike laptops, privacy-mode settings, plan tiers, or org policies hide the Cloud toggle entirely. **Do not demo this live** unless you have confirmed the Cloud option appears in your Agent chat. Teach the concept in 60 seconds; use the local alternatives below for the workshop.

Cursor's **Cloud Agents** run tasks in isolated Ubuntu VMs in the cloud (AWS), each in its own Docker container — not on your machine. You kick off a task and can close your laptop; the agent continues running and notifies you when done.

**When you don't have Cloud Agents**, the same *idea* still works locally:
- **`/worktree` + local Agent** — long task in an isolated checkout while you keep coding in main
- **`/multitask`** — parallel local sub-agents on independent scopes
- **Queued Agent messages** — submit the next task while the current one runs

**Access from (when enabled):** The Agents Window (`Cmd+Shift+P` → Open Agents Window), cursor.com/agents, Slack, Linear, GitHub, and your phone.

**How to start a cloud agent task (if the Cloud toggle is visible):**
```
Cmd+L → Agent tab → click the "Cloud" toggle → describe the task → Submit
```

If you only see **Local** (and maybe **Worktree**), you are on local Agent only — that is normal for this workshop environment.

**Best suited for:**
- Tasks that take 15+ minutes (large refactors, bulk migrations)
- Tasks you want to run overnight
- Running a full test suite in a clean environment
- Generating comprehensive test coverage across a module

**What cloud agents can do:**
- Read/write files, run tests, install packages
- Create branches and open PRs
- Work in multi-repo environments
- Use MCP servers via committed `.cursor/mcp.json`

**Configuration via `.cursor/environment.json`:**

Cloud agents run in configurable environments. Define initialization commands, start scripts, persistent terminals, and environment variables in `.cursor/environment.json`:
- **Initialization commands** — install dependencies, run migrations, set up the environment
- **Start scripts** — launch dev servers or watchers that persist for the session
- **Persistent terminals** — terminals that stay alive across agent interactions
- **Environment variables** — inject config without committing secrets

**Secret management:** Manage secrets via Cursor's dashboard — encrypted-at-rest with KMS. Secrets are injected into the cloud environment at runtime.

**Development environments for cloud agents:**

- **Multi-repo environments** — attach multiple repos so the agent can reason across service boundaries (e.g., frontend + backend + shared types)
- **Environment governance** — admins can lock down allowed base images, restrict network access, and enforce security policies for all cloud agent runs in the org

This solves the "works on my machine" problem for cloud agents — they run in the same environment your CI does.

**Local-to-cloud handoff:** Start a task locally, hand it to the cloud when scope grows; pull the cloud result back to local for cleanup and final review.

**What they cannot do (yet):**
- Access resources not in the repo (no internal DB, no local secrets beyond dashboard-managed ones)
- Interact with a running local server

### Orchestration pattern: worktree + long-running Agent (local or cloud)

Same workflow with **local Agent in a worktree** when Cloud is unavailable:

```
1. /worktree (or: git worktree add ../cv-builder-tests feature/test-coverage)
2. In the worktree chat — local Agent:
   "Audit @src/lib/ — for every exported function without a corresponding test in @tests/unit/,
    add vitest cases.
    Follow the style in @tests/unit/latex-generator.test.ts (describe per function, it() with
    behaviour-shaped names, top-of-file fixtures).
    Run npm test until everything passes.
    Commit when green."
3. Continue working in your main window while the worktree Agent runs
```

**With Cloud Agents (optional):** same prompt in a Cloud session — the laptop can sleep; you review the PR when notified.

### Demo: the full parallelism stack (10 min)
```
1. Show /worktree — start an isolated checkout for a compact-mode feature
2. Window 1 (main): Agent adding Languages + Publications sections via sub-agents
3. Worktree chat: Agent adding a Compact-mode toggle in ReviewView that
   tightens margins in latex-preamble.ts
4. Show sub-agents spawning in Window 1 (Languages + Publications in parallel)
5. Best-of-N moment: /best-of-n sonnet,gpt,composer on the Compact-mode refactor,
   walk through the three diffs side-by-side, pick the winner with /apply-worktree
6. (Skip if no Cloud toggle) Long-running test audit: local Agent in the worktree from step 3,
   OR Cloud Agent if your machine has it — same prompt as the orchestration pattern above
7. Show how to review diffs and merge the results (/apply-worktree or PR)
8. Clean up worktrees (automatic for /worktree; manual: git worktree remove <path>)
```

---

## 3.7 Section Recap & Q&A (5 min)

### Key takeaways
1. **Agent mode** = goal-driven autonomous execution; always commit before running
2. **AI output quality** = constrain the prompt, verify with self-critique, validate with tests
3. **AI Debug mode** = give it the symptom, not the hypothesis
4. **Built-in sub-agents** (explore, bash, browser) fire automatically — you don't configure them
5. **Custom sub-agents** (`.cursor/agents/`) = reusable specialists committed alongside code — verifier, security auditor, test runner
6. **Multitask Mode** (`/multitask`) = the agent as coordinator — it scopes, delegates, and synthesises across background workers
7. **Worktrees** (`/worktree`, `/apply-worktree`) = true parallel agent workstreams across branches (and smaller PRs)
8. **Best-of-N** (`/best-of-n`) = run **the same** task N times across models, pick the strongest diff — also the cheapest way to learn which model your codebase actually prefers
9. **Cloud Agents** (when enabled) = long-running tasks that continue without you; otherwise use **worktree + local Agent** or **queued messages** for the same parallelism

### Common mistakes
- Giving overlapping file scopes to parallel agents — they will conflict
- Creating too many generic sub-agents with vague descriptions — start with 2-3 focused ones
- Using cloud agents for tasks that require local secrets or running services
- Not committing before any agent task — you need a clean diff to review
- Running agent mode with a vague prompt — the more specific, the less rework
- Accepting agent output without reading the diff — "plausible but wrong" is the biggest risk
- Using sub-agents for tasks that don't need context isolation — overhead without benefit

### Safety note
> `git worktree` leaves extra directories on disk. Clean up with `git worktree remove <path>` when done.

### Hands-on

→ [Exercise 3 — Agent Mode & Output Quality](./exercises/README.md#exercise-3--agent-mode--output-quality) *(after this part, ~15 min)*
→ [Exercise 4 — Sub-agents & Parallelism](./exercises/README.md#exercise-4--sub-agents--parallelism) *(after this part, ~15 min)*

---

*Next: [Part 4 — Advanced Workflows & Team Practices →](./04-advanced-workflows.md)*
