import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:flutter/cupertino.dart';

import '../constants/app_constants.dart';

class CacheConsts {
  static var gCache;
  static var us1Cache;
  static var us2Cache;

  static Future<void> initUSG() async {
    final jsonString = await CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "null") {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          gCache = decoded;
          AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks();
        }
      } catch (e) {
        debugPrint("Error decoding USG in initUSG: $e");
      }
    }
  }
  static Future<void> initUS1() async {
    final jsonString = await CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "null") {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          us1Cache = decoded;
        }
      } catch (e) {
        debugPrint("Error decoding US1 in initUS1: $e");
      }
    }
  }
  static Future<void> initUS2() async {
    final jsonString = await CacheHelper.getString("US2");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "null") {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          us2Cache = decoded;
        }
      } catch (e) {
        debugPrint("Error decoding US2 in initUS2: $e");
      }
    }
  }
}
