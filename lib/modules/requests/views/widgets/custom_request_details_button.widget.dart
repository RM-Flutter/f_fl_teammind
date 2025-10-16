import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_colors.dart';

import '../../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../../constants/app_sizes.dart';

class CustomRequestDetailsButton extends StatelessWidget {
  final String title;
  var color;
  final Future<void> Function() onPressed;
  final double? width;
   CustomRequestDetailsButton({
    super.key,
    this.width,
    this.color,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomElevatedButton(
        titleSize: AppSizes.s10,
        width: width,
        buttonStyle: ElevatedButton.styleFrom(
          fixedSize: const Size(double.infinity, double.infinity),alignment: Alignment.center,
          shadowColor: Colors.transparent,
          backgroundColor:color?? const Color(AppColors.dark),
          foregroundColor: color??const Color(AppColors.dark),
          disabledForegroundColor: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.s28),
          ),
        ),
        onPressed: onPressed,
        title: title,
      ),
    );
  }
}
