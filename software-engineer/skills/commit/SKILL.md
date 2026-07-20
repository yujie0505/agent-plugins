---
name: commit
description: Triggers when the user asks to "commit code", "save changes to git", or "create a commit". Use this skill to handle the entire safe commit workflow.
tags: [git]
---

# Commit Workflow

Execute this workflow sequentially:

## Gotchas

- **No auto-stage**: NEVER run `git add`. Only work with already staged files.
- **Use scripts**: MUST use `scripts/create-commit.sh` instead of `git commit`.
- **Enforce checks**: STOP and inform the user immediately if any script returns a non-zero exit code. Do not force commits.

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
  - Draft a message and write it to `.software-engineer-commit-message`.
  - Run `scripts/check-message.sh`. Revise and re-validate if it fails.
  - Present the valid draft to the user and await EXPLICIT approval.
- [ ] **Step 5: Execute Commit**
  - Ensure the final approved message is in `.software-engineer-commit-message`.
  - Run `scripts/create-commit.sh`. (It will read the file and delete it automatically).
  - Report success, or explain the error if it fails.
