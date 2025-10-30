# starship-helpers.zsh - Helper functions for custom starship modules
# These functions are called by custom modules defined in starship.toml

# =============================================================================
# Context-Aware Directory Display
# =============================================================================
# Shows: dirname or repo:dirname with context symbols
# Symbols: (SSH),  (Container), or normal colors

__starship_context_dir() {
    local current_dir=$(basename "$PWD")
    local output=""
    local symbol=""

    # Detect context and set symbol
    if [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]]; then
        # SSH connection
        symbol=" "
    elif [[ -f /.dockerenv ]] || [[ -n "$KUBERNETES_SERVICE_HOST" ]]; then
        # Container environment
        symbol=" "
    fi

    # Check if in git repo
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -n "$git_root" ]]; then
        local repo_name=$(basename "$git_root")

        # If we're not at repo root, show repo:subdir
        if [[ "$PWD" != "$git_root" ]]; then
            output="${repo_name}:${current_dir}"
        else
            output="$repo_name"
        fi
    else
        # Not in git repo, just show current dir
        output="$current_dir"
    fi

    # Output with optional symbol
    if [[ -n "$symbol" ]]; then
        echo "${symbol}${output}"
    else
        echo "$output"
    fi
}

# =============================================================================
# Git Branch Symbol Mapping
# =============================================================================
# Maps branch names to symbols based on patterns
# Returns: [◎] [⎇] [✓] [🔥] or [branch-name]

__starship_git_branch_symbol() {
    # Get current branch name
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # If not in git repo or detached HEAD
    if [[ -z "$branch" ]] || [[ "$branch" == "HEAD" ]]; then
        return
    fi

    local symbol=""

    # Match branch patterns
    case "$branch" in
        main|master)
            symbol="◎"
            ;;
        feature/*|feat/*)
            symbol="⎇"
            ;;
        test/*|testing/*|tests/*)
            symbol="✓"
            ;;
        hotfix/*|fix/*|bugfix/*)
            symbol="🔥"
            ;;
        *)
            # For other branches, show abbreviated name (first 10 chars)
            if [[ ${#branch} -gt 10 ]]; then
                symbol="${branch:0:10}…"
            else
                symbol="$branch"
            fi
            ;;
    esac

    echo "[$symbol]"
}

# =============================================================================
# Git Remote Info
# =============================================================================
# Parses git remote URL and returns: origin:github, origin:gitlab, local, etc.
# Only outputs if in git repo

__starship_git_remote_info() {
    # Check if in git repo
    if ! git rev-parse --git-dir &>/dev/null; then
        return
    fi

    # Get remote URL
    local remote_url=$(git remote get-url origin 2>/dev/null)

    # If no remote, show "local"
    if [[ -z "$remote_url" ]]; then
        echo "local"
        return
    fi

    # Parse service from URL
    local service=""

    if [[ "$remote_url" =~ github\.com ]]; then
        service="github"
    elif [[ "$remote_url" =~ gitlab\.com ]]; then
        service="gitlab"
    elif [[ "$remote_url" =~ bitbucket\.org ]]; then
        service="bitbucket"
    elif [[ "$remote_url" =~ (git@|https?://)([^:/]+) ]]; then
        # Extract hostname for self-hosted
        local host="${match[2]}"
        # Take first part of hostname (before first dot)
        service="${host%%.*}"
    else
        service="git"
    fi

    # Get remote name (usually 'origin' but could be different)
    local remote_name=$(git remote 2>/dev/null | head -1)
    remote_name="${remote_name:-origin}"

    echo "${remote_name}:${service}"
}

# =============================================================================
# Context-Aware Directory Display (Simple - Basename Only)
# =============================================================================
# Shows: dirname (no repo:subdir, used for right prompt)
# Symbols: (SSH),  (Container), or normal

__starship_context_dir_simple() {
    local current_dir=$(basename "$PWD")
    local symbol=""

    # Detect context and set symbol
    if [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]]; then
        # SSH connection
        symbol=" "
    elif [[ -f /.dockerenv ]] || [[ -n "$KUBERNETES_SERVICE_HOST" ]]; then
        # Container environment
        symbol=" "
    fi

    # Output with optional symbol
    if [[ -n "$symbol" ]]; then
        echo "${symbol}${current_dir}"
    else
        echo "$current_dir"
    fi
}

# =============================================================================
# Git Ahead/Behind Counts
# =============================================================================
# Shows: ⇡N⇣M for ahead/behind counts
# Returns empty if not in git repo or no upstream

__starship_git_ahead_behind() {
    # Check if in git repo
    if ! git rev-parse --git-dir &>/dev/null; then
        return
    fi

    # Check if upstream is configured
    local upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if [[ -z "$upstream" ]]; then
        return
    fi

    # Get ahead/behind counts
    local counts=$(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
    if [[ -z "$counts" ]]; then
        return
    fi

    # Parse counts (format: "behind\tahead")
    local behind=$(echo "$counts" | awk '{print $1}')
    local ahead=$(echo "$counts" | awk '{print $2}')

    local output=""

    # Add ahead arrow if ahead
    if [[ "$ahead" -gt 0 ]]; then
        output="⇡${ahead}"
    fi

    # Add behind arrow if behind
    if [[ "$behind" -gt 0 ]]; then
        output="${output}⇣${behind}"
    fi

    # Only output if there's something to show
    if [[ -n "$output" ]]; then
        echo "$output"
    fi
}

# =============================================================================
# Functions are now defined and ready to be called by starship
# No need to export - they're called in subshells via 'source && function_name'
# =============================================================================
