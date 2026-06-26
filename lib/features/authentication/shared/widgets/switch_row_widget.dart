import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import 'custom_switch_button.dart';


class SwitchRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? rightText;
  final String? leftText;
  final bool? viewPhone;
  final bool? isLoginPageStyle;
  final MainAxisAlignment? axis;
  const SwitchRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.viewPhone = true,
    this.rightText,
    this.leftText,
    this.axis,
    this.isLoginPageStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isLoginPageStyle == true
        ? AppStyles.whiteHeading(context)
        .copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w500)
        : AppStyles.subTitleContent(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: axis ?? MainAxisAlignment.center,
        children: [
          Text(
            leftText ?? AppStrings.byEmail.tr(),
            style: textStyle,
          ),
          SizedBox(width: kIsWeb ? AppSizes.s8 : AppSizes.s8.w),
          CustomSwitchButton(
            width: kIsWeb ? AppSizes.s50 : AppSizes.s50.w,
            height: kIsWeb ? AppSizes.s20 : AppSizes.s20.h,
            padding: AppSizes.s3,
            value: value,
            inactiveColor: Color(AppColors.tabInactive),
            onChanged: onChanged,
          ),
          if(viewPhone == true)  SizedBox(width: kIsWeb ? AppSizes.s8 : AppSizes.s8.w),
          if(viewPhone == true)  Text(
            rightText ?? AppStrings.byPhone.tr(),
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
