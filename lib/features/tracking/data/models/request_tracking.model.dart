import 'tracking_point.model.dart';
import 'tracking_session.model.dart';
import 'tracking_status.enum.dart';

/// The `tracking` block of a request. It comes with every item of the request lists
/// (`my-approvables`, `under-my-management-approvables`), with the approvable details and with
/// `GET /emp_requests/v1/tracking/requests/{id}`.
///
/// The app never decides on its own whether tracking can start: [canStart] already covers the
/// request dates, a closed request, the request type and an open session.
class RequestTrackingInfoModel {
  /// `inactive` | `optional` | `required`
  final String requirement;
  final RequestTrackingStatus status;
  final bool canStart;
  final String? canStartReason;
  final int? activeSessionId;
  final int startCount;
  final double activeHours;

  /// Null when the company has no work hours for this request.
  final double? workHours;
  final bool hasSessions;

  const RequestTrackingInfoModel({
    this.requirement = 'inactive',
    this.status = RequestTrackingStatus.notRequired,
    this.canStart = false,
    this.canStartReason,
    this.activeSessionId,
    this.startCount = 0,
    this.activeHours = 0,
    this.workHours,
    this.hasSessions = false,
  });

  bool get isInactive => requirement == 'inactive';
  bool get isRequired => requirement == 'required';

  /// Approval is refused by the server until the employee tracks the request.
  bool get blocksApproval => isRequired && status == RequestTrackingStatus.requiredNotStarted;

  static RequestTrackingInfoModel? tryParse(dynamic json) =>
      json is Map ? RequestTrackingInfoModel.fromJson(Map<String, dynamic>.from(json)) : null;

  factory RequestTrackingInfoModel.fromJson(Map<String, dynamic> json) {
    double? n(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    return RequestTrackingInfoModel(
      requirement: json['requirement']?.toString() ?? 'inactive',
      status: RequestTrackingStatus.fromRaw(json['status']?.toString()),
      canStart: json['can_start'] == true,
      canStartReason: json['can_start_reason']?.toString(),
      activeSessionId: int.tryParse(json['active_session_id']?.toString() ?? ''),
      startCount: int.tryParse(json['start_count']?.toString() ?? '') ?? 0,
      activeHours: n(json['active_hours']) ?? 0,
      workHours: n(json['work_hours']),
      hasSessions: json['has_sessions'] == true,
    );
  }
}

/// `GET /requests/{requestId}`: everything the request's tracking tab needs except the full map.
/// [sessions] carry their key points (`main_points`) in `points`.
class RequestTrackingDetailsModel {
  final int requestId;
  final RequestTrackingInfoModel tracking;
  final List<TrackingSessionModel> sessions;

  const RequestTrackingDetailsModel({
    required this.requestId,
    required this.tracking,
    required this.sessions,
  });

  factory RequestTrackingDetailsModel.fromJson(Map<String, dynamic> json) {
    final sessions = (json['sessions'] as List? ?? const [])
        .whereType<Map>()
        .map((s) => TrackingSessionModel.fromJson(Map<String, dynamic>.from(s)))
        .toList();
    final mainPoints = (json['main_points'] as List? ?? const [])
        .whereType<Map>()
        .map((p) => TrackingPointModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();
    return RequestTrackingDetailsModel(
      requestId: int.tryParse(json['request_id']?.toString() ?? '') ?? 0,
      tracking: RequestTrackingInfoModel.tryParse(json['tracking']) ?? const RequestTrackingInfoModel(),
      sessions: TrackingSessionModel.attachPoints(sessions, mainPoints),
    );
  }
}
