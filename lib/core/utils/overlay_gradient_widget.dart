import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Fades the page photo into [AppColors.fadeColor] at the bottom. The photo
/// stays clear down to about 45 % of the height and the colour is solid by
/// about 95 % (Figma login page).
class OverlayGradientWidget extends StatelessWidget {
  const OverlayGradientWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Color(AppColors.fadeColor);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              base.withOpacity(0),
              base.withOpacity(0),
              base.withOpacity(0.45),
              base.withOpacity(0.85),
              base,
            ],
            stops: const [0.0, 0.45, 0.62, 0.82, 0.95],
          ),
        ),
      ),
    );
  }
}
