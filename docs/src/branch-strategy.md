# Branch Strategy

This repository uses a simple branching model optimized for personal dotfiles management.

## Branch Overview

### `main` (Stable)

- Production-ready configurations
- All tests pass
- Documentation is up-to-date
- Tagged as `stable`
- **Safe to use on primary machines**

### `test/docs` (Nightly)

- Testing ground for new features
- Documentation updates happen here
- CI/CD tests run automatically
- Tagged as `nightly`
- **Mostly stable, suitable for testing**

### `dev` (Development)

- Active development
- Experimental features
- No stability guarantees
- Breaking changes possible
- **Use at your own risk**

## Workflow

### Making Changes

```
feature branch → dev → test/docs → main
```

1. **Create feature branch** from `dev`
   ```bash
   git checkout dev
   git pull
   git checkout -b feature/my-new-config
   ```

2. **Develop and test locally**
   ```bash
   # Make changes
   vim shell/.config/starship.toml

   # Test locally
   stow -R shell

   # Commit
   git add -A
   git commit -m "Add new starship module"
   ```

3. **Merge to dev**
   ```bash
   git checkout dev
   git merge feature/my-new-config
   git push origin dev
   ```

4. **Test in test/docs**
   ```bash
   git checkout test/docs
   git merge dev

   # Update documentation
   vim docs/src/guides/starship-config.md

   # Run tests
   ./tests/lint.sh
   ./tests/test-snippets.sh

   git add -A
   git commit -m "Update starship config and docs"
   git push origin test/docs
   ```

5. **Merge to main** (after tests pass)
   ```bash
   git checkout main
   git merge test/docs
   git push origin main
   ```

## Tagging Strategy

### No Semantic Versioning

This repo doesn't use semver (1.2.3) or calver (2025.01.15) since dotfiles are continuously updated.

### Simple Tags

- `stable` - Always points to latest main
- `nightly` - Points to tested configurations on test/docs
- `dev` - Latest development snapshot

### Creating Tags

```bash
# Update stable tag on main
git checkout main
git tag -f stable
git push -f origin stable

# Update nightly tag on test/docs
git checkout test/docs
git tag -f nightly
git push -f origin nightly
```

## Git Notes for Documentation

Use git-notes for detailed post-mortems and technical documentation:

```bash
# Add a note to current commit
git notes add -m "Detailed explanation of changes"

# Add note to specific commit
git notes add <commit-hash> -m "Post-mortem analysis"

# View notes
git log --show-notes

# Push notes to remote
git push origin refs/notes/*
```

### When to Use Git Notes

- Post-mortem analysis after fixing bugs
- Detailed technical explanations
- Rationale behind design decisions
- Troubleshooting steps that worked

### Example

```bash
git notes add -m "
## Starship Performance Fix

### Problem
Kubernetes module was causing 2s delay on every prompt.

### Investigation
- Used `starship timings` to profile
- K8s context detection was hitting API
- No caching enabled

### Solution
- Disabled K8s module in non-k8s directories
- Added detect_folders = ['k8s/', 'kubernetes/']
- Reduced timeout to 500ms

### Result
Prompt now renders in <100ms consistently.

### References
- starship.rs/config/#kubernetes
- Issue #123 in dotfiles repo
"
```

## CI/CD Integration

### Automated Tests

GitHub Actions runs tests on:
- All pushes to `dev`, `test/docs`, `main`
- All pull requests

### Documentation Deployment

- `main` branch deploys to GitHub Pages
- `test/docs` builds docs but doesn't deploy

## Best Practices

### 1. Always Test on test/docs First

Never merge directly to main:

```bash
# ❌ Bad
git checkout main
git merge dev

# ✅ Good
git checkout test/docs
git merge dev
# ... test and update docs ...
git checkout main
git merge test/docs
```

### 2. Update Documentation With Changes

When merging to test/docs, update relevant docs:

```bash
git checkout test/docs
git merge dev

# Update docs
vim docs/src/packages/shell.md

git add -A
git commit -m "feat: new shell aliases

Updated shell package with new git aliases.
Documented in shell.md package docs."
```

### 3. Use Meaningful Commit Messages

Follow conventional commits:

```bash
git commit -m "feat: add kubernetes support to starship"
git commit -m "fix: resolve zsh plugin loading order"
git commit -m "docs: update starship configuration guide"
git commit -m "test: add integration tests for stow"
```

### 4. Keep Branches in Sync

Regularly sync dev with main:

```bash
git checkout dev
git merge main
git push origin dev
```

## Emergency Rollback

If something breaks on main:

```bash
# Find last good commit
git log --oneline

# Create rollback branch
git checkout -b hotfix/rollback main
git revert <bad-commit-hash>

# Test
./tests/lint.sh

# Merge back
git checkout main
git merge hotfix/rollback
git push origin main
```

## Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Notes Documentation](https://git-scm.com/docs/git-notes)
