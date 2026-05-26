# Part 4 — Skills, Spec-Kit, Security, MCP & Team Practices
**Presenter B · ~30 minutes**

> The CV Builder ships with the **full Spec-Kit skill set installed** (`.cursor/skills/speckit-*` — 14 skills) plus project skills (`create-issue`, `overview`), and a worked example at `specs/001-resume-builder/`. That makes Skills and Spec-Kit the headline content of this section, not a closing slide.

---

## 4.1 Prompt Engineering for Code Tasks (5 min)

Cursor is only as good as the prompts you give it. These patterns consistently produce better results.

### The STAR prompt structure for code tasks
| Component | Purpose | Example |
|---|---|---|
| **S**ituation | Current state | "The CV Builder has no Languages section yet (optional, between Skills and Projects in the PDF)…" |
| **T**ask | What you want | "…add a Languages section…" |
| **A**pproach | Constraints / preferences | "…single free-text field, return '' when empty (per FR-026), no new dependencies…" |
| **R**eference | Files / docs to follow | "…following @src/lib/latex-generator.ts::generateSkills and the contract in @specs/001-resume-builder/contracts/latex-generation.md" |

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
- No new packages
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
The lesson is not “vague prompt = bad code.” With a well-structured codebase, a bare prompt can produce **good-looking code** that still skips staging, contract updates, or end-to-end wiring. The demo shows **review → constrain → critique**.

**Step 1 — Vague prompt, then review (don't assume failure)**

```
Prompt: "Add a Languages section"
```

Run it live, then walk this checklist with attendees — something is usually missing even when tests pass:

| Check | What to look for |
|---|---|
| **Shape** | Single `languages: string` like `skills`, not `{ name, level }[]` repeatable entries |
| **Generator** | `generateLanguages()` in `@src/lib/latex-generator.ts`, same itemize block as `generateSkills`, returns `''` when empty |
| **Assembly** | Wired into `generateLatex()` between Skills and Projects |
| **Tests** | `describe('generateLanguages')` in `@tests/unit/latex-generator.test.ts` mirroring `generateSkills` |
| **Traceability** | `contracts/latex-generation.md` and `spec.md` updated? |
| **Confusion trap** | Not mixed up with the **"Languages:"** category line inside **Technical Skills** in `resume.tex` |

**Step 2 — STAR prompt (scoped: generator + tests only)**

```
The CV Builder has no Languages section today.
Add generateLanguages() to @src/lib/latex-generator.ts matching the conditional contract
used by generateSkills (single string, return '' when empty, same itemize block).
Add vitest cases in @tests/unit/latex-generator.test.ts matching the generateSkills describe()
block. Do not add a new tab yet — only the generator + tests.
```

→ correct, reviewable first PR: one file pair, explicit contract, tests that run with `npm test`.

**Step 3 — Critique before expanding scope**

```
The generator and tests look fine in isolation. Would Languages appear in the PDF with only
these changes? What's still missing for FR-026 to hold end-to-end?
```

→ surfaces missing `generateLatex()` wiring, then `ResumeData` / `LanguagesForm` / tab — deliberately left out of step 2. Spec-Kit (§4.2) is the systematic version of this same staged flow.

---

## 4.2 Skills — The CV Builder's Worked Example (10 min)

Rules tell Cursor *how to behave*. **Skills** tell it *what workflows to run* — reusable, version-controlled instruction packages (step-by-step workflows, conventions, optional scripts) you invoke with `/skill-name`. The CV Builder ships with 14 Spec-Kit (`speckit-*`) skills plus two project skills (`create-issue`, `overview`); this section uses the Spec-Kit chain as the worked example.

### What's in `cv-builder/.cursor/skills/`

```
.cursor/skills/
├── speckit-constitution/SKILL.md      Create or update project constitution; keep templates in sync
├── speckit-specify/SKILL.md           Create spec.md (+ requirements checklist) from a feature description
├── speckit-clarify/SKILL.md           Ask up to 5 targeted questions; encode answers back into spec.md
├── speckit-plan/SKILL.md              Generate plan.md, research.md, data-model.md, contracts/
├── speckit-tasks/SKILL.md             Generate dependency-ordered tasks.md with phased [P]arallel tags
├── speckit-implement/SKILL.md         Execute tasks.md in order; mark [X]; one [T{id}] commit per task
├── speckit-analyze/SKILL.md           Cross-check spec.md, plan.md, and tasks.md for consistency
├── speckit-checklist/SKILL.md         Generate a requirements-quality checklist for the current feature
├── speckit-taskstoissues/SKILL.md     Convert tasks.md into dependency-ordered GitHub issues
├── speckit-git-initialize/SKILL.md    Initialize a Git repository with an initial commit
├── speckit-git-feature/SKILL.md       Create a numbered feature branch (before_specify hook)
├── speckit-git-commit/SKILL.md        Auto-commit after a Spec Kit command completes (hook)
├── speckit-git-validate/SKILL.md      Validate current branch follows feature branch naming conventions
├── speckit-git-remote/SKILL.md        Detect Git remote URL for GitHub integration
├── create-issue/SKILL.md              Draft and create a GitHub issue via MCP (§4.4)
└── overview/SKILL.md                  Walkthrough of CV Builder domain, stack, and conventions
```

Each skill is a folder containing `SKILL.md`. **Cursor requires** YAML frontmatter with at least `name` and `description`, plus a free-form Markdown body (step-by-step instructions; optional `scripts/`, `references/`, and `assets/` subfolders). Spec-Kit adds custom fields like `compatibility` and `metadata`. Invoke skills as slash commands: `/speckit-specify`, `/speckit-plan`, etc.

### Anatomy of a Spec-Kit skill — `speckit-specify`

The four-section layout below is **Spec-Kit's template**, not a Cursor requirement. Other skills in this repo (`overview`, `speckit-git-commit`, …) use different shapes — copy the pattern when a workflow is multi-step, not because Cursor mandates it.

`speckit-specify` has four sections:

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

→ before_specify hook (`.specify/extensions.yml`): runs /speckit-git-feature first — new branch, then spec
→ creates specs/002-languages-section/ with spec.md + checklists/requirements.md
   (branch `002-languages-section` — speckit-specify auto-numbers by scanning existing specs/)
→ may ask up to 3 clarifying questions for any [NEEDS CLARIFICATION] markers

/speckit-plan
→ produces plan.md, research.md, data-model.md, contracts/

/speckit-tasks
→ produces tasks.md decomposed by user story, with [P]arallel tags

/speckit-implement
→ executes tasks.md in order; marks each task [X]; one [T{id}] commit per task
→ validates tests pass at the end (e.g. npm test on this project)
```

The first visible step is often a **git branch**, not a spec file — `.specify/extensions.yml` wires a mandatory `before_specify` hook that runs `/speckit-git-feature` before `speckit-specify` creates anything under `specs/`.

Walk through the diff with attendees — every file change traces back to a numbered task, which traces back to an FR in the spec.

### Standardising agent output with Rules + Skills

The two layers work together:

```
Rules     → always-on style and constraint enforcement (.cursor/rules/specify-rules.mdc)
Skills    → invocable workflows for whole categories of work (.cursor/skills/speckit-*)
```

### Tips for authoring your own skills

- Start by capturing a workflow you re-type often. Paste your usual prompt into `SKILL.md`, add steps, commit.
- Use `frontmatter.description` carefully — it determines when agent-requested skills auto-trigger.
- To chain skills, say plainly “run `/other-skill` before step 2” in your `SKILL.md` outline — no special syntax (example below). Spec-Kit goes further with `.specify/extensions.yml` hooks and `EXECUTE_COMMAND` — see below.
- Test the skill end-to-end in a fresh chat before committing.

#### Example: plain skill chaining (not installed)

```
---
name: add-latex-section
description: Add a new conditional LaTeX section to the CV Builder following existing patterns.
---

## Outline

1. Run `/overview spec` so you know the spec → plan → tasks → code lineage and conventions.
2. Read `@src/lib/latex-generator.ts::generateSkills` and `@specs/001-resume-builder/contracts/latex-generation.md`.
3. Add `generate{Section}()` matching the empty-string contract; add vitest cases in `@tests/unit/latex-generator.test.ts`.
4. Run `npm test` before finishing.
```

**`EXECUTE_COMMAND`** is a Spec-Kit convention inside `SKILL.md`, not a Cursor API. When a core skill hits Pre-Execution Checks, it reads `.specify/extensions.yml` for hooks (e.g. `before_specify`). For a **mandatory** hook it emits `EXECUTE_COMMAND: speckit.git.feature` — instructing the agent to run `/speckit-git-feature`, wait for it to finish, then resume the parent skill. Optional hooks prompt the user instead of auto-running.

---

## 4.3 Spec-Kit Deeper — Read the Worked Example (5 min)

We already invoked the speckit-* skills in 4.2 to add a Languages section. Now zoom into what's already there: `specs/001-resume-builder/` is the complete artifact set produced by Spec-Kit for the CV Builder itself.

### The command sequence (at a glance)

Spec-Kit separates **what to build** from **how to build it**. The [official workflow](https://github.com/github/spec-kit) is a fixed pipeline — each command produces committed artefacts the next command reads:

```
/speckit.constitution          once per project → .specify/memory/constitution.md
        ↓
/speckit.specify               per feature → spec.md (+ feature branch)
        ↓
/speckit.clarify               optional — resolve ambiguities before planning
        ↓
/speckit.plan                  tech stack & architecture → plan.md, research.md, …
        ↓
/speckit.tasks                 dependency-ordered work → tasks.md
        ↓
/speckit.analyze               optional — cross-check spec / plan / tasks before coding
        ↓
/speckit.implement             execute tasks.md; one [T{id}] commit per task
```

| Command | Focus | Key output |
|---|---|---|
| `/speckit.constitution` | Project principles | `.specify/memory/constitution.md` |
| `/speckit.specify` | **What & why** (no tech stack) | `specs/NNN-feature/spec.md` |
| `/speckit.clarify` | Structured Q&A on gaps | Clarifications section in `spec.md` |
| `/speckit.plan` | **How** — stack, structure, contracts | `plan.md`, `research.md`, `data-model.md`, `contracts/` |
| `/speckit.tasks` | Actionable, ordered work items | `tasks.md` with `[P]` parallel tags |
| `/speckit.analyze` | Consistency & coverage audit | Findings report (no file changes) |
| `/speckit.implement` | Build it | Code + `[T{id}]` commits |

The CV Builder's `001-resume-builder` folder is the output of running this pipeline once, end to end. Section 4.2's Languages demo is the same sequence on a new feature: `002-languages-section`.

### Greenfield vs incremental

The diagram above starts with `/speckit.constitution`, but the §4.2 demo starts at `/speckit-specify` — both are correct, depending on context:

| Scenario | Where you start | Full sequence |
|---|---|---|
| **Greenfield** (001) | `/speckit.constitution` | constitution → specify → clarify? → plan → tasks → analyze? → implement |
| **New feature** (002 Languages, …) | `/speckit-specify` | specify → clarify? → plan → tasks → analyze? → implement |

The constitution (`.specify/memory/constitution.md`) is written once per project. Every later feature reuses it — `/speckit-plan` still runs a Constitution Check against those principles, but you don't re-run `/speckit.constitution` unless the rules themselves need updating. Clarify and analyze remain optional on every feature.

### What's in `specs/001-resume-builder/`

```
specs/001-resume-builder/
├── spec.md              ← /speckit-specify — 6 user stories, 32 functional requirements,
│                        9 success criteria, 9 clarifications, edge cases
├── plan.md              ← /speckit-plan — Constitution Check (6 principles), Technical Context,
│                        Project Structure, post-design re-check
├── research.md          ← /speckit-plan — R-001…R-005: every "why this library" decision
├── data-model.md        ← /speckit-plan — per-entity field-to-LaTeX-argument mapping table
├── contracts/           ← /speckit-plan — latex-generation.md: the escape contract
├── checklists/
│   └── requirements.md  ← /speckit-specify — quality gate for the spec itself
├── tasks.md             ← /speckit-tasks — 45 tasks across 9 phases, [P]arallel tags,
│                        traceable back to user stories
└── quickstart.md        ← /speckit-plan — npm install → npm run dev verification steps
```

**What this gives you in practice:**

- **New team members** read `spec.md` and `plan.md` instead of reverse-engineering the code.
- **Cursor itself** reads them too — `specify-rules.mdc` always points at the current feature's `plan.md`. `/speckit-plan` updates it automatically — so after the Languages demo's plan step, Cursor loads that feature's technical context, not 001's.
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

MCP extends Cursor with **tools** that let the AI interact with external systems — GitHub issues/PRs, Jira tickets, Confluence pages, Postgres queries, internal APIs, etc. MCP servers are lightweight local processes that expose tools the AI can call.

```
Cursor (AI) ←→ MCP Server (local process) ←→ External System (GitHub, Jira, DB, etc.)
```

Think of MCP as: "giving the agent hands that reach outside the codebase." Without MCP, the agent can only read/write local files and run terminal commands. With MCP, it can query databases, read tickets, open PRs, and call APIs — all within the same agentic loop.

### Setting up an MCP server

`Cursor Settings` → `Tools & MCP` → Add server. Configuration lives in `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (project); both merge, project wins on name collision.

For GitHub, use the official [github/github-mcp-server](https://github.com/github/github-mcp-server). Requires Cursor v0.48.0+.

```json
{
  "mcpServers": {
    "github": {
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer YOUR_GITHUB_PAT"
      }
    }
  }
}
```

Match the PAT scope to what you ask the agent to do: **`repo` scope** (fine-grained, single-repo) for listing issues and creating issues/PRs; read-only or minimal scopes when you only need to query. Never commit tokens or `mcp.json` with real credentials.

Once configured, the agent sees the server's tools in its tool list and can call them autonomously. You don't invoke MCP tools directly — the agent decides when to use them based on your prompt.

### How the agent uses MCP tools

The agent's decision flow:
```
Your prompt: "Look at the open issues and fix the one about escape coverage"
→ Agent sees github MCP tools are available
→ Calls list_issues() → reads issue #7 → understands the bug
→ Searches codebase → finds the gap in latex-escape.ts
→ Implements fix → runs tests → calls create_pull_request()
```

You describe the **goal**; the agent picks which MCP tools to call and when.

### Workflow example (CV Builder)

```
Cmd+L → Agent tab →

"Look at the open GitHub issues on the cv-builder repo. Pick the one.
Read it, reproduce locally, fix the bug, add a vitest regression case, commit, and open a PR."
```

This is the full loop — issue → reproduction → fix → test → PR — without leaving Cursor.

### Rules + Skills: governing MCP workflows

MCP gives the agent **tools** (list issues, create PRs). **Rules** and **skills** govern *how* those tools are used — the pattern from §4.2 applies here too:

| Layer | Purpose | CV Builder example |
|---|---|---|
| **MCP server** | External capability (API access) | GitHub MCP → `list_issues`, `issue_write`, `create_pull_request` |
| **Rule** | Shared protocol — safety rails reused everywhere | `.cursor/rules/github-mcp-agent.mdc` — resolve repo from `git remote origin`, confirm before any write, refuse cross-repo requests |
| **Skill** | Invocable workflow for one task | `/create-issue` — polish your description, apply the issue template, present a draft, create on approval |

A **rule** is the contract: one place for confirmation gates, PAT failure handling, and MCP parameter mapping. A **skill** is the recipe: step-by-step orchestration for a slash command that *delegates* to the rule for the actual GitHub calls.

```
/create-issue "Fix latex escape for %"
  → Skill:  draft title + body from .github/ISSUE_TEMPLATE/task.md
  → Rule:   target origin repo only → show proposal → wait for "yes"
  → MCP:    issue_write(method: "create", …)
```

The same rule backs other entry points — ad-hoc "file a GitHub issue", `/speckit-taskstoissues` (bulk), "open a PR" — without duplicating safety logic in each skill. Write the protocol once; compose workflows on top.

### Other useful servers

| Server | What it does | Common use case |
|---|---|---|
| `github/github-mcp-server` | Issues, PRs, files, reviews | Issue → fix → PR loops |
| `mcp-server-jira` | Tickets, transitions, comments | Read ticket context, update status |
| `mcp-server-confluence` | Pages as context | Pull design docs into agent context |
| `@modelcontextprotocol/server-postgres` | Read-only queries | "What does the schema look like?" |

### Lean MCP setup — critical guidelines

MCP tools consume context. Every active server adds its tool descriptions to the prompt. This has real costs:

| Concern | Guideline |
|---|---|
| Context bloat | ~40-tool soft limit. Disable servers you're not using for the current task |
| Security | Tokens in `~/.cursor/mcp.json` only — never commit PATs. Document setup in a committed guide (`docs/github-mcp-setup.md` on cv-builder) or ship `.cursor/mcp.json.example` with placeholders |
| Permissions | Match scope to the workflow: **`repo` scope** (fine-grained, single-repo) for GitHub issue/PR loops; read-only/minimal scopes for query-only servers (Postgres, etc.) |
| Trust | Audit community server source before adding — they run with your credentials and can execute arbitrary code |
| Debugging | If an MCP tool fails, check `Cursor Settings` → `Tools & MCP` → server status (green dot = connected). Restart Cursor if needed. |

### Team sharing pattern

**CV Builder (worked example):** MCP config stays per-developer in `~/.cursor/mcp.json`. The repo commits a setup guide instead of an example config file:

```
cv-builder/
├── docs/github-mcp-setup.md   ← committed (PAT scopes, verification, troubleshooting)
├── .gitignore                 ← excludes .cursor/mcp.json (accidental commit guard)
└── .cursor/
    ├── rules/github-mcp-agent.mdc
    └── skills/create-issue/
```

**Alternative team pattern** — commit placeholders when you want a standard server definition in-repo:

```
your-repo/
├── .cursor/
│   ├── mcp.json              ← gitignored (has real tokens)
│   └── mcp.json.example      ← committed (placeholders + setup instructions)
```

---

## 4.5 Security & Trust (5 min)

### What Cursor sees

| Plan | What leaves your machine | Retained / trained on? |
|---|---|---|
| Free / Pro (Privacy Mode off) | Prompts and code context sent to model providers | May be used to improve Cursor; provider retention varies by subprocessor |
| Pro + Privacy Mode | Same routing to providers, under Zero Data Retention (ZDR) agreements | Not stored or used for training by Cursor or providers |
| Teams / Enterprise | Privacy Mode on by default for team members; admins can enforce org-wide | ZDR; SOC 2 Type II on Enterprise |

> If you wouldn't paste it into a public ChatGPT window, enable Privacy Mode (`Cursor Settings` → `General` → `Privacy Mode`) or join a Teams/Enterprise org that enforces it.

### `.cursorignore` for the CV Builder

cv-builder does **not** ship a `.cursorignore` yet — it relies on `.gitignore` for `public/core/busytex/` and `.env*`. That covers **indexing**, but per [Cursor docs](https://cursor.com/docs/reference/ignore-file), `.gitignore` alone does not block Agent, Tab, or `@`-mention access. Add a `.cursorignore` (or use the global ignore list in Settings) for secrets and large assets:

```
node_modules/
dist/
public/core/busytex/       # ~650 MB of WASM assets — keep out of AI context
*.pdf
.env
.env.*
!.env.example
secrets/
```

If a secret was ever committed, rotate it — the index may have captured it before you added ignore rules.

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

3. "@src/lib/latex-generator.ts — linkedin and website values from ContactForm
   render into \\href{} in the generated PDF (via escapeLatex). Is there an
   injection risk where a crafted URL escapes the href context?"
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
cv-builder/
├── .cursor/
│   ├── rules/                ✓ commit — team coding conventions
│   └── skills/               ✓ commit — 14 speckit-* + create-issue + overview (16 total)
├── docs/github-mcp-setup.md  ✓ commit — per-developer MCP setup (cv-builder pattern)
└── .gitignore                ✓ excludes .cursor/mcp.json

# Alternative: commit .cursor/mcp.json.example instead of a setup guide
.cursor/mcp.json              ✗ never commit — contains tokens
~/.cursor/mcp.json            ✗ global per-developer config (outside the repo)
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
| Security review before merge | Run a targeted Agent prompt on the PR diff (see §4.5) |
| Background agents for tests | Test generation in a separate PR from feature code |

Add to `.cursor/rules/general.mdc` (not shipped on cv-builder yet — add when your team wants this enforced):

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
         + Multitask Mode          Agent as coordinator — delegates to background workers
Layer 5 — Worktrees + Best-of-N    Parallel branches; same task across N models
         + Background agents       Hands-off execution with dev environments
Layer 6 — MCP + Spec-Kit           Issue → fix → PR loops; committed workflow artefacts
```

Most engineers live at Layers 1–2. Today's goal is comfort at 3–5 and awareness of 6.

### Top 7 things to do this week

1. Enable codebase indexing on your main project
2. Add a `.cursor/rules/` with one always-on rule pointing at your current design doc (like `specify-rules.mdc`)
3. Install the speckit-* skills on a real project and run `/speckit-specify` on a small feature
4. Try one Agent task with explicit constraints (STAR prompt, reference an existing file)
5. Use a worktree to run two independent features in parallel
6. Set up GitHub MCP with scope matched to the workflow — read-only for triage; **`repo`** (single-repo) when creating issues/PRs (see `docs/github-mcp-setup.md`)
7. Run a security review prompt on a PR before merging

### Resources

- [Cursor docs](https://docs.cursor.com) · [Cursor forum](https://forum.cursor.com) · [cursor.directory](https://cursor.directory) (rules library)
- [Spec-Kit](https://github.com/github/spec-kit) · [BMAD Method](https://docs.bmad-method.org)
- [MCP servers registry](https://github.com/modelcontextprotocol/servers)
- [texlyre-busytex](https://www.npmjs.com/package/texlyre-busytex) · [shadcn/ui](https://ui.shadcn.com) · [Vitest](https://vitest.dev) (CV Builder stack)

---

### Hands-on

→ [Exercise 5 — Prompt Engineering, Skills, Spec-Kit & MCP](./exercises/README.md#exercise-5--prompt-engineering-skills-spec-kit--mcp) *(after this part, ~20 min)*

---

*[← Back to Part 3](./03-agentic-coding.md) · [Exercises →](./exercises/)*
