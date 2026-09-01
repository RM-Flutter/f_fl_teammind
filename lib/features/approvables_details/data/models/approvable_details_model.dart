class ApprovableDetailsModel {
  final int? id;
  final String? approvableType;
  final String? status;
  final bool? takeAction;
  final bool? canTakeActionAsSomeoneElse;
  final bool? canUpdateApproval;
  final bool? waitingCancel;
  final String? createdAt;
  final String? updatedAt;
  final List<RequiredApprovalModel>? requiredApprovals;
  final String? seenAt;
  final List<dynamic>? seenBy;
  final DepartmentModel? department;
  final ProfileModel? profile;
  final int? typeId;
  final String? typeName;
  final num? duration;
  final String? unit;
  final String? moneyValue;
  final String? dateFrom;
  final String? dateTo;
  final String? reason;
  final int? level;
  final String? notes;
  final List<dynamic>? files;

  dynamic get from => dateFrom;
  dynamic get to => dateTo;
  dynamic get durationType => unit;
  dynamic get employeeId => profile?.id;
  dynamic get employeeName => profile?.name;
  dynamic get departmentName => department?.title;
  dynamic get statusUpdate => updatedAt;
  dynamic get managerReply => requiredApprovals ?? [];

  ApprovableDetailsModel({
    this.id,
    this.approvableType,
    this.status,
    this.takeAction,
    this.canTakeActionAsSomeoneElse,
    this.canUpdateApproval,
    this.waitingCancel,
    this.createdAt,
    this.updatedAt,
    this.requiredApprovals,
    this.seenAt,
    this.seenBy,
    this.department,
    this.profile,
    this.typeId,
    this.typeName,
    this.duration,
    this.unit,
    this.moneyValue,
    this.dateFrom,
    this.dateTo,
    this.reason,
    this.level,
    this.notes,
    this.files,
  });

  factory ApprovableDetailsModel.fromJson(Map<String, dynamic> json) {
    return ApprovableDetailsModel(
      id: json['id'],
      approvableType: json['approvable_type'],
      status: json['status'],
      takeAction: (json['can_take_action'] ?? json['take_action']) as bool? ?? false,
      canTakeActionAsSomeoneElse: (json['can_take_action_as_someone_else'] ?? json['take_action_as_someone_else']) as bool? ?? false,
      canUpdateApproval: (json['can_update_approval'] ?? json['can_update'] ?? json['update_approval']) as bool? ?? false,
      waitingCancel: json['waiting_cancel'] as bool?,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      requiredApprovals: json['required_approvals'] != null
          ? List<RequiredApprovalModel>.from(
              (json['required_approvals'] as List).map(
                (x) => RequiredApprovalModel.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      seenAt: json['seen_at'],
      seenBy: json['seen_by'] as List<dynamic>?,
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      typeId: json['type_id'],
      typeName: json['type_name'],
      duration: json['duration'] is num
          ? json['duration']
          : num.tryParse(json['duration']?.toString() ?? ''),
      unit: json['unit'],
      moneyValue: json['money_value']?.toString(),
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      reason: json['reason'],
      level: json['level'],
      notes: json['notes'],
      files: json['files'] as List<dynamic>?,
    );
  }
}

class RequiredApprovalModel {
  final int? id;
  final String? type;
  final String? role;
  final int? departmentId;
  final DepartmentModel? department;
  final int? employeeId;
  final ProfileModel? employee;
  final String? status;
  final String? statusLabel;
  final int? level;
  final bool? isAuto;
  final String? replay;
  final String? file;
  final String? startedTime;
  final String? approvedAutoTime;
  final int? actedBy;
  final ProfileModel? actor;

  RequiredApprovalModel({
    this.id,
    this.type,
    this.role,
    this.departmentId,
    this.department,
    this.employeeId,
    this.employee,
    this.status,
    this.statusLabel,
    this.level,
    this.isAuto,
    this.replay,
    this.file,
    this.startedTime,
    this.approvedAutoTime,
    this.actedBy,
    this.actor,
  });

  factory RequiredApprovalModel.fromJson(Map<String, dynamic> json) {
    return RequiredApprovalModel(
      id: json['id'],
      type: json['type'],
      role: json['role'],
      departmentId: json['department_id'],
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      employeeId: json['employee_id'],
      employee: json['employee'] != null
          ? ProfileModel.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      status: json['status'],
      statusLabel: json['status_label'],
      level: json['level'],
      isAuto: json['is_auto'] as bool?,
      replay: json['replay']?.toString(),
      file: json['file']?.toString(),
      startedTime: json['started_time'],
      approvedAutoTime: json['approved_auto_time'],
      actedBy: json['acted_by'],
      actor: json['actor'] != null
          ? ProfileModel.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DepartmentModel {
  final int? id;
  final String? title;
  final int? parentId;

  DepartmentModel({this.id, this.title, this.parentId});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      title: json['title'] ?? json['name'],
      parentId: json['parent_id'],
    );
  }
}

class ProfileModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? jobTitle;
  final String? department;
  final int? departmentId;

  ProfileModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.jobTitle,
    this.department,
    this.departmentId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone']?.toString(),
      avatar: json['avatar'],
      jobTitle: json['job_title'],
      department: json['department']?.toString(),
      departmentId: json['department_id'],
    );
  }
}

class CurrentLevelApproverModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? jobTitle;
  final String? department;

  CurrentLevelApproverModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.jobTitle,
    this.department,
  });

  factory CurrentLevelApproverModel.fromJson(Map<String, dynamic> json) {
    return CurrentLevelApproverModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone']?.toString(),
      avatar: json['avatar'],
      jobTitle: json['job_title'],
      department: json['department']?.toString(),
    );
  }
}
