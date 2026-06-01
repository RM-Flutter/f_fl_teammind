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

    return Column(
      children: [
        SizedBox(height: (kIsWeb || PlatformIs.web) ? 30 : 25),
        Container(
          padding: EdgeInsets.only(
            bottom: (kIsWeb || PlatformIs.web) ? AppSizes.s48 : AppSizes.s16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomElevatedButton(
                width: AppSizes.s290.w,
                title: AppStrings.createNewAccount.tr(),
                isFuture: false,
                onPressed: () => viewModel.showCreateAccountModal(context: context),
                buttonStyle: ElevatedButton.styleFrom(
                  shadowColor: Color(AppColors.shadow),
                  foregroundColor: Color(0xffffffff),
                  backgroundColor: Colors.transparent,
                  elevation: 2,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.s28.r),
                    side: BorderSide(
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
                titleWidget: Text(
                  AppStrings.createNewAccount.tr(),
                  style: AppStyles.titleTextContent(context).copyWith(
                    color: Color(0xffffffff),
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
