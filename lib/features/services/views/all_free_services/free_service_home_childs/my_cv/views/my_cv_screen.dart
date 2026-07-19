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
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyCVScreen extends StatefulWidget {
  const MyCVScreen({super.key});

  @override
  State<MyCVScreen> createState() => _MyCVScreenState();
}

class _MyCVScreenState extends State<MyCVScreen> with SingleTickerProviderStateMixin {
  late final MyCVViewModel viewModel;
  int selectIndex = 0;
  List<String> taps = [
    AppStrings.personal.tr().toUpperCase(),
    AppStrings.contact.tr().toUpperCase(),
    AppStrings.jopInfo.tr().toUpperCase(),
    AppStrings.education.tr().toUpperCase()
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpdateMyInfoScreen()),
    ).then((_) {
      // Reload CV data when returning from edit screen
      if (context.mounted) {
        viewModel.loadCVData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyCVViewModel>.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWithBookmark(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(AppColors.secondaryButton)),
            onPressed: _goBack,
          ),
          title: AppStrings.myCV2.tr().toUpperCase(),
          titleStyle: TextStyle(
            color: Color(AppColors.secondaryButton),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          routeName: AppRoutes.myCVScreen.name,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToEdit,
          backgroundColor: Color(AppColors.secondaryButton),
          icon: const Icon(Icons.edit, color: Colors.white),
          label: Text(
            AppStrings.edit.tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: Consumer<MyCVViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          const SizedBox(height: 80),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
         Text(
            AppStrings.cvDisplayedFreeCompanies.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          
          gapH12,
          
          // Learn More Link
          GestureDetector(
            onTap: () {
              context.pushNamed(
                AppRoutes.mediaCenterYoutubeScreenView.name,
                pathParameters: {
                  'lang': context.locale.languageCode,
                  'url': gCache['cvVideoUrl'].toString(),
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.learnMoreAboutOpportunities.tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return  Container(
      margin: EdgeInsets.zero, // ← key part
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton),
        borderRadius:
        BorderRadius.circular(
            AppSizes.s30),
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
          enableScroll: kIsWeb ? false : true,
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

