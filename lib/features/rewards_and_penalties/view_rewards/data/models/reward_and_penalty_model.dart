
class RewardAndPenaltyModel {
  final int? id;
  final int? amount;
  final dynamic type; // Can be String or Type object
  final Payroll? payroll;
  final dynamic category; // Can be String or Category object
  final Profile? profile;
  final String? reason;
  final dynamic action; // Can be String or ActionLinks object
  final int? employeeId;
  final int? payrollId;
  final String? createdAt;
  final String? dueDate;
  final Manager? manager;
  final bool? canCancel; // New field
  final List<MediaFile>? files; // New field

  RewardAndPenaltyModel({
    this.id,
    this.amount,
    this.createdAt,
    this.dueDate,
    this.manager,
    this.type,
    this.payroll,
    this.category,
    this.reason,
    this.profile,
    this.action,
    this.employeeId,
    this.payrollId,
    this.canCancel,
    this.files,
  });

  factory RewardAndPenaltyModel.fromJson(Map<String, dynamic> json) {
    return RewardAndPenaltyModel(
      id: json['id'] as int?,
      amount: json['amount'] as int?,
      type: json['type'] is Map<String, dynamic> ? Type.fromJson(json['type']) : json['type'],
      category: json['category'] is Map<String, dynamic> ? Category.fromJson(json['category']) : json['category'],
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : (json['employee'] != null ? Profile.fromJson(json['employee']) : null),
      manager: json['manager'] != null ? Manager.fromJson(json['manager']) : null,
      reason: json['reason'] as String?,
      action: json['action'] is Map<String, dynamic> ? ActionLinks.fromJson(json['action']) : json['action'],
      employeeId: json['profile_id'] as int?,
      payrollId: json['payroll_id'] as int?,
      payroll: json['payroll'] != null ? Payroll.fromJson(json['payroll']) : null,
      createdAt: json['created_at'] as String?,
      dueDate: json['due_date'] as String?,
      canCancel: json['can_cancel'] as bool?,
      files: json['signature_document'] != null ? (json['signature_document'] as List).map((i) => MediaFile.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type is Type ? type?.toJson() : type,
      'category': category is Category ? category?.toJson() : category,
      'reason': reason,
      'action': action is ActionLinks ? action?.toJson() : action,
      'profile_id': employeeId,
      'can_cancel': canCancel,
      'signature_document': files?.map((e) => e.toJson()).toList(),
      'payroll_id': payrollId,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'RewardAndPenaltyModel(id: $id,profile: $profile, amount: $amount, type: $type, category: $category, reason: $reason, action: $action, employeeId: $employeeId, payrollId: $payrollId, files: $files)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RewardAndPenaltyModel &&
        other.id == id &&
        other.profile == profile &&
        other.amount == amount &&
        other.type == type &&
        other.category == category &&
        other.reason == reason &&
        other.action == action &&
        other.employeeId == employeeId &&
        other.payrollId == payrollId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        category.hashCode ^
    profile.hashCode ^
        reason.hashCode ^
        action.hashCode ^
        employeeId.hashCode ^
        payrollId.hashCode;
  }
}
class Payroll {
  final int? id;
  final String? dateFrom;
  final String? currency;

  Payroll({this.id, this.dateFrom, this.currency});

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'] as int?,
      dateFrom: json['date_from'] as String?,
      currency: json['currency'] as String?,
    );
  }
}
class Type {
  final String? key;
  final String? value;

  Type({this.key, this.value});

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      key: json['key'] as String?,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() => 'Type(key: $key, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Type && other.key == key && other.value == value;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}
class Profile {
  final int? id;
  final String? name;

  Profile({this.id, this.name});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Manager {
  final int? id;
  final String? name;

  Manager({this.id, this.name});

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Category {
  final String? key;
  final String? value;

  Category({this.key, this.value});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      key: json['key'] as String?,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() => 'Category(key: $key, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category && other.key == key && other.value == value;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}

class ActionLinks {
  final String? key;
  final String? value;

  ActionLinks({this.key, this.value});

  factory ActionLinks.fromJson(Map<String, dynamic> json) {
    return ActionLinks(
      key: json['key'] as String?,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() => 'ActionLinks(key: $key, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ActionLinks && other.key == key && other.value == value;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}

class MediaFile {
  final int? id;
  final String? type;
  final String? title;
  final String? file;
  final String? thumbnail;

  MediaFile({this.id, this.type, this.title, this.file, this.thumbnail});

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'] as int?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      file: json['file'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'file': file,
      'thumbnail': thumbnail,
    };
  }
}
