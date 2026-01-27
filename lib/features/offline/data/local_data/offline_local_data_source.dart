import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

/// Local data source for offline feature
/// Handles all local storage operations using SharedPreferences and CacheHelper
abstract class OfflineLocalDataSource {
  /// Load fingerprints from SharedPreferences
  static Future<List<Map<String, dynamic>>?> loadFingerprintsFromPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('fingerPrints')) {
        final String? jsonString = prefs.getString('fingerPrints');
        if (jsonString != null && jsonString.isNotEmpty) {
          final List<dynamic> decodedList = jsonDecode(jsonString);
          return decodedList.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error loading fingerprints: $e");
      return [];
    }
  }

  /// Get user settings from cache
  static Map<String, dynamic>? getUserSettingsFromCache() {
    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("Error decoding US1: $e");
        return null;
      }
    }
    return null;
  }
}
