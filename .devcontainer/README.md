# Devcontainer for Dotfiles Testing

This devcontainer uses **Podman** (not Docker) for rootless, daemonless container testing.

## Why Podman?

- **FOSS:** Apache-2.0 license with no corporate restrictions
- **Daemonless:** No background daemon required - more secure, lighter weight
- **Rootless:** Containers run as non-root by default (UID 1000)
- **Compatible:** Drop-in Docker replacement when needed
- **Secure:** Better security model with no privilege escalation

## Container Details

- **Base Image:** Alpine Linux (minimal footprint)
- **User:** testuser (UID 1000, non-root)
- **Shell:** zsh (default)
- **Mount:** `~/dotfiles` → `/home/testuser/dotfiles`
- **Tools Installed:**
  - git, stow, zsh, bash, starship
  - neovim, curl, wget
  - shellcheck (for linting)
  - python3 (for test scripts)

## Usage

### Start Container

```bash
# From dotfiles directory
devcontainer up --workspace-folder ~/dotfiles
```

The first run will build the container image, subsequent runs are instant.

### Execute Commands in Container

```bash
# Get a shell
devcontainer exec --workspace-folder ~/dotfiles zsh

# Run specific command
devcontainer exec --workspace-folder ~/dotfiles --   ./tests/lint.sh
```

### Testing Workflows

#### Bootstrap Test (Fresh Install)

Tests that a fresh user can install and use the dotfiles:

```bash
./scripts/test-in-container.sh bootstrap
```

This will:
1. Start the container
2. Run `stow */` to install all packages
3. Verify shell, starship, and other tools work
4. Run linting and integration tests

#### Local Override Test

Tests that your personal `local.zsh` overrides work correctly:

```bash
./scripts/test-in-container.sh local
```

This will:
1. Start the container
2. Copy your `~/.config/omz-custom/local.zsh` into the container
3. Test that personal overrides load correctly
4. Run tests with your customizations

#### Cleanup

Remove the container when done:

```bash
./scripts/test-in-container.sh clean
```

## Manual Testing

### Interactive Shell

```bash
# Start container
devcontainer up --workspace-folder ~/dotfiles

# Get shell
devcontainer exec --workspace-folder ~/dotfiles zsh

# Inside container, test dotfiles
cd /home/testuser/dotfiles
stow shell
source ~/.zshrc
starship --version
```

### Test Specific Package

```bash
# In container
cd /home/testuser/dotfiles
stow shell         # Install shell config
stow git           # Install git config
stow editors       # Install editor configs
```

### Run Tests

```bash
# In container
cd /home/testuser/dotfiles
./tests/lint.sh                # Lint all scripts
./tests/integration-tests.sh   # Test package conflicts
./tests/test-snippets.sh       # Test doc snippets
```

## How It Works

### Bind Mount

Your local `~/dotfiles` directory is mounted into the container at `/home/testuser/dotfiles`:

```
Host: /Users/ox2a.fuu/dotfiles/shell/.zshrc
  ↓ (bind mount)
Container: /home/testuser/dotfiles/shell/.zshrc
```

Changes made locally are immediately visible in the container.

### Rootless Security

The container runs as `testuser` (UID 1000), not root:

- Processes in container cannot escalate privileges
- File permissions are preserved
- Matches typical user setup
- More secure than root containers

### Podman vs Docker

This setup is Podman-specific but compatible with Docker:

| Feature | Podman | Docker |
|---------|---------|--------|
| Daemon | No | Yes (dockerd) |
| Rootless | Default | Optional |
| License | Apache-2.0 | Mixed |
| Security | User namespaces | Daemon-based |
| Systemd | Native support | Limited |

devcontainer CLI works with both, auto-detecting which is available.

## Troubleshooting

### Podman Installation

**Official Installation (Recommended):**

Podman should be installed using the official installers, NOT Homebrew (per Podman team's recommendation due to hardcoded paths).

1. **Install Podman CLI** (v5.6.2 or later):
   - Download: https://github.com/containers/podman/releases
   - macOS ARM64: `podman-installer-macos-arm64.pkg`
   - macOS Intel: `podman-installer-macos-amd64.pkg`
   - Run the installer

2. **Install Podman Desktop** (optional GUI):
   - Download: https://podman-desktop.io/downloads/macOS
   - Install to Applications folder

3. **Initialize Podman machine**:
   ```bash
   podman machine init
   podman machine start
   podman info  # Verify installation
   ```

4. **Set up Docker compatibility**:
   ```bash
   sudo podman-mac-helper install
   # This creates /usr/local/bin/docker -> /opt/podman/bin/podman
   # Allows devcontainer CLI to work seamlessly
   ```

**Why Not Homebrew?**
The Podman team does not recommend Homebrew installation due to cross-platform path inconsistencies. The official `.pkg` installers use hardcoded paths (`/opt/podman/bin`) that ensure proper integration.

### Podman Not Found

If devcontainer can't find Podman after installation:

```bash
# Verify Podman is installed
ls -la /opt/podman/bin/podman

# Check if in PATH (should be automatic after .pkg install)
which podman || export PATH="/opt/podman/bin:$PATH"

# Verify Docker compatibility symlink
ls -la /usr/local/bin/docker
# Should point to: /opt/podman/bin/podman

# Restart shell if needed
exec zsh
```

### Container Build Fails

```bash
# Clean up and rebuild
./scripts/test-in-container.sh clean
rm -rf .devcontainer/.docker-cache
devcontainer up --workspace-folder ~/dotfiles --force-rebuild
```

### Permission Errors

The container runs as UID 1000. If you see permission errors:

```bash
# Check your UID
id -u  # Should be 501 or similar

# Files are accessible via bind mount regardless of UID mismatch
```

### Slow Performance

If container is slow:

1. Check Podman machine resources:
   ```bash
   podman machine inspect podman-machine-default
   ```

2. Increase resources if needed:
   ```bash
   podman machine stop
   podman machine set --cpus 8 --memory 8192
   podman machine start
   ```

## CI/CD Integration

The same container is used in GitHub Actions for consistent testing:

See `.github/workflows/test.yml` for the Podman-based CI workflow.

## Future Enhancements

- Custom Podman MCP server for direct container interaction
- Multi-arch support (arm64 + amd64)
- Caching for faster builds
- Additional test scenarios

## Resources

- [Podman Documentation](https://docs.podman.io/)
- [devcontainer CLI](https://github.com/devcontainers/cli)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
