
class RequestModel {
  var id;
  var departmentId;
  var departmentName;
  var employeeId;
  var employeeName;
  var typeId;
  var typeName;
  var durationType;
  var duration;
  var moneyValue;
  var from;
  var to;
  var rulesMessage;
  var status;
  bool? waitingCancel;
  bool? takeAction;
  bool? canTakeActionAsSomeoneElse;
  var level;
  List<Files>? files;
  List<ManagerReply>? managerReply;
  List<SeenBy>? seenBy;
  var createdAt;
  var seenAt;
  var statusUpdate;
  var notes;
  var reason;
  var approvableType;

  RequestModel({
    required this.id,
    required this.notes,
    required this.rulesMessage,
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
    required this.waitingCancel,
    required this.durationType,
    required this.duration,
    required this.moneyValue,
    required this.from,
    required this.to,
    required this.status,
    required this.level,
    this.approvableType,
    this.takeAction,
    this.canTakeActionAsSomeoneElse,
    this.managerReply,
    this.seenBy,
    this.files,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] ?? 0,
      rulesMessage: json['rules_message'] ?? "",
      waitingCancel: json['waiting_cancel'] ?? false,
      takeAction: json['can_take_action'] as bool?,
      canTakeActionAsSomeoneElse: (json['can_take_action_as_someone_else'] ?? json['take_action_as_someone_else']) as bool?,
      notes: json['notes'] ?? "",
      files: json['files'] != null
          ? List<Files>.from(json['files'].map((file) => Files.fromJson(file)))
          : [],
      managerReply: json['manager_reply'] != null
          ? List<ManagerReply>.from(json['manager_reply'].map((file) => ManagerReply.fromJson(file)))
          : [],
      seenBy: json['seen_by'] != null
          ? List<SeenBy>.from(json['seen_by'].map((file) => SeenBy.fromJson(file)))
          : [],
      createdAt: json['created_at'] ?? "",
      statusUpdate: json['status_update_at'] ?? "",
      seenAt: json['seen_at'] ?? "",
      reason: json['reason'] ?? "",
      departmentId: json['department_id'] ?? (json['department'] is Map ? json['department']['id'] : null) ?? 0,
      departmentName: json['department_name'] ?? (json['department'] is Map ? json['department']['title'] : null) ?? "",
      employeeId: json['employee_id'] ?? (json['profile'] is Map ? json['profile']['id'] : null) ?? 0,
      employeeName: json['employee_name'] ?? (json['profile'] is Map ? json['profile']['name'] : null) ?? "",
      typeId: json['type_id'] ?? 0,
      typeName: json['type_name'] ?? "",
      durationType: json['duration_type'] ?? json['unit'] ?? "",
      duration: json['duration'] ?? 0,
      moneyValue: json['money_value'] ?? 0,
      from: json['from'] ?? json['date_from'] ?? "",
      to: json['to'] ?? json['date_to'] ?? "",
      status: json['status'],
      level: json['level'] ?? "",
      approvableType: json['approvable_type'] ?? "",
    );
  }

  /// Factory for the new unified Approvals API response structure.
  /// Maps `approvables[]` items → RequestModel.
  /// Old fromJson() is kept above for backward compatibility (details screens, etc.)
  factory RequestModel.fromApprovableJson(Map<String, dynamic> json) {
    final department = json['department'] as Map<String, dynamic>? ?? {};
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return RequestModel(
      id: json['id'] ?? 0,
      // rules_message not returned yet in new API — backend will re-add it
      rulesMessage: "",
      waitingCancel: json['waiting_cancel'] ?? false,
      notes: json['notes'] ?? "",
      // No files/managerReply/seenBy in list endpoint — kept empty for list cards
      files: [],
      managerReply: [],
      seenBy: [],
      createdAt: json['created_at'] ?? "",
      // updated_at plays role of status_update_at
      statusUpdate: json['updated_at'] ?? "",
      // seen_at not present in list endpoint
      seenAt: "",
      reason: json['reason'] ?? "",
      // department is now a nested object: { id, title }
      departmentId: department['id'] ?? 0,
      departmentName: department['title'] ?? "",
      // employee info is now in profile: { id, name }
      employeeId: profile['id'] ?? 0,
      employeeName: profile['name'] ?? "",
      typeId: json['type_id'] ?? 0,
      typeName: json['type_name'] ?? "",
      // unit replaces duration_type (e.g. "days", "hours")
      durationType: json['unit'] ?? "",
      duration: json['duration'] ?? 0,
      moneyValue: json['money_value'] ?? 0,
      // date_from / date_to replace from / to
      from: json['date_from'] ?? "",
      to: json['date_to'] ?? "",
      status: json['status'],
      level: json['level'] ?? "",
      approvableType: json['approvable_type'] ?? "",
      takeAction: (json['can_take_action'] ?? json['take_action']) as bool?,
      canTakeActionAsSomeoneElse: (json['can_take_action_as_someone_else'] ?? json['take_action_as_someone_else']) as bool?,
    );
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
