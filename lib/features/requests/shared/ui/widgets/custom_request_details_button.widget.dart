import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
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
        titleSize: 10.sp,
        width: width,
        buttonStyle: ElevatedButton.styleFrom(
          fixedSize: const Size(double.infinity, double.infinity),alignment: Alignment.center,
          shadowColor: Colors.transparent,
          backgroundColor:color?? Color(AppColors.secondaryButton),
          foregroundColor: color??Color(AppColors.secondaryButton),
          disabledForegroundColor: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        onPressed: onPressed,
        title: title,
        titleWidget: Text(
          title.toUpperCase(),
          style: AppStyles.whiteContent(context).copyWith(
            fontSize: 11.sp,
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