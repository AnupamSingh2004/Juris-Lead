import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/google_auth_config.dart';
import '../models/analysis_models.dart';

class ApiService {

  // Use the baseUrl from config with fallback
  static String get baseUrl {
    try {
      return GoogleAuthConfig.apiBaseUrl;
    } catch (e) {
      // Fallback to localhost if .env is not configured
      return 'http://localhost:8001/api/v1';
    }
  }

  // Try multiple base URLs for better connectivity
  static Future<String> _getWorkingBaseUrl() async {
    final primaryUrl = baseUrl;
    
    // First try the primary URL
    try {
      final testUrl = primaryUrl.replaceAll('/api/v1', '/leads/analyze-case/');
      final response = await http.head(Uri.parse(testUrl)).timeout(Duration(seconds: 5));
      if (response.statusCode < 500) {
        print('✅ Primary URL working: $primaryUrl');
        return primaryUrl;
      }
    } catch (e) {
      print('❌ Primary URL failed: $primaryUrl - $e');
    }

    // Try fallback URLs
    for (final fallbackUrl in GoogleAuthConfig.fallbackUrls) {
      try {
        final testUrl = fallbackUrl.replaceAll('/api/v1', '/leads/analyze-case/');
        final response = await http.head(Uri.parse(testUrl)).timeout(Duration(seconds: 5));
        if (response.statusCode < 500) {
          print('✅ Fallback URL working: $fallbackUrl');
          return fallbackUrl;
        }
      } catch (e) {
        print('❌ Fallback URL failed: $fallbackUrl - $e');
        continue;
      }
    }

    print('⚠️ All URLs failed, using primary: $primaryUrl');
    return primaryUrl;
  }
  static const _storage = FlutterSecureStorage();
  
  // Timeout duration for requests
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration longTimeout = Duration(seconds: 120);
  static const Duration aiModelTimeout = Duration(seconds: 300); // 5 minutes for AI processing

  // API Endpoints configuration
  static const Map<String, String> endpoints = {
    'healthCheck': '/legal/health/',
    'login': '/auth/login/',
    'googleLogin': '/auth/google-login/',
    'logout': '/auth/logout/',
    'register': '/auth/register/',
    'profile': '/auth/profile/',
    'refreshToken': '/auth/token/refresh/',
    'analyzeCase': '/leads/analyze-case/',
    'extractText': '/legal/extract-text/',
    'summarizeDocument': '/legal/summarize-document/',
    'history': '/auth/history/activities/',
    'historyTypes': '/auth/history/activities/types/',
    'historyClear': '/auth/history/activities/clear/',
    'historyExport': '/auth/history/activities/export/',
    'lawyers': '/api/lawyers/',
    'cases': '/api/cases/',
    'searchCases': '/api/search-cases/',
    'updateProfile': '/auth/profile/update/',
    'changePassword': '/auth/change-password/',
    'uploadPrescriptions': '/prescriptions/upload/',
    'getPrescriptions': '/prescriptions/prescriptions/',
    'getAnalytics': '/prescriptions/analytics/',
  };

  // Store user data securely
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: 'user_profile', value: jsonEncode(userData));
    await _storage.write(key: 'juris-logged-in', value: 'true');
  }

  // Get user data
  static Future<UserProfile?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: 'user_profile');
      if (userData != null) {
        return UserProfile.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final isLoggedIn = await _storage.read(key: 'juris-logged-in');
    final accessToken = await getAccessToken();
    return isLoggedIn == 'true' && accessToken != null;
  }

  // Check if user is a lawyer
  static Future<bool> isLawyer() async {
    final user = await getCurrentUser();
    return user?.userRole == 'lawyer';
  }

  // Check if user is a client
  static Future<bool> isClient() async {
    final user = await getCurrentUser();
    return user?.userRole == 'client';
  }

  // Generic request method with error handling
  static Future<http.Response> _makeRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl${endpoints[endpoint] ?? endpoint}');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    if (requiresAuth) {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        requestHeaders['Authorization'] = 'Bearer $accessToken';
      }
    }

    http.Response response;
    final requestTimeout = timeout ?? defaultTimeout;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders).timeout(requestTimeout);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(requestTimeout);
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(requestTimeout);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders).timeout(requestTimeout);
          break;
        default:
          throw ApiError(message: 'Unsupported HTTP method: $method');
      }

      // Handle token refresh for 401 responses
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await refreshToken();
        if (refreshed) {
          final newAccessToken = await getAccessToken();
          if (newAccessToken != null) {
            requestHeaders['Authorization'] = 'Bearer $newAccessToken';
            switch (method.toUpperCase()) {
              case 'GET':
                response = await http.get(url, headers: requestHeaders).timeout(requestTimeout);
                break;
              case 'POST':
                response = await http.post(
                  url,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null,
                ).timeout(requestTimeout);
                break;
              case 'PUT':
                response = await http.put(
                  url,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null,
                ).timeout(requestTimeout);
                break;
              case 'DELETE':
                response = await http.delete(url, headers: requestHeaders).timeout(requestTimeout);
                break;
            }
          }
        }
      }

      return response;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiError(
          message: 'Request timeout: Please check your connection',
          status: 408,
          details: e,
        );
      }
      throw ApiError(
        message: 'Network error: ${e.toString()}',
        status: 0,
        details: e,
      );
    }
  }

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

  // ================ NEW COMPREHENSIVE API METHODS ================

  // Health Check with new method
  static Future<Map<String, dynamic>> healthCheckNew() async {
    try {
      final response = await _makeRequest('healthCheck', 'GET', requiresAuth: false);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        throw ApiError(
          message: 'Health check failed',
          status: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Health check failed: ${e.toString()}');
    }
  }

  // Enhanced Login with new model
  static Future<Map<String, dynamic>> loginNew(LoginRequest request) async {
    try {
      final response = await _makeRequest(
        'login', 
        'POST', 
        body: request.toJson(),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Store tokens and user data
          if (data['data']?['tokens'] != null) {
            await storeTokens(
              data['data']['tokens']['access'],
              data['data']['tokens']['refresh'],
            );
          }
          if (data['data']?['user'] != null) {
            await storeUserData(data['data']['user']);
          }
          return {'success': true, 'data': data['data']};
        }
      }
      
      final data = jsonDecode(response.body);
      return {
        'success': false, 
        'message': data['message'] ?? 'Login failed',
        'details': data,
      };
    } catch (e) {
      if (e is ApiError) rethrow;
      return {'success': false, 'message': 'Login request failed: ${e.toString()}'};
    }
  }

  // Enhanced Google Login
  static Future<Map<String, dynamic>> googleLoginNew(GoogleLoginRequest request) async {
    try {
      final response = await _makeRequest(
        'googleLogin', 
        'POST', 
        body: request.toJson(),
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Store tokens and user data
          if (data['data']?['tokens'] != null) {
            await storeTokens(
              data['data']['tokens']['access'],
              data['data']['tokens']['refresh'],
            );
          }
          if (data['data']?['user'] != null) {
            await storeUserData(data['data']['user']);
          }
          return {'success': true, 'data': data['data']};
        }
      }
      
      final data = jsonDecode(response.body);
      return {
        'success': false, 
        'message': data['message'] ?? 'Google login failed',
        'details': data,
      };
    } catch (e) {
      if (e is ApiError) rethrow;
      return {'success': false, 'message': 'Google login failed: ${e.toString()}'};
    }
  }

  // Enhanced Register
  static Future<Map<String, dynamic>> registerNew(RegisterRequest request) async {
    try {
      final response = await _makeRequest(
        'register', 
        'POST', 
        body: request.toJson(),
        requiresAuth: false,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      
      final data = jsonDecode(response.body);
      return {
        'success': false, 
        'message': data['message'] ?? 'Registration failed',
        'errors': data['errors'] ?? {},
      };
    } catch (e) {
      if (e is ApiError) rethrow;
      return {'success': false, 'message': 'Registration failed: ${e.toString()}'};
    }
  }

  // Enhanced Logout
  static Future<Map<String, dynamic>> logoutNew() async {
    try {
      await _makeRequest('logout', 'POST');
      
      // Clear all stored data
      await clearTokens();
      await _storage.delete(key: 'user_profile');
      await _storage.delete(key: 'juris-logged-in');
      
      return {'success': true};
    } catch (e) {
      // Clear tokens even if request fails
      await clearTokens();
      await _storage.delete(key: 'user_profile');
      await _storage.delete(key: 'juris-logged-in');
      return {'success': true}; // Return success since tokens are cleared
    }
  }

  // Get Enhanced Profile
  static Future<UserProfile?> getProfileNew() async {
    try {
      final response = await _makeRequest('profile', 'GET');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final user = UserProfile.fromJson(data['data']);
          await storeUserData(data['data']);
          return user;
        }
      }
      
      throw ApiError(
        message: 'Failed to fetch profile',
        status: response.statusCode,
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Profile request failed: ${e.toString()}');
    }
  }

  // ================ ANALYSIS AND DOCUMENT PROCESSING ================

  // Analyze Case with comprehensive error handling and URL fallback
  static Future<AnalysisResponse> analyzeCase(AnalysisRequest request) async {
    try {
      print('🔍 Starting case analysis...');
      
      // Get a working base URL
      final workingBaseUrl = await _getWorkingBaseUrl();
      final requestUrl = '$workingBaseUrl${endpoints['analyzeCase']}';
      
      print('📤 Request URL: $requestUrl');
      print('📤 Request body: ${jsonEncode(request.toJson())}');
      
      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(aiModelTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle success response formats
        if (data['status'] == 'success' && data['data'] != null) {
          print('✅ Analysis successful (wrapped format)');
          return AnalysisResponse.fromJson(data['data']);
        }
        
        // Direct response format
        if (data['applicable_ipc_sections'] != null) {
          print('✅ Analysis successful (direct format)');
          return AnalysisResponse.fromJson(data);
        }
        
        print('❌ Invalid response format: $data');
        throw ApiError(message: 'Invalid response format from analysis service');
      }
      
      final errorData = jsonDecode(response.body);
      print('❌ Analysis failed: ${response.statusCode} - $errorData');
      throw ApiError(
        message: errorData['detail'] ?? errorData['message'] ?? 'Analysis failed',
        status: response.statusCode,
        details: errorData,
      );
    } catch (e) {
      print('💥 Exception in analyzeCase: $e');
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Case analysis failed: ${e.toString()}');
    }
  }

  // Extract Text from Image (OCR)
  static Future<OCRResponse> extractTextFromImage(String imagePath) async {
    try {
      if (!await isAuthenticated()) {
        throw ApiError(
          message: 'Authentication required for image text extraction',
          status: 401,
        );
      }

      final uri = Uri.parse('$baseUrl${endpoints['extractText']}');
      final request = http.MultipartRequest('POST', uri);
      
      // Add auth header
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      // Add image file
      final file = await http.MultipartFile.fromPath('image', imagePath);
      request.files.add(file);

      final streamedResponse = await request.send().timeout(longTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OCRResponse.fromJson(data);
      }
      
      final errorData = jsonDecode(response.body);
      throw ApiError(
        message: errorData['error'] ?? 'OCR extraction failed',
        status: response.statusCode,
        details: errorData,
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Image text extraction failed: ${e.toString()}');
    }
  }

  // Summarize Document
  static Future<DocumentSummaryResponse> summarizeDocument(String documentPath) async {
    try {
      if (!await isAuthenticated()) {
        throw ApiError(
          message: 'Authentication required for document summarization',
          status: 401,
        );
      }

      final uri = Uri.parse('$baseUrl${endpoints['summarizeDocument']}');
      final request = http.MultipartRequest('POST', uri);
      
      // Add auth header
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      // Add document file
      final file = await http.MultipartFile.fromPath('document', documentPath);
      request.files.add(file);

      final streamedResponse = await request.send().timeout(aiModelTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DocumentSummaryResponse.fromJson(data);
      }
      
      final errorData = jsonDecode(response.body);
      throw ApiError(
        message: errorData['error'] ?? 'Document summarization failed',
        status: response.statusCode,
        details: errorData,
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Document summarization failed: ${e.toString()}');
    }
  }

  // ================ HISTORY AND SEARCH ================

  // Get History
  static Future<List<HistoryEntry>> getHistory() async {
    try {
      final response = await _makeRequest('history', 'GET');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> historyList = data['data'] ?? data['history'] ?? [];
        return historyList.map((item) => HistoryEntry.fromJson(item)).toList();
      }
      
      throw ApiError(
        message: 'Failed to fetch history',
        status: response.statusCode,
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'History request failed: ${e.toString()}');
    }
  }

  // Add to History
  static Future<Map<String, dynamic>> addToHistory(HistoryEntry entry) async {
    try {
      final response = await _makeRequest(
        'history', 
        'POST', 
        body: entry.toJson(),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Failed to add to history',
      };
    } catch (e) {
      if (e is ApiError) rethrow;
      return {'success': false, 'message': 'Add to history failed: ${e.toString()}'};
    }
  }

  // ================ LAWYERS AND CASES ================

  // Get Lawyers
  static Future<List<Map<String, dynamic>>> getLawyers({
    String? specialization,
    String? location,
    double? rating,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (specialization != null) queryParams['specialization'] = specialization;
      if (location != null) queryParams['location'] = location;
      if (rating != null) queryParams['rating'] = rating.toString();

      var url = '$baseUrl${endpoints['lawyers']}';
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(defaultTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? data['lawyers'] ?? []);
      }
      
      throw ApiError(
        message: 'Failed to fetch lawyers',
        status: response.statusCode,
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Lawyers request failed: ${e.toString()}');
    }
  }

  // Get Legal Cases
  static Future<List<Map<String, dynamic>>> getLegalCases({
    String? category,
    String? search,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit.toString();

      var url = '$baseUrl${endpoints['cases']}';
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(defaultTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? data['cases'] ?? []);
      }
      
      throw ApiError(
        message: 'Failed to fetch legal cases',
        status: response.statusCode,
      );
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Legal cases request failed: ${e.toString()}');
    }
  }

  // ================ UTILITY METHODS ================

  // Transform analysis response for UI
  static TransformedAnalysisResponse transformAnalysisResponse(AnalysisResponse response) {
    final severityMap = {
      'High': 'high',
      'Medium': 'medium',
      'Low': 'low',
    };

    final severity = severityMap[response.severity] ?? 'medium';

    final defensiveSections = response.defensiveIpcSections?.map((section) => 
      ApplicableSection(
        section: 'IPC ${section.sectionNumber}',
        title: section.description.split(':').first,
        description: section.whyApplicable,
        punishment: section.punishment,
      )
    ).toList();

    return TransformedAnalysisResponse(
      summary: 'AI analysis identified ${response.totalSectionsIdentified} applicable IPC sections'
               '${response.totalDefensiveSections != null ? " and ${response.totalDefensiveSections} defensive sections" : ""}'
               ' with $severity severity. This analysis was completed on ${DateTime.now().toString().split(' ').first}.',
      legalIssues: response.applicableIpcSections.map((section) => 
        'IPC ${section.sectionNumber}: ${section.description}'
      ).toList(),
      recommendations: [
        'Consult with a qualified legal professional immediately',
        'Document all relevant evidence and maintain records',
        'Gather witness statements if applicable',
        'Preserve any physical or digital evidence',
        'Consider filing a formal complaint with appropriate authorities',
        if (defensiveSections != null && defensiveSections.isNotEmpty)
          'Review available defensive strategies with your lawyer',
      ],
      severity: severity,
      nextSteps: [
        'Schedule consultation with recommended lawyers',
        'Prepare comprehensive case documentation',
        'Review applicable legal sections in detail',
        'Consider alternative dispute resolution options',
        if (defensiveSections != null && defensiveSections.isNotEmpty)
          'Discuss defensive legal strategies',
      ],
      applicableSections: response.applicableIpcSections.map((section) => 
        ApplicableSection(
          section: 'IPC ${section.sectionNumber}',
          title: section.description.split(':').first,
          description: section.whyApplicable,
          punishment: section.punishment,
        )
      ).toList(),
      defensiveSections: defensiveSections,
      timeline: severity == 'high' ? '1-3 months for urgent action' : 
               severity == 'medium' ? '2-6 months for resolution' : 
               '3-12 months for standard proceedings',
      caseType: 'Criminal Law - IPC Analysis',
    );
  }
}