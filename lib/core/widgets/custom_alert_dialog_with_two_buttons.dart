import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../routing/app_router.dart';

import '../constants/app_sizes.dart';
import 'custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_design.dart';

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
  
  bool busy = false;

  // Close exactly this dialog. A plain pop() removes whatever route is on top, e.g. a loading
  // dialog opened by the action, which left this confirmation stuck in the middle of the screen.
  void closeDialog(ModalRoute<dynamic>? route) {
    if (route == null || !route.isActive) return;
    if (route.isCurrent) {
      route.navigator?.pop();
    } else {
      route.navigator?.removeRoute(route);
    }
  }

  return showDialog<void>(
    context: dialogContext,
    useRootNavigator: true, // Use root navigator to ensure it works in offline screen
    barrierDismissible: false,
    barrierColor: Theme.of(dialogContext).dialogTheme.barrierColor,
    builder: (BuildContext builderContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s24, vertical: AppSizes.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (icon != null) ...[
                  SvgPicture.asset(icon),
                  const SizedBox(height: AppSizes.s16),
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
                const SizedBox(height: AppSizes.s16),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: Theme.of(builderContext).dialogTheme.contentTextStyle ??
                      TextStyle(
                        color: Color(AppColors.black),
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: AppSizes.s24),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        width: double.infinity,
                        titleSize: AppSizes.s12,
                        title: actionLeftText,
                        onPressed: () async {
                          if (busy) return;
                          closeDialog(ModalRoute.of(builderContext));
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.s8),
                    Expanded(
                      child: CustomElevatedButton(
                        width: double.infinity,
                        titleSize: AppSizes.s12,
                        title: actionRightText,
                        onPressed: () async {
                          if (busy) return; // ignore double taps while the action runs
                          busy = true;
                          // Captured before the await: the action may push routes (loading, results) on top.
                          final route = ModalRoute.of(builderContext);
                          try {
                            await onRightActionPressed();
                          } finally {
                            closeDialog(route);
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
