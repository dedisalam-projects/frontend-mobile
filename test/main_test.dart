import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/main.dart';
import 'package:dash/screens/login_screen.dart';
import 'package:dash/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dash/main.dart' as app_main;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  void setDisplaySize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('MyApp renders MaterialApp correctly', (WidgetTester tester) async {
    setDisplaySize(tester);
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));
    
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'PrimeLand');
    expect(materialApp.debugShowCheckedModeBanner, false);
    expect(materialApp.theme?.useMaterial3, true);
    expect(materialApp.theme?.colorScheme.primary.value, 0xFF10B981);
    expect(materialApp.theme?.colorScheme.surface, Colors.white);
    
    await tester.pumpWidget(Container());
  });

  testWidgets('MyApp routes to login initially when /login is passed', (WidgetTester tester) async {
    setDisplaySize(tester);
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
    
    // Clean up to prevent _elements.contains(element) flake
    await tester.pumpWidget(Container());
  });

  testWidgets('MyApp routes to dashboard initially when /dashboard is passed', (WidgetTester tester) async {
    setDisplaySize(tester);
    await tester.pumpWidget(const MyApp(initialRoute: '/dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    
    // Clean up
    await tester.pumpWidget(Container());
  });

  test('main initializes with auth_token and sets dashboard initialRoute', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'test_token'});
    Widget? capturedApp;
    await app_main.main(appRunner: (app) {
      capturedApp = app;
    });

    expect(capturedApp, isA<MyApp>());
    expect((capturedApp as MyApp).initialRoute, '/dashboard');
  });

  test('main initializes without auth_token and sets login initialRoute', () async {
    SharedPreferences.setMockInitialValues({});
    Widget? capturedApp;
    await app_main.main(appRunner: (app) {
      capturedApp = app;
    });

    expect(capturedApp, isA<MyApp>());
    expect((capturedApp as MyApp).initialRoute, '/login');
  });
}


