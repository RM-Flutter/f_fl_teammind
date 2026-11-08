import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter/material.dart';

class CustomRequestsPageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final IconData icon;

  const CustomRequestsPageButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppButtonSize.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: AppButtonSize.padding,
          backgroundColor: Color(AppColors.buttons),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.whiteContent(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppButtonSize.fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
