---
marp: true
theme: rose-pine
paginate: true
style: |
  section.title {
    display: flex;
    flex-direction: column;
    justify-content: center;
    text-align: center;
  }
  section.title h1 {
    font-size: 3em;
  }
  section.title h2 {
    color: var(--subtle);
    font-weight: 300;
  }
---

<!-- _class: title -->

# Part 3
## Agentic Coding & Agent Mode

---

# 3.1. What Is a Coding Agent?

**Reason-and-act loop:**
Break goal into sub-tasks → use tools → observe result → iterate

**Self-correction loop:**
Write code → run tests → observe failure → rewrite → pass

> "Vibe coding" is the experience.
> **Agentic coding** is the engine.

---

# 3.1. The Shift

| | You do | AI does |
|-|--------|---------|
| Autocomplete | Write code | Suggest tokens |
| Chat | Ask questions | Explain |
| **Agent** | **Describe the goal** | **Everything else** |

---

# 3.2. The Escalation

`Cmd+L` `Shift+Tab` to cycle modes

```
Ask   → understand (read-only)
Plan  → review steps before acting
Agent → full autonomous execution
Multitask → parallel agent sessions
```

---

# 3.2. Why Plan Mode Matters

- Catch architectural mistakes **before** any edits
- Agree on scope with a colleague or reviewer
- Record of intent → useful for PR descriptions

> Use Plan whenever a wrong first step would be expensive to undo.

---

# 3.2. Demo: Scaffold via Spec-Kit

```
/speckit-specify → /speckit-plan → /speckit-tasks → implement → npm test
```

Review: `Cmd+Enter` accept all `Esc` reject per-file checkmarks

---

# 3.2. Agent Prompt Tips

- Be specific about **file paths** when you know them
- Describe **desired behaviour**, not implementation details
- Say "match existing patterns in the codebase"
- Break very large features into **multiple Agent sessions**

---

# 3.3. Verify Before Trusting

**Never accept agent output without validation.**

| Root cause | Your lever |
|---|---|
| Missing context | `@Files` / `@Folders` ask agent to search |
| Wrong style | `.cursor/rules` (Part 2) |
| Stale conversation | New chat thread |
| Task too broad | Smaller, scoped sessions |
| Model limits | Stronger reasoning model |

---

# 3.3. The Three Steps

| Step | What you do |
|------|-------------|
| **Constrain** | Files, contracts, examples in the prompt |
| **Self-critique** | Ask what edge cases or style drift remain |
| **Test** | vitest + `npm test` as ground truth |

---

# 3.3. The Three Steps (CV Builder)

```
Step 1: "Add generateLanguages(). Constraints: ..."
Step 2: "What edge cases are missing?"
Step 3: "Add vitest cases. Run npm test."
```

---

# 3.3. Hallucination Red Flags

- Calls to functions that **don't exist** in the library
- Import paths that **look plausible** but are invented
- Config options with **wrong names**
- Logic that assumes **your machine only**

---

# 3.3. Demo: Verify Loop (live)

**Don't script a hallucination**. Agent often reads `resume.tex` and self-corrects.

```
Constrain  → generateLanguages + @files + FR-026
Critique   → "What edge cases are missing?"
Test       → vitest + npm test
```

Hallucinations: red flags + Ask check. Hands-on → Exercise 3b

---

# 3.4. Debug. Four Layers

| Layer | When |
|-------|------|
| **1 Inline** | Red underline → lightbulb → Fix with AI |
| **2 Terminal** | `@Terminals`, fix the error |
| **3 Debug mode** | Symptom, unknown cause |
| **4 Paste log** | pdfTeX / WASM, trace from log |

---

# 3.4. Debug Mode

**Give it the symptom, not the hypothesis.**

```
✅  "The PDF is empty when all sections are filled."
❌  "I think the bug is in line 42. Fix it."
```

| Debug mode | Agent mode |
|---|---|
| Symptom, cause unknown | You know what's broken |
| Spans multiple files | Fix in one known location |
| Agent investigates | Agent implements known fix |

---

# 3.5. Test Generation

**Always reference an existing test**. or the agent invents its own structure.

```
"Write vitest cases for generateProjects().
 Cover: empty array, tech string, no bullets, ampersand escaping.
 Match @tests/unit/latex-generator.test.ts. describe/it nesting,
 fixture pattern at top of file."
```

---

# 3.5. What to Specify in the Prompt

- **Edge cases**. To cover. don't leave domain cases to the agent
- **Test file**. To match. style, nesting, assertion patterns
- **Data style**. fixtures, factories, or inline data
- **Run tests**. say whether to run `npm test` after writing

---

# 3.5. TDD with Agent

```
Write failing tests first → implement → npm test → iterate until green
```

Red-green-refactor: agent creates test file, implementation, runs tests, fixes.

**After a bug fix:**. Ask for a **regression test** in the matching test file.

---

# 3.5. Agent-Generated Test Risks

| Risk | Mitigation |
|---|---|
| Tests implementation, not behaviour | Would test break on refactor? |
| Expected values copied from buggy output | Verify values independently |
| Missing domain edge cases | **Specify edge cases in the prompt** |
| `.toBeDefined()` only | "Every assertion checks a specific value" |

---

# 3.5. Exercise 3

**Agent mode + output quality + debug + TDD**
→ `exercises/README.md § 3a-3f`

---

# 3.6. Sub-agents

Each sub-agent gets its **own context window**.

| Built-in | Purpose | Why isolated |
|----------|---------|--------------|
| **Explore** | Codebase search | Uses faster model 10× parallel searches |
| **Bash** | Shell commands | Verbose output stays out of main context |
| **Browser** | Browser interaction | Noisy DOM snapshots filtered to essentials |

Fire **automatically**. Can launch child sub-agents (since 2.5).

---

# 3.6. Custom Sub-agents

`.cursor/agents/` (project). `~/.cursor/agents/` (user)

```yaml
# .cursor/agents/verifier.md
---
name: verifier
description: Validates completed work. Use after tasks are marked done.
model: inherit
readonly: true
---
```

Invoke: `/verifier <task>` or automatic via `description` field.

---

# 3.6. Subagents vs Skills

| Use subagents when… | Use skills when… |
|---|---|
| Context isolation for long research | Single-purpose task |
| Multiple parallel workstreams | Quick, repeatable action |
| Specialized expertise across steps | Completes in one shot |
| Independent verification of work | No separate context needed |

---

# 3.6. Multitask Mode

**`/multitask`**. Split work into parallel sub-agents.

You describe the **end state**.
The agent **decomposes, delegates, synthesises**.

> Submit follow-ups while agents run. They queue automatically.

---

# 3.6. Worktrees

```
/worktree fix the login race condition
```

Isolated Git checkout. Main branch untouched.
`/apply-worktree` to bring changes back.

Configure setup: `.cursor/worktrees.json` (deps, env, migrations).

---

# 3.6. Best-of-N

```
/best-of-n sonnet,gpt,composer fix the flaky logout test
```

```
           ┌── worktree 1 (Sonnet)
prompt ───►├── worktree 2 (GPT)
           └── worktree 3 (Composer)
                    │
          parent agent compares. You pick /apply-worktree
```

---

# 3.6. Cloud Agents — what they are

**Two places the agent can run**

| | **Local Agent** (default) | **Cloud Agent** (optional) |
|---|---|---|
| Runs on | Your laptop, open folder | Isolated **Ubuntu VM** (Docker) with a repo checkout |
| You can | Watch diffs live, iterate fast | **Close the lid** — job keeps running |
| Setup | `.cursor/worktrees.json` | `.cursor/environment.json` |
| Result | Edits in your workspace | Branch + PR (or pull back to local) |

Cloud = same *agent loop* (read files, run tests, commit) — different **machine**.


---

# 3.6. Cloud Agents — when & how

**Use cloud when the task is long and self-contained**
- 15+ minutes: refactors, bulk tests, migrations
- Overnight or while you're in meetings
- Clean environment: `npm ci` + full test suite (like CI)

**Start (if you see the Cloud toggle in Agent chat)**
```
Cloud ON → describe the goal → Submit → review when notified
```
Also from: Agents Window, cursor.com/agents, Slack, GitHub, Linear

**Configure the VM** — commit `.cursor/environment.json`:
```json
{ "install": "npm ci && npm run download:tex-assets" }
```
Secrets → **dashboard** only (never in `environment.json`).

**Cannot do:** hit your local dev server, VPN-only DB, or files outside the repo.

---

# 3.6. No Cloud toggle? Same goal, local path

**Normal in this workshop** — privacy mode, org policy, or plan tier often hides Cloud.

| You want… | Local equivalent |
|---|---|
| Long task without touching `main` | `/worktree` + Agent in isolated checkout |
| Several tasks at once | `/multitask` or manual `git worktree` + second window |
| Queue work while one agent runs | Send the next message — it queues |
| Compare models on the same task | `/best-of-n` (local worktrees) |

**Same orchestration pattern**
```
/worktree → Agent: "audit @tests/unit/ — add missing generator tests, npm test until green, commit"
→ keep coding in main window → /apply-worktree when happy
```
Cloud version: identical prompt, but the VM runs after you walk away.

---

# 3.6. Exercise 4

**Sub-agents, worktrees, Best-of-N, custom agents**
→ `exercises/README.md § 4a-4e`

---

# Part 3. Takeaways

1. **Agent**. Describe the goal, not the steps. Plan before big tasks.
2. **Verify before trusting**. Constrain, critique, test.
3. **Debug mode**. Symptom, not hypothesis. Four escalation layers.
4. **Tests**. Reference an existing file. Specify edge cases. Run `npm test`.
5. **Sub-agents**. Context isolation + parallelism.
6. **Worktrees**. `/worktree` for isolation. `/apply-worktree` to merge.
7. **Best-of-N**. `/best-of-n` same task across models.
8. **Cloud Agents** = agent on a remote VM (survives sleep). No toggle? `/worktree` + local Agent.

---

<!-- _class: title -->

# ☕ Break  5 min

## Part 4 → Skills, Spec-Kit, Security, MCP & Team