# TODO / Roadmap

## Immediate Fixes Needed

- [ ] Fix bash 3.2 compatibility in test scripts (replace `mapfile` with while loops)
  - `tests/lint.sh`
  - `tests/integration-tests.sh`
  - `tests/test-snippets.sh`

- [ ] Install missing test dependencies
  - `brew install shellcheck shfmt`
  - `pip install pre-commit pyyaml`

- [ ] Configure branch protection rules (see `.github/BRANCH_PROTECTION_SETUP.md`)

## Documentation Tasks (Wiki)

- [ ] Create wiki home page with quick links
- [ ] Add community recipes section
- [ ] Add troubleshooting database
- [ ] Add platform-specific guides (macOS, Linux)
- [ ] Migrate verbose docs from repo to wiki

## CI/CD Improvements

- [ ] Add test for bash 3.2 compatibility
- [ ] Add performance benchmarking test
- [ ] Create workflow to auto-update wiki from commits
- [ ] Add release notes generator

## Future Enhancements

- [ ] Add shell startup time profiling test
- [ ] Create automated backup/restore test
- [ ] Add cross-platform compatibility matrix
- [ ] Implement semantic versioning based on commit messages

## Nice to Have

- [ ] Video tutorials (link in wiki)
- [ ] Community contribution guidelines expansion
- [ ] Performance optimization guide
- [ ] Migration guide from other dotfiles managers

---

**Note**: Create GitHub issues for items you want to track formally
