import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/data/repos/rewards_and_penalties.service.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/views/widgets/widgets/rewards_and_penalties_details_modal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RewardAndPenaltyCardWidget extends StatelessWidget {
  final dynamic rewardAndPenalty;
  const RewardAndPenaltyCardWidget({super.key, required this.rewardAndPenalty});

  @override
  Widget build(BuildContext context) {
    if (rewardAndPenalty == null) return const SizedBox.shrink();

    // Determine type (reward/bonus vs penalty/deduction)
    final typeKey = rewardAndPenalty.type?.key?.toLowerCase() ?? '';
    final isReward = typeKey.contains('reward') || typeKey.contains('bonus');
    
    // Determine display title
    final title = rewardAndPenalty.reason ?? rewardAndPenalty.type?.value ?? AppStrings.details.tr();
    
    // Determine value and currency
    final amount = rewardAndPenalty.amount ?? 0;
    final currency = rewardAndPenalty.payroll?.currency ?? "EGP"; // Fallback to EGP

    return Column(
      children: [
        InkWell(
          onTap: () {
            ModalSheetHelper.showModalSheet(
              context: context,
              title: AppStrings.details.tr(),
              modalContent: RewardsAndPenaltiesDetailsModal(rewardAndPenalty: rewardAndPenalty),
              height: MediaQuery.of(context).size.height * .75,
              viewProfile: false
            );
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: AppSizes.s14.h, horizontal: AppSizes.s16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                )
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: AppSizes.s50.w,
                        height: AppSizes.s50.h,
                        padding: EdgeInsets.all(AppSizes.s12.r),
                        decoration: BoxDecoration(
                          color: isReward
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Icon(
                            isReward
                                ? Icons.add_circle_outline
                                : Icons.remove_circle_outline,
                            color: isReward
                                ? Colors.green
                                : Colors.red,
                            size: 24.r,
                          ),
                        ),
                      ),
                      gapW12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: AppStyles.heading(context).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: AppSizes.s14.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            gapH4,
                            Text(
                              '$amount $currency',
                              style: AppStyles.blackContent(context).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: AppSizes.s14.sp,
                                color: isReward
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        gapH12
      ],
    );
  }
}
