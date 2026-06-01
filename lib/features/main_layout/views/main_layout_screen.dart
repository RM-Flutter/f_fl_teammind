import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/features/main_layout/controllers/main_controller.dart';


class BottomNavigationBarModel {
  final String icon;
  final String title;

  BottomNavigationBarModel({required this.icon, required this.title});
}

final bottomNavigationBarItems = [
  BottomNavigationBarModel(
    icon: AppImages.homeBottomBarIcon,
    title: AppStrings.home,
  ),
  BottomNavigationBarModel(
    icon: AppImages.requestsBottomBarIcon,
    title: AppStrings.requests,
  ),
  BottomNavigationBarModel(
    icon: AppImages.fingerprintBottomBarIcon,
    title: AppStrings.fingerprint,
  ),
  BottomNavigationBarModel(
    icon: AppImages.notificationBottomBarIcon,
    title: AppStrings.notifications,
  ),
  BottomNavigationBarModel(
    icon: AppImages.moreBottomBarIcon,
    title: AppStrings.more,
  ),
];

class MainLayoutScreen extends StatelessWidget {
  final Widget child;
  final NavbarPages currentNavPage;
  const MainLayoutScreen(
      {super.key, required this.child, required this.currentNavPage});

  @override
  Widget build(BuildContext context) {
    // ConnectionsService.init();
    final viewModel = Provider.of<MainLayoutController>(context);
    viewModel.currentPage = currentNavPage;
    return Scaffold(
      backgroundColor: Color(AppColors.scaffoldBackGround),
      // floatingActionButton: const MainAppFabWidget(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(AppColors.navBar),
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedLabelStyle: AppStyles.titleTextContent(context).copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppStyles.titleTextContent(context).copyWith(
          fontSize: 10.sp,
        ),
        selectedItemColor: Color(AppColors.secondaryButton),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: bottomNavigationBarItems.map((element) {
          return BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
              child: SvgPicture.asset(
                element.icon,
                height: 24.r,
                width: 24.r,
                colorFilter: ColorFilter.mode(
                  Color(AppColors.tabInactive),
                  BlendMode.srcIn,
                ),
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color(AppColors.secondaryButton),
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(
                  element.icon,
                  height: 24.r,
                  width: 24.r,
                ),
              ),
            ),
            label: element.title.tr(),
          );
        }).toList(),
        currentIndex: viewModel.currentPage.index,
        onTap: (index) {
          viewModel.onItemTapped(
              context: context, page: NavbarPages.values[index]);
        },
      ),
      body: Builder(
        builder: (context) {
          return child;
        },
      ),

    );
  }
}
