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

Hallucinations, shallow fixes, wrong architecture
→ mostly **context problems**, not model problems.

---

# 2.2 — Codebase Indexing

- Runs on project open, then **incrementally** on file changes
- Creates **embeddings** for semantic similarity search (RAG)
- Agent queries it **autonomously** — you never trigger it
- Also powers Tab autocomplete's multi-file awareness

> Let indexing finish before a complex session.
> Check: `Cursor Settings` → `Indexing & Docs`

---

# 2.2 — What Affects Search Quality

- **File size** — >500 lines get chunked; split for better retrieval
- **Naming** — descriptive names improve semantic matches
- **Comments** — help the index understand intent
- **Stale index** — wait a few seconds after large refactors

---

# 2.2 — `.cursorignore` vs `.gitignore`

**`.gitignore`** — Cursor respects it for indexing (already excluded = already out)

**`.cursorignore`** — also blocks Agent from **reading** those paths

```
public/core/busytex/    # 680 MB WASM — out via .gitignore
.env                    # secrets — add to .cursorignore too
dist/
__pycache__/
```

---

# 2.2 — Large Repo Strategies

- **Monorepos** — open only the package(s) you need
- **Multi-root** — each root indexed independently; agent searches all
- **Build output** — exclude `dist/`, `target/`, `__pycache__/`, `*.pb.go`

---

# 2.3 — The `@` Context System

| Symbol | What it pulls in |
|--------|-----------------|
| `@<file>` | Specific file |
| `@<folder>/` | All files in directory |
| `@Docs` | Library documentation |
| `@Terminals` | Terminal output |
| `@Commit` | Uncommitted changes (staged + unstaged) |
| `@Branch` | Full branch diff vs. main |
| `@Past Chats` | Previous conversation |
| `@Browser` | Built-in browser context |

---

# 2.3 — Implicit (no symbol needed)

**Codebase search** — just ask; agent searches the index automatically

**Web search** — ask about current info; agent searches the web

> If the agent isn't finding code, use explicit `@Files` to point it there.

---

# 2.3 — Pinning a Function

Can't use `@file::function` — instead:

1. **Select the function** in the editor → `Cmd+L` (Add to Chat)
2. Or attach the file with `@` and **name the function** in the prompt

```
"@src/lib/latex-generator.ts — look at generateSkills
 and add a matching generateLanguages"
```

---

# 2.3 — Exercise 2

**Try each `@` symbol on the CV Builder**
→ `exercises/README.md § 2a–2d`

---

# 2.4 — `.cursor/rules`

Persistent instructions for Agent. Committed to git. Team-wide.

| Type | When applied |
|------|-------------|
| **Always Apply** | Every Agent session (`alwaysApply: true`) |
| **Specific Files** | When matching files are in context (`globs`) |
| **Intelligently** | Agent decides based on `description` |
| **Manually** | Only when you `@`-mention the rule |

> Rules apply to **Agent (Chat) only** — not Tab or `Cmd+K`.

---

# 2.4 — The CV Builder's Rule

```markdown
---
alwaysApply: true
---
Read the current plan at specs/001-resume-builder/plan.md
```

**Pointer, not content.** The agent reads the file when needed — cheap.

> Use prose pointers for large docs. Use `@filename` in rules only
> for small templates that must load every time.

---

# 2.4 — Context Cost

| Approach | Cost |
|----------|------|
| One pointer rule (`specify-rules.mdc`) | Minimal |
| 3–4 glob-scoped rules | Low, only when files match |
| One massive always-on `general.mdc` | High, every session — avoid |

> If your always-on rules feel like a full page of text,
> you're eating into the context the agent needs for code.

---

# Part 2 — Takeaways

1. **Codebase indexing** — the invisible RAG backbone
2. **`@` system** — highest-leverage skill to master
3. **`.cursor/rules`** — conventions as code, committed to git
4. **Pointer rules > fat rules** — cheap and effective
5. Better context = fewer hallucinations

---

<!-- _class: title -->

# ☕ Break — 10 min

## Part 3 → Agentic Coding & Agent Mode
