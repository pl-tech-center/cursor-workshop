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

# 3.1 — What Is a Coding Agent?

**Reason-and-act loop:**
Break goal into sub-tasks → use tools → observe result → iterate

**Self-correction loop:**
Write code → run tests → observe failure → rewrite → pass

> "Vibe coding" is the experience.
> **Agentic coding** is the engine.

---

# 3.1 — The Shift

| | You do | AI does |
|-|--------|---------|
| Autocomplete | Write code | Suggest tokens |
| Chat | Ask questions | Explain |
| **Agent** | **Describe the goal** | **Everything else** |

---

# 3.2 — The Escalation

```
Ask   → understand
Plan  → review steps before acting
Agent → full autonomous execution
```

---

# 3.2 — Demo: Scaffold via Spec-Kit

```
/speckit-specify → /speckit-plan → /speckit-tasks → implement → npm test
```

---

# 3.3 — AI Output Quality

**Constrain → Self-critique → Test**

```
Step 1: "Add generateLanguages(). Constraints: ..."
Step 2: "What edge cases are missing?"
Step 3: "Add vitest cases. Run npm test."
```

---

# 3.3 — Demo: Hallucination

```
❌  "Add generateAwards() using \resumeAwardHeading"
     → doesn't exist — agent invents it

✅  "Add generateAwards() — REUSE \resumeProjectHeading
     the way generateCertifications() does"
```

---

# 3.4 — Debug Mode

**Give it the symptom, not the hypothesis.**

```
✅  "The PDF is empty when all sections are filled."
❌  "I think the bug is in line 42 — fix it."
```

---

# 3.5 — Test Generation

**Always reference an existing test.**

```
"Write vitest cases for generateProjects().
 Match the style in @tests/unit/latex-generator.test.ts"
```

---

# 3.5 — Exercise 3

**Agent mode + output quality + debug + TDD**
→ `exercises/README.md § 3a–3f`

---

# 3.6 — Sub-agents

Each sub-agent gets its **own context window**.

| Built-in | Purpose |
|----------|---------|
| **Explore** | Codebase search |
| **Bash** | Shell commands |
| **Browser** | Browser interaction |

These fire **automatically**.

---

# 3.6 — Custom Sub-agents

```
.cursor/agents/
├── verifier.md
├── security-auditor.md
└── section-builder.md
```

Invoke: `/verifier`, `/security-auditor`, or automatic via description.

---

# 3.6 — Multitask Mode

You describe the **end state**.
The agent **decomposes, delegates, synthesises**.

---

# 3.6 — Worktrees

```bash
git worktree add ../cv-builder-feature feature/x
cursor ../cv-builder-feature
```

Two windows. Two agents. Zero conflicts.

> Also: smaller PRs. One worktree = one feature = one PR.

---

# 3.6 — Best-of-N

```
           ┌── attempt 1 (Model A)
prompt ───►├── attempt 2 (Model B)
           └── attempt 3 (Model C)
                    │
           pick best · discard rest
```

---

# 3.6 — Background Agents

```
Cmd+L → Agent → Background toggle → submit → close laptop
```

---

# 3.6 — Exercise 4

**Sub-agents, worktrees, Best-of-N, custom agents**
→ `exercises/README.md § 4a–4e`

---

# Part 3 — Takeaways

1. **Agent** — describe the goal, not the steps
2. **Output quality** — constrain, critique, test
3. **Debug mode** — symptom, not hypothesis
4. **Sub-agents** — context isolation + parallelism
5. **Worktrees** — true parallel branches
6. **Best-of-N** — same task, pick the best diff
7. **Background** — long tasks without you

---

<!-- _class: title -->

# ☕ Break — 5 min

## Part 4 → Skills, Spec-Kit, Security, MCP & Team
