---
marp: true
theme: rose-pine
paginate: true
style: |
  section.title {
    display: flex;
    flex-direction: column;
    justify-content: center;
    text-align: center;
  }
  section.title h1 {
    font-size: 3em;
  }
  section.title h2 {
    color: var(--subtle);
    font-weight: 300;
  }
---

<!-- _class: title -->

# Part 4
## Skills, Spec-Kit, Security, MCP & Team

---

# 4.1 — Prompt Engineering

## STAR

| **S**ituation | Current state |
|---|---|
| **T**ask | What you want |
| **A**pproach | Constraints |
| **R**eference | Files to follow |

---

# 4.2 — Rules vs. Skills

```
Rules  → how to behave       (.cursor/rules/)
Skills → what workflow to run (.cursor/skills/)
```

---

# 4.2 — Demo: Spec-Kit Chain

```
/speckit-specify → spec.md
/speckit-plan    → plan.md
/speckit-tasks   → tasks.md
/speckit-implement → code + tests
```

---

# 4.3 — Spec-Kit Artifacts

```
specs/001-resume-builder/
├── spec.md         6 user stories, 32 FRs
├── plan.md         Constitution, structure
├── tasks.md        45 tasks, 9 phases
└── ...
```

Every diff traces to a task → FR → user story.

---

# 4.4 — MCP

```
Cursor ←→ MCP Server ←→ External System
                         (GitHub, Jira, DB)
```

~40-tool limit. Read-only tokens. Never commit secrets.

---

# 4.5 — Automations & Jira

```
Jira ticket → Cursor agent → PR → Bug Bot → human review
```

---

# 4.6 — Security

| Plan | Data retained? |
|------|---------------|
| Free / Pro | Up to 30 days |
| Pro + Privacy Mode | Never |
| Business | Never (SOC 2) |

> Commit before agent tasks. Review every `package.json` diff.

---

# 4.7 — What to Commit

```
.cursor/
├── rules/           ✓  conventions
├── skills/          ✓  workflows
├── agents/          ✓  sub-agents
└── mcp.json.example ✓  placeholders

.cursor/mcp.json     ✗  gitignore (tokens)
```

---

# Exercise 5

**Prompt quality, security review, Spec-Kit chain, MCP**
→ `exercises/README.md § 5a–5f`

---

<!-- _class: title -->

# Wrap-Up
