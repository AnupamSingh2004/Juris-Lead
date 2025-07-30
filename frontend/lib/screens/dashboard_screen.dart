import 'package:flutter/material.dart';
import '../widgets/risk_status_card.dart';
import '../widgets/emergency_contacts_card.dart';
import '../widgets/recent_notifications_card.dart';
import '../services/health_prediction_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class DashboardScreen extends StatefulWidget {
  final String userType;
  final VoidCallback? onNavigateToRiskMap;
  final VoidCallback? onNavigateToAlerts;
  
  const DashboardScreen({
    Key? key, 
    required this.userType,
    this.onNavigateToRiskMap,
    this.onNavigateToAlerts,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State variables for dynamic data
  Map<String, dynamic>? _healthPrediction;
  Position? _currentPosition;
  String _currentLocation = 'Loading...';
  bool _isLoading = true;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/logo/logo.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AarogyaRekha',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D8A),
        elevation: 0,
        actions: [
          // Satellite Status Indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.satellite,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location & AI Status Header
              _buildLocationHeader(),
              const SizedBox(height: 16),
              
              // Critical Alert Banner (if any)
              _buildCriticalAlertBanner(),
              const SizedBox(height: 16),
              
              // Risk Status Card
              RiskStatusCard(
                healthPrediction: _healthPrediction,
                isLoading: _isLoading,
                onViewRiskMap: widget.onNavigateToRiskMap,
              ),
              const SizedBox(height: 16),
              
              // Weather and Satellite Intelligence
              _buildSatelliteIntelligence(),
              const SizedBox(height: 16),
              
              // Emergency Contacts
              const EmergencyContactsCard(),
              const SizedBox(height: 16),
              
              // Recent Notifications
              RecentNotificationsCard(
                onViewAllNotifications: widget.onNavigateToAlerts,
              ),
              const SizedBox(height: 16),
              
              // Community Health Snapshot
              _buildCommunityHealthSnapshot(),
              const SizedBox(height: 16),
              
              // Disease Prevention Tips
              _buildPreventionTips(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
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
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF2E7D8A),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentLocation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Show area name from prediction if available
          if (_healthPrediction != null && _healthPrediction!['success'] && _healthPrediction!['location'] != null)
            Text(
              'Area: ${_healthPrediction!['location']}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D8A),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _lastUpdated != null 
                    ? 'Last updated: ${_getTimeAgo(_lastUpdated!)}'
                    : 'Last updated: Never',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Icon(
                _healthPrediction?['success'] == true ? Icons.wifi : Icons.wifi_off,
                color: _healthPrediction?['success'] == true ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _healthPrediction?['success'] == true ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  color: _healthPrediction?['success'] == true ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertBanner() {
    // Only show if there's a critical alert (non-healthy prediction)
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return const SizedBox.shrink();
    }

    String prediction = _healthPrediction!['prediction'];
    double confidence = _healthPrediction!['confidence'];

    // Only show banner for non-healthy predictions
    if (prediction.toLowerCase() == 'healthy') {
      return const SizedBox.shrink();
    }

    Color alertColor = Colors.red;
    IconData alertIcon = Icons.warning;
    String alertTitle = 'High ${prediction.toUpperCase()} Risk Alert';
    String alertMessage = 'Potential ${prediction.toLowerCase()} risk detected in your area';

    if (confidence < 0.7) {
      alertColor = Colors.orange;
      alertIcon = Icons.info;
      alertTitle = 'Moderate ${prediction.toUpperCase()} Risk Alert';
      alertMessage = 'Possible ${prediction.toLowerCase()} risk - stay vigilant';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            alertIcon,
            color: alertColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alertTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: alertColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alertMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: alertColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: alertColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to alerts screen or show recommendations
              _showHealthRecommendations();
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildSatelliteIntelligence() {
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
          Row(
            children: [
              const Icon(
                Icons.satellite,
                color: Color(0xFF2E7D8A),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Satellite Intelligence',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D8A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sentinel-2 Active',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Satellite Data Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: _buildSatelliteDataCards(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSatelliteDataCards() {
    if (_isLoading) {
      return [
        _buildSatelliteDataCard('Loading...', '--', Icons.hourglass_empty, Colors.grey, 'Please wait'),
        _buildSatelliteDataCard('Loading...', '--', Icons.hourglass_empty, Colors.grey, 'Please wait'),
        _buildSatelliteDataCard('Loading...', '--', Icons.hourglass_empty, Colors.grey, 'Please wait'),
        _buildSatelliteDataCard('Loading...', '--', Icons.hourglass_empty, Colors.grey, 'Please wait'),
      ];
    }

    // Default values if no prediction available
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return [
        _buildSatelliteDataCard('Water Bodies', 'N/A', Icons.water, Colors.grey, 'Data unavailable'),
        _buildSatelliteDataCard('Sanitation', 'N/A', Icons.cleaning_services, Colors.grey, 'Data unavailable'),
        _buildSatelliteDataCard('Temperature', 'N/A', Icons.thermostat, Colors.grey, 'Data unavailable'),
        _buildSatelliteDataCard('Humidity', 'N/A', Icons.opacity, Colors.grey, 'Data unavailable'),
      ];
    }

    String prediction = _healthPrediction!['prediction'];
    String areaName = _healthPrediction!['location'] ?? 'Unknown Area';

    // Dynamic data based on prediction and area
    List<Widget> cards = [];

    // Water Bodies - higher risk for mosquito-borne diseases
    if (prediction.toLowerCase() == 'dengue' || prediction.toLowerCase() == 'malaria') {
      int waterBodies = _getWaterBodiesCount(areaName);
      cards.add(_buildSatelliteDataCard(
        'Water Bodies',
        '$waterBodies detected',
        Icons.water,
        Colors.red,
        'High breeding risk',
      ));
    } else {
      int waterBodies = _getWaterBodiesCount(areaName, isHealthy: true);
      cards.add(_buildSatelliteDataCard(
        'Water Bodies',
        '$waterBodies detected',
        Icons.water,
        Colors.blue,
        'Monitored sites',
      ));
    }

    // Sanitation - affects disease transmission
    if (prediction.toLowerCase() == 'dengue' || prediction.toLowerCase() == 'malaria') {
      int sanitationScore = _getSanitationScore(areaName);
      cards.add(_buildSatelliteDataCard(
        'Sanitation',
        'Score: $sanitationScore/100',
        Icons.cleaning_services,
        Colors.red,
        'Poor sanitation',
      ));
    } else if (prediction.toLowerCase() == 'typhoid' || prediction.toLowerCase() == 'diarrhea') {
      int sanitationScore = _getSanitationScore(areaName);
      cards.add(_buildSatelliteDataCard(
        'Sanitation',
        'Score: $sanitationScore/100',
        Icons.cleaning_services,
        Colors.orange,
        'Needs improvement',
      ));
    } else {
      int sanitationScore = _getSanitationScore(areaName, isHealthy: true);
      cards.add(_buildSatelliteDataCard(
        'Sanitation',
        'Score: $sanitationScore/100',
        Icons.cleaning_services,
        Colors.green,
        'Good sanitation',
      ));
    }

    // Temperature - affects disease transmission
    double temperature = _getTemperature(areaName, prediction);
    if (prediction.toLowerCase() == 'dengue' || prediction.toLowerCase() == 'malaria') {
      cards.add(_buildSatelliteDataCard(
        'Temperature',
        '${temperature.toStringAsFixed(1)}°C',
        Icons.thermostat,
        Colors.red,
        'High risk temp',
      ));
    } else {
      cards.add(_buildSatelliteDataCard(
        'Temperature',
        '${temperature.toStringAsFixed(1)}°C',
        Icons.thermostat,
        Colors.orange,
        'Moderate temp',
      ));
    }

    // Humidity - affects disease vectors
    double humidity = _getHumidity(areaName, prediction);
    if (prediction.toLowerCase() == 'dengue' || prediction.toLowerCase() == 'malaria') {
      cards.add(_buildSatelliteDataCard(
        'Humidity',
        '${humidity.toStringAsFixed(0)}%',
        Icons.opacity,
        Colors.red,
        'High moisture',
      ));
    } else if (prediction.toLowerCase() == 'typhoid') {
      cards.add(_buildSatelliteDataCard(
        'Humidity',
        '${humidity.toStringAsFixed(0)}%',
        Icons.opacity,
        Colors.orange,
        'Moderate moisture',
      ));
    } else {
      cards.add(_buildSatelliteDataCard(
        'Humidity',
        '${humidity.toStringAsFixed(0)}%',
        Icons.opacity,
        Colors.blue,
        'Normal moisture',
      ));
    }

    return cards;
  }

  // Helper methods to get area-specific environmental data
  int _getWaterBodiesCount(String areaName, {bool isHealthy = false}) {
    // Simulate area-specific water body counts
    Map<String, int> waterBodies = {
      'Karol Bagh': 8,
      'Connaught Place': 5,
      'Chanakyapuri': 12,
      'Dwarka': 15,
      'Rohini': 18,
      'Lajpat Nagar': 10,
      'Vasant Kunj': 6,
      'Mayur Vihar': 20,
      'Pitampura': 14,
      'Seelampur': 25,
      'Najafgarh': 30,
      'Greater Kailash': 7,
    };
    
    int baseCount = waterBodies[areaName] ?? 10;
    return isHealthy ? baseCount : (baseCount * 1.5).round();
  }

  int _getSanitationScore(String areaName, {bool isHealthy = false}) {
    // Area-specific sanitation scores out of 100
    Map<String, int> sanitationScores = {
      'Karol Bagh': 75,
      'Connaught Place': 85,
      'Chanakyapuri': 92,
      'Dwarka': 78,
      'Rohini': 72,
      'Lajpat Nagar': 68,
      'Vasant Kunj': 88,
      'Mayur Vihar': 65,
      'Pitampura': 74,
      'Seelampur': 45,
      'Najafgarh': 52,
      'Greater Kailash': 82,
    };
    
    int baseScore = sanitationScores[areaName] ?? 70;
    return isHealthy ? (baseScore + 10).clamp(0, 100) : (baseScore - 15).clamp(0, 100);
  }

  double _getTemperature(String areaName, String prediction) {
    // Area-specific temperature variations
    Map<String, double> temperatures = {
      'Karol Bagh': 30.5,
      'Connaught Place': 31.0,
      'Chanakyapuri': 29.5,
      'Dwarka': 32.0,
      'Rohini': 31.5,
      'Lajpat Nagar': 30.8,
      'Vasant Kunj': 29.0,
      'Mayur Vihar': 31.2,
      'Pitampura': 30.0,
      'Seelampur': 32.5,
      'Najafgarh': 33.0,
      'Greater Kailash': 29.8,
    };
    
    double baseTemp = temperatures[areaName] ?? 30.5;
    
    // Adjust based on prediction
    if (prediction.toLowerCase() == 'dengue' || prediction.toLowerCase() == 'malaria') {
      return baseTemp + 2.0;
    } else {
      return baseTemp;
    }
  }

  double _getHumidity(String areaName, String prediction) {
    // Area-specific humidity levels
    Map<String, double> humidity = {
      'Karol Bagh': 65.0,
      'Connaught Place': 60.0,
      'Chanakyapuri': 70.0,
      'Dwarka': 68.0,
      'Rohini': 72.0,
      'Lajpat Nagar': 66.0,
      'Vasant Kunj': 58.0,
      'Mayur Vihar': 74.0,
      'Pitampura': 63.0,
      'Seelampur': 76.0,
      'Najafgarh': 80.0,
      'Greater Kailash': 62.0,
    };
    
    double baseHumidity = humidity[areaName] ?? 65.0;
    
    // Adjust based on prediction
    if (prediction.toLowerCase() == 'dengue' || prediction.toLowerCase() == 'malaria') {
      return baseHumidity + 15.0;
    } else if (prediction.toLowerCase() == 'typhoid') {
      return baseHumidity + 10.0;
    } else {
      return baseHumidity;
    }
  }

  Widget _buildSatelliteDataCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityHealthSnapshot() {
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
            'Community Health Snapshot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildHealthMetric(
                  'Active Cases',
                  _getActiveCases(),
                  Colors.red,
                  Icons.sick,
                  _getActiveCasesTrend(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthMetric(
                  'Recovered',
                  _getRecoveredCases(),
                  Colors.green,
                  Icons.health_and_safety,
                  _getRecoveredTrend(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildHealthMetric(
                  'Vaccinated',
                  _getVaccinationRate(),
                  Colors.blue,
                  Icons.vaccines,
                  'Target: 95%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthMetric(
                  'Risk Level',
                  _getCommunityRiskLevel(),
                  _getCommunityRiskColor(),
                  Icons.warning,
                  _getRiskTrend(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for dynamic community health data
  String _getActiveCases() {
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return 'N/A';
    }
    
    String prediction = _healthPrediction!['prediction'];
    double confidence = _healthPrediction!['confidence'];
    
    if (prediction.toLowerCase() == 'healthy') {
      return '12';
    } else if (confidence > 0.8) {
      return '45';
    } else {
      return '28';
    }
  }

  String _getActiveCasesTrend() {
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return 'No data';
    }
    
    String prediction = _healthPrediction!['prediction'];
    
    if (prediction.toLowerCase() == 'healthy') {
      return '-3 from yesterday';
    } else {
      return '+8 from yesterday';
    }
  }

  String _getRecoveredCases() {
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return 'N/A';
    }
    
    String prediction = _healthPrediction!['prediction'];
    
    if (prediction.toLowerCase() == 'healthy') {
      return '234';
    } else {
      return '189';
    }
  }

  String _getRecoveredTrend() {
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return 'No data';
    }
    
    String prediction = _healthPrediction!['prediction'];
    
    if (prediction.toLowerCase() == 'healthy') {
      return '+12 from yesterday';
    } else {
      return '+5 from yesterday';
    }
  }

  String _getVaccinationRate() {
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return 'N/A';
    }
    
    String prediction = _healthPrediction!['prediction'];
    
    if (prediction.toLowerCase() == 'healthy') {
      return '92%';
    } else {
      return '87%';
    }
  }

  String _getCommunityRiskLevel() {
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return 'Unknown';
    }
    
    String prediction = _healthPrediction!['prediction'];
    double confidence = _healthPrediction!['confidence'];
    
    if (prediction.toLowerCase() == 'healthy' && confidence > 0.9) {
      return 'Low';
    } else if (prediction.toLowerCase() == 'healthy') {
      return 'Medium';
    } else if (confidence > 0.8) {
      return 'High';
    } else {
      return 'Medium';
    }
  }

  Color _getCommunityRiskColor() {
    String riskLevel = _getCommunityRiskLevel();
    
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRiskTrend() {
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return 'No data';
    }
    
    String prediction = _healthPrediction!['prediction'];
    
    if (prediction.toLowerCase() == 'healthy') {
      return 'Decreasing trend';
    } else {
      return 'Increasing trend';
    }
  }

  Widget _buildHealthMetric(String title, String value, Color color, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionTips() {
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
            'Today\'s Prevention Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          
          ..._buildDynamicTips(),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicTips() {
    if (_isLoading) {
      return [
        _buildTipItem(
          'Loading health recommendations...',
          'Please wait while we fetch the latest data',
          Icons.hourglass_empty,
          Colors.grey,
        ),
      ];
    }

    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return [
        _buildTipItem(
          'General health guidelines',
          'Follow basic hygiene and safety practices',
          Icons.health_and_safety,
          Colors.grey,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Stay hydrated',
          'Drink plenty of clean water throughout the day',
          Icons.water_drop,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Maintain cleanliness',
          'Keep your surroundings clean and hygienic',
          Icons.cleaning_services,
          Colors.green,
        ),
      ];
    }

    String prediction = _healthPrediction!['prediction'];

    List<Widget> tips = [];
    
    if (prediction.toLowerCase() == 'dengue') {
      tips.addAll([
        _buildTipItem(
          'Eliminate standing water',
          'Remove stagnant water from containers, pots, and drains',
          Icons.water_drop,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Use mosquito protection',
          'Apply repellent and use nets, especially during dawn and dusk',
          Icons.bug_report,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Seek medical attention',
          'Consult a doctor immediately if you experience fever',
          Icons.local_hospital,
          Colors.red,
        ),
      ]);
    } else if (prediction.toLowerCase() == 'malaria') {
      tips.addAll([
        _buildTipItem(
          'Sleep under treated nets',
          'Use insecticide-treated bed nets every night',
          Icons.bed,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Evening protection',
          'Use repellent during evening hours when mosquitoes are active',
          Icons.bug_report,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Monitor symptoms',
          'Watch for fever, chills, and headaches',
          Icons.thermostat,
          Colors.red,
        ),
      ]);
    } else if (prediction.toLowerCase() == 'typhoid') {
      tips.addAll([
        _buildTipItem(
          'Safe drinking water',
          'Boil water or use purified water for drinking',
          Icons.water_drop,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Hand hygiene',
          'Wash hands frequently with soap and water',
          Icons.wash,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Food safety',
          'Eat freshly cooked food and avoid street food',
          Icons.restaurant,
          Colors.orange,
        ),
      ]);
    } else {
      // Healthy prediction
      tips.addAll([
        _buildTipItem(
          'Maintain good practices',
          'Continue following preventive health measures',
          Icons.health_and_safety,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Stay vigilant',
          'Monitor your health and surroundings regularly',
          Icons.visibility,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          'Community awareness',
          'Share health information with neighbors and family',
          Icons.group,
          Colors.orange,
        ),
      ]);
    }

    return tips;
  }

  Widget _buildTipItem(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Show health recommendations dialog
  void _showHealthRecommendations() {
    if (_healthPrediction == null || !_healthPrediction!['success']) {
      return;
    }

    String prediction = _healthPrediction!['prediction'];
    double confidence = _healthPrediction!['confidence'];
    List<String> recommendations = HealthPredictionService.getRecommendations(prediction, confidence);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Health Recommendations'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Based on $prediction prediction (${(confidence * 100).toStringAsFixed(1)}% confidence):',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to format time ago
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location
      _currentPosition = await LocationService.getCurrentLocation();
      
      // Get health prediction
      _healthPrediction = await HealthPredictionService.getCurrentHealthPrediction();
      
      // Update location name with area name
      if (_currentPosition != null) {
        _currentLocation = LocationService.getFormattedLocation(_currentPosition!);
      } else {
        _currentLocation = 'Location unavailable';
      }
      
      _lastUpdated = DateTime.now();
      
    } catch (e) {
      print('Error refreshing data: $e');
      // Set default values on error
      _healthPrediction = {
        'success': false,
        'message': 'Unable to load health data',
        'prediction': 'Unknown',
        'confidence': 0.0,
      };
      _currentLocation = 'Location error';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
