import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

/// Unified card wrapper (previously GlassmorphismCard) now delegating to the standard
/// app card style: white background, 12px radius, 12% grey border, and soft 3% shadow.
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;

  const GlassmorphismCard({
    Key? key,
    required this.child,
    this.blur = 10,
    this.opacity = 1.0,
    this.padding = AppSpacing.cardPadding,
    this.borderRadius,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0x1F9E9E9E),
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolvedRadius =
        borderRadius ?? BorderRadius.circular(AppRadius.md);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: resolvedRadius,
        border: AppBorders.card,
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}
