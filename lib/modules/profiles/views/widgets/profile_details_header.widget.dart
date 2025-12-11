import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/modules/complain_screen/widget/full_image_screen.dart';
import 'package:rmemp/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../../../../common_modules_widgets/cached_network_image_widget.dart';
import '../../../../constants/app_images.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../general_services/layout.service.dart';
import '../../models/employee_profile.model.dart';

class EmployeeDetailsHeader extends StatelessWidget {
  const EmployeeDetailsHeader({
    super.key,
    required this.employee,
  });

  final EmployeeProfileModel? employee;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 302,
      width: LayoutService.getWidth(context),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/png/more_back.png"),
            fit: BoxFit.fill,
            opacity: 0.4),
        color: Color(AppColors.dark),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s28),
            bottomRight: Radius.circular(AppSizes.s28)),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              AppStrings.employeeInfo.tr(),
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
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
              constraints: BoxConstraints(
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
                        width: 85,
                        height: 85,
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
                    radius: AppSizes.s36,
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
                        fontSize: AppSizes.s20,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    employee?.jobTitle ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.s14,
                        fontWeight: FontWeight.w400),
                  ) ,
                 if(employee?.department != null && employee?.department!.isNotEmpty == true) Text(
                     "${AppStrings.department.tr()}: ${employee!.department!.toUpperCase() ?? ''}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.s14,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
