## Overview

A hands-on workshop for engineers who already use Cursor and want to move from ad-hoc usage to deliberate, high-leverage workflows. The session goes deep on context mastery, mode and model selection, agent mode, parallelism, **Spec-Kit-driven development**, and team practices.

Every demo and exercise runs against a real working app — the **CV Builder** (`../cv-builder/`), a browser-based resume builder built end-to-end with Cursor and Spec-Kit. The app is the through-line of the workshop: you'll explore it, extend it, and add new features to it using every Cursor pattern we cover.

**Duration:** ~3 hours (including exercises and Q&A)  
**Format:** Live demo + hands-on exercises  
**Audience:** Engineers with basic Cursor experience (can use Tab autocomplete, `Cmd+K`, and Chat)  
**Prereqs:** See [Pre-Workshop Setup](#pre-workshop-setup) below — includes a self-paced orientation for anyone new to Cursor

---

## Poll-Driven Priorities

Based on the 24-person poll, the session is optimized for:

| Signal | Implication |
|---|---|
| **71%** want sub-agents, worktrees & background agents | Part 3 expanded — most demo time here |
| **63%** want context management (`@` system) | Part 2 stays strong |
| **54%** want Rules & Skills | Part 2 + Part 4 both cover this — and the CV Builder ships with the 14 `speckit-*` skills installed, so Skills is a live demo, not a slide |
| **50%** concerned about security & privacy | Part 4 security section expanded |
| **50%** want Spec-Kit | **Promoted from sidebar to through-line** — `specs/001-resume-builder/` in the demo app is a worked example of `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` |
| **29%** interested in chat modes | Part 1 condensed — quick overview, not deep dive |
| Top frustrations: hallucinations (29%), shallow fixes (25%) | Part 3 adds "AI output quality" section |
| Mixed stacks across teams | Demo app is TypeScript/React — patterns transfer to any language |
| 5 people don't use Cursor yet | Pre-workshop self-paced orientation added to prereqs |

---

## Agenda

| # | Topic | Presenter | Duration |
|---|-------|-----------|----------|
| 0 | Quick-fire alignment + 60-second tour of the CV Builder demo app | Both | 5 min |
| 1 | [Core Features: Power Patterns](./01-fundamentals.md) | **Presenter A** | 25 min |
| — | *Break* | — | 5 min |
| 2 | [Context & Codebase Intelligence](./02-context-and-codebase.md) | **Presenter B** | 35 min |
| — | *Break* | — | 10 min |
| 3 | [Agentic Coding, Sub-agents & Parallelism](./03-agentic-coding.md) | **Presenter A** | 45 min |
| — | *Break* | — | 5 min |
| 4 | [Skills, Spec-Kit, Security, MCP & Team Practices](./04-advanced-workflows.md) | **Presenter B** | 35 min |
| — | Wrap-up & Q&A | Both | 10 min |

---

## The CV Builder: Demo App at a Glance

A browser-only resume builder. Users fill tabbed forms (Contact, Experience, Education, Skills, Summary, Projects, Certifications), preview a PDF, and download it. All compilation is client-side via a WASM build of pdfTeX.

```
cv-builder/                          (separate repo — cloned alongside this one)
├── DESIGN.md                        ← Apple-inspired design system (referenced by every UI task)
├── resume.tex                       ← Original LaTeX template — visual specification only
├── package.json                     ← React 18 + Vite 6 + Tailwind 4 + shadcn/ui + Vitest
├── public/core/busytex/             ← TeX Live 2026 WASM assets (texlyre-busytex)
├── src/
│   ├── App.tsx                      ← Single useState<ResumeData>, tab switcher
│   ├── components/                  ← 7 form components + ReviewView + shadcn primitives
│   └── lib/
│       ├── types.ts                 ← ResumeData + per-section interfaces
│       ├── latex-preamble.ts        ← Static preamble extracted from resume.tex
│       ├── latex-generator.ts       ← Pure functions: ResumeData → .tex string (1 per section)
│       ├── latex-escape.ts          ← Escapes 10 LaTeX special characters
│       ├── pdf-compiler.ts          ← Async wrapper around texlyre-busytex
│       └── date-format.ts           ← formatMonth, formatDateRange
├── tests/unit/                      ← Vitest — 3 files covering all pure functions
├── specs/001-resume-builder/        ← Spec-Kit output (THE worked example)
│   ├── spec.md                      ← /speckit-specify output (~25KB, 6 user stories, 32 FRs)
│   ├── plan.md                      ← /speckit-plan output
│   ├── research.md                  ← Tech decisions (R-001…R-005)
│   ├── data-model.md                ← Per-entity field-to-LaTeX mapping
│   ├── tasks.md                     ← /speckit-tasks output (45 tasks across 9 phases)
│   ├── contracts/                   ← latex-generation contract
│   ├── checklists/requirements.md   ← Quality gate from /speckit-specify
│   └── quickstart.md
├── .specify/                        ← Spec-Kit config (templates, workflows, integrations)
└── .cursor/
    ├── rules/specify-rules.mdc      ← Always-on rule pointing at the active plan
    └── skills/                      ← 14 speckit-* skills installed and ready to invoke
```

> **Why this app for a Cursor workshop?** Because it was built with Cursor + Spec-Kit, end-to-end. Every artifact — the spec, the plan, the tasks, the implementation, the tests — was produced by the agent. That makes it the ideal canvas for showing what good Cursor workflows actually produce.

---

## Topic Split at a Glance

### Presenter A — Core Feature Mastery & Agentic Coding
- Tab autocomplete: next-edit prediction, multi-file context, partial accept
- `Cmd+K` power patterns — generation, iteration, terminal commands
- **Chat modes + model selection** — matching mode (Ask / Plan / Agent / Debug) and model to the task; the "explore cheap, commit expensive" pattern
- Agent mode — multi-file edits, reviewing diffs
- **AI output quality** — taming hallucinations and shallow fixes
- **AI Debug mode** — hypothesis-driven debugging using Vitest output
- Test generation and TDD with agents (Vitest)
- **Sub-agents** — parallel task delegation with isolated context windows
- **Multitask Mode** — the agent as coordinator, delegating to background workers
- **Git worktrees + Best-of-N** — multiple agents on multiple branches
- **Cloud / Background agents** (optional — not on all laptops) — concept + local fallback (`/worktree` + Agent, `/multitask`); cloud when your org enables it

### Presenter B — Context Intelligence, Spec-Kit & Advanced Workflows
- The `@` context system (files, folders, docs, web, git)
- Codebase indexing, semantic search, and **context window management**
- `.cursor/rules` — custom instructions per project (four application methods); walk through `specify-rules.mdc`
- **Skills** — the CV Builder has the full `speckit-*` skill set installed (14 skills); we'll invoke `/speckit-specify`, `/speckit-plan`, and `/speckit-tasks` live
- **Spec-Kit as a daily-driver workflow** — `specs/001-resume-builder/` is the worked example. We'll add a new section to the resume via the full spec → plan → tasks → implement loop
- Prompt engineering patterns for code tasks
- **Security & Privacy** — `.cursorignore`, agent trust model, MCP least-privilege; the WASM/LaTeX angle in this app (untrusted user input → escape coverage → compiled in-browser)
- **MCP (Model Context Protocol)** — GitHub MCP for issue → PR loops; lean setup practices
- **Cursor Automations** — recurring/event-driven agent workflows in the Agents Window (multi-repo, no-repo)
- **Cursor in Jira** — assign tickets to Cursor or `@Cursor` in comments to trigger cloud agents
- Team conventions, sharing Cursor config, **Bug Bot** for automated PR review, **managing PR size**

---

## Best Practices Quick Reference

Reinforced throughout the workshop:

| Practice | Why |
|---|---|
| **One chat per goal** | Stale context is the #1 cause of hallucinations. Start fresh when switching tasks. |
| **Watch context usage** | Stay under 70-80%. Rules and MCP tools consume context too. |
| **"Explore cheap, commit expensive"** | Use a fast model for lookups; step up to a stronger reasoning model for architecture and complex refactors. |
| **Encode repeatability in skills** | Skills = markdown instructions + executable scripts. The CV Builder's `speckit-*` skills are a worked example. |
| **Lean MCP setup** | ~40-tool limit. Disable servers you're not using. Dynamic Context Discovery helps but fewer is still better. |
| **Never paste secrets** | Use env vars, `.cursorignore`, and secret managers. |
| **Put constraints in rules** | "Minimal diff", "don't change public API" belong in `.cursor/rules/`, not repeated in every prompt. |
| **Spec before you implement** | For anything > a few files, run `/speckit-specify` first. The spec catches scope creep before code does. |

---

## Pre-Workshop Setup

1. Ensure Cursor is up to date (Help → Check for Updates)
2. Clone the workshop repo (this folder — chapter notes + exercises)
3. Clone the demo app alongside this repo and install. You can run `./setup.sh` to do this automatically, or manually:
   ```bash
   cd ../cv-builder
   npm install
   npm run download:tex-assets       # one-time download of TeX Live WASM (~680 MB)
   npm test                          # vitest — all unit tests should pass
   npm run dev                       # opens http://localhost:5173
   ```
4. Codebase indexing: `Cursor Settings` → `Features` → `Codebase Indexing` — let it complete on the `cv-builder` repo before the session
5. Set your default model: fast model for daily use; step up to a stronger reasoning model for complex agent tasks (`Cmd+Shift+J`)

### New to Cursor? Complete this before the workshop

If you haven't used Cursor before (or have only tried it once or twice), please work through this self-paced orientation so you can hit the ground running on day one.

**1. Install & configure (~5 min)**
- Download Cursor from [cursor.sh](https://cursor.sh)
- Open the `cv-builder` repo — codebase indexing will start automatically
- Set your default model: `Cmd+Shift+J`

**2. Try the three core features (~15 min)**

| Feature | How to try it | What to expect |
|---|---|---|
| **Tab autocomplete** | Open `src/lib/types.ts`, start typing a new field on `ExperienceEntry` → ghost-text appears → press Tab to accept | Cursor predicts the next tokens based on context |
| **Inline edit (`Cmd+K`)** | Select `generateExperience` in `src/lib/latex-generator.ts` → `Cmd+K` → type "add JSDoc with @param and @returns" → review the diff → accept or reject | Cursor rewrites the selected code and shows a diff |
| **Chat (`Cmd+L`)** | Open chat → type "explain @src/lib/pdf-compiler.ts" → read the response | Cursor explains code and answers questions |

**3. Understand the modes (~5 min)**

The chat panel (`Cmd+L`) has a mode selector — switch between them:
- **Agent** — autonomous multi-file edits (the default workhorse — we'll go deep on this)
- **Ask** — Q&A, explanations (read-only)
- **Plan** — Agent proposes a plan for your approval before acting
- **Debug** — symptom-driven autonomous debugging
- **Multitask** — parallel agent sessions running concurrently

**4. Browse the Spec-Kit artifacts (~5 min)**

Open `specs/001-resume-builder/` in the CV Builder. Skim:
- `spec.md` — what `/speckit-specify` produced
- `plan.md` — what `/speckit-plan` produced
- `tasks.md` — what `/speckit-tasks` produced

These are real outputs from the skills you'll learn to invoke in Part 4.

Come to the workshop having tried Tab, `Cmd+K`, and Chat at least once, with the demo app running locally. Everything else we'll cover live.

---

## Files in This Workshop

```
cursor-workshop/
├── README.md                    ← This file (agenda & speaker split)
├── one-pager.md                 ← 1-page summary for stakeholders
├── 01-fundamentals.md           ← Part 1: Presenter A
├── 02-context-and-codebase.md   ← Part 2: Presenter B
├── 03-agentic-coding.md         ← Part 3: Presenter A
├── 04-advanced-workflows.md     ← Part 4: Presenter B
└── exercises/
    └── README.md                ← All exercises (ex1–ex5) — run against ../cv-builder
```

The demo app lives in a separate repo: **`../cv-builder/`**. Open it in a second Cursor window alongside this workshop repo for the live demos and exercises.
