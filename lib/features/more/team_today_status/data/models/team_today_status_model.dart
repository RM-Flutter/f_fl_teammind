class TeamTodayStatusModel {
  final String? date;
  final TeamStatusSummary? summary;
  final List<TeamMemberStatus> members;

  const TeamTodayStatusModel({
    this.date,
    this.summary,
    this.members = const [],
  });

  factory TeamTodayStatusModel.fromJson(Map<String, dynamic> json) {
    return TeamTodayStatusModel(
      date: json['date'] as String?,
      summary: json['summary'] != null
          ? TeamStatusSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => TeamMemberStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TeamStatusSummary {
  final int total;
  final int present;
  final int absent;
  final int vacation;
  final int weekend;

  const TeamStatusSummary({
    this.total = 0,
    this.present = 0,
    this.absent = 0,
    this.vacation = 0,
    this.weekend = 0,
  });

  factory TeamStatusSummary.fromJson(Map<String, dynamic> json) {
    return TeamStatusSummary(
      total: (json['total'] as num?)?.toInt() ?? 0,
      present: (json['present'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
      vacation: (json['vacation'] as num?)?.toInt() ?? 0,
      weekend: (json['weekend'] as num?)?.toInt() ?? 0,
    );
  }
}

class TeamMemberStatus {
  final int? id;
  final int? userId;
  final String? name;
  final String? avatar;
  final String? jobTitle;
  final int? departmentId;
  final String? department;
  final dynamic phone;
  final String? email;
  final String? status;       // e.g. "present", "absent", "clocked_out", "vacation", "weekend"
  final String? statusLabel;  // e.g. "Present", "Absent", "Clocked Out"
  final String? clockInTime;
  final String? clockOutTime;
  final String? vacationTitle;

  const TeamMemberStatus({
    this.id,
    this.userId,
    this.name,
    this.avatar,
    this.jobTitle,
    this.departmentId,
    this.department,
    this.phone,
    this.email,
    this.status,
    this.statusLabel,
    this.clockInTime,
    this.clockOutTime,
    this.vacationTitle,
  });

  factory TeamMemberStatus.fromJson(Map<String, dynamic> json) {
    return TeamMemberStatus(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      jobTitle: json['job_title'] as String?,
      departmentId: (json['department_id'] as num?)?.toInt(),
      department: json['department'] as String?,
      phone: json['phone'],
      email: json['email'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      clockInTime: json['clock_in_time'] as String?,
      clockOutTime: json['clock_out_time'] as String?,
      vacationTitle: json['vacation_title'] as String?,
    );
  }
}
