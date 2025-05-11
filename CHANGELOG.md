# Changelog

All notable changes to Flutter Bunny CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), 
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2025-05-11

### Features
- Stable release of Flutter Bunny CLI

### Fixed
- Fixed a bug where the update command was not working correctly

### Documentation
- Updated documentation to include more detailed instructions for using the CLI
- Added a section on how to contribute to the project

## [1.0.7-beta.11] - 2025-04-28

### Documentation
- Updated documentation to add more details about the commands and arguments

## [1.0.7-beta.8] - 2025-04-24

### Fixed
- Fixed Android build issue

## [1.0.7-beta.7] - 2025-04-22

### Documentation
- Updated documentation for the generate command to provide more detailed instructions and examples

## [1.0.7-beta.6] - 2025-04-22

### Fixed
- Fixed the issue with the generate command not working correctly for some users

## [1.0.7-beta.5] - 2025-04-15

### Added
- Improved the generate command to support more options and features
- Added ability for users to generate model or entity classes with JSON serialization support (Freezed, JsonSerializable, or custom serialization options)

## [1.0.7-beta.3] - 2025-04-15

### Documentation
- Added reminder to check documentation for updates

## [1.0.6-beta.5] - 2025-03-10

### Added
- `analyze` command: Helps to run analysis on the project and points out any issues
- `config` command: Helps to save settings for preferred user styles for template generation
- `doctor` command: Helps to analyze problems in a project, list them out and suggest changes

### Changed
- Refactored command structure for better extensibility
- Enhanced error handling and user feedback
- Improved template generation with consistent structure

### Fixed
- Process result handling in package manager
- Boolean condition checking in CLI runner

## [1.0.6-beta.2] - 2025-03-10

### Documentation
- Added comprehensive documentation for the CLI

## [1.0.6-beta.1] - 2025-03-09

### Added
- Initial beta release of Flutter Bunny CLI
- Core command structure and CLI framework
- `create app` command with interactive project creation
  - Support for multiple architectures (Clean, MVVM, MVC)
  - Support for various state management solutions (Provider, Riverpod, Bloc, GetX, MobX, Redux)
  - Custom template generation with project scaffolding
- `generate` command system with multiple generators:
  - Screen generator for creating new application screens/pages
  - Widget generator for creating reusable UI components
  - Model generator with JSON serialization support
- Project validation and post-generation setup:
  - Automatic dependency installation
  - Code formatting
  - Git repository initialization
- `update` command to keep the CLI up-to-date

### Changed
- Refactored command structure for better extensibility
- Enhanced error handling and user feedback
- Improved template generation with consistent structure

### Fixed
- Process result handling in package manager
- Parameter name updates for compatibility with latest pub_updater package
- Boolean condition checking in CLI runner

## [1.0.5-beta]

- Initial beta version

## [1.0.4]

- Initial version