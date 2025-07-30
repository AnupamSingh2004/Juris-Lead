import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthConfig {
  static String get androidClientId => 
    dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? _throwMissingEnvError('GOOGLE_ANDROID_CLIENT_ID');
  
  static String get webClientId => 
    dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? _throwMissingEnvError('GOOGLE_WEB_CLIENT_ID');

  static String get serverClientId => webClientId;
  
  static String get apiBaseUrl {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      _throwMissingEnvError('API_BASE_URL');
    }
    
    // Always use the configured base URL without modification
    // The .env file should contain the correct IP for the current network
    return baseUrl!;
  }

  static String _throwMissingEnvError(String key) {
    throw Exception(
      'Missing required environment variable: $key\n'
      'Please check your .env file and ensure it contains:\n'
      '$key=your_actual_value_here'
    );
  }
  
  static void validateConfig() {
    try {
      androidClientId;
      webClientId;
      print('✅ Google Auth configuration loaded successfully');
    } catch (e) {
      print('❌ Google Auth configuration error: $e');
      rethrow;
    }
  }
  
}
