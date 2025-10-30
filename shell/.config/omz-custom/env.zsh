# env.zsh - Environment variables and PATH management
# This file is sourced after oh-my-zsh loads

# Unified PATH export
# Priority order: homebrew -> texlive -> system paths -> user paths
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/texlive/2023/bin/universal-darwin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.cache/lm-studio/bin"

# PostgreSQL 18
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

# FPATH for completions
# Docker completions
fpath=($HOME/.docker/completions $fpath)

# eza completions (from custom FOSS build)
export FPATH="$HOME/foss/eza/completions/zsh:$FPATH"

# Ghostty completions
fpath=(/Applications/Ghostty.app/Contents/MacOS:$fpath)
