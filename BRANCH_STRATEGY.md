# Branch Strategy - Git-Flow Light

This document defines the branch strategy and workflow for this repository.

## Branch Structure

```
┌──────────────────────────────────────────────────────────────┐
│                        Feature Branches                       │
│                    (feature/*, bugfix/*)                      │
└────────────────────────────┬─────────────────────────────────┘
                             │ PR + Review
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                          dev                                  │
│  - Integration branch                                         │
│  - Feature branches merge here first                          │
│  - Continuous integration testing                             │
│  - Tag: 'dev' (floating)                                      │
└────────────────────────────┬─────────────────────────────────┘
                             │ PR + Testing
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                        nightly                                │
│  - Staging/Pre-production branch                              │
│  - Extended testing and validation                            │
│  - All CI/CD checks must pass                                 │
│  - Tag: 'nightly' (floating)                                  │
└────────────────────────────┬─────────────────────────────────┘
                             │ Auto-PR when all checks pass
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                        stable                                 │
│  - Production branch                                          │
│  - Deploys to GitHub Pages                                    │
│  - Tags: 'stable' (floating), 'v1.2.3' (version), 'latest'   │
└──────────────────────────────────────────────────────────────┘
```

## Branch Purposes

### `dev` - Development/Integration
- **Purpose**: Integration branch for active development
- **Protected**: Yes (require signed commits)
- **CI/CD**: Runs all tests, linting, security scans
- **Who merges**: Developers via PR
- **When to use**: Merge feature branches here first

### `nightly` - Staging/Pre-production
- **Purpose**: Testing and validation before production
- **Protected**: Yes (require PR + status checks + signed commits)
- **CI/CD**: Full test suite + extended validation
- **Who merges**: Maintainers after dev testing
- **When to use**: Promote from dev after manual testing

### `stable` - Production
- **Purpose**: Production-ready code, deployed to GitHub Pages
- **Protected**: Yes (require PR + reviews + status checks + signed commits)
- **CI/CD**: All checks + deployment
- **Who merges**: Auto-PR from GitHub Actions, manual merge by maintainer
- **When to use**: Only merge from nightly when all checks pass

## Workflow

### 1. Feature Development

```bash
# Start from dev
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b feature/my-awesome-feature

# Make changes, test locally
# ... work work work ...

# Install pre-commit hooks (if not already)
pre-commit install

# Commit (GPG signed automatically if configured)
git add .
git commit -m "feat(shell): add awesome feature"

# Push and create PR to dev
git push -u origin feature/my-awesome-feature
gh pr create --base dev --title "feat: add awesome feature"
```

### 2. Dev → Nightly Promotion

After feature is tested on `dev`:

```bash
# Create PR from dev to nightly
gh pr create --base nightly --head dev --title "Promote dev to nightly"

# Or manually
git checkout nightly
git pull origin nightly
git merge --no-ff dev -m "Merge dev into nightly for testing"
git push origin nightly
```

### 3. Nightly → Stable (Automatic)

When all CI/CD checks pass on `nightly`, GitHub Actions automatically:
1. Checks status of all workflows on nightly
2. Creates PR from nightly → stable
3. Adds PR with recent changes and checklist
4. Assigns to repository owner

**Manual steps**:
1. Review the auto-created PR
2. Verify all checks are green
3. Merge the PR
4. GitHub Actions will:
   - Update `stable` tag
   - Create version tag (v1.2.3)
   - Create GitHub release with changelog
   - Deploy documentation to GitHub Pages

## Branch Protection Rules

### For `stable` branch:

```yaml
Protection rules:
  - Require pull request before merging
    - Require approvals: 1
    - Dismiss stale reviews: true
  - Require status checks to pass before merging
    - Require branches to be up to date: true
    - Required checks:
      - Tests / lint
      - Tests / integration-tests
      - Tests / container-tests
      - Super-Linter
      - CodeQL Security Scanning
  - Require signed commits: true
  - Require linear history: false (allow merge commits)
  - Include administrators: true (no bypass)
  - Allow force pushes: false
  - Allow deletions: false
```

### For `nightly` branch:

```yaml
Protection rules:
  - Require pull request before merging
    - Require approvals: 0 (optional)
  - Require status checks to pass before merging
    - Require branches to be up to date: true
    - Required checks:
      - Tests / lint
      - Tests / integration-tests
      - Super-Linter
      - CodeQL Security Scanning
  - Require signed commits: true
  - Include administrators: true
  - Allow force pushes: false
  - Allow deletions: false
```

### For `dev` branch:

```yaml
Protection rules:
  - Require pull request before merging: false (direct push allowed)
  - Require status checks to pass before merging
    - Require branches to be up to date: false
    - Required checks:
      - Tests / lint (recommended)
  - Require signed commits: true
  - Include administrators: true
  - Allow force pushes: false
  - Allow deletions: false
```

## Tag Strategy

### Environment Tags (Floating)
Updated automatically on every push to the branch:
- `dev` → latest commit on dev branch
- `nightly` → latest commit on nightly branch
- `stable` → latest commit on stable branch

**Purpose**: Quick checkout of latest environment state
```bash
git checkout dev      # or
git checkout tags/dev
```

### Version Tags (Fixed)
Created only on stable branch merges:
- Format: `v<major>.<minor>.<patch>`
- Examples: `v1.0.0`, `v1.2.3`, `v2.0.0`
- Follows semantic versioning
- Created automatically based on commit messages

**Version bump logic**:
- **Major**: Breaking changes (`feat!:` or `BREAKING CHANGE:`)
- **Minor**: New features (`feat:`)
- **Patch**: Bug fixes, refactoring, docs (`fix:`, `refactor:`, `docs:`)

### Latest Tag (Floating)
Always points to the most recent version tag:
- `latest` → same as most recent `v*.*.*`

**Purpose**: Easy reference to current production version
```bash
git clone --branch latest https://github.com/ox2afuu/dotfiles.git
```

## Common Scenarios

### Hotfix to Production

For urgent fixes that can't wait for normal flow:

```bash
# Create hotfix branch from stable
git checkout stable
git checkout -b hotfix/critical-bug

# Fix the issue
# ... make changes ...

# Commit
git commit -m "fix: resolve critical bug"

# Create PR directly to stable (emergency only)
gh pr create --base stable --title "hotfix: critical bug"

# After merge, backport to nightly and dev
git checkout nightly
git cherry-pick <hotfix-commit>
git push origin nightly

git checkout dev
git cherry-pick <hotfix-commit>
git push origin dev
```

### Rolling Back a Release

If a release has issues:

```bash
# Option 1: Revert the merge commit
git checkout stable
git revert -m 1 <merge-commit-hash>
git push origin stable

# Option 2: Reset to previous version (dangerous)
git checkout stable
git reset --hard v1.2.2  # previous good version
git push --force origin stable  # requires removing protection temporarily
```

### Cherry-picking Features

To move specific commits between branches:

```bash
# Cherry-pick a commit from dev to nightly
git checkout nightly
git cherry-pick <commit-hash>
git push origin nightly
```

## Environment-Specific Configuration

Some configurations may differ per environment. Use branch-specific configs:

```bash
# .github/workflows/test.yml
on:
  push:
    branches: [stable, nightly, dev]

jobs:
  test:
    steps:
      - name: Set environment
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/stable" ]]; then
            echo "ENV=production" >> $GITHUB_ENV
          elif [[ "${{ github.ref }}" == "refs/heads/nightly" ]]; then
            echo "ENV=staging" >> $GITHUB_ENV
          else
            echo "ENV=development" >> $GITHUB_ENV
          fi
```

## Monitoring and Badges

The README displays real-time status for each environment:

```markdown
[![Stable](https://img.shields.io/github/actions/workflow/status/ox2a-fuu/dotfiles/test.yml?branch=stable)](...)
[![Nightly](https://img.shields.io/github/actions/workflow/status/ox2a-fuu/dotfiles/test.yml?branch=nightly)](...)
[![Dev](https://img.shields.io/github/actions/workflow/status/ox2a-fuu/dotfiles/test.yml?branch=dev)](...)
```

## Best Practices

1. **Always work from feature branches**: Never commit directly to dev, nightly, or stable
2. **Keep commits atomic**: One logical change per commit
3. **Use conventional commits**: Enables automatic versioning
4. **Sign all commits**: Required by branch protection
5. **Run pre-commit hooks**: Catches issues before CI/CD
6. **Test locally**: Use `./tests/lint.sh` and `./tests/integration-tests.sh`
7. **Update documentation**: Keep docs in sync with code changes
8. **Write descriptive PR descriptions**: Helps reviewers and generates better changelogs

## Troubleshooting

### Protected Branch Update Failed

Error: `remote: error: GH006: Protected branch update failed`

- You tried to push directly to a protected branch
- Solution: Create a PR instead

### Commit Signature Verification Failed

Error: `Commit signature verification failed`

- Commits must be GPG signed
- Solution: Follow GPG setup in contributing guide

### Required Status Check Not Found

Error: `Required status check not found`
- A required CI check hasn't run yet
- Solution: Wait for all checks to complete or trigger manually

### Branch Out of Date

Error: `Can't merge - branch is out of date`

- Your branch is behind the base branch
- Solution: `git pull origin <base-branch>` and resolve conflicts

## Resources

- [GitHub Branch Protection Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GPG Signing Guide](./docs/src/contributing.md#gpg-commit-signing-required)
