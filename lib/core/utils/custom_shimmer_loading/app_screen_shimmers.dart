import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:flutter/material.dart';

/// Skeleton of a form / profile page that is NOT a list: optional tab bar, optional round photo,
/// then either input fields ([fields]) or an info card with label / value rows ([infoRows]),
/// and an optional button pinned to the bottom. Draw the page the user is about to get, so the
/// loading state looks like the page and not like a list of cards.
class AppFormShimmer extends StatelessWidget {
  final bool tabs;
  final bool photo;
  final int headerLines;
  final int fields;
  final int infoRows;
  final bool button;
  const AppFormShimmer({
    super.key,
    this.tabs = true,
    this.photo = false,
    this.headerLines = 0,
    this.fields = 0,
    this.infoRows = 0,
    this.button = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (headerLines > 0) ...[
                  for (var i = 0; i < headerLines; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    Center(
                        child: ShimmerAnimatedLoading(
                            width: i == 0 ? 220 : 150, height: i == 0 ? 16 : 12)),
                  ],
                  const SizedBox(height: AppSpacing.section),
                ],
                if (tabs) ...[
                  const ShimmerAnimatedLoading(height: 48, circularRaduis: AppRadius.xl),
                  const SizedBox(height: AppSpacing.section),
                ],
                if (photo) ...[
                  const Center(
                      child: ShimmerAnimatedLoading(
                          width: 104, height: 104, circularRaduis: AppRadius.pill)),
                  const SizedBox(height: AppSpacing.section),
                ],
                for (var i = 0; i < fields; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  const ShimmerAnimatedLoading(
                      height: AppField.height, circularRaduis: AppRadius.md),
                ],
                if (infoRows > 0)
                  AppCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < infoRows; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          Row(
                            children: const [
                              ShimmerAnimatedLoading(width: 90, height: 12),
                              Spacer(),
                              ShimmerAnimatedLoading(width: 130, height: 12),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (button)
          const Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xl),
            child: ShimmerAnimatedLoading(
                height: AppButtonSize.height, circularRaduis: AppRadius.pill),
          ),
      ],
    );
  }
}

/// Skeleton of a page with one big preview card, page dots and a button (template pickers).
class AppPagerShimmer extends StatelessWidget {
  const AppPagerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.lg, AppSpacing.page, AppSpacing.xl),
      child: Column(
        children: [
          const Expanded(
            child: ShimmerAnimatedLoading(circularRaduis: AppRadius.lg),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ShimmerAnimatedLoading(
                    width: 8, height: 8, circularRaduis: AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          const ShimmerAnimatedLoading(
              height: AppButtonSize.height, circularRaduis: AppRadius.pill),
        ],
      ),
    );
  }
}

/// Skeleton of the Free Services tile grid: same number of columns as the real one.
class AppGridShimmer extends StatelessWidget {
  final int tiles;
  final double tileHeight;
  const AppGridShimmer({super.key, this.tiles = 8, this.tileHeight = 108});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: AppResponsiveGrid(
        compact: 2,
        medium: 3,
        expanded: 4,
        rowHeight: tileHeight,
        children: List.generate(
          tiles,
          (_) => const AppCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerAnimatedLoading(width: 40, height: 40, circularRaduis: AppRadius.md),
                SizedBox(height: AppSpacing.sm),
                ShimmerAnimatedLoading(width: 80, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
