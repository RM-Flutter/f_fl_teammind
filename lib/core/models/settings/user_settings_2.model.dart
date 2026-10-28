import 'app_settings_model.dart';

class UserSettings2Model extends AppSettingsModel {
  final DateTime? lastLogin;
  final List<String>? readList;
  final List<String>? bookmark;
  // final Map<String, Balance>? balance;
  final bool? canUseHolidays;
  final List<String>? weekend;
  final List<Holiday>? holidays;
  final Worktime? worktime;
  final Map<String, RequestType>? requestTypes;
  final List<String>? approvedLeaveDays;

  UserSettings2Model({
    required super.lastUpdateDate,
    this.lastLogin,
    this.readList,
    this.bookmark,
    // this.balance,
    this.canUseHolidays,
    this.weekend,
    this.holidays,
    this.worktime,
    this.requestTypes,
    this.approvedLeaveDays,
  });

  static List<String>? _parseWeekend(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [value.toString()];
  }

  factory UserSettings2Model.fromJson(Map<String, dynamic> json) {
    DateTime? parsedLastLogin;
    if (json['last_login'] is String) {
      try {
        parsedLastLogin = DateTime.parse(json['last_login']);
      } catch (e) {
        parsedLastLogin = null;
      }
    }

    return UserSettings2Model(
      lastUpdateDate: json['last_update_date']?.toString(),
      lastLogin: parsedLastLogin,
      readList: (json['read_list'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      bookmark: (json['bookmark'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      //   balance: json['balance'] != null
      // ? (json['balance'] as Map<String, dynamic>).map(
      //       (key, value) => MapEntry(key, Balance.fromJson(value)),
      // )
      //     : {},
      canUseHolidays: json['can_use_holidays'],
      weekend: _parseWeekend(json['weekend']),
      holidays: (json['holidays'] as List<dynamic>?)
          ?.map((e) => Holiday.fromJson(e as Map<String, dynamic>))
          .toList(),
      worktime:
      json['worktime'] != null ? Worktime.fromJson(json['worktime']) : null,
      requestTypes: json['request_types'] is List
          ? {}
          : (json['request_types'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, RequestType.fromJson(value)),
              ),
      approvedLeaveDays: (json['approved_leave_days'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'last_update_date': lastUpdateDate,
      'last_login': lastLogin?.toIso8601String(),
      'read_list': readList,
      'bookmark': bookmark,
      // 'balance': balance?.map((key, value) => MapEntry(key, value.toJson())),
      'can_use_holidays': canUseHolidays == true ? "1" : "0",
      'weekend': weekend,
      'holidays': holidays?.map((e) => e.toJson()).toList(),
      'worktime': worktime?.toJson(),
      'request_types':
      requestTypes?.map((key, value) => MapEntry(key, value.toJson())),
      'approved_leave_days': approvedLeaveDays,
    };
  }
}

class Balance {
  Title? title;
  var take;
  var type;
  var max;
  var available;
  var maxLevel;

  Balance({
    required this.title,
    required this.take,
    required this.type,
    required this.max,
    required this.available,
    required this.maxLevel,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      title: json['title'] != null ? Title.fromJson(json['title']) : null,
      take: json['take'],
      type: json['type'] ?? "",
      max: json['max'],
      available: json['available'],
      maxLevel: json['maxLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'take': take,
      'max': max,
      'available': available,
      'maxLevel': maxLevel,
    };
  }
}

class Holiday {
  final String? name;
  final String? from;
  final String? to;

  Holiday({
    this.name,
    this.from,
    this.to,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      name: json['name']?.toString(),
      from: json['from']?.toString(),
      to: json['to']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'from': from,
      'to': to,
    };
  }
}
class Title {
  String? ar;
  String? en;

  Title({
    this.ar,
    this.en,
  });

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title(
      ar: json['ar']?.toString(),
      en: json['en']?.toString(),
    );
  }
}
class ReqTitle {
  String? ar;
  String? en;

  ReqTitle({
    this.ar,
    this.en,
  });

  factory ReqTitle.fromJson(Map<String, dynamic> json) {
    return ReqTitle(
      ar: json['ar']?.toString(),
      en: json['en']?.toString(),
    );
  }
}

class Worktime {
  final String? workingHoursType;
  final String? workingHoursFrom;
  final String? workingHoursTo;
  final String? allowedDelayMinutes;
  final String? workingShiftType;

  bool get isShifts => workingHoursType == 'shifts';

  Worktime({
    this.workingHoursType,
    this.workingHoursFrom,
    this.workingHoursTo,
    this.allowedDelayMinutes,
    this.workingShiftType,
  });

  factory Worktime.fromJson(Map<String, dynamic> json) {
    return Worktime(
      workingHoursType: json['working_hours_type']?.toString(),
      workingHoursFrom: json['working_hours_from']?.toString(),
      workingHoursTo: json['working_hours_to']?.toString(),
      allowedDelayMinutes: json['allowed_delay_minutes']?.toString(),
      workingShiftType: json['working_shift_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'working_hours_type': workingHoursType,
      if (workingHoursFrom != null) 'working_hours_from': workingHoursFrom,
      if (workingHoursTo != null) 'working_hours_to': workingHoursTo,
      if (allowedDelayMinutes != null) 'allowed_delay_minutes': allowedDelayMinutes,
      if (workingShiftType != null) 'working_shift_type': workingShiftType,
    };
  }
}

class RequestType {
  var id;
  ReqTitle? title;
  final String? type;
  var acceptanceTime;
  var maximum;
  final String? countingType;
  final Fields? fields;
  final String? rulesMessage;

  RequestType({
    this.id,
    this.title,
    this.type,
    this.acceptanceTime,
    this.maximum,
    this.countingType,
    this.fields,
    this.rulesMessage,
  });

  factory RequestType.fromJson(Map<String, dynamic> json) {
    return RequestType(
      id: json['id'],
      title: json['title'] != null ? ReqTitle.fromJson(json['title']) : null,
      type: json['type']?.toString(),
      acceptanceTime: json['acceptance_time'],
      maximum: json['maximum'],
      countingType: json['counting_type']?.toString(),
      fields: json['fields'] != null ? Fields.fromJson(json['fields']) : null,
      rulesMessage: json['rules_message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'acceptance_time': acceptanceTime,
      'maximum': maximum,
      'counting_type': countingType,
      'fields': fields?.toJson(),
      'rules_message': rulesMessage,
    };
  }
}

class Fields {
  final String? attachingFile;
  final String? moneyValue;

  Fields({
    this.attachingFile,
    this.moneyValue,
  });

  factory Fields.fromJson(Map<String, dynamic> json) {
    return Fields(
      attachingFile: json['attaching_file']?.toString(),
      moneyValue: json['money_value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attaching_file': attachingFile,
      'money_value': moneyValue,
    };
  }
}
