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
    int? page,
  }) async {
    String url = baseUrl;
    List<String> queryParams = [];
    if (employeeProfileId != null && employeeProfileId.isNotEmpty) {
      queryParams.add('employee_id=$employeeProfileId');
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
    if (page != null) {
      queryParams.add('page=$page');
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

  /// New unified Approvals API — used for the employee personal (mine) overtime list.
  /// Replaces getOvertimeRequests() for the personal tab only.
  /// employees_ids[] and department_ids[] are sent as list query params.
  static Future<OperationResult<Map<String, dynamic>>> getMyApprovablesOvertime({
    required BuildContext context,
    List<String>? employeesIds,   // employees_ids[]
    List<String>? departmentIds,  // department_ids[]
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 15,
  }) async {
    final String baseUrl = '${AppConstants.baseUrl}/approval-system/v1/overtime/employee/my-approvables';

    final Map<String, dynamic> queryParams = {
      'page': page,
      'per_page': perPage,
    };
    if (employeesIds != null && employeesIds.isNotEmpty) {
      queryParams['employees_ids[]'] = employeesIds;
    }
    if (departmentIds != null && departmentIds.isNotEmpty) {
      queryParams['department_ids[]'] = departmentIds;
    }
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (dateFrom != null && dateFrom.isNotEmpty) queryParams['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) queryParams['date_to'] = dateTo;

    debugPrint("🟢 getMyApprovablesOvertime → $baseUrl | params: $queryParams");

    final response = await DioApiService().get<Map<String, dynamic>>(
      baseUrl,
      context: context,
      dataKey: '',
      queryParameters: queryParams,
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

  static Future<OperationResult<Map<String, dynamic>>> addManagerOvertimeRequest({
    required BuildContext context,
    required String date,
    required String overtime,
    required String employeeProfileId,
  }) async {
    final url = '${AppConstants.baseUrl}/rm_fingerprint/v1/manager/overtime_requests';
    final Map<String, String> requestData = {
      'date': date,
      'overtime': overtime,
      'employee_profile_id': employeeProfileId,
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
