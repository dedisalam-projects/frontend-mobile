import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'auth_token': 'fake-token'});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const Scaffold(body: Text('Login Screen')),
      },
      initialRoute: '/dashboard',
    );
  }

  group('DashboardScreen', () {
    testWidgets('renders Dashboard title and welcome text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome to the Dashboard!'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('logout button clears token and navigates to login', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
