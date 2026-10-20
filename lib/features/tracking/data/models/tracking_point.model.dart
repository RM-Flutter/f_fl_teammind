class TrackingPointModel {
  final String clientPointId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double accuracy;
  final double? speed;
  final double? heading;
  final double? altitude;
  final String pointType; // 'auto' | 'manual'
  final String? label;
  final String? labelEn;
  final bool isStartPoint;
  final bool isEndPoint;

  const TrackingPointModel({
    required this.clientPointId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy = 10.0,
    this.speed,
    this.heading,
    this.altitude,
    this.pointType = 'auto',
    this.label,
    this.labelEn,
    this.isStartPoint = false,
    this.isEndPoint = false,
  });

  bool get isManual => pointType == 'manual' || (label != null && label!.trim().isNotEmpty);
  bool get isAccurate => accuracy <= 30.0;

  String getDisplayLabel({bool isArabic = true}) {
    if (isStartPoint) {
      return isArabic ? (label ?? 'نقطة الانطلاق') : (labelEn ?? 'Start Point');
    }
    if (isEndPoint) {
      return isArabic ? (label ?? 'نقطة التوقف') : (labelEn ?? 'End Point');
    }
    if (isArabic) {
      return label ?? 'نقطة تتبع';
    } else {
      return labelEn ?? label ?? 'Tracking Point';
    }
  }

  factory TrackingPointModel.fromJson(Map<String, dynamic> json) {
    return TrackingPointModel(
      clientPointId: json['client_point_id']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      recordedAt: json['recorded_at'] != null
          ? DateTime.tryParse(json['recorded_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 10.0,
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      pointType: json['point_type']?.toString() ?? 'auto',
      label: json['label']?.toString(),
      labelEn: json['label_en']?.toString(),
      isStartPoint: json['is_start_point'] == true,
      isEndPoint: json['is_end_point'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_point_id': clientPointId,
      'latitude': latitude,
      'longitude': longitude,
      'recorded_at': recordedAt.toIso8601String(),
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'altitude': altitude,
      'point_type': pointType,
      'label': label,
      'label_en': labelEn,
      'is_start_point': isStartPoint,
      'is_end_point': isEndPoint,
    };
  }
}
