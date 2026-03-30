import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:flutter/material.dart';

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
          backgroundColor:color?? Color(AppColors.dark),
          foregroundColor: color??Color(AppColors.dark),
          disabledForegroundColor: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.s28),
          ),
        ),
        onPressed: onPressed,
        title: title,
        titleWidget: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}