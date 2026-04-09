import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../authentication/shared/widgets/custom_switch_button.dart';

class SwitchRowNotification extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? rightText;
  final String? leftText;
  final bool? isLoginPageStyle;

  const SwitchRowNotification({
    super.key,
    required this.value,
    required this.onChanged,
    this.rightText,
    this.leftText,
    this.isLoginPageStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isLoginPageStyle == true
        ? AppStyles.blackContent(context).copyWith(fontSize: 12.sp)
        : AppStyles.blackContent(context).copyWith(fontSize: 12.sp);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            leftText ?? AppStrings.allNotifications.tr(),
            style: textStyle,
          ),
          SizedBox(width: 8.w),
          CustomSwitchButton(
            width: 60.w,
            height: 30.h,
            padding: 4.r,
            circleSize: 22.r,
            value: value,
            activeColor:  Theme.of(context).colorScheme.primary,
            inactiveColor: const Color(AppColors.navyBlue),
            onChanged: onChanged,
          ),
          SizedBox(width: 8.w),
          Text(
            rightText ?? AppStrings.myDepartment.tr(),
            style: textStyle,
          ),

        ],
      ),
    );
  }
}
