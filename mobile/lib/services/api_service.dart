import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/runpod_config.dart';
import '../config/environment.dart';

class ApiService {
  // Use environment-based URL configuration
  static String get baseUrl {
    if (kReleaseMode) {
      // Production mode - use deployed backend
      return Environment.apiBaseUrl;
    } else {
      // Development mode - use local backend
      if (kIsWeb) return 'http://localhost:8000';
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'http://10.0.2.2:8000';
        default:
          return 'http://localhost:8000';
      }
    }
  }

  static const String apiPrefix = '/api/v1';

  // RunPod API Configuration - uses secure storage
  static const String runpodBaseUrl = 'https://api.runpod.ai/v2';

  static String resolvedBaseUrl() => baseUrl;

  // Save user products to backend
  Future<bool> saveUserProducts(
    List<Map<String, dynamic>> products,
    String username,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiPrefix/user/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'products': products}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error saving products: $e');
      return false;
    }
  }

  // Load user products from backend
  Future<List<Map<String, dynamic>>?> loadUserProducts(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/user/products/$username'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['products'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error loading products: $e');
      return null;
    }
  }

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

  // AI Recommendations method using RunPod API
  Future<Map<String, dynamic>?> generateRecommendations({
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      // Check if RunPod is configured
      final isConfigured = await RunPodConfig.isConfigured();
      if (!isConfigured) {
        final statusMessage = await RunPodConfig.getStatusMessage();
        debugPrint('RunPod API not configured: $statusMessage');
        return null;
      }

      // Get credentials securely
      final apiKey = await RunPodConfig.getApiKey();
      final appId = await RunPodConfig.getAppId();

      if (apiKey == null || appId == null) {
        debugPrint('RunPod credentials not available');
        return null;
      }

      // Ensure we have exactly 3 products as required by RunPod API
      if (products.length != 3) {
        debugPrint(
          'RunPod API requires exactly 3 products, got ${products.length}',
        );
        return null;
      }

      // Prepare RunPod API request
      final requestBody = {
        "input": {
          "products":
              products
                  .map(
                    (product) => {
                      "name": product['name'] ?? '',
                      "price": product['price'] ?? 0,
                      "sold": product['sold'] ?? 0,
                    },
                  )
                  .toList(),
          "do_sample": false,
          "max_new_tokens": 300,
        },
      };

      debugPrint('Sending RunPod API request: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$runpodBaseUrl/$appId/run'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 60),
          ); // Longer timeout for AI processing

      debugPrint('RunPod API response status: ${response.statusCode}');
      debugPrint('RunPod API response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if this is an async job (IN_QUEUE)
        if (responseData['status'] == 'IN_QUEUE') {
          final jobId = responseData['id'] as String;
          debugPrint('RunPod job submitted: $jobId, polling for results...');

          // Poll for results
          final result = await _pollRunPodJob(jobId);
          return result;
        }

        // Direct response (synchronous)
        final parsed = responseData['parsed'] as Map<String, dynamic>?;
        final qualityScore = _safeToDouble(responseData['quality_score']);

        if (parsed != null) {
          return {
            'copy1': parsed['copy1'],
            'copy2': parsed['copy2'],
            'copy3': parsed['copy3'],
            'bundle': parsed['bundle'],
            'time': parsed['time'],
            'quality_score': qualityScore,
            'raw_output': responseData['output'],
          };
        } else {
          debugPrint('RunPod API: No parsed data in response');
          return null;
        }
      } else {
        debugPrint(
          'RunPod API error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('RunPod API exception: $e');
      return null;
    }
  }

  // Poll RunPod job until completion
  Future<Map<String, dynamic>?> _pollRunPodJob(String jobId) async {
    const pollingInterval = Duration(seconds: 2); // Poll every 2 seconds
    const maxAttempts = 150; // Max 5 minutes (150 * 2 seconds)
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        debugPrint('Polling RunPod job $jobId, attempt $attempt/$maxAttempts');

        final appId = await RunPodConfig.getAppId();
        final apiKey = await RunPodConfig.getApiKey();

        if (appId == null || apiKey == null) return null;

        final response = await http
            .get(
              Uri.parse('$runpodBaseUrl/$appId/status/$jobId'),
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final statusData = jsonDecode(response.body) as Map<String, dynamic>;
          final status = statusData['status'] as String?;

          debugPrint('RunPod job status: $status');

          if (status == 'COMPLETED') {
            final output = statusData['output'];
            if (output != null) {
              // Parse the completed output
              final parsed = output['parsed'] as Map<String, dynamic>?;
              final qualityScore = _safeToDouble(output['quality_score']);

              if (parsed != null) {
                debugPrint('RunPod job completed successfully!');
                return {
                  'copy1': parsed['copy1'],
                  'copy2': parsed['copy2'],
                  'copy3': parsed['copy3'],
                  'bundle': parsed['bundle'],
                  'time': parsed['time'],
                  'quality_score': qualityScore,
                  'raw_output': output['output'],
                };
              }
            }
            debugPrint('RunPod job completed but no valid output found');
            return null;
          } else if (status == 'FAILED') {
            debugPrint(
              'RunPod job failed: ${statusData['error'] ?? 'Unknown error'}',
            );
            return null;
          } else if (status == 'IN_PROGRESS' || status == 'IN_QUEUE') {
            // Continue polling
            await Future.delayed(pollingInterval);
            continue;
          } else {
            debugPrint('Unknown RunPod job status: $status');
            return null;
          }
        } else {
          debugPrint('RunPod status check failed: ${response.statusCode}');
          await Future.delayed(pollingInterval);
          continue;
        }
      } catch (e) {
        debugPrint('RunPod polling error: $e');
        await Future.delayed(pollingInterval);
        continue;
      }
    }

    debugPrint('RunPod job polling timeout after $maxAttempts attempts');
    return null;
  }

  // Generic HTTP methods for sessions service
  Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse('$baseUrl$apiPrefix$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl$apiPrefix$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    return await http.delete(
      Uri.parse('$baseUrl$apiPrefix$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Save AI recommendations to backend for persistent storage
  Future<bool> saveAIRecommendations(
    Map<String, dynamic> recommendations,
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiPrefix/recommendations/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(recommendations),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('AI recommendations saved to backend successfully');
        return true;
      } else {
        print(
          'Failed to save recommendations to backend: ${response.statusCode}',
        );
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving recommendations to backend: $e');
      return false;
    }
  }

  // Load AI recommendations from backend
  Future<Map<String, dynamic>?> loadAIRecommendations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/recommendations/load'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          print('AI recommendations loaded from backend');
          return responseData['data'];
        } else {
          print('No AI recommendations found in backend');
          return null;
        }
      } else {
        print(
          'Failed to load recommendations from backend: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error loading recommendations from backend: $e');
      return null;
    }
  }

  // Helper method to safely convert any numeric type to double
  static double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }
}
