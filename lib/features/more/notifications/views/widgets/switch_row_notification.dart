import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';
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
        ? AppStyles.blackContent(context).copyWith(fontSize: 12)
        : AppStyles.blackContent(context).copyWith(fontSize: 12);

    // Every header row owns its 12 above (layout rule 8): app bar -> row, row -> row, row -> list.
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              leftText ?? AppStrings.allNotifications.tr(),
              style: textStyle,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppSizes.s8),
          CustomSwitchButton(
            width: 60,
            height: 30,
            padding: 4,
            circleSize: 22,
            value: value,
            activeColor: Color(AppColors.buttons),
            inactiveColor: const Color(AppColors.navyBlue),
            onChanged: onChanged,
          ),
          SizedBox(width: AppSizes.s8),
          Expanded(
            child: Text(
              rightText ?? AppStrings.myDepartment.tr(),
              style: textStyle,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
