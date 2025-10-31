# Test Suite

This directory contains the comprehensive test suite for the dotfiles repository.

## Test Organization

```
tests/
├── README.md                    # This file
├── lint.sh                      # Linting tests (shellcheck, shfmt, YAML, TOML, JSON)
├── integration-tests.sh         # Stow integration tests
├── test-snippets.sh             # Documentation snippet validation
├── check-links.sh               # Documentation link checking
├── test-pre-commit.sh           # Pre-commit hook validation
├── test-workflows.sh            # GitHub Actions workflow validation
└── test-gpg.sh                  # GPG signing verification
```

## Running Tests

### Run All Tests

```bash
# From repository root
./tests/run-all-tests.sh
```

### Run Individual Test Suites

```bash
# Linting
./tests/lint.sh

# Integration tests
./tests/integration-tests.sh

# Documentation tests
./tests/test-snippets.sh
./tests/check-links.sh

# CI/CD validation
./tests/test-pre-commit.sh
./tests/test-workflows.sh

# Security
./tests/test-gpg.sh
```

## Test Categories

### 1. Code Quality (`lint.sh`)

- **Shellcheck**: Static analysis for shell scripts
- **shfmt**: Shell script formatting validation
- **YAML validation**: GitHub Actions, config files
- **TOML validation**: Starship config, etc.
- **JSON validation**: Various config files

**Exit codes**:
- `0`: All checks passed
- `1`: One or more checks failed

### 2. Integration (`integration-tests.sh`)

- **Package structure**: Verify all packages are properly structured
- **Stow dry run**: Check for conflicts before installation
- **File conflicts**: Detect multiple packages managing same files
- **Symlink validation**: Ensure symlinks point to valid targets
- **Documentation coverage**: Check each package has docs

**Exit codes**:
- `0`: All tests passed
- `1`: One or more tests failed

### 3. Documentation (`test-snippets.sh`, `check-links.sh`)

- **Code snippets**: Extract and validate shell code from markdown
- **Link checking**: Verify all links in documentation are valid
- **Syntax validation**: Ensure code examples are correct

**Exit codes**:
- `0`: All documentation valid
- `1`: Broken links or invalid code examples

### 4. CI/CD Validation (`test-pre-commit.sh`, `test-workflows.sh`)

- **Pre-commit hooks**: Verify hooks are properly configured
- **Workflow syntax**: Validate GitHub Actions YAML
- **Required jobs**: Ensure all critical jobs are defined
- **Branch configuration**: Check workflow triggers are correct

**Exit codes**:
- `0`: CI/CD configuration valid
- `1`: Configuration errors found

### 5. Security (`test-gpg.sh`)

- **GPG setup**: Verify GPG is configured
- **Signing capability**: Test commit signing works
- **Key validation**: Ensure key is properly configured
- **GitHub integration**: Check public key is uploaded

**Exit codes**:
- `0`: GPG properly configured
- `1`: GPG configuration incomplete
- `2`: GPG not available

## CI/CD Integration

These tests are automatically run by GitHub Actions on every push and pull request.

### Workflow Matrix

| Workflow | Tests Run | Branches |
|----------|-----------|----------|
| Tests | lint, integration, snippets, links | stable, nightly, dev |
| Super-Linter | Comprehensive linting | stable, nightly, dev |
| CodeQL | Security scanning | stable, nightly, dev |

### Required Checks

For branch protection, these checks must pass:

- `Tests / lint`
- `Tests / integration-tests`
- `Tests / container-tests`
- `Super-Linter / super-linter`
- `CodeQL Security Scanning / analyze`

## Local Development

### Pre-commit Hooks

Install pre-commit hooks to catch issues before committing:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

### Quick Check

Before pushing, run:

```bash
./tests/lint.sh && ./tests/integration-tests.sh
```

## Test Development

### Adding New Tests

1. Create test script in `tests/` directory
2. Follow naming convention: `test-<feature>.sh`
3. Use standard exit codes (0 = pass, non-zero = fail)
4. Include colored output (GREEN/RED/YELLOW)
5. Add to `run-all-tests.sh`
6. Update CI workflow if needed

### Test Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Get repo root
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
cd "${REPO_ROOT}"

echo "=== Your Test Name ==="
echo

FAILURES=0

print_status() {
    local status="${1}"
    local message="${2}"

    case "${status}" in
        ok)
            echo -e "${GREEN}✓${NC} ${message}"
            ;;
        fail)
            echo -e "${RED}✗${NC} ${message}"
            ((FAILURES++))
            ;;
        warn)
            echo -e "${YELLOW}⚠${NC} ${message}"
            ;;
    esac
}

# Your test logic here

# Summary
echo
echo "=== Summary ==="
if [[ ${FAILURES} -eq 0 ]]; then
    print_status "ok" "All checks passed!"
    exit 0
else
    print_status "fail" "${FAILURES} check(s) failed"
    exit 1
fi
```

## Troubleshooting

### Tests Failing Locally But Pass in CI

- Check tool versions (shellcheck, python, etc.)
- Ensure you're on the correct branch
- Run `git status` to check for uncommitted changes

### Tests Pass Locally But Fail in CI

- CI uses Ubuntu latest (GitHub Actions runner)
- Check for macOS-specific assumptions
- Verify all dependencies are installed in CI workflow

### Pre-commit Hooks Failing

```bash
# Reinstall hooks
pre-commit uninstall
pre-commit install

# Run specific hook
pre-commit run shellcheck --all-files

# Skip hooks (emergency only)
git commit --no-verify
```

## Performance

### Test Execution Times

Typical execution times on GitHub Actions:

- `lint.sh`: ~30 seconds
- `integration-tests.sh`: ~20 seconds
- `test-snippets.sh`: ~40 seconds
- `check-links.sh`: ~15 seconds
- Full test suite: ~2-3 minutes

## References

- [Shellcheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Pre-commit Framework](https://pre-commit.com/)
- [Super-Linter](https://github.com/super-linter/super-linter)
