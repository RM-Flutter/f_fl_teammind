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
  });

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
      lastUpdateDate: json['last_update_date'],
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
      weekend: (json['weekend'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      worktime:
          json['worktime'] != null ? Worktime.fromJson(json['worktime']) : null,
      requestTypes: (json['request_types'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, RequestType.fromJson(value)),
      ),
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
      name: json['name'],
      from: json['from'],
      to: json['to'],
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
      ar: json['ar'],
      en: json['en'],
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
      ar: json['ar'],
      en: json['en'],
    );
  }
}

class Worktime {
  final String? workingHoursType;
  final String? workingHoursFrom;
  final String? workingHoursTo;

  Worktime({
    this.workingHoursType,
    this.workingHoursFrom,
    this.workingHoursTo,
  });

  factory Worktime.fromJson(Map<String, dynamic> json) {
    return Worktime(
      workingHoursType: json['working_hours_type'],
      workingHoursFrom: json['working_hours_from'],
      workingHoursTo: json['working_hours_to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'working_hours_type': workingHoursType,
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
      type: json['type'],
      acceptanceTime: json['acceptance_time'],
      maximum: json['maximum'],
      countingType: json['counting_type'],
      fields: json['fields'] != null ? Fields.fromJson(json['fields']) : null,
      rulesMessage: json['rules_message'],
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
      attachingFile: json['attaching_file'],
      moneyValue: json['money_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attaching_file': attachingFile,
      'money_value': moneyValue,
    };
  }
}
