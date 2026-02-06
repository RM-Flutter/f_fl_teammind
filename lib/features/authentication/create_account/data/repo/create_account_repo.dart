import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint_service.dart';
import 'package:app_test/core/models/endpoint_model.dart';
import 'package:app_test/core/models/operation_result.model.dart';

abstract class CreateAccountRepo {

  static Future<OperationResult<Map<String, dynamic>>> createAccount({
    required String name,
    required String phone,
    required String countryKey,
    required String password,
    required String email,
    required int departmentId,
    required Map<String, dynamic> deviceInformation,
    required BuildContext context,
  }) async {
    Map<String, dynamic> body = {
      "name": name,
      "phone": phone,
      "email": email,
      "country_key": countryKey,
      "password": password,
      "department_id": departmentId,
      "device_info": deviceInformation
    };
    return await DioApiService().post<Map<String, dynamic>>(
        EndpointServices.getApiEndpoint(EndpointsNames.registration).url, body,
        dataKey: 'data', allData: true, context: context);
  }
}
