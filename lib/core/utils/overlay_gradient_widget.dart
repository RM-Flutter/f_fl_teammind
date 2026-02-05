import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class OverlayGradientWidget extends StatelessWidget {
  const OverlayGradientWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(AppColors.dark).withOpacity(0.5),
            Color(AppColors.dark),
          ],
        ),
      ),
    );
  }
}
