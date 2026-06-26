import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';
import '../../controllers/personal_profile_controller.dart';
import 'personal_profile_header.widget.dart';

class PersonalProfileShrinkedHeaderWidget extends StatelessWidget {
  const PersonalProfileShrinkedHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalProfileController>(
      builder: (context, viewModel, child) => Stack(
        children: [
          PersonalProfileHeaderBackgroundWidget(
            headerImage: AppImages.companyInfoBackground,
            backgroundHeight: AppSizes.s140,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSizes.s12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.s12),
              width: 1.sw,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFA3A3A3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.s15),
                      ),
                      child: Center(
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon:  Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: AppSizes.s18,
                          ),
                        ),
                      )),
                   Text(
                    AppStrings.accountAndSettings.tr(),
                    style: AppStyles.whiteContent(context).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: AppSizes.s14,
                      letterSpacing: 1.4,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFA3A3A3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.s15),
                      ),
                      child: Center(
                        child: IconButton(
                          onPressed: () async =>
                              await viewModel.logout(context: context),
                          icon:  Icon(
                            Icons.logout_outlined,
                            color: Colors.red,
                            size: AppSizes.s18,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
