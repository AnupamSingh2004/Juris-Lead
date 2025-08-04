import 'dart:math';

class MockAuthService {
  static Future<Map<String, dynamic>> mockGoogleSignIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate mock user data
    final random = Random();
    final userTypes = ['lawyer', 'citizen'];
    final names = ['John Doe', 'Jane Smith', 'Priya Sharma', 'Rahul Kumar', 'Sarah Wilson'];
    final domains = ['gmail.com', 'yahoo.com', 'outlook.com'];
    
    final selectedName = names[random.nextInt(names.length)];
    final selectedDomain = domains[random.nextInt(domains.length)];
    final selectedUserType = userTypes[random.nextInt(userTypes.length)];
    
    final email = '${selectedName.toLowerCase().replaceAll(' ', '.')}@$selectedDomain';
    
    return {
      'success': true,
      'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'idToken': 'mock_id_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'email': email,
        'displayName': selectedName,
        'photoUrl': 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(selectedName)}&background=random',
        'id': 'mock_${random.nextInt(999999)}',
      },
      'userType': selectedUserType,
      'isMockAuth': true, // Flag to indicate this is mock authentication
    };
  }
}
