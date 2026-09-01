import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';

class ActionReplyField extends StatelessWidget {
  final TextEditingController controller;
  final bool isArabic;

  const ActionReplyField({
    super.key,
    required this.controller,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'ملاحظات / الرد (اختياري)' : 'Reply / Notes (Optional)',
          style: AppStyles.darkContent(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.secondaryButton),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: AppStyles.darkContent(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(AppColors.secondaryButton),
          ),
          decoration: InputDecoration(
            hintText: isArabic ? 'أدخل ملاحظاتك هنا...' : 'Enter your notes here...',
            hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 12),
            filled: true,
            fillColor: const Color(0xFFF3F3F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
