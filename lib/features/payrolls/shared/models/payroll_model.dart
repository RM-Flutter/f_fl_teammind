
class PayrollModel {
  var id;
  String? profile;
  var profileId;
  String? dateFrom;
  String? dateTo;
  var basicSalary;
  var salaryAdvance;
  var netPayable;
  String? currency;
  List<PayrollDeductions>? payrollDeductions;
  var payrollTotalDeductions;
  List<PayrollSpecialBonus>? payrollSpecialBonus;
  var payrollTotalSpecialBonus;
  Status? status;
  var scheduleDate;

  PayrollModel(
      {this.id,
        this.profile,
        this.profileId,
        this.dateFrom,
        this.dateTo,
        this.basicSalary,
        this.salaryAdvance,
        this.netPayable,
        this.currency,
        this.payrollDeductions,
        this.payrollTotalDeductions,
        this.payrollSpecialBonus,
        this.payrollTotalSpecialBonus,
        this.status,
        this.scheduleDate});

  PayrollModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profile = json['profile'];
    profileId = json['profile_id'];
    dateFrom = json['date_from'];
    dateTo = json['date_to'];
    basicSalary = json['basic_salary'];
    salaryAdvance = json['salary_advance'];
    netPayable = json['net_payable'];
    currency = json['currency'];
    if (json['payroll_deductions'] != null) {
      payrollDeductions = <PayrollDeductions>[];
      json['payroll_deductions'].forEach((v) {
        payrollDeductions!.add(new PayrollDeductions.fromJson(v));
      });
    }
    payrollTotalDeductions = json['payroll_total_deductions'];
    if (json['payroll_special_bonus'] != null) {
      payrollSpecialBonus = <PayrollSpecialBonus>[];
      json['payroll_special_bonus'].forEach((v) {
        payrollSpecialBonus!.add(new PayrollSpecialBonus.fromJson(v));
      });
    }
    payrollTotalSpecialBonus = json['payroll_total_special_bonus'];
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
    scheduleDate = json['schedule_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['profile'] = this.profile;
    data['profile_id'] = this.profileId;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['basic_salary'] = this.basicSalary;
    data['salary_advance'] = this.salaryAdvance;
    data['net_payable'] = this.netPayable;
    data['currency'] = this.currency;
    if (this.payrollDeductions != null) {
      data['payroll_deductions'] =
          this.payrollDeductions!.map((v) => v.toJson()).toList();
    }
    data['payroll_total_deductions'] = this.payrollTotalDeductions;
    if (this.payrollSpecialBonus != null) {
      data['payroll_special_bonus'] =
          this.payrollSpecialBonus!.map((v) => v.toJson()).toList();
    }
    data['payroll_total_special_bonus'] = this.payrollTotalSpecialBonus;
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    data['schedule_date'] = this.scheduleDate;
    return data;
  }
}

class PayrollDeductions {
  Title? title;
  var value;
  bool? nextPeriodOnly;

  PayrollDeductions({this.title, this.value, this.nextPeriodOnly});

  PayrollDeductions.fromJson(Map<String, dynamic> json) {
    if (json['title'] is String) {
      title = Title(en: json['title'], ar: json['title']);
    } else if (json['title'] is Map<String, dynamic>) {
      title = Title.fromJson(json['title']);
    }
    value = json['value'];
    nextPeriodOnly = json['next_period_only'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    data['next_period_only'] = this.nextPeriodOnly;
    return data;
  }
}
class Title {
  String? en;
  String? ar;

  Title({this.en, this.ar});

  Title.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

}
class PayrollSpecialBonus {
  Titles? title;
  var value;
  bool? nextPeriodOnly;

  PayrollSpecialBonus({this.title, this.value, this.nextPeriodOnly});

  PayrollSpecialBonus.fromJson(Map<String, dynamic> json) {
    if (json['title'] is String) {
      title = Titles(en: json['title'], ar: json['title']);
    } else if (json['title'] is Map<String, dynamic>) {
      title = Titles.fromJson(json['title']);
    }
    value = json['value'];
    nextPeriodOnly = json['next_period_only'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    data['next_period_only'] = this.nextPeriodOnly;
    return data;
  }
}

class Status {
  String? key;
  String? value;

  Status({this.key, this.value});

  Status.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}
class Titles {
  String? en;
  String? ar;

  Titles({this.en, this.ar});

  Titles.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ar'] = this.ar;
    data['en'] = this.en;
    return data;
  }
}
