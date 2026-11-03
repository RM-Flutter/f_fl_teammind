import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

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
        padding: EdgeInsets.symmetric(horizontal: AppSizes.s12),
        child: Column(
          children: [
            gapH24,
            // if (payroll?.user?.jobTitle != null)
            //   PayrollDetailsBodyTileWidget(
            //       title: AppStrings.jobTitle.tr(), subtitle: ''),

            if (payroll?.currency != null)
              PayrollDetailsBodyTileWidget(
                  title: AppStrings.currency.tr(), subtitle: payroll?.currency ?? '', showCurrency: false),

            if (payroll?.basicSalary != null)
              PayrollDetailsBodyTileWidget(
                  currency: payroll?.currency,
                  title: AppStrings.basicSalary.tr(),
                  subtitle: double.parse(payroll!.basicSalary.toString()).toStringAsFixed(2)),

            if (payroll?.salaryAdvance != null)
              PayrollDetailsBodyTileWidget(
                  currency: payroll?.currency,
                  title: AppStrings.salaryAdvance.tr(),
                  subtitle:double.parse(payroll!.salaryAdvance.toString()).toStringAsFixed(2),
                  subtitleColor: Colors.red),
            // display all deductions
            if (payroll?.payrollDeductions?.isNotEmpty ?? false)
              ...payroll!.payrollDeductions!.map(
                (deduction) => PayrollDetailsBodyTileWidget(
                  currency: payroll?.currency,
                    title: LocalizationService.isArabic(context: context)? deduction.title!.ar :
                    deduction.title!.en,
                    subtitle: double.parse(deduction.value.toString()).toStringAsFixed(2) ?? '',
                    subtitleColor: Colors.red),
              ),

            // display all bounuses
            if (payroll?.payrollSpecialBonus?.isNotEmpty ?? false)
              ...payroll!.payrollSpecialBonus!.map(
                (bonuse) => PayrollDetailsBodyTileWidget(
                  currency: payroll?.currency,
                    title: LocalizationService.isArabic(context: context) ?
                    bonuse.title!.ar : bonuse.title!.en,
                    subtitle: double.parse(bonuse.value.toString()).toStringAsFixed(2) ?? '',
                    subtitleColor: Colors.green),
              ),

            if (payroll?.payrollTotalDeductions != null)
              PayrollDetailsBodyTileWidget(
                  currency: payroll?.currency,
                  title: AppStrings.totalSpecialAndBonuses.tr(),
                  subtitle:
                      double.parse(payroll!.payrollTotalSpecialBonus.toString()).toStringAsFixed(2) ?? '',
                  subtitleColor: Colors.green),

            if (payroll?.payrollTotalDeductions != null)
              PayrollDetailsBodyTileWidget(
                  currency: payroll?.currency,
                  title: AppStrings.totalDeductions.tr(),
                  subtitle: double.parse(payroll!.payrollTotalDeductions.toString()).toStringAsFixed(2) ?? '',
                  subtitleColor: Colors.red),

            if (payroll?.netPayable != null)
              PayrollDetailsBodyTileWidget(
                  currency: payroll?.currency,
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
  final Color? subtitleColor;
  /// Currency the payroll was generated in; falls back to EGP when missing
  final String? currency;
  final bool showCurrency;
  const PayrollDetailsBodyTileWidget(
      {super.key, required this.title, required this.subtitle, this.subtitleColor, this.currency, this.showCurrency = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSizes.s12, vertical: AppSizes.s18),
          decoration: BoxDecoration(
            color: const Color(AppColors.lightGreyE5).withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AutoSizeText(
                  title ?? "",
                  style: AppStyles.primaryContent(context).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.s14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              gapW16,
              AutoSizeText(
                showCurrency ? "${subtitle!} ${currency ?? AppStrings.EGP.tr()}" : subtitle!,
                style: AppStyles.blackContent(context).copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: AppSizes.s12,
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
