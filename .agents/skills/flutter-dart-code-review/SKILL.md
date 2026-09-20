---
name: flutter-dart-code-review
description: "Use when reviewing Flutter or Dart code, whatever state management library the project uses. — Library-agnostic Flutter/Dart code review checklist covering widget best practices, state management patterns (BLoC, Riverpod, Provider, GetX, MobX, Signals), Dart idioms, performance, accessibility, security, and clean architecture"
metadata:
  origin: ECC
---

# Flutter/Dart Code Review Best Practices

Comprehensive, library-agnostic checklist for reviewing Flutter/Dart applications across state management, architecture, performance, accessibility, and security.

## 1. Project Health & Dart Idioms

- [ ] **Project Structure**: Consistent feature-first or layer-first layout; clean separation between UI, domain logic, and data repositories.
- [ ] **Dependencies & Lints**: Pinned dependencies in `pubspec.yaml`; strict analyzer flags (`strict-casts`, `strict-inference`, `strict-raw-types`) in `analysis_options.yaml`.
- [ ] **Logging**: No `print()` statements in production code — use `dart:developer` `log()` or a structured logger.
- [ ] **Dart 3 Features**: Prefer pattern matching (`switch` expressions, `if-case`) and records over throwaway DTOs.
- [ ] **Null Safety & Types**: Avoid excessive `!` bang operators and `late` fields; use localized null promotions; specify exception types on `catch (e)`.
- [ ] **Async Disciplines**: Never leave unawaited futures unhandled (use `await` or `unawaited()`); avoid redundant `async` on functions that don't `await`.

## 2. Widget Best Practices

- [ ] **Decomposition**: `build()` methods under ~80 lines. Split rebuild boundaries by extracting widgets to classes, not `_build*()` helper methods.
- [ ] **Const Usage**: Use `const` constructors and collection literals wherever fields are immutable to prevent tree rebuilds.
- [ ] **Keys & Identity**: Use `ValueKey` in lists/grids to preserve state across reorders; avoid `UniqueKey()` in `build()`.
- [ ] **Design Tokens**: Retrieve styles and colors via `Theme.of(context).colorScheme` and `textTheme`; avoid raw hex codes or magic margins.
- [ ] **Build Purity**: Zero network calls, file I/O, regex compilations, or stream subscriptions inside `build()`.

## 3. State Management (Library-Agnostic)

- [ ] **Separation**: Business logic decoupled from widgets into controllers, stores, or BLoCs with injected repositories.
- [ ] **State Modeling**: Represent mutually exclusive states via sealed classes or unions (loading, success, error) rather than multiple boolean flags.
- [ ] **Immutability & Reactions**: Ensure state objects implement equality (`freezed`, `Equatable`); mutate reactive state strictly through actions or signal APIs.
- [ ] **Async Gaps & Context**: Verify `if (!mounted) return;` or `context.mounted` checks before using `BuildContext` across async gaps.
- [ ] **Disposal**: Cancel stream subscriptions, timers, and controllers in `dispose()` / `close()`.

```dart
// GOOD: Sealed types eliminate impossible states
sealed class UserState {}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState { final User user; const UserLoaded(this.user); }
class UserError extends UserState { final String message; const UserError(this.message); }
```

## 4. Performance & Rendering

- [ ] **Rebuild Scoping**: Scope listeners (Builder, Consumer, Obx) to the smallest possible subtrees; use selectors to observe specific fields.
- [ ] **List Rendering**: Use `ListView.builder` / `GridView.builder` for unbounded or dynamic items; paginate large datasets.
- [ ] **Image Optimization**: Specify `cacheWidth`/`cacheHeight` on `Image.asset` and use cached network image providers with placeholders.
- [ ] **Repaint Boundaries**: Wrap complex or frequently repainting widgets in `RepaintBoundary`.
- [ ] **Animation Cost**: Prefer `FadeTransition` or `AnimatedOpacity` over raw `Opacity` widgets; avoid clipping inside render loops.

## 5. Testing & Quality Gates

- [ ] **Coverage**: 80%+ coverage on business logic, repositories, and state machines.
- [ ] **Isolation**: Mock or fake external HTTP/database dependencies; test behavior rather than internal private state.
- [ ] **Async Tests**: Use `pumpAndSettle()` or timed `pump(Duration)` in widget tests to avoid timing flakiness.

## 6. Accessibility & Localization

- [ ] **Semantics**: Provide `Semantics(label: ...)` for icon-only actions; wrap decorative assets in `ExcludeSemantics`.
- [ ] **Touch Targets & Contrast**: Minimum 48x48 pt touch targets; minimum 4.5:1 text contrast ratio against background.
- [ ] **L10n**: Zero hardcoded UI strings; extract strings into ARB or localization catalogs with support for plurals and ICU formatting.

## 7. Security & Platform Integration

- [ ] **Secure Storage**: Store tokens and credentials in platform Keychain / EncryptedSharedPreferences (never plain SharedPreferences).
- [ ] **API Secrets**: Inject secrets via `--dart-define` or `.env` excluded from source control; never commit secret keys.
- [ ] **Network**: Enforce HTTPS and validate server certificates; sanitize all deep link inputs.
- [ ] **Platform Adaptation**: Wrap screens with `SafeArea`; respect platform navigation (Android back button & iOS back swipe).

## 8. Routing & Error Handling

- [ ] **Type-Safe Routing**: Use typed route arguments (e.g. GoRouter extra or typed routes); centralize authentication guards.
- [ ] **Global Error Traps**: Wire `FlutterError.onError` and `PlatformDispatcher.instance.onError` to Crashlytics/Sentry.
- [ ] **User-Facing Errors**: Map low-level socket/HTTP exceptions to actionable, user-friendly messages.

## State Management Quick Reference

| Principle | BLoC/Cubit | Riverpod | Provider | GetX | MobX | Signals |
|---|---|---|---|---|---|---|
| State container | `Bloc`/`Cubit` | `Notifier`/`AsyncNotifier` | `ChangeNotifier` | `GetxController` | `Store` | `signal()` |
| UI consumer | `BlocBuilder` | `ConsumerWidget` | `Consumer` | `Obx` | `Observer` | `Watch` |
| Selector | `BlocSelector` | `ref.watch(p.select)` | `Selector` | N/A | computed | `computed()` |
| Side effects | `BlocListener` | `ref.listen` | callback | `ever()`/`once()` | `reaction` | `effect()` |
| Disposal | `BlocProvider` | `.autoDispose` | `Provider` | `onClose()` | `ReactionDisposer` | manual |

## Sources

- [Effective Dart: Style & Design](https://dart.dev/effective-dart)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter Accessibility & Localization](https://docs.flutter.dev/ui/accessibility-and-internationalization)

> [!IMPORTANT]
> Always strictly follow the `flutter-dart-code-review` conventions outlined above to ensure workspace consistency and prevent regressions.
