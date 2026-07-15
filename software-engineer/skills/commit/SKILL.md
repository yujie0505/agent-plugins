---
name: commit
description: Use this skill when the user requests to commit code or create a git commit. It performs file path sanity checks, runs security scans (gitleaks), generates a standardized commit message, and executes the commit after explicit user approval.
version: 1.0.0
tags: [git]
---

# Commit

When invoked (e.g., via `/commit`), execute the following workflow sequentially:

## Workflow

1. **Check Staging Area:**
   - Verify if there are any staged files by running:
     ```bash
     git diff --cached --name-only
     ```
   - If the output is empty, you MUST stop the workflow and inform the user: "No staged files found. Please stage your files first."
   - **Crucial:** You MUST NOT automatically run the following command for the user:
     ```bash
     git add <files>
     ```

2. **File Path Sanity Check:**
   - You MUST review the staged file paths from the output of the previous step.
   - You SHOULD look for suspicious files that probably SHOULD NOT be committed, such as:
     - Source code from a language not used in the project.
     - Files conventionally ignored in git repos (e.g., `.DS_Store`, build artifacts, log files).
     - Local testing scripts, temporary data files, or mock data.
   - If you spot any such files, you MUST ask the user to verify their intent one by one.
   - If the user confirms a file was added by mistake, you MUST advise them to unstage it by running:
     ```bash
     git restore --staged <file>
     ```
     You MUST then STOP the workflow until the staging area is fixed.

3. **Security Check:**
   - You MUST automatically scan for exposed secrets in the staged changes by running:
     ```bash
     gitleaks git --pre-commit --redact --staged --verbose
     ```
   - **Crucial:** If `gitleaks` detects any exposed secrets, you MUST immediately alert the user, point out the issue, and STOP the workflow. You MUST NOT proceed further.
   - If `gitleaks` passes, you MUST run the following command to inspect the changes yourself and catch any sensitive files (e.g., `.env`, private configs) or data that `gitleaks` might miss:
     ```bash
     git diff --cached
     ```
     If you manually detect any issues, you MUST alert the user and STOP the workflow immediately.

4. **Message Generation & Discussion:**
   - If you have not already retrieved the actual content of the staged changes, you MUST run:
     ```bash
     git diff --cached
     ```
   - You MUST review the project's `AGENTS.md` (if available in your context or project root) to ensure the commit message adheres to any project-specific formatting or guidelines.
   - You MUST generate a draft commit message based on the staged changes and present it to the user.
   - You SHOULD discuss and refine the draft with the user until a consensus is reached, and you MUST receive explicit approval to proceed.

5. **Execution & Cleanup:**
   - Once approved, you MUST save the finalized commit message to a temporary file (e.g., `.agent-commit-message`) in the project root.
   - You MUST execute the commit by running:
     ```bash
     git commit -F .agent-commit-message
     ```
   - If the commit fails (e.g., due to linter hooks), you MUST read the error, explain it to the user, and offer to help fix the issues.
   - Regardless of success or failure, you MUST ALWAYS clean up the temporary file by running:
     ```bash
     rm -f .agent-commit-message
     ```
   - You MUST report the final execution result to the user.
