import 'package:app_test/core/widgets/app_intro_banner.widget.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_screen_shimmers.dart';
import 'package:app_test/core/widgets/app_fab.widget.dart';
import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/utils/tab_bar_widget.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/views/taps/cv_contact_tab.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/views/taps/cv_education_tab.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/views/taps/cv_job_info_tab.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/views/taps/cv_personal_tab.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/controllers/my_cv_view_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/cv_generator/views/update_my_info/update_my_info_screen.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/cv_generator/views/create_cv/create_cv_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_design.dart';

class MyCVScreen extends StatefulWidget {
  const MyCVScreen({super.key});

  @override
  State<MyCVScreen> createState() => _MyCVScreenState();
}

class _MyCVScreenState extends State<MyCVScreen> with SingleTickerProviderStateMixin {
  late final MyCVViewModel viewModel;
  int selectIndex = 0;
  List<String> taps = [
    AppStrings.personal.tr(),
    AppStrings.contact.tr(),
    AppStrings.jopInfo.tr(),
    AppStrings.education.tr()
  ];

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    viewModel = MyCVViewModel();
    viewModel.loadCVData(context);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _navigateToEdit() {
    final bool hasRealCV = viewModel.cvData?.jobInfo?.jobId != null || 
                           (viewModel.cvData?.education?.isNotEmpty ?? false) || 
                           (viewModel.cvData?.jobInfo?.experiences?.isNotEmpty ?? false);

    if (!hasRealCV) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateCVScreen()),
      ).then((_) {
        if (context.mounted) viewModel.loadCVData(context);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UpdateMyInfoScreen()),
      ).then((_) {
        if (context.mounted) viewModel.loadCVData(context);
      });
    }
  }

  /// Same page as every other "Learn more" video: the full-screen player route.
  void _openVideo(String videoUrl) {
    final url = videoUrl.trim();
    if (url.isEmpty) return;
    context.pushNamed(
      AppRoutes.youtubeVideoScreen.name,
      pathParameters: {
        'lang': context.locale.languageCode,
        'url': Uri.encodeComponent(url),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyCVViewModel>.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: Color(AppColors.background),
        appBar: AppBarWithBookmark(
          backgroundColor: Color(AppColors.background),
          elevation: 0,
          leading: AppBackButton(onPressed: _goBack),
          title: AppStrings.myCV2.tr(),
          centerTitle: true,
          routeName: AppRoutes.myCVScreen.name,
        ),
        floatingActionButton: Consumer<MyCVViewModel>(
          builder: (context, viewModel, child) {
            final bool hasRealCV = viewModel.cvData?.jobInfo?.jobId != null || 
                                   (viewModel.cvData?.education?.isNotEmpty ?? false) || 
                                   (viewModel.cvData?.jobInfo?.experiences?.isNotEmpty ?? false);
            return AppFab(
              heroTag: 'my_cv_fab',
              onPressed: _navigateToEdit,
              tooltip: hasRealCV ? AppStrings.edit.tr() : AppStrings.createCV.tr(),
              icon: hasRealCV ? Icons.edit_outlined : null,
            );
          },
        ),
        body: Consumer<MyCVViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const AppFormShimmer(headerLines: 2, infoRows: 7);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
              child: Column(
                children: [
                  // Header Section
                  _buildHeaderSection(viewModel),

                  // Tab Bar
                  _buildTabBar(),

                  // Tab Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(selectIndex == 0) CVPersonalTab(cvData: viewModel.cvData),
                          if(selectIndex == 1) CVContactTab(cvData: viewModel.cvData),
                          if(selectIndex == 2) CVJobInfoTab(cvData: viewModel.cvData),
                          if(selectIndex == 3) CVEducationTab(cvData: viewModel.cvData),
                          // Extra space so FAB doesn't overlap last item
                          const SizedBox(height: AppSizes.s80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(MyCVViewModel viewModel) {
    final jsonString = CacheHelper.getString("USG");
    var gCache;
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.md),
      child: AppIntroBanner(
        description: AppStrings.cvDisplayedFreeCompanies.tr(),
        onLearnMore: () => _openVideo(gCache?['cvVideoUrl']?.toString() ?? ''),
      ),
    );
  }

  Widget _buildTabBar() {
    return  Container(
      margin: EdgeInsets.zero, // ← key part
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton),
        borderRadius:
        BorderRadius.circular(AppRadius.xl),
      ),
      height: AppSizes.s55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s6,
          vertical: AppSizes.s6),
      child: Align(
        alignment: Alignment.centerLeft, // FORCE alignment to start
        child: defaultTapBarItem(
          isVertical: false,
          items: taps,
          tapBarItemsWidth: MediaQuery.sizeOf(context).width * 0.95,
          selectIndex: selectIndex,
          enableScroll: true,
          onTapItem: (index) {
            setState(() {
              selectIndex = index;
            });
          },
        ),
      ),
    );
  }
}

