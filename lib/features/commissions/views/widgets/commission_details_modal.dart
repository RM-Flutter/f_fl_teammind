import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/commissions/data/models/commission_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommissionDetailsModal extends StatelessWidget {
  final CommissionModel commission;

  const CommissionDetailsModal({super.key, required this.commission});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gapH16,

        // ── Title header ───────────────────────────────────────────────────
        if (commission.title != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.s10),
            decoration: BoxDecoration(
              color: Color(AppColors.buttons),
              borderRadius: BorderRadius.circular(AppSizes.s8),
            ),
            child: Center(
              child: Text(
                commission.title!,
                style: AppStyles.whiteContent(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.s13,
                ),
              ),
            ),
          ),

        gapH16,

        // ── Details rows ───────────────────────────────────────────────────
        _CommissionRowTile(
          title: 'commission_amount'.tr(),
          subtitle: commission.localizedAmount,
        ),

        _CommissionRowTile(
          title: 'status'.tr(),
          subtitle: commission.statusLabel ?? commission.status ?? '-',
        ),

        if (commission.createdAt != null)
          _CommissionRowTile(
            title: 'created_at'.tr(),
            subtitle:
                CommissionModel.formatDateTimeFull(context, commission.createdAt),
          ),

        if (commission.payrollMonthLabel != null)
          _CommissionRowTile(
            title: 'payroll_month'.tr(),
            subtitle: commission.payrollMonthLabel!,
          ),

        if (commission.appliedAt != null)
          _CommissionRowTile(
            title: 'applied_at'.tr(),
            subtitle:
                CommissionModel.formatDateTimeFull(context, commission.appliedAt),
          ),

        if (commission.paymentDateLabel != null)
          _CommissionRowTile(
            title: 'payment_date'.tr(),
            subtitle: commission.paymentDateLabel!,
          ),

        if (commission.paymentReason != null &&
            commission.paymentReason!.isNotEmpty)
          _CommissionRowTile(
            title: 'payment_reason'.tr(),
            subtitle: commission.paymentReason!,
          ),

        if (commission.notes != null && commission.notes!.isNotEmpty)
          _CommissionRowTile(
            title: 'notes'.tr(),
            subtitle: commission.notes!,
          ),

        gapH24,
      ],
    );
  }
}

class _CommissionRowTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CommissionRowTile({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppStyles.primaryContent(context).copyWith(
      fontWeight: FontWeight.w600,
      fontSize: AppSizes.s14,
    );

    final titleWidget = AutoSizeText('$title: ', style: textStyle);
    final valueWidget = AutoSizeText(
      subtitle,
      style: textStyle.copyWith(
        color: Color(AppColors.black),
        fontWeight: FontWeight.w600,
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              Expanded(child: valueWidget),
            ],
          ),
          gapH16,
        ],
      ),
    );
  }
}
