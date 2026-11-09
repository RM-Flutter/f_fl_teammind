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
            // Photo stays visible at the top; a light tint there keeps the headline readable.
            colors: [
              base.withOpacity(0.12),
              base.withOpacity(0.18),
              base.withOpacity(0.55),
              base.withOpacity(0.88),
              base,
            ],
            stops: const [0.0, 0.4, 0.6, 0.82, 0.95],
          ),
        ),
      ),
    );
  }
}
