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
  
  // Check if user is logged in
  static bool get isLoggedIn => _accessToken != null && _currentUsername != null;
  
  // Clear user data on logout
  static void logout() {
    _currentUsername = null;
    _currentEmail = null;
    _accessToken = null;
  }
  
  // For demo purposes, set dummy data
  static void setDemoUser() {
    _currentUsername = 'Krisna Putra Purnomo';
    _currentEmail = 'krisna@example.com';
    _accessToken = 'demo_token';
  }
}
