/// One leave the manager created on an employee's behalf (`GET /emp_requests/v1/manager/requests`).
/// The doc does not spell out the item shape, so every field accepts the names the app's other
/// request endpoints use.
class ProxyRequestModel {
  final int id;
  final int? typeId;
  final String typeName;
  final String employeeName;
  final String? employeeAvatar;
  final String? department;
  final String dateFrom;
  final String dateTo;
  final String duration;
  final String reason;
  final String status;

  const ProxyRequestModel({
    required this.id,
    required this.typeId,
    required this.typeName,
    required this.employeeName,
    required this.employeeAvatar,
    required this.department,
    required this.dateFrom,
    required this.dateTo,
    required this.duration,
    required this.reason,
    required this.status,
  });

  factory ProxyRequestModel.fromJson(Map<String, dynamic> json) {
    String? text(dynamic v) {
      if (v == null) return null;
      if (v is Map) return (v['title'] ?? v['name'] ?? v['value'] ?? v['key'])?.toString();
      return v.toString();
    }

    final profile = json['profile'] is Map ? json['profile'] as Map : const {};
    final type = json['type'] is Map ? json['type'] as Map : const {};
    return ProxyRequestModel(
      id: int.tryParse('${json['id']}') ?? 0,
      typeId: int.tryParse('${json['emp_request_type_id'] ?? json['type_id'] ?? type['id']}'),
      typeName: text(json['type_name'] ?? json['type_title'] ?? type['title'] ?? json['type']) ?? '',
      employeeName: text(json['employee_name'] ?? profile['name'] ?? json['employee']) ?? '',
      employeeAvatar: text(profile['avatar'] ?? json['avatar']),
      department: text(json['department_name'] ?? json['department']),
      dateFrom: text(json['date_from'] ?? json['from']) ?? '',
      dateTo: text(json['date_to'] ?? json['to']) ?? '',
      duration: text(json['duration']) ?? '',
      reason: text(json['reason']) ?? '',
      status: text(json['status']) ?? '',
    );
  }

  /// The server only accepts an edit while nobody has acted on the request yet.
  bool get isEditable {
    final s = status.toLowerCase();
    return s == 'waiting' || s == 'waiting_seen';
  }
}
