#!/bin/bash

COMMIT_FILE=".software-engineer-commit-message"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Usage: scripts/check-message.sh"
            echo ""
            echo "Validates the commit message in $COMMIT_FILE using commitlint."
            echo ""
            echo "Exit codes:"
            echo "  0: Success (or skipped if npx is missing)"
            echo "  1: Validation failed"
            exit 0
            ;;
    esac
done

if [ ! -f "$COMMIT_FILE" ]; then
    echo "ERROR: Commit message file '$COMMIT_FILE' not found." >&2
    exit 1
fi

if ! command -v npx >/dev/null 2>&1; then
    echo "WARNING: npx is not installed. Skipping automated commitlint validation. Please proceed with manual inspection." >&2
    exit 0
fi

# Attempt to lint assuming a local config might exist
npx --yes @commitlint/cli@21.2.1 --edit "$COMMIT_FILE" >&2
EXIT_CODE=$?

# If commitlint fails with code 9 (indicating missing configuration rules)
if [ $EXIT_CODE -eq 9 ]; then
    echo "WARNING: Local commitlint config not found or invalid (exit code 9). Falling back to default config..." >&2
    npx --yes @commitlint/cli@21.2.1 --edit "$COMMIT_FILE" --default-config >&2
    EXIT_CODE=$?
fi

if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: commitlint validation failed. Please revise the commit message." >&2
    exit 1
fi

echo "SUCCESS: Commit message validation passed." >&2
exit 0
