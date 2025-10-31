# Testing

This document describes the testing strategy for the dotfiles repository.

## Testing Philosophy

**Goal**: Ensure dotfiles work correctly and documentation remains accurate.

**Approach**: Automated testing for shell scripts, configuration files, and documentation snippets.

## Test Types

### 1. Shell Script Linting

**Tool**: shellcheck, shfmt

**What it tests**:
- Syntax errors in shell scripts
- Common scripting pitfalls
- Code style consistency

**Run locally**:
```bash
./tests/lint.sh
```

**Configuration**: `.shellcheckrc`

### 2. Configuration Validation

**Tools**: Various validators

**What it tests**:
- TOML files (starship.toml, etc.)
- YAML files (GitHub Actions, etc.)
- JSON files (various configs)

**Run locally**:
```bash
./tests/lint.sh
```

### 3. Documentation Testing

**Tool**: mdbook-linkcheck, custom scripts

**What it tests**:
- Broken links in documentation
- Code snippets are syntactically valid
- Shell commands in docs actually work

**Run locally**:
```bash
./tests/test-snippets.sh
```

### 4. Integration Testing

**Tool**: Custom test scripts + Docker

**What it tests**:
- Stow commands work correctly
- No file conflicts between packages
- Configs don't break each other

**Run locally**:
```bash
./tests/integration-tests.sh
```

## Running Tests

### All Tests

```bash
# From repo root
./tests/lint.sh && \
./tests/test-snippets.sh && \
./tests/integration-tests.sh
```

### Specific Test Suite

```bash
# Shell linting only
./tests/lint.sh

# Documentation snippets
./tests/test-snippets.sh

# Integration tests
./tests/integration-tests.sh
```

### In CI/CD

Tests run automatically on:
- Every push to `dev`, `test/docs`, `main`
- Every pull request
- Triggered by GitHub Actions workflows

## Test Scripts

### tests/lint.sh

Lints all shell scripts and config files:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Find and lint all shell scripts
find . -type f \( -name "*.sh" -o -name "*.zsh" -o -name "*.bash" \) \
  -not -path "*/\.git/*" \
  -exec shellcheck {} +

# Format check
shfmt -d .
```

### tests/test-snippets.sh

Extracts and tests code snippets from documentation:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Extract shell code blocks from markdown
# Run through shellcheck
# Optionally execute in container
```

### tests/integration-tests.sh

Tests stow functionality and package conflicts:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Test in clean Docker container
# Verify stow commands work
# Check for file conflicts
```

## Test Configuration

### .shellcheckrc

```bash
# Shellcheck configuration
disable=SC1090  # Can't follow non-constant source
disable=SC2034  # Unused variables (often false positives)

shell=bash
severity=warning
```

### .markdownlint.json

```json
{
  "default": true,
  "MD013": false,
  "MD033": false,
  "MD041": false
}
```

## Code Coverage

### What We Track

- Shell scripts covered by shellcheck
- Config files validated
- Documentation links checked
- Code snippets tested

### Viewing Coverage

```bash
# Run all tests with verbose output
./tests/lint.sh -v
./tests/test-snippets.sh -v
```

## Writing Tests

### Adding Shell Script Tests

1. Place scripts in appropriate directories
2. shellcheck will automatically find them
3. Follow shell best practices:
   - Use `set -euo pipefail`
   - Quote variables
   - Use `[[ ]]` over `[ ]`

### Adding Documentation Tests

1. Write code examples in markdown with language tags:
   ````markdown
   ```bash
   stow shell
   ```
   ````

2. Test script extracts and validates these automatically

### Adding Integration Tests

Add test cases to `tests/integration-tests.sh`:

```bash
test_stow_shell() {
    echo "Testing shell package stow..."
    stow shell
    [[ -L ~/.zshrc ]] || { echo "Failed: ~/.zshrc not a symlink"; exit 1; }
    stow -D shell
    echo "✓ Shell package test passed"
}
```

## CI/CD Pipeline

### Test Workflow (.github/workflows/test.yml)

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y shellcheck stow
      - name: Run linting
        run: ./tests/lint.sh
      - name: Test snippets
        run: ./tests/test-snippets.sh
      - name: Integration tests
        run: ./tests/integration-tests.sh
```

### Documentation Workflow (.github/workflows/docs.yml)

```yaml
name: Documentation

on:
  push:
    branches: [main, test/docs]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - name: Install mdBook
        run: cargo install mdbook mdbook-linkcheck
      - name: Build documentation
        run: mdbook build docs
      - name: Deploy to GitHub Pages
        if: github.ref == 'refs/heads/main'
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs/book
```

## Troubleshooting Tests

### shellcheck Errors

```bash
# View specific error details
shellcheck shell/.config/omz-custom/aliases.zsh

# Ignore specific rules
# SC1090: Can't follow non-constant source
# shellcheck disable=SC1090
source "${HOME}/.config/something"
```

### Documentation Link Errors

```bash
# Test docs locally
cd docs
mdbook build

# Check specific file
mdbook-linkcheck --standalone docs/src/guides/starship-config.md
```

### Integration Test Failures

```bash
# Run with verbose output
bash -x ./tests/integration-tests.sh

# Test individual packages
stow -nv shell  # Dry run with verbose output
```

## Best Practices

### 1. Test Before Commit

```bash
# Quick pre-commit check
./tests/lint.sh && echo "✓ Tests passed"
```

### 2. Write Testable Code

```bash
# ✅ Good - Testable
function stow_package() {
    local pkg="${1}"
    stow "${pkg}"
}

# ❌ Bad - Hard to test
stow shell && stow git && stow editors
```

### 3. Document Test Failures

When tests fail, add notes:

```bash
git notes add -m "
Test failure investigation:
- shellcheck complained about SC2086
- Fixed by adding quotes around variables
- All tests now pass
"
```

### 4. Keep Tests Fast

- Use parallel execution where possible
- Skip expensive tests in local development
- Run full suite in CI only

## Resources

- [shellcheck wiki](https://github.com/koalaman/shellcheck/wiki)
- [mdBook Testing](https://rust-lang.github.io/mdBook/cli/test.html)
- [GitHub Actions](https://docs.github.com/en/actions)
