import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String userType;
  
  const SettingsScreen({Key? key, required this.userType}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = 'English';
  bool notificationsEnabled = true;
  bool locationEnabled = true;
  bool autoSync = true;
  String selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Settings
            _buildSettingsSection(
              'Language Preferences',
              [
                _buildLanguageSelector(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notification Settings
            _buildSettingsSection(
              'Notifications',
              [
                _buildSwitchTile(
                  'Enable Notifications',
                  'Receive health alerts and updates',
                  notificationsEnabled,
                  (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
                _buildNotificationTypes(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Location Settings
            _buildSettingsSection(
              'Location & Privacy',
              [
                _buildSwitchTile(
                  'Location Services',
                  'Allow location access for risk mapping',
                  locationEnabled,
                  (value) {
                    setState(() {
                      locationEnabled = value;
                    });
                  },
                ),
                _buildLocationAccuracy(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Data Sync Settings
            _buildSettingsSection(
              'Data Sync',
              [
                _buildSwitchTile(
                  'Auto Sync',
                  'Automatically sync data when connected',
                  autoSync,
                  (value) {
                    setState(() {
                      autoSync = value;
                    });
                  },
                ),
                _buildSyncOptions(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // App Settings
            _buildSettingsSection(
              'App Settings',
              [
                _buildThemeSelector(),
                _buildCacheSettings(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Advanced Settings
            _buildSettingsSection(
              'Advanced',
              [
                _buildAdvancedOption('Export Data', Icons.download, () {
                  _showExportDialog();
                }),
                _buildAdvancedOption('Clear Cache', Icons.clear, () {
                  _showClearCacheDialog();
                }),
                _buildAdvancedOption('Reset Settings', Icons.restore, () {
                  _showResetDialog();
                }),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
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

  Widget _buildLanguageSelector() {
    final languages = ['English', 'Hindi', 'Bengali', 'Telugu', 'Tamil', 'Marathi'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Language',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedLanguage,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguage = newValue!;
              });
            },
            items: languages.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
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
                const SizedBox(height: 4),
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

  Widget _buildNotificationTypes() {
    final notificationTypes = [
      'Health Alerts',
      'Weather Updates',
      'Emergency Notifications',
      'Reminder Notifications',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Types',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...notificationTypes.map((type) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: notificationsEnabled ? (value) {} : null,
                  activeColor: const Color(0xFF2E7D8A),
                ),
                Text(type),
              ],
            ),
          ),
        ).toList(),
      ],
    );
  }

  Widget _buildLocationAccuracy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location Accuracy',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio<String>(
              value: 'High',
              groupValue: 'High',
              onChanged: locationEnabled ? (value) {} : null,
              activeColor: const Color(0xFF2E7D8A),
            ),
            const Text('High (GPS + Network)'),
          ],
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Medium',
              groupValue: 'High',
              onChanged: locationEnabled ? (value) {} : null,
              activeColor: const Color(0xFF2E7D8A),
            ),
            const Text('Medium (Network only)'),
          ],
        ),
      ],
    );
  }

  Widget _buildSyncOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sync Options',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: true,
              onChanged: autoSync ? (value) {} : null,
              activeColor: const Color(0xFF2E7D8A),
            ),
            const Text('Sync on WiFi only'),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: autoSync ? (value) {} : null,
              activeColor: const Color(0xFF2E7D8A),
            ),
            const Text('Sync on mobile data'),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theme',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio<String>(
              value: 'Light',
              groupValue: selectedTheme,
              onChanged: (value) {
                setState(() {
                  selectedTheme = value!;
                });
              },
              activeColor: const Color(0xFF2E7D8A),
            ),
            const Text('Light'),
            const SizedBox(width: 20),
            Radio<String>(
              value: 'Dark',
              groupValue: selectedTheme,
              onChanged: (value) {
                setState(() {
                  selectedTheme = value!;
                });
              },
              activeColor: const Color(0xFF2E7D8A),
            ),
            const Text('Dark'),
          ],
        ),
      ],
    );
  }

  Widget _buildCacheSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cache Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Cache size: 45.2 MB',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Last cleared: 2 days ago',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOption(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2E7D8A),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export your health data and settings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('This will reset all settings to default. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export started...'),
        backgroundColor: Color(0xFF2E7D8A),
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully'),
        backgroundColor: Color(0xFF2E7D8A),
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      selectedLanguage = 'English';
      notificationsEnabled = true;
      locationEnabled = true;
      autoSync = true;
      selectedTheme = 'Light';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to default'),
        backgroundColor: Color(0xFF2E7D8A),
      ),
    );
  }
}
