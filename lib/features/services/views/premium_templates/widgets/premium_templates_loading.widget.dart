import 'package:flutter/material.dart';
import '../../../../../core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class PremiumTemplatesLoadingWidget extends StatelessWidget {
  const PremiumTemplatesLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(
            6,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Image placeholder
                  const ShimmerAnimatedLoading(
                    width: 80,
                    height: 80,
                    circularRaduis: 12,
                  ),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 8),
                        // Title placeholder
                        const ShimmerAnimatedLoading(
                          height: 16,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 6),
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

