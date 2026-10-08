---
name: commit
description: Use this skill when the user asks to "commit code", "save changes to git", or "create a commit", or to handle the safe commit workflow.
compatibility: Requires git. Optional: gitleaks, commitlint.
---

# Commit Workflow

## Gotchas

- **Script Resolution**: The helper scripts reside in the `scripts/` directory alongside this `SKILL.md`. When executing commands, resolve the script paths relative to this skill's directory (e.g. `<skill_directory>/scripts/<script_name>.sh`), NOT relative to the target repository's root.
- **No auto-stage**: NEVER run `git add`. Only work with already staged files.

## Workflow

Progress:

- [ ] **Step 1: Run Automated Checks**
  - Run `scripts/check-staging.sh`. If it fails, STOP and inform the user of the error output.
- [ ] **Step 2: Review File Paths**
  - Identify suspicious staged files (`*.log`, `.env`, `.DS_Store`, `dist/`, temporary files).
  - If found, ask the user to verify. If they choose to unstage, run `git restore --staged <file>` and restart from Step 1.
- [ ] **Step 3: Review Content Security**
  - Inspect staged changes: run `git diff --cached --stat` to check the scope.
  - Review diffs for hardcoded secrets (API keys, passwords, tokens) missed by automated tools, filtering out lock files or generated artifacts. STOP immediately if secrets are found.
- [ ] **Step 4: Draft Commit Message**
  - Check `AGENTS.md` for formatting guidelines (if available) and run `git log --oneline -n 10` to align with the repository's commit style (e.g., type/scope conventions).
  - Focus on motivation; do not summarize the diff.
  - Draft a message and write it to a temporary file in the location used by the agent runtime for conversation temporary files. NEVER write temporary files into the target repository root.
  - Run `scripts/check-message.sh <path-to-commit-file>`.
  - If the script reports that `commitlint` is not installed (exit code 10), inform the user that `commitlint` is missing and perform manual validation against the style conventions.
  - Revise and re-validate if automated or manual checks fail.
  - Present the valid draft to the user and await EXPLICIT approval. If the user requests changes, update the draft file, re-run `scripts/check-message.sh`, and seek approval again.
- [ ] **Step 5: Execute Commit**
  - Run `scripts/create-commit.sh <path-to-commit-file>`.
  - Report success (including the created commit hash), or explain the error if it fails.
