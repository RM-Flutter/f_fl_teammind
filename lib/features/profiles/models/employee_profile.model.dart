import '../../../models/settings/user_settings_2.model.dart';

class EmployeeProfileModel {
  var id;
  final String? avatar;
  final String? jobTitle;
  final String? name;
  final String? username;
  final String? email;
  final String? birthDay;
  // final KeyValue? countryKey;
  var countryKey;
  var phone;
  final String? roles;
  final EmpKeyValue? defaultLanguage;
  final EmpKeyValue? status;
  final String? tags;
  final String? department;
  final int? departmentId;
  final Map<String, String>? action;
  final List<AdditionalPhoneNumbers>? additionalPhoneNumbers;
  final EmpSocialMedia? social;
  final String? jobDescription;
  final String? hireDate;
  final List<Balance>? balance;
  final List<String>? weekends;
  EmpWorkingHours? workingHours;
  final List<Assets>? assets;
  final List<EmpCustomData>? empCustomData;
  final String? basicSalary;
  final List<EmpPayrollDeduction>? payrollDeductions;
  final List<EmpPayrollBonus>? payrollSpecialBonus;
  final List<EmpPayroll>? payrolls;
  var netSalary;
  final String? workingHoursType;
   var totalDeductions;
   var additions; // or "totalBonuses"

  EmployeeProfileModel({
    this.id,
    this.avatar,
    this.name,
    this.workingHoursType,
    this.username,
    this.empCustomData,
    this.email,
    this.jobTitle,
    this.birthDay,
    this.countryKey,
    this.phone,
    this.roles,
    this.defaultLanguage,
    this.status,
    this.tags,
    this.departmentId,
    this.department,
    this.action,
    this.additionalPhoneNumbers,
    this.social,
    this.jobDescription,
    this.hireDate,
    this.balance,
    this.weekends,
    this.workingHours,
    this.assets,
    this.basicSalary,
    this.payrollDeductions,
    this.payrollSpecialBonus,
    this.payrolls,
  })  : totalDeductions = _calculateTotalAmount(
            basicSalary, payrollDeductions?.map((d) => d.value).toList()),
        additions = _calculateTotalAmount(
            basicSalary, payrollSpecialBonus?.map((b) => b.value).toList()),
        netSalary = _calculateNetSalary(
            basicSalary, payrollDeductions, payrollSpecialBonus);

  static double _calculateNetSalary(
    String? basicSalary,
    List<EmpPayrollDeduction>? payrollDeductions,
    List<EmpPayrollBonus>? payrollSpecialBonus,
  ) {
    if (basicSalary == null) return 0.0;

    final totalDeductions = _calculateTotalAmount(
        basicSalary, payrollDeductions?.map((d) => d.value).toList());

    final totalBonuses = _calculateTotalAmount(
      basicSalary,
      payrollSpecialBonus?.map((b) => b.value).toList(),
    );

    return double.tryParse(basicSalary)! + totalBonuses - totalDeductions;
  }

  static double _calculateTotalAmount(
      String? baseSalary, List<String?>? values) {
    if (baseSalary == null || values == null || values.isEmpty == true) {
      return 0.0;
    }
    final baseSalaryValue = double.tryParse(baseSalary) ?? 0.0;
    return values.fold(0.0, (total, value) {
      if (value?.endsWith('%') == true) {
        final percentage = double.tryParse(value!.replaceAll('%', '')) ?? 0.0;
        return total + (baseSalaryValue * (percentage / 100));
      } else {
        if (value == null || value.isEmpty == true) return total;
        return total + (double.tryParse(value) ?? 0.0);
      }
    });
  }

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
        id: json['id'],
        avatar: json['avatar'],
        name: json['name'],
        workingHoursType: json['working_hours_type'],
        username: json['username'],
        email: json['email'],
        birthDay: json['birth_day'],
        countryKey: json['country_key'],
        // countryKey: json['country_key'] != null
        //     ? KeyValue.fromJson(json['country_key'])
        //     : null,
        phone: json['phone'],
        roles: json['roles'],
        defaultLanguage: json['default_language'] != null
            ? EmpKeyValue.fromJson(json['default_language'])
            : null,
        status: json['status'] != null
            ? EmpKeyValue.fromJson(json['status'])
            : null,
        tags: json['tags'],
        departmentId: json['department_id'],
        department: json['department'],
        action: json['action'] != null
            ? Map<String, String>.from(json['action'])
            : null,
        jobTitle: json['job_title'],
        additionalPhoneNumbers: json['additional_phone_numbers'] != null
            ? List<AdditionalPhoneNumbers>.from(
            json['additional_phone_numbers'].map((item) => AdditionalPhoneNumbers.fromJson(item)))
            : null,
        social: json['social'] != null
            ? EmpSocialMedia.fromJson(json['social'])
            : null,
        jobDescription: json['job_description'],
        hireDate: json['hire_date'],
        balance: json['balance'] != null
            ? List<Balance>.from(
                json['balance'].map((item) => Balance.fromJson(item)))
            : null,
        weekends: (json['weekend'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        workingHours: json['working_hours'] != null
            ? EmpWorkingHours.fromJson(json['working_hours'])
            : null,
        assets:json['aassets'] != null
            ? List<Assets>.from(json['aassets']
            .map((item) => Assets.fromJson(item)))
            : null,
        empCustomData:json['emp_custom_data'] != null
            ? List<EmpCustomData>.from(json['emp_custom_data']
            .map((item) => EmpCustomData.fromJson(item)))
            : null,
        basicSalary: json['basic_salary'],
        // json['basic_salary'] is num?
        //     ? (json['basic_salary'] as num?)?.toDouble()
        //     : num.tryParse(json['basic_salary'])?.toDouble(),
        payrollDeductions: json['payroll_deductions'] != null
            ? List<EmpPayrollDeduction>.from(json['payroll_deductions']
                .map((item) => EmpPayrollDeduction.fromJson(item)))
            : null,
        payrollSpecialBonus: json['payroll_special_bonus'] != null
            ? List<EmpPayrollBonus>.from(json['payroll_special_bonus']
                .map((item) => EmpPayrollBonus.fromJson(item)))
            : null,
        payrolls: json['payrolls'] != null
            ? List<EmpPayroll>.from(
                json['payrolls'].map((item) => EmpPayroll.fromJson(item)))
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatar': avatar,
      'name': name,
      'username': username,
      'email': email,
      'birth_day': birthDay,
      'country_key': countryKey,
      'phone': phone,
      'roles': roles,
      'default_language': defaultLanguage?.toJson(),
      'status': status?.toJson(),
      'tags': tags,
      'department_id': departmentId,
      'action': action,
      'job_title': jobTitle,
      'additional_phone_numbers': additionalPhoneNumbers?.map((item) => item.toJson()).toList(),
      'social': social?.toJson(),
      'job_description': jobDescription,
      'hire_date': hireDate,
      'balance': balance?.map((item) => item.toJson()).toList(),
      'weekend': weekends,
      'working_hours': workingHours?.toJson(),
      'basic_salary': basicSalary,
      'payroll_deductions':
          payrollDeductions?.map((item) => item.toJson()).toList(),
      'payroll_special_bonus':
          payrollSpecialBonus?.map((item) => item.toJson()).toList(),
      'payrolls': payrolls?.map((item) => item.toJson()).toList(),
      'working_hours_type': workingHoursType,
    };
  }

  EmployeeProfileModel copyWith(
      {var id,
      String? avatar,
      String? name,
      String? username,
      String? email,
      String? birthDay,
      // KeyValue? countryKey,
      var countryKey,
      var phone,
      String? roles,
      EmpKeyValue? defaultLanguage,
      EmpKeyValue? status,
      String? tags,
      int? departmentId,
      Map<String, String>? action,
      String? jobTitle}) {
    return EmployeeProfileModel(
        id: id ?? this.id,
        avatar: avatar ?? this.avatar,
        name: name ?? this.name,
        username: username ?? this.username,
        email: email ?? this.email,
        birthDay: birthDay ?? this.birthDay,
        countryKey: countryKey ?? this.countryKey,
        phone: phone ?? this.phone,
        roles: roles ?? this.roles,
        defaultLanguage: defaultLanguage ?? this.defaultLanguage,
        status: status ?? this.status,
        tags: tags ?? this.tags,
        departmentId: departmentId ?? this.departmentId,
        action: action ?? this.action,
        jobTitle: jobTitle ?? this.jobTitle);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmployeeProfileModel &&
        other.id == id &&
        other.avatar == avatar &&
        other.name == name &&
        other.username == username &&
        other.email == email &&
        other.birthDay == birthDay &&
        other.countryKey == countryKey &&
        other.phone == phone &&
        other.roles == roles &&
        other.defaultLanguage == defaultLanguage &&
        other.status == status &&
        other.tags == tags &&
        other.departmentId == departmentId &&
        other.action == action &&
        other.jobTitle == jobTitle &&
        other.additionalPhoneNumbers == additionalPhoneNumbers &&
        other.social == social &&
        other.jobDescription == jobDescription &&
        other.hireDate == hireDate &&
        other.balance == balance &&
        other.weekends == weekends &&
        other.workingHours == workingHours &&
        other.assets == assets &&
        other.basicSalary == basicSalary &&
        other.payrollDeductions == payrollDeductions &&
        other.payrollSpecialBonus == payrollSpecialBonus &&
        other.payrolls == payrolls;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        avatar.hashCode ^
        name.hashCode ^
        username.hashCode ^
        email.hashCode ^
        birthDay.hashCode ^
        countryKey.hashCode ^
        phone.hashCode ^
        roles.hashCode ^
        defaultLanguage.hashCode ^
        status.hashCode ^
        tags.hashCode ^
        departmentId.hashCode ^
        action.hashCode ^
        jobTitle.hashCode ^
        additionalPhoneNumbers.hashCode ^
        social.hashCode ^
        jobDescription.hashCode ^
        hireDate.hashCode ^
        balance.hashCode ^
        weekends.hashCode ^
        workingHours.hashCode ^
        assets.hashCode ^
        basicSalary.hashCode ^
        payrollDeductions.hashCode ^
        payrollSpecialBonus.hashCode ^
        payrolls.hashCode;
  }

  @override
  String toString() {
    return 'EmployeeModel(id: $id, jobTitle: $jobTitle, avatar: $avatar, name: $name, username: $username, email: $email, birthDay: $birthDay, countryKey: $countryKey, phone: $phone, roles: $roles, defaultLanguage: $defaultLanguage, status: $status, tags: $tags, departmentId: $departmentId, action: $action, additionalPhoneNumbers: $additionalPhoneNumbers, social: $social, jobDescription: $jobDescription, hireDate: $hireDate, balance: $balance, weekends: $weekends, workingHours: $workingHours, assets: $assets, basicSalary: $basicSalary, payrollDeductions: $payrollDeductions, payrollSpecialBonus: $payrollSpecialBonus, payrolls: $payrolls)';
  }
}

class EmpSocialMedia {
  final String? facebook;
  final String? twitter;
  final String? linkedin;
  final String? instagram;
  final String? youtube;
  final String? pinterest;
  final String? snapchat;
  final String? whatsapp;

  EmpSocialMedia({
    this.facebook,
    this.twitter,
    this.linkedin,
    this.instagram,
    this.youtube,
    this.pinterest,
    this.snapchat,
    this.whatsapp,
  });

  factory EmpSocialMedia.fromJson(Map<String, dynamic> json) {
    return EmpSocialMedia(
      facebook: json['facebook'],
      twitter: json['twitter'],
      linkedin: json['linkedin'],
      instagram: json['instagram'],
      youtube: json['youtube'],
      pinterest: json['pinterest'],
      snapchat: json['snapchat'],
      whatsapp: json['whatsapp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'twitter': twitter,
      'linkedin': linkedin,
      'instagram': instagram,
      'youtube': youtube,
      'pinterest': pinterest,
      'snapchat': snapchat,
      'whatsapp': whatsapp,
    };
  }
}

class EmpWorkingHours {
  final String? dailyWorkingHours;
  final String? dailyWorkingHoursStart;
  final String? dailyWorkingHoursEnd;
  final String? dailyWorkingHoursFrom;
  final String? dailyWorkingHoursTo;
  final String? allowedDelayMinutes;
  final String? workingHoursType;

  EmpWorkingHours({
    this.dailyWorkingHours,
    this.dailyWorkingHoursStart,
    this.dailyWorkingHoursEnd,
    this.allowedDelayMinutes,
    this.dailyWorkingHoursFrom,
    this.dailyWorkingHoursTo,
    this.workingHoursType,
  });

  factory EmpWorkingHours.fromJson(Map<String, dynamic> json) {
    return EmpWorkingHours(
      dailyWorkingHours: json['daily_working_hours'],
      dailyWorkingHoursStart: json['working_hours_from_start'],
      dailyWorkingHoursEnd: json['working_hours_from_end'],
      dailyWorkingHoursFrom: json['working_hours_from'],
      allowedDelayMinutes: json['allowed_delay_minutes'],
      dailyWorkingHoursTo: json['working_hours_to'],
      workingHoursType: json['working_hours_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_working_hours': dailyWorkingHours,
      'working_hours_from_end': dailyWorkingHoursEnd,
      'working_hours_from_start': dailyWorkingHoursStart,
      'working_hours_type': workingHoursType,
    };
  }
}

class EmpPayrollDeduction {
  final Titles? title;
  final String? value;
  final bool? nextPeriodOnly;

  EmpPayrollDeduction({
    this.title,
    this.value,
    this.nextPeriodOnly,
  });

  factory EmpPayrollDeduction.fromJson(Map<String, dynamic> json) {
    return EmpPayrollDeduction(
      title: json['title'] != null
          ? Titles.fromJson(json['title'])
          : null,
      value: json['value'].toString(),
      nextPeriodOnly: json['next_period_only'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'next_period_only': nextPeriodOnly,
    };
  }
}
class AdditionalPhoneNumbers {
  final String? phone;
  final String? visible;

  AdditionalPhoneNumbers({
    this.phone,
    this.visible,
  });

  factory AdditionalPhoneNumbers.fromJson(Map<String, dynamic> json) {
    return AdditionalPhoneNumbers(
      phone: json['phone'],
      visible: json['visible'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'visible': visible,
    };
  }
}
class Assets {
  final String? assets;

  Assets({
    this.assets,
  });

  factory Assets.fromJson(Map<String, dynamic> json) {
    return Assets(
      assets: json['aassets'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aassets': assets,
    };
  }
}
class EmpCustomData {
  final String? item;

  EmpCustomData({
    this.item,
  });

  factory EmpCustomData.fromJson(Map<String, dynamic> json) {
    return EmpCustomData(
      item: json['item'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
    };
  }
}
class Titles {
  final String? en;
  final String? ar;

  Titles({
    this.en,
    this.ar,
  });

  factory Titles.fromJson(Map<String, dynamic> json) {
    return Titles(
      en: json['en'],
      ar: json['ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ar': ar,
    };
  }
}
class Titling {
  final String? en;
  final String? ar;

  Titling({
    this.en,
    this.ar,
  });

  factory Titling.fromJson(Map<String, dynamic> json) {
    return Titling(
      en: json['en'],
      ar: json['ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ar': ar,
    };
  }
}

class EmpPayrollBonus {
  final Titling? title;
  final String? value;
  final bool? nextPeriodOnly;

  EmpPayrollBonus({
    this.title,
    this.value,
    this.nextPeriodOnly,
  });

  factory EmpPayrollBonus.fromJson(Map<String, dynamic> json) {
    return EmpPayrollBonus(
      title: json['title'] != null
          ? Titling.fromJson(json['title'])
          : null,
      value: json['value'].toString(),
      nextPeriodOnly: json['next_period_only'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'next_period_only': nextPeriodOnly,
    };
  }
}

class EmpPayroll {
    var id;
  final String? dateFrom;
  final String? dateTo;
  final String? currency;
   var basicSalary;
   var netPayable;
  final String? status;
  final List<EmpPayrollDeduction>? payrollDeductions;
  final List<EmpPayrollBonus>? payrollSpecialBonus;
   var payrollTotalDeductions;
   var payrollTotalSpecialBonus;

  EmpPayroll({
    this.id,
    this.dateFrom,
    this.dateTo,
    this.currency,
    this.basicSalary,
    this.netPayable,
    this.status,
    this.payrollDeductions,
    this.payrollSpecialBonus,
    this.payrollTotalDeductions,
    this.payrollTotalSpecialBonus,
  });

  factory EmpPayroll.fromJson(Map<String, dynamic> json) {
    return EmpPayroll(
      id: json['id'],
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      currency: json['currency'],
      basicSalary: (json['basic_salary'] != null)
          ? (json['basic_salary'] is String
          ? double.tryParse(json['basic_salary'])
          : (json['basic_salary'] as num).toDouble())
          : null,

      netPayable: (json['net_payable'] != null)
          ? (json['net_payable'] is String
          ? double.tryParse(json['net_payable'])
          : (json['net_payable'] as num).toDouble())
          : null,

      status: json['status'],
      payrollDeductions: json['payroll_deductions'] != null
          ? List<EmpPayrollDeduction>.from(json['payroll_deductions']
              .map((item) => EmpPayrollDeduction.fromJson(item)))
          : null,
      payrollSpecialBonus: json['payroll_special_bonus'] != null
          ? List<EmpPayrollBonus>.from(json['payroll_special_bonus']
              .map((item) => EmpPayrollBonus.fromJson(item)))
          : null,
      payrollTotalDeductions: json['payroll_total_deductions'] != null
          ? (json['payroll_total_deductions'] is String
          ? double.tryParse(json['payroll_total_deductions'])
          : (json['payroll_total_deductions'] as num).toDouble())
          : null,

      payrollTotalSpecialBonus: json['payroll_total_special_bonus'] != null
          ? json['payroll_total_special_bonus'] is String
              ? double.tryParse(json['payroll_total_special_bonus'])
              : json['payroll_total_special_bonus']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_from': dateFrom,
      'date_to': dateTo,
      'currency': currency,
      'basic_salary': basicSalary?.toString(),
      'net_payable': netPayable?.toString(),
      'status': status,
      'payroll_deductions':
          payrollDeductions?.map((item) => item.toJson()).toList(),
      'payroll_special_bonus':
          payrollSpecialBonus?.map((item) => item.toJson()).toList(),
      'payroll_total_deductions': payrollTotalDeductions?.toString(),
      'payroll_total_special_bonus': payrollTotalSpecialBonus?.toString(),
    };
  }
}

class EmpKeyValue {
  final String? key;
  final String? value;

  EmpKeyValue({this.key, this.value});

  factory EmpKeyValue.fromJson(Map<String, dynamic> json) {
    return EmpKeyValue(
      key: json['key']?.toString(), // Ensuring the key is treated as a String
      value: json['value']
          ?.toString(), // Ensuring the value is treated as a String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmpKeyValue && other.key == key && other.value == value;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  String toString() => 'KeyValue(key: $key, value: $value)';
}
