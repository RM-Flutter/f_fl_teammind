import 'package:app_test/core/constants/app_colors.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // floatingActionButton: const MainAppFabWidget(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedLabelStyle: Theme.of(context)
            .navigationBarTheme
            .labelTextStyle
            ?.resolve({WidgetState.selected})?.copyWith(
                color: Color(AppColors.dark)),
        unselectedLabelStyle: Theme.of(context)
            .navigationBarTheme
            .labelTextStyle
            ?.resolve({WidgetState.dragged}),
        selectedItemColor: Color(AppColors.dark),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: bottomNavigationBarItems.map((element) {
          return BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: SvgPicture.asset(
                element.icon,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.tertiary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color(AppColors.dark),
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(element.icon),
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
