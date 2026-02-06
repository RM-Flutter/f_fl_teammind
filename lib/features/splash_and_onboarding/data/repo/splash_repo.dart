import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:flutter/services.dart';

class SplashRepo {
  String? getInitialNotificationPayload() {
    return CacheHelper.getString('initialNotification');
  }

  Future<void> clearInitialNotificationPayload() async {
    await CacheHelper.setString(key: 'initialNotification', value: '');
  }

  String? getDateWatchScreen() {
    return CacheHelper.getString("dateWatchScreen");
  }

  Map<String, dynamic>? getCachedGlobalData() {
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  List<dynamic>? getAllOnboardingData() {
    final gCache = getCachedGlobalData();
    return gCache?['features']?['items'];
  }

  Future<List<dynamic>> getRoutes() async {
    const filepath = 'assets/json/routes.json';
    final content = await rootBundle.loadString(filepath);
    return jsonDecode(content);
  }
}
