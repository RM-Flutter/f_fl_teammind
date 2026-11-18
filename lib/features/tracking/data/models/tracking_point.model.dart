/// One point of a tracking route, as the server returns it:
/// - `main_points[]`: `{kind: start | end | manual, session_id, label, lat, lng, recorded_at}`
/// - `path[]`: `{session_id, lat, lng, recorded_at, type: auto | manual, label}`
///   (`path?only=main` returns the `main_points` shape, so `kind` is read as a fallback).
/// Server times are UTC; they are kept in local time here.
class TrackingPointModel {
  final int? sessionId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;

  /// Metres. Not returned by the read APIs, so usually null.
  final double? accuracy;
  final String pointType; // 'auto' | 'manual'
  final String? label;
  final bool isStartPoint;
  final bool isEndPoint;

  const TrackingPointModel({
    this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy,
    this.pointType = 'auto',
    this.label,
    this.isStartPoint = false,
    this.isEndPoint = false,
  });

  bool get isManual => pointType == 'manual';
  bool get isKeyPoint => isStartPoint || isEndPoint || isManual;

  String getDisplayLabel({bool isArabic = true}) {
    final l = label?.trim();
    if (l != null && l.isNotEmpty) return l;
    if (isStartPoint) return isArabic ? 'نقطة الانطلاق' : 'Start Point';
    if (isEndPoint) return isArabic ? 'نقطة التوقف' : 'End Point';
    if (isManual) return isArabic ? 'نقطة رئيسية' : 'Key Point';
    return isArabic ? 'نقطة تتبع' : 'Tracking Point';
  }

  static double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  static DateTime parseTime(dynamic v) =>
      (DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now()).toLocal();

  factory TrackingPointModel.fromJson(Map<String, dynamic> json) {
    final kind = json['kind']?.toString();
    final type = json['type']?.toString() ?? (kind == 'manual' ? 'manual' : 'auto');
    return TrackingPointModel(
      sessionId: int.tryParse(json['session_id']?.toString() ?? ''),
      latitude: _d(json['lat'] ?? json['latitude']),
      longitude: _d(json['lng'] ?? json['longitude']),
      recordedAt: parseTime(json['recorded_at']),
      accuracy: json['accuracy'] == null ? null : _d(json['accuracy']),
      pointType: type,
      label: json['label']?.toString(),
      isStartPoint: kind == 'start',
      isEndPoint: kind == 'end',
    );
  }
}
