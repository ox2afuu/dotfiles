# GitHub Repository Setup

This document describes the GitHub repository configuration for the dotfiles project, including branch protection rules, environments, actions, and workflows.

## Repository Settings

### General Settings

- **Repository name**: `dotfiles`
- **Description**: "Personal dotfiles configuration managed with GNU Stow"
- **Visibility**: Public (or Private, depending on your preference)
- **Issues**: Enabled
- **Discussions**: Optional
- **Wiki**: Disabled (using mdBook instead)
- **Projects**: Optional

### Branch Configuration

**Default Branch**: `main`

**Branch Protection Rules** should be configured for:
- `main` (production)
- `test/docs` (testing and documentation)
- `dev` (development)

## Branch Protection Rules

### Main Branch Protection

Navigate to: **Settings → Branches → Branch protection rules → Add rule**

**Branch name pattern**: `main`

**Protection settings**:

✅ **Require a pull request before merging**
- Require approvals: 1 (for personal repos, optional)
- Dismiss stale pull request approvals when new commits are pushed
- Require review from Code Owners (if using CODEOWNERS file)

✅ **Require status checks to pass before merging**
- Require branches to be up to date before merging
- **Required status checks**:
  - `lint` - Shell script and config linting
  - `snippet-tests` - Documentation snippet validation
  - `integration-tests` - Package conflict testing
  - `markdown-lint` - Markdown linting
  - `container-tests` - Pod man container bootstrap test
  - `test-summary` - Overall test summary

✅ **Require conversation resolution before merging**

✅ **Require signed commits** (optional, recommended for security)

✅ **Require linear history**
- Prevents merge commits, enforces rebase or squash merges

✅ **Do not allow bypassing the above settings**

❌ **Allow force pushes** (disabled)

❌ **Allow deletions** (disabled)

### Test/Docs Branch Protection

**Branch name pattern**: `test/docs`

**Protection settings**:

✅ **Require status checks to pass before merging**
- **Required status checks**:
  - `lint`
  - `snippet-tests`
  - `integration-tests`
  - `markdown-lint`
  - `container-tests`

✅ **Require conversation resolution before merging**

✅ **Allow force pushes** (enabled - for testing iterations)
- Specify who can force push: Repository admins only

### Dev Branch Protection

**Branch name pattern**: `dev`

**Protection settings**:

✅ **Require status checks to pass before merging**
- **Required status checks**:
  - `lint` (basic linting only)

✅ **Allow force pushes** (enabled)
- Specify who can force push: Repository admins only

## GitHub Actions Configuration

### Workflow Files

Located in `.github/workflows/`:

1. **test.yml** - Runs on all branches (main, test/docs, dev)
   - Lint tests
   - Snippet tests
   - Integration tests
   - Markdown linting
   - Container tests
   - Test summary

2. **docs.yml** - Builds and deploys documentation
   - Builds on: `main`, `test/docs` branches
   - Deploys to GitHub Pages: `main` branch only
   - Build verification only: `test/docs` branch

### Secrets and Variables

Navigate to: **Settings → Secrets and variables → Actions**

**Repository Secrets** (if needed):
- None required for basic setup
- Add `GITHUB_TOKEN` if custom permissions needed (auto-provided by default)

**Repository Variables**:
- None required for basic setup

**Environment Secrets**:
- Configure per-environment if using deployment environments

### Actions Permissions

Navigate to: **Settings → Actions → General**

**Actions permissions**:
- ✅ Allow all actions and reusable workflows

**Workflow permissions**:
- ✅ Read and write permissions
- ✅ Allow GitHub Actions to create and approve pull requests

**Fork pull request workflows**:
- ✅ Require approval for first-time contributors

## GitHub Pages Configuration

### Pages Setup

Navigate to: **Settings → Pages**

**Source**:
- Deploy from a branch

**Branch**:
- Branch: `gh-pages` (auto-created by docs workflow)
- Folder: `/ (root)`

**Custom domain** (optional):
- Add your custom domain if desired
- Configure DNS records accordingly

**Enforce HTTPS**:
- ✅ Enabled (recommended)

### Pages URL

Your documentation will be available at:
```
https://<username>.github.io/dotfiles/
```

Or with custom domain:
```
https://dotfiles.yourdomain.com
```

## Environments

### GitHub Pages Environment

Navigate to: **Settings → Environments → New environment**

**Environment name**: `github-pages`

**Deployment branches**:
- Selected branches only
- Add: `main`

**Environment protection rules**:
- Wait timer: 0 minutes
- Required reviewers: None (for personal repos)

**Environment secrets**:
- None required

## Tags and Releases

### Tagging Strategy

This repository uses **simple descriptive tags** instead of semver:

- `stable` - Latest tested, production-ready configuration
- `nightly` - Daily builds from test/docs
- `dev` - Development snapshots

**Creating tags**:

```bash
# Tag as stable after thorough testing
git tag -a stable -m "Stable release - tested on macOS Sequoia"
git push origin stable

# Force update existing tag
git tag -f stable
git push --force origin stable

# Create milestone tags
git tag -a macos-sequoia-stable -m "Stable for macOS Sequoia 15.1"
git push origin macos-sequoia-stable
```

### GitHub Releases

Navigate to: **Releases → Create a new release**

**Tag**: Select or create tag (e.g., `stable`, `v2024-10-31`)

**Release title**: Descriptive title (e.g., "Stable Release - October 2024")

**Description**:
- Summarize major changes
- Link to commit range
- Note breaking changes
- Include installation instructions

**Assets**: None typically needed (dotfiles are in repo)

## Webhooks and Integrations

### Optional Integrations

**Recommended**:
- None required for basic setup

**Optional**:
- **CodeCov** - Code coverage tracking (if adding test coverage)
- **Dependabot** - Automated dependency updates
- **GitHub Advanced Security** - Security scanning (if available)

### Dependabot Configuration

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

## Issue and Pull Request Templates

### Issue Templates

Create `.github/ISSUE_TEMPLATE/bug_report.md`:

```markdown
---
name: Bug report
about: Create a report to help improve dotfiles
title: '[BUG] '
labels: 'bug'
assignees: ''
---

**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Run command '...'
2. See error

**Expected behavior**
What you expected to happen.

**Environment:**
- OS: [e.g., macOS 14.0]
- Shell: [e.g., zsh 5.9]
- Package: [e.g., shell, git, etc.]

**Additional context**
Any other context about the problem.
```

### Pull Request Template

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Description

Brief description of changes.

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Configuration update
- [ ] Documentation update
- [ ] Refactoring

## Testing

- [ ] Ran `./scripts/test-in-container.sh bootstrap`
- [ ] Ran `./tests/lint.sh`
- [ ] Tested manually on local system
- [ ] Updated documentation

## Checklist

- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where necessary
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] All tests pass locally

## Related Issues

Closes #(issue number)
```

## Repository Labels

### Recommended Labels

Navigate to: **Issues → Labels**

**Type labels**:
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Documentation improvements
- `refactor` - Code refactoring
- `test` - Testing related

**Priority labels**:
- `priority:high` - High priority
- `priority:medium` - Medium priority
- `priority:low` - Low priority

**Status labels**:
- `status:in-progress` - Currently being worked on
- `status:blocked` - Blocked by another issue
- `status:wontfix` - Will not be implemented

**Package labels**:
- `package:shell` - Shell configuration
- `package:git` - Git configuration
- `package:editors` - Editor configurations
- `package:terminal` - Terminal emulators
- `package:tools` - System tools

## Access and Permissions

### Collaborator Permissions

Navigate to: **Settings → Collaborators**

For personal repos, typically only the owner has access.

For shared repos:
- **Admin**: Full access (use sparingly)
- **Write**: Push access, merge PRs
- **Read**: View-only access

### Team Permissions (for Organizations)

If this is an organization repo:
- Create teams for different access levels
- Assign team permissions to repository

## Monitoring and Notifications

### Watch Settings

Configure your personal notification preferences:
- **Releases only**: Get notified of new releases
- **All Activity**: Get notified of all issues, PRs, discussions
- **Ignore**: No notifications (not recommended for your own repo)

### GitHub Actions Notifications

Failed workflow runs will send email notifications by default.

**To customize**:
- Settings → Notifications → Actions
- Choose email or web notifications

## Backup and Recovery

### Repository Backup

**Automated backups**:
- GitHub automatically backs up your repository
- Tags and releases are preserved

**Manual backups**:
```bash
# Clone with full history
git clone --mirror https://github.com/username/dotfiles.git

# Update backup
cd dotfiles.git
git fetch --all
```

### Disaster Recovery

If repository is accidentally deleted:
- Contact GitHub Support within 90 days
- They can restore deleted repositories

## Security Best Practices

### Repository Security

✅ **Enable vulnerability alerts**
- Settings → Security & analysis → Dependabot alerts

✅ **Enable secret scanning** (if available)
- Prevents committing secrets

✅ **Review access regularly**
- Remove collaborators who no longer need access

✅ **Use signed commits**
- Configure GPG signing for commits
- Enforce in branch protection

✅ **Enable two-factor authentication (2FA)**
- Required for GitHub account security

### Secrets Management

**Never commit**:
- API keys
- Passwords
- Personal access tokens
- SSH private keys
- `.env` files with secrets

**Use**:
- GitHub Secrets for CI/CD
- `.gitignore` for sensitive files
- Local-only configuration in `local.zsh`

## Checklist for New Repository Setup

- [ ] Configure branch protection for `main`
- [ ] Configure branch protection for `test/docs`
- [ ] Configure branch protection for `dev`
- [ ] Enable GitHub Pages
- [ ] Configure GitHub Pages environment
- [ ] Add repository description
- [ ] Add topics/tags for discoverability
- [ ] Create issue templates
- [ ] Create PR template
- [ ] Configure recommended labels
- [ ] Enable Dependabot (optional)
- [ ] Test GitHub Actions workflows
- [ ] Verify documentation deployment
- [ ] Test container workflow in CI
- [ ] Review security settings
- [ ] Enable vulnerability alerts

## Resources

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security/getting-started/securing-your-repository)
