import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

/// Local data source for splash and onboarding feature
/// Handles all local storage operations using CacheHelper
abstract class SplashOnboardingLocalDataSource {
  /// Get onboarding data from cache (USG)
  static Map<String, dynamic>? getOnboardingDataFromCache() {
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("Error decoding USG: $e");
        return null;
      }
    }
    return null;
  }

  /// Get user settings from cache (US1)
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

  /// Get user settings 2 from cache (US2)
  static Map<String, dynamic>? getUserSettings2FromCache() {
    final jsonString = CacheHelper.getString("US2");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("Error decoding US2: $e");
        return null;
      }
    }
    return null;
  }

  /// Get initial notification from cache
  static String? getInitialNotification() {
    return CacheHelper.getString('initialNotification');
  }

  /// Set initial notification in cache
  static Future<void> setInitialNotification(String value) async {
    await CacheHelper.setString(key: 'initialNotification', value: value);
  }

  /// Get date watch screen from cache
  static String? getDateWatchScreen() {
    return CacheHelper.getString("dateWatchScreen");
  }
}
