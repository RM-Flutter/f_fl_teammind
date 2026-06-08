import 'dart:convert';
class DailyReportModel {
  int? id;
  int? employeeId;
  String? date;
  String? done;
  String? inProgress;
  String? problems;
  List<ReportAttachmentModel>? attachments;
  ReportEmployeeProfile? employeeProfile;
  DateTime? createdAt;
  DateTime? updatedAt;

  DailyReportModel({
    this.id,
    this.employeeId,
    this.date,
    this.done,
    this.inProgress,
    this.problems,
    this.attachments,
    this.employeeProfile,
    this.createdAt,
    this.updatedAt,
  });

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    return DailyReportModel(
      id: json['id'],
      employeeId: json['employee_id'],
      date: json['date']?.toString(),
      done: json['done'],
      inProgress: json['inProgress'],
      problems: json['problems'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((e) => ReportAttachmentModel.fromJson(e))
              .toList()
          : null,
      employeeProfile: json['employee_profile'] != null
          ? ReportEmployeeProfile.fromJson(json['employee_profile'])
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'date': date,
      'done': done,
      'inProgress': inProgress,
      'problems': problems,
      'attachments': attachments?.map((e) => e.toJson()).toList(),
      'employee_profile': employeeProfile?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ReportAttachmentModel {
  int? id;
  String? fileType;
  String? fileName;
  String? url;
  double? size;
  String? title;
  Map<String, dynamic>? imageList;

  ReportAttachmentModel({
    this.id,
    this.fileType,
    this.fileName,
    this.url,
    this.size,
    this.title,
    this.imageList,
  });

  factory ReportAttachmentModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? decodedImageList;
    // Support both salary-advance format (thumbnail/href direct) and daily-report format (image_list JSON)
    if (json['thumbnail'] != null) {
      // Salary advance format: thumbnail and href at top level
      decodedImageList = {
        'thumbnail': json['thumbnail'].toString(),
        'original': (json['href'] ?? json['url'] ?? json['thumbnail']).toString(),
      };
    } else if (json['image_list'] != null && json['image_list'] is String) {
      try {
        decodedImageList = jsonDecode(json['image_list']);
      } catch (e) {
        decodedImageList = null;
      }
    }
    return ReportAttachmentModel(
      id: json['id'],
      fileType: json['file_type'] ?? _guessFileType(json['thumbnail']?.toString() ?? json['file_name']?.toString() ?? ''),
      fileName: json['file_name'],
      url: json['url'],
      size: json['size'] != null ? double.tryParse(json['size'].toString()) : null,
      title: json['title'],
      imageList: decodedImageList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_type': fileType,
      'file_name': fileName,
      'url': url,
      'size': size,
      'title': title,
      'image_list': imageList,
    };
  }

  static String _guessFileType(String path) {
    final ext = path.split('.').last.toLowerCase().split('?').first;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return ext;
    return 'file';
  }
}

class ReportEmployeeProfile {
  int? id;
  String? name;
  String? department;
  String? jobTitle;

  ReportEmployeeProfile({
    this.id,
    this.name,
    this.department,
    this.jobTitle,
  });

  factory ReportEmployeeProfile.fromJson(Map<String, dynamic> json) {
    return ReportEmployeeProfile(
      id: json['id'],
      name: json['name'],
      department: json['department'],
      jobTitle: json['job_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'job_title': jobTitle,
    };
  }
}
