## [1.0.7-beta.11] - 2025-04-28
- [docs] - Update the documentation to add more details about the commands and args

## [1.0.7-beta.8] - 2025-04-24
- [fixes] - Fixed android build issue 

## [1.0.7-beta.7] - 2025-04-22
- [docs] - Updated the documentation for the generate command to provide more detailed instructions and examples.

## [1.0.7-beta.6] - 2025-04-22
- [fixes] -  Fixed the issue with the generate command not working correctly for some users.


## [1.0.7-beta.5] - 2025-04-15

### Added
- [generate] - Improvedd the generate command to support more options and features, Allow users to generate model or entity classes with JSON serialization support with Freezed, JsonnSerializable, or custom serialization options.

## [1.0.6-beta.2x] - 2025-03-10

### Added

- [docs] - Added Documentation for the CLI

## [1.0.7-beta.3] - 2025-04-15

### Added 
- [docs] - Check docs for updates


## [1.0.6-beta.5] - 2025-03-10

### Added

- [analyze] - Helps to run analysis on the project and helps to point out any issues
- [config] - Helps to save settings for preferred users style for template generation
- [doctor] - Helps to analysis problems in a project, list them out and suggest changes to it

### Changed

- Refactored command structure for better extensibility
- Enhanced error handling and user feedback
- Improved template generation with consistent structure

### Fixed

- Process result handling in package manager
- Boolean condition checking in CLI runner

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

- Changelog

All notable changes to Flutter Bunny CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.5-beta

- Changelog

All notable changes to Flutter Bunny CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.4

- Initial version.