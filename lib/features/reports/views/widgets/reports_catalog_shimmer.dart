import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class ReportsCatalogShimmer extends StatelessWidget {
  const ReportsCatalogShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label shimmer
        ShimmerAnimatedLoading(height: 20, width: 140, circularRaduis: 6),
        const SizedBox(height: AppSizes.s12),
        ...List.generate(4, (i) => _buildItemShimmer()),
        const SizedBox(height: AppSizes.s24),
        ShimmerAnimatedLoading(height: 20, width: 180, circularRaduis: 6),
        const SizedBox(height: AppSizes.s12),
        ...List.generate(3, (i) => _buildItemShimmer()),
      ],
    );
  }

  Widget _buildItemShimmer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s14, horizontal: AppSizes.s16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSizes.s8),
              Expanded(child: ShimmerAnimatedLoading(height: 18, circularRaduis: 4)),
              const SizedBox(width: AppSizes.s12),
              ShimmerAnimatedLoading(height: 28, width: 28, circularRaduis: 50),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s12),
      ],
    );
  }
}
