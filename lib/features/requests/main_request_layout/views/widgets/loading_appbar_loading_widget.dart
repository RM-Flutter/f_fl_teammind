import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:flutter/material.dart';

/// Placeholder for the balance carousel ([VacationListWidget]): same page padding, card width,
/// gap and corners, so nothing jumps when the real cards arrive.
class RequestsAppbarLoading extends StatelessWidget {
  const RequestsAppbarLoading({super.key});

  @override
  Widget build(BuildContext context) {
    const gap = AppSizes.s12;
    final itemWidth =
        (LayoutService.getWidth(context) - (AppSpacing.page * 2 + gap * 2)) / 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, 0, AppSpacing.page, AppSizes.s32),
      child: Row(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsetsDirectional.only(end: index < 2 ? gap : 0),
            child: ShimmerAnimatedLoading(
              width: itemWidth,
              height: 120,
              circularRaduis: AppRadius.md,
            ),
          ),
        ),
      ),
    );
  }
}
