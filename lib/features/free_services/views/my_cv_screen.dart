import 'package:app_test/features/free_services/view_models/my_cv.viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'widgets/cv_tabs/cv_contact_tab.dart';
import 'widgets/cv_tabs/cv_education_tab.dart';
import 'widgets/cv_tabs/cv_job_info_tab.dart';
import 'widgets/cv_tabs/cv_personal_tab.dart';

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
            icon: Icon(Icons.arrow_back, color: Color(AppColors.dark)),
            onPressed: _goBack,
          ),
          title: AppStrings.myCV2.tr().toUpperCase(),
          titleStyle: TextStyle(
            color: Color(AppColors.dark),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          routeName: AppRoutes.myCVScreen.name,
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
                    child: Column(
                      children: [
                        if(selectIndex == 0) CVPersonalTab(cvData: viewModel.cvData),
                        if(selectIndex == 1) CVContactTab(cvData: viewModel.cvData),
                        if(selectIndex == 2) CVJobInfoTab(cvData: viewModel.cvData),
                        if(selectIndex == 3) CVEducationTab(cvData: viewModel.cvData),
                      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // // User Avatar
          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     Container(
          //       width: 80,
          //       height: 80,
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         border: Border.all(
          //           color: Color(AppColors.primary),
          //           width: 3,
          //         ),
          //       ),
          //       child: ClipOval(
          //         child: viewModel.getUserPhoto() != null
          //             ? CachedNetworkImage(
          //                 imageUrl: viewModel.getUserPhoto()!,
          //                 fit: BoxFit.cover,
          //                 width: 74,
          //                 height: 74,
          //                 placeholder: (context, url) => const CircularProgressIndicator(),
          //                 errorWidget: (context, url, error) => Container(
          //                   color: Color(AppColors.primary),
          //                   child: const Icon(
          //                     Icons.person,
          //                     color: Colors.white,
          //                     size: 40,
          //                   ),
          //                 ),
          //               )
          //             : Container(
          //                 color: Color(AppColors.primary),
          //                 child: const Icon(
          //                   Icons.person,
          //                   color: Colors.white,
          //                   size: 40,
          //                 ),
          //               ),
          //       ),
          //     ),
          //     // M Badge (like in design)
          //     Positioned(
          //       bottom: 0,
          //       right: 0,
          //       child: Container(
          //         width: 28,
          //         height: 28,
          //         decoration: const BoxDecoration(
          //           color: Color(0xFFFFD700),
          //           shape: BoxShape.circle,
          //         ),
          //         child: const Center(
          //           child: Text(
          //             'M',
          //             style: TextStyle(
          //               color: Colors.black,
          //               fontWeight: FontWeight.bold,
          //               fontSize: 14,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          //
          // gapH16,
          
          // Description Text
          Text(
            'Your CV Will Be Displayed For Free In Hundreds Of Egyptian And Saudi Companies Directly Within Their System',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.4,
            ),
          ),
          
          gapH12,
          
          // Learn More Link
          GestureDetector(
            onTap: () {
              // TODO: Navigate to opportunities page
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Learn More About The Opportunities',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.grey[700],
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
}

