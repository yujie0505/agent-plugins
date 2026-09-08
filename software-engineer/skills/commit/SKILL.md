---
name: commit
description: Use this skill when the user asks to "commit code", "save changes to git", or "create a commit", or to handle the safe commit workflow.
tags: [git]
---

# Commit Workflow

## Gotchas

- **Script Resolution**: The helper scripts reside in the `scripts/` directory alongside this `SKILL.md`. When executing commands, resolve the script paths relative to this skill's directory (e.g. `<skill_directory>/scripts/<script_name>.sh`), NOT relative to the target repository's root.
- **No auto-stage**: NEVER run `git add`. Only work with already staged files.

## Workflow

Progress:

- [ ] **Step 1: Run Automated Checks**
  - Run `scripts/check-preconditions.sh` and `scripts/check-staging.sh`.
  - If either fails (non-zero exit), STOP and inform the user.
  - Note the list of staged files.
- [ ] **Step 2: Review File Paths**
  - Identify suspicious staged files (`*.log`, `.env`, `.DS_Store`, `dist/`, temporary files).
  - If found, ask the user to verify. If they choose to unstage, run `git restore --staged <file>` and restart this step.
- [ ] **Step 3: Review Content Security**
  - Read the content of staged changes: `git diff --cached`
  - Review diffs for hardcoded secrets (API keys, passwords, tokens) missed by automated tools. STOP immediately if found.
- [ ] **Step 4: Draft Commit Message**
  - Check `AGENTS.md` for formatting guidelines (if available).
  - Explain the motivation. NEVER summarize the `git diff` (it already shows the "what").
  - Draft a message and write it to `.software-engineer-commit-message`.
  - Run `scripts/check-message.sh`. Revise and re-validate if it fails.
  - Present the valid draft to the user and await EXPLICIT approval.
- [ ] **Step 5: Execute Commit**
  - Run `scripts/create-commit.sh` instead of `git commit` directly. (It will read the file and delete it automatically).
  - Report success, or explain the error if it fails.
