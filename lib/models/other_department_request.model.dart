import 'department.model.dart';

class OtherDepartmentRequestModel {
  var id;
  var departmentId;
  var departmentName;
  var employeeId;
  var rulesMessage;
  var employeeName;
  var typeId;
  var typeName;
  var durationType;
  var duration;
  var moneyValue;
  var from;
  var to;
  var status;
  var level;
  List<ManagerReply>? managerReply;
  List<SeenBy>? seenBy;
  List<Files>? files;
  var createdAt;
  var seenAt;
  bool? waitingCancel;
  var statusUpdate;
  var notes;
  var reason;

  OtherDepartmentRequestModel({
    required this.id,
    required this.rulesMessage,
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
    this.waitingCancel,
    this.seenBy,
  });

  factory OtherDepartmentRequestModel.fromJson(Map<String, dynamic> json) {
    return OtherDepartmentRequestModel(
      id: json['id'] ?? 0,
      rulesMessage: json['rules_message'] ?? "",
      notes: json['notes'] ?? "",
      waitingCancel: json['waiting_cancel'] ?? false,
      createdAt: json['created_at'] ?? "",
      statusUpdate: json['status_update_at'] ?? "",
      seenAt: json['seen_at'] ?? "",
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
      managerReply: json['manager_reply'] != null
          ? List<ManagerReply>.from(json['manager_reply'].map((file) => ManagerReply.fromJson(file)))
          : [],
      seenBy: json['seen_by'] != null
          ? List<SeenBy>.from(json['seen_by'].map((file) => SeenBy.fromJson(file)))
          : [],
      files: json['files'] != null
          ? List<Files>.from(json['files'].map((file) => Files.fromJson(file)))
          : [],
    );
  }
}
class SeenBy {
  var id;
  var managerName;
  var date;

  SeenBy(
      {this.id, this.managerName, this.date});

  SeenBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    managerName = json['manager_name'];
  }
}
class Files {
  var id;
  var file;

  Files(
      {this.id, this.file});

  Files.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    file = json['file'];
  }
}
class ManagerReply {
  var id;
  var name;
  var jobTitle;
  var replay;
  var createAt;

  ManagerReply(
      {this.id, this.name, this.jobTitle, this.createAt, this.replay});

  ManagerReply.fromJson(Map<String, dynamic> json) {
    id = json['manager_id'];
    name = json['manager_name'];
    jobTitle = json['manager_job_title'];
    replay = json['replay'];
    createAt = json['created_at'];
  }
}