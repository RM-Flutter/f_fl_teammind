class AnnualLeaveEntitlementReportModel {
  final String reportKey;
  final int totalEmployees;
  final num totalEntitlementDays;
  final num totalTakenDays;
  final num totalRemainingDays;
  final num overallUsageRate;
  final List<AnnualLeaveEmployeeItem> employees;
  final AnnualLeaveEntitlementReportModel? compare;

  AnnualLeaveEntitlementReportModel({
    required this.reportKey,
    required this.totalEmployees,
    required this.totalEntitlementDays,
    required this.totalTakenDays,
    required this.totalRemainingDays,
    required this.overallUsageRate,
    required this.employees,
    this.compare,
  });

  factory AnnualLeaveEntitlementReportModel.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['summary'] as Map<String, dynamic>? ?? {};
    final employeesList = json['employees'] as List<dynamic>? ?? [];

    return AnnualLeaveEntitlementReportModel(
      reportKey: json['report_key'] ?? '',
      totalEmployees: (summaryMap['total_employees'] as num?)?.toInt() ?? 0,
      totalEntitlementDays: (summaryMap['total_entitlement_days'] as num?) ?? 0,
      totalTakenDays: (summaryMap['total_taken_days'] as num?) ?? 0,
      totalRemainingDays: (summaryMap['total_remaining_days'] as num?) ?? 0,
      overallUsageRate: (summaryMap['overall_usage_rate'] as num?) ?? 0,
      employees: employeesList
          .map((e) => AnnualLeaveEmployeeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      compare: json['compare'] != null && json['compare'] is Map<String, dynamic>
          ? AnnualLeaveEntitlementReportModel.fromJson(json['compare'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AnnualLeaveEmployeeItem {
  final int employeeId;
  final String name;
  final String jobTitle;
  final String departmentName;
  final num entitlementDays;
  final num takenDays;
  final num remainingDays;
  final num usagePercentage;
  final String hireDate;
  final bool isQualified;
  final String notes;

  AnnualLeaveEmployeeItem({
    required this.employeeId,
    required this.name,
    required this.jobTitle,
    required this.departmentName,
    required this.entitlementDays,
    required this.takenDays,
    required this.remainingDays,
    required this.usagePercentage,
    required this.hireDate,
    required this.isQualified,
    required this.notes,
  });

  factory AnnualLeaveEmployeeItem.fromJson(Map<String, dynamic> json) {
    return AnnualLeaveEmployeeItem(
      employeeId: (json['employee_id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      jobTitle: json['job_title'] ?? '',
      departmentName: json['department_name'] ?? '',
      entitlementDays: (json['entitlement_days'] as num?) ?? 0,
      takenDays: (json['taken_days'] as num?) ?? 0,
      remainingDays: (json['remaining_days'] as num?) ?? 0,
      usagePercentage: (json['usage_percentage'] as num?) ?? 0,
      hireDate: json['hire_date'] ?? '',
      isQualified: json['is_qualified'] == true,
      notes: json['notes'] ?? '',
    );
  }
}
