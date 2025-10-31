#!/usr/bin/env bash
#
# run-all-tests.sh - Master test runner
#
# This script runs all test suites and provides a comprehensive summary.

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Change to repo root
cd "${REPO_ROOT}"

echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}         Dotfiles Comprehensive Test Suite${NC}"
echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
echo

# Track results (using parallel arrays for bash 3.2 compatibility)
test_results=()
test_times=()
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test suites to run
test_suites=(
    "lint.sh:Linting & Formatting"
    "integration-tests.sh:Integration Tests"
    "test-snippets.sh:Documentation Snippets"
    "check-links.sh:Link Checking"
    "test-pre-commit.sh:Pre-commit Configuration"
    "test-workflows.sh:Workflow Validation"
    "test-gpg.sh:GPG Signing Setup"
    "test-zsh.sh:Zsh Configuration"
)

# Function to print section header
print_header() {
    local title="${1}"
    echo
    echo -e "${BLUE}═══ ${title} ═══${NC}"
    echo
}

# Function to run a test suite
run_test() {
    local test_script="${1}"
    local test_name="${2}"
    local result=""

    ((TOTAL_TESTS++))

    print_header "${test_name}"

    # Record start time
    local start_time=$(date +%s)

    # Run test and capture exit code
    if "${SCRIPT_DIR}/${test_script}"; then
        result="PASS"
        ((PASSED_TESTS++))
    else
        local exit_code=$?
        if [[ ${exit_code} -eq 2 ]]; then
            # Exit code 2 indicates skip (e.g., tool not installed)
            result="SKIP"
            ((SKIPPED_TESTS++))
        else
            result="FAIL"
            ((FAILED_TESTS++))
        fi
    fi

    # Record end time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Store result as "name|result|time" for bash 3.2 compatibility
    test_results+=("${test_name}|${result}|${duration}s")
}

# Parse command line arguments
QUICK_MODE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick|-q)
            QUICK_MODE=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  --quick, -q     Run only essential tests (lint, integration)"
            echo "  --verbose, -v   Show detailed output"
            echo "  --help, -h      Show this help message"
            echo
            echo "Examples:"
            echo "  $0              Run all tests"
            echo "  $0 --quick      Run essential tests only"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run test suites
if [[ "${QUICK_MODE}" == "true" ]]; then
    echo -e "${YELLOW}Running in quick mode (essential tests only)${NC}"
    echo
    # Only run essential tests
    run_test "lint.sh" "Linting & Formatting"
    run_test "integration-tests.sh" "Integration Tests"
else
    # Run all tests
    for suite in "${test_suites[@]}"; do
        IFS=':' read -r script name <<< "${suite}"
        if [[ -f "${SCRIPT_DIR}/${script}" ]]; then
            run_test "${script}" "${name}"
        else
            echo -e "${YELLOW}⚠ Skipping ${name}: ${script} not found${NC}"
        fi
    done
fi

# Print summary
echo
echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}                     Summary${NC}"
echo -e "${BOLD}════════════════════════════════════════════════════════${NC}"
echo

# Print results table
printf "%-35s %-10s %-10s\n" "Test Suite" "Result" "Time"
echo "──────────────────────────────────────────────────────────"

for result_entry in "${test_results[@]}"; do
    # Parse the stored result (name|result|time)
    IFS='|' read -r name result time <<< "${result_entry}"

    case "${result}" in
        PASS)
            printf "%-35s ${GREEN}%-10s${NC} %-10s\n" "${name}" "✓ PASS" "${time}"
            ;;
        FAIL)
            printf "%-35s ${RED}%-10s${NC} %-10s\n" "${name}" "✗ FAIL" "${time}"
            ;;
        SKIP)
            printf "%-35s ${YELLOW}%-10s${NC} %-10s\n" "${name}" "⊘ SKIP" "${time}"
            ;;
    esac
done

echo
echo "──────────────────────────────────────────────────────────"
echo "Total: ${TOTAL_TESTS} | Passed: ${PASSED_TESTS} | Failed: ${FAILED_TESTS} | Skipped: ${SKIPPED_TESTS}"
echo

# Final result
if [[ ${FAILED_TESTS} -eq 0 ]]; then
    if [[ ${SKIPPED_TESTS} -gt 0 ]]; then
        echo -e "${YELLOW}⚠ Tests passed with ${SKIPPED_TESTS} skipped${NC}"
        echo "Some tests were skipped (usually due to missing optional tools)"
        exit 0
    else
        echo -e "${GREEN}✓ All tests passed!${NC}"
        exit 0
    fi
else
    echo -e "${RED}✗ ${FAILED_TESTS} test suite(s) failed${NC}"
    echo
    echo "Failed suites:"
    for result_entry in "${test_results[@]}"; do
        IFS='|' read -r name result time <<< "${result_entry}"
        if [[ "${result}" == "FAIL" ]]; then
            echo "  - ${name}"
        fi
    done
    echo
    echo "Run individual test to see details:"
    echo "  ./tests/<test-script>.sh"
    exit 1
fi
