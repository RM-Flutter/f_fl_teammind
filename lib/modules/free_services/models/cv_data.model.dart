int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

/// Model for CV Personal Data
class CVPersonalData {
  final String? name;
  final String? familyStatus;
  final String? birthday;
  final String? gender;
  final int? nationalityId;
  final String? nationalityTitle;
  final String? countryKey;
  final int? countryId;
  final String? countryTitle;
  final int? stateId;
  final String? stateTitle;
  final int? cityId;
  final String? cityTitle;
  final String? address;

  CVPersonalData({
    this.name,
    this.familyStatus,
    this.birthday,
    this.gender,
    this.nationalityId,
    this.nationalityTitle,
    this.countryKey,
    this.countryId,
    this.countryTitle,
    this.stateId,
    this.stateTitle,
    this.cityId,
    this.cityTitle,
    this.address,
  });

  factory CVPersonalData.fromJson(Map<String, dynamic> json) {
    return CVPersonalData(
      name: json['name'] as String?,
      familyStatus: json['family_status'] as String?,
      birthday: json['birthday'] as String?,
      gender: json['gender'] as String?,
      nationalityId: _parseInt(json['nationality_id']),
      nationalityTitle: json['nationality_title'] as String?,
      countryKey: json['country_key'] as String?,
      countryId: _parseInt(json['country_id']),
      countryTitle: json['country_title'] as String?,
      stateId: _parseInt(json['state_id']),
      stateTitle: json['state_title'] as String?,
      cityId: _parseInt(json['city_id']),
      cityTitle: json['city_title'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null && name!.isNotEmpty) json['name'] = name;
    if (familyStatus != null && familyStatus!.isNotEmpty) json['family_status'] = familyStatus;
    if (birthday != null && birthday!.isNotEmpty) json['birthday'] = birthday;
    if (gender != null && gender!.isNotEmpty) json['gender'] = gender;
    if (nationalityId != null) json['nationality_id'] = nationalityId;
    if (countryKey != null && countryKey!.isNotEmpty) json['country_key'] = countryKey;
    if (countryId != null) json['country_id'] = countryId;
    if (stateId != null) json['state_id'] = stateId;
    if (cityId != null) json['city_id'] = cityId;
    if (address != null && address!.isNotEmpty) json['address'] = address;
    return json;
  }
}

/// Model for CV Contact Data
class CVContactData {
  final String? phone;
  final String? email;
  final String? linkedin;
  final String? behance;
  final String? whatsapp;

  CVContactData({
    this.phone,
    this.email,
    this.linkedin,
    this.behance,
    this.whatsapp,
  });

  factory CVContactData.fromJson(Map<String, dynamic> json) {
    return CVContactData(
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      linkedin: json['linkedin'] as String?,
      behance: json['behance'] as String?,
      whatsapp: json['whatsapp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (phone != null && phone!.isNotEmpty) json['phone'] = phone;
    if (email != null && email!.isNotEmpty) json['email'] = email;
    if (linkedin != null && linkedin!.isNotEmpty) json['linkedin'] = linkedin;
    if (behance != null && behance!.isNotEmpty) json['behance'] = behance;
    if (whatsapp != null && whatsapp!.isNotEmpty) json['whatsapp'] = whatsapp;
    return json;
  }
}

/// Model for CV Experience
class CVExperience {
  final String? companyName;
  final int? countryId;
  final int? stateId;
  final String? dateFrom;
  final String? dateTo;
  final String? jobTitle;

  CVExperience({
    this.companyName,
    this.countryId,
    this.stateId,
    this.dateFrom,
    this.dateTo,
    this.jobTitle,
  });

  factory CVExperience.fromJson(Map<String, dynamic> json) {
    return CVExperience(
      companyName: json['company_name'] as String?,
      countryId: _parseInt(json['country_id']),
      stateId: _parseInt(json['state_id']),
      dateFrom: json['date_from'] as String?,
      dateTo: json['date_to'] as String?,
      jobTitle: json['job_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (companyName != null && companyName!.isNotEmpty) json['company_name'] = companyName;
    if (countryId != null) json['country_id'] = countryId;
    if (stateId != null) json['state_id'] = stateId;
    if (dateFrom != null && dateFrom!.isNotEmpty) json['date_from'] = dateFrom;
    if (dateTo != null && dateTo!.isNotEmpty) json['date_to'] = dateTo;
    if (jobTitle != null && jobTitle!.isNotEmpty) json['job_title'] = jobTitle;
    return json;
  }
}

/// Model for CV Portfolio
class CVPortfolio {
  final String? projectName;
  final String? projectDescription;
  final String? projectLink;
  final List<String>? images;

  CVPortfolio({
    this.projectName,
    this.projectDescription,
    this.projectLink,
    this.images,
  });

  factory CVPortfolio.fromJson(Map<String, dynamic> json) {
    return CVPortfolio(
      projectName: json['project_name'] as String?,
      projectDescription: json['project_description'] as String?,
      projectLink: json['project_link'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (projectName != null && projectName!.isNotEmpty) json['project_name'] = projectName;
    if (projectDescription != null && projectDescription!.isNotEmpty) json['project_description'] = projectDescription;
    if (projectLink != null && projectLink!.isNotEmpty) json['project_link'] = projectLink;
    if (images != null && images!.isNotEmpty) json['images'] = images;
    return json;
  }
}

/// Model for CV Job Info Data
class CVJobInfoData {
  final String? currentJobTitle;
  final int? jobId;
  final String? jobTitle;
  final String? aboutMe;
  final List<int>? skills;
  final List<String>? skillsTitles;
  final String? moreSkills;
  final List<CVExperience>? experiences;
  final List<CVPortfolio>? portfolios;
  final List<CVLanguageLevel>? languagesLevels;
  final List<CVSkillLevel>? skillsLevels;

  CVJobInfoData({
    this.currentJobTitle,
    this.jobId,
    this.jobTitle,
    this.aboutMe,
    this.skills,
    this.skillsTitles,
    this.moreSkills,
    this.experiences,
    this.portfolios,
    this.languagesLevels,
    this.skillsLevels,
  });

  factory CVJobInfoData.fromJson(Map<String, dynamic> json) {
    final skills = json['skills'] as List<dynamic>?;
    return CVJobInfoData(
      currentJobTitle: json['current_job_title'] as String?,
      jobId: json['job_id'] as int?,
      jobTitle: json['job_title'] as String?,
      aboutMe: json['about_me'] as String?,
      skills: skills
          ?.map((e) => e is int ? e : (e as Map<String, dynamic>)['id'] as int)
          .toList(),
      skillsTitles: skills
          ?.map((e) {
            if (e is Map<String, dynamic>) {
              return e['title'] as String? ?? e['name'] as String? ?? '';
            }
            return '';
          })
          .where((title) => title.isNotEmpty)
          .toList(),
      moreSkills: json['more_skills'] as String?,
      experiences: (json['experiences'] as List<dynamic>?)
          ?.map((e) => CVExperience.fromJson(e as Map<String, dynamic>))
          .toList(),
      portfolios: (json['portfolios'] as List<dynamic>?)
          ?.map((e) => CVPortfolio.fromJson(e as Map<String, dynamic>))
          .toList(),
      languagesLevels: (json['languagesLevels'] as List<dynamic>?)
          ?.map((e) => CVLanguageLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      skillsLevels: (json['skillsLevels'] as List<dynamic>?)
          ?.map((e) => CVSkillLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (currentJobTitle != null && currentJobTitle!.isNotEmpty) json['current_job_title'] = currentJobTitle;
    if (jobId != null) json['job_id'] = jobId;
    if (aboutMe != null && aboutMe!.isNotEmpty) json['about_me'] = aboutMe;
    if (skills != null && skills!.isNotEmpty) json['skills'] = skills;
    if (moreSkills != null && moreSkills!.isNotEmpty) json['more_skills'] = moreSkills;
    if (experiences != null && experiences!.isNotEmpty) {
      final expList = experiences!.map((e) => e.toJson()).where((json) => json.isNotEmpty).toList();
      if (expList.isNotEmpty) json['experiences'] = expList;
    }
    if (portfolios != null && portfolios!.isNotEmpty) {
      final portList = portfolios!.map((e) => e.toJson()).where((json) => json.isNotEmpty).toList();
      if (portList.isNotEmpty) json['portfolios'] = portList;
    }
    if (languagesLevels != null && languagesLevels!.isNotEmpty) {
      final langList = languagesLevels!.map((e) => e.toJson()).where((json) => json.isNotEmpty).toList();
      if (langList.isNotEmpty) json['languagesLevels'] = langList;
    }
    if (skillsLevels != null && skillsLevels!.isNotEmpty) {
      final skillList = skillsLevels!.map((e) => e.toJson()).where((json) => json.isNotEmpty).toList();
      if (skillList.isNotEmpty) json['skillsLevels'] = skillList;
    }
    return json;
  }
}

/// Model for CV Education
class CVEducation {
  final String? institutionName;
  final int? countryId;
  final int? stateId;
  final String? dateFrom;
  final String? dateTo;
  final String? certificateName;

  CVEducation({
    this.institutionName,
    this.countryId,
    this.stateId,
    this.dateFrom,
    this.dateTo,
    this.certificateName,
  });

  factory CVEducation.fromJson(Map<String, dynamic> json) {
    return CVEducation(
      institutionName: json['institution_name'] as String?,
      countryId: _parseInt(json['country_id']),
      stateId: _parseInt(json['state_id']),
      dateFrom: json['date_from'] as String?,
      dateTo: json['date_to'] as String?,
      certificateName: json['certificate_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (institutionName != null && institutionName!.isNotEmpty) json['institution_name'] = institutionName;
    if (countryId != null) json['country_id'] = countryId;
    if (stateId != null) json['state_id'] = stateId;
    if (dateFrom != null && dateFrom!.isNotEmpty) json['date_from'] = dateFrom;
    if (dateTo != null && dateTo!.isNotEmpty) json['date_to'] = dateTo;
    if (certificateName != null && certificateName!.isNotEmpty) json['certificate_name'] = certificateName;
    return json;
  }
}

/// Model for Language Level
class CVLanguageLevel {
  final int? languageId;
  final int? levelId;

  CVLanguageLevel({
    this.languageId,
    this.levelId,
  });

  factory CVLanguageLevel.fromJson(Map<String, dynamic> json) {
    return CVLanguageLevel(
      languageId: json['language_id'] as int?,
      levelId: json['level_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (languageId != null) json['language_id'] = languageId;
    if (levelId != null) json['level_id'] = levelId;
    return json;
  }
}

/// Model for Skill Level
class CVSkillLevel {
  final int? skillId;
  final int? levelId;

  CVSkillLevel({
    this.skillId,
    this.levelId,
  });

  factory CVSkillLevel.fromJson(Map<String, dynamic> json) {
    return CVSkillLevel(
      skillId: json['skill_id'] as int?,
      levelId: json['level_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (skillId != null) json['skill_id'] = skillId;
    if (levelId != null) json['level_id'] = levelId;
    return json;
  }
}

/// Main CV Data Model for API Request
class CreateCVRequestModel {
  final String? name;
  final String? familyStatus;
  final String? birthday;
  final String? gender;
  final String? countryKey;
  final String? phone;
  final int? nationalityId;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? address;
  final String? currentJobTitle;
  final int? jobId;
  final String? aboutMe;
  final String? moreSkills;
  final String? email;
  final String? linkedin;
  final String? behance;
  final String? whatsapp;
  final List<int>? skills;
  final List<CVExperience>? experiences;
  final List<CVPortfolio>? portfolios;
  final List<CVLanguageLevel>? languagesLevels;
  final List<CVSkillLevel>? skillsLevels;

  CreateCVRequestModel({
    this.name,
    this.familyStatus,
    this.birthday,
    this.gender,
    this.countryKey,
    this.phone,
    this.nationalityId,
    this.countryId,
    this.stateId,
    this.cityId,
    this.address,
    this.currentJobTitle,
    this.jobId,
    this.aboutMe,
    this.moreSkills,
    this.email,
    this.linkedin,
    this.behance,
    this.whatsapp,
    this.skills,
    this.experiences,
    this.portfolios,
    this.languagesLevels,
    this.skillsLevels,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    // Only add non-null and non-empty fields
    if (name != null && name!.isNotEmpty) json['name'] = name;
    if (familyStatus != null && familyStatus!.isNotEmpty) json['family_status'] = familyStatus;
    if (birthday != null && birthday!.isNotEmpty) json['birthday'] = birthday;
    if (gender != null && gender!.isNotEmpty) json['gender'] = gender;
    if (countryKey != null && countryKey!.isNotEmpty) json['country_key'] = countryKey;
    if (phone != null && phone!.isNotEmpty) json['phone'] = phone;
    if (nationalityId != null) json['nationality_id'] = nationalityId;
    if (countryId != null) json['country_id'] = countryId;
    if (stateId != null) json['state_id'] = stateId;
    if (cityId != null) json['city_id'] = cityId;
    if (address != null && address!.isNotEmpty) json['address'] = address;
    if (currentJobTitle != null && currentJobTitle!.isNotEmpty) json['current_job_title'] = currentJobTitle;
    if (jobId != null) json['job_id'] = jobId;
    if (aboutMe != null && aboutMe!.isNotEmpty) json['about_me'] = aboutMe;
    if (moreSkills != null && moreSkills!.isNotEmpty) json['more_skills'] = moreSkills;
    if (email != null && email!.isNotEmpty) json['email'] = email;
    if (linkedin != null && linkedin!.isNotEmpty) json['linkedin'] = linkedin;
    if (behance != null && behance!.isNotEmpty) json['behance'] = behance;
    if (whatsapp != null && whatsapp!.isNotEmpty) json['whatsapp'] = whatsapp;
    
    // Only add non-empty lists
    if (skills != null && skills!.isNotEmpty) json['skills'] = skills;
    if (experiences != null && experiences!.isNotEmpty) {
      json['experiences'] = experiences!.map((e) => e.toJson()).toList();
    }
    if (portfolios != null && portfolios!.isNotEmpty) {
      json['portfolios'] = portfolios!.map((e) => e.toJson()).toList();
    }
    if (languagesLevels != null && languagesLevels!.isNotEmpty) {
      json['languagesLevels'] = languagesLevels!.map((e) => e.toJson()).toList();
    }
    if (skillsLevels != null && skillsLevels!.isNotEmpty) {
      json['skillsLevels'] = skillsLevels!.map((e) => e.toJson()).toList();
    }
    
    return json;
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
    final Map<String, dynamic> json = {};
    
    // Only add non-empty objects
    if (personal != null) {
      final personalJson = personal!.toJson();
      if (personalJson.isNotEmpty) json['personal'] = personalJson;
    }
    
    if (contact != null) {
      final contactJson = contact!.toJson();
      if (contactJson.isNotEmpty) json['contact'] = contactJson;
    }
    
    if (jobInfo != null) {
      final jobInfoJson = jobInfo!.toJson();
      if (jobInfoJson.isNotEmpty) json['job_info'] = jobInfoJson;
    }
    
    if (education != null && education!.isNotEmpty) {
      final educationList = education!.map((e) => e.toJson()).where((json) => json.isNotEmpty).toList();
      if (educationList.isNotEmpty) json['education'] = educationList;
    }
    
    return json;
  }
}

/// Company update request – body as Map (same approach as CreateCVRequestModel / update CV)
class UpdateCompanyRequestModel {
  final String? name;
  final String? about;
  final String? business;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? address;
  final String? countryKey;
  final String? phone;
  final String? email;
  final List<Map<String, String>>? morePhones;
  final String? linkedin;
  final String? behance;
  final String? website;
  final String? whatsapp;
  final List<Map<String, String>>? otherLinks;
  final List<CVPortfolio>? portfolios;
  final List<dynamic>? worksGallery;
  final List<dynamic>? videoGallery;

  UpdateCompanyRequestModel({
    this.name,
    this.about,
    this.business,
    this.countryId,
    this.stateId,
    this.cityId,
    this.address,
    this.countryKey,
    this.phone,
    this.email,
    this.morePhones,
    this.linkedin,
    this.behance,
    this.website,
    this.whatsapp,
    this.otherLinks,
    this.portfolios,
    this.worksGallery,
    this.videoGallery,
  });

  /// Body for API: single Map, only non-empty fields, same style as update CV
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null && name!.isNotEmpty) json['name'] = name;
    if (about != null && about!.isNotEmpty) json['about'] = about;
    if (business != null && business!.isNotEmpty) json['business'] = business;
    if (countryId != null) json['country_id'] = countryId;
    if (stateId != null) json['state_id'] = stateId;
    if (cityId != null) json['city_id'] = cityId;
    if (address != null && address!.isNotEmpty) json['address'] = address;
    if (countryKey != null && countryKey!.isNotEmpty) json['country_key'] = countryKey;
    if (phone != null && phone!.isNotEmpty) json['phone'] = phone;
    if (email != null && email!.isNotEmpty) json['email'] = email;
    if (morePhones != null && morePhones!.isNotEmpty) {
      json['more_phones'] = morePhones;
    }
    if (linkedin != null && linkedin!.isNotEmpty) json['linkedin'] = linkedin;
    if (behance != null && behance!.isNotEmpty) json['behance'] = behance;
    if (website != null && website!.isNotEmpty) json['website'] = website;
    if (whatsapp != null && whatsapp!.isNotEmpty) json['whatsapp'] = whatsapp;
    if (otherLinks != null && otherLinks!.isNotEmpty) {
      json['other_links'] = otherLinks;
    }
    if (portfolios != null && portfolios!.isNotEmpty) {
      final list = portfolios!.map((e) => e.toJson()).where((j) => j.isNotEmpty).toList();
      if (list.isNotEmpty) json['portfolios'] = list;
    }
    if (worksGallery != null && worksGallery!.isNotEmpty) {
      json['works_gallery'] = worksGallery;
    }
    if (videoGallery != null && videoGallery!.isNotEmpty) {
      json['video_gallery'] = videoGallery;
    }
    return json;
  }
}

