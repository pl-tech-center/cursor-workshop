# Workshop Exercises

Hands-on exercises to reinforce each section. Most exercises are 5–15 minutes; Exercises 4–5 run longer (~15–20 min). Do them solo or in pairs.

> **All exercises run against the CV Builder app** at `../cv-builder/`. Open it in Cursor before you start. The app is a browser-only resume builder: tabbed forms → pure TypeScript LaTeX generators → client-side WASM pdfTeX → PDF preview + download. Stack: React 18 + TypeScript 5 + Vite 6 + Tailwind 4 + shadcn/ui + Vitest.
>
> Before starting:
>
> ```bash
> cd ../cv-builder
> npm install
> npm run download:tex-assets   # one-time, ~150 MB of TeX Live WASM
> npm test                      # should be all green before you begin
> npm run dev                   # http://localhost:5173
> ```

---

## Exercise 1 — Tab Autocomplete & `Cmd+K`

_After Part 1 · ~10 min_

### 1a. Next-edit prediction (Tab)

1. Open `src/lib/types.ts`
2. Add a new field `employmentType: 'full-time' | 'part-time' | 'contract' | 'freelance' | 'internship'` to the `ExperienceEntry` interface
3. Watch Cursor suggest matching updates as you tab through:
    - `makeExperience()` in `src/App.tsx`
    - The `experienceEntry` fixture in `tests/unit/latex-generator.test.ts`
4. Accept the suggestions and keep tabbing — note how Cursor predicts the next sensible place to touch

### 1b. Inline edit with `Cmd+K`

1. Open `src/lib/latex-generator.ts`
2. Select the body of `generateExperience()` → `Cmd+K` → `"add an early return that returns '' if every entry is missing both jobTitle and company"`
3. Review and accept the diff
4. Now select the responsibility-bullet block → `Cmd+K` → `"extract this into a private helper renderBullets(items: string[], indent: string): string"`

### 1c. Terminal `Cmd+K`

1. Click in the terminal panel
2. `Cmd+K` → `"run only the latex-generator vitest file in watch mode"`
3. Review the generated `npm run test:watch -- latex-generator` command before running it

---

## Exercise 2 — Context & `@` Symbols

_After Part 2 · ~15 min_

### 2a. Implicit codebase search

1. `Cmd+L` → `"How does the app turn form data into a PDF? Walk me through the pipeline."`
   (No `@Codebase` symbol — codebase search is automatic; the agent queries the index when it needs context.)
2. Note which files Cursor cites. Open them — is the pipeline correct?
   Expected: `ResumeData` in `App.tsx` → `generateLatex()` in `src/lib/latex-generator.ts` → `compilePdf()` in `src/lib/pdf-compiler.ts` (texlyre-busytex Worker) → Blob URL → `<iframe>` in `src/components/ReviewView.tsx`
3. Follow up: `"What WASM functions does pdf-compiler.ts call?"` — the agent should find the right file from the index even without `@Files`.

### 2b. Explicit file reference with `@Files`

1. `Cmd+L` → `"Look at @src/lib/latex-generator.ts and @src/lib/types.ts. For every entity in types.ts, is there a corresponding generator function? Is every field used? Anything orphaned?"`
2. If Cursor finds a gap, fix it with a follow-up prompt.
3. **Contrast with 2a:** when you know the exact files, `@Files` is cheaper and deterministic than hoping the index surfaces them.

### 2c. `@Docs` research

1. `Cmd+L` → `"@Docs Vitest — show me the recommended pattern for testing a function that returns a multi-line string with deterministic indentation. Apply it to the assertions in @tests/unit/latex-generator.test.ts on generateExperience."`
2. Compare to the official docs. Optionally apply one improvement.

### 2d. Git context — `@Commit (Diff of Working State)`

1. Make a small uncommitted change (e.g. add a comment in `src/lib/latex-generator.ts`)
2. `Cmd+L` → `"@Commit (Diff of Working State) — review these changes. Does anything look inconsistent with the patterns in @src/lib/latex-generator.ts? Write a commit message."`

### 2e. Terminal feedback loop with `@Terminals`

1. Run `npm test` in the terminal
2. `Cmd+L` → `"@Terminals — two assertions are failing. Fix the expected output in @tests/unit/latex-generator.test.ts."`
   (If all tests pass, temporarily break an expected string in `latex-generator.test.ts`, re-run `npm test`, then try the prompt.)
3. Note how the agent reads stdout/stderr directly — no copy-paste needed.

### 2f. Branch summary with `@Branch (Diff with Main)`

1. If you're on a feature branch with commits (e.g. after Exercise 2d or a speckit run): `"@Branch (Diff with Main) — summarise everything on this branch for a PR description."`
2. Compare to `@Commit` — branch diff is the full PR scope; commit diff is only uncommitted work.

### 2g. Explore the `.cursor/rules` files

The CV Builder ships three rules in `.cursor/rules/`:

| Rule                          | When it applies                                      |
| ----------------------------- | ---------------------------------------------------- |
| `specify-rules.mdc`           | Always — points the agent at the active feature plan |
| `github-mcp-agent.mdc`        | GitHub MCP writes (confirmation gates; Part 4 §4.4)  |
| `speckit-commit-workflow.mdc` | `[T{id}]` task commits during `/speckit-implement`   |

1. Read `specify-rules.mdc` — note the plan path between `<!-- SPECKIT START -->` and `<!-- SPECKIT END -->` (currently `specs/008-github-mcp-integration/plan.md`; `/speckit-plan` rewrites this for each new feature)
2. Skim `.specify/memory/constitution.md` or `specs/001-resume-builder/plan.md` for project-wide gates (Constitution VI: files < 200 lines, conditional-empty-string contract, PDF section order)
3. Open a new Chat → ask Cursor: `"Add a generateLanguages() function for a Languages section."` — without `@`-mentioning the plan
4. Watch the agent read `plan.md` automatically (look at the citations). Does its proposed code respect the constitution gates and the `generateSkills` contract?
5. **Bonus:** add `.cursor/rules/testing.mdc` with `globs: ["tests/**/*.test.ts"]` enforcing "describe per function, `it()` names describe behaviour, top-of-file fixtures only" (see Part 2 §2.4 example). Re-run the same prompt asking it to also add tests — note the difference.

### 2h. (Bonus) Index hygiene — `.cursorignore`

cv-builder relies on `.gitignore` for indexing but does not ship a `.cursorignore` yet. Per Part 2 §2.2 and Part 4 §4.5, `.gitignore` alone does not block Agent, Tab, or `@`-mention access.

1. Review the recommended `.cursorignore` block in Part 2 §2.2 (excludes `public/core/busytex/`, `.env*`, etc.)
2. Create `.cursorignore` locally (do not commit unless your team agrees) and check `Cursor Settings` → `Indexing & Docs` — does the indexed file count drop?

---

## Exercise 3 — Agent Mode & Output Quality

_After Part 3 · ~15 min_

### 3a. Add a Languages section with Agent mode

1. `Cmd+L` → Agent tab
2. Use this prompt:

    ```
    Add a Languages section to the CV Builder.

    - Languages is a single free-text field (e.g., "English (native), Spanish (B2)")
    - Add the field to ResumeData in @src/lib/types.ts (initial value: '')
    - Add a SkillsForm-style LanguagesForm in @src/components/LanguagesForm.tsx
    - Add generateLanguages() to @src/lib/latex-generator.ts matching the conditional
      contract used by generateSkills (return '' when empty)
    - Use \section{Languages} as the heading; reuse the same itemize block as Skills
    - Wire it into @src/App.tsx as a new tab after Skills, before Projects (per FR-001 in @specs/011-languages-section/spec.md — between Skills and Summary in the current tab bar)
    - Insert `generateLanguages()` in `generateLatex()` between `generateSkills` and `generateProjects` (per FR-030 / FR-007)
    - Add vitest cases in @tests/unit/latex-generator.test.ts matching the generateSkills block
    - Run npm test to verify
    ```

3. Review every file in the diff. Accept.
4. Open `http://localhost:5173`, type something in Languages, click Review, confirm it appears in the PDF.

### 3b. Tame a hallucination

1. Agent tab → `"Add generateAwards() that uses the \\resumeAwardHeading custom command from resume.tex"` — this command doesn't exist
2. Verify: `"@Files @resume.tex — list every \\newcommand. Does \\resumeAwardHeading exist?"`
3. Re-run with constraints: `"Add generateAwards() that REUSES \\resumeProjectHeading the same way generateCertifications() does in @src/lib/latex-generator.ts. Do not invent new custom commands."`
4. Compare both versions — what made the difference?

### 3c. Debug with Agent mode

1. Break something on purpose in `src/lib/latex-escape.ts` — e.g., comment out the `.replace(/%/g, '\\%')` line
2. Run `npm test` — at least one assertion in `latex-escape.test.ts` and one in `latex-generator.test.ts` should fail
3. `Cmd+L` → Agent tab → `"@Terminals — npm test is failing. Find the bug in src/lib/ and fix it. Re-run npm test."`
4. Watch it read the failures, locate the regression, patch, and re-verify

### 3d. Improve a generator's robustness

1. Open `src/lib/latex-generator.ts` and look at `generateContact`
2. `Cmd+L` → Agent tab → `"generateContact's output looks fine when fullName is non-empty, but produces a stray block if fullName is whitespace. Add a precondition: if fullName.trim() is empty, return ''. Add a vitest case in @tests/unit/latex-generator.test.ts asserting this behaviour."`
3. Run `npm test` to confirm

### 3e. TDD loop with Agent mode

1. `Cmd+L` → Agent tab → use this prompt:

    ```
    I need a sortEntriesByDate<T extends { startDate: Date | null }>(entries: T[],
      direction: 'asc' | 'desc'): T[] helper.

    - Live in src/lib/sort-entries.ts (new file)
    - First write tests in tests/unit/sort-entries.test.ts (they should fail — the file doesn't exist yet)
    - Cover: empty array, single entry, null startDate sorted last, stable ordering for equal dates
    - Then implement until every test passes
    - Run npm test
    ```

2. Did Cursor write the tests first, run them, watch them fail, then implement? If it skipped a step, ask it to start over.

### 3f. (Bonus) Use the speckit chain for the same task

_Preview of Part 4 — only if you have time._

1. Reset (`git stash` your work from 3a)
2. `Cmd+L` → Agent tab → `"/speckit-specify Add a Languages section accepting a single free-text field, rendered in the PDF between Skills and Projects, conditional when empty."`
3. Step through `/speckit-plan`, `/speckit-tasks`, `/speckit-implement`
4. Compare the artifacts to your hand-prompted version from 3a. Which version was easier to review? Which would be easier to revisit in 6 months?

---

## Exercise 4 — Sub-agents & Parallelism

_After Part 3 (sub-agents section) · ~15 min_

> The #1 requested topic — this is where it all comes together.

### 4a. Sub-agent delegation: add Languages + Publications in parallel

1. Reset to a clean tree (`git stash` any work from Exercise 3)
2. `Cmd+L` → Agent tab → use this prompt:

    ```
    Add Languages and Publications sections to the CV Builder in parallel.

    Split into parallel sub-tasks:
    1. Languages — single free-text field. Add to types.ts, create LanguagesForm.tsx
       matching SkillsForm, add generateLanguages() matching generateSkills.
    2. Publications — repeatable list (title, venue, date, URL). Add to types.ts,
       create PublicationsForm.tsx matching ProjectsForm, add generatePublications()
       matching generateProjects (use \resumeProjectHeading).
    3. Both — wire into App.tsx (TABS, TAB_LABELS, INITIAL_DATA, TabsContent) and
       add vitest cases in tests/unit/latex-generator.test.ts.

    Run npm test at the end.
    ```

3. Watch Cursor spawn sub-agents and process Languages + Publications concurrently
4. Review the diffs — did each sub-agent stay within its scope? Did the wiring step run only after both completed?
5. Open the app and verify both sections show up in the PDF

### 4b. Worktree parallel work

1. From the `cv-builder` repo:
    ```bash
    git worktree add ../cv-builder-compact-mode feature/compact-mode
    cursor ../cv-builder-compact-mode
    ```
2. In the new window: Agent task → `"Add a 'Compact mode' toggle (Switch) to @src/components/ReviewView.tsx. When on, regenerate the LaTeX with tighter margins by adjusting the geometry package in @src/lib/latex-preamble.ts (e.g., 0.5in margins instead of the current 0.75in). Pass a mode argument through generateLatex."`
3. In the original window: continue with Agent task → `"Add a per-entry 'visible' boolean (default true) to ExperienceEntry. When false, the entry is rendered in the form (so it can be re-enabled) but skipped by generateExperience. Add tests."`
4. Both run without conflicting
5. Clean up: `git worktree remove ../cv-builder-compact-mode`

### 4c. Best-of-N — same task, three models

1. Pick a deliberately ambiguous refactor — there is no one "right" answer:

    ```
    Refactor @src/lib/latex-generator.ts so the section ordering and the
    "skip empty section" filter live in one place instead of being implicit
    in generateLatex's array literal.

    Constraints:
    - Keep the exported generateLatex(data) signature unchanged
    - No new dependencies
    - All existing vitest cases must still pass
    - Stay under the 200-line file cap (Constitution VI in plan.md)
    ```

2. `Cmd+L` → Agent tab → `"Best-of-3: run the refactor above in three isolated worktrees. Use a different model for each attempt (Composer 2.5, Sonnet, and one more of your choice). Do not merge. Present each diff for review."`
3. Read all three diffs side-by-side. Score each on:
    - Diff size relative to the task (smaller wins when constraints are met)
    - Style match against the rest of `src/lib/`
    - New abstractions introduced (usually a smell at this scope)
    - Files touched outside the asked scope (disqualifying unless explained)
4. Cherry-pick the winning branch; discard the worktrees for the others:
    ```bash
    git worktree remove ../cv-builder-bon-1 ../cv-builder-bon-2 ../cv-builder-bon-3
    ```
5. **Reflection:** did the most expensive model win? Often it doesn't. Note which model your codebase actually prefers — that's a calibration data point worth more than benchmarks.

### 4d. (Bonus) Multitask Mode — let the agent coordinate

1. Reset to a clean tree (`git stash`)
2. `Cmd+L` → Agent tab → use this prompt:

    ```
    Add Languages, Awards, and Publications sections to the CV Builder.
    Use Multitask Mode to parallelise the work — you decide how to split it.

    Each section needs: interface in types.ts, form component, generator function
    in latex-generator.ts, vitest cases, and wiring in App.tsx.
    Follow existing patterns. Run npm test at the end.
    ```

3. Compare the experience to 4a where you explicitly defined the sub-tasks. Did the agent make reasonable scoping decisions on its own?

---

## Exercise 5 — Prompt Engineering, Skills, Spec-Kit & MCP

_After Part 4 · ~20 min_

### 5a. Three-step prompt engineering (Part 4 §4.1 demo)

The lesson is not "vague prompt = bad code." A bare prompt can produce good-looking code that still skips wiring, contracts, or tests. Walk through the same three steps as the slide deck.

> **Prerequisite:** If you already built Languages in Exercise 3a, run `git stash` first — otherwise the vague prompt in Step 1 has nothing left to miss. Alternatively, swap "Languages" for a section that does not exist yet (e.g. Hobbies) and adjust the checklist accordingly.

> **Note:** cv-builder may already contain `specs/011-languages-section/` from a prior Spec-Kit run. That does not mean the code is wired — use `git status` and the Step 1 checklist to see what is actually implemented.

**Step 1 — Vague prompt, then review (don't assume failure)**

```
"Add a Languages section"
```

Run it, then walk this checklist — something is usually missing even when tests pass:

| Check              | What to look for                                                                                                        |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------- |
| **Shape**          | Single `languages: string` like `skills`, not `{ name, level }[]` repeatable entries                                    |
| **Generator**      | `generateLanguages()` in `@src/lib/latex-generator.ts`, same itemize block as `generateSkills`, returns `''` when empty |
| **Assembly**       | Wired into `generateLatex()` between Skills and Projects (per FR-030 in `@specs/001-resume-builder/spec.md`)            |
| **Tests**          | `describe('generateLanguages')` in `@tests/unit/latex-generator.test.ts` mirroring `generateSkills`                     |
| **Traceability**   | `contracts/latex-generation.md` and `spec.md` updated?                                                                  |
| **Confusion trap** | Not mixed up with the **"Languages:"** category line inside **Technical Skills** in `resume.tex`                        |

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

→ surfaces missing `generateLatex()` wiring, then `ResumeData` / `LanguagesForm` / tab — deliberately left out of step 2. Spec-Kit (5c) is the systematic version of this staged flow.

### 5b. Security review with Cursor (Part 4 §4.5)

Run the three security questions from the deck:

1. `"@src/lib/latex-escape.ts — review the escape coverage. Are there any LaTeX special characters not handled? What's the worst input a user could supply that would either (a) execute LaTeX commands they shouldn't, or (b) crash the compiler?"`
2. Cross-check the answer against [LaTeX's list of special characters](https://en.wikibooks.org/wiki/LaTeX/Basics#Special_characters) (10 characters). Is the escape function complete?
3. `"@src/lib/pdf-compiler.ts — the texlyre-busytex Worker runs in the browser with the user's compiled tex. Is there any way a crafted .tex file could read files outside the WASM sandbox, or leak data via fetch?"`
4. `"@src/lib/latex-generator.ts — linkedin and website values from ContactForm render into \\href{} in the generated PDF (via escapeLatex). Is there an injection risk where a crafted URL escapes the href context?"`
5. If any review finds a real gap, fix it and add a regression test in `tests/unit/latex-escape.test.ts` or `tests/unit/latex-generator.test.ts`

### 5c. Skills — invoke the full speckit chain (Part 4 §4.2)

_The headline Spec-Kit exercise. Same Volunteering feature as the Part 3 §3.2 demo — if you watched that live, use this step to read the artifacts; otherwise run the chain yourself._

0. Skim `specs/001-resume-builder/` (`spec.md`, `plan.md`, `tasks.md`) to see what a completed Spec-Kit run looks like (Part 4 §4.3)
1. `Cmd+L` → Agent tab → `/speckit-specify Add a "Volunteering" section to the resume builder. Repeatable entries with organisation, role, location, start/end month with "Currently volunteering" toggle, and bullet-point activities. Renders between Projects and Certifications in the PDF using \resumeSubheading.`
2. Watch the `before_specify` hook (`.specify/extensions.yml`) run `/speckit-git-feature` first — a numbered feature branch is created before any spec files appear
3. When `/speckit-specify` presents clarification questions, answer them (max 3)
4. Read the generated `specs/NNN-volunteering-section/spec.md` and `checklists/requirements.md` (NNN is the next free number — e.g. `012` if `011-languages-section` already exists)
5. Run `/speckit-plan` — read `plan.md`, `research.md`, `data-model.md`, `contracts/`; note that `specify-rules.mdc` now points at this feature's plan
6. Run `/speckit-tasks` — read `tasks.md` (look for `[P]` parallel tags)
7. **Optional:** run `/speckit-analyze` to cross-check spec, plan, and tasks before coding (Part 4 §4.3 pipeline)
8. Run `/speckit-implement` — watch the agent tick through tasks in dependency order; one `[T{id}]` commit per task
9. `npm test` should pass at the end

**Reflection:** how much typing did you save vs. authoring 3a manually? Which version produces a better trail for the next person to read? Walk through the diff — every file change should trace back to a task ID → FR → user story.

### 5d. Author a skill of your own (Part 4 §4.2)

1. Create `.cursor/skills/add-section/SKILL.md` capturing the pattern from Exercise 3a so the next engineer can run `/add-section <name> <type>`
2. Frontmatter: `name`, `description` ("Add a new section to the resume builder following the project conventions")
3. Body: numbered steps — start with `Run /overview spec` (or read `@specs/001-resume-builder/contracts/latex-generation.md`), then types.ts, form component, generator matching the empty-string contract, vitest cases, App.tsx wiring, and `npm test` (see the `add-latex-section` example in Part 4 §4.2)
4. Test it end-to-end in a fresh Chat → `/add-section Hobbies single-field` → confirm it does the right thing

### 5e. (Bonus) MCP setup — issue → PR loop (Part 4 §4.4)

If you have a GitHub personal access token (**`repo`** scope, fine-grained, scoped to your `cv-builder` fork):

1. Follow `docs/github-mcp-setup.md` in cv-builder — add the GitHub MCP server to `Cursor Settings` → `Tools & MCP` (config lives in `~/.cursor/mcp.json`, never committed)
2. Note the safety layer: `.cursor/rules/github-mcp-agent.mdc` (confirmation before writes) and `/create-issue` skill (draft → approve → create)
3. Push the CV Builder to your own GitHub fork, open an issue: "Add a Hobbies section" (or run `/create-issue "Add a Hobbies section"`)
4. `Cmd+L` → Agent tab → `"Read the open issue about adding a Hobbies section in <your-fork>. Implement the requested feature using /speckit-specify → /speckit-plan → /speckit-tasks → /speckit-implement. Commit and open a PR."`
5. Watch the full loop — issue → spec → plan → implementation → tests → PR — without leaving Cursor

### 5f. Evolve the rules (Part 4 §4.6)

1. Review the three rules in `.cursor/rules/` — `specify-rules.mdc` (always-on plan pointer), `github-mcp-agent.mdc`, `speckit-commit-workflow.mdc`
2. From the work you've done in Exercises 1–5, identify two conventions Cursor kept getting wrong without explicit reminders
3. Add `.cursor/rules/typescript.mdc` (auto-attached to `**/*.ts`, `**/*.tsx`) capturing them — see the Part 2 §2.4 example for style
4. Re-run an earlier exercise — note whether the rule changes the output
5. **Bonus:** add `.cursor/rules/general.mdc` with the PR-size guidance from Part 4 §4.6 (≤500 lines, split phases). Open a PR adding the new rules — rules go through code review like any other team decision.

---

## Reflection Questions

After completing the exercises, discuss with your pair:

1. Which Cursor feature surprised you most when working on the CV Builder?
2. How would you use Agent mode on a task from your current sprint?
3. What rules would be most valuable for your team to codify? (Compare your `typescript.mdc` from 5f with your pair's.)
4. Where did Cursor get it wrong? What context would have helped?
5. How would you use sub-agents or worktrees to break your current work into smaller PRs?
6. The CV Builder is itself built with Spec-Kit. Which of your current projects would benefit most from `/speckit-specify` before the next feature? What's stopping you from trying it tomorrow?
7. The `speckit-*` skills are committed to `.cursor/skills/` and travel with the repo. What skill would your team write first, and what workflow would it capture?
