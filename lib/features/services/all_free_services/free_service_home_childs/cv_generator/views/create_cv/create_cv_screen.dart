import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart' show AppSizes;
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/tab_bar_widget.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/all_free_services/free_service_home_childs/cv_generator/views/common_ui/create_cv_contact_tab.dart';
import 'package:app_test/features/services/all_free_services/free_service_home_childs/cv_generator/views/common_ui/create_cv_education_tab.dart';
import 'package:app_test/features/services/all_free_services/free_service_home_childs/cv_generator/views/common_ui/create_cv_job_info_tab.dart';
import 'package:app_test/features/services/all_free_services/free_service_home_childs/cv_generator/views/common_ui/create_cv_personal_tab.dart';
import 'package:app_test/features/services/view_models/create_cv_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CreateCVScreen extends StatefulWidget {
  const CreateCVScreen({super.key});

  @override
  State<CreateCVScreen> createState() => _CreateCVScreenState();
}

class _CreateCVScreenState extends State<CreateCVScreen> {
  late final CreateCVViewModel viewModel;
  int selectIndex = 0;
  List<String> taps = [
    AppStrings.personal.tr().toUpperCase(),
    AppStrings.contact.tr().toUpperCase(),
    AppStrings.jopInfo.tr().toUpperCase(),
    AppStrings.education.tr().toUpperCase()
  ];

  @override
  void initState() {
    super.initState();
    viewModel = CreateCVViewModel();
    viewModel.loadReferenceData(context);
  }

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _submitCV() async {
    final success = await viewModel.submitCV(context);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.cvCreatedSuccessfully.tr()),
          backgroundColor: Colors.green,
        ),
      );
      _goBack();
    } else if (context.mounted && viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? AppStrings.failedToCreateCV.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateCVViewModel>.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWithBookmark(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.titleText),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
            onPressed: _goBack,
          ),
          title: AppStrings.createCV.tr(),
          titleStyle: TextStyle(
            color: Color(AppColors.titleText),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          routeName: AppRoutes.cvGeneratorScreen.name,
        ),
        body: Consumer<CreateCVViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // Tab Bar
                  const SizedBox(height: 20),
                  _buildTabBar(),

                  // Tab Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (selectIndex == 0) CreateCVPersonalTab(viewModel: viewModel),
                          if (selectIndex == 1) CreateCVContactTab(viewModel: viewModel),
                          if (selectIndex == 2) CreateCVJobInfoTab(viewModel: viewModel),
                          if (selectIndex == 3) CreateCVEducationTab(viewModel: viewModel),
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: viewModel.isSubmitting ? null : _submitCV,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.titleText),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: viewModel.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              AppStrings.submitCV.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Color(AppColors.titleText),
        borderRadius: BorderRadius.circular(AppSizes.s30),
      ),
      height: AppSizes.s55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.s6,
        vertical: AppSizes.s6,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
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

