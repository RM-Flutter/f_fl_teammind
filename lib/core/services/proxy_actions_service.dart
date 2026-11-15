import 'dart:convert';

import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

/// What the signed-in manager / HR may do on behalf of their employees (`proxy_actions` from
/// `start_app`). Each action has its own switch on the server:
/// - `attendance`: punch in / out for an employee
/// - `leave_create`: create a leave for an employee
/// - `leave_edit`: edit a leave created on someone's behalf
///
/// The same keys are the `ability` of `GET /emp_requests/v1/manager/employees`.
abstract class ProxyActionsService {
  static const String _cacheKey = 'proxy_actions';

  static const String attendance = 'attendance';
  static const String leaveCreate = 'leave_create';
  static const String leaveEdit = 'leave_edit';

  /// Saves `proxy_actions` from a `start_app` reply. The doc only says start_app returns it, so it
  /// is read from the top level first, then from `user_settings.data`. A reply without it leaves
  /// the cached value untouched (an incremental start_app may skip unchanged sections).
  static Future<void> saveFromStartApp(Map reply) async {
    dynamic actions = reply['proxy_actions'];
    if (actions == null) {
      final userSettings = reply['user_settings'];
      if (userSettings is Map && userSettings['data'] is Map) {
        actions = userSettings['data']['proxy_actions'];
      }
    }
    if (actions is Map) {
      await CacheHelper.setString(key: _cacheKey, value: json.encode(actions));
    }
  }

  static Map<String, dynamic> get _actions {
    final raw = CacheHelper.getString(_cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    // Fallback: the user settings cache (if the server puts it there).
    final us1 = CacheHelper.getString('US1');
    if (us1 != null && us1.isNotEmpty) {
      try {
        final decoded = json.decode(us1);
        if (decoded is Map && decoded['proxy_actions'] is Map) {
          return Map<String, dynamic>.from(decoded['proxy_actions']);
        }
      } catch (_) {}
    }
    return const {};
  }

  static bool _isOn(String key) {
    final v = _actions[key];
    return v == true || v == 1 || v == '1' || v == 'true';
  }

  static bool get canAttendance => _isOn(attendance);
  static bool get canCreateLeave => _isOn(leaveCreate);
  static bool get canEditLeave => _isOn(leaveEdit);

  /// At least one action is on: shows the "On Behalf of an Employee" entry.
  static bool get hasAny => canAttendance || canCreateLeave || canEditLeave;

  /// Logout / domain change.
  static Future<void> clear() => CacheHelper.deleteData(key: _cacheKey);
}
