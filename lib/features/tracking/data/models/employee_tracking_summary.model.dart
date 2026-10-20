import 'tracking_point.model.dart';
import 'tracking_session.model.dart';

class EmployeeTrackingSummaryModel {
  final int employeeId;
  final String employeeName;
  final String? employeeNameEn;
  final String departmentName;
  final String? departmentNameEn;
  final String? avatarUrl;
  final int colorIndex;
  final String status; // 'active' | 'completed' | 'offline' | 'no_active_tracking'
  final TrackingSessionModel? activeSession;
  final TrackingPointModel? lastPoint;
  final int? lastUpdatedAgoSeconds;
  final List<TrackingSessionModel> sessions;

  const EmployeeTrackingSummaryModel({
    required this.employeeId,
    required this.employeeName,
    this.employeeNameEn,
    required this.departmentName,
    this.departmentNameEn,
    this.avatarUrl,
    required this.colorIndex,
    required this.status,
    this.activeSession,
    this.lastPoint,
    this.lastUpdatedAgoSeconds,
    this.sessions = const [],
  });

  bool get isActive => status == 'active';
  bool get isOffline => status == 'offline';
  bool get hasActiveTracking => activeSession != null;

  String getName({bool isArabic = true}) =>
      (isArabic ? employeeName : (employeeNameEn ?? employeeName));

  String getDepartment({bool isArabic = true}) =>
      (isArabic ? departmentName : (departmentNameEn ?? departmentName));

  String getLastUpdatedText({bool isArabic = true}) {
    if (lastUpdatedAgoSeconds == null) {
      return isArabic ? "لا يوجد نشاط" : "No Activity";
    }
    final sec = lastUpdatedAgoSeconds!;
    if (sec < 60) {
      return isArabic ? "منذ ثوانٍ" : "Few seconds ago";
    }
    final min = sec ~/ 60;
    if (min < 60) {
      return isArabic ? "منذ $min دقيقة" : "$min mins ago";
    }
    final hours = min ~/ 60;
    return isArabic ? "منذ $hours ساعة" : "$hours hrs ago";
  }

  factory EmployeeTrackingSummaryModel.fromJson(Map<String, dynamic> json) {
    return EmployeeTrackingSummaryModel(
      employeeId: json['employee_id'] is int
          ? json['employee_id']
          : int.tryParse(json['employee_id']?.toString() ?? '0') ?? 0,
      employeeName: json['employee_name']?.toString() ?? '',
      employeeNameEn: json['employee_name_en']?.toString(),
      departmentName: json['department_name']?.toString() ?? '',
      departmentNameEn: json['department_name_en']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      colorIndex: json['color_index'] is int
          ? json['color_index']
          : int.tryParse(json['color_index']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'no_active_tracking',
      activeSession: json['active_session'] != null
          ? TrackingSessionModel.fromJson(json['active_session'] as Map<String, dynamic>)
          : null,
      lastPoint: json['last_point'] != null
          ? TrackingPointModel.fromJson(json['last_point'] as Map<String, dynamic>)
          : null,
      lastUpdatedAgoSeconds: json['last_updated_ago_seconds'] as int?,
      sessions: (json['sessions'] as List?)
              ?.map((s) => TrackingSessionModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
