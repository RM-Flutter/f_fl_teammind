import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class PayrollsAndPenaltiesRewardsLoadingScreensWidget extends StatelessWidget {
  const PayrollsAndPenaltiesRewardsLoadingScreensWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        7,
        (index) => Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: AppSizes.s14.h, horizontal: AppSizes.s16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.s10.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    offset: const Offset(0, 0),
                    blurRadius: 2.5.r,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShimmerAnimatedLoading(
                    width: AppSizes.s24.w,
                    height: AppSizes.s24.h,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ShimmerAnimatedLoading(
                      height: AppSizes.s24.h,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ShimmerAnimatedLoading(
                    width: AppSizes.s28.w,
                    height: AppSizes.s28.h,
                    circularRaduis: AppSizes.s50,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h)
          ],
        ),
      ),
    );
  }
}
