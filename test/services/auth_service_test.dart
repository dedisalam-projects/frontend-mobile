import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dash/services/auth_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(Uri.parse('http://192.168.1.4:8080/api/auth/login'));
  });


  group('AuthService', () {
    test('login success with token in body', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': {'accessToken': 'fake-token'}
            }),
            200,
          ));

      final result = await AuthService.login('test@test.com', 'password', client: mockClient);
      
      expect(result, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), 'fake-token');
    });

    test('login success with token in cookie', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': {}
            }),
            200,
            headers: {
              'set-cookie': 'accessToken=cookie-token; Path=/; HttpOnly'
            }
          ));

      final result = await AuthService.login('test@test.com', 'password', client: mockClient);
      
      expect(result, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), 'cookie-token');
    });

    test('login success but no token provided anywhere', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': {}
            }),
            200,
          ));

      final result = await AuthService.login('test@test.com', 'password', client: mockClient);
      
      expect(result, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
    });

    test('login fails due to server error (json error body)', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'error': {'message': 'Invalid credentials'}
            }),
            401,
          ));

      final result = await AuthService.login('test@test.com', 'wrong_password', client: mockClient);
      
      expect(result, 'Invalid credentials');
    });

    test('login fails due to server error (non-json error body)', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            'Internal Server Error',
            500,
          ));

      final result = await AuthService.login('test@test.com', 'password', client: mockClient);
      
      expect(result, 'Login failed with status 500');
    });

    test('login fails due to network error', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(Exception('Network Error'));

      final result = await AuthService.login('test@test.com', 'password', client: mockClient);
      
      expect(result, startsWith('Gagal ke http://192.168.1.4:8080/api'));
    });

    test('login fails due to invalid response format from server', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'success': false,
            }),
            200,
          ));

      final result = await AuthService.login('test@test.com', 'password', client: mockClient);
      
      expect(result, 'Invalid response format from server');
    });

    test('logout successfully clears token', () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'existing-token'});
      
      await AuthService.logout();
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
    });
  });
}
