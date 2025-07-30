import 'package:flutter/material.dart';
import 'health_prediction_service.dart';

class AlertsService {
  // Alert severity levels based on prediction confidence
  static const double HIGH_RISK_THRESHOLD = 0.7;
  static const double MEDIUM_RISK_THRESHOLD = 0.4;
  static const double LOW_RISK_THRESHOLD = 0.2;
  
  // Generate alerts based on current health prediction
  static Future<List<AlertData>> generateAlertsFromPrediction() async {
    List<AlertData> alerts = [];
    
    try {
      // Get current health prediction
      Map<String, dynamic> prediction = await HealthPredictionService.getCurrentHealthPrediction();
      
      if (prediction['success'] == true) {
        String predictedDisease = prediction['prediction'] ?? 'Unknown';
        double confidence = prediction['confidence'] ?? 0.0;
        Map<String, dynamic>? probabilities = prediction['probabilities'];
        String location = prediction['location'] ?? 'Unknown Location';
        
        // Only generate alerts for actual diseases, not "Healthy" predictions
        if (confidence > LOW_RISK_THRESHOLD && !_isHealthyPrediction(predictedDisease)) {
          AlertData primaryAlert = _createPredictionAlert(
            predictedDisease, 
            confidence, 
            location
          );
          alerts.add(primaryAlert);
        }
        
        // Generate secondary alerts based on probabilities
        if (probabilities != null) {
          for (String disease in probabilities.keys) {
            double prob = probabilities[disease] ?? 0.0;
            if (prob > MEDIUM_RISK_THRESHOLD && 
                disease != predictedDisease && 
                !_isHealthyPrediction(disease)) {
              AlertData secondaryAlert = _createSecondaryAlert(disease, prob, location);
              alerts.add(secondaryAlert);
            }
          }
        }
        
        // If prediction is "Healthy" with high confidence, add a positive health message
        if (_isHealthyPrediction(predictedDisease) && confidence > 0.5) {
          alerts.add(_createHealthyStatusAlert(location, confidence));
        }
      }
      
      // Add general health tips and prevention alerts
      alerts.addAll(_generateGeneralHealthAlerts());
      
      // Add weather-based alerts if applicable
      alerts.addAll(_generateWeatherBasedAlerts());
      
    } catch (e) {
      print('Error generating alerts: $e');
      // Fallback to general alerts if prediction fails
      alerts.addAll(_generateFallbackAlerts());
    }
    
    return alerts;
  }
  
  // Create alert based on disease prediction
  static AlertData _createPredictionAlert(String disease, double confidence, String location) {
    String type = _getAlertType(confidence);
    bool isUrgent = confidence > HIGH_RISK_THRESHOLD;
    
    String title = _getAlertTitle(disease, confidence);
    String description = _getAlertDescription(disease, confidence, location);
    IconData icon = _getAlertIcon(disease);
    Color color = _getAlertColor(confidence);
    
    return AlertData(
      type: type,
      title: title,
      description: description,
      icon: icon,
      color: color,
      time: 'Now',
      isUrgent: isUrgent,
      timestamp: DateTime.now(),
    );
  }
  
  // Create secondary alert for other diseases with significant probability
  static AlertData _createSecondaryAlert(String disease, double probability, String location) {
    return AlertData(
      type: 'PREVENTION',
      title: '${_getDiseaseName(disease)} Prevention',
      description: 'Moderate ${_getDiseaseName(disease).toLowerCase()} risk detected in $location (${(probability * 100).toStringAsFixed(1)}% probability). Follow preventive measures.',
      icon: _getAlertIcon(disease),
      color: Colors.orange,
      time: 'Now',
      isUrgent: false,
      timestamp: DateTime.now(),
    );
  }
  
  // Create positive health status alert when prediction is "Healthy"
  static AlertData _createHealthyStatusAlert(String location, double confidence) {
    return AlertData(
      type: 'PREVENTION',
      title: 'Good Health Status',
      description: 'Health assessment shows good conditions in $location (${(confidence * 100).toStringAsFixed(1)}% confidence). Continue following preventive measures to maintain good health.',
      icon: Icons.health_and_safety,
      color: Colors.green,
      time: 'Now',
      isUrgent: false,
      timestamp: DateTime.now(),
    );
  }
  
  // Generate general health alerts
  static List<AlertData> _generateGeneralHealthAlerts() {
    List<AlertData> alerts = [];
    
    // Seasonal health tips
    DateTime now = DateTime.now();
    int month = now.month;
    
    if (month >= 6 && month <= 9) { // Monsoon season
      alerts.add(AlertData(
        type: 'PREVENTION',
        title: 'Monsoon Health Guidelines',
        description: 'Monsoon season is here. Prevent water-borne diseases by drinking boiled water, avoiding street food, and maintaining hygiene.',
        icon: Icons.water_drop,
        color: Colors.blue,
        time: '1 day ago',
        isUrgent: false,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ));
    }
    
    // Hand hygiene reminder
    alerts.add(AlertData(
      type: 'PREVENTION',
      title: 'Hand Hygiene Reminder',
      description: 'Regular handwashing is your first line of defense against infections. Wash hands for 20 seconds with soap and water.',
      icon: Icons.wash,
      color: Colors.green,
      time: '2 days ago',
      isUrgent: false,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ));
    
    return alerts;
  }
  
  // Generate weather-based alerts
  static List<AlertData> _generateWeatherBasedAlerts() {
    List<AlertData> alerts = [];
    
    // This would ideally connect to a weather API
    // For now, we'll generate based on season
    DateTime now = DateTime.now();
    int month = now.month;
    
    if (month >= 6 && month <= 9) { // Monsoon
      alerts.add(AlertData(
        type: 'ACTIVE',
        title: 'Mosquito Breeding Alert',
        description: 'Recent rainfall increases mosquito breeding. Remove stagnant water from containers, flower pots, and drains.',
        icon: Icons.bug_report,
        color: Colors.orange,
        time: '3 hours ago',
        isUrgent: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ));
    }
    
    return alerts;
  }
  
  // Generate fallback alerts when prediction fails
  static List<AlertData> _generateFallbackAlerts() {
    return [
      AlertData(
        type: 'PREVENTION',
        title: 'General Health Screening',
        description: 'Regular health monitoring is important. Schedule routine check-ups and maintain healthy habits.',
        icon: Icons.health_and_safety,
        color: Colors.blue,
        time: '1 hour ago',
        isUrgent: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AlertData(
        type: 'PREVENTION',
        title: 'Stay Hydrated',
        description: 'Proper hydration supports immune function. Drink at least 8 glasses of clean water daily.',
        icon: Icons.local_drink,
        color: Colors.cyan,
        time: '4 hours ago',
        isUrgent: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }
  
  // Helper methods
  static bool _isHealthyPrediction(String prediction) {
    // Check if the prediction indicates a healthy state (not a disease)
    String normalizedPrediction = prediction.toLowerCase().trim();
    return normalizedPrediction == 'healthy' || 
           normalizedPrediction == 'normal' || 
           normalizedPrediction == 'no_disease' ||
           normalizedPrediction == 'no disease' ||
           normalizedPrediction == 'safe' ||
           normalizedPrediction.contains('healthy') ||
           normalizedPrediction.contains('normal');
  }
  
  static String _getAlertType(double confidence) {
    if (confidence > HIGH_RISK_THRESHOLD) return 'EMERGENCY';
    if (confidence > MEDIUM_RISK_THRESHOLD) return 'ACTIVE';
    return 'PREVENTION';
  }
  
  static String _getAlertTitle(String disease, double confidence) {
    String diseaseName = _getDiseaseName(disease);
    
    if (confidence > HIGH_RISK_THRESHOLD) {
      return '$diseaseName Risk Alert';
    } else if (confidence > MEDIUM_RISK_THRESHOLD) {
      return '$diseaseName Prevention Required';
    } else {
      return '$diseaseName Awareness';
    }
  }
  
  static String _getAlertDescription(String disease, double confidence, String location) {
    String diseaseName = _getDiseaseName(disease);
    String confidencePercent = (confidence * 100).toStringAsFixed(1);
    
    if (confidence > HIGH_RISK_THRESHOLD) {
      return 'High $diseaseName risk detected in $location ($confidencePercent% confidence). Take immediate preventive actions and consult healthcare providers if symptoms appear.';
    } else if (confidence > MEDIUM_RISK_THRESHOLD) {
      return 'Moderate $diseaseName risk in $location ($confidencePercent% confidence). Follow preventive measures and monitor for symptoms.';
    } else {
      return 'Low $diseaseName risk in $location ($confidencePercent% confidence). Maintain good hygiene and healthy practices.';
    }
  }
  
  static IconData _getAlertIcon(String disease) {
    switch (disease.toLowerCase()) {
      case 'dengue':
        return Icons.coronavirus;
      case 'malaria':
        return Icons.bug_report;
      case 'typhoid':
        return Icons.water_drop;
      case 'chikungunya':
        return Icons.healing;
      default:
        return Icons.health_and_safety;
    }
  }
  
  static Color _getAlertColor(double confidence) {
    if (confidence > HIGH_RISK_THRESHOLD) return Colors.red;
    if (confidence > MEDIUM_RISK_THRESHOLD) return Colors.orange;
    return Colors.blue;
  }
  
  static String _getDiseaseName(String disease) {
    switch (disease.toLowerCase()) {
      case 'dengue':
        return 'Dengue';
      case 'malaria':
        return 'Malaria';
      case 'typhoid':
        return 'Typhoid';
      case 'chikungunya':
        return 'Chikungunya';
      default:
        return disease.split('_').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
        ).join(' ');
    }
  }
}

// Alert data model (moved from alerts_screen.dart)
class AlertData {
  final String type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String time;
  final bool isUrgent;
  final DateTime timestamp;

  AlertData({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.time,
    required this.isUrgent,
    required this.timestamp,
  });
}
