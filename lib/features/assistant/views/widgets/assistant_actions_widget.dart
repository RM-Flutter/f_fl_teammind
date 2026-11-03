import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app_test/core/constants/app_design.dart';

/// اتجاه النص من حروفه، لا من لغة الواجهة: رد إنجليزي داخل واجهة عربية يُكتب
/// من اليسار فلا تنتقل علامات الترقيم لبداية السطر.
TextDirection assistantTextDirection(String text) =>
    intl.Bidi.detectRtlDirectionality(text) ? TextDirection.rtl : TextDirection.ltr;

/// زر "افتح" صغير بلون الهوية (ثيم التطبيق يكبّر نص الأزرار).
class AssistantOpenButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AssistantOpenButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(AppColors.brandNavy),
        foregroundColor: Colors.white,
        minimumSize: const Size(0, AppButtonSize.compactHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppStyles.whiteContent(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.arrow_outward_rounded, size: 16),
      label: Text(AppStrings.assistantOpen.tr()),
    );
  }
}

/// اقتراح ("هل تقصد...") بنص صغير وحدود خفيفة.
class AssistantSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AssistantSuggestionChip({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onPressed,
      label: Text(label, textDirection: assistantTextDirection(label)),
      labelStyle: AppStyles.content(context).copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: const Color(AppColors.brandNavy),
      ),
      avatar: const Icon(Icons.help_outline_rounded, size: 16, color: Color(AppColors.brandBlue)),
      backgroundColor: Colors.white,
      side: BorderSide(color: const Color(AppColors.brandBlue).withValues(alpha: 0.35)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
