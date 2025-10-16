import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../../constants/app_sizes.dart';
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
    } String? formatDateString2(String? dateString) {
      if (dateString == null) return null;
      DateTime dateTime = DateFormat('yyyy-MM-dd', "en").parse(dateString);
      String formattedDate = DateFormat('MMM yyyy',LocalizationService.isArabic(context: context) ? "ar" : "en").format(dateTime);
      return formattedDate;
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
              title: '${AppStrings.reason.tr()}: ', subtitle: rewardAndpenalty.reason!)
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
    Widget subtitleWidget = Expanded(
      child: AutoSizeText(subtitle,
          style: textStyle.copyWith(color: Color(AppColors.black),fontSize: 14, fontWeight: FontWeight.w600)),
    );
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          isNewLine == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleWidget, subtitleWidget],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleWidget, subtitleWidget],
                ),
          gapH16,
        ],
      ),
    );
  }
}
