import '../../../core/models/employee_action_model.dart';
import '../../approvables_details/data/models/approvable_details_model.dart';

class ShiftDefinitionModel {
  final int? id;
  final String? name;
  final String? startTime;
  final String? endTime;
  final num? breakDuration;
  final String? breakDurationStartTime;
  final String? breakDurationEndTime;
  final bool? isOvernight;
  final int? departmentId;
  final int? branchId;

  ShiftDefinitionModel({
    this.id,
    this.name,
    this.startTime,
    this.endTime,
    this.breakDuration,
    this.breakDurationStartTime,
    this.breakDurationEndTime,
    this.isOvernight,
    this.departmentId,
    this.branchId,
  });

  factory ShiftDefinitionModel.fromJson(Map<String, dynamic> json) {
    return ShiftDefinitionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      breakDuration: json['break_duration'] is num
          ? json['break_duration']
          : num.tryParse(json['break_duration']?.toString() ?? ''),
      breakDurationStartTime: json['break_duration_start_time']?.toString(),
      breakDurationEndTime: json['break_duration_end_time']?.toString(),
      isOvernight: json['is_overnight'] as bool?,
      departmentId: json['department_id'] is int
          ? json['department_id']
          : int.tryParse(json['department_id']?.toString() ?? ''),
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id']?.toString() ?? ''),
    );
  }
}

class ShiftAssignmentModel {
  final int? id;
  final int? employeeId;
  final int? shiftId;
  final String? shiftName;
  final String? date;
  final String? status;
  final num? financialModifier;
  final String? startTime;
  final String? endTime;
  final String? breakDurationStartTime;
  final String? breakDurationEndTime;
  final num? breakDuration;
  final String? notes;

  ShiftAssignmentModel({
    this.id,
    this.employeeId,
    this.shiftId,
    this.shiftName,
    this.date,
    this.status,
    this.financialModifier,
    this.startTime,
    this.endTime,
    this.breakDurationStartTime,
    this.breakDurationEndTime,
    this.breakDuration,
    this.notes,
  });

  factory ShiftAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ShiftAssignmentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      employeeId: json['employee_id'] is int
          ? json['employee_id']
          : int.tryParse(json['employee_id']?.toString() ?? ''),
      shiftId: json['shift_id'] is int
          ? json['shift_id']
          : int.tryParse(json['shift_id']?.toString() ?? ''),
      shiftName: json['shift_name']?.toString() ?? json['shift']?['name']?.toString(),
      date: json['date']?.toString(),
      status: json['status']?.toString(),
      financialModifier: json['financial_modifier'] is num
          ? json['financial_modifier']
          : num.tryParse(json['financial_modifier']?.toString() ?? ''),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      breakDurationStartTime: json['break_duration_start_time']?.toString(),
      breakDurationEndTime: json['break_duration_end_time']?.toString(),
      breakDuration: json['break_duration'] is num
          ? json['break_duration']
          : num.tryParse(json['break_duration']?.toString() ?? ''),
      notes: json['notes']?.toString(),
    );
  }

  String get formattedDateOnly {
    if (date == null || date!.isEmpty) return '';
    return date!.split(' ').first.split('T').first;
  }

  String get formattedStartTimeOnly {
    if (startTime == null || startTime!.isEmpty) return '';
    final parts = startTime!.split(' ');
    final timeStr = parts.length > 1 ? parts[1] : parts[0];
    return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
  }

  String get formattedEndTimeOnly {
    if (endTime == null || endTime!.isEmpty) return '';
    final parts = endTime!.split(' ');
    final timeStr = parts.length > 1 ? parts[1] : parts[0];
    return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
  }
}

class SchedulerEmployeeModel {
  final int? employeeId;
  final String? name;
  final bool isMe;
  final List<ShiftAssignmentModel> assignments;

  SchedulerEmployeeModel({
    this.employeeId,
    this.name,
    this.isMe = false,
    this.assignments = const [],
  });

  factory SchedulerEmployeeModel.fromJson(Map<String, dynamic> json) {
    return SchedulerEmployeeModel(
      employeeId: json['employee_id'] is int
          ? json['employee_id']
          : int.tryParse(json['employee_id']?.toString() ?? ''),
      name: json['name']?.toString(),
      isMe: json['is_me'] == true,
      assignments: json['assignments'] != null && json['assignments'] is List
          ? (json['assignments'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ShiftAssignmentModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

class ShiftChangeRequestModel {
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
  final String? closedAt;
  final DepartmentModel? department;
  final ProfileModel? profile;
  final ProfileModel? requesterEmployee;
  final ProfileModel? receiverEmployee;
  final int? requesterEmployeeId;
  final String? requesterEmployeeName;
  final int? receiverEmployeeId;
  final String? receiverEmployeeName;
  final int? requesterShiftId;
  final int? receiverShiftId;
  final String? requesterShiftName;
  final String? receiverShiftName;
  final int? requesterShiftAssignmentId;
  final int? receiverShiftAssignmentId;
  final String? requesterDate;
  final String? receiverDate;
  final String? dateFrom;
  final String? dateTo;
  final num? duration;
  final String? unit;
  final String? reason;
  final int? level;
  final bool? isValid;
  final bool? hasProblem;
  final String? problemMessage;
  final List<dynamic>? problems;
  final List<EmployeeActionModel>? employeeActions;

  String? get employeeName =>
      requesterEmployee?.name ?? requesterEmployeeName ?? profile?.name;

  String? get departmentName => department?.title;

  bool get isTwoWaySwap => receiverShiftAssignmentId != null;

  ShiftChangeRequestModel({
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
    this.closedAt,
    this.department,
    this.profile,
    this.requesterEmployee,
    this.receiverEmployee,
    this.requesterEmployeeId,
    this.requesterEmployeeName,
    this.receiverEmployeeId,
    this.receiverEmployeeName,
    this.requesterShiftId,
    this.receiverShiftId,
    this.requesterShiftName,
    this.receiverShiftName,
    this.requesterShiftAssignmentId,
    this.receiverShiftAssignmentId,
    this.requesterDate,
    this.receiverDate,
    this.dateFrom,
    this.dateTo,
    this.duration,
    this.unit,
    this.reason,
    this.level,
    this.isValid,
    this.hasProblem,
    this.problemMessage,
    this.problems,
    this.employeeActions,
  });

  factory ShiftChangeRequestModel.fromApprovableJson(Map<String, dynamic> json) {
    final reqEmp = json['requester_employee'] is Map<String, dynamic>
        ? ProfileModel.fromJson(json['requester_employee'])
        : null;
    final recEmp = json['receiver_employee'] is Map<String, dynamic>
        ? ProfileModel.fromJson(json['receiver_employee'])
        : null;
    final prof = json['profile'] is Map<String, dynamic>
        ? ProfileModel.fromJson(json['profile'])
        : null;

    return ShiftChangeRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      approvableType: json['approvable_type']?.toString() ?? 'shift_change_requests',
      status: json['status']?.toString(),
      takeAction: (json['can_take_action'] ?? json['take_action']) as bool? ?? false,
      canTakeActionAsSomeoneElse:
          (json['can_take_action_as_someone_else'] ?? json['take_action_as_someone_else'])
                  as bool? ??
              false,
      canUpdateApproval:
          (json['can_update_approval'] ?? json['can_update']) as bool? ?? false,
      waitingCancel: json['waiting_cancel'] as bool?,
      hasOverlapping: json['has_overlapping'] as bool? ?? false,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      closedAt: json['closed_at']?.toString(),
      department: json['department'] is Map<String, dynamic>
          ? DepartmentModel.fromJson(json['department'])
          : (json['department_name'] != null
              ? DepartmentModel(
                  id: json['department_id'],
                  title: json['department_name']?.toString(),
                )
              : null),
      profile: prof,
      requesterEmployee: reqEmp,
      receiverEmployee: recEmp,
      requesterEmployeeId: json['requester_employee_id'] is int
          ? json['requester_employee_id']
          : int.tryParse(json['requester_employee_id']?.toString() ?? ''),
      requesterEmployeeName:
          json['requester_employee_name']?.toString() ?? reqEmp?.name ?? prof?.name,
      receiverEmployeeId: json['receiver_employee_id'] is int
          ? json['receiver_employee_id']
          : int.tryParse(json['receiver_employee_id']?.toString() ?? ''),
      receiverEmployeeName:
          json['receiver_employee_name']?.toString() ?? recEmp?.name,
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
      dateFrom: json['date_from']?.toString() ?? json['requester_date']?.toString(),
      dateTo: json['date_to']?.toString() ?? json['receiver_date']?.toString(),
      duration: json['duration'] is num
          ? json['duration']
          : num.tryParse(json['duration']?.toString() ?? ''),
      unit: json['unit']?.toString(),
      reason: json['reason']?.toString(),
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? ''),
      isValid: json['is_valid'] as bool?,
      hasProblem: json['has_problem'] as bool?,
      problemMessage: json['problem_message']?.toString(),
      problems: json['problems'] is List ? json['problems'] as List<dynamic> : null,
      employeeActions: json['employee_actions'] != null && json['employee_actions'] is List
          ? (json['employee_actions'] as List)
              .map((e) => EmployeeActionModel.fromJson(e))
              .toList()
          : null,
    );
  }
}
