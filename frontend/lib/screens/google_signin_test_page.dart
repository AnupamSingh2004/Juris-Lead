import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import '../services/api_test_service.dart';

class GoogleSignInTestPage extends StatefulWidget {
  const GoogleSignInTestPage({Key? key}) : super(key: key);

  @override
  State<GoogleSignInTestPage> createState() => _GoogleSignInTestPageState();
}

class _GoogleSignInTestPageState extends State<GoogleSignInTestPage> {
  String _status = 'Ready to test Google Sign-In';
  bool _isLoading = false;
  Map<String, dynamic>? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In Test'),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Google Sign-In Debug Tool',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: TextStyle(
                      color: _status.contains('Error') ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Test Backend Connection Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testBackendConnection,
                icon: const Icon(Icons.cloud),
                label: const Text('Test Backend Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Test Google Sign-In Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testGoogleSignIn,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.login),
                label: Text(_isLoading ? 'Testing...' : 'Test Google Sign-In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Results
            if (_lastResult != null) ...[
              const Text(
                'Last Result:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _formatResult(_lastResult!),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Test backend connection first\n'
                    '2. For Android emulator: Use 10.0.2.2:8000 instead of localhost\n'
                    '3. For physical device: Use your host IP (check terminal output)\n'
                    '4. Make sure Docker backend is running on host machine\n'
                    '5. Set up Google Cloud Console with provided credentials\n'
                    '6. Package name: com.aarogyarekha.app\n'
                    '7. SHA-1: 03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing backend connection...';
    });

    try {
      // Test multiple URLs for better connectivity
      final healthResult = await ApiTestService.testConnectionMultiple();
      
      if (healthResult['success']) {
        setState(() {
          _status = 'Backend connection successful! ✅\nUsing: ${healthResult['workingUrl']}';
          _lastResult = healthResult;
        });
        
        // Test auth endpoint
        final authResult = await ApiTestService.testAuthEndpoint();
        setState(() {
          _lastResult = {
            'health_check': healthResult,
            'auth_check': authResult,
            'overall_success': healthResult['success'] && authResult['success'],
          };
          
          if (authResult['success']) {
            _status = 'Backend and auth endpoints working! ✅\nUsing: ${healthResult['workingUrl']}';
          } else {
            _status = 'Backend OK, but auth endpoint issue: ${authResult['message']} ⚠️\nUsing: ${healthResult['workingUrl']}';
          }
        });
      } else {
        setState(() {
          _status = 'Backend connection failed: ${healthResult['message']} ❌';
          _lastResult = healthResult;
        });
      }
    } catch (e) {
      setState(() {
        _lastResult = {'error': e.toString()};
        _status = 'Backend connection error: $e ❌';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Google Sign-In...';
    });

    try {
      final result = await GoogleAuthService.signInWithGoogle();
      
      setState(() {
        _lastResult = result;
        if (result['success']) {
          _status = 'Google Sign-In successful! Testing backend integration... ✅';
        } else {
          _status = 'Google Sign-In failed: ${result['message']} ❌';
        }
      });
      
      // If Google Sign-In was successful, test backend integration
      if (result['success'] && result['idToken'] != null) {
        final backendResult = await ApiTestService.testGoogleLogin(result['idToken']);
        setState(() {
          _lastResult = {
            'google_signin': result,
            'backend_integration': backendResult,
            'overall_success': result['success'] && backendResult['success'],
          };
          
          if (backendResult['success']) {
            _status = 'Google Sign-In and backend integration successful! ✅';
          } else {
            _status = 'Google Sign-In OK, but backend integration failed: ${backendResult['message']} ❌';
          }
        });
      }
    } catch (e) {
      setState(() {
        _lastResult = {'error': e.toString()};
        _status = 'Error during Google Sign-In: $e ❌';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatResult(Map<String, dynamic> result) {
    String formatted = '';
    
    formatted += 'Success: ${result['success'] ?? 'N/A'}\n\n';
    
    if (result['message'] != null) {
      formatted += 'Message: ${result['message']}\n\n';
    }
    
    if (result['suggestion'] != null) {
      formatted += 'Suggestion: ${result['suggestion']}\n\n';
    }
    
    if (result['baseUrl'] != null) {
      formatted += 'Base URL: ${result['baseUrl']}\n\n';
    }
    
    if (result['platform'] != null) {
      formatted += 'Platform: ${result['platform']}\n\n';
    }
    
    if (result['accessToken'] != null) {
      formatted += 'Access Token: ${result['accessToken'].toString().substring(0, 50)}...\n\n';
    }
    
    if (result['idToken'] != null) {
      formatted += 'ID Token: ${result['idToken'].toString().substring(0, 50)}...\n\n';
    }
    
    if (result['user'] != null) {
      formatted += 'User Info:\n';
      final user = result['user'] as Map<String, dynamic>;
      user.forEach((key, value) {
        formatted += '  $key: $value\n';
      });
      formatted += '\n';
    }
    
    if (result['error'] != null) {
      formatted += 'Error: ${result['error']}\n\n';
    }
    
    formatted += 'Full Response:\n${result.toString()}';
    
    return formatted;
  }
}
