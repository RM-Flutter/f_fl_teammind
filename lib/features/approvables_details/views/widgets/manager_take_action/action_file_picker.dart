import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/constants/app_design.dart';

class ActionFilePicker extends StatelessWidget {
  final PlatformFile? selectedFile;
  final bool isArabic;
  final VoidCallback onTapPick;
  final VoidCallback onTapClear;

  const ActionFilePicker({
    super.key,
    required this.selectedFile,
    required this.isArabic,
    required this.onTapPick,
    required this.onTapClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'مرفق (اختياري)' : 'Attachment File (Optional)',
          style: AppStyles.darkContent(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.secondaryButton),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTapPick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, color: Color(AppColors.buttons)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedFile != null
                        ? selectedFile!.name
                        : (isArabic ? 'اضغط لإرفاق ملف' : 'Tap to attach file'),
                    style: AppStyles.darkContent(context).copyWith(
                      fontSize: 12,
                      color: Color(AppColors.secondaryButton),
                      fontWeight: selectedFile != null
                          ? FontWeight.bold
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selectedFile != null)
                  GestureDetector(
                    onTap: onTapClear,
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
