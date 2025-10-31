#!/usr/bin/env bash
#
# test-workflows.sh - Validate GitHub Actions workflows
#
# This script validates that GitHub Actions workflows are properly configured.

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
readonly WORKFLOWS_DIR="${REPO_ROOT}/.github/workflows"

# Change to repo root
cd "${REPO_ROOT}"

echo "=== GitHub Actions Workflow Validation ==="
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

# Test 1: Check if workflows directory exists
echo "--- Test 1: Workflows Directory ---"

if [[ -d "${WORKFLOWS_DIR}" ]]; then
    print_status "ok" "Workflows directory exists"
else
    print_status "fail" "Workflows directory not found"
    exit 1
fi

echo

# Test 2: Check required workflows exist
echo "--- Test 2: Required Workflows ---"

required_workflows=(
    "test.yml"
    "docs.yml"
    "super-linter.yml"
    "codeql.yml"
    "promote-to-stable.yml"
    "tag-release.yml"
)

for workflow in "${required_workflows[@]}"; do
    if [[ -f "${WORKFLOWS_DIR}/${workflow}" ]]; then
        print_status "ok" "Workflow exists: ${workflow}"
    else
        print_status "fail" "Workflow missing: ${workflow}"
    fi
done

echo

# Test 3: Validate YAML syntax
echo "--- Test 3: YAML Syntax Validation ---"

if command -v python3 &> /dev/null; then
    for workflow_file in "${WORKFLOWS_DIR}"/*.yml; do
        if [[ ! -f "${workflow_file}" ]]; then
            continue
        fi

        filename=$(basename "${workflow_file}")

        if python3 -c "import yaml; yaml.safe_load(open('${workflow_file}'))" 2>/dev/null; then
            print_status "ok" "Valid YAML: ${filename}"
        else
            print_status "fail" "Invalid YAML: ${filename}"
        fi
    done
else
    print_status "warn" "Python3 not found, cannot validate YAML"
fi

echo

# Test 4: Check workflow names are defined
echo "--- Test 4: Workflow Names ---"

for workflow_file in "${WORKFLOWS_DIR}"/*.yml; do
    if [[ ! -f "${workflow_file}" ]]; then
        continue
    fi

    filename=$(basename "${workflow_file}")

    if grep -q "^name:" "${workflow_file}"; then
        workflow_name=$(grep "^name:" "${workflow_file}" | head -1 | sed 's/name: *//' | sed 's/"//g')
        print_status "ok" "${filename}: ${workflow_name}"
    else
        print_status "warn" "${filename}: No name defined"
    fi
done

echo

# Test 5: Check branch triggers are correct
echo "--- Test 5: Branch Trigger Configuration ---"

expected_branches=("stable" "nightly" "dev")

for workflow_file in "${WORKFLOWS_DIR}"/*.yml; do
    if [[ ! -f "${workflow_file}" ]]; then
        continue
    fi

    filename=$(basename "${workflow_file}")

    # Skip tag-release and promote workflows (different trigger logic)
    if [[ "${filename}" == "tag-release.yml" || "${filename}" == "promote-to-stable.yml" ]]; then
        continue
    fi

    # Check if workflow has branch triggers
    if grep -q "branches:" "${workflow_file}"; then
        # Check for old branch names (main, test/docs)
        if grep -A 5 "branches:" "${workflow_file}" | grep -qE "(- main|main$|test/docs)"; then
            print_status "fail" "${filename}: Uses old branch names (main/test/docs)"
        else
            print_status "ok" "${filename}: Branch triggers configured"
        fi
    else
        # Some workflows may not have branch triggers (e.g., scheduled workflows)
        if grep -q "schedule:" "${workflow_file}"; then
            print_status "ok" "${filename}: Scheduled workflow (no branch trigger needed)"
        else
            print_status "warn" "${filename}: No branch triggers defined"
        fi
    fi
done

echo

# Test 6: Check for required jobs in test.yml
echo "--- Test 6: Required Test Jobs ---"

if [[ -f "${WORKFLOWS_DIR}/test.yml" ]]; then
    required_jobs=(
        "lint"
        "integration-tests"
        "container-tests"
    )

    for job in "${required_jobs[@]}"; do
        if grep -qE "^  ${job}:" "${WORKFLOWS_DIR}/test.yml"; then
            print_status "ok" "Job defined: ${job}"
        else
            print_status "fail" "Job missing: ${job}"
        fi
    done
else
    print_status "fail" "test.yml not found"
fi

echo

# Test 7: Check permissions are properly defined
echo "--- Test 7: Workflow Permissions ---"

for workflow_file in "${WORKFLOWS_DIR}"/*.yml; do
    if [[ ! -f "${workflow_file}" ]]; then
        continue
    fi

    filename=$(basename "${workflow_file}")

    if grep -q "permissions:" "${workflow_file}"; then
        print_status "ok" "${filename}: Has permissions defined"
    else
        print_status "warn" "${filename}: No explicit permissions (uses defaults)"
    fi
done

echo

# Test 8: Check for hardcoded secrets (security check)
echo "--- Test 8: Security - No Hardcoded Secrets ---"

for workflow_file in "${WORKFLOWS_DIR}"/*.yml; do
    if [[ ! -f "${workflow_file}" ]]; then
        continue
    fi

    filename=$(basename "${workflow_file}")

    # Check for patterns that might indicate hardcoded secrets
    if grep -qE "(password|token|secret|key):\s*['\"]?[a-zA-Z0-9]{10,}" "${workflow_file}"; then
        print_status "warn" "${filename}: Possible hardcoded secret (verify manually)"
    else
        print_status "ok" "${filename}: No obvious hardcoded secrets"
    fi
done

echo

# Test 9: Check action versions are pinned
echo "--- Test 9: Action Version Pinning ---"

for workflow_file in "${WORKFLOWS_DIR}"/*.yml; do
    if [[ ! -f "${workflow_file}" ]]; then
        continue
    fi

    filename=$(basename "${workflow_file}")

    # Check if actions use version tags (not @latest or @master)
    if grep -E "uses:.*@(latest|master|main)" "${workflow_file}" > /dev/null 2>&1; then
        print_status "warn" "${filename}: Uses unpinned action versions (@latest/@master)"
    else
        if grep -q "uses:" "${workflow_file}"; then
            print_status "ok" "${filename}: Actions are version pinned"
        fi
    fi
done

echo

# Test 10: Validate workflow file structure
echo "--- Test 10: Workflow Structure ---"

for workflow_file in "${WORKFLOWS_DIR}"/*.yml; do
    if [[ ! -f "${workflow_file}" ]]; then
        continue
    fi

    filename=$(basename "${workflow_file}")

    # Check for required top-level keys
    has_name=$(grep -q "^name:" "${workflow_file}" && echo "yes" || echo "no")
    has_on=$(grep -q "^on:" "${workflow_file}" && echo "yes" || echo "no")
    has_jobs=$(grep -q "^jobs:" "${workflow_file}" && echo "yes" || echo "no")

    if [[ "${has_name}" == "yes" && "${has_on}" == "yes" && "${has_jobs}" == "yes" ]]; then
        print_status "ok" "${filename}: Valid structure (name, on, jobs)"
    else
        missing=""
        [[ "${has_name}" == "no" ]] && missing="${missing} name"
        [[ "${has_on}" == "no" ]] && missing="${missing} on"
        [[ "${has_jobs}" == "no" ]] && missing="${missing} jobs"
        print_status "fail" "${filename}: Missing required keys:${missing}"
    fi
done

echo

# Summary
echo "=== Summary ==="
echo "Workflows validated: $(find "${WORKFLOWS_DIR}" -name "*.yml" | wc -l | tr -d ' ')"

if [[ ${FAILURES} -eq 0 ]]; then
    print_status "ok" "All workflow validations passed!"
    exit 0
else
    print_status "fail" "${FAILURES} check(s) failed"
    exit 1
fi
