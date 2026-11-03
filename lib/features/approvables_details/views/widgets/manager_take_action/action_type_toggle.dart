import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/constants/app_design.dart';

class ActionTypeToggle extends StatelessWidget {
  final String selectedAction;
  final bool isArabic;
  final ValueChanged<String> onActionChanged;

  const ActionTypeToggle({
    super.key,
    required this.selectedAction,
    required this.isArabic,
    required this.onActionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('action_type'.tr(),
          style: AppStyles.darkContent(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.secondaryButton),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onActionChanged('approve'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedAction == 'approve'
                        ?  Color(AppColors.successGreen)
                        : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: selectedAction == 'approve'
                          ?  Color(AppColors.successGreen)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: selectedAction == 'approve'
                            ? Colors.white
                            : Color(AppColors.secondaryButton),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text('approve'.tr(),
                        style: AppStyles.whiteContent(context).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selectedAction == 'approve'
                              ? Colors.white
                              : Color(AppColors.secondaryButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => onActionChanged('refuse'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedAction == 'refuse'
                        ?  Color(AppColors.failureRed)
                        : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: selectedAction == 'refuse'
                          ?  Color(AppColors.failureRed)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: selectedAction == 'refuse'
                            ? Colors.white
                            : Color(AppColors.secondaryButton),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text('refuse'.tr(),
                        style: AppStyles.whiteContent(context).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selectedAction == 'refuse'
                              ? Colors.white
                              : Color(AppColors.secondaryButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
