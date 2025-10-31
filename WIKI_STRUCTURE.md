# GitHub Wiki Structure Recommendations

This document outlines what should go in the GitHub Wiki vs the mdBook documentation.

## Wiki Purpose

The GitHub Wiki should serve as a **living, community-driven knowledge base** that complements the official documentation.

## Recommended Wiki Structure

### Home
- Quick links to official docs
- Latest stable release info
- Quick start for new users
- Link to contributing guide

### Community Recipes
**Purpose**: User-contributed configurations and customizations

Examples:
- "Using Starship with iTerm2 and tmux"
- "Custom Neovim setup for Python development"
- "Ghostty color schemes collection"
- "Aerospace window management workflows"

**Why Wiki**: These are community contributions that don't need formal review or version control

### Troubleshooting Database
**Purpose**: Community-reported issues and solutions

Examples:
- "Starship prompt not updating in tmux"
- "Stow conflicts with existing dotfiles"
- "GPG signing fails on macOS"
- "Zsh completion not working for custom aliases"

Format:
```markdown
## Issue: [Brief description]

**Symptoms**: What you see
**Cause**: Why it happens
**Solution**: How to fix
**Related**: Links to issues, PRs, or docs
```

**Why Wiki**: Grows organically with user reports, doesn't need to go through PR process

### FAQ
**Purpose**: Frequently asked questions from issues and discussions

Examples:
- "Can I use only some packages?"
- "How do I override default configurations?"
- "Does this work on Linux/macOS/Windows?"
- "How do I contribute a new package?"

**Why Wiki**: Can be updated quickly without rebuilding docs

### Environment-Specific Guides
**Purpose**: Platform or setup-specific instructions

Examples:
- "Setting up on fresh macOS Sonoma install"
- "Ubuntu 24.04 LTS setup guide"
- "Using with chezmoi instead of Stow"
- "Docker development environment setup"

**Why Wiki**: Too specific for main docs, but valuable for community

### Integration Examples
**Purpose**: Real-world examples of integrations

Examples:
- "Integrating with VS Code Remote SSH"
- "Using with 1Password CLI"
- "Setting up with GitHub Codespaces"
- "Automation with Ansible/Puppet/Chef"

**Why Wiki**: Community-maintained integration patterns

### Performance Tips
**Purpose**: Optimization techniques discovered by community

Examples:
- "Reducing zsh startup time"
- "Optimizing Starship prompt performance"
- "Lazy-loading plugins effectively"
- "Profiling shell configuration"

**Why Wiki**: Community discoveries and benchmarks

### Tool Comparisons
**Purpose**: Comparing alternatives and why choices were made

Examples:
- "Stow vs Chezmoi vs Yadm"
- "Starship vs Powerlevel10k vs Oh My Posh"
- "Zsh vs Bash vs Fish"

**Why Wiki**: Opinions and subjective comparisons don't belong in official docs

### Migration Guides
**Purpose**: Migrating from other setups

Examples:
- "Migrating from Oh My Zsh to this setup"
- "Converting from bare git repo to Stow"
- "Moving from Homebrew bundle to package management"

**Why Wiki**: Community can contribute their migration experiences

### Development Notes
**Purpose**: Design decisions and architectural notes

Examples:
- "Why we chose git-flow light"
- "Branch strategy evolution"
- "CI/CD pipeline design decisions"

**Why Wiki**: Internal development context that's too detailed for user docs

## What Should NOT Go in Wiki

### ❌ Don't put in Wiki:
- Installation instructions (belongs in official docs)
- Core package documentation (belongs in official docs)
- API/configuration reference (belongs in official docs)
- Contributing guidelines (belongs in official docs)
- Code of conduct (belongs in repo)
- Security policy (belongs in repo)

### ✅ Do put in Wiki:
- Community tips and tricks
- Troubleshooting discovered by users
- Platform-specific workarounds
- Third-party integrations
- Subjective comparisons
- Quick reference cards
- Video tutorial links
- Community resources

## Wiki Maintenance

### Guidelines
1. **Low barrier to entry**: Community can edit without PR process
2. **Link to official docs**: Always reference canonical documentation
3. **Date information**: Add "Last updated: YYYY-MM-DD" to time-sensitive content
4. **Version context**: Specify which version/branch content applies to
5. **Attribution**: Credit community contributors

### Quality Control
- Maintainers periodically review wiki changes
- Outdated content moved to "Archive" section
- Migrate high-quality wiki content to official docs when appropriate
- Link wiki pages from main documentation where relevant

## Example Wiki Navigation

```
📚 Home
├── 🚀 Quick Start
├── 🎨 Community Recipes
│   ├── Starship Themes
│   ├── Neovim Configurations
│   └── Terminal Integrations
├── 🔧 Troubleshooting
│   ├── macOS Issues
│   ├── Linux Issues
│   └── General Issues
├── ❓ FAQ
├── 🖥️ Platform Guides
│   ├── macOS Setup
│   ├── Ubuntu Setup
│   └── Arch Linux Setup
├── 🔗 Integrations
│   ├── VS Code
│   ├── Docker
│   └── Cloud IDEs
├── ⚡ Performance Tips
├── 🔄 Migration Guides
└── 📝 Development Notes
```

## Relationship: Wiki ↔ Docs

```
┌─────────────────────┐         ┌──────────────────────┐
│   mdBook Docs       │         │    GitHub Wiki       │
│   (Stable/Official) │◄────────┤    (Community)       │
│                     │  link   │                      │
│ - Installation      │         │ - Tips & Tricks      │
│ - Configuration     │         │ - Troubleshooting    │
│ - API Reference     │         │ - Recipes            │
│ - Contributing      │         │ - FAQ                │
│ - Architecture      │         │ - Platform Guides    │
└─────────────────────┘         └──────────────────────┘
         ▲                                  │
         │                                  │
         └──────── Promote valuable ────────┘
                   content to docs
```

## Getting Started with Wiki

1. **Enable Wiki**: Settings → Features → Wikis ✓
2. **Initialize**: Create Home page with welcome and navigation
3. **Create structure**: Add initial pages for main categories
4. **Seed content**: Add a few examples in each category
5. **Announce**: Post in discussions to invite community contributions
6. **Link from docs**: Add "Community Wiki" link to mdBook sidebar

## Benefits of This Approach

- **Official docs stay clean**: Only canonical, reviewed information
- **Community can contribute easily**: No PR process for wiki
- **Faster iteration**: FAQ and troubleshooting updated immediately
- **Lower barrier**: Non-technical users can contribute wiki content
- **Searchable**: Both docs and wiki are searchable on GitHub
- **Complementary**: Each serves its purpose without overlap
