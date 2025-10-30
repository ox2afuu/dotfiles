# plugins.zsh - External plugin loading
# This file is sourced AFTER oh-my-zsh.sh loads

# Docker CLI completions (load early)
autoload -Uz compinit
compinit -u

# zsh-autosuggestions (from homebrew)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-navigation-tools (from homebrew)
source /opt/homebrew/share/zsh-navigation-tools/zsh-navigation-tools.plugin.zsh

# fzf - Set up key bindings and fuzzy completion (provides Ctrl+R history search)
source <(fzf --zsh)

# zsh-f-sy-h - Feature-rich syntax highlighting (load after completions)
# Suppress harmless warning about zsh-autocomplete widgets
source /opt/homebrew/share/zsh-f-sy-h/F-Sy-H.plugin.zsh 2> >(grep -v 'zsh-syntax-highlighting.*unhandled ZLE widget' >&2)

# zsh-autocomplete (load last to avoid conflicts)
source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
