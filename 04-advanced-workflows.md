# Part 4 — Advanced Workflows & Team Practices
**Presenter B · ~80 minutes**

---

## 4.1 Prompt Engineering for Code Tasks (10 min)

Cursor is only as good as the prompts you give it. These patterns consistently produce better results.

### The STAR prompt structure for code tasks
| Component | Purpose | Example |
|---|---|---|
| **S**ituation | Current state | "This FastAPI handler does X…" |
| **T**ask | What you want | "…refactor it to Y…" |
| **A**pproach | Constraints / preferences | "…using the repository pattern, no new dependencies…" |
| **R**eference | Files / docs to follow | "…following the style in @src/api/orders.py" |

### Patterns that consistently work

**Pattern 1: "Match the existing pattern"**
```
"Add pagination to the GET /users endpoint.
Match the pagination pattern already used in @src/api/products.py"
```
This prevents Cursor from inventing its own style.

**Pattern 2: Explicit constraints**
```
"Refactor this function. Constraints:
- No new pip packages
- Must remain backward-compatible
- Keep the public interface identical
- All functions must have type hints"
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
| "Write tests" | "Write pytest tests covering the happy path, invalid input, and auth failure" |

### Demo: iterative prompting
```
1. Bad prompt → mediocre result
2. Refined prompt + context → much better result
3. Follow-up critique → catch issues before review
```

---

## 4.2 Custom Commands & Skills (15 min)

Rules tell Cursor *how to behave*. **Commands** and **Skills** tell it *what workflows to run* — they are reusable, invocable prompt templates committed alongside your code.

### Custom Commands
Cursor allows you to define slash commands in `.cursor/commands/`. Each command is a `.md` file whose contents become the prompt when invoked.

```
your-project/
└── .cursor/
    └── commands/
        ├── pr-description.md
        ├── review-security.md
        └── explain-for-junior.md
```

Invoke from Chat or Agent mode: `/pr-description`, `/review-security`, etc.

**Example: `pr-description.md`**
```markdown
Look at the staged changes in @Git diff.

Write a pull request description with:
- A one-sentence summary of what changed and why
- A "Changes" section listing each modified component
- A "Testing" section describing how to verify the change
- Any breaking changes or migration notes

Tone: technical but concise. Audience: the team's engineers.
```

**Example: `review-security.md`**
```markdown
Review the selected code for security vulnerabilities.
Check specifically for:
- Injection vulnerabilities (SQL, command, LDAP)
- Authentication and authorisation gaps
- Sensitive data in logs or responses
- Insecure use of cryptographic functions
- Missing input validation at trust boundaries

Output as a numbered list. For each issue: severity (HIGH/MED/LOW), 
location (file:line), description, and a concrete fix.
```

**Example: `explain-for-junior.md`**
```markdown
Explain the selected code to a junior engineer who is unfamiliar with this codebase.
Avoid jargon. Use an analogy if helpful. Include:
- What this code is responsible for
- Why it exists (the problem it solves)
- What a reader needs to know to safely modify it
```

**Key benefits:**
- Standardizes how the team asks Cursor for common tasks
- Reduces prompt re-typing for frequent workflows
- Commands go through PR review — they are team decisions, not personal preferences

---

### Skills — Reusable Agent Capabilities

Skills are larger, structured prompt files that define how an agent should approach a **category of task**. Think of them as agent personas for specific engineering activities.

```
.cursor/
└── skills/
    ├── incident-response.md
    ├── api-design.md
    └── db-migration.md
```

Invoke a skill explicitly by referencing it:
```
"Follow the process in @.cursor/skills/api-design.md to design the new
payments API. Start with the interface, then the contract, then stub the implementation."
```

**Example: `api-design.md`**
```markdown
# API Design Skill

When asked to design an API, follow these steps in order:

1. **Clarify** — list any ambiguities in requirements and ask before proceeding
2. **Contract first** — define request/response shapes as Pydantic models
3. **Error cases** — enumerate all error conditions and their HTTP status codes
4. **Examples** — write 3 example request/response pairs
5. **Stub** — implement skeleton route handlers with TODO bodies
6. **Review** — self-critique the design for consistency with @src/api/ patterns

Do not write implementation logic until the contract is approved.
```

**Example: `incident-response.md`**
```markdown
# Incident Response Skill

When given a production error or alert:
1. Identify the affected component from the stack trace or logs
2. Search @Codebase for the relevant code paths
3. Propose a short-term mitigation (feature flag, rollback trigger, safe default)
4. Propose a root-cause fix with tests
5. List any other code paths with the same vulnerability
6. Draft a 5-line incident summary for posting in the incident channel
```

### Standardizing agent output with Commands + Skills + Rules

The three layers work together:

```
Rules     → always-on style and constraint enforcement
Skills    → task-type workflows (how to approach design, debugging, review)
Commands  → one-click invocation of specific recurring tasks
```

**Demo**
```
1. Show /pr-description on a real diff — consistent, structured PR every time
2. Show /review-security on a route handler — systematic security check in seconds
3. Show invoking skills/api-design.md to design a new endpoint from scratch
4. Show how a new team member gets all of this for free by cloning the repo
```

---

## 4.3 MCP — Model Context Protocol (10 min)

MCP extends Cursor with tools that let the AI interact with external systems.

### What MCP enables
Instead of just reading/writing files, the agent can:
- Query your database
- Call internal APIs
- Search Confluence / Notion / Linear
- Read and create GitHub issues and PRs
- Read and transition Jira tickets

### Architecture
```
Cursor (AI) ←→ MCP Server ←→ External System
```
MCP servers are lightweight local processes that expose tools the AI can call.

### Setting up MCP in Cursor
`Cursor Settings` → `MCP` → Add server

Example: GitHub MCP server
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
      }
    }
  }
}
```

### Popular MCP servers

| Server | What it does |
|---|---|
| `@modelcontextprotocol/server-github` | Read/create issues, PRs, files |
| `@modelcontextprotocol/server-postgres` | Query PostgreSQL databases |
| `mcp-server-jira` | Read/create Jira tickets, transitions, comments |
| `mcp-server-confluence` | Read Confluence pages as context |
| `@modelcontextprotocol/server-brave-search` | Web search via Brave |
| `@notionhq/notion-mcp-server` | Read/write Notion pages |

### Real workflow examples

**Example 1: Jira ticket → implementation**
```
"Read Jira ticket ENG-1024. Pull the acceptance criteria from the ticket
and the relevant Confluence design doc it links to.
Implement the feature following our patterns in @src/ and @.cursor/rules/"
```
This is the full loop: ticket → design doc → code → tests, without leaving Cursor.

**Example 2: Bug from GitHub issue to PR**
```
Cmd+L → Agent tab →
"Look at GitHub issue #342. Reproduce the reported bug, find the root cause
in the codebase, write a fix with a regression test, and open a PR."
```

**Example 3: Confluence architecture context**
```
"Read the Confluence page 'Event Bus Architecture' before implementing
this new event subscriber. Match the patterns described there."
```

### Demo
```
1. Show MCP config in Cursor Settings
2. Cmd+L → Agent tab → ask it to read a GitHub issue
3. Show it pulling the issue description into context automatically
```

### Security note
> MCP servers run locally with your credentials. Only use servers from trusted sources. Treat the access token scopes with least-privilege principles.

---

## 4.4 Team Conventions & Sharing Cursor Config (10 min)

Getting the whole team productive requires sharing configuration.

### What to commit to git

```
your-repo/
└── .cursor/
    ├── rules/
    │   ├── general.mdc      ✓ commit
    │   ├── python.mdc       ✓ commit
    │   └── testing.mdc      ✓ commit
    ├── commands/
    │   ├── pr-description.md ✓ commit
    │   └── review-security.md ✓ commit
    └── skills/
        └── api-design.md     ✓ commit
```

**Do commit:** `.cursor/rules/`, `.cursor/commands/`, `.cursor/skills/`  
**Do not commit:** `.cursor/mcp.json` if it contains tokens; use environment variables instead

### Onboarding new engineers
Add to your project's README or onboarding doc:
```markdown
## Cursor Setup

1. Install Cursor from https://cursor.sh
2. Open this repo — codebase index will build automatically (~5 min)
3. Review .cursor/rules/ to understand our AI coding conventions
4. Set Privacy Mode if required for this project (Cursor Settings → Privacy Mode)
```

### Creating a team rule library
- Rules are code — they go through PR review
- Add a comment at the top with the rationale
- Use a naming convention: `domain.mdc` (`api.mdc`, `db.mdc`, `testing.mdc`)

### Managing PR size with AI workflows

> One attendee's ask: "A polite way to explain that 5000+ line PRs are not normal and can be avoided."

AI-assisted development makes large PRs worse, not better — the agent can generate 1000 lines in minutes, but review time scales with PR size, not generation time.

**The antidote: scope the agent, scope the PR.**

| Practice | How |
|---|---|
| One agent task = one PR | Give the agent a focused scope; commit and PR when done |
| Use worktrees for parallel features | Each worktree → separate branch → separate PR |
| Use Plan mode for big features | Break the plan into phases; each phase = one PR |
| `/pr-description` command | Forces you to articulate what changed — if you can't summarize it in 3 bullets, the PR is too big |
| Background agents for tests | Run test generation in a separate PR from feature code |

**Team convention to add to your rules:**
```markdown
# In .cursor/rules/general.mdc
- When implementing features, break work into PRs of ≤500 lines of meaningful changes.
- Each PR should be independently reviewable and deployable.
- If a task would produce >500 lines, ask me to help split it into phases first.
```

### Evolving rules over time
When you notice Cursor generating something wrong:
```
1. Identify the pattern that was wrong
2. Add a rule to .cursor/rules/ to prevent it
3. Commit the rule with a short explanation
```
Rules are **living documentation** of your team's decisions.

---

## 4.5 Privacy, Security & Trust (15 min)

> **50% of attendees** are concerned about security. 33% are quite/very concerned. This is not a sidebar — it's a core topic.

### What Cursor knows about your code

Before anything else, engineers need to understand the data flow:

| Plan | What leaves your machine | Retained? |
|---|---|---|
| Free / Pro (default) | Code context sent to model provider (OpenAI/Anthropic) | Up to 30 days |
| Pro + Privacy Mode | Code routed through Cursor's servers only, not to model provider | Never |
| Business | Privacy Mode on by default, SOC 2 Type II | Never |

Enable per project: `Cursor Settings` → `Privacy Mode`

> **Rule of thumb:** If you wouldn't paste it into a public ChatGPT window, enable Privacy Mode or Business plan before working with it in Cursor.

### Working with Cursor in the Nike environment

> Directly addresses the poll question: "How to work with this in Nike env"

Key considerations for enterprise codebases:
1. **Privacy Mode** — enable it for any repo with proprietary business logic
2. **Business plan** — SOC 2 Type II compliance; Privacy Mode on by default
3. **`.cursorignore`** — exclude sensitive configs, secrets, and compliance-sensitive files
4. **MCP token scoping** — fine-grained, read-only, scoped to specific repos
5. **Agent trust** — commit before every agent task; review every diff

### Protecting secrets from indexing

Cursor's codebase index includes all non-gitignored files. Secrets in `.env` files or config folders **will** be indexed unless you exclude them.

Create a `.cursorignore` (same syntax as `.gitignore`):
```
# .cursorignore
.env
.env.*
!.env.example
secrets/
config/production.yml
*.pem
*.key
credentials/
```

Best practice: also add these to `.gitignore` if not already there. If a secret was ever committed, rotate it — Cursor's index may have captured it.

### Preventing secrets from appearing in prompts

When using `@Files` or `@Folders`, Cursor includes file contents in the prompt. Avoid:
```
# DON'T
"@.env — help me refactor the database config"

# DO
"@src/config/database.py — help me refactor this. The env vars it reads are DB_HOST, DB_PORT, DB_NAME"
```

Reference the *names* of env vars. Never attach the file containing the values.

### Agent mode trust model

Agent mode has significantly higher blast radius than Chat or `Cmd+K`:
- It can **create, modify, and delete** files
- It can **run terminal commands** including `rm`, `git push`, package installs
- It can **call MCP tools** with your credentials

**Checklist before running an agent task:**
- [ ] Is the git tree clean? (commit first — your undo button)
- [ ] Does this task need write access to anything sensitive?
- [ ] Are any MCP servers active that have write access you don't need right now?
- [ ] Is Privacy Mode on if the codebase contains proprietary logic?

### MCP least-privilege

MCP servers run with whatever credentials you give them. Default to read-only tokens where possible:

```json
// RISKY: full write token for all repos
{ "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_fullAccessToken" }

// SAFER: fine-grained token, read-only, scoped to one repo
{ "GITHUB_PERSONAL_ACCESS_TOKEN": "github_pat_readOnlyRepoScoped" }
```

For team MCP setups:
- Store tokens in environment variables, never in committed config files
- Use a `.cursor/mcp.json.example` with placeholder values that is committed
- Add `.cursor/mcp.json` (with real values) to `.gitignore`
- Audit MCP server source code before adding community servers — they run with your credentials

### Using Cursor as a security reviewer

Flipping the direction: Cursor can *find* vulnerabilities before attackers do.

**Run `/review-security` on every new route handler, auth change, or data access layer before raising a PR.**

**Targeted security prompts:**
```
"@src/api/payments.py — are there any authorisation checks missing?
A user should only be able to access their own payment records."

"@src/db/queries.py — audit all raw SQL. Flag any that are not
parameterized and could be vulnerable to injection."

"Review @src/auth/ — is there anything here that would fail
an OWASP Top 10 audit?"
```

### Trusting AI-generated code

Agent-generated code lands in your codebase looking identical to human-written code. It is not safer.

| Risk | What to check |
|---|---|
| Plausible-but-wrong logic | Run tests; review diffs line by line |
| Invented API surfaces | Check that called methods/functions actually exist |
| Insecure defaults | Check auth, validation, and error handling in generated routes |
| Supply chain risk | Never let agent mode install packages without reviewing `pyproject.toml` / `go.mod` diff |
| Over-permissive code | Check that generated access control matches your actual requirements |

### Demo
```
1. Show .cursorignore protecting .env files from indexing
2. Run /review-security on a route handler with a subtle IDOR vulnerability
3. Show an Agent diff that adds a package — pause and review before accepting
4. Show MCP config with read-only scoped token vs. full-access token
```

---

## 4.6 Model Selection (5 min)

### Available models (as of 2026)
| Model | Best for |
|---|---|
| Claude Sonnet 4 | Complex reasoning, large codebases, agentic tasks |
| Claude Haiku 3.5 | Fast, lightweight tasks |
| GPT-4.1 | General tasks, fast responses |
| Gemini 2.5 Pro | Very long context windows, complex reasoning |
| o3 | Deep multi-step reasoning, math-heavy problems |
| `cursor-small` | Ultra-fast autocomplete (used for Tab by default) |

You can set different models for autocomplete vs. chat vs. Agent mode.

> **Tip:** For agent tasks on large codebases, Claude Sonnet 4 and Gemini 2.5 Pro are the strongest choices. For quick inline edits, the fast models save time and quota.

---

## 4.7 Structured AI Methodologies: Spec-Kit & BMAD (10 min)

> Spec-Kit was the **#5 most-requested topic** (50%). BMAD was #8 (38%). Both are covered.

---

### Spec-Kit — Specification-Driven Development

**Spec-Kit** ([github.com/github/spec-kit](https://github.com/github/spec-kit)) is GitHub's toolkit for *specification-driven development*: instead of writing code and hoping it matches requirements, you make the specification executable and generate code from it.

#### The Spec-Kit workflow

```
Constitution → Specification → Plan → Tasks → Implement
```

| Phase | Command | What it produces |
|---|---|---|
| Define principles | `/speckit.constitution` | `constitution.md` — project rules & constraints |
| Define requirements | `/speckit.specify` | `specification/*.md` — what to build |
| Plan implementation | `/speckit.plan` | Technical approach and architecture decisions |
| Break down work | `/speckit.tasks` | Implementable task list |
| Generate code | `/speckit.implement` | Working code matching the spec |
| Clarify ambiguity | `/speckit.clarify` | Resolved questions embedded in spec |
| Validate completeness | `/speckit.checklist` | Gap analysis against requirements |

#### Installation
```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

Then open the project in Cursor and use the slash commands in chat or Agent mode.

#### Project structure
```
your-project/
└── .speckit/
    ├── constitution.md     ← immutable project principles
    └── specification/
        ├── auth.md
        └── payments.md
```

#### When to use it
- Greenfield features where requirements need to be explicit before coding starts
- Team alignment — the spec files become living documentation everyone edits
- Brownfield: start by specifying existing code, then iterate

#### Example: writing a constitution
```
/speckit.constitution

"This is a Python FastAPI service.
Principles:
- No runtime type coercion — use Pydantic for all validation
- All external IO must be abstracted behind interfaces
- Tests are required before implementation is accepted
- No package may be added without a security review"
```

---

### BMAD Method — Agile AI-Driven Development Framework

**BMAD** (Build More Architect Dreams — [docs.bmad-method.org](https://docs.bmad-method.org)) is a framework that brings a full software development lifecycle into your AI editor through **specialized agent personas**.

#### Core concept: agent personas
Instead of talking to a generic AI, you invoke a specific expert:

| Agent | Role |
|---|---|
| `@analyst` | Business analysis, requirements, PRFAQs |
| `@pm` | Product management, stories, roadmap |
| `@architect` | System design, ADRs, technical direction |
| `@dev` | Implementation, code review, debugging |
| `@qa` | Test strategy, risk-based testing |
| `bmad-help` | Meta-agent — tells you what to do next |

#### Installation
```bash
npx bmad-method install
```

#### Using BMAD in Cursor
```
"Acting as @architect: review this system design and produce an ADR for
the choice between Kafka and RabbitMQ for our event bus."
```

#### BMAD vs. Spec-Kit — which to choose?

| | Spec-Kit | BMAD |
|---|---|---|
| Focus | Specification → code | Full lifecycle (discovery → deployment) |
| Scope | Single feature/module | Whole product or large initiative |
| Overhead | Low — a few markdown files | Medium — structured artefacts per phase |
| Best for | Developer-led features, API design | Cross-functional initiatives, new products |

> You can use **both**: use BMAD for discovery and architecture phases, then hand off to Spec-Kit for the specification → implementation loop.

---

## 4.8 Productivity Patterns & Anti-Patterns (5 min)

### High-value patterns
- **Rubber duck at scale** — describe a problem in chat before you've even started coding; the act of articulation plus AI response often reveals the solution immediately
- **Code review prep** — "What questions will reviewers ask about this diff?"
- **Documentation generation** — "Write a README section explaining how to use this module"
- **Migration assistance** — "@Codebase — find all places that use the old API and list them"
- **Architecture sounding board** — "Here are 2 approaches. Which is more maintainable at scale?"

### Anti-patterns to avoid
| Anti-pattern | Problem | Fix |
|---|---|---|
| Accepting without reading | AI makes plausible-but-wrong changes | Always read the diff |
| One giant Agent task | Hard to review, risky to roll back | Break into smaller tasks |
| No `.cursor/rules` | Inconsistent output across the team | Add rules for every convention you care about |
| Using AI for everything | Loses your own understanding | Use it to accelerate, not replace, thinking |
| Skipping git commits | No undo for agent mode | Commit before every agent task |
| 5000+ line PRs from agent mode | Unreviewable, risky to merge | Scope the agent → scope the PR |

---

## 4.9 Wrap-Up & Q&A (Both Presenters — 15 min)

### Summary: The capability stack

```
Layer 1 — Tab / Cmd+K / Chat     Individual edits and Q&A
Layer 2 — @Context + Rules       High-quality, consistent single output
Layer 3 — Commands + Skills      Repeatable, team-wide workflows
Layer 4 — Agent tab + Sub-agents  Autonomous multi-file feature work
Layer 5 — Worktrees + Cloud      Parallel, async, background execution
Layer 6 — MCP + Spec-Kit/BMAD    Integrated lifecycle from ticket to deploy
```

Most engineers live at Layers 1–2. Today's goal is comfort at 3–5 and awareness of 6.

### Top 10 things to do this week
1. Enable codebase indexing on your main project
2. Learn all `@` context symbols — practise one per day
3. Add a `.cursor/rules/general.mdc` with 5 team conventions
4. Add a `.cursor/rules/python.mdc` (or `golang.mdc`) with language-specific rules
5. Try one Agent task for a unit of work you'd normally spend 2 hours on
6. Use Plan mode on a task that touches 3+ files
7. Set up the GitHub MCP server (or Jira if that's your workflow)
8. Ask Cursor to write tests for an untested module
9. Share your `.cursor/rules/` in a team PR
10. Run `/review-security` on a PR before merging

### Resources
- [Cursor docs](https://docs.cursor.com)
- [Cursor forum](https://forum.cursor.com)
- [MCP servers registry](https://github.com/modelcontextprotocol/servers)
- [Cursor rules examples](https://cursor.directory)
- [Spec-Kit](https://github.com/github/spec-kit)
- [BMAD Method](https://docs.bmad-method.org)

---

*[← Back to Part 3](./03-agentic-coding.md) · [Exercises →](./exercises/)*
