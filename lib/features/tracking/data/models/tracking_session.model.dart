import 'package:easy_localization/easy_localization.dart';
import 'tracking_point.model.dart';
import 'tracking_status.enum.dart';

class TrackingSessionModel {
  final int id;
  final int requestId;
  final int employeeId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final TrackingSessionStatus status;
  final String? stopSource;
  final String? startSource;
  final DateTime? lastPointAt;
  final int pointsCount;
  final int manualPointsCount;
  final int durationMinutes;
  final List<TrackingPointModel> points;

  const TrackingSessionModel({
    required this.id,
    required this.requestId,
    required this.employeeId,
    required this.startedAt,
    this.endedAt,
    this.status = TrackingSessionStatus.active,
    this.stopSource,
    this.startSource = 'employee_app',
    this.lastPointAt,
    this.pointsCount = 0,
    this.manualPointsCount = 0,
    this.durationMinutes = 0,
    this.points = const [],
  });

  bool get isActive => status == TrackingSessionStatus.active;

  List<TrackingPointModel> get manualPoints =>
      points.where((p) => p.isManual || p.isStartPoint || p.isEndPoint).toList();

  String get durationFormatted => getDurationFormatted(isArabic: true);

  String getDurationFormatted({bool isArabic = true}) {
    final minutes = durationMinutes > 0
        ? durationMinutes
        : DateTime.now().difference(startedAt).inMinutes;
    if (minutes < 60) {
      return 'mins_2'.tr(namedArgs: {'minutes': '$minutes'});
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return 'hrs'.tr(namedArgs: {'hours': '$hours'});
    }
    return 'h_m'.tr(namedArgs: {'hours': '$hours', 'remaining_minutes': '$remainingMinutes'});
  }

  factory TrackingSessionModel.fromJson(Map<String, dynamic> json) {
    TrackingSessionStatus sessionStatus = TrackingSessionStatus.active;
    final statusStr = json['status']?.toString().toLowerCase();
    if (statusStr == 'completed') {
      sessionStatus = TrackingSessionStatus.completed;
    } else if (statusStr == 'interrupted') {
      sessionStatus = TrackingSessionStatus.interrupted;
    } else if (statusStr == 'cancelled') {
      sessionStatus = TrackingSessionStatus.cancelled;
    }

    final pointsList = (json['points'] as List?)
            ?.map((p) => TrackingPointModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return TrackingSessionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      requestId: json['request_id'] is int
          ? json['request_id']
          : int.tryParse(json['request_id'].toString()) ?? 0,
      employeeId: json['employee_id'] is int
          ? json['employee_id']
          : int.tryParse(json['employee_id'].toString()) ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      status: sessionStatus,
      stopSource: json['stop_source']?.toString(),
      startSource: json['start_source']?.toString() ?? 'employee_app',
      lastPointAt: json['last_point_at'] != null
          ? DateTime.tryParse(json['last_point_at'].toString())
          : null,
      pointsCount: json['points_count'] is int
          ? json['points_count']
          : int.tryParse(json['points_count']?.toString() ?? '0') ?? pointsList.length,
      manualPointsCount: json['manual_points_count'] is int
          ? json['manual_points_count']
          : pointsList.where((p) => p.isManual).length,
      durationMinutes: json['duration_minutes'] is int
          ? json['duration_minutes']
          : int.tryParse(json['duration_minutes']?.toString() ?? '0') ?? 0,
      points: pointsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'employee_id': employeeId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'status': status.name,
      'stop_source': stopSource,
      'start_source': startSource,
      'last_point_at': lastPointAt?.toIso8601String(),
      'points_count': pointsCount,
      'manual_points_count': manualPointsCount,
      'duration_minutes': durationMinutes,
      'points': points.map((p) => p.toJson()).toList(),
    };
  }
}
