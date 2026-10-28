import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/evaluation/shared/widgets/profile_tile_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_test/core/models/settings/user_settings_2.model.dart';

class GeneralSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  const GeneralSectionWidget({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    String convertTime(String time24h) {
      try {
        final parsed = DateFormat("HH:mm:ss").parseStrict(time24h);
        return DateFormat("h:mm a", LocalizationService.isArabic(context: context)? "ar" : "en").format(parsed);
      } catch (e) {
        try {
          final parsed = DateFormat("HH:mm").parseStrict(time24h);
          return DateFormat("h:mm a", LocalizationService.isArabic(context: context)? "ar" : "en").format(parsed);
        } catch (e2) {
          return time24h;
        }
      }
    }
    var jsonString;
    var us2Cache;
    jsonString = CacheHelper.getString("US2");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      us2Cache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings2 = UserSettings2Model.fromJson(us2Cache);
    }
    var json1String;
    var gCache;
    json1String = CacheHelper.getString("US1");
    if (json1String != null && json1String.isNotEmpty && json1String != "") {
      gCache = json.decode(json1String) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    final textStyle = AppStyles.primaryContent(context).copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
    final bool isMyProfile = gCache != null &&
        employee?.id != null &&
        employee!.id.toString() ==
            (gCache['empId'] ?? gCache['employee_profile_id']).toString();
    final String? us2WorkingHoursType = us2Cache is Map
        ? (us2Cache['worktime'] is Map
            ? us2Cache['worktime']['working_hours_type']?.toString()
            : null)
        : null;
    final bool isShifts = employee?.workingHoursType == "shifts" ||
        employee?.workingHours?.workingHoursType == "shifts" ||
        (isMyProfile && us2WorkingHoursType == "shifts") ||
        employee?.thisWeekShifts != null;
    final String? effectiveWorkingHoursType =
        (employee?.workingHoursType != null &&
                employee!.workingHoursType!.isNotEmpty)
            ? employee!.workingHoursType
            : (employee?.workingHours?.workingHoursType ??
                (isMyProfile ? us2WorkingHoursType : null));

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          if (employee?.jobDescription != null &&
              employee?.jobDescription?.isNotEmpty == true) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                AppStrings.jopDescription.tr().toUpperCase(),
                style: textStyle,
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(employee!.jobDescription!,
              style: AppStyles.greyContent(context).copyWith(
                fontWeight: FontWeight.w400,
                color:  const Color(0xff666666),
                fontSize: 13,
                height: 1.5,
              ),
              ),

            ),
            SizedBox(height: 24),
          ],
          if ((employee?.hireDate != null &&
                  employee?.hireDate?.isNotEmpty == true) ||
              (effectiveWorkingHoursType != null &&
                  effectiveWorkingHoursType.isNotEmpty) ||
              isShifts ||
              (employee?.workingHoursType != null &&
                  employee?.workingHours?.dailyWorkingHours?.isNotEmpty ==
                      true) ||
              (employee?.mainStatus != null &&
                  employee?.mainStatus?.isNotEmpty == true) ||
              (employee?.employeeStatus != null &&
                  employee?.employeeStatus?.isNotEmpty == true) ||
              (employee?.employmentType != null &&
                  employee?.employmentType?.isNotEmpty == true) ||
              (employee?.jobLevel != null &&
                  employee?.jobLevel?.isNotEmpty == true) ||
              (employee?.weekends != null &&
                  employee?.weekends?.isNotEmpty == true)) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                AppStrings.generalInfo.tr().toUpperCase(),
                style: textStyle,
              ),
            ),
            SizedBox(height: 12),
            // MAIN STATUS
            if (employee?.mainStatus != null && employee?.mainStatus?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.mainStatus.tr().toUpperCase(),
                trailingTitle: employee?.mainStatus.toString().tr().toUpperCase() ?? '',
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color: Color(AppColors.buttons)),
              ),
            // EMPLOYEE STATUS
            if (employee?.employeeStatus != null && employee?.employeeStatus?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.employeeStatus.tr().toUpperCase(),
                trailingTitle: employee?.employeeStatus.toString().tr().toUpperCase() ?? '',
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color: Color(AppColors.buttons)),
              ),
            // EMPLOYMENT TYPE
            if (employee?.employmentType != null && employee?.employmentType?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.employmentType.tr().toUpperCase(),
                trailingTitle: employee?.employmentType.toString().tr().toUpperCase() ?? '',
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color: Color(AppColors.buttons)),
              ),
            // JOB LEVEL
            if (employee?.jobLevel != null && employee?.jobLevel?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.jobLevel.tr().toUpperCase(),
                trailingTitle: employee?.jobLevel.toString().tr().toUpperCase() ?? '',
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color: Color(AppColors.buttons)),
              ),
            //HIRE DATE
            if (employee?.hireDate != null &&
                employee?.hireDate?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.hireDate.tr().toUpperCase(),
                trailingTitle: employee!.hireDate,
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
            //WORK HOURS TYPE
            if (effectiveWorkingHoursType != null &&
                effectiveWorkingHoursType.isNotEmpty)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.workHoursType.tr().toUpperCase(),
                trailingTitle: effectiveWorkingHoursType.toString().tr().toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
            if (!isShifts &&
                ((effectiveWorkingHoursType.toString().tr() == "عدد الساعات اليومية" ||
                        effectiveWorkingHoursType.toString().tr() == "According Hours Count") ||
                    (effectiveWorkingHoursType.toString().tr() == "ساعات حرة" ||
                        effectiveWorkingHoursType.toString().tr() == "Free Hours")))
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.hoursDailyCount.tr().toUpperCase(),
                trailingTitle: employee?.workingHours?.dailyWorkingHours ?? '',
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
            // WORK HOURS (only shown when NOT working on shifts)
            if (!isShifts &&
                employee?.workingHours != null &&
                (employee!.workingHours!.dailyWorkingHoursStart != null ||
                    employee!.workingHours!.dailyWorkingHoursEnd != null))
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.workHours.tr().toUpperCase(),
                trailingTitle: "${(employee!.workingHours!.dailyWorkingHoursStart)!=null ? convertTime(employee!.workingHours!.dailyWorkingHoursStart.toString())
                    : ""} : ${(employee!.workingHours!.dailyWorkingHoursEnd != null)? convertTime(employee!.workingHours!.dailyWorkingHoursEnd.toString()) : ""}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
            if (!isShifts &&
                employee?.workingHours != null &&
                (employee!.workingHours!.dailyWorkingHoursFrom != null ||
                    employee!.workingHours!.dailyWorkingHoursTo != null))
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.workHours.tr().toUpperCase(),
                trailingTitle: "${(employee!.workingHours!.dailyWorkingHoursFrom)!=null ? convertTime(employee!.workingHours!.dailyWorkingHoursFrom.toString())
                    : ""} : ${(employee!.workingHours!.dailyWorkingHoursTo != null)? convertTime(employee!.workingHours!.dailyWorkingHoursTo.toString()) : ""}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
            if (effectiveWorkingHoursType.toString().tr() == "ساعات ثابتة" ||
                effectiveWorkingHoursType.toString().tr() == "Fixed Hours" ||
                isShifts)
              if (employee?.workingHours?.allowedDelayMinutes != null)
                ProfileTile(
                  isTitleOnly: false,
                  isList: false,
                  title: AppStrings.allowedDelayMinutes.tr().toUpperCase(),
                  trailingTitle: "${employee?.workingHours?.allowedDelayMinutes ?? '0'} ${AppStrings.minutes.tr()}".toUpperCase(),
                  icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
                ),
            // THIS WEEK SHIFTS (shown instead of fixed working hours when type is shifts)
            if (isShifts)
              ThisWeekShiftsDisplayWidget(
                shifts: employee?.thisWeekShifts ?? const [],
              ),
            //WEEKENDS
            Builder(
              builder: (context) {
                WeekendModel? wModel;
                if (employee!.id.toString() == gCache['empId'].toString()) {
                  if (us2Cache['weekend'] is Map) {
                    wModel = WeekendModel.fromJson(us2Cache['weekend'] as Map<String, dynamic>);
                  } else if (us2Cache['weekend'] is List) {
                    wModel = WeekendModel(
                      hasWeekends: true,
                      days: (us2Cache['weekend'] as List).map((e) => e.toString()).toList(),
                      specificDates: [],
                      recurringRules: [],
                    );
                  }
                } else {
                  wModel = employee!.weekendModel;
                  if (wModel == null && employee!.weekends != null) {
                    wModel = WeekendModel(
                      hasWeekends: true,
                      days: employee!.weekends!,
                      specificDates: [],
                      recurringRules: [],
                    );
                  }
                }

                if (wModel != null) {
                  return WeekendDisplayWidget(weekendModel: wModel);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class WeekendDisplayWidget extends StatelessWidget {
  final WeekendModel weekendModel;

  const WeekendDisplayWidget({super.key, required this.weekendModel});

  String _formatRecurringRule(RecurringRuleModel rule) {
    // Basic translation mappings
    String typeText = rule.type ?? "";
    switch (rule.type) {
      case "first_day_of_month":
        typeText = "first_week_of_month".tr();
        break;
      case "last_day_of_month":
        typeText = "last_week_of_month".tr();
        break;
      case "last_week_of_month":
        typeText = "last_week_of_month".tr();
        break;
      case "take_week_day_skip_week":
        typeText = "take_week_skip_week".tr();
        break;
      case "take_week_day_skip_two_week":
        typeText = "take_week_skip_two_weeks".tr();
        break;
    }
    
    String day = (rule.dayOfWeek ?? "").tr();
    return "$typeText - $day";
  }

  @override
  Widget build(BuildContext context) {
    if (!weekendModel.hasWeekends) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.05))),
        child: Row(
          children: [
            Image.asset("assets/images/new-cale.png", width: 20, height: 20, color: Color(AppColors.buttons)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.weekends.tr().toUpperCase(),
                style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            Text(
              "no_weekends".tr(),
              style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/images/new-cale.png", width: 20, height: 20, color: Color(AppColors.buttons)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.weekends.tr().toUpperCase(),
                  style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
          if (weekendModel.days.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "regular_days".tr(),
                style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: Color(AppColors.buttons)),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: weekendModel.days.map((day) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(AppColors.cardBackground),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(AppColors.buttons).withOpacity(0.3)),
                  ),
                  child: Text(day.tr().toUpperCase(), style: AppStyles.blackContent(context).copyWith(fontSize: 11)),
                )).toList(),
              ),
            ),
          ],
          if (weekendModel.specificDates.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "specific_dates".tr(),
                style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: Color(AppColors.buttons)),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: weekendModel.specificDates.map((date) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(date, style: AppStyles.blackContent(context).copyWith(fontSize: 11)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
          if (weekendModel.recurringRules.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "recurring_rules".tr(),
                style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: Color(AppColors.buttons)),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: weekendModel.recurringRules.map((rule) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.repeat, size: 14, color: Colors.purple),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(_formatRecurringRule(rule), style: AppStyles.blackContent(context).copyWith(fontSize: 11)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ThisWeekShiftsDisplayWidget extends StatelessWidget {
  final List<EmpWeekShift> shifts;

  const ThisWeekShiftsDisplayWidget({super.key, required this.shifts});

  String _formatDate(BuildContext context, String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.parse(rawDate.trim());
      final locale = LocalizationService.isArabic(context: context) ? 'ar' : 'en';
      return DateFormat('EEE, yyyy-MM-dd', locale).format(parsed);
    } catch (_) {
      return rawDate.split(' ').first;
    }
  }

  String _formatTime(BuildContext context, String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return '';
    final locale = LocalizationService.isArabic(context: context) ? 'ar' : 'en';
    final clean = rawTime.trim();
    try {
      final parsed = DateTime.parse(clean);
      return DateFormat('h:mm a', locale).format(parsed);
    } catch (_) {}
    final timePart = clean.contains(' ') ? clean.split(' ').last : clean;
    try {
      final parsed = DateFormat('HH:mm:ss').parseStrict(timePart);
      return DateFormat('h:mm a', locale).format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('HH:mm').parseStrict(timePart);
        return DateFormat('h:mm a', locale).format(parsed);
      } catch (_) {
        return timePart;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/images/new-cale.png",
                width: 20,
                height: 20,
                color: Color(AppColors.buttons),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.thisWeekShifts.tr().toUpperCase(),
                  style: AppStyles.blackContent(context).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (shifts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                AppStrings.noShiftsThisWeek.tr(),
                style: AppStyles.blackContent(context).copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: shifts.map((shift) {
                  final startStr = _formatTime(context, shift.startTime);
                  final endStr = _formatTime(context, shift.endTime);
                  final dateStr = _formatDate(context, shift.date);
                  final breakStart = _formatTime(context, shift.breakDurationStartTime);
                  final breakEnd = _formatTime(context, shift.breakDurationEndTime);
                  final hasBreak = breakStart.isNotEmpty && breakEnd.isNotEmpty;
                  final hasModifier = shift.financialModifier != null &&
                      shift.financialModifier != 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(AppColors.cardBackground),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(AppColors.buttons).withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shift.shiftName ?? AppStrings.shifts.tr(),
                                style: AppStyles.blackContent(context).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(AppColors.buttons),
                                ),
                              ),
                            ),
                            if (hasModifier)
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "x${shift.financialModifier}",
                                  style: AppStyles.blackContent(context).copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            if (shift.status != null && shift.status!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(AppColors.buttons).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  shift.status!.tr().toUpperCase(),
                                  style: AppStyles.blackContent(context).copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(AppColors.buttons),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 13, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              dateStr,
                              style: AppStyles.blackContent(context)
                                  .copyWith(fontSize: 12),
                            ),
                            const Spacer(),
                            if (startStr.isNotEmpty || endStr.isNotEmpty) ...[
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "$startStr - $endStr",
                                style: AppStyles.blackContent(context).copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (hasBreak || (shift.breakDuration != null && shift.breakDuration! > 0)) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.free_breakfast_outlined,
                                  size: 13, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                hasBreak
                                    ? "${AppStrings.breakTime.tr()}: $breakStart - $breakEnd"
                                    : "${AppStrings.breakTime.tr()}: ${shift.breakDuration} ${AppStrings.hours.tr()}",
                                style: AppStyles.blackContent(context).copyWith(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

