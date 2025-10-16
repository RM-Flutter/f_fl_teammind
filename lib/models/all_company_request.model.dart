import 'department.model.dart';

class AllCompanyRequestModel {
  var id;
  var departmentId;
  final String? departmentName;
  var employeeId;
  final String? employeeName;
  var typeId;
  final String? typeName;
  final String? durationType;
  var duration;
  var moneyValue;
  final String? from;
  final String? to;
  var status;
  final String? level;
  final String? managerReply;
  List<Files>? files;
  var createdAt;
  var seenAt;
  var statusUpdate;
  var notes;
  var seenBy;
  var reason;

  AllCompanyRequestModel({
    required this.id,
    required this.notes,
    required this.reason,
    required this.seenAt,
    required this.statusUpdate,
    required this.createdAt,
    required this.departmentId,
    required this.departmentName,
    required this.employeeId,
    required this.employeeName,
    required this.typeId,
    required this.typeName,
    required this.durationType,
    required this.duration,
    required this.moneyValue,
    required this.from,
    required this.to,
    required this.status,
    required this.level,
    this.managerReply,
    this.files,
    this.seenBy,
  });

  factory AllCompanyRequestModel.fromJson(Map<String, dynamic> json) {
    return AllCompanyRequestModel(
      id: json['id'] ?? 0,
      notes: json['notes'] ?? "",
      createdAt: json['created_at'] ?? "",
      statusUpdate: json['status_update_at'] ?? "",
      seenAt: json['sean_at'] ?? "",
      reason: json['reason'] ?? "",
      departmentId: json['department_id'] ?? 0,
      departmentName: json['department_name'] ?? "",
      employeeId: json['employee_id'] ?? 0,
      employeeName: json['employee_name'] ?? "",
      typeId: json['type_id'] ?? 0,
      typeName: json['type_name'] ?? "",
      durationType: json['duration_type'] ?? "",
      duration: json['duration'] ?? 0,
      moneyValue: json['money_value'] ?? 0,
      from: json['from'] ?? "",
      to: json['to'] ?? "",
      status: json['status'],
      level: json['level'] ?? "",
      managerReply: json['manager_reply'],
      files: json['files'] != null
          ? List<Files>.from(json['files'].map((file) => Files.fromJson(file)))
          : [],
      seenBy: json['seen_by'] != null
          ? List<SeenBy>.from(json['seen_by'].map((file) => SeenBy.fromJson(file)))
          : [],
    );
  }
}
class SeenBy {
  int? id;
  String? managerName;
  String? date;

  SeenBy(
      {this.id, this.managerName, this.date});

  SeenBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    managerName = json['manager_name'];
  }
}
class Files {
  int? id;
  String? file;

  Files(
      {this.id, this.file});

  Files.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    file = json['file'];
  }
}
