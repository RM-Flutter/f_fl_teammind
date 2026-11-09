import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:flutter/material.dart';

/// Skeleton of the interview details page, in the same order and spacing as the real one:
/// the header card (avatar + name + subtitle), a section title, the info box with its rows,
/// then a second section with chips.
class InterviewDetailsLoading extends StatelessWidget {
  const InterviewDetailsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Row(
              children: [
                const _Bone(width: 46, height: 46, radius: AppRadius.pill),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _Bone(width: 150, height: 14),
                      SizedBox(height: AppSpacing.sm),
                      _Bone(width: double.infinity, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle(),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  Row(
                    children: const [
                      _Bone(width: 90, height: 12),
                      Spacer(),
                      _Bone(width: 130, height: 12),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle(),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              _Bone(width: 80, height: 30, radius: AppRadius.pill),
              _Bone(width: 100, height: 30, radius: AppRadius.pill),
              _Bone(width: 70, height: 30, radius: AppRadius.pill),
              _Bone(width: 90, height: 30, radius: AppRadius.pill),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) => Row(
        children: const [
          _Bone(width: 20, height: 20, radius: AppRadius.xs),
          SizedBox(width: AppSpacing.sm),
          _Bone(width: 120, height: 14),
        ],
      );
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Bone({required this.width, required this.height, this.radius = AppRadius.xs});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
        child: const ShimmerAnimatedLoading(),
      );
}
