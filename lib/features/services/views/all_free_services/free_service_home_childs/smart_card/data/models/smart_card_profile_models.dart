import 'dart:convert';

/// تحويل آمن من dynamic إلى int? (الـ API قد يرجع أرقاماً كـ string)
int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

/// Smart Card API requires the **full model** in request body (all keys, null when empty).
/// Employee: POST/PUT /emp_requests/v1/smart-card/employee
/// Company:  POST/PUT /emp_requests/v1/smart-card/company/:id

/// One item in more_phones
class SmartCardMorePhone {
  final String? phone;
  SmartCardMorePhone({this.phone});
  Map<String, dynamic> toJson() => {'phone': phone};
  static SmartCardMorePhone? fromDynamic(dynamic e) {
    if (e == null) return null;
    if (e is Map) return SmartCardMorePhone(phone: e['phone']?.toString());
    return null;
  }
}

/// One item in other_links
class SmartCardOtherLink {
  final String? url;
  SmartCardOtherLink({this.url});
  Map<String, dynamic> toJson() => {'url': url};
  static SmartCardOtherLink? fromDynamic(dynamic e) {
    if (e == null) return null;
    if (e is Map) return SmartCardOtherLink(url: e['url']?.toString());
    return null;
  }
}

/// One portfolio item
class SmartCardPortfolioItem {
  final String? projectName;
  final String? projectDescription;
  final String? projectLink;
  SmartCardPortfolioItem({
    this.projectName,
    this.projectDescription,
    this.projectLink,
  });
  Map<String, dynamic> toJson() => {
        'project_name': projectName,
        'project_description': projectDescription,
        'project_link': projectLink,
      };
  static SmartCardPortfolioItem? fromDynamic(dynamic e) {
    if (e == null) return null;
    if (e is Map) {
      return SmartCardPortfolioItem(
        projectName: e['project_name']?.toString(),
        projectDescription: e['project_description']?.toString(),
        projectLink: e['project_link']?.toString(),
      );
    }
    return null;
  }
}

/// One experience item (employee)
class SmartCardExperienceItem {
  final String? companyName;
  final int? countryId;
  final int? stateId;
  final String? dateFrom;
  final String? dateTo;
  final String? jobTitle;
  SmartCardExperienceItem({
    this.companyName,
    this.countryId,
    this.stateId,
    this.dateFrom,
    this.dateTo,
    this.jobTitle,
  });
  Map<String, dynamic> toJson() => {
        'company_name': companyName,
        'country_id': countryId,
        'state_id': stateId,
        'date_from': dateFrom,
        'date_to': dateTo,
        'job_title': jobTitle,
      };
  static SmartCardExperienceItem? fromDynamic(dynamic e) {
    if (e == null) return null;
    if (e is Map) {
      return SmartCardExperienceItem(
        companyName: e['company_name']?.toString(),
        countryId: _parseInt(e['country_id']),
        stateId: _parseInt(e['state_id']),
        dateFrom: e['date_from']?.toString(),
        dateTo: e['date_to']?.toString(),
        jobTitle: e['job_title']?.toString(),
      );
    }
    return null;
  }
}

/// Full employee profile body – كل المفاتيح تُرسل (قيمة أو null)
/// photo: نفس أسلوب logo في الشركة – List<dynamic> (Map{id, file} للعناصر الموجودة أو String base64 للجديد). مفتاح الباك: photo
class SmartCardEmployeeProfileModel {
  final List<dynamic>? photo;
  final String? name;
  final String? business;
  final String? currentJobTitle;
  final String? companyName;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? address;
  final String? countryKey;
  final String? phone;
  final String? email;
  final List<SmartCardMorePhone>? morePhones;
  final String? linkedin;
  final String? behance;
  final String? website;
  final String? whatsapp;
  final List<SmartCardOtherLink>? otherLinks;
  final List<SmartCardPortfolioItem>? portfolios;
  final List<SmartCardExperienceItem>? experiences;
  /// تعليم – نفس المفتاح والبنية كما في Create CV: educations = قائمة عناصر (institution_name, country_id, state_id, date_from, date_to, certificate_name)
  final List<Map<String, dynamic>>? educations;
  /// نفس أسلوب company – List<dynamic>: Map{id, file} للعناصر الموجودة أو String base64 للجديد. يُرسل multipart + IDs
  final List<dynamic>? worksGallery;
  final List<dynamic>? videoGallery;

  SmartCardEmployeeProfileModel({
    this.photo,
    this.name,
    this.business,
    this.currentJobTitle,
    this.companyName,
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
    this.experiences,
    this.educations,
    this.worksGallery,
    this.videoGallery,
  });

  /// API requires full model – كل المفاتيح موجودة، null لو مفيش قيمة
  Map<String, dynamic> toFullJson() {
    return {
      'photo': photo ?? [],
      'name': name,
      'business': business,
      'current_job_title': currentJobTitle,
      'company_name': companyName,
      'country_id': countryId,
      'state_id': stateId,
      'city_id': cityId,
      'address': address,
      'country_key': countryKey,
      'phone': phone,
      'email': email,
      'more_phones': morePhones?.map((e) => e.toJson()).toList() ?? [],
      'linkedin': linkedin,
      'behance': behance,
      'website': website,
      'whatsapp': whatsapp,
      'other_links': otherLinks?.map((e) => e.toJson()).toList() ?? [],
      'portfolios': portfolios?.map((e) => e.toJson()).toList() ?? [],
      'experiences': experiences?.map((e) => e.toJson()).toList() ?? [],
      'educations': educations ?? [],
      'works_gallery': worksGallery ?? [],
      'video_gallery': videoGallery ?? [],
    };
  }

  /// From API response map (for merge before PUT)
  factory SmartCardEmployeeProfileModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return SmartCardEmployeeProfileModel();
    final morePhones = map['more_phones'] as List<dynamic>?;
    final otherLinks = map['other_links'] as List<dynamic>?;
    final portfolios = map['portfolios'] as List<dynamic>?;
    final experiences = map['experiences'] as List<dynamic>?;
    final educationsRaw = map['educations'] as List<dynamic>?;
    final worksGallery = map['works_gallery'] as List<dynamic>?;
    final videoGallery = map['video_gallery'] as List<dynamic>?;
    final rawPhoto = map['photo'];
    List<dynamic>? photoList;
    if (rawPhoto is List) {
      photoList = rawPhoto.map((e) {
        if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
          return {'id': e['id'], 'file': (e['file'] ?? e['thumbnail'])?.toString()};
        }
        return e.toString();
      }).toList();
    } else if (rawPhoto is Map && (rawPhoto['id'] != null || rawPhoto['file'] != null || rawPhoto['thumbnail'] != null)) {
      photoList = [{'id': rawPhoto['id'], 'file': (rawPhoto['file'] ?? rawPhoto['thumbnail'])?.toString()}];
    } else if (rawPhoto != null && rawPhoto.toString().trim().isNotEmpty) {
      photoList = [rawPhoto.toString()];
    }
    return SmartCardEmployeeProfileModel(
      photo: photoList,
      name: map['name']?.toString(),
      business: map['business']?.toString(),
      currentJobTitle: map['current_job_title']?.toString(),
      companyName: map['company_name']?.toString(),
      countryId: _parseInt(map['country_id']),
      stateId: _parseInt(map['state_id']),
      cityId: _parseInt(map['city_id']),
      address: map['address']?.toString(),
      countryKey: map['country_key']?.toString(),
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      morePhones: morePhones
          ?.map((e) => SmartCardMorePhone.fromDynamic(e))
          .whereType<SmartCardMorePhone>()
          .toList(),
      linkedin: map['linkedin']?.toString(),
      behance: map['behance']?.toString(),
      website: map['website']?.toString(),
      whatsapp: map['whatsapp']?.toString(),
      otherLinks: otherLinks
          ?.map((e) => SmartCardOtherLink.fromDynamic(e))
          .whereType<SmartCardOtherLink>()
          .toList(),
      portfolios: portfolios
          ?.map((e) => SmartCardPortfolioItem.fromDynamic(e))
          .whereType<SmartCardPortfolioItem>()
          .toList(),
      experiences: experiences
          ?.map((e) => SmartCardExperienceItem.fromDynamic(e))
          .whereType<SmartCardExperienceItem>()
          .toList(),
      educations: educationsRaw
          ?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .where((m) => m.isNotEmpty)
          .toList(),
      worksGallery: worksGallery
          ?.map((e) {
            if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
              return {'id': e['id'], 'file': (e['file'] ?? e['thumbnail'])?.toString()};
            }
            return e.toString();
          })
          .toList(),
      videoGallery: videoGallery
          ?.map((e) {
            if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
              return {'id': e['id'], 'file': (e['file'] ?? e['thumbnail'])?.toString()};
            }
            return e.toString();
          })
          .toList(),
    );
  }
}

/// Full company profile body – كل المفاتيح تُرسل (قيمة أو null)
/// logo / works_gallery / video_gallery: List<dynamic> where each item is Map{id, file} (existing) or String (base64 new). API expects array of IDs for existing + files for new.
class SmartCardCompanyProfileModel {
  final List<dynamic>? logo;
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
  final List<SmartCardMorePhone>? morePhones;
  final String? linkedin;
  final String? behance;
  final String? website;
  final String? whatsapp;
  final List<SmartCardOtherLink>? otherLinks;
  final List<SmartCardPortfolioItem>? portfolios;
  final List<dynamic>? worksGallery;
  final List<dynamic>? videoGallery;

  SmartCardCompanyProfileModel({
    this.logo,
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

  /// API requires full model – كل المفاتيح موجودة
  Map<String, dynamic> toFullJson() {
    return {
      // API wants [] not "[]" – always send array
      'logo': logo ?? [],
      'name': name,
      'about': about,
      'business': business,
      'country_id': countryId,
      'state_id': stateId,
      'city_id': cityId,
      'address': address,
      'country_key': countryKey,
      'phone': phone,
      'email': email,
      'more_phones': morePhones?.map((e) => e.toJson()).toList() ?? [],
      'linkedin': linkedin,
      'behance': behance,
      'website': website,
      'whatsapp': whatsapp,
      'other_links': otherLinks?.map((e) => e.toJson()).toList() ?? [],
      'portfolios': portfolios?.map((e) => e.toJson()).toList() ?? [],
      'works_gallery': worksGallery ?? [],
      'video_gallery': videoGallery ?? [],
    };
  }

  factory SmartCardCompanyProfileModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return SmartCardCompanyProfileModel();
    final morePhones = map['more_phones'] as List<dynamic>?;
    final otherLinks = map['other_links'] as List<dynamic>?;
    final portfolios = map['portfolios'] as List<dynamic>?;
    final worksGallery = map['works_gallery'] as List<dynamic>?;
    final videoGallery = map['video_gallery'] as List<dynamic>?;

    // Normalize logo: keep as List<dynamic> with Map{id, file} for existing or String for new
    final rawLogo = map['logo'];
    List<dynamic>? logo;
    if (rawLogo is List) {
      logo = rawLogo
          .map((e) {
            if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
              return {'id': e['id'], 'file': (e['file'] ?? e['thumbnail'])?.toString()};
            }
            return e.toString();
          })
          .toList();
    } else if (rawLogo is String) {
      final trimmed = rawLogo.trim();
      if (trimmed.isNotEmpty && trimmed != '[]') {
        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          try {
            final decoded = json.decode(trimmed);
            if (decoded is List) logo = decoded.map((e) => e.toString()).toList();
          } catch (_) {
            logo = [trimmed];
          }
        } else {
          logo = [trimmed];
        }
      }
    }

    final worksGalleryList = worksGallery
        ?.map((e) {
          if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
            return {'id': e['id'], 'file': (e['file'] ?? e['thumbnail'])?.toString()};
          }
          return e.toString();
        })
        .toList();
    final videoGalleryList = videoGallery
        ?.map((e) {
          if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
            return {'id': e['id'], 'file': (e['file'] ?? e['thumbnail'])?.toString()};
          }
          return e.toString();
        })
        .toList();

    return SmartCardCompanyProfileModel(
      logo: logo,
      name: map['name']?.toString(),
      about: map['about']?.toString(),
      business: map['business']?.toString(),
      countryId: _parseInt(map['country_id']),
      stateId: _parseInt(map['state_id']),
      cityId: _parseInt(map['city_id']),
      address: map['address']?.toString(),
      countryKey: map['country_key']?.toString(),
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      morePhones: morePhones
          ?.map((e) => SmartCardMorePhone.fromDynamic(e))
          .whereType<SmartCardMorePhone>()
          .toList(),
      linkedin: map['linkedin']?.toString(),
      behance: map['behance']?.toString(),
      website: map['website']?.toString(),
      whatsapp: map['whatsapp']?.toString(),
      otherLinks: otherLinks
          ?.map((e) => SmartCardOtherLink.fromDynamic(e))
          .whereType<SmartCardOtherLink>()
          .toList(),
      portfolios: portfolios
          ?.map((e) => SmartCardPortfolioItem.fromDynamic(e))
          .whereType<SmartCardPortfolioItem>()
          .toList(),
      worksGallery: worksGalleryList,
      videoGallery: videoGalleryList,
    );
  }
}
