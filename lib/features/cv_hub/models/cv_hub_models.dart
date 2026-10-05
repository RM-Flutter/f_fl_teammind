class InterviewModel {
  final int id;
  final String? interviewType;
  final String? location;
  final String? status;
  final String? scheduledAt;
  final CandidateModel? candidate;
  final EvaluationModel? myEvaluation;
  final String? createdAt;

  InterviewModel({
    required this.id,
    this.interviewType,
    this.location,
    this.status,
    this.scheduledAt,
    this.candidate,
    this.myEvaluation,
    this.createdAt,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    return InterviewModel(
      id: json['id'],
      interviewType: json['interview_type'],
      location: json['location'],
      status: json['status'],
      scheduledAt: json['scheduled_at'],
      candidate: json['candidate'] != null
          ? CandidateModel.fromJson(json['candidate'])
          : null,
      myEvaluation: json['my_evaluation'] != null
          ? EvaluationModel.fromJson(json['my_evaluation'])
          : null,
      createdAt: json['created_at'],
    );
  }
}

class CandidateModel {
  final int id;
  final String? fullName;
  final String? email;
  final String? phone;
  final JobModel? job;
  final num? expectedSalary;
  final num? yearsExperience;
  final String? educationLevel;
  final String? employmentType;
  final List<SkillModel>? skills;
  final List<AttachmentModel>? attachments;

  CandidateModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.job,
    this.expectedSalary,
    this.yearsExperience,
    this.educationLevel,
    this.employmentType,
    this.skills,
    this.attachments,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      job: json['job'] != null ? JobModel.fromJson(json['job']) : null,
      expectedSalary: json['expected_salary'],
      yearsExperience: json['years_experience'],
      educationLevel: json['education_level'],
      employmentType: json['employment_type'],
      skills: json['skills'] != null
          ? (json['skills'] as List).map((i) => SkillModel.fromJson(i)).toList()
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((i) => AttachmentModel.fromJson(i))
              .toList()
          : null,
    );
  }
}

class JobModel {
  final int id;
  final String? title;

  JobModel({required this.id, this.title});

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      title: json['title'],
    );
  }
}

class SkillModel {
  final int id;
  final String? name;

  SkillModel({required this.id, this.name});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AttachmentModel {
  final int id;
  final String? fileType;
  final String? fileUrl;

  AttachmentModel({required this.id, this.fileType, this.fileUrl});

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'],
      fileType: json['file_type'],
      fileUrl: json['file_url'],
    );
  }
}

class EvaluationModel {
  final int id;
  final int? interviewId;
  final num? technicalScore;
  final num? softSkillsScore;
  final num? overallScore;
  final String? recommendation;
  final String? notes;
  final bool? canEdit;
  final String? createdAt;

  EvaluationModel({
    required this.id,
    this.interviewId,
    this.technicalScore,
    this.softSkillsScore,
    this.overallScore,
    this.recommendation,
    this.notes,
    this.canEdit,
    this.createdAt,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: json['id'],
      interviewId: json['interview_id'],
      technicalScore: json['technical_score'],
      softSkillsScore: json['soft_skills_score'],
      overallScore: json['overall_score'],
      recommendation: json['recommendation'],
      notes: json['notes'],
      canEdit: json['can_edit'],
      createdAt: json['created_at'],
    );
  }
}
