#!/bin/bash

DRY_RUN=0

# Parse arguments
for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Usage: scripts/execute-commit.sh [OPTIONS] < message.txt"
            echo "   or: echo \"message\" | scripts/execute-commit.sh [OPTIONS]"
            echo ""
            echo "Executes a git commit using the message provided via standard input (stdin)."
            echo "Using stdin instead of positional arguments prevents quoting/escaping issues with multi-line messages."
            echo ""
            echo "Options:"
            echo "  --dry-run    Preview the commit without actually creating it"
            echo ""
            echo "Exit codes:"
            echo "  0: Success"
            echo "  2: Missing commit message"
            echo "  3: Git commit execution failed"
            exit 0
            ;;
        --dry-run)
            DRY_RUN=1
            ;;
    esac
done

commit_msg=$(cat)

if [ -z "$commit_msg" ]; then
    echo "ERROR: Please provide a commit message via standard input (stdin)." >&2
    exit 2
fi

if [ "$DRY_RUN" -eq 1 ]; then
    echo "DRY RUN: The following commit message would be used:" >&2
    echo "---" >&2
    echo "$commit_msg" >&2
    echo "---" >&2
    echo "SUCCESS: Dry run complete. No commit was created." >&2
    exit 0
fi

if ! echo "$commit_msg" | git commit -F -; then
    echo "ERROR: Failed to execute git commit." >&2
    exit 3
fi
