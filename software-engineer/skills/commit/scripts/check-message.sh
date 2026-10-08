#!/bin/bash

COMMIT_FILE=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Usage: scripts/check-message.sh <commit-message-file>"
            echo ""
            echo "Validates the commit message in the specified file using commitlint."
            echo ""
            echo "Exit codes:"
            echo "  0: Success"
            echo "  1: Validation failed"
            echo "  2: Missing or invalid file argument"
            echo "  10: commitlint is not installed (validation skipped)"
            exit 0
            ;;
        -*)
            echo "ERROR: Unexpected option: $arg" >&2
            echo "Usage: scripts/check-message.sh <commit-message-file>" >&2
            exit 2
            ;;
        *)
            if [ -z "$COMMIT_FILE" ]; then
                COMMIT_FILE="$arg"
            else
                echo "ERROR: Unexpected argument: $arg" >&2
                exit 2
            fi
            ;;
    esac
done

if [ -z "$COMMIT_FILE" ]; then
    echo "ERROR: Missing commit message file path." >&2
    echo "Usage: scripts/check-message.sh <commit-message-file>" >&2
    exit 2
fi

if [ ! -f "$COMMIT_FILE" ]; then
    echo "ERROR: Commit message file '$COMMIT_FILE' not found." >&2
    exit 2
fi

if ! command -v commitlint >/dev/null 2>&1; then
    echo "WARNING: commitlint is not installed. Skipping automated commitlint validation. Please proceed with manual inspection." >&2
    exit 10
fi

if ! commitlint --edit "$COMMIT_FILE" --default-config >&2; then
    echo "ERROR: commitlint validation failed. Please revise the commit message." >&2
    exit 1
fi

echo "SUCCESS: Commit message validation passed." >&2
exit 0
