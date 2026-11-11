import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_details_sheet.widget.dart';
import 'package:app_test/features/commissions/data/models/commission_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'commission_card_widget.dart';

class CommissionDetailsModal extends StatelessWidget {
  final CommissionModel commission;

  const CommissionDetailsModal({super.key, required this.commission});

  @override
  Widget build(BuildContext context) {
    final color = CommissionCardWidget.statusColorOf(commission);
    final status = commission.statusLabel ?? commission.status;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDetailsHeader(
          icon: Icons.attach_money_rounded,
          color: color,
          title: commission.title ?? 'commission_details'.tr(),
          badgeLabel: status,
          badgeColor: color,
        ),
        const SizedBox(height: AppSpacing.section),
        AppDetailsHighlight(
          value: commission.localizedAmount,
          caption: commission.paymentDateLabel,
          color: color,
        ),
        const SizedBox(height: AppSpacing.section),
        AppInfoCard(rows: [
          if (commission.createdAt != null)
            AppInfoRow(
                label: 'created_at'.tr(),
                value: CommissionModel.formatDateTimeFull(context, commission.createdAt)),
          if (commission.payrollMonthLabel != null)
            AppInfoRow(label: 'payroll_month'.tr(), value: commission.payrollMonthLabel!),
          if (commission.appliedAt != null)
            AppInfoRow(
                label: 'applied_at'.tr(),
                value: CommissionModel.formatDateTimeFull(context, commission.appliedAt)),
          if (commission.paymentReason != null && commission.paymentReason!.isNotEmpty)
            AppInfoRow(label: 'payment_reason'.tr(), value: commission.paymentReason!),
          if (commission.notes != null && commission.notes!.isNotEmpty)
            AppInfoRow(label: 'notes'.tr(), value: commission.notes!),
        ]),
        const SizedBox(height: AppSpacing.section),
      ],
    );
  }
}
