---
name: commit
description: Triggers when the user asks to "commit code", "save changes to git", or "create a commit". Use this skill to handle the entire safe commit workflow.
tags: [git]
---

# Commit

When invoked (e.g., via `/commit`), you MUST execute the following workflow sequentially. Track your progress through these steps.

## Gotchas

- **Never auto-stage files**: You MUST NOT automatically run `git add` for the user under any circumstances. Only work with what is already staged.
- **Strict script usage**: You MUST use `scripts/create-commit.sh` to execute the commit. Do NOT run `git commit` directly.
- **Do not bypass checks**: If the staging validation fails (e.g. exposed secrets or empty staging area), you MUST STOP and inform the user. Do not attempt to force the commit.

## Workflow

Progress:

- [ ] **Step 1: Run Automated Checks**
  - Run the precondition check script:

    ```bash
    scripts/check-preconditions.sh
    ```

  - If it returns a non-zero exit code, STOP and inform the user.
  - Run the validation script:

    ```bash
    scripts/check-staging.sh
    ```

  - If it returns a non-zero exit code, STOP and inform the user.
  - Note the list of staged files output by the script.
- [ ] **Step 2: Review File Paths**
  - Review the staged file paths from Step 1.
  - Identify any suspicious files (e.g., `*.log`, `.env`, `.DS_Store`, `dist/`, or temporary scripts).
  - Ask the user to verify suspicious files one by one. If they approve unstaging, run `git restore --staged <file>` and restart this step.
- [ ] **Step 3: Review Content Security**
  - Read the content of staged changes: `git diff --cached`
  - Manually review the diff content for any hardcoded secrets (e.g., API keys, passwords, tokens) that automated tools might have missed.
  - If you find any exposed secrets, alert the user and STOP the workflow immediately.
- [ ] **Step 4: Draft Commit Message**
  - Review `AGENTS.md` (if available in the project root) for project-specific formatting guidelines.
  - Generate a draft commit message based on the reviewed content.
  - Write the draft commit message to a temporary file named `.software-engineer-commit-message` using your file writing tool.
  - Validate the draft message:

    ```bash
    scripts/check-message.sh
    ```

  - If validation fails, revise the draft and re-validate.
  - Present the draft to the user and discuss/refine it until you receive EXPLICIT approval to proceed.
- [ ] **Step 5: Execute Commit**
  - Write the approved commit message to a temporary file named `.software-engineer-commit-message` using your file writing tool.
  - Execute the commit script:

    ```bash
    scripts/create-commit.sh
    ```

  - The script will automatically read from the file and delete it after execution.
  - If execution fails, read the error, explain it to the user, and offer help to fix issues.
  - Report the final result to the user.
