# Pull Request

## Description

<!-- Provide a clear and concise description of your changes -->

## Type of Change

<!-- Mark the relevant option with an 'x' -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to change)
- [ ] 📝 Documentation update
- [ ] 🔧 Configuration update
- [ ] ♻️ Code refactoring
- [ ] 🎨 Style/formatting changes
- [ ] ⚡ Performance improvement

## Target Branch

<!-- Which branch are you targeting? -->

- [ ] `dev` - Development (feature branches)
- [ ] `nightly` - Testing/Pre-production
- [ ] `stable` - Production (requires all checks passing on nightly)

## Changes Made

<!-- List the specific changes made in this PR -->

-
-
-

## Related Issues

<!-- Link any related issues -->

Closes #
Relates to #

## Testing Performed

<!-- Describe the testing you've done -->

### Pre-commit Hooks

- [ ] Pre-commit hooks installed and passing (`pre-commit install` && `pre-commit run --all-files`)
- [ ] No spelling/typo errors detected
- [ ] Shellcheck linting passed

### Local Testing

- [ ] Ran `./tests/lint.sh` successfully
- [ ] Ran `./tests/integration-tests.sh` successfully
- [ ] Ran `./scripts/test-in-container.sh bootstrap` successfully
- [ ] Tested manually on local system

### Container Testing

- [ ] Container builds successfully
- [ ] Stow installation works without conflicts
- [ ] All tests pass in container environment

## Documentation

- [ ] Updated relevant documentation in `docs/`
- [ ] Updated `README.md` if needed
- [ ] Added/updated code comments
- [ ] Updated `CLAUDE.md` for AI assistant context

## Breaking Changes

<!-- If this PR includes breaking changes, describe them here -->

**Breaking changes**: No / Yes (describe below)

<!-- If yes, describe:
- What breaks
- Migration path
- Deprecation notices
-->

## Screenshots / Examples

<!-- If applicable, add screenshots or examples -->

## Checklist

<!-- Ensure all items are checked before submitting -->

### Code Quality

- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings or errors
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing tests pass locally with my changes

### Git Commit

- [ ] Commit is signed with GPG key (`git config --global commit.gpgsign true`)
- [ ] Commit message follows conventional commits format
- [ ] Commit includes co-authored-by if applicable

### Security

- [ ] I have checked for potential security issues
- [ ] No secrets, passwords, or sensitive data committed
- [ ] Dependencies are up-to-date and secure

### Final Checks

- [ ] I have read the [Contributing Guidelines](https://ox2a-fuu.github.io/dotfiles/contributing.html)
- [ ] I have tested the changes on the target environment
- [ ] This PR is ready for review

## Additional Notes

<!-- Any additional information for reviewers -->

---

**For Reviewers**:
- [ ] Code review completed
- [ ] All checks passing
- [ ] Documentation adequate
- [ ] Ready to merge
