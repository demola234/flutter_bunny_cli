# 🐰 Flutter Bunny CLI (Beta)

A powerful CLI tool for creating and managing Flutter applications with best practices and consistent architecture.

[![Pub Version](https://img.shields.io/pub/v/flutter_bunny.svg)](https://pub.dev/packages/flutter_bunny)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## 📚 Overview

Flutter Bunny is an opinionated CLI tool that helps you create, manage, and maintain Flutter applications with a focus on:

- **Best practices** - Follow Flutter community best practices for code organization and patterns
- **Consistent architecture** - Choose from popular architecture patterns (Clean Architecture, MVVM, MVC)
- **Rapid development** - Generate common components with a single command
- **Testing** - Built-in testing templates and utilities
- **Project maintenance** - Tools to keep your project organized and up-to-date

## Beta Installation

```bash
dart pub global activate flutter_bunny 1.0.7-beta.8

# Verify installation
flutter_bunny --version
```
Make sure the pub cache bin directory is in your PATH.

## Beta Installation on macOS with Homebrew

```bash
brew tap demola234/homebrew-tap

brew install flutter_bunny
```



## 🏗️ Commands

### Creating a New Flutter Project

```bash
# Create a new Flutter application interactively
flutter_bunny create app

# Create with specific options
flutter_bunny create app --name my_awesome_app --architecture clean_architecture --state-management riverpod
```

During creation, you'll be guided through selecting:

- Project name and organization
- Architecture pattern (Clean Architecture, MVVM, MVC)
- State management solution (Provider, Riverpod, Bloc, GetX, etc.)
- Core features and modules to include

### Generating Components

Generate various application components with best practices baked in:

```bash
# Generate a new screen
flutter_bunny generate screen --name HomeScreen

# Generate a stateful widget
flutter_bunny generate widget --name CustomButton --stateful

# Generate a data model with JSON serialization
flutter_bunny generate model --name User --fields "id:int,name:String,email:String,createdAt:DateTime" --json
```

The generate command supports the following component types:

- `screen` - Application screens/pages
- `widget` - Reusable UI components
- `model` - Data models with optional JSON serialization

### Updating the CLI

```bash
# Update to the latest version
flutter_bunny update
```

## 📋 Project Structure

Projects created with Flutter Bunny follow a consistent structure based on your chosen architecture:

### Clean Architecture Structure

```
lib/
├── core/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── theme/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── blocs/
│   ├── pages/
│   └── widgets/
└── main.dart
```

### MVVM Architecture Structure

```
lib/
├── models/
├── services/
├── view_models/
├── views/
│   ├── screens/
│   └── widgets/
└── main.dart
```

### MVC Architecture Structure

```
lib/
├── models/
├── services/
├── views/
│   ├── controllers/
│   ├── models/
│   └── views/
└── main.dart
```

## 🎨 Customization

### Configuration

Flutter Bunny uses a configuration file to store your preferences. You can edit this file directly or use the command-line options to override settings.

```bash
# View current configuration
flutter_bunny config show

# Set a configuration value
flutter_bunny config set default_architecture clean_architecture
```

### Templates

Templates used by Flutter Bunny can be customized to match your team's specific requirements:

1. Create a custom template in the `~/.flutter_bunny/templates/` directory
2. Use your custom template with the `--template` flag:

```bash
flutter_bunny create app --template custom_template
```

## 🧪 Testing

Projects created with Flutter Bunny are set up with comprehensive testing utilities:

- **Unit Tests** - For business logic, models, and utilities
- **Widget Tests** - For UI components
- **Integration Tests** - For feature workflows

Run tests using the built-in commands:

```bash
# Run all tests
flutter_bunny test

# Run specific tests
flutter_bunny test --type unit
```

## 📋 Architecture Options

Flutter Bunny supports multiple architecture patterns:

### Clean Architecture

Separates your application into layers with clear responsibilities:

- **Presentation Layer** - UI components, pages and state management
- **Domain Layer** - Business logic, entities and use cases
- **Data Layer** - Data sources, repositories and models

### MVVM (Model-View-ViewModel)

Separates UI logic from business logic:

- **Model** - Data and business logic
- **View** - UI components with minimal logic
- **ViewModel** - Mediator between Model and View

### MVC (Model-View-Controller)

Classic pattern for separating concerns:

- **Model** - Data and business logic
- **View** - UI components
- **Controller** - Handles user input and updates models/views

## 🧩 State Management Options

Flutter Bunny supports multiple state management solutions:

- **Provider** - Simple and flexible state management
- **Riverpod** - Evolution of Provider with improved patterns
- **Bloc/Cubit** - Predictable state management with events and states
- **GetX** - Lightweight state management with utilities
- **MobX** - Reactive state management
- **Redux** - Predictable state container

## 🔧 Common Tasks

### Analyzing Code

```bash
# Run static analysis
flutter_bunny analyze
```

### Running Doctor

```bash
# Check for issues
flutter_bunny doctor
```

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

Flutter Bunny is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## 📞 Support

If you encounter any issues or have questions:

- Open an [issue](https://github.com/demola234/flutter_bunny/issues)
- Check [documentation](https://www.flutterbunny.xyz)
