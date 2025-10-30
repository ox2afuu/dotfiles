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

# Ghostty color palette setup
# Use themes as set by ghostty | export the palette once per host
[[ -z $COLORFGBG ]] && {
    export COLORFGBG='15;0'
    ghostty +list-colors | sed -n 's/\([^ ]*\) \(#\)/\1 \2/p' > ~/.cache/ghostty-palette
}
