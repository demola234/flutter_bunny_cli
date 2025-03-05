# Contributing to Flutter Bunny CLI 🐰

Thank you for your interest in contributing to our project! This document provides guidelines and instructions to help you contribute effectively.

## Table of Contents

- [Contributing to Flutter Bunny CLI 🐰](#contributing-to-flutter-bunny-cli-)
  - [Table of Contents](#table-of-contents)
  - [Code of Conduct](#code-of-conduct)
  - [Getting Started](#getting-started)
    - [Setting Up the Development Environment](#setting-up-the-development-environment)
    - [Understanding the Project Structure](#understanding-the-project-structure)
  - [Development Process](#development-process)
    - [Branching Strategy](#branching-strategy)
    - [Commit Messages](#commit-messages)
      - [Commit Structure](#commit-structure)
      - [Examples](#examples)
    - [Pull Requests](#pull-requests)
  - [Code Style and Linting](#code-style-and-linting)
    - [Dart Style Guide](#dart-style-guide)
    - [Linter Configuration](#linter-configuration)
  - [Testing](#testing)
  - [Documentation](#documentation)
  - [Issue Reporting](#issue-reporting)
  - [License](#license)

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to maintain a respectful and inclusive environment for everyone.

## Getting Started

### Setting Up the Development Environment

1. Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) and [Dart](https://dart.dev/get-dart) installed
2. Fork and clone the repository:
   ```bash
   git clone https://github.com/yourusername/flutter_bunny.git
   cd flutter_bunny
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Understanding the Project Structure

- `lib/` - Contains the main source code
  - `lib/flutter_bunny.dart` - Main library entry point
  - `lib/src/cli/` - CLI implementation
  - `lib/src/commands/` - Command implementations
  - `lib/src/common/` - Shared utilities and base classes
  - `lib/src/templates/` - Template generation tools
- `bin/` - Contains executable entry points
  - `bin/flutter_bunny.dart` - Main CLI executable
- `test/` - Contains test files mirroring the lib structure
- `doc/` - Project documentation
- `analysis_options.yaml` - Defines linting rules and static analysis configuration
- `all_linter_rules.yaml` - Comprehensive list of linter rules

## Development Process

### Branching Strategy

We follow a simplified Git flow:

- `main` - Production-ready code
- `develop` - Integration branch for features
- Feature branches - Named as `feature/feature-name`
- Bugfix branches - Named as `fix/bug-description`

### Commit Messages

We strictly follow the [Conventional Commits](https://www.conventionalcommits.org/) standard which helps with automatic versioning and changelog generation:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

#### Commit Structure

1. **fix:** a commit of the *type* `fix` patches a bug in the codebase (correlates with `PATCH` in Semantic Versioning).
2. **feat:** a commit of the *type* `feat` introduces a new feature to the codebase (correlates with `MINOR` in Semantic Versioning).
3. **BREAKING CHANGE:** a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with `MAJOR` in Semantic Versioning). A BREAKING CHANGE can be part of commits of any *type*.
4. Other *types* allowed include:
   - `build:` - Changes affecting build system or external dependencies
   - `chore:` - Maintenance tasks that don't modify src or test files
   - `ci:` - Changes to CI configuration files and scripts
   - `docs:` - Documentation only changes
   - `style:` - Changes that don't affect code meaning (white-space, formatting, etc)
   - `refactor:` - Code changes that neither fix bugs nor add features
   - `perf:` - Performance improvements
   - `test:` - Adding or correcting tests

5. A *scope* may be provided for additional context: `feat(cli):`  

#### Examples

**Commit with description and breaking change footer**
```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

**Commit with `!` to draw attention to breaking change**
```
feat!: send an email to the customer when a product is shipped
```

**Commit with scope and breaking change**
```
feat(api)!: send an email to the customer when a product is shipped
```

**Commit with both `!` and BREAKING CHANGE footer**
```
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

**Commit with no body**
```
docs: correct spelling of CHANGELOG
```

**Commit with scope**
```
feat(lang): add Polish language
```

**Commit with multi-paragraph body and multiple footers**
```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

### Pull Requests

1. Create a branch from `develop`
2. Make your changes
3. Ensure tests pass and linting is successful
4. Submit a PR with a clear description of changes
5. Link relevant issues using keywords like `Fixes #123`

## Code Style and Linting

### Dart Style Guide

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) with the following specifics:

- Use single quotes for strings
- Use relative imports for local files
- Write self-documenting code with clear variable and function names
- Follow the command pattern for CLI implementation

### Linter Configuration

Our project uses a strict set of linter rules defined in `analysis_options.yaml`. Key rules include:

- **String Quotes**: Use single quotes (`prefer_single_quotes`)
- **Imports**: Use relative imports for project files (`prefer_relative_imports`)
- **Types**: Always specify types (`always_specify_types`)
- **Documentation**: Public APIs must be documented (`public_member_api_docs`)
- **Code Organization**: Sort constructors first (`sort_constructors_first`)
- **Error Handling**: Properly catch and handle exceptions

A comprehensive list of all available linter rules is available in `all_linter_rules.yaml` for reference.

Run the analyzer regularly to check your code:

```bash
dart analyze
```

## Testing

- Write tests for all new features and bug fixes
- Tests should mirror the library structure in the `test/` directory
- For CLI commands, ensure both success and error paths are tested
- Maintain or improve code coverage
- Run tests before submitting a PR:
  ```bash
  dart test
  ```

## Documentation

- Document all public APIs using [dartdoc](https://dart.dev/tools/dartdoc) comments
- Keep README, CHANGELOG, and other documentation up to date
- Add version-specific documentation in the `doc/` directory
- For new commands, include detailed help text and examples
- Update the help text in CLI commands when modifying behavior

## Issue Reporting

When reporting issues, please use the provided templates and include:

- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (Flutter version, device/emulator, etc.)

## License

By contributing to this project, you agree that your contributions will be licensed under the project's [license](LICENSE).

---

Thank you for contributing to make this project better!