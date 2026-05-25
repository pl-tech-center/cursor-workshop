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
This is where most work happens. The agent reads files, creates files, runs terminal commands, checks errors, and fixes them in a loop until the task is done.

- Starts with `Cmd+L` — Agent is the default mode
- Reviews diffs per file — accept individually or all at once
- Can run commands in the terminal (tests, builds, linters)
- Uses tools: file search, grep, read, write, terminal, MCP

### Ask mode (read-only exploration)
No edits. The agent can search and read code but cannot modify anything. Use this for understanding, not doing.

- The agent can still search the codebase index and read files
- Useful for onboarding to unfamiliar code, planning before acting, or research
- Hover a code block in the response → click "Apply" to push it into a file (the one write-like action)

### Plan mode (review before execution)
Agent proposes a numbered step-by-step plan before touching any code. You review, edit, or reject before it acts.

- Use for: tasks with multiple valid approaches, anything where a wrong first step is expensive to undo
- The plan becomes a record of intent (useful for PR descriptions)
- After approval, the agent executes exactly the approved steps

### Debug mode (hypothesis-driven)
You give it a **symptom** (not a hypothesis). The agent investigates autonomously — adding logging, running commands, reading output, narrowing the cause.

- Give it: "the PDF is empty when all sections are filled"
- Don't give it: "I think the issue is in generateLatex" (that's your hypothesis — let it form its own)
- Covered in depth in Part 3

### Multitask mode (parallel agents)
Runs multiple agent sessions concurrently. Each session has its own context and can work on independent tasks simultaneously.

- Use for: implementing multiple unrelated features, running tests while coding, research + implementation in parallel
- Each task gets its own thread — they don't share context
- Results appear as they complete — you review each independently
- Covered in depth in Part 3

### Model selection — "explore cheap, commit expensive"

Switch models with `Cmd+Shift+J` or in the model picker at the bottom of chat.

| Task type | Recommended model tier | Why |
|---|---|---|
| Lookups, explanations, exploration | Fast model | Cheap, quick, good enough for reading |
| Standard implementation, refactoring | Default model | Balanced quality/speed |
| Complex architecture, tricky bugs, security review | Reasoning model | Needs deeper thinking, worth the latency |

The key habit: **don't use your most expensive model for "how does this function work?"** — save it for "redesign this module to handle concurrent writes safely."

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

---

*Next: [Part 2 — Context & Codebase Intelligence →](./02-context-and-codebase.md)*
