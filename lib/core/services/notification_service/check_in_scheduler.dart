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
  static const int _checkInOutBaseId = 7000; // 7000..7799, see [_reminderId]
  static const String _punchesKey = 'check_in_scheduler_punches'; // 'yyyy-MM-dd|count'
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

  /// Web: the reminders are timers that die with the page, so the first run of each page
  /// load ignores the saved throttle and signature and schedules again.
  static bool _ranThisPage = false;

  /// On logout: cancels the pending reminders (they belong to the old account) and forgets
  /// the last run, so the next login schedules again right away.
  static Future<void> clear() async {
    _ranThisPage = false;
    try {
      await LocalNotificationService.cancelAllPending();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_signatureKey);
      await prefs.remove(_lastRunKey);
      await prefs.remove(_punchesKey);
    } catch (e) {
      debugPrint('CheckInScheduler.clear error: $e');
    }
  }

  /// Id of a day's check-in / check-out reminder. It depends on the date (not on the run),
  /// so [onPunch] can cancel today's reminder whenever it was scheduled.
  static int _reminderId(DateTime day, {required bool checkOut}) {
    final epochDay = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return _checkInOutBaseId + (epochDay % 400) * 2 + (checkOut ? 1 : 0);
  }

  /// Punches made today from this device (counted by [onPunch]).
  static int _localPunchesToday(SharedPreferences prefs, DateTime today) {
    final parts = prefs.getString(_punchesKey)?.split('|');
    if (parts == null || parts.length != 2 || parts[0] != _day(today)) return 0;
    return int.tryParse(parts[1]) ?? 0;
  }

  /// Call after the employee's own punch succeeded (online, or saved offline).
  /// The day's punches carry no in/out type, so the 1st punch counts as the check-in
  /// (cancels today's check-in reminder) and the 2nd as the check-out (cancels the
  /// check-out reminder too).
  static Future<void> onPunch() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final prefs = await SharedPreferences.getInstance();
      await _applyPunches(prefs, today, _localPunchesToday(prefs, today) + 1);
    } catch (e) {
      debugPrint('CheckInScheduler.onPunch error: $e');
    }
  }

  /// Saves today's punch count and cancels today's reminders it covers:
  /// 1+ punches → check-in reminder, 2+ → check-out reminder too.
  static Future<void> _applyPunches(SharedPreferences prefs, DateTime today, int count) async {
    if (count <= 0) return;
    await prefs.setString(_punchesKey, '${_day(today)}|$count');
    await LocalNotificationService.cancel(_reminderId(today, checkOut: false));
    if (count >= 2) {
      await LocalNotificationService.cancel(_reminderId(today, checkOut: true));
    }
  }

  /// Today's punches on the server (all devices, proxy punches included), or null on failure.
  /// `get_fingerprints` returns one record per day with its punches in `finger_datetime`.
  static Future<int?> _serverPunchesToday(BuildContext context, DateTime today) async {
    final body = await _get(
      context,
      '${AppConstants.baseUrl}/rm_fingerprint/v1/get_fingerprints',
      {'page': 1, 'order': 'desc'},
    );
    if (body == null) return null;
    final list = body['fingerprints'] ?? (body['data'] is Map ? body['data']['fingerprints'] : null);
    if (list is! List) return 0;
    var count = 0;
    for (final r in list.whereType<Map>()) {
      final day = _parseDate(r['finger_day']);
      if (day == null || _day(day) != _day(today)) continue;
      final times = r['finger_datetime'];
      count += times is List ? times.length : 1;
    }
    return count;
  }

  static Future<void> scheduleNotifications(BuildContext context) async {
    if (_running) return;
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

  /// Backend-computed off days for the current month (weekend, holidays and
  /// approved requests): `{off_days: [{date: yyyy-MM-dd}, ...]}`.
  static Future<Set<String>?> _backendOffDays(BuildContext context) async {
    final body = await _get(context, '${AppConstants.baseUrl}/emp_requests/v1/off-days-this-month', {});
    if (body == null) return null;
    final list = body['off_days'] ?? (body['data'] is Map ? body['data']['off_days'] : null);
    final days = <String>{};
    if (list is List) {
      for (final item in list) {
        final d = _parseDate(item is Map ? item['date'] : item);
        if (d != null) days.add(_day(d));
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
    final freshPage = kIsWeb && !_ranThisPage;
    final last = freshPage ? null : prefs.getString(_lastRunKey)?.split('|');
    if (last != null && last.length == 2 && last[0] == '$inputs') {
      final at = DateTime.tryParse(last[1]);
      if (at != null && now.difference(at) < _minInterval) {
        // No full run yet, but a punch from another device or by a manager (proxy)
        // must still drop today's reminder: check today's punches on the server.
        if (_isCheckInActive(_readCache('US1')) && context.mounted) {
          final server = await _serverPunchesToday(context, today);
          if (server != null && server > _localPunchesToday(prefs, today)) {
            await _applyPunches(prefs, today, server);
          }
        }
        return;
      }
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
      // Main source: the backend's off days for this month. The local
      // calculation and approved leaves cover the days after month end too.
      final backendOff = context.mounted ? await _backendOffDays(context) : null;
      if (backendOff == null) complete = false;
      offDays.addAll(backendOff ?? const {});

      final leaves = context.mounted ? await _approvedLeaveDays(context, today, lastDay) : null;
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

    // Already punched today: no check-in reminder today, and none for check-out after 2 punches.
    var punchesToday = _localPunchesToday(prefs, today);
    if (active && reminders[_day(today)] != null && context.mounted) {
      final server = await _serverPunchesToday(context, today);
      if (server != null && server > punchesToday) punchesToday = server;
    }
    if (punchesToday > _localPunchesToday(prefs, today)) {
      await prefs.setString(_punchesKey, '${_day(today)}|$punchesToday');
    }
    final todayReminders = reminders[_day(today)];
    if (todayReminders != null && punchesToday > 0) {
      reminders[_day(today)] = (null, punchesToday >= 2 ? null : todayReminders.$2);
    }

    // Skip the work when nothing changed since the last run today.
    final signature = json.encode([
      _day(today), active, punchesToday,
      reminders.entries.map((e) => [e.key, e.value.$1?.toIso8601String(), e.value.$2?.toIso8601String()]).toList(),
      hireDate == null ? null : _day(hireDate),
      CacheHelper.getString('lang'),
    ]);
    // Even a run with a failed API waits [_minInterval] before calling again,
    // so a missing endpoint isn't hit on every home load.
    await prefs.setString(_lastRunKey, '$inputs|${now.toIso8601String()}');
    if (!freshPage && prefs.getString(_signatureKey) == signature) return;

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
        await schedule(_reminderId(d, checkOut: false), 'attendance_reminder'.tr(),
            'check_in_reminder_body'.tr(), r.$1!);
      }
      if (r.$2 != null) {
        await schedule(_reminderId(d, checkOut: true), 'attendance_reminder'.tr(),
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

    if (complete) await prefs.setString(_signatureKey, signature);
    _ranThisPage = true;
    debugPrint('CheckInScheduler: scheduled $count notifications (active=$active, exact=$exact).');
  }
}
