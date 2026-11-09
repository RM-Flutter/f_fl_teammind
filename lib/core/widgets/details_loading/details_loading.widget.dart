import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:flutter/material.dart';

/// Loading skeleton of a details screen. It draws the same blocks as the real page, in the same
/// places and with the same spacing: the navy header (title row, chips), the tab bar, then cards.
/// So nothing jumps when the data arrives.
class DetailsLoadingWidget extends StatelessWidget {
  /// Height of the navy header block (status bar included).
  final double headerHeight;

  /// Draw the navy header (screens with a plain app bar turn it off).
  final bool showHeader;

  /// Draw the tab bar under the header.
  final bool showTabs;

  /// Number of placeholder cards under the tabs.
  final int cards;

  /// Centred paragraph lines instead of cards (notification / complaint details show their
  /// content as centred text under the header).
  final int textLines;

  const DetailsLoadingWidget({
    super.key,
    this.headerHeight = 300,
    this.showHeader = true,
    this.showTabs = true,
    this.cards = 3,
    this.textLines = 0,
  });

  Widget _block(double w, double h, {double radius = AppRadius.sm}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    const radius = BorderRadius.only(
      bottomLeft: Radius.circular(AppRadius.xl),
      bottomRight: Radius.circular(AppRadius.xl),
    );
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header: back button + title, then two rows of chips
          if (showHeader)
          Container(
            height: headerHeight,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(AppSpacing.page, top + AppSpacing.sm, AppSpacing.page, AppSpacing.lg),
            decoration: BoxDecoration(color: Color(AppColors.secondaryButton), borderRadius: radius),
            child: Column(
              children: [
                Row(
                  children: [
                    _block(40, 40, radius: AppRadius.pill),
                    const Spacer(),
                    _block(120, 20, radius: AppRadius.sm),
                    const Spacer(),
                    _block(24, 24),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(child: _block(double.infinity, 40, radius: AppRadius.md)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _block(double.infinity, 40, radius: AppRadius.md)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _block(double.infinity, 40, radius: AppRadius.md)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _block(double.infinity, 40, radius: AppRadius.md)),
                  ],
                ),
              ],
            ),
          ),
          if (showTabs)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.page, 0),
              child: Container(
                height: 52,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.xl)),
                child: const ShimmerAnimatedLoading(),
              ),
            ),
          if (textLines > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.section * 1.5, AppSpacing.page, 0),
              child: Column(
                children: [
                  for (var i = 0; i < textLines; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: _Line(
                        width: i == textLines - 1 ? 160 : double.infinity,
                        height: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.page, 0),
            child: Column(
              children: [
                for (var i = 0; i < cards; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.cardGap),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _Line(width: 140, height: 14),
                        SizedBox(height: AppSpacing.sm),
                        _Line(width: double.infinity, height: 12),
                        SizedBox(height: AppSpacing.xs),
                        _Line(width: 200, height: 12),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final double width;
  final double height;
  const _Line({required this.width, required this.height});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.xs)),
        child: const ShimmerAnimatedLoading(),
      );
}
