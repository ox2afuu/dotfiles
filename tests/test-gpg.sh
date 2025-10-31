#!/usr/bin/env bash
#
# test-gpg.sh - Validate GPG signing configuration
#
# This script validates that GPG commit signing is properly configured.

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

echo "=== GPG Signing Validation ==="
echo

# Track failures and warnings
FAILURES=0
WARNINGS=0

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
        ((WARNINGS++))
    fi
}

# Test 1: Check if GPG is installed
echo "--- Test 1: GPG Installation ---"

if command -v gpg &> /dev/null; then
    gpg_version=$(gpg --version | head -1)
    print_status "ok" "GPG is installed: ${gpg_version}"
else
    print_status "fail" "GPG is not installed"
    echo "Install with: brew install gnupg"
    exit 2
fi

echo

# Test 2: Check if GPG keys exist
echo "--- Test 2: GPG Key Availability ---"

if gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -q "sec"; then
    print_status "ok" "GPG secret key(s) found"

    # Show key info
    echo "  Available keys:"
    gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -E "(sec|uid)" | sed 's/^/  /'
else
    print_status "warn" "No GPG secret keys found"
    echo "  Generate with: gpg --full-generate-key"
fi

echo

# Test 3: Check Git GPG configuration
echo "--- Test 3: Git GPG Configuration ---"

# Check if signing key is configured
if git config --global user.signingkey &> /dev/null; then
    signing_key=$(git config --global user.signingkey)
    print_status "ok" "Signing key configured: ${signing_key}"
else
    print_status "warn" "No signing key configured in Git"
    echo "  Configure with: git config --global user.signingkey YOUR_KEY_ID"
fi

# Check if commit signing is enabled
if git config --global commit.gpgsign &> /dev/null; then
    gpgsign=$(git config --global commit.gpgsign)
    if [[ "${gpgsign}" == "true" ]]; then
        print_status "ok" "Commit signing is enabled"
    else
        print_status "warn" "Commit signing is disabled"
        echo "  Enable with: git config --global commit.gpgsign true"
    fi
else
    print_status "warn" "Commit signing not configured"
    echo "  Enable with: git config --global commit.gpgsign true"
fi

# Check GPG program
if git config --global gpg.program &> /dev/null; then
    gpg_program=$(git config --global gpg.program)
    print_status "ok" "GPG program set: ${gpg_program}"

    # Verify it exists
    if command -v "${gpg_program}" &> /dev/null; then
        print_status "ok" "GPG program is accessible"
    else
        print_status "fail" "GPG program not found: ${gpg_program}"
    fi
else
    print_status "warn" "GPG program not explicitly set (using default)"
fi

echo

# Test 4: Check GPG agent configuration
echo "--- Test 4: GPG Agent Configuration ---"

if [[ -f ~/.gnupg/gpg-agent.conf ]]; then
    print_status "ok" "gpg-agent.conf exists"

    # Check for pinentry program
    if grep -q "pinentry-program" ~/.gnupg/gpg-agent.conf; then
        pinentry=$(grep "pinentry-program" ~/.gnupg/gpg-agent.conf | head -1)
        print_status "ok" "Pinentry configured: ${pinentry}"

        # Extract path and check if it exists
        pinentry_path=$(echo "${pinentry}" | awk '{print $2}')
        if [[ -f "${pinentry_path}" ]]; then
            print_status "ok" "Pinentry program exists"
        else
            print_status "warn" "Pinentry program not found: ${pinentry_path}"
        fi
    else
        print_status "warn" "No pinentry program configured"
        echo "  Add to ~/.gnupg/gpg-agent.conf:"
        echo "  pinentry-program /opt/homebrew/bin/pinentry-mac"
    fi
else
    print_status "warn" "gpg-agent.conf not found"
    echo "  Create ~/.gnupg/gpg-agent.conf with pinentry configuration"
fi

echo

# Test 5: Check environment variables
echo "--- Test 5: Environment Variables ---"

if [[ -n "${GPG_TTY:-}" ]]; then
    print_status "ok" "GPG_TTY is set: ${GPG_TTY}"
else
    print_status "warn" "GPG_TTY not set"
    echo "  Add to ~/.zshrc: export GPG_TTY=\$(tty)"
fi

echo

# Test 6: Test GPG signing capability
echo "--- Test 6: GPG Signing Test ---"

if echo "test" | gpg --clearsign &> /dev/null; then
    print_status "ok" "GPG can sign data"
else
    print_status "fail" "GPG signing failed"
    echo "  Test with: echo 'test' | gpg --clearsign"
fi

echo

# Test 7: Check recent commits for GPG signatures
echo "--- Test 7: Recent Commit Signatures ---"

if git log -1 --show-signature &> /dev/null; then
    # Check if last commit is signed
    if git log -1 --pretty="%G?" | grep -qE "^G"; then
        print_status "ok" "Last commit is GPG signed (Good signature)"
    elif git log -1 --pretty="%G?" | grep -qE "^U"; then
        print_status "warn" "Last commit signed but key is untrusted"
    elif git log -1 --pretty="%G?" | grep -qE "^B"; then
        print_status "warn" "Last commit has bad signature"
    elif git log -1 --pretty="%G?" | grep -qE "^E"; then
        print_status "warn" "Last commit signature cannot be verified"
    else
        print_status "warn" "Last commit is not signed"
    fi
else
    print_status "warn" "Cannot check commit signatures"
fi

# Check last 5 commits
signed_count=0
total_count=0

while IFS= read -r sig_status; do
    ((total_count++))
    if [[ "${sig_status}" == "G" ]]; then
        ((signed_count++))
    fi
done < <(git log -5 --pretty="%G?" 2>/dev/null || true)

if [[ ${total_count} -gt 0 ]]; then
    echo "  Last 5 commits: ${signed_count}/${total_count} signed"
fi

echo

# Test 8: Check key expiration
echo "--- Test 8: Key Expiration Check ---"

if gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -q "sec"; then
    # Get key ID
    key_id=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -A 1 "sec" | tail -1 | awk '{print $1}' | head -1)

    if gpg --list-keys "${key_id}" 2>/dev/null | grep -q "expires"; then
        expiry=$(gpg --list-keys "${key_id}" 2>/dev/null | grep "expires" | head -1)
        print_status "warn" "Key has expiration: ${expiry}"
    else
        print_status "ok" "Key does not expire"
    fi
fi

echo

# Test 9: Verify pinentry-mac installation (macOS specific)
echo "--- Test 9: Pinentry Installation (macOS) ---"

if [[ "$(uname)" == "Darwin" ]]; then
    if command -v pinentry-mac &> /dev/null; then
        print_status "ok" "pinentry-mac is installed"
    else
        print_status "warn" "pinentry-mac not installed"
        echo "  Install with: brew install pinentry-mac"
    fi
else
    print_status "ok" "Skipping (not macOS)"
fi

echo

# Test 10: Check for common issues
echo "--- Test 10: Common Issues Check ---"

# Check for GPG 2.x
if gpg --version | head -1 | grep -q "gpg (GnuPG) 2\."; then
    print_status "ok" "Using GPG 2.x (recommended)"
else
    print_status "warn" "Not using GPG 2.x"
fi

# Check if gpg-agent is running
if pgrep gpg-agent &> /dev/null; then
    print_status "ok" "gpg-agent is running"
else
    print_status "warn" "gpg-agent not running (may start on demand)"
fi

echo

# Summary
echo "=== Summary ==="
echo "Checks: $((FAILURES + WARNINGS)) issues found"

if [[ ${FAILURES} -eq 0 && ${WARNINGS} -eq 0 ]]; then
    print_status "ok" "GPG is fully configured for commit signing!"
    exit 0
elif [[ ${FAILURES} -eq 0 ]]; then
    print_status "warn" "${WARNINGS} warning(s) - GPG is functional but can be improved"
    echo
    echo "GPG signing should work, but review warnings above for optimal setup."
    exit 0
else
    print_status "fail" "${FAILURES} critical issue(s), ${WARNINGS} warning(s)"
    echo
    echo "See: docs/src/contributing.md#gpg-commit-signing-required"
    exit 1
fi
