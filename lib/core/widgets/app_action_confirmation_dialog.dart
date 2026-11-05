import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';

Future<bool?> showAppActionConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  Color? confirmColor,
  Color? iconBgColor,
  Color? iconColor,
  IconData icon = Icons.help_outline_rounded,
}) {
  final isArabic = LocalizationService.isArabic(context: context);
  final effectiveConfirmColor = confirmColor ?? Color(AppColors.buttons);
  final effectiveIconColor = iconColor ?? effectiveConfirmColor;
  final effectiveIconBgColor = iconBgColor ?? effectiveIconColor.withOpacity(0.1);

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon Badge
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: effectiveIconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: effectiveIconColor,
                  ),
                ),
                const SizedBox(height: 18),

                // Dialog Title (Navy - 100% visible and stylish)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.secondaryButton),
                    fontFamily: isArabic ? null : 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),

                // Dialog Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // Action Buttons
                Row(
                  children: [
                    // Cancel / تراجع Button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            backgroundColor: Colors.grey.shade50,
                            foregroundColor: Colors.grey.shade800,
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            cancelText ?? AppStrings.cancel.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Confirm / تأكيد Button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: effectiveConfirmColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            confirmText ?? (isArabic ? 'تأكيد' : 'Confirm'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
