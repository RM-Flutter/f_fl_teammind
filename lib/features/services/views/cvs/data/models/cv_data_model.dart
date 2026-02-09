/// Model for CV Personal Data
class CVPersonalData {
  final String? name;
  final String? familyStatus;
  final String? birthday;
  final String? gender;
  final String? nationality;
  final String? country;
  final String? governorateState;
  final String? city;
  final String? address;

  CVPersonalData({
    this.name,
    this.familyStatus,
    this.birthday,
    this.gender,
    this.nationality,
    this.country,
    this.governorateState,
    this.city,
    this.address,
  });

  factory CVPersonalData.fromJson(Map<String, dynamic> json) {
    return CVPersonalData(
      name: json['name'] as String?,
      familyStatus: json['family_status'] as String?,
      birthday: json['birthday'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      country: json['country'] as String?,
      governorateState: json['governorate_state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'family_status': familyStatus,
      'birthday': birthday,
      'gender': gender,
      'nationality': nationality,
      'country': country,
      'governorate_state': governorateState,
      'city': city,
      'address': address,
    };
  }
}

/// Model for CV Contact Data
class CVContactData {
  final String? phone;
  final List<String>? morePhones;
  final String? email;
  final Map<String, String>? socialMediaLinks;
  final String? whatsapp;

  CVContactData({
    this.phone,
    this.morePhones,
    this.email,
    this.socialMediaLinks,
    this.whatsapp,
  });

  factory CVContactData.fromJson(Map<String, dynamic> json) {
    return CVContactData(
      phone: json['phone'] as String?,
      morePhones: (json['more_phones'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      email: json['email'] as String?,
      socialMediaLinks: json['social_media_links'] != null
          ? Map<String, String>.from(json['social_media_links'])
          : null,
      whatsapp: json['whatsapp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'more_phones': morePhones,
      'email': email,
      'social_media_links': socialMediaLinks,
      'whatsapp': whatsapp,
    };
  }
}

/// Model for CV Experience
class CVExperience {
  final String? companyName;
  final String? country;
  final String? governorateState;
  final String? dateFrom;
  final String? dateTo;
  final String? jobTitle;

  CVExperience({
    this.companyName,
    this.country,
    this.governorateState,
    this.dateFrom,
    this.dateTo,
    this.jobTitle,
  });

  factory CVExperience.fromJson(Map<String, dynamic> json) {
    return CVExperience(
      companyName: json['company_name'] as String?,
      country: json['country'] as String?,
      governorateState: json['governorate_state'] as String?,
      dateFrom: json['date_from'] as String?,
      dateTo: json['date_to'] as String?,
      jobTitle: json['job_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'country': country,
      'governorate_state': governorateState,
      'date_from': dateFrom,
      'date_to': dateTo,
      'job_title': jobTitle,
    };
  }
}

/// Model for CV Portfolio
class CVPortfolio {
  final String? projectName;
  final String? description;
  final String? link;

  CVPortfolio({
    this.projectName,
    this.description,
    this.link,
  });

  factory CVPortfolio.fromJson(Map<String, dynamic> json) {
    return CVPortfolio(
      projectName: json['project_name'] as String?,
      description: json['description'] as String?,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_name': projectName,
      'description': description,
      'link': link,
    };
  }
}

/// Model for CV Job Info Data
class CVJobInfoData {
  final String? currentJobTitle;
  final String? jobType;
  final String? aboutMe;
  final String? description;
  final List<String>? skills;
  final List<String>? moreSkills;
  final List<CVExperience>? experiences;
  final List<CVPortfolio>? portfolios;

  CVJobInfoData({
    this.currentJobTitle,
    this.jobType,
    this.aboutMe,
    this.description,
    this.skills,
    this.moreSkills,
    this.experiences,
    this.portfolios,
  });

  factory CVJobInfoData.fromJson(Map<String, dynamic> json) {
    return CVJobInfoData(
      currentJobTitle: json['current_job_title'] as String?,
      jobType: json['job_type'] as String?,
      aboutMe: json['about_me'] as String?,
      description: json['description'] as String?,
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      moreSkills: (json['more_skills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      experiences: (json['experiences'] as List<dynamic>?)
          ?.map((e) => CVExperience.fromJson(e as Map<String, dynamic>))
          .toList(),
      portfolios: (json['portfolios'] as List<dynamic>?)
          ?.map((e) => CVPortfolio.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_job_title': currentJobTitle,
      'job_type': jobType,
      'about_me': aboutMe,
      'description': description,
      'skills': skills,
      'more_skills': moreSkills,
      'experiences': experiences?.map((e) => e.toJson()).toList(),
      'portfolios': portfolios?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model for CV Education
class CVEducation {
  final String? universityName;
  final String? country;
  final String? governorateState;
  final String? dateFrom;
  final String? dateTo;
  final String? certificateName;
  final String? degree;

  CVEducation({
    this.universityName,
    this.country,
    this.governorateState,
    this.dateFrom,
    this.dateTo,
    this.certificateName,
    this.degree,
  });

  factory CVEducation.fromJson(Map<String, dynamic> json) {
    return CVEducation(
      universityName: json['university_name'] as String?,
      country: json['country'] as String?,
      governorateState: json['governorate_state'] as String?,
      dateFrom: json['date_from'] as String?,
      dateTo: json['date_to'] as String?,
      certificateName: json['certificate_name'] as String?,
      degree: json['degree'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'university_name': universityName,
      'country': country,
      'governorate_state': governorateState,
      'date_from': dateFrom,
      'date_to': dateTo,
      'certificate_name': certificateName,
      'degree': degree,
    };
  }
}

/// Main CV Data Model
class CVDataModel {
  final CVPersonalData? personal;
  final CVContactData? contact;
  final CVJobInfoData? jobInfo;
  final List<CVEducation>? education;

  CVDataModel({
    this.personal,
    this.contact,
    this.jobInfo,
    this.education,
  });

  factory CVDataModel.fromJson(Map<String, dynamic> json) {
    return CVDataModel(
      personal: json['personal'] != null
          ? CVPersonalData.fromJson(json['personal'] as Map<String, dynamic>)
          : null,
      contact: json['contact'] != null
          ? CVContactData.fromJson(json['contact'] as Map<String, dynamic>)
          : null,
      jobInfo: json['job_info'] != null
          ? CVJobInfoData.fromJson(json['job_info'] as Map<String, dynamic>)
          : null,
      education: (json['education'] as List<dynamic>?)
          ?.map((e) => CVEducation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personal': personal?.toJson(),
      'contact': contact?.toJson(),
      'job_info': jobInfo?.toJson(),
      'education': education?.map((e) => e.toJson()).toList(),
    };
  }
}

