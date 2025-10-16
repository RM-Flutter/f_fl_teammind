import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/cache_consts.dart';
import 'package:rmemp/constants/general_listener.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../constants/app_sizes.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/layout.service.dart';
import '../../../general_services/popup_offers_view.dart';
import '../../../services/requests.services.dart';
import '../../../utils/base_page/mobile.header.dart';
import '../../../utils/base_page/mobile.scaffold.dart';
import '../../../utils/general_screen_message_widget.dart';
import '../../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../view_models/home.viewmodel.dart';
import 'widgets/loading/home_appbar_loading.dart';
import 'widgets/loading/home_body_loading.dart';
import '../../../common_modules_widgets/main_app_fab_widget/main_app_fab.widget.dart';
import 'widgets/page_body_widgets/my_requests_widget.dart';
import 'widgets/page_body_widgets/notifications_section.dart';
import 'widgets/page_header_widgets/home_appbar.widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  {
  late final HomeViewModel viewModel;
  final generalListener = GeneralListener(); // instance

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel();
    CacheConsts.initUSG();
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
    }
    final popups = gCache?['popups'];
    if (popups != null && popups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        generalListener.startAll(context, "home", popups);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel()..getHome(context),
      child: CoreMobileScaffold(
        backgroundColor: Colors.white,
        controller: viewModel.homeScrollController,
        headers: [
          CoreHeader.transform(
            pinned: true,
            color: Colors.white,
            shrinkHeight: AppSizes.s140,
            expandedHeight: AppSizes.s300,
            shrinkChild: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) => HomeAppbarWidget(
                      requests: viewModel.myRequests,
                      isExpanded: false,
                    )),
            child: SingleChildScrollView(
                controller: viewModel.homeScrollController,
                child: Consumer<HomeViewModel>(
                    builder: (context, viewModel, child) => viewModel.isLoading
                        ? const HomeAppbarLoading()
                        : HomeAppbarWidget(
                            requests: viewModel.myRequests,
                          ))),
          )
        ],
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(
              horizontal:
                  LocalizationService.isArabic(context: context) ? 35 : 0),
          child: MainAppFabWidget(
            requests: false,
              viewRequest: true
          ),
        ),
          children: [
            Consumer<HomeViewModel>(
              builder: (context, viewModel, child) => viewModel.isLoading
                  ? const HomeLoadingPage()
                  : Padding(
                padding: const EdgeInsets.only(top: AppSizes.s12),
                child: Column(
                  children: [
                    if ((viewModel.myRequests == null) &&
                        (viewModel.myTeamRequests == null) &&
                        (viewModel.otherDepartmentRequests == null) &&
                        (viewModel.allCompanyRequests == null) &&
                        (viewModel.notifications == null))
                      NoExistingPlaceholderScreen(
                          height: LayoutService.getHeight(context) * 0.4,
                          title: AppStrings
                              .thereIsNoRequestsAndNotifications
                              .tr()),
                    GeneralScreenMessageWidget(screenId: '/'),
                    if (viewModel.myRequests != null &&
                        viewModel.myRequests?.isNotEmpty == true)
                      RequestsWidget(
                          requests: viewModel.myRequests!,
                          requestType: GetRequestsTypes.mine),
                    if (viewModel.myTeamRequests != null &&
                        viewModel.myTeamRequests?.isNotEmpty == true)
                      RequestsWidget(
                          requests: viewModel.myTeamRequests!,
                          requestType: GetRequestsTypes.myTeam),
                    if (viewModel.otherDepartmentRequests != null &&
                        viewModel.otherDepartmentRequests?.isNotEmpty == true)
                      RequestsWidget(
                          requests: viewModel.otherDepartmentRequests!,
                          requestType: GetRequestsTypes.otherDepartment),
                    gapH16,
                    if (viewModel.notifications != null &&
                        viewModel.notifications?.isNotEmpty == true)
                      NotificationsSection(
                          notifications: viewModel.notifications!)
                  ],
                ),
              ),
            )
          ],
      ),
    );
  }
}
