# Workshop Exercises

Hands-on exercises to reinforce each section. Each exercise is 5–10 minutes. Do them solo or in pairs.

> **All exercises run against the CV Builder app** at `../cv-builder/`. Open it in Cursor before you start. The app is a browser-only resume builder: tabbed forms → pure TypeScript LaTeX generators → client-side WASM pdfTeX → PDF preview + download. Stack: React 18 + TypeScript 5 + Vite 6 + Tailwind 4 + shadcn/ui + Vitest.
>
> Before starting:
> ```bash
> cd ../cv-builder
> npm install
> npm run download:tex-assets   # one-time, ~680 MB of TeX Live WASM
> npm test                      # should be all green before you begin
> npm run dev                   # http://localhost:5173
> ```

---

## Exercise 1 — Tab Autocomplete & `Cmd+K`
*During Part 1 · ~10 min · follow along with the presenter*

### 1a. Next-edit prediction (Tab)
1. Open `src/lib/types.ts`
2. Add a new field `employmentType: 'full-time' | 'part-time' | 'contract' | 'freelance' | 'internship'` to the `ExperienceEntry` interface
3. Watch Cursor suggest matching updates as you tab through:
   - `makeExperience()` in `src/App.tsx` and `src/components/ExperienceForm.tsx`
   - The `experienceEntry` fixture in `tests/unit/latex-generator.test.ts`
4. Accept the suggestions and keep tabbing — note how Cursor predicts the next sensible place to touch

### 1b. Inline edit with `Cmd+K`
1. Open `src/lib/latex-generator.ts`
2. Select the body of `generateEducation()` → `Cmd+K` → `"if degree is empty, fall back to fieldOfStudy as the first line of the subheading"`
3. Review the diff — does it match the surrounding style? Accept or reject.
4. Follow-up in the same `Cmd+K` bar: `"also handle the case where both degree and fieldOfStudy are empty — skip the entry entirely"`
5. Accept, then undo both (`Cmd+Z`) to leave the file clean.

### 1c. Terminal `Cmd+K`
1. Click in the terminal panel
2. `Cmd+K` → `"show the git log for latex-generator.ts — last 5 commits, one line each"`
3. Review the generated command before running it
4. Try another: `Cmd+K` → `"count the lines of code in src/lib/ excluding blank lines and comments"`

---

## Exercise 2 — Context & `@` Symbols
*After Part 2 · ~15 min*

Reinforces [Part 2 — Context & Codebase Intelligence](../02-context-and-codebase.md): indexing (§2.2), the `@` system (§2.3), and `.cursor/rules` (§2.4).

### 2a. Implicit codebase search (§2.2–2.3)
1. `Cmd+L` → `"How does the app turn form data into a PDF? Walk me through the pipeline."`
   (No `@Codebase` symbol — the agent searches the codebase index automatically.)
2. Note which files Cursor cites. Open them — is the pipeline correct? (Expected: `App.tsx` → `ReviewView.tsx` → `latex-generator.ts` → `pdf-compiler.ts` → `<iframe>`)
3. If the agent misses `pdf-compiler.ts`, escalate per Part 2 troubleshooting: attach `@src/lib/pdf-compiler.ts` or ask `"search the codebase for browser-side LaTeX compilation"`.

### 2b. Indexing & ignore files (§2.2)
1. `Cursor Settings` → `Indexing & Docs` — confirm indexing is complete; note the file count.
2. Open `.gitignore` → find `public/core/busytex/` (~680 MB of WASM). Why is it excluded from the index even though cv-builder has no `.cursorignore`?
3. In one sentence, explain the difference between `.gitignore` and `.cursorignore` (from §2.2).

### 2c. Explicit `@Files` — pin the contract (§2.3)
Part 2’s `@Files` pattern: attach the exact files you need — cheaper and more deterministic than implicit search (contrast with **2a**).

1. `Cmd+L` → `"In @src/lib/latex-generator.ts — using generateSummary() as the reference, which section generators return '' when their section is empty? Which one behaves differently?"`
   (Expected: `generateExperience`, `generateEducation`, `generateSkills`, `generateProjects`, and `generateCertifications` follow the pattern; **`generateContact` always emits a contact block** — even when optional fields are blank.)
2. Follow up with the spec attached: `"@specs/001-resume-builder/contracts/latex-generation.md @src/lib/latex-generator.ts — does the contract explain why generateContact is the exception? Quote the relevant line."`
   (Expected: the contract’s document structure lists the contact block as **always present**; optional sections omit output when empty.)
3. **Do not change any code** — this step is read-only. You’ll implement a new generator in **2e**.

### 2d. `@Docs` lookup (§2.3)
1. `Cmd+L` → `"@Docs Vitest — how do I run tests in watch mode for a single file?"`
2. Run the command it suggests (expected: `npm run test:watch -- latex-generator` or `npx vitest tests/unit/latex-generator.test.ts`). Leave watch running for **2e**.


### 2e. TDD, `@Terminals`, and git context (§2.3)
1. `git checkout -b workshop/context-demo`
2. `Cmd+L` → `"@tests/unit/latex-generator.test.ts @src/lib/latex-generator.ts — add describe('generateLanguages') mirroring generateSkills. Use toContain assertions. Do NOT implement generateLanguages yet."`
3. Watch the terminal — tests should fail (missing export / failing assertions).
4. `Cmd+L` → `"@src/lib/latex-generator.ts — add generateLanguages(languages: string): string. Match the conditional contract of generateSkills. Do NOT wire it into generateLatex yet."`
5. Confirm watch reruns and `generateLanguages` tests pass.
6. Introduce a typo in one test expectation → select the failure in the terminal → `Cmd+L` (or `@Terminals`): `"Fix the test expectation, not the implementation."`
7. `@Commit (Diff of Working State)` → `"Review these changes. Does generateLanguages match generateSkills? Write a commit message."` → commit.
8. **Optional:** `@Branch (Diff with Main)` → `"Summarise this branch for a PR description."`

### 2f. Explore `.cursor/rules` (§2.4)
The CV Builder ships **two** rules in `.cursor/rules/`:

| File | Role |
|---|---|
| `specify-rules.mdc` | Always-on pointer to `specs/001-resume-builder/plan.md` — focus here |
| `speckit-commit-workflow.mdc` | Spec Kit commit format during `/speckit-implement` — covered in Part 4 |

1. Read `specify-rules.mdc`, then skim `plan.md`.
2. Open a **new** Chat (fresh context) → `"Add a generateReferences(references: string) function for a References section — single free-text field, same conditional-empty pattern as generateSkills."` — without `@`-mentioning or referencing the plan.
   Review the agent’s response and file reads. Confirm it consulted `plan.md` without you `@`-mentioning it. Reject any code changes — this step is read-only.
3. Does the proposed approach respect Constitution VI (files < 200 lines), pure functions in `src/lib/`, and Constitution IV (unit tests for generators, no UI tests)?
4. **Bonus:** add a glob-scoped **third** rule, `.cursor/rules/testing.mdc`, with `globs: ["tests/**/*.test.ts"]` enforcing "describe per function, `it()` names start with a verb describing behaviour, top-of-file fixtures only". Re-run step 2 asking it to also sketch tests — note the difference.

> **Next up:** Exercise 3a wires Languages into the full app (form tab, `generateLatex`, PDF preview) — building on the unwired `generateLanguages` from **2e**.

---

## Exercise 3 — Agent Mode & Output Quality
*After Part 3 · ~15 min*

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
   - Wire it into @src/App.tsx as a new tab between Skills and Summary
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
*Preview of Part 4 — only if you have time.*

1. Reset (`git stash` your work from 3a)
2. `Cmd+L` → Agent tab → `"/speckit-specify Add a Languages section accepting a single free-text field, rendered in the PDF between Skills and Summary, conditional when empty."`
3. Step through `/speckit-plan`, `/speckit-tasks`, `/speckit-implement`
4. Compare the artifacts to your hand-prompted version from 3a. Which version was easier to review? Which would be easier to revisit in 6 months?

---

## Exercise 4 — Sub-agents & Parallelism
*After Part 3 (sub-agents section) · ~15 min*

> The #1 requested topic — this is where it all comes together.

### 4a. Sub-agent delegation: add Languages + Publications in parallel

Sub-agents work in parallel only when their file scopes **don't overlap**. If multiple sub-tasks need to edit the same file (like `types.ts` or `App.tsx`), the agent will serialise them to avoid conflicts.

**Attempt 1 — observe sequential behaviour:**
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
3. Observe: the agent likely does this **sequentially** because `types.ts`, `App.tsx`, and the test file are shared across sub-tasks.

**Attempt 2 — true parallel with non-overlapping scopes:**
4. Reset again (`git checkout .`) and try this restructured prompt where each sub-agent owns all of its own files:
   ```
   Add Languages and Publications sections to the CV Builder.

   Process these as TWO INDEPENDENT sub-agents with no shared files:

   Sub-agent 1 (Languages):
   - Create src/components/LanguagesForm.tsx matching SkillsForm
   - Create src/lib/generators/languages.ts with generateLanguages() matching generateSkills
   - Create tests/unit/languages.test.ts with vitest cases

   Sub-agent 2 (Publications):
   - Create src/components/PublicationsForm.tsx matching ProjectsForm
   - Create src/lib/generators/publications.ts with generatePublications() matching generateProjects
   - Create tests/unit/publications.test.ts with vitest cases

   After BOTH complete, wire both into types.ts, App.tsx, and latex-generator.ts yourself.
   Run npm test at the end.
   ```
5. Compare: did the second prompt actually run in parallel? (It should — no file overlaps between sub-agents.)

**Key takeaway:** Sub-agents parallelise when scope boundaries are clean. Shared files force sequential execution. For tasks with inherently shared files, use **Multitask Mode** (exercise 4d) instead.

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

### 4e. Custom sub-agents — create a verifier and a section-builder

Custom sub-agents live in `.cursor/agents/` as markdown files with YAML frontmatter. The agent delegates to them automatically based on their `description`, or you invoke them explicitly with `/name`.

**Step 1: Create a verifier sub-agent**

1. Create the file `.cursor/agents/verifier.md` in the CV Builder repo:
   ```markdown
   ---
   name: verifier
   description: Validates completed work. Use after implementation tasks to confirm everything actually works.
   model: inherit
   readonly: true
   ---

   You are a skeptical validator for the CV Builder app. Your job is to verify that work
   claimed as complete actually works.

   When invoked:
   1. Check that all new files mentioned in the task actually exist
   2. Run `npm test` and confirm all tests pass
   3. Check that new generators return '' for empty input (the conditional-section contract)
   4. Verify new components follow the controlled-input pattern (value + onChange)
   5. Look for edge cases: whitespace-only input, special characters, missing fields

   Report:
   - What was verified and passed
   - What was claimed but incomplete or broken
   - Specific issues that need to be addressed

   Do not accept claims at face value. Test everything.
   ```

2. Test it — after any previous exercise that added a section, run:
   ```
   /verifier confirm the Languages section handles all edge cases:
   empty string, whitespace-only, strings with LaTeX special characters (&, %, $)
   ```
3. Did it catch anything the original implementation missed?

**Step 2: Create a section-builder sub-agent**

1. Create `.cursor/agents/section-builder.md`:
   ```markdown
   ---
   name: section-builder
   description: Adds a new section to the CV Builder. Use when asked to add any resume section (Languages, Awards, Volunteering, etc.).
   model: inherit
   ---

   You are a specialist for adding new sections to the CV Builder resume app.

   When invoked with a section name and type (single-field or repeatable-list):

   1. Add the interface/field to src/lib/types.ts
   2. Create the form component in src/components/ matching:
      - SkillsForm.tsx for single-field sections
      - ProjectsForm.tsx for repeatable-list sections
   3. Add the generator function to src/lib/latex-generator.ts matching:
      - generateSkills() contract for single-field
      - generateProjects() contract for repeatable-list
   4. Add vitest cases in tests/unit/latex-generator.test.ts matching the existing style
   5. Wire into App.tsx (TABS, TAB_LABELS, INITIAL_DATA, TabsContent)
   6. Run npm test

   Follow all conventions in specs/001-resume-builder/plan.md.
   Use \section{Name} for the heading. Return '' when empty (conditional-section contract).
   Escape user input via src/lib/latex-escape.ts.
   ```

2. Test automatic delegation — start a new chat and type:
   ```
   Add a Hobbies section to the resume. It's a single free-text field, like Languages.
   ```
   Did the agent delegate to `/section-builder` automatically? (Check the tool calls in the chat output.)

3. Test explicit invocation:
   ```
   /section-builder Add a "Volunteering" section — repeatable list with organisation, role, dates, and bullet-point activities.
   ```

4. Chain them: after the section-builder finishes, invoke the verifier:
   ```
   /verifier confirm the Volunteering section is complete and all tests pass
   ```

**Reflection:**
- How does a custom sub-agent compare to a Spec-Kit skill (`/speckit-specify → /speckit-implement`)?
- Sub-agents are lighter (one file, immediate) but less structured (no spec, no plan, no traceability). Skills produce auditable artifacts. Choose based on the task's longevity — throwaway vs. team-maintained.
- Would you add these sub-agents to `.cursor/agents/` and commit them for the whole team?

---

## Exercise 5 — Prompt Engineering, Skills, Spec-Kit & MCP
*After Part 4 · ~20 min*

### 5a. Prompt quality comparison
Try both prompts on the CV Builder and compare:

**Prompt A (vague):**
```
"Add a new section"
```

**Prompt B (STAR):**
```
"The CV Builder has no Awards section today.

Add a generateAwards() function to @src/lib/latex-generator.ts matching the contract
of generateCertifications (repeatable list with name, issuer, date; reuse
\resumeProjectHeading; return '' when empty).

Also add the AwardEntry interface to @src/lib/types.ts (id, name, issuer, date)
and add vitest cases in @tests/unit/latex-generator.test.ts matching the
generateCertifications describe block.

Do not wire it into App.tsx yet — only the generator + interface + tests."
```

Which produced more usable code? What made the difference?

### 5b. Security review with Cursor
1. `Cmd+L` → `"Review @src/lib/latex-escape.ts. Are there any LaTeX special characters not handled? What's the worst input a user could supply that would either (a) execute LaTeX commands they shouldn't, or (b) crash the WASM compiler?"`
2. Cross-check the answer against [LaTeX's list of special characters](https://en.wikibooks.org/wiki/LaTeX/Basics#Special_characters) (10 characters). Is the escape function complete?
3. `Cmd+L` → `"Review @src/components/ContactForm.tsx — the linkedin and website fields render into \\href{} in the generated PDF (see generateContact in @src/lib/latex-generator.ts). Is there an injection risk where a crafted URL escapes the href context?"`
4. If the review finds a real gap, fix it and add a regression test in `tests/unit/latex-escape.test.ts` or `tests/unit/latex-generator.test.ts`

### 5c. Skills — invoke the full speckit chain
*The headline Spec-Kit exercise.*

1. `Cmd+L` → Agent tab → `/speckit-specify Add a "Volunteering" section to the resume builder. Repeatable entries with organisation, role, location, start/end month with "Currently volunteering" toggle, and bullet-point activities. Renders between Projects and Certifications in the PDF using \resumeSubheading.`
2. When `/speckit-specify` presents clarification questions, answer them (max 3)
3. Read the generated `specs/002-volunteering-section/spec.md` and `checklists/requirements.md`
4. Run `/speckit-plan` — read `plan.md`, `research.md`, `data-model.md`
5. Run `/speckit-tasks` — read `tasks.md`
6. Run `/speckit-implement` — watch the agent tick through tasks in dependency order
7. `npm test` should pass at the end

**Reflection:** how much typing did you save vs. authoring 3a manually? Which version produces a better trail for the next person to read?

### 5d. Author a skill of your own
1. Create `.cursor/skills/add-section/SKILL.md` capturing the pattern from Exercise 3a so the next engineer can run `/add-section <name> <type>`
2. Frontmatter: `name`, `description` ("Add a new section to the resume builder following the project conventions")
3. Body: numbered steps covering types.ts, the form component, the generator, the test, the App.tsx wiring, and `npm test`
4. Test it: open a fresh Chat → `/add-section Hobbies single-field` → confirm it does the right thing

### 5e. (Bonus) MCP setup — issue → PR loop
If you have a GitHub personal access token (fine-grained, read+PR, scoped to your `cv-builder` fork):

1. Add the GitHub MCP server to `Cursor Settings` → `MCP` (see the snippet in Part 4 §4.4)
2. Push the CV Builder to your own GitHub fork, open an issue: "Add a Hobbies section"
3. `Cmd+L` → Agent tab → `"Read the open issue tagged 'good first issue' in <your-fork>. Implement the requested feature using /speckit-specify → /speckit-plan → /speckit-tasks → /speckit-implement. Commit and open a PR."`
4. Watch the full loop — issue → spec → plan → implementation → tests → PR — without leaving Cursor

### 5f. Evolve the rules
1. Look at `.cursor/rules/specify-rules.mdc` (the only rule that ships)
2. From the work you've done in Exercises 1–5, identify two conventions Cursor kept getting wrong without explicit reminders
3. Add `.cursor/rules/typescript.mdc` (auto-attached to `**/*.ts`, `**/*.tsx`) capturing them
4. Re-run an earlier exercise — note whether the rule changes the output
5. **Bonus:** open a PR adding the new rules. Rules go through code review like any other team decision.

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
