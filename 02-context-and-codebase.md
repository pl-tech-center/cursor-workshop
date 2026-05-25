# Part 2 — Context & Codebase Intelligence
**Presenter B · ~35 minutes**

> All demos use the CV Builder app at `../cv-builder`. Open it in Cursor before this section starts.

---

## 2.1 Why Context Is Everything (5 min)

AI output quality is **directly proportional to the context you provide**. Cursor's `@` system and codebase indexing are the mechanisms that make this practical at scale.

> The difference between a mediocre AI response and an excellent one is usually not the model — it is the context.

This is also why the top frustrations from the poll — hallucinations, shallow fixes, wrong architecture — are mostly **context problems**, not model problems. Better context = dramatically fewer bad outputs.

---

## 2.2 Codebase Indexing (10 min)

Cursor indexes your codebase to enable semantic search. Since `@Codebase` no longer exists as an explicit symbol, the index is now **the invisible backbone** — the agent searches it autonomously whenever it needs context. Understanding how the index works is the key to understanding why the agent sometimes finds the right code and sometimes doesn't.

### How it works
- Runs once on project open, then incrementally on file changes
- Creates embeddings of your code for semantic similarity search
- The agent queries the index automatically when it determines it needs more context — you never trigger this explicitly
- Also powers features like Tab autocomplete's multi-file awareness and next-edit prediction

### Checking index status
`Cursor Settings` → `Indexing & Docs` → shows file count and status

> **Important:** If the index is incomplete or stale, the agent will miss relevant code. Always let indexing finish before starting a complex agent session — especially on a fresh clone.

### What gets indexed
- All text files tracked by git (source code, markdown, config files)
- Respects `.gitignore` and `.cursorignore`
- Binary files, images, and compiled output are excluded automatically

### What affects search quality

| Factor | Impact |
|---|---|
| File size | Very large files (>500 lines) get chunked — split them for better retrieval |
| Naming conventions | Descriptive function/variable names improve semantic matches |
| Code comments & docstrings | Help the index understand intent, not just syntax |
| Stale index | After large refactors, give the incremental indexer a few seconds to catch up |

### `.cursorignore`

Excludes files from both the index **and** from being read by the agent. Use it for build artifacts, large bundled assets, secrets, and noise.

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

### Large repo strategies
- **Monorepos:** Only open workspace folders get indexed. Either open just the package(s) you need, or open the monorepo root and use `.cursorignore` to exclude packages you aren't working on
- **Multi-root workspaces:** Each root is indexed independently, but Agent can search **all** open roots — not just the folder of the active file. Use `@Folders` or `.cursorignore` when cross-package noise is a problem
- **Build & package-generated output** (not AI-written code): Exclude artifacts produced by your toolchain — e.g. `dist/` / `.next/` (JS/TS), `__pycache__/` / `*.egg-info/` / `*_pb2.py` (Python), Maven `target/` / Gradle `build/` (Java), `*.pb.go` / `mock_*.go` (Go). They add noise and slow indexing without helping semantic search. Use `.cursorignore` to exclude from both the index and agent access, or `.cursorindexingignore` when you still want the agent to read those files on demand but keep them out of search results

### When the agent doesn't find what you expect

If the agent misses relevant code during a session:
1. Check that indexing is complete (settings panel)
2. Use explicit `@<filename>` or `@<folder>/` references to point it in the right direction
3. Ask directly: "search the codebase for how X works" — this prompts the agent to search more aggressively
4. For cross-cutting concerns, mention multiple related files with `@`

### Demo (using the CV Builder app)
```
1. Show Codebase Indexing status in Settings — note file count
2. Cmd+L → "How does the app turn form data into a PDF?"
   → Agent searches the index autonomously and surfaces the pipeline:
      ResumeData → generateLatex() in src/lib/latex-generator.ts
                 → compilePdf() in src/lib/pdf-compiler.ts (texlyre-busytex Worker)
                 → Blob URL → <iframe> in src/components/ReviewView.tsx
3. Show .cursorignore — note that public/core/busytex/ (150 MB of WASM) is excluded
4. Ask: "What WASM functions does pdf-compiler.ts call?"
   → Agent finds the right file even without @Files, because the index has good embeddings for it
```

---

## 2.3 The `@` Context System (20 min)

The `@` symbol is the primary way to **explicitly pull context** into chat or Agent mode. Type `@` in any prompt to see options.

### `@Files` and `@Folders`
Reference specific files or entire directories. This is your **most-used** context tool — the explicit, precise alternative to hoping the agent finds what it needs.

```
"Refactor @src/lib/latex-generator.ts so that every section generator follows the same conditional-empty-string contract used by @src/lib/latex-generator.ts::generateSummary"
```

```
"Look at @src/components/ — are all form components following the same controlled-input pattern?"
```

**Tips:**
- Drag-and-drop files into chat also works
- Type `@` then start typing a filename — autocomplete narrows the list
- Folders add all contained files (watch context usage on large folders)
- Navigate deeper into folders with `/` after selecting one
- When you know the exact files, `@Files` is always better than hoping the agent searches — it's cheaper on context and deterministic

### Codebase Search (implicit — no `@Codebase` symbol)

The explicit `@Codebase` symbol has been removed. Codebase search is now **automatic** — the agent searches the semantic index on its own when it determines context is needed. You don't need to (and can't) trigger it manually with an `@` mention.

```
"How does the app turn form data into a PDF?"
→ The agent autonomously searches the index and surfaces relevant files
```

Best for: cross-cutting concerns, finding existing patterns, understanding unfamiliar code — just ask in natural language.

> **Tip:** If the agent isn't finding relevant code, use explicit `@Files` or `@Folders` references to point it in the right direction. You can also prompt it directly: "search the codebase for X".

### `@Docs`
Reference indexed documentation for any library without copy-pasting. This is how you get framework-specific guidance that's more accurate than the model's training data.

```
"@Docs Vitest — how do I run a single test file with the @web reporter for nicer diffs?"
"@Docs shadcn/ui Tabs — what props do I need to control the active tab from parent state?"
```

**Setup:**
- Cursor ships with pre-indexed docs for popular libraries (React, TypeScript, Vitest, Tailwind, etc.)
- Add custom documentation sources: `@Docs` → `Add new doc` → paste a URL
- Frequently used libraries: add them in `Cursor Settings` → `Features` → `Docs` so they're always available

**When to use @Docs vs. web search:**
- `@Docs` — stable API references, established libraries with indexed documentation
- Natural language ("check the latest docs for X") — bleeding-edge libraries, recent changelogs, community discussions

**Gotcha:** If `@Docs` returns outdated information, re-index the source in Settings or re-add the URL.

### Web search (implicit — no `@Web` symbol)

The explicit `@Web` symbol has been removed. In Agent mode, the agent can search the web autonomously when it determines it needs current information. Just ask in natural language.

```
"Does texlyre-busytex 2026 support per-call timeout yet? Check the latest docs."
→ The agent decides whether to search the web based on your question
```

Use when: the model's training data may be outdated, or you need current issues/PRs.

### `@Commit (Diff of Working State)` and `@Branch (Diff with Main)`
Git context is now surfaced through two specific symbols rather than a generic `@Git`:

**`@Commit (Diff of Working State)`** — attaches your uncommitted changes (staged + unstaged) as context.
```
"@Commit (Diff of Working State) — review these changes before I commit. Anything I missed?"
"@Commit (Diff of Working State) — write a commit message for these changes"
```

**`@Branch (Diff with Main)`** — attaches the full diff of your current branch vs. main.
```
"@Branch (Diff with Main) — summarise what this branch does for a PR description"
"@Branch (Diff with Main) — are there any inconsistencies across these changes?"
```

These are particularly useful for:
- Pre-commit self-review (catch forgotten files, inconsistencies)
- Generating PR descriptions from the full branch diff
- Understanding what changed since branching

### `@Terminals`
Pull in the output of your terminal(s). Essential for the "run → fail → fix" loop.

```
# Run failing test, then:
"@Terminals — why is this vitest test failing?"
"@Terminals — the build failed. What's wrong?"
```

The agent reads the last N lines of stdout/stderr from your integrated terminal. No need to copy-paste error output.

### `@Past Chats`
Reference context from a previous conversation. Useful when building on earlier work without re-explaining.

```
"@Past Chats — in the chat where we discussed the LaTeX escape coverage, you identified
a gap with tilde characters. Implement that fix now."
```

### `@Browser`
Attach context from Cursor's built-in browser. Useful for capturing visual state or error pages.

```
"@Browser — the app is showing this layout. The spacing between sections is too tight.
Fix the margin in the component that renders section headers."
```

### Context reference cheat sheet

| Symbol | What it references |
|---|---|
| `@<filename>` | Specific file(s) — type `@` then start typing |
| `@<folder>/` | All files in a directory (navigate deeper with `/`) |
| `@Docs` | Indexed library documentation |
| `@Terminals` | Terminal output (stdout/stderr) |
| `@Commit (Diff of Working State)` | Uncommitted changes (staged + unstaged) |
| `@Branch (Diff with Main)` | Full branch diff vs. main |
| `@Past Chats` | Context from a previous conversation |
| `@Browser` | Context from the built-in browser |

**Implicit (no symbol needed):**

| Capability | How to trigger |
|---|---|
| Codebase search | Ask in natural language — agent searches the index automatically |
| Web search | Ask about current info — agent searches the web when needed |

### Demo sequence (using the CV Builder app)
```
1. Implicit codebase search:
   "How does generateLatex assemble sections in the correct order? Where is the order defined?"
   → Agent searches the index automatically — no @Codebase needed

2. Explicit file reference:
   "@src/lib/latex-generator.ts — add a generator for a Languages section (free-text input,
   conditional). Match the contract used by generateSkills."

3. Documentation lookup:
   "@Docs Vitest — show me the recommended pattern for testing a function that returns
   a multi-line string with deterministic indentation."

4. Git context:
   "@Commit (Diff of Working State) — review these changes. Does the new generator match
   the existing pattern? Write a commit message."

5. Terminal feedback loop:
   Run `npm test` in the terminal →
   "@Terminals — two assertions are failing. Fix the expected output in the test file."

6. Branch summary:
   "@Branch (Diff with Main) — summarise everything we did in this session for a PR description."
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

### Context window impact

Rules consume context on every request. This is the trade-off: more rules = more consistent output, but also less room for actual code context.

| Approach | Context cost | When to use |
|---|---|---|
| One `alwaysApply` pointer rule (like `specify-rules.mdc`) | Minimal (~50 tokens) | Always — points the agent at the plan |
| 3-4 glob-scoped rules | Low (~200 tokens each, only when relevant files are touched) | Style enforcement per file type |
| One massive `general.mdc` with 40 rules | High (~2000+ tokens on every request) | Avoid — split into scoped rules instead |

**Rule of thumb:** If your rules total exceeds ~1000 tokens on a given request, you're eating into the context the agent needs for the actual code. Prefer targeted glob-scoped rules over one huge always-on file.

### Tips
- Start simple — add rules when you notice Cursor generating code that doesn't match your style
- Rules over ~500 lines get ignored; keep them focused
- Each rule should be a specific, testable instruction — not vague guidance
- **Rules are living documentation** — treat them like code (PRs, review, iteration)
- When Cursor ignores a rule, it's usually too long or contradicts another rule — simplify
- Glob rules only fire when matching files are in context — cheap and precise

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
