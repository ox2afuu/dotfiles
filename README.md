# Dotfiles

[![Stable](https://img.shields.io/github/actions/workflow/status/ox2a-fuu/dotfiles/test.yml?branch=stable&label=Stable&logo=github)](https://github.com/ox2a-fuu/dotfiles/actions?query=branch%3Astable)
[![Nightly](https://img.shields.io/github/actions/workflow/status/ox2a-fuu/dotfiles/test.yml?branch=nightly&label=Nightly&logo=github)](https://github.com/ox2a-fuu/dotfiles/actions?query=branch%3Anightly)
[![Dev](https://img.shields.io/github/actions/workflow/status/ox2a-fuu/dotfiles/test.yml?branch=dev&label=Dev&logo=github)](https://github.com/ox2a-fuu/dotfiles/actions?query=branch%3Adev)
[![Super-Linter](https://img.shields.io/github/actions/workflow/status/ox2a-fuu/dotfiles/super-linter.yml?label=Super-Linter&logo=github)](https://github.com/ox2a-fuu/dotfiles/actions/workflows/super-linter.yml)
[![CodeQL](https://img.shields.io/github/actions/workflow/status/ox2a-fuu/dotfiles/codeql.yml?label=CodeQL&logo=github)](https://github.com/ox2a-fuu/dotfiles/security/code-scanning)

Personal configuration files managed with GNU Stow.

## Quick Links

- [📚 Documentation](https://ox2a-fuu.github.io/dotfiles/) - Full documentation site
- [🤝 Contributing Guide](./docs/src/contributing.md) - How to contribute
- [🌿 Branch Strategy](./BRANCH_STRATEGY.md) - Git-flow light workflow
- [📝 Wiki Structure](./WIKI_STRUCTURE.md) - Community wiki guidelines
- [💬 Discussions](https://github.com/ox2a-fuu/dotfiles/discussions) - Ask questions
- [🐛 Report Bug](https://github.com/ox2a-fuu/dotfiles/issues/new?template=bug_report.yml) - Report an issue
- [✨ Request Feature](https://github.com/ox2a-fuu/dotfiles/issues/new?template=feature_request.yml) - Suggest an enhancement

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
