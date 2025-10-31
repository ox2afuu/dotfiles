# options.zsh - Zsh and Oh-My-Zsh settings
# This file is sourced BEFORE oh-my-zsh.sh loads

# Oh-My-Zsh configuration
plugins=(git)

# Auto-update settings
zstyle ':omz:update' mode auto

# Required to keep homebrew working with zsh-autosuggestions
ZSH_DISABLE_COMPFIX="true"

# Suppress warning for widget errors
zle -N menu-search 2>/dev/null
zle -N recent-paths 2>/dev/null

# Ghostty integration
# Export COLORFGBG for terminal compatibility
# Note: ghostty +list-colors exports X11 color names, not terminal ANSI colors
[[ -z ${COLORFGBG} ]] && {
    export COLORFGBG='15;0'
    # Optional: export X11 color names (useful for some tools)
    # ghostty +list-colors | sed -n 's/\([^ ]*\) \(#\)/\1 \2/p' > ~/.cache/ghostty-palette
}
