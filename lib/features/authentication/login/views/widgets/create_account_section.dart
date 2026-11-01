import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';

import '../../../../../core/platform/platform_is.dart';
import 'package:app_test/core/services/layout_service.dart';

/// Outlined "CREATE NEW ACCOUNT" pill. The login page pins it near the bottom
/// of the screen (Figma: 223 x 38 dp, 55 dp from the bottom).
class CreateAccountSection extends StatelessWidget {
  final Map<String, dynamic>? gCache;
  final AuthenticationController viewModel;

  const CreateAccountSection({
    super.key,
    required this.gCache,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (gCache == null || gCache?['can_new_register'] != true) {
      return const SizedBox.shrink();
    }

    final compact = LayoutService.isPhoneLayout(context);
    final isWeb = kIsWeb || PlatformIs.web;

    return CustomElevatedButton(
      width: compact
          ? AppSizes.createAccountWidth.w
          : (isWeb ? AppSizes.s290 : AppSizes.s290.w),
      height: compact ? AppSizes.createAccountHeight.h : null,
      title: AppStrings.createNewAccount.tr(),
      isFuture: false,
      onPressed: () => viewModel.showCreateAccountModal(context: context),
      buttonStyle: ElevatedButton.styleFrom(
        shadowColor: Color(AppColors.shadow),
        foregroundColor: const Color(0xffffffff),
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.s28.r),
          side: const BorderSide(color: Color(0xffffffff)),
        ),
      ),
      titleWidget: AutoSizeText(
        AppStrings.createNewAccount.tr().toUpperCase(),
        maxLines: 1,
        minFontSize: 8,
        style: AppStyles.titleTextContent(context).copyWith(
          color: const Color(0xffffffff),
          fontWeight: FontWeight.w400,
          fontSize: isWeb ? 14 : 12.sp,
        ),
      ),
    );
  }
}
