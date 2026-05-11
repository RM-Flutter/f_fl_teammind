import 'dart:convert';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RewardsAndPenaltiesDetailsModal extends StatelessWidget {
  final dynamic rewardAndPenalty;
  
  const RewardsAndPenaltiesDetailsModal({super.key, required this.rewardAndPenalty});

  @override
  Widget build(BuildContext context) {
    String? formatDateString(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('EEEE, dd MMM yyyy', LocalizationService.isArabic(context: context) ? "ar" : "en").format(dateTime);
      } catch (e) {
        return dateString;
      }
    }

    String? formatDateString2(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('MMM yyyy', LocalizationService.isArabic(context: context) ? "ar" : "en").format(dateTime);
      } catch (e) {
        return dateString;
      }
    }

    var jsonString = CacheHelper.getString("US1");
    Map<String, dynamic>? gCache;
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        gCache = json.decode(jsonString) as Map<String, dynamic>;
      } catch (_) {}
    }

    bool canShowComplaintButton = false;
    if (gCache != null && rewardAndPenalty.employeeId != null && gCache['employee_profile_id'] != null) {
      final bool isOwner = rewardAndPenalty.employeeId.toString() == gCache['employee_profile_id'].toString();
      final typeKey = rewardAndPenalty.type?.key?.toLowerCase() ?? '';
      final bool isPenalty = !typeKey.contains('reward') && !typeKey.contains('bonus');
      
      bool isWithinTwoMonths = false;
      try {
        String? dateToCheck = rewardAndPenalty.createdAt ?? rewardAndPenalty.dueDate;
        if (dateToCheck != null && dateToCheck.isNotEmpty) {
          DateTime penaltyDate = DateTime.parse(dateToCheck);
          DateTime now = DateTime.now();
          isWithinTwoMonths = now.difference(penaltyDate).inDays < 60;
        }
      } catch (_) {}
      
      canShowComplaintButton = isOwner && isPenalty && isWithinTwoMonths;
    }

    final typeValue = rewardAndPenalty.type?.value ?? "";
    final categoryValue = rewardAndPenalty.category?.value ?? "";
    final amount = rewardAndPenalty.amount?.toString() ?? "0";
    final actionKey = rewardAndPenalty.action?.key ?? "";
    final payrollDate = rewardAndPenalty.payroll?.dateFrom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        gapH16,
        if (rewardAndPenalty.profile?.name != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.s10.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.s8.r),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                rewardAndPenalty.profile!.name!,
                style: AppStyles.whiteContent(context).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.s12.sp),
              ),
            ),
          ),
        gapH12,
        
        if (typeValue.isNotEmpty)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.requestType.tr()}: ',
              subtitle: typeValue),

        RewardAndPenaltyRowTile(
            title: '${AppStrings.amounts.tr()}: ',
            subtitle: "$amount $categoryValue"),

        if (rewardAndPenalty.dueDate != null)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.dueDate.tr()}: ',
              subtitle: formatDateString2(rewardAndPenalty.dueDate) ?? ''),
              
        if (rewardAndPenalty.createdAt != null)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.createdAt.tr()}: ',
              subtitle: formatDateString(rewardAndPenalty.createdAt) ?? ''),
              
        RewardAndPenaltyRowTile(
            title: '${AppStrings.applied.tr()}: ',
            subtitle: actionKey == "applied" 
                ? "${AppStrings.yes.tr()} (${payrollDate ?? AppStrings.thereIsNoSalary.tr()})" 
                : AppStrings.no.tr()
        ),

        if (rewardAndPenalty.manager?.name != null)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.from.tr()}: ',
              subtitle: rewardAndPenalty.manager!.name!),
              
        if (rewardAndPenalty.reason != null && rewardAndPenalty.reason!.isNotEmpty)
          RewardAndPenaltyRowTile(
              title: '${AppStrings.reason.tr()}: ', 
              subtitle: rewardAndPenalty.reason!),
        
        if (canShowComplaintButton) ...[
          gapH24,
          CustomElevatedButton(
            titleSize: AppSizes.s10.sp,
            buttonStyle: ElevatedButton.styleFrom(
              fixedSize: Size(double.infinity, 50.h),
              alignment: Alignment.center,
              shadowColor: Colors.transparent,
              backgroundColor: Color(AppColors.titleText),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.s28.r),
              ),
            ),
            onPressed: () async => context.pushNamed(
              AppRoutes.newComplainScreen.name,
              pathParameters: {'lang': context.locale.languageCode},
            ),
            title: AppStrings.complaint.tr(),
          ),
        ],
        gapH24,
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
    TextStyle textStyle = AppStyles.primaryContent(context).copyWith(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.s14.sp);
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
                        style: textStyle.copyWith(color: Color(AppColors.black), fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    Expanded(
                      child: AutoSizeText(subtitle,
                          style: textStyle.copyWith(color: Color(AppColors.black), fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
          gapH16,
        ],
      ),
    );
  }
}
