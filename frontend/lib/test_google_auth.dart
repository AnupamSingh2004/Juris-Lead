import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config/google_auth_config.dart';
import 'services/google_auth_service.dart';

class TestGoogleAuth extends StatefulWidget {
  const TestGoogleAuth({Key? key}) : super(key: key);

  @override
  State<TestGoogleAuth> createState() => _TestGoogleAuthState();
}

class _TestGoogleAuthState extends State<TestGoogleAuth> {
  String _status = 'Ready to test Google Sign-In';
  bool _isLoading = false;

  void _testGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Google Sign-In...';
    });

    try {
      // First, let's test the configuration
      print('=== Google Sign-In Configuration Test ===');
      print('Android Client ID: ${GoogleAuthConfig.androidClientId}');
      print('Web Client ID: ${GoogleAuthConfig.webClientId}');
      print('Server Client ID: ${GoogleAuthConfig.serverClientId}');
      print('Package Name: com.aarogyarekha.app');
      print('SHA-1: 03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49');
      
      // Test direct GoogleSignIn initialization
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: GoogleAuthConfig.serverClientId,
      );
      
      print('GoogleSignIn object created successfully');
      print('Current user: ${googleSignIn.currentUser?.email ?? 'None'}');
      
      // Test sign-in
      final result = await GoogleAuthService.signInWithGoogle();
      
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _status = 'SUCCESS!\n\n'
                   'User: ${result['user']['email']}\n'
                   'Display Name: ${result['user']['displayName']}\n'
                   'Access Token: ${result['accessToken']?.substring(0, 20)}...\n'
                   'ID Token: ${result['idToken']?.substring(0, 20) ?? 'None'}...';
        } else {
          _status = 'FAILED!\n\n'
                   'Error: ${result['message']}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'ERROR!\n\n'
                 'Exception: $e';
      });
    }
  }

  void _testConfigurationOnly() {
    setState(() {
      _status = 'Configuration Details:\n\n'
               'Android Client ID:\n${GoogleAuthConfig.androidClientId}\n\n'
               'Web Client ID:\n${GoogleAuthConfig.webClientId}\n\n'
               'Server Client ID:\n${GoogleAuthConfig.serverClientId}\n\n'
               'Package: com.aarogyarekha.app\n\n'
               'SHA-1: 03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConfigurationOnly,
              child: const Text('Show Configuration'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGoogleSignIn,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Test Google Sign-In'),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.orange,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting Steps:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Verify SHA-1 fingerprint in Google Cloud Console\n'
                      '2. Check package name matches exactly\n'
                      '3. Ensure both Android and Web OAuth clients are created\n'
                      '4. Verify the Web Client ID is complete and correct\n'
                      '5. Make sure Google Identity Services API is enabled',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
