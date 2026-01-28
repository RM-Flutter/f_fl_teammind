import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

abstract class FaqsLocalDataSource {
  static const String _cacheKey = "faqs_cache";

  static void cacheFaqJson(String json) {
    CacheHelper.setString(key: _cacheKey, value: json);
  }

  static Map<String, dynamic>? getFaqFromCache() {
    final jsonString = CacheHelper.getString(_cacheKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("Error decoding faqs cache: $e");
        return null;
      }
    }
    return null;
  }
}
