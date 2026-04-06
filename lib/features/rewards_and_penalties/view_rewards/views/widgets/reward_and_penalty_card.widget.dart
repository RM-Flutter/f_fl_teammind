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
  var rewardAndPenalty;
  RewardAndPenaltyCardWidget({super.key, required this.rewardAndPenalty});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
              Row(
                children: [
                  Container(
                    width: AppSizes.s50.w,
                    height: AppSizes.s50.h,
                    padding: EdgeInsets.all(AppSizes.s12.r),
                    decoration: BoxDecoration(
                      color: rewardAndPenalty.type == 'bonus'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        rewardAndPenalty.type == 'bonus'
                            ? Icons.add_circle_outline
                            : Icons.remove_circle_outline,
                        color: rewardAndPenalty.type == 'bonus'
                            ? Colors.green
                            : Colors.red,
                        size: 24.r,
                      ),
                    ),
                  ),
                  gapW12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 0.5.sw,
                        child: Text(
                          LocalizationService.isArabic(context: context)
                              ? rewardAndPenalty.titleAr ?? ''
                              : rewardAndPenalty.titleEn ?? '',
                          style: AppStyles.darkHeading(context).copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizes.s14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      gapH4,
                      Text(
                        '${rewardAndPenalty.value} ${rewardAndPenalty.currency}',
                        style: AppStyles.blackContent(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.s14.sp,
                          color: rewardAndPenalty.type == 'bonus'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              gapW8,
              Container(
                height: AppSizes.s28.r,
                width: AppSizes.s28.r,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary),
                child: Icon(
                  Icons.arrow_forward_outlined,
                  color: Colors.white,
                  size: AppSizes.s12.r,
                ),
              ),
            ],
          ),
        ),
        gapH12
      ],
    );
  }
}
