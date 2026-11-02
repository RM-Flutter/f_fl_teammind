import 'dart:convert';

import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

/// بيانات حساب المستخدم من إعدادات start_app المخزنة (US1 و US2) كقيم جاهزة
/// لملء إجابات المساعد، مثل "قسمك هو {department}".
///
/// النصوص الصغيرة هنا (مثل "غير محدود") جزء من محتوى الإجابة نفسها، مثل ملف
/// المساعدة، لذلك هي بالعربية والإنجليزية داخل الملف وليست مفاتيح ترجمة.
abstract class UserDataRepo {
  static final RegExp _placeholder = RegExp(r'\{([a-z_]+)\}');

  /// القيم من الكاش الحالي.
  static Map<String, String> values(String lang) =>
      valuesFrom(_decode('US1'), _decode('US2'), lang, DateTime.now());

  static Map<String, dynamic> _decode(String key) {
    try {
      final raw = CacheHelper.getString(key);
      if (raw == null || raw.toString().isEmpty) return const {};
      final v = json.decode(raw);
      return v is Map<String, dynamic> ? v : const {};
    } catch (_) {
      return const {};
    }
  }

  /// يملأ [template] من [values]. أي سطر فيه قيمة غير موجودة يُحذف، فإن لم
  /// يبقَ شيء يرجع null (فيستخدم المساعد رسالة "لا توجد بيانات").
  static String? fill(String template, Map<String, String> values) {
    if (!_placeholder.hasMatch(template)) return template;
    final lines = <String>[];
    for (final line in template.split('\n')) {
      var ok = true;
      final filled = line.replaceAllMapped(_placeholder, (m) {
        final v = values[m.group(1)];
        if (v == null || v.trim().isEmpty) ok = false;
        return v ?? '';
      });
      if (ok) lines.add(filled);
    }
    final out = lines.join('\n').trim();
    return out.isEmpty ? null : out;
  }

  static bool hasPlaceholders(String template) => _placeholder.hasMatch(template);

  // ---------------------------------------------------------------- building

  static Map<String, String> valuesFrom(
      Map<String, dynamic> us1, Map<String, dynamic> us2, String lang, DateTime now) {
    final ar = lang == 'ar';
    String t(String en, String arText) => ar ? arText : en;
    final v = <String, String>{};
    void put(String key, String? value) {
      if (value != null && value.trim().isNotEmpty && value != 'null') v[key] = value.trim();
    }

    // الهوية
    put('name', _str(us1['name']));
    put('job_title', _str(us1['job_title']));
    put('email', _str(us1['email']));
    put('phone', _str(us1['phone']));
    if (v.containsKey('email')) {
      put('email_status',
          us1['email_verified_at'] != null ? t('verified', 'متوثّق') : t('not verified', 'مش متوثّق'));
    }
    if (v.containsKey('phone')) {
      put('phone_status',
          us1['phone_verified_at'] != null ? t('verified', 'متوثّق') : t('not verified', 'مش متوثّق'));
    }
    put('birthday', _date(us1['birthday']));
    put('hire_date', _date(us1['hire_date']));
    final hired = _parseDate(us1['hire_date']);
    if (hired != null && !hired.isAfter(now)) put('service_length', _duration(hired, now, ar));
    put('insurance_number', _str(_valueOf(us1['insurance_number'])));
    put('assets', _listText(_valueOf(us1['asset']), lang));
    final notifications = us1['new_notification_count'];
    if (notifications is num) put('new_notifications', notifications.toInt().toString());

    // القسم والأدوار
    final departments = us1['departments'] is Map ? us1['departments'] as Map : const {};
    String? deptName(dynamic id) => _translated(departments['$id'], lang);
    put('department', _departmentName(us1['department_info'], lang) ?? deptName(us1['department_id']));
    final roles = us1['role'];
    if (roles is List && roles.isNotEmpty) put('roles', roles.map((e) => '$e').join(', '));
    put('managed_departments', _names(us1['is_manager_in'], deptName));
    put('led_departments', _names(us1['is_teamleader_in'], deptName));
    if (us1['is_hr'] == true) put('special_access', t('HR', 'الـ HR'));
    if (us1['top_management'] == true) {
      put('special_access',
          [v['special_access'], t('top management', 'الإدارة العليا')].whereType<String>().join(', '));
    }

    // أوقات العمل
    final worktime = us2['worktime'];
    if (worktime is Map) {
      put('work_hours', _workHours(worktime, ar));
      put('allowed_delay', _str(worktime['allowed_delay_minutes']));
    }
    final weekend = us2['weekend'];
    if (weekend is List && weekend.isNotEmpty) {
      put('weekend', weekend.map((d) => _day('$d', ar)).join(ar ? '، ' : ', '));
    }
    final upcoming = _upcomingHolidays(us2['holidays'], lang, now);
    if (upcoming.isNotEmpty) {
      put('next_holiday', upcoming.first);
      put('holidays', upcoming.take(5).map((h) => '• $h').join('\n'));
    }

    // الرصيد
    put('balance', _balance(us2['balance'], ar, lang));
    put('last_login', _date(us2['last_login'], withTime: true));
    return v;
  }

  // ----------------------------------------------------------------- helpers

  static String? _str(dynamic v) {
    if (v == null) return null;
    if (v is String || v is num || v is bool) return '$v';
    return null;
  }

  /// كثير من حقول US1 بالشكل {title, value, type}.
  static dynamic _valueOf(dynamic v) => v is Map ? v['value'] : v;

  static String? _translated(dynamic v, String lang) {
    if (v is String) return v;
    if (v is Map) return _str(v[lang]) ?? _str(v['en']) ?? _str(v['ar']);
    return null;
  }

  /// department_info هو موديل القسم من الباك اند: العنوان قد يكون نصاً أو
  /// {en, ar} أو ضمن translations بمفتاح title.<lang>.
  static String? _departmentName(dynamic info, String lang) {
    if (info is! Map) return null;
    final translations = info['translations'];
    if (translations is List) {
      for (final tr in translations) {
        if (tr is Map && tr['key'] == 'title.$lang') return _str(tr['value']);
      }
    }
    return _translated(info['title'], lang) ?? _translated(info['name'], lang);
  }

  static String? _names(dynamic ids, String? Function(dynamic) name) {
    if (ids is! List || ids.isEmpty) return null;
    final names = ids.map(name).whereType<String>().toList();
    return names.isEmpty ? null : names.join(', ');
  }

  static String? _listText(dynamic v, String lang) {
    if (v is List && v.isNotEmpty) {
      final items = v
          .map((e) => e is Map
              ? (_translated(e['name'], lang) ??
                  _translated(e['title'], lang) ??
                  e.values.where((x) => x is String || x is num).join(' - '))
              : _str(e))
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();
      return items.isEmpty ? null : items.map((s) => '• $s').join('\n');
    }
    if (v is Map && v.isNotEmpty) {
      return v.entries.map((e) => '• ${e.key}: ${e.value}').join('\n');
    }
    return _str(v);
  }

  static DateTime? _parseDate(dynamic v) => v == null ? null : DateTime.tryParse('$v');

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String? _date(dynamic v, {bool withTime = false}) {
    final d = _parseDate(v);
    if (d == null) return null;
    final date = '${d.year}-${_two(d.month)}-${_two(d.day)}';
    return withTime ? '$date ${_two(d.hour)}:${_two(d.minute)}' : date;
  }

  static String _duration(DateTime from, DateTime to, bool ar) {
    var months = (to.year - from.year) * 12 + to.month - from.month;
    if (to.day < from.day) months--;
    final years = months ~/ 12;
    months %= 12;
    final parts = <String>[];
    if (years > 0) parts.add(ar ? _arCount(years, 'سنة', 'سنتين', 'سنين') : '$years year${years == 1 ? '' : 's'}');
    if (months > 0) parts.add(ar ? _arCount(months, 'شهر', 'شهرين', 'شهور') : '$months month${months == 1 ? '' : 's'}');
    if (parts.isEmpty) return ar ? 'أقل من شهر' : 'less than a month';
    return parts.join(ar ? ' و' : ', ');
  }

  /// العدد بالعامية: سنة / سنتين / 3 سنين / 11 سنة.
  static String _arCount(int n, String one, String two, String few) {
    if (n == 1) return one;
    if (n == 2) return two;
    if (n <= 10) return '$n $few';
    return '$n $one';
  }

  /// "09:00:00" -> "09:00"
  static String? _time(dynamic v) {
    final s = _str(v);
    if (s == null) return null;
    final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(s);
    return m == null ? s : '${_two(int.parse(m.group(1)!))}:${m.group(2)}';
  }

  static String? _workHours(Map w, bool ar) {
    switch ('${w['working_hours_type']}') {
      case 'fixed_hours':
        final from = _time(w['working_hours_from']), to = _time(w['working_hours_to']);
        if (from == null || to == null) return null;
        return ar ? 'من $from لـ $to' : '$from to $to';
      case 'free_hours':
        final h = _str(w['daily_working_hours']);
        final s = _time(w['working_hours_from_start']), e = _time(w['working_hours_from_end']);
        if (h == null) return null;
        if (s == null || e == null) return ar ? '$h ساعات في اليوم' : '$h hours a day';
        return ar
            ? '$h ساعات في اليوم، وتبدأ ما بين $s و$e'
            : '$h hours a day, starting between $s and $e';
      case 'according_hours_count':
        final h = _str(w['daily_working_hours']);
        return h == null ? null : (ar ? '$h ساعات في اليوم' : '$h hours a day');
      case 'shifts':
        return ar ? 'حسب الوردية بتاعتك' : 'according to your assigned shift';
    }
    return null;
  }

  static const _daysAr = {
    'saturday': 'السبت', 'sunday': 'الأحد', 'monday': 'الاثنين', 'tuesday': 'الثلاثاء',
    'wednesday': 'الأربعاء', 'thursday': 'الخميس', 'friday': 'الجمعة',
  };

  static String _day(String d, bool ar) {
    final key = d.toLowerCase().trim();
    if (ar) return _daysAr[key] ?? d;
    return key.isEmpty ? d : key[0].toUpperCase() + key.substring(1);
  }

  static List<String> _upcomingHolidays(dynamic holidays, String lang, DateTime now) {
    if (holidays is! List) return const [];
    final today = DateTime(now.year, now.month, now.day);
    final items = <(DateTime, String)>[];
    for (final h in holidays) {
      if (h is! Map) continue;
      final from = _parseDate(h['from']);
      final to = _parseDate(h['to']) ?? from;
      if (from == null || to == null || to.isBefore(today)) continue;
      final name = _translated(h['name'], lang) ?? '';
      final range = _date(h['from']) == _date(h['to']) || h['to'] == null
          ? _date(h['from'])!
          : '${_date(h['from'])} → ${_date(h['to'])}';
      items.add((from, name.isEmpty ? range : '$name ($range)'));
    }
    items.sort((a, b) => a.$1.compareTo(b.$1));
    return items.map((e) => e.$2).toList();
  }

  static String _num(dynamic v) {
    if (v is num) return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
    return '$v';
  }

  /// US2.balance: {typeId: {title: {en, ar}, take, max, available}} حيث -1 = غير محدود.
  static String? _balance(dynamic balance, bool ar, String lang) {
    if (balance is! Map || balance.isEmpty) return null;
    final lines = <String>[];
    for (final b in balance.values) {
      if (b is! Map) continue;
      final title = _translated(b['title'], lang);
      if (title == null) continue;
      final take = _num(b['take'] ?? 0);
      if (b['max'] == -1 || b['available'] == -1) {
        lines.add(ar ? '• $title: مفتوح (خدت $take)' : '• $title: unlimited (used $take)');
      } else {
        final available = _num(b['available']), max = _num(b['max']);
        lines.add(ar
            ? '• $title: فاضلك $available من $max (خدت $take)'
            : '• $title: $available of $max left (used $take)');
      }
    }
    return lines.isEmpty ? null : lines.join('\n');
  }
}
