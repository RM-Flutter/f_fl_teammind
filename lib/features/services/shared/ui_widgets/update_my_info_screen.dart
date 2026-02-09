import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/tab_bar_widget.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/cvs/views/taps/cv_personal_tab.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../cvs/controller/my_cv_controller.dart';
import '../../cvs/views/taps/cv_contact_tab.dart';
import '../../cvs/views/taps/cv_education_tab.dart';
import '../../cvs/views/taps/cv_job_info_tab.dart';

class UpdateMyInfoScreen extends StatefulWidget {
  const UpdateMyInfoScreen({super.key});

  @override
  State<UpdateMyInfoScreen> createState() => _UpdateMyInfoScreenState();
}

class _UpdateMyInfoScreenState extends State<UpdateMyInfoScreen> with SingleTickerProviderStateMixin {
  late final MyCVViewModel viewModel;
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
    viewModel = MyCVViewModel();
    viewModel.loadCVData(context);
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
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.dark),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
            onPressed: _goBack,
          ),
          title: AppStrings.updateMyInfo.tr(),
          titleStyle: TextStyle(
            color: Color(AppColors.dark),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          routeName: AppRoutes.updateMyInfoScreen.name,
        ),
        body: Consumer<MyCVViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // Tab Bar
                  SizedBox(height: 20,),
                  _buildTabBar(),

                  // Tab Content
                  Expanded(
                    child: Column(
                      children: [
                        if(selectIndex == 0) _buildEditablePersonalTab(viewModel),
                        if(selectIndex == 1) _buildEditableContactTab(viewModel),
                        if(selectIndex == 2) _buildEditableJobInfoTab(viewModel),
                        if(selectIndex == 3) _buildEditableEducationTab(viewModel),
                      ],
                    ),
                  ),

                  // Update Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Update CV data
                        if (viewModel.cvData != null) {
                          final success = await viewModel.updateCVData(context, viewModel.cvData!);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppStrings.updatedSuccessfully.tr())),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.dark),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        AppStrings.update.tr(),
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
    return  Container(
      margin: EdgeInsets.zero, // ← key part
      decoration: BoxDecoration(
        color: Color(AppColors.dark),
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

  Widget _buildEditablePersonalTab(MyCVViewModel viewModel) {
    return CVPersonalTab(cvData: viewModel.cvData);
  }

  Widget _buildEditableContactTab(MyCVViewModel viewModel) {
    return CVContactTab(cvData: viewModel.cvData);
  }

  Widget _buildEditableJobInfoTab(MyCVViewModel viewModel) {
    return CVJobInfoTab(cvData: viewModel.cvData);
  }

  Widget _buildEditableEducationTab(MyCVViewModel viewModel) {
    return CVEducationTab(cvData: viewModel.cvData);
  }
}
