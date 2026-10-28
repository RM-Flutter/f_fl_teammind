import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/data/models/reward_and_penalty_model.dart';

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
  final WeekendModel? weekendModel;
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
  final String? mainStatus;
  final String? employeeStatus;
  final String? employmentType;
  final String? jobLevel;
  final List<EmpRewardPenalty>? rewardsAndPenalties;
  final EmpTodayAttendance? todayAttendance;
  final List<EmpWeekShift>? thisWeekShifts;

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
    this.weekendModel,
    this.workingHours,
    this.assets,
    this.basicSalary,
    this.payrollDeductions,
    this.payrollSpecialBonus,
    this.payrolls,
    this.mainStatus,
    this.employeeStatus,
    this.employmentType,
    this.jobLevel,
    this.rewardsAndPenalties,
    this.todayAttendance,
    this.thisWeekShifts,
  })  : totalDeductions = _calculateTotalAmount(
            basicSalary, payrollDeductions?.map((d) => d.value).toList()),
        additions = _calculateTotalAmount(
            basicSalary, payrollSpecialBonus?.map((b) => b.value).toList()),
        netSalary = _calculateNetSalary(
            basicSalary, payrollDeductions, payrollSpecialBonus);

  static String? _parseStringOrKey(dynamic val) {
    if (val == null) return null;
    if (val is Map) {
      return (val['key'] ?? val['value'] ?? val['en'] ?? val['ar'])?.toString();
    }
    return val.toString();
  }

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
      status:
          json['status'] != null ? EmpKeyValue.fromJson(json['status']) : null,
      tags: json['tags'],
      departmentId: json['department_id'],
      department: json['department'],
      action: json['action'] != null
          ? Map<String, String>.from(json['action'])
          : null,
      jobTitle: json['job_title'],
      additionalPhoneNumbers: json['additional_phone_numbers'] != null
          ? List<AdditionalPhoneNumbers>.from(json['additional_phone_numbers']
              .map((item) => AdditionalPhoneNumbers.fromJson(item)))
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
      weekends: json['weekend'] is Map
          ? (json['weekend']['days'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList()
          : (json['weekend'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      weekendModel: json['weekend'] is Map
          ? WeekendModel.fromJson(json['weekend'])
          : null,
      workingHours: json['working_hours'] != null
          ? EmpWorkingHours.fromJson(json['working_hours'])
          : null,
      assets: json['aassets'] != null
          ? List<Assets>.from(
              json['aassets'].map((item) => Assets.fromJson(item)))
          : null,
      empCustomData: json['emp_custom_data'] != null
          ? List<EmpCustomData>.from(json['emp_custom_data']
              .map((item) => EmpCustomData.fromJson(item)))
          : null,
      basicSalary: json['basic_salary'],
      // json['basic_salary'] is num?
      //     ? (json['basic_salary'] as num?)?.toDouble()
      //     : num.tryParse(json['basic_salary'])?.toDouble(),
      payrollDeductions: json['payroll_deductions'] is List
          ? List<EmpPayrollDeduction>.from(json['payroll_deductions']
              .map((item) => EmpPayrollDeduction.fromJson(item)))
          : null,
      payrollSpecialBonus: json['payroll_special_bonus'] is List
          ? List<EmpPayrollBonus>.from(json['payroll_special_bonus']
              .map((item) => EmpPayrollBonus.fromJson(item)))
          : null,
      payrolls: json['payrolls'] is List
          ? List<EmpPayroll>.from(
              json['payrolls'].map((item) => EmpPayroll.fromJson(item)))
          : null,
      mainStatus: _parseStringOrKey(json['main_status']),
      employeeStatus: _parseStringOrKey(json['employee_status']),
      employmentType: _parseStringOrKey(json['employment_type']),
      jobLevel: _parseStringOrKey(json['job_level']),
      rewardsAndPenalties: json['rewards_and_penalties'] != null
          ? List<EmpRewardPenalty>.from(json['rewards_and_penalties']
              .map((item) => EmpRewardPenalty.fromJson(item)))
          : null,
      todayAttendance: json['today_attendance'] != null
          ? EmpTodayAttendance.fromJson(json['today_attendance'])
          : null,
      thisWeekShifts:
          (json['this_week_shifts'] ?? json['This_week_shifts']) is List
              ? List<EmpWeekShift>.from(
                  ((json['this_week_shifts'] ?? json['This_week_shifts']) as List)
                      .map((item) => EmpWeekShift.fromJson(item)))
              : null,
    );
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
      'additional_phone_numbers':
          additionalPhoneNumbers?.map((item) => item.toJson()).toList(),
      'social': social?.toJson(),
      'job_description': jobDescription,
      'hire_date': hireDate,
      'balance': balance?.map((item) => item.toJson()).toList(),
      'weekend': weekends,
      'working_hours': workingHours?.toJson(),
      'this_week_shifts':
          thisWeekShifts?.map((item) => item.toJson()).toList(),
      'basic_salary': basicSalary,
      'payroll_deductions':
          payrollDeductions?.map((item) => item.toJson()).toList(),
      'payroll_special_bonus':
          payrollSpecialBonus?.map((item) => item.toJson()).toList(),
      'payrolls': payrolls?.map((item) => item.toJson()).toList(),
      'working_hours_type': workingHoursType,
      'main_status': mainStatus,
      'employee_status': employeeStatus,
      'employment_type': employmentType,
      'job_level': jobLevel,
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
      String? mainStatus,
      String? employeeStatus,
      String? employmentType,
      String? jobLevel,
      String? jobTitle,
      String? workingHoursType,
      EmpWorkingHours? workingHours,
      List<EmpWeekShift>? thisWeekShifts}) {
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
        mainStatus: mainStatus ?? this.mainStatus,
        employeeStatus: employeeStatus ?? this.employeeStatus,
        employmentType: employmentType ?? this.employmentType,
        jobLevel: jobLevel ?? this.jobLevel,
        jobTitle: jobTitle ?? this.jobTitle,
        workingHoursType: workingHoursType ?? this.workingHoursType,
        workingHours: workingHours ?? this.workingHours,
        thisWeekShifts: thisWeekShifts ?? this.thisWeekShifts);
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
        other.mainStatus == mainStatus &&
        other.employeeStatus == employeeStatus &&
        other.employmentType == employmentType &&
        other.jobLevel == jobLevel &&
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
        mainStatus.hashCode ^
        employeeStatus.hashCode ^
        employmentType.hashCode ^
        jobLevel.hashCode ^
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
      title: json['title'] != null ? Titles.fromJson(json['title']) : null,
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
  final int? id;
  final int? assetId;
  final String? title;
  final String? serialNumber;
  final String? description;
  final String? assetStatus;
  final String? assignmentStatus;
  final List<MediaFile>? signatureDocumentUrl;
  final String? startAt;
  final String? endsAt;

  Assets({
    this.id,
    this.assetId,
    this.title,
    this.serialNumber,
    this.description,
    this.assetStatus,
    this.assignmentStatus,
    this.signatureDocumentUrl,
    this.startAt,
    this.endsAt,
  });

  factory Assets.fromJson(Map<String, dynamic> json) {
    return Assets(
      id: json['id'],
      assetId: json['asset_id'],
      title: json['title'] ?? json['aassets'],
      serialNumber: json['serial_number'],
      description: json['description'],
      assetStatus: json['asset_status'],
      assignmentStatus: json['assignment_status'],
      signatureDocumentUrl: json['signature_document_url'] != null
          ? (json['signature_document_url'] is List
              ? (json['signature_document_url'] as List)
                  .map((i) => MediaFile.fromJson(i))
                  .toList()
              : (json['signature_document_url'] is String
                  ? [MediaFile(file: json['signature_document_url'])]
                  : null))
          : null,
      startAt: json['start_at'],
      endsAt: json['ends_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'title': title,
      'serial_number': serialNumber,
      'description': description,
      'asset_status': assetStatus,
      'assignment_status': assignmentStatus,
      'signature_document_url':
          signatureDocumentUrl?.map((e) => e.toJson()).toList(),
      'start_at': startAt,
      'ends_at': endsAt,
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
      title: json['title'] != null ? Titling.fromJson(json['title']) : null,
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
      payrollDeductions: json['payroll_deductions'] is List
          ? List<EmpPayrollDeduction>.from(json['payroll_deductions']
              .map((item) => EmpPayrollDeduction.fromJson(item)))
          : null,
      payrollSpecialBonus: json['payroll_special_bonus'] is List
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

class EmpRewardPenalty {
  final int? id;
  final String? type; // 'reward' | 'penalty'
  final String? category; // 'amount' | 'days'
  final num? amount;
  final String? reason;
  final String? dueDate;
  final String? action; // 'waiting' | 'approved' | 'applied' | 'cancelled'
  final bool? canCancel;
  final String? signatureDocumentUrl;
  final int? profileId;
  final String? createdAt;

  EmpRewardPenalty({
    this.id,
    this.type,
    this.category,
    this.amount,
    this.reason,
    this.dueDate,
    this.action,
    this.canCancel,
    this.signatureDocumentUrl,
    this.profileId,
    this.createdAt,
  });

  factory EmpRewardPenalty.fromJson(Map<String, dynamic> json) {
    return EmpRewardPenalty(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse(json['amount']?.toString() ?? ''),
      reason: json['reason'],
      dueDate: json['due_date'],
      action: json['action'],
      canCancel: json['can_cancel'],
      signatureDocumentUrl: json['signature_document_url'],
      profileId: json['profile_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'reason': reason,
      'due_date': dueDate,
      'action': action,
      'can_cancel': canCancel,
      'signature_document_url': signatureDocumentUrl,
      'profile_id': profileId,
      'created_at': createdAt,
    };
  }
}

class WeekendModel {
  final bool hasWeekends;
  final List<String> days;
  final List<String> specificDates;
  final List<RecurringRuleModel> recurringRules;

  WeekendModel({
    required this.hasWeekends,
    required this.days,
    required this.specificDates,
    required this.recurringRules,
  });

  factory WeekendModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WeekendModel(
        hasWeekends: true,
        days: [],
        specificDates: [],
        recurringRules: [],
      );
    }
    return WeekendModel(
      hasWeekends: json['has_weekends'] ?? true,
      days:
          (json['days'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      specificDates: (json['specific_dates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recurringRules: (json['recurring_rules'] as List<dynamic>?)
              ?.map(
                  (e) => RecurringRuleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_weekends': hasWeekends,
      'days': days,
      'specific_dates': specificDates,
      'recurring_rules': recurringRules.map((e) => e.toJson()).toList(),
    };
  }
}

class RecurringRuleModel {
  final String? type;
  final String? dayOfWeek;
  final String? firstDate;

  RecurringRuleModel({
    this.type,
    this.dayOfWeek,
    this.firstDate,
  });

  factory RecurringRuleModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecurringRuleModel();
    return RecurringRuleModel(
      type: json['type']?.toString(),
      dayOfWeek: json['day_of_week']?.toString(),
      firstDate: json['first_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'day_of_week': dayOfWeek,
      'first_date': firstDate,
    };
  }
}

class EmpTodayAttendance {
  final String? status;
  final String? clockInTime;
  final String? clockOutTime;

  EmpTodayAttendance({this.status, this.clockInTime, this.clockOutTime});

  factory EmpTodayAttendance.fromJson(Map<String, dynamic> json) {
    return EmpTodayAttendance(
      status: json['status']?.toString(),
      clockInTime: json['clock_in_time']?.toString(),
      clockOutTime: json['clock_out_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'clock_in_time': clockInTime,
      'clock_out_time': clockOutTime,
    };
  }
}

class EmpWeekShift {
  final int? id;
  final int? employeeId;
  final int? shiftId;
  final String? shiftName;
  final String? date;
  final String? status;
  final num? financialModifier;
  final String? startTime;
  final String? endTime;
  final String? breakDurationStartTime;
  final String? breakDurationEndTime;
  final num? breakDuration;
  final String? notes;

  EmpWeekShift({
    this.id,
    this.employeeId,
    this.shiftId,
    this.shiftName,
    this.date,
    this.status,
    this.financialModifier,
    this.startTime,
    this.endTime,
    this.breakDurationStartTime,
    this.breakDurationEndTime,
    this.breakDuration,
    this.notes,
  });

  factory EmpWeekShift.fromJson(Map<String, dynamic> json) {
    return EmpWeekShift(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      employeeId: json['employee_id'] is int
          ? json['employee_id']
          : int.tryParse(json['employee_id']?.toString() ?? ''),
      shiftId: json['shift_id'] is int
          ? json['shift_id']
          : int.tryParse(json['shift_id']?.toString() ?? ''),
      shiftName: json['shift_name']?.toString(),
      date: json['date']?.toString(),
      status: json['status']?.toString(),
      financialModifier: json['financial_modifier'] is num
          ? json['financial_modifier'] as num
          : num.tryParse(json['financial_modifier']?.toString() ?? ''),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      breakDurationStartTime: json['break_duration_start_time']?.toString(),
      breakDurationEndTime: json['break_duration_end_time']?.toString(),
      breakDuration: json['break_duration'] is num
          ? json['break_duration'] as num
          : num.tryParse(json['break_duration']?.toString() ?? ''),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'shift_id': shiftId,
      'shift_name': shiftName,
      'date': date,
      'status': status,
      'financial_modifier': financialModifier,
      'start_time': startTime,
      'end_time': endTime,
      'break_duration_start_time': breakDurationStartTime,
      'break_duration_end_time': breakDurationEndTime,
      'break_duration': breakDuration,
      'notes': notes,
    };
  }
}
