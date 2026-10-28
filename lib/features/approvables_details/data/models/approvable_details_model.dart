import '../../../../core/models/employee_action_model.dart';

class ApprovableDetailsModel {
  final int? id;
  final String? approvableType;
  final String? status;
  final bool? takeAction;
  final bool? canTakeActionAsSomeoneElse;
  final bool? canUpdateApproval;
  final bool? waitingCancel;
  final bool? hasOverlapping;
  final String? createdAt;
  final String? updatedAt;
  final List<RequiredApprovalModel>? requiredApprovals;
  final String? seenAt;
  final List<SeenByModel>? seenBy;
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
  final List<EmployeeActionModel>? employeeActions;

  // Extra fields for Shift Change Requests & Shift/Leave conflicts
  final ProfileModel? requesterEmployee;
  final ProfileModel? receiverEmployee;
  final int? requesterEmployeeId;
  final int? receiverEmployeeId;
  final int? requesterShiftId;
  final int? receiverShiftId;
  final String? requesterShiftName;
  final String? receiverShiftName;
  final int? requesterShiftAssignmentId;
  final int? receiverShiftAssignmentId;
  final String? requesterDate;
  final String? receiverDate;
  final bool? isValid;
  final bool? hasProblem;
  final String? problemMessage;
  final List<dynamic>? problems;

  dynamic get from => dateFrom;
  dynamic get to => dateTo;
  dynamic get durationType => unit;
  dynamic get employeeId => profile?.id;
  dynamic get employeeName => profile?.name;
  dynamic get departmentName => department?.title;
  dynamic get statusUpdate => updatedAt;
  dynamic get managerReply => requiredApprovals ?? [];
  bool get isShiftChangeRequest => approvableType == 'shift_change_requests';
  bool get isTwoWayShiftSwap => receiverShiftAssignmentId != null;

  ApprovableDetailsModel({
    this.id,
    this.approvableType,
    this.status,
    this.takeAction,
    this.canTakeActionAsSomeoneElse,
    this.canUpdateApproval,
    this.waitingCancel,
    this.hasOverlapping,
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
    this.employeeActions,
    this.requesterEmployee,
    this.receiverEmployee,
    this.requesterEmployeeId,
    this.receiverEmployeeId,
    this.requesterShiftId,
    this.receiverShiftId,
    this.requesterShiftName,
    this.receiverShiftName,
    this.requesterShiftAssignmentId,
    this.receiverShiftAssignmentId,
    this.requesterDate,
    this.receiverDate,
    this.isValid,
    this.hasProblem,
    this.problemMessage,
    this.problems,
  });

  factory ApprovableDetailsModel.fromJson(Map<String, dynamic> json) {
    final reqEmp = json['requester_employee'] is Map<String, dynamic>
        ? ProfileModel.fromJson(json['requester_employee'] as Map<String, dynamic>)
        : null;
    final recEmp = json['receiver_employee'] is Map<String, dynamic>
        ? ProfileModel.fromJson(json['receiver_employee'] as Map<String, dynamic>)
        : null;

    // profile fallback: profile -> employee -> requester_employee
    final ProfileModel? profileVal = json['profile'] is Map<String, dynamic>
        ? ProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
        : (json['employee'] is Map<String, dynamic>
            ? ProfileModel.fromJson(json['employee'] as Map<String, dynamic>)
            : reqEmp);

    final bool hasProblemVal = (json['has_problem'] as bool?) == true;
    final bool isValidVal = (json['is_valid'] as bool?) != false; // null treated as valid
    final bool conflictBlocked = hasProblemVal || !isValidVal;

    final bool rawTakeAction =
        (json['can_take_action'] ?? json['take_action']) as bool? ?? false;
    final bool rawCanTakeActionAsSomeoneElse =
        (json['can_take_action_as_someone_else'] ?? json['take_action_as_someone_else'])
                as bool? ??
            false;
    final bool rawCanUpdateApproval =
        (json['can_update_approval'] ?? json['can_update'] ?? json['update_approval'])
                as bool? ??
            false;

    final int? levelVal = json['level'] is int
        ? json['level']
        : int.tryParse(json['level']?.toString() ?? '');

    return ApprovableDetailsModel(
      id: json['id'],
      approvableType: json['approvable_type'],
      status: json['status'],
      takeAction: conflictBlocked ? false : rawTakeAction,
      canTakeActionAsSomeoneElse:
          conflictBlocked ? false : rawCanTakeActionAsSomeoneElse,
      canUpdateApproval: conflictBlocked ? false : rawCanUpdateApproval,
      waitingCancel: json['waiting_cancel'] as bool?,
      hasOverlapping: json['has_overlapping'] as bool? ?? false,
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
      seenBy: (json['seen_by'] as List<dynamic>?)?.map((e) => SeenByModel.fromJson(e as Map<String, dynamic>)).toList(),
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      profile: profileVal,
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
      level: levelVal,
      notes: json['notes'],
      files: json['files'] as List<dynamic>?,
      employeeActions: json['employee_actions'] != null
          ? (json['employee_actions'] as List)
              .map((e) => EmployeeActionModel.fromJson(e))
              .toList()
          : null,
      requesterEmployee: reqEmp,
      receiverEmployee: recEmp,
      requesterEmployeeId: json['requester_employee_id'] is int
          ? json['requester_employee_id']
          : int.tryParse(json['requester_employee_id']?.toString() ?? ''),
      receiverEmployeeId: json['receiver_employee_id'] is int
          ? json['receiver_employee_id']
          : int.tryParse(json['receiver_employee_id']?.toString() ?? ''),
      requesterShiftId: json['requester_shift_id'] is int
          ? json['requester_shift_id']
          : int.tryParse(json['requester_shift_id']?.toString() ?? ''),
      receiverShiftId: json['receiver_shift_id'] is int
          ? json['receiver_shift_id']
          : int.tryParse(json['receiver_shift_id']?.toString() ?? ''),
      requesterShiftName: json['requester_shift_name']?.toString(),
      receiverShiftName: json['receiver_shift_name']?.toString(),
      requesterShiftAssignmentId: json['requester_shift_assignment_id'] is int
          ? json['requester_shift_assignment_id']
          : int.tryParse(json['requester_shift_assignment_id']?.toString() ?? ''),
      receiverShiftAssignmentId: json['receiver_shift_assignment_id'] is int
          ? json['receiver_shift_assignment_id']
          : int.tryParse(json['receiver_shift_assignment_id']?.toString() ?? ''),
      requesterDate: json['requester_date']?.toString() ?? json['date_from']?.toString(),
      receiverDate: json['receiver_date']?.toString() ?? json['date_to']?.toString(),
      isValid: json['is_valid'] as bool?,
      hasProblem: hasProblemVal,
      problemMessage: json['problem_message']?.toString(),
      problems: json['problems'] is List ? json['problems'] as List<dynamic> : null,
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

class OverlappingVacationModel {
  final int? id;
  final int? profileId;
  final String? employeeName;
  final String? employeeAvatar;
  final String? jobTitle;
  final int? departmentId;
  final String? departmentName;
  final int? typeId;
  final String? typeName;
  final String? dateFrom;
  final String? dateTo;
  final num? duration;
  final String? unit;
  final String? reason;
  final String? status;

  OverlappingVacationModel({
    this.id,
    this.profileId,
    this.employeeName,
    this.employeeAvatar,
    this.jobTitle,
    this.departmentId,
    this.departmentName,
    this.typeId,
    this.typeName,
    this.dateFrom,
    this.dateTo,
    this.duration,
    this.unit,
    this.reason,
    this.status,
  });

  factory OverlappingVacationModel.fromJson(Map<String, dynamic> json) {
    return OverlappingVacationModel(
      id: json['id'],
      profileId: json['profile_id'],
      employeeName: json['employee_name'],
      employeeAvatar: json['employee_avatar'],
      jobTitle: json['job_title'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      typeId: json['type_id'],
      typeName: json['type_name'],
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      duration: json['duration'] is num ? json['duration'] : num.tryParse(json['duration']?.toString() ?? ''),
      unit: json['unit'],
      reason: json['reason'],
      status: json['status'],
    );
  }
}


class SeenByModel {
  final int? id;
  final String? name;
  final String? date;
  final String? avatar;

  SeenByModel({this.id, this.name, this.date, this.avatar});

  factory SeenByModel.fromJson(Map<String, dynamic> json) {
    return SeenByModel(
      id: json['id'] as int?,
      name: json['manager_name'] ?? json['name'] as String?,
      date: json['date'] ?? json['seen_at'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}
