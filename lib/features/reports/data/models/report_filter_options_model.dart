class ReportFilterOptionsModel {
  final List<DepartmentOption> departments;
  final List<EmployeeOption> employees;
  final List<RequestTypeOption> requestTypes;
  final List<TimeFrameOption> timeFrames;
  /// user_scope from API: "all" | "department" | "individual"
  final String userScope;
  /// user_role from API: e.g. "top_hr" | "manager" | "employee"
  final String userRole;

  ReportFilterOptionsModel({
    required this.departments,
    required this.employees,
    required this.requestTypes,
    required this.timeFrames,
    this.userScope = 'all',
    this.userRole = '',
  });

  factory ReportFilterOptionsModel.fromJson(Map<String, dynamic> json) {
    return ReportFilterOptionsModel(
      departments: (json['departments'] as List<dynamic>?)
              ?.map((e) => DepartmentOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      employees: (json['employees'] as List<dynamic>?)
              ?.map((e) => EmployeeOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requestTypes: (json['request_types'] as List<dynamic>?)
              ?.map((e) => RequestTypeOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timeFrames: (json['time_frames'] as List<dynamic>?)
              ?.map((e) => TimeFrameOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      userScope: json['user_scope']?.toString() ?? 'all',
      userRole: json['user_role']?.toString() ?? '',
    );
  }
}

class DepartmentOption {
  final int id;
  final String title;

  DepartmentOption({required this.id, required this.title});

  factory DepartmentOption.fromJson(Map<String, dynamic> json) {
    return DepartmentOption(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}

class EmployeeOption {
  final int id;
  final String name;
  final int departmentId;
  final String departmentName;
  final String status;

  EmployeeOption({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.departmentName,
    required this.status,
  });

  factory EmployeeOption.fromJson(Map<String, dynamic> json) {
    return EmployeeOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      departmentId: json['department_id'] ?? 0,
      departmentName: json['department_name'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class RequestTypeOption {
  final int id;
  final String title;

  RequestTypeOption({required this.id, required this.title});

  factory RequestTypeOption.fromJson(Map<String, dynamic> json) {
    return RequestTypeOption(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}

class TimeFrameOption {
  final String key;
  final String label;

  TimeFrameOption({required this.key, required this.label});

  factory TimeFrameOption.fromJson(Map<String, dynamic> json) {
    return TimeFrameOption(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
    );
  }
}
