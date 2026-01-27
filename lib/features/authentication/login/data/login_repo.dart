import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api.service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint.service.dart';
import 'package:app_test/core/models/endpoint.model.dart';
import 'package:app_test/core/models/operation_result.model.dart';

import '../../../../core/constants/app_constants.dart';

abstract class LoginRepo {
  static Future<OperationResult<Map<String, dynamic>>> login(
      {required String username,
        required String password,
        required Map<String, dynamic> deviceInformation,
        required BuildContext context}) async {
    debugPrint("deviceInformation --> $deviceInformation");
    Map<String, dynamic> body = {
      "username": username, // may be phone number or email
      "password": password,
      "device_info": deviceInformation
    };
    return await DioApiService().post<Map<String, dynamic>>(
        EndpointServices.getApiEndpoint(EndpointsNames.createAuthentication)
            .url,
        body,
        dataKey: 'token',
        context: context,
        allData: true);
  }

  static Future<OperationResult<Map<String, dynamic>>> getDeviceToken({
    required BuildContext context,
  }) async {
    return await DioApiService().get<Map<String, dynamic>>(
        EndpointServices.getApiEndpoint(EndpointsNames.getDeviceToken).url,
        dataKey: 'data',
        // allData: true,
        context: context);
  }


  static Future<OperationResult<Map<String, dynamic>>> accoutnVerification(
      {required String uuid,
        required String method,
        required BuildContext context}) async {
    final url =
        '${AppConstants.baseUrl}/rm_users/v1/account_verification/$uuid/send';
    final response = await DioApiService().post<Map<String, dynamic>>(
        url,
        {
          "send_by": method,
        },
        dataKey: 'data',
        context: context,
        allData: true);
    return response;
  }

  static Future<OperationResult<Map<String, dynamic>>> validateAccoutnVerificationCode(
      {required String uuid,
        required String code,
        required String method,
        required Map<String, dynamic> deviceInformation,
        required BuildContext context}) async {
    final url =
        '${AppConstants.baseUrl}/rm_users/v1/account_verification/$uuid/validate';
    final response = await DioApiService().post<Map<String, dynamic>>(
        url,
        {
          "send_by": method,
          "code": int.tryParse(code),
          "device_info": deviceInformation
        },
        dataKey: 'data',
        context: context,
        allData: true);
    return response;
  }


  static Future<OperationResult<Map<String, dynamic>>> send2FAVerificationCode(
      {required String uuid,
        required String sendType,
        required BuildContext context}) async {
    final url = '${AppConstants.baseUrl}/rm_users/v1/tfa/$uuid/send';
    return await DioApiService().post<Map<String, dynamic>>(
        context: context,
        url,
        {"send_by": sendType},
        dataKey: 'data',
        allData: true);
  }

  static Future<OperationResult<Map<String, dynamic>>>
  validate2FAVerificationCode(
      {required String uuid,
        required String code,
        required String sendType,
        required BuildContext context,
        required Map<String, dynamic> deviceInformation}) async {
    final url = '${AppConstants.baseUrl}/rm_users/v1/tfa/$uuid/validate';
    return await DioApiService().post<Map<String, dynamic>>(
        url,
        context: context,
        {"send_by": sendType, "code": code, "device_info": deviceInformation},
        dataKey: 'data',
        allData: true);
  }
}
