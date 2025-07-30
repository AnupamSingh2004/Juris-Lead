import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/google_auth_config.dart';

class ApiService {

  // Use the baseUrl from config
  static String get baseUrl => GoogleAuthConfig.apiBaseUrl;
  static const _storage = FlutterSecureStorage();

  // Store tokens securely
  static Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Clear tokens
  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // Refresh access token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Make authenticated request with automatic token refresh
  static Future<http.Response> _makeAuthenticatedRequest(
      Future<http.Response> Function(String token) request,
      ) async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('No access token available');
    }

    http.Response response = await request(accessToken);

    // If token expired, try to refresh and retry
    if (response.statusCode == 401) {
      bool refreshed = await refreshToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        if (accessToken != null) {
          response = await request(accessToken);
        }
      }
    }

    return response;
  }

  // Login with email and password
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10)); // Added timeout

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['data']?['tokens'] != null) {
          await storeTokens(
            data['data']['tokens']['access'],
            data['data']['tokens']['refresh'],
          );
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('Login error: $e'); // Add logging
      return {'success': false, 'message': 'Network error: Please check your connection'};
    }
  }

  // Google Sign In
  static Future<Map<String, dynamic>> googleLogin(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'access_token': accessToken,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['data']?['tokens'] != null) {
          await storeTokens(
            data['data']['tokens']['access'],
            data['data']['tokens']['refresh'],
          );
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Google login failed'};
      }
    } catch (e) {
      print('Google login error: $e');
      return {'success': false, 'message': 'Network error: Please check your connection'};
    }
  }
  // Register user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      print('Attempting registration for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'password_confirm': password, // Add password confirmation
          'first_name': firstName,
          'last_name': lastName,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'errors': data['errors'] ?? {}
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'Network error: Please check your connection and try again'
      };
    }
  }
  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _makeAuthenticatedRequest((token) async {
        return await http.post(
          Uri.parse('$baseUrl/auth/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      });

      await clearTokens();

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Logout failed'};
      }
    } catch (e) {
      await clearTokens(); // Clear tokens even if request fails
      return {'success': true}; // Return success since tokens are cleared
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _makeAuthenticatedRequest((token) async {
        return await http.get(
          Uri.parse('$baseUrl/auth/profile/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to get profile'};
      }
    } catch (e) {
      print('Get profile error: $e');
      return {'success': false, 'message': 'Network error: Please check your connection'};
    }
  }

  // Upload prescriptions
  static Future<Map<String, dynamic>> uploadPrescriptions({
    required List<String> imagePaths,
    String? title,
    String? description,
    String? doctorName,
    String? hospitalName,
    String? prescriptionDate,
  }) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/prescriptions/upload/'),
      );

      request.headers['Authorization'] = 'Bearer $accessToken';

      // Add images
      for (int i = 0; i < imagePaths.length; i++) {
        var file = await http.MultipartFile.fromPath(
          'images',
          imagePaths[i],
        );
        request.files.add(file);
      }

      // Add optional fields
      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (doctorName != null) request.fields['doctor_name'] = doctorName;
      if (hospitalName != null) request.fields['hospital_name'] = hospitalName;
      if (prescriptionDate != null) request.fields['prescription_date'] = prescriptionDate;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle token refresh if needed
      if (response.statusCode == 401) {
        bool refreshed = await refreshToken();
        if (refreshed) {
          final newAccessToken = await getAccessToken();
          if (newAccessToken != null) {
            request.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryStreamedResponse = await request.send();
            final retryResponse = await http.Response.fromStream(retryStreamedResponse);
            final data = jsonDecode(retryResponse.body);
            
            if (retryResponse.statusCode == 201) {
              return {'success': true, 'data': data};
            } else {
              return {'success': false, 'message': data['error'] ?? 'Upload failed'};
            }
          }
        }
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Upload failed'};
      }
    } catch (e) {
      print('Upload prescriptions error: $e');
      return {'success': false, 'message': 'Network error: Please check your connection'};
    }
  }

  // Get user prescriptions
  static Future<Map<String, dynamic>> getUserPrescriptions() async {
    try {
      final response = await _makeAuthenticatedRequest((token) async {
        return await http.get(
          Uri.parse('$baseUrl/prescriptions/prescriptions/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to get prescriptions'};
      }
    } catch (e) {
      print('Get prescriptions error: $e');
      return {'success': false, 'message': 'Network error: Please check your connection'};
    }
  }

  // Get prescription analytics
  static Future<Map<String, dynamic>> getPrescriptionAnalytics() async {
    try {
      final response = await _makeAuthenticatedRequest((token) async {
        return await http.get(
          Uri.parse('$baseUrl/prescriptions/analytics/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to get analytics'};
      }
    } catch (e) {
      print('Get analytics error: $e');
      return {'success': false, 'message': 'Network error: Please check your connection'};
    }
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/health/'), // Add this endpoint to your Django app
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}