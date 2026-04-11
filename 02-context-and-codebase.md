# Part 2 — Context & Codebase Intelligence
**Presenter B · ~50 minutes**

---

## 2.1 Why Context Is Everything (5 min)

AI output quality is **directly proportional to the context you provide**. Cursor's `@` system and codebase indexing are the mechanisms that make this practical at scale.

> The difference between a mediocre AI response and an excellent one is usually not the model — it is the context.

This is also why the top frustrations from the poll — hallucinations, shallow fixes, wrong architecture — are mostly **context problems**, not model problems. Better context = dramatically fewer bad outputs.

---

## 2.2 Codebase Indexing (10 min)

Cursor indexes your entire codebase locally to enable semantic search.

### How it works
- Runs once on project open, then incrementally on file changes
- Creates embeddings of your code for semantic similarity search
- Powers the "search codebase" capability in chat

### Checking index status
`Cursor Settings` → `Features` → `Codebase Indexing` → shows file count and status

### What gets indexed
- All text files tracked by git
- Respects `.gitignore` and `.cursorignore`

### `.cursorignore`
```
# Example .cursorignore
__pycache__/
.venv/
*.generated.py
secrets/
vendor/
node_modules/
dist/
```

### Demo
```
Cmd+L → "Where is the authentication middleware defined?"
→ Cursor searches the codebase semantically and returns the exact file + line
```

---

## 2.3 The `@` Context System (20 min)

The `@` symbol is the primary way to **explicitly pull context** into chat or Agent mode. Type `@` in any prompt to see options.

### `@Files` and `@Folders`
Reference specific files or entire directories.

```
"Refactor @src/api/users.py to use the repository pattern from @src/api/products.py"
```

- Drag-and-drop files into chat also works
- Folders add all contained files (use sparingly for large folders)

### `@Codebase`
Triggers a semantic search across the entire indexed codebase.

```
"@Codebase How do we handle rate limiting?"
```

Best for: cross-cutting concerns, finding existing patterns, understanding unfamiliar code.

### `@Docs`
Reference official documentation for any library without copy-pasting.

```
"@Docs FastAPI — how do I define a dependency that validates auth tokens?"
```

- Cursor fetches and caches docs pages
- Works with any URL: `@Docs https://docs.pydantic.dev/latest/...`
- Add frequently used libraries in `Cursor Settings` → `Features` → `Docs`

### `@Web`
Live web search — useful for recent information the model may not know.

```
"@Web latest breaking changes in Go 1.23"
```

Use when: the model's training data may be outdated, or you need current issues/PRs.

### `@Git`
Reference git history for context.

```
"@Git what changed in the last 5 commits to this file?"
"@Git show the diff for commit abc1234"
```

### `@Terminal`
Pull in the output of your last terminal command.

```
# Run failing test, then:
"@Terminal — why is this pytest test failing?"
```

### Context reference cheat sheet

| Symbol | What it references |
|---|---|
| `@Files` | Specific file(s) |
| `@Folders` | All files in a directory |
| `@Codebase` | Semantic search of indexed repo |
| `@Docs` | Library documentation |
| `@Web` | Live web search |
| `@Git` | Git history / diffs |
| `@Terminal` | Last terminal output |
| `@Lint` | Current lint errors |

### Demo sequence
```
1. "@Codebase where is user authentication handled?"
2. "@Files @src/middleware/auth.py — add a check for expired tokens"
3. "@Docs pyjwt — what options does jwt.decode() accept?"
4. "@Git — what changed in auth.py in the last week?"
```

---

## 2.4 `.cursor/rules` — Project-Level Instructions (15 min)

Rules let you encode your team's conventions so Cursor follows them automatically — every session, for everyone on the team. This is the **#3 most-requested topic** from the poll (54%).

### File location
```
your-project/
└── .cursor/
    └── rules/
        ├── general.mdc        ← always-on rules
        ├── python.mdc         ← applied to .py files
        ├── golang.mdc         ← applied to .go files
        └── testing.mdc        ← applied to test files
```

Rules files use `.mdc` format (Markdown with optional frontmatter).

### Rule types

| Type | Description | When applied |
|---|---|---|
| **Always** | Applied to every request | No frontmatter needed |
| **Auto-attached** | Applied based on file globs | `globs: ["**/*.py"]` |
| **Agent-requested** | AI decides when to use | Add description in frontmatter |
| **Manual** | Only when you `@` them | Good for one-off templates |

### Example: `general.mdc`
```markdown
---
description: General coding standards for this project
---

- Follow the existing project structure: handlers → services → repositories.
- All functions must have docstrings (Google style).
- Prefer composition over inheritance.
- All async code must handle errors with try/except and log before re-raising.
- Use named exports / public functions. Avoid exposing internal helpers.
- No hardcoded secrets or credentials — always use environment variables.
```

### Example: `python.mdc` (auto-attached to `.py` files)
```markdown
---
globs: ["**/*.py"]
---

- Use type hints on all function signatures (PEP 484).
- Use `dataclasses` or Pydantic `BaseModel` for data structures — no plain dicts for domain objects.
- Prefer `pathlib.Path` over `os.path`.
- Use f-strings for formatting. No `.format()` or `%` formatting.
- Imports: stdlib → third-party → local, separated by blank lines (isort convention).
- Max function length: 30 lines. Extract if larger.
```

### Example: `golang.mdc` (auto-attached to `.go` files)
```markdown
---
globs: ["**/*.go"]
---

- Always check errors immediately after the call. Never use `_` for error return values.
- Use `context.Context` as the first parameter for functions that do I/O.
- Prefer table-driven tests.
- Structs: exported fields first, then unexported, grouped by concern.
- Use `errors.Is()` / `errors.As()` for error comparison, never `==`.
```

### Example: `testing.mdc`
```markdown
---
globs: ["**/*_test.py", "**/test_*.py", "**/*_test.go"]
---

- Python: use pytest. Test names must describe behavior: `test_returns_404_when_user_not_found`.
- Go: use table-driven tests. Subtests must describe the scenario.
- Mock external services — never make real network calls in tests.
- Aim for 80% branch coverage for business logic.
```

### Demo
```
1. Show a project without rules → generate a Python function → inconsistent style
2. Add python.mdc with team conventions
3. Same prompt → Cursor now follows the conventions automatically
4. Show that rules are committed to git → shared with the whole team
```

### Tips
- Start simple — add rules when you notice Cursor generating code that doesn't match your style
- Rules over ~500 lines get ignored; keep them focused
- Use `@rules` in chat to explicitly cite a rule
- **Rules are living documentation** — treat them like code (PRs, review, iteration)

---

## 2.5 Section Recap & Q&A (5 min)

### Key takeaways
1. **Codebase indexing** gives Cursor semantic knowledge of your whole project
2. The **`@` system** is the highest-leverage skill — learn all the symbols
3. **`.cursor/rules`** encode your team's conventions and are version-controlled
4. Better context = dramatically better output (and fewer hallucinations)

### Common mistakes
- Asking vague questions without `@` references
- Not setting up `.cursorignore` → slow indexing on huge repos
- Forgetting to commit `.cursor/rules` → team doesn't benefit
- Writing rules that are too vague ("write good code") — be specific and concrete

---

*Next: [Part 3 — Agentic Coding & Agent Mode →](./03-agentic-coding.md)*
