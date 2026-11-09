import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';

/// One pulsing placeholder block. Colours, speed and default corner come from [AppShimmer],
/// so every loading state in the app pulses the same way.
///
/// For a whole list of cards use [AppShimmerList] / [AppShimmerCard] instead of building
/// placeholders by hand.
class ShimmerAnimatedLoading extends StatefulWidget {
  final double? height, width, circularRaduis, maxHeight, maxWidth;

  const ShimmerAnimatedLoading(
      {super.key,
      this.height,
      this.width,
      this.circularRaduis,
      this.maxHeight,
      this.maxWidth});

  @override
  State<ShimmerAnimatedLoading> createState() => _ShimmerAnimatedLoadingState();
}

class _ShimmerAnimatedLoadingState extends State<ShimmerAnimatedLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _color;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: AppShimmer.period,
      vsync: this,
    )..repeat(reverse: true);
    _color = ColorTween(begin: AppShimmer.base, end: AppShimmer.highlight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (BuildContext context, Widget? child) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth ?? double.infinity,
            maxHeight: widget.maxHeight ?? double.infinity,
          ),
          height: widget.height,
          width: widget.width,
          padding: const EdgeInsets.all(AppSizes.s8),
          decoration: BoxDecoration(
              color: _color.value,
              borderRadius: BorderRadius.all(
                  Radius.circular(widget.circularRaduis ?? AppShimmer.radius))),
        );
      },
    );
  }
}
