import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Dynamically resolve base URL for web vs Android emulator vs others
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    // defaultTargetPlatform is safe to use without dart:io
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://localhost:8000';
    }
  }

  static const String apiPrefix = '/api/v1';
  static String resolvedBaseUrl() => baseUrl;

  // FastAPI uses OAuth2PasswordRequestForm on /auth/login (form-encoded)
  Future<String?> login(String emailOrUsername, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$apiPrefix/auth/login'),
            // Sending as form data automatically sets content-type to x-www-form-urlencoded
            body: {
              'username':
                  emailOrUsername, // backend treats this as email in authenticate()
              'password': password,
            },
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Get user profile with token
  Future<Map<String, dynamic>?> getUserProfile(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$apiPrefix/auth/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Backend expects email, username, password JSON and returns 200 on success
  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$apiPrefix/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (!ok && kDebugMode) {
        debugPrint('Register failed: ${response.statusCode} ${response.body}');
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  // Same as register() but returns error details for UI display
  Future<(bool, String?)> registerWithDetail({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$apiPrefix/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (ok) return (true, null);
      try {
        final body = jsonDecode(response.body);
        final detail = body is Map<String, dynamic> ? body['detail'] : null;
        return (false, detail?.toString());
      } catch (_) {
        return (false, 'Registration failed (${response.statusCode}).');
      }
    } catch (e) {
      return (false, 'Cannot reach server. Check connection.');
    }
  }

  Future<String?> loginWithGoogle(String idToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$apiPrefix/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Uri?> getTikTokAuthUrl() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$apiPrefix/auth/tiktok/start'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final url = data['auth_url'] as String?;
        if (url != null) return Uri.parse(url);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Ping backend health endpoint to verify connectivity from the device
  Future<(bool, String)> healthCheck() async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        return (true, 'OK');
      }
      return (false, 'HTTP ${resp.statusCode}');
    } catch (e) {
      return (false, e.toString());
    }
  }
}
