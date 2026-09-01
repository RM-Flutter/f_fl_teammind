import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint_service.dart';
import 'package:app_test/core/models/endpoint_model.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// used when getting requests ( my requests - my team requests - other Departments requests)
enum GetRequestsTypes { mine, myTeam, otherDepartment, allCompany }

enum RequestStatus {
  waiting,
  waitingSeen,
  seen,
  approved,
  canceled,
  refused,
  waitingCancel,
}

enum RequestManagerActions { approved, refused }

abstract class RequestsServices {
  /// get request Status String from Request Statuses enum
  static String getRequestStatusStr({required RequestStatus status}) {
    switch (status) {
      case RequestStatus.waitingCancel:
        return 'waiting_cancel';
      case RequestStatus.waiting:
        return 'waiting';
      case RequestStatus.waitingSeen:
        return 'waiting_seen';
      case RequestStatus.seen:
        return 'seen';
      case RequestStatus.approved:
        return 'approved';
      case RequestStatus.canceled:
        return 'canceled';
      case RequestStatus.refused:
        return 'refused';
    }
  }

  /// get request type String from GetRequestsTypes
  static String getRequestsTypeStr({required GetRequestsTypes type}) {
    switch (type) {
      case GetRequestsTypes.mine:
        return 'my_requests';
      case GetRequestsTypes.myTeam:
        return 'team_requests';
      case GetRequestsTypes.otherDepartment:
        return 'other_departments';
      case GetRequestsTypes.allCompany:
        return 'all_company_requests';
    }
  }

  /// used in app router configs to get GetRequestTypes from string
  static GetRequestsTypes getRequestTypeFromString(
      {required String? reqTypeString}) {
    switch (reqTypeString) {
      case 'mine':
        return GetRequestsTypes.mine;
      case 'myTeam':
        return GetRequestsTypes.myTeam;
      case 'otherDepartment':
        return GetRequestsTypes.otherDepartment;
      case 'allCompany':
        return GetRequestsTypes.allCompany;
      default:
        return GetRequestsTypes.mine;
    }
  }

  /// get Request Status Icon [waiting_seen - seen - approved - canceled - refused]
  static Widget getRequestsStatusIcon(
      {required BuildContext context,
      String? status,
      Color? iconColor,
      double? iconSize}) {
    switch (status?.toLowerCase().trim()) {
      case 'approved':
        return Icon(Icons.check_circle_outline_rounded,
            color: iconColor ?? Colors.green, size: iconSize ?? AppSizes.s24);
      case 'refused' || 'canceled' || 'cancelled' || 'rejected':
        return Icon(Icons.cancel_outlined,
            color: iconColor ?? Colors.red, size: iconSize ?? AppSizes.s24);
      case 'seen':
        return Icon(Icons.access_time,
            color: iconColor ?? Colors.blue, size: iconSize ?? AppSizes.s24);
      case 'waiting_seen' || 'waiting_cancel' || 'waiting' || 'pending':
        return Image.asset(
          'assets/images/waiting_icon.png',
          color: iconColor,
          width: iconSize ?? AppSizes.s24,
          height: iconSize ?? AppSizes.s24,
        );
      default:
        return Icon(
          Icons.more_horiz,
          color: iconColor ?? Color(AppColors.secondaryButton),
          size: iconSize ?? AppSizes.s24,
        );
    }
  }

  /// build query parameters string
  static String _buildQueryParameters({
    String? requestTypeId,
    var ids,
    var department,
    var status,
    String? from,
    String? to,
    int? plimits,
    int? page,
    String? type,
  }) {
    final Map<String, String> queryParams = {};

    if (requestTypeId != null && requestTypeId != "")
      queryParams['request_type_id'] = requestTypeId;
    if (ids != null && ids.isNotEmpty) queryParams['emp_ids[]'] = ids;
    if (department != null && department.isNotEmpty)
      queryParams['department_id'] = department;
    if (from != null && from != "") queryParams['from'] = from;
    if (status != null && status != "") queryParams['status'] = status;
    if (to != null && to != "") queryParams['to'] = to;
    if (plimits != null) queryParams['plimits'] = plimits.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (type != null) queryParams['type'] = type;

    return queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  /// get Requests depends on the current user privileges
  static Future<OperationResult<Map<String, dynamic>>>
      getRequestsByTypeDependsOnUserPrivileges({
    required BuildContext context,
    required GetRequestsTypes? reqType,
    String? requestTypeId,
    var empIds,
    var depId,
    var status,
    String? from,
    String? to,
    int? plimits,
    int? page,
    String? type,
  }) async {
    try {
      if (reqType == GetRequestsTypes.mine) {
        final res = await getMyApprovables(
          context: context,
          type: 'employee_requests',
          employeesIds: empIds != null ? [empIds.toString()] : null,
          status: status?.toString(),
          dateFrom: from,
          dateTo: to,
          page: page ?? 1,
          perPage: plimits ?? 15,
        );
        if (res.success && res.data != null) {
          final rawData = res.data!['approvables'] ?? res.data!['data'] ?? res.data!['requests'];
          List<dynamic> list = [];
          if (rawData is Map<String, dynamic> && rawData['data'] is List) {
            list = rawData['data'];
          } else if (rawData is List) {
            list = rawData;
          }
          if (list.isNotEmpty) {
            return OperationResult(
              success: true,
              message: res.message,
              data: {'requests': list, 'status': true},
            );
          }
        }
      } else if (reqType == GetRequestsTypes.myTeam || reqType == GetRequestsTypes.allCompany) {
        final scope = reqType == GetRequestsTypes.myTeam ? 'team' : 'all_company';
        final res = await getManagerApprovables(
          context: context,
          type: 'employee_requests',
          scope: scope,
          employeesIds: empIds != null ? [empIds.toString()] : null,
          status: status?.toString(),
          dateFrom: from,
          dateTo: to,
          page: page ?? 1,
          perPage: plimits ?? 15,
        );
        if (res.success && res.data != null) {
          final rawData = res.data!['approvables'] ?? res.data!['data'] ?? res.data!['requests'];
          List<dynamic> list = [];
          if (rawData is Map<String, dynamic> && rawData['data'] is List) {
            list = rawData['data'];
          } else if (rawData is List) {
            list = rawData;
          }
          if (list.isNotEmpty) {
            return OperationResult(
              success: true,
              message: res.message,
              data: {'requests': list, 'status': true},
            );
          }
        }
      }
    } catch (_) {}

    String baseUrl;
    if (reqType == null) {
      baseUrl = EndpointServices.getApiEndpoint(EndpointsNames.getRequests).url;
    } else {
      baseUrl =
          '${EndpointServices.getApiEndpoint(EndpointsNames.getRequests).url}?type=${getRequestsTypeStr(type: reqType)}';
    }
    final queryParams = _buildQueryParameters(
      requestTypeId: requestTypeId,
      ids: empIds,
      status: status,
      department: depId,
      from: from,
      to: to,
      plimits: plimits,
      page: page,
      type: type,
    );
    debugPrint("queryParams is --> ${queryParams}");
    final url = queryParams.isEmpty ? baseUrl : '$baseUrl&$queryParams';

    final response = await DioApiService().get<Map<String, dynamic>>(url,
        dataKey: 'data', context: context, allData: true);
    return response;
  }

  /// New unified Approvals API — replaces per-feature list endpoints for employee (mine) view.
  /// type: 'employee_requests' | 'salary_advance' | 'overtime'
  static Future<OperationResult<Map<String, dynamic>>> getMyApprovables({
    required BuildContext context,
    required String type,
    List<String>? employeesIds,   // sent as employees_ids[]
    List<String>? departmentIds,  // sent as department_ids[]
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 15,
  }) async {
    // The endpoint pattern is: /approval-system/v1/{type}/employee/my-approvables
    final url = '${AppConstants.baseUrl}/approval-system/v1/$type/employee/my-approvables';

    // Build query map — Dio handles List values as repeated params: key[]=v1&key[]=v2
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

    debugPrint("🟢 getMyApprovables → $url | params: $queryParams");

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: '',
      queryParameters: queryParams,
      allData: true,
      checkOnTokenExpiration: true,
    );
  }

  /// New unified Approvals API for Manager/HR/Admin views (Team, Other Depts, All Company)
  /// type: 'employee_requests' | 'salary_advance' | 'overtime'
  /// scope: 'team' | 'other_departments' | 'all_company'
  static Future<OperationResult<Map<String, dynamic>>> getManagerApprovables({
    required BuildContext context,
    required String type,
    required String scope,
    List<String>? employeesIds,
    List<String>? departmentIds,
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 15,
  }) async {
    final url = '${AppConstants.baseUrl}/approval-system/v1/$type/manager/under-my-management-approvables';

    final Map<String, dynamic> queryParams = {
      'scope': scope,
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

    debugPrint("🟢 getManagerApprovables → $url | params: $queryParams");

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: '',
      queryParameters: queryParams,
      allData: true,
      checkOnTokenExpiration: true,
    );
  }

  /// get Requests depends on the current user privileges
  static Future<OperationResult<List<dynamic>>> getSummaryReports({
    required BuildContext context,
    List<String>? years,
    String? requestTypeId,
    String? requestType,
  }) async {
    final baseUrl =
        EndpointServices.getApiEndpoint(EndpointsNames.summaryReport).url;

    // Build query parameters
    final Map<String, String> params = {};
    if (years != null && years.isNotEmpty) {
      params['years'] = years.join(',');
    }
    if (requestTypeId != null) {
      params['request_id'] = requestTypeId;
    }
    if (requestType != null) {
      params['request_type'] = requestType;
    }

    final queryParams =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final url = queryParams.isEmpty ? baseUrl : '$baseUrl?$queryParams';

    // Send request
    final response = await DioApiService().get<List<dynamic>>(url,
        dataKey: 'data',
        context: context,
        allData: true,
        checkOnTokenExpiration: false);

    return response;
  }

  /// ask remember service
  static Future<OperationResult<Map<String, dynamic>>> askRemember({
    required BuildContext context,
    required String requestId,
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.askRemember).url;
    final response = await DioApiService().post<Map<String, dynamic>>(
        url, {'id': requestId},
        context: context, allData: true, dataKey: 'data');
    return response;
  }

  /// ask ignore service
  static Future<OperationResult<Map<String, dynamic>>> askIgnore({
    required BuildContext context,
    required String requestId,
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.askIgnore).url;
    final response = await DioApiService().post<Map<String, dynamic>>(
      url,
      {'id': requestId},
      context: context,
      allData: true,
      dataKey: 'data',
    );
    return response;
  }

  /// method to create a new request with files
  static Future<OperationResult<Map<String, dynamic>>> createNewRequestWithFile(
      {required BuildContext context,
      required Map<String, String> requestData,
      required List<FilePickerResult> files}) async {
    debugPrint("REQUEST DATA IS --> $requestData");
    debugPrint("REQUEST DATA IS --> $files");
    return await DioApiService().postWithFormData<Map<String, dynamic>>(
        EndpointServices.getApiEndpoint(EndpointsNames.empAddRequest).url,
        context: context,
        requestData,
        dataKey: 'data',
        files: files,
        allData: true);
  }

  /// method to create a new request without files
  static Future<OperationResult<Map<String, dynamic>>> createNewRequest(
      {required BuildContext context,
      required Map<String, dynamic> requestData}) async {
    return await DioApiService().post<Map<String, dynamic>>(
        EndpointServices.getApiEndpoint(EndpointsNames.empAddRequest).url,
        context: context,
        requestData,
        dataKey: 'data',
        allData: true);
  }

  /// method to perform manager action (approve or refuse)
  static Future<OperationResult<Map<String, dynamic>>> managerAction({
    required BuildContext context,
    required String requestId,
    required String action,
    required String replay,
  }) async {
    final url =
        EndpointServices.getApiEndpoint(EndpointsNames.managerAction).url;
    final response = await DioApiService().post<Map<String, dynamic>>(
      url,
      {
        'request_id': requestId,
        'action':
            action == 'Approved' || action == 'approved' || action == 'موافقة'
                ? 'approved'
                : 'refused',
        'reply': replay,
      },
      context: context,
      allData: true,
      dataKey: 'data',
    );
    return response;
  }

  static Future<OperationResult<Map<String, dynamic>>> getEmployeeBalance({
    required BuildContext context,
    required String empId,
  }) async {
    final url =
        '${EndpointServices.getApiEndpoint(EndpointsNames.getEmployeeBalance).url}/$empId';
    final response = await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: 'data',
      allData: true,
    );
    return response;
  }
}
