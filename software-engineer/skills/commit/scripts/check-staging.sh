#!/bin/bash

for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "Usage: scripts/check-staging.sh"
            echo ""
            echo "Checks the git staging area for files and runs security scans (gitleaks)."
            echo ""
            echo "Output:"
            echo "  - stdout: Tab-separated status and path for each staged file (git diff --cached --name-status)."
            echo "  - stderr: Diagnostic messages, warnings, and errors."
            echo ""
            echo "Exit codes:"
            echo "  0: Success"
            echo "  1: Invalid arguments"
            echo "  2: Not a git repository"
            echo "  3: No staged files found"
            echo "  5: gitleaks scan failed or detected exposed secrets"
            echo "  10: gitleaks is not installed (security scan skipped; staged file list still written to stdout)"
            exit 0
            ;;
        *)
            echo "ERROR: Unexpected argument: $arg" >&2
            echo "Usage: scripts/check-staging.sh" >&2
            exit 1
            ;;
    esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: Not a git repository (or any of the parent directories)." >&2
    exit 2
fi

if git diff --cached --quiet; then
    echo "ERROR: No staged files found. Please stage your files first." >&2
    exit 3
fi

SKIPPED=0

if command -v gitleaks >/dev/null 2>&1; then
    if ! gitleaks git --pre-commit --redact --staged --verbose >&2; then
        echo "ERROR: gitleaks scan failed or detected exposed secrets. Please review the output above." >&2
        exit 5
    fi
    echo "SUCCESS: Staging area validation passed." >&2
else
    echo "WARNING: gitleaks is not installed. Skipping automated security scan. Please proceed with manual inspection." >&2
    SKIPPED=1
fi

git -c core.quotepath=false diff --cached --name-status

if [ "$SKIPPED" -eq 1 ]; then
    exit 10
fi
