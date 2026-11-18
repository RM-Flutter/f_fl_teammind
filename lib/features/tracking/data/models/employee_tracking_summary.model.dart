import 'package:easy_localization/easy_localization.dart';
import 'tracking_point.model.dart';
import 'tracking_session.model.dart';
import 'tracking_status.enum.dart';

/// One employee on the group map (`GET /live` item, optionally merged with the matching
/// `GET /history` item of the same page and filters).
///
/// live: `employee{id,name,job_title,department_id,department_name}, state, last_update_at,
/// last_update_age_seconds, request_id, session_id, last_point{lat,lng,recorded_at}, color_index`
/// history: `employee, color_index, sessions[], main_points[], path[]`
class EmployeeTrackingSummaryModel {
  final int employeeId;
  final String name;
  final String? jobTitle;
  final String departmentName;
  final int colorIndex;

  /// live `state`: active | offline | stopped | no_active_tracking. Null for history-only items.
  final String? state;
  final DateTime? lastUpdateAt;
  final int? lastUpdateAgeSeconds;
  final int? requestId;
  final int? sessionId;
  final TrackingPointModel? lastPoint;

  /// History sessions with their path (`path` + `main_points` flags) in `points`.
  final List<TrackingSessionModel> sessions;

  const EmployeeTrackingSummaryModel({
    required this.employeeId,
    required this.name,
    this.jobTitle,
    required this.departmentName,
    required this.colorIndex,
    this.state,
    this.lastUpdateAt,
    this.lastUpdateAgeSeconds,
    this.requestId,
    this.sessionId,
    this.lastPoint,
    this.sessions = const [],
  });

  /// Presence for the badge. On a picked day there is no live state, so it comes from the
  /// sessions (API doc: "اعرض حالة الجلسات من sessions[].status").
  EmployeeTrackingPresence get presence {
    if (state != null) return EmployeeTrackingPresence.fromRaw(state!);
    if (sessions.any((s) => s.isActive)) return EmployeeTrackingPresence.active;
    if (sessions.isNotEmpty) return EmployeeTrackingPresence.stopped;
    return EmployeeTrackingPresence.noActiveTracking;
  }

  TrackingSessionModel? get activeSession {
    for (final s in sessions) {
      if (s.isActive) return s;
    }
    return null;
  }

  int get totalDistanceMeters => sessions.fold(0, (sum, s) => sum + s.distanceMeters);
  int get totalActiveSeconds => sessions.fold(0, (sum, s) => sum + s.activeSeconds);

  String getLastUpdatedText() {
    final sec = lastUpdateAgeSeconds;
    if (sec == null) return 'no_activity'.tr();
    if (sec < 60) return 'few_seconds_ago'.tr();
    final min = sec ~/ 60;
    if (min < 60) return 'mins_ago'.tr(namedArgs: {'min': '$min'});
    final hours = min ~/ 60;
    return 'hrs_ago'.tr(namedArgs: {'hours': '$hours'});
  }

  EmployeeTrackingSummaryModel withHistory(EmployeeTrackingSummaryModel history) =>
      EmployeeTrackingSummaryModel(
        employeeId: employeeId,
        name: name,
        jobTitle: jobTitle,
        departmentName: departmentName,
        colorIndex: colorIndex,
        state: state,
        lastUpdateAt: lastUpdateAt,
        lastUpdateAgeSeconds: lastUpdateAgeSeconds,
        requestId: requestId,
        sessionId: sessionId,
        lastPoint: lastPoint,
        sessions: history.sessions,
      );

  static Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : {};

  factory EmployeeTrackingSummaryModel.fromJson(Map<String, dynamic> json) {
    final employee = _map(json['employee']);
    final lp = _map(json['last_point']);
    final sessions = (json['sessions'] as List? ?? const [])
        .whereType<Map>()
        .map((s) => TrackingSessionModel.fromJson(Map<String, dynamic>.from(s)))
        .toList();
    final path = (json['path'] as List? ?? const [])
        .whereType<Map>()
        .map((p) => TrackingPointModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();
    // Start / end markers come from main_points (the path has only auto / manual).
    final markers = (json['main_points'] as List? ?? const [])
        .whereType<Map>()
        .map((p) => TrackingPointModel.fromJson(Map<String, dynamic>.from(p)))
        .where((p) => p.isStartPoint || p.isEndPoint)
        .toList();
    int? i(dynamic v) => int.tryParse(v?.toString() ?? '');
    return EmployeeTrackingSummaryModel(
      employeeId: i(employee['id']) ?? 0,
      name: employee['name']?.toString() ?? '',
      jobTitle: employee['job_title']?.toString(),
      departmentName: employee['department_name']?.toString() ?? '',
      colorIndex: i(json['color_index']) ?? 0,
      state: json['state']?.toString(),
      lastUpdateAt: DateTime.tryParse(json['last_update_at']?.toString() ?? '')?.toLocal(),
      lastUpdateAgeSeconds: i(json['last_update_age_seconds']),
      requestId: i(json['request_id']),
      sessionId: i(json['session_id']),
      lastPoint: lp.isEmpty ? null : TrackingPointModel.fromJson(lp),
      sessions: TrackingSessionModel.attachPoints(sessions, [...path, ...markers]),
    );
  }
}

/// One page of `GET /live` or `GET /history` (10 employees per page).
class TrackingEmployeesPage {
  final List<EmployeeTrackingSummaryModel> employees;
  final int total;
  final int page;
  final int itemsCount;

  const TrackingEmployeesPage({
    this.employees = const [],
    this.total = 0,
    this.page = 1,
    this.itemsCount = 10,
  });

  int get pages => total == 0 ? 1 : (total / (itemsCount == 0 ? 10 : itemsCount)).ceil();
}
