import '../../../../core/models/employee_action_model.dart';

class ExpenseClaimModel {
  int? id;
  String? reason;
  String? moneyValue;
  String? dateFrom;
  String? dateTo;
  String? category;
  String? categoryName;
  String? notes;
  List<ExpenseClaimFileModel>? files;
  String? status;
  int? level;
  int? employeeId;
  String? employeeName;
  int? departmentId;
  String? departmentName;
  String? createdAt;
  String? updatedAt;
  bool? takeAction;
  bool? canTakeActionAsSomeoneElse;
  List<EmployeeActionModel>? employeeActions;

  ExpenseClaimModel({
    this.id,
    this.reason,
    this.moneyValue,
    this.dateFrom,
    this.dateTo,
    this.category,
    this.categoryName,
    this.notes,
    this.files,
    this.status,
    this.level,
    this.employeeId,
    this.employeeName,
    this.departmentId,
    this.departmentName,
    this.createdAt,
    this.updatedAt,
    this.takeAction,
    this.canTakeActionAsSomeoneElse,
    this.employeeActions,
  });

  ExpenseClaimModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reason = json['reason'];
    moneyValue = json['money_value']?.toString();
    dateFrom = json['date_from'];
    dateTo = json['date_to'];
    category = json['category'];
    categoryName = json['category_name'];
    notes = json['notes'];
    files = json['files'] != null
        ? (json['files'] as List)
            .map((e) => ExpenseClaimFileModel.fromJson(e))
            .toList()
        : null;
    status = json['status'];
    level = json['level'];
    employeeId = json['employee_id'];
    employeeName = json['employee_name'];
    departmentId = json['department_id'];
    departmentName = json['department_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    takeAction = (json['can_take_action'] ?? json['take_action']) as bool?;
    canTakeActionAsSomeoneElse =
        (json['can_take_action_as_someone_else'] ?? json['take_action_as_someone_else']) as bool?;
    employeeActions = json['employee_actions'] != null
        ? (json['employee_actions'] as List)
            .map((e) => EmployeeActionModel.fromJson(e))
            .toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason'] = reason;
    data['money_value'] = moneyValue;
    data['date_from'] = dateFrom;
    data['date_to'] = dateTo;
    data['category'] = category;
    data['category_name'] = categoryName;
    data['notes'] = notes;
    data['files'] = files?.map((e) => e.toJson()).toList();
    data['status'] = status;
    data['level'] = level;
    data['employee_id'] = employeeId;
    data['employee_name'] = employeeName;
    data['department_id'] = departmentId;
    data['department_name'] = departmentName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  /// Factory for the unified Approvals API list response.
  /// Maps `approvables[]` items → ExpenseClaimModel.
  factory ExpenseClaimModel.fromApprovableJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    return ExpenseClaimModel(
      id: json['id'],
      status: json['status'],
      takeAction: json['can_take_action'] as bool?,
      canTakeActionAsSomeoneElse:
          (json['can_take_action_as_someone_else'] ?? json['take_action_as_someone_else']) as bool?,
      reason: json['reason'],
      moneyValue: json['money_value']?.toString(),
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      category: json['category'],
      categoryName: json['category_name'],
      notes: json['notes'],
      employeeId: profile['id'] ?? json['employee_id'],
      employeeName: profile['name'] ?? json['employee_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      employeeActions: json['employee_actions'] != null
          ? (json['employee_actions'] as List)
              .map((e) => EmployeeActionModel.fromJson(e))
              .toList()
          : null,
      files: null,
    );
  }
}

class ExpenseClaimFileModel {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;

  ExpenseClaimFileModel({
    this.id,
    this.type,
    this.title,
    this.alt,
    this.file,
    this.thumbnail,
  });

  ExpenseClaimFileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    alt = json['alt'];
    file = json['file'];
    thumbnail = json['thumbnail'] ?? json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['alt'] = alt;
    data['file'] = file;
    data['thumbnail'] = thumbnail;
    return data;
  }

  bool get isImage {
    final ext = (type ?? '').toLowerCase();
    return ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'webp' || ext == 'gif';
  }

  String? get url => file;
  String? get fileName => title;
  String? get fileType => type;
}
