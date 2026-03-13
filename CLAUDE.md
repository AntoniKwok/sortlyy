# CLAUDE.md — Sortly (Swipe Clean)

## What this app is

**Sortly** (working title: "Swipe Clean") is a Flutter app for iOS and Android. One-liner: _Tinder for your camera roll_ — swipe left to delete, right to keep, up to favorite, until your gallery is clean. The experience is gamified and satisfying, not stressful.

Full product context: see `knowledge.md`.

---

## Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Dart), iOS + Android only |
| State management | BLoC (`flutter_bloc`) |
| Backend / auth | Supabase (`supabase_flutter`) |
| HTTP | Dio |
| Error handling | Either pattern via `dartz` |
| DI | GetIt service locator |
| Code gen | Freezed + json_serializable via build_runner |

---

## Architecture

Clean Architecture with feature-based folder layout. Three layers per feature:

```
lib/features/<feature>/
├── data/          # models, datasources, repository impls
├── domain/        # entities, repository interfaces, use cases
└── presentation/  # bloc (events/states/bloc), pages, widgets
```

Shared:
```
lib/
├── core/
│   ├── constants/    # API, Supabase config
│   ├── di/           # GetIt injection_container.dart
│   ├── errors/       # Failure types (Freezed), exceptions
│   ├── network/      # Dio ApiClient
│   └── utils/        # typedef.dart (ResultStream etc), usecase.dart
└── shared/
    ├── themes/       # AppTheme (dark-first)
    └── widgets/      # Shared loading/error widgets
```

Dependency flow: `Presentation → Domain ← Data`. Domain depends on nothing.

---

## Code conventions

### Error handling
Always use the Either pattern — never throw from repositories:
```dart
// Good
return Right(entity);
return Left(Failure.serverFailure(message: 'reason'));

// Bad — don't let exceptions propagate past the data layer
```

### State management
BLoC only — no Provider, Riverpod, or setState for feature logic. Events are Freezed unions. States are Freezed unions. Keep BLoC thin; business logic lives in use cases.

### Entities vs Models
- **Entity**: pure Dart, Freezed, lives in `domain/entities/`
- **Model**: extends or maps to entity, has `fromJson`/`toJson`, lives in `data/models/`

### Dependency injection
Register everything in `core/di/injection_container.dart`. Use `registerLazySingleton` for expensive/shared objects, `registerFactory` for BLoCs.

### Code generation
Run after any Freezed or JSON annotation change:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
# or watch mode during dev:
flutter packages pub run build_runner watch --delete-conflicting-outputs
```
Generated files (`*.freezed.dart`, `*.g.dart`) are committed to version control.

---

## Adding a new feature — checklist

1. Create `lib/features/<name>/data|domain|presentation/` structure
2. Domain first: entity → repository interface → use case(s)
3. Data: model (with JSON) → datasource → repository impl
4. Presentation: BLoC events/states (Freezed) → BLoC → page → widgets
5. Register in `injection_container.dart`
6. Run build_runner

---

## Key features to build (priority order)

See `knowledge.md` for full UX spec. Build order:

1. **Swipe screen** — the core loop, card physics, action overlays
2. **Session complete screen** — storage freed, stats, streak
3. **Onboarding** — gallery scan, preference pills, swipe tutorial
4. **Home / dashboard** — streak, storage freed, quick start
5. **Paywall / Pro screen**
6. **Settings**

---

## UI rules

- Dark-first: background `#0F0F0F`, photos are the hero
- Action colors: delete `#E53935` (red), keep `#43A047` (green), favorite `#FFB300` (amber)
- Card swipe feel is paramount — rotation on drag, colored overlay + label, snap-back on center release
- Micro-animations are not optional; the experience lives or dies on swipe feel
- Three tap buttons below card mirror swipe gestures
- Session progress bar: thin, top of screen
- Undo toast: 5-second window after each swipe

---

## Photo / gallery access

- **iOS**: `PHPhotoLibrary` via a Flutter plugin (e.g., `photo_manager`)
- **Android**: `MediaStore` via the same plugin
- Photos never leave the device — this is a hard privacy constraint, mention it in UI
- Deletion goes to OS trash/recycle (recoverable for 30 days on iOS) — not permanent immediately

---

## What to avoid

- No web or desktop targets — iOS + Android only
- No setState for feature-level state — BLoC only
- Don't expose raw exceptions to the UI layer — map to Failure types
- Don't skip code generation after annotation changes
- Keep BLoC events/states as Freezed sealed unions, not plain classes
