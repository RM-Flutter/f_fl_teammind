class ReportCatalogModel {
  final String key;
  final String package;
  final String name;
  final String viewType;
  final bool isSensitive;
  final String permission;
  final FiltersConfigModel filtersConfig;

  ReportCatalogModel({
    required this.key,
    required this.package,
    required this.name,
    required this.viewType,
    required this.isSensitive,
    required this.permission,
    required this.filtersConfig,
  });

  factory ReportCatalogModel.fromJson(Map<String, dynamic> json) {
    return ReportCatalogModel(
      key: json['key'] ?? '',
      package: json['package'] ?? '',
      name: json['name'] ?? '',
      viewType: json['view_type'] ?? '',
      isSensitive: json['is_sensitive'] ?? false,
      permission: json['permission'] ?? '',
      filtersConfig: FiltersConfigModel.fromJson(json['filters_config'] ?? {}),
    );
  }
}

class FiltersConfigModel {
  final bool showDepartments;
  final bool showEmployees;
  final bool showEmployeeStatus;
  final bool showTimePeriod;
  final bool showCompare;
  final bool showRequestTypes;
  final bool requestTypesRequired;
  final String defaultPeriodType;
  final String defaultTimeFrame;
  final bool lockTimePeriod;

  FiltersConfigModel({
    required this.showDepartments,
    required this.showEmployees,
    required this.showEmployeeStatus,
    required this.showTimePeriod,
    required this.showCompare,
    required this.showRequestTypes,
    required this.requestTypesRequired,
    required this.defaultPeriodType,
    required this.defaultTimeFrame,
    required this.lockTimePeriod,
  });

  factory FiltersConfigModel.fromJson(Map<String, dynamic> json) {
    return FiltersConfigModel(
      showDepartments: json['show_departments'] ?? false,
      showEmployees: json['show_employees'] ?? false,
      showEmployeeStatus: json['show_employee_status'] ?? false,
      showTimePeriod: json['show_time_period'] ?? false,
      showCompare: json['show_compare'] ?? false,
      showRequestTypes: json['show_request_types'] ?? false,
      requestTypesRequired: json['request_types_required'] ?? false,
      defaultPeriodType: json['default_period_type'] ?? '',
      defaultTimeFrame: json['default_time_frame'] ?? '',
      lockTimePeriod: json['lock_time_period'] ?? false,
    );
  }
}
