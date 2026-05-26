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

# Part 2
## Context & Codebase Intelligence

---

# 2.1 — Why Context Is Everything

> The difference between a mediocre AI response and an excellent one
> is usually **not the model — it is the context.**

---

# 2.2 — Codebase Indexing

- Runs on project open, then incrementally
- Agent searches it **autonomously**
- `.cursorignore` excludes noise (WASM, node_modules, secrets)

> Let indexing finish before starting a complex session.

---

# 2.3 — The `@` Context System

| Symbol | What it pulls in |
|--------|-----------------|
| `@<file>` | Specific file |
| `@<folder>/` | All files in directory |
| `@Docs` | Library documentation |
| `@Terminals` | Terminal output |
| `@Commit` | Uncommitted changes |
| `@Branch` | Branch diff vs. main |
| `@Past Chats` | Previous conversation |

---

# 2.3 — Implicit (no symbol needed)

**Codebase search** — just ask, agent searches the index

**Web search** — ask about current info, agent searches the web

---

# 2.3 — Exercise 2

**Try each `@` symbol on the CV Builder**
→ `exercises/README.md § 2a–2d`

---

# 2.4 — `.cursor/rules`

| Type | When applied |
|------|-------------|
| **Always** | Every request |
| **Auto-attached** | File globs match |
| **Agent-requested** | AI decides |
| **Manual** | You `@` it |

---

# 2.4 — The CV Builder's Rule

```markdown
---
alwaysApply: true
---
Read the current plan at specs/001-resume-builder/plan.md
```

**4 lines. One pointer. Every session reads the plan.**

---

# Part 2 — Takeaways

1. **Codebase indexing** — the invisible backbone
2. **`@` system** — highest-leverage skill to master
3. **`.cursor/rules`** — conventions as code, committed to git
4. Better context = fewer hallucinations

---

<!-- _class: title -->

# ☕ Break — 10 min

## Part 3 → Agentic Coding & Agent Mode
