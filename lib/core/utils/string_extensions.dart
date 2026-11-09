/// Text helpers shared by the whole app.
extension TitleCaseString on String {
  /// "mohamed ryad" / "HR MANAGEMENT" -> "Mohamed Ryad" / "HR Management".
  /// Arabic and other scripts without capitals are returned untouched; words that are all
  /// capitals and 3 letters or fewer (HR, CV, EGP, ID) are kept as abbreviations.
  String get titleCase {
    final text = trim();
    if (text.isEmpty) return text;
    return text.split(RegExp(r'\s+')).map((w) {
      if (w.isEmpty) return w;
      final isAbbreviation = w.length <= 3 && w == w.toUpperCase() && RegExp(r'[A-Z]').hasMatch(w);
      if (isAbbreviation) return w;
      final first = w[0].toUpperCase();
      return first + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
