// RunPod API Configuration - DEVELOPMENT EXAMPLE
// COPY this file to runpod_config.dart and add your real credentials
// This file shows the structure but contains dummy data

class RunPodConfig {
  // DEVELOPMENT: Put your real API keys here (this file is gitignored)
  static const String _devApiKey =
      'rp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; // Your real API key
  static const String _devAppId =
      'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'; // Your real App ID

  // Get API key from secure source
  static Future<String?> getApiKey() async {
    // TODO: For production, use flutter_secure_storage:
    // final secureStorage = FlutterSecureStorage();
    // return await secureStorage.read(key: 'runpod_api_key');

    // For development - replace with your real key
    return _devApiKey.length > 20 ? _devApiKey : null;
  }

  // Get App ID from secure source
  static Future<String?> getAppId() async {
    // TODO: For production, use flutter_secure_storage:
    // final secureStorage = FlutterSecureStorage();
    // return await secureStorage.read(key: 'runpod_app_id');

    // For development - replace with your real app ID
    return _devAppId.length > 20 ? _devAppId : null;
  }

  // Validation method
  static Future<bool> isConfigured() async {
    final apiKey = await getApiKey();
    final appId = await getAppId();
    return apiKey != null &&
        appId != null &&
        apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        !apiKey.startsWith('rp_xxxx') &&
        !appId.startsWith('xxxx');
  }

  // Store credentials securely (call this once during setup)
  static Future<void> setCredentials({
    required String apiKey,
    required String appId,
  }) async {
    // TODO: Implement with flutter_secure_storage
    // final secureStorage = FlutterSecureStorage();
    // await secureStorage.write(key: 'runpod_api_key', value: apiKey);
    // await secureStorage.write(key: 'runpod_app_id', value: appId);

    print('For now, manually edit _devApiKey and _devAppId in this file');
    print('In production, use secure storage instead!');
  }

  static Future<String> getStatusMessage() async {
    final configured = await isConfigured();
    if (!configured) {
      return 'RunPod API not configured. Replace dummy keys with real credentials.';
    }
    return 'RunPod API configured and ready';
  }
}

/*
SETUP INSTRUCTIONS:
1. Get your RunPod credentials from https://runpod.ai
2. Replace _devApiKey with your real API key (starts with rp_)
3. Replace _devAppId with your real App ID (UUID format)
4. Test the configuration in the app
5. For production: implement flutter_secure_storage

SECURITY NOTES:
- This file is gitignored for safety
- Never commit real API keys to version control
- Use environment variables or secure storage in production
- Rotate your API keys regularly
*/
