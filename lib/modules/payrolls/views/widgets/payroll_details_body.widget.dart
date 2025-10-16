import 'dart:ffi';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../../constants/app_sizes.dart';
import '../../models/payroll.model.dart';

class PayrollDetailsBodyWidget extends StatelessWidget {
  final PayrollModel? payroll;
  const PayrollDetailsBodyWidget({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    String? formatString(String? input) {
      if (input == null || input.trim().isEmpty) return null;

      try {
        // Replace underscores with spaces and trim whitespace
        String normalizedString = input.replaceAll('_', ' ').trim();

        // Capitalize the first letter of each word
        String formattedString = normalizedString.split(' ').map((word) {
          return word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        }).join(' ');

        return formattedString;
      } catch (e) {
        // Handle any potential errors and return null
        return null;
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
        child: Column(
          children: [
            gapH24,
            // if (payroll?.user?.jobTitle != null)
            //   PayrollDetailsBodyTileWidget(
            //       title: AppStrings.jobTitle.tr(), subtitle: ''),

            if (payroll?.currency != null)
              PayrollDetailsBodyTileWidget(
                  title: AppStrings.currency.tr(), subtitle: payroll?.currency ?? ''),

            if (payroll?.basicSalary != null)
              PayrollDetailsBodyTileWidget(
                  title: AppStrings.basicSalary.tr(),
                  subtitle: double.parse(payroll!.basicSalary.toString()).toStringAsFixed(2) ?? ''),

            if (payroll?.salaryAdvance != null)
              PayrollDetailsBodyTileWidget(
                  title: AppStrings.salaryAdvance.tr(),
                  subtitle:double.parse(payroll!.salaryAdvance.toString()).toStringAsFixed(2) ?? ''),
            // display all deductions
            if (payroll?.payrollDeductions?.isNotEmpty ?? false)
              ...payroll!.payrollDeductions!.map(
                (deduction) => PayrollDetailsBodyTileWidget(
                    title: LocalizationService.isArabic(context: context)? deduction.title!.ar :
                    deduction.title!.en,
                    subtitle: double.parse(deduction.value.toString()).toStringAsFixed(2) ?? ''),
              ),

            // display all bounuses
            if (payroll?.payrollSpecialBonus?.isNotEmpty ?? false)
              ...payroll!.payrollSpecialBonus!.map(
                (bonuse) => PayrollDetailsBodyTileWidget(
                    title: LocalizationService.isArabic(context: context) ?
                    bonuse.title!.ar : bonuse.title!.en,
                    subtitle: double.parse(bonuse.value.toString()).toStringAsFixed(2) ?? ''),
              ),

            if (payroll?.payrollTotalDeductions != null)
              PayrollDetailsBodyTileWidget(
                  title: AppStrings.totalSpecialAndBonuses.tr(),
                  subtitle:
                      double.parse(payroll!.payrollTotalSpecialBonus.toString()).toStringAsFixed(2) ?? ''),

            if (payroll?.payrollTotalDeductions != null)
              PayrollDetailsBodyTileWidget(
                  title: AppStrings.totalDeductions.tr(),
                  subtitle: double.parse(payroll!.payrollTotalDeductions.toString()).toStringAsFixed(2) ?? ''),

            if (payroll?.netPayable != null)
              PayrollDetailsBodyTileWidget(
                  title: AppStrings.totalSalary.tr(),
                  subtitle: double.parse(payroll!.netPayable.toString()).toStringAsFixed(2) ?? ''),
          ],
        ),
      ),
    );
  }
}

class PayrollDetailsBodyTileWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const PayrollDetailsBodyTileWidget(
      {super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.s12, vertical: AppSizes.s18),
          decoration: BoxDecoration(
            color: const Color(0xffE5E5E5).withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppSizes.s8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AutoSizeText(
                  title ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.s14,
                    color: Color(AppColors.c3),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              gapW16,
              AutoSizeText(
                subtitle ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: AppSizes.s12,
                  color: Color(AppColors.primary),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
        gapH16
      ],
    );
  }
}
