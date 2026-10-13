import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/features/commissions/data/models/commission_model.dart';
import 'package:app_test/features/commissions/views/widgets/commission_details_modal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommissionCardWidget extends StatelessWidget {
  final CommissionModel commission;

  const CommissionCardWidget({super.key, required this.commission});

  // Map status badge string to a Flutter Color
  Color _resolveStatusColor() {
    final badge = commission.statusBadge ?? '';
    if (badge.contains('warning')) return const Color(0xFFFFC107);
    if (badge.contains('success')) return const Color(0xFF28A745);
    if (badge.contains('danger')) return const Color(0xFFDC3545);
    if (badge.contains('info')) return const Color(0xFF17A2B8);
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveStatusColor();
    final amount = commission.localizedAmount;
    final datePart = CommissionModel.formatDatePart(context, commission.createdAt);
    final timePart = CommissionModel.formatTimePart(context, commission.createdAt);

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.s10),
          onTap: () => ModalSheetHelper.showModalSheet(
            context: context,
            viewProfile: false,
            title: 'commission_details'.tr(),
            height: MediaQuery.of(context).size.height * 0.65,
            modalContent: CommissionDetailsModal(commission: commission),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.s14,
              horizontal: AppSizes.s16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.s10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: AppSizes.s45,
                  height: AppSizes.s45,
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.attach_money_rounded,
                    color: Color(AppColors.buttons),
                    size: AppSizes.s22,
                  ),
                ),
                gapW12,
                // Title + amount + formatted date/time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commission.title ?? 'commission'.tr(),
                        style: AppStyles.primaryContent(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.s14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      gapH4,
                      Text(
                        amount,
                        style: AppStyles.primaryContent(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.s13,
                          color: Color(AppColors.secondaryButton),
                        ),
                      ),
                      if (datePart != null && datePart.isNotEmpty) ...[
                        gapH6,
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  datePart,
                                  style: TextStyle(
                                    fontSize: AppSizes.s12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            if (timePart != null && timePart.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timePart,
                                    style: TextStyle(
                                      fontSize: AppSizes.s12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                gapW8,
                // Status badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.s8, vertical: AppSizes.s4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppSizes.s20),
                      ),
                      child: Text(
                        commission.statusLabel ?? commission.status ?? '',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: AppSizes.s10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    gapH8,
                    Container(
                      height: AppSizes.s28,
                      width: AppSizes.s28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(AppColors.buttons),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_outlined,
                        color: Colors.white,
                        size: AppSizes.s12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        gapH12,
      ],
    );
  }
}
