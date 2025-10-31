# Branch Protection Rules Setup Guide

This guide shows you **exactly** how to configure branch protection rules in GitHub UI.

## Understanding Status Checks

**Status checks** = The individual jobs from your GitHub Actions workflows.

The format in GitHub is: `<Workflow Name> / <Job Name>`

### Available Status Checks from Our Workflows

From your `.github/workflows/` files:

| Workflow File | Workflow Name | Job Names | Status Check Name |
|--------------|---------------|-----------|-------------------|
| `test.yml` | Tests | lint | `Tests / lint` |
| `test.yml` | Tests | snippet-tests | `Tests / snippet-tests` |
| `test.yml` | Tests | integration-tests | `Tests / integration-tests` |
| `test.yml` | Tests | markdown-lint | `Tests / markdown-lint` |
| `test.yml` | Tests | container-tests | `Tests / container-tests` |
| `test.yml` | Tests | test-summary | `Tests / test-summary` |
| `super-linter.yml` | Super-Linter | super-linter | `Super-Linter / super-linter` |
| `codeql.yml` | CodeQL Security Scanning | analyze | `CodeQL Security Scanning / analyze` |
| `docs.yml` | Documentation | build | `Documentation / build` |

**Note**: The status check names won't appear in the dropdown until they've run at least once on that branch!

---

## Step-by-Step Configuration

### Prerequisites

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Branches**
3. You'll need admin access to the repository

### Step 1: Run Workflows First (Important!)

Before configuring, you need status checks to run at least once on each branch:

```bash
# Make a small change on each branch to trigger workflows
git checkout dev
echo "# Dev branch" >> .github/README.md
git add .github/README.md
git commit -S -m "docs: trigger workflows for dev branch"
git push origin dev

git checkout nightly
echo "# Nightly branch" >> .github/README.md
git add .github/README.md
git commit -S -m "docs: trigger workflows for nightly branch"
git push origin nightly

git checkout stable
echo "# Stable branch" >> .github/README.md
git add .github/README.md
git commit -S -m "docs: trigger workflows for stable branch"
git push origin stable
```

Wait for workflows to complete, then proceed with configuration.

---

## Configuration for Each Branch

### 🔴 STABLE Branch (Production)

**Path**: Settings → Branches → Add rule → Branch name pattern: `stable`

#### 1. Basic Settings
- ✅ **Require a pull request before merging**
  - ✅ **Require approvals**: 1
  - ✅ **Dismiss stale pull request approvals when new commits are pushed**
  - ✅ **Require review from Code Owners** (optional, if you have CODEOWNERS file)
  - ❌ Allow specified actors to bypass required pull requests (leave empty)

#### 2. Status Checks
- ✅ **Require status checks to pass before merging**
  - ✅ **Require branches to be up to date before merging**
  - **Search and add these checks**:
    - `Tests / lint`
    - `Tests / snippet-tests`
    - `Tests / integration-tests`
    - `Tests / markdown-lint`
    - `Tests / container-tests`
    - `Tests / test-summary`
    - `Super-Linter / super-linter`
    - `CodeQL Security Scanning / analyze`
    - `Documentation / build`

**How to add**:
1. Click in the search box under "Status checks that are required"
2. Type the exact name (e.g., "Tests / lint")
3. Click on it when it appears
4. Repeat for all checks listed above

#### 3. Additional Rules
- ✅ **Require conversation resolution before merging**
- ✅ **Require signed commits**
- ❌ Require linear history (leave unchecked - we want merge commits)
- ❌ Require deployments to succeed before merging (not needed)

#### 4. Admin Settings
- ✅ **Do not allow bypassing the above settings**
- ✅ **Include administrators**
- ❌ Allow force pushes (keep disabled)
- ❌ Allow deletions (keep disabled)

#### 5. Lock branch
- ❌ Lock branch (keep unlocked for automation)

**Click "Create" or "Save changes"**

---

### 🟡 NIGHTLY Branch (Staging)

**Path**: Settings → Branches → Add rule → Branch name pattern: `nightly`

#### 1. Basic Settings
- ✅ **Require a pull request before merging**
  - **Require approvals**: 0 (optional review, not required)
  - ❌ Dismiss stale pull request approvals (not necessary for nightly)

#### 2. Status Checks
- ✅ **Require status checks to pass before merging**
  - ✅ **Require branches to be up to date before merging**
  - **Required checks**:
    - `Tests / lint`
    - `Tests / integration-tests`
    - `Tests / container-tests`
    - `Super-Linter / super-linter`
    - `CodeQL Security Scanning / analyze`

**Note**: Fewer checks than stable - we skip snippet-tests and markdown-lint for faster feedback.

#### 3. Additional Rules
- ✅ **Require signed commits**
- ❌ Require conversation resolution (optional for nightly)
- ❌ Require linear history

#### 4. Admin Settings
- ✅ **Do not allow bypassing the above settings**
- ✅ **Include administrators**
- ❌ Allow force pushes
- ❌ Allow deletions

**Click "Create" or "Save changes"**

---

### 🟢 DEV Branch (Development)

**Path**: Settings → Branches → Add rule → Branch name pattern: `dev`

#### 1. Basic Settings
- ❌ **Require a pull request before merging** (allow direct push for speed)

#### 2. Status Checks (Recommended but not blocking)
- ✅ **Require status checks to pass before merging**
  - ❌ Require branches to be up to date (too strict for dev)
  - **Suggested checks** (minimal):
    - `Tests / lint`
    - `Super-Linter / super-linter`

**Note**: Dev should be flexible. Only require linting to catch obvious errors.

#### 3. Additional Rules
- ✅ **Require signed commits** (still enforce GPG signing)
- ❌ Everything else

#### 4. Admin Settings
- ✅ **Do not allow bypassing the above settings**
- ✅ **Include administrators**
- ❌ Allow force pushes (even on dev, maintain history)
- ❌ Allow deletions

**Click "Create" or "Save changes"**

---

## Troubleshooting

### "I don't see the status checks in the search box"

**Cause**: Status checks only appear after they've run at least once on a branch.

**Solution**:
1. Make a commit to that branch
2. Let workflows complete
3. Refresh the branch protection settings page
4. Now search for the check names

### "Some checks are failing that I don't care about"

**Options**:
1. **Don't require that check** - Remove it from required checks
2. **Make it pass** - Fix the issue the check found
3. **Skip on certain paths** - Modify workflow to skip (not recommended)

### "Status check names have changed"

**Cause**: You renamed a workflow or job in YAML.

**Solution**:
1. Go to branch protection settings
2. Remove old check name
3. Add new check name
4. Old PRs may need to be updated (close/reopen)

### "How do I test branch protection without merging?"

**Solution**: Create a test PR from a feature branch:

```bash
git checkout dev
git checkout -b test/branch-protection
echo "test" >> README.md
git commit -S -m "test: verify branch protection"
git push -u origin test/branch-protection
gh pr create --base dev --title "Test branch protection"
```

Try to merge without checks passing - should be blocked!

---

## Visual Guide: Adding Status Checks

When you're in the branch protection settings:

```
┌─────────────────────────────────────────────────────────┐
│ Require status checks to pass before merging     [✓]   │
├─────────────────────────────────────────────────────────┤
│ Require branches to be up to date before merging [✓]   │
├─────────────────────────────────────────────────────────┤
│ Status checks that are required:                        │
│                                                          │
│ [Search for status checks________________]  🔍          │
│                                                          │
│ ✓ Tests / lint                              [x]         │
│ ✓ Tests / integration-tests                 [x]         │
│ ✓ Super-Linter / super-linter               [x]         │
│ ✓ CodeQL Security Scanning / analyze        [x]         │
│                                                          │
│ [+ Add more]                                            │
└─────────────────────────────────────────────────────────┘
```

Click the `[x]` to remove a check, or search to add more.

---

## Verification Checklist

After setting up, verify your configuration:

### For `stable` branch:
- [ ] Requires PR with 1 approval
- [ ] Requires 9 status checks (all critical checks)
- [ ] Requires signed commits
- [ ] Administrators cannot bypass
- [ ] Force push disabled

### For `nightly` branch:
- [ ] Requires PR (no approval needed)
- [ ] Requires 5 status checks (core checks)
- [ ] Requires signed commits
- [ ] Administrators cannot bypass
- [ ] Force push disabled

### For `dev` branch:
- [ ] Direct push allowed
- [ ] Requires 2 status checks (linting only)
- [ ] Requires signed commits
- [ ] Administrators cannot bypass
- [ ] Force push disabled

---

## Quick Reference: Status Check Names

Copy these exact names when searching:

**For stable** (require all):
```
Tests / lint
Tests / snippet-tests
Tests / integration-tests
Tests / markdown-lint
Tests / container-tests
Tests / test-summary
Super-Linter / super-linter
CodeQL Security Scanning / analyze
Documentation / build
```

**For nightly** (require subset):
```
Tests / lint
Tests / integration-tests
Tests / container-tests
Super-Linter / super-linter
CodeQL Security Scanning / analyze
```

**For dev** (minimal):
```
Tests / lint
Super-Linter / super-linter
```

---

## Advanced: Using GitHub CLI

You can also configure branch protection via `gh` CLI:

```bash
# Stable branch
gh api repos/:owner/:repo/branches/stable/protection \
  --method PUT \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field required_status_checks='{"strict":true,"contexts":["Tests / lint","Tests / integration-tests"]}' \
  --field enforce_admins=true \
  --field required_signatures=true

# But UI is easier for first-time setup!
```

---

## Getting Help

If status checks aren't appearing:
1. Check Actions tab - did workflows run?
2. Check workflow YAML - are job names correct?
3. Check branch name - workflows need to trigger on that branch
4. Wait 1-2 minutes and refresh settings page

For more help:
- [GitHub Branch Protection Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Required Status Checks](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches#require-status-checks-before-merging)
