# Contributing

Thank you for considering contributing to this dotfiles repository!

## Getting Started

### Prerequisites

- Git installed
- Basic knowledge of shell scripting
- Understanding of GNU Stow (see [Stow Guide](./guides/stow.md))

### Setup Development Environment

```bash
# Fork and clone
git clone https://github.com/your-username/dotfiles.git ~/dotfiles-dev
cd ~/dotfiles-dev

# Add upstream remote
git remote add upstream https://github.com/ox2a-fuu/dotfiles.git

# Install mdBook for docs
cargo install mdbook mdbook-linkcheck2

# Install testing tools
brew install shellcheck shfmt stow

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# (Optional) Run pre-commit on all files to verify setup
pre-commit run --all-files
```

**What pre-commit hooks do**:
- Run shellcheck on shell scripts
- Check for spelling errors with typos and codespell
- Validate YAML, Markdown, and TOML files
- Run project lint tests automatically before each commit
- Prevent common mistakes from reaching CI/CD

This catches errors locally before they reach GitHub Actions, saving time and CI/CD minutes.

## Making Changes

### 1. Create a Feature Branch

```bash
git checkout dev
git pull upstream dev
git checkout -b feature/my-improvement
```

### 2. Make Your Changes

Follow the structure:

```
dotfiles/
├── <package>/
│   └── .config/
│       └── your-config
├── docs/src/
│   └── packages/<package>.md
└── tests/
    └── test-your-feature.sh
```

### 3. Test Your Changes

```bash
# Lint shell scripts
./tests/lint.sh

# Test documentation
cd docs && mdbook test

# Integration tests
./tests/integration-tests.sh
```

### 4. Update Documentation

Document your changes in:

- Relevant package docs (`docs/src/packages/`)
- Update guides if needed
- Add examples

### 5. Commit Your Changes

Use [conventional commits](https://www.conventionalcommits.org/):

```bash
git add -A
git commit -m "feat(shell): add new zsh aliases

- Add git shortcuts
- Add docker shortcuts
- Update aliases.zsh documentation"
```

**Commit Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting changes
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

#### GPG Commit Signing (Required)

All commits to this repository **must** be signed with a GPG key. This is enforced by branch protection rules.

**First-time setup**:

```bash
# 1. Check if you have a GPG key
gpg --list-secret-keys --keyid-format=long

# 2. If no keys exist, generate one
gpg --full-generate-key
# Choose: RSA and RSA, 4096 bits, no expiration (or your preference)
# Enter your name and email (must match your GitHub email)

# 3. Get your GPG key ID
gpg --list-secret-keys --keyid-format=long
# Look for: sec   rsa4096/YOUR_KEY_ID 2024-01-01
# YOUR_KEY_ID is what you need (e.g., 3AA5C34371567BD2)

# 4. Configure Git to use GPG signing
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
git config --global gpg.program gpg

# 5. Export your public key for GitHub
gpg --armor --export YOUR_KEY_ID
# Copy the output (including BEGIN and END lines)
```

**Add GPG key to GitHub**:

1. Go to [GitHub GPG Keys Settings](https://github.com/settings/keys)
2. Click "New GPG key"
3. Paste your public key
4. Click "Add GPG key"

**Troubleshooting GPG**:

```bash
# If commits fail with "gpg: signing failed"
export GPG_TTY=$(tty)
echo 'export GPG_TTY=$(tty)' >> ~/.zshrc  # or ~/.bashrc

# If using macOS and gpg hangs
brew install pinentry-mac
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent

# Test GPG signing
echo "test" | gpg --clearsign
```

**Verify commits are signed**:

```bash
# Check if last commit is signed
git log --show-signature -1

# Sign an existing commit
git commit --amend --no-edit -S
```

**For 1Password users**:

If you store your GPG key in 1Password, configure the integration:

```bash
# Install 1Password CLI
brew install --cask 1password-cli

# Configure Git to use 1Password's GPG
git config --global gpg.program op-gpg-sign
```

### 6. Push and Create PR

```bash
git push origin feature/my-improvement
```

Then create a pull request on GitHub targeting the `dev` branch.

## Contribution Guidelines

### Code Style

#### Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Always use `set -euo pipefail`
- Quote all variables: `"${var}"`
- Use `[[ ]]` over `[ ]`
- Add comments for complex logic

```bash
#!/usr/bin/env bash
set -euo pipefail

# Good example
function install_package() {
    local package="${1}"

    if [[ -d "${package}" ]]; then
        stow "${package}"
        echo "✓ Installed ${package}"
    else
        echo "✗ Package ${package} not found" >&2
        return 1
    fi
}
```

#### Configuration Files

- Use consistent indentation (2 spaces for YAML/TOML)
- Add comments explaining non-obvious settings
- Group related settings together

#### Documentation

- Use clear, concise language
- Include code examples
- Add command output where helpful
- Link to related documentation

### Testing Requirements

All contributions must:

1. Pass shellcheck linting
2. Pass integration tests
3. Include documentation updates
4. Not break existing functionality

```bash
# Verify before PR
./tests/lint.sh && ./tests/test-snippets.sh && ./tests/integration-tests.sh
```

### Documentation Standards

#### Structure

Each package should have:

```markdown
# Package Name

Brief description

## Installation

## Configuration

## Usage

## Customization

## Troubleshooting
```

#### Code Examples

Always use code blocks with language tags:

````markdown
```bash
stow shell
```
````

#### Links

Use relative links for internal docs:

```markdown
See [Installation Guide](./installation.md)
```

## Review Process

### What Happens After PR

1. **Automated Tests** - GitHub Actions runs all tests (linting, integration, security)
2. **Code Review** - Maintainer reviews changes
3. **Documentation Check** - Ensure docs are updated
4. **Merge to dev** - Changes merged to development branch
5. **Promotion to nightly** - After testing, changes promoted to nightly branch
6. **Auto-promotion to stable** - When all CI/CD checks pass on nightly, GitHub Actions automatically creates PR to stable branch
7. **Final Review** - Manual review of stable promotion PR
8. **Deploy** - Merged to stable and documentation deployed

### Review Criteria

Reviewers check for:

- Code quality and style
- Test coverage
- Documentation completeness
- No breaking changes
- Follows project conventions

## Types of Contributions

### Bug Fixes

1. Create issue describing bug
2. Reference issue in commit: `fix: resolve #123`
3. Include steps to reproduce
4. Add test to prevent regression

### New Features

1. Discuss in issue first (for major features)
2. Update relevant documentation
3. Add tests
4. Follow existing patterns

### Documentation Improvements

1. Fix typos, improve clarity
2. Add examples
3. Update outdated information
4. Create new guides

### Performance Improvements

1. Benchmark before/after
2. Document findings in git-notes
3. Explain the optimization

## Getting Help

### Questions

- Open an issue with `question` label
- Check existing documentation first
- Be specific about your setup

### Reporting Bugs

Include:

- Operating system and version
- Steps to reproduce
- Expected vs actual behavior
- Error messages
- Configuration details

```markdown
## Bug Report

**OS**: macOS 14.2
**Shell**: zsh 5.9

**Steps to reproduce**:
1. `stow shell`
2. Open new terminal
3. Run `prompt-theme-auto`

**Expected**: Theme should auto-detect
**Actual**: Error message about missing file

**Error**:
```
./starship.zsh: line 42: no such file
```
```

### Feature Requests

Describe:

- Use case
- Proposed solution
- Alternatives considered
- Willing to implement?

## Development Tips

### Testing Locally

Use containers for safe testing:

```bash
docker run -it --rm -v $(pwd):/dotfiles alpine:latest /bin/sh
cd /dotfiles
apk add stow
stow shell
```

### Documentation Development

Live preview:

```bash
cd docs
mdbook serve --open
```

### Quick Feedback Loop

```bash
# Watch for changes and run tests
while true; do
    inotifywait -r -e modify .
    ./tests/lint.sh
done
```

## Code of Conduct

### Be Respectful

- Welcoming to newcomers
- Constructive feedback
- Professional communication

### Be Collaborative

- Share knowledge
- Help others learn
- Improve documentation

## Recognition

Contributors are recognized in:

- Git commit history
- Release notes
- Documentation contributors page (coming soon)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT).

## Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [shellcheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [mdBook Documentation](https://rust-lang.github.io/mdBook/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
