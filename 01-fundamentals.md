# Part 1 — Core Features: Power Patterns
**Presenter A · ~40 minutes**

> We're assuming everyone has completed the pre-workshop setup and tried Tab autocomplete, `Cmd+K`, and Chat. This section is about the non-obvious depth behind each feature — the behaviours most engineers miss after months of daily use.

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

### Live demo
```
1. Add a new field to a Python dataclass
   → Watch Cursor suggest all the places that need updating
2. Write a repetitive pattern once (e.g., three dict literals with the same shape)
   → Watch it complete the second and third from context
3. Start a function after defining its docstring
   → Watch it infer the full implementation from the docstring
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
"find all Python files modified in the last 24 hours, excluding __pycache__"
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

### Demo
```
1. Select a 20-line Python function → Cmd+K → "add early returns to reduce nesting"
2. Follow up: "now add a docstring with Args and Returns sections"
3. Reject the docstring → try again: "one-line docstring only"
4. Show terminal Cmd+K: generate a git command from a description
```

---

## 1.3 Chat Modes: Quick Overview (10 min)

> Condensed section — 71% of attendees already use chat modes daily. This is a quick reference, not a deep dive.

Chat (`Cmd+L`) has several modes. Switch between them with the toggle at the top of the chat input.

### The modes at a glance

| Mode | What it does | Best for |
|---|---|---|
| **Ask** | Conversation — explains, discusses | Understanding, planning, research |
| **Edit** | Directly modifies the file you're in (diff in-place) | Targeted single-file rewrites |
| **Agent** | Full autonomous multi-file execution loop | Features, refactors, scaffolding |
| **Plan** | Agent proposes steps, you review before execution | Large tasks where mistakes are expensive |
| **Debug** | Symptom-driven autonomous debugging | Bug investigation with breakpoints/logging |

### The escalation pattern
```
Ask:   "How should I restructure this module?"
Plan:  "OK, plan the refactor" → review steps
Agent: approve the plan → it executes
```

### Three tips most people miss
1. **Apply, don't copy-paste** — hover a code block in Ask mode → click "Apply" to diff it into the right file
2. **Switch models mid-conversation** — use a fast model for lookups, a reasoning model for complex logic
3. **Start fresh when context gets stale** — if the model contradicts itself or references old code, `Cmd+L` → new thread

### The decision tree
```
Is it one file?
  → Small, targeted edit       → Cmd+K
  → Need conversation/history  → Chat (Edit tab)
  → Involves other files?      → Chat with @Files or Agent tab
Does it touch multiple files?  → Agent tab (Cmd+L → Agent)
Do you need to understand first? → Chat (Ask tab), then act
```

### Demo
```
1. Quick Ask-mode conversation: understand a piece of Python code across 2 follow-ups
2. Switch to Edit mode on the same file → make a targeted change
3. Apply a code block from Ask mode using the Apply button
```

---

## 1.4 Section Recap & Q&A (5 min)

### Key takeaways
1. **Tab** — follow the next-edit prediction for refactoring; use partial accept (`Cmd+→`) to cherry-pick
2. **`Cmd+K`** — iterate with follow-up prompts; use it in the terminal too
3. **Chat modes** — Ask → Edit → Plan → Agent is an escalation, not a random choice
4. The decision tree (Cmd+K → Chat Edit → Agent) is the most important habit to build

### Habits that separate heavy users from casual ones
- Always follow the next-edit ghost text before reaching for find-and-replace
- Never copy-paste from Chat — always use Apply
- Start a new Chat thread when the conversation has been going more than 10–15 messages
- Use `Cmd+K` in the terminal for shell commands you'd otherwise Google

---

*Next: [Part 2 — Context & Codebase Intelligence →](./02-context-and-codebase.md)*
