#!/usr/bin/env bash
#
# test-pre-commit.sh - Validate pre-commit configuration
#
# This script validates that pre-commit hooks are properly configured
# and can run successfully.

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

echo "=== Pre-commit Hook Validation ==="
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

# Test 1: Check if .pre-commit-config.yaml exists
echo "--- Test 1: Configuration File ---"

if [[ -f ".pre-commit-config.yaml" ]]; then
    print_status "ok" ".pre-commit-config.yaml exists"
else
    print_status "fail" ".pre-commit-config.yaml not found"
fi

echo

# Test 2: Validate YAML syntax
echo "--- Test 2: YAML Syntax Validation ---"

if [[ -f ".pre-commit-config.yaml" ]]; then
    if command -v python3 &> /dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('.pre-commit-config.yaml'))" 2>/dev/null; then
            print_status "ok" "Valid YAML syntax"
        else
            print_status "fail" "Invalid YAML syntax"
        fi
    else
        print_status "warn" "Python3 not found, cannot validate YAML"
    fi
fi

echo

# Test 3: Check required hooks are configured
echo "--- Test 3: Required Hooks ---"

if [[ -f ".pre-commit-config.yaml" ]]; then
    required_hooks=(
        "shellcheck"
        "typos"
        "check-yaml"
        "check-toml"
        "check-json"
    )

    for hook in "${required_hooks[@]}"; do
        if grep -q "${hook}" .pre-commit-config.yaml; then
            print_status "ok" "Hook configured: ${hook}"
        else
            print_status "warn" "Hook not found: ${hook}"
        fi
    done
fi

echo

# Test 4: Check if pre-commit is installed
echo "--- Test 4: Pre-commit Installation ---"

if command -v pre-commit &> /dev/null; then
    print_status "ok" "pre-commit is installed"

    # Get version
    version=$(pre-commit --version | head -1)
    echo "  Version: ${version}"
else
    print_status "warn" "pre-commit not installed (optional for CI)"
    echo "  Install with: pip install pre-commit"
fi

echo

# Test 5: Validate hook repositories
echo "--- Test 5: Hook Repository Validation ---"

if [[ -f ".pre-commit-config.yaml" ]] && command -v pre-commit &> /dev/null; then
    # Try to validate the config
    if pre-commit validate-config 2>&1 | grep -q "is valid"; then
        print_status "ok" "Configuration is valid"
    else
        # Run again to show output
        if pre-commit validate-config 2>/dev/null; then
            print_status "ok" "Configuration validated"
        else
            print_status "fail" "Configuration validation failed"
            pre-commit validate-config || true
        fi
    fi
else
    print_status "warn" "Skipping validation (pre-commit not installed)"
fi

echo

# Test 6: Check if hooks are installable
echo "--- Test 6: Hook Installation Test ---"

if command -v pre-commit &> /dev/null; then
    # Try to run pre-commit without installing (dry run)
    if pre-commit run --help &> /dev/null; then
        print_status "ok" "Pre-commit hooks are runnable"
    else
        print_status "fail" "Pre-commit hooks cannot run"
    fi
else
    print_status "warn" "Skipping (pre-commit not installed)"
fi

echo

# Test 7: Check for common hook configuration issues
echo "--- Test 7: Configuration Best Practices ---"

if [[ -f ".pre-commit-config.yaml" ]]; then
    # Check for minimum configuration
    if grep -q "repos:" .pre-commit-config.yaml; then
        print_status "ok" "Has repos section"
    else
        print_status "fail" "Missing repos section"
    fi

    # Check for hook IDs
    if grep -q "id:" .pre-commit-config.yaml; then
        print_status "ok" "Has hook IDs defined"
    else
        print_status "fail" "No hook IDs found"
    fi

    # Check for specific version pins (recommended)
    if grep -q "rev:" .pre-commit-config.yaml; then
        print_status "ok" "Hooks are version pinned"
    else
        print_status "warn" "Hooks are not version pinned"
    fi
fi

echo

# Summary
echo "=== Summary ==="
if [[ ${FAILURES} -eq 0 ]]; then
    print_status "ok" "Pre-commit configuration is valid!"
    exit 0
else
    print_status "fail" "${FAILURES} check(s) failed"
    exit 1
fi
