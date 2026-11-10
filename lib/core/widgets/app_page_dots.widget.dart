import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:flutter/material.dart';

/// Page indicator of a carousel: the current page is a longer pill in the brand colour, the
/// others are small grey dots. Moves smoothly with [AppMotion].
class AppPageDots extends StatelessWidget {
  final int count;
  final int index;
  const AppPageDots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.enter,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            color: active ? Color(AppColors.buttons) : Colors.grey[300],
          ),
        );
      }),
    );
  }
}
