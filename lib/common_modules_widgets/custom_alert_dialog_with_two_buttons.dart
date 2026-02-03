import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rmemp/constants/app_colors.dart';
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
      return AlertDialog(
        iconPadding:
            const EdgeInsets.only(right: 24, left: 24, bottom: 32, top: 32),
        titlePadding:
            const EdgeInsets.only(top: 24, right: 24, left: 24, bottom: 24),
        contentPadding: const EdgeInsets.only(bottom: 32, right: 24, left: 24),
        actionsPadding: const EdgeInsets.only(bottom: 18, right: 8, left: 8),
        contentTextStyle: Theme.of(builderContext).dialogTheme.contentTextStyle,
        icon: icon != null ? SvgPicture.asset(icon) : null,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(AppColors.dark),
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: Theme.of(builderContext).dialogTheme.contentTextStyle,
        ),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                  //   flex: 2,
                  child: CustomElevatedButton(
                titleSize: AppSizes.s12,
                title: actionLeftText,
                onPressed: () async {
                  if (builderContext.mounted) {
                    Navigator.of(builderContext, rootNavigator: true).pop();
                  }
                },
              )),
              const SizedBox(width: 8),
              Expanded(
                  //   flex: 2,
                  child: CustomElevatedButton(
                titleSize: AppSizes.s12,
                title: actionRightText,
                onPressed: () async {
                  await onRightActionPressed();
                  if (builderContext.mounted) {
                    Navigator.of(builderContext, rootNavigator: true).pop();
                  }
                },
              )),
            ],
          ),
          // SizedBox(height: 12),
          // Expanded(
          //   child: ButtonWidget(
          //     onPressed: () {},
          //     title: 'CLOSE',
          //   ),
          // ),
        ],
      );
    },
  );
}
