import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/main.dart';
import 'package:dash/screens/login_screen.dart';
import 'package:dash/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MyApp routes to login initially when /login is passed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('MyApp routes to dashboard initially when /dashboard is passed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
