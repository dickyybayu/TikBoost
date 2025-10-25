class Environment {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static String get apiBaseUrl {
    if (isProduction) {
      // Production backend URL (will be provided by Render)
      return 'https://tikboost-backend.onrender.com';
    } else {
      // Development backend URL
      return 'http://localhost:8000';
    }
  }
  
  static String get environment {
    return isProduction ? 'production' : 'development';
  }
}
