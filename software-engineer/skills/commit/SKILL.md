---
name: commit
description: Use this skill when the user asks to commit staged changes or create a git commit. Validates the staging area, drafts a convention-aligned message, and commits after explicit approval.
---

# Commit Workflow

## Gotchas

- **Script Resolution**: The helper scripts reside in the `scripts/` directory alongside this `SKILL.md`. When executing commands, resolve the script paths relative to this skill's directory (e.g. `<skill_directory>/scripts/<script_name>.sh`), NOT relative to the target repository's root.
- **Scripts as Black Boxes**: Run a script with `--help` to learn its usage, output, and exit codes. Do NOT read the script source unless debugging a failure that its output cannot explain. Act only on the reported output and exit status, not on assumptions about how the script works internally.
- **Skipped Checks**: If a script reports that a check was skipped, inform the user and compensate with manual review.
- **No auto-stage**: NEVER run `git add`. Only work with already staged files.

## Workflow

Progress:

- [ ] **Step 1: Run Automated Checks**
  - Run `scripts/check-staging.sh`. If it fails, STOP and inform the user of the error output.
  - If any check was skipped, perform a more thorough manual secret inspection in Step 3.
- [ ] **Step 2: Review File Paths**
  - Identify suspicious files in the staged file list, such as:
    - Environment and credential files: `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa*`
    - Logs and OS artifacts: `*.log`, `.DS_Store`
    - Dependencies and build outputs: `node_modules/`, `dist/`
    - IDE settings: `.idea/`, `.vscode/`
    - Temporary files and large binaries
  - If found, ask the user to verify. If they choose to unstage, run `git restore --staged <file>` and restart from Step 1.
- [ ] **Step 3: Review Content Security**
  - Inspect staged changes: run `git diff --cached --stat` to check the scope.
  - Review the full diff while excluding lock files and generated artifacts via pathspecs (e.g. `git diff --cached -- . ':!*.lock' ':!package-lock.json' ':!pnpm-lock.yaml'`).
  - Look for hardcoded secrets (API keys, passwords, tokens). If secrets are found, STOP immediately and report only the file path and line number, redacting the secret value.
- [ ] **Step 4: Draft Commit Message**
  - Determine the repository's commit conventions from `AGENTS.md` (if available), any commit lint configuration in the repository, and `git log --oneline -n 10` (e.g., type/scope conventions).
  - Write the subject in the imperative mood, describing what changed.
  - Write the body to explain why the change was made (motivation and context); do not restate the diff.
  - Draft a message and write it to a temporary file in the location used by the agent runtime for conversation temporary files. NEVER write temporary files into the target repository root.
  - Run `scripts/check-message.sh <path-to-commit-file>` and also validate the draft manually against the repository's conventions.
    - If the script's findings conflict with the repository's conventions, the repository's conventions take precedence.
    - Otherwise, revise the draft and re-validate until both checks pass.
  - Present the valid draft to the user and await EXPLICIT approval. If the user requests changes, update the draft file, re-validate, and seek approval again.
- [ ] **Step 5: Execute Commit**
  - Run `scripts/create-commit.sh <path-to-commit-file>`.
  - Report success (including the created commit hash), or explain the error if it fails.
- [ ] **Step 6: Run Retrospective**
  - After a successful commit, invoke the `retrospective` skill.
