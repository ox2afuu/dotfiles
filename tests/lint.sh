#!/usr/bin/env bash
#
# lint.sh - Shell script and configuration file linting
#
# This script lints all shell scripts and validates configuration files
# in the dotfiles repository.

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

echo "=== Dotfiles Linting ==="
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

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
    print_status "warn" "shellcheck not found, skipping shell linting"
    print_status "warn" "Install with: brew install shellcheck"
else
    echo "--- Shell Script Linting ---"

    # Find all shell scripts
    mapfile -t SHELL_SCRIPTS < <(find . -type f \
        \( -name "*.sh" -o -name "*.zsh" -o -name "*.bash" \) \
        -not -path "*/\.git/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/\.cache/*")

    if [[ ${#SHELL_SCRIPTS[@]} -eq 0 ]]; then
        print_status "warn" "No shell scripts found"
    else
        echo "Found ${#SHELL_SCRIPTS[@]} shell scripts"

        for script in "${SHELL_SCRIPTS[@]}"; then
            if shellcheck "${script}"; then
                print_status "ok" "shellcheck ${script}"
            else
                print_status "fail" "shellcheck ${script}"
            fi
        done
    fi
    echo
fi

# Check if shfmt is installed
if ! command -v shfmt &> /dev/null; then
    print_status "warn" "shfmt not found, skipping shell formatting check"
    print_status "warn" "Install with: brew install shfmt"
else
    echo "--- Shell Script Formatting ---"

    if shfmt -d -i 4 -ci -sr .; then
        print_status "ok" "Shell scripts are properly formatted"
    else
        print_status "fail" "Shell scripts have formatting issues"
        echo "Run: shfmt -w -i 4 -ci -sr ."
    fi
    echo
fi

# Validate TOML files
echo "--- TOML Validation ---"

mapfile -t TOML_FILES < <(find . -type f -name "*.toml" \
    -not -path "*/\.git/*" \
    -not -path "*/target/*")

if [[ ${#TOML_FILES[@]} -eq 0 ]]; then
    print_status "warn" "No TOML files found"
else
    for toml_file in "${TOML_FILES[@]}"; do
        # Basic TOML syntax check using Python
        if command -v python3 &> /dev/null; then
            if python3 -c "import tomllib; tomllib.load(open('${toml_file}', 'rb'))" 2>/dev/null; then
                print_status "ok" "Valid TOML: ${toml_file}"
            else
                print_status "fail" "Invalid TOML: ${toml_file}"
            fi
        else
            print_status "warn" "Python3 not found, cannot validate TOML"
            break
        fi
    done
fi
echo

# Validate YAML files
echo "--- YAML Validation ---"

mapfile -t YAML_FILES < <(find . -type f \( -name "*.yaml" -o -name "*.yml" \) \
    -not -path "*/\.git/*" \
    -not -path "*/node_modules/*")

if [[ ${#YAML_FILES[@]} -eq 0 ]]; then
    print_status "warn" "No YAML files found"
else
    for yaml_file in "${YAML_FILES[@]}"; do
        # Basic YAML syntax check using Python
        if command -v python3 &> /dev/null; then
            if python3 -c "import yaml; yaml.safe_load(open('${yaml_file}'))" 2>/dev/null; then
                print_status "ok" "Valid YAML: ${yaml_file}"
            else
                print_status "fail" "Invalid YAML: ${yaml_file}"
            fi
        else
            print_status "warn" "Python3 not found, cannot validate YAML"
            break
        fi
    done
fi
echo

# Validate JSON files
echo "--- JSON Validation ---"

mapfile -t JSON_FILES < <(find . -type f -name "*.json" \
    -not -path "*/\.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/target/*")

if [[ ${#JSON_FILES[@]} -eq 0 ]]; then
    print_status "warn" "No JSON files found"
else
    for json_file in "${JSON_FILES[@]}"; do
        if python3 -m json.tool "${json_file}" > /dev/null 2>&1; then
            print_status "ok" "Valid JSON: ${json_file}"
        else
            print_status "fail" "Invalid JSON: ${json_file}"
        fi
    done
fi
echo

# Summary
echo "=== Summary ==="
if [[ ${FAILURES} -eq 0 ]]; then
    print_status "ok" "All linting checks passed!"
    exit 0
else
    print_status "fail" "${FAILURES} check(s) failed"
    exit 1
fi
