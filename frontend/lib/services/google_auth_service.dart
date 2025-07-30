import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_auth_config.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Temporarily remove serverClientId to test basic Android OAuth
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
      print('Package name: com.aarogyarekha.app');
      print('SHA-1: 03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49');
      print('=== END DEBUG ===');

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
            'message': 'DEVELOPER_ERROR (Code 10): Configuration mismatch!\n\n'
                      'This usually means:\n'
                      '1. SHA-1 fingerprint doesn\'t match Google Cloud Console\n'
                      '2. Package name doesn\'t match\n'
                      '3. Android OAuth client not properly configured\n\n'
                      'Current SHA-1: 03:BA:58:0D:5B:E6:F0:8B:95:59:AB:3C:CA:5D:1E:05:6E:2E:EA:49\n'
                      'Package: com.aarogyarekha.app\n\n'
                      'Please verify these match exactly in Google Cloud Console.'
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