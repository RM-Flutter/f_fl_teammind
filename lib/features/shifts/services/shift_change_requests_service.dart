import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/operation_result.model.dart';
import '../../../core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';

class ShiftChangeRequestsService {
  static String get empRequestsBaseUrl =>
      '${AppConstants.baseUrl}/emp_requests/v1/shift-change-requests';

  static String get approvalsBaseUrl =>
      '${AppConstants.baseUrl}/approval-system/v1/shift_change_requests';

  /// GET /api/emp_requests/v1/shift-change-requests/scheduler-calendar?from=YYYY-MM-DD&to=YYYY-MM-DD
  static Future<OperationResult<Map<String, dynamic>>> getSchedulerCalendar({
    required BuildContext context,
    required String from,
    required String to,
  }) async {
    final url = '$empRequestsBaseUrl/scheduler-calendar';
    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: '',
      queryParameters: {
        'from': from,
        'to': to,
      },
      allData: true,
      checkOnTokenExpiration: true,
    );
  }

  /// POST /api/emp_requests/v1/shift-change-requests
  static Future<OperationResult<Map<String, dynamic>>> createShiftChangeRequest({
    required BuildContext context,
    required int receiverEmployeeId,
    required int requesterShiftAssignmentId,
    int? receiverShiftAssignmentId,
    required String reason,
  }) async {
    final Map<String, dynamic> body = {
      'receiver_employee_id': receiverEmployeeId,
      'requester_shift_assignment_id': requesterShiftAssignmentId,
      'reason': reason,
    };
    if (receiverShiftAssignmentId != null) {
      body['receiver_shift_assignment_id'] = receiverShiftAssignmentId;
    }

    return await DioApiService().post<Map<String, dynamic>>(
      empRequestsBaseUrl,
      body,
      dataKey: '',
      context: context,
      allData: true,
    );
  }

  /// GET /api/approval-system/v1/shift_change_requests/employee/my-approvables
  static Future<OperationResult<Map<String, dynamic>>> getMyShiftChangeRequests({
    required BuildContext context,
    List<String>? employeesIds,
    List<String>? departmentIds,
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 15,
  }) async {
    final url = '$approvalsBaseUrl/employee/my-approvables';
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
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (dateFrom != null && dateFrom.isNotEmpty) {
      queryParams['date_from'] = dateFrom;
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      queryParams['date_to'] = dateTo;
    }

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: '',
      queryParameters: queryParams,
      allData: true,
      checkOnTokenExpiration: true,
    );
  }
}
