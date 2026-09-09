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
            echo "  0: Success (or skipped if commitlint is missing)"
            echo "  1: Validation failed"
            echo "  2: Missing or invalid file argument"
            exit 0
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
    exit 0
fi

# Attempt to lint assuming a local config might exist
commitlint --edit "$COMMIT_FILE" >&2
EXIT_CODE=$?

# If commitlint fails with code 9 (indicating missing configuration rules)
if [ $EXIT_CODE -eq 9 ]; then
    echo "WARNING: Local commitlint config not found or invalid (exit code 9). Falling back to default config..." >&2
    commitlint --edit "$COMMIT_FILE" --default-config >&2
    EXIT_CODE=$?
fi

if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: commitlint validation failed. Please revise the commit message." >&2
    exit 1
fi

echo "SUCCESS: Commit message validation passed." >&2
exit 0
