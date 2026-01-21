import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_strings.dart';
import '../../../routing/app_router.dart';
import '../view_models/main_viewmodel.dart';

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

class MainScreen extends StatelessWidget {
  final Widget child;
  final NavbarPages currentNavPage;
  const MainScreen(
      {super.key, required this.child, required this.currentNavPage});

  @override
  Widget build(BuildContext context) {
    // ConnectionsService.init();
    final viewModel = Provider.of<MainScreenViewModel>(context);
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
            ?.resolve({WidgetState.selected}),
        unselectedLabelStyle: Theme.of(context)
            .navigationBarTheme
            .labelTextStyle
            ?.resolve({WidgetState.dragged}),
        selectedItemColor: Theme.of(context).colorScheme.secondary,
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
                  Theme.of(context).colorScheme.secondary,
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
      body: SafeArea(child: child),
    );
  }
}
