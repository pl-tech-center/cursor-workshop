# Part 2 — Context & Codebase Intelligence
**Presenter B · ~35 minutes**

> All demos use the CV Builder app at `/Users/tmarfe/nike/cv-builder`. Open it in Cursor before this section starts.

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
node_modules/
dist/
.vite/
public/core/busytex/       # ~150 MB of WASM assets — keep out of the index
*.pdf
.env
.env.*
!.env.example
secrets/
```

### Demo (using the CV Builder app)
```
Cmd+L → "How does the app turn form data into a PDF?"
→ Cursor searches semantically and surfaces the pipeline:
   ResumeData → generateLatex() in src/lib/latex-generator.ts
              → compilePdf() in src/lib/pdf-compiler.ts (texlyre-busytex Worker)
              → Blob URL → <iframe> in src/components/ReviewView.tsx
```

---

## 2.3 The `@` Context System (20 min)

The `@` symbol is the primary way to **explicitly pull context** into chat or Agent mode. Type `@` in any prompt to see options.

### `@Files` and `@Folders`
Reference specific files or entire directories.

```
"Refactor @src/lib/latex-generator.ts so that every section generator follows the same conditional-empty-string contract used by @src/lib/latex-generator.ts::generateSummary"
```

- Drag-and-drop files into chat also works
- Folders add all contained files (use sparingly for large folders)

### `@Codebase`
Triggers a semantic search across the entire indexed codebase.

```
"@Codebase How does the app turn form data into a PDF?"
```

Best for: cross-cutting concerns, finding existing patterns, understanding unfamiliar code.

> **Note:** In Agent mode, codebase search happens automatically — the agent decides when to search the index without you typing `@Codebase`. The explicit symbol is still useful in Ask/Chat mode, or in Agent mode when you want to force a search the agent didn't initiate on its own.

### `@Docs`
Reference official documentation for any library without copy-pasting.

```
"@Docs Vitest — how do I run a single test file with the @web reporter for nicer diffs?"
"@Docs shadcn/ui Tabs — what props do I need to control the active tab from parent state?"
```

- Cursor fetches and caches docs pages
- Works with any URL: `@Docs https://ui.shadcn.com/docs/components/tabs`
- Add frequently used libraries in `Cursor Settings` → `Features` → `Docs`

### `@Web`
Live web search — useful for recent information the model may not know.

```
"@Web texlyre-busytex 2026 — does the PdfLatex class support per-call timeout yet?"
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
"@Terminal — why is this vitest test failing?"
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

### Demo sequence (using the CV Builder app)
```
1. "@Codebase how does generateLatex assemble sections in the correct order? Where is the order defined?"
2. "@Files @src/lib/latex-generator.ts — add a generator for a Languages section (free-text input, conditional). Match the contract used by generateSkills."
3. "@Docs Vitest — show me the recommended pattern for testing a function that returns a multi-line string with deterministic indentation."
4. "@Git — what changed in src/lib/latex-generator.ts in the last week? Summarise the intent."
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
        ├── typescript.mdc     ← applied to .ts/.tsx files
        ├── react.mdc          ← applied to React components
        └── testing.mdc        ← applied to test files
```

Rules files use `.mdc` format (Markdown with optional frontmatter).

### Rule types

| Type | Description | When applied |
|---|---|---|
| **Always** | Applied to every request | `alwaysApply: true` in frontmatter |
| **Auto-attached** | Applied based on file globs | `globs: ["**/*.ts", "**/*.tsx"]` |
| **Agent-requested** | AI decides when to use | Add description in frontmatter |
| **Manual** | Only when you `@` them | Good for one-off templates |

### The CV Builder's actual rule — `specify-rules.mdc`

The CV Builder ships with exactly one rule, and it's a great pattern worth copying:

```markdown
---
alwaysApply: true
---

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
at specs/001-resume-builder/plan.md
<!-- SPECKIT END -->
```

This is a 4-line, always-on rule that points the agent at the **active spec plan**. The plan is the source of truth for stack decisions (R-001 R-005), constitution gates, and file layout — so every chat in the project sees that context without any `@` reference.

Per-project rules don't have to be long. One always-on pointer + a couple of glob-scoped rules is usually enough.

### Example additions you might layer on top

`typescript.mdc` (auto-attached to `.ts`/`.tsx` files):
```markdown
---
globs: ["**/*.ts", "**/*.tsx"]
---

- Use explicit interfaces in src/lib/types.ts — no inline anonymous shapes for entities.
- Pure functions in src/lib/ must have no side effects (no DOM, no fetch, no Date.now without injection).
- Prefer named exports; reserve default exports for React components.
- Imports: external packages → @/ aliases → relative, separated by blank lines.
- Max file length: 200 lines (matches Constitution VI in plan.md).
```

`react.mdc` (auto-attached to components):
```markdown
---
globs: ["src/components/**/*.tsx"]
---

- All inputs must be controlled (value + onChange) — never uncontrolled.
- Follow the design tokens in DESIGN.md (colors, border-radius, spacing). Do not invent new shades.
- shadcn/ui primitives in components/ui/ are scaffolded by CLI — never modify them directly. Compose them.
- Use crypto.randomUUID() for entry IDs.
```

`testing.mdc`:
```markdown
---
globs: ["tests/**/*.test.ts"]
---

- Use vitest. Test names must describe behaviour: `it('renders Present when isCurrent is true', ...)`.
- Test pure functions in src/lib/ exhaustively; do not write UI component tests — the live PDF preview is the feedback loop (per plan.md Constitution IV).
- Use realistic fixtures from the per-section types in src/lib/types.ts.
```

### Demo (using the CV Builder app)
```
1. Show .cursor/rules/specify-rules.mdc — 4 lines, alwaysApply: true, points at the plan
2. Cmd+L → "Add a generator for a Languages section" — note that Cursor reads plan.md before suggesting code (it knows about Constitution VI, the section ordering rule, the file layout)
3. Open a fresh project without rules → same prompt → suggestions wander away from the project's conventions
4. Show that rules are committed to git → new team members get them automatically (and the spec-kit skills too)
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
