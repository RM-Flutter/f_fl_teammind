import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/repos/payroll_service.dart';

class PayrollListItemWidget extends StatelessWidget {
  final PayrollModel payroll;
  const PayrollListItemWidget({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        PayrollRepo.formatDate(payroll.dateTo, context) ?? '-';
    final String subtitle = [
      if (payroll.dateFrom != null && payroll.dateFrom!.isNotEmpty)
        '${'from'.tr()}: ${payroll.dateFrom}',
      if (payroll.dateTo != null && payroll.dateTo!.isNotEmpty)
        '${'to'.tr()}: ${payroll.dateTo}',
    ].join(' · ');

    return AppCard(animateIn: true, 
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: AppSpacing.cardPadding,
      onTap: () async => await context.pushNamed(
        AppRoutes.payrollDetails.name,
        extra: payroll,
        pathParameters: {'lang': context.locale.languageCode},
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCardLeadingAvatar(
            icon: Icons.calendar_month_rounded,
            borderColor: Color(AppColors.buttons),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedDate,
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s3),
                  Text(
                    subtitle,
                    style: AppStyles.subtitleContent(context).copyWith(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          AppStatusBadge(
            label: 'view'.tr(),
            color: Color(AppColors.buttons),
            trailingIcon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}
