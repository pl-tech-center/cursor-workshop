# Workshop Exercises

Hands-on exercises to reinforce each section. Each exercise is 5–10 minutes. Do them solo or in pairs.

> **All exercises run against the CV Builder app** at `../cv-builder/`. Open it in Cursor before you start. The app is a browser-only resume builder: tabbed forms → pure TypeScript LaTeX generators → client-side WASM pdfTeX → PDF preview + download. Stack: React 18 + TypeScript 5 + Vite 6 + Tailwind 4 + shadcn/ui + Vitest.
>
> Before starting:
> ```bash
> cd ../cv-builder
> npm install
> npm run download:tex-assets   # one-time, ~150 MB of TeX Live WASM
> npm test                      # should be all green before you begin
> npm run dev                   # http://localhost:5173
> ```

---

## Exercise 1 — Tab Autocomplete & `Cmd+K`
*After Part 1 · ~10 min*

### 1a. Next-edit prediction (Tab)
1. Open `src/lib/types.ts`
2. Add a new field `employmentType: 'full-time' | 'part-time' | 'contract' | 'freelance' | 'internship'` to the `ExperienceEntry` interface
3. Watch Cursor suggest matching updates as you tab through:
   - `makeExperience()` in `src/App.tsx` and `src/components/ExperienceForm.tsx`
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
*After Part 2 · ~10 min*

### 2a. Implicit codebase search
1. `Cmd+L` → `"How does the app turn form data into a PDF? Walk me through the pipeline."`
   (No `@Codebase` needed — the agent searches the codebase index automatically.)
2. Note which files Cursor cites. Open them — is the pipeline correct? (Expected: `App.tsx` → `ReviewView.tsx` → `latex-generator.ts` → `pdf-compiler.ts` → `<iframe>`)

### 2b. Cross-file consistency with `@Files`
1. `Cmd+L` → `"Look at @src/lib/latex-generator.ts and @src/lib/types.ts. For every entity in types.ts, is there a corresponding generator function? Is every field used? Anything orphaned?"`
2. If Cursor finds a gap, fix it with a follow-up prompt.

### 2c. `@Docs` research
1. `Cmd+L` → `"@Docs Vitest — what's the recommended way to assert on multi-line strings with stable indentation? Show me how to apply that to the assertions in @tests/unit/latex-generator.test.ts on generateExperience."`
2. Compare to the official docs. Optionally apply one improvement.

### 2d. Explore the `.cursor/rules` files
The CV Builder ships exactly one rule: `.cursor/rules/specify-rules.mdc`. It's `alwaysApply: true` and points the agent at the current plan.

1. Read the rule, then read `specs/001-resume-builder/plan.md`
2. Open a new Chat → ask Cursor: `"Add a generateLanguages() function for a Languages section."` — without referencing the plan
3. Watch the agent read `plan.md` automatically (look at the citations). Does its proposed code respect Constitution VI (files < 200 lines), the section ordering, the conditional-empty-string contract?
4. **Bonus:** add a second rule, `.cursor/rules/testing.mdc`, with `globs: ["tests/**/*.test.ts"]` enforcing "describe per function, it() names start with a verb describing behaviour, top-of-file fixtures only". Re-run the same prompt asking it to also add tests — note the difference.

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
