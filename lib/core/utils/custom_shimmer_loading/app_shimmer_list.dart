import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'shimmer_animated_loading.dart';

/// Placeholder with the exact shape of [AppCard.listItem]: a white [AppCard] with a 46px
/// circle, a title line, a subtitle line and a small badge on the end.
///
/// Every list in the app uses this while it loads, so loading → loaded doesn't jump.
class AppShimmerCard extends StatelessWidget {
  /// Show the round leading avatar.
  final bool showAvatar;

  /// Show the pill badge on the end (status badge / action).
  final bool showTrailing;

  /// Number of text lines (1 – 3).
  final int lines;

  const AppShimmerCard({
    super.key,
    this.showAvatar = true,
    this.showTrailing = true,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final int lineCount = lines < 1 ? 1 : (lines > 3 ? 3 : lines);
    return AppCard(
      child: Row(
        children: [
          if (showAvatar) ...[
            const ShimmerAnimatedLoading(
              width: AppShimmer.avatar,
              height: AppShimmer.avatar,
              circularRaduis: AppRadius.pill,
            ),
            gapW12,
          ],
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerAnimatedLoading(
                    height: AppShimmer.titleLine,
                    width: constraints.maxWidth * 0.7,
                  ),
                  for (int i = 1; i < lineCount; i++) ...[
                    gapH8,
                    ShimmerAnimatedLoading(
                      height: AppShimmer.subtitleLine,
                      width: constraints.maxWidth * (i == 1 ? 0.45 : 0.3),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (showTrailing) ...[
            gapW8,
            const ShimmerAnimatedLoading(
              width: AppSizes.s60,
              height: AppSizes.s22,
              circularRaduis: AppRadius.pill,
            ),
          ],
        ],
      ),
    );
  }
}

/// Placeholder for a section title row ("My requests ....... View all").
class AppShimmerSectionHeader extends StatelessWidget {
  const AppShimmerSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppSpacing.sectionHeaderHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerAnimatedLoading(width: AppSizes.s120, height: AppSizes.s14),
          ShimmerAnimatedLoading(width: AppSizes.s50, height: AppSizes.s10),
        ],
      ),
    );
  }
}

/// The loading state of a list screen / list section: [count] × [AppShimmerCard] separated by
/// [AppSpacing.cardGap].
///
/// By default it adds the page padding itself ([AppSpacing.pagePadding] + a small top gap).
/// Pass `padding: EdgeInsets.zero` when the parent already pads the page.
/// It is a plain Column, so it works inside slivers, scroll views and Columns.
class AppShimmerList extends StatelessWidget {
  final int count;
  final EdgeInsetsGeometry padding;
  final bool showHeader;
  final bool showAvatar;
  final bool showTrailing;
  final int lines;

  const AppShimmerList({
    super.key,
    this.count = AppShimmer.listCount,
    this.padding = const EdgeInsets.fromLTRB(
        AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.md),
    this.showHeader = false,
    this.showAvatar = true,
    this.showTrailing = true,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Never-scrolling scroll view: inside a bounded parent (Expanded, page body) extra
    // placeholders are clipped instead of overflowing; inside a list it just takes its height.
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHeader) ...[
            const AppShimmerSectionHeader(),
            const SizedBox(height: AppSpacing.sectionHeaderGap),
          ],
          for (int i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.cardGap),
            AppShimmerCard(
              showAvatar: showAvatar,
              showTrailing: showTrailing,
              lines: lines,
            ),
          ],
        ],
      ),
    );
  }
}
