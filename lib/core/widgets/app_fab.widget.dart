import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/services/app_theme_service.dart';

/// The one floating action button of the app: a round button with an icon only (layout rule 6).
/// Never an extended button with text; put the words in [tooltip], which screen readers use.
/// Without [icon] it shows the standard "+" image, the same as the Requests tab.
class AppFab extends StatelessWidget {
  final String heroTag;
  final String? tooltip;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppFab({
    super.key,
    required this.heroTag,
    required this.onPressed,
    this.tooltip,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = AppThemeService.colorPalette.fabIconColor.color;
    return FloatingActionButton(
      heroTag: heroTag,
      tooltip: tooltip,
      onPressed: onPressed,
      backgroundColor: Color(AppColors.buttons),
      child: icon != null
          ? Icon(icon, color: iconColor, size: 22)
          : Image.asset(
              AppImages.addFloatingActionButtonIcon,
              color: iconColor,
              width: 16,
              height: 16,
            ),
    );
  }
}
