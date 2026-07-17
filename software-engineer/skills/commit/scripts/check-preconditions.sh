#!/bin/bash

COMMIT_FILE=".software-engineer-commit-message"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Usage: scripts/check-preconditions.sh"
            echo ""
            echo "Checks if the environment is ready for the commit skill."
            echo "Specifically ensures that the temporary commit message file does not already exist."
            echo ""
            echo "Exit codes:"
            echo "  0: Success"
            echo "  1: Preconditions failed"
            exit 0
            ;;
    esac
done

if [ -e "$COMMIT_FILE" ]; then
    echo "ERROR: The file '$COMMIT_FILE' already exists in the project." >&2
    echo "This file is used temporarily by the commit skill to store the commit message." >&2
    echo "To avoid overwriting unexpected data, the skill will abort." >&2
    echo "Please review and remove the file manually if it is no longer needed." >&2
    exit 1
fi

echo "SUCCESS: Preconditions met." >&2
exit 0
