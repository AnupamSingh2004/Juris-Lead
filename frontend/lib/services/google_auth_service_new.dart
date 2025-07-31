import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  static GoogleSignInAccount? _currentUser;

  static GoogleSignInAccount? get currentUser => _currentUser;
  static bool get isSignedIn => _currentUser != null;

  static Future<void> initializeAuth() async {
    try {
      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
        _currentUser = account;
      });
      
      // Check if user is already signed in
      _currentUser = await _googleSignIn.signInSilently();
    } catch (error) {
      debugPrint('Google Auth initialization error: $error');
    }
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      _currentUser = account;
      return account;
    } catch (error) {
      debugPrint('Google Sign-In error: $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (error) {
      debugPrint('Google Sign-Out error: $error');
    }
  }

  static String getUserType(GoogleSignInAccount account) {
    // Determine user type based on email domain or other criteria
    final email = account.email.toLowerCase();
    
    if (email.contains('lawyer') || email.contains('advocate') || email.contains('legal')) {
      return 'Lawyer';
    } else if (email.contains('student') || email.contains('edu')) {
      return 'Law Student';
    } else if (email.contains('legal-aid') || email.contains('ngo')) {
      return 'Legal Aid Organization';
    } else {
      return 'Citizen';
    }
  }

  static Map<String, dynamic> getUserData(GoogleSignInAccount account) {
    return {
      'id': account.id,
      'name': account.displayName ?? 'Unknown User',
      'email': account.email,
      'photoUrl': account.photoUrl,
      'userType': getUserType(account),
    };
  }
}
