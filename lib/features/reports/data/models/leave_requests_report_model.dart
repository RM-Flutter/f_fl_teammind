class LeaveRequestsReportModel {
  final String reportKey;
  final int total;
  final Map<String, int> byStatus;
  final int waitingCount;
  final int approvedCount;
  final int refusedCount;
  final List<LeaveRequestReportItem> requests;
  final LeaveRequestsReportModel? compare;

  LeaveRequestsReportModel({
    required this.reportKey,
    required this.total,
    required this.byStatus,
    required this.waitingCount,
    required this.approvedCount,
    required this.refusedCount,
    required this.requests,
    this.compare,
  });

  factory LeaveRequestsReportModel.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['summary'] as Map<String, dynamic>? ?? {};
    final byStatusRaw = summaryMap['by_status'] as Map<String, dynamic>? ?? {};
    
    final Map<String, int> parsedByStatus = {};
    byStatusRaw.forEach((key, value) {
      if (value is num) {
        parsedByStatus[key] = value.toInt();
      }
    });

    final requestsList = json['requests'] as List<dynamic>? ?? [];

    final waiting = parsedByStatus['waiting'] ?? parsedByStatus['pending'] ?? 0;
    final approved = parsedByStatus['approved'] ?? 0;
    final refused = parsedByStatus['refused'] ?? parsedByStatus['rejected'] ?? 0;

    return LeaveRequestsReportModel(
      reportKey: json['report_key'] ?? '',
      total: (summaryMap['total'] as num?)?.toInt() ?? (json['total'] as num?)?.toInt() ?? 0,
      byStatus: parsedByStatus,
      waitingCount: waiting,
      approvedCount: approved,
      refusedCount: refused,
      requests: requestsList
          .map((e) => LeaveRequestReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      compare: json['compare'] != null && json['compare'] is Map<String, dynamic>
          ? LeaveRequestsReportModel.fromJson(json['compare'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LeaveRequestReportItem {
  final int id;
  final String employeeName;
  final String departmentName;
  final String requestType;
  final String startDate;
  final String endDate;
  final String status;
  final String statusLabel;
  final String createdAt;

  LeaveRequestReportItem({
    required this.id,
    required this.employeeName,
    required this.departmentName,
    required this.requestType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
  });

  factory LeaveRequestReportItem.fromJson(Map<String, dynamic> json) {
    return LeaveRequestReportItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      employeeName: json['employee_name'] ?? '',
      departmentName: json['department_name'] ?? '',
      requestType: json['request_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
