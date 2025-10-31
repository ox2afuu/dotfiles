# ~/.zshrc - Zsh configuration
# Managed with GNU Stow for portability across systems

# =============================================================================
# Oh-My-Zsh Setup
# =============================================================================

# Path to Oh-My-Zsh installation (installed via curl script, not homebrew)
export ZSH="$HOME/.oh-my-zsh"

# Path to custom configuration (XDG-compliant, managed via Stow)
export ZSH_CUSTOM="${XDG_CONFIG_HOME:-$HOME/.config}/omz-custom"

# =============================================================================
# Load Configuration Modules (in order)
# =============================================================================

# 1. Options - Oh-My-Zsh settings that must be set BEFORE oh-my-zsh.sh loads
[[ -f "$ZSH_CUSTOM/options.zsh" ]] && source "$ZSH_CUSTOM/options.zsh"

# 2. Oh-My-Zsh - Load the framework
source $ZSH/oh-my-zsh.sh

# 3. Environment - PATH, FPATH, and environment variables
[[ -f "$ZSH_CUSTOM/env.zsh" ]] && source "$ZSH_CUSTOM/env.zsh"

# 4. Plugins - External plugins (must load AFTER oh-my-zsh)
[[ -f "$ZSH_CUSTOM/plugins.zsh" ]] && source "$ZSH_CUSTOM/plugins.zsh"

# 5. Starship - Prompt configuration
[[ -f "$ZSH_CUSTOM/starship.zsh" ]] && source "$ZSH_CUSTOM/starship.zsh"

# 6. Aliases - Custom aliases
[[ -f "$ZSH_CUSTOM/aliases.zsh" ]] && source "$ZSH_CUSTOM/aliases.zsh"

# 7. Keybinds - Custom keybindings
[[ -f "$ZSH_CUSTOM/keybinds.zsh" ]] && source "$ZSH_CUSTOM/keybinds.zsh"

# 8. Local - Machine-specific overrides (NOT tracked in git)
[[ -f "$ZSH_CUSTOM/local.zsh" ]] && source "$ZSH_CUSTOM/local.zsh"

# =============================================================================
# End of .zshrc
# =============================================================================
export GPG_TTY=$(tty)
