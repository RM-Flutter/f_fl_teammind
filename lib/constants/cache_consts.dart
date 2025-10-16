import 'dart:convert';
import '../general_services/backend_services/api_service/dio_api_service/shared.dart';

class CacheConsts {
  static var gCache;
  static var us1Cache;
  static var us2Cache;

  static Future<void> initUSG() async {
    final jsonString = await CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty) {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
    }
  }
  static Future<void> initUS1() async {
    final jsonString = await CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>;
    }
  }
  static Future<void> initUS2() async {
    final jsonString = await CacheHelper.getString("US2");
    if (jsonString != null && jsonString.isNotEmpty) {
      us2Cache = json.decode(jsonString) as Map<String, dynamic>;
    }
  }
}
