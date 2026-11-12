import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

/// Home header while loading: the real navy header (same colour, texture, corners and layout as
/// [HomeAppbarWidget]) with the shimmer blocks drawn on it where the avatar, name, actions and
/// request cards will be.
class HomeAppbarLoading extends StatelessWidget {
  const HomeAppbarLoading({super.key});

  /// Shimmer on a dark background: the same pulse, softer so it does not glare on the navy.
  static Widget _block({double? width, double? height, double? radius}) => Opacity(
        opacity: 0.28,
        child: ShimmerAnimatedLoading(width: width, height: height, circularRaduis: radius),
      );

  @override
  Widget build(BuildContext context) {
    const corners = BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl));
    final columns = LayoutService.columns(context, compact: 3, medium: 4, expanded: 6);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Color(AppColors.secondaryButton), borderRadius: corners),
      child: ClipRRect(
        borderRadius: corners,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset('assets/images/png/home-app-bar.png', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + AppSpacing.xs, bottom: AppSpacing.section),
              child: AppContentWidth(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _block(width: AppSizes.s40, height: AppSizes.s40, radius: AppSizes.s40),
                          gapW12,
                          _block(width: 160, height: AppSizes.s32, radius: AppRadius.sm),
                          const Spacer(),
                          _block(width: AppSizes.s40, height: AppSizes.s40, radius: AppSizes.s40),
                        ],
                      ),
                      const SizedBox(height: AppSizes.s32),
                      Row(
                        children: [
                          for (var i = 0; i < columns; i++) ...[
                            if (i > 0) const SizedBox(width: AppSpacing.md),
                            Expanded(child: _block(height: 128, radius: AppRadius.md)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
