# Starship Configuration Guide

This guide explains the new starship prompt configuration with ghostty theme integration.

## Overview

The starship configuration has been updated with:
- **Two-line multiline prompt** with context information
- **Ghostty theme integration** with automatic detection
- **Custom prompt switching functions** for different workflows
- **Continuation prompt** with bold double arrows (❯❯)
- **Rich module support** for your development toolchain

## Prompt Layout

### Main Prompt (Two Lines)

```
╭─ ~/dotfiles  main !1 ?2  󱃾 production (default)  3.11.0  1.75.0
╰─❯
```

**Line 1** (Context):
- Directory path (truncated, repo-aware)
- Git branch and status
- Language versions (Python, Rust, C)
- Container context (Docker/Podman)
- Kubernetes context
- Command duration (if > 2s)

**Line 2** (Prompt):
- Character prompt (❯) - green on success, red on error
- Supports vi-mode indicators (❮ for command mode)

### Right Prompt

Shows current time: `15:42:30`

### Continuation Prompt

For multi-line commands:
```bash
echo "hello \
❯❯ world"
```

## Theme Integration

The configuration automatically detects your ghostty theme on shell startup and applies the matching Catppuccin palette.

### Supported Themes

- **Catppuccin Latte** (light) - `catppuccin_latte`
- **Catppuccin Frappé** - `catppuccin_frappe`
- **Catppuccin Macchiato** - `catppuccin_macchiato`
- **Catppuccin Mocha** (dark) - `catppuccin_mocha`

### Theme Commands

```bash
# Auto-detect from ghostty config
prompt-theme-auto

# Manually set light theme
prompt-theme-light

# Manually set dark theme
prompt-theme-dark

# Check current configuration
prompt-status
```

## Prompt Mode Switching

Switch between different prompt configurations for different workflows:

```bash
# Minimal - just the prompt character
prompt-mode-minimal
# Output: ❯

# Standard - git branch + character (default transient)
prompt-mode-standard
# Output:  main ❯

# Kubernetes - shows k8s context
prompt-mode-kube
# Output: 󱃾 production (default)  main ❯

# Container - shows docker/podman context
prompt-mode-container
# Output:  myapp  main ❯

# Full - directory + git info
prompt-mode-full
# Output: ~/dotfiles  main !1 ?2 ❯
```

These modes control what information is displayed in transient prompts (old command prompts after execution).

## Configured Modules

### Version Control
- **Git Branch**: Shows current branch and remote
- **Git Status**: Modified, staged, untracked, stashed files with counts
- **Git State**: Shows rebase, merge, cherry-pick operations

### Languages & Runtimes
- **Python** () - Shows version and virtual environment
- **Rust** () - Shows rustc version
- **C** () - Shows gcc/clang version

### Container & Orchestration
- **Docker/Podman** () - Shows active context
- **Kubernetes** (󱃾) - Shows context and namespace
  - Detects k8s directories and files
  - Context aliases configurable in `starship.toml`

### System Info
- **SSH** - Shows hostname when connected remotely
- **Command Duration** (󱦟) - Shows runtime for commands > 2s
- **Time** - Current time (right prompt)

### Directory
- Truncates to 4 levels
- Repo-aware (shows from git root)
- Read-only indicator (󰌾)

## File Locations

- **Main config**: `shell/.config/starship.toml`
- **ZSH integration**: `shell/.config/omz-custom/starship.zsh`
- **Ghostty config**: `terminal/.config/ghostty/config`

## Customization

### Adding New Modules

Edit `shell/.config/starship.toml`:

1. Add module to the `format` string (Line 22-36)
2. Configure module settings in the Modules section
3. Reload with `prompt-reload`

### Changing Colors

The color palettes are defined at the bottom of `starship.toml`. Each palette includes:
- Base colors (background, foreground)
- UI colors (surface, overlay, crust, mantle)
- Accent colors (red, green, blue, yellow, etc.)
- Catppuccin colors (mauve, peach, lavender, etc.)

### Performance Tuning

If modules are slow (especially kubernetes):

```toml
# In starship.toml
command_timeout = 500  # Reduce from 1000ms

[kubernetes]
disabled = true  # Disable entirely
```

Or use `prompt-mode-minimal` to reduce overhead.

## Tips & Tricks

### Quick Theme Switching

Add to your `local.zsh`:
```bash
alias dark='prompt-theme-dark'
alias light='prompt-theme-light'
```

### Project-Specific Prompts

In a kubernetes project, automatically use kube mode:
```bash
# In project .zshrc or .envrc
prompt-mode-kube
```

### Disable Transient Prompts

```bash
export STARSHIP_USE_TRANSIENT=0
prompt-reload
```

### Show All Available Commands

```bash
prompt-status
```

## Troubleshooting

### Prompt not updating after theme change
```bash
prompt-reload
```

### Colors look wrong
1. Check ghostty theme: `cat ~/.config/ghostty/config | grep theme`
2. Check starship palette: `echo $STARSHIP_PALETTE`
3. Re-detect theme: `prompt-theme-auto`

### Modules not showing
Some modules only appear when relevant files are detected:
- Python: requires `.py` files or `requirements.txt`
- Rust: requires `Cargo.toml`
- Kubernetes: requires `k8s/` directory or k8s-related files

### Performance issues
```bash
# Disable kubernetes module (slowest)
# Edit starship.toml: kubernetes.disabled = true

# Or use minimal mode
prompt-mode-minimal
```

## Integration with Existing Tools

### Works with
- Oh-My-Zsh plugins (git, docker, kubectl)
- zsh-autosuggestions
- zsh-syntax-highlighting
- fzf (Ctrl-R history search)
- Vi-mode (shows vi state in character)

### Ghostty Integration
The configuration reads `terminal/.config/ghostty/config` to detect:
- Active theme name
- Maps to corresponding Catppuccin palette

When you change the ghostty theme:
1. Update `theme = ...` in ghostty config
2. Restart terminal OR run `prompt-theme-auto`

## Advanced Configuration

### Custom Transient Format

Set your own transient format:
```bash
export STARSHIP_TRANSIENT_FORMAT='$directory$git_branch$character'
```

### Kubernetes Context Aliases

Edit `starship.toml`:
```toml
[kubernetes.context_aliases]
"dev.local.cluster.k8s" = "dev"
"prod.local.cluster.k8s" = "prod"
"staging-.*" = "stage"
```

### Git Status Symbols

Customize in `starship.toml`:
```toml
[git_status]
ahead = "⇡${count} "
behind = "⇣${count} "
diverged = "⇕⇡${ahead_count}⇣${behind_count} "
modified = "!${count} "
# etc...
```

## Contributing

To modify the configuration:

1. Edit files in `shell/.config/`
2. Test changes: `prompt-reload`
3. Commit with descriptive message
4. Share improvements!

## Resources

- [Starship Documentation](https://starship.rs)
- [Catppuccin Theme](https://github.com/catppuccin)
- [Nerd Fonts](https://www.nerdfonts.com/) (required for icons)
- [Ghostty Terminal](https://ghostty.org)
