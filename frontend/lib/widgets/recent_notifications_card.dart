import 'package:flutter/material.dart';

class RecentNotificationsCard extends StatelessWidget {
  final VoidCallback? onViewAllNotifications;
  
  const RecentNotificationsCard({
    Key? key,
    this.onViewAllNotifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Color(0xFF2E7D8A),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recent Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D8A),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewAllNotifications,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2E7D8A),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Recent notifications list
          _buildNotificationItem(
            'Dengue Alert',
            'High risk detected in your area. Take preventive measures.',
            Icons.warning,
            Colors.red,
            '2 hours ago',
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            'Vaccination Campaign',
            'Free vaccination camp starting tomorrow at PHC.',
            Icons.vaccines,
            Colors.green,
            '5 hours ago',
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            'Weather Update',
            'Heavy rainfall expected in next 24 hours.',
            Icons.grain,
            Colors.blue,
            '1 day ago',
          ),
          
          const SizedBox(height: 16),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to all notifications
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D8A)),
                foregroundColor: const Color(0xFF2E7D8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View All Notifications'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String description,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
