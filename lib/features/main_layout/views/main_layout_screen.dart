import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';
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


import 'package:app_test/core/helpers/package_helper.dart';
import 'package:app_test/features/assistant/views/widgets/assistant_wake_host_widget.dart';

class BottomNavigationBarModel {
  final String icon;
  final String title;
  final NavbarPages page;

  BottomNavigationBarModel({required this.icon, required this.title, required this.page});
}

List<BottomNavigationBarModel> getBottomNavigationBarItems() {
  return [
    BottomNavigationBarModel(
      icon: AppImages.homeBottomBarIcon,
      title: AppStrings.home,
      page: NavbarPages.home,
    ),
    if (PackageHelper.hasPackage('emp-requests'))
      BottomNavigationBarModel(
        icon: AppImages.requestsBottomBarIcon,
        title: AppStrings.requests,
        page: NavbarPages.requests,
      ),
    if (PackageHelper.hasPackage('fingerprint-sys'))
      BottomNavigationBarModel(
        icon: AppImages.fingerprintBottomBarIcon,
        title: AppStrings.fingerprint,
        page: NavbarPages.fingerprint,
      ),
    BottomNavigationBarModel(
      icon: AppImages.notificationBottomBarIcon,
      title: AppStrings.notifications,
      page: NavbarPages.page,
    ),
    BottomNavigationBarModel(
      icon: AppImages.moreBottomBarIcon,
      title: AppStrings.more,
      page: NavbarPages.more,
    ),
  ];
}

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
    final items = getBottomNavigationBarItems();
    final currentIndex = items.indexWhere((item) => item.page == viewModel.currentPage);
    // Wide windows (tablet landscape, desktop, web): side rail instead of the bottom bar.
    final useRail = LayoutService.isExpanded(context);
    final pageBody = AssistantWakeHost(
      child: Builder(
        builder: (context) {
          return child;
        },
      ),
    );
    return Scaffold(
      backgroundColor: Color(AppColors.scaffoldBackGround),
      // floatingActionButton: const MainAppFabWidget(),
      bottomNavigationBar: useRail ? null : BottomNavigationBar(
        backgroundColor: Color(AppColors.navBar),
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedLabelStyle: AppStyles.titleTextContent(context).copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppStyles.titleTextContent(context).copyWith(
          fontSize: 10,
        ),
        selectedItemColor: Color(AppColors.secondaryButton),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: getBottomNavigationBarItems().map((element) {
          return BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8, bottom: 12),
              child: SvgPicture.asset(
                element.icon,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  Color(AppColors.tabInactive),
                  BlendMode.srcIn,
                ),
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 8, bottom: 12),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color(AppColors.secondaryButton),
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(
                  element.icon,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            label: element.title.tr(),
          );
        }).toList(),
        currentIndex: getBottomNavigationBarItems().indexWhere((item) => item.page == viewModel.currentPage) == -1 
            ? 0 
            : getBottomNavigationBarItems().indexWhere((item) => item.page == viewModel.currentPage),
        onTap: (index) {
          viewModel.onItemTapped(
              context: context, page: getBottomNavigationBarItems()[index].page);
        },
      ),
      body: useRail
          ? Row(
              children: [
                NavigationRail(
                  backgroundColor: Color(AppColors.navBar),
                  minWidth: AppSizes.navRailWidth,
                  labelType: NavigationRailLabelType.all,
                  selectedIndex: currentIndex == -1 ? 0 : currentIndex,
                  selectedIconTheme:
                      IconThemeData(color: Color(AppColors.secondaryButton)),
                  selectedLabelTextStyle: AppStyles.titleTextContent(context).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.secondaryButton),
                  ),
                  unselectedLabelTextStyle:
                      AppStyles.titleTextContent(context).copyWith(fontSize: 10),
                  onDestinationSelected: (index) => viewModel.onItemTapped(
                      context: context, page: items[index].page),
                  destinations: items.map((element) {
                    return NavigationRailDestination(
                      icon: SvgPicture.asset(
                        element.icon,
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                            Color(AppColors.tabInactive), BlendMode.srcIn),
                      ),
                      selectedIcon: SvgPicture.asset(
                        element.icon,
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                            Color(AppColors.secondaryButton), BlendMode.srcIn),
                      ),
                      label: Text(element.title.tr()),
                    );
                  }).toList(),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: pageBody),
              ],
            )
          : pageBody,
    );
  }
}
