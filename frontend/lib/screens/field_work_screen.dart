import 'package:flutter/material.dart';

class FieldWorkScreen extends StatefulWidget {
  final String userType;
  
  const FieldWorkScreen({Key? key, required this.userType}) : super(key: key);

  @override
  State<FieldWorkScreen> createState() => _FieldWorkScreenState();
}

class _FieldWorkScreenState extends State<FieldWorkScreen> {
  String selectedTab = 'scheduler';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Work'),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tab Navigation
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('scheduler', 'House Visits'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton('high_risk', 'High Risk Homes'),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: selectedTab == 'scheduler' 
                ? _buildHouseVisitScheduler() 
                : _buildHighRiskHomes(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label) {
    final isSelected = selectedTab == tabId;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tabId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D8A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHouseVisitScheduler() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Today's Schedule
          _buildScheduleCard(),
          const SizedBox(height: 16),
          
          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 16),
          
          // Scheduled Visits
          Expanded(
            child: _buildScheduledVisits(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
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
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                color: Color(0xFF2E7D8A),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '8 visits scheduled',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
              ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '3 completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Next visit: Rajesh Kumar (House #42) - 2:30 PM',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Schedule Visit',
                  Icons.add_circle_outline,
                  Colors.blue,
                  () => _showScheduleDialog(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'Emergency Visit',
                  Icons.warning,
                  Colors.red,
                  () => _showEmergencyDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledVisits() {
    final visits = [
      {
        'name': 'Rajesh Kumar',
        'address': 'House #42, Sector A',
        'time': '2:30 PM',
        'purpose': 'Health checkup',
        'status': 'upcoming',
      },
      {
        'name': 'Priya Sharma',
        'address': 'House #156, Sector B',
        'time': '3:15 PM',
        'purpose': 'Vaccination follow-up',
        'status': 'upcoming',
      },
      {
        'name': 'Ramesh Patel',
        'address': 'House #89, Sector C',
        'time': '4:00 PM',
        'purpose': 'Malaria screening',
        'status': 'upcoming',
      },
    ];

    return Container(
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Upcoming Visits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D8A),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return _buildVisitCard(visit);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(Map<String, String> visit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                visit['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  visit['time']!,
                  style: const TextStyle(
                    color: Color(0xFF2E7D8A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                visit['address']!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Purpose: ${visit['purpose']!}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showVisitDetails(visit),
                child: const Text('View Details'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _startVisit(visit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Start Visit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighRiskHomes() {
    final highRiskHomes = [
      {
        'name': 'Sunita Devi',
        'address': 'House #23, Sector A',
        'riskLevel': 'High',
        'issues': ['Malaria symptoms', 'Poor sanitation'],
        'lastVisit': '2 days ago',
      },
      {
        'name': 'Mohan Lal',
        'address': 'House #78, Sector B',
        'riskLevel': 'High',
        'issues': ['Dengue risk area', 'Stagnant water'],
        'lastVisit': '1 week ago',
      },
      {
        'name': 'Kamala Sharma',
        'address': 'House #145, Sector C',
        'riskLevel': 'Medium',
        'issues': ['Malnutrition concern', 'Elderly care'],
        'lastVisit': '3 days ago',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'High Risk Homes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: highRiskHomes.length,
              itemBuilder: (context, index) {
                final home = highRiskHomes[index];
                return _buildHighRiskHomeCard(home);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighRiskHomeCard(Map<String, dynamic> home) {
    Color riskColor = home['riskLevel'] == 'High' ? Colors.red : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                home['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${home['riskLevel']} Risk',
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                home['address']!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Issues:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (home['issues'] as List<String>).map((issue) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.grey)),
                    Text(
                      issue,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Last visit: ${home['lastVisit']}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showHomeDetails(home),
                child: const Text('View Details'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _scheduleUrgentVisit(home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: riskColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Schedule Visit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule New Visit'),
        content: const Text('Schedule visit functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Visit'),
        content: const Text('Emergency visit functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showVisitDetails(Map<String, String> visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(visit['name']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${visit['address']!}'),
            const SizedBox(height: 8),
            Text('Time: ${visit['time']!}'),
            const SizedBox(height: 8),
            Text('Purpose: ${visit['purpose']!}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startVisit(Map<String, String> visit) {
    // Navigate to visit details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting visit to ${visit['name']}'),
        backgroundColor: const Color(0xFF2E7D8A),
      ),
    );
  }

  void _showHomeDetails(Map<String, dynamic> home) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(home['name']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${home['address']!}'),
            const SizedBox(height: 8),
            Text('Risk Level: ${home['riskLevel']}'),
            const SizedBox(height: 8),
            Text('Last Visit: ${home['lastVisit']}'),
            const SizedBox(height: 8),
            const Text('Issues:'),
            ...(home['issues'] as List<String>).map((issue) => 
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('• $issue'),
              )
            ).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _scheduleUrgentVisit(Map<String, dynamic> home) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scheduling urgent visit to ${home['name']}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
