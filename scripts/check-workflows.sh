#!/usr/bin/env bash
set -euo pipefail

# Check workflows and list status check names
# This helps you know what names to use in branch protection

echo "════════════════════════════════════════════════════════"
echo "  GitHub Actions Workflow Status Check Names"
echo "════════════════════════════════════════════════════════"
echo ""

WORKFLOWS_DIR=".github/workflows"

if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    echo "❌ Error: $WORKFLOWS_DIR not found"
    exit 1
fi

echo "Scanning workflows in $WORKFLOWS_DIR..."
echo ""

for workflow in "$WORKFLOWS_DIR"/*.yml; do
    if [[ ! -f "$workflow" ]]; then
        continue
    fi

    filename=$(basename "$workflow")

    # Extract workflow name
    workflow_name=$(grep "^name:" "$workflow" | head -1 | sed 's/name: *//' | sed 's/"//g')

    if [[ -z "$workflow_name" ]]; then
        echo "⚠️  $filename - No workflow name found"
        continue
    fi

    echo "📋 Workflow: $workflow_name"
    echo "   File: $filename"
    echo ""

    # Extract job names (lines that start with 2 spaces and end with :, but not keywords)
    jobs=$(grep -E "^  [a-z][a-z0-9_-]+:" "$workflow" | \
           sed 's/://g' | \
           sed 's/^  //' | \
           grep -vE "^(on|permissions|env|concurrency|jobs)$" || true)

    if [[ -n "$jobs" ]]; then
        echo "   Status check names:"
        while IFS= read -r job; do
            if [[ -n "$job" ]]; then
                echo "   ✓ $workflow_name / $job"
            fi
        done <<< "$jobs"
    else
        echo "   ⚠️  No jobs found"
    fi

    echo ""
done

echo "════════════════════════════════════════════════════════"
echo ""
echo "📝 How to use these names:"
echo ""
echo "1. Go to GitHub: Settings → Branches → Add rule"
echo "2. Enter branch name (stable, nightly, or dev)"
echo "3. Enable 'Require status checks to pass'"
echo "4. Search for the names listed above"
echo "5. Click on each to add it as required"
echo ""
echo "⚠️  Important: Status checks only appear in GitHub after"
echo "   they've run at least once on that branch!"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
echo "Recommended status checks by branch:"
echo ""
echo "🔴 STABLE (Production):"
echo "   - Tests / lint"
echo "   - Tests / snippet-tests"
echo "   - Tests / integration-tests"
echo "   - Tests / markdown-lint"
echo "   - Tests / container-tests"
echo "   - Tests / test-summary"
echo "   - Super-Linter / super-linter"
echo "   - CodeQL Security Scanning / analyze"
echo "   - Documentation / build"
echo ""
echo "🟡 NIGHTLY (Staging):"
echo "   - Tests / lint"
echo "   - Tests / integration-tests"
echo "   - Tests / container-tests"
echo "   - Super-Linter / super-linter"
echo "   - CodeQL Security Scanning / analyze"
echo ""
echo "🟢 DEV (Development):"
echo "   - Tests / lint"
echo "   - Super-Linter / super-linter"
echo ""
echo "════════════════════════════════════════════════════════"
