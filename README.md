# Sortlyy

**Tinder for your camera roll** — swipe to keep, delete, or favorite photos. Built with Flutter, Clean Architecture, and BLoC.

> In-app subscriptions powered by [RevenueCat](https://revenuecat.com) (`purchases_flutter`)

---

## What it does

Sortlyy lets you blaze through your camera roll one photo at a time — swipe right to keep, left to delete, up to favorite. Designed to make clearing storage feel effortless.

## Tech Stack

- **Flutter** + Dart (SDK ^3.5.4)
- **BLoC** — event-driven state management
- **Clean Architecture** — feature-based, domain/data/presentation layers
- **Supabase** — auth and backend
- **RevenueCat** (`purchases_flutter`) — in-app subscription management
- **Dio** + Either pattern — typed API error handling
- **GetIt** — dependency injection
- **Freezed** — immutable models with code generation
- **photo_manager** — camera roll access
- **flutter_animate** — swipe animations

## Architecture

`
lib/
├── core/ # DI, network, error handling, utils
├── features/ # Self-contained feature modules
│ ├── auth/ # data / domain / presentation
│ └── home/ # data / domain / presentation
└── shared/ # Reusable widgets and themes
`

Each feature owns its data, domain, and presentation layers. Dependencies point inward — domain has no external dependencies.

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Key Patterns

**Error handling** — repositories return `Either<Failure, T>`, BLoCs emit typed states.

**Dependency injection** — all dependencies registered via GetIt in `core/di/injection_container.dart`.

**Code generation** — Freezed for immutable models, json_serializable for API responses.
