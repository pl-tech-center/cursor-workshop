# Cursor Workshop for Engineers

## Overview

A hands-on workshop for engineers who already use Cursor and want to move from ad-hoc usage to deliberate, high-leverage workflows. The session goes deep on context mastery, agent mode, parallelism, and team practices. Examples use **Python and Go** to match the team's stack.

**Duration:** ~4.5 hours (including exercises and Q&A)  
**Format:** Live demo + hands-on exercises  
**Audience:** Engineers with basic Cursor experience (can use Tab autocomplete, `Cmd+K`, and Chat)  
**Prereqs:** See [Pre-Workshop Setup](#pre-workshop-setup) below — includes a self-paced orientation for anyone new to Cursor

---

## Poll-Driven Priorities

Based on the 24-person poll, we're optimizing the session for:

| Signal | Implication |
|---|---|
| **71%** want sub-agents, worktrees & background agents | Part 3 expanded — most demo time here |
| **63%** want context management (`@` system) | Part 2 stays strong |
| **54%** want Rules & Skills | Part 2 + Part 4 both cover this |
| **50%** concerned about security & privacy | Part 4 security section expanded |
| **50%** want Spec-Kit | Part 4 keeps Spec-Kit coverage |
| **29%** interested in chat modes | Part 1 condensed — quick overview, not deep dive |
| Top frustrations: hallucinations (29%), shallow fixes (25%) | Part 3 adds "AI output quality" section |
| 15/24 use Python, 9/24 use Go | All examples rewritten for Python/Go |
| 5 people don't use Cursor yet | Pre-workshop self-paced orientation added to prereqs |

---

## Agenda

| # | Topic | Presenter | Duration |
|---|-------|-----------|----------|
| 0 | Quick-fire alignment (what we're skipping, what we're covering) | Both | 10 min |
| 1 | [Core Features: Power Patterns](./01-fundamentals.md) | **Presenter A** | 40 min |
| — | *Break* | — | 10 min |
| 2 | [Context & Codebase Intelligence](./02-context-and-codebase.md) | **Presenter B** | 50 min |
| — | *Break* | — | 10 min |
| 3 | [Agentic Coding, Sub-agents & Parallelism](./03-agentic-coding.md) | **Presenter A** | 75 min |
| — | *Break* | — | 10 min |
| 4 | [Commands, Skills, Security, MCP & Advanced Workflows](./04-advanced-workflows.md) | **Presenter B** | 80 min |
| — | Wrap-up & Q&A | Both | 15 min |

---

## Topic Split at a Glance

### Presenter A — Core Feature Mastery & Agentic Coding
- Tab autocomplete: next-edit prediction, multi-file context, partial accept
- `Cmd+K` power patterns — generation, iteration, terminal commands
- Chat modes overview — Ask / Edit / Agent / Plan / Debug (condensed — most attendees already use these)
- Agent mode — multi-file edits, reviewing diffs
- **AI output quality** — taming hallucinations and shallow fixes (directly addresses top frustrations)
- **AI Debug mode** — symptom-driven autonomous debugging loop
- Test generation and TDD with agents
- **Sub-agents** — parallel task delegation within agent mode *(expanded — #1 requested topic)*
- **Git worktrees** — multiple agents on multiple branches simultaneously *(expanded)*
- **Cloud / Background agents** — long-running tasks that run without you *(expanded)*

### Presenter B — Context Intelligence & Advanced Workflows
- The `@` context system (files, folders, docs, web, git)
- Codebase indexing and semantic search
- `.cursor/rules` — custom instructions per project
- **Custom Commands** — slash commands for reusable team workflows (`.cursor/commands/`)
- **Skills** — reusable agent capability files (`.cursor/skills/`)
- Standardizing agent output: rules + skills + commands as a layered system
- Prompt engineering patterns for code tasks
- **Security & Privacy** — `.cursorignore`, agent trust model, MCP least-privilege, Cursor as security reviewer *(expanded — 50% concerned)*
- **MCP (Model Context Protocol)** — GitHub, Jira, Confluence integrations
- Team conventions, sharing Cursor config, and **managing PR size with AI workflows**
- **Spec-Kit** — specification-driven development (GitHub)
- **BMAD Method** — agile AI development framework with agent personas
- Model selection (updated for 2026)

---

## Pre-Workshop Setup

1. Ensure Cursor is up to date (Help → Check for Updates)
2. Clone the practice repo: *(add link)*
3. Codebase indexing enabled: `Cursor Settings` → `Features` → `Codebase Indexing` — let it complete before the session starts
4. Preferred model set: Claude Sonnet 4 recommended (`Cmd+Shift+J`)

### New to Cursor? Complete this before the workshop

If you haven't used Cursor before (or have only tried it once or twice), please work through this self-paced orientation so you can hit the ground running on day one.

**1. Install & configure (~5 min)**
- Download Cursor from [cursor.sh](https://cursor.sh)
- Open your main project — codebase indexing will start automatically
- Set your preferred model: `Cmd+Shift+J` → Claude Sonnet 4

**2. Try the three core features (~15 min)**

| Feature | How to try it | What to expect |
|---|---|---|
| **Tab autocomplete** | Open a Python file, start typing a function → ghost-text appears → press Tab to accept | Cursor predicts the next tokens based on context |
| **Inline edit (`Cmd+K`)** | Select a function → `Cmd+K` → type "add type hints" → review the diff → accept or reject | Cursor rewrites the selected code and shows a diff |
| **Chat (`Cmd+L`)** | Open chat → type "explain this file" → read the response | Cursor explains code and answers questions |

**3. Understand the modes (~5 min)**

The chat panel (`Cmd+L`) has tabs at the top — switch between them:
- **Ask** — Q&A, explanations (read-only)
- **Edit** — proposes diffs to the current file
- **Agent** — autonomous multi-file edits (the real power — we'll go deep on this)
- **Plan** — Agent proposes a plan for your approval before acting
- **Debug** — symptom-driven autonomous debugging

**4. Cursor vs. Copilot — why we use both / either**

| If you need… | Use |
|---|---|
| Autocomplete in a familiar IDE | Either works |
| Multi-file autonomous edits | Cursor (Agent mode) |
| Plan → review → execute workflow | Cursor (Plan mode) |
| Sub-agents and parallel workstreams | Cursor |
| Team rules enforced per file type | Cursor (`.cursor/rules/` with globs) |
| Integration with Jira, Confluence, GitHub | Cursor (MCP) |
| Minimal change to existing IDE | Copilot |

Come to the workshop having tried Tab, `Cmd+K`, and Chat at least once. Everything else we'll cover live.

---

## Files in This Workshop

```
cursor-workshop/
├── README.md                    ← This file (agenda & speaker split)
├── 01-fundamentals.md           ← Part 1: Presenter A
├── 02-context-and-codebase.md   ← Part 2: Presenter B
├── 03-agentic-coding.md         ← Part 3: Presenter A
├── 04-advanced-workflows.md     ← Part 4: Presenter B
└── exercises/
    └── README.md                ← All exercises (ex1–ex5)
```
