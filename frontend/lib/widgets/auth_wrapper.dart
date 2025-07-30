import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/login_page.dart';
import '../widgets/main_navigation.dart';
import '../models/user_model.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationState();
  }

  Future<void> _checkAuthenticationState() async {
    print('🔍 AuthWrapper: Checking authentication state...');
    
    try {
      // Check if we have a stored access token
      final accessToken = await ApiService.getAccessToken();
      print('🔑 AuthWrapper: Access token exists: ${accessToken != null && accessToken.isNotEmpty}');
      
      if (accessToken != null && accessToken.isNotEmpty) {
        print('📡 AuthWrapper: Attempting to fetch user profile...');
        // Try to get user profile to validate the token
        final userProfileResult = await ApiService.getUserProfile();
        
        if (userProfileResult['success'] == true) {
          final userData = userProfileResult['data'];
          final user = User.fromJson(userData);
          print('✅ AuthWrapper: User profile loaded successfully for: ${user.email}');
          
          setState(() {
            _isAuthenticated = true;
            _user = user;
            _isLoading = false;
          });
          return;
        } else {
          print('🔄 AuthWrapper: Token might be invalid, attempting to refresh...');
          // Token might be invalid, try to refresh it
          final refreshSuccess = await ApiService.refreshToken();
          if (refreshSuccess) {
            print('✅ AuthWrapper: Token refreshed successfully, retrying profile fetch...');
            // Try getting profile again with refreshed token
            final retryResult = await ApiService.getUserProfile();
            if (retryResult['success'] == true) {
              final userData = retryResult['data'];
              final user = User.fromJson(userData);
              print('✅ AuthWrapper: User profile loaded after token refresh for: ${user.email}');
              
              setState(() {
                _isAuthenticated = true;
                _user = user;
                _isLoading = false;
              });
              return;
            } else {
              print('❌ AuthWrapper: Failed to fetch profile even after token refresh');
            }
          } else {
            print('❌ AuthWrapper: Token refresh failed');
          }
        }
      } else {
        print('ℹ️ AuthWrapper: No access token found');
      }
      
      // No valid token found or all attempts failed
      print('🧹 AuthWrapper: Clearing invalid tokens and redirecting to login');
      await ApiService.clearTokens(); // Clear any invalid tokens
      setState(() {
        _isAuthenticated = false;
        _user = null;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ AuthWrapper: Error checking authentication state: $e');
      await ApiService.clearTokens(); // Clear tokens on error
      setState(() {
        _isAuthenticated = false;
        _user = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Checking authentication...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_isAuthenticated && _user != null) {
      // Skip user type selection and go directly to main navigation with default user type
      return const MainNavigation(userType: 'Rural');
    } else {
      return const LoginPage();
    }
  }
}
