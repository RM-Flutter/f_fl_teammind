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
        ? Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w500, color: const Color(AppColors.grey51))
        : Theme.of(context).textTheme.displaySmall;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            leftText ?? AppStrings.allNotifications.tr(),
            style: textStyle,
          ),
          gapW8,
          CustomSwitchButton(
            width: 60,
            height: 30,
            padding: 4,
            circleSize: 22,
            value: value,
            activeColor: const Color(0xFF3489EF),
            inactiveColor: const Color(AppColors.navyBlue),
            onChanged: onChanged,
          ),
          gapW8,
          Text(
            rightText ?? AppStrings.myDepartment.tr(),
            style: textStyle,
          ),

        ],
      ),
    );
  }
}
