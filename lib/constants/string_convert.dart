class StringConvert{
  static String sanitizeDateString(String dateStr) {
    final arabicNumeralsRegExp = RegExp(r'[٠-٩]');
    const arabicToEnglishDigits = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    if (arabicNumeralsRegExp.hasMatch(dateStr)) {
      dateStr = dateStr.split('').map((char) {
        return arabicToEnglishDigits[char] ?? char;
      }).join('');
    }

    return dateStr;
  }
  static String sanitizeDateStringArabic(String dateStr) {
    final arabicNumeralsRegExp = RegExp(r'[0-9]');
    const arabicToEnglishDigits = {
      '0' : '٠',
      '1': '١',
      '2' : '٢',
      '3' : '٣',
      '4' : '٤',
      '5' : '٥',
      '6' : '٦',
      '7': '٧',
      '8' : '٨',
      '9' : '٩',
    };

    if (arabicNumeralsRegExp.hasMatch(dateStr)) {
      dateStr = dateStr.split('').map((char) {
        return arabicToEnglishDigits[char] ?? char;
      }).join('');
    }

    return dateStr;
  }
}