import 'dart:convert';

/// A login that succeeded before, remembered so it can be picked again later.
class SavedAccount {
  /// `true` when the account logs in by phone, `false` for email.
  final bool isPhone;

  /// The email, or the phone number without its country code.
  final String identifier;

  /// Dial code with the plus sign (e.g. `+20`). Empty for email accounts.
  final String countryCode;

  final String password;

  /// Full name and photo URL of the user, copied from the user settings once
  /// the login finished. Empty until then.
  final String name;
  final String avatar;

  const SavedAccount({
    required this.isPhone,
    required this.identifier,
    required this.password,
    this.countryCode = '',
    this.name = '',
    this.avatar = '',
  });

  SavedAccount copyWith({String? name, String? avatar}) => SavedAccount(
        isPhone: isPhone,
        identifier: identifier,
        countryCode: countryCode,
        password: password,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
      );

  /// Identity used to de-duplicate: logging in again with the same email or
  /// phone replaces the saved entry instead of adding a second one.
  String get id =>
      isPhone ? '$countryCode$identifier' : identifier.trim().toLowerCase();

  /// What the list shows: the user's name. Until the name is known (just saved,
  /// or saved by an older version) a masked identifier is used instead, so the
  /// email / phone is never shown in full.
  String get displayName => name.isNotEmpty ? name : _masked;

  String get _masked {
    if (isPhone) {
      final tail = identifier.length > 2
          ? identifier.substring(identifier.length - 2)
          : identifier;
      return '$countryCode •••••$tail';
    }
    final at = identifier.indexOf('@');
    if (at <= 0) return '•••••';
    return '${identifier[0]}•••${identifier.substring(at)}';
  }

  Map<String, dynamic> toJson() => {
        'isPhone': isPhone,
        'identifier': identifier,
        'countryCode': countryCode,
        'password': password,
        'name': name,
        'avatar': avatar,
      };

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
        isPhone: json['isPhone'] == true,
        identifier: (json['identifier'] ?? '').toString(),
        countryCode: (json['countryCode'] ?? '').toString(),
        password: (json['password'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        avatar: (json['avatar'] ?? '').toString(),
      );

  static String encodeList(List<SavedAccount> accounts) =>
      jsonEncode(accounts.map((a) => a.toJson()).toList());

  static List<SavedAccount> decodeList(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((m) => SavedAccount.fromJson(Map<String, dynamic>.from(m)))
        .where((a) => a.identifier.isNotEmpty && a.password.isNotEmpty)
        .toList();
  }
}
