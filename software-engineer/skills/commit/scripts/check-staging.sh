#!/bin/bash

VERBOSE=0

# Parse arguments
for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Usage: scripts/check-staging.sh [OPTIONS]"
            echo ""
            echo "Checks the git staging area for files and runs security scans (gitleaks)."
            echo ""
            echo "Options:"
            echo "  --verbose    Show all staged files instead of truncating large lists"
            echo ""
            echo "Output:"
            echo "  - stdout: Line-separated list of staged files."
            echo "  - stderr: Diagnostic messages, warnings, and errors."
            echo ""
            echo "Exit codes:"
            echo "  0: Success"
            echo "  1: Invalid arguments"
            echo "  2: No staged files found"
            echo "  3: gitleaks detected exposed secrets"
            echo "  4: Not a git repository"
            exit 0
            ;;
        --verbose)
            VERBOSE=1
            ;;
        *)
            echo "ERROR: Unexpected argument: $arg" >&2
            echo "Usage: scripts/check-staging.sh [OPTIONS]" >&2
            exit 1
            ;;
    esac
done

# 1. Check if inside git work tree
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: Not a git repository (or any of the parent directories)." >&2
    exit 4
fi

# 2. Check if staging area is empty
if git diff --cached --quiet; then
    echo "ERROR: No staged files found. Please stage your files first." >&2
    exit 2
fi

# 3. Security Check with gitleaks
if command -v gitleaks >/dev/null 2>&1; then
    if ! gitleaks git --pre-commit --redact --staged --verbose >&2; then
        echo "ERROR: gitleaks detected exposed secrets. Please review and remove them." >&2
        exit 3
    fi
else
    echo "WARNING: gitleaks is not installed. Skipping automated security scan. Please proceed with manual inspection." >&2
fi

# 4. Output staged files for agent's manual review
echo "SUCCESS: Staging area validation passed." >&2

# Output structured data to stdout (with predictable output size)
STAGED_FILES=$(git -c core.quotepath=false diff --cached --name-only)
FILE_COUNT=$(echo "$STAGED_FILES" | wc -l | tr -d '[:space:]')

if [ "$VERBOSE" -eq 1 ] || [ "$FILE_COUNT" -le 50 ]; then
    echo "$STAGED_FILES"
else
    echo "$STAGED_FILES" | head -n 50
    echo "... and $((FILE_COUNT - 50)) more files. Run with --verbose to see all." >&2
fi
