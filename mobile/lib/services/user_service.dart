import '../services/subscription_service.dart';

class UserService {
  static String? _currentUsername;
  static String? _currentEmail;
  static String? _accessToken;

  // Set user data after successful login
  static void setUserData({
    required String username,
    required String email,
    String? token,
  }) {
    _currentUsername = username;
    _currentEmail = email;
    _accessToken = token;
  }

  // Get current username
  static String get currentUsername => _currentUsername ?? 'User';

  // Get current email
  static String get currentEmail => _currentEmail ?? '';

  // Get access token
  static String? get accessToken => _accessToken;

  // Get current username as async method (for consistency with service patterns)
  static Future<String?> getUsername() async {
    return _currentUsername;
  }

  // Check if user is logged in
  static bool get isLoggedIn =>
      _accessToken != null && _currentUsername != null;

  // Clear user data on logout
  static void logout() {
    _currentUsername = null;
    _currentEmail = null;
    _accessToken = null;

    // IMPORTANT: Clear subscription data when logging out
    SubscriptionService.clearSubscription();
  }

  // For demo purposes, set dummy data
  static void setDemoUser() {
    _currentUsername = 'Krisna Putra Purnomo';
    _currentEmail = 'krisna@example.com';
    _accessToken = 'demo_token';
  }
}
