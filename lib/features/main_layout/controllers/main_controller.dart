import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/more/views/notification/views/notification_screen.dart';
import 'package:app_test/core/routing/app_router.dart';
import '../../home/views/home_screen.dart';
import '../../more/views/more_screen.dart';


class MainLayoutController extends ChangeNotifier {
  NavbarPages currentPage = NavbarPages.home;
  int get pageIndex => NavbarPages.values.indexOf(currentPage);


  void onItemTapped({required BuildContext context, required NavbarPages page}) {
    if (page == currentPage) return;
    int oldIndex = pageIndex;
    int newIndex = NavbarPages.values.indexOf(page);
    currentPage = page;
    Offset begin = (newIndex > oldIndex)
        ? const Offset(1.0, 0.0)
        : const Offset(-1.0, 0.0);
    notifyListeners();
    _pushNamedToPage(context: context, page: page, begin: begin);
    return;
  }

  void _pushNamedToPage({
    required BuildContext context,
    required NavbarPages page,
    required Offset begin,
  }) {
    switch (page) {
      case NavbarPages.home:
        context.goNamed(AppRoutes.home.name,
            extra: begin,
            pathParameters: {'lang': context.locale.languageCode});
        return;
      case NavbarPages.fingerprint:
        context.goNamed(AppRoutes.fingerprint.name,
            extra: {'offset': begin},
            pathParameters: {'lang': context.locale.languageCode,
            });
        return;
      case NavbarPages.requests:
        context.goNamed(AppRoutes.requests.name,
            extra: begin, pathParameters: {
          'type': 'mine',
          'lang': context.locale.languageCode
        });
        return;
      case NavbarPages.notifications:
        context.goNamed(AppRoutes.notifications.name,
            extra: begin,
            pathParameters: {'lang': context.locale.languageCode});
        return;
      case NavbarPages.more:
        context.goNamed(AppRoutes.more.name,
            extra: begin,
            pathParameters: {'lang': context.locale.languageCode});
        return;
    }
  }
}
