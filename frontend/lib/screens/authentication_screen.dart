import 'package:flutter/material.dart';
import '../services/google_auth_service_new.dart';
import 'main_navigation.dart';

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
    await GoogleAuthService.initializeAuth();
    if (GoogleAuthService.isSignedIn && mounted) {
      _navigateToMainApp();
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
                            : Image.asset(
                                'assets/images/google_logo.png',
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.login, color: Colors.white);
                                },
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
      final account = await GoogleAuthService.signIn();
      if (account != null && mounted) {
        _navigateToMainApp();
      } else {
        setState(() {
          _error = 'Sign in was cancelled or failed. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _error = 'Failed to sign in with Google. Please check your internet connection.';
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
