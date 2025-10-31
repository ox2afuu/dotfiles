# Starship + Ghostty Integration Guide

This document explains how the starship prompt configuration integrates with ghostty's color system.

## Philosophy

**Ghostty owns the color palette.** All tools (starship, bat, delta, fzf, etc.) should respect the terminal colors set by ghostty rather than defining their own hardcoded themes.

## How It Works

### 1. Ghostty Exports Colors

On shell startup, `options.zsh` exports ghostty's color palette:

```zsh
[[ -z $COLORFGBG ]] && {
    export COLORFGBG='15;0'
    ghostty +list-colors | sed -n 's/\([^ ]*\) \(#\)/\1 \2/p' > ~/.cache/ghostty-palette
}
```

This creates `~/.cache/ghostty-palette` with entries like:
```
color0 #1e1e2e
color1 #f38ba8
color2 #a6e3a1
...
background #1e1e2e
foreground #cdd6f4
```

### 2. Starship Uses ANSI Colors by Default

The starship configuration uses **ANSI color names** (red, green, blue, cyan, etc.) instead of hardcoded hex values. These automatically map to whatever colors ghostty defines.

Example:
```toml
[git_branch]
style = "bold magenta"  # Uses terminal's magenta (color5)

[directory]
style = "bold cyan"     # Uses terminal's cyan (color6)
```

This means:
- Change ghostty theme → starship colors change automatically
- No manual sync needed for basic usage
- Works with any ghostty theme

### 3. Optional: Exact Hex Value Sync

For precise control, run `sync-ghostty-colors` to generate a `[palettes.ghostty]` section with exact hex values from your current ghostty theme.

```bash
sync-ghostty-colors
```

This:
1. Reads `~/.cache/ghostty-palette`
2. Generates `[palettes.ghostty]` section in `starship.toml`
3. Sets `palette = "ghostty"` to use these exact colors

## Configuration Changes Made

### Prompt Format

**Before:**
```toml
format = """
[╭─](surface0)\
$username\
$hostname\
$directory\
...
[╰─](surface0)$character"""

continuation_prompt = "[❯❯](bold peach) "
```

**After:**
```toml
format = """
$username\
$hostname\
$directory\
...
$character"""

continuation_prompt = "[❯❯](bold cyan) "
```

Changes:
- ✓ Removed `╭─` and `╰─` decorators (clean, minimalist)
- ✓ Changed continuation prompt from peach (reddish) to cyan (neutral)
- ✓ Maintained two-line layout

### Color System

**Before:**
- Hardcoded Catppuccin palettes (Latte, Frappé, Macchiato, Mocha)
- `palette = "catppuccin_macchiato"` forced a specific theme
- Custom theme detection tried to map ghostty → Catppuccin

**After:**
- No palette set by default = uses ANSI colors
- ANSI color names throughout (red, green, blue, cyan, magenta, yellow, bright_black, etc.)
- Catppuccin palettes kept as commented reference for manual use
- Optional `sync-ghostty-colors` for exact hex control

### Module Style Updates

All modules updated to use ANSI colors:

| Module | Old Style | New Style |
|--------|-----------|-----------|
| directory | `bold lavender` | `bold cyan` |
| git_branch | `bold mauve` | `bold magenta` |
| time | `bold subtext0` | `bold bright_black` |
| character (vim) | `bold subtext1` | `bold bright_black` |
| character (replace) | `bold peach` | `bold yellow` |
| character (visual) | `bold mauve` | `bold magenta` |

## Available Commands

### sync-ghostty-colors

Syncs exact hex values from ghostty to starship config.

```bash
sync-ghostty-colors
```

Output:
```
Syncing ghostty colors to starship...
Removed old ghostty palette section
✓ Ghostty colors synced to starship
✓ Palette set to 'ghostty'

Colors imported:
  ANSI: color0-color15
  Background: #1e1e2e
  Foreground: #cdd6f4

Reload your prompt to see changes: prompt-reload
```

When to use:
- You want exact hex precision
- You're using a custom ghostty theme with specific color tweaks
- You prefer explicit color definitions

### prompt-reload

Reloads the starship prompt after config changes.

```bash
prompt-reload
```

### prompt-status

Shows current starship configuration.

```bash
prompt-status
```

Output:
```
Current Starship Configuration:
  Using ANSI colors (respects ghostty theme)
  Transient format: $git_branch$character

Available commands:
  sync-ghostty-colors  - Sync exact hex values from ghostty
  Mode:  prompt-mode-{minimal,standard,kube,container,full}
  Other: prompt-reload, prompt-status

By default, starship uses ANSI color names that automatically
map to your ghostty theme. Run sync-ghostty-colors for exact
hex value control.
```

### Prompt Mode Functions

These control transient prompt content (unchanged from before):

```bash
prompt-mode-minimal      # Just ❯
prompt-mode-standard     # git + character
prompt-mode-kube         # kubernetes + git + character
prompt-mode-container    # docker + git + character
prompt-mode-full         # directory + git + character
```

## Workflow Examples

### Scenario 1: Using Default ANSI Colors (Recommended)

1. Set ghostty theme in `~/.config/ghostty/config`:
   ```
   theme = catppuccin-mocha
   ```

2. Restart terminal or reload shell
3. Starship automatically uses the new colors
4. Done! No manual intervention needed.

### Scenario 2: Using Exact Hex Values

1. Set ghostty theme
2. Run `sync-ghostty-colors`
3. Run `prompt-reload`
4. Starship now uses exact hex values from ghostty

Repeat whenever you change ghostty theme.

### Scenario 3: Trying Different Ghostty Themes

1. Edit `~/.config/ghostty/config`
2. Change `theme = ...` line
3. Reload terminal
4. All tools (starship, bat, fzf, etc.) update automatically

## Technical Details

### Why ANSI Colors Work

Terminal emulators (including ghostty) define 16 ANSI colors (0-15):
- 0-7: Normal colors (black, red, green, yellow, blue, magenta, cyan, white)
- 8-15: Bright variants

When starship uses `style = "bold cyan"`, it references color6 (ANSI cyan), which ghostty defines. Different themes define different hex values for color6, so the same starship config looks different in different themes.

### Color Mapping

```
ANSI Name          Ghostty Color   Example Hex
─────────────────  ──────────────  ───────────
black              color0          #1e1e2e
red                color1          #f38ba8
green              color2          #a6e3a1
yellow             color3          #f9e2af
blue               color4          #89b4fa
magenta            color5          #cba6f7
cyan               color6          #94e2d5
white              color7          #cdd6f4
bright_black       color8          #45475a
bright_red         color9          #f38ba8
bright_green       color10         #a6e3a1
bright_yellow      color11         #f9e2af
bright_blue        color12         #89b4fa
bright_magenta     color13         #cba6f7
bright_cyan        color14         #94e2d5
bright_white       color15         #ffffff
```

### `sync-ghostty-colors` Implementation

The function:
1. Parses `~/.cache/ghostty-palette`
2. Extracts all color0-15, background, foreground
3. Generates TOML with proper escaping
4. Removes old `[palettes.ghostty]` section (marked by comment)
5. Appends new palette
6. Updates `palette = "ghostty"` line

## Troubleshooting

### Colors don't match ghostty theme

**If using ANSI colors (default):**
1. Check `~/.cache/ghostty-palette` exists
2. Verify `COLORFGBG` is set: `echo $COLORFGBG`
3. Restart shell to regenerate palette

**If using synced hex colors:**
1. Run `sync-ghostty-colors` again
2. Run `prompt-reload`

### Prompt looks wrong after theme change

**ANSI mode:** Just reload terminal (colors should update automatically)

**Synced mode:** Re-run `sync-ghostty-colors`

### Red colors appear in non-error contexts

Check `continuation_prompt` is using cyan:
```bash
grep continuation_prompt ~/.config/starship.toml
```

Should show: `continuation_prompt = "[❯❯](bold cyan) "`

### Decorators (╭─ ╰─) still showing

Old config is cached. Run:
```bash
starship print-config | head -20
```

If decorators appear, check which config is being used:
```bash
ls -la ~/.config/starship.toml
```

Should be a symlink to dotfiles, or you need to `stow shell` from dotfiles directory.

## Integration with Other Tools

The same principle applies to other tools:

### bat (syntax highlighting)
```bash
export BAT_THEME="ansi"  # Use terminal colors
```

### delta (git diff)
```toml
[delta]
syntax-theme = "ansi"
```

### fzf (fuzzy finder)
```bash
# Default color scheme uses terminal colors
export FZF_DEFAULT_OPTS="--color=16"
```

### ls (via eza/exa)
Uses terminal colors by default

## Files Modified

- `shell/.config/starship.toml` - Main configuration
- `shell/.config/omz-custom/starship.zsh` - Shell integration
- `shell/.config/omz-custom/options.zsh` - Already had ghostty palette export (unchanged)

## Summary

This configuration makes ghostty the **single source of truth** for colors. Change your ghostty theme once, and all terminal tools update automatically. This is the Unix philosophy: tools should cooperate and avoid reinventing the wheel.

Optional sync function provides hex-level control when needed, but ANSI colors work great for 99% of use cases.
