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

import '../../../../../../core/models/settings/user_settings_2.model.dart';

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
      fontSize: 14.sp,
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          if (employee?.jobDescription != null &&
              employee?.jobDescription?.isNotEmpty == true) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Text(
                AppStrings.jopDescription.tr().toUpperCase(),
                style: textStyle,
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Text(employee!.jobDescription!,
              style: AppStyles.greyContent(context).copyWith(
                fontWeight: FontWeight.w400,
                color: const Color(0xff666666),
                fontSize: 13.sp,
                height: 1.5.h,
              ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
          if ((employee?.hireDate != null &&
                  employee?.hireDate?.isNotEmpty == true) ||
              (employee?.workingHoursType != null &&
                  employee?.workingHoursType?.isNotEmpty == true) ||
              (employee?.workingHoursType != null &&
                  employee?.workingHours?.dailyWorkingHours?.isNotEmpty ==
                      true) ||
              (employee?.weekends != null &&
                  employee?.weekends?.isNotEmpty == true)) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Text(
                AppStrings.generalInfo.tr().toUpperCase(),
                style: textStyle,
              ),
            ),
            SizedBox(height: 12.h),
            //HIRE DATE
            if (employee?.hireDate != null &&
                employee?.hireDate?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.hireDate.tr().toUpperCase(),
                trailingTitle: employee!.hireDate,
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color: const Color(0xff2F88FF)),
              ),
            //WORK HOURS TYPE
            if (employee?.workingHoursType != null &&
                employee?.workingHoursType?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.workHoursType.tr().toUpperCase(),
                trailingTitle: employee?.workingHoursType.toString().tr().toUpperCase() ?? '',
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color: const Color(0xff2F88FF)),
              ),
            if ((employee?.workingHoursType.toString().tr() == "عدد الساعات اليومية" ||
                employee?.workingHoursType.toString().tr() == "According Hours Count" ) || (employee?.workingHoursType.toString().tr() == "ساعات حرة" ||
                employee?.workingHoursType.toString().tr() == "Free Hours" ))
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.hoursDailyCount.tr().toUpperCase(),
                trailingTitle: employee!.workingHours!.dailyWorkingHours ?? '',
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color: const Color(0xff2F88FF)),
              ),
            // WORK HOURS
            if ((employee!.workingHours!.dailyWorkingHoursStart != null || employee!.workingHours!.dailyWorkingHoursEnd != null))
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.workHours.tr().toUpperCase(),
                trailingTitle: "${(employee!.workingHours!.dailyWorkingHoursStart)!=null ? convertTime(employee!.workingHours!.dailyWorkingHoursStart.toString())
                    : ""} : ${(employee!.workingHours!.dailyWorkingHoursEnd != null)? convertTime(employee!.workingHours!.dailyWorkingHoursEnd.toString()) : ""}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color: const Color(0xff2F88FF)),
              ),if ((employee!.workingHours!.dailyWorkingHoursFrom != null || employee!.workingHours!.dailyWorkingHoursTo != null))
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.workHours.tr().toUpperCase(),
                trailingTitle: "${(employee!.workingHours!.dailyWorkingHoursFrom)!=null ? convertTime(employee!.workingHours!.dailyWorkingHoursFrom.toString())
                    : ""} : ${(employee!.workingHours!.dailyWorkingHoursTo != null)? convertTime(employee!.workingHours!.dailyWorkingHoursTo.toString()) : ""}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color: const Color(0xff2F88FF)),
              ),
            if (employee?.workingHoursType.toString().tr() == "ساعات ثابتة" ||
                employee?.workingHoursType.toString().tr() == "Fixed Hours" )
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.allowedDelayMinutes.tr().toUpperCase(),
                trailingTitle: "${employee!.workingHours!.allowedDelayMinutes} ${AppStrings.minutes.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color: const Color(0xff2F88FF)),
              ),
            //WEEKENDS
            if (employee!.id.toString() != gCache['empId'].toString() && employee!.weekends != null&& employee!.weekends!.isNotEmpty )
              ProfileTile(
                isTitleOnly: false,
                isList: true,
                title: AppStrings.weekends.tr().toUpperCase(),
                weekends: employee!.weekends!.map((e) => e.toString().tr().toUpperCase()).toList(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color: const Color(0xff2F88FF)),
              ),
            if (employee!.id.toString() == gCache['empId'].toString() && us2Cache['weekend'] != null&&us2Cache['weekend']!.isNotEmpty )
              ProfileTile(
                isTitleOnly: false,
                isList: true,
                title: AppStrings.weekends.tr().toUpperCase(),
                weekends: (us2Cache['weekend'] as List).map((e) => e.toString().tr().toUpperCase()).toList(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color: const Color(0xff2F88FF)),
              ),
          ],
        ],
      ),
    );
  }
}
