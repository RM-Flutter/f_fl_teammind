/// يجهّز نص الإجابة للنطق (لا للعرض): صوت Google العربي يقرأ الأرقام والتواريخ
/// والرموز بالفصحى أو حرفاً حرفاً، فنحوّلها لكلام مصري قبل النطق.
///   2026-11-02    -> اتنين نوفمبر ألفين وستة وعشرين
///   9:30 الصبح    -> تسعة ونص الصبح
///   01012345678   -> صفر واحد صفر ... (الأرقام الطويلة رقم رقم)
///   QR / الـ HR   -> كيو آر / الإتش آر
abstract class SpeechText {
  static String prepare(String text, String lang) {
    var s = text;
    if (lang != 'ar') {
      return s
          .replaceAll('→', ' to ')
          .replaceAll('•', '')
          .replaceAll(RegExp(r'\s*\n+\s*'), '. ')
          .replaceAll(RegExp(r'\.(\s*\.)+'), '.')
          .replaceAll(RegExp(r' {2,}'), ' ')
          .trim();
    }
    s = _latinDigits(s);
    s = s.replaceAll(RegExp(r'Team\s*Mind', caseSensitive: false), 'تيم مايند');
    s = s.replaceAll(RegExp(r'Right\s*Mind', caseSensitive: false), 'رايت مايند');
    s = s.replaceAllMapped(RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{2})(?::\d{2})?)?\b'), (m) {
      final date = _date(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
      return m[4] == null ? date : '$date الساعة ${_clock(int.parse(m[4]!), int.parse(m[5]!))}';
    });
    s = s.replaceAllMapped(RegExp(r'\b(\d{1,2}):(\d{2})\b'),
        (m) => _clock(int.parse(m[1]!), int.parse(m[2]!)));
    s = s.replaceAllMapped(RegExp(r'(\d+)\s*%'), (m) => '${_number(int.parse(m[1]!))} في المية');
    // أرقام الموبايل والتأمين وما شابه: رقم رقم
    s = s.replaceAllMapped(RegExp(r'\+?\d[\d ]{5,}\d|\b0\d+\b'),
        (m) => m[0]!.replaceAll(RegExp(r'[^\d]'), '').split('').map((d) => _units[int.parse(d)]).join(' '));
    s = s.replaceAllMapped(RegExp(r'\b(\d+)\.(\d+)\b'), (m) {
      final whole = _number(int.parse(m[1]!));
      return m[2] == '5' ? '$whole ونص' : '$whole فاصلة ${_number(int.parse(m[2]!))}';
    });
    s = s.replaceAllMapped(RegExp(r'\d+'), (m) => _number(int.parse(m[0]!)));
    // اختصارات إنجليزية بحروف عربية حتى لا يتبدّل الصوت للإنجليزي
    s = s.replaceAllMapped(RegExp(r'(الـ\s*)?\b([A-Z]{2,5})\b'), (m) {
      final spelled = m[2]!.split('').map((c) => _letters[c] ?? c).join(' ');
      return m[1] != null ? 'ال$spelled' : spelled;
    });
    s = s
        .replaceAll('→', ' لحد ')
        .replaceAll('•', '')
        .replaceAll('+', ' زائد ')
        .replaceAll('/', ' أو ')
        .replaceAll(RegExp(r'\s*\n+\s*'), '. ')
        .replaceAll(RegExp(r'\.(\s*\.)+'), '.')
        .replaceAll(RegExp(r' {2,}'), ' ');
    return s.trim();
  }

  static String _latinDigits(String s) => s.replaceAllMapped(
      RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x0660}');

  static const _units = ['صفر', 'واحد', 'اتنين', 'تلاتة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'تمانية', 'تسعة', 'عشرة'];
  static const _teens = {
    11: 'حداشر', 12: 'اتناشر', 13: 'تلتاشر', 14: 'أربعتاشر', 15: 'خمستاشر',
    16: 'ستاشر', 17: 'سبعتاشر', 18: 'تمنتاشر', 19: 'تسعتاشر',
  };
  static const _tens = ['', '', 'عشرين', 'تلاتين', 'أربعين', 'خمسين', 'ستين', 'سبعين', 'تمانين', 'تسعين'];
  static const _hundreds = ['', 'مية', 'ميتين', 'تلتمية', 'ربعمية', 'خمسمية', 'ستمية', 'سبعمية', 'تمنمية', 'تسعمية'];
  static const _thousandsFew = ['', 'ألف', 'ألفين', 'تلات تلاف', 'أربع تلاف', 'خمس تلاف', 'ست تلاف', 'سبع تلاف', 'تمن تلاف', 'تسع تلاف', 'عشر تلاف'];

  /// العدد بالعامية المصرية (حتى 999999، وما فوقه رقم رقم).
  static String number(int n) => _number(n);

  static String _number(int n) {
    if (n >= 1000000) return '$n'.split('').map((d) => _units[int.parse(d)]).join(' ');
    if (n <= 10) return _units[n];
    if (n < 20) return _teens[n]!;
    if (n < 100) return n % 10 == 0 ? _tens[n ~/ 10] : '${_units[n % 10]} و${_tens[n ~/ 10]}';
    if (n < 1000) {
      final rest = n % 100;
      return rest == 0 ? _hundreds[n ~/ 100] : '${_hundreds[n ~/ 100]} و${_number(rest)}';
    }
    final k = n ~/ 1000, rest = n % 1000;
    final thousands = k <= 10 ? _thousandsFew[k] : '${_number(k)} ألف';
    return rest == 0 ? thousands : '$thousands و${_number(rest)}';
  }

  static const _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static String _date(int y, int m, int d) {
    if (m < 1 || m > 12) return '${_number(d)} / ${_number(m)} / ${_number(y)}';
    return '${_number(d)} ${_months[m - 1]} ${_number(y)}';
  }

  static const _hours = ['اتناشر', 'واحدة', 'اتنين', 'تلاتة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'تمانية', 'تسعة', 'عشرة', 'حداشر', 'اتناشر'];

  /// 9:30 -> تسعة ونص، 9:45 -> عشرة إلا ربع، 9:07 -> تسعة وسبعة دقايق.
  static String _clock(int h, int min) {
    String hour(int x) => _hours[x % 12 == 0 ? 12 : x % 12];
    switch (min) {
      case 0:
        return hour(h);
      case 15:
        return '${hour(h)} وربع';
      case 20:
        return '${hour(h)} وتلت';
      case 30:
        return '${hour(h)} ونص';
      case 40:
        return '${hour(h + 1)} إلا تلت';
      case 45:
        return '${hour(h + 1)} إلا ربع';
    }
    final minutes = min <= 10 && min > 2 ? '${_number(min)} دقايق' : '${_number(min)} دقيقة';
    return '${hour(h)} و$minutes';
  }

  static const _letters = {
    'A': 'إيه', 'B': 'بي', 'C': 'سي', 'D': 'دي', 'E': 'إي', 'F': 'إف', 'G': 'جي', 'H': 'إتش',
    'I': 'آي', 'J': 'جيه', 'K': 'كيه', 'L': 'إل', 'M': 'إم', 'N': 'إن', 'O': 'أو', 'P': 'بي',
    'Q': 'كيو', 'R': 'آر', 'S': 'إس', 'T': 'تي', 'U': 'يو', 'V': 'في', 'W': 'دبليو', 'X': 'إكس',
    'Y': 'واي', 'Z': 'زد',
  };
}
