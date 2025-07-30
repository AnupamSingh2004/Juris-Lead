import 'package:flutter/material.dart';

class UserSpecificActions extends StatelessWidget {
  final String userType;
  
  const UserSpecificActions({Key? key, required this.userType}) : super(key: key);

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
                Icons.dashboard,
                color: Color(0xFF2E7D8A),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User-specific action buttons
          _buildUserSpecificContent(context),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (userType) {
      case 'ASHA':
        return 'Field Work Dashboard';
      case 'PHC':
        return 'Administrative Dashboard';
      case 'Rural':
        return 'Family Health Tools';
      case 'Tourist':
        return 'Travel Safety Tools';
      default:
        return 'Quick Actions';
    }
  }

  Widget _buildUserSpecificContent(BuildContext context) {
    switch (userType) {
      case 'ASHA':
        return _buildASHAActions(context);
      case 'PHC':
        return _buildPHCActions(context);
      case 'Rural':
        return _buildRuralActions(context);
      case 'Tourist':
        return _buildTouristActions(context);
      default:
        return _buildRuralActions(context);
    }
  }

  Widget _buildASHAActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildActionButton(
              'House Visits',
              Icons.home_work,
              Colors.blue,
              () => {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'High Risk Homes',
              Icons.warning,
              Colors.red,
              () => {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildActionButton(
              'Report Case',
              Icons.report,
              Colors.orange,
              () => {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'Training Hub',
              Icons.school,
              Colors.green,
              () => {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPHCActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildActionButton(
              'Resource Mgmt',
              Icons.inventory,
              Colors.purple,
              () => {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'Staff Coord',
              Icons.group,
              Colors.teal,
              () => {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildActionButton(
              'Analytics',
              Icons.analytics,
              Colors.indigo,
              () => {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'Campaigns',
              Icons.campaign,
              Colors.pink,
              () => {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRuralActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildActionButton(
              'Family Health',
              Icons.family_restroom,
              Colors.green,
              () => {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'Home Safety',
              Icons.home,
              Colors.blue,
              () => {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildActionButton(
              'Health Facilities',
              Icons.local_hospital,
              Colors.red,
              () => {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'Health Education',
              Icons.menu_book,
              Colors.orange,
              () => {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTouristActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildActionButton(
              'Travel Safety',
              Icons.travel_explore,
              Colors.blue,
              () => {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'Safe Routes',
              Icons.route,
              Colors.green,
              () => {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildActionButton(
              'Emergency',
              Icons.emergency,
              Colors.red,
              () => {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'Health Prep',
              Icons.vaccines,
              Colors.purple,
              () => {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
