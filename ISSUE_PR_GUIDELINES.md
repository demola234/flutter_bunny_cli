# Issue and Pull Request Guidelines

This document outlines the standards and workflows for creating issues and pull requests for the Flutter Bunny project. Following these guidelines helps maintain project quality and ensures efficient collaboration.

## Issues

### Issue Types

We categorize issues into several types:

1. **Bug Report** - Something isn't working as expected
2. **Feature Request** - Suggestion for new functionality
3. **Documentation** - Improvements or additions to documentation
4. **Performance** - Issues related to performance optimization
5. **Maintenance** - Technical debt, refactoring, dependencies
6. **Question** - Community questions that aren't bug reports

### Creating an Issue

#### Before Creating

1. **Search existing issues** to avoid duplicates
2. **Check the documentation** to ensure the behavior isn't expected
3. **Verify with the latest version** to confirm the issue still exists

#### Issue Templates

We provide issue templates for common types. Please use them when available:

- Bug Report
- Feature Request
- Documentation Issue

#### Writing Good Issues

A high-quality issue includes:

1. **Clear, descriptive title** that summarizes the issue
2. **Environment details**:
   - Flutter Bunny version
   - Operating system
   - Dart/Flutter version (if applicable)
   - Any relevant configuration
3. **Steps to reproduce**:
   - Provide minimal, complete steps
   - Include sample code when applicable
   - Mention any specific settings or configuration
4. **Expected behavior**
5. **Actual behavior**:
   - Error messages (in text, not screenshots)
   - Stack traces when available
   - Screenshots for UI issues only
6. **Additional context**:
   - Possible solutions you've considered
   - Related issues
   - References to documentation

#### Issue Labels

Our labels help categorize and prioritize issues:

- `bug` - Confirmed bugs
- `feature` - New feature requests
- `documentation` - Documentation improvements
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `priority: high/medium/low` - Issue priority
- `needs: reproduction/clarification` - More information needed

### Issue Lifecycle

1. **New** - Issue is created
2. **Triage** - Maintainers review, add labels, and prioritize
3. **In Progress** - Issue is being worked on (assigned)
4. **Review** - Solution is ready for review
5. **Done** - Issue is resolved and closed

## Pull Requests

### PR Preparation

1. **Create an issue first** (if one doesn't exist)
2. **Discuss implementation approach** to avoid wasted effort
3. **Fork the repository** and create a feature branch
4. **Keep changes focused** on a single issue

### Branch Naming

Format: `<type>/<issue-number>-<short-description>`

Examples:
- `fix/123-handle-null-parameters`
- `feat/456-add-polish-language-support`
- `docs/789-update-cli-usage-example`

### Pull Request Content

A good PR includes:

1. **Clear, descriptive title** following [conventional commits](https://www.conventionalcommits.org/) format
2. **Detailed description** including:
   - Reference to the issue: `Fixes #123`
   - Summary of changes
   - Motivation and context
   - Screenshots/examples for UI changes
3. **Comprehensive testing**:
   - Unit tests for new functionality
   - Updated existing tests if needed
4. **Documentation updates**:
   - Update README if needed
   - Add/update API documentation
   - Update CHANGELOG

### PR Template

```md
## Description

[Reference the issue this PR addresses: Fixes #XX]

### Changes
- [Description of changes]
- [Another change]

### Motivation
[Why was this change needed?]

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement

## Testing
- [ ] Added unit tests
- [ ] Updated existing tests
- [ ] Manually tested on [environment]

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding documentation changes
- [ ] My changes generate no new warnings
- [ ] PR title follows conventional commit syntax
```

### PR Review Process

1. **Automated checks**:
   - CI tests must pass
   - Code coverage requirements must be met
   - Linting must pass
   
2. **Code review**:
   - At least one maintainer approval required
   - Reviewer checks for:
     - Code quality and style
     - Test coverage
     - Documentation
     - Adherence to project standards

3. **Revision process**:
   - Address reviewer comments
   - Push changes to same branch
   - Request re-review when ready

4. **Merge requirements**:
   - All comments resolved
   - Required approvals obtained
   - CI checks passing
   - Commits squashed if needed

### After Merging

1. The issue is automatically closed if properly referenced
2. The PR is added to the appropriate milestone for release tracking
3. Changes are documented in the CHANGELOG

## Contributor Recognition

We value all contributions and recognize contributors in the following ways:

1. Add to CONTRIBUTORS.md file
2. Mention in release notes
3. Include in project documentation as appropriate

## Labels Reference

| Label | Description |
|-------|-------------|
| `bug` | Something isn't working |
| `feature` | New feature or request |
| `documentation` | Documentation improvements |
| `duplicate` | Issue already exists |
| `good first issue` | Good for newcomers |
| `help wanted` | Extra attention needed |
| `invalid` | Issue doesn't apply |
| `question` | Further information requested |
| `wontfix` | This will not be worked on |
| `priority: high` | Urgent issues |
| `priority: medium` | Important but not urgent |
| `priority: low` | Will be addressed as time permits |

## Additional Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)