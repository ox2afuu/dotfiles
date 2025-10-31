# Dotfiles

Personal configuration files managed with GNU Stow.

This repository contains modular dotfiles for macOS (and potentially other Unix systems) organized using GNU Stow for easy deployment and management.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/ox2a-fuu/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install all packages
stow */
```

For detailed installation instructions, see the [Installation Guide](./installation.md).

## Features

- Modular package structure for easy selective deployment
- Modern shell configuration with Zsh + Oh My Zsh
- Beautiful Starship prompt with Ghostty theme integration
- Comprehensive editor configurations (Neovim, Emacs)
- Container and development tool setups
- Automated testing and documentation

## Packages

- [Shell Configuration](./packages/shell.md) - zsh, bash, starship, omz-custom
- [Git Configuration](./packages/git.md) - git configuration
- [Editors](./packages/editors.md) - neovim, emacs
- [Terminal Emulators](./packages/terminal.md) - ghostty, iterm2
- [System Tools](./packages/tools.md) - htop, television
- [Desktop Environment](./packages/desktop.md) - aerospace
- [Development Tools](./packages/dev.md) - containers (Docker/Podman)
- [Data Analysis](./packages/analysis.md) - octave, weka (data science & computation)
- [Writing & Content](./packages/writing.md) - latex, obsidian (content creation)

## Documentation Highlights

- [Starship Configuration Guide](./guides/starship-config.md) - Comprehensive prompt customization
- [Ghostty-Starship Integration](./guides/starship-ghostty.md) - Theme synchronization
- [GNU Stow Usage](./guides/stow.md) - Package management
- [Testing Documentation](./testing.md) - Quality assurance and CI/CD

## Branch Strategy

This repository uses a simple but effective branching strategy:

- `main` - Stable, production-ready configurations (tagged as `stable`)
- `test/docs` - Testing and documentation updates (tagged as `nightly`)
- `dev` - Active development branch (no stability guarantees)

See [Branch Strategy](./branch-strategy.md) for more details.

## Contributing

Contributions are welcome! Please see the [Contributing Guide](./contributing.md) for details on:

- Code style and conventions
- Testing requirements
- Documentation standards
- Pull request process
