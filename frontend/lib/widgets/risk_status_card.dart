import 'package:flutter/material.dart';

class RiskStatusCard extends StatelessWidget {
  final Map<String, dynamic>? healthPrediction;
  final bool isLoading;
  final VoidCallback? onViewRiskMap;
  
  const RiskStatusCard({
    Key? key,
    this.healthPrediction,
    this.isLoading = false,
    this.onViewRiskMap,
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
                Icons.health_and_safety,
                color: Color(0xFF2E7D8A),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Real-time Risk Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D8A),
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Risk level indicator
          _buildRiskIndicator(),
          
          const SizedBox(height: 12),
          
          // Disease risk breakdown
          _buildRiskBreakdown(),
          
          const SizedBox(height: 16),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewRiskMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Detailed Risk Map'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator() {
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Loading health data...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (healthPrediction == null || !healthPrediction!['success']) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.grey, size: 16),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATA UNAVAILABLE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Unable to load health risk data',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    String prediction = healthPrediction!['prediction'];
    double confidence = healthPrediction!['confidence'];
    
    Color riskColor;
    String riskLevel;
    String riskMessage;

    if (prediction.toLowerCase() == 'healthy') {
      if (confidence > 0.9) {
        riskColor = Colors.green;
        riskLevel = 'LOW RISK';
        riskMessage = 'Your area shows low disease risk';
      } else {
        riskColor = Colors.orange;
        riskLevel = 'MODERATE RISK';
        riskMessage = 'Monitor conditions, some uncertainty in prediction';
      }
    } else {
      if (confidence > 0.8) {
        riskColor = Colors.red;
        riskLevel = 'HIGH RISK';
        riskMessage = 'Potential ${prediction.toLowerCase()} risk detected';
      } else {
        riskColor = Colors.orange;
        riskLevel = 'MODERATE RISK';
        riskMessage = 'Possible ${prediction.toLowerCase()} risk - stay vigilant';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: riskColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: riskColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riskLevel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
                Text(
                  riskMessage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBreakdown() {
    if (isLoading || healthPrediction == null || !healthPrediction!['success']) {
      return Row(
        children: [
          _buildRiskIndicatorSmall('Loading...', Colors.grey, 'N/A'),
          const SizedBox(width: 12),
          _buildRiskIndicatorSmall('Loading...', Colors.grey, 'N/A'),
          const SizedBox(width: 12),
          _buildRiskIndicatorSmall('Loading...', Colors.grey, 'N/A'),
        ],
      );
    }

    String prediction = healthPrediction!['prediction'];
    double confidence = healthPrediction!['confidence'];

    // Create risk breakdown based on prediction
    List<Map<String, dynamic>> risks = [];
    
    if (prediction.toLowerCase() == 'dengue') {
      risks = [
        {'disease': 'Dengue', 'color': Colors.red, 'level': confidence > 0.8 ? 'High' : 'Medium'},
        {'disease': 'Malaria', 'color': Colors.orange, 'level': 'Medium'},
        {'disease': 'Typhoid', 'color': Colors.green, 'level': 'Low'},
      ];
    } else if (prediction.toLowerCase() == 'malaria') {
      risks = [
        {'disease': 'Malaria', 'color': Colors.red, 'level': confidence > 0.8 ? 'High' : 'Medium'},
        {'disease': 'Dengue', 'color': Colors.orange, 'level': 'Medium'},
        {'disease': 'Typhoid', 'color': Colors.green, 'level': 'Low'},
      ];
    } else if (prediction.toLowerCase() == 'typhoid') {
      risks = [
        {'disease': 'Typhoid', 'color': Colors.red, 'level': confidence > 0.8 ? 'High' : 'Medium'},
        {'disease': 'Dengue', 'color': Colors.green, 'level': 'Low'},
        {'disease': 'Malaria', 'color': Colors.green, 'level': 'Low'},
      ];
    } else {
      // Healthy prediction
      risks = [
        {'disease': 'Dengue', 'color': Colors.green, 'level': 'Low'},
        {'disease': 'Malaria', 'color': Colors.green, 'level': 'Low'},
        {'disease': 'Typhoid', 'color': Colors.green, 'level': 'Low'},
      ];
    }

    return Row(
      children: risks.map((risk) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          child: _buildRiskIndicatorSmall(
            risk['disease'],
            risk['color'],
            risk['level'],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildRiskIndicatorSmall(String disease, Color color, String level) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            disease,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            level,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
