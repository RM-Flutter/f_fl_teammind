class GetOneRequestModel {
  bool? status;
  String? message;
  Complain? complain;

  GetOneRequestModel({this.status, this.message, this.complain});

  GetOneRequestModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    complain = json['complain'] != null
        ? new Complain.fromJson(json['complain'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.complain != null) {
      data['complain'] = this.complain!.toJson();
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
  Ptype? pType;
  Complain(
      {this.id,
        this.pType,
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
        mainThumbnail!.add(new MainThumbnail.fromJson(v));
      });
    }
    pType = json['ptype'] != null ? new Ptype.fromJson(json['ptype']) : null;
    employeeId = json['employee_id'];
    employee = json['employee'] != null
        ? new Employee.fromJson(json['employee'])
        : null;
    commentStatus = json['comment_status'];
    createdAt = json['created_at'];
    pstatus = json['pstatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['department_id'] = this.departmentId;
    data['subject'] = this.subject;
    data['details'] = this.details;
    if (this.mainThumbnail != null) {
      data['main_thumbnail'] =
          this.mainThumbnail!.map((v) => v.toJson()).toList();
    }
    data['employee_id'] = this.employeeId;
    if (this.employee != null) {
      data['employee'] = this.employee!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['pstatus'] = this.pstatus;
    return data;
  }
}
class Ptype {
  var id;
  String? title;

  Ptype({this.id, this.title});

  Ptype.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
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
    sizes = json['sizes'] != null ? new Sizes.fromJson(json['sizes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['title'] = this.title;
    data['alt'] = this.alt;
    data['file'] = this.file;
    data['thumbnail'] = this.thumbnail;
    if (this.sizes != null) {
      data['sizes'] = this.sizes!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thumbnail'] = this.thumbnail;
    data['medium'] = this.medium;
    data['large'] = this.large;
    data['1200_800'] = this.s1200800;
    data['800_1200'] = this.s8001200;
    data['1200_300'] = this.s1200300;
    data['300_1200'] = this.s3001200;
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
    json['social'] != null ? new Social.fromJson(json['social']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['country_key'] = this.countryKey;
    data['phone'] = this.phone;
    data['avatar'] = this.avatar;
    data['job_title'] = this.jobTitle;
    if (this.social != null) {
      data['social'] = this.social!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['facebook'] = this.facebook;
    data['twitter'] = this.twitter;
    data['linkedin'] = this.linkedin;
    data['instagram'] = this.instagram;
    data['youtube'] = this.youtube;
    data['pinterest'] = this.pinterest;
    data['snapchat'] = this.snapchat;
    data['whatsapp'] = this.whatsapp;
    return data;
  }
}