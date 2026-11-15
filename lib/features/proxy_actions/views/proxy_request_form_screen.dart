import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/proxy_actions_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_field_shell.widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/widgets/text_form_widget.dart';
import '../data/models/proxy_employee_model.dart';
import '../data/models/proxy_request_model.dart';
import '../data/repos/proxy_repo.dart';
import 'widgets/proxy_employee_picker_sheet.dart';

/// Create a leave for an employee, or edit one created on their behalf ([editing] set).
///
/// Dates: a date range for day-based types, a day + start / end time for hour-based ones.
/// Duration: days minus the employee's weekend days and the official holidays (the same rules
/// as the app's own request form), or the hours between the two times. The server has the last
/// word: when its duration differs it replies "you made a calc error" with the right one, and the
/// user can resend with it.
///
/// Pops `true` after a successful save.
class ProxyRequestFormScreen extends StatefulWidget {
  final ProxyEmployeeModel? employee;
  final ProxyRequestModel? editing;

  const ProxyRequestFormScreen({super.key, this.employee, this.editing});

  bool get isEdit => editing != null;

  @override
  State<ProxyRequestFormScreen> createState() => _ProxyRequestFormScreenState();
}

class _RequestTypeOption {
  final String id;
  final String title;
  final String type;
  final bool halfDay;
  const _RequestTypeOption(this.id, this.title, this.type, this.halfDay);

  /// Hour-based types pick a time range; the others a date range.
  bool get isHours {
    final t = type.toLowerCase().trim();
    return t == 'hours' || t == 'minutes';
  }
}

class _ProxyRequestFormScreenState extends State<ProxyRequestFormScreen> {
  final TextEditingController _reason = TextEditingController();
  ProxyEmployeeModel? _employee;
  List<_RequestTypeOption> _types = const [];
  _RequestTypeOption? _type;
  DateTimeRange? _range;
  num? _duration;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _types = _loadTypes(context));
      if (widget.isEdit) _prefill(widget.editing!);
    });
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  /// Every request type of the company. The manager's own balance must not filter them (it is
  /// not the employee's balance); the server checks the employee's balance on save.
  /// Read from the parsed general settings, and straight from the cached `USG` when that gives
  /// nothing: the model drops all types when `request_types` comes as a list, or when one type's
  /// title is plain text instead of `{en, ar}`.
  List<_RequestTypeOption> _loadTypes(BuildContext context) {
    final isAr = LocalizationService.isArabic(context: context);
    String titleOf(dynamic title) {
      if (title is Map) return '${(isAr ? title['ar'] : title['en']) ?? title['en'] ?? title['ar'] ?? ''}';
      return title?.toString() ?? '';
    }

    bool isOn(dynamic v) => v == true || v == 1 || v == '1' || v == 'true';

    final fromModel = UserSettingConst.generalSettingsModel?.requestTypes?.values
            .map((t) => _RequestTypeOption(
                  '${t.id}',
                  isAr ? t.title.ar : t.title.en,
                  t.type,
                  isOn(t.halfDay),
                ))
            .toList() ??
        const <_RequestTypeOption>[];
    if (fromModel.isNotEmpty) return fromModel;

    // 2) The raw general settings (USG `request_types`, map or list).
    final fromUsg = <_RequestTypeOption>[];
    final usg = CacheHelper.getString('USG');
    if (usg != null && usg.isNotEmpty) {
      try {
        final raw = (json.decode(usg) as Map)['request_types'];
        final items = raw is Map ? raw.values : (raw is List ? raw : const []);
        fromUsg.addAll(items.whereType<Map>().where((t) => t['id'] != null).map((t) => _RequestTypeOption(
              '${t['id']}',
              titleOf(t['title']),
              '${t['type'] ?? 'days'}',
              isOn(t['half_day_leave']),
            )));
      } catch (e) {
        debugPrint('Proxy request types not read from USG: $e');
      }
    }
    if (fromUsg.isNotEmpty) return fromUsg;

    // 3) The balances shown on Home (US2 `balance`, keyed by request type id, each with its
    //    title and type). The same list the Home balance cards use.
    final us2 = CacheHelper.getString('US2');
    if (us2 == null || us2.isEmpty) return const [];
    try {
      final balance = (json.decode(us2) as Map)['balance'];
      if (balance is! Map) return const [];
      return balance.entries
          .where((e) => e.value is Map)
          .map((e) {
            final b = e.value as Map;
            final type = '${b['type'] ?? ''}'.toLowerCase();
            return _RequestTypeOption(
              '${b['id'] ?? e.key}',
              titleOf(b['title']),
              type == 'hours' || type == 'minutes' ? type : 'days',
              isOn(b['half_day_leave']),
            );
          })
          .where((t) => t.title.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Proxy request types not read from US2: $e');
      return const [];
    }
  }

  void _selectType(String? id) {
    final t = _types.where((e) => e.id == id).firstOrNull;
    if (t == null) return;
    setState(() {
      final sameUnit = _type != null && _type!.isHours == t.isHours;
      _type = t;
      if (sameUnit && _range != null) {
        // Same kind of dates (days ↔ days, hours ↔ hours): keep them, only the duration rules
        // (half day) may change.
        _duration = _computeDuration(_range!);
      } else {
        // Days ↔ hours: the old dates do not fit the new type.
        _range = null;
        _duration = null;
      }
    });
  }

  void _prefill(ProxyRequestModel r) {
    final from = DateTime.tryParse(r.dateFrom);
    final to = DateTime.tryParse(r.dateTo) ?? from;
    setState(() {
      _type = _types.where((e) => e.id == '${r.typeId}').firstOrNull;
      if (from != null && to != null) _range = DateTimeRange(start: from, end: to);
      _duration = num.tryParse(r.duration) ?? (_range == null ? null : _computeDuration(_range!));
      _reason.text = r.reason;
    });
  }

  // ---------------------------------------------------------------- dates

  Future<void> _pickDates() async {
    final type = _type;
    if (type == null) {
      AlertsService.warning(
          context: context, title: AppStrings.warning.tr(), message: AppStrings.pleaseSelectRequestType.tr());
      return;
    }
    final now = DateTime.now();
    DateTimeRange? picked;
    if (!type.isHours) {
      picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2),
        initialDateRange: _range == null
            ? null
            : DateTimeRange(start: _dateOnly(_range!.start), end: _dateOnly(_range!.end)),
      );
    } else {
      final day = await showDatePicker(
        context: context,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2),
        initialDate: _range?.start ?? now,
      );
      if (day == null || !mounted) return;
      final start = await showTimePicker(
        context: context,
        helpText: AppStrings.startTime.tr(),
        initialTime: TimeOfDay.fromDateTime(_range?.start ?? now),
      );
      if (start == null || !mounted) return;
      final end = await showTimePicker(
        context: context,
        helpText: AppStrings.endTime.tr(),
        initialTime: TimeOfDay.fromDateTime(_range?.end ?? now.add(const Duration(hours: 1))),
      );
      if (end == null || !mounted) return;
      final from = DateTime(day.year, day.month, day.day, start.hour, start.minute);
      final to = DateTime(day.year, day.month, day.day, end.hour, end.minute);
      if (!to.isAfter(from)) {
        AlertsService.warning(
            context: context, title: AppStrings.warning.tr(), message: 'start_time_before_end'.tr());
        return;
      }
      picked = DateTimeRange(start: from, end: to);
    }
    if (picked == null || !mounted) return;
    setState(() {
      _range = picked;
      _duration = _computeDuration(picked!);
    });
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Hours between the two times, or the days of the range minus the employee's weekend days and
  /// the official holidays. Never throws: a settings value it cannot read is skipped.
  num _computeDuration(DateTimeRange range) {
    final type = _type;
    if (type != null && type.isHours) {
      return double.parse((range.duration.inMinutes / 60).toStringAsFixed(1));
    }
    final start = _dateOnly(range.start);
    final end = _dateOnly(range.end);
    final total = DateTime.utc(end.year, end.month, end.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays +
        1;
    final today = _dateOnly(DateTime.now());
    if (type?.halfDay == true && total == 1 && start == today) return 0.5;

    Map? us2;
    Map? usg;
    try {
      us2 = json.decode(CacheHelper.getString('US2') ?? '') as Map?;
    } catch (_) {}
    try {
      usg = json.decode(CacheHelper.getString('USG') ?? '') as Map?;
    } catch (_) {}

    const names = {1: 'monday', 2: 'tuesday', 3: 'wednesday', 4: 'thursday', 5: 'friday', 6: 'saturday', 7: 'sunday'};
    final weekend = (us2?['weekend'] is List) ? (us2!['weekend'] as List).map((e) => '$e').toList() : <String>[];
    final variable = weekend.contains('variable');
    final weekendDays = <DateTime>{};
    if (!variable) {
      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        if (weekend.contains(names[d.weekday])) weekendDays.add(d);
      }
    }

    var holidays = 0;
    final canUseHolidays = us2?['can_use_holidays'] == true || us2?['can_use_holidays'] == 1;
    if (canUseHolidays && usg?['holidays'] is List) {
      for (final h in usg!['holidays'] as List) {
        final holiday = h is Map ? (h['holiday'] is Map ? h['holiday'] : h) : null;
        final from = DateTime.tryParse('${holiday?['from'] ?? ''}');
        final to = DateTime.tryParse('${holiday?['to'] ?? ''}') ?? from;
        if (from == null || to == null) continue;
        for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
          final inHoliday = !d.isBefore(_dateOnly(from)) && !d.isAfter(_dateOnly(to));
          if (inHoliday && !weekendDays.contains(d)) holidays++;
        }
      }
    }
    final days = total - weekendDays.length - holidays;
    return days < 0 ? 0 : days;
  }

  /// "Sunday, 15 November 2026", "15 – 17 November 2026", "15 Nov – 2 Dec 2026", or the day with
  /// "10:00 AM – 12:30 PM" for hour-based types, in the app language.
  String? _rangeText(BuildContext context) {
    final r = _range;
    if (r == null) return null;
    final loc = context.locale.languageCode;
    final sep = loc == 'ar' ? '،' : ',';
    if (_type?.isHours == true) {
      final time = intl.DateFormat.jm(loc);
      return '${intl.DateFormat('EEEE$sep d MMMM yyyy', loc).format(r.start)}  ·  '
          '${time.format(r.start)} – ${time.format(r.end)}';
    }
    final s = _dateOnly(r.start);
    final e = _dateOnly(r.end);
    if (s == e) return intl.DateFormat('EEEE$sep d MMMM yyyy', loc).format(s);
    if (s.year == e.year && s.month == e.month) {
      return '${intl.DateFormat('d', loc).format(s)} – ${intl.DateFormat('d MMMM yyyy', loc).format(e)}';
    }
    if (s.year == e.year) {
      return '${intl.DateFormat('d MMMM', loc).format(s)} – ${intl.DateFormat('d MMMM yyyy', loc).format(e)}';
    }
    return '${intl.DateFormat('d MMM yyyy', loc).format(s)} – ${intl.DateFormat('d MMM yyyy', loc).format(e)}';
  }

  String? _durationText() {
    final d = _duration;
    if (d == null) return null;
    final value = d == d.roundToDouble() ? d.toInt().toString() : d.toString();
    final unit = _type?.isHours == true ? AppStrings.hours.tr() : AppStrings.days.tr();
    return '$value $unit';
  }

  // ---------------------------------------------------------------- save

  Future<void> _changeEmployee() async {
    final picked = await ProxyEmployeePickerSheet.show(context,
        ability: ProxyActionsService.leaveCreate, title: 'proxy_choose_employee'.tr());
    if (picked != null && mounted) setState(() => _employee = picked);
  }

  Map<String, dynamic> _body({num? durationOverride}) {
    final f = intl.DateFormat('yyyy-MM-dd HH:mm:ss', 'en');
    return {
      'emp_request_type_id': _type!.id,
      'date_from': f.format(_range!.start),
      'date_to': f.format(_range!.end),
      'duration': '${durationOverride ?? _duration}',
      'reason': _reason.text.trim(),
    };
  }

  Future<ProxyResult> _send(Map<String, dynamic> body) {
    return widget.isEdit
        ? ProxyRepo.updateRequest(context, requestId: widget.editing!.id, body: body)
        : ProxyRepo.createRequest(context, employeeProfileId: _employee!.id, body: body);
  }

  Future<void> _submit() async {
    if (_saving) return;
    String? missing;
    if (!widget.isEdit && _employee == null) missing = 'proxy_choose_employee'.tr();
    if (_type == null) missing ??= AppStrings.pleaseSelectRequestType.tr();
    if (_range == null || _duration == null) missing ??= AppStrings.pleaseSelectRequestDuration.tr();
    if (_reason.text.trim().isEmpty) missing ??= AppStrings.pleaseEnterTheReasonForTheRequest.tr();
    if (missing != null) {
      AlertsService.info(context: context, title: AppStrings.information.tr(), message: missing);
      return;
    }

    setState(() => _saving = true);
    try {
      var result = await _send(_body());
      if (!mounted) return;
      // The server computed another duration: offer to resend with it.
      final serverDuration = num.tryParse('${result.data['duration'] ?? ''}');
      if (!result.success && serverDuration != null) {
        final unit = _type!.isHours ? AppStrings.hours.tr() : AppStrings.days.tr();
        final resend = await AlertsService.confirmMessage(
          context,
          result.message ?? AppStrings.failed.tr(),
          message: '${AppStrings.doYouWantToResendYourRequestWithTheCorrectDurationis.tr()} $serverDuration $unit ?',
        );
        if (!resend || !mounted) return;
        result = await _send(_body(durationOverride: serverDuration));
        if (!mounted) return;
      }
      if (result.success) {
        AlertsService.success(
          context: context,
          title: AppStrings.success.tr(),
          message: result.message ?? (widget.isEdit ? 'proxy_request_updated'.tr() : 'proxy_request_created'.tr()),
        );
        Navigator.of(context).pop(true);
      } else {
        AlertsService.error(
          context: context,
          title: AppStrings.failed.tr(),
          message: result.message ?? AppStrings.somethingWentWrong.tr(),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final rangeText = _rangeText(context);
    final durationText = _durationText();
    return TemplatePage(
      pageContext: context,
      title: widget.isEdit ? 'proxy_edit_request'.tr() : 'proxy_new_request'.tr(),
      backgroundColor: Color(AppColors.background),
      showBookmark: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.listBottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('proxy_on_behalf_of'.tr()),
            if (widget.isEdit)
              AppCard.listItem(
                context: context,
                title: widget.editing!.employeeName,
                subtitle: widget.editing!.department,
                avatarUrl: widget.editing!.employeeAvatar,
              )
            else if (_employee != null)
              AppCard.listItem(
                context: context,
                title: _employee!.name,
                subtitle: _employee!.subtitle,
                avatarUrl: _employee!.avatar,
                trailing: TextButton(onPressed: _changeEmployee, child: Text('proxy_change'.tr())),
              )
            else
              AppFieldShell(
                onTap: _changeEmployee,
                trailingIcon: Icons.person_search_rounded,
                child: Text('proxy_choose_employee'.tr(), style: AppField.hintStyle),
              ),
            const SizedBox(height: AppSpacing.section),
            _label(AppStrings.requestType.tr()),
            defaultDropdownField(
              context: context,
              value: _type?.id,
              title: AppStrings.requestType.tr(),
              items: [
                for (final t in _types)
                  DropdownMenuItem<String>(value: t.id, child: Text(t.title, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: _selectType,
            ),
            if (_types.isEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('proxy_no_request_types'.tr(), style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
            ],
            const SizedBox(height: AppSpacing.md),
            _label(AppStrings.requestTime.tr()),
            AppFieldShell(
              onTap: _pickDates,
              trailingIcon: _type?.isHours == true ? Icons.schedule_rounded : Icons.calendar_month_rounded,
              child: Text(
                rangeText ?? AppStrings.requestTime.tr(),
                style: rangeText == null ? AppField.hintStyle : AppField.valueStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (durationText != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.timelapse_rounded, size: 16, color: Color(AppColors.buttons)),
                  const SizedBox(width: AppSizes.s6),
                  Text(
                    '${'proxy_duration'.tr()}: $durationText',
                    style: AppStyles.greyContent(context).copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _label(AppStrings.reason.tr()),
            TextField(
              controller: _reason,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(hintText: AppStrings.reason.tr()),
            ),
            const SizedBox(height: AppSpacing.section),
            CustomElevatedButton(
              width: double.infinity,
              title: widget.isEdit ? AppStrings.saveChanges.tr() : 'proxy_submit_request'.tr(),
              backgroundColor: Color(AppColors.secondaryButton),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.s8),
        child: Text(text, style: AppStyles.heading(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
      );
}
