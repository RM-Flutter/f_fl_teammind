import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/full_image_screen.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:app_test/core/models/settings/user_settings_2.model.dart';
class EmployeeDetailsHeader extends StatelessWidget {
  const EmployeeDetailsHeader({
    super.key,
    required this.employee,
  });

  final EmployeeProfileModel? employee;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350.h,
      width: LayoutService.getWidth(context),
      decoration: BoxDecoration(
        color: Color(AppColors.titleText),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s32.r),
            bottomRight: Radius.circular(AppSizes.s32.r)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.s32.r),
                bottomRight: Radius.circular(AppSizes.s32.r)),
            child: Image.asset(
              "assets/images/profile-app-bar.png",
              fit: BoxFit.cover,
              alignment: const Alignment(0.5, 0.0),
              width: double.infinity,
              height: 350.h,
            ),
          ),
          Column(
            children: [
              AppBarWithBookmark(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: AppStrings.employeeInfo.tr(),
                titleStyle: AppStyles.whiteHeading(context).copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
                centerTitle: true,
                routeName: AppRoutes.employeeDetails.name,
                defaultTitle: AppStrings.employeeInfo.tr(),
                bookmarkIconColor: Colors.white,
                leading: Padding(
                  padding: EdgeInsets.all(AppSizes.s10.r),
                  child: InkWell(
                    onTap: () => context.pop(),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2)),
                      child: Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.white,
                        size: AppSizes.s18.sp,
                      ),
                    ),
                  ),
                ),
              ),
              gapH12,
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: kIsWeb ? 1100.w : double.infinity
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
                          borderRadius: BorderRadius.circular(85.r),
                          child: CachedNetworkImage(
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                            imageUrl: employee!.avatar!,
                            placeholder: (context, url) =>
                            const ShimmerAnimatedLoading(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported_outlined,
                              size: AppSizes.s32.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                          : CircleAvatar(
                        radius: 50.r,
                        child: Image.asset(
                          AppImages.profilePlaceHolder,
                          fit: BoxFit.cover,
                        ),
                      ),
                      gapH12,
                      Text(
                        employee?.name ?? '',
                        style: AppStyles.whiteHeading(context).copyWith(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        employee?.jobTitle?.toUpperCase() ?? '',
                        style: AppStyles.whiteHeading(context).copyWith(
                            fontSize: 14.sp,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600),
                      ) ,
                      if(employee?.department != null && employee?.department!.isNotEmpty == true) Text(
                        "${AppStrings.department.tr()}: ${employee!.department!.toUpperCase()}",
                        style: AppStyles.whiteContent(context).copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14.sp,
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
