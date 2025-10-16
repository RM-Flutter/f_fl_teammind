import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/models/settings/user_settings_2.model.dart';
import '../../../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../../../routing/app_router.dart';
import '../../../models/employee_profile.model.dart';
import '../profile_tile.widget.dart';

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
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary,
      fontSize: AppSizes.s13,
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          if (employee?.jobDescription != null &&
              employee?.jobDescription?.isNotEmpty == true) ...[
            AutoSizeText(
              AppStrings.jopDescription.tr().toUpperCase(),
              style: textStyle,
            ),
            gapH8,
            Text(employee!.jobDescription!,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: Color(AppColors.textC4),
              fontSize: AppSizes.s12,
            ),
            ),
            gapH20,
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
            AutoSizeText(
              AppStrings.generalInfo.tr().toUpperCase(),
              style: textStyle,
            ),
            gapH8,
            //HIRE DATE
            if (employee?.hireDate != null &&
                employee?.hireDate?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.hireDate.tr().toUpperCase(),
                trailingTitle: employee!.hireDate,
                icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
              ),
            //WORK HOURS TYPE
            if (employee?.workingHoursType != null &&
                employee?.workingHoursType?.isNotEmpty == true)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.workHoursType.tr().toUpperCase(),
                trailingTitle: employee?.workingHoursType.toString().tr() ?? '',
                icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
              ),
            if ((employee?.workingHoursType.toString().tr() == "عدد الساعات اليومية" ||
                employee?.workingHoursType.toString().tr() == "According Hours Count" ) || (employee?.workingHoursType.toString().tr() == "ساعات حرة" ||
                employee?.workingHoursType.toString().tr() == "Free Hours" ))
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.hoursDailyCount.tr().toUpperCase(),
                trailingTitle: employee!.workingHours!.dailyWorkingHours ?? '',
                icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
              ),
            // WORK HOURS
            if (employee!.workingHours! != null &&
                (employee!.workingHours!.dailyWorkingHoursStart != null || employee!.workingHours!.dailyWorkingHoursEnd != null))
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.workHours.tr().toUpperCase(),
                trailingTitle: "${(employee!.workingHours!.dailyWorkingHoursStart)!=null ? convertTime(employee!.workingHours!.dailyWorkingHoursStart.toString())
                    : ""} : ${(employee!.workingHours!.dailyWorkingHoursEnd != null)? convertTime(employee!.workingHours!.dailyWorkingHoursEnd.toString()) : ""}" ?? '',
                icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
              ),if (employee!.workingHours! != null &&
                (employee!.workingHours!.dailyWorkingHoursFrom != null || employee!.workingHours!.dailyWorkingHoursTo != null))
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.workHours.tr().toUpperCase(),
                trailingTitle: "${(employee!.workingHours!.dailyWorkingHoursFrom)!=null ? convertTime(employee!.workingHours!.dailyWorkingHoursFrom.toString())
                    : ""} : ${(employee!.workingHours!.dailyWorkingHoursTo != null)? convertTime(employee!.workingHours!.dailyWorkingHoursTo.toString()) : ""}" ?? '',
                icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
              ),
            if (employee?.workingHoursType.toString().tr() == "ساعات ثابتة" ||
                employee?.workingHoursType.toString().tr() == "Fixed Hours" )
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.allowedDelayMinutes.tr().toUpperCase(),
                trailingTitle: "${employee!.workingHours!.allowedDelayMinutes} ${AppStrings.minutes.tr()}" ?? '',
                icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
              ),
            //WEEKENDS
            if (employee!.id.toString() != gCache['empId'].toString() && employee!.weekends != null&& employee!.weekends!.isNotEmpty )Container(
                margin: EdgeInsets.only(bottom: AppSizes.s12),
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.s12, horizontal: AppSizes.s10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.s8),
                    border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child:  Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(AppColors.black),) ?? const SizedBox.shrink(),
                    gapW4,
                    Text(AppStrings.weekends.tr().toUpperCase(),style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(AppColors.black))),
                    gapW12,
                    Expanded(
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.38,
                          alignment:LocalizationService.isArabic(context: context)? Alignment.centerLeft : Alignment.centerRight,
                          height: 18,
                          child: ListView.separated(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              reverse: false,
                              itemBuilder: (context, index) => AutoSizeText(
                                employee!.weekends![index].toString().tr() ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff000000)),
                                textAlign: LocalizationService.isArabic(context: context)?TextAlign.end : TextAlign.start,
                              ),
                              separatorBuilder: (context, index) => SizedBox(width: 10,child: Text(index == employee!.weekends!.length - 1 ? "" : ",", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff000000)),),),
                              itemCount: employee!.weekends!.length),
                        )
                    ),
                  ],
                )
              ),
            if (employee!.id.toString() == gCache['empId'].toString() && us2Cache['weekend'] != null&&us2Cache['weekend']!.isNotEmpty ) Container(
              margin: const EdgeInsets.only(bottom: AppSizes.s12),
              padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.s12, horizontal: AppSizes.s10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.s8),
                  border: Border.all(color: Colors.grey.withOpacity(0.1))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
                  gapW4,
                  Text(AppStrings.weekends.tr().toUpperCase(),style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(AppColors.black))),
                  gapW12,
                  Expanded(
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.38,
                        alignment: LocalizationService.isArabic(context: context)?Alignment.centerLeft: Alignment.centerRight,
                        height: 18,
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            reverse: false,
                            itemBuilder: (context, index) => AutoSizeText(
                              us2Cache['weekend']![index].toString().tr() ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff000000)),
                              textAlign: LocalizationService.isArabic(context: context)?TextAlign.end:TextAlign.start,
                            ),
                            separatorBuilder: (context, index) => SizedBox(width: 10,child: Text(index == us2Cache['weekend']!.length - 1 ? "" : ",", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff000000)),),),
                            itemCount: us2Cache['weekend']!.length),
                      )
                  ),
                ],
              )
            ),
          ],
          // gapH24,
          // Center(
          //   child: CustomElevatedButton(
          //     backgroundColor: Theme.of(context).colorScheme.black,
          //     titleSize: AppSizes.s12,
          //     title: AppStrings.viewFingerPrints.tr().toUpperCase(),
          //     onPressed: () async => await context.pushNamed(
          //       AppRoutes.employeeFingerprint.name,
          //       extra: {},
          //       pathParameters: {
          //         'lang': context.locale.languageCode,
          //         'employeeName': employee?.name ?? '',
          //         'employeeId': employee?.id?.toString() ?? '',
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
