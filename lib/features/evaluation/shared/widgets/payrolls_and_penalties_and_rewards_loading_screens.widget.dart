import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
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
                  vertical: AppSizes.s14, horizontal: AppSizes.s16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.s10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color:
                        Color(AppColors.buttons).withOpacity(0.2),
                    offset: const Offset(0, 0),
                    blurRadius: 2.5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShimmerAnimatedLoading(
                    width: AppSizes.s24,
                    height: AppSizes.s24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ShimmerAnimatedLoading(
                      height: AppSizes.s24,
                    ),
                  ),
                  SizedBox(width: 12),
                  ShimmerAnimatedLoading(
                    width: AppSizes.s28,
                    height: AppSizes.s28,
                    circularRaduis: AppSizes.s50,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
