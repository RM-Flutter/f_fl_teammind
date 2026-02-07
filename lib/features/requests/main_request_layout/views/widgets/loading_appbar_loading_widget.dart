import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:flutter/material.dart';

class RequestsAppbarLoading extends StatelessWidget {
  const RequestsAppbarLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Row(
                children: List.generate(
                    3,
                    (index) => Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s12),
                        child: ShimmerAnimatedLoading(
                          width: (LayoutService.getWidth(context) -
                                  (AppSizes.s32 + ((AppSizes.s12) * 3))) /
                              3,
                          height: AppSizes.s120,
                        )))),
            gapH32,
          ],
        ),
      ],
    );
  }
}
