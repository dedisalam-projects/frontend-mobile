import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:dash/screens/login_screen.dart';
import 'package:dash/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
    testWidgets('renders initial UI elements correctly and styling', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Welcome to PrimeLand!'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Assert LinearGradient (kills numeric mutations on stops)
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(Scaffold),
        matching: find.byType(Container).first,
      ));
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.stops, [0.0, 0.4, 1.0]);

      // Assert padding (kills 32.0, 24.0)
      final singleChildScrollView = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(singleChildScrollView.padding, const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0));

      // Assert SizedBoxes
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(sizedBoxes.any((box) => box.height == 48), true);
      expect(sizedBoxes.any((box) => box.height == 32), true);
      expect(sizedBoxes.any((box) => box.height == 8), true);
      expect(sizedBoxes.any((box) => box.height == 24), true);
      expect(sizedBoxes.any((box) => box.height == 16), true);

      // Assert Icon
      final icon = tester.widget<Icon>(find.byIcon(Icons.lock));
      expect(icon.size, 64);
      
      // Assert TextField styling (kills 12, 16)
      final emailField = tester.widget<TextField>(find.byType(TextField).first);
      final emailDec = emailField.decoration!;
      expect(emailDec.contentPadding, const EdgeInsets.symmetric(horizontal: 16, vertical: 16));
      expect((emailDec.border as OutlineInputBorder).borderRadius, BorderRadius.circular(12));
      
      final passField = tester.widget<TextField>(find.byType(TextField).last);
      final passDec = passField.decoration!;
      expect((passDec.border as OutlineInputBorder).borderRadius, BorderRadius.circular(12));
      expect(passDec.contentPadding, const EdgeInsets.symmetric(horizontal: 16, vertical: 16));

      // Assert Button styling and text
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final shape = button.style?.shape?.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
      
      final buttonText = tester.widget<Text>(find.text('Sign In'));
      expect(buttonText.style?.fontSize, 16);
      
      final buttonSizedBox = tester.widget<SizedBox>(find.ancestor(of: find.byType(FilledButton), matching: find.byType(SizedBox)).first);
      expect(buttonSizedBox.height, 54);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final passwordField = find.byType(TextField).last;
      
      TextField fieldWidget = tester.widget(passwordField);
      expect(fieldWidget.obscureText, true);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      fieldWidget = tester.widget(passwordField);
      expect(fieldWidget.obscureText, false);

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
          )).thenAnswer((invocation) async {
            final bodyStr = invocation.namedArguments[#body] as String;
            final bodyJson = jsonDecode(bodyStr);
            expect(bodyJson['email'], 'test@test.com');
            expect(bodyJson['password'], 'password');
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
      await tester.pump(); 

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(indicator.strokeWidth, 2);

      await tester.pumpAndSettle(); 

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

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(); 
      await tester.pumpAndSettle(); 

      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
    testWidgets('taps Forgot password button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Forgot password?'));
      await tester.pump();
    });
  });
}

