import '../../../daily_reports/models/daily_report_model.dart';

class SalaryAdvanceRequestModel {
  int? id;
  String? total;
  String? howLongToPay;
  String? from;
  String? to;
  int? employeeId;
  int? hrId;
  int? managerId;
  bool? employeeApproved;
  bool? hrApproved;
  bool? managerApproved;
  ProfileModel? employeeProfile;
  ProfileModel? managerProfile;
  ProfileModel? hrProfile;
  List<ReportAttachmentModel>? attachments;
  String? status;
  String? createdAt;
  String? updatedAt;

  SalaryAdvanceRequestModel({
    this.id,
    this.total,
    this.howLongToPay,
    this.from,
    this.to,
    this.employeeId,
    this.hrId,
    this.managerId,
    this.employeeApproved,
    this.hrApproved,
    this.managerApproved,
    this.employeeProfile,
    this.managerProfile,
    this.hrProfile,
    this.attachments,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  SalaryAdvanceRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    total = json['total']?.toString();
    howLongToPay = json['how_long_to_pay']?.toString();
    from = json['from'];
    to = json['to'];
    employeeId = json['employee_id'];
    hrId = json['hr_id'];
    managerId = json['manager_id'];
    employeeApproved = json['employeeApproved'];
    hrApproved = json['hrApproved'];
    managerApproved = json['managerApproved'];
    employeeProfile = json['employee_profile'] != null
        ? ProfileModel.fromJson(json['employee_profile'])
        : null;
    managerProfile = json['manager_profile'] != null
        ? ProfileModel.fromJson(json['manager_profile'])
        : null;
    hrProfile = json['hr_profile'] != null
        ? ProfileModel.fromJson(json['hr_profile'])
        : null;
    attachments = json['attachments'] != null
        ? (json['attachments'] as List)
            .map((e) => ReportAttachmentModel.fromJson(e))
            .toList()
        : null;
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['total'] = total;
    data['how_long_to_pay'] = howLongToPay;
    data['from'] = from;
    data['to'] = to;
    data['employee_id'] = employeeId;
    data['hr_id'] = hrId;
    data['manager_id'] = managerId;
    data['employeeApproved'] = employeeApproved;
    data['hrApproved'] = hrApproved;
    data['managerApproved'] = managerApproved;
    if (employeeProfile != null) {
      data['employee_profile'] = employeeProfile!.toJson();
    }
    if (managerProfile != null) {
      data['manager_profile'] = managerProfile!.toJson();
    }
    if (hrProfile != null) {
      data['hr_profile'] = hrProfile!.toJson();
    }
    data['attachments'] = attachments?.map((e) => e.toJson()).toList();
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ProfileModel {
  int? id;
  String? name;

  ProfileModel({this.id, this.name});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
