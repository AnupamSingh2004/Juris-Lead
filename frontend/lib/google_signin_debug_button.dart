import 'package:flutter/material.dart';
import 'services/google_auth_service.dart';

class GoogleSignInDebugButton extends StatelessWidget {
  const GoogleSignInDebugButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            print('=== TESTING GOOGLE SIGN-IN ===');
            final result = await GoogleAuthService.signInWithGoogle();
            
            if (result['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SUCCESS: Signed in as ${result['user']['email']}'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('FAILED: ${result['message']}'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 10),
                ),
              );
            }
          },
          child: const Text('Test Google Sign-In'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check the console/debug output for detailed information',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// Add this to your existing widget to test Google Sign-In quickly
/*
Usage in any StatefulWidget:

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Your App')),
    body: Column(
      children: [
        // Your existing widgets
        GoogleSignInDebugButton(),
      ],
    ),
  );
}
*/
