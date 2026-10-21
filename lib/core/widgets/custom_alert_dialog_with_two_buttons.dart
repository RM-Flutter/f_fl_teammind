import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../routing/app_router.dart';

import '../constants/app_sizes.dart';
import 'custom_elevated_button.widget.dart';

Future<void> customAlertDialogWithTwoButtons(
  BuildContext context, {
  String? icon,
  required String title,
  required String content,
  required String actionLeftText,
  required VoidCallback onLeftActionPressed,
  required String actionRightText,
  required onRightActionPressed,
  Color? actionRightColor,
  Color? actionLeftColor,
}) async {
  // Use rootNavigatorKey.currentContext if context is not mounted
  final dialogContext = rootNavigatorKey.currentContext ?? context;
  if (!dialogContext.mounted) {
    debugPrint("❌ Dialog context not mounted");
    return;
  }
  
  return showDialog<void>(
    context: dialogContext,
    useRootNavigator: true, // Use root navigator to ensure it works in offline screen
    barrierDismissible: false,
    barrierColor: Theme.of(dialogContext).dialogTheme.barrierColor,
    builder: (BuildContext builderContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (icon != null) ...[
                  SvgPicture.asset(icon),
                  const SizedBox(height: 16),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(AppColors.secondaryButton),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: Theme.of(builderContext).dialogTheme.contentTextStyle ??
                      TextStyle(
                        color: Color(AppColors.black),
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        width: double.infinity,
                        titleSize: AppSizes.s12,
                        title: actionLeftText,
                        onPressed: () async {
                          if (builderContext.mounted) {
                            Navigator.of(builderContext, rootNavigator: true).pop();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomElevatedButton(
                        width: double.infinity,
                        titleSize: AppSizes.s12,
                        title: actionRightText,
                        onPressed: () async {
                          await onRightActionPressed();
                          if (builderContext.mounted) {
                            Navigator.of(builderContext, rootNavigator: true).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
