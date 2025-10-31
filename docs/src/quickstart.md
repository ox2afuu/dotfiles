# Quick Start

Get up and running with dotfiles in minutes.

## Installation

```bash
# Clone and install all packages
git clone https://github.com/ox2a-fuu/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow */
```

## Common Tasks

### Installing Specific Packages

```bash
# Shell configuration only
stow shell

# Multiple packages
stow shell git editors terminal
```

### Updating Dotfiles

```bash
cd ~/dotfiles
git pull
stow -R */  # Re-stow to apply changes
```

### Removing a Package

```bash
stow -D shell
```

## Package Overview

| Package | Description | Key Tools |
|---------|-------------|-----------|
| `shell` | Shell configuration | Zsh, Starship, Oh My Zsh |
| `git` | Git settings | git config, aliases |
| `editors` | Text editors | Neovim, Emacs |
| `terminal` | Terminal emulators | Ghostty, iTerm2 |
| `tools` | System utilities | htop, television |
| `desktop` | Window manager | Aerospace |
| `dev` | Development tools | Docker, Podman |
| `analysis` | Data science | Octave, Weka |
| `writing` | Content creation | LaTeX, Obsidian |

## Customization

### Local Overrides

Create local config files that won't be tracked:

```bash
# Local zsh config
echo "export MY_VAR=value" > ~/.config/omz-custom/local.zsh

# Local git config
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Starship Theme

Switch between light and dark themes:

```bash
prompt-theme-auto  # Auto-detect from Ghostty
prompt-theme-light # Manual light theme
prompt-theme-dark  # Manual dark theme
```

## Next Steps

- Read [Installation](./installation.md) for detailed setup
- Explore [Package Documentation](./packages/shell.md) for configuration options
- Check out [Guides](./guides/starship-config.md) for advanced features
