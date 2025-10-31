# Installation

This guide covers installing the dotfiles on a new machine.

## Prerequisites

### Required Tools

- **GNU Stow** - Package manager for dotfiles
  ```bash
  # macOS
  brew install stow

  # Linux (Debian/Ubuntu)
  apt install stow
  ```

- **Git** - Version control
  ```bash
  # macOS
  brew install git

  # Linux
  apt install git
  ```

### Optional Tools

Depending on which packages you want to use:

- **Zsh** - Modern shell (required for shell package)
- **Starship** - Cross-shell prompt (required for shell package)
- **Neovim** - Text editor (required for editors package)
- **Ghostty** - Terminal emulator (required for terminal package)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/ox2a-fuu/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Review Available Packages

List all available packages:

```bash
ls -d */
```

### 3. Install Packages

#### Install All Packages

```bash
stow */
```

#### Install Specific Packages

```bash
# Install shell configuration only
stow shell

# Install multiple packages
stow shell git editors
```

### 4. Verify Installation

Check that symlinks were created:

```bash
# Check shell config
ls -la ~/.zshrc

# Check git config
ls -la ~/.gitconfig

# Check starship config
ls -la ~/.config/starship.toml
```

## Troubleshooting

### Conflicts

If Stow reports conflicts, you may have existing files:

```bash
# Backup existing files
mkdir ~/dotfiles-backup
mv ~/.zshrc ~/dotfiles-backup/

# Try again
stow shell
```

### Removing Packages

To uninstall a package:

```bash
stow -D shell
```

### Re-stowing After Updates

After pulling updates:

```bash
cd ~/dotfiles
git pull
stow -R */
```

## Next Steps

- See [Quick Start](./quickstart.md) for basic usage
- Explore [Package Documentation](./packages/shell.md) for customization
- Read [Guides](./guides/starship-config.md) for advanced features
