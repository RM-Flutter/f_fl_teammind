class EmployeeActionModel {
  int? id;
  int? profileId;
  String? profileName;
  String? profileJobTitle;
  String? action;
  String? message;
  String? valueFrom;
  String? valueTo;
  String? createdAt;

  EmployeeActionModel({
    this.id,
    this.profileId,
    this.profileName,
    this.profileJobTitle,
    this.action,
    this.message,
    this.valueFrom,
    this.valueTo,
    this.createdAt,
  });

  EmployeeActionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profileId = json['profile_id'];
    profileName = json['profile_name'];
    profileJobTitle = json['profile_job_title'];
    action = json['action'];
    message = json['message'];
    valueFrom = json['value_from']?.toString();
    valueTo = json['value_to']?.toString();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['profile_id'] = profileId;
    data['profile_name'] = profileName;
    data['profile_job_title'] = profileJobTitle;
    data['action'] = action;
    data['message'] = message;
    data['value_from'] = valueFrom;
    data['value_to'] = valueTo;
    data['created_at'] = createdAt;
    return data;
  }
}
