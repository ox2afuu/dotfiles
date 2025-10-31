# GNU Stow Usage

GNU Stow is a symlink manager that makes it easy to manage dotfiles.

## How Stow Works

Stow creates symlinks from your home directory to files in the dotfiles repository:

```
~/dotfiles/shell/.config/starship.toml
              ↓ (stow creates symlink)
~/.config/starship.toml
```

## Basic Commands

### Install a Package

```bash
cd ~/dotfiles
stow shell
```

This creates symlinks for all files in `shell/` to your home directory.

### Install Multiple Packages

```bash
stow shell git editors
```

### Install All Packages

```bash
stow */
```

### Remove a Package

```bash
stow -D shell
```

This removes all symlinks created by the shell package.

### Update After Changes

```bash
stow -R shell
```

The `-R` flag restows (removes and re-adds) the package.

## Directory Structure

Stow expects a specific structure:

```
dotfiles/
├── shell/          # Package name
│   ├── .zshrc      # Will link to ~/.zshrc
│   └── .config/    # Will link to ~/.config/
│       └── starship.toml
└── git/
    └── .gitconfig
```

Files and directories are linked relative to your home directory.

## Advanced Usage

### Dry Run

Preview what Stow will do:

```bash
stow -n shell
stow -nv shell  # Verbose output
```

### Target Directory

Change the target directory (default is parent of current directory):

```bash
stow -t /some/other/dir shell
```

### Ignore Patterns

Create `.stow-local-ignore` to exclude files:

```
# .stow-local-ignore
\.git
\.DS_Store
README\.md
```

## Troubleshooting

### Conflicts

If Stow reports conflicts:

```
WARNING! stowing shell would cause conflicts:
  * existing target is not owned by stow: .zshrc
```

**Solution**: Backup and remove the existing file:

```bash
mv ~/.zshrc ~/.zshrc.backup
stow shell
```

### Broken Symlinks

Remove broken symlinks:

```bash
find ~ -maxdepth 3 -type l ! -exec test -e {} \; -print
```

Then restow:

```bash
stow -R shell
```

### Wrong Links

If symlinks point to wrong locations, unstow and restow:

```bash
stow -D shell
stow shell
```

## Best Practices

### 1. Always Use Stow from Repo Root

```bash
cd ~/dotfiles  # Always run stow from here
stow shell
```

### 2. Test First

Use `-n` flag to preview:

```bash
stow -nv shell
```

### 3. Backup Before Major Changes

```bash
tar czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/.*rc ~/.config
```

### 4. Use Git

Track changes before major updates:

```bash
cd ~/dotfiles
git status
git add -A
git commit -m "Update shell config"
```

## Package Organization

### Good Package Structure

```
shell/
├── .zshrc
├── .bashrc
└── .config/
    ├── starship.toml
    └── omz-custom/
        └── *.zsh
```

### Multiple Config Files

Group related configs in one package:

```
editors/
├── .config/
│   ├── nvim/
│   │   └── init.lua
│   └── emacs/
│       └── init.el
```

## Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Stow GitHub](https://github.com/aspiers/stow)
