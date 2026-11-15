import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show BuildContext, DateUtils, debugPrint;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/notification_service/local_notification_service.dart';

/// Local (on-device, no backend push) attendance reminders:
/// - fixed hours: check-in 5 minutes before `working_hours_from`, check-out at `working_hours_to`;
/// - free hours: check-in reminder at the start of the window (`working_hours_from_start`);
/// - shifts: check-in 5 minutes before / check-out at each shift in the employee profile's
///   `this_week_shifts` (`/emp_requests/v1/employees/{employee_profile_id}`);
/// skipping weekend days (`weekend`, `specific_dates`, `recurring_rules`), official
/// holidays (`US2`) and approved day-leaves (`approval-system/v1/employee_requests/employee/my-approvables`);
/// - a yearly work-anniversary notification from `hire_date` (`US1`, fallback `US2`).
///
/// Uses a rolling window of [_windowDays] days that is rebuilt on every home load
/// (at most once a day unless the settings change), so it keeps working across
/// month boundaries and stays under iOS's 64 pending-notification limit.
abstract class CheckInScheduler {
  static const String _signatureKey = 'check_in_scheduler_signature';
  static const String _lastRunKey = 'check_in_scheduler_last_run';
  static const Duration _minInterval = Duration(hours: 3);
  static const int _windowDays = 14;
  static const int _checkInOutBaseId = 7000; // 7000..7000+2*_windowDays
  static const int _anniversaryId = 7999;

  static const Map<int, String> _weekdayNames = {
    DateTime.monday: 'monday',
    DateTime.tuesday: 'tuesday',
    DateTime.wednesday: 'wednesday',
    DateTime.thursday: 'thursday',
    DateTime.friday: 'friday',
    DateTime.saturday: 'saturday',
    DateTime.sunday: 'sunday',
  };

  static bool _running = false;

  static Future<void> scheduleNotifications(BuildContext context) async {
    if (kIsWeb || _running) return;
    _running = true;
    try {
      await _schedule(context);
    } catch (e) {
      debugPrint('CheckInScheduler error: $e');
    } finally {
      _running = false;
    }
  }

  static Map<String, dynamic> _readCache(String key) {
    final raw = CacheHelper.getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = json.decode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  /// Attendance package is on when any fingerprint type is allowed.
  /// The backend now sends `allowed_fingerprint_types` (type => true/false);
  /// `av_fingerprint` ('active_all' / 'active_some') is the older format.
  static bool _isCheckInActive(Map<String, dynamic> us1) {
    bool truthy(dynamic v) {
      if (v is bool) return v;
      final s = v?.toString().toLowerCase().trim();
      return s == 'true' || s == '1' || s == 'active_all' || s == 'active_some';
    }

    final allowed = us1['allowed_fingerprint_types'];
    if (allowed is Map && allowed.isNotEmpty) {
      return allowed.values.any(truthy);
    }
    final legacy = us1['av_fingerprint'];
    if (legacy is Map) return legacy.values.any(truthy);
    return false;
  }

  static String _day(DateTime d) => DateFormat('yyyy-MM-dd', 'en').format(d);

  static DateTime? _parseDate(dynamic v) {
    final s = v?.toString().trim() ?? '';
    if (s.length < 10) return null;
    return DateTime.tryParse(s.substring(0, 10));
  }

  static ({int h, int m})? _parseTime(dynamic v) {
    final parts = v?.toString().split(':') ?? const [];
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    if (h == null || m == null) return null;
    return (h: h, m: m);
  }

  /// Off days in [from, to] built from US2: weekend, holidays and approved leaves.
  static Set<String> _offDays(Map<String, dynamic> us2, DateTime from, DateTime to) {
    final off = <String>{};

    final weekendRaw = us2['weekend'];
    final weekend = (weekendRaw is List ? weekendRaw : [weekendRaw])
        .where((e) => e != null)
        .map((e) => e.toString().toLowerCase().trim())
        .toSet();
    final hasWeekends = !(us2['has_weekends'] == false ||
        us2['has_weekends']?.toString() == '0');
    final variableWeekend = !hasWeekends || weekend.contains('variable');

    // Extra weekend dates set on the employee (`specific_dates: [yyyy-MM-dd]`).
    if (hasWeekends && us2['specific_dates'] is List) {
      for (final d in us2['specific_dates'] as List) {
        final parsed = _parseDate(d);
        if (parsed != null) off.add(_day(parsed));
      }
    }
    final rules = hasWeekends && us2['recurring_rules'] is List
        ? (us2['recurring_rules'] as List).whereType<Map>().toList()
        : const <Map>[];

    final canUseHolidays = us2['can_use_holidays'];
    final holidaysApply = !(canUseHolidays == false ||
        canUseHolidays?.toString() == '0' ||
        canUseHolidays?.toString() == 'false');

    final holidays = <(DateTime, DateTime)>[];
    if (holidaysApply && us2['holidays'] is List) {
      for (final h in us2['holidays'] as List) {
        if (h is Map) {
          final s = _parseDate(h['from']);
          final e = _parseDate(h['to']) ?? s;
          if (s != null && e != null) holidays.add((s, e));
        } else {
          final d = _parseDate(h);
          if (d != null) holidays.add((d, d));
        }
      }
    }

    if (us2['approved_leave_days'] is List) {
      for (final d in us2['approved_leave_days'] as List) {
        final parsed = _parseDate(d);
        if (parsed != null) off.add(_day(parsed));
      }
    }

    for (var d = from; !d.isAfter(to); d = DateTime(d.year, d.month, d.day + 1)) {
      if (!variableWeekend && weekend.contains(_weekdayNames[d.weekday])) {
        off.add(_day(d));
        continue;
      }
      if (rules.any((r) => _matchesRecurringRule(r, d))) {
        off.add(_day(d));
        continue;
      }
      for (final (s, e) in holidays) {
        if (!d.isBefore(s) && !d.isAfter(e)) {
          off.add(_day(d));
          break;
        }
      }
    }
    return off;
  }

  /// Recurring weekend rule `{type, day_of_week, first_date}` (same types the
  /// employee profile shows): the weekday is off in the first / last week of the
  /// month, or every 2nd / 3rd week counted from `first_date`.
  static bool _matchesRecurringRule(Map rule, DateTime d) {
    final day = rule['day_of_week']?.toString().toLowerCase().trim();
    if (day == null || _weekdayNames[d.weekday] != day) return false;
    switch (rule['type']?.toString()) {
      case 'first_day_of_month':
        return d.day <= 7;
      case 'last_day_of_month':
      case 'last_week_of_month':
        return d.day > DateUtils.getDaysInMonth(d.year, d.month) - 7;
      case 'take_week_day_skip_week':
      case 'take_week_day_skip_two_week':
        final first = _parseDate(rule['first_date']);
        if (first == null || d.isBefore(first)) return false;
        final every = rule['type'] == 'take_week_day_skip_week' ? 2 : 3;
        final weeks = (DateTime.utc(d.year, d.month, d.day)
                    .difference(DateTime.utc(first.year, first.month, first.day))
                    .inDays /
                7)
            .floor();
        return weeks % every == 0;
    }
    return false;
  }

  /// GET returning the response body, or null on any failure.
  static Future<Map<String, dynamic>?> _get(
      BuildContext context, String url, Map<String, dynamic> query) async {
    try {
      final res = await DioApiService().get<Map<String, dynamic>>(
        url,
        context: context,
        dataKey: '',
        allData: true,
        queryParameters: query,
      );
      return res.success ? res.data : null;
    } catch (e) {
      debugPrint('CheckInScheduler: GET $url failed: $e');
      return null;
    }
  }

  /// Days covered by the employee's approved day-based requests (leaves).
  /// Hour-based requests (permissions) don't make the whole day off.
  static Future<Set<String>?> _approvedLeaveDays(
      BuildContext context, DateTime from, DateTime to) async {
    final body = await _get(
      context,
      '${AppConstants.baseUrl}/approval-system/v1/employee_requests/employee/my-approvables',
      {'status': 'approved', 'page': 1, 'per_page': 100},
    );
    if (body == null) return null;
    final list = body['approvables'] ?? (body['data'] is Map ? body['data']['approvables'] : null);
    final days = <String>{};
    if (list is! List) return days;
    for (final r in list.whereType<Map>()) {
      if (r['status']?.toString() != 'approved') continue;
      if (r['unit']?.toString().toLowerCase() == 'hours') continue;
      final s = _parseDate(r['date_from']);
      final e = _parseDate(r['date_to']) ?? s;
      if (s == null || e == null) continue;
      for (var d = s.isBefore(from) ? from : s;
          !d.isAfter(e) && !d.isAfter(to);
          d = DateTime(d.year, d.month, d.day + 1)) {
        days.add(_day(d));
      }
    }
    return days;
  }

  /// The employee's own profile: `this_week_shifts` and `working_hours`.
  static Future<Map?> _ownProfile(BuildContext context, Map<String, dynamic> us1) async {
    final id = us1['employee_profile_id'];
    if (id == null) return null;
    final body = await _get(context, '${AppConstants.baseUrl}/emp_requests/v1/employees/$id', {});
    if (body == null) return null;
    final emp = body['employee'] ?? (body['data'] is Map ? body['data']['employee'] : null);
    return emp is Map ? emp : null;
  }

  static Future<void> _schedule(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = today.add(const Duration(days: _windowDays - 1));
    final prefs = await SharedPreferences.getInstance();

    // Throttle the API calls: at most every [_minInterval], unless the cached
    // settings (US1/US2) or the day changed.
    final inputs = '${_day(today)}|${CacheHelper.getString('US1')}|${CacheHelper.getString('US2')}'.hashCode;
    final last = prefs.getString(_lastRunKey)?.split('|');
    if (last != null && last.length == 2 && last[0] == '$inputs') {
      final at = DateTime.tryParse(last[1]);
      if (at != null && now.difference(at) < _minInterval) return;
    }

    final us1 = _readCache('US1');
    final us2 = _readCache('US2');
    final active = _isCheckInActive(us1);
    final hireDate = _parseDate(us1['hire_date']) ?? _parseDate(us2['hire_date']);

    // Working hours: US2 `worktime`, completed by the profile's `working_hours`.
    final worktime = <String, dynamic>{
      if (us2['worktime'] is Map) ...Map<String, dynamic>.from(us2['worktime'] as Map),
    };
    final offDays = _offDays(us2, today, lastDay);
    var complete = true; // false when an API call failed → retry on next home load
    Map? profile;
    if (active) {
      final leaves = await _approvedLeaveDays(context, today, lastDay);
      if (leaves == null) complete = false;
      offDays.addAll(leaves ?? const {});

      final type = worktime['working_hours_type']?.toString();
      final needsProfile = type == 'shifts' ||
          (worktime['working_hours_from'] == null && worktime['working_hours_from_start'] == null);
      if (needsProfile && context.mounted) {
        profile = await _ownProfile(context, us1);
        if (profile == null) complete = false;
        if (profile?['working_hours'] is Map) {
          (profile!['working_hours'] as Map).forEach((k, v) => worktime.putIfAbsent('$k', () => v));
        }
        worktime.putIfAbsent('working_hours_type', () => profile?['working_hours_type']);
      }
    }

    // Reminders per day in the window: (check-in, check-out), either can be null.
    final reminders = <String, (DateTime?, DateTime?)>{};
    final type = worktime['working_hours_type']?.toString();
    if (active && type == 'shifts') {
      final shifts = profile?['this_week_shifts'] ?? profile?['This_week_shifts'];
      if (shifts is List) {
        for (final sh in shifts.whereType<Map>()) {
          final d = _parseDate(sh['date']);
          final st = _parseTime(sh['start_time']);
          if (d == null || st == null || d.isBefore(today) || d.isAfter(lastDay)) continue;
          if (offDays.contains(_day(d))) continue;
          final en = _parseTime(sh['end_time']);
          final inAt = DateTime(d.year, d.month, d.day, st.h, st.m);
          var outAt = en == null ? null : DateTime(d.year, d.month, d.day, en.h, en.m);
          if (outAt != null && !outAt.isAfter(inAt)) outAt = outAt.add(const Duration(days: 1)); // night shift
          reminders[_day(d)] = (inAt.subtract(const Duration(minutes: 5)), outAt);
        }
      }
    } else if (active) {
      final from = _parseTime(worktime['working_hours_from']);
      final to = _parseTime(worktime['working_hours_to']);
      final windowStart = _parseTime(worktime['working_hours_from_start']);
      for (int i = 0; i < _windowDays; i++) {
        final d = DateTime(today.year, today.month, today.day + i);
        if (offDays.contains(_day(d))) continue;
        if (from != null) {
          final inAt = DateTime(d.year, d.month, d.day, from.h, from.m);
          var outAt = to == null ? null : DateTime(d.year, d.month, d.day, to.h, to.m);
          if (outAt != null && !outAt.isAfter(inAt)) outAt = outAt.add(const Duration(days: 1));
          reminders[_day(d)] = (inAt.subtract(const Duration(minutes: 5)), outAt);
        } else if (windowStart != null) {
          // Free hours: check-out time depends on the actual check-in, so only remind to check in.
          reminders[_day(d)] = (DateTime(d.year, d.month, d.day, windowStart.h, windowStart.m), null);
        }
      }
    }

    // Skip the work when nothing changed since the last run today.
    final signature = json.encode([
      _day(today), active,
      reminders.entries.map((e) => [e.key, e.value.$1?.toIso8601String(), e.value.$2?.toIso8601String()]).toList(),
      hireDate == null ? null : _day(hireDate),
      CacheHelper.getString('lang'),
    ]);
    if (prefs.getString(_signatureKey) == signature) {
      if (complete) await prefs.setString(_lastRunKey, '$inputs|${now.toIso8601String()}');
      return;
    }

    // Only this scheduler schedules notifications, so clear every pending one
    // (also removes ids 1..N left by the old monthly scheduler) but keep the
    // ones already shown in the tray.
    await LocalNotificationService.cancelAllPending();

    final exact = await LocalNotificationService.canScheduleExact();
    int count = 0;

    Future<void> schedule(int id, String title, String body, DateTime at) async {
      if (!at.isAfter(now)) return;
      try {
        await LocalNotificationService.scheduleNotification(
          id: id, title: title, body: body, scheduledDate: at, exact: exact,
        );
        count++;
      } catch (e) {
        debugPrint('CheckInScheduler: failed to schedule $id at $at: $e');
      }
    }

    for (int i = 0; i < _windowDays; i++) {
      final d = DateTime(today.year, today.month, today.day + i);
      final r = reminders[_day(d)];
      if (r == null) continue;
      if (r.$1 != null) {
        await schedule(_checkInOutBaseId + i * 2, 'attendance_reminder'.tr(),
            'check_in_reminder_body'.tr(), r.$1!);
      }
      if (r.$2 != null) {
        await schedule(_checkInOutBaseId + i * 2 + 1, 'attendance_reminder'.tr(),
            'check_out_reminder_body'.tr(), r.$2!);
      }
    }

    // Next work anniversary (1 year or more), any month, at 10:00.
    if (hireDate != null) {
      var year = now.year;
      DateTime at() => DateTime(year, hireDate.month, hireDate.day, 10);
      if (!at().isAfter(now)) year++;
      if (year - hireDate.year >= 1) {
        await schedule(
          _anniversaryId,
          'happy_work_anniversary'.tr(),
          'thank_you_for_your_dedication'.tr(),
          at(),
        );
      }
    }

    if (complete) {
      await prefs.setString(_signatureKey, signature);
      await prefs.setString(_lastRunKey, '$inputs|${now.toIso8601String()}');
    }
    debugPrint('CheckInScheduler: scheduled $count notifications (active=$active, exact=$exact).');
  }
}
