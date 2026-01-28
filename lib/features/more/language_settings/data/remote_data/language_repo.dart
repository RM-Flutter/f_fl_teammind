import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';

class LanguageRepo {
  static Future<Response> setDeviceLanguage({
    required BuildContext context,
    required String state,
    required Map<String, dynamic> deviceInfo,
    String? notiToken,
  }) {
    return DioHelper.postData(
      url: "/rm_users/v1/device_sys",
      context: context,
      data: {
        "action": "set",
        "key": "language",
        "value": state,
        "default": state,
        "device_info": {
          "device_unique_id": deviceInfo["device_unique_id"],
          "operating_system": deviceInfo["operating_system"],
          "operating_system_version": deviceInfo["operating_system_version"],
          "type": deviceInfo["type"],
          "notification_token": notiToken
        }
      },
    );
  }
}
