#!/usr/bin/env bash
#
# test-snippets.sh - Test code snippets from documentation
#
# This script extracts shell code blocks from markdown files and validates them.

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
readonly TEMP_DIR=$(mktemp -d)

# Cleanup on exit
trap 'rm -rf "${TEMP_DIR}"' EXIT

# Change to repo root
cd "${REPO_ROOT}"

echo "=== Documentation Snippet Testing ==="
echo

# Track failures
FAILURES=0

# Function to print status
print_status() {
    local status="${1}"
    local message="${2}"

    if [[ "${status}" == "ok" ]]; then
        echo -e "${GREEN}✓${NC} ${message}"
    elif [[ "${status}" == "fail" ]]; then
        echo -e "${RED}✗${NC} ${message}"
        ((FAILURES++))
    elif [[ "${status}" == "warn" ]]; then
        echo -e "${YELLOW}⚠${NC} ${message}"
    fi
}

# Extract bash/sh/zsh code blocks from markdown
extract_shell_snippets() {
    local markdown_file="${1}"
    local output_dir="${2}"

    awk '
    /^```(bash|sh|zsh)/ {
        in_code_block=1
        counter++
        filename=sprintf("%s/snippet_%03d.sh", output_dir, counter)
        next
    }
    /^```/ {
        if (in_code_block) {
            in_code_block=0
            close(filename)
        }
        next
    }
    in_code_block {
        print $0 >> filename
    }
    ' output_dir="${output_dir}" "${markdown_file}"
}

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
    print_status "fail" "shellcheck not found - required for snippet testing"
    echo "Install with: brew install shellcheck"
    exit 1
fi

# Find all markdown files in docs
echo "--- Extracting Code Snippets ---"

mapfile -t MARKDOWN_FILES < <(find docs/src -type f -name "*.md" 2>/dev/null || true)

if [[ ${#MARKDOWN_FILES[@]} -eq 0 ]]; then
    print_status "warn" "No markdown files found in docs/src"
    exit 0
fi

echo "Found ${#MARKDOWN_FILES[@]} markdown files"
echo

TOTAL_SNIPPETS=0

for md_file in "${MARKDOWN_FILES[@]}"; do
    # Create temp directory for this file's snippets
    file_temp_dir="${TEMP_DIR}/$(basename "${md_file}" .md)"
    mkdir -p "${file_temp_dir}"

    # Extract snippets
    extract_shell_snippets "${md_file}" "${file_temp_dir}"

    # Count snippets
    snippet_count=$(find "${file_temp_dir}" -type f -name "snippet_*.sh" 2>/dev/null | wc -l | tr -d ' ')

    if [[ ${snippet_count} -gt 0 ]]; then
        echo "Found ${snippet_count} snippet(s) in $(basename "${md_file}")"
        TOTAL_SNIPPETS=$((TOTAL_SNIPPETS + snippet_count))
    fi
done

echo
echo "Total snippets extracted: ${TOTAL_SNIPPETS}"
echo

if [[ ${TOTAL_SNIPPETS} -eq 0 ]]; then
    print_status "warn" "No code snippets found to test"
    exit 0
fi

# Test extracted snippets
echo "--- Testing Snippets ---"

find "${TEMP_DIR}" -type f -name "snippet_*.sh" | while read -r snippet; do
    snippet_name=$(basename "${snippet}")
    parent_dir=$(basename "$(dirname "${snippet}")")

    # Run shellcheck on snippet
    # Use -s bash and allow some common documentation patterns
    if shellcheck -s bash \
        -e SC2148 \
        -e SC2317 \
        "${snippet}" 2>&1 | grep -q "No issues detected"; then
        print_status "ok" "${parent_dir}/${snippet_name}"
    else
        # Check if it's just missing shebang (common in docs)
        if shellcheck -s bash -e SC2148 -e SC2317 "${snippet}" 2>/dev/null; then
            print_status "ok" "${parent_dir}/${snippet_name} (documentation example)"
        else
            print_status "fail" "${parent_dir}/${snippet_name}"
            # Show errors
            shellcheck -s bash -e SC2148 -e SC2317 "${snippet}" || true
        fi
    fi
done

echo

# Summary
echo "=== Summary ==="
if [[ ${FAILURES} -eq 0 ]]; then
    print_status "ok" "All ${TOTAL_SNIPPETS} snippets validated successfully!"
    exit 0
else
    print_status "fail" "${FAILURES} snippet(s) failed validation"
    exit 1
fi
