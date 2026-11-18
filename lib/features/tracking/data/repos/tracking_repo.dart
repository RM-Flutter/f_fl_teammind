import 'package:flutter/material.dart';

import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/app_error_reporter.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import '../models/employee_tracking_summary.model.dart';
import '../models/request_tracking.model.dart';
import '../models/tracking_point.model.dart';
import '../models/tracking_session.model.dart';

/// Request-linked location tracking APIs (`/emp_requests/v1/tracking`).
///
/// Success is `status == true` (a boolean) in the body, never the HTTP code: errors usually come
/// with HTTP 200, and the rate limit answers `"status": "false"` as a string.
/// Uploading points lives in `LocationTrackingService` (core), because it also runs with no screen.
abstract class TrackingRepo {
  static const String _base = '/emp_requests/v1/tracking';

  static bool _ok(dynamic body) => body is Map && body['status'] == true;

  static String? _message(dynamic body) => body is Map ? body['message']?.toString() : null;

  static Future<OperationResult<T>> _run<T>(
      Future<dynamic> Function() call, T Function(Map<String, dynamic> body) parse) async {
    try {
      final response = await call();
      final body = response.data;
      if (_ok(body)) {
        return OperationResult(success: true, data: parse(Map<String, dynamic>.from(body)), message: _message(body));
      }
      return OperationResult(success: false, message: _message(body), errors: body is Map ? body['errors'] : null);
    } catch (e) {
      debugPrint('TrackingRepo error: $e');
      return OperationResult(success: false, message: AppErrorReporter.safeMessage(e));
    }
  }

  /// Screens 2 and 3: tracking block, sessions and key points of one request.
  static Future<OperationResult<RequestTrackingDetailsModel>> getRequestTracking({
    required BuildContext context,
    required int requestId,
  }) =>
      _run(
        () => DioHelper.getData(url: '$_base/requests/$requestId', query: null, context: context),
        (b) => RequestTrackingDetailsModel.fromJson(Map<String, dynamic>.from(b['data'] as Map)),
      );

  /// No body. Returns the open session when one already runs (pressing twice is safe).
  static Future<OperationResult<TrackingSessionModel>> startSession({
    required BuildContext context,
    required int requestId,
  }) =>
      _run(
        () => DioHelper.postData(url: '$_base/requests/$requestId/sessions/start', query: null, data: {}, context: context),
        (b) => TrackingSessionModel.fromJson(Map<String, dynamic>.from(b['data'] as Map)),
      );

  /// No body. Returns the session as `completed` (or as it is if the server closed it before).
  static Future<OperationResult<TrackingSessionModel>> stopSession({
    required BuildContext context,
    required int sessionId,
  }) =>
      _run(
        () => DioHelper.postData(url: '$_base/sessions/$sessionId/stop', query: null, data: {}, context: context),
        (b) => TrackingSessionModel.fromJson(Map<String, dynamic>.from(b['data'] as Map)),
      );

  /// The whole route (max 1000 points), each session with its points; start / end markers are
  /// added from `main_points` when [mainPoints] is given.
  static Future<OperationResult<List<TrackingSessionModel>>> getPath({
    required BuildContext context,
    required int requestId,
    List<TrackingPointModel> mainPoints = const [],
  }) =>
      _run(
        () => DioHelper.getData(url: '$_base/requests/$requestId/path', query: null, context: context),
        (b) {
          final data = Map<String, dynamic>.from(b['data'] as Map);
          final sessions = (data['sessions'] as List? ?? const [])
              .whereType<Map>()
              .map((s) => TrackingSessionModel.fromJson(Map<String, dynamic>.from(s)))
              .toList();
          final path = (data['path'] as List? ?? const [])
              .whereType<Map>()
              .map((p) => TrackingPointModel.fromJson(Map<String, dynamic>.from(p)))
              .toList();
          final markers = mainPoints.where((p) => p.isStartPoint || p.isEndPoint);
          return TrackingSessionModel.attachPoints(sessions, [...path, ...markers]);
        },
      );

  static Map<String, dynamic> _groupQuery({
    required int page,
    List<String>? employeeIds,
    List<String>? departmentIds,
  }) =>
      {
        'page': page,
        if (employeeIds != null && employeeIds.isNotEmpty) 'employee_ids[]': employeeIds,
        if (departmentIds != null && departmentIds.isNotEmpty) 'department_ids[]': departmentIds,
      };

  static TrackingEmployeesPage _page(Map<String, dynamic> b) => TrackingEmployeesPage(
        employees: (b['data'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => EmployeeTrackingSummaryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        total: int.tryParse(b['total']?.toString() ?? '') ?? 0,
        page: int.tryParse(b['page']?.toString() ?? '') ?? 1,
        itemsCount: int.tryParse(b['itemsCount']?.toString() ?? '') ?? 10,
      );

  /// Screen 4, "Live": last place, state and age of the last update per employee.
  static Future<OperationResult<TrackingEmployeesPage>> getLive({
    required BuildContext context,
    int page = 1,
    List<String>? employeeIds,
    List<String>? departmentIds,
    bool onlyTracking = false,
  }) =>
      _run(
        () => DioHelper.getData(
          url: '$_base/live',
          query: {
            ..._groupQuery(page: page, employeeIds: employeeIds, departmentIds: departmentIds),
            if (onlyTracking) 'only_tracking': 1,
          },
          context: context,
        ),
        _page,
      );

  /// Screen 4, "Today" ([date] null) or a picked day: sessions, key points and route per employee.
  static Future<OperationResult<TrackingEmployeesPage>> getHistory({
    required BuildContext context,
    int page = 1,
    DateTime? date,
    List<String>? employeeIds,
    List<String>? departmentIds,
  }) =>
      _run(
        () => DioHelper.getData(
          url: '$_base/history',
          query: {
            ..._groupQuery(page: page, employeeIds: employeeIds, departmentIds: departmentIds),
            if (date == null) 'mode': 'today',
            if (date != null) 'mode': 'date',
            if (date != null)
              'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          },
          context: context,
        ),
        _page,
      );
}
