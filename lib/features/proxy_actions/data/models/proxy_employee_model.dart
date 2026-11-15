/// One employee the manager may act for (`GET /emp_requests/v1/manager/employees`).
/// [id] is the `employee_profile_id` the proxy endpoints expect.
class ProxyEmployeeModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final int? departmentId;
  final String? department;
  final String? jobTitle;
  final String? avatar;

  const ProxyEmployeeModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.departmentId,
    this.department,
    this.jobTitle,
    this.avatar,
  });

  /// The doc lists the keys; nested `{title}` / `{name}` maps are accepted too, in case the server
  /// returns the department or job title as an object.
  factory ProxyEmployeeModel.fromJson(Map<String, dynamic> json) {
    String? text(dynamic v) {
      if (v == null) return null;
      if (v is Map) return (v['title'] ?? v['name'])?.toString();
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    return ProxyEmployeeModel(
      id: int.tryParse('${json['id'] ?? json['employee_profile_id']}') ?? 0,
      name: text(json['name']) ?? '',
      email: text(json['email']),
      phone: text(json['phone']),
      departmentId: int.tryParse('${json['department_id']}'),
      department: text(json['department']),
      jobTitle: text(json['job_title']),
      avatar: text(json['avatar']),
    );
  }

  /// "Job title · Department", whatever is available.
  String get subtitle => [jobTitle, department].whereType<String>().where((e) => e.isNotEmpty).join(' · ');

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [name, email, phone, department, jobTitle]
        .whereType<String>()
        .any((v) => v.toLowerCase().contains(q));
  }
}
