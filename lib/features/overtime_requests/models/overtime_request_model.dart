import '../../../core/models/employee_action_model.dart';

class OvertimeRequestModel {
  int? id;
  int? employeeProfileId;
  String? date;
  String? status;
  String? rejectReason;
  int? overtime;
  List<ManagerReply>? theManagerReply;
  List<EmployeeActionModel>? employeeActions;
  EmployeeProfile? employeeProfile;
  String? employeeName; // Fallback field
  String? createdAt;
  String? updatedAt;

  OvertimeRequestModel({
    this.id,
    this.employeeProfileId,
    this.date,
    this.status,
    this.rejectReason,
    this.overtime,
    this.theManagerReply,
    this.employeeActions,
    this.employeeProfile,
    this.employeeName,
    this.createdAt,
    this.updatedAt,
  });

  OvertimeRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeProfileId = json['employee_profile_id'];
    date = json['date'];
    status = json['status'];
    rejectReason = json['reject_reason'];
    if (json['overtime'] != null) {
      overtime = int.tryParse(json['overtime'].toString());
    }
    if (json['the_manager_reply'] != null) {
      theManagerReply = <ManagerReply>[];
      json['the_manager_reply'].forEach((v) {
        theManagerReply!.add(ManagerReply.fromJson(v));
      });
    }
    if (json['employee_actions'] != null) {
      employeeActions = <EmployeeActionModel>[];
      json['employee_actions'].forEach((v) {
        employeeActions!.add(EmployeeActionModel.fromJson(v));
      });
    }
    employeeProfile = json['employee_profile'] != null
        ? EmployeeProfile.fromJson(json['employee_profile'])
        : null;
    employeeName = json['employee_name'] ?? employeeProfile?.name;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_profile_id'] = employeeProfileId;
    data['date'] = date;
    data['status'] = status;
    data['reject_reason'] = rejectReason;
    data['overtime'] = overtime;
    data['employee_name'] = employeeName;
    if (theManagerReply != null) {
      data['the_manager_reply'] =
          theManagerReply!.map((v) => v.toJson()).toList();
    }
    if (employeeActions != null) {
      data['employee_actions'] =
          employeeActions!.map((v) => v.toJson()).toList();
    }
    if (employeeProfile != null) {
      data['employee_profile'] = employeeProfile!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ManagerReply {
  int? managerId;
  String? managerName;
  String? managerJobTitle;
  String? managerPhoto;
  String? replay;
  String? createdAt;

  ManagerReply({
    this.managerId,
    this.managerName,
    this.managerJobTitle,
    this.managerPhoto,
    this.replay,
    this.createdAt,
  });

  ManagerReply.fromJson(Map<String, dynamic> json) {
    managerId = json['manager_id'];
    managerName = json['manager_name'];
    managerJobTitle = json['manager_job_title'];
    managerPhoto = json['manager_photo'];
    replay = json['replay'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['manager_id'] = managerId;
    data['manager_name'] = managerName;
    data['manager_job_title'] = managerJobTitle;
    data['manager_photo'] = managerPhoto;
    data['replay'] = replay;
    data['created_at'] = createdAt;
    return data;
  }
}

class EmployeeProfile {
  int? id;
  String? name;
  String? department;

  EmployeeProfile({this.id, this.name, this.department});

  EmployeeProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    department = json['department'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['department'] = department;
    return data;
  }
}
