import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class PremiumTemplatesLoadingWidget extends StatelessWidget {
  const PremiumTemplatesLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
        child: Column(
          children: List.generate(
            6,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.s12),
              padding: const EdgeInsets.all(AppSizes.s12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  // Image placeholder
                  const ShimmerAnimatedLoading(
                    width: 80,
                    height: 80,
                    circularRaduis: 12,
                  ),
                  const SizedBox(width: AppSizes.s12),
                  // Info placeholders
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Type placeholder
                        const ShimmerAnimatedLoading(
                          height: 12,
                          width: 80,
                        ),
                        const SizedBox(height: AppSizes.s8),
                        // Title placeholder
                        const ShimmerAnimatedLoading(
                          height: 16,
                          width: double.infinity,
                        ),
                        const SizedBox(height: AppSizes.s6),
                        // Description placeholder
                        const ShimmerAnimatedLoading(
                          height: 12,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

