class ReportDataModel {
  final String reportKey;
  final ReportPeriod period;
  final ReportSummary summary;
  final List<ReportEmployeeData> employees;

  ReportDataModel({
    required this.reportKey,
    required this.period,
    required this.summary,
    required this.employees,
  });

  factory ReportDataModel.fromJson(Map<String, dynamic> json) {
    return ReportDataModel(
      reportKey: json['report_key'] ?? '',
      period: ReportPeriod.fromJson(json['period'] ?? {}),
      summary: ReportSummary.fromJson(json['summary'] ?? {}),
      employees: (json['employees'] as List<dynamic>?)
              ?.map((e) => ReportEmployeeData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ReportPeriod {
  final String from;
  final String to;

  ReportPeriod({required this.from, required this.to});

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class ReportSummary {
  final int totalEmployees;
  final int totalAttendanceDays;
  final int totalAbsenceDays;
  final int totalDelayMinutes;
  final String totalDelayReadable;
  final int totalOvertimeMinutes;
  final String totalOvertimeReadable;

  ReportSummary({
    required this.totalEmployees,
    required this.totalAttendanceDays,
    required this.totalAbsenceDays,
    required this.totalDelayMinutes,
    required this.totalDelayReadable,
    required this.totalOvertimeMinutes,
    required this.totalOvertimeReadable,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    String _clean(String s) => s.replaceAll('_choice', '').trim();
    return ReportSummary(
      totalEmployees: json['total_employees'] ?? 0,
      totalAttendanceDays: json['total_attendance_days'] ?? 0,
      totalAbsenceDays: json['total_absence_days'] ?? 0,
      totalDelayMinutes: json['total_delay_minutes'] ?? 0,
      totalDelayReadable: _clean(json['total_delay_readable'] ?? ''),
      totalOvertimeMinutes: json['total_overtime_minutes'] ?? 0,
      totalOvertimeReadable: _clean(json['total_overtime_readable'] ?? ''),
    );
  }
}

class ReportEmployeeData {
  final int employeeId;
  final String name;
  final String departmentName;
  final String avatar;
  final int attendanceCount;
  final int absenceCount;
  final int totalDelayMinutes;
  final int totalOvertimeMinutes;
  final String totalDelayReadable;
  final String totalOvertimeReadable;
  final List<ReportTimeline> timeline;

  ReportEmployeeData({
    required this.employeeId,
    required this.name,
    required this.departmentName,
    required this.avatar,
    required this.attendanceCount,
    required this.absenceCount,
    required this.totalDelayMinutes,
    required this.totalOvertimeMinutes,
    required this.totalDelayReadable,
    required this.totalOvertimeReadable,
    required this.timeline,
  });

  factory ReportEmployeeData.fromJson(Map<String, dynamic> json) {
    String _clean(String s) => s.replaceAll('_choice', '').trim();
    return ReportEmployeeData(
      employeeId: json['employee_id'] ?? 0,
      name: json['name'] ?? '',
      departmentName: json['department_name'] ?? '',
      avatar: json['avatar'] ?? '',
      attendanceCount: json['attendance_count'] ?? 0,
      absenceCount: json['absence_count'] ?? 0,
      totalDelayMinutes: json['total_delay_minutes'] ?? 0,
      totalOvertimeMinutes: json['total_overtime_minutes'] ?? 0,
      totalDelayReadable: _clean(json['total_delay_readable'] ?? ''),
      totalOvertimeReadable: _clean(json['total_overtime_readable'] ?? ''),
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => ReportTimeline.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ReportTimeline {
  final String date;
  final String type;
  final String statusLabel;
  final String? checkIn;
  final String? checkOut;
  final int delayMinutes;
  final int overtimeMinutes;
  final String delayReadable;
  final String overtimeReadable;

  ReportTimeline({
    required this.date,
    required this.type,
    required this.statusLabel,
    this.checkIn,
    this.checkOut,
    required this.delayMinutes,
    required this.overtimeMinutes,
    required this.delayReadable,
    required this.overtimeReadable,
  });

  factory ReportTimeline.fromJson(Map<String, dynamic> json) {
    String _clean(String s) => s.replaceAll('_choice', '').trim();
    return ReportTimeline(
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      statusLabel: _clean(json['status_label'] ?? ''),
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      delayMinutes: json['delay_minutes'] ?? 0,
      overtimeMinutes: json['overtime_minutes'] ?? 0,
      delayReadable: _clean(json['delay_readable'] ?? ''),
      overtimeReadable: _clean(json['overtime_readable'] ?? ''),
    );
  }
}
