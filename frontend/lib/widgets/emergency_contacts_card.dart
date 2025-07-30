import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsCard extends StatelessWidget {
  const EmergencyContactsCard({Key? key}) : super(key: key);

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
                Icons.emergency,
                color: Color(0xFF2E7D8A),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Emergency contacts list
          _buildEmergencyContact(
            'Ambulance',
            '108',
            Icons.local_hospital,
            Colors.red,
            'tel:108',
          ),
          const SizedBox(height: 8),
          _buildEmergencyContact(
            'Police',
            '100',
            Icons.local_police,
            Colors.blue,
            'tel:100',
          ),
          const SizedBox(height: 8),
          _buildEmergencyContact(
            'Fire Brigade',
            '101',
            Icons.local_fire_department,
            Colors.orange,
            'tel:101',
          ),
          const SizedBox(height: 8),
          _buildEmergencyContact(
            'Disaster Management',
            '1070',
            Icons.warning,
            Colors.purple,
            'tel:1070',
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(
    String name,
    String number,
    IconData icon,
    Color color,
    String callUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _makeCall(callUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Call',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
