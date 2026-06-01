import 'dart:convert';
import 'package:app_test/features/services/views/all_free_services/free_service_home_widgets/free_service_grid/services_grid_widget.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_widgets/free_service_more/widgets/free_services_header_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/base_page/mobile.scaffold.dart';
import 'package:app_test/core/utils/base_page/mobile_header.dart';
import 'package:app_test/core/widgets/webview_offers.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/notifications_section.dart';
import 'package:app_test/features/services/controllers/free_services_view_model.dart';
import 'package:app_test/features/more/notifications/views/notification_screen.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';


class FreeServicesHomeScreen extends StatefulWidget {
  const FreeServicesHomeScreen({super.key});

  @override
  State<FreeServicesHomeScreen> createState() => _FreeServicesHomeScreenState();
}

class _FreeServicesHomeScreenState extends State<FreeServicesHomeScreen> {
  late final FreeServicesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = FreeServicesViewModel();
    viewModel.loadHomeData(context);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }


  String? _getUserPhotoUrl() {
    var jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      var cache = json.decode(jsonString) as Map<String, dynamic>;
      return cache['photo'];
    }
    return null;
  }

  void _handleServiceTap(String serviceId) {
    // Handle service navigation based on serviceId
    debugPrint('Service tapped: $serviceId');
    switch (serviceId) {
      case 'my_cv':
        // Navigate to CV screen
        context.pushNamed(
          AppRoutes.myCVScreen.name,
          pathParameters: {'lang': context.locale.languageCode},
        );
        break;
      case 'smart_card':
        // Navigate to Smart Card screen
        context.pushNamed(
          AppRoutes.smartCardScreen.name,
          pathParameters: {'lang': context.locale.languageCode},
        );
        break;
      case 'cv_generator':
        // Navigate to CV Generator screen
        context.pushNamed(
          AppRoutes.cvGeneratorScreen.name,
          pathParameters: {'lang': context.locale.languageCode},
        );
        break;
      case 'salary_calc':
        // Navigate to Vacation Calculator screen (used for salary calculations)
       Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewStackOffers(
              '${AppConstants.base}/front-end/job-offer-calculator',
            ),
          ),
        );
        break;
      case 'premium_templates':
        // Navigate to Premium Templates screen
        context.pushNamed(
          AppRoutes.premiumTemplatesScreen.name,
          pathParameters: {'lang': context.locale.languageCode},
        );
        break;
      case 'vacation_calc':
        // Navigate to Vacation Calculator screen
        context.pushNamed(
          AppRoutes.vacationCalcScreen.name,
          pathParameters: {'lang': context.locale.languageCode},
        );
        break;
      case 'personality_test':
        // Navigate to Personality Test screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewStackOffers(
              '${AppConstants.base}/frontend/personality-test',
            ),
          ),
        );
        // context.pushNamed(
        //   AppRoutes.personalityTestScreen.name,
        //   pathParameters: {'lang': context.locale.languageCode},
        // );
        break;
      case 'team_mind_system':
        // Navigate to About Team Mind screen
        context.pushNamed(
          AppRoutes.aboutTeamMindScreen.name,
          pathParameters: {'lang': context.locale.languageCode},
        );
        break;
      case 'job_offer_generator':
        // Open Job Offer Calculator in WebView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewStackOffers(
              '${AppConstants.base}/front-end/job-offer-calculator',
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FreeServicesViewModel>.value(
      value: viewModel,
      child: RefreshIndicator(
        onRefresh: () async {
          try {
            await viewModel.loadHomeData(context);
          } catch (_) {}
          await Future.delayed(const Duration(milliseconds: 200));
        },
        child: CoreMobileScaffold(
          backgroundColor: Colors.white,
          controller: viewModel.scrollController,
          headers: [
            CoreHeader.transform(
              pinned: true,
              color: Colors.white,
              shrinkHeight: AppSizes.s140,
              expandedHeight: AppSizes.s200,
              shrinkChild: const FreeServicesHeaderWidget(isExpanded: false),
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: FreeServicesHeaderWidget(isExpanded: true),
              ),
            ),
          ],
          children: [
            Consumer<FreeServicesViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: AppSizes.s12),
                  child: Column(
                    children: [
                      // Services Grid
                      ServicesGridWidget(
                        userPhotoUrl: _getUserPhotoUrl(),
                        onServiceTap: _handleServiceTap,
                      ),

                      gapH16,

                      // Ad Banner
                      // const AdBannerWidget(),
                      //
                      // gapH16,

                      // Notifications Section (only for logged-in users)
                      if (!viewModel.isVisitor) ...[
                        if (viewModel.notifications != null &&
                            viewModel.notifications?.isNotEmpty == true)
                          NotificationsSection(
                            notifications: viewModel.notifications!,
                            isFreeService: true,
                          )
                        else
                          Container(
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.s12,
                              vertical: AppSizes.s20,
                            ),
                            color: Color(AppColors.secondaryButton),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppStrings.myNotifications.tr(),
                                      style: TextStyle(
                                        color: Color(AppColors.pink),
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const NotificationScreen(true),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppStrings.viewAll.tr(),
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Center(
                                  child: Text(
                                    AppStrings.thereIsNoNotifications.tr(),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
