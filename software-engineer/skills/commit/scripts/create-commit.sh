#!/bin/bash

DRY_RUN=0
COMMIT_FILE=""

for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Usage: scripts/create-commit.sh [OPTIONS] <commit-message-file>"
            echo ""
            echo "Executes a git commit using the message from the specified file."
            echo ""
            echo "Options:"
            echo "  --dry-run    Preview the commit without actually creating it"
            echo ""
            echo "Output:"
            echo "  - stdout: Git commit summary output."
            echo "  - stderr: Diagnostic messages and errors."
            echo ""
            echo "Exit codes:"
            echo "  0: Success"
            echo "  1: Unexpected argument or option"
            echo "  2: Missing or invalid commit message file"
            echo "  3: Git commit execution failed"
            echo "  4: Not a git repository"
            echo "  5: No staged files found"
            exit 0
            ;;
        --dry-run)
            DRY_RUN=1
            ;;
        -*)
            echo "ERROR: Unexpected option: $arg" >&2
            echo "Usage: scripts/create-commit.sh [OPTIONS] <commit-message-file>" >&2
            exit 1
            ;;
        *)
            if [ -z "$COMMIT_FILE" ]; then
                COMMIT_FILE="$arg"
            else
                echo "ERROR: Unexpected argument: $arg" >&2
                echo "Usage: scripts/create-commit.sh [OPTIONS] <commit-message-file>" >&2
                exit 1
            fi
            ;;
    esac
done

if [ -z "$COMMIT_FILE" ]; then
    echo "ERROR: Missing commit message file path." >&2
    echo "Usage: scripts/create-commit.sh [OPTIONS] <commit-message-file>" >&2
    exit 2
fi

if [ ! -f "$COMMIT_FILE" ]; then
    echo "ERROR: Commit message file '$COMMIT_FILE' not found." >&2
    exit 2
fi

if [ ! -s "$COMMIT_FILE" ]; then
    echo "ERROR: Commit message file '$COMMIT_FILE' is empty." >&2
    exit 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: Not a git repository (or any of the parent directories)." >&2
    exit 4
fi

if git diff --cached --quiet; then
    echo "ERROR: No staged files found. Please stage your files first." >&2
    exit 5
fi

if [ "$DRY_RUN" -eq 1 ]; then
    echo "DRY RUN: Testing commit execution with message from $COMMIT_FILE:" >&2
    echo "---" >&2
    cat "$COMMIT_FILE" >&2
    echo "---" >&2
    if ! git commit --dry-run -F "$COMMIT_FILE" >&2; then
        echo "ERROR: Dry run failed (staged changes or commit configuration error)." >&2
        exit 3
    fi
    echo "SUCCESS: Dry run complete. No commit was created." >&2
    exit 0
fi

if ! git commit -F "$COMMIT_FILE"; then
    echo "ERROR: Failed to execute git commit." >&2
    echo "HINT: If caused by permission issues on .git/ in a sandbox, retry with sandbox bypass. If an index.lock exists, ensure no other git processes are running." >&2
    exit 3
fi
