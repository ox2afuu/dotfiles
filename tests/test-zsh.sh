#!/usr/bin/env bash
#
# test-zsh.sh - Validate Zsh and Oh My Zsh configuration
#
# This script validates that Zsh configurations are properly structured
# and don't contain common errors.

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
readonly SHELL_DIR="${REPO_ROOT}/shell"

# Change to repo root
cd "${REPO_ROOT}"

echo "=== Zsh Configuration Validation ==="
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

# Test 1: Check if shell directory exists
echo "--- Test 1: Shell Directory Structure ---"

if [[ -d "${SHELL_DIR}" ]]; then
    print_status "ok" "Shell directory exists"
else
    print_status "fail" "Shell directory not found: ${SHELL_DIR}"
    exit 1
fi

# Check for key zsh files
zsh_files=(
    ".zshrc"
    ".zshenv"
)

for zsh_file in "${zsh_files[@]}"; do
    if [[ -f "${SHELL_DIR}/${zsh_file}" ]]; then
        print_status "ok" "Found ${zsh_file}"
    else
        print_status "warn" "Missing ${zsh_file}"
    fi
done

echo

# Test 2: Check for Oh My Zsh custom directory
echo "--- Test 2: Oh My Zsh Custom Directory ---"

if [[ -d "${SHELL_DIR}/.oh-my-zsh-custom" ]]; then
    print_status "ok" "Oh My Zsh custom directory exists"

    # Check for common subdirectories
    for subdir in plugins themes; do
        if [[ -d "${SHELL_DIR}/.oh-my-zsh-custom/${subdir}" ]]; then
            print_status "ok" "Custom ${subdir} directory exists"
        else
            print_status "warn" "Custom ${subdir} directory not found"
        fi
    done
else
    print_status "warn" "Oh My Zsh custom directory not found"
fi

echo

# Test 3: Validate .zshrc syntax
echo "--- Test 3: Zsh Configuration Syntax ---"

if [[ -f "${SHELL_DIR}/.zshrc" ]]; then
    # Check if zsh is installed
    if command -v zsh &> /dev/null; then
        print_status "ok" "Zsh is installed"

        # Try to source the file in a subshell to check for syntax errors
        # Use -n flag for syntax checking without execution
        if zsh -n "${SHELL_DIR}/.zshrc" 2>/dev/null; then
            print_status "ok" ".zshrc has valid syntax"
        else
            print_status "fail" ".zshrc has syntax errors"
            zsh -n "${SHELL_DIR}/.zshrc" 2>&1 | head -10 || true
        fi
    else
        print_status "warn" "Zsh not installed - cannot validate syntax"
        echo "  Install with: brew install zsh"
    fi
else
    print_status "warn" ".zshrc not found"
fi

echo

# Test 4: Check for common anti-patterns
echo "--- Test 4: Configuration Best Practices ---"

if [[ -f "${SHELL_DIR}/.zshrc" ]]; then
    # Check for source commands with proper error handling
    if grep -q "source.*||" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "Has error handling for source commands"
    else
        print_status "warn" "Consider adding error handling: source file || true"
    fi

    # Check for ZSH_CUSTOM variable
    if grep -q "ZSH_CUSTOM" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "ZSH_CUSTOM variable configured"
    else
        print_status "warn" "ZSH_CUSTOM variable not set"
    fi

    # Check if PATH is modified
    if grep -q "PATH=" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "PATH modifications found"
    fi

    # Check for plugin definitions
    if grep -q "plugins=(" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "Oh My Zsh plugins configured"

        # Extract and show plugins
        plugins=$(grep "plugins=(" "${SHELL_DIR}/.zshrc" | sed 's/.*plugins=(//' | sed 's/).*//' | tr '\n' ' ')
        echo "  Plugins: ${plugins}"
    else
        print_status "warn" "No Oh My Zsh plugins configured"
    fi

    # Check for theme configuration
    if grep -q "ZSH_THEME=" "${SHELL_DIR}/.zshrc"; then
        theme=$(grep "ZSH_THEME=" "${SHELL_DIR}/.zshrc" | head -1 | sed 's/.*ZSH_THEME=//' | tr -d '"')
        print_status "ok" "Theme configured: ${theme}"
    else
        print_status "warn" "No theme configured"
    fi
fi

echo

# Test 5: Check for Starship configuration
echo "--- Test 5: Starship Prompt ---"

if [[ -f "${SHELL_DIR}/.config/starship.toml" ]]; then
    print_status "ok" "Starship config exists"

    # Check if starship is referenced in zshrc
    if [[ -f "${SHELL_DIR}/.zshrc" ]] && grep -q "starship" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "Starship integrated in .zshrc"
    else
        print_status "warn" "Starship not integrated in .zshrc"
    fi

    # Validate TOML syntax if python3 is available
    if command -v python3 &> /dev/null; then
        if python3 -c "import tomllib; tomllib.load(open('${SHELL_DIR}/.config/starship.toml', 'rb'))" 2>/dev/null; then
            print_status "ok" "Starship TOML is valid"
        else
            print_status "fail" "Starship TOML has syntax errors"
        fi
    fi
else
    print_status "warn" "Starship config not found"
fi

echo

# Test 6: Check for custom aliases and functions
echo "--- Test 6: Custom Aliases and Functions ---"

alias_files=(
    ".oh-my-zsh-custom/aliases.zsh"
    ".zsh_aliases"
)

found_aliases=false
for alias_file in "${alias_files[@]}"; do
    if [[ -f "${SHELL_DIR}/${alias_file}" ]]; then
        print_status "ok" "Found alias file: ${alias_file}"
        found_aliases=true

        # Count aliases
        alias_count=$(grep -c "^alias " "${SHELL_DIR}/${alias_file}" 2>/dev/null || echo "0")
        echo "  Aliases defined: ${alias_count}"
    fi
done

if [[ "${found_aliases}" == "false" ]]; then
    print_status "warn" "No custom alias files found"
fi

echo

# Test 7: Check for potential issues
echo "--- Test 7: Common Issues Check ---"

if [[ -f "${SHELL_DIR}/.zshrc" ]]; then
    # Check for hardcoded paths
    if grep -qE "/Users/[a-zA-Z0-9._-]+/" "${SHELL_DIR}/.zshrc"; then
        print_status "warn" "Found hardcoded user paths - consider using \$HOME"
        grep -nE "/Users/[a-zA-Z0-9._-]+/" "${SHELL_DIR}/.zshrc" | head -5 | sed 's/^/  /' || true
    else
        print_status "ok" "No hardcoded user paths"
    fi

    # Check for unquoted variables
    if grep -qE '\$[A-Z_]+[^}]' "${SHELL_DIR}/.zshrc" | grep -v "^#"; then
        print_status "warn" "Consider quoting variables with curly braces: \${VAR}"
    else
        print_status "ok" "Variables properly formatted"
    fi

    # Check for deprecated syntax
    if grep -q "setopt " "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "Uses setopt for options"
    fi
fi

echo

# Test 8: Check plugin files
echo "--- Test 8: Custom Plugin Validation ---"

if [[ -d "${SHELL_DIR}/.oh-my-zsh-custom/plugins" ]]; then
    plugin_count=$(find "${SHELL_DIR}/.oh-my-zsh-custom/plugins" -type d -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')

    if [[ ${plugin_count} -gt 0 ]]; then
        print_status "ok" "Found ${plugin_count} custom plugin(s)"

        # Check each plugin has a main file
        for plugin_dir in "${SHELL_DIR}/.oh-my-zsh-custom/plugins"/*; do
            if [[ -d "${plugin_dir}" ]]; then
                plugin_name=$(basename "${plugin_dir}")
                main_file="${plugin_dir}/${plugin_name}.plugin.zsh"

                if [[ -f "${main_file}" ]]; then
                    print_status "ok" "Plugin ${plugin_name} has main file"
                else
                    print_status "warn" "Plugin ${plugin_name} missing main file"
                fi
            fi
        done
    else
        print_status "warn" "No custom plugins found"
    fi
fi

echo

# Test 9: Check for Zsh-specific features
echo "--- Test 9: Zsh-Specific Features ---"

if [[ -f "${SHELL_DIR}/.zshrc" ]]; then
    # Check for completion system
    if grep -q "autoload.*compinit" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "Completion system configured"
    else
        print_status "warn" "Completion system not explicitly configured"
    fi

    # Check for history configuration
    if grep -qE "HISTSIZE|SAVEHIST|HISTFILE" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "History configuration present"
    else
        print_status "warn" "No history configuration found"
    fi

    # Check for key bindings
    if grep -qE "bindkey" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "Custom key bindings configured"
    fi
fi

echo

# Test 10: Integration with other tools
echo "--- Test 10: Tool Integration ---"

tools_to_check=(
    "fzf:fuzzy finder"
    "zoxide:smart cd"
    "direnv:directory environments"
)

for tool_info in "${tools_to_check[@]}"; do
    IFS=':' read -r tool desc <<< "${tool_info}"

    if [[ -f "${SHELL_DIR}/.zshrc" ]] && grep -qi "${tool}" "${SHELL_DIR}/.zshrc"; then
        print_status "ok" "Integrated with ${tool} (${desc})"
    fi
done

echo

# Summary
echo "=== Summary ==="
echo "Checks: $((FAILURES + WARNINGS)) issues found"

if [[ ${FAILURES} -eq 0 && ${WARNINGS} -eq 0 ]]; then
    print_status "ok" "Zsh configuration is optimal!"
    exit 0
elif [[ ${FAILURES} -eq 0 ]]; then
    print_status "warn" "${WARNINGS} warning(s) - configuration is functional"
    echo
    echo "Zsh configuration should work, but review warnings for improvements."
    exit 0
else
    print_status "fail" "${FAILURES} critical issue(s), ${WARNINGS} warning(s)"
    exit 1
fi
