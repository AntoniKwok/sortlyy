# Architecture Guide

## Overview

This Flutter base project implements **Clean Architecture** with **Feature-Based Organization**, providing a scalable foundation for mobile applications.

## Core Principles

### 1. Clean Architecture Layers

```
┌─────────────────────────────────────┐
│           Presentation              │
│        (UI, BLoC, Pages)           │
├─────────────────────────────────────┤
│             Domain                  │
│    (Entities, Use Cases, Repos)    │
├─────────────────────────────────────┤
│              Data                   │
│   (Models, Data Sources, Repos)    │
└─────────────────────────────────────┘
```

### 2. Feature-Based Organization

Each feature is self-contained with its own:
- **Data Layer**: API calls, models, repository implementations
- **Domain Layer**: Business logic, entities, repository contracts
- **Presentation Layer**: UI components, state management

### 3. Dependency Flow

```
Presentation → Domain ← Data
```

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** depends on nothing (pure business logic)

## Key Components

### State Management (BLoC)

```dart
// Event-driven architecture
AuthBloc → AuthEvent → AuthState

// Stream-based updates
Stream<Either<Failure, User>> getCurrentUser()
```

### Error Handling (Either Pattern)

```dart
// Success
return Right(user);

// Failure
return Left(Failure.networkFailure(message: 'No connection'));
```

### API Integration (Dio + Streams)

```dart
// HTTP client with interceptors
ApiClient → Dio → Response

// Stream-based real-time updates
Repository → Stream<Either<Failure, T>>
```

### Dependency Injection (GetIt)

```dart
// Service locator pattern
final sl = GetIt.instance;

// Register dependencies
sl.registerLazySingleton<ApiClient>(() => ApiClient());
```

## Data Flow

### 1. User Interaction
```
UI Widget → BLoC Event
```

### 2. Business Logic
```
BLoC → Use Case → Repository Interface
```

### 3. Data Fetching
```
Repository Implementation → Data Source → API
```

### 4. Response Handling
```
API Response → Model → Entity → BLoC State → UI Update
```

## Code Generation

### Freezed (Immutable Classes)
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
  }) = _User;
}
```

### JSON Serialization
```dart
@JsonSerializable()
class UserModel {
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

## Testing Strategy

### Unit Tests
- **Domain Layer**: Use cases, entities
- **Data Layer**: Repository implementations, data sources

### Widget Tests
- **Presentation Layer**: Individual widgets, pages

### Integration Tests
- **End-to-End**: Complete user flows

## Best Practices

### 1. Separation of Concerns
- Each layer has a single responsibility
- Dependencies flow inward (toward domain)

### 2. Testability
- Pure functions in domain layer
- Dependency injection for easy mocking

### 3. Scalability
- Feature-based organization
- Modular architecture ready for package separation

### 4. Error Handling
- Consistent error types across the app
- Either pattern for functional error handling

### 5. State Management
- Reactive programming with streams
- Immutable state objects

## Adding New Features

### 1. Create Feature Structure
```bash
lib/features/new_feature/
├── data/
├── domain/
└── presentation/
```

### 2. Implement Domain Layer
- Define entities
- Create repository interfaces
- Implement use cases

### 3. Implement Data Layer
- Create models with JSON serialization
- Implement data sources
- Implement repository

### 4. Implement Presentation Layer
- Create BLoC (events, states, bloc)
- Build UI components
- Connect to dependency injection

### 5. Register Dependencies
```dart
// In injection_container.dart
void _initNewFeature() {
  sl.registerFactory(() => NewFeatureBloc(useCase: sl()));
  sl.registerLazySingleton(() => NewFeatureUseCase(repository: sl()));
  // ... more registrations
}
```

## Performance Considerations

### 1. Lazy Loading
- Use `registerLazySingleton` for expensive objects
- Load features on-demand

### 2. Stream Management
- Properly dispose of stream subscriptions
- Use `StreamController.broadcast()` for multiple listeners

### 3. Code Generation
- Run `build_runner` in watch mode during development
- Include generated files in version control

## Security Best Practices

### 1. API Security
- Use HTTPS for all API calls
- Implement proper authentication headers
- Handle token refresh automatically

### 2. Data Validation
- Validate all user inputs
- Sanitize data before API calls

### 3. Error Information
- Don't expose sensitive information in error messages
- Log detailed errors server-side only

This architecture provides a solid foundation for building scalable, maintainable Flutter applications with clear separation of concerns and excellent testability.