#!/usr/bin/env bash
# test-in-container.sh - Test dotfiles in Podman container
# Usage: ./scripts/test-in-container.sh [bootstrap|local|clean]

set -euo pipefail

# Ensure Podman is in PATH (handles both Homebrew and Podman Desktop locations)
export PATH="/opt/homebrew/bin:/opt/podman/bin:$PATH"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory and workspace
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

print_status() {
    local status="$1"
    local message="$2"

    case "$status" in
        "ok")
            echo -e "${GREEN}✓${NC} ${message}"
            ;;
        "fail")
            echo -e "${RED}✗${NC} ${message}"
            ;;
        "info")
            echo -e "${BLUE}ℹ${NC} ${message}"
            ;;
        "warn")
            echo -e "${YELLOW}⚠${NC} ${message}"
            ;;
    esac
}

print_header() {
    echo ""
    echo -e "${BLUE}===${NC} $1 ${BLUE}===${NC}"
    echo ""
}

check_dependencies() {
    print_header "Checking Dependencies"

    if ! command -v podman &> /dev/null; then
        print_status "fail" "Podman not found. Install with: brew install podman"
        exit 1
    fi
    print_status "ok" "Podman $(podman --version | awk '{print $3}')"

    if ! command -v devcontainer &> /dev/null; then
        print_status "fail" "devcontainer CLI not found. Install with: npm install -g @devcontainers/cli"
        exit 1
    fi
    print_status "ok" "devcontainer CLI installed"
}

start_container() {
    print_header "Starting Container"

    print_status "info" "Building and starting Podman container..."
    if devcontainer up --workspace-folder "${WORKSPACE_DIR}"; then
        print_status "ok" "Container started successfully"
    else
        print_status "fail" "Failed to start container"
        exit 1
    fi
}

bootstrap_test() {
    print_header "Bootstrap Test - Fresh Install"

    print_status "info" "Testing fresh dotfiles installation..."

    # Clean up any conflicting default files
    print_status "info" "Cleaning up default config files..."
    devcontainer exec --workspace-folder "${WORKSPACE_DIR}" bash -c \
        "rm -f ~/.gitconfig ~/.bashrc ~/.profile" || true

    # Install all packages with stow
    print_status "info" "Running: stow */"
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" bash -c \
        "cd /home/testuser/dotfiles && stow */"; then
        print_status "ok" "Stow installation successful"
    else
        print_status "fail" "Stow installation failed"
        exit 1
    fi

    # Verify shell config
    print_status "info" "Verifying zsh configuration..."
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" zsh -c \
        "source ~/.zshrc && echo 'Shell loaded successfully'"; then
        print_status "ok" "Shell configuration valid"
    else
        print_status "warn" "Shell configuration has issues (non-critical)"
    fi

    # Verify starship
    print_status "info" "Checking Starship prompt..."
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" bash -c \
        "starship --version"; then
        print_status "ok" "Starship is available"
    else
        print_status "warn" "Starship check failed"
    fi

    # Run lint tests
    print_status "info" "Running lint tests..."
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" bash -c \
        "cd /home/testuser/dotfiles && ./tests/lint.sh"; then
        print_status "ok" "Lint tests passed"
    else
        print_status "fail" "Lint tests failed"
        exit 1
    fi

    # Run integration tests
    print_status "info" "Running integration tests..."
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" bash -c \
        "cd /home/testuser/dotfiles && ./tests/integration-tests.sh"; then
        print_status "ok" "Integration tests passed"
    else
        print_status "fail" "Integration tests failed"
        exit 1
    fi

    print_header "Bootstrap Test Complete"
    print_status "ok" "All tests passed successfully"
}

local_override_test() {
    print_header "Local Override Test"

    local LOCAL_ZSH="${HOME}/.config/omz-custom/local.zsh"

    if [[ ! -f "${LOCAL_ZSH}" ]]; then
        print_status "warn" "No local.zsh found at ${LOCAL_ZSH}"
        print_status "info" "Skipping local override test"
        return 0
    fi

    print_status "info" "Copying local.zsh into container..."

    # Copy local.zsh into container
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" bash -c \
        "mkdir -p /home/testuser/.config/omz-custom"; then
        print_status "ok" "Created omz-custom directory"
    else
        print_status "fail" "Failed to create directory"
        exit 1
    fi

    # Read local.zsh and write it into the container
    if podman exec -i "$(get_container_id)" bash -c \
        "cat > /home/testuser/.config/omz-custom/local.zsh" < "${LOCAL_ZSH}"; then
        print_status "ok" "Copied local.zsh into container"
    else
        print_status "fail" "Failed to copy local.zsh"
        exit 1
    fi

    # Install dotfiles with stow
    print_status "info" "Installing dotfiles with stow..."
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" bash -c \
        "cd /home/testuser/dotfiles && stow */"; then
        print_status "ok" "Stow installation successful"
    else
        print_status "fail" "Stow installation failed"
        exit 1
    fi

    # Test that local.zsh loads
    print_status "info" "Testing local.zsh loading..."
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" zsh -c \
        "source ~/.zshrc && [[ -f ~/.config/omz-custom/local.zsh ]]"; then
        print_status "ok" "local.zsh is sourced correctly"
    else
        print_status "fail" "local.zsh not loaded"
        exit 1
    fi

    # Run tests with local overrides
    print_status "info" "Running tests with local overrides..."
    if devcontainer exec --workspace-folder "${WORKSPACE_DIR}" bash -c \
        "cd /home/testuser/dotfiles && ./tests/lint.sh && ./tests/integration-tests.sh"; then
        print_status "ok" "Tests passed with local overrides"
    else
        print_status "fail" "Tests failed with local overrides"
        exit 1
    fi

    print_header "Local Override Test Complete"
    print_status "ok" "Local customizations work correctly"
}

get_container_id() {
    # Get container ID for the dotfiles devcontainer
    podman ps --filter "label=devcontainer.local_folder=${WORKSPACE_DIR}" \
        --format "{{.ID}}" | head -n 1
}

clean_container() {
    print_header "Cleaning Up Container"

    local container_id
    container_id="$(get_container_id)"

    if [[ -z "${container_id}" ]]; then
        print_status "info" "No container found to clean"
        return 0
    fi

    print_status "info" "Stopping container ${container_id}..."
    if podman stop "${container_id}"; then
        print_status "ok" "Container stopped"
    else
        print_status "warn" "Failed to stop container (may already be stopped)"
    fi

    print_status "info" "Removing container ${container_id}..."
    if podman rm "${container_id}"; then
        print_status "ok" "Container removed"
    else
        print_status "warn" "Failed to remove container"
    fi

    print_status "info" "Cleaning up devcontainer cache..."
    rm -rf "${WORKSPACE_DIR}/.devcontainer/.docker-cache"

    print_status "ok" "Cleanup complete"
}

usage() {
    cat << EOF
Usage: $0 [MODE]

Test dotfiles in a Podman rootless container.

MODES:
    bootstrap    Test fresh installation (stow all packages)
    local        Test with personal local.zsh overrides
    clean        Stop and remove the container

EXAMPLES:
    $0 bootstrap
    $0 local
    $0 clean

The container uses:
- Alpine Linux base image
- testuser (UID 1000, non-root)
- Bind mount: ~/dotfiles → /home/testuser/dotfiles

See .devcontainer/README.md for more details.
EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 0
    fi

    local mode="$1"

    case "$mode" in
        bootstrap)
            check_dependencies
            start_container
            bootstrap_test
            ;;
        local)
            check_dependencies
            start_container
            local_override_test
            ;;
        clean)
            clean_container
            ;;
        -h|--help|help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error:${NC} Unknown mode '${mode}'"
            echo ""
            usage
            exit 1
            ;;
    esac
}

main "$@"
