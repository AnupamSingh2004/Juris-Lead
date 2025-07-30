import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool smsNotifications = false;
  bool healthAlerts = true;
  bool emergencyAlerts = true;
  bool preventionTips = true;
  bool weatherUpdates = true;
  bool communityUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Notifications
            _buildNotificationSection(
              'General Notifications',
              [
                _buildNotificationTile(
                  'Push Notifications',
                  'Receive notifications on your device',
                  Icons.notifications,
                  pushNotifications,
                  (value) => setState(() => pushNotifications = value),
                ),
                _buildNotificationTile(
                  'Email Notifications',
                  'Receive important updates via email',
                  Icons.email,
                  emailNotifications,
                  (value) => setState(() => emailNotifications = value),
                ),
                _buildNotificationTile(
                  'SMS Notifications',
                  'Get critical alerts via SMS',
                  Icons.sms,
                  smsNotifications,
                  (value) => setState(() => smsNotifications = value),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Health Notifications
            _buildNotificationSection(
              'Health Notifications',
              [
                _buildNotificationTile(
                  'Health Alerts',
                  'Disease outbreak warnings and health risks',
                  Icons.health_and_safety,
                  healthAlerts,
                  (value) => setState(() => healthAlerts = value),
                ),
                _buildNotificationTile(
                  'Emergency Alerts',
                  'Immediate health emergency notifications',
                  Icons.emergency,
                  emergencyAlerts,
                  (value) => setState(() => emergencyAlerts = value),
                ),
                _buildNotificationTile(
                  'Prevention Tips',
                  'Daily health tips and prevention advice',
                  Icons.tips_and_updates,
                  preventionTips,
                  (value) => setState(() => preventionTips = value),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Other Notifications
            _buildNotificationSection(
              'Other Notifications',
              [
                _buildNotificationTile(
                  'Weather Updates',
                  'Weather conditions affecting health',
                  Icons.cloud,
                  weatherUpdates,
                  (value) => setState(() => weatherUpdates = value),
                ),
                _buildNotificationTile(
                  'Community Updates',
                  'Local community health news',
                  Icons.group,
                  communityUpdates,
                  (value) => setState(() => communityUpdates = value),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Quiet Hours
            _buildQuietHoursSection(),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToDefaults,
                    child: const Text('Reset to Defaults'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D8A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> children) {
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

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D8A).withAlpha(26),
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

  Widget _buildQuietHoursSection() {
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
          const Text(
            'Quiet Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Set times when you don\'t want to receive non-emergency notifications',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Time'),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('10:00 PM'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Time'),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('7:00 AM'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF2E7D8A),
              ),
              const Expanded(
                child: Text('Allow emergency notifications during quiet hours'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      pushNotifications = true;
      emailNotifications = true;
      smsNotifications = false;
      healthAlerts = true;
      emergencyAlerts = true;
      preventionTips = true;
      weatherUpdates = true;
      communityUpdates = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings reset to defaults'),
        backgroundColor: Color(0xFF2E7D8A),
      ),
    );
  }

  void _saveSettings() {
    // Here you would save the settings to backend or local storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved successfully'),
        backgroundColor: Color(0xFF2E7D8A),
      ),
    );
  }
}
