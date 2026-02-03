class CheckValuesFromApi{
  static List<dynamic> safeArray(dynamic value) {
    if (value is List) {
      return value;
    }
    return [];
  }
  static String getTitle(dynamic value, {required String langCode}) {
    if (value is Map<String, dynamic>) {
      return value[langCode] ?? value['en'] ?? "";
    } else if (value is String) {
      return value;
    }
    return "";
  }
}