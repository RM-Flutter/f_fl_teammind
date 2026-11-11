import 'tracking_status.enum.dart';

/// One row of the tracking reports (spec: back end §9). The same row feeds the three reports:
/// Manager Tracking Compliance, HR Tracking Compliance and Tracking History.
class TrackingReportRowModel {
  final int employeeId;
  final String employeeName;
  final String departmentName;
  final int requestId;
  final String requestType;
  final bool isRequired;
  final RequestTrackingStatus status;
  final DateTime requestDate;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? lastUpdateAt;
  final int sessionsCount;
  final int durationMinutes;
  final int pointsCount;
  final double distanceKm;

  const TrackingReportRowModel({
    required this.employeeId,
    required this.employeeName,
    required this.departmentName,
    required this.requestId,
    required this.requestType,
    required this.isRequired,
    required this.status,
    required this.requestDate,
    this.startedAt,
    this.endedAt,
    this.lastUpdateAt,
    this.sessionsCount = 0,
    this.durationMinutes = 0,
    this.pointsCount = 0,
    this.distanceKm = 0,
  });

  bool get isStarted => sessionsCount > 0;
  bool get isCompleted => status == RequestTrackingStatus.completed;
  bool get isMissing =>
      status == RequestTrackingStatus.requiredMissing || status == RequestTrackingStatus.requiredNotStarted;

  factory TrackingReportRowModel.fromJson(Map<String, dynamic> json) {
    RequestTrackingStatus status = RequestTrackingStatus.notRequired;
    for (final s in RequestTrackingStatus.values) {
      if (s.name == json['tracking_status']) status = s;
    }
    DateTime? date(String key) => json[key] == null ? null : DateTime.tryParse(json[key].toString());
    int number(String key) => int.tryParse(json[key]?.toString() ?? '') ?? 0;
    return TrackingReportRowModel(
      employeeId: number('employee_id'),
      employeeName: json['employee_name']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
      requestId: number('request_id'),
      requestType: json['request_type']?.toString() ?? '',
      isRequired: json['tracking_requirement'] == 'required',
      status: status,
      requestDate: date('request_date') ?? DateTime.now(),
      startedAt: date('started_at'),
      endedAt: date('ended_at'),
      lastUpdateAt: date('last_update_at'),
      sessionsCount: number('sessions_count'),
      durationMinutes: number('duration_minutes'),
      pointsCount: number('points_count'),
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? '') ?? 0,
    );
  }
}
