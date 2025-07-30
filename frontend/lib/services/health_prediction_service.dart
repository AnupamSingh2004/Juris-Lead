import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'location_service.dart';

class HealthPredictionService {
  // Base URL for the ML model API
  static const String _baseUrl = 'http://192.168.165.1:8000/api';
  static const _storage = FlutterSecureStorage();
  
  // Health prediction data model
  static Map<String, dynamic> _currentPrediction = {};
  static DateTime? _lastUpdated;
  
  // Get access token for authentication
  static Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'access_token');
  }
  
  // Get current health prediction based on location
  static Future<Map<String, dynamic>> getCurrentHealthPrediction() async {
    try {
      // Get current location
      Position? position = await LocationService.getCurrentLocation();
      
      if (position == null) {
        return {
          'success': false,
          'message': 'Unable to get location',
          'prediction': 'Unknown',
          'confidence': 0.0,
        };
      }
      
      // Get current week
      DateTime now = DateTime.now();
      int weekOfYear = _getWeekOfYear(now);
      String weekString = '${now.year}-W${weekOfYear.toString().padLeft(2, '0')}';
      
      // Get location name from coordinates
      String locationName = LocationService.getAreaNameFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      // Create prediction request data
      Map<String, dynamic> requestData = {
        'Location': locationName,
        'Week': weekString,
        'Humidity_pct': 65.0, // Default values - can be enhanced with weather API
        'Rainfall_mm': 15.5,
        'FeverCases': 8,
        'Absenteeism_pct': 12.5,
        'ToiletUsage_pct': 85.0,
        'WaterIndex': 0.3,
        'NDVI': 0.5,
      };
      
      // Get auth token
      String? token = await _getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
          'prediction': 'Unknown',
          'confidence': 0.0,
        };
      }
      
      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/predict/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        
        // Cache the prediction
        _currentPrediction = data;
        _lastUpdated = DateTime.now();
        
        return {
          'success': true,
          'prediction': data['prediction'],
          'confidence': data['confidence'],
          'probabilities': data['probabilities'],
          'location': locationName,
          'coordinates': 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
          'week': weekString,
          'last_updated': _lastUpdated,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get health prediction: ${response.statusCode}',
          'prediction': 'Unknown',
          'confidence': 0.0,
        };
      }
    } catch (e) {
      print('Error getting health prediction: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'prediction': 'Unknown',
        'confidence': 0.0,
      };
    }
  }
  
  // Get batch predictions for multiple locations/scenarios
  static Future<Map<String, dynamic>> getBatchPredictions(List<Map<String, dynamic>> locations) async {
    try {
      String? token = await _getAuthToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/predict/batch/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'data': locations}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to get batch predictions: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error getting batch predictions: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
  
  // Check if prediction is recent (within last hour)
  static bool isPredictionCurrent() {
    if (_lastUpdated == null) return false;
    return DateTime.now().difference(_lastUpdated!).inHours < 1;
  }
  
  // Get cached prediction if available and current
  static Map<String, dynamic>? getCachedPrediction() {
    if (isPredictionCurrent()) {
      return _currentPrediction;
    }
    return null;
  }
  
  // Get risk level based on prediction
  static String getRiskLevel(String prediction, double confidence) {
    if (prediction == 'Healthy' && confidence > 0.9) {
      return 'Low';
    } else if (prediction == 'Healthy' && confidence > 0.7) {
      return 'Medium';
    } else if (prediction != 'Healthy') {
      return 'High';
    }
    return 'Unknown';
  }
  
  // Get risk color based on level
  static Color getRiskColor(String riskLevel) {
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
  
  // Get recommendations based on prediction
  static List<String> getRecommendations(String prediction, double confidence) {
    switch (prediction.toLowerCase()) {
      case 'dengue':
        return [
          'Use mosquito repellent and nets',
          'Remove standing water around your home',
          'Wear long-sleeved clothes during peak hours',
          'Seek medical attention if fever persists',
        ];
      case 'malaria':
        return [
          'Sleep under insecticide-treated bed nets',
          'Use mosquito repellent during evening hours',
          'Keep surroundings clean and dry',
          'Consult a doctor if experiencing fever and chills',
        ];
      case 'typhoid':
        return [
          'Ensure safe drinking water',
          'Practice good hand hygiene',
          'Eat freshly cooked food',
          'Get vaccinated if traveling to high-risk areas',
        ];
      case 'healthy':
        if (confidence < 0.8) {
          return [
            'Continue following preventive measures',
            'Monitor your health regularly',
            'Stay hydrated and eat nutritious food',
            'Report any unusual symptoms immediately',
          ];
        }
        return [
          'Great! Your area shows low disease risk',
          'Continue maintaining good hygiene',
          'Stay updated with health advisories',
          'Help spread awareness in your community',
        ];
      default:
        return [
          'Follow general health guidelines',
          'Maintain good hygiene practices',
          'Stay informed about health advisories',
          'Consult healthcare providers for concerns',
        ];
    }
  }
  
  // Helper method to get week of year
  static int _getWeekOfYear(DateTime date) {
    int dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
  
  // Get health status summary
  static Map<String, dynamic> getHealthStatusSummary(Map<String, dynamic> prediction) {
    if (!prediction['success']) {
      return {
        'status': 'Unknown',
        'message': 'Unable to determine health status',
        'color': Colors.grey,
        'icon': Icons.help_outline,
      };
    }
    
    String pred = prediction['prediction'];
    double confidence = prediction['confidence'];
    
    if (pred == 'Healthy') {
      return {
        'status': 'Healthy',
        'message': 'Your area shows low disease risk',
        'color': Colors.green,
        'icon': Icons.health_and_safety,
        'confidence': confidence,
      };
    } else {
      return {
        'status': 'Alert',
        'message': 'Potential $pred risk detected',
        'color': Colors.red,
        'icon': Icons.warning,
        'confidence': confidence,
        'disease': pred,
      };
    }
  }
}
