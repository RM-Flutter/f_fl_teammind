import 'package:flutter/material.dart';
import '../../../../../../../../../core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';

class CVInfoItem extends StatelessWidget {
  final String label;
  final String? value;
  final bool isRequired;
  final String? hint;
  final IconData? icon;

  const CVInfoItem({
    super.key,
    required this.label,
    this.value,
    this.isRequired = false,
    this.hint,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: AppBorders.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: label),
                      if (isRequired)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (value != null && value!.isNotEmpty)
            Text(
              value!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (hint != null)
            Text(
              hint!,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Text(
              "-",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
            ),
        ],
      ),
    );
  }
}
