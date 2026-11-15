import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/string_convert.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
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
import 'package:app_test/features/requests/add/controller/add_new_request_controller.dart';
import '../data/models/proxy_employee_model.dart';
import '../data/models/proxy_request_model.dart';
import '../data/repos/proxy_repo.dart';
import 'widgets/proxy_employee_picker_sheet.dart';

/// Create a leave for an employee, or edit one created on their behalf ([editing] set).
/// Request types, date pickers and the duration (weekends, holidays, half day) come from the
/// app's request logic ([AddNewRequestController]), so the duration matches what the server
/// computes. When it still does not, the server replies "you made a calc error" with the right
/// duration and the user can resend with it.
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
}

class _ProxyRequestFormScreenState extends State<ProxyRequestFormScreen> {
  final AddNewRequestController _form = AddNewRequestController();
  ProxyEmployeeModel? _employee;
  List<_RequestTypeOption> _types = const [];
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
    _form.dispose();
    super.dispose();
  }

  /// Every request type of the company. The manager's own balance must not filter them (it is
  /// not the employee's balance); the server checks the employee's balance on save.
  List<_RequestTypeOption> _loadTypes(BuildContext context) {
    Map<String, RequestTypeOrList>? types = UserSettingConst.generalSettingsModel?.requestTypes;
    if (types == null) {
      final usg = CacheHelper.getString('USG');
      if (usg != null && usg.isNotEmpty) {
        try {
          types = GeneralSettingsModel.fromJson(json.decode(usg)).requestTypes;
        } catch (_) {}
      }
    }
    final isAr = LocalizationService.isArabic(context: context);
    return (types?.values ?? const <RequestTypeOrList>[])
        .map((t) => _RequestTypeOption(
              '${t.id}',
              isAr ? t.title.ar : t.title.en,
              t.type,
              t.halfDay == true || t.halfDay == 1,
            ))
        .toList();
  }

  _RequestTypeOption? get _selectedType {
    final id = _form.selectReqType;
    for (final t in _types) {
      if (t.id == id) return t;
    }
    return null;
  }

  void _selectType(String? id) {
    final t = _types.where((e) => e.id == id).firstOrNull;
    if (t == null) return;
    setState(() {
      _form.selectReqType = t.id;
      _form.selectedRequestType = {'id': t.id, 'type': t.type};
      _form.reqType = t.type;
      _form.halfDay = t.halfDay;
      // A new type can change days ↔ hours: pick the dates again.
      _form.selectedDateOrDatetimeRange = null;
      _form.duration = null;
      _form.controller.clear();
    });
  }

  void _prefill(ProxyRequestModel r) {
    final from = DateTime.tryParse(r.dateFrom);
    final to = DateTime.tryParse(r.dateTo) ?? from;
    setState(() {
      if (r.typeId != null) _selectType('${r.typeId}');
      if (from != null && to != null) {
        _form.selectedDateOrDatetimeRange = DateTimeRange(start: from, end: to);
        _form.controller.text = _form.formatDateTimeRange(context, _form.selectedDateOrDatetimeRange!);
      }
      _form.duration = num.tryParse(r.duration);
      _form.reasonController.text = r.reason;
    });
  }

  Future<void> _pickDates() async {
    if (_selectedType == null) {
      AlertsService.warning(
          context: context, title: AppStrings.warning.tr(), message: AppStrings.pleaseSelectRequestType.tr());
      return;
    }
    await _form.selectDate(context);
    if (mounted) setState(() {});
  }

  Future<void> _changeEmployee() async {
    final picked = await ProxyEmployeePickerSheet.show(context,
        ability: ProxyActionsService.leaveCreate, title: 'proxy_choose_employee'.tr());
    if (picked != null && mounted) setState(() => _employee = picked);
  }

  Map<String, dynamic> _body({num? durationOverride}) {
    final f = intl.DateFormat('yyyy-MM-dd HH:mm:ss', 'en');
    final range = _form.selectedDateOrDatetimeRange!;
    return {
      'emp_request_type_id': _form.selectReqType,
      'date_from': StringConvert.sanitizeDateString(f.format(range.start)),
      'date_to': StringConvert.sanitizeDateString(f.format(range.end)),
      'duration': '${durationOverride ?? _form.duration}',
      'reason': _form.reasonController.text.trim(),
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
    if (_selectedType == null) missing ??= AppStrings.pleaseSelectRequestType.tr();
    if (_form.selectedDateOrDatetimeRange == null || _form.duration == null) {
      missing ??= AppStrings.pleaseSelectRequestDuration.tr();
    }
    if (_form.reasonController.text.trim().isEmpty) {
      missing ??= AppStrings.pleaseEnterTheReasonForTheRequest.tr();
    }
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
        final resend = await AlertsService.confirmMessage(
          context,
          result.message ?? AppStrings.failed.tr(),
          message: '${AppStrings.doYouWantToResendYourRequestWithTheCorrectDurationis.tr()} '
              '$serverDuration ${_form.getHoursOrDayesStringDependsOnRequestType()} ?',
        );
        if (!resend || !mounted) return;
        result = await _send(_body(durationOverride: serverDuration));
        if (!mounted) return;
      }
      if (result.success) {
        AlertsService.success(
          context: context,
          title: AppStrings.success.tr(),
          message: result.message ??
              (widget.isEdit ? 'proxy_request_updated'.tr() : 'proxy_request_created'.tr()),
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

  @override
  Widget build(BuildContext context) {
    final type = _selectedType;
    final durationText = _form.duration == null || _form.selectedDateOrDatetimeRange == null
        ? null
        : '${_form.duration} ${_form.getHoursOrDayesStringDependsOnRequestType()}';
    return ChangeNotifierProvider<AddNewRequestController>.value(
      value: _form,
      child: TemplatePage(
        pageContext: context,
        title: widget.isEdit ? 'proxy_edit_request'.tr() : 'proxy_new_request'.tr(),
        backgroundColor: Color(AppColors.background),
        showBookmark: false,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.listBottom),
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
                value: type?.id,
                title: AppStrings.requestType.tr(),
                items: [
                  for (final t in _types)
                    DropdownMenuItem<String>(
                      value: t.id,
                      child: Text(t.title, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: _selectType,
              ),
              const SizedBox(height: AppSpacing.md),
              _label(AppStrings.requestTime.tr()),
              AppFieldShell(
                onTap: _pickDates,
                trailingIcon: Icons.calendar_month_rounded,
                child: Text(
                  _form.controller.text.isEmpty ? AppStrings.requestTime.tr() : _form.controller.text,
                  style: _form.controller.text.isEmpty ? AppField.hintStyle : AppField.valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (durationText != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${'proxy_duration'.tr()}: $durationText',
                  style: AppStyles.greyContent(context).copyWith(fontSize: 12),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _label(AppStrings.reason.tr()),
              TextField(
                controller: _form.reasonController,
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
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.s8),
        child: Text(text, style: AppStyles.heading(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
      );
}
