import 'package:shared_preferences/shared_preferences.dart';

/// Service class to manage user statistics across the app
class UserStatisticsService {
  
  /// Increment the number of cases analyzed
  static Future<void> incrementCasesAnalyzed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('cases_analyzed') ?? 0;
      await prefs.setInt('cases_analyzed', current + 1);
    } catch (e) {
      print('Error updating cases analyzed: $e');
    }
  }

  /// Increment the number of documents processed
  static Future<void> incrementDocumentsProcessed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('documents_processed') ?? 0;
      await prefs.setInt('documents_processed', current + 1);
    } catch (e) {
      print('Error updating documents processed: $e');
    }
  }

  /// Increment the number of AI consultations
  static Future<void> incrementAiConsultations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('ai_consultations') ?? 0;
      await prefs.setInt('ai_consultations', current + 1);
    } catch (e) {
      print('Error updating AI consultations: $e');
    }
  }

  /// Get current user statistics
  static Future<Map<String, int>> getCurrentStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'cases_analyzed': prefs.getInt('cases_analyzed') ?? 0,
        'documents_processed': prefs.getInt('documents_processed') ?? 0,
        'ai_consultations': prefs.getInt('ai_consultations') ?? 0,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      return {
        'cases_analyzed': 0,
        'documents_processed': 0,
        'ai_consultations': 0,
      };
    }
  }

  /// Reset all statistics (useful for testing or user request)
  static Future<void> resetStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cases_analyzed', 0);
      await prefs.setInt('documents_processed', 0);
      await prefs.setInt('ai_consultations', 0);
    } catch (e) {
      print('Error resetting statistics: $e');
    }
  }
}
