import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';

/// The single action of a bottom sheet (Save Changes, Submit): centered, navy
/// ([AppColors.secondaryButton]), 60% of the sheet and never wider than 320, with the button's own
/// loading state while [onPressed] runs.
class AppSheetSubmitButton extends StatelessWidget {
  final String title;
  final Future<void> Function() onPressed;

  const AppSheetSubmitButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320, minWidth: 180),
          child: CustomElevatedButton(
            title: title,
            width: double.infinity,
            backgroundColor: Color(AppColors.secondaryButton),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
