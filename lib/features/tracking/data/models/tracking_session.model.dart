import 'package:easy_localization/easy_localization.dart';
import 'tracking_point.model.dart';
import 'tracking_status.enum.dart';

/// One tracking session (leg) of a request. Every Start / Stop makes a new session.
///
/// Server object (`sessions[]`, Start / Stop / upload `data`): `id, request_id, profile_id, status,
/// start_source, stop_source, points_count, manual_points_count, distance_m, active_seconds,
/// first_point, last_point, permission_state, started_at, ended_at, last_point_at,
/// last_uploaded_at`. Right after Start the counters come back as `null`.
///
/// [points] is filled by the app: the key points (`main_points`) for the log, or the whole
/// `path` for the map.
class TrackingSessionModel {
  final int id;
  final int requestId;
  final int profileId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final TrackingSessionStatus status;
  final String? stopSource;
  final DateTime? lastPointAt;
  final int pointsCount;
  final int manualPointsCount;
  final int distanceMeters;
  final int activeSeconds;
  final List<TrackingPointModel> points;

  const TrackingSessionModel({
    required this.id,
    this.requestId = 0,
    this.profileId = 0,
    required this.startedAt,
    this.endedAt,
    this.status = TrackingSessionStatus.active,
    this.stopSource,
    this.lastPointAt,
    this.pointsCount = 0,
    this.manualPointsCount = 0,
    this.distanceMeters = 0,
    this.activeSeconds = 0,
    this.points = const [],
  });

  bool get isActive => status == TrackingSessionStatus.active;

  TrackingSessionModel withPoints(List<TrackingPointModel> pts) => TrackingSessionModel(
        id: id,
        requestId: requestId,
        profileId: profileId,
        startedAt: startedAt,
        endedAt: endedAt,
        status: status,
        stopSource: stopSource,
        lastPointAt: lastPointAt,
        pointsCount: pointsCount,
        manualPointsCount: manualPointsCount,
        distanceMeters: distanceMeters,
        activeSeconds: activeSeconds,
        points: pts,
      );

  /// Time actually tracked (server `active_seconds`); for a running session with no number yet,
  /// the time since it started.
  String getDurationFormatted({bool isArabic = true}) {
    final minutes = activeSeconds > 0
        ? activeSeconds ~/ 60
        : (isActive ? DateTime.now().difference(startedAt).inMinutes : 0);
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

  static int _i(dynamic v) => v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

  factory TrackingSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime? time(String k) =>
        json[k] == null ? null : DateTime.tryParse(json[k].toString())?.toLocal();
    return TrackingSessionModel(
      id: _i(json['id']),
      requestId: _i(json['request_id']),
      profileId: _i(json['profile_id']),
      startedAt: time('started_at') ?? DateTime.now(),
      endedAt: time('ended_at'),
      status: TrackingSessionStatus.fromRaw(json['status']?.toString()),
      stopSource: json['stop_source']?.toString(),
      lastPointAt: time('last_point_at'),
      pointsCount: _i(json['points_count']),
      manualPointsCount: _i(json['manual_points_count']),
      distanceMeters: _i(json['distance_m']),
      activeSeconds: _i(json['active_seconds']),
    );
  }

  /// Attaches each point to its session (by `session_id`), sorted by time.
  static List<TrackingSessionModel> attachPoints(
      List<TrackingSessionModel> sessions, List<TrackingPointModel> points) {
    final sorted = [...sessions]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    return [
      for (final s in sorted)
        s.withPoints(points.where((p) => p.sessionId == s.id).toList()
          ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt))),
    ];
  }
}
