import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  @visibleForTesting
  static http.Client? mockClient;

  static String get _baseUrl {
    try {
      final url = dotenv.env['API_URL'];
      if (url == null || url.isEmpty) {
        throw Exception('API_URL not found in .env');
      }
      return url;
    } catch (_) {
      // Fallback domain in case .env is missing or invalid
      return 'https://api.primeland.com/api/v1';
    }
  }

  static Future<String?> login(String email, String password, {http.Client? client}) async {
    final httpClient = client ?? mockClient ?? http.Client();
    try {
      final response = await httpClient.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] ?? {};
          
          // Token might be in JSON body or in Set-Cookie headers
          String? token = data['accessToken'];
          
          if (token == null) {
            final rawCookie = response.headers['set-cookie'];
            if (rawCookie != null) {
              final match = RegExp(r'accessToken=([^;]+)').firstMatch(rawCookie);
              if (match != null) {
                token = match.group(1);
              }
            }
          }

          if (token != null) {
            const storage = FlutterSecureStorage();
            await storage.write(key: 'auth_token', value: token);
            return null; // Success
          } else {
            // If token is completely handled by cookies, we can still consider it success
            // but let's just return success for now if the API says success
            return null;
          }
        }
        return 'Invalid response format from server';
      } else {
        try {
           final errData = jsonDecode(response.body);
           return errData['error']?['message'] ?? 'Login failed (${response.statusCode})';
        } catch (_) {
           return 'Login failed with status ${response.statusCode}';
        }
      }
    } catch (e) {
      return 'Gagal ke $_baseUrl\nError: $e';
    }
  }

  static Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
  }
}
