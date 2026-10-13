class RequestsSummaryReportModel {
  final String reportKey;
  final int totalCount;
  final int approved;
  final int pending;
  final int rejected;
  final List<RequestTypeBreakdownItem> typeBreakdown;
  final RequestsSummaryReportModel? compare;

  RequestsSummaryReportModel({
    required this.reportKey,
    required this.totalCount,
    required this.approved,
    required this.pending,
    required this.rejected,
    required this.typeBreakdown,
    this.compare,
  });

  factory RequestsSummaryReportModel.fromJson(Map<String, dynamic> json) {
    final statusMap = json['status_breakdown'] as Map<String, dynamic>? ?? {};
    final typesList = json['type_breakdown'] as List<dynamic>? ?? [];

    return RequestsSummaryReportModel(
      reportKey: json['report_key'] ?? '',
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      approved: (statusMap['approved'] as num?)?.toInt() ?? 0,
      pending: (statusMap['pending'] as num?)?.toInt() ?? (statusMap['waiting'] as num?)?.toInt() ?? 0,
      rejected: (statusMap['rejected'] as num?)?.toInt() ?? (statusMap['refused'] as num?)?.toInt() ?? 0,
      typeBreakdown: typesList
          .map((e) => RequestTypeBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      compare: json['compare'] != null && json['compare'] is Map<String, dynamic>
          ? RequestsSummaryReportModel.fromJson(json['compare'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RequestTypeBreakdownItem {
  final String typeName;
  final int count;
  final num percentage;

  RequestTypeBreakdownItem({
    required this.typeName,
    required this.count,
    required this.percentage,
  });

  factory RequestTypeBreakdownItem.fromJson(Map<String, dynamic> json) {
    return RequestTypeBreakdownItem(
      typeName: json['type_name'] ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?) ?? 0,
    );
  }
}
