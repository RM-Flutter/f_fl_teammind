import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/full_image_screen.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/models/settings/user_settings_2.model.dart';
class EmployeeDetailsHeader extends StatelessWidget {
  const EmployeeDetailsHeader({
    super.key,
    required this.employee,
  });

  final EmployeeProfileModel? employee;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: LayoutService.getWidth(context),
      decoration: BoxDecoration(
        color: Color(AppColors.dark),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s32),
            bottomRight: Radius.circular(AppSizes.s32)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.s32),
                bottomRight: Radius.circular(AppSizes.s32)),
            child: Image.asset(
              "assets/images/profile-app-bar.png",
              fit: BoxFit.cover,
              alignment: const Alignment(0.5, 0.0),
              width: double.infinity,
              height: 350,
            ),
          ),
          Column(
            children: [
              AppBarWithBookmark(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: AppStrings.employeeInfo.tr(),
                titleStyle: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                centerTitle: true,
                routeName: AppRoutes.employeeDetails.name,
                defaultTitle: AppStrings.employeeInfo.tr(),
                bookmarkIconColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(AppSizes.s10),
                  child: InkWell(
                    onTap: () => context.pop(),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2)),
                      child: const Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.white,
                        size: AppSizes.s18,
                      ),
                    ),
                  ),
                ),
              ),
              gapH12,
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: kIsWeb ? 1100 : double.infinity
                  ),
                  child: Column(
                    children: [
                      employee?.avatar != null
                          ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageViewer(
                                initialIndex: 0,
                                imageUrls: [""],
                                one: true,
                                url: false,
                                image: employee!.avatar!,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(85),
                          child: CachedNetworkImage(
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            imageUrl: employee!.avatar!,
                            placeholder: (context, url) =>
                            const ShimmerAnimatedLoading(),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image_not_supported_outlined,
                              size: AppSizes.s32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                          : CircleAvatar(
                        radius: 50,
                        child: Image.asset(
                          AppImages.profilePlaceHolder,
                          fit: BoxFit.cover,
                        ),
                      ),
                      gapH12,
                      Text(
                        employee?.name ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        employee?.jobTitle?.toUpperCase() ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600),
                      ) ,
                      if(employee?.department != null && employee?.department!.isNotEmpty == true) Text(
                        "${AppStrings.department.tr()}: ${employee!.department!.toUpperCase()}",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w400),
                      ) ,
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
