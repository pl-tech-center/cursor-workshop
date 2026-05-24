# Part 4 — Skills, Spec-Kit, Security, MCP & Team Practices
**Presenter B · ~35 minutes**

> The CV Builder ships with the **full Spec-Kit skill set installed** (`.cursor/skills/speckit-*` — 14 skills) and a worked example at `specs/001-resume-builder/`. That makes Skills and Spec-Kit the headline content of this section, not a closing slide.

---

## 4.1 Prompt Engineering for Code Tasks (5 min)

Cursor is only as good as the prompts you give it. These patterns consistently produce better results.

### The STAR prompt structure for code tasks
| Component | Purpose | Example |
|---|---|---|
| **S**ituation | Current state | "The CV Builder has 7 sections, none for Languages…" |
| **T**ask | What you want | "…add a Languages section…" |
| **A**pproach | Constraints / preferences | "…single free-text field, conditional rendering, no new dependencies…" |
| **R**eference | Files / docs to follow | "…following the pattern in @src/lib/latex-generator.ts::generateSkills and the contracts in @specs/001-resume-builder/spec.md FR-026" |

### Patterns that consistently work

**Pattern 1: "Match the existing pattern"**
```
"Add a generateLanguages() function to @src/lib/latex-generator.ts.
Match the contract used by generateSkills exactly (single string in, conditional empty
output, same itemize/leftmargin block)."
```
This prevents Cursor from inventing its own style.

**Pattern 2: Explicit constraints**
```
"Refactor this function. Constraints:
- No new npm packages
- Must remain backward-compatible (no public API breakage)
- Keep the file under 200 lines (per Constitution VI in @specs/001-resume-builder/plan.md)
- Every exported function keeps explicit TypeScript types"
```

**Pattern 3: Step-by-step decomposition**
For large tasks, ask Cursor to plan first:
```
"I want to add OAuth2 login to this app.
First, give me a step-by-step implementation plan.
Don't write any code yet — I want to review the plan first."
```
Then: `"OK, implement step 1"`

**Pattern 4: Critique before committing**
```
"Here is the implementation you just wrote. What are the potential issues,
edge cases, or security concerns I should address before merging?"
```

### What makes a bad prompt
| Bad | Better |
|---|---|
| "Fix the bug" | "The function returns None when the input list is empty. Fix it." |
| "Add a feature" | "Add email notifications when an order status changes to 'shipped'" |
| "Make it better" | "Reduce the cyclomatic complexity of this function. Keep behaviour identical." |
| "Write tests" | "Write vitest tests covering the happy path, invalid input, and the empty-array case" |

### Demo: iterative prompting (using the CV Builder)
```
1. Bad prompt: "Add a Languages section" → mediocre result (invents a new shape, wrong file,
   no test coverage, may add a category structure not in the spec)
2. STAR prompt: "The CV Builder has no Languages section today.
   Add generateLanguages() to @src/lib/latex-generator.ts matching the conditional contract
   used by generateSkills (single string, return '' when empty, same itemize block).
   Add vitest cases in @tests/unit/latex-generator.test.ts matching the generateSkills describe()
   block. Do not add a new tab yet — only the generator + tests." → correct result
3. Follow-up critique: "What edge cases does generateLanguages not handle? Does whitespace-only
   input go through cleanly?" → catches the trim() gap if missing
```

---

## 4.2 Skills — The CV Builder's Worked Example (10 min)

Rules tell Cursor *how to behave*. **Skills** tell it *what workflows to run* — they are reusable, invocable prompt templates committed alongside your code. The CV Builder ships with 14 skills already installed, and this section uses them as the worked example.

### What's in `cv-builder/.cursor/skills/`

```
.cursor/skills/
├── speckit-constitution/SKILL.md      Define project principles & gates
├── speckit-specify/SKILL.md           Generate spec.md + requirements checklist from a feature description
├── speckit-clarify/SKILL.md           Resolve [NEEDS CLARIFICATION] markers via 3-max question batches
├── speckit-plan/SKILL.md              Generate plan.md + research.md + data-model.md + contracts/
├── speckit-tasks/SKILL.md             Decompose the plan into phased, parallel-tagged tasks
├── speckit-implement/SKILL.md         Execute tasks in dependency order, ticking the checklist
├── speckit-analyze/SKILL.md           Re-analyse an existing spec for gaps
├── speckit-checklist/SKILL.md         Produce a quality checklist for any artifact
├── speckit-taskstoissues/SKILL.md     Push tasks.md into GitHub issues for distributed work
├── speckit-git-initialize/SKILL.md    Initialise the spec-kit git extension
├── speckit-git-feature/SKILL.md       Create a feature branch before /speckit-specify
├── speckit-git-commit/SKILL.md        Conventional commit per task
├── speckit-git-validate/SKILL.md      Validate branch + commit shape against extension config
└── speckit-git-remote/SKILL.md        Push to remote and open PR with the spec attached
```

Each skill is a `SKILL.md` file with frontmatter (`name`, `description`, `compatibility`, `metadata`) and a structured prompt body. Invoke them as slash commands: `/speckit-specify`, `/speckit-plan`, etc.

### Anatomy of a skill — `speckit-specify`

The skill has four sections:

1. **User Input** — captures the user's description verbatim
2. **Pre-Execution Checks** — reads `.specify/extensions.yml` for hooks (e.g., git-feature creates a branch before the spec)
3. **Outline** — the step-by-step procedure: name the feature, create the directory, populate `spec.md` from the template, run a quality checklist, present clarifications if any markers remain
4. **Quick Guidelines + Section Requirements** — output rules (focus on WHAT/WHY, not HOW; max 3 `[NEEDS CLARIFICATION]` markers; measurable success criteria)

The key idea: **skills are agent workflows committed alongside code**, in plain Markdown. They go through PR review like any other team decision.

### Demo: invoke the skill chain (using the CV Builder)

```
Cmd+L → Agent tab →

/speckit-specify Add a Languages section to the resume builder.
The section accepts a single free-text field (e.g., "English (native), Spanish (B2)") and
appears in the PDF between Skills and Projects, omitted when empty.

→ produces specs/002-languages-section/spec.md + checklists/requirements.md
→ presents up to 3 clarification questions

/speckit-plan
→ produces plan.md, research.md, data-model.md, contracts/

/speckit-tasks
→ produces tasks.md decomposed by user story, with [P]arallel tags

/speckit-implement
→ executes tasks in dependency order, ticks the checklist as it goes
→ runs npm test at the end
```

Walk through the diff with attendees — every file change traces back to a numbered task, which traces back to an FR in the spec.

### Standardising agent output with Rules + Skills

The two layers work together:

```
Rules     → always-on style and constraint enforcement (.cursor/rules/specify-rules.mdc)
Skills    → invocable workflows for whole categories of work (.cursor/skills/speckit-*)
```

> **Commands are being folded into skills.** Existing `.cursor/commands/*.md` still work but new repeatable workflows should be authored as skills. The CV Builder skips commands entirely.

### Tips for authoring your own skills

- Start by capturing a workflow you re-type often. Paste your usual prompt into `SKILL.md`, add steps, commit.
- Use `frontmatter.description` carefully — it determines when agent-requested skills auto-trigger.
- Reference other skills with `EXECUTE_COMMAND: {command}` for chains (the spec-kit skills do this).
- Test the skill end-to-end in a fresh chat before committing.

---

## 4.3 Spec-Kit Deeper — Read the Worked Example (5 min)

We already invoked the speckit-* skills in 4.2 to add a Languages section. Now zoom into what's already there: `specs/001-resume-builder/` is the complete artifact set produced by Spec-Kit for the CV Builder itself.

```
specs/001-resume-builder/
├── spec.md              ~25 KB — 6 user stories, 32 functional requirements,
│                        9 success criteria, 9 clarifications, edge cases
├── plan.md              Constitution Check (6 principles), Technical Context,
│                        Project Structure, post-design re-check
├── research.md          R-001…R-005 — every "why this library" decision
├── data-model.md        Per-entity field-to-LaTeX-argument mapping table
├── contracts/           latex-generation.md — the escape contract
├── checklists/
│   └── requirements.md  Quality gate produced by /speckit-specify
├── tasks.md             45 tasks across 9 phases, [P]arallel tags,
│                        traceable back to user stories
└── quickstart.md        npm install → npm run dev verification steps
```

**What this gives you in practice:**

- **New team members** read `spec.md` and `plan.md` instead of reverse-engineering the code.
- **Cursor itself** reads them too — `specify-rules.mdc` makes `plan.md` always-on context.
- **The constitution** (in plan.md) is what stops Cursor from inventing helper layers — every chat is reminded that files must stay under 200 lines, that there's no state-management library, that pure functions go in `src/lib/`.
- **Tasks** carry through to commits — every PR diff traces back to a task ID, which traces back to an FR, which traces back to a user story.

### When to use Spec-Kit

| Use Spec-Kit | Skip it |
|---|---|
| Greenfield feature spanning multiple files | One-line bug fix |
| Adding a section/module that follows an existing pattern | Local refactor with no behaviour change |
| Anything you'd normally write a design doc for | Spike / throwaway exploration |
| Brownfield work where you want to capture conventions | Already-spec'd work mid-implementation |

> **BMAD** ([docs.bmad-method.org](https://docs.bmad-method.org)) is a related framework that brings full-lifecycle personas (@analyst, @pm, @architect, @dev, @qa). Heavier than Spec-Kit; useful for cross-functional initiatives. Same philosophy — externalise the workflow into committed artefacts.

---

## 4.4 MCP — Model Context Protocol (5 min)

MCP extends Cursor with tools that let the AI interact with external systems — GitHub issues/PRs, Jira tickets, Confluence pages, Postgres queries, internal APIs, etc. MCP servers are lightweight local processes that expose tools the AI can call.

```
Cursor (AI) ←→ MCP Server ←→ External System
```

### Setting up an MCP server

`Cursor Settings` → `MCP` → Add server. Example: GitHub.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<read-only, fine-grained, scoped to one repo>"
      }
    }
  }
}
```

### Workflow example (CV Builder)

```
Cmd+L → Agent tab →

"Look at the open GitHub issues on the cv-builder repo. Pick the one tagged 'good first issue'.
Read it, reproduce locally, fix the bug, add a vitest regression case, commit, and open a PR."
```

This is the full loop — issue → reproduction → fix → test → PR — without leaving Cursor.

### Other useful servers

| Server | What it does |
|---|---|
| `@modelcontextprotocol/server-github` | Issues, PRs, files |
| `mcp-server-jira` | Tickets, transitions, comments |
| `mcp-server-confluence` | Pages as context |
| `@modelcontextprotocol/server-postgres` | Read-only queries |
| `@notionhq/notion-mcp-server` | Notion docs |

### Lean MCP setup

- ~40-tool soft limit before context bloat — disable servers you're not using
- Tokens via env vars; commit a `.cursor/mcp.json.example` with placeholders only
- Read-only / fine-grained / repo-scoped tokens by default
- Audit community server source before adding — they run with your credentials

---

## 4.5 Security & Trust (5 min)

> **50% of attendees** flagged security as a concern. The fundamentals matter — and the CV Builder gives us very concrete examples since it runs untrusted text through a LaTeX compiler in the user's own browser.

### What Cursor sees

| Plan | What leaves your machine | Retained? |
|---|---|---|
| Free / Pro (default) | Code context sent to model provider | Up to 30 days |
| Pro + Privacy Mode | Routed through Cursor only, not to provider | Never |
| Business | Privacy Mode on by default, SOC 2 Type II | Never |

> If you wouldn't paste it into a public ChatGPT window, enable Privacy Mode (per project: `Cursor Settings` → `Privacy Mode`) or use the Business plan.

### `.cursorignore` for the CV Builder

```
node_modules/
dist/
public/core/busytex/       # 150 MB of WASM assets — keep out of the index
*.pdf
.env
.env.*
!.env.example
secrets/
```

If a secret was ever committed, rotate it — the index may have captured it.

### Agent trust model

Agent mode can create/modify/delete files, run terminal commands, and call MCP tools with your credentials. Before each task:

- [ ] Git tree clean (commit first — your undo button)
- [ ] No write-access MCP servers active that you don't need right now
- [ ] Privacy Mode on if the codebase contains proprietary logic

**Never let Agent mode install packages without reviewing the `package.json` / `package-lock.json` diff.** Supply-chain risk is real.

### Using Cursor as a security reviewer — CV Builder example

The CV Builder takes arbitrary user text and feeds it into a LaTeX compiler. Three real security questions:

```
1. "@src/lib/latex-escape.ts — review the escape coverage. Are there any LaTeX
   special characters not handled? What's the worst input a user could supply
   that would either (a) execute LaTeX commands they shouldn't, or
   (b) crash the compiler?"

2. "@src/lib/pdf-compiler.ts — the texlyre-busytex Worker runs in the browser
   with the user's compiled tex. Is there any way a crafted .tex file could
   read files outside the WASM sandbox, or leak data via fetch?"

3. "@src/components/ContactForm.tsx — the linkedin and website fields render
   into \href{} in the generated PDF. Is there an injection risk where a
   crafted URL escapes the href context?"
```

### AI-generated code is not safer code

| Risk | What to check |
|---|---|
| Plausible-but-wrong logic | Run tests; review diffs line by line |
| Invented API surfaces | Check that called methods/functions actually exist (the Awards-section hallucination from Part 3) |
| Insecure defaults | Check input validation in any new form / API surface |
| Supply chain | Review every `package.json` diff before accepting |

---

## 4.6 Team Conventions & Sharing Cursor Config (3 min)

### What to commit
```
your-repo/
└── .cursor/
    ├── rules/                ✓ commit — team coding conventions
    ├── skills/               ✓ commit — invocable workflows (the CV Builder ships 14)
    └── mcp.json.example      ✓ commit (with placeholder values)
.cursor/mcp.json              ✗ gitignore — contains tokens
```

### Onboarding paragraph for your README

```markdown
## Cursor Setup
1. Install Cursor from cursor.sh
2. Open this repo — codebase indexing starts automatically
3. Review .cursor/rules/ and .cursor/skills/ — these are how we work
4. Enable Privacy Mode if required for this project
```

### Managing PR size with AI workflows

The agent can generate 1000 lines in minutes; review time scales with PR size, not generation time. **Scope the agent → scope the PR.**

| Practice | How |
|---|---|
| One agent task = one PR | Focused scope; commit and PR when done |
| Worktrees for parallel features | Separate worktree → separate branch → separate PR |
| Plan/Spec-Kit for big features | Break the plan into phases; each phase = one PR |
| Bug Bot on every PR | Automated review on the PR before human reviewers see it |
| Background agents for tests | Test generation in a separate PR from feature code |

Add to `.cursor/rules/general.mdc`:

```markdown
- Break work into PRs of ≤500 lines of meaningful changes.
- Each PR should be independently reviewable and deployable.
- If a task would produce >500 lines, ask me to split it into phases first.
```

### Evolving rules over time

When Cursor generates something wrong: identify the pattern → add a rule → commit. Rules are **living documentation** of your team's decisions.

---

## Wrap-Up

### Summary: The capability stack

```
Layer 1 — Tab / Cmd+K / Chat       Individual edits and Q&A
Layer 2 — @Context + Rules         High-quality, consistent single output
Layer 3 — Skills                   Repeatable, team-wide workflows (speckit-* is the worked example)
Layer 4 — Agent + Sub-agents       Autonomous multi-file feature work
Layer 5 — Worktrees + Best-of-N    Parallel branches; same task across N models
                                   + Background agents for hands-off execution
Layer 6 — MCP + Spec-Kit           Integrated lifecycle from ticket to deploy
```

Most engineers live at Layers 1–2. Today's goal is comfort at 3–5 and awareness of 6.

### Top 7 things to do this week

1. Enable codebase indexing on your main project
2. Add a `.cursor/rules/` with one always-on rule pointing at your current design doc (like `specify-rules.mdc`)
3. Install the speckit-* skills on a real project and run `/speckit-specify` on a small feature
4. Try one Agent task with explicit constraints (STAR prompt, reference an existing file)
5. Use a worktree to run two independent features in parallel
6. Set up GitHub or Jira MCP with a read-only, repo-scoped token
7. Run a security review prompt on a PR before merging

### Resources

- [Cursor docs](https://docs.cursor.com) · [Cursor forum](https://forum.cursor.com) · [cursor.directory](https://cursor.directory) (rules library)
- [Spec-Kit](https://github.com/github/spec-kit) · [BMAD Method](https://docs.bmad-method.org)
- [MCP servers registry](https://github.com/modelcontextprotocol/servers)
- [texlyre-busytex](https://www.npmjs.com/package/texlyre-busytex) · [shadcn/ui](https://ui.shadcn.com) · [Vitest](https://vitest.dev) (CV Builder stack)

---

*[← Back to Part 3](./03-agentic-coding.md) · [Exercises →](./exercises/)*
