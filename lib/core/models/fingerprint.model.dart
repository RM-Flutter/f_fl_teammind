import 'package:equatable/equatable.dart';

class FingerPrintModel extends Equatable {
  var id;
  var pfor;
  var mustCheckManually;
  final bool? updatedManually;
  var fingerDay;
  final List<FingerDateTime>? fingerDateTime;
  var status;
  var note;
  var createdAt;
  var updatedAt;
  final List<dynamic>? files;

   FingerPrintModel({
    this.id,
    this.pfor,
    this.mustCheckManually,
    this.updatedManually,
    this.fingerDay,
    this.fingerDateTime,
    this.status,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.files,
  });

  factory FingerPrintModel.fromJson(Map<String, dynamic> json) {
    return FingerPrintModel(
      id: json['id'] as int?,
      pfor: json['pfor'] as String?,
      mustCheckManually: json['must_check_manually'] as int?,
      updatedManually: json['updated_manually'] as bool?,
      fingerDay: json['finger_day'] as String?,
      fingerDateTime: (json['finger_datetime'] as List<dynamic>?)
          ?.map((e) => FingerDateTime.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      files: json['files'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pfor': pfor,
      'must_check_manually': mustCheckManually,
      'updated_manually': updatedManually,
      'finger_day': fingerDay,
      'finger_datetime': fingerDateTime?.map((e) => e.toJson()).toList(),
      'status': status,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'files': files,
    };
  }

  FingerPrintModel copyWith({
    int? id,
    String? pfor,
    int? mustCheckManually,
    bool? updatedManually,
    String? fingerDay,
    List<FingerDateTime>? fingerDateTime,
    String? status,
    String? note,
    String? createdAt,
    String? updatedAt,
    List<dynamic>? files,
  }) {
    return FingerPrintModel(
      id: id ?? this.id,
      pfor: pfor ?? this.pfor,
      mustCheckManually: mustCheckManually ?? this.mustCheckManually,
      updatedManually: updatedManually ?? this.updatedManually,
      fingerDay: fingerDay ?? this.fingerDay,
      fingerDateTime: fingerDateTime ?? this.fingerDateTime,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      files: files ?? this.files,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pfor,
        mustCheckManually,
        updatedManually,
        fingerDay,
        fingerDateTime,
        status,
        note,
        createdAt,
        updatedAt,
        files,
      ];

  @override
  String toString() {
    return 'FingerPrintModel(id: $id, pfor: $pfor, mustCheckManually: $mustCheckManually, updatedManually: $updatedManually, fingerDay: $fingerDay, fingerDateTime: $fingerDateTime, status: $status, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, files: $files)';
  }
}

class FingerDateTime extends Equatable {
  final bool? isOffline;
  var branchId;
  final List<dynamic>? files;
  var locationId;
  var type;
  var deviceId;
  var deviceUniqueId;
  var time;

   FingerDateTime({
    this.isOffline,
    this.branchId,
    this.files,
    this.locationId,
    this.type,
    this.deviceId,
    this.deviceUniqueId,
    this.time,
  });

  factory FingerDateTime.fromJson(Map<String, dynamic> json) {
    return FingerDateTime(
      isOffline: json['is_offline'] as bool?,
      branchId: json['branch_id'] ,
      //files: json['files'] as List<dynamic>? ?? null,
      locationId: json['location_id'],
      type: json['type'] ,
      deviceId: json['device_id'],
      deviceUniqueId: json['device_unique_id'] ,
      time: json['time'] ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_offline': isOffline,
      'branch_id': branchId,
      'files': files,
      'location_id': locationId,
      'type': type,
      'device_id': deviceId,
      'device_unique_id': deviceUniqueId,
      'time': time,
    };
  }

  FingerDateTime copyWith({
    bool? isOffline,
    String? branchId,
    List<dynamic>? files,
    int? locationId,
    String? type,
    int? deviceId,
    String? deviceUniqueId,
    String? time,
  }) {
    return FingerDateTime(
      isOffline: isOffline ?? this.isOffline,
      branchId: branchId ?? this.branchId,
      files: files ?? this.files,
      locationId: locationId ?? this.locationId,
      type: type ?? this.type,
      deviceId: deviceId ?? this.deviceId,
      deviceUniqueId: deviceUniqueId ?? this.deviceUniqueId,
      time: time ?? this.time,
    );
  }

  @override
  List<Object?> get props => [
        isOffline,
        branchId,
        files,
        locationId,
        type,
        deviceId,
        deviceUniqueId,
        time,
      ];

  @override
  String toString() {
    return 'FingerDateTime(isOffline: $isOffline, branchId: $branchId, files: $files, locationId: $locationId, type: $type, deviceId: $deviceId, deviceUniqueId: $deviceUniqueId, time: $time)';
  }
}
