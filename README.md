# Dotfiles

Personal configuration files managed with GNU Stow.

## Usage
```bash
# Stow a package
stow shell

# Stow all packages
stow */

# Unstow a package
stow -D shell

# Restow (useful after changes)
stow -R shell
```

## Packages

- `shell/` - zsh, bash, starship, omz-custom
- `git/` - git configuration
- `editors/` - neovim, emacs
- `terminal/` - ghostty, iterm2
- `tools/` - htop, television
- `desktop/` - aerospace
- `dev/` - containers, octave, fish

## Installation on new machine
```bash
cd ~/dotfiles
stow */
```
