#!/bin/bash

DRY_RUN=0
COMMIT_FILE=".software-engineer-commit-message"

# Set up atomic cleanup: ensures the file is removed upon script exit (success or failure)
trap 'rm -f "$COMMIT_FILE"' EXIT

# Parse arguments
for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Usage: scripts/execute-commit.sh [OPTIONS]"
            echo ""
            echo "Executes a git commit using the message from the fixed file path:"
            echo "  $COMMIT_FILE"
            echo "The file will be automatically deleted after execution."
            echo ""
            echo "Options:"
            echo "  --dry-run    Preview the commit without actually creating it"
            echo ""
            echo "Exit codes:"
            echo "  0: Success"
            echo "  2: Missing commit message file"
            echo "  3: Git commit execution failed"
            exit 0
            ;;
        --dry-run)
            DRY_RUN=1
            ;;
    esac
done

if [ ! -f "$COMMIT_FILE" ]; then
    echo "ERROR: Commit message file '$COMMIT_FILE' not found." >&2
    exit 2
fi

if [ "$DRY_RUN" -eq 1 ]; then
    echo "DRY RUN: The following commit message would be used:" >&2
    echo "---" >&2
    cat "$COMMIT_FILE" >&2
    echo "---" >&2
    echo "SUCCESS: Dry run complete. No commit was created." >&2
    exit 0
fi

if ! git commit -F "$COMMIT_FILE"; then
    echo "ERROR: Failed to execute git commit." >&2
    exit 3
fi
