import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class HomeAppbarLoading extends StatelessWidget {
  const HomeAppbarLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = LayoutService.getWidth(context);
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppRadius.xl),
            bottomRight: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: AppSpacing.page,
          right: AppSpacing.page),
      child: AppContentWidth(
        child: Column(
          children: [
            gapH18,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const ShimmerAnimatedLoading(
                  width: AppSizes.s40,
                  height: AppSizes.s40,
                  circularRaduis: AppSizes.s40,
                ),
                gapW12,
                ShimmerAnimatedLoading(
                  height: AppSizes.s32,
                  width: effectiveWidth / 2,
                ),
                const Spacer(),
                const ShimmerAnimatedLoading(
                  width: AppSizes.s40,
                  height: AppSizes.s40,
                  circularRaduis: AppSizes.s40,
                )
              ],
            ),
            gapH32,
            Row(
                children: List.generate(
                    3,
                    (index) => Padding(
                        padding: EdgeInsetsDirectional.only(
                            end: index < 2 ? AppSizes.s12 : 0),
                        child: ShimmerAnimatedLoading(
                          width: (effectiveWidth -
                                  (AppSpacing.page * 2 + AppSizes.s12 * 2)) /
                              3,
                          height: AppSizes.s120,
                          circularRaduis: AppRadius.md,
                        ))))
          ],
        ),
      ),
    );
  }
}
