import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';

import '../../../constants/app_sizes.dart';

class GradientBgImage extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const GradientBgImage({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(AppColors.pinkLight).withOpacity(0.03),
            Color(AppColors.blueLight).withOpacity(0.03)
          ],
        ),
      ),
      child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                  horizontal: AppSizes.s24, vertical: AppSizes.s24),
          child: child),
    );
  }
}
