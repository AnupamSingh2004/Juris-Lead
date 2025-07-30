import 'package:flutter/material.dart';
import '../services/health_prediction_service.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  final String userType;
  
  const ReportsAnalyticsScreen({Key? key, required this.userType}) : super(key: key);

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  String selectedTimeRange = 'Last 30 Days';
  String selectedDisease = 'All Diseases';
  Map<String, dynamic>? currentPrediction;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPredictionData();
  }

  Future<void> _loadPredictionData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final prediction = await HealthPredictionService.getCurrentHealthPrediction();
      setState(() {
        currentPrediction = prediction;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading prediction data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadPredictionData,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            _buildFilterSection(),
            const SizedBox(height: 20),
            
            // Disease Trends
            _buildDiseaseAnalytics(),
            const SizedBox(height: 20),
            
            // Outbreak Predictions
            _buildOutbreakPredictions(),
            const SizedBox(height: 20),
            
            // Historical Data
            _buildHistoricalData(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
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
            'Filter Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip('Time Range', selectedTimeRange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip('Disease', selectedDisease),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E7D8A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseAnalytics() {
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
            'Disease Trend Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          _buildDiseaseChart(),
          const SizedBox(height: 16),
          _buildDiseaseStats(),
        ],
      ),
    );
  }

  Widget _buildDiseaseChart() {
    if (isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentPrediction == null || !currentPrediction!['success']) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'Unable to load chart data',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Generate dynamic chart data based on current prediction
    final probabilities = currentPrediction!['probabilities'] as Map<String, dynamic>;
    final chartData = _generateChartData(probabilities);

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disease Risk Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildDynamicBarChart(chartData),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateChartData(Map<String, dynamic> probabilities) {
    // Convert probabilities to chart data format
    final chartData = probabilities.entries.map((entry) {
      Color color;
      switch (entry.key.toLowerCase()) {
        case 'malaria':
          color = Colors.red;
          break;
        case 'dengue':
          color = Colors.orange;
          break;
        case 'typhoid':
          color = Colors.blue;
          break;
        case 'healthy':
          color = Colors.green;
          break;
        default:
          color = Colors.purple;
      }
      
      return {
        'disease': entry.key,
        'probability': entry.value,
        'color': color,
      };
    }).toList();

    // Sort by probability (highest first)
    chartData.sort((a, b) => b['probability'].compareTo(a['probability']));
    
    return chartData;
  }

  Widget _buildDynamicBarChart(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    // Find the maximum probability for scaling
    final maxProbability = chartData.map((data) => data['probability'] as double).reduce((a, b) => a > b ? a : b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: chartData.map((data) {
        final disease = data['disease'] as String;
        final probability = data['probability'] as double;
        final color = data['color'] as Color;
        
        // Calculate bar height (minimum 20, maximum 120)
        final barHeight = (probability / maxProbability * 120).clamp(20.0, 120.0);
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Percentage label
                Text(
                  '${(probability * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                // Animated bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.8),
                          color,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Disease name
                Text(
                  disease,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDiseaseStats() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (currentPrediction == null || !currentPrediction!['success']) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Unable to load disease statistics',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final probabilities = currentPrediction!['probabilities'] as Map<String, dynamic>;
    final diseases = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: diseases.map((entry) {
        final disease = entry.key;
        final probability = entry.value;
        final isHighest = entry == diseases.first;
        
        Color diseaseColor;
        switch (disease.toLowerCase()) {
          case 'malaria':
            diseaseColor = Colors.red;
            break;
          case 'dengue':
            diseaseColor = Colors.orange;
            break;
          case 'typhoid':
            diseaseColor = Colors.blue;
            break;
          case 'healthy':
            diseaseColor = Colors.green;
            break;
          default:
            diseaseColor = Colors.purple;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighest ? diseaseColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isHighest ? Border.all(color: diseaseColor, width: 2) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: diseaseColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    disease,
                    style: TextStyle(
                      fontWeight: isHighest ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${(probability * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isHighest ? diseaseColor : Colors.grey,
                    fontSize: 14,
                    fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isHighest) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.trending_up,
                    color: diseaseColor,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOutbreakPredictions() {
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
            'Outbreak Prediction Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          _buildPredictionTimeline(),
        ],
      ),
    );
  }

  Widget _buildPredictionTimeline() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (currentPrediction == null || !currentPrediction!['success']) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.warning_amber,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Unable to load prediction data',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final prediction = currentPrediction!['prediction'];
    final confidence = currentPrediction!['confidence'];
    final location = currentPrediction!['location'];
    
    // Get risk level and color
    final riskLevel = HealthPredictionService.getRiskLevel(prediction, confidence);
    final riskColor = HealthPredictionService.getRiskColor(riskLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 4,
            color: riskColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Prediction: $prediction',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: $location',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  riskLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last Updated: ${DateTime.now().toString().split('.')[0]}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Recommendations:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...HealthPredictionService.getRecommendations(prediction, confidence)
              .take(3)
              .map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildHistoricalData() {
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
            'Historical Data Visualization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          _buildHistoricalChart(),
        ],
      ),
    );
  }

  Widget _buildHistoricalChart() {
    if (isLoading) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Generate historical data for the last 7 days
    final historicalData = _generateHistoricalData();

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risk Level Trend (Last 7 Days)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildHistoricalLineChart(historicalData),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateHistoricalData() {
    // Generate mock historical data for demonstration
    final currentPrediction = this.currentPrediction;
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      double riskLevel;
      
      if (currentPrediction != null && currentPrediction['success']) {
        final prediction = currentPrediction['prediction'];
        final confidence = currentPrediction['confidence'];
        
        // Simulate historical variation
        final baseRisk = prediction.toLowerCase() == 'healthy' ? 0.2 : 0.7;
        final variation = (i * 0.05) - 0.15; // Creates some variation
        riskLevel = (baseRisk + variation + (confidence * 0.3)).clamp(0.0, 1.0);
      } else {
        riskLevel = 0.5; // Default medium risk
      }

      data.add({
        'date': date,
        'riskLevel': riskLevel,
        'dayLabel': _getDayLabel(date),
      });
    }

    return data;
  }

  String _getDayLabel(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  Widget _buildHistoricalLineChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No historical data available',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    return Row(
      children: [
        // Y-axis labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildYAxisLabel('High', Colors.red),
            _buildYAxisLabel('Med', Colors.orange),
            _buildYAxisLabel('Low', Colors.green),
          ],
        ),
        const SizedBox(width: 8),
        // Chart area
        Expanded(
          child: Column(
            children: [
              // Chart with points and lines
              Expanded(
                child: Stack(
                  children: [
                    // Grid lines
                    _buildGridLines(),
                    // Data points and lines
                    _buildDataPoints(data),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // X-axis labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data.map((point) {
                  return Text(
                    point['dayLabel'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYAxisLabel(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGridLines() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataPoints(List<Map<String, dynamic>> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value;
        final riskLevel = point['riskLevel'] as double;
        
        // Calculate position from bottom (0 = bottom, 1 = top)
        final position = 1 - riskLevel;
        
        // Determine color based on risk level
        Color pointColor;
        if (riskLevel > 0.7) {
          pointColor = Colors.red;
        } else if (riskLevel > 0.4) {
          pointColor = Colors.orange;
        } else {
          pointColor = Colors.green;
        }

        return Expanded(
          child: Stack(
            children: [
              // Data point
              Positioned(
                bottom: position * 60, // Adjust for chart height
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: pointColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: pointColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Line to next point (if not last)
              if (index < data.length - 1)
                Positioned(
                  bottom: position * 60,
                  left: 6,
                  right: -6,
                  child: Container(
                    height: 2,
                    color: pointColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Time Range'),
                subtitle: Text(selectedTimeRange),
                onTap: () {
                  // Show time range picker
                },
              ),
              ListTile(
                title: const Text('Disease Type'),
                subtitle: Text(selectedDisease),
                onTap: () {
                  // Show disease picker
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Apply filters
                setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
