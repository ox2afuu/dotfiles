#!/usr/bin/env bash
#
# check-links.sh - Check for broken links in documentation
#
# This script uses mdbook-linkcheck2 in standalone mode to check all links
# in the documentation.

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
readonly DOCS_DIR="${REPO_ROOT}/docs"

echo "=== Documentation Link Checking ==="
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

# Check if mdbook-linkcheck2 is installed
if ! command -v mdbook-linkcheck2 &> /dev/null; then
    print_status "fail" "mdbook-linkcheck2 not found"
    echo "Install with: cargo install mdbook-linkcheck2"
    exit 1
fi

# Check if docs directory exists
if [[ ! -d "${DOCS_DIR}" ]]; then
    print_status "fail" "Documentation directory not found: ${DOCS_DIR}"
    exit 1
fi

# Run linkcheck in standalone mode
echo "--- Checking Links in Documentation ---"
cd "${DOCS_DIR}"

if mdbook-linkcheck2 --standalone .; then
    print_status "ok" "All links are valid"
else
    print_status "fail" "Found broken links in documentation"
fi

echo

# Summary
echo "=== Summary ==="
if [[ ${FAILURES} -eq 0 ]]; then
    print_status "ok" "All link checks passed!"
    exit 0
else
    print_status "fail" "${FAILURES} check(s) failed"
    exit 1
fi
