import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_constants.dart';

class OvertimeRequestsService {
  static String get baseUrl => '${AppConstants.baseUrl}/rm_fingerprint/v1/overtime_requests';

  static Future<OperationResult<Map<String, dynamic>>> getOvertimeRequests({
    required BuildContext context,
    String? employeeProfileId,
    String? departmentId,
    String? from,
    String? to,
  }) async {
    String url = baseUrl;
    List<String> queryParams = [];
    if (employeeProfileId != null && employeeProfileId.isNotEmpty) {
      queryParams.add('employee_profile_id=$employeeProfileId');
    }
    if (departmentId != null && departmentId.isNotEmpty) {
      queryParams.add('department_id=$departmentId');
    }
    if (from != null && from.isNotEmpty) {
      queryParams.add('from=$from');
    }
    if (to != null && to.isNotEmpty) {
      queryParams.add('to=$to');
    }
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: '',
      allData: true,
      checkOnTokenExpiration: true,
    );
    return response;
  }

  static Future<OperationResult<Map<String, dynamic>>> addOvertimeRequest({
    required BuildContext context,
    required String date,
    required String overtime,
  }) async {
    final Map<String, String> requestData = {
      'date': date,
      'overtime': overtime,
    };

    final response = await DioApiService().postWithFormData<Map<String, dynamic>>(
      baseUrl,
      requestData,
      files: [],
      dataKey: '',
      context: context,
      allData: true,
    );
    return response;
  }

  static Future<OperationResult<Map<String, dynamic>>> updateStatus({
    required BuildContext context,
    required String requestId,
    required String status,
    required String managerReply,
  }) async {
    final url = '$baseUrl/$requestId/update_status';
    final Map<String, String> requestData = {
      'status': status,
      'the_manager_reply': managerReply,
    };

    final response = await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      requestData,
      files: [],
      dataKey: '',
      context: context,
      allData: true,
    );
    return response;
  }

  static Future<OperationResult<Map<String, dynamic>>> updateOvertime({
    required BuildContext context,
    required String requestId,
    required String overtime,
  }) async {
    final url = '$baseUrl/$requestId/update_overtime';
    final Map<String, String> requestData = {
      'overtime': overtime,
    };

    final response = await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      requestData,
      files: [],
      dataKey: '',
      context: context,
      allData: true,
    );
    return response;
  }
}
