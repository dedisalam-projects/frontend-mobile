---
name: dart-flutter-patterns
description: "Use when writing or reviewing Dart and Flutter code — state, widgets, navigation, networking, or architecture. — Production-ready Dart and Flutter patterns covering null safety, immutable state, async composition, widget architecture, popular state management frameworks (BLoC, Riverpod, Provider), GoRouter navigation, Dio networking, Freezed code generation, and clean architecture"
metadata:
  origin: ECC
---

# Dart & Flutter Development Patterns

Production-ready patterns for Dart 3 and Flutter: null safety, immutable state modeling, widget performance, BLoC/Riverpod state, GoRouter, and Dio networking.

## When to Activate

- Designing Flutter features, domain models, or reactive UI components
- Implementing state management with BLoC/Cubit or Riverpod Notifiers
- Configuring GoRouter authentication guards, Dio HTTP interceptors, or global error hooks

## Null Safety & Immutable State

### Dart 3 Pattern Matching & Null Guards
```dart
// Prefer pattern matching and fallbacks over dangerous bang operators (!)
final display = switch (user) {
  User(:final name, :final email) => '$name <$email>',
  null => 'Guest',
};

// Safe nullable promotion with early return
String getUserName(User? user) {
  if (user == null) return 'Guest';
  return user.name; // Promoted to non-null
}
```

### Sealed State Hierarchies & Freezed
```dart
// Sealed classes guarantee exhaustive UI handling
sealed class AsyncState<T> {}
final class Loading<T> extends AsyncState<T> {}
final class Success<T> extends AsyncState<T> { final T data; const Success(this.data); }
final class Failure<T> extends AsyncState<T> { final String message; const Failure(this.message); }

Widget renderState(AsyncState<User> state) => switch (state) {
  Loading() => const CircularProgressIndicator(),
  Success(:final data) => UserCard(user: data),
  Failure(:final message) => ErrorBanner(message: message),
};

// Freezed immutable model
@freezed
class User with _$User {
  const factory User({required String id, required String name, @Default(false) bool isAdmin}) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Async Composition & BuildContext Safety

```dart
// Structured concurrency with Dart 3 record destructuring
Future<Dashboard> loadDashboard(UserRepo users, OrderRepo orders) async {
  final (userList, orderList) = await (users.getAll(), orders.getRecent()).wait;
  return Dashboard(users: userList, orders: orderList);
}

// CRITICAL: Guard context across async gaps in StatefulWidgets
Future<void> _handleLogin() async {
  setState(() => _loading = true);
  try {
    await authService.login(email, password);
    if (!mounted) return; // Guard before using context
    context.go('/dashboard');
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
```

## Widget Architecture & Performance

- **Extract to Classes, Never Helper Methods**: `_buildHeader()` helper methods defeat element reuse and const propagation. Always extract into `StatelessWidget` classes.
- **Const Propagation**: Use `const` widgets to stop tree rebuilds.
- **Scoped Rebuilds**: Isolate consumers to narrow leaf widgets to prevent parent scaffold rebuilds.

## State Management

### BLoC / Cubit
```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authService) : super(const AuthState.initial());
  final AuthService _authService;

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    try {
      final user = await _authService.login(email, password);
      emit(AuthState.authenticated(user));
    } on AuthException catch (e) {
      emit(AuthState.error(e.message));
    }
  }
}
```

### Riverpod (Notifier & Derived Providers)
```dart
@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() => [];
  void add(Product product) {
    state = [...state, CartItem(productId: product.id, quantity: 1)];
  }
}

// Derived selector provider
@riverpod
double cartTotal(Ref ref) {
  final cart = ref.watch(cartNotifierProvider);
  final products = ref.watch(productsProvider).valueOrNull ?? [];
  return cart.fold(0.0, (acc, item) {
    final prod = products.firstWhereOrNull((p) => p.id == item.productId);
    return acc + (prod?.price ?? 0) * item.quantity;
  });
}
```

## Navigation: GoRouter with Auth Guards

```dart
final router = GoRouter(
  refreshListenable: GoRouterRefreshStream(authCubit.stream),
  redirect: (context, state) {
    final authed = context.read<AuthCubit>().state is AuthAuthenticated;
    final onLogin = state.matchedLocation == '/login';
    if (!authed && !onLogin) return '/login';
    if (authed && onLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
  ],
);
```

## Networking: Dio with Auth Interceptor

```dart
final dio = Dio(BaseOptions(baseUrl: const String.fromEnvironment('API_URL')));

dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await secureStorage.read(key: 'jwt');
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  },
  onError: (error, handler) async {
    final isRetry = error.requestOptions.extra['_isRetry'] == true;
    if (!isRetry && error.response?.statusCode == 401) {
      if (await refreshToken()) {
        error.requestOptions.extra['_isRetry'] = true;
        return handler.resolve(await dio.fetch(error.requestOptions));
      }
    }
    handler.next(error);
  },
));
```

## Testing Quick Reference

```dart
// BLoC test
blocTest<AuthCubit, AuthState>(
  'emits loading then authenticated',
  build: () => AuthCubit(FakeAuthService()),
  act: (cubit) => cubit.login('test@test.com', 'pass'),
  expect: () => [const AuthState.loading(), isA<AuthStateAuthenticated>()],
);

// Widget test with Riverpod overrides
testWidgets('Renders badge count', (tester) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [cartCountProvider.overrideWithValue(5)],
    child: const MaterialApp(home: CartBadge()),
  ));
  expect(find.text('5'), findsOneWidget);
});
```

> [!IMPORTANT]
> Always strictly follow the `dart-flutter-patterns` conventions outlined above to ensure workspace consistency and prevent regressions.
