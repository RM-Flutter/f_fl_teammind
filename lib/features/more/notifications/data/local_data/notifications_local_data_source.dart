import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

abstract class NotificationsLocalDataSource {
  static const String _listCacheKey = "notifications_list_cache";
  static const String _singleCacheKeyPrefix = "notification_single_";

  static void cacheNotificationsListJson(String json) {
    CacheHelper.setString(key: _listCacheKey, value: json);
  }

  static Map<String, dynamic>? getNotificationsListFromCache() {
    final jsonString = CacheHelper.getString(_listCacheKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("Error decoding notifications list cache: $e");
        return null;
      }
    }
    return null;
  }

  static void cacheNotificationSingleJson(String id, String json) {
    CacheHelper.setString(key: "$_singleCacheKeyPrefix$id", value: json);
  }

  static Map<String, dynamic>? getNotificationSingleFromCache(String id) {
    final jsonString = CacheHelper.getString("$_singleCacheKeyPrefix$id");
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("Error decoding notification single cache: $e");
        return null;
      }
    }
    return null;
  }
}
