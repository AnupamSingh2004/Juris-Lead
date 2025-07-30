import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class LocationService {
  // Delhi area coordinates mapping for better location recognition
  static const Map<String, Map<String, double>> delhiAreas = {
    'Karol Bagh': {'lat': 28.5454, 'lng': 77.1900},
    'Connaught Place': {'lat': 28.6315, 'lng': 77.2167},
    'Chanakyapuri': {'lat': 28.5918, 'lng': 77.1874},
    'Dwarka': {'lat': 28.5921, 'lng': 77.0460},
    'Rohini': {'lat': 28.7041, 'lng': 77.1025},
    'Lajpat Nagar': {'lat': 28.5677, 'lng': 77.2436},
    'Vasant Kunj': {'lat': 28.5244, 'lng': 77.1590},
    'Mayur Vihar': {'lat': 28.6138, 'lng': 77.2905},
    'Pitampura': {'lat': 28.6962, 'lng': 77.1313},
    'Seelampur': {'lat': 28.6667, 'lng': 77.2833},
    'Najafgarh': {'lat': 28.6093, 'lng': 76.9794},
    'Greater Kailash': {'lat': 28.5494, 'lng': 77.2426},
    'Janakpuri': {'lat': 28.6219, 'lng': 77.0856},
    'Saket': {'lat': 28.5245, 'lng': 77.2066},
    'Preet Vihar': {'lat': 28.6472, 'lng': 77.2947},
    'Shahdara': {'lat': 28.6780, 'lng': 77.2897},
    'Paschim Vihar': {'lat': 28.6684, 'lng': 77.1026},
    'Kalkaji': {'lat': 28.5355, 'lng': 77.2588},
    'Malviya Nagar': {'lat': 28.5355, 'lng': 77.2077},
    'Vikaspuri': {'lat': 28.6281, 'lng': 77.0570},
  };

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<bool> requestLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  static Future<void> openLocationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening location settings: $e');
    }
  }

  // Get area name from coordinates
  static String getAreaNameFromCoordinates(double latitude, double longitude) {
    String closestArea = 'Karol Bagh'; // Default fallback
    double minDistance = double.infinity;
    
    for (String area in delhiAreas.keys) {
      double areaLat = delhiAreas[area]!['lat']!;
      double areaLng = delhiAreas[area]!['lng']!;
      
      // Calculate distance using Haversine formula (more accurate)
      double distance = _calculateDistance(latitude, longitude, areaLat, areaLng);
      
      if (distance < minDistance) {
        minDistance = distance;
        closestArea = area;
      }
    }
    
    return closestArea;
  }

  // Calculate distance between two points using Haversine formula
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = (dLat / 2) * (dLat / 2) +
        (dLon / 2) * (dLon / 2) * _cos(_toRadians(lat1)) * _cos(_toRadians(lat2));
    
    double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Helper math functions
  static double _toRadians(double degrees) => degrees * (math.pi / 180);
  static double _cos(double radians) => math.cos(radians);
  static double _sqrt(double value) => math.sqrt(value);
  static double _atan2(double y, double x) => math.atan2(y, x);

  // Get formatted location string with area name and coordinates
  static String getFormattedLocation(Position position) {
    String areaName = getAreaNameFromCoordinates(position.latitude, position.longitude);
    return '$areaName (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
  }
}
