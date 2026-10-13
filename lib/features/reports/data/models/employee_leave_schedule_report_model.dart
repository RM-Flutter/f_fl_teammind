class EmployeeLeaveScheduleReportModel {
  final String reportKey;
  final int total;
  final List<LeaveScheduleEventItem> events;
  final EmployeeLeaveScheduleReportModel? compare;

  EmployeeLeaveScheduleReportModel({
    required this.reportKey,
    required this.total,
    required this.events,
    this.compare,
  });

  factory EmployeeLeaveScheduleReportModel.fromJson(Map<String, dynamic> json) {
    final eventsList = json['events'] as List<dynamic>? ?? [];

    return EmployeeLeaveScheduleReportModel(
      reportKey: json['report_key'] ?? '',
      total: (json['total'] as num?)?.toInt() ?? eventsList.length,
      events: eventsList
          .map((e) => LeaveScheduleEventItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      compare: json['compare'] != null && json['compare'] is Map<String, dynamic>
          ? EmployeeLeaveScheduleReportModel.fromJson(json['compare'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LeaveScheduleEventItem {
  final int employeeId;
  final String employeeName;
  final String departmentName;
  final String leaveType;
  final String startDate;
  final String endDate;
  final num daysCount;
  final String status;
  final String statusColor;

  LeaveScheduleEventItem({
    required this.employeeId,
    required this.employeeName,
    required this.departmentName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.status,
    required this.statusColor,
  });

  factory LeaveScheduleEventItem.fromJson(Map<String, dynamic> json) {
    return LeaveScheduleEventItem(
      employeeId: (json['employee_id'] as num?)?.toInt() ?? 0,
      employeeName: json['employee_name'] ?? '',
      departmentName: json['department_name'] ?? '',
      leaveType: json['leave_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      daysCount: (json['days_count'] as num?) ?? 0,
      status: json['status'] ?? '',
      statusColor: json['status_color'] ?? '#6B7280',
    );
  }
}
