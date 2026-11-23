---
name: commit
description: Use this skill when the user asks to commit staged changes or create a git commit. Validates the staging area, drafts a convention-aligned message, and commits after explicit approval.
---

# Commit Workflow

## Gotchas

- **Script Resolution**: The helper scripts reside in the `scripts/` directory alongside this `SKILL.md`. When executing commands, resolve the script paths relative to this skill's directory (e.g. `<skill_directory>/scripts/<script_name>.sh`), NOT relative to the target repository's root.
- **Scripts as Black Boxes**: Run a script with `--help` when you need its usage, output format, or exit code meanings (especially on a non-zero exit). Do NOT read the script source unless debugging a failure that its output cannot explain. Act only on the reported output and exit status, not on assumptions about how the script works internally.
- **Skipped Checks**: If a script reports that a check was skipped (rather than a hard error), inform the user, continue the workflow, and compensate with manual review.
- **No Auto-Stage**: NEVER run `git add`. Only work with already staged files.
- **No Hook Bypass**: NEVER bypass git hooks (e.g., `--no-verify`) unless explicitly instructed by the user. If a repository hook fails during commit, report the failure output and stop.
- **Isolated Subagent Review**: When invoking the `commit-message-reviewer` subagent, pass ONLY the path to the commit message temporary file—NEVER include conversational context, rationale, or explanations in the prompt. On each review iteration, always launch a brand-new `commit-message-reviewer` instance rather than messaging a previous one, ensuring an unpolluted future-reader perspective.

## Workflow

Progress:

- [ ] **Step 1: Run Automated Checks**
  - Run `scripts/check-staging.sh`. If it fails with an error (not a skipped check), STOP and inform the user of the error output.
  - If a check was skipped, continue using the staged file list output and perform a more thorough manual secret inspection in Step 3.
- [ ] **Step 2: Review File Paths**
  - Inspect the status-prefixed staged file list from Step 1 and flag suspicious files only for added, modified, or renamed entries (ignore staged deletions `D`, since removing sensitive or unwanted files from tracking is intentional):
    - Environment and credential files: `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa*`
    - Logs and OS artifacts: `*.log`, `.DS_Store`
    - Dependencies and build outputs: `node_modules/`, `dist/`
    - IDE settings: `.idea/`, `.vscode/`
    - Temporary files and large binaries
  - If found, ask the user to verify. If they choose to unstage, run `git restore --staged <file>` and restart from Step 1.
- [ ] **Step 3: Review Content Security**
  - Inspect staged changes: run `git diff --cached --stat` to check the scope.
  - Review the full diff while excluding lock files and generated artifacts via pathspecs (e.g. `git diff --cached -- . ':!*.lock' ':!package-lock.json' ':!pnpm-lock.yaml' ':!go.sum'`).
  - Look for hardcoded secrets (API keys, passwords, tokens). If secrets are found, STOP immediately and report only the file path and line number, redacting the secret value.
- [ ] **Step 4: Draft Commit Message**
  - Determine the repository's commit conventions from `AGENTS.md` (if available), any commit lint configuration in the repository, and `git log --oneline -n 10` (e.g., type/scope conventions). Expect Conventional Commits as the baseline even when no commit lint configuration file is present.
  - Write the subject in the imperative mood, describing what changed.
  - Write the body to explain why the change was made (motivation and context); do not restate the diff.
  - Draft a message and write it to a temporary file in the location used by the agent runtime for conversation temporary files. NEVER write temporary files into the target repository root.
  - Validate and refine the draft iteratively (up to 3 subagent review rounds):
    1. **Format & Convention Check**: Run `scripts/check-message.sh <path-to-commit-file>` and validate the draft manually against Conventional Commits and repository conventions. If the script reports a skipped check, rely on manual validation. If an explicit repository convention conflicts with a default linter rule (when no repository commit lint config exists), follow the repository convention for that specific rule while satisfying all other checks. Revise the draft and re-validate until the checks pass.
    2. **Semantic Review**: Launch a new `commit-message-reviewer` subagent, passing only `<path-to-commit-file>`.
       - The review passes when `Verdict` `Result` is `PASS` (`Blocking: 0`).
       - If `Verdict` `Result` is `NEEDS_INPUT`: check conversation history for the requested rationale; if it cannot be inferred from the codebase, diff, or conversation history, ask the user for the missing rationale before continuing. Update the draft file to incorporate the rationale and resolve all `Blocking` findings, then repeat from the **Format & Convention Check**.
       - If `Verdict` `Result` is `FAIL`: update the draft file to resolve all `Blocking` findings, then repeat from the **Format & Convention Check**.
       - If `Verdict` `Result` is still not `PASS` after 3 subagent review rounds, stop iterating and present the latest draft alongside the unresolved review findings to the user.
  - Present the valid draft to the user and await EXPLICIT approval. If the user requests changes, update the draft file, re-validate with `scripts/check-message.sh <path-to-commit-file>` and the repository's conventions, and seek approval again.
- [ ] **Step 5: Execute Commit**
  - Run `scripts/create-commit.sh <path-to-commit-file>`. Never bypass failed git hooks with `--no-verify`.
  - Report success (including the created commit hash), or explain the error if it fails.
- [ ] **Step 6: Run Retrospective**
  - After a successful commit, invoke the `retrospective` skill.
