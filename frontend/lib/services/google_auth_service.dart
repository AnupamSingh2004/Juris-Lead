import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_auth_config.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Remove serverClientId for now to test basic Android OAuth
    // Will be added back when proper credentials are configured
    // serverClientId: GoogleAuthConfig.serverClientId,
  );

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      print('=== CONFIGURATION DEBUG ===');
      print('Android client ID: ${GoogleAuthConfig.androidClientId}');
      print('Web client ID: ${GoogleAuthConfig.webClientId}');
      print('Android client ID length: ${GoogleAuthConfig.androidClientId.length}');
      print('Web client ID length: ${GoogleAuthConfig.webClientId.length}');
      print('Package name: com.jurislead.app');
      print('SHA-1: 03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49');
      print('=== END DEBUG ===');

      // Check if we're using old credentials
      if (GoogleAuthConfig.androidClientId.contains('266959479556')) {
        print('⚠️  WARNING: Using old OAuth credentials for package com.aarogyarekha.app');
        print('⚠️  Current package is com.jurislead.app - this will likely fail');
        print('⚠️  Please update credentials in Google Cloud Console');
      }

      await _googleSignIn.signOut();
      
      print('Attempting to sign in...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('User cancelled Google sign-in');
        return {'success': false, 'message': 'Google sign in cancelled'};
      }

      print('Google user obtained: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        print('Failed to get access token');
        return {'success': false, 'message': 'Failed to get Google access token'};
      }

      print('Google Sign-In Success:');
      print('Access Token: ${googleAuth.accessToken?.substring(0, 20)}...');
      print('ID Token: ${googleAuth.idToken?.substring(0, 20) ?? 'No ID Token'}...');
      print('User Email: ${googleUser.email}');

      return {
        'success': true,
        'accessToken': googleAuth.accessToken,
        'idToken': googleAuth.idToken,
        'user': {
          'email': googleUser.email,
          'displayName': googleUser.displayName ?? '',
          'photoUrl': googleUser.photoUrl,
          'id': googleUser.id,
        }
      };
    } catch (e) {
      print('Google Sign-In Error Details: $e');

      if (e.toString().contains('sign_in_failed')) {
        if (e.toString().contains('10')) {
          return {
            'success': false, 
            'message': 'DEVELOPER_ERROR (Code 10): OAuth Configuration Mismatch!\n\n'
                      '🔥 PROBLEM: The app package name changed from com.aarogyarekha.app to com.jurislead.app\n'
                      'but Google OAuth credentials still use the old package name.\n\n'
                      '✅ SOLUTION:\n'
                      '1. Go to Google Cloud Console\n'
                      '2. Create new Android OAuth client for com.jurislead.app\n'
                      '3. Use SHA-1: 03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49\n'
                      '4. Update .env file with new credentials\n\n'
                      '📖 See GOOGLE_AUTH_SETUP.md for detailed instructions'
          };
        }
      }
      
      return {'success': false, 'message': 'Google sign in error: $e'};
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}