import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_sizes.dart';

import '../constants/app_colors.dart';

class GradientBgImage extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const GradientBgImage({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(AppColors.background),
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSizes.s24,
              vertical: AppSizes.s24,
            ),
        child: child,
      ),
    );
  }
}
