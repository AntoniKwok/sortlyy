# Flutter Base Project

A feature-based Flutter project template with clean architecture, BLoC state management, and stream-based API handling.

## Architecture

This project follows a **feature-based architecture** with clean architecture principles:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── errors/             # Error handling
│   ├── network/            # API client
│   ├── utils/              # Utilities and typedefs
│   └── di/                 # Dependency injection
├── features/               # Feature modules
│   ├── auth/               # Authentication feature
│   │   ├── data/           # Data layer
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/         # Domain layer
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/   # Presentation layer
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   └── home/               # Home feature
└── shared/                 # Shared components
    ├── widgets/
    └── themes/
```

## Key Features

### 🏗️ Clean Architecture
- **Domain Layer**: Business logic and entities
- **Data Layer**: API calls, models, and repositories
- **Presentation Layer**: UI, BLoC, and widgets

### 🔄 State Management
- **BLoC Pattern**: Reactive state management
- **Stream-based**: Real-time data updates
- **Event-driven**: Clear separation of events and states

### 🌐 API Handling
- **Dio**: HTTP client for API calls
- **Either Pattern**: Functional error handling (Left = Error, Right = Success)
- **Stream Support**: Real-time data streaming

### 🧩 Dependency Injection
- **GetIt**: Service locator pattern
- **Modular**: Easy to test and maintain

## Dependencies

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  
  # HTTP Client
  dio: ^5.7.0
  
  # Functional Programming
  dartz: ^0.10.1
  
  # Dependency Injection
  get_it: ^8.0.2
  
  # Code Generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

## Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code:**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Code Generation

This project uses code generation for:
- **Freezed**: Immutable classes and unions
- **JSON Serialization**: Model serialization

Run code generation:
```bash
# One-time generation
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

## Adding New Features

1. **Create feature folder structure:**
   ```
   lib/features/your_feature/
   ├── data/
   │   ├── datasources/
   │   ├── models/
   │   └── repositories/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   └── presentation/
       ├── bloc/
       ├── pages/
       └── widgets/
   ```

2. **Register dependencies** in `core/di/injection_container.dart`

3. **Follow the established patterns** for consistency

## Error Handling

The project uses the **Either pattern** for error handling:

```dart
// Success case
return Right(data);

// Error case
return Left(Failure.serverFailure(message: 'Error message'));
```

## Stream-based Architecture

Real-time data updates using streams:

```dart
// Repository returns stream
ResultStream<User?> getCurrentUser();

// BLoC listens to stream
_userSubscription = getCurrentUserUseCase(NoParams()).listen(
  (result) => result.fold(
    (failure) => emit(Error(message: failure.message)),
    (user) => emit(Authenticated(user: user)),
  ),
);
```

## Platform Support

- ✅ Android
- ✅ iOS
- ❌ Web (excluded)
- ❌ Desktop (excluded)

## Next Steps

This base project is ready for:
- **Modularization**: Split features into separate packages
- **Testing**: Unit, widget, and integration tests
- **CI/CD**: Automated testing and deployment
- **Additional Features**: Add more features following the established pattern

## Contributing

1. Follow the established architecture patterns
2. Use BLoC for state management
3. Implement proper error handling with Either
4. Add tests for new features
5. Update documentation as needed