#!/usr/bin/env bash
#
# integration-tests.sh - Integration tests for dotfiles
#
# This script tests that stow commands work correctly and packages
# don't conflict with each other.

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Change to repo root
cd "${REPO_ROOT}"

echo "=== Integration Tests ==="
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

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    print_status "fail" "GNU Stow not found - required for integration tests"
    echo "Install with: brew install stow"
    exit 1
fi

# Test 1: Verify package structure
echo "--- Test 1: Package Structure ---"

mapfile -t PACKAGES < <(find . -maxdepth 1 -type d -not -path "." -not -path "./.*" -not -path "./docs" -not -path "./tests" | sed 's|^\./||')

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    print_status "fail" "No packages found"
else
    print_status "ok" "Found ${#PACKAGES[@]} package(s): ${PACKAGES[*]}"
fi

echo

# Test 2: Stow Dry Run (check for conflicts)
echo "--- Test 2: Stow Dry Run ---"

for package in "${PACKAGES[@]}"; do
    if [[ ! -d "${package}" ]]; then
        continue
    fi

    # Skip if package is empty
    if [[ -z "$(find "${package}" -mindepth 1 -print -quit)" ]]; then
        print_status "warn" "${package}: Empty package, skipping"
        continue
    fi

    # Run stow in simulation mode
    if stow -n -v "${package}" 2>&1 | grep -q "LINK"; then
        print_status "ok" "${package}: Dry run successful"
    else
        # Check if it's because no files would be stowed
        if stow -n -v "${package}" 2>&1 | grep -q "WARNING"; then
            print_status "warn" "${package}: Warnings during dry run"
            stow -n -v "${package}" 2>&1 | grep "WARNING" || true
        else
            print_status "ok" "${package}: No conflicts detected"
        fi
    fi
done

echo

# Test 3: Check for common configuration file conflicts
echo "--- Test 3: Configuration File Conflicts ---"

# Check if multiple packages try to manage the same files
declare -A file_owners

for package in "${PACKAGES[@]}"; do
    if [[ ! -d "${package}" ]]; then
        continue
    fi

    # Find all files in package
    while IFS= read -r -d '' file; do
        # Get relative path from package root
        rel_path="${file#${package}/}"

        if [[ -n "${file_owners[${rel_path}]:-}" ]]; then
            print_status "fail" "Conflict: ${rel_path} owned by both ${file_owners[${rel_path}]} and ${package}"
        else
            file_owners["${rel_path}"]="${package}"
        fi
    done < <(find "${package}" -type f -print0)
done

if [[ ${FAILURES} -eq 0 ]]; then
    print_status "ok" "No file conflicts detected between packages"
fi

echo

# Test 4: Validate symlink targets exist
echo "--- Test 4: Symlink Target Validation ---"

for package in "${PACKAGES[@]}"; do
    if [[ ! -d "${package}" ]]; then
        continue
    fi

    # Find symlinks in package
    while IFS= read -r -d '' symlink; do
        if [[ -L "${symlink}" ]]; then
            target=$(readlink "${symlink}")

            if [[ ! -e "${target}" && ! -e "${package}/${target}" ]]; then
                print_status "warn" "${package}: Broken symlink ${symlink} -> ${target}"
            fi
        fi
    done < <(find "${package}" -type l -print0 2>/dev/null || true)
done

echo

# Test 5: Check for stow-local-ignore files
echo "--- Test 5: Stow Configuration ---"

if [[ -f .stow-local-ignore ]]; then
    print_status "ok" "Found .stow-local-ignore"

    # Validate patterns
    while IFS= read -r pattern; do
        # Skip comments and empty lines
        [[ "${pattern}" =~ ^#.*$ || -z "${pattern}" ]] && continue

        print_status "ok" "  Ignore pattern: ${pattern}"
    done < .stow-local-ignore
else
    print_status "warn" "No .stow-local-ignore found"
fi

echo

# Test 6: Documentation completeness
echo "--- Test 6: Documentation Coverage ---"

for package in "${PACKAGES[@]}"; do
    if [[ ! -d "${package}" ]]; then
        continue
    fi

    doc_file="docs/src/packages/${package}.md"

    if [[ -f "${doc_file}" ]]; then
        print_status "ok" "${package}: Documentation exists"
    else
        print_status "warn" "${package}: Missing documentation at ${doc_file}"
    fi
done

echo

# Summary
echo "=== Summary ==="
if [[ ${FAILURES} -eq 0 ]]; then
    print_status "ok" "All integration tests passed!"
    exit 0
else
    print_status "fail" "${FAILURES} test(s) failed"
    exit 1
fi
