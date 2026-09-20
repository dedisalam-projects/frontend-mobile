import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:dash/screens/login_screen.dart';
import 'package:dash/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    AuthService.mockClient = mockClient;
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(Uri.parse('http://192.168.1.4:8080/api/auth/login'));
  });


  tearDown(() {
    AuthService.mockClient = null;
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      routes: {
        '/dashboard': (context) => const Scaffold(body: Text('Dashboard Screen')),
      },
      home: const LoginScreen(),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders initial UI elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Welcome to PrimeLand!'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final passwordField = find.byType(TextField).last;
      
      // Initially obscureText is true
      TextField fieldWidget = tester.widget(passwordField);
      expect(fieldWidget.obscureText, true);

      // Tap visibility icon (initially it's visibility)
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Now obscureText should be false
      fieldWidget = tester.widget(passwordField);
      expect(fieldWidget.obscureText, false);

      // Tap again (now it's visibility_off)
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      
      fieldWidget = tester.widget(passwordField);
      expect(fieldWidget.obscureText, true);
    });

    testWidgets('toggles remember me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final checkbox = find.byType(Checkbox);
      
      Checkbox boxWidget = tester.widget(checkbox);
      expect(boxWidget.value, false);

      await tester.tap(checkbox);
      await tester.pump();

      boxWidget = tester.widget(checkbox);
      expect(boxWidget.value, true);
    });

    testWidgets('shows loading and navigates to dashboard on successful login', (WidgetTester tester) async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {'accessToken': 'fake-token'}
              }),
              200,
            );
          });

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).first, 'test@test.com');
      await tester.enterText(find.byType(TextField).last, 'password');

      await tester.tap(find.text('Sign In'));
      await tester.pump(); // Start loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Finish loading and navigation

      expect(find.text('Dashboard Screen'), findsOneWidget);
    });

    testWidgets('shows error message on failed login', (WidgetTester tester) async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return http.Response(
              jsonEncode({
                'error': {'message': 'Invalid credentials'}
              }),
              401,
            );
          });

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).first, 'test@test.com');
      await tester.enterText(find.byType(TextField).last, 'wrong_password');

      // Submit via keyboard action on password field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(); // Start loading
      await tester.pumpAndSettle(); // Finish loading

      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget); // Button is back
    });
  });
}
