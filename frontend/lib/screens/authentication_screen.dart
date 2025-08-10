import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_auth_service.dart';
import '../services/mock_auth_service.dart';
import 'main_navigation_simple.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkExistingAuth();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  Future<void> _checkExistingAuth() async {
    try {
      // For now, we'll skip checking existing auth since the GoogleAuthService
      // doesn't have persistent auth checking implemented
      // TODO: Implement when proper Google OAuth is configured
    } catch (error) {
      debugPrint('Auth check error: $error');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Title
                    Text(
                      'Juris-Lead',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Your AI-Powered Legal Assistant',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Feature Highlights
                    _buildFeatureHighlight(
                      Icons.psychology_outlined,
                      'AI Legal Analysis',
                      'Get instant analysis of your legal cases',
                      colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureHighlight(
                      Icons.people_outline,
                      'Find Legal Experts',
                      'Connect with qualified lawyers and advocates',
                      colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureHighlight(
                      Icons.build_outlined,
                      'Legal Tools',
                      'Access comprehensive legal research tools',
                      colorScheme,
                    ),

                    const SizedBox(height: 48),

                    // Error Message
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.login,
                                color: Colors.white,
                                size: 24,
                              ),
                        label: Text(
                          _isLoading ? 'Signing In...' : 'Continue with Google',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skip Button
                    TextButton(
                      onPressed: _isLoading ? null : _continueWithoutAuth,
                      child: Text(
                        'Continue without signing in',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Terms and Privacy
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlight(
    IconData icon,
    String title,
    String description,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await GoogleAuthService.signInWithGoogle();
      
      if (result['success'] == true && mounted) {
        // Save user data to SharedPreferences
        await _saveUserData(result);
        
        // Navigate to main navigation after successful sign in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      } else {
        setState(() {
          _error = result['message'] ?? 'Sign in failed. Please try again.';
        });
        
        // Show detailed error message if it's a configuration issue
        if (mounted && result['message']?.contains('DEVELOPER_ERROR') == true) {
          _showConfigurationDialog(result['message']);
        }
      }
    } catch (error) {
      setState(() {
        _error = 'Failed to sign in with Google. Please check your internet connection.';
      });
      debugPrint('Google Sign-In error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showConfigurationDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Google Auth Configuration Required'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _tryMockSignIn();
                  },
                  child: const Text('Continue with Mock Authentication'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUserData(Map<String, dynamic> result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = result['user'] as Map<String, dynamic>;
      
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', user['displayName'] ?? user['email'] ?? 'User');
      await prefs.setString('user_email', user['email'] ?? '');
      await prefs.setString('user_photo', user['photoUrl'] ?? '');
      await prefs.setString('user_type', 'client'); // Default to client, can be changed later
      await prefs.setString('subscription_type', 'free');
      await prefs.setBool('is_premium', false);
      await prefs.setString('join_date', DateTime.now().toIso8601String());
      
      // Initialize statistics
      await prefs.setInt('cases_analyzed', 0);
      await prefs.setInt('documents_processed', 0);
      await prefs.setInt('ai_consultations', 0);
      
      debugPrint('User data saved successfully');
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> _saveMockUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', 'John Doe (Mock)');
      await prefs.setString('user_email', 'john.doe@example.com');
      await prefs.setString('user_photo', '');
      await prefs.setString('user_type', 'client');
      await prefs.setString('subscription_type', 'free');
      await prefs.setBool('is_premium', false);
      await prefs.setString('join_date', DateTime.now().toIso8601String());
      
      // Initialize statistics with some mock data
      await prefs.setInt('cases_analyzed', 5);
      await prefs.setInt('documents_processed', 12);
      await prefs.setInt('ai_consultations', 3);
      
      debugPrint('Mock user data saved successfully');
    } catch (e) {
      debugPrint('Error saving mock user data: $e');
    }
  }

  Future<void> _tryMockSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await MockAuthService.mockGoogleSignIn();
      
      if (result['success'] == true && mounted) {
        // Save mock user data to SharedPreferences
        await _saveMockUserData();
        
        // Show mock authentication notice
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Using mock authentication for development'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate to main navigation with mock user info
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _error = 'Mock authentication failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _continueWithoutAuth() {
    _navigateToMainApp();
  }

  void _navigateToMainApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigation(),
      ),
    );
  }
}
