import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';

class CVInfoItem extends StatelessWidget {
  final String label;
  final String? value;
  final bool isRequired;
  final String? hint;

  const CVInfoItem({
    super.key,
    required this.label,
    this.value,
    this.isRequired = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Color(AppColors.dark),
              fontSize: 13,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Color(AppColors.dark),
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (hint != null)
                    TextSpan(
                      text: ' $hint',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

