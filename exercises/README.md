# Workshop Exercises

Hands-on exercises to reinforce each section. Each exercise is designed to take 5–10 minutes. Do them solo or in pairs.

> **Stack note:** Examples use Python to match the team's primary stack. Adapt to Go or your preferred language if you prefer.

---

## Exercise 1 — Tab Autocomplete & `Cmd+K`
*After Part 1*

### 1a. Next-edit prediction
1. Open (or create) a Python file with a dataclass:
   ```python
   @dataclass
   class User:
       id: str
       name: str
       email: str
   ```
2. Add a new field `role: str` to the dataclass
3. Watch Cursor suggest updates to every place `User` is constructed or used
4. Follow the ghost-text with Tab through 3+ locations

### 1b. Inline edit with `Cmd+K`
1. Paste this function into `scratch/utils.py`:
   ```python
   def get_user_age(birth_year):
       return 2026 - birth_year
   ```
2. Select the function body → `Cmd+K` → `"add type hints and handle the case where birth_year is in the future"`
3. Review and accept the diff.
4. Now select the whole function → `Cmd+K` → `"convert to handle timezone-aware dates using datetime"`

### 1c. Terminal `Cmd+K`
1. Click in the terminal panel
2. `Cmd+K` → `"find all Python files modified in the last 7 days, excluding __pycache__ and .venv"`
3. Review the generated command before running it

---

## Exercise 2 — Context & `@` Symbols
*After Part 2*

### 2a. `@Codebase` search
1. Open your main project (or any project with >10 files)
2. `Cmd+L` → `"@Codebase where is error handling centralized?"`
3. Note which files Cursor cites. Navigate to them — is it correct?

### 2b. Cross-file refactor with `@Files`
1. Find two similar files in your project (e.g., two service modules or route handlers)
2. `Cmd+L` → `"Look at @[file1] and @[file2]. How are they different? What pattern should we standardize on?"`

### 2c. `@Docs` research
1. `Cmd+L` → `"@Docs Pydantic — how do I validate an object with optional fields and a custom error message?"`
2. Compare the answer to the official docs to verify accuracy.

### 2d. Create `.cursor/rules` files
Create two rules files in your project:

**`.cursor/rules/general.mdc`** with at least 5 rules your team cares about.

**`.cursor/rules/python.mdc`** (or `golang.mdc`) with language-specific conventions.

Then:
1. Open a new Chat → ask Cursor to generate a simple function
2. Does it follow your rules? If not, make the rules more specific.
3. Try again — iterate until the rules produce the output you want.

---

## Exercise 3 — Agent Mode & Output Quality
*After Part 3*

### 3a. Scaffold a feature with Agent mode
1. Open chat (`Cmd+L`) and switch to the **Agent tab**
2. Use this prompt (adapt paths to your project):
   ```
   Create a simple Todo module with:
   - A Pydantic model Todo with id (str), title (str), done (bool)
   - A TodoService class in src/services/todo.py with add(), complete(), and list() methods
   - Unit tests in tests/test_todo.py using pytest
   
   Match the file structure already in the project.
   ```
3. Review each file in the diff. Accept.

### 3b. Tame a hallucination
1. The Agent tab is already open from 3a
2. Ask: `"What edge cases does TodoService not handle? What would fail under concurrent access?"`
3. Review the critique — does it identify real issues or invent fake ones?
4. Ask it to fix the real issues: `"Fix only the issues that are actually problems. Skip anything speculative."`

### 3c. Debug with Agent
1. Intentionally introduce a bug in the service (e.g., wrong return value in `complete()`)
2. Ask Cursor: `"The tests for TodoService are failing. Find the bug and fix it."`
3. Watch it run the tests, identify the failure, and fix it.

### 3d. Debugging with `@Terminal`
1. Run a command that fails (a failing test is fine)
2. `Cmd+L` → `"@Terminal — why did this fail and how do I fix it?"`

---

## Exercise 4 — Sub-agents & Parallelism
*After Part 3 (sub-agents section)*

> This is a new exercise — directly addresses the #1 requested topic.

### 4a. Sub-agent delegation
1. Open chat (`Cmd+L`) → Agent tab
2. Use this prompt:
   ```
   I need to add input validation to all service methods in src/services/.
   
   For each service file:
   1. Add Pydantic validation models for the inputs
   2. Add validation at the start of each public method
   3. Add tests for invalid input in the corresponding test file
   
   Process each service file as a separate sub-task.
   ```
3. Watch Cursor spawn sub-agents and process files in parallel.
4. Review the diffs — did each sub-agent stay within its scope?

### 4b. Worktree parallel work (if time allows)
1. Create a worktree:
   ```bash
   git worktree add ../project-exercise feature/exercise-4b
   cursor ../project-exercise
   ```
2. In the new window: start an Agent task (e.g., "add docstrings to all functions in src/")
3. In the original window: start a different Agent task simultaneously
4. Compare: both run without conflicting
5. Clean up: `git worktree remove ../project-exercise`

---

## Exercise 5 — Prompt Engineering, Security & MCP
*After Part 4*

### 5a. Prompt quality comparison
Try both prompts below and compare the outputs:

**Prompt A (vague):**
```
"Add error handling to this code"
```

**Prompt B (specific):**
```
"This FastAPI route handler has no error handling.
Add try/except around the database calls.
For database errors, return HTTP 503 with {'error': 'Database unavailable'}.
For validation errors, return HTTP 400 with the validation message.
Match the error handling pattern in @src/api/users.py"
```

Which produced more usable code? What made the difference?

### 5b. Security review
1. Find a route handler or database access function in your project
2. `Cmd+L` → `"Review this code for security vulnerabilities. Check for injection, missing auth checks, and data leakage."`
3. Does it find anything? Create a `/review-security` command to make this repeatable.

### 5c. Iterative refinement
1. Generate a function using a prompt
2. Then ask: `"What edge cases does this not handle?"`
3. Then ask: `"Add handling for those edge cases"`
4. Then ask: `"What security concerns does this function have?"`
5. Compare the final version to the first. How much better is it?

### 5d. Rules challenge
1. Look at your `.cursor/rules/general.mdc` from Exercise 2d
2. Ask Cursor to deliberately generate code that would violate some of your rules
3. Does Cursor follow the rules anyway?
4. If not, refine the rules to be more explicit and try again.

### 5e. (Bonus) MCP setup
If you have a GitHub personal access token:
1. Add the GitHub MCP server to `Cursor Settings` → `MCP`
2. `Cmd+L` → Agent tab → `"List the open issues in [your-org/your-repo] and summarize the top 3 by impact"`
3. If that works: `"Find the issue most related to authentication and draft a fix plan"`

---

## Reflection Questions

After completing the exercises, discuss with your pair:

1. Which Cursor feature surprised you most?
2. What's a task from your current sprint you'd use Cursor differently on now?
3. What rules would be most valuable for your team to codify?
4. Where did Cursor get it wrong? What context would have helped?
5. How would you use sub-agents or worktrees to break your current work into smaller PRs?
