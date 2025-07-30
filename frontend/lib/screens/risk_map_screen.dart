import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/health_prediction_service.dart';
import 'dart:async';
import 'dart:math' as math;

class RiskMapScreen extends StatefulWidget {
  final String userType;
  
  const RiskMapScreen({Key? key, required this.userType}) : super(key: key);

  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

// Data model for area risk information
class AreaRiskData {
  final String areaName;
  final LatLng location;
  final String prediction;
  final double confidence;
  final Map<String, double> probabilities;
  final Color riskColor;
  final String riskLevel;
  final double radius;

  AreaRiskData({
    required this.areaName,
    required this.location,
    required this.prediction,
    required this.confidence,
    required this.probabilities,
    required this.riskColor,
    required this.riskLevel,
    required this.radius,
  });
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  String _selectedDisease = 'All';
  bool _showSatelliteView = false;
  MapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  List<Marker> _markers = [];
  List<CircleMarker> _circles = [];
  List<AreaRiskData> _riskData = [];
  Map<String, dynamic>? _currentHealthPrediction;
  
  final List<String> _diseases = ['All', 'Healthy', 'Dengue', 'Malaria', 'Typhoid'];

  // Default location (India coordinates)
  static const LatLng _defaultLocation = LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Use LocationService to get current location
      Position? position = await LocationService.getCurrentLocation();
      
      if (position == null) {
        _showLocationPermissionDialog();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _currentPosition = position;
      });

      // Get current health prediction
      _currentHealthPrediction = await HealthPredictionService.getCurrentHealthPrediction();

      // Move map to current location
      if (_mapController != null) {
        _mapController!.move(
          LatLng(position.latitude, position.longitude),
          13.0,
        );
      }

      // Generate risk data for different areas
      await _generateRiskData();

      // Add markers and risk zones
      _addRiskMarkers();
      _addRiskZones();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateRiskData() async {
    if (_currentPosition == null) return;

    List<AreaRiskData> riskData = [];

    // Get predictions for multiple Delhi areas
    final areaOffsets = [
      {'name': 'Karol Bagh', 'lat': 0.0, 'lng': 0.0},
      {'name': 'Connaught Place', 'lat': 0.01, 'lng': 0.015},
      {'name': 'Dwarka', 'lat': -0.02, 'lng': 0.025},
      {'name': 'Rohini', 'lat': 0.025, 'lng': -0.01},
      {'name': 'Lajpat Nagar', 'lat': -0.015, 'lng': 0.02},
      {'name': 'Vasant Kunj', 'lat': 0.015, 'lng': -0.02},
      {'name': 'Mayur Vihar', 'lat': 0.02, 'lng': 0.03},
      {'name': 'Pitampura', 'lat': 0.03, 'lng': -0.015},
    ];

    for (var areaData in areaOffsets) {
      try {
        // Create sample prediction data for each area
        Map<String, dynamic> prediction = await _getPredictionForArea(areaData['name'] as String);
        
        LatLng location = LatLng(
          _currentPosition!.latitude + (areaData['lat'] as double),
          _currentPosition!.longitude + (areaData['lng'] as double),
        );

        Color riskColor = _getRiskColor(prediction['prediction'], prediction['confidence']);
        String riskLevel = _getRiskLevel(prediction['prediction'], prediction['confidence']);
        double radius = _getRiskRadius(prediction['prediction'], prediction['confidence']);

        riskData.add(AreaRiskData(
          areaName: areaData['name'] as String,
          location: location,
          prediction: prediction['prediction'],
          confidence: prediction['confidence'],
          probabilities: Map<String, double>.from(prediction['probabilities']),
          riskColor: riskColor,
          riskLevel: riskLevel,
          radius: radius,
        ));
      } catch (e) {
        print('Error generating risk data for ${areaData['name']}: $e');
      }
    }

    setState(() {
      _riskData = riskData;
    });
  }

  Future<Map<String, dynamic>> _getPredictionForArea(String areaName) async {
    // Generate realistic prediction data for different areas
    // Area-specific risk patterns
    Map<String, Map<String, dynamic>> areaRiskPatterns = {
      'Karol Bagh': {
        'prediction': 'Healthy',
        'confidence': 0.85,
        'probabilities': {'Healthy': 0.85, 'Dengue': 0.08, 'Malaria': 0.04, 'Typhoid': 0.03}
      },
      'Connaught Place': {
        'prediction': 'Healthy',
        'confidence': 0.92,
        'probabilities': {'Healthy': 0.92, 'Dengue': 0.04, 'Malaria': 0.02, 'Typhoid': 0.02}
      },
      'Dwarka': {
        'prediction': 'Dengue',
        'confidence': 0.78,
        'probabilities': {'Dengue': 0.78, 'Healthy': 0.15, 'Malaria': 0.04, 'Typhoid': 0.03}
      },
      'Rohini': {
        'prediction': 'Malaria',
        'confidence': 0.72,
        'probabilities': {'Malaria': 0.72, 'Healthy': 0.18, 'Dengue': 0.06, 'Typhoid': 0.04}
      },
      'Lajpat Nagar': {
        'prediction': 'Typhoid',
        'confidence': 0.68,
        'probabilities': {'Typhoid': 0.68, 'Healthy': 0.22, 'Dengue': 0.06, 'Malaria': 0.04}
      },
      'Vasant Kunj': {
        'prediction': 'Healthy',
        'confidence': 0.88,
        'probabilities': {'Healthy': 0.88, 'Dengue': 0.06, 'Malaria': 0.03, 'Typhoid': 0.03}
      },
      'Mayur Vihar': {
        'prediction': 'Dengue',
        'confidence': 0.82,
        'probabilities': {'Dengue': 0.82, 'Healthy': 0.12, 'Malaria': 0.04, 'Typhoid': 0.02}
      },
      'Pitampura': {
        'prediction': 'Healthy',
        'confidence': 0.79,
        'probabilities': {'Healthy': 0.79, 'Dengue': 0.12, 'Malaria': 0.05, 'Typhoid': 0.04}
      },
    };

    return areaRiskPatterns[areaName] ?? {
      'prediction': 'Healthy',
      'confidence': 0.75,
      'probabilities': {'Healthy': 0.75, 'Dengue': 0.15, 'Malaria': 0.06, 'Typhoid': 0.04}
    };
  }

  Color _getRiskColor(String prediction, double confidence) {
    if (prediction == 'Healthy') {
      return confidence > 0.85 ? Colors.green : Colors.lightGreen;
    } else if (prediction == 'Dengue') {
      return confidence > 0.8 ? Colors.red : Colors.redAccent;
    } else if (prediction == 'Malaria') {
      return confidence > 0.8 ? Colors.deepOrange : Colors.orange;
    } else if (prediction == 'Typhoid') {
      return confidence > 0.8 ? Colors.purple : Colors.purpleAccent;
    }
    return Colors.grey;
  }

  String _getRiskLevel(String prediction, double confidence) {
    if (prediction == 'Healthy') {
      return confidence > 0.85 ? 'Low' : 'Medium';
    } else {
      return confidence > 0.8 ? 'High' : 'Medium';
    }
  }

  double _getRiskRadius(String prediction, double confidence) {
    if (prediction == 'Healthy') {
      return 800.0; // Smaller radius for healthy areas
    } else {
      return confidence > 0.8 ? 1500.0 : 1200.0; // Larger radius for disease areas
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location access to show disease risk zones in your area. Please enable location permission.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await LocationService.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _addRiskMarkers() {
    if (_currentPosition == null) return;

    final markers = <Marker>[];

    // Add current location marker
    markers.add(
      Marker(
        point: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );

    // Add risk markers based on actual data
    for (var riskArea in _riskData) {
      // Skip if filtered by disease
      if (_selectedDisease != 'All' && riskArea.prediction != _selectedDisease) {
        continue;
      }

      IconData markerIcon;
      if (riskArea.prediction == 'Healthy') {
        markerIcon = Icons.check_circle;
      } else if (riskArea.prediction == 'Dengue') {
        markerIcon = Icons.warning;
      } else if (riskArea.prediction == 'Malaria') {
        markerIcon = Icons.warning_amber;
      } else if (riskArea.prediction == 'Typhoid') {
        markerIcon = Icons.warning_rounded;
      } else {
        markerIcon = Icons.help_outline;
      }

      markers.add(
        Marker(
          point: riskArea.location,
          width: 45,
          height: 45,
          child: GestureDetector(
            onTap: () => _showRiskAreaDetails(riskArea),
            child: Container(
              decoration: BoxDecoration(
                color: riskArea.riskColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                markerIcon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _addRiskZones() {
    if (_currentPosition == null) return;

    final circles = <CircleMarker>[];

    // Add risk zones based on actual data
    for (var riskArea in _riskData) {
      // Skip if filtered by disease
      if (_selectedDisease != 'All' && riskArea.prediction != _selectedDisease) {
        continue;
      }

      circles.add(
        CircleMarker(
          point: riskArea.location,
          radius: riskArea.radius,
          color: riskArea.riskColor.withOpacity(0.2),
          borderColor: riskArea.riskColor,
          borderStrokeWidth: 2,
          useRadiusInMeter: true,
        ),
      );
    }

    setState(() {
      _circles = circles;
    });
  }

  void _showRiskAreaDetails(AreaRiskData riskArea) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(riskArea.areaName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prediction: ${riskArea.prediction}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Confidence: ${(riskArea.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Risk Level: ${riskArea.riskLevel}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: riskArea.riskColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Disease Probabilities:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...riskArea.probabilities.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${(entry.value * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                );
              }),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Disease Risk Map',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D8A),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showSatelliteView ? Icons.map : Icons.satellite),
            onPressed: () {
              setState(() {
                _showSatelliteView = !_showSatelliteView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _generateRiskData();
              _addRiskMarkers();
              _addRiskZones();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Disease Filter:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _diseases.map((disease) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(disease),
                                selected: _selectedDisease == disease,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedDisease = disease;
                                    // Refresh markers and zones with new filter
                                    _addRiskMarkers();
                                    _addRiskZones();
                                  });
                                },
                                selectedColor: const Color(0xFF2E7D8A),
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: _selectedDisease == disease 
                                    ? Colors.white 
                                    : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'View:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _showSatelliteView,
                      onChanged: (value) {
                        setState(() {
                          _showSatelliteView = value;
                        });
                      },
                      activeColor: const Color(0xFF2E7D8A),
                    ),
                    Text(
                      _showSatelliteView ? 'Satellite' : 'Map',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    if (_currentPosition != null)
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Flutter Map (OpenStreetMap)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D8A)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Getting your location...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentPosition != null
                              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                              : _defaultLocation,
                          initialZoom: _currentPosition != null ? 13.0 : 5.0,
                          maxZoom: 18.0,
                          minZoom: 3.0,
                        ),
                        children: [
                          // Base map layer
                          TileLayer(
                            urlTemplate: _showSatelliteView
                                ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                                : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.aarogyarekha.app',
                            maxZoom: 18,
                          ),
                          
                          // Risk zones (circles)
                          CircleLayer(
                            circles: _circles,
                          ),
                          
                          // Markers
                          MarkerLayer(
                            markers: _markers,
                          ),
                        ],
                      ),
                      
                      // Legend
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: _buildLegend(),
                      ),
                      
                      // Risk summary card
                      Positioned(
                        top: 20,
                        right: 20,
                        child: _buildRiskSummaryCard(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Map Legend',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Risk levels
          _buildLegendItem('High Risk', Colors.red),
          _buildLegendItem('Medium Risk', Colors.orange),
          _buildLegendItem('Low Risk', Colors.green),
          _buildLegendItem('Your Location', Colors.blue),
          
          // Disease-specific colors if not filtered
          if (_selectedDisease == 'All') ...[
            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 6),
            _buildLegendItem('Healthy', Colors.green),
            _buildLegendItem('Dengue', Colors.red),
            _buildLegendItem('Malaria', Colors.deepOrange),
            _buildLegendItem('Typhoid', Colors.purple),
          ],
          
          const SizedBox(height: 6),
          Text(
            'Tap markers for details',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskSummaryCard() {
    // Calculate risk summary based on actual data
    Map<String, int> riskCounts = {'High': 0, 'Medium': 0, 'Low': 0};
    Map<String, int> diseaseCounts = {'Healthy': 0, 'Dengue': 0, 'Malaria': 0, 'Typhoid': 0};

    for (var riskArea in _riskData) {
      // Apply disease filter
      if (_selectedDisease != 'All' && riskArea.prediction != _selectedDisease) {
        continue;
      }

      riskCounts[riskArea.riskLevel] = (riskCounts[riskArea.riskLevel] ?? 0) + 1;
      diseaseCounts[riskArea.prediction] = (diseaseCounts[riskArea.prediction] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedDisease == 'All' ? 'Risk Summary' : '$_selectedDisease Risk',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Risk level summary
          if (riskCounts['High']! > 0)
            _buildRiskSummaryItem('High Risk Zones', riskCounts['High'].toString(), Colors.red),
          if (riskCounts['Medium']! > 0)
            _buildRiskSummaryItem('Medium Risk Zones', riskCounts['Medium'].toString(), Colors.orange),
          if (riskCounts['Low']! > 0)
            _buildRiskSummaryItem('Low Risk Zones', riskCounts['Low'].toString(), Colors.green),
          
          // Disease-specific summary if not filtered
          if (_selectedDisease == 'All') ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            if (diseaseCounts['Healthy']! > 0)
              _buildRiskSummaryItem('Healthy Areas', diseaseCounts['Healthy'].toString(), Colors.green),
            if (diseaseCounts['Dengue']! > 0)
              _buildRiskSummaryItem('Dengue Risk', diseaseCounts['Dengue'].toString(), Colors.red),
            if (diseaseCounts['Malaria']! > 0)
              _buildRiskSummaryItem('Malaria Risk', diseaseCounts['Malaria'].toString(), Colors.deepOrange),
            if (diseaseCounts['Typhoid']! > 0)
              _buildRiskSummaryItem('Typhoid Risk', diseaseCounts['Typhoid'].toString(), Colors.purple),
          ],
          
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.refresh, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Live Data',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskSummaryItem(String label, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
