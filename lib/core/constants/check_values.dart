class CheckValuesFromApi{
  static List<dynamic> safeArray(dynamic value) {
    if (value is List) {
      return value;
    }
    return [];
  }
}