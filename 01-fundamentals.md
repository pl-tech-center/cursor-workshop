# Part 1 — Core Features: Power Patterns
**Presenter A · ~25 minutes**

> We're assuming everyone has completed the pre-workshop setup and tried Tab autocomplete, `Cmd+K`, and Chat. This section is about the non-obvious depth behind each feature — the behaviours most engineers miss after months of daily use.
>
> **All demos use the CV Builder app** at `../cv-builder`. Open it in Cursor before this section starts.

---

## 1.1 Tab Autocomplete: Beyond "Accept the Line" (10 min)

Cursor's autocomplete goes far beyond single-line suggestions.

### Next-edit prediction (the underused killer feature)
Cursor doesn't just complete what you're typing — it watches your edits and predicts **the next place you need to change** in the file. After renaming a variable, it will ghost-text the same rename at every downstream reference.

```
1. Rename a function parameter at its definition
2. Move cursor away — Cursor highlights the next usage with a ghost edit
3. Tab → accept it → it jumps to the next occurrence
→ One Tab per occurrence, no find-and-replace needed
```

> Most engineers only use Tab for inline completion. Learning to follow the *next-edit* cursor is a 2× productivity multiplier on refactoring tasks.

### What affects completion quality
| Factor | Effect |
|---|---|
| Open tabs | Files open in other tabs are in context |
| Recent edits | Recently edited code weighs more heavily |
| Codebase index | Semantic patterns from the whole repo |
| File size | Very large files get truncated — split large files |

### Partial accept
- `Cmd+→` — accept one word at a time instead of the whole suggestion
- Useful when the first part is right but the end isn't

### When to skip autocomplete
- You already know exactly what to type — just type it
- The suggestion is plausible but subtly wrong — always read it
- For anything architecturally significant — use Agent mode instead

### Pro tips
- Tab predictions improve dramatically when you have related files open in other tabs — open the test file alongside the implementation for best results
- If autocomplete is consistently wrong, check your codebase index status — a stale or incomplete index degrades prediction quality
- For multi-cursor edits, Cursor predicts the next-edit per cursor position — combine multi-cursor with Tab for batch renaming without regex

### Live demo (using the CV Builder app)
```
1. Open src/lib/types.ts → add a new field `employmentType: 'full-time' | 'part-time' | 'contract' | 'freelance' | 'internship'` to the ExperienceEntry interface
   → Watch Cursor suggest updates everywhere ExperienceEntry is constructed:
     - makeExperience() in App.tsx and ExperienceForm.tsx
     - the experienceEntry test fixture in tests/unit/latex-generator.test.ts
     - the type annotations in latex-generator.ts
2. Open src/components/ExperienceForm.tsx → start typing a new <Input> for company website
   → Watch autocomplete suggest the full controlled-input pattern (value, onChange, className) from the surrounding fields
3. Open src/lib/latex-generator.ts → start typing a docstring above generateExperience
   → Watch Cursor infer the full docstring (@param entries, @returns LaTeX block, conditional behaviour) from the implementation
```

---

## 1.2 `Cmd+K` Power Patterns (10 min)

`Cmd+K` opens an inline prompt bar directly in the editor. Most people use it for one round — but iterating with follow-ups is where it gets powerful.

### The full interaction model
```
Select code (optional) → Cmd+K → prompt → review diff → accept/reject → follow-up prompt
```

You can keep iterating in the same `Cmd+K` bar without reopening it. Each follow-up sees the previous result.

### Patterns that produce better diffs

| Pattern | Example |
|---|---|
| Constrain behaviour | `"refactor — do not change the public interface"` |
| Reference a style | `"rewrite to match the style just above this"` |
| Sequential operations | `"first add type hints, then rename to snake_case"` |
| Generate + explain | `"add the logic AND add a docstring explaining the edge case"` |

### `Cmd+K` on the terminal
Often overlooked: you can use `Cmd+K` **inside the terminal panel** to generate and run shell commands.
```
Cmd+K in terminal →
"find all TypeScript files modified in the last 24 hours, excluding node_modules and dist"
→ Cursor generates the find command → you approve and run it
```

### When NOT to use `Cmd+K`
- If the change requires reading other files → use Chat with `@Files`
- If the change spans multiple files → use Agent mode (`Cmd+L` → Agent tab)
- If you need to understand *why* before changing → ask Chat first

### Keyboard shortcuts recap
| Action | Shortcut |
|---|---|
| Open inline prompt | `Cmd+K` |
| Accept change | `Cmd+Enter` |
| Reject change | `Escape` |
| Follow-up prompt | Just keep typing in the same bar |

### Pro tips
- Chain `Cmd+K` with undo (`Cmd+Z`) as a rapid exploration tool: prompt → review → undo → re-prompt with refined constraints
- Select nothing and press `Cmd+K` to generate new code at the cursor position — useful for inserting a new function between existing ones
- In the terminal, `Cmd+K` has access to your shell history — it can reference previous commands in its suggestions

### Demo (using the CV Builder app)
```
1. Select generateExperience() in src/lib/latex-generator.ts → Cmd+K → "add an early return that returns '' if every entry is missing both jobTitle and company"
2. Follow up: "now add a JSDoc block with @param and @returns explaining the conditional behaviour"
3. Reject the JSDoc → try again: "one-line JSDoc only — keep the @param and @returns tags"
4. Show terminal Cmd+K: "run only the latex-generator vitest file in watch mode"
```

---

## 1.3 Chat Modes & Model Selection (10 min)

> Condensed section — 71% of attendees already use chat modes daily. This is a quick reference, not a deep dive.

Chat (`Cmd+L`) has several modes. Switch between them with the mode selector at the top of the chat input.

### The modes at a glance

| Mode | What it does | Best for |
|---|---|---|
| **Agent** | Full autonomous multi-file execution loop | Features, refactors, scaffolding — the default workhorse |
| **Ask** | Read-only conversation — explains, discusses | Understanding code, research, exploration |
| **Plan** | Agent proposes steps, you review before execution | Large tasks where mistakes are expensive |
| **Debug** | Symptom-driven autonomous debugging | Bug investigation with breakpoints/logging |
| **Multitask** | Parallel agent sessions running concurrently | Multiple independent tasks at once |

### Agent mode (the default)
The workhorse. Agent searches your codebase, edits multiple files, runs terminal commands, and fixes errors on its own. Give it a task in plain language and it figures out which files to read, what changes to make, and how to verify the result.

- Starts with `Cmd+L` — Agent is the default mode
- Reviews diffs per file — accept individually or all at once
- Can run commands in the terminal (tests, builds, linters)
- Uses tools: file search, grep, read, write, terminal, MCP

### Ask mode (read-only exploration)
No edits. The agent searches your codebase and provides answers without making any changes. You should be using this mode **far more often than you probably are** — plan with Ask, implement with Agent.

- Useful for onboarding to unfamiliar code, exploring architecture, or research
- Hover a code block in the response → click "Apply" to push it into a file (the one write-like action)

### Plan mode (review before execution)
Creates detailed implementation plans before writing any code. The agent researches your codebase, asks clarifying questions, and generates a reviewable plan you can edit before building.

- Use for: complex features with multiple valid approaches, tasks that touch many files, unclear requirements
- Plans can be saved to the workspace for team sharing and documentation
- If the agent builds something wrong, **revert and refine the plan** — often faster than fixing through follow-up prompts
- Cursor suggests Plan mode automatically when you type keywords indicating complex tasks

### Debug mode (hypothesis-driven)
For bugs that are hard to reproduce or understand. Instead of immediately writing code, the agent generates hypotheses, adds **temporary log statements that send data to a local debug server**, asks you to reproduce the bug, and uses the captured runtime information to pinpoint the exact issue.

The loop:
1. Explore files and generate hypotheses about root causes
2. Add instrumentation (log statements → local debug server)
3. Ask you to reproduce the bug (keeps you in the loop)
4. Analyse captured logs → identify root cause from runtime evidence
5. Make a targeted fix — often just a few lines
6. You verify → agent removes all instrumentation

Best for: bugs you can reproduce but can't figure out, race conditions, performance problems, regressions where something used to work. Covered in depth in Part 3.

### Multitask mode / `/multitask`
Spawns async sub-agents that run in parallel instead of queueing prompts sequentially. Can also auto-decompose a larger request into chunks and assign them to multiple sub-agents at the same time.

- **Queue parallelisation** — stacked prompts run concurrently as background sub-agents
- **Auto-decomposition** — one large request is split into independent chunks, each dispatched to its own sub-agent
- Each sub-agent has its own context window; only the final summary returns to the parent
- The parent stays interactive — you can draft the next prompt or review earlier diffs while the fleet runs
- Combine with `/worktree` when sub-agents need to edit overlapping files (worktree gives filesystem isolation, multitask gives context-only isolation)
- Covered in depth in Part 3

### Switching modes
- **`Shift+Tab`** to cycle through modes
- Click the mode picker dropdown
- Each mode uses its own context — switching starts a fresh context window

### Model selection — "explore cheap, commit expensive"

Switch models with `Cmd+/` (cycle) or the model picker dropdown at the top of the chat input. Your selection persists across conversations until you change it. Set a default in `Cursor Settings` → `Models`.

### Routing options

| Option | What it does | Best for |
|---|---|---|
| **Auto** | Cursor picks per-request, balancing intelligence, cost, and reliability. Defaults to Composer 2; routes to stronger models when complexity warrants it. | Everyday tasks — leave it on unless you have a reason to override |
| **Premium** | Cursor selects the most capable model for you (Opus-class). | Complex tasks where you want maximum quality without choosing manually |
| **Manual** | You pick a specific model from the dropdown. | When you know which model you want, or when comparing models |

### Key models

| Model | Provider | Strengths | When to pick it |
|---|---|---|---|
| **Composer 2.5** | Cursor | Fast, cheap, built for agentic coding | Default workhorse under Auto; speed-critical iteration |
| **Claude Opus 4.7** | Anthropic | Top-tier reasoning, 1M context | Complex architecture, multi-step refactors, security review |
| **Claude Sonnet 4.6** | Anthropic | Strong reasoning, lower cost than Opus | Budget-conscious daily work, extended thinking |
| **GPT-5.5** | OpenAI | Strong agentic coding, 1M context | Alternative perspective when one model family keeps getting stuck |
| **Gemini 3 Pro** | Google | Up to 1M context, multimodal | Image/diagram analysis, extreme context needs |

### The key habit

Don't use Opus for _"how does this function work?"_ — save it for _"redesign this module to handle concurrent writes safely."_ You can switch models **mid-conversation**: use a fast model for exploration, then step up to a reasoning model for implementation.

### Sub-agent model selection

Built-in sub-agents (Explore, Bash, Browser) select their model automatically. Custom sub-agents default to `inherit` (parent's model). Override with the `model` field in the sub-agent's YAML frontmatter.

### Best-of-N for model calibration

Run the same task across 3 models in parallel worktrees (`/best-of-n`) and compare outcomes. This is the cheapest way to learn which model your codebase actually prefers — the answer is rarely what benchmarks imply.

### The escalation pattern
```
Ask:       "How should I restructure this module?"
Plan:      "OK, plan the refactor" → review steps
Agent:     approve the plan → it executes
Multitask: kick off independent tasks in parallel while you keep working
```

### The decision tree
```
Is it one file?
  → Small, targeted edit           → Cmd+K
  → Need conversation/history      → Agent mode (single prompt)
  → Involves other files?          → Agent mode
Does it touch multiple files?      → Agent mode (Cmd+L → Agent)
Multiple independent tasks?        → Multitask mode
Do you need to understand first?   → Ask mode, then switch to Agent
Is it large/risky?                 → Plan mode → review → execute
```

### Pro tips
- You can switch models mid-conversation — start exploration with a fast model, then switch to a reasoning model for the implementation step with `Cmd+/`
- Agent mode queues follow-up messages: submit your next instruction while the agent is busy and it runs automatically when the current task finishes. Drag to reorder queued messages.
- Built-in sub-agents (Explore, Bash, Browser) select their model automatically — they use faster models by default for cost efficiency. Custom sub-agents inherit the parent's model unless you override with the `model` field.

### Demo (using the CV Builder app)
```
1. Ask mode: "How does generateLatex assemble sections into the final document?"
   → follow-up: "What happens if an optional section returns an empty string — does it leave a blank line?"
2. Switch to Agent mode → "When a section is empty, ensure no extra blank line ends up
   between adjacent sections in src/lib/latex-generator.ts"
3. Show the diff Agent proposes → accept or reject
4. Model switch: Cmd+Shift+J → switch to a reasoning model →
   "Review this diff. Are there edge cases where two consecutive empty sections
   would still leave a gap?"
```

---

## 1.4 Section Recap & Q&A (5 min)

### Key takeaways
1. **Tab** — follow the next-edit prediction for refactoring; use partial accept (`Cmd+→`) to cherry-pick
2. **`Cmd+K`** — iterate with follow-up prompts; use it in the terminal too
3. **Chat modes** — Ask → Plan → Agent → Multitask is an escalation, not a random choice
4. The decision tree (Cmd+K → Agent → Multitask) is the most important habit to build

### Habits that separate heavy users from casual ones
- Always follow the next-edit ghost text before reaching for find-and-replace
- Never copy-paste from Chat — always use Apply
- Start a new Chat thread when the conversation has been going more than 10–15 messages
- Use `Cmd+K` in the terminal for shell commands you'd otherwise Google

### Hands-on

→ [Exercise 1 — Tab Autocomplete & `Cmd+K`](./exercises/README.md#exercise-1--tab-autocomplete--cmdk) *(during this part, ~10 min)*

---

*Next: [Part 2 — Context & Codebase Intelligence →](./02-context-and-codebase.md)*
