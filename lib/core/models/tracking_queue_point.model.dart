/// A location point waiting in the phone's queue to be uploaded to
/// `POST /emp_requests/v1/tracking/sessions/{sessionId}/points` (request-linked tracking).
///
/// [clientPointId] is made once per point and never changes, so a re-sent point is never saved
/// twice by the server.
class TrackingQueuePoint {
  final String clientPointId;
  final int sessionId;
  final int requestId;
  final double latitude;
  final double longitude;

  /// When the phone took the point (not when it is sent).
  final DateTime recordedAt;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final double? altitude;

  /// `auto` | `manual`
  final String pointType;
  final String? label;

  const TrackingQueuePoint({
    required this.clientPointId,
    required this.sessionId,
    required this.requestId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy,
    this.speed,
    this.heading,
    this.altitude,
    this.pointType = 'auto',
    this.label,
  });

  bool get isManual => pointType == 'manual';

  /// ISO 8601 with the phone's UTC offset, e.g. `2026-11-17T09:16:00+02:00`.
  static String isoWithOffset(DateTime t) {
    final local = t.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-${two(local.day)}'
        'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}'
        '$sign${two(abs.inHours)}:${two(abs.inMinutes % 60)}';
  }

  /// Body item of the upload request.
  Map<String, dynamic> toApiJson() => {
        'client_point_id': clientPointId,
        'latitude': latitude,
        'longitude': longitude,
        'recorded_at': isoWithOffset(recordedAt),
        if (accuracy != null) 'accuracy': accuracy,
        if (speed != null && speed! >= 0) 'speed': speed,
        if (heading != null && heading! >= 0) 'heading': heading,
        if (altitude != null) 'altitude': altitude,
        'point_type': pointType,
        if (label != null && label!.trim().isNotEmpty) 'label': label!.trim(),
      };

  /// Local storage (SharedPreferences).
  Map<String, dynamic> toJson() => {
        'id': clientPointId,
        'session_id': sessionId,
        'request_id': requestId,
        'lat': latitude,
        'lng': longitude,
        'at': recordedAt.toUtc().toIso8601String(),
        'acc': accuracy,
        'speed': speed,
        'heading': heading,
        'alt': altitude,
        'type': pointType,
        'label': label,
      };

  static double? _d(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');

  factory TrackingQueuePoint.fromJson(Map<String, dynamic> json) => TrackingQueuePoint(
        clientPointId: json['id'].toString(),
        sessionId: int.parse(json['session_id'].toString()),
        requestId: int.tryParse(json['request_id']?.toString() ?? '') ?? 0,
        latitude: _d(json['lat']) ?? 0,
        longitude: _d(json['lng']) ?? 0,
        recordedAt: DateTime.parse(json['at'].toString()).toLocal(),
        accuracy: _d(json['acc']),
        speed: _d(json['speed']),
        heading: _d(json['heading']),
        altitude: _d(json['alt']),
        pointType: json['type']?.toString() ?? 'auto',
        label: json['label']?.toString(),
      );
}
