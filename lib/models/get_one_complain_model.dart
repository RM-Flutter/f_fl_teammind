class GetOneComplainModel {
  bool? status;
  String? message;
  Complain? complain;

  GetOneComplainModel({this.status, this.message, this.complain});

  GetOneComplainModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    complain = json['complain'] != null
        ? Complain.fromJson(json['complain'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (complain != null) {
      data['complain'] = complain!.toJson();
    }
    return data;
  }
}

class Complain {
  int? id;
  int? departmentId;
  String? departmentName;
  String? commentStatus;
  String? subject;
  String? details;
  List<MainThumbnail>? mainThumbnail;
  int? employeeId;
  Employee? employee;
  String? createdAt;
  String? pstatus;

  Complain(
      {this.id,
        this.departmentId,
        this.departmentName,
        this.subject,
        this.details,
        this.mainThumbnail,
        this.commentStatus,
        this.employeeId,
        this.employee,
        this.createdAt,
        this.pstatus});

  Complain.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    departmentName = json['department_name'];
    departmentId = json['department_id'];
    subject = json['subject'];
    details = json['details'];
    if (json['main_thumbnail'] != null) {
      mainThumbnail = <MainThumbnail>[];
      json['main_thumbnail'].forEach((v) {
        mainThumbnail!.add(MainThumbnail.fromJson(v));
      });
    }
    employeeId = json['employee_id'];
    employee = json['employee'] != null
        ? Employee.fromJson(json['employee'])
        : null;
    commentStatus = json['comment_status'];
    createdAt = json['created_at'];
    pstatus = json['pstatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['department_id'] = departmentId;
    data['subject'] = subject;
    data['details'] = details;
    if (mainThumbnail != null) {
      data['main_thumbnail'] =
          mainThumbnail!.map((v) => v.toJson()).toList();
    }
    data['employee_id'] = employeeId;
    if (employee != null) {
      data['employee'] = employee!.toJson();
    }
    data['created_at'] = createdAt;
    data['pstatus'] = pstatus;
    return data;
  }
}

class MainThumbnail {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;
  Sizes? sizes;

  MainThumbnail(
      {this.id,
        this.type,
        this.title,
        this.alt,
        this.file,
        this.thumbnail,
        this.sizes});

  MainThumbnail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    alt = json['alt'];
    file = json['file'];
    thumbnail = json['thumbnail'];
    sizes = json['sizes'] != null ? Sizes.fromJson(json['sizes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['alt'] = alt;
    data['file'] = file;
    data['thumbnail'] = thumbnail;
    if (sizes != null) {
      data['sizes'] = sizes!.toJson();
    }
    return data;
  }
}

class Sizes {
  String? thumbnail;
  String? medium;
  String? large;
  String? s1200800;
  String? s8001200;
  String? s1200300;
  String? s3001200;

  Sizes(
      {this.thumbnail,
        this.medium,
        this.large,
        this.s1200800,
        this.s8001200,
        this.s1200300,
        this.s3001200});

  Sizes.fromJson(Map<String, dynamic> json) {
    thumbnail = json['thumbnail'];
    medium = json['medium'];
    large = json['large'];
    s1200800 = json['1200_800'];
    s8001200 = json['800_1200'];
    s1200300 = json['1200_300'];
    s3001200 = json['300_1200'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['thumbnail'] = thumbnail;
    data['medium'] = medium;
    data['large'] = large;
    data['1200_800'] = s1200800;
    data['800_1200'] = s8001200;
    data['1200_300'] = s1200300;
    data['300_1200'] = s3001200;
    return data;
  }
}

class Employee {
  int? id;
  String? name;
  String? email;
  String? countryKey;
  int? phone;
  String? avatar;
  String? jobTitle;
  List<Null>? additionalPhoneNumbers;
  Social? social;

  Employee(
      {this.id,
        this.name,
        this.email,
        this.countryKey,
        this.phone,
        this.avatar,
        this.jobTitle,
        this.additionalPhoneNumbers,
        this.social});

  Employee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    countryKey = json['country_key'];
    phone = json['phone'];
    avatar = json['avatar'];
    jobTitle = json['job_title'];
    social =
    json['social'] != null ? Social.fromJson(json['social']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['country_key'] = countryKey;
    data['phone'] = phone;
    data['avatar'] = avatar;
    data['job_title'] = jobTitle;
    if (social != null) {
      data['social'] = social!.toJson();
    }
    return data;
  }
}

class Social {
  var facebook;
  var twitter;
  var linkedin;
  var instagram;
  var youtube;
  var pinterest;
  var snapchat;
  var whatsapp;

  Social(
      {this.facebook,
        this.twitter,
        this.linkedin,
        this.instagram,
        this.youtube,
        this.pinterest,
        this.snapchat,
        this.whatsapp});

  Social.fromJson(Map<String, dynamic> json) {
    facebook = json['facebook'];
    twitter = json['twitter'];
    linkedin = json['linkedin'];
    instagram = json['instagram'];
    youtube = json['youtube'];
    pinterest = json['pinterest'];
    snapchat = json['snapchat'];
    whatsapp = json['whatsapp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['facebook'] = facebook;
    data['twitter'] = twitter;
    data['linkedin'] = linkedin;
    data['instagram'] = instagram;
    data['youtube'] = youtube;
    data['pinterest'] = pinterest;
    data['snapchat'] = snapchat;
    data['whatsapp'] = whatsapp;
    return data;
  }
}
