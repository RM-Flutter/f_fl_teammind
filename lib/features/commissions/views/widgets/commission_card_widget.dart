import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:app_test/features/commissions/data/models/commission_model.dart';
import 'package:app_test/features/commissions/views/widgets/commission_details_modal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommissionCardWidget extends StatelessWidget {
  final CommissionModel commission;

  const CommissionCardWidget({super.key, required this.commission});

  Color _resolveStatusColor() {
    final badge = (commission.statusBadge ?? '').toLowerCase();
    if (badge.contains('warning')) return Color(AppColors.warningYellow);
    if (badge.contains('success')) return Color(AppColors.successGreen);
    if (badge.contains('danger')) return Color(AppColors.failureRed);
    if (badge.contains('info')) return Color(AppColors.helpBlue);
    return AppStatusBadge.colorForStatus(
      (commission.status ?? '').toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveStatusColor();
    final amount = commission.localizedAmount;
    final datePart =
        CommissionModel.formatDatePart(context, commission.createdAt);
    final timePart =
        CommissionModel.formatTimePart(context, commission.createdAt);

    final subtitleParts = <String>[
      if (amount.isNotEmpty) amount,
      if (datePart != null && datePart.isNotEmpty) datePart,
      if (timePart != null && timePart.isNotEmpty) timePart,
    ];

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: AppSpacing.cardPadding,
      onTap: () => ModalSheetHelper.showModalSheet(
        context: context,
        viewProfile: false,
        title: 'commission_details'.tr(),
        height: MediaQuery.of(context).size.height * 0.65,
        modalContent: CommissionDetailsModal(commission: commission),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCardLeadingAvatar(
            icon: Icons.attach_money_rounded,
            borderColor: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  commission.title ?? 'commission'.tr(),
                  style: AppStyles.heading(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitleParts.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitleParts.join(' · '),
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
          const SizedBox(width: 8),
          AppStatusBadge(
            label: commission.statusLabel ?? commission.status ?? '-',
            color: statusColor,
            icon: AppStatusBadge.iconForStatus(
              (commission.status ?? '').toLowerCase(),
            ),
          ),
        ],
      ),
    );
  }
}
