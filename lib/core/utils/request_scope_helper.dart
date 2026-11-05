import 'dart:convert';

import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

/// Which incoming-requests scopes the current user can open.
///
/// - "Team" requests: managers, team leaders, HR and top management only.
/// - "Other departments" and "All company": every employee.
class RequestScopeHelper {
  static Map<String, dynamic>? _userSettings() {
    try {
      final jsonString = CacheHelper.getString("US1");
      if (jsonString.isEmpty) return null;
      final decoded = json.decode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static bool _notEmptyList(dynamic v) => v is List && v.isNotEmpty;

  /// Manager / team leader of a department, HR or top management.
  static bool get canSeeTeam {
    final s = _userSettings();
    if (s == null) return false;
    return _notEmptyList(s['is_manager_in']) ||
        _notEmptyList(s['is_teamleader_in']) ||
        s['is_hr'] == true ||
        s['top_management'] == true;
  }

  /// Scope opened first in the incoming-requests lists.
  static String get defaultIncomingScope => canSeeTeam ? 'team' : 'other_departments';
}
