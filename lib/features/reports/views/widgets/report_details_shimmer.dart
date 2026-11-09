import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class ReportDetailsShimmer extends StatelessWidget {
  const ReportDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary card shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerAnimatedLoading(height: 16, width: 200, circularRaduis: 4),
                const SizedBox(height: 12),
                const Divider(),
                ...List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerAnimatedLoading(height: 14, width: 120, circularRaduis: 4),
                      ShimmerAnimatedLoading(height: 14, width: 60, circularRaduis: 4),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Employees list shimmer
          ShimmerAnimatedLoading(height: 20, width: 140, circularRaduis: 4),
          const SizedBox(height: 12),
          ...List.generate(5, (i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                ShimmerAnimatedLoading(height: 40, width: 40, circularRaduis: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerAnimatedLoading(height: 16, width: 150, circularRaduis: 4),
                      const SizedBox(height: 6),
                      ShimmerAnimatedLoading(height: 12, width: 100, circularRaduis: 4),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
