import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/routing/app_router.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../modules/requests/views/widgets/custom_request_details_button.widget.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../models/reward_and_penalty.model.dart';

class RewardAndPenaltyDetailsModalSheet extends StatelessWidget {
  var rewardAndpenalty;
   RewardAndPenaltyDetailsModalSheet(
      {super.key, required this.rewardAndpenalty});

  @override
  Widget build(BuildContext context) {
    String? formatDateString(String? dateString) {
      if (dateString == null) return null;
      DateTime dateTime = DateFormat('yyyy-MM-dd', "en").parse(dateString);
      String formattedDate = DateFormat('EEEE, dd MMM yyyy',LocalizationService.isArabic(context: context) ? "ar" : "en").format(dateTime);
      return formattedDate;
    }     String? formatDateString2(String? dateString) {
      if (dateString == null) return null;
      DateTime dateTime = DateFormat('yyyy-MM-dd', "en").parse(dateString);
      String formattedDate = DateFormat('MMM yyyy',LocalizationService.isArabic(context: context) ? "ar" : "en").format(dateTime);
      return formattedDate;
    }

    // الحصول على معلومات المستخدم الحالي
    var jsonString = CacheHelper.getString("US1");
    var gCache;
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
    }

    // التحقق من الشروط لعرض زر الشكوى
    bool canShowComplaintButton = false;
    if (gCache != null && rewardAndpenalty.employeeId != null && gCache['employee_profile_id'] != null) {
      // 1. التحقق من أن المستخدم هو صاحب العقوبة
      final bool isOwner = rewardAndpenalty.employeeId.toString() == gCache['employee_profile_id'].toString();
      
      // 2. التحقق من أن النوع هو penalty وليس reward
      final bool isPenalty = rewardAndpenalty.type?.value?.toLowerCase().contains('reward') != true;
      
      // 3. التحقق من أن لم يمر أكثر من شهرين على العقوبة
      bool isWithinTwoMonths = false;
      try {
        String? dateToCheck = rewardAndpenalty.createdAt ?? rewardAndpenalty.dueDate;
        if (dateToCheck != null && dateToCheck.isNotEmpty) {
          DateTime penaltyDate = DateFormat('yyyy-MM-dd', "en").parse(dateToCheck);
          DateTime now = DateTime.now();
          Duration difference = now.difference(penaltyDate);
          // التحقق من أن الفرق أقل من شهرين (حوالي 60 يوم)
          isWithinTwoMonths = difference.inDays < 60;
        }
      } catch (e) {
        // في حالة وجود خطأ في parsing التاريخ، لا نعرض الزر
        isWithinTwoMonths = false;
      }
      
      canShowComplaintButton = isOwner && isPenalty && isWithinTwoMonths;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        gapH16,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.s10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.s8),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                rewardAndpenalty.profile?.name ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.s12),
              ),
            ),
          ),
        gapH12,
        if (rewardAndpenalty.type?.value?.isNotEmpty ?? false)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.requestType.tr()}: ',
              subtitle: rewardAndpenalty.type!.key!.toString().tr()),

        if (rewardAndpenalty.amount != null)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.amounts.tr()}: ',
              subtitle: "${rewardAndpenalty.amount?.toString()} ${rewardAndpenalty.category.key.toString().tr()}" ?? ''),

        if (rewardAndpenalty.dueDate?.isNotEmpty ?? false)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.dueDate.tr()}: ',
              subtitle: formatDateString2(rewardAndpenalty.dueDate) ?? ''),
        if (rewardAndpenalty.createdAt?.isNotEmpty ?? false)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.createdAt.tr()}: ',
              subtitle: formatDateString(rewardAndpenalty.createdAt) ?? ''),
        if (rewardAndpenalty.action != null)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.applied.tr()}: ',
              subtitle: rewardAndpenalty.action.key == "applied" ? "${AppStrings.yes.tr()} (${rewardAndpenalty.payroll != null ?rewardAndpenalty.payroll.dateFrom : AppStrings.thereIsNoSalary.tr()})" : AppStrings.no.tr()
          ),
          // if(rewardAndpenalty.action.key != "applied")
          // RewardAndPenaltyRowTile(
          //     title: '${AppStrings.salaryDate.tr()}: ',
          //     subtitle: rewardAndpenalty.payroll != null ? rewardAndpenalty.payroll.dateFrom :  AppStrings.thereIsNoSalary.tr()
          // ),
        if (rewardAndpenalty.manager != null && rewardAndpenalty.manager?.name?.isNotEmpty ?? false)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.from.tr()}: ',
              subtitle: rewardAndpenalty.manager?.name?.toString() ?? ''),
        if (rewardAndpenalty.reason?.isNotEmpty ?? false)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.reason.tr()}: ', subtitle: rewardAndpenalty.reason!),
        
        // زر الشكوى - يظهر فقط للعقوبات التي تستوفي الشروط
        if (canShowComplaintButton) ...[
          gapH24,
          CustomElevatedButton(
            titleSize: AppSizes.s10,
            buttonStyle: ElevatedButton.styleFrom(
              fixedSize: const Size(double.infinity, double.infinity),alignment: Alignment.center,
              shadowColor: Colors.transparent,
              backgroundColor:Color(AppColors.dark),
              foregroundColor: Color(AppColors.dark),
              disabledForegroundColor: Colors.transparent,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.s28),
              ),
            ),
            onPressed: () async => context.pushNamed(
              AppRoutes.newComplainScreen.name,
              pathParameters: {'lang': context.locale.languageCode},
            ),
            title: AppStrings.complaint.tr(),
          ),
        ],
      ],
    );
  }
}

class RewardAndPenaltyRowTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool? isNewLine;
  const RewardAndPenaltyRowTile(
      {super.key,
      required this.title,
      required this.subtitle,
      this.isNewLine = false});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.s14);
    Widget titleWidget = AutoSizeText(title, style: textStyle);
    
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isNewLine == true
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    AutoSizeText(subtitle,
                        style: textStyle.copyWith(color: Color(AppColors.black),fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    Expanded(
                      child: AutoSizeText(subtitle,
                          style: textStyle.copyWith(color: Color(AppColors.black),fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
          gapH16,
        ],
      ),
    );
  }
}
