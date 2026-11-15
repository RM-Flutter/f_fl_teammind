import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import '../models/proxy_employee_model.dart';
import '../models/proxy_request_model.dart';

/// Result of a proxy call. [data] is the whole reply, also when [success] is false, so a
/// "you made a calc error" reply still carries the server's `duration`.
class ProxyResult {
  final bool success;
  final String? message;
  final Map<String, dynamic> data;

  const ProxyResult({required this.success, this.message, this.data = const {}});
}

/// The proxy ("on behalf of") endpoints of the doc "Proxy-Task-Flutter". Uses [DioHelper] so a
/// `status: false` reply keeps its body.
abstract class ProxyRepo {
  static ProxyResult _parse(dynamic body) {
    if (body is! Map) return const ProxyResult(success: false);
    final map = Map<String, dynamic>.from(body);
    final status = map['status'];
    final ok = status == true || status?.toString() == 'true';
    final message = map['message'] is String ? map['message'] as String : null;
    return ProxyResult(success: ok, message: message, data: map);
  }

  static Future<ProxyResult> _run(Future<Response> Function() call) async {
    try {
      return _parse((await call()).data);
    } on DioException catch (e) {
      final parsed = _parse(e.response?.data);
      return parsed.data.isEmpty ? const ProxyResult(success: false) : parsed;
    } catch (e) {
      debugPrint('ProxyRepo error: $e');
      return const ProxyResult(success: false);
    }
  }

  /// 1) Employees the manager may act for, for one [ability]
  /// (`attendance` / `leave_create` / `leave_edit`).
  static Future<({ProxyResult result, List<ProxyEmployeeModel> employees})> employees(
      BuildContext context, String ability) async {
    final result = await _run(() => DioHelper.getData(
          context: context,
          url: '/emp_requests/v1/manager/employees',
          query: {'ability': ability},
        ));
    final raw = result.data['employees'] ?? result.data['data'];
    final list = raw is List
        ? raw.whereType<Map>().map((e) => ProxyEmployeeModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : <ProxyEmployeeModel>[];
    return (result: result, employees: list);
  }

  /// 2) Punch for an employee now (server time). Without [branchId] the employee's branch is used.
  static Future<ProxyResult> addFingerprint(BuildContext context,
      {required int employeeProfileId, int? branchId}) {
    return _run(() => DioHelper.postData(
          context: context,
          url: '/rm_fingerprint/v1/manager/add_fingerprint',
          query: null,
          data: {
            'employee_profile_id': employeeProfileId,
            if (branchId != null) 'branch_id': branchId,
          },
        ));
  }

  /// 3) Create a leave for an employee: the `create_new_request` body + `employee_profile_id`.
  static Future<ProxyResult> createRequest(BuildContext context,
      {required int employeeProfileId, required Map<String, dynamic> body}) {
    return _run(() => DioHelper.postData(
          context: context,
          url: '/emp_requests/v1/manager/requests',
          query: null,
          data: {...body, 'employee_profile_id': employeeProfileId},
        ));
  }

  /// 4) Edit a leave created on someone's behalf. Every field is sent, changed or not.
  static Future<ProxyResult> updateRequest(BuildContext context,
      {required int requestId, required Map<String, dynamic> body}) {
    return _run(() => DioHelper.putData(
          context: context,
          url: '/emp_requests/v1/manager/requests/$requestId',
          query: null,
          data: body,
        ));
  }

  /// 5) Leaves this manager created on behalf of employees (paged).
  static Future<({ProxyResult result, List<ProxyRequestModel> requests, int total})> myProxyRequests(
      BuildContext context,
      {required int page,
      int limit = 10}) async {
    final result = await _run(() => DioHelper.getData(
          context: context,
          url: '/emp_requests/v1/manager/requests',
          query: {'page': page, 'limit': limit},
        ));
    final raw = result.data['requests'] ?? result.data['data'];
    final list = raw is List
        ? raw.whereType<Map>().map((e) => ProxyRequestModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : <ProxyRequestModel>[];
    final total = int.tryParse('${result.data['total'] ?? result.data['itemsCount'] ?? list.length}') ?? list.length;
    return (result: result, requests: list, total: total);
  }
}
