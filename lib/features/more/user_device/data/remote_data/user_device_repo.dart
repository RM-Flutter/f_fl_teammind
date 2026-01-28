import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';

class UserDeviceRepo {
  static Future<Response> getDevices({required BuildContext context}) {
    return DioHelper.getData(
      url: "/rm_users/v1/devices/get",
      context: context,
    );
  }

  static Future<Response> stopDevice({
    required BuildContext context,
    String? deviceId,
  }) {
    return DioHelper.postData(
      url: "/rm_users/v1/devices/stop",
      context: context,
      data: (deviceId != null) ? {"device_id": deviceId} : null,
    );
  }

  static Future<Response> deviceSysGet({
    required BuildContext context,
  }) {
    return DioHelper.postData(
      url: "/rm_users/v1/device_sys",
      context: context,
      data: {
        "action": "get",
        "key": "notification_token_status",
      },
    );
  }

  static Future<Response> deviceSysSetToken({
    required BuildContext context,
    required String? token,
  }) {
    return DioHelper.postData(
      url: "/rm_users/v1/device_sys",
      context: context,
      data: {
        "action": "set",
        "key": "notification_token",
        "value": token,
      },
    );
  }

  static Future<Response> deviceSysSetTokenStatus({
    required BuildContext context,
    required bool state,
  }) {
    return DioHelper.postData(
      url: "/rm_users/v1/device_sys",
      context: context,
      data: {
        "action": "set",
        "key": "notification_token_status",
        "value": state,
      },
    );
  }
}
