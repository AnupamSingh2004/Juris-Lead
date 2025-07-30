import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool locationSharing = true;
  bool dataAnalytics = true;
  bool crashReporting = true;
  bool biometricLogin = false;
  bool twoFactorAuth = false;
  bool autoLogout = true;
  String dataRetention = '1 year';
  String locationAccuracy = 'High';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Settings
            _buildSection(
              'Privacy Settings',
              [
                _buildSwitchTile(
                  'Location Sharing',
                  'Share your location for better health risk assessment',
                  Icons.location_on,
                  locationSharing,
                  (value) => setState(() => locationSharing = value),
                ),
                _buildSwitchTile(
                  'Data Analytics',
                  'Help improve the app by sharing anonymous usage data',
                  Icons.analytics,
                  dataAnalytics,
                  (value) => setState(() => dataAnalytics = value),
                ),
                _buildSwitchTile(
                  'Crash Reporting',
                  'Automatically send crash reports to help fix issues',
                  Icons.bug_report,
                  crashReporting,
                  (value) => setState(() => crashReporting = value),
                ),
                _buildDropdownTile(
                  'Data Retention',
                  'How long to keep your health data',
                  Icons.schedule,
                  dataRetention,
                  ['6 months', '1 year', '2 years', '5 years'],
                  (value) => setState(() => dataRetention = value),
                ),
                _buildDropdownTile(
                  'Location Accuracy',
                  'Balance between accuracy and battery usage',
                  Icons.gps_fixed,
                  locationAccuracy,
                  ['High', 'Medium', 'Low'],
                  (value) => setState(() => locationAccuracy = value),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Security Settings
            _buildSection(
              'Security Settings',
              [
                _buildSwitchTile(
                  'Biometric Login',
                  'Use fingerprint or face recognition to login',
                  Icons.fingerprint,
                  biometricLogin,
                  (value) => setState(() => biometricLogin = value),
                ),
                _buildSwitchTile(
                  'Two-Factor Authentication',
                  'Add extra security with 2FA verification',
                  Icons.security,
                  twoFactorAuth,
                  (value) => setState(() => twoFactorAuth = value),
                ),
                _buildSwitchTile(
                  'Auto Logout',
                  'Automatically logout after 30 minutes of inactivity',
                  Icons.logout,
                  autoLogout,
                  (value) => setState(() => autoLogout = value),
                ),
                _buildActionTile(
                  'Change Password',
                  'Update your account password',
                  Icons.lock,
                  _changePassword,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Data Management
            _buildSection(
              'Data Management',
              [
                _buildActionTile(
                  'Download My Data',
                  'Download all your health data in PDF format',
                  Icons.download,
                  _downloadData,
                ),
                _buildActionTile(
                  'Delete Account',
                  'Permanently delete your account and all data',
                  Icons.delete_forever,
                  _deleteAccount,
                  isDestructive: true,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Privacy Policy
            _buildSection(
              'Legal & Compliance',
              [
                _buildActionTile(
                  'Privacy Policy',
                  'Read our privacy policy and data handling practices',
                  Icons.policy,
                  _showPrivacyPolicy,
                ),
                _buildActionTile(
                  'Terms of Service',
                  'View the terms and conditions of using AarogyaRekha',
                  Icons.description,
                  _showTermsOfService,
                ),
                _buildActionTile(
                  'Data Usage Report',
                  'See how your data is being used',
                  Icons.bar_chart,
                  _showDataUsageReport,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We use end-to-end encryption to protect your health data. Your information is never shared without your consent.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2E7D8A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E7D8A),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2E7D8A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: (String? newValue) {
              if (newValue != null) onChanged(newValue);
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF2E7D8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF2E7D8A),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully'),
                  backgroundColor: Color(0xFF2E7D8A),
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Data'),
        content: const Text(
          'Your health data will be compiled into a PDF report and sent to your registered email address. This may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export started. Check your email in a few minutes.'),
                  backgroundColor: Color(0xFF2E7D8A),
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your health data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested. Please check your email for confirmation.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _PolicyScreen(
          title: 'Privacy Policy',
          content: 'Privacy policy content would be loaded here...',
        ),
      ),
    );
  }

  void _showTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _PolicyScreen(
          title: 'Terms of Service',
          content: 'Terms of service content would be loaded here...',
        ),
      ),
    );
  }

  void _showDataUsageReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _DataUsageScreen(),
      ),
    );
  }
}

class _PolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const _PolicyScreen({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}

class _DataUsageScreen extends StatelessWidget {
  const _DataUsageScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Usage Report'),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Data Usage Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUsageCard('Location Data', 'Used for risk assessment', '245 times'),
            _buildUsageCard('Health Records', 'Stored for analysis', '12 entries'),
            _buildUsageCard('Prediction History', 'AI model training', '89 predictions'),
            _buildUsageCard('App Usage', 'Performance optimization', '156 sessions'),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(String title, String description, String usage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Usage Count:'),
                Text(
                  usage,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
