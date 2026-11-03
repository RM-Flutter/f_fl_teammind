import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_design.dart';

/// The standard card of the app: white, 12px corners, one soft shadow, 16px padding.
/// Use it instead of hand-made Container/BoxDecoration cards so every screen matches.
///
/// [onTap] adds a ripple clipped to the card's corners.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? radius;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.cardPadding,
    this.margin,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final shape = radius ?? AppRadius.card;
    return Container(
      margin: margin,
      decoration: BoxDecoration(borderRadius: shape, boxShadow: AppShadows.card),
      child: Material(
        color: color ?? Color(AppColors.cardBackground),
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
