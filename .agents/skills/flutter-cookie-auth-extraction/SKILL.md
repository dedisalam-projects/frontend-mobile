---
name: flutter-cookie-auth-extraction
description: "Use when migrating or connecting a Flutter app to a web-focused backend that strictly issues authentication tokens via HTTP-Only Set-Cookie headers rather than JSON bodies."
tier: local
target-stacks: ["flutter", "dart", "http"]
metadata:
  origin: auto-extracted
---

# Handling HTTP-Only Cookie Auth in Flutter via Set-Cookie Header Extraction

**Extracted:** 2026-09-20
**Context:** When a Flutter mobile application authenticates against a backend (e.g., NestJS, Express, Spring Boot) that is configured to secure tokens using HTTP-Only cookies.

## Problem
Web-focused backends often strip sensitive tokens (like `accessToken` or `refreshToken`) from the JSON response body and send them purely via the `Set-Cookie` header. Browsers handle this automatically, but Flutter's `package:http` does not. This results in the Flutter client receiving an apparently empty JSON data payload, causing `token == null` validation errors or infinite loading states.

## Solution
Instead of forcing the backend to compromise its security posture by altering its architecture for mobile, extract the token directly from the HTTP response headers in Dart using Regular Expressions.

### Executable Code Block

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Example inside an AuthService login method
final response = await http.post(
  Uri.parse('http://your-backend.com/api/v1/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);

if (response.statusCode == 200 || response.statusCode == 201) {
  final jsonResponse = jsonDecode(response.body);
  
  if (jsonResponse['success'] == true) {
    final data = jsonResponse['data'] ?? {};
    
    // 1. Try JSON body first (fallback if backend behaves normally)
    String? token = data['accessToken'];
    
    // 2. Extract from Set-Cookie header if JSON body is empty
    if (token == null) {
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        // Regex extracts value between "accessToken=" and the next semicolon
        final match = RegExp(r'accessToken=([^;]+)').firstMatch(rawCookie);
        if (match != null) {
          token = match.group(1);
        }
      }
    }

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      return null; // Success
    }
  }
}
```

## When to Use
- When `http.post` returns a successful status code (200/201) but the expected token in JSON is `null`.
- When connecting Flutter to a NestJS/Express backend that utilizes HTTP-Only cookies for cross-site scripting (XSS) mitigation.
